--[[
    Mr. X Fact Discovery
    ====================
    Automatically discovers and stores facts about players
    from various sources: conversations, police records, jobs, finances
]]

local FactDiscovery = {}

print('^2[MR_X]^7 Fact Discovery module loading...')

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function AddFact(citizenid, key, data)
    if not citizenid then return false end
    return exports['sv_mr_x']:AddKnownFact(citizenid, key, data)
end

-- ============================================
-- CONVERSATION FACT EXTRACTION
-- Uses patterns to extract facts from player messages
-- ============================================

local ConversationPatterns = {
    -- Names mentioned
    {
        pattern = "my (%w+) is (%w+)",
        extract = function(matches)
            return 'personal_' .. matches[1]:lower(), matches[2]
        end
    },
    {
        pattern = "i work at (%w+)",
        extract = function(matches)
            return 'claimed_workplace', matches[1]
        end
    },
    {
        pattern = "i work for (%w+)",
        extract = function(matches)
            return 'claimed_employer', matches[1]
        end
    },
    -- Gang/crew references
    {
        pattern = "my crew",
        extract = function()
            return 'has_crew', true
        end
    },
    {
        pattern = "my gang",
        extract = function()
            return 'admits_gang', true
        end
    },
    -- Location references
    {
        pattern = "i live in (%w+)",
        extract = function(matches)
            return 'claimed_residence', matches[1]
        end
    },
    {
        pattern = "i stay at (%w+)",
        extract = function(matches)
            return 'claimed_residence', matches[1]
        end
    },
    -- Criminal activity admissions
    {
        pattern = "i sold",
        extract = function()
            return 'admits_dealing', true
        end
    },
    {
        pattern = "i robbed",
        extract = function()
            return 'admits_robbery', true
        end
    },
    {
        pattern = "i killed",
        extract = function()
            return 'admits_violence', true
        end
    },
}

---Extract facts from a player's message
---@param citizenid string
---@param message string
---@return table extractedFacts
function FactDiscovery.ExtractFromConversation(citizenid, message)
    if not citizenid or not message then return {} end

    local facts = {}
    local lowerMsg = message:lower()

    for _, pattern in ipairs(ConversationPatterns) do
        local matches = {lowerMsg:match(pattern.pattern)}
        if #matches > 0 or lowerMsg:find(pattern.pattern) then
            local key, value = pattern.extract(matches)
            if key then
                facts[key] = value
                AddFact(citizenid, key, {
                    value = value,
                    source = 'conversation',
                    message_excerpt = message:sub(1, 50)
                })
            end
        end
    end

    return facts
end

-- ============================================
-- POLICE RECORD DISCOVERY
-- Pulls facts from lb-tablet police records
-- ============================================

---Discover facts from police MDT records
---@param citizenid string
---@return table facts
function FactDiscovery.FromPoliceRecords(citizenid)
    if not citizenid then return {} end

    local facts = {}

    -- Check for active warrants (lb-tablet: lbtablet_police_warrants)
    -- Uses linked_profile_id for citizenid, warrant_status for status
    local warrants = MySQL.query.await([[
        SELECT * FROM lbtablet_police_warrants
        WHERE linked_profile_id = ? AND warrant_status = 'active'
    ]], {citizenid})

    if warrants and #warrants > 0 then
        AddFact(citizenid, 'has_active_warrants', {
            count = #warrants,
            discovered_at = os.time()
        })
        facts.has_active_warrants = #warrants
    end

    -- Check for incident reports (lb-tablet: join reports with _involved table)
    local reports = MySQL.query.await([[
        SELECT COUNT(*) as count FROM lbtablet_police_reports r
        INNER JOIN lbtablet_police_reports_involved i ON r.id = i.report_id
        WHERE i.involved = ?
    ]], {citizenid})

    if reports and reports[1] and reports[1].count > 0 then
        AddFact(citizenid, 'police_report_count', {
            count = reports[1].count,
            discovered_at = os.time()
        })
        facts.police_report_count = reports[1].count
    end

    -- Check for BOLO in bulletin (lb-tablet: lbtablet_police_bulletin with pinned=1)
    local bolos = MySQL.query.await([[
        SELECT * FROM lbtablet_police_bulletin
        WHERE pinned = 1 AND content LIKE ?
    ]], {'%' .. citizenid .. '%'})

    if bolos and #bolos > 0 then
        AddFact(citizenid, 'has_bolo', {
            count = #bolos,
            discovered_at = os.time()
        })
        facts.has_bolo = #bolos
    end

    return facts
