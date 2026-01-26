func = {}

func.show = function(data)
    TriggerEvent("codem-notification:Create", data.message, data.style, data.title, data.duration)
end

return func