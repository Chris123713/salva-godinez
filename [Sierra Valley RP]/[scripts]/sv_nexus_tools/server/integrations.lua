-- Integration Layer for External Script Communication
-- Allows existing scripts to communicate with sv_nexus_tools

local Integrations = {}

-- ============================================
-- EVENT LISTENERS
-- Track activities from other scripts
-- ============================================

local ActivityLog = {}       -- Recent activities for AI context
local EventSubscribers = {}  -- Callbacks registered for specific events
local ActivityHooks = {}     -- Hooks that run on any activity

-- Standard event types for cross-script communication
local EventTypes = {
    -- Criminal Activities
    ROBBERY_STARTED = 'robbery_started',
    ROBBERY_COMPLETED = 'robbery_completed',
    ROBBERY_FAILED = 'robbery_failed',
    HEIST_STARTED = 'heist_started',
    HEIST_COMPLETED = 'heist_completed',
    DRUG_SALE = 'drug_sale',
    DRUG_PRODUCTION = 'drug_production',
    VEHICLE_THEFT = 'vehicle_theft',
    WEAPON_SALE = 'weapon_sale',
    GANG_ACTIVITY = 'gang_activity',
    HOSTAGE_TAKEN = 'hostage_taken',
    HOSTAGE_RELEASED = 'hostage_released',

    -- Police Activities
    DISPATCH_RECEIVED = 'dispatch_received',
    PURSUIT_STARTED = 'pursuit_started',
    PURSUIT_ENDED = 'pursuit_ended',
    ARREST_MADE = 'arrest_made',
    CITATION_ISSUED = 'citation_issued',
    EVIDENCE_COLLECTED = 'evidence_collected',
    CASE_FILED = 'case_filed',
    PATROL_CHECKPOINT = 'patrol_checkpoint',

    -- EMS Activities
    PATIENT_TREATED = 'patient_treated',
    PATIENT_TRANSPORTED = 'patient_transported',
    DEATH_REPORTED = 'death_reported',

    -- Civilian Activities
    JOB_STARTED = 'job_started',
    JOB_COMPLETED = 'job_completed',
    PURCHASE_MADE = 'purchase_made',
    BUSINESS_TRANSACTION = 'business_transaction',
    PROPERTY_INTERACTION = 'property_interaction',

    -- Economy
    LARGE_TRANSACTION = 'large_transaction',
    BANK_DEPOSIT = 'bank_deposit',
    BANK_WITHDRAWAL = 'bank_withdrawal',

    -- Social
    PLAYER_INTERACTION = 'player_interaction',
    FACTION_REP_CHANGE = 'faction_rep_change',
    PHONE_CALL_MADE = 'phone_call_made',
    MESSAGE_SENT = 'message_sent'
}

-- Export event types for external scripts
exports('GetEventTypes', function()
    return EventTypes
end)

--[[
    REPORT ACTIVITY
    External scripts call this to report activities
    This is the main entry point for integration
]]
local function ReportActivity(eventType, data, source)
    local activity = {
        type = eventType,
        data = data,
        source = source,
        citizenid = data.citizenid or (source and Utils.GetCitizenId(source)),
        timestamp = os.time(),
        coords = data.coords
    }

    -- Add to activity log (keep last 100)
    table.insert(ActivityLog, 1, activity)
    if #ActivityLog > 100 then
        table.remove(ActivityLog)
    end

    Utils.Debug('Activity reported:', eventType, source and ('by ' .. source) or '')

    -- Trigger registered subscribers
    if EventSubscribers[eventType] then
        for _, callback in ipairs(EventSubscribers[eventType]) do
            local success, err = pcall(callback, activity)
            if not success then
                Utils.Error('Event subscriber error:', eventType, err)
            end
        end
    end

    -- Trigger global hooks
    for _, hook in ipairs(ActivityHooks) do
        local success, err = pcall(hook, activity)
        if not success then
            Utils.Error('Activity hook error:', err)
        end
    end

    -- Check if this activity can enhance an active mission
    CheckMissionEnhancement(activity)

    -- Store in database for AI context
    MySQL.insert([[
        INSERT INTO nexus_activity_log (event_type, citizenid, data, coords, created_at)
        VALUES (?, ?, ?, ?, NOW())
    ]], {eventType, activity.citizenid, json.encode(data), data.coords and json.encode(data.coords) or nil})

    return activity
