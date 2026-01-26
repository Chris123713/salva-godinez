func = {}

func.get = function(veh)
    return GetVehicleFuelLevel(veh)
end

func.set = function(veh, fuel)
    SetVehicleFuelLevel(veh, fuel)
end

return func