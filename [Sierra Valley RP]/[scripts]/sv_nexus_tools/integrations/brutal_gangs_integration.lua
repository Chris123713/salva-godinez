--[[
    BRUTAL_GANGS INTEGRATION SNIPPET
    For gang-based mission generation and territory tracking

    This enables Mr. X to:
    - Generate gang-specific missions based on territory
    - Track gang wars and raids for reactive content
    - Create gang recruitment/expansion missions
    - Offer weapons deals to active gangs
    - Link gang activity to criminal empire building

    EXPORTS AVAILABLE FROM brutal_gangs:
    - isPlayerInGangJob() - Check if player is in a gang
    - playerGangRank() - Get player's rank number
    - playerGangRankName() - Get player's rank name
    - getGangLabelbyName(gangName) - Get gang's display label
]]

-- Helper function to safely call nexus
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function GetPlayerCoords(source)
    return GetEntityCoords(GetPlayerPed(source))
end

-- ============================================
-- GANG STATUS HELPERS
-- ============================================

-- Get complete gang info for a player
---@param source number Player source
---@return table|nil gangInfo
local function GetPlayerGangInfo(source)
    if GetResourceState('brutal_gangs') ~= 'started' then return nil end

    local isInGang = exports.brutal_gangs:isPlayerInGangJob(source)
    if not isInGang then return nil end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return nil end

    local gangName = player.PlayerData.gang.name
    if gangName == 'none' then return nil end

    return {
        name = gangName,
        label = exports.brutal_gangs:getGangLabelbyName(gangName) or gangName,
        rank = exports.brutal_gangs:playerGangRank(source) or 0,
        rankName = exports.brutal_gangs:playerGangRankName(source) or 'Member',
        isLeader = (exports.brutal_gangs:playerGangRank(source) or 0) >= 90  -- Leaders typically have high rank
    }
end

-- ============================================
-- GANG ACTIVITY REPORTING
-- ============================================

-- Call when gang territory is sprayed
local function OnGraffitiPlaced(source, gangName, location)
    local gangInfo = GetPlayerGangInfo(source)

    ReportToNexus('gang_activity', {
        gang = gangName,
        activity = 'graffiti_placed',
        location = location,
        coords = GetPlayerCoords(source),
        gangInfo = gangInfo
    }, source)
end

