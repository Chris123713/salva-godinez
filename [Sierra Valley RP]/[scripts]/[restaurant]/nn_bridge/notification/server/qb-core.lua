func = {}

func.show = function(src, data)
    data.style = data.style == "info" and "primary" or data.style
    
    TriggerClientEvent("QBCore:Notify", src, data.message, data.style, data.duration)
end

return func
