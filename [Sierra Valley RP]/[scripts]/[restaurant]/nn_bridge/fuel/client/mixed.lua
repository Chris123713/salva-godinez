func = {}

func.get = function(veh)
    return exports[bridge.fuel.name]:GetFuel(veh)
end

func.set = function(veh, fuel)
    exports[bridge.fuel.name]:SetFuel(veh, fuel)
end

return func