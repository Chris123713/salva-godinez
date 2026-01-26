exports('GetOwnedHomes', function()
    local ownedHomes = {}
    for k, data in pairs(Homes) do
        if data.properties.owner == (GetIdentifier()) and data.properties.complex == 'Individual' then
            table.insert(ownedHomes, data)
        elseif data.properties.complex == 'Apartment' and Apartments[data.identifier]:OwnApartment() then
            table.insert(ownedHomes, data)
        elseif Homes[data.identifier]:isTenant() then
            table.insert(ownedHomes, data)
        end
    end
    for _, apt in pairs(Flats) do
        for _, data in pairs(apt.rooms) do
            if data.properties.owner == (GetIdentifier()) then
                local room = table.clone(data)
                room.entry = room.flat.coords
                table.insert(ownedHomes, room)
            end
        end
    end
    return ownedHomes
end)

exports('GetRealestateHomes', function(job)
    local list = {}
    for k, data in pairs(Homes) do
        if data.properties.realestate and data.properties.realestate == job and data.properties.complex == 'Individual' then
            table.insert(list, data)
        end
    end
    for _, apt in pairs(Flats) do
        for _, data in pairs(apt.rooms) do
            if data.properties.realestate and data.properties.realestate == job then
                local room = table.clone(data)
                room.entry = room.flat.coords
                table.insert(list, room)
            end
        end
    end
    return list
end)

exports("GetOwnedApartments", function()
    return lib.callback('apartments:GetOwnedApartment', false)
end)

exports('GetStarterApartments', function()
    return StarterApartment
end)

exports('GetOwnedHomeKeys', function()
    local ownedHomes = {}
    for k, data in pairs(Homes) do
        if data.keys and data.keys:HasKey(GetIdentifier()) and data.properties.complex == 'Individual' then
            table.insert(ownedHomes, data)
        elseif data.properties.complex == 'Apartment' then
            local apts = Apartments[data.identifier].apartments
            for i = 1, #apts do
                if apts[i].keys:HasKey(GetIdentifier(), nil, apts[i].apartment) then
                    data.owner = apts[i].owner
                    data.apartment = apts[i].apartment
                    table.insert(ownedHomes, data)
                    break
                end
            end
        elseif Homes[data.identifier]:isTenant() then
            table.insert(ownedHomes, data)
        end
    end
    for _, apt in pairs(Flats) do
        for _, data in pairs(apt.rooms) do
            if data.keys and data.keys:HasKey(GetIdentifier()) then
                local room = table.clone(data)
                room.entry = room.flat.coords
                table.insert(ownedHomes, room)
            end
        end
    end
    return ownedHomes
end)

exports('GetOwnedRentedHomes', function()
    local ownedHomes = {}
    for k, data in pairs(Homes) do
        if data.properties.owner == (GetIdentifier()) and data.properties.complex == 'Individual' then
            if data.properties.rent and data.properties.rent.isRented then
                table.insert(ownedHomes, data)
            end
        end
    end
    for _, apt in pairs(Flats) do
        for _, data in pairs(apt.rooms) do
            if data.properties.owner == (GetIdentifier()) then
                if data.properties.rent and data.properties.rent.isRented then
                    local room = table.clone(data)
                    room.entry = room.flat.coords
                    table.insert(ownedHomes, room)
                end
            end
        end
    end
    return ownedHomes
end)

exports('GetHomes', function()
    local list = {}
    for k, data in pairs(Homes) do
        if data.properties.complex ~= 'Flat' then
            table.insert(list, data)
        end
    end
    for _, apt in pairs(Flats) do
        for _, data in pairs(apt.rooms) do
            local room = table.clone(data)
            room.entry = room.flat.coords
            table.insert(list, room)
        end
    end
    return list
end)

exports('GetHome', function(homeId, aptId)
    if aptId then
        local apt = Apartments[homeId]:GetApartmentById(aptId)
        if apt then
            return apt
        else
            return false
        end
    else
        return Homes[homeId] or false
    end
end)

exports('LockHome', function(homeId, aptId)
    local home = Homes[homeId]
    if home and home.keys:HasKey(GetIdentifier(), nil, aptId) then
        TriggerServerEvent('Housing:server:LockHome', homeId)
    end
end)

exports('isLocked', function(homeId, aptId)
    local id = homeId or CurrentHome.identifier
    local home = Homes[homeId]
    if home then
        if home.properties.complex == 'Apartment' then
            return Apartments[id]:isLocked(aptId)
        else
            return home.properties.locked
        end
    else
        return false
    end
end)

exports('GetKeyList', function(homeId, aptId)
    local home = Homes[homeId]
    local list = {}
    if aptId then
        local apt = Apartments[homeId]:GetApartmentById(aptId)
        if apt then
            list = apt.keys.list or {}
        end
    else
        list = home and home.keys.list or {}
    end
    return list
end)

exports('GetKeyHolders', function(homeId, aptId)
    local home = Homes[homeId]
    if home then
        local holders = {}
        if aptId then
            local apt = Apartments[homeId]:GetApartmentById(aptId)
            if apt then
                home = apt
            end
        end
        for k, v in pairs(home.keys.holders) do
            holders[#holders + 1] = { identifier = k, name = v.name, key = v.key }
        end
        return holders
    else
        return {}
    end
end)

exports('GetStarterApartment', function()
    return StarterApartment
end)

exports('AddKeyHolder', function(homeId, target, keyName, aptId)
    local home = Homes[homeId]
    if home then
        if #exports[GetCurrentResourceName()]:GetKeyHolders(homeId) < home.configuration.keys then
            local result = lib.callback.await("Housing:server:GiveHomeKeyHolder", false, homeId, target, keyName, aptId)
            if result.success then
                if aptId then
                    local apt = Apartments[homeId]:GetApartmentById(aptId)
                    if apt then
                        home = apt
                    end
                end
                home.keys:UpdateHolder(result.identifier, result.name, keyName)
                Notify(locale('housing'), locale('key_given_successfully', keyName, result.name), 'success', 5000)
            else
                Notify(locale('housing'), locale('key_give_error'), 'error', 3000)
            end
            return result.success
        else
            Notify(locale('housing'), locale('max_keys_exceeded'), 'error', 3000)
            return false
        end
    else
        return false
    end
end)

exports('RemoveKeyHolder', function(homeId, identifier, aptId)
    local home = Homes[homeId]
    if home then
        local result = lib.callback.await("Housing:server:RemoveKeyHolder", false, homeId, identifier, aptId)
        if result then
            if aptId then
                local apt = Apartments[homeId]:GetApartmentById(aptId)
                if apt then
                    home = apt
                end
            end
            home.keys:DeleteHolder(identifier)
            Notify(locale('housing'), locale('key_removed_successfully'), 'success', 3000)
        else
            Notify(locale('housing'), locale('key_removal_error'), 'error', 3000)
        end
        return result
    else
        return false
    end
end)

exports('HasKey', function(homeId, permission, aptId)
    local home = Homes[homeId]
    return home.keys:HasKey(GetIdentifier(), permission, aptId)
end)

exports('SetWaypoint', function(homeId)
    local home = Homes[homeId]
    ClearGpsPlayerWaypoint()
    local entry = home:GetEntryCoords()
    SetNewWaypoint(entry.x, entry.y)
end)

exports('GetPlayersInside', function(homeId)
    local home = Homes[homeId]
    if home then
        return home:GetPlayersInside()
    end
end)

exports('GetLastProperty', function()
    return lib.callback.await('Housing:server:GetLastProperty', false)
end)
