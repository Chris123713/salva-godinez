RegisterNetEvent('cd_vehiclecontrol:ToggleNUIFocus_2')
AddEventHandler('cd_vehiclecontrol:ToggleNUIFocus_2', function()
    NUI_status = true
    SetUserRadioControlEnabled(false)
    while NUI_status do
        Wait(0)
        SetNuiFocus(NUI_status, NUI_status)
        SetNuiFocusKeepInput(NUI_status)
        for cd = 1, #Config.DisabledKeys do
            DisableControlAction(0, Config.DisabledKeys[cd], true)
        end
        SetPlayerCanDoDriveBy(PlayerId(), false)
        HudWeaponWheelIgnoreSelection(true)
    end
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetUserRadioControlEnabled(true)
    SetPlayerCanDoDriveBy(PlayerId(), true)
    HudWeaponWheelIgnoreSelection(false)
    local count, keys = 0, {177, 200, 202, 322}
    while count < 100 do 
        Wait(0)
        count=count+1
        for cd = 1, #keys do
            DisableControlAction(0, keys[cd], true)
        end
    end
end)

if Config.PreventAutoSeatShuffle then
    CreateThread(function()
        local last_vehicle = nil
        SetPedConfigFlag(PlayerPedId(), 184, true)
        while true do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            if IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(vehicle, 0) == ped and vehicle ~= last_vehicle then
                Wait(100)
                SetPedIntoVehicle(ped, vehicle, 0)
            end
            last_vehicle = vehicle
            Wait(100)
        end
    end)
else
    SetPedConfigFlag(PlayerPedId(), 184, false)
end