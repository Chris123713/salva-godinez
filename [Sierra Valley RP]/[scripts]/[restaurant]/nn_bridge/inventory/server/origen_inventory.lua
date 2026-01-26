func = {}

func.addItem = function(src, name, amount, metadata)
    exports['origen_inventory']:addItem(src, name, amount, metadata, nil, true)
end

func.removeItem = function(src, name, amount)   
    exports['origen_inventory']:removeItem(src, name, amount)
end

func.hasItem = function(src, name)
    local items = exports['origen_inventory']:getItem(src, type(name) == "string" and name or name.name, false, false)

    for _, itemData in pairs(items) do
        if itemData.amount and itemData.amount > 0 then
            return {
                label = itemData.label,
                count = itemData.amount,
                metadata = itemData.metadata
            }
        end
    end

    return nil
end

func.getInventory = function(src)
    local inventory = exports['origen_inventory']:getInventoryItems(src)
    local data = {}

    for k,v in pairs(inventory) do
        data[k] = v
        data[k].amount = v.amount
    end
    
    return data
end

return func