end

-- ============================================
-- JOB CHANGE TRACKING
-- ============================================

-- Cache of last known jobs
local LastKnownJobs = {}

---Track job changes for a player
---@param source number
function FactDiscovery.TrackJobChange(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local currentJob = player.PlayerData.job

    if not currentJob then return end

    local lastJob = LastKnownJobs[citizenid]
    LastKnownJobs[citizenid] = currentJob.name

    -- If job changed, record it
    if lastJob and lastJob ~= currentJob.name then
        AddFact(citizenid, 'job_history_' .. os.time(), {
            from = lastJob,
            to = currentJob.name,
            changed_at = os.time()
        })

        -- Track specific job types
        if currentJob.name == 'unemployed' and lastJob ~= 'unemployed' then
            AddFact(citizenid, 'recently_unemployed', {
                previous_job = lastJob,
                timestamp = os.time()
            })
        end

        -- Track if they joined law enforcement (Mr. X takes note)
        local lawJobs = {police = true, lscso = true, lspd = true, sast = true, safr = true}
        if lawJobs[currentJob.name] then
            AddFact(citizenid, 'joined_law_enforcement', {
                department = currentJob.name,
                timestamp = os.time()
            })
        end
    end
end

-- Listen for job updates
AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    FactDiscovery.TrackJobChange(source)
end)

RegisterNetEvent('qbx_core:server:onJobUpdate', function()
    local source = source
    FactDiscovery.TrackJobChange(source)
end)

-- ============================================
-- FINANCIAL TRACKING
-- ============================================

---Track significant financial events
---@param citizenid string
---@param eventType string 'large_deposit' | 'large_withdrawal' | 'broke' | 'wealthy'
---@param amount number
---@param details? table
function FactDiscovery.TrackFinancial(citizenid, eventType, amount, details)
    if not citizenid then return end

    local factKey = 'financial_' .. eventType .. '_' .. os.date('%Y%m%d')

    AddFact(citizenid, factKey, {
        type = eventType,
        amount = amount,
        details = details,
        timestamp = os.time()
    })
end

-- Hook into money changes (if qbx_core exposes this)
-- NOTE: Cash transactions require camera visibility (physically visible)
--       Bank transactions use a different intel source (electronic/hacking)
AddEventHandler('QBCore:Server:OnMoneyChange', function(source, moneyType, amount, operation)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    -- Track large transactions (over $50,000)
    if amount >= 50000 then
        local isCash = moneyType == 'cash'

        if operation == 'add' then
            if isCash then
                -- Cash deposits require camera visibility (e.g., counting cash on camera)
                exports['sv_mr_x']:RecordFact(citizenid, 'LARGE_CASH_DEPOSIT', {
                    amount = amount,
                    operation = operation,
                    timestamp = os.time()
                }, source, true)  -- requireCamera = true
            else
                -- Bank deposits are electronic - tracked via financial intel, not cameras
                -- This would require Mr. X to have "hacked the bank" or have financial connections
                exports['sv_mr_x']:RecordFact(citizenid, 'BANK_INTEL_DEPOSIT', {
                    amount = amount,
                    operation = operation,
                    timestamp = os.time(),
                    intelSource = 'financial_network'  -- Future: check if Mr. X has bank access
                }, source, false)  -- requireCamera = false
            end
        elseif operation == 'remove' then
            if isCash then
                -- Cash withdrawals visible on camera (e.g., handing over cash)
                exports['sv_mr_x']:RecordFact(citizenid, 'LARGE_CASH_WITHDRAWAL', {
                    amount = amount,
                    operation = operation,
                    timestamp = os.time()
                }, source, true)  -- requireCamera = true
            else
                -- Bank withdrawals are electronic
                exports['sv_mr_x']:RecordFact(citizenid, 'BANK_INTEL_WITHDRAWAL', {
                    amount = amount,
                    operation = operation,
                    timestamp = os.time(),
                    intelSource = 'financial_network'
                }, source, false)  -- requireCamera = false
            end
        end
    end

    -- Track if player goes broke (cash + bank < $100)
    local cash = player.PlayerData.money.cash or 0
    local bank = player.PlayerData.money.bank or 0
    if cash + bank < 100 then
        FactDiscovery.TrackFinancial(citizenid, 'broke', cash + bank)
    end

    -- Track if player becomes wealthy (cash + bank > $500,000)
    if cash + bank > 500000 then
        FactDiscovery.TrackFinancial(citizenid, 'wealthy', cash + bank)
    end
end)

