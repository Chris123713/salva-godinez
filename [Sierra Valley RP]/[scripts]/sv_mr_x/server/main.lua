--[[
    Mr. X Server Main
    =================
    Main entry point and coordination
]]

local MrX = {}

-- Version info
MrX.Version = '1.0.0'
MrX.Name = 'sv_mr_x'

-- ============================================
-- STARTUP
-- ============================================

local function PrintBanner()
    print('')
    print('^3╔══════════════════════════════════════════╗^7')
    print('^3║           ^7MR. X - THE FIXER^3              ║^7')
    print('^3║        ^7Sierra Valley RP v' .. MrX.Version .. '^3          ║^7')
    print('^3╚══════════════════════════════════════════╝^7')
    print('')
end

local function CheckDependencies()
    local dependencies = {
        {name = 'ox_lib', required = true},
        {name = 'oxmysql', required = true},
        {name = 'qbx_core', required = true},
        {name = 'lb-phone', required = true},
        {name = 'sv_nexus_tools', required = false},
        {name = 'lb-tablet', required = false}
    }

    local allGood = true

    for _, dep in ipairs(dependencies) do
        local state = GetResourceState(dep.name)

        if state == 'started' then
            print('^2[MR_X]^7 ✓ ' .. dep.name .. ' - loaded')
        elseif dep.required then
            print('^1[MR_X]^7 ✗ ' .. dep.name .. ' - REQUIRED but not started!')
            allGood = false
        else
            print('^3[MR_X]^7 ⚠ ' .. dep.name .. ' - optional, not started')
        end
    end

    return allGood
end

-- ============================================
-- TEST MODE GATE
-- ============================================

---Check if automated actions are allowed
---@return boolean allowed
function MrX.IsAutomatedAllowed()
    return not Config.TestMode
end

---Gate function for automated actions
---@param actionName string Name of the action for logging
---@return boolean allowed
function MrX.GateAutomated(actionName)
    if Config.TestMode then
        if Config.Debug then
            print('^3[MR_X]^7 Blocked automated action: ' .. actionName .. ' (TEST_MODE)')
        end
        return false
    end
    return true
end

-- ============================================
-- UTILITY EXPORTS
-- ============================================

---Find player source by citizenid
---@param citizenid string
---@return number|nil source
function MrX.FindPlayerSource(citizenid)
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
-- PROACTIVE CONTACT SYSTEM
-- ============================================

-- Track last contact time per player
local LastProactiveContact = {}
local DailyContactCount = {}
local LastResetDay = os.date('%j')

---Check if Mr. X can proactively contact a player
---@param citizenid string
---@param source? number Player source for exemption check
---@return boolean canContact
---@return string|nil reason
local function CanProactivelyContact(citizenid, source)
    if not Config.ProactiveContact.Enabled then
        return false, 'proactive_disabled'
    end

    if Config.TestMode then
        return false, 'test_mode'
    end

    -- Check exemption - no contact for exempt players
    if source then
        local isExempt = exports['sv_mr_x']:IsExempt(source)
        if isExempt then
            return false, 'exempt'
        end
    else
        local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(citizenid)
        if isExempt then
            return false, 'exempt'
        end
    end

    -- Check daily limit
    local today = os.date('%j')
    if today ~= LastResetDay then
        DailyContactCount = {}
        LastResetDay = today
    end

    local dailyCount = DailyContactCount[citizenid] or 0
    if dailyCount >= Config.ProactiveContact.MaxContactsPerDay then
        return false, 'daily_limit'
    end

    -- Check minimum interval
    local lastContact = LastProactiveContact[citizenid]
    if lastContact then
        local elapsed = (os.time() - lastContact) / 60  -- in minutes
        if elapsed < Config.ProactiveContact.MinIntervalMinutes then
            return false, 'too_recent'
        end
    end

    -- Check active hours
    if Config.ProactiveContact.ActiveHours then
        local hour = tonumber(os.date('%H'))
        if hour < Config.ProactiveContact.ActiveHours.start or hour >= Config.ProactiveContact.ActiveHours.stop then
            return false, 'outside_hours'
        end
    end

    return true
end

