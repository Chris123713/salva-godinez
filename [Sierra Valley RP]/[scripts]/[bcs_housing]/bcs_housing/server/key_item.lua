function CheckKeyItem(identifier, home, permission, aptId)
    local source = identifier

    if tonumber(identifier) then
        source = tonumber(identifier)
    else
        local player = GetPlayerFromIdentifier(identifier)
        if player then
            source = player.source
        else
            return false
        end
    end

    return lib.callback.await('Housing:client:CheckKeyItem', source, home.identifier, permission, aptId)
end

RegisterNetEvent('Housing:server:CreateKeyItem', function(homeId, aptId, keyName, permissions)
    local source = source
    local home = Homes[homeId]
    local player = GetPlayerFromId(source)
    if not home or not player then return end

    if GetMoney(player, Config.KeyAsItem.Account) < Config.KeyAsItem.Price then
        return TriggerClientEvent("Housing:notify", source, locale('housing'),
            locale('not_enough_money', Config.KeyAsItem.Account), 'error', 3000)
    end

    RemoveMoney(player, Config.KeyAsItem.Account, Config.KeyAsItem.Price, 'Create Key Item', home)

    if aptId then
        if home.apartments then
            local apartment = nil
            for i = 1, #home.apartments do
                if home.apartments[i].apartment == aptId then
                    apartment = home.apartments[i]
                    break
                end
            end

            if not apartment or apartment.owner ~= player.identifier then return end
            return TriggerClientEvent("Housing:notify", source, locale('housing'),
                locale('not_apartment_owner'), 'error', 3000)
        end
    else
        if home.owner ~= player.identifier then
            return TriggerClientEvent("Housing:notify", source, locale('housing'),
                locale('not_home_owner'), 'error', 3000)
        end
    end

    AddItemInventory(source, Config.KeyAsItem.ItemName, 1, {
        homeId = homeId,
        aptId = aptId,
        name = keyName,
        permissions = permissions,
        label = aptId and ("%s %s (Apt %s)"):format(keyName, home.name, aptId) or ("%s %s"):format(keyName, home.name),
        owner = player.identifier
    })
end)

RegisterNetEvent('Housing:server:DuplicateKeyItem', function(data)
    local source = source
    local player = GetPlayerFromId(source)
    local home = Homes[data.homeId]
    local aptId = data.aptId
    if not home or not player then return end

    if GetMoney(player, Config.KeyAsItem.Account) < Config.KeyAsItem.DuplicatePrice then
        return TriggerClientEvent("Housing:notify", source, locale('housing'),
            locale('not_enough_money', Config.KeyAsItem.Account), 'error', 3000)
    end

    RemoveMoney(player, Config.KeyAsItem.Account, Config.KeyAsItem.DuplicatePrice, 'Duplicate Key Item', home)

    if aptId then
        if home.apartments then
            local apartment = nil
            for i = 1, #home.apartments do
                if home.apartments[i].apartment == aptId then
                    apartment = home.apartments[i]
                    break
                end
            end

            if not apartment or apartment.owner ~= player.identifier then return end
            return TriggerClientEvent("Housing:notify", source, locale('housing'),
                locale('not_apartment_owner'), 'error', 3000)
        end
    else
        if home.owner ~= player.identifier then
            return TriggerClientEvent("Housing:notify", source, locale('housing'),
                locale('not_home_owner'), 'error', 3000)
        end
    end

    AddItemInventory(source, Config.KeyAsItem.ItemName, 1, data)
end)