-- ============================================
-- MISSION BEHAVIOR TRACKING
-- Learn from how players complete missions
-- ============================================

---Track mission behavior and learn patterns
---@param citizenid string
---@param missionData table
---@param outcome string
function FactDiscovery.TrackMissionBehavior(citizenid, missionData, outcome)
    if not citizenid then return end

    -- Track completion speed
    if missionData.startTime and missionData.endTime then
        local duration = missionData.endTime - missionData.startTime
        local expectedDuration = missionData.expectedDuration or 1800 -- 30 min default

        if duration < expectedDuration * 0.5 then
            AddFact(citizenid, 'fast_operator', {
                mission_id = missionData.id,
                duration = duration,
                expected = expectedDuration
            })
        elseif duration > expectedDuration * 2 then
            AddFact(citizenid, 'slow_methodical', {
                mission_id = missionData.id,
                duration = duration,
                expected = expectedDuration
            })
        end
    end

    -- Track violence level
    if missionData.killCount and missionData.killCount > 0 then
        AddFact(citizenid, 'uses_violence', {
            mission_id = missionData.id,
            kills = missionData.killCount
        })
    elseif missionData.stealthCompleted then
        AddFact(citizenid, 'prefers_stealth', {
            mission_id = missionData.id
        })
    end

    -- Track betrayal tendencies
    if outcome == 'betrayed' then
        AddFact(citizenid, 'betrayer', {
            mission_id = missionData.id,
            timestamp = os.time()
        })
    end

    -- Track reliability
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    if profile then
        local successRate = profile.total_missions > 0
            and (profile.successful_missions / profile.total_missions)
            or 0

        if profile.total_missions >= 5 then
            if successRate >= 0.9 then
                AddFact(citizenid, 'highly_reliable', {
                    success_rate = successRate,
                    total_missions = profile.total_missions
                })
            elseif successRate <= 0.3 then
                AddFact(citizenid, 'unreliable', {
                    success_rate = successRate,
                    total_missions = profile.total_missions
                })
            end
        end
    end
end

-- ============================================
-- LOCATION TRACKING
-- Track where player spends time
-- ============================================

local PlayerLocations = {}  -- citizenid -> {zone, time}

---Track player location visits
---@param citizenid string
---@param zone string Zone name
function FactDiscovery.TrackLocation(citizenid, zone)
    if not citizenid or not zone then return end

    local now = os.time()
    local loc = PlayerLocations[citizenid]

    if not loc then
        PlayerLocations[citizenid] = {zone = zone, since = now, visits = {}}
        return
    end

    -- If stayed in same zone for 30+ minutes, note it
    if loc.zone == zone and (now - loc.since) >= 1800 then
        loc.visits[zone] = (loc.visits[zone] or 0) + 1

        -- If visited same spot 3+ times, it's a frequent location
        if loc.visits[zone] >= 3 then
            AddFact(citizenid, 'frequent_location_' .. zone:lower():gsub(' ', '_'), {
                zone = zone,
                visit_count = loc.visits[zone]
            })
        end
    elseif loc.zone ~= zone then
        -- Changed zones, reset timer
        PlayerLocations[citizenid] = {zone = zone, since = now, visits = loc.visits}
    end
