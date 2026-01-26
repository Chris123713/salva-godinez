local Blips = {}
spawnedPeds = {}

ExitZone = function()
    HelpText(false)
    inZone = false
end

function LabelizeFurnitures(furnitures, home)
    local list = {}
    for i = 1, #furnitures do
        local furniture = furnitures[i]
        if (LocalPlayer.state.isInsideHome and not furniture.area) or (LocalPlayer.state.isInsideArea and furniture.area) then
            list[#list + 1] = table.clone(furniture)
            list[#list].label = FurnitureModelList[furniture.model]
                and FurnitureModelList[furniture.model].label or furniture.model
            local furncoords
            if home.properties.type == "mlo" or (LocalPlayer.state.isInsideArea and furniture.area) then
                furncoords = ToVector3(home.properties.entry) + ToVector3(furniture.coords)
            elseif home.properties.type == "ipl" then
                furncoords = ToVector3(CurrentHome.entryInside) + ToVector3(furniture.coords)
            else
                furncoords = GetOffsetFromEntityInWorldCoords(CurrentHome.object, furniture.coords.x, furniture.coords.y,
                    furniture.coords.z)
            end
            list[#list].coords = { x = round(furncoords.x, 3), y = round(furncoords.y, 3), z = round(furncoords.z, 3) }
        end
    end
    return list
end

function GetClosestFurnitureSpawn()
    local pedCoords = GetEntityCoords(cache.ped)
    local dist = 100
    local furnitureSpawn
    for _, store in pairs(Config.FurnitureShop.locations) do
        if #(pedCoords - store.coords) < dist then
            dist = #(pedCoords - store.coords)
            furnitureSpawn = store.furnitureSpawn
        end
    end
    return furnitureSpawn
end

-- Flat functions

function GetFlat(identifier, flatId)
    if flatId then
        for _, room in pairs(Flats[flatId].rooms) do
            if room.identifier == identifier then return room end
        end
    else
        for _, apt in pairs(Flats) do
            for _, room in pairs(apt.rooms) do
                if room.identifier == identifier then return room end
            end
        end
    end
    return nil
end

function GetNearestFlat()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closest = 10
    local closestApt
    for k, v in pairs(Flats) do
        local coord = ToVector3(v.entry)
        local dist = #(coord - pedCoords)
        if closest > dist then
            closest = dist
            closestApt = k
        end
    end
    return closestApt
end

-- Misc functions

function GetNearestHome(type)
    local pedCoords = GetEntityCoords(PlayerPedId())
    local nearest = 100
    local home
    for k, v in pairs(Homes) do
        if type and v.properties.complex ~= type then
            goto continue
        end
        local dist = #(pedCoords - v:GetEntryCoords())
        if dist < 10.0 and dist < nearest then
            debugPrint("[GetNearestHome]", "Nearest Home found! " .. v.properties.name)
            nearest = dist
            home = v
        end
        ::continue::
    end
    return home or false
end

function DeleteHome(identifier)
    HelpText(false)
    if identifier then
        TriggerServerEvent("Housing:server:DeleteHome", identifier)
    else
        local home = GetNearestHome('Individual')
        if home then
            inZone = false
            TriggerServerEvent("Housing:server:DeleteHome", home.identifier)
        end
    end
end

function DeleteApartment()
    local apartment = GetNearestHome('Apartment')
    if apartment then
        TriggerServerEvent('Housing:server:DeleteApartment', apartment.identifier)
    end
end

function DeleteFlat(name)
    HelpText(false)
    local found = false
    for _, apt in pairs(Flats) do
        for _, room in pairs(apt.rooms) do
            if room.properties.name == name then
                found = true
                TriggerServerEvent("Housing:server:DeleteHome", room.identifier)
                break
            end
        end
        if found then
            inZone = false
            break
        end
    end
    if not found then
        Notify(locale("housing"), locale("apt_not_found", name),
            "error", 3000)
    end
end

function AvailableRooms(rooms) -- To check if there is any available room in the flat or complex thats being passed
    local totalRooms = #rooms
    local ownsARoom = false
    for _, v in pairs(rooms) do
        if v.owner then
            if PlayerData and v.owner == GetIdentifier() then
                ownsARoom = true
            end
            totalRooms = totalRooms - 1
        end
    end
    return totalRooms, ownsARoom
end

function GetHomeObject(identifier)
    return Homes[identifier] or GetFlat(identifier) or {}
end

function GetCoordsHeading(name)
    HelpText(true, locale('prompt_title', name))
    while true do
        Wait(0)
        if IsControlJustReleased(0, 38) then break end
    end
    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
    HelpText(false)
    return {
        x = round(x, 2),
        y = round(y, 2),
        z = round(z, 2),
        w = round(GetEntityHeading(PlayerPedId()), 2)
    }
end

function createBlip(id, data)
    if not Blips[id] then
        Blips[id] = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(Blips[id], data.sprite)
        SetBlipDisplay(Blips[id], 4)
        SetBlipScale(Blips[id], data.scale)
        SetBlipColour(Blips[id], data.colour)
        SetBlipAsShortRange(Blips[id], true)

        if data.category then
            local function GetLabelCategory(category)
                for k, v in pairs(Config.Blips) do
                    if v.category == category and v.label then
                        return v.label
                    end
                end

                return data.label
            end

            SetBlipCategory(Blips[id], data.category)
            AddTextEntry("BLIP_CAT_" .. data.category, GetLabelCategory(data.category))
        end

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.label)
        EndTextCommandSetBlipName(Blips[id])
    end
end

function deleteBlip(id)
    if Blips[id] then
        debugPrint('[deleteBlip] Deleting blip', id)
        RemoveBlip(Blips[id])
        Blips[id] = nil
    end
end

function RemoveAllBlip()
    for k, v in pairs(Blips) do
        RemoveBlip(v)
        Blips[k] = nil
    end
end

function RefreshHomeBlip(homeId, admin)
    local home = Homes[homeId]
    if not home then return end
    if home.disabled then
        deleteBlip(home.identifier .. '_disabled')
        Wait(50)
        local data = table.clone(Config.Blips.disabled_house)
        data.coords = home.properties.entry
        data.label = home.properties.name
        createBlip(home.identifier .. '_disabled', data)
        return
    elseif home.properties.complex == 'Individual' then
        deleteBlip(home.identifier .. '_sell')
        deleteBlip(home.identifier .. '_owned')
        deleteBlip(home.identifier .. '_admin_owned')
        Wait(50)
        if not home.properties.owner then
            local data = table.clone(Config.Blips.house_sell)
            data.coords = home.properties.entry
            if blipStatus['sell'] then
                createBlip(home.identifier .. '_sell', data)
            end
        elseif PlayerData and home:isKeyOwner() or home:isTenant() then
            local data = table.clone(Config.Blips.owned_house)
            data.coords = home.properties.entry
            data.label = home.properties.name
            if blipStatus['owned'] then
                createBlip(home.identifier .. '_owned', data)
            end
        elseif PlayerData and home.properties.realestate and isAgent(home.properties.realestate) then
            if home.properties.owner then
                local data = table.clone(Config.Blips.agent_owned_house)
                data.coords = home.properties.entry
                if blipStatus['agent'] then
                    createBlip(home.identifier .. '_agent', data)
                end
            else
                local data = table.clone(Config.Blips.agent)
                data.coords = home.properties.entry
                if blipStatus['agent'] then
                    createBlip(home.identifier .. '_agent', data)
                end
            end
        elseif admin and not home:isKeyOwner() and not home:isTenant() then
            local data = table.clone(Config.Blips.admin_owned_house)
            data.coords = home.properties.entry
            if blipStatus['admin_owned'] then
                createBlip(home.identifier .. '_admin_owned', data)
            end
        end
    elseif home.properties.complex == 'Apartment' then
        deleteBlip(home.identifier .. '_sell')
        deleteBlip(home.identifier .. '_owned')
        deleteBlip(home.identifier .. '_admin_owned')
        Wait(50)
        lib.callback('Housing:server:OwnApartment', false, function(owned)
            if not owned then
                local data = table.clone(Config.Blips.apartment_sell)
                data.coords = home.properties.entry
                if data.enable then
                    createBlip(home.identifier .. '_sell', data)
                end
            elseif owned then
                local data = table.clone(Config.Blips.owned_apartment)
                data.coords = home.properties.entry
                data.label = home.properties.name
                if data.enable then
                    createBlip(home.identifier .. '_owned', data)
                end
            end
        end, home.identifier)
    end
end

function RefreshFlatBlip()
    -- Create blips for flats
    for _, v in pairs(Flats) do
        local emptyRooms, ownsARoom = AvailableRooms(v.rooms)
        for _, room in pairs(v.rooms) do
            local flatId = room.properties.data.flat.identifier
            deleteBlip(flatId .. "_sell")
            deleteBlip(flatId .. "_owned")
            if not Blips[flatId .. "_sell"] and not Blips[flatId .. "_owned"] then
                if emptyRooms > 0 and not ownsARoom then
                    local data = table.clone(Config.Blips.flat_available)
                    data.coords = room.properties.data.flat.coords
                    data.label = room.properties.data.flat.name
                    if blipStatus['sell'] then
                        createBlip(flatId .. "_sell", data)
                    end
                    break
                elseif emptyRooms == 0 and not ownsARoom then
                    local data = table.clone(Config.Blips.flat_unavailable)
                    data.coords = room.properties.data.flat.coords
                    data.label = room.properties.data.flat.name
                    if blipStatus['sell'] then
                        createBlip(flatId .. "_sell", data)
                    end
                    break
                elseif ownsARoom then
                    local data = table.clone(Config.Blips.owned_flat)
                    data.coords = room.properties.data.flat.coords
                    data.label = room.properties.data.flat.name
                    if blipStatus['owned'] then
                        createBlip(flatId .. "_owned", data)
                    end
                    break
                end
            end
        end
    end
end

function spawnPed(id, ped, coords, animDict, animName)
    local pedModel = ped

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        RequestModel(pedModel)
        Wait(100)
    end

    local createdPed = CreatePed(5, pedModel, coords.x, coords.y,
        coords.z - 1.0, coords.w, false, false)
    ClearPedTasks(createdPed)
    ClearPedSecondaryTask(createdPed)
    TaskSetBlockingOfNonTemporaryEvents(createdPed, true)
    SetPedFleeAttributes(createdPed, 0, 0)
    SetPedCombatAttributes(createdPed, 17, 1)

    SetPedSeeingRange(createdPed, 0.0)
    SetPedHearingRange(createdPed, 0.0)
    SetPedAlertness(createdPed, 0)
    SetPedKeepTask(createdPed, true)

    if animDict and animName then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do Citizen.Wait(1) end
        TaskPlayAnim(createdPed, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
    end

    spawnedPeds[id] = createdPed

    FreezeEntityPosition(createdPed, true)
    SetEntityInvincible(createdPed, true)
end

function deletePed(id)
    DeletePed(spawnedPeds[id])
    spawnedPeds[id] = nil
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerEvent("Housing:initialize")
    end
end)

AddEventHandler("onResourceStop", function(resourcename)
    if GetCurrentResourceName() == resourcename then
        if CurrentHome and CurrentHome.object then
            DeleteEntity(CurrentHome.object)
        end
        for k, v in pairs(spawnedPeds) do DeletePed(v) end
        for k, v in pairs(Homes) do
            if v.type ~= "mlo" then
                debugPrint("[onResourceStop]",
                    json.encode(Homes[k].spawnedObjects))
                for i = 1, #v.spawnedObjects do
                    debugPrint("[onResourceStop]", "Deleting MLO furniture", v.spawnedObjects[i].object)
                    DeleteEntity(v.spawnedObjects[i].object)
                end
            elseif v.properties.area and next(v.properties.area) then
                debugPrint("[onResourceStop]",
                    json.encode(Homes[k].areaObjects))
                for i = 1, #v.areaObjects do
                    debugPrint("[onResourceStop]",
                        "Deleting Frontyard Furniture", v.areaObjects[i].object)
                    DeleteEntity(v.areaObjects[i].object)
                end
            end
        end
        if LocalPlayer.state.isInsideHome then
            LocalPlayer.state.isInsideHome = nil
        end
    end
end)

UnpackParams = function(arguments, i)
    if not arguments then return end
    local index = i or 1

    if index <= #arguments then
        return arguments[index], UnpackParams(arguments, index + 1)
    end
end

function OpenHouseManager(identifier, isShell)
    local home = Homes[identifier]
    if home then
        local boxes = {
            {
                text = {
                    title = locale("furnish_home"),
                    body = locale("furnish_home_body")
                },
                event = "Housing:client:Furnish",
                icon = "home",
                args = { home.identifier }
            },
            {
                text = {
                    title = locale("edit_furniture"),
                    body = locale("edit_furniture_body")
                },
                event = "Housing:client:EditFurniture",
                icon = "sofa"
            },
            ---@TODO ADD FUNCTIONALITY
            {
                text = {
                    title = locale("pay_mortgage"),
                    body = locale("pay_mortgage_body")
                },
                event = "Housing:client:PayMortgage",
                icon = "banknote",
                args = { home.identifier, LocalPlayer.state.CurrentApartment }
            },
        }
        if home.properties.payment == "Rent" then
            table.insert(boxes, {
                text = {
                    title = locale("check_rent"),
                    body = locale("check_rent_body")
                },
                event = "Housing:checkRent",
                server = true,
                icon = "calendar-days",
                args = { home.identifier }
            })
        end
        if not isShell then
            if Homes[home.identifier].permission.sell then
                table.insert(boxes, {
                    text = {
                        title = locale("sell_home"),
                        body = locale("sell_home_body")
                    },
                    event = "Housing:client:SellHome",
                    icon = "banknote",
                    args = { home.identifier }
                })
            end
            if Homes[home.identifier].permission.transfer then
                table.insert(boxes, {
                    text = {
                        title = locale("transfer_home"),
                        body = locale("transfer_home_body")
                    },
                    event = "Housing:client:TransferHome",
                    icon = "arrow-right-left",
                    args = { home.identifier }
                })
            end
        end
        if home:isOwner() and isShell then
            table.insert(boxes, {
                text = {
                    title = locale("lock_home"),
                    body = locale("lock_home_body")
                },
                icon = "lock",
                server = true,
                event = "Housing:server:LockHome",
                args = { home.identifier }
            })
        end
        TriggerEvent("Housing:client:CreateMenu", { title = locale('house_manager_menu'), boxes = boxes })
    end
end

function GetCenterPoint(home, area)
    local homecoords
    if home.properties.type == "mlo" or (LocalPlayer.state.isInsideArea and not LocalPlayer.state.isInsideHome) or area then
        homecoords = ToVector3(home.properties.entry)
    elseif home.properties.type == "ipl" or home.properties.type == "mlo_teleport" and CurrentHome then
        homecoords = CurrentHome.entryInside
    elseif CurrentHome then
        homecoords = GetEntityCoords(CurrentHome.object)
    end
    return homecoords
end

RayCastGamePlayCamera = function(distance, custom)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    if custom then
        cameraRotation = custom.rotation
        cameraCoord = custom.camera
    end
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(
        StartShapeTestRay(cameraCoord.x, cameraCoord.y,
            cameraCoord.z, destination.x,
            destination.y, destination.z,
            -1, PlayerPedId(), 0))
    return b, c, e
end

RotationToDirection = function(rotation)
    -- https://github.com/Risky-Shot/new_banking/blob/main/new_banking/client/client.lua
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) *
            math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) *
            math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RequestKeyboardInput(title, description, maxlength)
    -- UpdateOnscreenKeyboard 2 = cancel 1 = enter 0 = normal
    AddTextEntry("RequestKeyboardInput", title .. " " .. description)
    DisplayOnscreenKeyboard(1, "RequestKeyboardInput", "", "", "", "", "",
        maxlength)
    local p = promise.new()
    CreateThread(function()
        while p do
            Wait(100)
            if UpdateOnscreenKeyboard() == 1 then
                local result = GetOnscreenKeyboardResult()
                CancelOnscreenKeyboard()
                p:resolve(result)
                p = nil
            elseif UpdateOnscreenKeyboard() == 2 then
                CancelOnscreenKeyboard()
                p:resolve("Invalid")
                p = nil
            end
        end
    end)
    return Citizen.Await(p)
