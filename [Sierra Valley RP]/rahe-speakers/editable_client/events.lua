CreateThread(function()
    if GetResourceState('jg-advancedgarages') == 'started' then
        RegisterNetEvent('jg-advancedgarages:client:TakeOutVehicle:config', function(vehicle, vehicleDbData, type)
            TriggerServerEvent('rahe-speakers:server:vehicleSpawnedByClient', VehToNet(vehicle))
        end)
    end
end)
