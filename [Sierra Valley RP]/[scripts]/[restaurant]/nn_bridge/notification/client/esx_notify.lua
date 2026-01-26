func = {}

func.show = function(data)    
    TriggerEvent("ESX:Notify", data.style, data.duration, data.message)
end

return func