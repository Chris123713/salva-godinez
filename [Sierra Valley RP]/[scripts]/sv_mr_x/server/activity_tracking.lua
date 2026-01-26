--[[
    Mr. X Activity Tracking
    =======================
    Tracks player sessions, activity, and idle status
    for optimal proactive contact timing
]]

local Activity = {}

-- ============================================
-- SESSION TRACKING
-- ============================================

-- Active player sessions {citizenid -> session data}
local PlayerSessions = {}

-- Activity types that reset idle timer
local ACTIVITY_TYPES = {
    'message_sent',
    'mission_started',
    'mission_completed',
    'service_used',
    'bounty_action',
    'job_activity',
    'vehicle_interaction',
    'weapon_purchase',
    'drug_activity'
}

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
    ]], {citizenid, eventType, JsonEncode(data), source or 'activity_tracking'})
end

-- ============================================
-- SESSION MANAGEMENT
-- ============================================

---Start tracking a player session
---@param source number
---@param citizenid string
function Activity.StartSession(source, citizenid)
    if not citizenid then return end

    PlayerSessions[citizenid] = {
        source = source,
        citizenid = citizenid,
        loginTime = os.time(),
        lastActivity = os.time(),
        lastActivityType = 'login',
        activityCount = 0,
        missionCount = 0,
        lastMissionComplete = nil,
        isInMission = false,
        currentJob = nil,
        isInJobActivity = false,
        idleStartTime = os.time()
    }

    if Config.Debug then
        print('^2[MR_X:ACTIVITY]^7 Started session for ' .. citizenid)
    end

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhook('session_start', {
            citizenid = citizenid,
            source = source,
            timestamp = os.time()
        })
    end
end

---End a player session
---@param citizenid string
---@param reason? string
function Activity.EndSession(citizenid, reason)
    if not citizenid or not PlayerSessions[citizenid] then return end

    local session = PlayerSessions[citizenid]
    local duration = os.time() - session.loginTime

    -- Save session summary to database
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {
        citizenid,
        'SESSION_END',
        JsonEncode({
            duration = duration,
            activityCount = session.activityCount,
            missionCount = session.missionCount,
            reason = reason or 'disconnect'
        }),
        'activity_tracking'
    })

    PlayerSessions[citizenid] = nil

    if Config.Debug then
        print('^3[MR_X:ACTIVITY]^7 Ended session for ' .. citizenid .. ' (duration: ' .. duration .. 's)')
    end
end

---Get a player's session data
---@param citizenid string
---@return table|nil session
function Activity.GetSession(citizenid)
    return PlayerSessions[citizenid]
end

-- ============================================
-- ACTIVITY RECORDING
-- ============================================

---Record player activity (resets idle timer)
---@param citizenid string
---@param activityType string
---@param details? table
function Activity.RecordActivity(citizenid, activityType, details)
    if not citizenid then return end

    local session = PlayerSessions[citizenid]
    if not session then
        -- Create session if doesn't exist
        local source = exports['sv_mr_x']:FindPlayerSource(citizenid)
        if source then
            Activity.StartSession(source, citizenid)
            session = PlayerSessions[citizenid]
        end
    end

    if not session then return end

    session.lastActivity = os.time()
    session.lastActivityType = activityType
    session.activityCount = session.activityCount + 1
    session.idleStartTime = os.time()

    -- Track specific activity types
    if activityType == 'mission_started' then
        session.isInMission = true
    elseif activityType == 'mission_completed' or activityType == 'mission_failed' or activityType == 'mission_abandoned' then
        session.isInMission = false
        session.lastMissionComplete = os.time()
        session.missionCount = session.missionCount + 1
    elseif activityType == 'job_activity_start' then
        session.isInJobActivity = true
    elseif activityType == 'job_activity_end' then
        session.isInJobActivity = false
    end

    if Config.Debug then
        print('^2[MR_X:ACTIVITY]^7 ' .. citizenid .. ': ' .. activityType)
    end
end

-- ============================================
-- IDLE/AVAILABILITY CHECKS
-- ============================================

---Check if player is considered "idle" (available for proactive contact)
---@param citizenid string
---@return boolean isIdle
---@return string|nil reason
function Activity.IsPlayerIdle(citizenid)
    local session = PlayerSessions[citizenid]
    if not session then return false, 'no_session' end

    -- Check if in mission
    if session.isInMission then
        return false, 'in_mission'
    end

    -- Check if in job activity
    if session.isInJobActivity then
        return false, 'in_job_activity'
    end

    -- Check idle time (3 minutes of no activity = idle)
    local idleDuration = os.time() - session.idleStartTime
    if idleDuration < 180 then
        return false, 'recent_activity'
    end

    return true
end

---Check if player has been online long enough for proactive contact
---@param citizenid string
---@return boolean eligible
function Activity.IsOnlineLongEnough(citizenid)
    local session = PlayerSessions[citizenid]
    if not session then return false end

    local onlineMinutes = (os.time() - session.loginTime) / 60
    return onlineMinutes >= (Config.ProactiveContact.MinOnlineMinutes or 15)
end

