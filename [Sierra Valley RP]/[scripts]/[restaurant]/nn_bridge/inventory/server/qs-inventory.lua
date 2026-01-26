func = {}

func.addItem = function(src, name, amount, metadata)
    exports["qs-inventory"]:AddItem(src, name, amount, false, metadata)
end

func.removeItem = function(src, name, amount)
    exports["qs-inventory"]:RemoveItem(src, name, amount)
end

func.hasItem = function(src, data)
    local count = exports["qs-inventory"]:GetItemTotalAmount(src, type(data) == "string" and data or data.name)

    if not count or count == 0 then return nil end

    return {
        label = exports["qs-inventory"]:GetItemLabel(type(data) == "string" and data or data.name),
        count = count,
        metadata = metadata
    }
end

func.getInventory = function(src)
    local inventory = exports['qs-inventory']:GetInventory(src)
    return inventory
end

func.registerStash = function(name, weight, maxWeight)
    exports['qs-inventory']:RegisterStash(name, 'Stash - ' .. name, weight, maxWeight)
end

return func
