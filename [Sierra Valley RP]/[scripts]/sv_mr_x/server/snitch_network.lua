--[[
    Mr. X Snitch Network
    ====================
    Players can sell intel about other players to Mr. X via SMS.
    Intel is verified against game state and payment is based on quality.
]]

local SnitchNetwork = {}

-- Active snitch sessions {citizenid -> session data}
local ActiveSnitchSessions = {}

-- Cooldown tracking
local SnitchCooldowns = {}      -- {citizenid -> lastSnitchTime}
local TargetCooldowns = {}      -- {targetCitizenid -> {snitchCitizenid -> timestamp}}

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
    ]], {citizenid, eventType, JsonEncode(data), source or 'snitch_network'})
end

local function RandomMessage(messageList)
    if not messageList or #messageList == 0 then return messageList end
    if type(messageList) == 'string' then return messageList end
    return messageList[math.random(#messageList)]
end

local function SendMessage(source, message)
    exports['sv_mr_x']:SendMrXMessage(source, message)
end

local function FormatMoney(amount)
    return '$' .. tostring(amount):reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
end

-- ============================================
-- TARGET LOOKUP
-- ============================================

---Find a player by name (fuzzy match)
---@param firstName string
---@param lastName string
---@return table|nil playerData {citizenid, source, name, job, online}
local function FindPlayerByName(firstName, lastName)
    if not firstName then return nil end

    firstName = firstName:lower()
    lastName = lastName and lastName:lower() or nil

    -- Search online players first
    for _, playerId in ipairs(GetPlayers()) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.charinfo then
            local pFirst = (player.PlayerData.charinfo.firstname or ''):lower()
            local pLast = (player.PlayerData.charinfo.lastname or ''):lower()

            -- Check for match
            local firstMatch = pFirst:find(firstName, 1, true) or firstName:find(pFirst, 1, true)
            local lastMatch = not lastName or pLast:find(lastName, 1, true) or lastName:find(pLast, 1, true)

            if firstMatch and lastMatch then
                return {
                    citizenid = player.PlayerData.citizenid,
                    source = tonumber(playerId),
                    name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
                    job = player.PlayerData.job and player.PlayerData.job.name or 'unknown',
                    online = true
                }
            end
        end
    end

    -- Search database for offline players
    local query = [[
        SELECT citizenid, charinfo, job FROM players
        WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) LIKE ?
    ]]
    local params = {'%' .. firstName .. '%'}

    if lastName then
        query = query .. [[ AND JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) LIKE ?]]
        table.insert(params, '%' .. lastName .. '%')
    end

    query = query .. ' LIMIT 1'

    local result = MySQL.single.await(query, params)
    if result then
        local charinfo = type(result.charinfo) == 'string' and json.decode(result.charinfo) or result.charinfo
        local jobData = type(result.job) == 'string' and json.decode(result.job) or result.job

        return {
            citizenid = result.citizenid,
            source = nil,
            name = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or ''),
            job = jobData and jobData.name or 'unknown',
            online = false
        }
    end

    return nil
end

---Get target's current location (if online)
---@param targetSource number
---@return table|nil location {x, y, z, zone}
local function GetTargetLocation(targetSource)
    if not targetSource then return nil end

    local ped = GetPlayerPed(targetSource)
    if not ped or ped == 0 then return nil end

    local coords = GetEntityCoords(ped)
    -- Note: Zone names would require client-side call, so we just return coords
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }
end

---Get target's current vehicle (if online and in vehicle)
---@param targetSource number
---@return table|nil vehicle {model, plate}
local function GetTargetVehicle(targetSource)
    if not targetSource then return nil end

    local ped = GetPlayerPed(targetSource)
    if not ped or ped == 0 then return nil end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 then return nil end

    return {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle)
    }
end

-- ============================================
-- INTEL VERIFICATION
-- ============================================

---Verify location intel
---@param targetData table
---@param claimedLocation string
---@return string status 'verified'|'stale'|'false'
---@return table|nil actualData
local function VerifyLocationIntel(targetData, claimedLocation)
    if not targetData.online then
        return 'stale', nil  -- Can't verify offline player location
    end

    local actualLocation = GetTargetLocation(targetData.source)
    if not actualLocation then
        return 'stale', nil
    end

    -- For now, any location intel on an online player is considered valuable
    return 'verified', actualLocation
end