---Attempt proactive contact with a player
---@param source number
---@param citizenid string
local function AttemptProactiveContact(source, citizenid)
    local canContact, reason = CanProactivelyContact(citizenid, source)
    if not canContact then
        if Config.Debug then
            print('^3[MR_X]^7 Skipped proactive contact for ' .. citizenid .. ': ' .. (reason or 'unknown'))
        end
        return
    end

    -- Check activity tracking eligibility (if available)
    local activityEligible, activityReason = true, nil
    pcall(function()
        activityEligible, activityReason = exports['sv_mr_x']:IsEligibleForContact(citizenid)
    end)

    if not activityEligible then
        if Config.Debug then
            print('^3[MR_X]^7 Skipped proactive contact (activity): ' .. citizenid .. ' - ' .. (activityReason or 'unknown'))
        end
        return
    end

    -- Roll for contact chance
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    if not profile then return end

    local tier = exports['sv_mr_x']:GetReputationTier(profile.reputation or 0)
    local tierModifier = Config.ProactiveContact.TierModifiers[tier:upper()] or 1.0
    local adjustedChance = Config.ProactiveContact.ContactChance * tierModifier

    if math.random() > adjustedChance then
        return  -- Failed chance roll
    end

    -- Select contact type based on weights
    local contactType = MrX.SelectContactType(profile)

    -- Record contact
    LastProactiveContact[citizenid] = os.time()
    DailyContactCount[citizenid] = (DailyContactCount[citizenid] or 0) + 1

    -- Execute contact
    MrX.ExecuteProactiveContact(source, citizenid, contactType, profile)
end

---Select contact type based on weights and player state
---@param profile table
---@return string contactType
function MrX.SelectContactType(profile)
    local weights = Config.ProactiveContact.ContactTypes
    local rep = profile.reputation or 0

    -- Adjust weights based on player state
    local adjustedWeights = {}
    local totalWeight = 0

    for contactType, weight in pairs(weights) do
        local adjustedWeight = weight

        -- Only offer tips to high rep
        if contactType == 'TIP' and rep < 40 then
            adjustedWeight = 0
        end

        -- Only send warnings to low rep
        if contactType == 'WARNING' and rep >= 20 then
            adjustedWeight = 0
        end

        adjustedWeights[contactType] = adjustedWeight
        totalWeight = totalWeight + adjustedWeight
    end

    -- Random selection
    local roll = math.random() * totalWeight
    local cumulative = 0

    for contactType, weight in pairs(adjustedWeights) do
        cumulative = cumulative + weight
        if roll <= cumulative then
            return contactType
        end
    end

    return 'CHECK_IN'
end

