--[[
    DRUGS_CREATOR INTEGRATION SNIPPET
    For drug production, sales, and distribution tracking

    This enables Mr. X to:
    - Track drug empire building for mission triggers
    - Generate supplier/distribution missions
    - Create competition scenarios with rival dealers
    - Offer lab upgrades to successful producers
    - Track drug running patterns for police intelligence

    DRUGS_CREATOR SYSTEMS:
    - Fields (harvesting)
    - Laboratories (processing)
    - Crafting recipes
    - NPC selling
    - Boat/plane selling (large shipments)
    - Pusher system
    - Narcos (high-level dealing)
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
-- FIELD/HARVESTING INTEGRATION
-- ============================================

-- Call when player harvests from a field
local function OnFieldHarvest(source, fieldData)
    ReportToNexus('drug_production', {
        drugType = fieldData.drugType .. '_ingredient',
        amount = fieldData.amount,
        labId = fieldData.fieldId,
        stage = 'harvest',
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when player plants in a field
local function OnFieldPlant(source, fieldData)
    ReportToNexus('drug_production', {
        drugType = fieldData.drugType,
        amount = fieldData.amount,
        labId = fieldData.fieldId,
        stage = 'plant',
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- LABORATORY INTEGRATION
-- ============================================

-- Call when player starts processing at a lab
local function OnLabProcessStart(source, labData)
    ReportToNexus('drug_production', {
        drugType = labData.drugType,
        amount = labData.inputAmount,
        labId = labData.labId,
        stage = 'processing_start',
        recipe = labData.recipe,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when player completes processing
local function OnLabProcessComplete(source, labData)
    ReportToNexus('drug_production', {
        drugType = labData.drugType,
        amount = labData.outputAmount,
        labId = labData.labId,
        stage = 'processing_complete',
        quality = labData.quality,  -- If applicable
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- NPC SELLING INTEGRATION
-- ============================================

-- Call when player sells to NPC
local function OnNPCSale(source, saleData)
    ReportToNexus('drug_sale', {
        drugType = saleData.drugType,
        amount = saleData.amount,
        price = saleData.price,
        buyerType = 'npc',
        npcType = saleData.npcType,  -- 'street', 'corner', etc.
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when sale is interrupted (police, rival, etc.)
local function OnSaleInterrupted(source, interruptData)
    ReportToNexus('drug_sale', {
        drugType = interruptData.drugType,
        amount = interruptData.amount,
        price = 0,
        buyerType = 'interrupted',
        reason = interruptData.reason,  -- 'police', 'rival', 'fled'
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- BOAT/PLANE SELLING (LARGE SHIPMENTS)
-- ============================================

-- Call when player starts a boat/plane run
local function OnShipmentStart(source, shipmentData)
    ReportToNexus('drug_shipment', {
        transportType = shipmentData.type,  -- 'boat', 'plane'
        drugType = shipmentData.drugType,
        amount = shipmentData.amount,
        estimatedValue = shipmentData.value,
        stage = 'started',
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when shipment is delivered
local function OnShipmentDelivered(source, shipmentData)
    ReportToNexus('drug_shipment', {
        transportType = shipmentData.type,
        drugType = shipmentData.drugType,
        amount = shipmentData.amount,
        actualValue = shipmentData.earnings,
        stage = 'delivered',
        success = true,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when shipment fails
local function OnShipmentFailed(source, shipmentData)
    ReportToNexus('drug_shipment', {
        transportType = shipmentData.type,
        drugType = shipmentData.drugType,
        amount = shipmentData.amount,
        stage = 'failed',
        success = false,
        reason = shipmentData.reason,  -- 'intercepted', 'crashed', 'abandoned'
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- PUSHER SYSTEM INTEGRATION
-- ============================================

-- Call when player hires/activates a pusher
local function OnPusherActivated(source, pusherData)
    ReportToNexus('drug_empire', {
        action = 'pusher_activated',
        pusherId = pusherData.id,
        location = pusherData.location,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when pusher makes a sale (periodic callback)
local function OnPusherSale(source, pusherData)
    ReportToNexus('drug_sale', {
        drugType = pusherData.drugType,
        amount = pusherData.amount,
        price = pusherData.earnings,
        buyerType = 'pusher',
        pusherId = pusherData.pusherId,
        coords = pusherData.coords
    }, source)
end

-- ============================================
-- NARCOS INTEGRATION (HIGH-LEVEL)
-- ============================================

-- Call for narcos-level deals
local function OnNarcosDeal(source, dealData)
    ReportToNexus('drug_sale', {
        drugType = dealData.drugType,
        amount = dealData.amount,
        price = dealData.price,
        buyerType = 'narcos',
        dealLevel = 'high',
        coords = GetPlayerCoords(source)
    }, source)

    -- Large deals trigger special attention
    if dealData.price > 50000 then
        ReportToNexus('high_value_criminal', {
            activityType = 'narcos_deal',
            value = dealData.price,
            drugType = dealData.drugType
        }, source)
    end
end

-- ============================================
-- EXAMPLE: Hook into drugs_creator Events
-- ============================================

--[[
-- These examples show how to hook into drugs_creator.
-- Add to appropriate files in the drugs_creator resource.

-- In server/fields.lua:
RegisterNetEvent('drugs_creator:server:fieldHarvest', function(fieldId, drugType, amount)
    local src = source
    -- Existing code...

    -- ADD: Report to nexus
    OnFieldHarvest(src, {
        fieldId = fieldId,
        drugType = drugType,
        amount = amount
    })
end)

-- In server/laboratories.lua:
RegisterNetEvent('drugs_creator:server:labProcessComplete', function(labId, drugType, amount, quality)
    local src = source
    -- Existing code...

    -- ADD: Report to nexus
    OnLabProcessComplete(src, {
        labId = labId,
        drugType = drugType,
        outputAmount = amount,
        quality = quality
    })
end)

-- In server/npc_selling.lua:
RegisterNetEvent('drugs_creator:server:npcSaleComplete', function(drugType, amount, price)
    local src = source
    -- Existing code...

    -- ADD: Report to nexus
    OnNPCSale(src, {
        drugType = drugType,
        amount = amount,
        price = price,
        npcType = 'street'
    })
end)

-- In server/boat_selling.lua:
RegisterNetEvent('drugs_creator:server:boatDeliveryComplete', function(drugType, amount, earnings)
    local src = source
    -- Existing code...

    -- ADD: Report to nexus
    OnShipmentDelivered(src, {
        type = 'boat',
        drugType = drugType,
        amount = amount,
        earnings = earnings
    })
end)
]]

-- ============================================
-- DRUGS_CREATOR INTEGRATIONS FOLDER
-- ============================================

--[[
-- If using drugs_creator's built-in integrations folder (integrations/sv_integrations.lua),
-- you can add nexus reporting there:

-- Add to drugs_creator/integrations/sv_integrations.lua:

-- Nexus Tools Integration
if GetResourceState('sv_nexus_tools') == 'started' then
    local function ReportToNexus(eventType, data, source)
        exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
    end

    -- Add hooks to your framework callbacks
    AddEventHandler('drugs_creator:onSale', function(source, drugType, amount, price)
        ReportToNexus('drug_sale', {
            drugType = drugType,
            amount = amount,
            price = price,
            buyerType = 'npc',
            coords = GetEntityCoords(GetPlayerPed(source))
        }, source)
    end)
end
]]

-- ============================================
-- REACTIVE TRIGGERS
-- ============================================

--[[
-- In sv_nexus_tools, subscribe to drug events for reactive content:

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    local playerDrugStats = {}

    exports['sv_nexus_tools']:SubscribeToEvent('drug_sale', function(activity)
        local citizenid = activity.citizenid
        if not playerDrugStats[citizenid] then
            playerDrugStats[citizenid] = {totalSales = 0, totalValue = 0}
        end

        playerDrugStats[citizenid].totalSales = playerDrugStats[citizenid].totalSales + 1
        playerDrugStats[citizenid].totalValue = playerDrugStats[citizenid].totalValue + (activity.data.price or 0)

        -- After significant activity, offer supplier mission
        if playerDrugStats[citizenid].totalValue >= 100000 then
            print('^3[NEXUS]^7 High-value dealer detected - triggering supplier mission')
            -- TriggerEvent('sv_nexus_tools:offerSupplierMission', activity.source)
        end
    end)

    exports['sv_nexus_tools']:SubscribeToEvent('drug_shipment', function(activity)
        if activity.data.stage == 'delivered' and activity.data.success then
            -- Successful large shipment = major player
            print('^3[NEXUS]^7 Successful shipment - player is a major player')
        end
    end)
end)
]]

-- Export functions
return {
    OnFieldHarvest = OnFieldHarvest,
    OnFieldPlant = OnFieldPlant,
    OnLabProcessStart = OnLabProcessStart,
    OnLabProcessComplete = OnLabProcessComplete,
    OnNPCSale = OnNPCSale,
    OnSaleInterrupted = OnSaleInterrupted,
    OnShipmentStart = OnShipmentStart,
    OnShipmentDelivered = OnShipmentDelivered,
    OnShipmentFailed = OnShipmentFailed,
    OnPusherActivated = OnPusherActivated,
    OnPusherSale = OnPusherSale,
    OnNarcosDeal = OnNarcosDeal
}
