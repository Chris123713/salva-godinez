VehicleTypes = Config.Garage.types

local options = {}

for k, v in pairs(VehicleTypes) do
    table.insert(options, { label = v.label, value = k })
end

function GetGarageData()
    local input = lib.inputDialog(locale('garage'), {
        { type = 'input',        label = locale('name'), required = true },
        { type = 'multi-select', label = locale('type'), options = options, required = true },
    })

    if not input then
        return
    end

    return input
end

RegisterNUICallback('getGarageTypes', function(_, cb)
    cb(options)
end)

RegisterNUICallback('getHomeGarages', function(homeId, cb)
    local home = Homes[homeId]

    if home then
        local garages = lib.table.deepclone(home.garages)
        local allowed = false

        for i = 1, #garages do
            for j = 1, #garages[i].type do
                garages[i].type[j] = VehicleTypes[garages[i].type[j]].label
            end
        end

        if home.properties.realestate and isAgent(home.properties.realestate, 'garage') then
            allowed = true
        elseif isAdmin() or home:isKeyOwner('Garage') then
            allowed = true
        end
        cb({
            garages = garages,
            max = home.configuration.garages,
            allowed = allowed
        })
    end
end)


RegisterNUICallback('addGarage', function(data, cb)
    cb(1)
    local home = Homes[data.homeId]
    if home then
        local garage = GetGarageData()
        local garageData = {
            name = garage?[1],
            type = garage?[2]
        }

        if home.permission.moveGarage or isAdmin() then
            if home.garages then
                for i = 1, #home.garages do
                    if home.garages[i].name == garageData.name then
                        Notify(locale('housing'), locale('garage_exists'), 'error', 3000)
                        return
                    end
                end
            end

            ToggleNuiFrame(false)

            local entry = home:GetEntryCoords()
            local coords = GetVehiclePoint(garageData.type ~= nil)
            local dist = Config.MaxDistance.Garage

            if coords then
                repeat
                    Wait(100)
                    dist = #(ToVector3(coords) - ToVector3(entry))
                    if dist < Config.MaxDistance.Garage then
                        TriggerServerEvent('Housing:server:AddGarage', home.identifier, {
                            coords = coords,
                            name = garageData.name,
                            type = garageData.type,
                        })
                    else
                        Notify(locale('housing'), locale('point_too_far'), 'error', 3000)
                        coords = GetVehiclePoint(garageData.type ~= nil)
                    end
                until dist < Config.MaxDistance.Garage
            end
        end
    end
end)

RegisterNUICallback('deleteGarage', function(data, cb)
    cb(1)
    local home = Homes[data.homeId]
    if home then
        if home.permission.moveGarage or isAdmin() then
            ToggleNuiFrame(false)
            TriggerServerEvent('Housing:server:DeleteGarage', data.homeId, data.garage)
        end
    end
end)

RegisterNUICallback('moveGarage', function(data, cb)
    local home = Homes[data.homeId]
    if home then
        local entry = home:GetEntryCoords()
        if home.permission.moveGarage or isAdmin() then
            ToggleNuiFrame(false)
            local coords = GetVehiclePoint(true)
            local dist = Config.MaxDistance.Garage
            if coords then
                repeat
                    Wait(100)
                    dist = #(ToVector3(coords) - ToVector3(entry))
                    if dist < Config.MaxDistance.Garage then
                        data.garage.coords = coords
                        TriggerServerEvent('Housing:server:MoveGarage', data.homeId, data.garage)
                    else
                        Notify(locale('housing'), locale('point_too_far'), 'error', 3000)
                        coords = GetVehiclePoint(true)
                    end
                until dist < Config.MaxDistance.Garage
            end
        else
            Notify(locale('housing'), locale('not_allowed_to_movegarage'), 'error', 3000)
        end
    end
    cb(1)
end)

RegisterNetEvent('Housing:client:MoveGarage', function(homeId, data)
    local home = Homes[homeId]
    if home then
        home:MoveGarage(data)
    end
end)

RegisterNetEvent('Housing:client:DeleteGarage', function(homeId, data)
    local home = Homes[homeId]
    if home then
        home:DeleteGarage(data)
    end
end)

RegisterNetEvent('Housing:client:AddGarage', function(homeId, data)
    local home = Homes[homeId]
    if home then
        home:AddGarage(data)
    end
end)
