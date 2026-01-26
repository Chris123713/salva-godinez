func = {}

func.show = function(data)
    TriggerEvent("ox_lib:notify", {
        title = data.title,
        description = data.message,
        duration = data.duration,
        type = data.style,
    })
end

return func