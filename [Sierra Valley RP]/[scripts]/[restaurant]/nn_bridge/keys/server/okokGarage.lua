func = {}

func.add = function(src, plate)
    TriggerEvent("okokGarage:GiveKeys", plate, src)
end

func.remove = function(src, plate)
    TriggerEvent("okokGarage:RemoveKeys", plate, src)
end

return func