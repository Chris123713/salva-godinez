--[[
    Mr. X Admin Callbacks
    =====================
    Server-side callbacks for admin testing functionality
]]

local Admin = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function IsAdmin(source)
    return IsPlayerAceAllowed(source, 'admin') or IsPlayerAceAllowed(source, 'command.mrx')
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

-- ============================================
-- CALLBACK REGISTRATION (wrapped in thread for ox_lib timing)
-- ============================================

CreateThread(function()
    -- Wait for ox_lib to be available
    while not lib do
        Wait(100)
    end

-- ============================================
-- TEST MODE
-- ============================================

---Toggle test mode
lib.callback.register('mrx:admin:toggleTestMode', function(source)
    if not IsAdmin(source) then return false end

    Config.TestMode = not Config.TestMode

    Log(MrXConstants.EventTypes.TEST_MODE_TOGGLED, GetCitizenId(source), {
        enabled = Config.TestMode
    }, source)

    print('^3[MR_X]^7 Test mode ' .. (Config.TestMode and 'ENABLED' or 'DISABLED') .. ' by admin')

    return Config.TestMode
end)

---Get current test mode status
lib.callback.register('mrx:admin:getTestMode', function(source)
    return Config.TestMode
end)

-- ============================================
-- PROFILE MANAGEMENT
-- ============================================

---Get player's profile data
lib.callback.register('mrx:admin:getProfile', function(source)
    if not IsAdmin(source) then return nil end

    local citizenid = GetCitizenId(source)
    if not citizenid then return nil end

    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    local repSummary = exports['sv_mr_x']:GetReputationSummary(citizenid)

    return {
        profile = profile,
        reputation = repSummary
    }
end)

---Set player's reputation
lib.callback.register('mrx:admin:setReputation', function(source, newRep)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    newRep = tonumber(newRep)
    if not newRep then return false end

    local result = exports['sv_mr_x']:SetReputation(citizenid, newRep, 'admin_set', source)

    Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
        action = 'set_reputation',
        value = newRep
    }, source)

    return result
end)

---Set player's archetype
lib.callback.register('mrx:admin:setArchetype', function(source, archetype)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    -- Validate archetype
    local validArchetypes = {'thug', 'wheeler_dealer', 'silent_pro', 'wildcard', 'civilian'}
    local isValid = false
    for _, valid in ipairs(validArchetypes) do
        if archetype == valid then
            isValid = true
            break
        end
    end

    if not isValid then return false end

    local success = exports['sv_mr_x']:UpdateProfile(citizenid, {archetype = archetype})

    Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
        action = 'set_archetype',
        value = archetype
    }, source)

    return success
end)

---Reset player's profile
lib.callback.register('mrx:admin:resetProfile', function(source)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    local success = exports['sv_mr_x']:UpdateProfile(citizenid, {
        reputation = 0,
        archetype = 'civilian',
        history = {},
        known_facts = {},
        total_missions = 0,
        successful_missions = 0
    })

    Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
        action = 'reset_profile'
    }, source)

    return success
end)

-- ============================================
-- OPT-OUT MANAGEMENT
-- ============================================

---Get opt-out info for current player
lib.callback.register('mrx:admin:getOptOutInfo', function(source)
    if not IsAdmin(source) then return nil end

    return exports['sv_mr_x']:GetOptOutInfo(source)
end)

---Set opt-out status for a player (by citizenid)
lib.callback.register('mrx:admin:setOptOut', function(source, targetCid, optedOut)
    if not IsAdmin(source) then return false end

    targetCid = targetCid or GetCitizenId(source)
    optedOut = optedOut == true or optedOut == 1

    local success = exports['sv_mr_x']:SetOptOut(targetCid, optedOut)

    Log(MrXConstants.EventTypes.ADMIN_ACTION, GetCitizenId(source), {
        action = 'set_optout',
        targetCid = targetCid,
        optedOut = optedOut
    }, source)

    return success
end)

