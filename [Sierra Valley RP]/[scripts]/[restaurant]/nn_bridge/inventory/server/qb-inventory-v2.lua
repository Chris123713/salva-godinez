local QBCore = exports['qb-core']:GetCoreObject()
local func = {}

func.addItem = function(src, name, amount, metadata)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.AddItem(name, amount, false, metadata)
    end
end

func.removeItem = function(src, name, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        Player.Functions.RemoveItem(name, amount)
    end
end

func.hasItem = function(src, name)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end

    local itemName = type(name) == "table" and name.name or name
    local item = Player.Functions.GetItemByName(itemName)

    if not item or item.amount <= 0 then return nil end

    return {
        label = item.label,
        count = item.amount,
        metadata = item.info
    }
end

func.getInventory = function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return {} end

    return Player.PlayerData.items
end

return func