---Check if enough time has passed since last mission
---@param citizenid string
---@return boolean eligible
function Activity.IsPastMissionCooldown(citizenid)
    local session = PlayerSessions[citizenid]
    if not session then return true end  -- No session = no recent mission

    if not session.lastMissionComplete then
        return true  -- Never completed a mission this session
    end

    local minutesSinceMission = (os.time() - session.lastMissionComplete) / 60
    return minutesSinceMission >= (Config.ProactiveContact.PostMissionCooldownMinutes or 30)
end

---Full eligibility check for proactive contact
---@param citizenid string
---@return boolean eligible
---@return string|nil reason
function Activity.IsEligibleForContact(citizenid)
    -- Check if online long enough
    if not Activity.IsOnlineLongEnough(citizenid) then
        return false, 'not_online_long_enough'
    end

    -- Check if past mission cooldown
    if not Activity.IsPastMissionCooldown(citizenid) then
        return false, 'recent_mission'
    end

    -- Check if idle (if required)
    if Config.ProactiveContact.RequireIdle then
        local isIdle, reason = Activity.IsPlayerIdle(citizenid)
        if not isIdle then
            return false, reason
        end
    end

    return true
end

-- ============================================
-- EVENT HANDLERS - PLAYER LIFECYCLE
-- ============================================

-- Player loaded (login complete)
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    if not player then return end
    local source = player.PlayerData.source
    local citizenid = player.PlayerData.citizenid
    Activity.StartSession(source, citizenid)
end)

-- Player dropped (disconnect)
AddEventHandler('playerDropped', function(reason)
    local source = source
    local citizenid = GetCitizenId(source)
    if citizenid then
        Activity.EndSession(citizenid, reason)
    end
end)

-- ============================================
-- EVENT HANDLERS - MISSION ACTIVITY
-- ============================================

AddEventHandler('sv_mr_x:internal:missionStarted', function(source, citizenid, missionData)
    Activity.RecordActivity(citizenid, 'mission_started', missionData)
end)

AddEventHandler('sv_mr_x:internal:missionCompleted', function(source, citizenid, outcome)
    if outcome == 'success' then
        Activity.RecordActivity(citizenid, 'mission_completed', {outcome = outcome})
    elseif outcome == 'failure' then
        Activity.RecordActivity(citizenid, 'mission_failed', {outcome = outcome})
    else
        Activity.RecordActivity(citizenid, 'mission_abandoned', {outcome = outcome})
    end
end)

-- ============================================
-- EVENT HANDLERS - JOB ACTIVITY
-- ============================================

-- Generic job activity tracking
AddEventHandler('sv_mr_x:internal:jobActivity', function(citizenid, activityType, details)
    Activity.RecordActivity(citizenid, 'job_activity', {
        type = activityType,
        details = details
    })
end)

-- ============================================
-- EVENT HANDLERS - EXTERNAL INTEGRATIONS
-- ============================================

-- Try to hook into common job resources
CreateThread(function()
    Wait(5000)  -- Wait for resources to load

    -- Hook into mechanic jobs if available
    if GetResourceState('qbx_mechanicjob') == 'started' then
        AddEventHandler('qbx_mechanicjob:server:repairVehicle', function(source, vehiclePlate)
            local citizenid = GetCitizenId(source)
            if citizenid then
                Activity.RecordActivity(citizenid, 'job_activity', {
                    type = 'mechanic_repair',
                    plate = vehiclePlate
                })
            end
        end)
    end

    -- Hook into drug sales if available
    if GetResourceState('qbx_drugs') == 'started' then
        AddEventHandler('qbx_drugs:server:sellDrugs', function(source, drugType, amount)
            local citizenid = GetCitizenId(source)
            if citizenid then
                Activity.RecordActivity(citizenid, 'drug_activity', {
                    type = 'drug_sale',
                    drug = drugType,
                    amount = amount
                })

                -- Also record as fact
                if exports['sv_mr_x'] then
                    pcall(function()
                        exports['sv_mr_x']:RecordFact(citizenid, 'DRUG_SALES', {
                            drug = drugType,
                            amount = amount,
                            timestamp = os.time()
                        })
                    end)
                end
            end
        end)
    end

    if Config.Debug then
        print('^2[MR_X:ACTIVITY]^7 External hooks registered')
    end
end)

-- ============================================
-- CLEANUP THREAD
-- ============================================

CreateThread(function()
    while true do
        Wait(60000)  -- Every minute

        local now = os.time()

        for citizenid, session in pairs(PlayerSessions) do
            -- Check if player is still online
            local source = exports['sv_mr_x']:FindPlayerSource(citizenid)
            if not source then
                -- Player left without trigger, clean up
                Activity.EndSession(citizenid, 'orphaned')
            end
        end
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('GetSession', Activity.GetSession)
exports('RecordActivity', Activity.RecordActivity)
exports('IsPlayerIdle', Activity.IsPlayerIdle)
exports('IsOnlineLongEnough', Activity.IsOnlineLongEnough)
exports('IsPastMissionCooldown', Activity.IsPastMissionCooldown)
exports('IsEligibleForContact', Activity.IsEligibleForContact)
exports('StartSession', Activity.StartSession)
exports('EndSession', Activity.EndSession)

-- Return module
return Activity
