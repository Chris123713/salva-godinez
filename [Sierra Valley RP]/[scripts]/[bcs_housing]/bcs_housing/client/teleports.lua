RegisterNUICallback('getHomeTeleports', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        local allowed = false

        if home.properties.realestate and isAgent(home.properties.realestate, 'teleports') then
            allowed = true
        elseif isAdmin() then
            allowed = true
        end

        cb({
            teleports = home.teleports or {},
            allowed = allowed
        })
    end
end)

local function PlaceTeleport(key, home)
    local homecoords
    local object
    local coords

    if key == 'inside' then
        if home.properties.type == 'shell' then
            homecoords = home.properties.data.placement

            lib.requestModel(home.properties.data.interior)
            object = CreateShell(home.properties.data.interior, home.properties.data.placement)
            ---@diagnostic disable-next-line
            entry = GetOffsetFromEntityInWorldCoords(object, Shells[home.properties.data.interior])
            ---@diagnostic disable-next-line
            SetEntityCoordsNoOffset(cache.ped, entry)
            SetEntityHeading(cache.ped, Shells[home.properties.data.interior].w)
            FreezeEntityPosition(cache.ped, true)
            Wait(2500)
        elseif home.properties.type == 'ipl' then
            for i = 1, #CustomizeIPL, 1 do
                local ipl = CustomizeIPL[i]
                if ipl.name == home.properties.data.interior then
                    homecoords = ipl.entry

                    ---@diagnostic disable-next-line
                    SetEntityCoordsNoOffset(cache.ped, ipl.entry)
                    SetEntityHeading(cache.ped, ipl.entry.w)
                    break
                end
            end
        elseif home.properties.type == 'mlo_teleport' then
            for i = 1, #MLOTeleport, 1 do
                local mlo = MLOTeleport[i]
                if mlo.name == home.properties.data.interior then
                    homecoords = mlo.entry

                    ---@diagnostic disable-next-line
                    SetEntityCoordsNoOffset(cache.ped, mlo.entry)
                    SetEntityHeading(cache.ped, mlo.entry.w)
                    break
                end
            end
        elseif home.properties.type == 'mlo' then
            homecoords = home.properties.entry
        end
    elseif key == 'outside' then
        homecoords = home.properties.entry
        ---@diagnostic disable-next-line
        SetEntityCoordsNoOffset(cache.ped, homecoords.x, homecoords.y, homecoords.z)
        SetEntityHeading(cache.ped, homecoords.w)
    end

    local function Place()
        local playerCoords = GetEntityCoords(cache.ped)

        if key == 'inside' then
            coords = {
                x = round(playerCoords.x - homecoords.x, 4),
                y = round(playerCoords.y - homecoords.y, 4),
                z = round(playerCoords.z - homecoords.z, 4),
                w = round(GetEntityHeading(cache.ped), 4)
            }


            local entry = home.properties.entry
            ---@diagnostic disable-next-line
            SetEntityCoordsNoOffset(cache.ped, entry.x, entry.y, entry.z)
            SetEntityHeading(cache.ped, entry.w)
            Wait(500)
            if home.properties.type == 'shell' then
                DeleteObject(object)
            end
        elseif key == 'outside' then
            homecoords = home.properties.entry
            coords = {
                x = round(playerCoords.x, 4),
                y = round(playerCoords.y, 4),
                z = round(playerCoords.z, 4),
                w = round(GetEntityHeading(cache.ped), 4)
            }
        end

        return coords
    end

    FreezeEntityPosition(cache.ped, false)

    HelpText(true, "Press ~E~ to place the teleport")

    while true do
        Wait(0)
        if IsControlJustReleased(0, 38) then
            HelpText(false)
            return Place()
        end
    end
end

RegisterNUICallback('addTeleport', function(homeId, cb)
    cb(1)
    if LocalPlayer.state.isInsideHome then
        Notify(locale('housing'), locale('action_cannot_inside'), 'error', 3000)
        return
    end
    local home = Homes[homeId]
    if home then
        if home.properties.realestate and isAgent(home.properties.realestate, 'teleports') or isAdmin() then
            ToggleNuiFrame(false)

            local teleport = {
                inside = {},
                outside = {}
            }

            for k in pairs(teleport) do
                teleport[k] = PlaceTeleport(k, home)
            end

            local input = lib.inputDialog("Teleports", {
                { type = 'input', label = locale('name'), required = true },
            })

            for k, v in pairs(home.teleports) do
                if v.name == input[1] then
                    Notify(locale('housing'), locale('name_taken'), 'error', 3000)
                    return
                end
            end

            Wait(1000)
            Notify(locale('housing'), locale('teleport_created'), 'success', 3000)

            TriggerServerEvent('Housing:server:AddTeleport', homeId, input[1], teleport.inside, teleport.outside)
        end
    end
end)

