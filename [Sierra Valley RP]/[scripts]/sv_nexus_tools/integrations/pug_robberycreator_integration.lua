--[[
    PUG-ROBBERYCREATOR INTEGRATION SNIPPET
    For robbery/heist tracking and mission triggers

    This enables Mr. X to:
    - Track player robbery patterns and success rates
    - Generate escalating heist opportunities
    - Create police investigation missions after robberies
    - Link robbery activity to criminal reputation
    - Trigger reactive content based on heist completion

    PUG-ROBBERYCREATOR FEATURES:
    - Custom robbery creation system
    - Minigame integration
    - Guard spawning
    - Door/vault mechanics
    - Bank truck robberies
    - ATM robberies
    - Multi-step heists
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
-- ROBBERY START/END TRACKING
-- ============================================

-- Call when a robbery/heist starts
local function OnRobberyStart(source, robberyData)
    ReportToNexus('robbery_started', {
        robberyType = robberyData.type,  -- 'bank', 'store', 'jewelry', 'atm', 'custom'
        robberyId = robberyData.id,
        location = robberyData.location,
        estimatedValue = robberyData.estimatedValue,
        difficulty = robberyData.difficulty,
        alarmTriggered = robberyData.alarmTriggered or false,
        coords = robberyData.coords or GetPlayerCoords(source)
    }, source)
end

-- Call when robbery step is completed
local function OnRobberyStepComplete(source, stepData)
    ReportToNexus('robbery_progress', {
        robberyType = stepData.robberyType,
        robberyId = stepData.robberyId,
        step = stepData.step,
        totalSteps = stepData.totalSteps,
        minigameUsed = stepData.minigame,
        success = stepData.success,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when robbery is completed
local function OnRobberyComplete(source, robberyData)
    local eventType = robberyData.success and 'robbery_completed' or 'robbery_failed'

    ReportToNexus(eventType, {
        robberyType = robberyData.type,
        robberyId = robberyData.id,
        location = robberyData.location,
        success = robberyData.success,
        lootValue = robberyData.lootValue or 0,
        itemsStolen = robberyData.items,
        duration = robberyData.duration,  -- Time from start to finish
        policeResponded = robberyData.policeResponded,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- BANK TRUCK INTEGRATION
-- ============================================

-- Call when bank truck heist starts
local function OnBankTruckStart(source, truckData)
    ReportToNexus('robbery_started', {
        robberyType = 'bank_truck',
        vehiclePlate = truckData.plate,
        estimatedValue = truckData.value or 50000,
        coords = truckData.coords or GetPlayerCoords(source)
    }, source)
end

-- Call when bank truck is successfully robbed
local function OnBankTruckComplete(source, truckData)
    ReportToNexus('robbery_completed', {
        robberyType = 'bank_truck',
        vehiclePlate = truckData.plate,
        lootValue = truckData.lootValue,
        success = true,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- ATM ROBBERY INTEGRATION
-- ============================================

-- Call when ATM robbery starts
local function OnATMRobberyStart(source, atmData)
    ReportToNexus('robbery_started', {
        robberyType = 'atm',
        atmModel = atmData.model,
        estimatedValue = atmData.value or 2500,
        alarmTriggered = true,  -- ATMs usually trigger alerts
        coords = atmData.coords or GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- GUARD INTERACTION
-- ============================================

-- Call when guards are engaged
local function OnGuardEngaged(source, guardData)
    ReportToNexus('robbery_violence', {
        robberyId = guardData.robberyId,
        guardsKilled = guardData.killed or 0,
        guardsIncapacitated = guardData.incapacitated or 0,
        method = guardData.method,  -- 'stealth', 'lethal', 'nonlethal'
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- VAULT/DOOR BREACH
-- ============================================

-- Call when vault is breached
local function OnVaultBreach(source, vaultData)
    ReportToNexus('robbery_progress', {
        robberyType = vaultData.robberyType,
        robberyId = vaultData.robberyId,
        step = 'vault_breach',
        method = vaultData.method,  -- 'thermite', 'drill', 'hack', 'explosive'
        success = vaultData.success,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- EXAMPLE: Hook into pug-robberycreator
-- ============================================

--[[
-- Since pug-robberycreator uses escrow protection, hook into the
-- unencrypted config callbacks or events.

-- In server/sv_open.lua (unencrypted), add nexus reporting:

-- When robbery starts:
local originalStartRobbery = StartRobbery  -- If there's a function
function StartRobbery(source, robberyId, robberyData)
    -- ADD: Report to nexus
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('robbery_started', {
            robberyType = robberyData.type or 'custom',
            robberyId = robberyId,
            location = robberyData.location,
            estimatedValue = robberyData.reward,
            coords = GetEntityCoords(GetPlayerPed(source))
        }, source)
    end

    -- Original code...
    if originalStartRobbery then
        return originalStartRobbery(source, robberyId, robberyData)
    end
end

-- In server/sv_sellitems.lua (unencrypted):
-- After player sells stolen items:
RegisterNetEvent('pug-robbery:server:sellItems', function(items, totalValue)
    local src = source

    -- Existing code to sell items...

    -- ADD: Report to nexus
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('robbery_completed', {
            robberyType = 'fence',
            lootValue = totalValue,
            items = items,
            success = true,
            coords = GetEntityCoords(GetPlayerPed(src))
        }, src)
    end
end)

-- In server/sv_banktruck.lua (unencrypted):
-- When bank truck is completed:
-- Add similar reporting for bank truck heists
]]

-- ============================================
-- POLICE JOB CHECK (for reset permission)
-- ============================================

-- Check if player is police (for step reset, etc.)
local function IsPlayerPolice(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local job = player.PlayerData.job.name
    local policeJobs = {'police', 'bcso', 'leo', 'ranger', 'trooper', 'sasp', 'lscso'}

    for _, policeJob in ipairs(policeJobs) do
        if job == policeJob then
            return true
        end
    end

    return false
end

-- Call when police reset a robbery step
local function OnPoliceResetStep(source, resetData)
    ReportToNexus('police_action', {
        actionType = 'robbery_reset',
        robberyId = resetData.robberyId,
        step = resetData.step,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- MINIGAME TRACKING
-- ============================================

-- Track minigame performance for skill-based missions
local function OnMinigameComplete(source, minigameData)
    ReportToNexus('criminal_skill', {
        skillType = 'minigame',
        minigameType = minigameData.type,  -- 'hack', 'drill', 'thermite', 'lockpick'
        success = minigameData.success,
        attempts = minigameData.attempts,
        difficulty = minigameData.difficulty,
        robberyId = minigameData.robberyId
    }, source)
end

-- ============================================
-- REACTIVE TRIGGERS
-- ============================================

--[[
-- In sv_nexus_tools, subscribe to robbery events for reactive content:

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    local playerRobberyStats = {}

    exports['sv_nexus_tools']:SubscribeToEvent('robbery_completed', function(activity)
        local citizenid = activity.citizenid
        if not playerRobberyStats[citizenid] then
            playerRobberyStats[citizenid] = {
                totalRobberies = 0,
                successfulRobberies = 0,
                totalValue = 0
            }
        end

        local stats = playerRobberyStats[citizenid]
        stats.totalRobberies = stats.totalRobberies + 1
        if activity.data.success then
            stats.successfulRobberies = stats.successfulRobberies + 1
        end
        stats.totalValue = stats.totalValue + (activity.data.lootValue or 0)

        -- After multiple successful robberies, offer bigger heist
        if stats.successfulRobberies >= 5 then
            print('^3[NEXUS]^7 Experienced robber detected - offering major heist')
            -- TriggerEvent('sv_nexus_tools:offerMajorHeist', activity.source)
        end

        -- After $500k stolen, they're on the radar
        if stats.totalValue >= 500000 then
            print('^3[NEXUS]^7 High-value thief - triggering heat')
            -- TriggerEvent('sv_nexus_tools:increaseHeat', activity.source)
        end
    end)

    -- Track violence levels
    exports['sv_nexus_tools']:SubscribeToEvent('robbery_violence', function(activity)
        if activity.data.guardsKilled and activity.data.guardsKilled > 0 then
            -- Violent robber - changes mission offerings
            print('^3[NEXUS]^7 Violent robber detected - adjusting mission profile')
        end
    end)
end)
]]

-- ============================================
-- WEBHOOK INTEGRATION
-- ============================================

--[[
-- pug-robberycreator has a webhook system.
-- You can intercept webhook calls to also report to nexus.

-- In server/sv_open.lua, find the webhook send function and add:
local originalWebhook = SendDiscordWebhook  -- If exists
function SendDiscordWebhook(title, description, color)
    -- Original webhook code...

    -- Also report to nexus
    if GetResourceState('sv_nexus_tools') == 'started' then
        exports['sv_nexus_tools']:ReportActivity('robbery_log', {
            title = title,
            description = description
        }, nil)
    end

    if originalWebhook then
        return originalWebhook(title, description, color)
    end
end
]]

-- Export functions
return {
    OnRobberyStart = OnRobberyStart,
    OnRobberyStepComplete = OnRobberyStepComplete,
    OnRobberyComplete = OnRobberyComplete,
    OnBankTruckStart = OnBankTruckStart,
    OnBankTruckComplete = OnBankTruckComplete,
    OnATMRobberyStart = OnATMRobberyStart,
    OnGuardEngaged = OnGuardEngaged,
    OnVaultBreach = OnVaultBreach,
    IsPlayerPolice = IsPlayerPolice,
    OnPoliceResetStep = OnPoliceResetStep,
    OnMinigameComplete = OnMinigameComplete
}
