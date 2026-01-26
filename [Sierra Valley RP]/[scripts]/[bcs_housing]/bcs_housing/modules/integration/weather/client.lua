local weatherSyncScripts = { "av_weather", "cd_easytime", 'weathersync', 'Renewed-Weathersync', 'qb-weathersync',
    'cs_weather', 'night_natural_disasters', 'randol_weather', '0r-easytime' }

function ToggleSyncTime()
    CreateThread(function()
        -- Disable weather sync
        if IsResourceStarted('cd_easytime') then
            TriggerEvent('cd_easytime:PauseSync', true, Config.TimeInShell)
        elseif IsResourceStarted("night_natural_disasters") then
            exports.night_natural_disasters:PauseSynchronization(true)
        elseif IsResourceStarted('qb-weathersync') then
            TriggerEvent('qb-weathersync:client:DisableSync')
        elseif IsResourceStarted('cs_weather') then
            TriggerEvent("cs:weather:client:DisableSync")
        elseif IsResourceStarted('av_weather') then
            TriggerEvent("av_weather:freeze", true, Config.TimeInShell, 00, "CLEAR", false)
        elseif IsResourceStarted('esx-weathersync') then
            TriggerEvent('esx-weathersync:client:DisableSync')
        elseif IsResourceStarted('randol_weather') then
            exports.randol_weather:ToggleSync(false)
        elseif IsResourceStarted('uniq_weathersync') then
            TriggerServerEvent("managesync", "pause")
        elseif not IsResourceStarted('Renewed-Weathersync') then
            TriggerEvent("vSync:toggle", true)
        else
            LocalPlayer.state.syncWeather = false
            TriggerEvent("weathersync:toggleSync")
        end

        local hasWeathersync = false
        for _, script in pairs(weatherSyncScripts) do
            if IsResourceStarted(script) then
                hasWeathersync = true
            end
        end

        -- Set the time to the configured time in shell
        while inside or LocalPlayer.state.designInterior do
            if not hasWeathersync then
                SetRainLevel(0.0)
                ClearOverrideWeather()
                ClearWeatherTypePersist()
                SetWeatherTypePersist("CLEAR")
                SetWeatherTypeNow("CLEAR")
                SetWeatherTypeNowPersist("CLEAR")
                SetForcePedFootstepsTracks(false)
                SetForceVehicleTrails(false)
                RemoveParticleFxInRange(GetEntityCoords(PlayerPedId()), 10.0)

                NetworkOverrideClockTime(Config.TimeInShell, 0, 0)
                Wait(500)
            end
            Wait(500)
        end

        -- Reset weather to server's current weather

        SetRainLevel(-1) -- sets rain back to server's current weather
        if IsResourceStarted('cd_easytime') then
            TriggerEvent('cd_easytime:PauseSync', false)
        elseif IsResourceStarted("night_natural_disasters") then
            exports.night_natural_disasters:PauseSynchronization(false)
        elseif IsResourceStarted('qb-weathersync') then
            TriggerEvent('qb-weathersync:client:EnableSync')
        elseif IsResourceStarted('cs_weather') then
            TriggerEvent("cs:weather:client:EnableSync")
        elseif IsResourceStarted('av_weather') then
            TriggerEvent("av_weather:freeze", false)
        elseif IsResourceStarted('esx-weathersync') then
            TriggerEvent('esx-weathersync:client:EnableSync')
        elseif IsResourceStarted('randol_weather') then
            exports.randol_weather:ToggleSync(true)
        elseif IsResourceStarted('uniq_weathersync') then
            TriggerServerEvent("managesync", "resume")
        elseif not IsResourceStarted('Renewed-Weathersync') then
            TriggerEvent("vSync:toggle", false)
        else
            LocalPlayer.state.syncWeather = true
            TriggerEvent("weathersync:toggleSync")
        end
    end)
end

exports('ToggleSyncTime', ToggleSyncTime)
