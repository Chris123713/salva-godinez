func = {}

func.add = function(plate)
    TriggerServerEvent("okokGarage:GiveKeys", plate, GetPlayerServerId(PlayerId()))
end

func.remove = function(plate)
    TriggerServerEvent("okokGarage:RemoveKeys", plate, GetPlayerServerId(PlayerId()))
end

return func