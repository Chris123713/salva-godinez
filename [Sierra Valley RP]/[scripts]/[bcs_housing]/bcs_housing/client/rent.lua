RegisterNUICallback('saveRentOptions', function(data, cb)
    local home = Homes[data.identifier]
    if home then
        TriggerServerEvent('Housing:server:UpdateRentOptions', data.identifier, data)
    end
    cb({})
end)

RegisterNUICallback('rentOwnedHouse', function(data, cb)
    local home = Homes[data.identifier]
    if home then
        TriggerServerEvent('Housing:server:SetRented', data.identifier, data.checked)
    end
    cb({})
end)

RegisterNUICallback('payOwnedHouseRent', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        cb(lib.callback.await('Housing:server:TenantPayRent', false, homeId))
    else
        cb(false)
    end
end)

RegisterNUICallback('evictTenant', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        local result = lib.callback.await("Housing:server:EvictTenant", false, homeId)
        cb(result)
    end
end)

RegisterNetEvent('Housing:client:RentMenu', function(homeId)
    local home = Homes[homeId]
    if home then
        local permissions = ''
        for k, v in pairs(home.properties.rent.permission) do
            permissions = permissions .. '- ' .. k .. ': ' .. (v and locale('yes') or locale('no')) .. '  \n '
        end
        local result = lib.alertDialog({
            header = locale('rent_home'),
            content = locale('tenant_rent_desc', home.properties.rent.price, home.properties.rent.duration,
                home.properties.rent.durationType, permissions),
            cancel = true
        })
        if result == 'confirm' then
            TriggerServerEvent('Housing:server:RentHouse', homeId)
        end
    end
end)
