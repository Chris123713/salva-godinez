---@class FurnitureAsItem
---@field model string
---@field label string
---@field imageurl string

---@class KeyAsItem
---@field homeId number
---@field aptId number
---@field label string
---@field name string
---@field permissions table
---@field owner string

function GetInventoryItems(item)
    if Config.Inventory == 'ox_inventory' then
        return exports.ox_inventory:Search('slots', item)
    end

    if Config.Inventory == 'qb-inventory' or Config.Inventory == 'lj-inventory' or Config.Inventory == 'ak47_inventory' or Config.Inventory == 'ps_inventory' then
        local items = PlayerData.items
        local result = {}

        for k, v in pairs(items) do
            if v.name == item then
                table.insert(result, v)
            end
        end

        return result
    end

    if Config.Inventory == 'core_inventory' then
        local items = exports.core_inventory:getInventory()
        local result = {}

        for k, v in pairs(items) do
            if v.name == item then
                table.insert(result, v)
            end
        end

        return result
    end

    if Config.Inventory == 'tgiann' then
        local items = exports["tgiann-inventory"]:GetPlayerItems()
        local result = {}

        for k, v in pairs(items) do
            if v.name == item then
                table.insert(result, v)
            end
        end

        return result
    end


    if Config.Inventory == 'origen_inventory' then
        local items = exports.origen_inventory:Search('slots', item)
        local result = {}

        for k, v in pairs(items) do
            if v.name == item then
                table.insert(result, v)
            end
        end

        return result
    end

    return {}
end

--- Get furniture items from inventory
--- @return FurnitureAsItem[]
function GetFurnitureItems()
    local items = GetInventoryItems(Config.FurnitureItem)

    for k, v in pairs(items) do
        if v.name == Config.FurnitureItem and (v.metadata or v.info) then
            items[k] = v.metadata or v.info
        end
    end

    return items
end

function UseFurniture()
    ExecuteCommand('furnish')
end

RegisterNetEvent('Housing:client:UseFurniture', UseFurniture)
exports('UseFurniture', UseFurniture)

--- Get key items from inventory
--- @return KeyAsItem[]
function GetKeyItems()
    local items = GetInventoryItems(Config.KeyAsItem.ItemName)

    for k, v in pairs(items) do
        if v.name == Config.KeyAsItem.ItemName and (v.metadata or v.info) then
            items[k] = v.metadata or v.info
        end
    end

    return items
end
