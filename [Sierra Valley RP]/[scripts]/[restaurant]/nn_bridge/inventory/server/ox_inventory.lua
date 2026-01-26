func = {}

func.addItem = function(src, data, amount, metadata)
    exports["ox_inventory"]:AddItem(src, type(data) == "string" and data or data.name, amount, metadata)
end

func.removeItem = function(src, data, amount)
    exports["ox_inventory"]:RemoveItem(src, type(data) == "string" and data or data.name, amount)
end

func.hasItem = function(src, data)
    local item = exports["ox_inventory"]:GetItem(src, type(data) == "string" and data or data.name)
    if not item or item.count == 0 then return nil end

    return {
        label = item.label,
        count = item.count,
        metadata = item.metadata
    }
end

func.getInventory = function(src)
    local playerItems = exports.ox_inventory:GetInventoryItems(src)
    local data = {}

    for k,v in pairs(playerItems) do
        data[k] = v
        data[k].amount = v.count
    end
    return data
end

func.registerStash = function(name, weight, maxWeight)
    exports.ox_inventory:RegisterStash(name, 'Stash - ' .. name, weight, maxWeight)
end

return func