RegisterNUICallback('deleteTeleport', function(data, cb)
    cb(1)
    local home = Homes[data.homeId]
    if home then
        if home.properties.realestate and isAgent(home.properties.realestate, 'teleports') or isAdmin() then
            ToggleNuiFrame(false)
            TriggerServerEvent('Housing:server:DeleteTeleport', data.homeId, data.name)

            Notify(locale('housing'), locale('teleport_removed'), 'success', 3000)
        end
    end
end)

RegisterNUICallback('moveTeleport', function(data, cb)
    cb(1)
    if LocalPlayer.state.isInsideHome then
        Notify(locale('housing'), locale('action_cannot_inside'), 'error', 3000)
        return
    end
    local home = Homes[data.homeId]
    if home then
        if home.properties.realestate and isAgent(home.properties.realestate, 'teleports') or isAdmin() then
            ToggleNuiFrame(false)

            local teleports = home.teleports

            for i = 1, #teleports, 1 do
                if teleports[i].name == data.name then
                    local teleport = teleports[i]

                    teleport.outside = PlaceTeleport('outside', home)
                    teleport.inside = PlaceTeleport('inside', home)

                    local homecoords = home.properties.entry
                    ---@diagnostic disable-next-line
                    SetEntityCoordsNoOffset(cache.ped, homecoords.x, homecoords.y, homecoords.z)
                    SetEntityHeading(cache.ped, homecoords.w)

                    Wait(1000)
                    Notify(locale('housing'), locale('teleport_edited'), 'success', 3000)

                    TriggerServerEvent('Housing:server:MoveTeleport', data.homeId, data.name, teleport.inside,
                        teleport.outside)
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('Housing:client:AddTeleport', function(homeId, data)
    local home = Homes[homeId]
    if home then
        home:AddTeleport(data)
    end
end)

RegisterNetEvent('Housing:client:DeleteTeleport', function(homeId, name)
    local home = Homes[homeId]
    if home then
        home:DeleteTeleport(name)
    end
end)

RegisterNetEvent('Housing:client:MoveTeleport', function(homeId, data)
    local home = Homes[homeId]
    if home then
        home:MoveTeleport(data)
    end
end)

RegisterNetEvent('Housing:client:ToggleLockTeleport', function(homeId, name, lock)
    local home = Homes[homeId]
    if home then
        home:ToggleLockTeleport(name, lock)
    end
end)

function SetTeleport(home, teleport)
    local function CanInteract()
        return home:isOwner() or (home.properties.realestate and isAgent(home.properties.realestate, 'teleports')) or
            isAdmin()
    end

    if teleport.zoneInside then
        teleport.zoneInside:remove()
        teleport.zoneInside = nil
    end
    if teleport.zoneOutside then
        teleport.zoneOutside:remove()
        teleport.zoneOutside = nil
    end

    local insideCoords = teleport.inside

    if home.properties.type == 'shell' then
        local x = insideCoords.x + home.properties.data.placement.x
        local y = insideCoords.y + home.properties.data.placement.y
        local z = insideCoords.z + home.properties.data.placement.z
        insideCoords = vec4(x, y, z, insideCoords.w)
    elseif home.properties.type == 'ipl' then
        for i = 1, #CustomizeIPL, 1 do
            local ipl = CustomizeIPL[i]
            if ipl.name == home.properties.data.interior then
                local x = insideCoords.x + ipl.entry.x
                local y = insideCoords.y + ipl.entry.y
                local z = insideCoords.z + ipl.entry.z
                insideCoords = vec4(x, y, z, insideCoords.w)
                break
            end
        end
    elseif home.properties.type == 'mlo_teleport' then
        for i = 1, #MLOTeleport, 1 do
            local mlo = MLOTeleport[i]
            if mlo.name == home.properties.data.interior then
                local x = insideCoords.x + mlo.entry.x
                local y = insideCoords.y + mlo.entry.y
                local z = insideCoords.z + mlo.entry.z
                insideCoords = vec4(x, y, z, insideCoords.w)
                break
            end
        end
    end

    if LocalPlayer.state.isInsideHome then
        if Config.target then
            RemoveTargetZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-inside')
            AddTargetBoxZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-inside', {
                coords = insideCoords,
                length = 2.0,
                width = 2.0,
                heading = insideCoords.w,
                debug = true,
                minZ = insideCoords.z - 1.0,
                maxZ = insideCoords.z + 2.0,

            }, {
                options = {
                    {
                        icon = "fas fa-door-open",
                        label = locale('exit_house'),
                        event = "Housing:client:ExitHome",
                        action = function()
                            TriggerEvent('Housing:client:ExitHome', home.identifier, ToVector4(teleport.outside))
                        end,
                        canInteract = function()
                            return not teleport.locked
                        end
                    },
                    {
                        icon = teleport.locked and 'fas fa-lock' or 'fas fa-lock-open',
                        label = teleport.locked and locale('unlock_home') or locale('lock_home'),
                        action = function()
                            TriggerServerEvent('Housing:server:ToggleLockTeleport', home.identifier, teleport.name)
                        end,
                        canInteract = CanInteract
                    }
                },
                distance = 2.0
            })
        else
            teleport.zoneInside = lib.zones.box({
                name = 'home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-inside',
                coords = insideCoords,
                size = vec3(1.0, 1.0, 1.0),
                debug = Config.debug,
                onEnter = function()
                    if teleport.locked and CanInteract() then
                        HelpText(true, locale('prompt_unlock_door'))
                    else
                        HelpText(true, locale('inside') .. ' ' .. teleport.name)
                    end
                end,
                onExit = function()
                    HelpText(false)
                end,
                inside = function()
                    if IsControlJustPressed(0, 38) then
                        if teleport.locked and CanInteract() then
                            TriggerServerEvent('Housing:server:ToggleLockTeleport', home.identifier, teleport.name)
                        else
                            local boxes = {}

                            if CanInteract() then
                                table.insert(boxes, {
                                    text = {
                                        title = locale('lock_home'),
                                        body = locale('lock_home_body'),
                                    },
                                    icon = 'lock',
                                    server = true,
                                    event = "Housing:server:ToggleLockTeleport",
                                    args = { home.identifier, teleport.name }
                                })
                            end
                            if not teleport.locked then
                                table.insert(boxes, {
                                    text = { title = locale('exit_house') },
                                    icon = "door-open",
                                    event = "Housing:client:ExitHome",
                                    args = { home.identifier, ToVector4(teleport.outside) }
                                })
                            end

                            TriggerEvent("Housing:client:CreateMenu", {
                                title = home.properties.name,
                                subtitle = locale('house_entrance_menu'),
                                boxes = boxes,
                            })
                        end
                    end
                end
            })
        end
    else
        if Config.target then
            RemoveTargetZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-outside')
            AddTargetBoxZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-outside', {
                    coords = ToVector3(teleport.outside),
                    length = 2.0,
                    width = 2.0,
                    heading = teleport.outside.w,
                    debug = Config.debug,
                    minZ = teleport.outside.z - 1.0,
                    maxZ = teleport.outside.z + 2.0,

                },
                {
                    options = {
                        {
                            icon = 'fas fa-door-open',
                            label = locale('enter_home'),
                            action = function()
                                TriggerEvent("Housing:client:EnterHome", home.identifier, false, nil,
                                    ToVector4(insideCoords))
                            end,
                            canInteract = function()
                                return not teleport.locked
                            end
                        },
                        {
                            icon = teleport.locked and 'fas fa-lock' or 'fas fa-lock-open',
                            label = teleport.locked and locale('unlock_home') or locale('lock_home'),
                            action = function()
                                TriggerServerEvent('Housing:server:ToggleLockTeleport', home.identifier, teleport.name)
                            end,
                            canInteract = CanInteract
                        }
                    },
                    distance = 2.0
                }
            )
        else
            teleport.zoneOutside = lib.zones.box({
                name = 'home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-outside',
                coords = ToVector3(teleport.outside),
                size = vec3(1.0, 1.0, 1.0),
                debug = Config.debug,

                onEnter = function()
                    if teleport.locked and CanInteract() then
                        HelpText(true, locale('prompt_unlock_door'))
                    else
                        HelpText(true, locale('outside') .. ' ' .. teleport.name)
                    end
                end,
                onExit = function()
                    HelpText(false)
                end,
                inside = function()
                    if IsControlJustPressed(0, 38) then
                        if teleport.locked and CanInteract() then
                            TriggerServerEvent('Housing:server:ToggleLockTeleport', home.identifier, teleport.name)
                        else
                            local boxes = {}

                            if CanInteract() then
                                table.insert(boxes, {
                                    text = {
                                        title = locale('lock_home'),
                                        body = locale('lock_home_body'),
                                    },
                                    icon = 'lock',
                                    server = true,
                                    event = "Housing:server:ToggleLockTeleport",
                                    args = { home.identifier, teleport.name }
                                })
                            end

                            if not teleport.locked then
                                table.insert(boxes, {
                                    text = {
                                        title = locale('enter_home')
                                    },
                                    icon = 'door-open',
                                    event = "Housing:client:EnterHome",
                                    args = { home.identifier, false, nil, ToVector4(insideCoords) }
                                })
                            end

                            TriggerEvent("Housing:client:CreateMenu", {
                                title = home.properties.name,
                                subtitle = teleport.name,
                                boxes = boxes,
                            })
                        end
                    end
                end
            })
        end
    end
end

function DeleteTeleport(home, teleport)
    if Config.target then
        RemoveTargetZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-inside')
        RemoveTargetZone('home-teleport-' .. home.identifier .. '-' .. teleport.name .. '-outside')
    else
        if teleport.zoneInside then
            teleport.zoneInside:remove()
            teleport.zoneInside = nil
        end
        if teleport.zoneOutside then
            teleport.zoneOutside:remove()
            teleport.zoneOutside = nil
        end
    end

    for i = 1, #home.teleports, 1 do
        if home.teleports[i].name == teleport.name then
            table.remove(home.teleports, i)
            break
        end
    end
end
