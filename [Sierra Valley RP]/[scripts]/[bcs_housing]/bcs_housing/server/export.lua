exports('GetOwnedHomes', function(plyId, complex)
    local ownedHomes = {}
    for k, data in pairs(Homes) do
        if not complex or complex == data.complex then
            if data.complex == 'Apartment' then
                for i = 1, #data.apartments do
                    if data.apartments[i].owner == plyId then
                        local house = table.clone(data.apartments[i])
                        for k, v in pairs(data) do if k ~= 'apartments' then house[k] = v end end
                        table.insert(ownedHomes, house)
                        break
                    end
                end
            elseif data.owner == plyId then
                table.insert(ownedHomes, data)
            end
        end
    end
    return ownedHomes
end)

exports('GetOwnedHomeKeys', function(plyId, complex)
    local ownedHomes = {}
    for k, data in pairs(Homes) do
        if data.keys and data.keys:HasKey(plyId) and (not complex or complex == data.complex) then
            if data.complex == 'Apartment' then
                for i = 1, #data.apartments do
                    local house = table.clone(data.apartments[i])
                    for k, v in pairs(data) do if k ~= 'apartments' then house[k] = v end end
                    table.insert(ownedHomes, house)
                    break
                end
            else
                table.insert(ownedHomes, data)
            end
        end
    end
    return ownedHomes
end)

exports('GetHomesForSale', function()
    local HomesForSale = {}
    for k, data in pairs(Homes) do
        if not data.owner then
            table.insert(HomesForSale, data)
        end
    end
    return HomesForSale
end)

exports('GetHomes', function()
    local list = {}
    for k, data in pairs(Homes) do
        table.insert(list, data)
    end
    return list
end)

exports('GetHome', function(homeId)
    return Homes[homeId] or false
end)

---Give a House to a target
---@param homeId string
---@param target number player server id
---@param src number player server id
exports('GiveHouse', function(homeId, target, src)
    GiveHouse(homeId, target, src)
end)

exports("LockHome", function(homeId)
    if Homes[homeId] then
        Homes[homeId]:LockHome()
    end
end)

exports('isLocked', function(homeId)
    local home = Homes[homeId]
    if home then
        if home.complex == 'Apartment' then
            for i = 1, #home.apartments do
                if home.apartments[i].apartment == aptId then
                    return home.apartments[i].locked
                end
            end
        else
            return home.locked
        end
    else
        return false
    end
end)

exports('AddKeyHolder', function(homeId, target, keyName)
    local home = Homes[homeId]
    local xTarget = GetPlayerFromId(target)
    if xTarget and home then
        if #exports[GetCurrentResourceName()]:GetKeyHolders(homeId) < home.configuration.keys then
            local result = home.keys:UpdateHolder(xTarget.identifier, GetName(xTarget), keyName)
            return {
                identifier = xTarget.identifier,
                name = GetName(xTarget),
                success = result and true or false
            }
        else
            Notify(locale('housing'), locale('max_keys_exceeded'), 'error', 3000)
            return {
                success = false
            }
        end
    end
end)

exports('RemoveKeyHolder', function(homeId, targetIdentifier)
    local home = Homes[homeId]
    if home then
        local result = home.keys:DeleteHolder(targetIdentifier)
        return result and true or false
    end
end)

exports('RevokeOwnership', function(homeId, owner)
    if Homes[homeId] then
        Homes[homeId]:RevokeOwner(owner)
        TriggerClientEvent("Housing:client:UpdateOwner", -1, homeId)
    end
end)

exports('RevokePropertyByIdentifier', function(identifier)
    for k, v in pairs(Homes) do
        if v.owner and v.owner == identifier then
            v:RevokeOwner(identifier)
        end
    end
end)

exports('HasKey', function(homeId, plyId, permission)
    return Homes[homeId].keys:HasKey(plyId, permission)
end)

exports('GetKeyList', function(homeId)
    if Homes[homeId] then
        return Homes[homeId].keys.list
    end
end)

exports('GetKeyHolders', function(homeId)
    if Homes[homeId] then
        return Homes[homeId].keys.holders
    end
end)

exports('GetHouseKeys', function(plyId)
    local ownerKeys = {}
    for k, data in pairs(Homes) do
        if data.keys and data.keys:HasKey(plyId) and data.owner ~= plyId then
            table.insert(ownerKeys, data)
        end
    end
    return ownedKeys
end)

exports('GetPlayersInside', function(homeId)
    if Homes[homeId] then
        return Homes[homeId]:GetPlayersInside()
    end
end)

exports('isPlayerInside', function(homeId, plyId)
    if Homes[homeId] then
        return Homes[homeId]:isPlayerInside(plyId)
    end
end)

exports('GetLastProperty', function(source)
    local xPlayer

    if tonumber(source) then
        xPlayer = GetPlayerFromId(tonumber(source))
    else
        xPlayer = GetPlayerFromIdentifier(source)
    end

    if xPlayer then
        return GetLastProperty(xPlayer)
    end

    return nil
end)

exports('GetHomeConfiguration', function(homeId)
    if Homes[homeId] then
        return Homes[homeId].configuration
    end
end)

exports('UpdateHomeConfiguration', function(source, homeId, configuration)
    return SaveHomeConfiguration(source, homeId, configuration)
end)

exports('SetHouseDisabled', function(homeId, disabled)
    if Homes[homeId] then
        Homes[homeId]:SetDisabled(disabled)
    end
end)

exports('UpdateFurniture', function(homeId, aptId, furnitures)
    if Homes[homeId] then
        Homes[homeId]:UpdateFurniture(furnitures, aptId)
        local players = Homes[homeId]:GetPlayersInside()
        if players then
            for i = 1, #players, 1 do
                TriggerClientEvent('Housing:client:UpdateFurniture', players[i], homeId, furnitures, aptId)
            end
        end
    end
end)
