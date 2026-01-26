local doors, nearbyDoors = {}, {}
local tempDoor = {}
local tempList = {}
local shown = false
-- CREDITS TO OX_DOORLOCK (https://github.com/overextended/ox_doorlock) FOR CODE LOGIC

function CreateInitialDoors()
    local input = lib.inputDialog(locale('create_a_door'), {
        { type = 'input',    label = locale('name'),       required = true },
        { type = 'number',   label = locale('distance'),   required = true, min = 1, default = 1 },
        { type = 'number',   label = locale('permission'), required = true, min = 1, max = 3,    default = 1 },
        { type = 'checkbox', label = locale('double') },
        { type = 'checkbox', label = locale('locked') },
    })
    if not input then
        return {}
    end
    local data = {
        name = input[1],
        distance = input[2],
        permission = input[3],
        double = input[4],
        locked = input[5]
    }
    local door = CreateDoor(data)
    if door then
        local found = false
        for i = 1, #tempList do
            if #(ToVector3(tempList[i].coords) - ToVector3(door.coords)) < 1.0 and data.model == tempList[i].model then
                found = true
                break
            end
        end
        if not found then
            tempList[#tempList + 1] = door
        else
            Notify(locale('housing'), locale('door_exist'), 'error', 5000)
        end
    end
    local alert = lib.alertDialog({
        header = locale('create_more_doors'),
        cancel = true,
        centered = true,
        labels = {
            cancel = locale('keybind_finish'),
            confirm = locale('continue')
        }
    })
    if alert == 'confirm' then
        return CreateInitialDoors()
    else
        local list = table.clone(tempList)
        table.wipe(tempList)
        return list
    end
end

-- distance: data.distance,
-- permission: data.level,
-- name: data.name,
-- locked: data.locked,
-- double: data.double,
function CreateDoor(data)
    local checkList = CurrentHome and CurrentHome.doors or tempList
    for i = 1, #checkList do
        if checkList[i].name == data.name then
            Notify(locale('housing'), locale('error_duplicate_door_name'), 'error', 3000)
            return false
        end
    end

    data.identifier = nil

    local doorCount = data.double and 2 or 1
    local highlightedEntity = nil

    HelpText(true, locale('prompt_add_door'))

    repeat
        DisablePlayerFiring(cache.playerId, true)
        DisableControlAction(0, 25, true)

        local hit, entity, coords = lib.raycast.cam(1|16)
        local firstDoor = tempDoor[1]?.entity
        DrawLine(GetEntityCoords(cache.ped), coords, 0, 255, 34, 255)

        if entity ~= highlightedEntity then
            SetEntityDrawOutline(highlightedEntity, false)
            if hit and entity > 0 and GetEntityType(entity) == 3 then
                SetEntityDrawOutline(entity, true)
            end
        end

        if IsDisabledControlJustPressed(0, 24) then
            if hit and entity > 0 and GetEntityType(entity) == 3 then
                AddTempDoorlock(entity)
                HelpText(false)
            end
        end

        highlightedEntity = entity

        if IsDisabledControlJustPressed(0, 25) then
            SetEntityDrawOutline(entity, false)

            SetEntityDrawOutline(firstDoor, false)
            table.wipe(tempDoor)
            HelpText(false)
            return nil
        end
    until tempDoor[doorCount]

    SetEntityDrawOutline(highlightedEntity, false)

    if doorCount > 1 then
        tempDoor[1].entity = nil
        tempDoor[2].entity = nil
        data.doors = table.clone(tempDoor)
        data.coords = data.doors[1].coords - ((data.doors[1].coords - data.doors[2].coords) / 2)
        data.doors[1].coords = RoundCoordinates(data.doors[1].coords)
        data.doors[2].coords = RoundCoordinates(data.doors[2].coords)
    else
        data.model = tempDoor[1].model
        data.coords = tempDoor[1].coords
        data.heading = tempDoor[1].heading
    end

    data.double = nil
    data.locked = data.locked and 1 or 0
    data.coords = RoundCoordinates(data.coords)

    table.wipe(tempDoor)
    return data
end

CreateThread(function()
    while true do
        table.wipe(nearbyDoors)
        local coords = GetEntityCoords(cache.ped)

        for _, door in pairs(doors) do
            local double = door.doors
            door.dist = #(coords - door.coords)

            if double then
                if door.dist < 80 then
                    for i = 1, 2 do
                        if not double[i].entity and IsModelValid(double[i].model) then
                            local entity = GetClosestObjectOfType(double[i].coords.x, double[i].coords.y,
                                double[i].coords.z, 1.0, double[i].model, false, false, false)

                            if entity ~= 0 then
                                double[i].entity = entity
                            end
                        end
                    end

                    if door.dist < 20 then
                        nearbyDoors[#nearbyDoors + 1] = door
                    end
                else
                    for i = 1, 2 do
                        double[i].entity = nil
                    end
                end
            elseif door.dist < 80 then
                if not door.entity and IsModelValid(door.model) then
                    local entity = GetClosestObjectOfType(door.coords.x, door.coords.y, door.coords.z, 1.0, door.model,
                        false, false, false)

                    if entity ~= 0 then
                        local min, max = GetModelDimensions(door.model)
                        local points = {
                            GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, min.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, min.x, min.y, max.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, max.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, min.x, max.y, min.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, min.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, max.x, min.y, max.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, max.z).xy,
                            GetOffsetFromEntityInWorldCoords(entity, max.x, max.y, min.z).xy
                        }

                        local centroid = vec2(0, 0)

                        for i = 1, 8 do
                            centroid += points[i]
                        end

                        centroid = centroid / 8
                        door.coords = vec3(centroid.x, centroid.y, door.coords.z)
                        door.entity = entity
                    end
                end

                if door.dist < 20 then
                    nearbyDoors[#nearbyDoors + 1] = door
                end
            elseif door.entity then
                door.entity = nil
            end
        end

        Wait(500)
    end
end)

function OpenDoor(raid)
    TriggerServerEvent('Housing:server:SetDoorState', ClosestDoor.homeId, ClosestDoor.name,
        ClosestDoor.locked == 1 and 0 or 1, raid)
end

CreateThread(function()
    local showUI

    while true do
        local num = #nearbyDoors

        if num > 0 then
            for i = 1, num do
                local door = nearbyDoors[i]

                if door.dist < door.distance then
                    if door.dist < (ClosestDoor?.dist or 10) then
                        ClosestDoor = door
                    end
                end
            end
        else
            ClosestDoor = nil
        end

        if ClosestDoor and ClosestDoor.dist < ClosestDoor.distance then
            if ClosestDoor.locked ~= showUI then
                HelpText(true, ClosestDoor.locked == 0 and locale('prompt_lock_door') or locale('prompt_unlock_door'))
                showUI = ClosestDoor.locked
            end

            if IsDisabledControlJustReleased(0, 38) then
                local home = Homes[ClosestDoor.homeId]
                local identifier = GetIdentifier()
                if home and home.keys:HasKey(identifier, 'Door ' .. ClosestDoor.permission) or isAdmin() then
                    TriggerServerEvent('Housing:server:SetDoorState', ClosestDoor.homeId, ClosestDoor.name,
                        ClosestDoor.locked == 1 and 0 or 1)
                else
                    Notify(locale('housing'), locale('door_no_permission'), 'error', 3000)
                end
            end
        elseif showUI then
            HelpText(false)
            showUI = nil
        end

        Wait(num > 0 and 0 or 500)
    end
end)

function IsNearMLODoor()
    return ClosestDoor ~= nil and true or false
end

function AddTempDoorlock(entity)
    local model = GetEntityModel(entity)
    local coords = GetEntityCoords(entity)

    AddDoorToSystem(`temp`, model, coords.x, coords.y, coords.z, false, false, false)
    DoorSystemSetDoorState(`temp`, 4, false, false)

    coords = GetEntityCoords(entity)
    tempDoor[#tempDoor + 1] = {
        entity = entity,
        model = model,
        coords = coords,
        heading = math.floor(GetEntityHeading(entity) + 0.5)
    }

    RemoveDoorFromSystem(`temp`)
end

function AddDoor(homeId, door)
    local double = door.doors
    doors[#doors + 1] = door
    doors[#doors].homeId = homeId
    debugPrint('[Door] Adding door', doors[#doors].name, doors[#doors].homeId)

    if double then
        for i = 1, 2 do
            double[i].hash = joaat(('house_%s_%s_%s'):format(homeId, door.name, i))
            AddDoorToSystem(double[i].hash, double[i].model, double[i].coords.x, double[i].coords.y, double[i].coords.z,
                false, false, false)
            DoorSystemSetDoorState(double[i].hash, 4, false, false)
            DoorSystemSetDoorState(double[i].hash, door.locked, false, false)
        end
    else
        door.hash = joaat(('house_%s_%s'):format(homeId, door.name))
        AddDoorToSystem(door.hash, door.model, door.coords.x, door.coords.y, door.coords.z, false, false, false)
        DoorSystemSetDoorState(door.hash, 4, false, false)
        DoorSystemSetDoorState(door.hash, door.locked, false, false)
    end
end

function RemoveDoor(homeId, door)
    local double = door.doors

    if double then
        for i = 1, 2 do
            double[i].hash = joaat(('house_%s_%s_%s'):format(homeId, door.name, i))
            RemoveDoorFromSystem(double[i].hash)
        end
    else
        door.hash = joaat(('house_%s_%s'):format(door.homeId, door.name))
        RemoveDoorFromSystem(door.hash)
    end

    for i = 1, #doors do
        if doors[i].homeId == homeId and doors[i].name == door.name then
            table.remove(doors, i)
            break
        end
    end
end

RegisterNUICallback('getHomeDoors', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        cb(home.doors)
    end
end)

---@diagnostic disable-next-line: missing-parameter
RegisterNUICallback('createDoor', function(data, cb)
    local admin = isAdmin()
    if not CurrentHome or not next(CurrentHome) then
        Notify(locale('housing'), locale('not_inside_home'), 'error', 3000)
        return
    elseif not Homes[CurrentHome.identifier]:isTenant('door') and not Homes[CurrentHome.identifier]:isKeyOwner() and not admin then
        Notify(locale('housing'), locale('not_owned_home'), 'error', 3000)
        return
    elseif CurrentHome and CurrentHome.identifier ~= data.identifier then
        Notify(locale('housing'), locale('incorrect_home'), 'error', 3000)
        return
    elseif not CurrentHome.permission.doorlock and not admin then
        return Notify(locale('housing'), locale('not_allowed_to_doorlock'), 'error', 3000)
    end
    ToggleNuiFrame(false)
    local door = CreateDoor(data)
    if door then
        TriggerServerEvent('Housing:server:AddDoor', CurrentHome.identifier, door)
    end
    cb({})
end)

RegisterNUICallback('deleteDoor', function(data, cb)
    local result = lib.callback.await('Housing:server:DeleteDoor', false, data)
    cb(result and true or false)
end)

RegisterNetEvent('Housing:client:AddDoor', function(homeId, data)
    AddDoor(homeId, data)
    local home = Homes[homeId]
    if home then
        home.doors[#home.doors + 1] = data
    end
end)

RegisterNetEvent('Housing:client:DeleteDoor', function(data)
    local home = Homes[data.identifier]
    if home then
        TriggerEvent('Housing:client:SetDoorState', data.identifier, data.name, 0)
        Wait(500)
        for i = 1, #doors do
            if doors[i].homeId == data.identifier and doors[i].name == data.name then
                table.remove(doors, i)
                break
            end
        end
        for i = 1, #home.doors do
            if home.doors[i].name == data.name then
                table.remove(home.doors, i)
                break
            end
        end
    end
end)

RegisterNetEvent('Housing:client:SetDoorState', function(homeId, name, state)
    local home = Homes[homeId]
    if home then
        for i = 1, #doors do
            if doors[i].homeId == homeId and doors[i].name == name then
                doors[i].locked = state
                local double = doors[i].doors
                if double then
                    for i = 1, 2 do
                        DoorSystemSetDoorState(double[i].hash, 4, false, false)
                        DoorSystemSetDoorState(double[i].hash, state, false, false)
                    end
                else
                    DoorSystemSetDoorState(doors[i].hash, 4, false, false)
                    DoorSystemSetDoorState(doors[i].hash, state, false, false)
                end
                break
            end
        end
        for i = 1, #home.doors do
            if home.doors[i].name == name then
                home.doors[i].locked = state
                break
            end
        end
    end
end)

---@diagnostic disable-next-line: missing-parameter
RegisterCommand(commands.deletehomedoor.name, function()
    local highlightedEntity = nil
    HelpText(true, locale('prompt_delete_door'))
    while true do
        local hit, entity, coords = lib.raycast.cam(1|16)
        DrawLine(GetEntityCoords(cache.ped), coords, 0, 255, 34, 255)

        if entity ~= highlightedEntity then
            SetEntityDrawOutline(highlightedEntity, false)
            if hit and entity > 0 and GetEntityType(entity) == 3 then
                SetEntityDrawOutline(entity, true)
            end
        end

        if IsControlJustPressed(0, 38) then
            for i = 1, #doors do
                if #(doors[i].coords - GetEntityCoords(entity)) < 2.0 then
                    lib.callback.await('Housing:server:DeleteDoor', false, doors[i])
                    break
                end
            end
            SetEntityDrawOutline(entity, false)
            HelpText(false)
            break
        end

        if IsControlJustPressed(0, 73) then
            HelpText(false)
            SetEntityDrawOutline(highlightedEntity, false)
            break
        end

        highlightedEntity = entity

        Wait(0)
    end
end)