end

function isPolice()
    return PlayerData.job and Config.robbery.policeName[PlayerData.job.name] and
        Config.robbery.policeName[PlayerData.job.name] <=
        GetPlayerGrade()
end

function isAdmin(permission)
    local result = lib.callback.await('Housing:server:isAdmin')
    if result and permission then
        return Config.Admin.Permission[permission]
    else
        return result
    end
end

function isAgent(job, perm)
    while not PlayerData or not PlayerData.job do
        Wait(500)
    end
    if job and PlayerData.job and PlayerData.job.name == job then
        if perm then
            return JobConfig.jobs[job].permission[perm] <= GetPlayerGrade()
        else
            return true
        end
    else
        return false
    end
end

function DoesModelExists(model)
    return IsModelValid(model) or IsModelInCdimage(model)
end

-- HUD

function displayHelp(text, position)
    SendNUIMessage({
        action = "displayHelp",
        data = { text = text, position = position or "top-left" }
    })
end

function closeHelp()
    if IsResourceStarted("bcs_hud") then exports["bcs_hud"]:closeKeybind() end
    SendNUIMessage({ action = "closeHelp", data = {} })
end

function GetVehiclePoint(data)
    HelpText(true, locale('prompt_vehicle_spawn_point'))
    local coords = GetEntityCoords(cache.ped)
    lib.requestModel(`sultan`)
    local vehicle = CreateVehicle(`sultan`, coords.x, coords.y, coords.z, GetEntityHeading(cache.ped),
        false, false)
    local heading = 0.0

    SetEntityAlpha(vehicle, 120)
    SetEntityCollision(vehicle, false)
    FreezeEntityPosition(vehicle, true)
    while true do
        local hit, entityHit, endCoords = lib.raycast.cam(nil, nil, 50)
        if hit then
            SetEntityCoords(vehicle, endCoords)
        end
        DisableControlAction(0, 18)
        DisableControlAction(0, 38)
        DisableControlAction(0, 73)
        SetEntityHeading(vehicle, heading)

        if IsDisabledControlJustPressed(0, 38) then
            Notify(locale('garage'), locale('spawn_point_added'))
            HelpText(false)
            DeleteVehicle(vehicle)

            data = not data and GetGarageData() or data

            return vec4(endCoords.x, endCoords.y, endCoords.z + 1.0, heading), data
        elseif IsDisabledControlJustPressed(0, 73) then
            Notify(locale('garage'), locale('garage_canceled'))
            HelpText(false)
            DeleteVehicle(vehicle)
            return false
        end

        if IsControlPressed(0, 175) then
            if heading <= 355 then
                heading += 1.0
                SetEntityHeading(vehicle, heading)
            end
        elseif IsControlPressed(0, 174) then
            if heading >= 5 then
                heading -= 1.0
                SetEntityHeading(vehicle, heading)
            end
        end
    end
end

function GetMloTeleport(name)
    for i = 1, #MLOTeleport, 1 do
        if MLOTeleport[i].name == name then
            return MLOTeleport[i]
        end
    end
    return nil
end

---@param shell string
---@param coords vector4?
---@return integer | nil
function CreateShell(shell, coords)
    if not IsModelValid(shell) then
        print('[HOUSING] ^1Shell does not exists! Make sure it is loaded', shell)
        DoScreenFadeIn(500)
        return
    elseif not Shells[shell] then
        print(('[HOUSING] ^1Shell %s is not in the list! Make sure it is config/shells.lua'):format(shell))
        DoScreenFadeIn(500)
        return
    end

    if not coords then
        local playerCoords = GetEntityCoords(cache.ped)
        coords = vec(playerCoords.x, playerCoords.y, playerCoords.z + 200.0)
    end

    RequestModel(shell)
    while not HasModelLoaded(shell) do
        Wait(1000)
    end
    local object = CreateObjectNoOffset(shell, coords.x, coords.y, coords.z, false, false, false)
    FreezeEntityPosition(object, true)
    SetEntityHeading(object, coords.w or 0.0)

    return object
end

exports('CreateShell', CreateShell)
