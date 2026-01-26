RegisterNUICallback('getHomeStorages', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        local storages = home:GetStorages() or {}
        local allowed = false
        if home.properties.realestate and isAgent(home.properties.realestate, 'storage') then
            allowed = true
        elseif isAdmin() then
            allowed = true
        end
        cb({
            storages = storages,
            max = home.configuration.storage,
            allowed = allowed
        })
    end
end)

RegisterNUICallback('moveStorage', function(data, cb)
    cb(1)
    local home = Homes[data.homeId]
    if home and CurrentHome and next(CurrentHome) then
        ToggleNuiFrame(false)
        local done = false
        repeat
            local hit, _, endCoords = lib.raycast.cam()
            if hit then
                DrawMarker(1, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 100,
                    100,
                    255, false, true, 2, false,
                    false, false, false)
            end
            if IsControlJustReleased(0, 38) then
                local homecoords = GetCenterPoint(home)
                local coords = {
                    x = round(endCoords.x - homecoords.x, 4),
                    y = round(endCoords.y - homecoords.y, 4),
                    z = round(endCoords.z - homecoords.z, 4),
                }
                local area = LocalPlayer.state.isInsideArea and not LocalPlayer.state.isInsideHome
                home:MoveStorage(data.storageId, coords, area)
                done = true
                break
            end
        until done
    else
        Notify(locale('housing'), locale('not_inside_home'), 'error', 3000)
    end
end)

RegisterNUICallback('deleteStorage', function(data, cb)
    local home = Homes[tostring(data.homeId)]
    if home then
        local result = lib.callback.await('Housing:server:DeleteStorage', false, data.homeId, data.storageId)
        cb(result)
    end
end)

RegisterNUICallback('addStorage', function(data, cb)
    cb(1)
    local home = Homes[data.identifier]
    if home then
        if not isAdmin() and not (home.properties.realestate and isAgent(home.properties.realestate, 'storage')) then return end
        local storages = LocalPlayer.state.CurrentApartment and #Apartments[data.identifier]:GetStorages() or
            #home.properties.storages
        if home and storages < home.configuration.storage then
            ToggleNuiFrame(false)
            home:AddStorage(nil, data.weight, data.slots, area)
        else
            Notify(locale('housing'), locale('storage_max_exceeded'), 'error', 3000)
        end
    end
end)

RegisterNUICallback('addSetStorage', function(data, cb)
    cb(1)
    local home = Homes[data.identifier]
    if LocalPlayer.state.isInsideHome or LocalPlayer.state.isInsideArea then
        local storages = LocalPlayer.state.CurrentApartment and #Apartments[data.identifier]:GetStorages() or
            #home.properties.storages
        if not isAdmin() and not (home.properties.realestate and isAgent(home.properties.realestate, 'storage')) then return end
        if home and storages < home.configuration.storage then
            ToggleNuiFrame(false)
            HelpText(true, locale('prompt_add_storage'))
            local done = false
            repeat
                local hit, _, endCoords = lib.raycast.cam()
                if hit then
                    DrawMarker(1, endCoords.x, endCoords.y, endCoords.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255,
                        100,
                        100,
                        255, false, true, 2, false,
                        false, false, false)
                end
                if IsControlJustReleased(0, 38) and hit then
                    local homecoords = GetCenterPoint(home)
                    local coords = {
                        x = round(endCoords.x - homecoords.x, 4),
                        y = round(endCoords.y - homecoords.y, 4),
                        z = round(endCoords.z - homecoords.z, 4),
                    }
                    local area = LocalPlayer.state.isInsideArea and not LocalPlayer.state.isInsideHome
                    home:AddStorage(nil, data.weight, data.slots, area, coords)
                    HelpText(false)
                    done = true
                    break
                end

                if IsControlJustReleased(0, 73) then
                    HelpText(false)
                    done = true
                    break
                end
            until done
        else
            Notify(locale('housing'), locale('storage_max_exceeded'), 'error', 3000)
        end
    else
        Notify(locale('housing'), locale('not_inside_home'), 'error', 3000)
    end
end)

RegisterNUICallback('saveStorages', function(data, cb)
    local home = Homes[data.identifier]
    if home then
        ToggleNuiFrame(false)
        TriggerServerEvent('Housing:server:SaveStorages', data)
    end
    cb(1)
end)

RegisterNetEvent('Housing:client:RefreshStorage', function(homeId, data, aptId, update)
    local home = Homes[homeId]
    if home then
        local found = false
        if aptId then
            local apt = Apartments[homeId]
            if update then
                apt:MoveStorage(data.id, data.coords, data.area)
            else
                apt:CreateStorage(data, aptId)
            end
        else
            if home.properties.storages then
                for i = 1, #home.properties.storages do
                    if home.properties.storages[i].id == data.id then
                        found = true
                        home.properties.storages[i] = data
                        break
                    end
                end
                if not found then
                    home.properties.storages[#home.properties.storages + 1] = data
                end
            end
        end
        if home.properties.complex == 'mlo' or (CurrentHome and CurrentHome.identifier == homeId and (not aptId or aptId == LocalPlayer.state.CurrentApartment)) then
            home:SetStoragesZone(aptId)
        end
    end
end)

RegisterNetEvent('Housing:client:DeleteStorage', function(homeId, storageId, aptId)
    local home = Homes[homeId]
    home:DeleteStorage(storageId, aptId)
end)

RegisterNetEvent('Housing:client:SaveStorages', function(homeId, storages)
    local home = Homes[homeId]
    if home then
        home:SaveStorages(storages)
    end
end)

AddEventHandler('Housing:Storage', function(data)
    if data then
        local home = Homes[data.home]
        local hasKey = home.keys:HasKey(GetIdentifier(), 'Storage', data.aptId) or home:isTenant('storage')

        if not Config.robbery.storageRobbery and not hasKey and (not isRaiding and not isPolice()) then
            Notify(locale('housing'), locale('no_owned_house'), 'error', 3000)
            return
        end

        if hasKey or (isRaiding and isPolice()) or not Config.robbery.storageLockpick then
            OpenStorage(data, home)
        elseif Config.robbery.storageLockpick then
            if IsResourceStarted('qb-lockpick') then
                TriggerEvent('qb-lockpick:client:openLockpick', function(result)
                    if result then
                        TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                        OpenStorage(data, home)
                    else
                        Notify(locale('housing'), locale('failed_lockpick'), 'error', 3000)
                        TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                    end
                end)
            elseif IsResourceStarted('ps-ui') then
                exports['ps-ui']:Circle(function(success)
                    if success then
                        TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                        OpenStorage(data, home)
                    else
                        Notify(locale('housing'), locale('failed_lockpick'), 'error', 3000)
                        TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                    end
                end, 2, 20)
            else
                local result = exports['lockpick']:startLockpick()
                if result then
                    TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                    OpenStorage(data, home)
                else
                    Notify(locale('housing'), locale('failed_lockpick'), 'error', 3000)
                    TriggerServerEvent('Housing:removeItem', Config.robbery.lockpickItem)
                end
            end
        end
    end
end)
