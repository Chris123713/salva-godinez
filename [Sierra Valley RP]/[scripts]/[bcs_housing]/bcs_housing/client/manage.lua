RegisterNUICallback('payRent', function(homeId, cb)
    TriggerServerEvent('Housing:server:PayRent', homeId, LocalPlayer.state.CurrentApartment)
    cb(1)
end)

RegisterNUICallback('payMortgagePage', function(data, cb)
    TriggerEvent('Housing:client:PayMortgage', data.identifier, tonumber(data.aptId))
end)

RegisterNUICallback('payMortgage', function(data, cb)
    ToggleNuiFrame(false)
    if data.type then
        TriggerServerEvent('Housing:server:PayMortgageRemaining', data.identifier, data.aptId)
    else
        TriggerServerEvent('Housing:server:PayMortgage', data.identifier, data.aptId)
    end
    cb(1)
end)
