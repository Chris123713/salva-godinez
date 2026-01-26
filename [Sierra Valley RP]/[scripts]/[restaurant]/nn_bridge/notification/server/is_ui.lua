func = {}

func.show = function(src, data)
    TriggerClientEvent("is_ui:Notify", src, data.title, data.message, data.duration, data.style)
end

return func