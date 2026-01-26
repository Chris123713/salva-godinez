func = {}

func.show = function(src, data)
    TriggerClientEvent("ESX:Notify", src, data.style, data.duration, data.message)
end

return func