---Get opt-out info for another player (by citizenid)
lib.callback.register('mrx:admin:getPlayerOptOutInfo', function(source, targetCid)
    if not IsAdmin(source) then return nil end

    local isExempt, reason = exports['sv_mr_x']:IsExemptByCitizenId(targetCid)
    return {
        citizenid = targetCid,
        isExempt = isExempt,
        reason = reason
    }
end)

-- ============================================
-- MESSAGING
-- ============================================

---Send test SMS
lib.callback.register('mrx:admin:sendTestSMS', function(source, message)
    if not IsAdmin(source) then return false end

    if not message or message == '' then
        message = 'Test message from Mr. X'
    end

    return exports['sv_mr_x']:SendMrXMessage(source, message)
end)

---Send test email
lib.callback.register('mrx:admin:sendTestEmail', function(source, subject, body)
    if not IsAdmin(source) then return false end

    subject = subject or 'Test Email'
    body = body or 'This is a test email from Mr. X.'

    return exports['sv_mr_x']:SendMrXEmail(source, subject, body)
end)

---Send test notification
lib.callback.register('mrx:admin:sendTestNotification', function(source, title, message)
    if not IsAdmin(source) then return false end

    title = title or 'Mr. X'
    message = message or 'Test notification'

    return exports['sv_mr_x']:SendMrXNotification(source, title, message)
end)

---Initiate test call
lib.callback.register('mrx:admin:initiateTestCall', function(source)
    if not IsAdmin(source) then return false end

    return exports['sv_mr_x']:CreateMrXCall(source)
end)

-- ============================================
-- MISSION GENERATION
-- ============================================

---Generate a mission based on profile
lib.callback.register('mrx:admin:generateMission', function(source)
    if not IsAdmin(source) then return nil end

    local result = nil

    exports['sv_mr_x']:GenerateMission(source, nil, function(success, mission, error)
        result = {
            success = success,
            mission = mission,
            error = error
        }
    end)

    -- Wait for async callback (simple polling)
    local timeout = 10000
    local waited = 0
    while result == nil and waited < timeout do
        Wait(100)
        waited = waited + 100
    end

    return result
end)

---Generate a mission at specific tier
lib.callback.register('mrx:admin:generateMissionAtTier', function(source, tier)
    if not IsAdmin(source) then return nil end

    -- Temporarily set reputation to match tier
    local citizenid = GetCitizenId(source)
    local originalRep = exports['sv_mr_x']:GetReputation(citizenid)

    local targetRep
    if tier == 'easy' then
        targetRep = 10
    elseif tier == 'dilemma' then
        targetRep = 35
    elseif tier == 'high_risk' then
        targetRep = 75
    else
        return nil
    end

    exports['sv_mr_x']:SetReputation(citizenid, targetRep, 'admin_tier_test')

    local result = nil
    exports['sv_mr_x']:GenerateMission(source, nil, function(success, mission, error)
        result = {
            success = success,
            mission = mission,
            error = error,
            tier = tier
        }
    end)

    -- Wait for async callback
    local timeout = 10000
    local waited = 0
    while result == nil and waited < timeout do
        Wait(100)
        waited = waited + 100
    end

    -- Restore original reputation
    exports['sv_mr_x']:SetReputation(citizenid, originalRep, 'admin_tier_restore')

    return result
end)

---Execute a generated mission
lib.callback.register('mrx:admin:executeMission', function(source, mission)
    if not IsAdmin(source) then return false end

    if not mission then return false end

    local result = nil
    exports['sv_mr_x']:ExecuteMission(source, mission, function(success, error)
        result = {success = success, error = error}
    end)

    local timeout = 5000
    local waited = 0
    while result == nil and waited < timeout do
        Wait(100)
        waited = waited + 100
    end

    return result
end)

-- ============================================
-- CHAOS ENGINE
-- ============================================

---Start chaos engine
lib.callback.register('mrx:admin:startChaos', function(source)
    if not IsAdmin(source) then return false end

    -- Override test mode temporarily for chaos
    local wasTestMode = Config.TestMode
    Config.TestMode = false

    local success = exports['sv_mr_x']:StartChaos()

    if not success then
        Config.TestMode = wasTestMode
    end

    Log(MrXConstants.EventTypes.ADMIN_ACTION, GetCitizenId(source), {
        action = 'start_chaos'
    }, source)

    return success
end)

