local qbShared = require 'shared.main'

qbShared.Items = {}

-- Check if ox_inventory is started before loading data
if GetResourceState('ox_inventory') ~= 'started' then
    print("^1[qbx_core] ERROR: ox_inventory is not started! Make sure ox_inventory starts BEFORE qbx_core in server.cfg^0")
    print("^3[qbx_core] Bridge will continue but items may not load correctly.^0")
    return qbShared
end

-- Load ox_inventory items with error handling
local oxItems
-- Try LoadResourceFile first (most reliable)
local itemsFile = LoadResourceFile('ox_inventory', 'data/items.lua')
if itemsFile then
    local func, err = load(itemsFile, '@@ox_inventory/data/items.lua')
    if func then
        local success, result = pcall(func)
        if success and type(result) == 'table' then
            oxItems = result
        end
    end
end

-- Fallback to lib.load if LoadResourceFile didn't work
if not oxItems then
    local oxItemsSuccess, oxItemsResult = pcall(function()
        return lib.load('@ox_inventory/data/items')
    end)
    if oxItemsSuccess and type(oxItemsResult) == 'table' then
        oxItems = oxItemsResult
    end
end

-- Final fallback to require method
if not oxItems then
    local oxItemsSuccess, oxItemsResult = pcall(function()
        return require '@ox_inventory.data.items'
    end)
    if oxItemsSuccess and type(oxItemsResult) == 'table' then
        oxItems = oxItemsResult
    end
end

if not oxItems then
    print("^1[qbx_core] ERROR: Could not load ox_inventory data.items^0")
    print("^3[qbx_core] Make sure ox_inventory starts BEFORE qbx_core in server.cfg and the resource is named 'ox_inventory'^0")
    return qbShared
end
for item, data in pairs(oxItems) do
    qbShared.Items[item] = {
        name = item,
        label = data.label,
        weight = data.weight or 0,
        type = 'item',
        image = data.client?.image or string.strjoin(item,'.png'),
        unique = false,
        useable = true,
        shouldClose = data.close or true,
        combinable = nil,
        description = data.description or nil
    }
end

-- Load ox_inventory weapons with error handling
local oxWeapons
-- Try LoadResourceFile first (most reliable)
local weaponsFile = LoadResourceFile('ox_inventory', 'data/weapons.lua')
if weaponsFile then
    local func, err = load(weaponsFile, '@@ox_inventory/data/weapons.lua')
    if func then
        local success, result = pcall(func)
        if success and type(result) == 'table' then
            oxWeapons = result
        end
    end
end

-- Fallback to lib.load if LoadResourceFile didn't work
if not oxWeapons then
    local oxWeaponsSuccess, oxWeaponsResult = pcall(function()
        return lib.load('@ox_inventory/data/weapons')
    end)
    if oxWeaponsSuccess and type(oxWeaponsResult) == 'table' then
        oxWeapons = oxWeaponsResult
    end
end

-- Final fallback to require method
if not oxWeapons then
    local oxWeaponsSuccess, oxWeaponsResult = pcall(function()
        return require '@ox_inventory.data.weapons'
    end)
    if oxWeaponsSuccess and type(oxWeaponsResult) == 'table' then
        oxWeapons = oxWeaponsResult
    end
end

if not oxWeapons then
    print("^1[qbx_core] ERROR: Could not load ox_inventory data.weapons^0")
    print("^3[qbx_core] Make sure ox_inventory starts BEFORE qbx_core in server.cfg and the resource is named 'ox_inventory'^0")
    return qbShared
end
for weapon, data in pairs(oxWeapons.Weapons) do
    weapon = string.lower(weapon)
    qbShared.Items[weapon] = {
        name = weapon,
        label = data.label,
        weight = data.weight,
        type = 'weapon',
        ammotype = data.ammoname or nil,
        image = data.client?.image or string.strjoin(weapon,'.png'),
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = nil
    }
end
for component, data in pairs(oxWeapons.Components) do
    component = string.lower(component)
    qbShared.Items[component] = {
        name = component,
        label = data.label,
        weight = data.weight,
        type = 'component',
        image = data.client?.image or string.strjoin(component,'.png'),
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = data.description
    }
end
for ammo, data in pairs(oxWeapons.Ammo) do
    ammo = string.lower(ammo)
    qbShared.Items[ammo] = {
        name = ammo,
        label = data.label,
        weight = data.weight,
        type = 'ammo',
        image = data.client?.image or string.strjoin(ammo,'.png'),
        unique = true,
        useable = false,
        shouldClose = true,
        combinable = nil,
        description = data.description
    }
end

local starterItems = require 'config.shared'.starterItems
---@deprecated use starterItems in config/shared.lua
qbShared.StarterItems = {}

if type(starterItems) == 'table' then
    for i = 1, #starterItems do
        local item = starterItems[i]

        ---@diagnostic disable-next-line: deprecated
        qbShared.StarterItems[item.name] = {
            amount = item.amount,
            item = item.name,
        }
    end
end

---@deprecated use lib.math.groupdigits from ox_lib
qbShared.CommaValue = lib.math.groupdigits

---@deprecated use lib.string.random from ox_lib
qbShared.RandomStr = function(length)
    if length <= 0 then return '' end
    local pattern = math.random(2) == 1 and 'a' or 'A'

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomStr(length - 1) .. lib.string.random(pattern)
end

---@deprecated use lib.string.random from ox_lib
qbShared.RandomInt = function(length)
    if length <= 0 then return '' end

    ---@diagnostic disable-next-line: deprecated
    return qbShared.RandomInt(length - 1) .. lib.string.random('1')
end

---@deprecated use string.strsplit with CfxLua 5.4
qbShared.SplitStr = function(str, delimiter)
    local result = table.pack(string.strsplit(delimiter, str))
    result.n = nil
    return result
end

---@deprecated use qbx.string.trim from modules/lib.lua
qbShared.Trim = function(str)
    if not str then return nil end
    return qbx.string.trim(str)
end

---@deprecated use qbx.string.capitalize from modules/lib.lua
qbShared.FirstToUpper = function(str)
    if not str then return nil end
    return qbx.string.capitalize(str)
end

---@deprecated use qbx.math.round from modules/lib.lua
qbShared.Round = qbx.math.round

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.ChangeVehicleExtra = qbx.setVehicleExtras

---@deprecated use qbx.setVehicleExtra from modules/lib.lua
qbShared.SetDefaultVehicleExtras = qbx.setVehicleExtras

---@deprecated use qbx.armsWithoutGloves.male from modules/lib.lua
qbShared.MaleNoGloves = qbx.armsWithoutGloves.male

---@deprecated use qbx.armsWithoutGloves.female from modules/lib.lua
qbShared.FemaleNoGloves = qbx.armsWithoutGloves.female

return qbShared