---Verify vehicle intel
---@param targetData table
---@param claimedPlate string|nil
---@return string status 'verified'|'partial'|'false'
---@return table|nil actualData
local function VerifyVehicleIntel(targetData, claimedPlate)
    if not targetData.online then
        -- Check database for owned vehicles
        local vehicles = MySQL.query.await([[
            SELECT vehicle, plate FROM player_vehicles WHERE citizenid = ?
        ]], {targetData.citizenid})

        if vehicles and #vehicles > 0 then
            if claimedPlate then
                for _, v in ipairs(vehicles) do
                    if v.plate and v.plate:lower():find(claimedPlate:lower()) then
                        return 'verified', {plate = v.plate, model = v.vehicle}
                    end
                end
            end
            return 'partial', {count = #vehicles}
        end
        return 'false', nil
    end

    local actualVehicle = GetTargetVehicle(targetData.source)
    if actualVehicle then
        if claimedPlate and actualVehicle.plate:lower():find(claimedPlate:lower()) then
            return 'verified', actualVehicle
        end
        return 'partial', actualVehicle
    end

    return 'false', nil
end

-- ============================================
-- PAYMENT CALCULATION
-- ============================================

---Calculate payment for intel
---@param intelType string
---@param verificationStatus string
---@param details table
---@return number payment
local function CalculatePayment(intelType, verificationStatus, details)
    local cfg = Config.SnitchNetwork.Payments
    local payment = 0

    if intelType == 'location' then
        if verificationStatus == 'verified' then
            payment = cfg.Location.verified
        elseif verificationStatus == 'stale' then
            payment = cfg.Location.stale
        else
            payment = cfg.Location.base
        end
    elseif intelType == 'vehicle' then
        if details and details.plate then
            payment = cfg.Vehicle.withPlate
        else
            payment = cfg.Vehicle.base
        end
    elseif intelType == 'activity' then
        local activityLevel = details and details.level or 'minor'
        payment = cfg.Activity[activityLevel] or cfg.Activity.minor
    elseif intelType == 'associates' then
        if details and details.gang then
            payment = cfg.Associates.gang
        else
            payment = cfg.Associates.base
        end
    end

    return payment
end

-- ============================================
-- SNITCH SESSION MANAGEMENT
-- ============================================

---Start a snitch session
---@param source number
---@param citizenid string
local function StartSnitchSession(source, citizenid)
    ActiveSnitchSessions[citizenid] = {
        source = source,
        state = 'awaiting_target',
        startedAt = os.time(),
        targetData = nil,
        intelType = nil,
        intelDetails = nil
    }

    -- Send intro message
    local intro = RandomMessage(Config.SnitchNetwork.IntroMessages)
    SendMessage(source, intro)

    Log('SNITCH_SESSION_START', citizenid, {}, source)

    -- Post webhook
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhook('snitch', {
            event = 'session_start',
            citizenid = citizenid
        })
    end
end

---Process snitch session message
---@param source number
---@param citizenid string
---@param message string
---@return boolean handled
local function ProcessSnitchMessage(source, citizenid, message)
    local session = ActiveSnitchSessions[citizenid]
    if not session then return false end

    local prompts = Config.SnitchNetwork.Prompts
    local lowerMsg = message:lower()

    -- Check for cancel/abort
    if lowerMsg:match('cancel') or lowerMsg:match('nevermind') or lowerMsg:match('forget it') then
        ActiveSnitchSessions[citizenid] = nil
        SendMessage(source, "Fine. Don't waste my time next time.")
        return true
    end

    -- State machine
    if session.state == 'awaiting_target' then
        -- Try to parse name from message
        local firstName, lastName = message:match('(%w+)%s+(%w+)')
        if not firstName then
            firstName = message:match('(%w+)')
        end

        if not firstName or #firstName < 2 then
            SendMessage(source, prompts.AskTarget)
            return true
        end

        -- Look up target
        local targetData = FindPlayerByName(firstName, lastName)

        if not targetData then
            SendMessage(source, prompts.Invalid)
            return true
        end

        -- Check target cooldown
        local targetCd = TargetCooldowns[targetData.citizenid]
        if targetCd and targetCd[citizenid] then
            local elapsed = os.time() - targetCd[citizenid]
            if elapsed < Config.SnitchNetwork.Cooldowns.PerTarget then
                SendMessage(source, prompts.TargetCooldown)
                ActiveSnitchSessions[citizenid] = nil
                return true
            end
        end

        -- Can't snitch on yourself
        if targetData.citizenid == citizenid then
            SendMessage(source, "Nice try. I'm not paying you for intel on yourself.")
            ActiveSnitchSessions[citizenid] = nil
            return true
        end

        session.targetData = targetData
        session.state = 'awaiting_details'

        local statusText = targetData.online and "(Currently active)" or "(Currently offline)"
        SendMessage(source, targetData.name .. ". " .. statusText .. " What do you have on them?")
        return true

    elseif session.state == 'awaiting_details' then
        -- Analyze the intel type from message content
        local intelType = 'activity'  -- Default
        local intelDetails = {raw = message}

        -- Location keywords
        if lowerMsg:match('at ') or lowerMsg:match('near ') or lowerMsg:match('saw them') or
           lowerMsg:match('location') or lowerMsg:match('spotted') then
            intelType = 'location'
            intelDetails.claimedLocation = message
        end

        -- Vehicle keywords
        if lowerMsg:match('car') or lowerMsg:match('vehicle') or lowerMsg:match('drove') or
           lowerMsg:match('driving') or lowerMsg:match('plate') then
            intelType = 'vehicle'
            -- Try to extract plate
            local plate = lowerMsg:match('plate%s*:?%s*(%w+)') or lowerMsg:match('(%w%w%w%w%w%w%w%w)')
            intelDetails.claimedPlate = plate
        end

        -- Criminal activity keywords
        if lowerMsg:match('rob') or lowerMsg:match('stole') or lowerMsg:match('drug') or
           lowerMsg:match('deal') or lowerMsg:match('kill') or lowerMsg:match('shot') or
           lowerMsg:match('weapon') or lowerMsg:match('heist') then
            intelType = 'activity'
            intelDetails.level = 'criminal'
            if lowerMsg:match('kill') or lowerMsg:match('heist') or lowerMsg:match('murder') then
                intelDetails.level = 'major'
            end
        end

        -- Associates keywords
        if lowerMsg:match('gang') or lowerMsg:match('crew') or lowerMsg:match('with ') or
           lowerMsg:match('partner') or lowerMsg:match('working with') then
            intelType = 'associates'
            if lowerMsg:match('gang') then
                intelDetails.gang = true
            end
        end

        session.intelType = intelType
        session.intelDetails = intelDetails
        session.state = 'verifying'

        -- Verify intel
        local verificationStatus = 'partial'
        local verifiedData = nil

        if intelType == 'location' then
            verificationStatus, verifiedData = VerifyLocationIntel(session.targetData, intelDetails.claimedLocation)
        elseif intelType == 'vehicle' then
            verificationStatus, verifiedData = VerifyVehicleIntel(session.targetData, intelDetails.claimedPlate)
        else
            -- Activity and associates can't be auto-verified, assume partial
            verificationStatus = 'partial'
        end

        -- Calculate payment
        local payment = CalculatePayment(intelType, verificationStatus, intelDetails)

        -- Apply reputation bonus
        local profile = exports['sv_mr_x']:GetProfile(citizenid)
        if profile and profile.reputation >= 50 then
            payment = math.floor(payment * 1.2)  -- 20% bonus for trusted snitches
        end

        -- Process payment
        local paymentSuccess = exports.qbx_core:AddMoney(source, 'bank', payment, 'mr-x-snitch-payment')

        if paymentSuccess then
            -- Update reputation
            local repGain = Config.SnitchNetwork.ReputationGain.base
            if verificationStatus == 'verified' then
                repGain = Config.SnitchNetwork.ReputationGain.verified
            end
            if intelDetails.level == 'major' then
                repGain = Config.SnitchNetwork.ReputationGain.majorIntel
            end
            exports['sv_mr_x']:ChangeReputation(citizenid, repGain, 'snitch_intel')

            -- Send appropriate response
            if verificationStatus == 'verified' then
                SendMessage(source, string.format(prompts.Verified, FormatMoney(payment)))
            else
                SendMessage(source, string.format(prompts.Unverified:gsub('half', FormatMoney(payment)), FormatMoney(payment)))
            end

            -- Store intel for Mr. X to use
            StoreIntel(citizenid, session.targetData, intelType, intelDetails, verifiedData)

            -- Set cooldowns
            SnitchCooldowns[citizenid] = os.time()
            if not TargetCooldowns[session.targetData.citizenid] then
                TargetCooldowns[session.targetData.citizenid] = {}
            end
            TargetCooldowns[session.targetData.citizenid][citizenid] = os.time()

            -- Log and webhook
            Log('SNITCH_PAYMENT', citizenid, {
                target = session.targetData.citizenid,
                intelType = intelType,
                payment = payment,
                verified = verificationStatus
            }, source)

            if Config.WebServer and Config.WebServer.Enabled then
                exports['sv_mr_x']:PostWebhook('snitch', {
                    event = 'intel_received',
                    snitch = citizenid,
                    target = session.targetData.citizenid,
                    targetName = session.targetData.name,
                    intelType = intelType,
                    payment = payment,
                    verified = verificationStatus
                })
            end
        else
            SendMessage(source, "There was an issue with your payment. Try again later.")
        end

        -- End session
        ActiveSnitchSessions[citizenid] = nil
        return true
    end

    return false
end

---Store intel for Mr. X to use later
---@param snitchCitizenid string
---@param targetData table
---@param intelType string
---@param details table
---@param verifiedData table|nil
local function StoreIntel(snitchCitizenid, targetData, intelType, details, verifiedData)
    -- Store as a fact on the target
    exports['sv_mr_x']:AddKnownFact(targetData.citizenid, 'SNITCH_INTEL_' .. intelType:upper(), {
        reportedBy = snitchCitizenid,  -- Could be anonymized for privacy
        intelType = intelType,
        details = details,
        verifiedData = verifiedData,
        timestamp = os.time()
    })

    -- Also store in dedicated intel table for future use
    MySQL.insert.await([[
        INSERT INTO mr_x_snitch_intel (snitch_citizenid, target_citizenid, intel_type, details, verified, timestamp)
        VALUES (?, ?, ?, ?, ?, NOW())
    ]], {
        snitchCitizenid,
        targetData.citizenid,
        intelType,
        JsonEncode(details),
        verifiedData ~= nil and 1 or 0
    })
end

-- ============================================
-- MESSAGE DETECTION (Hook into comms)
-- ============================================

---Check if message triggers snitch mode
---@param message string
---@return boolean triggered
local function IsSnitchTrigger(message)
    if not Config.SnitchNetwork.Enabled then return false end

    local lowerMsg = message:lower()
    for _, keyword in ipairs(Config.SnitchNetwork.TriggerKeywords) do
        if lowerMsg:find(keyword, 1, true) then
            return true
        end
    end

    return false
end

---Handle potential snitch message
---@param source number
---@param citizenid string
---@param message string
---@return boolean handled
function SnitchNetwork.HandleMessage(source, citizenid, message)
    -- Check if already in a snitch session
    if ActiveSnitchSessions[citizenid] then
        return ProcessSnitchMessage(source, citizenid, message)
    end

    -- Check for snitch trigger
    if IsSnitchTrigger(message) then
        -- Check global cooldown
        local lastSnitch = SnitchCooldowns[citizenid]
        if lastSnitch then
            local elapsed = os.time() - lastSnitch
            if elapsed < Config.SnitchNetwork.Cooldowns.PerSnitch then
                SendMessage(source, Config.SnitchNetwork.Prompts.Cooldown)
                return true
            end
        end

        StartSnitchSession(source, citizenid)
        return true
    end

    return false
end

---Mr. X can proactively offer the snitch service
---@param source number
function SnitchNetwork.OfferService(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    local messages = {
        "I pay well for information. If you see something... tell me.",
        "Eyes and ears are valuable in this city. If you have intel on anyone, I'm interested.",
        "You look like someone who pays attention. If you ever have information to sell, reach out."
    }

    SendMessage(source, RandomMessage(messages))

    Log('SNITCH_SERVICE_OFFERED', citizenid, {}, source)
end

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_snitch_stats', function(source)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then return end

    local stats = MySQL.single.await([[
        SELECT
            COUNT(*) as total_reports,
            COUNT(DISTINCT snitch_citizenid) as unique_snitches,
            COUNT(DISTINCT target_citizenid) as unique_targets,
            SUM(CASE WHEN verified = 1 THEN 1 ELSE 0 END) as verified_reports
        FROM mr_x_snitch_intel
    ]])

    print('^3[SNITCH NETWORK STATS]^7')
    print('Total Reports: ' .. (stats and stats.total_reports or 0))
    print('Unique Snitches: ' .. (stats and stats.unique_snitches or 0))
    print('Unique Targets: ' .. (stats and stats.unique_targets or 0))
    print('Verified Reports: ' .. (stats and stats.verified_reports or 0))
end, false)

-- ============================================
-- DATABASE SETUP
-- ============================================

CreateThread(function()
    -- Ensure intel table exists
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS mr_x_snitch_intel (
            id INT AUTO_INCREMENT PRIMARY KEY,
            snitch_citizenid VARCHAR(50) NOT NULL,
            target_citizenid VARCHAR(50) NOT NULL,
            intel_type VARCHAR(50) NOT NULL,
            details TEXT,
            verified TINYINT DEFAULT 0,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_target (target_citizenid),
            INDEX idx_snitch (snitch_citizenid)
        )
    ]])

    print('^2[MR_X]^7 Snitch Network initialized')
end)

-- ============================================
-- SESSION CLEANUP
-- ============================================

CreateThread(function()
    while true do
        Wait(60000)  -- Every minute

        local now = os.time()
        for citizenid, session in pairs(ActiveSnitchSessions) do
            -- Timeout sessions after 5 minutes of inactivity
            if now - session.startedAt > 300 then
                local source = session.source
                if source then
                    SendMessage(source, "You went quiet. This conversation is over.")
                end
                ActiveSnitchSessions[citizenid] = nil
            end
        end
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('HandleSnitchMessage', SnitchNetwork.HandleMessage)
exports('OfferSnitchService', SnitchNetwork.OfferService)
exports('IsSnitchTrigger', IsSnitchTrigger)

return SnitchNetwork
