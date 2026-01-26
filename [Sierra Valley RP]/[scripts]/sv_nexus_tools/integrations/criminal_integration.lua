--[[
    CRIMINAL ACTIVITIES INTEGRATION SNIPPET
    For drug scripts, gang systems, weapon dealers, etc.

    This enables Mr. X to:
    - Track drug empire building
    - Generate supplier/distribution missions
    - Create gang war scenarios based on territory
    - Offer weapons deals to active criminals
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
-- DRUG SALES INTEGRATION
-- ============================================

-- Call when player sells drugs to NPC or player
local function OnDrugSale(source, drugType, amount, price, buyerType)
    ReportToNexus('drug_sale', {
        drugType = drugType,      -- 'weed', 'coke', 'meth', 'heroin', etc.
        amount = amount,
        price = price,
        buyerType = buyerType,    -- 'npc', 'player'
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- DRUG PRODUCTION INTEGRATION
-- ============================================

-- Call when player produces drugs at a lab
local function OnDrugProduction(source, drugType, amount, labId)
    ReportToNexus('drug_production', {
        drugType = drugType,
        amount = amount,
        labId = labId,            -- Unique lab identifier
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when player harvests/picks ingredients
local function OnDrugHarvest(source, ingredientType, amount, location)
    ReportToNexus('drug_production', {
        drugType = ingredientType .. '_ingredient',
        amount = amount,
        labId = location,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- VEHICLE THEFT INTEGRATION
-- ============================================

-- Call when player steals a vehicle (boosting, etc.)
local function OnVehicleTheft(source, vehicleData)
    ReportToNexus('vehicle_theft', {
        vehicleModel = vehicleData.model,
        plate = vehicleData.plate,
        class = vehicleData.class,  -- 'A', 'B', 'S', etc.
        value = vehicleData.value,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- WEAPON SALES INTEGRATION
-- ============================================

-- Call when player sells weapons
local function OnWeaponSale(source, weaponType, price, buyerType)
    ReportToNexus('weapon_sale', {
        weaponType = weaponType,  -- 'pistol', 'smg', 'rifle', etc.
        price = price,
        buyerType = buyerType,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when player crafts weapons
local function OnWeaponCraft(source, weaponType, benchId)
    ReportToNexus('weapon_sale', {
        weaponType = weaponType,
        price = 0,
        buyerType = 'crafted',
        benchId = benchId,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- GANG ACTIVITY INTEGRATION
-- ============================================

-- Call for various gang activities
local function OnGangActivity(source, gangName, activityType, data)
    data = data or {}
    data.gang = gangName
    data.activity = activityType
    data.coords = data.coords or GetPlayerCoords(source)

    ReportToNexus('gang_activity', data, source)
end

-- Specific gang events
local function OnTerritorySpray(source, gangName, location, success)
    OnGangActivity(source, gangName, 'territory_spray', {
        location = location,
        success = success
    })
end

local function OnTerritoryClaim(source, gangName, territoryId)
    OnGangActivity(source, gangName, 'territory_claim', {
        territoryId = territoryId
    })
end

local function OnGangWar(source, gangName, enemyGang, outcome)
    OnGangActivity(source, gangName, 'gang_war', {
        enemyGang = enemyGang,
        outcome = outcome  -- 'started', 'won', 'lost', 'truce'
    })
end

local function OnGangMeeting(source, gangName, attendees)
    OnGangActivity(source, gangName, 'gang_meeting', {
        attendees = attendees
    })
end

-- ============================================
-- HOSTAGE INTEGRATION
-- ============================================

local function OnHostageTaken(source, hostageData)
    ReportToNexus('hostage_taken', {
        hostageCount = hostageData.count or 1,
        demands = hostageData.demands,
        location = hostageData.location,
        coords = GetPlayerCoords(source)
    }, source)
end

local function OnHostageReleased(source, resolved)
    ReportToNexus('hostage_released', {
        resolved = resolved,  -- true = peacefully, false = escaped/killed
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- EXAMPLE: qb-drugs INTEGRATION
-- ============================================

--[[
-- In your drug selling script:

RegisterNetEvent('qb-drugs:server:sellDrug', function(drugName, amount, price)
    local src = source

    -- Existing sale code...

    -- ADD: Report to nexus
    OnDrugSale(src, drugName, amount, price, 'npc')
end)

-- Player-to-player sales
RegisterNetEvent('qb-drugs:server:playerSale', function(targetId, drugName, amount, price)
    local src = source

    -- Existing code...

    OnDrugSale(src, drugName, amount, price, 'player')
end)
]]

-- ============================================
-- EXAMPLE: Lab/Production INTEGRATION
-- ============================================

--[[
-- In your drug production script:

RegisterNetEvent('meth:server:finishCook', function(amount)
    local src = source

    -- Existing code...

    OnDrugProduction(src, 'meth', amount, 'meth_lab_1')
end)

RegisterNetEvent('weed:server:harvest', function(plantId, yield)
    local src = source

    -- Existing code...

    OnDrugHarvest(src, 'weed', yield, plantId)
end)
]]

-- ============================================
-- EXAMPLE: Vehicle Boosting INTEGRATION
-- ============================================

--[[
-- In your boosting script:

RegisterNetEvent('boosting:server:vehicleDelivered', function(vehicleData)
    local src = source

    -- Existing code...

    OnVehicleTheft(src, {
        model = vehicleData.model,
        plate = vehicleData.plate,
        class = vehicleData.class,
        value = vehicleData.reward
    })
end)
]]

-- ============================================
-- EXAMPLE: Gang Territory INTEGRATION
-- ============================================

--[[
-- In your gang territory script:

RegisterNetEvent('gangs:server:sprayComplete', function(gangName, location, success)
    local src = source

    -- Existing code...

    OnTerritorySpray(src, gangName, location, success)
end)

RegisterNetEvent('gangs:server:territoryCaptured', function(gangName, territoryId)
    local src = source

    -- Existing code...

    OnTerritoryClaim(src, gangName, territoryId)
end)
]]

-- ============================================
-- EXAMPLE: Hostage INTEGRATION (for heists)
-- ============================================

--[[
-- In your heist script:

RegisterNetEvent('heist:server:hostageGrabbed', function(count)
    local src = source

    OnHostageTaken(src, {
        count = count,
        demands = 'Safe passage and vehicle',
        location = 'bank'
    })
end)

RegisterNetEvent('heist:server:hostageReleased', function(peacefully)
    local src = source

    OnHostageReleased(src, peacefully)
end)
]]

-- ============================================
-- ADVANCED: Track Criminal Empire
-- ============================================

--[[
-- You can subscribe to events to track total criminal activity

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    local playerDrugSales = {}

    exports['sv_nexus_tools']:SubscribeToEvent('drug_sale', function(activity)
        local citizenid = activity.citizenid
        playerDrugSales[citizenid] = (playerDrugSales[citizenid] or 0) + activity.data.price

        -- After $50k in sales, they get noticed
        if playerDrugSales[citizenid] >= 50000 then
            -- Mr. X or a supplier might reach out
            print('High-value dealer detected:', citizenid)
        end
    end)
end)
]]