end

exports('ReportActivity', ReportActivity)

--[[
    SUBSCRIBE TO EVENTS
    Allow other scripts or internal systems to subscribe to events
]]
local function SubscribeToEvent(eventType, callback)
    if not EventSubscribers[eventType] then
        EventSubscribers[eventType] = {}
    end
    table.insert(EventSubscribers[eventType], callback)

    Utils.Debug('Subscribed to event:', eventType)

    -- Return unsubscribe function
    return function()
        for i, cb in ipairs(EventSubscribers[eventType]) do
            if cb == callback then
                table.remove(EventSubscribers[eventType], i)
                break
            end
        end
    end
end

exports('SubscribeToEvent', SubscribeToEvent)

--[[
    ADD ACTIVITY HOOK
    Register a callback for ALL activities
]]
local function AddActivityHook(callback)
    table.insert(ActivityHooks, callback)

    return function()
        for i, cb in ipairs(ActivityHooks) do
            if cb == callback then
                table.remove(ActivityHooks, i)
                break
            end
        end
    end
end

exports('AddActivityHook', AddActivityHook)

--[[
    GET RECENT ACTIVITY
    Get recent activities for AI context building
]]
local function GetRecentActivity(options)
    options = options or {}
    local limit = options.limit or 20
    local eventType = options.eventType
    local citizenid = options.citizenid
    local since = options.since or (os.time() - 3600) -- Last hour default

    local results = {}
    for _, activity in ipairs(ActivityLog) do
        if #results >= limit then break end

        local matches = true
        if eventType and activity.type ~= eventType then matches = false end
        if citizenid and activity.citizenid ~= citizenid then matches = false end
        if activity.timestamp < since then matches = false end

        if matches then
            table.insert(results, activity)
        end
    end

    return results
end

exports('GetRecentActivity', GetRecentActivity)

--[[
    CHECK MISSION ENHANCEMENT
    See if an activity can be woven into an active mission
]]
function CheckMissionEnhancement(activity)
    local activeMissions = exports['sv_nexus_tools']:GetActiveMissions()
    if not activeMissions then return end

    for missionId, mission in pairs(activeMissions) do
        -- Check if this activity relates to the mission
        local enhancement = nil

        -- Criminal activity during police mission
        if mission.type == 'police' and IsActivityCriminal(activity.type) then
            enhancement = {
                type = 'new_lead',
                description = 'New criminal activity detected related to investigation',
                activity = activity
            }
        end

        -- Police activity during criminal mission
        if mission.type == 'criminal' and IsActivityPolice(activity.type) then
            enhancement = {
                type = 'heat_increase',
                description = 'Police activity detected nearby',
                activity = activity
            }
        end

        -- Same player activity
        if mission.participants[activity.citizenid] then
            enhancement = {
                type = 'participant_action',
                description = 'Mission participant performed related action',
                activity = activity
            }
        end

        if enhancement then
            TriggerMissionEnhancement(missionId, enhancement)
        end
    end
end

function IsActivityCriminal(eventType)
    local criminal = {
        [EventTypes.ROBBERY_STARTED] = true,
        [EventTypes.ROBBERY_COMPLETED] = true,
        [EventTypes.HEIST_STARTED] = true,
        [EventTypes.HEIST_COMPLETED] = true,
        [EventTypes.DRUG_SALE] = true,
        [EventTypes.VEHICLE_THEFT] = true,
        [EventTypes.WEAPON_SALE] = true,
        [EventTypes.GANG_ACTIVITY] = true,
        [EventTypes.HOSTAGE_TAKEN] = true
    }
    return criminal[eventType] or false
end

function IsActivityPolice(eventType)
    local police = {
        [EventTypes.DISPATCH_RECEIVED] = true,
        [EventTypes.PURSUIT_STARTED] = true,
        [EventTypes.ARREST_MADE] = true,
        [EventTypes.EVIDENCE_COLLECTED] = true
    }
    return police[eventType] or false
end

