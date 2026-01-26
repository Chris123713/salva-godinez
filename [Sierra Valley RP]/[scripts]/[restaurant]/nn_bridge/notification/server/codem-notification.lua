func = {}

func.show = function(src, data)
    TriggerClientEvent("codem-notification:Create", src, data.message, data.style, data.title, data.duration)
end

return func