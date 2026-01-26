local config = require 'config.client'
local sharedConfig = require 'config.shared'
local route = 1
local max = #sharedConfig.npcLocations.locations
local busBlip = nil
local vehicleZone
local deliverZone
local pickupZone

local NpcData = {
    Active = false,
    LastNpc = nil,
    LastDeliver = nil,
    Npc = nil,
    NpcBlip = nil,
    DeliveryBlip = nil,
    NpcTaken = false,
    NpcDelivered = false,
    CountDown = 180
}

local BusData = {
    Active = false,
}

local depotPed = nil

-- Functions
local function resetNpcTask()
    NpcData = {
        Active = false,
        LastNpc = nil,
        LastDeliver = nil,
        Npc = nil,
        NpcBlip = nil,
        DeliveryBlip = nil,
        NpcTaken = false,
        NpcDelivered = false,
    }
end

local function removeBusBlip()
    if not busBlip then return end
    RemoveBlip(busBlip)
    busBlip = nil
end

local function removeNPCBlip()
    if NpcData.DeliveryBlip then
        RemoveBlip(NpcData.DeliveryBlip)
        NpcData.DeliveryBlip = nil
    end

    if NpcData.NpcBlip then
        RemoveBlip(NpcData.NpcBlip)
        NpcData.NpcBlip = nil
    end
end

local function updateBlip()
    if table.type(QBX.PlayerData) == 'empty' or (QBX.PlayerData.job.name ~= "bus" and busBlip) then
        removeBusBlip()
        return
    elseif (QBX.PlayerData.job.name == "bus" and not busBlip) then
        local coords = sharedConfig.location
        busBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(busBlip, 513)
        SetBlipDisplay(busBlip, 4)
        SetBlipScale(busBlip, 0.6)
        SetBlipAsShortRange(busBlip, true)
        SetBlipColour(busBlip, 49)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(locale('info.bus_depot'))
        EndTextCommandSetBlipName(busBlip)
        return
    end
end

local function isPlayerVehicleABus()
    if not cache.vehicle then return false end
    local veh = GetEntityModel(cache.vehicle)

    for i = 1, #config.allowedVehicles, 1 do
        if veh == config.allowedVehicles[i].model then
            return true
        end
    end

    if veh == `dynasty` then
        return true
    end

    return false
end

local function nextStop()
    route = route <= (max - 1) and route + 1 or 1
end

local function removePed(ped)
    SetTimeout(60000, function()
        DeletePed(ped)
    end)
end

local function getDeliveryLocation()
    nextStop()
    removeNPCBlip()
    NpcData.DeliveryBlip = AddBlipForCoord(sharedConfig.npcLocations.locations[route].x, sharedConfig.npcLocations.locations[route].y, sharedConfig.npcLocations.locations[route].z)
    SetBlipColour(NpcData.DeliveryBlip, 3)
    SetBlipRoute(NpcData.DeliveryBlip, true)
    SetBlipRouteColour(NpcData.DeliveryBlip, 3)
    NpcData.LastDeliver = route
    local inRange = false
    local shownTextUI = false
    deliverZone = lib.zones.sphere({
        name = "qbx_busjob_bus_deliver",
        coords = vec3(sharedConfig.npcLocations.locations[route].x, sharedConfig.npcLocations.locations[route].y, sharedConfig.npcLocations.locations[route].z),
        radius = 5,
        debug = config.debugPoly,
        onEnter = function()
            inRange = true
            if not shownTextUI then
                lib.showTextUI(locale('info.busstop_text'))
                shownTextUI = true
            end
            CreateThread(function()
                repeat
                    Wait(0)
                    -- Only handle if player is in a bus and has passengers
                    if cache.vehicle and isPlayerVehicleABus() and NpcData.NpcTaken and NpcData.Npc then
                        if IsControlJustPressed(0, 38) then
                            TaskLeaveVehicle(NpcData.Npc, cache.vehicle, 0)
                            SetEntityAsMissionEntity(NpcData.Npc, false, true)
                            SetEntityAsNoLongerNeeded(NpcData.Npc)
                            local targetCoords = sharedConfig.npcLocations.locations[NpcData.LastNpc]
                            TaskGoStraightToCoord(NpcData.Npc, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)
                            lib.notify({
                                title = locale('info.bus_job'),
                                description = locale('info.dropped_off'),
                                type = 'success'
                            })
                            removeNPCBlip()
                            removePed(NpcData.Npc)
                            resetNpcTask()
                            nextStop()
                            TriggerEvent('qbx_busjob:client:DoBusNpc')
                            lib.hideTextUI()
                            shownTextUI = false
                            deliverZone:remove()
                            deliverZone = nil
                            break
                        end
                    end
                until not inRange
            end)
        end,
        onExit = function()
            lib.hideTextUI()
            shownTextUI = false
            inRange = false
        end
    })
