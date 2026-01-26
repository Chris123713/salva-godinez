func = {}

func.addItem = function(src, name, amount, metadata)
    exports["codem-inventory"]:AddItem(src, name, amount, false, metadata)
end

func.removeItem = function(src, name, amount)
    exports["codem-inventory"]:RemoveItem(src, name, amount)
end

func.hasItem = function(src, name)
    return exports["codem-inventory"]:HasItem(src, name, 1)
end

func.getInventory = function(src)
    return exports["codem-inventory"]:GetInventory(src)
end

return func