function TriggerMissionEnhancement(missionId, enhancement)
    -- Notify mission system of enhancement opportunity
    local mission = exports['sv_nexus_tools']:GetMission(missionId)
    if not mission then return end

    -- Depending on enhancement type, take action
    if enhancement.type == 'heat_increase' then
        -- Notify criminal players that police are nearby
        for citizenid, participant in pairs(mission.participants) do
            local source = Utils.GetSourceByCitizenId(citizenid)
            if source and participant.role == 'criminal' then
                exports['sv_nexus_tools']:SendPhoneNotification(source, {
                    title = 'Warning',
                    message = 'Police activity detected in the area. Stay alert.',
                    icon = 'fas fa-exclamation-triangle'
                })
            end
        end
    elseif enhancement.type == 'new_lead' then
        -- Notify police players of new lead
        for citizenid, participant in pairs(mission.participants) do
            local source = Utils.GetSourceByCitizenId(citizenid)
            if source and participant.role == 'police' then
                exports['sv_nexus_tools']:SendPhoneNotification(source, {
                    title = 'New Lead',
                    message = 'Dispatch: Related criminal activity reported nearby.',
                    icon = 'fas fa-search'
                })

                -- Could also spawn new evidence or objectives
            end
        end
    end

    Utils.Debug('Mission enhanced:', missionId, enhancement.type)
end

-- ============================================
-- STANDARD INTEGRATION HELPERS
-- Easy functions for common script integrations
-- ============================================

--[[
    ROBBERY INTEGRATION
    Call from robbery scripts (qb-bankrobbery, qb-storerobbery, etc.)
]]
local function OnRobberyStart(source, robberyType, location, data)
    return ReportActivity(EventTypes.ROBBERY_STARTED, {
        robberyType = robberyType,  -- 'bank', 'store', 'house', 'jewelry', 'pacific'
        location = location,
        coords = data.coords,
        estimatedValue = data.estimatedValue,
        alarmTriggered = data.alarmTriggered or true,
        participants = data.participants or {Utils.GetCitizenId(source)}
    }, source)
end

local function OnRobberyComplete(source, robberyType, success, data)
    return ReportActivity(success and EventTypes.ROBBERY_COMPLETED or EventTypes.ROBBERY_FAILED, {
        robberyType = robberyType,
        success = success,
        coords = data.coords,
        lootValue = data.lootValue,
        duration = data.duration,
        policeResponded = data.policeResponded
    }, source)
end

exports('OnRobberyStart', OnRobberyStart)
exports('OnRobberyComplete', OnRobberyComplete)

--[[
    POLICE INTEGRATION
    Call from police scripts (ps-dispatch, cd_dispatch, etc.)
]]
local function OnDispatchReceived(source, dispatchType, data)
    return ReportActivity(EventTypes.DISPATCH_RECEIVED, {
        dispatchType = dispatchType,
        code = data.code,
        description = data.description,
        coords = data.coords,
        priority = data.priority
    }, source)
end

local function OnPursuitStart(source, suspectSource, data)
    return ReportActivity(EventTypes.PURSUIT_STARTED, {
        suspectCitizenId = Utils.GetCitizenId(suspectSource),
        vehiclePlate = data.vehiclePlate,
        vehicleModel = data.vehicleModel,
        reason = data.reason,
        coords = data.coords
    }, source)
end

local function OnArrestMade(source, suspectSource, data)
    return ReportActivity(EventTypes.ARREST_MADE, {
        suspectCitizenId = Utils.GetCitizenId(suspectSource),
        charges = data.charges,
        coords = data.coords,
        fineAmount = data.fineAmount,
        jailTime = data.jailTime
    }, source)
end

exports('OnDispatchReceived', OnDispatchReceived)
exports('OnPursuitStart', OnPursuitStart)
exports('OnArrestMade', OnArrestMade)

