func = {}

func.get = function(veh)
    return Entity(veh).state.fuel
end

func.set = function(veh, fuel)
    Entity(veh).state.fuel = fuel
end

return func