---Execute a proactive contact
---@param source number
---@param citizenid string
---@param contactType string
---@param profile table
function MrX.ExecuteProactiveContact(source, citizenid, contactType, profile)
    local messages = {
        MISSION_OFFER = {
            "I have work for someone with your... talents.",
            "A situation has arisen. Your involvement could be... profitable.",
            "Check your email. Opportunity knocks."
        },
        CHECK_IN = {
            "I'm always watching.",
            "Your name came up recently. Interesting times ahead.",
            "Stay ready. I may need you soon."
        },
        REPUTATION_UPDATE = {
            profile.reputation >= 50 and "Your reputation precedes you. Impressive." or "Your standing could be better.",
            profile.reputation >= 30 and "You're making progress." or "I expected more from you."
        },
        WARNING = {
            "I know where you are.",
            "Don't think I've forgotten.",
            "Your debts accumulate."
        },
        TIP = {
            "A gift, for a valued associate.",
            "Consider this... professional courtesy."
        }
    }

    local messageList = messages[contactType] or messages.CHECK_IN
    local message = messageList[math.random(#messageList)]

    exports['sv_mr_x']:SendMrXMessage(source, message)

    -- If mission offer, follow up with actual mission
    if contactType == 'MISSION_OFFER' then
        SetTimeout(5000, function()
            exports['sv_mr_x']:GenerateMission(source, nil, function(success, mission)
                if success and mission then
                    exports['sv_mr_x']:ExecuteMission(source, mission, function() end)
                end
            end)
        end)
    end

    -- If tip, give location
    if contactType == 'TIP' then
        SetTimeout(3000, function()
            exports['sv_mr_x']:GetLocationTip(source)
        end)
    end

    if Config.Debug then
        print('^2[MR_X]^7 Proactive contact (' .. contactType .. ') sent to ' .. citizenid)
    end
end

-- ============================================
-- PROACTIVE CONTACT THREAD
-- ============================================

CreateThread(function()
    Wait(30000)  -- Wait 30 seconds after start

    while true do
        Wait(60000)  -- Check every minute

        if Config.ProactiveContact.Enabled and not Config.TestMode then
            local players = GetPlayers()

            for _, playerId in ipairs(players) do
                local source = tonumber(playerId)
                local player = exports.qbx_core:GetPlayer(source)

                if player then
                    local citizenid = player.PlayerData.citizenid

                    -- Check if player has been online long enough
                    -- (Would need to track login time for accurate check)

                    AttemptProactiveContact(source, citizenid)
                end
            end
        end
    end
end)

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Handle mission accept from email
RegisterNetEvent('sv_mr_x:server:acceptMission', function(data)
    local source = source
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    -- Verify the mission was for this player
    if data and data.citizenid and data.citizenid ~= citizenid then
        exports['sv_mr_x']:SendMrXMessage(source, "This offer wasn't meant for you.")
        return
    end

    exports['sv_mr_x']:SendMrXMessage(source, "Good. Don't disappoint me.")

    -- Update last contact
    exports['sv_mr_x']:UpdateLastContact(citizenid)
end)

-- Handle request for record clear
RegisterNetEvent('sv_mr_x:server:requestRecordClear', function(message)
    local source = source
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local rep = exports['sv_mr_x']:GetReputation(citizenid)

    if rep < Config.Services.ClearWarrant.minRep then
        exports['sv_mr_x']:SendMrXMessage(source, "You haven't earned that privilege yet.")
        return
    end

    -- Get records and offer to clear
    local records = exports['sv_mr_x']:GetPlayerRecords(citizenid)
    local warrantCount = #(records.warrants or {})
    local reportCount = #(records.reports or {})
    local caseCount = #(records.cases or {})

    if warrantCount + reportCount + caseCount == 0 then
        exports['sv_mr_x']:SendMrXMessage(source, "Your record is already clean.")
        return
    end

    local totalCost = (warrantCount * Config.Services.ClearWarrant.cost) +
                      (reportCount * Config.Services.ClearReport.cost) +
                      (caseCount * Config.Services.ClearCase.cost)

    local msg = string.format(
        "I can make %d warrant(s), %d report(s), and %d case(s) disappear. Cost: $%s. Reply 'clean' to proceed.",
        warrantCount, reportCount, caseCount, totalCost
    )

    exports['sv_mr_x']:SendMrXMessage(source, msg)
end)

-- ============================================
-- NEXUS MISSION COMPLETION HOOKS
-- ============================================

-- Listen for sv_nexus_tools mission completions
AddEventHandler('sv_nexus_tools:missionComplete', function(missionId, outcome, participantCid)
    if not participantCid then return end

    local outcomeMap = {
        completed = 'success',
        failed = 'failure',
        abandoned = 'abandoned',
        timeout = 'timeout'
    }

    local mrxOutcome = outcomeMap[outcome] or outcome

    local source = MrX.FindPlayerSource(participantCid)
    exports['sv_mr_x']:HandleMissionCompletion(participantCid, missionId, mrxOutcome, source)
end)

-- ============================================
-- SHUTDOWN
-- ============================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    print('^3[MR_X]^7 Shutting down...')

    -- Stop chaos engine
    pcall(function() exports['sv_mr_x']:StopChaos() end)

    -- Mark active sessions as timeout
    MySQL.update.await([[
        UPDATE mr_x_sessions SET status = 'timeout' WHERE status = 'active'
    ]])

    print('^3[MR_X]^7 Shutdown complete')
end)

-- ============================================
-- RESOURCE START
-- ============================================

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    PrintBanner()

    if not CheckDependencies() then
        print('^1[MR_X]^7 Missing required dependencies! Resource may not function correctly.')
    end

    print('')
    print('^3[MR_X]^7 Test Mode: ' .. (Config.TestMode and '^2ENABLED^7 (No automated actions)' or '^1DISABLED^7'))
    print('^3[MR_X]^7 Chaos Engine: ' .. (Config.ChaosEngine.Enabled and '^2Enabled^7' or '^1Disabled^7'))
    print('^3[MR_X]^7 Proactive Contact: ' .. (Config.ProactiveContact.Enabled and '^2Enabled^7' or '^1Disabled^7'))
    print('')

    if Config.TestMode then
        print('^3[MR_X]^7 ═══════════════════════════════════════════════════')
        print('^3[MR_X]^7   TEST MODE ACTIVE - Use /mrx to access admin menu')
        print('^3[MR_X]^7 ═══════════════════════════════════════════════════')
    end

    print('')
    print('^2[MR_X]^7 Mr. X is watching...')
    print('')
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('IsAutomatedAllowed', MrX.IsAutomatedAllowed)
exports('GateAutomated', MrX.GateAutomated)
exports('FindPlayerSource', MrX.FindPlayerSource)

-- Return module
return MrX
