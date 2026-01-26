CreateThread(function()
    while not Config.Framework do
        if NetworkIsSessionStarted() then
            init()
            return
        end
        Wait(0)
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    init()
    TriggerEvent('av_weather:freeze', false)
end)

RegisterNetEvent('esx:playerLoaded', function()
    Wait(2000)
    init()
    TriggerEvent('av_weather:freeze', false)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    init()
end)

RegisterCommand("weather:sync", function()
    print("syncying player with server...")
    if Config.UseFog then
        initFog()
    end
    print("Player Frozen State? ", LocalPlayer.state and LocalPlayer.state.frozen)
    print("ready?", ready)
    print("playerLoaded?", ready)
    print("pauseSync?", pauseSync)
    print("pauseTime?", pauseTime)
    calculateSpeed()
    LocalPlayer.state:set("frozen", false, false)
    ready = true
    pauseSync = false
    pauseTime = false
    playerLoaded = true
    TriggerServerEvent("av_weather:freeze", false)
    print("Player should be now synced.")
end)

-- Some debug commands to test the freeze event :)

-- RegisterCommand("pause", function()
--     TriggerEvent('av_weather:freeze', true, 23, 0, "CLEAR")
-- end)

-- RegisterCommand("play", function()
--     TriggerEvent('av_weather:freeze', false)
-- end)