end

local function busGarage()
    local vehicleMenu = {}
    for _, v in pairs(config.allowedVehicles) do
        vehicleMenu[#vehicleMenu + 1] = {
            title = locale('info.bus'),
            event = "qbx_busjob:client:TakeVehicle",
            args = v
        }
    end
    lib.registerContext({
        id = 'qbx_busjob_open_garage_context_menu',
        title = locale('info.bus_header'),
        options = vehicleMenu
    })
    lib.showContext('qbx_busjob_open_garage_context_menu')
end

local function spawnDepotPed()
    if depotPed and DoesEntityExist(depotPed) then return end
    
    local pedModel = joaat('s_m_m_autoshop_02')
    lib.requestModel(pedModel, 5000)
    depotPed = CreatePed(0, pedModel, sharedConfig.location.x, sharedConfig.location.y, sharedConfig.location.z - 1.0, sharedConfig.location.w, false, false)
    SetModelAsNoLongerNeeded(pedModel)
    FreezeEntityPosition(depotPed, true)
    SetEntityInvincible(depotPed, true)
    SetBlockingOfNonTemporaryEvents(depotPed, true)
    TaskStartScenarioInPlace(depotPed, 'WORLD_HUMAN_CLIPBOARD', 0, true)
    
    exports.ox_target:addLocalEntity(depotPed, {
        {
            name = 'qbx_busjob_depot',
            icon = 'fa-solid fa-bus',
            label = locale('info.bus_job_vehicles'),
            distance = 2.5,
            onSelect = function()
                if not isPlayerVehicleABus() then
                    busGarage()
                else
                    if not NpcData.Active or NpcData.Active and not NpcData.NpcTaken then
                        if cache.vehicle then
                            BusData.Active = false
                            DeleteVehicle(cache.vehicle)
                            removeNPCBlip()
                            resetNpcTask()
                        end
                    else
                        lib.notify({
                            title = locale('info.bus_job'),
                            description = locale('error.drop_off_passengers'),
                            type = 'error'
                        })
                    end
                end
            end
        }
    })
end

local function deleteDepotPed()
    if depotPed and DoesEntityExist(depotPed) then
        DeletePed(depotPed)
        depotPed = nil
    end
end

local function updateZone()
    if vehicleZone then
        vehicleZone:remove()
        vehicleZone = nil
    end

    if table.type(QBX.PlayerData) == 'empty' or QBX.PlayerData.job.name ~= 'bus' then 
        deleteDepotPed()
        return 
    end
    
    spawnDepotPed()

    -- Vehicle zone removed - using depot ped with ox_target instead to prevent conflicts with bus stop zones
end

-- onExit()

RegisterNetEvent("qbx_busjob:client:TakeVehicle", function(data)
    if BusData.Active then
        lib.notify({
            title = locale('info.bus_job'),
            description = locale('error.one_bus_active'),
            type = 'error'
        })
        return
    end

    local netId = lib.callback.await('qbx_busjob:server:spawnBus', false, data.model)
    Wait(300)
    if not netId or netId == 0 or not NetworkDoesEntityExistWithNetworkId(netId) then
        lib.notify({
            title = locale('info.bus_job'),
            description = locale('error.failed_to_spawn'),
            type = 'error'
        })
        return
    end

    local veh = NetToVeh(netId)
    if veh == 0 then
        lib.notify({
            title = locale('info.bus_job'),
            description = locale('error.failed_to_spawn'),
            type = 'error'
        })
        return
    end

    SetVehicleFuelLevel(veh, 100.0)
    SetVehicleEngineOn(veh, true, true, false)
    lib.hideContext()
    TriggerEvent('qbx_busjob:client:DoBusNpc')
end)