-- Call when gang graffiti is cleaned
local function OnGraffitiCleaned(source, cleanerGang, targetGang, location)
    ReportToNexus('gang_activity', {
        gang = cleanerGang,
        activity = 'graffiti_cleaned',
        targetGang = targetGang,
        location = location,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when scout mission starts
local function OnScoutStarted(source, gangName, targetGang)
    ReportToNexus('gang_activity', {
        gang = gangName,
        activity = 'scout_started',
        targetGang = targetGang,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when raid starts
local function OnRaidStarted(source, attackingGang, defendingGang)
    ReportToNexus('gang_activity', {
        gang = attackingGang,
        activity = 'raid_started',
        targetGang = defendingGang,
        coords = GetPlayerCoords(source)
    }, source)

    -- Also report to defenders
    ReportToNexus('gang_activity', {
        gang = defendingGang,
        activity = 'raid_defending',
        attackerGang = attackingGang
    }, nil)  -- No source for defending gang broadcast
end

-- Call when raid ends
local function OnRaidEnded(source, attackingGang, defendingGang, outcome)
    ReportToNexus('gang_activity', {
        gang = attackingGang,
        activity = 'raid_ended',
        targetGang = defendingGang,
        outcome = outcome,  -- 'attacker_won', 'defender_won', 'draw'
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when gang task is started (drug heist, kidnapping, etc.)
local function OnGangTaskStarted(source, gangName, taskType, taskData)
    ReportToNexus('gang_activity', {
        gang = gangName,
        activity = 'task_started',
        taskType = taskType,  -- 'drug', 'disposalofthebody', 'homeless', 'assassination'
        taskData = taskData,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when gang task is completed
local function OnGangTaskCompleted(source, gangName, taskType, success, reward)
    ReportToNexus('gang_activity', {
        gang = gangName,
        activity = 'task_completed',
        taskType = taskType,
        success = success,
        reward = reward
    }, source)
end

-- ============================================
-- EXAMPLE: Hook into brutal_gangs Events
-- ============================================

--[[
-- In brutal_gangs files, add these calls:

-- When graffiti is placed (client/graffiti.lua):
RegisterNetEvent('brutal_gangs:server:graffitiPlaced', function(gangName, location)
    local src = source
    OnGraffitiPlaced(src, gangName, location)
end)

-- When raid starts (server/raids.lua):
RegisterNetEvent('brutal_gangs:server:raidStarted', function(attackingGang, defendingGang)
    local src = source
    OnRaidStarted(src, attackingGang, defendingGang)
end)

-- When task completes (server/tasks.lua):
RegisterNetEvent('brutal_gangs:server:taskCompleted', function(gangName, taskType, success, reward)
    local src = source
    OnGangTaskCompleted(src, gangName, taskType, success, reward)
end)
]]

-- ============================================
-- EXTERNAL TASK REGISTRATION
-- ============================================

--[[
-- You can register sv_nexus_tools missions as external tasks in brutal_gangs:
-- Add to Config.ExternalTasks in brutal_gangs/config.lua:

Config.ExternalTasks = {
    ["nexus_heist"] = {
        Label = "HIGH-VALUE HEIST",
        Description = "Mr. X has a special job. Complete it for major rewards.",
        TimeToRestart = 1440,
        event = 'sv_nexus_tools:client:startGangMission',
    },
    ["nexus_delivery"] = {
        Label = "SPECIAL DELIVERY",
        Description = "A sensitive package needs to be moved. No questions asked.",
        TimeToRestart = 720,
        event = 'sv_nexus_tools:client:startDeliveryMission',
    },
}

-- Then in sv_nexus_tools, register the event handler:
RegisterNetEvent('sv_nexus_tools:client:startGangMission', function()
    -- This is called when gang starts the external task
    local gangInfo = GetPlayerGangInfo(source)
    if not gangInfo then return end

    -- Generate gang-specific mission via Mr. X
    exports['sv_nexus_tools']:GenerateMissionForPlayer(source, 'gang_heist', {
        gang = gangInfo.name,
        gangLabel = gangInfo.label
    })
end)
]]

-- ============================================
-- GANG-AWARE MISSION CONTEXT
-- ============================================

-- Get mission context based on gang membership
---@param source number Player source
---@return table context
local function GetGangMissionContext(source)
    local gangInfo = GetPlayerGangInfo(source)

    if not gangInfo then
        return {
            isGangMember = false,
            recommendedTypes = {'solo_criminal', 'freelance'}
        }
    end

    local context = {
        isGangMember = true,
        gang = gangInfo,
        recommendedTypes = {'gang_heist', 'territory', 'gang_war'}
    }

    -- Leaders get different mission options
    if gangInfo.isLeader then
        table.insert(context.recommendedTypes, 'gang_expansion')
        table.insert(context.recommendedTypes, 'alliance_mission')
    end

    return context
end

-- ============================================
-- REACTIVE TRIGGERS FOR GANG ACTIVITY
-- ============================================

--[[
-- Subscribe to gang events in sv_nexus_tools to trigger reactive content:

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    -- Track gang war activity
    local gangWarActivity = {}

    exports['sv_nexus_tools']:SubscribeToEvent('gang_activity', function(activity)
        local gangName = activity.data.gang

        if activity.data.activity == 'raid_started' then
            -- During gang wars, offer weapons to both sides
            gangWarActivity[gangName] = os.time()
            gangWarActivity[activity.data.targetGang] = os.time()

            -- Trigger weapons deal opportunity
            print('^3[NEXUS]^7 Gang war detected - triggering weapons deal opportunity')
        end

        if activity.data.activity == 'graffiti_cleaned' then
            -- Tension building - potential war trigger
            local targetGang = activity.data.targetGang
            -- Could trigger escalation missions
        end
    end)
end)
]]

-- Export functions
return {
    GetPlayerGangInfo = GetPlayerGangInfo,
    GetGangMissionContext = GetGangMissionContext,
    OnGraffitiPlaced = OnGraffitiPlaced,
    OnGraffitiCleaned = OnGraffitiCleaned,
    OnScoutStarted = OnScoutStarted,
    OnRaidStarted = OnRaidStarted,
    OnRaidEnded = OnRaidEnded,
    OnGangTaskStarted = OnGangTaskStarted,
    OnGangTaskCompleted = OnGangTaskCompleted
}
