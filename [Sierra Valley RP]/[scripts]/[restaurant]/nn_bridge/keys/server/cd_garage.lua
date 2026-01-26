func = {}

func.add = function(plate)
    TriggerEvent('cd_garage:AddKeys', plate)
end

func.remove = function(plate)
    TriggerEvent('cd_garage:RemoveKeys', plate)
end

return func