---Stop chaos engine
lib.callback.register('mrx:admin:stopChaos', function(source)
    if not IsAdmin(source) then return false end

    local success = exports['sv_mr_x']:StopChaos()

    Log(MrXConstants.EventTypes.ADMIN_ACTION, GetCitizenId(source), {
        action = 'stop_chaos'
    }, source)

    return success
end)

---Get chaos status
lib.callback.register('mrx:admin:getChaosStatus', function(source)
    if not IsAdmin(source) then return nil end

    return {
        running = exports['sv_mr_x']:IsChaosRunning(),
        testMode = Config.TestMode,
        chaosEnabled = Config.ChaosEngine.Enabled
    }
end)

---Run manual chaos scan
lib.callback.register('mrx:admin:runChaosScan', function(source)
    if not IsAdmin(source) then return nil end

    local candidates = exports['sv_mr_x']:RunChaosScan()

    return {
        candidateCount = #candidates,
        candidates = candidates
    }
end)

---Trigger specific surprise on self
lib.callback.register('mrx:admin:triggerSurprise', function(source, surpriseType)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    -- Valid surprise types
    local validTypes = {
        'FAKE_WARRANT', 'FAKE_REPORT', 'FAKE_CASE', 'FAKE_BOLO',
        'ANONYMOUS_TIP', 'HIT_SQUAD', 'DEBT_COLLECTOR', 'AMBUSH',
        'PLAYER_BOUNTY', 'GANG_CONTRACT', 'GANG_BETRAYAL', 'LEAK_LOCATION'
    }

    local isValid = false
    for _, valid in ipairs(validTypes) do
        if surpriseType == valid then
            isValid = true
            break
        end
    end

    if not isValid then return false end

    -- Execute without warning delay for testing
    exports['sv_mr_x']:ExecuteSurprise(source, citizenid, surpriseType)

    Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
        action = 'trigger_surprise',
        type = surpriseType
    }, source)

    return true
end)

-- ============================================
-- SERVICES (HELP/HARM)
-- ============================================

---Get player's police records
lib.callback.register('mrx:admin:getRecords', function(source)
    if not IsAdmin(source) then return nil end

    local citizenid = GetCitizenId(source)
    return exports['sv_mr_x']:GetPlayerRecords(citizenid)
end)

---Clear all records (admin bypass - no cost)
lib.callback.register('mrx:admin:clearAllRecords', function(source)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    local records = exports['sv_mr_x']:GetPlayerRecords(citizenid)

    local cleared = 0

    -- Clear without cost (admin override)
    if GetResourceState('lb-tablet') == 'started' then
        for _, warrant in ipairs(records.warrants or {}) do
            pcall(function() exports['lb-tablet']:DeletePoliceWarrant(warrant.id) end)
            cleared = cleared + 1
        end
        for _, report in ipairs(records.reports or {}) do
            pcall(function() exports['lb-tablet']:DeletePoliceReport(report.id) end)
            cleared = cleared + 1
        end
        for _, case in ipairs(records.cases or {}) do
            pcall(function() exports['lb-tablet']:DeletePoliceCase(case.id) end)
            cleared = cleared + 1
        end
    end

    Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
        action = 'clear_all_records',
        cleared = cleared
    }, source)

    return cleared
end)

---Test loan system
lib.callback.register('mrx:admin:testLoan', function(source)
    if not IsAdmin(source) then return nil end

    -- Temporarily set high rep for testing
    local citizenid = GetCitizenId(source)
    local originalRep = exports['sv_mr_x']:GetReputation(citizenid)

    exports['sv_mr_x']:SetReputation(citizenid, 75, 'admin_loan_test')

    local success, loanId = exports['sv_mr_x']:IssueLoan(source)

    exports['sv_mr_x']:SetReputation(citizenid, originalRep, 'admin_loan_restore')

    return {success = success, loanId = loanId}
end)