-- Events
AddEventHandler('onResourceStart', function(resourceName)
    -- handles script restarts
    if GetCurrentResourceName() ~= resourceName then return end

    updateBlip()
    updateZone()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    deleteDepotPed()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    updateBlip()
    updateZone()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()

    updateBlip()
    updateZone()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function()

    updateBlip()
    updateZone()
end)

RegisterNetEvent('qbx_busjob:client:DoBusNpc', function()
    if not isPlayerVehicleABus() then
        lib.notify({
            title = locale('info.bus_job'),
            description = locale('error.not_in_bus'),
            type = 'error'
        })
        return
    end

    if not NpcData.Active then
        local Gender = math.random(1, #config.npcSkins)
        local PedSkin = math.random(1, #config.npcSkins[Gender])
        local model = joaat(config.npcSkins[Gender][PedSkin])
        lib.requestModel(model, 10000)
        NpcData.Npc = CreatePed(3, model, sharedConfig.npcLocations.locations[route].x, sharedConfig.npcLocations.locations[route].y, sharedConfig.npcLocations.locations[route].z - 0.98, sharedConfig.npcLocations.locations[route].w, false, true)
        SetModelAsNoLongerNeeded(model)
        PlaceObjectOnGroundProperly(NpcData.Npc)
        FreezeEntityPosition(NpcData.Npc, true)
        removeNPCBlip()
        NpcData.NpcBlip = AddBlipForCoord(sharedConfig.npcLocations.locations[route].x, sharedConfig.npcLocations.locations[route].y, sharedConfig.npcLocations.locations[route].z)
        SetBlipColour(NpcData.NpcBlip, 3)
        SetBlipRoute(NpcData.NpcBlip, true)
        SetBlipRouteColour(NpcData.NpcBlip, 3)
        NpcData.LastNpc = route
        NpcData.Active = true
        local inRange = false
        local shownTextUI = false
        pickupZone = lib.zones.sphere({
            name = "qbx_busjob_bus_pickup",
            coords = vec3(sharedConfig.npcLocations.locations[route].x, sharedConfig.npcLocations.locations[route].y, sharedConfig.npcLocations.locations[route].z),
            radius = 5,
            debug = config.debugPoly,
            onEnter = function()
                inRange = true
                if not shownTextUI then
                    lib.showTextUI(locale('info.busstop_text'))
                    shownTextUI = true
                end
                CreateThread(function()
                    repeat
                        Wait(0)
                        -- Only handle if player is in a bus
                        if cache.vehicle and isPlayerVehicleABus() then
                            if IsControlJustPressed(0, 38) then
                                local maxSeats, freeSeat = GetVehicleModelNumberOfSeats(GetEntityModel(cache.vehicle))

                                for i = maxSeats - 1, 0, -1 do
                                    if IsVehicleSeatFree(cache.vehicle, i) then
                                        freeSeat = i
                                        break
                                    end
                                end

                                if not freeSeat then 
                                    lib.notify({
                                        title = locale('info.bus_job'),
                                        description = 'No available seats on the bus',
                                        type = 'error'
                                    })
                                    break 
                                end

                                ClearPedTasksImmediately(NpcData.Npc)
                                FreezeEntityPosition(NpcData.Npc, false)
                                TaskEnterVehicle(NpcData.Npc, cache.vehicle, -1, freeSeat, 1.0, 0)
                                Wait(3000)
                                lib.notify({
                                    title = locale('info.bus_job'),
                                    description = locale('info.goto_busstop'),
                                    type = 'info'
                                })
                                removeNPCBlip()
                                getDeliveryLocation()
                                NpcData.NpcTaken = true
                                TriggerServerEvent('qbx_busjob:server:NpcPay')
                                lib.hideTextUI()
                                shownTextUI = false
                                pickupZone:remove()
                                pickupZone = nil
                                break
                            end
                        end
                    until not inRange
                end)
            end,
            onExit = function()
                lib.hideTextUI()
                shownTextUI = false
                inRange = false
            end
        })
    else
        lib.notify({
            title = locale('info.bus_job'),
            description = locale('error.already_driving_bus'),
            type = 'info'
        })
    end
end)
