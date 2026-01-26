func = {}

func.add = function(src, plate)
    TriggerClientEvent("pd_bridge:client:addKeys", src, plate)
end

func.remove = function(src, plate)
    TriggerClientEvent("pd_bridge:client:removeKeys", src, plate)
end

return func