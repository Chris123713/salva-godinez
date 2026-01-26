func = {}

func.show = function(data)
    data.style = data.style == "info" and "primary" or data.style
    
    TriggerEvent("QBCore:Notify", data.message, data.style, data.duration)
end

return func