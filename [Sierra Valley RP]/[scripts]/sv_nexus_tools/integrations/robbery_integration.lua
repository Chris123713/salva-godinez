--[[
    ROBBERY INTEGRATION SNIPPET
    Copy relevant parts into your robbery scripts (qb-bankrobbery, qb-storerobbery, etc.)

    This enables Mr. X to:
    - Track player robbery patterns
    - Generate heist missions for successful robbers
    - Create police investigation missions after robberies
    - Trigger reactive content based on criminal activity
]]

-- Helper function to safely call nexus
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

-- ============================================
-- BANK ROBBERY INTEGRATION
-- Add these to your bank robbery script
-- ============================================

-- Call when robbery starts (alarm triggered, hack begun, etc.)
local function OnBankRobberyStart(source, bankId, bankCoords)
    ReportToNexus('robbery_started', {
        robberyType = 'bank',
        location = bankId,
        coords = bankCoords,
        estimatedValue = 50000,  -- Adjust based on your config
        alarmTriggered = true,
        participants = {exports.qbx_core:GetPlayer(source).PlayerData.citizenid}
    }, source)
end

-- Call when robbery completes
local function OnBankRobberyComplete(source, bankId, success, lootValue, duration)
    ReportToNexus(success and 'robbery_completed' or 'robbery_failed', {
        robberyType = 'bank',
        location = bankId,
        success = success,
        lootValue = lootValue,
        duration = duration,
        policeResponded = true  -- Set based on your police response tracking
    }, source)
end

-- ============================================
-- STORE ROBBERY INTEGRATION
-- ============================================

local function OnStoreRobberyStart(source, storeId, storeCoords)
    ReportToNexus('robbery_started', {
        robberyType = 'store',
        location = storeId,
        coords = storeCoords,
        estimatedValue = 1500,
        alarmTriggered = true
    }, source)
end

local function OnStoreRobberyComplete(source, storeId, success, lootValue)
    ReportToNexus(success and 'robbery_completed' or 'robbery_failed', {
        robberyType = 'store',
        location = storeId,
        success = success,
        lootValue = lootValue
    }, source)
end

-- ============================================
-- JEWELRY STORE INTEGRATION
-- ============================================

local function OnJewelryRobberyStart(source, coords)
    ReportToNexus('robbery_started', {
        robberyType = 'jewelry',
        coords = coords,
        estimatedValue = 75000,
        alarmTriggered = true
    }, source)
end

-- ============================================
-- PACIFIC STANDARD INTEGRATION
-- ============================================

local function OnPacificHeistStart(source, participants, coords)
    -- This is a major heist, use heist event
    ReportToNexus('heist_started', {
        heistType = 'pacific',
        coords = coords,
        estimatedValue = 500000,
        participants = participants
    }, source)
end

local function OnPacificHeistComplete(source, success, totalLoot)
    ReportToNexus(success and 'heist_completed' or 'robbery_failed', {
        heistType = 'pacific',
        success = success,
        totalLoot = totalLoot
    }, source)
end

-- ============================================
-- HOUSE ROBBERY INTEGRATION
-- ============================================

local function OnHouseRobberyStart(source, houseId, coords)
    ReportToNexus('robbery_started', {
        robberyType = 'house',
        location = houseId,
        coords = coords,
        estimatedValue = 5000,
        alarmTriggered = math.random() > 0.5  -- 50% chance
    }, source)
end

-- ============================================
-- EXAMPLE: qb-bankrobbery INTEGRATION
-- Add to server/main.lua in appropriate events
-- ============================================

--[[
-- In your StartFleecaRobbery function or event:
RegisterNetEvent('qb-bankrobbery:server:startFleeca', function(bankId)
    local src = source
    local bankData = Config.SmallBanks[bankId]

    -- Your existing code...

    -- ADD THIS:
    OnBankRobberyStart(src, bankId, bankData.coords)
end)

-- In your robbery completion:
RegisterNetEvent('qb-bankrobbery:server:fleecaComplete', function(bankId, loot)
    local src = source

    -- Your existing code...

    -- ADD THIS:
    OnBankRobberyComplete(src, bankId, true, loot, robberyDuration)
end)
]]

-- ============================================
-- EXAMPLE: Direct Event Registration
-- If you want to hook without modifying original scripts
-- ============================================

--[[
-- Create a new resource that listens to existing events
AddEventHandler('qb-bankrobbery:alarmTriggered', function(bankId, coords)
    local src = source
    OnBankRobberyStart(src, bankId, coords)
end)

AddEventHandler('qb-bankrobbery:robberyComplete', function(bankId, success, loot)
    local src = source
    OnBankRobberyComplete(src, bankId, success, loot, 0)
end)
]]

-- Export these if you want to call from other resources
-- exports('OnBankRobberyStart', OnBankRobberyStart)
-- exports('OnBankRobberyComplete', OnBankRobberyComplete)
