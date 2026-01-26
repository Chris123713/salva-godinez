func = {}

func.addItem = function(src, name, amount, metadata)
    exports["tgiann-inventory"]:AddItem(src, name, amount, nil, metadata)
end

func.removeItem = function(src, name, amount)
    exports["tgiann-inventory"]:RemoveItem(src, name, amount)
end

func.hasItem = function(src, data)
    local count = exports["tgiann-inventory"]:GetItemCount(src, type(data) == "string" and data or data.name)

    if not count or count == 0 then return nil end

    return {
        label = exports["tgiann-inventory"]:GetItemLabel(type(data) == "string" and data or data.name, src),
        count = count,
        metadata = metadata
    }
end

func.getInventory = function(src)
    local inventory = exports["tgiann-inventory"]:GetPlayerItems(src)
    return inventory
end

func.registerStash = function(name, weight, maxWeight)
    exports['tgiann-inventory']:RegisterStash(name, 'Stash - ' .. name, weight, maxWeight)
end

return func
