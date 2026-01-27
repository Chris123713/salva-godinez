--[[
    Mr. X Chaos Engine
    ==================
    Autonomous system for triggering HARM surprises on eligible players
    DISABLED BY DEFAULT - must be enabled via admin menu
]]

local Chaos = {}

-- Engine state
local ChaosEnabled = false
local ScanTimer = nil

-- Last surprise time per player
local LastSurprise = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, JsonEncode(data), source})
end

local function SendMessage(source, message)
    return exports['sv_mr_x']:SendMrXMessage(source, message)
end

local function RandomMessage(messageList)
    if not messageList or #messageList == 0 then return nil end
    return messageList[math.random(#messageList)]
end

local function FindPlayerSource(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

-- ============================================
-- ENGINE CONTROL
-- ============================================

---Start the chaos engine
function Chaos.Start()
    if Config.TestMode then
        print('^3[MR_X]^7 Chaos engine NOT started - TEST MODE active')
        return false
    end

    if ChaosEnabled then
        print('^3[MR_X]^7 Chaos engine already running')
        return true
    end

    ChaosEnabled = true

    -- Start scan timer
    ScanTimer = SetTimeout(Config.ChaosEngine.ScanIntervalMs, function()
        Chaos.ScanLoop()
    end)

    Log(MrXConstants.EventTypes.CHAOS_SCAN, nil, {action = 'started'})
    print('^2[MR_X]^7 Chaos engine started - scanning every ' .. (Config.ChaosEngine.ScanIntervalMs / 60000) .. ' minutes')

    return true
end

---Stop the chaos engine
function Chaos.Stop()
    ChaosEnabled = false

    if ScanTimer then
        -- Note: SetTimeout can't be canceled in FiveM, but flag prevents action
    end

    Log(MrXConstants.EventTypes.CHAOS_SCAN, nil, {action = 'stopped'})
    print('^3[MR_X]^7 Chaos engine stopped')

    return true
end

---Check if chaos engine is running
---@return boolean
function Chaos.IsRunning()
    return ChaosEnabled and not Config.TestMode
end

-- ============================================
-- SCANNING
-- ============================================

---Main scan loop
function Chaos.ScanLoop()
    if not ChaosEnabled or Config.TestMode then return end

    Chaos.Scan()

    -- Schedule next scan
    ScanTimer = SetTimeout(Config.ChaosEngine.ScanIntervalMs, function()
        Chaos.ScanLoop()
    end)
end

---Scan for chaos candidates
---@return table candidates Array of {citizenid, source, reasons}
function Chaos.Scan()
    local candidates = {}
    local players = GetPlayers()
    local criteria = Config.ChaosEngine.Criteria

    Log(MrXConstants.EventTypes.CHAOS_SCAN, nil, {playerCount = #players})

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookChaos('scan', nil, nil, {playerCount = #players})
    end

    for _, playerId in ipairs(players) do
        local source = tonumber(playerId)
        local player = exports.qbx_core:GetPlayer(source)

        if player then
            local citizenid = player.PlayerData.citizenid

            -- Skip exempt players - no HARM for them
            local isExempt = exports['sv_mr_x']:IsExempt(source)
            if isExempt then
                if Config.Debug then
                    print('^3[MR_X]^7 Chaos scan skipping exempt player: ' .. citizenid)
                end
                goto continue
            end

            local profile = exports['sv_mr_x']:GetProfile(citizenid)

            if profile then
                local reasons = {}

                -- Check low reputation
                if profile.reputation < criteria.LowRepThreshold then
                    table.insert(reasons, 'low_reputation')
                end

                -- Check recent failures
                local recentFailures = Chaos.CountRecentFailures(profile.history or {}, 24 * 3600)
                if recentFailures >= criteria.RecentFailures then
                    table.insert(reasons, 'recent_failures')
                end

                -- Check abandoned missions
                local abandoned = Chaos.CountAbandonedMissions(profile.history or {})
                if abandoned >= criteria.AbandonedMissions then
                    table.insert(reasons, 'abandoned_missions')
                end

                -- Check overdue loans
                local hasOverdueLoan = MySQL.single.await([[
                    SELECT 1 FROM mr_x_loans WHERE citizenid = ? AND status = 'overdue'
                ]], {citizenid})
                if hasOverdueLoan then
                    table.insert(reasons, 'overdue_loan')
                end

                if #reasons > 0 then
                    -- Check cooldown
                    if Chaos.CanSurprise(citizenid) then
                        table.insert(candidates, {
                            citizenid = citizenid,
                            source = source,
                            reasons = reasons
                        })
                    end
                end
            end

            ::continue::
        end
    end

    if Config.Debug then
        print('^3[MR_X]^7 Chaos scan found ' .. #candidates .. ' candidates')
    end

    -- Process candidates
    for _, candidate in ipairs(candidates) do
        Log(MrXConstants.EventTypes.CHAOS_CANDIDATE, candidate.citizenid, {
            reasons = candidate.reasons
        }, candidate.source)

        -- Roll dice to trigger surprise
        if math.random() < 0.3 then  -- 30% chance per scan
            Chaos.SelectAndTrigger(candidate.source, candidate.citizenid, candidate.reasons)
        end
    end

    return candidates
end

---Count recent failures in history
---@param history table
---@param maxAgeSec number
---@return number count
function Chaos.CountRecentFailures(history, maxAgeSec)
    local count = 0
    local now = os.time()

    for _, entry in ipairs(history) do
        if entry.outcome == 'failure' or entry.outcome == 'failed' then
            if entry.timestamp and (now - entry.timestamp) < maxAgeSec then
                count = count + 1
            end
        end
    end

    return count
end

---Count abandoned missions
---@param history table
---@return number count
function Chaos.CountAbandonedMissions(history)
    local count = 0

    for _, entry in ipairs(history) do
        if entry.outcome == 'abandoned' then
            count = count + 1
        end
    end

    return count
end

---Check if player can receive a surprise (cooldown)
---@param citizenid string
---@return boolean canSurprise
function Chaos.CanSurprise(citizenid)
    local last = LastSurprise[citizenid]
    if not last then return true end

    local elapsed = os.time() - last
    return elapsed >= Config.ChaosEngine.SurpriseCooldownSec
end

-- ============================================
-- SURPRISE SELECTION & TRIGGERING
-- ============================================

---Select and trigger an appropriate surprise
---@param source number
---@param citizenid string
---@param reasons table
function Chaos.SelectAndTrigger(source, citizenid, reasons)
    -- Select surprise type based on reasons and weights
    local surpriseType = Chaos.SelectSurpriseType(reasons)

    if surpriseType then
        Chaos.TriggerSurprise(source, citizenid, surpriseType)
    end
end

---Select a surprise type based on weights and reasons
---@param reasons table
---@return string|nil surpriseType
function Chaos.SelectSurpriseType(reasons)
    local weighted = {}

    -- Build weighted table from config
    for surpriseType, config in pairs(Config.Harm) do
        if config.weight and config.weight > 0 then
            -- Increase weight if reason matches
            local weight = config.weight
            for _, reason in ipairs(reasons) do
                if reason == 'low_reputation' and (surpriseType == 'FAKE_WARRANT' or surpriseType == 'ANONYMOUS_TIP') then
                    weight = weight * 1.5
                elseif reason == 'overdue_loan' and surpriseType == 'DEBT_COLLECTOR' then
                    weight = weight * 2.0
                elseif reason == 'recent_failures' and surpriseType == 'HIT_SQUAD' then
                    weight = weight * 1.3
                end
            end

            table.insert(weighted, {type = surpriseType, weight = weight})
        end
    end

    if #weighted == 0 then return nil end

    -- Calculate total weight
    local totalWeight = 0
    for _, item in ipairs(weighted) do
        totalWeight = totalWeight + item.weight
    end

    -- Random selection
    local roll = math.random() * totalWeight
    local cumulative = 0

    for _, item in ipairs(weighted) do
        cumulative = cumulative + item.weight
        if roll <= cumulative then
            return item.type
        end
    end

    return weighted[1].type
end

---Trigger a surprise on a player
---@param source number
---@param citizenid string
---@param surpriseType string
function Chaos.TriggerSurprise(source, citizenid, surpriseType)
    -- Check if player is exempt - no HARM for exempt players
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then
            print('^3[MR_X]^7 Blocked surprise for exempt player: ' .. citizenid)
        end
        return
    end

    -- Record timing
    LastSurprise[citizenid] = os.time()

    -- Send warning first
    local warningMsg = RandomMessage(MrXConstants.Messages.Warnings)
    SendMessage(source, warningMsg)

    Log(MrXConstants.EventTypes.SURPRISE_WARNING, citizenid, {
        surpriseType = surpriseType
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookChaos('warning', citizenid, surpriseType, nil)
    end

    -- Delay then execute
    SetTimeout(Config.ChaosEngine.WarningDelaySec * 1000, function()
        Chaos.ExecuteSurprise(source, citizenid, surpriseType)
    end)
end

---Execute a surprise
---@param source number
---@param citizenid string
---@param surpriseType string
function Chaos.ExecuteSurprise(source, citizenid, surpriseType)
    -- Verify player still online
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local success = false

    -- Execute based on type
    if surpriseType == 'FAKE_WARRANT' or surpriseType == 'FakeWarrant' then
        local warrantId = exports['sv_mr_x']:CreateFakeWarrant(citizenid, {
            title = 'Warrant for Arrest',
            description = 'Anonymous tip received. Subject wanted for questioning.',
            priority = 'medium'
        })
        success = warrantId ~= nil

    elseif surpriseType == 'FAKE_REPORT' or surpriseType == 'FakeReport' then
        local reportId = exports['sv_mr_x']:CreateFakeReport(citizenid, {
            title = 'Suspicious Activity',
            description = 'Subject observed in connection with ongoing criminal activity.'
        })
        success = reportId ~= nil

    elseif surpriseType == 'FAKE_CASE' or surpriseType == 'FakeCase' then
        local caseId = exports['sv_mr_x']:CreateFakeCase(citizenid, {
            title = 'Open Investigation',
            description = 'Subject under active investigation.'
        })
        success = caseId ~= nil

    elseif surpriseType == 'FAKE_BOLO' or surpriseType == 'FakeBOLO' then
        local ped = GetPlayerPed(source)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local plate = vehicle ~= 0 and GetVehicleNumberPlateText(vehicle) or nil

        success = exports['sv_mr_x']:CreateFakeBOLO({
            title = 'BOLO Alert',
            content = plate
                and string.format('Vehicle with plate %s involved in suspicious activity.', plate)
                or 'Subject wanted for questioning.'
        })

    elseif surpriseType == 'ANONYMOUS_TIP' or surpriseType == 'AnonymousTip' then
        local ped = GetPlayerPed(source)
        local coords = GetEntityCoords(ped)

        exports['sv_mr_x']:CreateTabletDispatch({
            priority = 'medium',
            code = '10-37',
            title = 'Anonymous Tip',
            description = 'Suspicious individual reported in area.',
            coords = {x = coords.x, y = coords.y},
            label = 'Anonymous Tip Location',
            time = 300
        })
        success = true

    elseif surpriseType == 'HIT_SQUAD' or surpriseType == 'HitSquad' then
        success = Chaos.SpawnHitSquad(source, citizenid)

    elseif surpriseType == 'DEBT_COLLECTOR' or surpriseType == 'DebtCollector' then
        success = Chaos.SpawnDebtCollector(source, citizenid)

    elseif surpriseType == 'AMBUSH' or surpriseType == 'Ambush' then
        success = Chaos.SpawnAmbush(source, citizenid)

    elseif surpriseType == 'PLAYER_BOUNTY' or surpriseType == 'PlayerBounty' then
        local amount = math.random(Config.Bounties.AmountMin, Config.Bounties.AmountMax)
        local bountyId = exports['sv_mr_x']:PostBounty(citizenid, amount, 'Mr. X is displeased.')
        success = bountyId ~= nil

    elseif surpriseType == 'GANG_CONTRACT' or surpriseType == 'GangContract' then
        local gang = player.PlayerData.gang and player.PlayerData.gang.name
        if gang and gang ~= 'none' then
            success = exports['sv_mr_x']:PostGangContract(citizenid, gang, math.random(10000, 30000))
        end

    elseif surpriseType == 'GANG_BETRAYAL' or surpriseType == 'GangBetrayal' then
        success = exports['sv_mr_x']:InitiateGangBetrayal(citizenid, 'Chaos engine triggered')

    elseif surpriseType == 'LEAK_LOCATION' or surpriseType == 'LeakLocation' then
        success = Chaos.LeakLocation(source, citizenid)

    elseif surpriseType == 'VEHICLE_TRACKER' or surpriseType == 'VehicleTracker' then
        -- Would need vehicle tracking system integration
        SendMessage(source, "Something feels off with your vehicle...")
        success = true

    elseif surpriseType == 'PHONE_HACK' or surpriseType == 'PhoneHack' then
        -- Power move: Take a selfie via their phone and send it back
        if Config.PhoneHack and Config.PhoneHack.Enabled then
            success = exports['sv_mr_x']:InitiatePhoneHack(source, false)
        else
            SendMessage(source, "I can see everything you do.")
            success = true
        end
    end

    Log(MrXConstants.EventTypes.CHAOS_TRIGGERED, citizenid, {
        surpriseType = surpriseType,
        success = success
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookChaos('triggered', citizenid, surpriseType, {success = success})
    end

    if Config.Debug then
        print(string.format('^3[MR_X]^7 Chaos surprise %s on %s: %s',
            surpriseType, citizenid, success and 'SUCCESS' or 'FAILED'))
    end
end

-- ============================================
-- NPC SPAWNING (Uses sv_nexus_tools if available)
-- ============================================

---Spawn a hit squad to hunt the player
---@param source number
---@param citizenid string
---@return boolean success
function Chaos.SpawnHitSquad(source, citizenid)
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        SendMessage(source, "They're coming for you.")
        return false
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    -- Spawn behind player
    local heading = GetEntityHeading(ped)
    local spawnCoords = coords + vector3(
        math.sin(math.rad(heading + 180)) * 50,
        math.cos(math.rad(heading + 180)) * 50,
        0
    )

    exports['sv_nexus_tools']:ExecuteToolsArray({
        {
            name = 'spawn_enemy_wave',
            params = {
                coords = {x = spawnCoords.x, y = spawnCoords.y, z = spawnCoords.z},
                count = 3,
                model = 'g_m_m_chiboss_01',
                weapons = {'WEAPON_PISTOL', 'WEAPON_MICROSMG'},
                spread = 15.0,
                behavior = 'hunt_player',
                targetCitizenId = citizenid
            }
        }
    }, 0, function(result)
        if Config.Debug then
            print('^3[MR_X]^7 Hit squad spawn result: ' .. tostring(result.success))
        end
    end)

    return true
end

---Spawn a debt collector NPC
---@param source number
---@param citizenid string
---@return boolean success
function Chaos.SpawnDebtCollector(source, citizenid)
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        SendMessage(source, "Someone is looking for you about a debt.")
        return false
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    exports['sv_nexus_tools']:ExecuteToolsArray({
        {
            name = 'spawn_npc',
            params = {
                coords = {x = coords.x + 10, y = coords.y + 10, z = coords.z},
                model = 's_m_m_fiboffice_01',
                scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
                dialog = 'debt_collector'  -- Would need dialog tree
            }
        }
    }, 0)

    return true
end

---Spawn an ambush
---@param source number
---@param citizenid string
---@return boolean success
function Chaos.SpawnAmbush(source, citizenid)
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        SendMessage(source, "Watch your back.")
        return false
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)

    -- Spawn around player
    exports['sv_nexus_tools']:ExecuteToolsArray({
        {
            name = 'spawn_enemy_wave',
            params = {
                coords = {x = coords.x, y = coords.y, z = coords.z},
                count = 2,
                model = 'g_m_y_lost_01',
                weapons = {'WEAPON_PISTOL'},
                spread = 30.0,
                behavior = 'aggressive'
            }
        }
    }, 0)

    return true
end

---Leak player's location to rivals or police
---@param source number
---@param citizenid string
---@return boolean success
function Chaos.LeakLocation(source, citizenid)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash) or 'Unknown'

    -- Create dispatch
    exports['sv_mr_x']:CreateTabletDispatch({
        priority = 'low',
        code = '10-37',
        title = 'Location Tip',
        description = 'Reliable source reports suspicious individual in area.',
        coords = {x = coords.x, y = coords.y},
        label = streetName,
        time = 180
    })

    -- Also notify any players with bounties on this target
    local bounty = exports['sv_mr_x']:GetBountyOnPlayer(citizenid)
    if bounty and bounty.accepted_by then
        local hunterSource = FindPlayerSource(bounty.accepted_by)
        if hunterSource then
            SendMessage(hunterSource, string.format(
                "Your target was spotted near %s. Move fast.",
                streetName
            ))
        end
    end

    return true
end

-- ============================================
-- INTERNAL EVENT HANDLER
-- ============================================

RegisterNetEvent('sv_mr_x:internal:triggerSurprise', function(source, citizenid, surpriseType)
    if Config.TestMode then return end
    Chaos.ExecuteSurprise(source, citizenid, surpriseType)
end)

RegisterNetEvent('sv_mr_x:internal:playerBecameThreat', function(citizenid, source)
    if Config.TestMode then return end

    -- Player crossed threshold - immediate chaos response
    if source and Chaos.CanSurprise(citizenid) then
        -- High probability of bounty or gang action
        local surpriseType = math.random() < 0.5 and 'PLAYER_BOUNTY' or 'ANONYMOUS_TIP'
        Chaos.TriggerSurprise(source, citizenid, surpriseType)
    end
end)

-- ============================================
-- AUTO-START (Respects Config)
-- ============================================

CreateThread(function()
    Wait(5000)  -- Wait for other systems to initialize

    if Config.ChaosEngine.Enabled and not Config.TestMode then
        Chaos.Start()
    else
        print('^3[MR_X]^7 Chaos engine NOT auto-started (TestMode=' .. tostring(Config.TestMode) .. ', Enabled=' .. tostring(Config.ChaosEngine.Enabled) .. ')')
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('StartChaos', Chaos.Start)
exports('StopChaos', Chaos.Stop)
exports('IsChaosRunning', Chaos.IsRunning)
exports('RunChaosScan', Chaos.Scan)
exports('TriggerChaosSurprise', Chaos.TriggerSurprise)
exports('ExecuteSurprise', Chaos.ExecuteSurprise)
exports('SpawnHitSquad', Chaos.SpawnHitSquad)

-- Return module
return Chaos
