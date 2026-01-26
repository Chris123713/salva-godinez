RegisterNetEvent('Housing:server:AddWardrobe', function(id, wardrobe)
    local src = source
    local homeId, aptId = GetHomeAptId(id)
    local home = Homes[homeId]
    if home then
        home:AddWardrobe(wardrobe, aptId)
        TriggerClientEvent('Housing:notify', src, locale('housing'), locale('saved_wardrobe'), 'success', 3000)
        TriggerClientEvent('Housing:client:AddWardrobe', -1, id, wardrobe)
    end
end)

RegisterNetEvent('Housing:server:DeleteWardrobe', function(id, name)
    local homeId, aptId = GetHomeAptId(id)
    local home = Homes[homeId]
    if home then
        home:DeleteWardrobe(name, aptId)
        TriggerClientEvent('Housing:client:DeleteWardrobe', -1, id, name)
    end
end)

lib.callback.register('Housing:server:GetWardrobe', function(source, identifier)
    return GetWardrobe(source, identifier)
end)

lib.callback.register('Housing:server:GetOutfit', function(source, identifier, label)
    return GetOutfit(source, identifier, label)
end)

RegisterNetEvent('Housing:server:SaveOutfit', function(identifier, label, skin)
    local source = source
    SaveOutfit(source, identifier, label, skin)
end)

RegisterNetEvent('Housing:server:DeleteOutfit', function(identifier, label)
    local source = source
    DeleteOutfit(source, identifier, label)
end)