end

-- ============================================
-- PERIODIC POLICE RECORD CHECK
-- Runs every hour to update police-related facts
-- ============================================

CreateThread(function()
    while true do
        Wait(3600000)  -- Every hour

        if Config.WebServer and Config.WebServer.Enabled then
            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local player = exports.qbx_core:GetPlayer(tonumber(playerId))
                if player then
                    local citizenid = player.PlayerData.citizenid
                    -- Check police records in background
                    FactDiscovery.FromPoliceRecords(citizenid)
                    Wait(100)  -- Small delay between checks
                end
            end
        end
    end
end)

-- ============================================
-- INVENTORY DISCOVERY
-- What items/weapons does the player carry?
-- ============================================

---Discover facts from player's inventory
---@param source number
---@return table facts
function FactDiscovery.FromInventory(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {} end

    local citizenid = player.PlayerData.citizenid
    local facts = {}

    -- Get inventory from ox_inventory
    local success, inventory = pcall(function()
        return exports.ox_inventory:GetInventoryItems(source)
    end)
    if not success or not inventory then return facts end

    local weaponCount = 0
    local drugCount = 0
    local hasLockpick = false
    local hasDisguise = false
    local valuableItems = {}

    for _, item in pairs(inventory) do
        local name = item.name:lower()

        -- Count weapons
        if name:find('weapon_') or name:find('gun') or name:find('pistol') or name:find('rifle') then
            weaponCount = weaponCount + 1
        end

        -- Count drugs
        if name:find('weed') or name:find('coke') or name:find('meth') or name:find('oxy') then
            drugCount = drugCount + (item.count or 1)
        end

        -- Check for criminal tools
        if name:find('lockpick') or name:find('advancedlockpick') then
            hasLockpick = true
        end

        -- Check for disguises
        if name:find('mask') or name:find('disguise') then
            hasDisguise = true
        end

        -- Track valuable items (marked bills, gold, etc)
        if name:find('markedbills') or name:find('goldbar') or name:find('diamond') then
            table.insert(valuableItems, name)
        end
    end

    -- Record facts
    if weaponCount >= 3 then
        AddFact(citizenid, 'heavily_armed', {count = weaponCount})
        facts.heavily_armed = weaponCount
    end

    if drugCount >= 10 then
        AddFact(citizenid, 'carries_drugs', {count = drugCount})
        facts.carries_drugs = drugCount
    end

    if hasLockpick then
        AddFact(citizenid, 'has_lockpicks', true)
        facts.has_lockpicks = true
    end

    if hasDisguise then
        AddFact(citizenid, 'has_disguise', true)
        facts.has_disguise = true
    end

    if #valuableItems > 0 then
        AddFact(citizenid, 'carries_valuables', valuableItems)
        facts.carries_valuables = valuableItems
    end

    return facts
end

-- ============================================
-- VEHICLE DISCOVERY
-- What vehicles does the player own?
-- ============================================

---Discover facts from player's vehicles
---@param citizenid string
---@return table facts
function FactDiscovery.FromVehicles(citizenid)
    if not citizenid then return {} end

    local facts = {}

    -- Query owned vehicles
    local vehicles = MySQL.query.await([[
        SELECT vehicle, mods FROM player_vehicles
        WHERE citizenid = ?
    ]], {citizenid})

    if not vehicles or #vehicles == 0 then
        return facts
    end

    local vehicleCount = #vehicles
    local hasLuxury = false
    local hasFast = false

    -- Luxury/fast vehicle models (partial list)
    local luxuryModels = {
        adder = true, t20 = true, zentorno = true, osiris = true,
        entityxf = true, turismor = true, xa21 = true, nero = true,
        tezeract = true, thrax = true, krieger = true, emerus = true
    }

    for _, v in ipairs(vehicles) do
        local model = v.vehicle:lower()
        if luxuryModels[model] then
            hasLuxury = true
            hasFast = true
        end
    end

    if vehicleCount >= 5 then
        AddFact(citizenid, 'vehicle_collector', {count = vehicleCount})
        facts.vehicle_collector = vehicleCount
    end

    if hasLuxury then
        AddFact(citizenid, 'owns_luxury_vehicles', true)
        facts.owns_luxury_vehicles = true
    end

    return facts
end

-- ============================================
-- PROPERTY DISCOVERY
-- What properties does the player own?
-- ============================================

---Discover facts from player's properties
---@param citizenid string
---@return table facts
function FactDiscovery.FromProperties(citizenid)
    if not citizenid then return {} end

    local facts = {}
    local totalProperties = 0

    -- Query owned houses (bcs_housing: house_owned table)
    local houses = MySQL.query.await([[
        SELECT * FROM house_owned
        WHERE owner = ?
    ]], {citizenid})

    if houses then
        totalProperties = totalProperties + #houses
    end

    -- Query owned apartments (bcs_housing: house_apartment table)
    local apartments = MySQL.query.await([[
        SELECT * FROM house_apartment
        WHERE owner = ?
    ]], {citizenid})

    if apartments then
        totalProperties = totalProperties + #apartments
    end

    if totalProperties > 0 then
        AddFact(citizenid, 'property_owner', {count = totalProperties})
        facts.property_owner = totalProperties

        if totalProperties >= 3 then
            AddFact(citizenid, 'real_estate_investor', {count = totalProperties})
            facts.real_estate_investor = totalProperties
        end
    end

    return facts
end

-- ============================================
-- LICENSE DISCOVERY
-- What licenses does the player have?
-- ============================================

---Discover facts from player's licenses
---@param source number
---@return table facts
function FactDiscovery.FromLicenses(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {} end

    local citizenid = player.PlayerData.citizenid
    local metadata = player.PlayerData.metadata or {}
    local licenses = metadata.licences or metadata.licenses or {}
    local facts = {}

    -- Track interesting licenses
    if licenses.weapon then
        AddFact(citizenid, 'has_weapon_license', true)
        facts.has_weapon_license = true
    end

    if licenses.driver == false then
        AddFact(citizenid, 'no_drivers_license', true)
        facts.no_drivers_license = true
    end

    if licenses.pilot then
        AddFact(citizenid, 'has_pilot_license', true)
        facts.has_pilot_license = true
    end

    if licenses.hunting then
        AddFact(citizenid, 'has_hunting_license', true)
        facts.has_hunting_license = true
    end

    return facts
end

-- ============================================
-- CRIMINAL HISTORY DISCOVERY
-- Aggregate criminal indicators
-- ============================================

---Build a criminal profile from all available data
---@param citizenid string
---@param source? number
---@return table profile
function FactDiscovery.BuildCriminalProfile(citizenid, source)
    if not citizenid then return {} end

    local profile = {
        citizenid = citizenid,
        indicators = {},
        riskLevel = 'low'
    }

    -- Get Mr. X profile
    local mrxProfile = exports['sv_mr_x']:GetProfile(citizenid)
    if mrxProfile then
        if mrxProfile.reputation < 0 then
            table.insert(profile.indicators, 'negative_reputation')
        end
        if mrxProfile.reputation >= 50 then
            table.insert(profile.indicators, 'trusted_operative')
        end
    end

    -- Check police records
    local policeRecords = FactDiscovery.FromPoliceRecords(citizenid)
    if policeRecords.has_active_warrants then
        table.insert(profile.indicators, 'active_warrants')
        profile.riskLevel = 'high'
    end
    if policeRecords.police_report_count and policeRecords.police_report_count > 3 then
        table.insert(profile.indicators, 'frequent_suspect')
        profile.riskLevel = 'medium'
    end

    -- Check inventory if online
    if source then
        local invFacts = FactDiscovery.FromInventory(source)
        if invFacts.heavily_armed then
            table.insert(profile.indicators, 'heavily_armed')
        end
        if invFacts.carries_drugs then
            table.insert(profile.indicators, 'drug_carrier')
        end
        if invFacts.has_lockpicks then
            table.insert(profile.indicators, 'has_burglary_tools')
        end
    end

    -- Check vehicles
    local vehFacts = FactDiscovery.FromVehicles(citizenid)
    if vehFacts.owns_luxury_vehicles then
        table.insert(profile.indicators, 'wealth_indicator')
    end

    -- Determine risk level
    local indicatorCount = #profile.indicators
    if indicatorCount >= 5 then
        profile.riskLevel = 'high'
    elseif indicatorCount >= 3 then
        profile.riskLevel = 'medium'
    end

    -- Store the profile summary as a fact
    AddFact(citizenid, 'criminal_profile_' .. os.date('%Y%m%d'), profile)

    return profile
end

-- ============================================
-- FULL DISCOVERY SCAN
-- Run all discovery methods for a player
-- ============================================

---Run full fact discovery for a player
---@param citizenid string
---@param source? number Player source if online
---@return table allFacts
function FactDiscovery.FullScan(citizenid, source)
    if not citizenid then return {} end

    local allFacts = {}

    -- Run all discovery methods
    local policeFacts = FactDiscovery.FromPoliceRecords(citizenid)
    for k, v in pairs(policeFacts) do allFacts[k] = v end

    local vehFacts = FactDiscovery.FromVehicles(citizenid)
    for k, v in pairs(vehFacts) do allFacts[k] = v end

    local propFacts = FactDiscovery.FromProperties(citizenid)
    for k, v in pairs(propFacts) do allFacts[k] = v end

    if source then
        local invFacts = FactDiscovery.FromInventory(source)
        for k, v in pairs(invFacts) do allFacts[k] = v end

        local licFacts = FactDiscovery.FromLicenses(source)
        for k, v in pairs(licFacts) do allFacts[k] = v end

        FactDiscovery.TrackJobChange(source)
    end

    -- Build criminal profile
    FactDiscovery.BuildCriminalProfile(citizenid, source)

    -- Post to webhook
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhook('fact_scan', {
            citizenid = citizenid,
            factCount = 0,  -- Count would require iteration
            timestamp = os.time()
        })
    end

    return allFacts
end

-- ============================================
-- PLAYER LOAD HOOK - Run initial scan
-- ============================================

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData then return end

    local citizenid = Player.PlayerData.citizenid
    local source = Player.PlayerData.source

    -- Delay scan to let everything load
    SetTimeout(10000, function()
        FactDiscovery.FullScan(citizenid, source)
    end)
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('ExtractFactsFromConversation', FactDiscovery.ExtractFromConversation)
exports('DiscoverPoliceRecords', FactDiscovery.FromPoliceRecords)
exports('DiscoverInventory', FactDiscovery.FromInventory)
exports('DiscoverVehicles', FactDiscovery.FromVehicles)
exports('DiscoverProperties', FactDiscovery.FromProperties)
exports('DiscoverLicenses', FactDiscovery.FromLicenses)
exports('BuildCriminalProfile', FactDiscovery.BuildCriminalProfile)
exports('FullFactScan', FactDiscovery.FullScan)
exports('TrackJobChange', FactDiscovery.TrackJobChange)
exports('TrackFinancial', FactDiscovery.TrackFinancial)
exports('TrackMissionBehavior', FactDiscovery.TrackMissionBehavior)
exports('TrackLocation', FactDiscovery.TrackLocation)

print('^2[MR_X]^7 Fact Discovery module loaded - exports registered')

-- Return module
return FactDiscovery
