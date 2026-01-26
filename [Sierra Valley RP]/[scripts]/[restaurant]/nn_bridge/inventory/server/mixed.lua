func = {}

func.addItem = function(src, name, amount, metadata)
    exports[bridge.inventory.name]:AddItem(src, name, amount, false, metadata)
end

func.removeItem = function(src, name, amount)   
    exports[bridge.inventory.name]:RemoveItem(src, name, amount)
end

func.hasItem = function(src, name)
    local item = exports[bridge.inventory.name]:GetItemByName(src, type(name) == "string" and name or name.name)

    if not item or item.amount == 0 then return nil end

    return {
        label = item.label,
        count = item.amount,
        metadata = item.info
    }
end

func.getInventory = function(src)
    local inventory = exports[bridge.inventory.name]:GetInventory(src)
    local data = {}

    for k,v in pairs(inventory) do
        if v.amount and v.amount > 0 then
            data[k] = v
            data[k].amount = v.amount
        elseif v.count and v.count > 0 then
            data[k] = v
            data[k].amount = v.count
        end
    end
    
    return data
end

return func