--[[
    DRUG INTEGRATION
    Call from drug scripts (qb-drugs, etc.)
]]
local function OnDrugSale(source, drugType, amount, price, buyerType)
    return ReportActivity(EventTypes.DRUG_SALE, {
        drugType = drugType,
        amount = amount,
        price = price,
        buyerType = buyerType,  -- 'npc', 'player'
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

local function OnDrugProduction(source, drugType, amount, labId)
    return ReportActivity(EventTypes.DRUG_PRODUCTION, {
        drugType = drugType,
        amount = amount,
        labId = labId,
        coords = GetEntityCoords(GetPlayerPed(source))
    }, source)
end

exports('OnDrugSale', OnDrugSale)
exports('OnDrugProduction', OnDrugProduction)

--[[
    GANG INTEGRATION
    Call from gang scripts
]]
local function OnGangActivity(source, gangName, activityType, data)
    return ReportActivity(EventTypes.GANG_ACTIVITY, {
        gang = gangName,
        activity = activityType,  -- 'territory_claim', 'spray', 'war', 'meeting'
        coords = data.coords,
        involvedPlayers = data.involvedPlayers
    }, source)
end

exports('OnGangActivity', OnGangActivity)

--[[
    JOB INTEGRATION
    Call from job scripts
]]
local function OnJobStart(source, jobType, data)
    return ReportActivity(EventTypes.JOB_STARTED, {
        jobType = jobType,
        coords = data.coords,
        expectedPay = data.expectedPay
    }, source)
end

local function OnJobComplete(source, jobType, data)
    return ReportActivity(EventTypes.JOB_COMPLETED, {
        jobType = jobType,
        success = data.success,
        pay = data.pay,
        duration = data.duration
    }, source)
end

exports('OnJobStart', OnJobStart)
exports('OnJobComplete', OnJobComplete)

--[[
    ECONOMY INTEGRATION
    Call from banking/economy scripts
]]
local function OnLargeTransaction(source, transactionType, amount, data)
    return ReportActivity(EventTypes.LARGE_TRANSACTION, {
        transactionType = transactionType,  -- 'deposit', 'withdrawal', 'transfer'
        amount = amount,
        accountType = data.accountType,
        toAccount = data.toAccount
    }, source)
end

exports('OnLargeTransaction', OnLargeTransaction)

-- ============================================
-- MISSION TRIGGERS
-- Allow external scripts to request missions
-- ============================================

--[[
    REQUEST CONTEXTUAL MISSION
    External scripts can request Mr. X generate a mission based on context
]]
local function RequestContextualMission(source, context)
    -- Build enhanced context from recent activity
    local recentActivity = GetRecentActivity({
        citizenid = Utils.GetCitizenId(source),
        limit = 10
    })

    local activitySummary = {}
    for _, activity in ipairs(recentActivity) do
        table.insert(activitySummary, string.format('%s: %s', activity.type, json.encode(activity.data)))
    end

    context.recentActivity = table.concat(activitySummary, '\n')
    context.additionalContext = string.format([[
Recent player activity:
%s

Generate a mission that builds on or responds to this activity.
]], context.recentActivity)

    -- Generate mission via Mr. X
    exports['sv_nexus_tools']:GenerateMrXMission(source, context, function(success, mission)
        if success then
            exports['sv_nexus_tools']:ExecuteMrXMission(source, mission, function(ok, missionId)
                if ok then
                    Utils.Success('Contextual mission started:', missionId)
                end
            end)
        end
    end)
end

exports('RequestContextualMission', RequestContextualMission)

--[[
    TRIGGER REACTIVE MISSION
    Automatically trigger mission based on activity patterns
]]
local ReactiveTriggers = {
    -- After 3 successful robberies, Mr. X notices
    {
        name = 'heist_invitation',
        condition = function(activity, history)
            if activity.type ~= EventTypes.ROBBERY_COMPLETED then return false end
            local robberies = 0
            for _, a in ipairs(history) do
                if a.type == EventTypes.ROBBERY_COMPLETED and a.citizenid == activity.citizenid then
                    robberies = robberies + 1
                end
            end
            return robberies >= 3
        end,
        action = function(activity)
            local source = Utils.GetSourceByCitizenId(activity.citizenid)
            if source then
                -- Mr. X reaches out
                exports['sv_nexus_tools']:SendPhoneMail(source, {
                    subject = 'Opportunity',
                    message = 'I\'ve been watching your work. You have potential. Let\'s talk about something bigger.',
                    sender = 'Mr. X'
                })

                -- Queue a heist mission for this player
                SetTimeout(30000, function()
                    RequestContextualMission(source, {
                        missionType = 'criminal',
                        difficulty = 'hard',
                        additionalContext = 'This player has proven themselves with multiple successful robberies. Generate a heist mission.'
                    })
                end)
            end
        end,
        cooldown = 86400  -- 24 hour cooldown per player
    },

    -- Police making arrests gets detective work
    {
        name = 'detective_case',
        condition = function(activity, history)
            if activity.type ~= EventTypes.ARREST_MADE then return false end
            local arrests = 0
            for _, a in ipairs(history) do
                if a.type == EventTypes.ARREST_MADE and a.citizenid == activity.citizenid then
                    arrests = arrests + 1
                end
            end
            return arrests >= 5
        end,
        action = function(activity)
            local source = Utils.GetSourceByCitizenId(activity.citizenid)
            if source then
                exports['sv_nexus_tools']:SendPhoneMail(source, {
                    subject = 'Special Assignment',
                    message = 'Detective, we have a case that needs your attention. Check your MDT for details.',
                    sender = 'Chief of Police'
                })

                SetTimeout(10000, function()
                    RequestContextualMission(source, {
                        missionType = 'police',
                        additionalContext = 'This officer has made multiple arrests. Generate an investigation/detective mission.'
                    })
                end)
            end
        end,
        cooldown = 86400
    }
}

local TriggerCooldowns = {}

-- Check reactive triggers on each activity
AddActivityHook(function(activity)
    for _, trigger in ipairs(ReactiveTriggers) do
        local cooldownKey = trigger.name .. ':' .. (activity.citizenid or 'unknown')

        -- Check cooldown
        if TriggerCooldowns[cooldownKey] and os.time() < TriggerCooldowns[cooldownKey] then
            goto continue
        end

        -- Check condition
        local history = GetRecentActivity({citizenid = activity.citizenid, limit = 50, since = os.time() - 604800})
        if trigger.condition(activity, history) then
            -- Set cooldown
            TriggerCooldowns[cooldownKey] = os.time() + trigger.cooldown

            -- Execute action
            Utils.Debug('Reactive trigger fired:', trigger.name)
            trigger.action(activity)
        end

        ::continue::
    end
end)

-- ============================================
-- CROSS-SCRIPT CALLBACKS
-- Register callbacks other scripts can trigger
-- ============================================

local RegisteredCallbacks = {}

--[[
    REGISTER CALLBACK
    Allow sv_nexus_tools to expose callbacks other scripts can call
]]
local function RegisterIntegrationCallback(name, handler)
    RegisteredCallbacks[name] = handler
    Utils.Debug('Registered integration callback:', name)
end

local function TriggerIntegrationCallback(name, ...)
    if RegisteredCallbacks[name] then
        return RegisteredCallbacks[name](...)
    end
    Utils.Error('Unknown integration callback:', name)
    return nil
end

exports('RegisterIntegrationCallback', RegisterIntegrationCallback)
exports('TriggerIntegrationCallback', TriggerIntegrationCallback)

-- Register standard callbacks
RegisterIntegrationCallback('canPlayerDoMission', function(source, missionType)
    -- Check if player can participate in a mission type
    local player = Utils.GetPlayer(source)
    if not player then return false, 'Player not found' end

    -- Check active missions
    local activeMission = exports['sv_nexus_tools']:GetPlayerActiveMission(Utils.GetCitizenId(source))
    if activeMission then
        return false, 'Already in a mission'
    end

    return true, nil
end)

RegisterIntegrationCallback('getPlayerMissionContext', function(source)
    -- Get context for AI mission generation
    local player = Utils.GetPlayer(source)
    if not player then return nil end

    local citizenid = player.PlayerData.citizenid

    return {
        citizenid = citizenid,
        job = player.PlayerData.job.name,
        gang = player.PlayerData.gang and player.PlayerData.gang.name,
        money = player.PlayerData.money.cash,
        recentActivity = GetRecentActivity({citizenid = citizenid, limit = 10})
    }
end)

RegisterIntegrationCallback('notifyMissionComplete', function(missionId, success, rewards)
    -- External script signals mission completed
    return exports['sv_nexus_tools']:CompleteMission(missionId, success and 'completed' or 'failed')
end)

-- ============================================
-- DATABASE TABLE
-- ============================================

MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `nexus_activity_log` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `event_type` VARCHAR(50) NOT NULL,
            `citizenid` VARCHAR(50),
            `data` JSON,
            `coords` JSON,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_event_type` (`event_type`),
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_created` (`created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])
end)

return Integrations
