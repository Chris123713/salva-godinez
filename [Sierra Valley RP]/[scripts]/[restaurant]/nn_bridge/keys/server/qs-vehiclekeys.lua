func = {}

func.add = function(src, plate, hash)
    TriggerClientEvent("pd_bridge:client:addKeys", src, plate, hash)
end

func.remove = function(src, plate, hash)
    TriggerClientEvent("pd_bridge:client:removeKeys", src, plate, hash)
end

return func