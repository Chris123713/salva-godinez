func = {}

func.show = function(src, data)
    TriggerClientEvent("ox_lib:notify", src, {
        title = data.title,
        description = data.message,
        duration = data.duration,
        type = data.style,
    })
end

return func