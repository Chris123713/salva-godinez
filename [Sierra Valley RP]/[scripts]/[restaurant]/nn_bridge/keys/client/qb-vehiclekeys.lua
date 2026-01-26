func = {}

func.add = function(plate)
    TriggerEvent("qb-vehiclekeys:client:AddKeys", plate)
end

func.remove = function(plate)
    TriggerEvent("qb-vehiclekeys:client:RemoveKeys", plate)
end

return func