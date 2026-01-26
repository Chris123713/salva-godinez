func = {}

func.show = function(src, data)
    TriggerClientEvent("pd_bridge:client:showNotify", src, data)
end

return func