--[[
    NEXTGENFIVEM_CRAFTING INTEGRATION SNIPPET
    For crafting/production tracking and supply missions

    This enables Mr. X to:
    - Track weapon/item crafting for criminal reputation
    - Generate supply acquisition missions
    - Create special blueprint/recipe missions
    - Link crafting activity to criminal empire building
    - Offer bench upgrades to prolific crafters

    NEXTGENFIVEM_CRAFTING FEATURES:
    - Workbench system
    - Recipe management
    - Blueprint items (optional)
    - Queue system
    - Level system (optional)
    - Portable benches
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
-- CRAFTING EVENT TRACKING
-- ============================================

-- Call when player starts crafting an item
local function OnCraftingStart(source, craftData)
    ReportToNexus('crafting_activity', {
        action = 'start',
        item = craftData.item,
        amount = craftData.amount,
        benchId = craftData.benchId,
        benchType = craftData.benchType,  -- 'weapons', 'drugs', 'general', etc.
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when crafting completes
local function OnCraftingComplete(source, craftData)
    ReportToNexus('crafting_activity', {
        action = 'complete',
        item = craftData.item,
        amount = craftData.amount,
        benchId = craftData.benchId,
        benchType = craftData.benchType,
        success = craftData.success ~= false,
        coords = GetPlayerCoords(source)
    }, source)

    -- Special tracking for weapons
    if IsWeaponItem(craftData.item) then
        ReportToNexus('weapon_sale', {
            weaponType = craftData.item,
            price = 0,
            buyerType = 'crafted',
            benchId = craftData.benchId,
            coords = GetPlayerCoords(source)
        }, source)
    end

    -- Special tracking for drugs
    if IsDrugItem(craftData.item) then
        ReportToNexus('drug_production', {
            drugType = craftData.item,
            amount = craftData.amount,
            labId = craftData.benchId,
            stage = 'crafted',
            coords = GetPlayerCoords(source)
        }, source)
    end
end

-- Call when crafting fails
local function OnCraftingFailed(source, craftData)
    ReportToNexus('crafting_activity', {
        action = 'failed',
        item = craftData.item,
        amount = craftData.amount,
        benchId = craftData.benchId,
        reason = craftData.reason,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- ITEM CLASSIFICATION
-- ============================================

-- Check if item is a weapon
local function IsWeaponItem(itemName)
    local weaponPrefixes = {'weapon_', 'pistol', 'rifle', 'smg', 'shotgun', 'sniper'}
    local weaponSuffixes = {'_ammo', '_clip', '_suppressor'}

    itemName = string.lower(itemName)

    for _, prefix in ipairs(weaponPrefixes) do
        if string.find(itemName, prefix) then
            return true
        end
    end

    for _, suffix in ipairs(weaponSuffixes) do
        if string.find(itemName, suffix) then
            return true
        end
    end

    return false
end

-- Check if item is a drug
local function IsDrugItem(itemName)
    local drugItems = {
        'weed', 'marijuana', 'coke', 'cocaine', 'meth', 'heroin',
        'lsd', 'ecstasy', 'mdma', 'crack', 'oxy', 'joint',
        'baggie', 'brick'
    }

    itemName = string.lower(itemName)

    for _, drug in ipairs(drugItems) do
        if string.find(itemName, drug) then
            return true
        end
    end

    return false
end

-- ============================================
-- BENCH ACCESS TRACKING
-- ============================================

-- Call when player accesses a bench
local function OnBenchAccess(source, benchData)
    ReportToNexus('crafting_activity', {
        action = 'access',
        benchId = benchData.benchId,
        benchType = benchData.benchType,
        benchOwner = benchData.owner,
        coords = GetPlayerCoords(source)
    }, source)
end

-- Call when portable bench is placed
local function OnPortableBenchPlaced(source, benchData)
    ReportToNexus('crafting_activity', {
        action = 'portable_placed',
        benchType = benchData.benchType,
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- BLUEPRINT/RECIPE TRACKING
-- ============================================

-- Call when player learns a blueprint
local function OnBlueprintLearned(source, blueprintData)
    ReportToNexus('crafting_activity', {
        action = 'blueprint_learned',
        blueprint = blueprintData.name,
        item = blueprintData.item,
        source = blueprintData.source  -- 'mission', 'purchase', 'found'
    }, source)
end

-- ============================================
-- EXAMPLE: Hook into nextgenfivem_crafting
-- ============================================

--[[
-- The crafting script may have hooks or events you can use.
-- Check src/lib/utils/sv_hooks.lua if available.

-- If you have access to crafting events, add:

-- In server files or as a separate integration:
RegisterNetEvent('crafting:server:craftComplete', function(itemName, amount, benchId)
    local src = source

    if GetResourceState('sv_nexus_tools') == 'started' then
        OnCraftingComplete(src, {
            item = itemName,
            amount = amount,
            benchId = benchId,
            benchType = 'unknown'
        })
    end
end)

-- If using ox_lib hooks pattern:
AddEventHandler('crafting:onCraftComplete', function(source, item, amount, benchData)
    if GetResourceState('sv_nexus_tools') == 'started' then
        OnCraftingComplete(source, {
            item = item,
            amount = amount,
            benchId = benchData.id,
            benchType = benchData.type
        })
    end
end)
]]

-- ============================================
-- REACTIVE CONTENT TRIGGERS
-- ============================================

--[[
-- In sv_nexus_tools, track crafting for reactive content:

CreateThread(function()
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end

    local playerCraftingStats = {}

    exports['sv_nexus_tools']:SubscribeToEvent('crafting_activity', function(activity)
        if activity.data.action ~= 'complete' then return end

        local citizenid = activity.citizenid
        local item = activity.data.item

        if not playerCraftingStats[citizenid] then
            playerCraftingStats[citizenid] = {
                totalCrafts = 0,
                weapons = 0,
                drugs = 0
            }
        end

        local stats = playerCraftingStats[citizenid]
        stats.totalCrafts = stats.totalCrafts + 1

        if IsWeaponItem(item) then
            stats.weapons = stats.weapons + 1
        elseif IsDrugItem(item) then
            stats.drugs = stats.drugs + 1
        end

        -- Prolific weapon crafter
        if stats.weapons >= 10 then
            print('^3[NEXUS]^7 Prolific weapon crafter detected - offering arms deal mission')
        end

        -- Prolific drug producer
        if stats.drugs >= 20 then
            print('^3[NEXUS]^7 Prolific drug producer - offering distribution mission')
        end
    end)
end)
]]

-- ============================================
-- SUPPLY MISSIONS
-- ============================================

--[[
-- Track crafting supplies for mission generation:

-- If player crafts weapons but needs materials:
local function CheckSupplyNeeds(source, benchType)
    -- Check player inventory for crafting materials
    local materials = {
        weapons = {'steel', 'rubber', 'metalscrap', 'aluminum'},
        drugs = {'weed_leaf', 'coke_brick', 'meth_crystal'}
    }

    local needed = materials[benchType]
    if not needed then return {} end

    local lowSupplies = {}
    for _, material in ipairs(needed) do
        local count = exports.ox_inventory:Search(source, 'count', material)
        if count < 5 then
            table.insert(lowSupplies, material)
        end
    end

    return lowSupplies
end

-- Could trigger supply missions when materials are low
]]

-- Export functions
return {
    OnCraftingStart = OnCraftingStart,
    OnCraftingComplete = OnCraftingComplete,
    OnCraftingFailed = OnCraftingFailed,
    OnBenchAccess = OnBenchAccess,
    OnPortableBenchPlaced = OnPortableBenchPlaced,
    OnBlueprintLearned = OnBlueprintLearned,
    IsWeaponItem = IsWeaponItem,
    IsDrugItem = IsDrugItem
}
