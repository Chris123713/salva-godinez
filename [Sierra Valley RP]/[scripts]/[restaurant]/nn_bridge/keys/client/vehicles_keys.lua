func = {}

func.add = function(plate)
    TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", plate)
end

RegisterNetEvent("pd_bridge:client:addKeys", function(plate)
    bridge.keys.addKeys(plate)
end)

func.remove = function(plate)
    TriggerServerEvent("vehicles_keys:selfRemoveKeys", plate)
end

RegisterNetEvent("pd_bridge:client:removeKeys", function(plate)
    bridge.keys.removeKeys(plate)
end)

return func