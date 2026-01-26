RegisterNetEvent('av_weather:notification', function(msg,type)
    lib.notify({
        title = 'AV Weather',
        description = msg,
        type = type
    })
end)