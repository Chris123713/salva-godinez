func = {}

func.add = function(plate, model)
    exports['qs-vehiclekeys']:GiveKeys(plate, model or "NULL", false)
end

RegisterNetEvent("nn_bridge:client:addKeys", function(plate, hash)
    bridge.keys.add(plate, hash)
end)

func.remove = function(plate, hash)
    local model = GetDisplayNameFromVehicleModel(hash)

    exports['qs-vehiclekeys']:RemoveKeys(plate, model or "NULL")
end

RegisterNetEvent("pd_bridge:client:removeKeys", function(plate, hash)
    bridge.keys.removeKeys(plate, hash)
end)

return func