func = {}

func.addItem = function(src, name, amount, metadata)
    local PlayerData = bridge.framework.getPlayerData(src)

    exports["core_inventory"]:addItem("primary-"..PlayerData.identifier, name, amount, metadata, "primary")
end

func.removeItem = function(src, name, amount)
    local PlayerData = bridge.framework.getPlayerData(src)

    exports["core_inventory"]:removeItemExact("primary-"..PlayerData.identifier, name, amount)
end

func.hasItem = function(src, name)
    local PlayerData = bridge.framework.getPlayerData(src)
    local item = exports["core_inventory"]:getItem("primary-"..PlayerData.identifier, type(name) == "string" and name or name.name)

    if not item or item.count == 0 then return nil end

    return {
        label = item.label,
        count = item.count,
        metadata = item.metadata
    }
end

return func