---Test bounty system
lib.callback.register('mrx:admin:testBounty', function(source, amount)
    if not IsAdmin(source) then return nil end

    local citizenid = GetCitizenId(source)
    amount = tonumber(amount) or 10000

    local bountyId = exports['sv_mr_x']:PostBounty(citizenid, amount, 'Admin test bounty')

    return {bountyId = bountyId}
end)

---Test gang betrayal
lib.callback.register('mrx:admin:testGangBetrayal', function(source)
    if not IsAdmin(source) then return false end

    local citizenid = GetCitizenId(source)
    return exports['sv_mr_x']:InitiateGangBetrayal(citizenid, 'Admin test')
end)

-- ============================================
-- EVENTS LOG
-- ============================================

---Get recent events
lib.callback.register('mrx:admin:getRecentEvents', function(source, limit)
    if not IsAdmin(source) then return nil end

    limit = tonumber(limit) or 20

    local events = MySQL.query.await([[
        SELECT * FROM mr_x_events
        ORDER BY created_at DESC
        LIMIT ?
    ]], {limit})

    return events
end)

---Get events for specific player
lib.callback.register('mrx:admin:getPlayerEvents', function(source, targetCid, limit)
    if not IsAdmin(source) then return nil end

    targetCid = targetCid or GetCitizenId(source)
    limit = tonumber(limit) or 20

    local events = MySQL.query.await([[
        SELECT * FROM mr_x_events
        WHERE citizenid = ?
        ORDER BY created_at DESC
        LIMIT ?
    ]], {targetCid, limit})

    return events
end)

-- ============================================
-- SNITCH NETWORK ADMIN
-- ============================================

---Get snitch network stats
lib.callback.register('mrx:admin:getSnitchStats', function(source)
    if not IsAdmin(source) then return nil end

    local stats = MySQL.single.await([[
        SELECT
            COUNT(*) as total,
            COUNT(DISTINCT snitch_citizenid) as snitches,
            COUNT(DISTINCT target_citizenid) as targets,
            SUM(CASE WHEN verified = 1 THEN 1 ELSE 0 END) as verified
        FROM mr_x_snitch_intel
    ]])

    return stats
end)

---Get recent intel reports
lib.callback.register('mrx:admin:getRecentIntel', function(source, limit)
    if not IsAdmin(source) then return nil end

    limit = tonumber(limit) or 10

    local intel = MySQL.query.await([[
        SELECT snitch_citizenid as snitch, target_citizenid as target,
               intel_type, verified, timestamp
        FROM mr_x_snitch_intel
        ORDER BY timestamp DESC
        LIMIT ?
    ]], {limit})

    return intel or {}
end)

---Offer snitch service to self
lib.callback.register('mrx:admin:offerSnitchService', function(source)
    if not IsAdmin(source) then return false end

    local success = pcall(function()
        exports['sv_mr_x']:OfferSnitchService(source)
    end)

    Log(MrXConstants.EventTypes.ADMIN_ACTION, GetCitizenId(source), {
        action = 'offer_snitch_service'
    }, source)

    return success
end)

---Offer snitch service to another player
lib.callback.register('mrx:admin:offerSnitchServiceTo', function(source, targetSource)
    if not IsAdmin(source) then return false end

    local player = exports.qbx_core:GetPlayer(targetSource)
    if not player then return false end

    local success = pcall(function()
        exports['sv_mr_x']:OfferSnitchService(targetSource)
    end)

    Log(MrXConstants.EventTypes.ADMIN_ACTION, GetCitizenId(source), {
        action = 'offer_snitch_service_to',
        target = targetSource
    }, source)

    return success
end)

end) -- End CreateThread for lib.callback registrations

-- ============================================
-- COMMAND REGISTRATION
-- ============================================

RegisterCommand('mrx', function(source, args, rawCommand)
    if source == 0 then
        print('This command can only be used in-game')
        return
    end

    if not IsAdmin(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You do not have permission to use this command'
        })
        return
    end

    TriggerClientEvent('sv_mr_x:client:openAdminMenu', source)
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('IsAdminAllowed', IsAdmin)

-- Return module
return Admin
