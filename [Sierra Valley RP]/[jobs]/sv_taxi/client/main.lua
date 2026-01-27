-- Client-Side Core Logic for Advanced Taxi System
local QBCore = exports['qbx_core']:GetCoreObject()

-- State Management
local isOnDuty = false
local currentVehicle = nil
local currentTrip = nil
local meterActive = false
local meterThread = nil

-- Trip Data
local tripData = {
    startCoords = nil,
    currentCoords = nil,
    pickupCoords = nil,
    dropoffCoords = nil,
    distance = 0.0,
    fare = 0.0,
    startTime = 0,
    duration = 0,
    passengerType = 'npc',
    vehicle = nil
}

-- NPC Job Data
local npcJob = {
    active = false,
    ped = nil,
    pickupBlip = nil,
    dropoffBlip = nil,
    pickupCoords = nil,
    dropoffCoords = nil,
    inVehicle = false
}

-- Player Data
local driverData = nil

-- Debug helper
local function Debug(msg)
    if Config.EnableDebug then
        print('^3[SV_TAXI CLIENT]^7 ' .. msg)
    end
end

-- UI Management
local function OpenUI()
    Debug('OpenUI called, fetching fresh data...')

    -- Fetch fresh driver data before opening UI
    lib.callback('sv_taxi:getDriverData', false, function(data)
        if data then
            driverData = data
            Debug('Fresh data received, opening UI now')

            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openUI',
                data = driverData
            })

            -- Update vehicle state
            local hasVeh = currentVehicle and DoesEntityExist(currentVehicle)
            SendNUIMessage({action = 'setVehicleState', hasVehicle = hasVeh})
        else
            Debug('Failed to get driver data, cannot open UI')
            lib.notify({type = 'error', description = 'Failed to load taxi data'})
        end
    end)
end

local function CloseUI()
    Debug('CloseUI called')
    SetNuiFocus(false, false)
    SendNUIMessage({action = 'closeUI'})
end

local function UpdateMeter(data)
    SendNUIMessage({
        action = 'updateMeter',
        data = data
    })
end

local function ShowMeter()
    SendNUIMessage({action = 'showMeter'})
end

local function HideMeter()
    SendNUIMessage({action = 'hideMeter'})
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    local vehicleModel = data.vehicle

    -- Find nearest taxi stand
    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestStand = nil
    local nearestDist = 999999.0

    for _, stand in ipairs(Config.TaxiStands) do
        local dist = #(playerCoords - stand.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearestStand = stand
        end
    end

    if not nearestStand then
        lib.notify({type = 'error', description = 'No taxi stand nearby'})
        cb('ok')
        return
    end

    lib.callback('sv_taxi:spawnVehicle', false, function(allowed)
        if allowed then
            SpawnTaxiVehicle(vehicleModel, nearestStand.vehicleSpawn)
            CloseUI()
        end
    end, vehicleModel, nearestStand.vehicleSpawn)

    cb('ok')
end)

RegisterNUICallback('startNPCJob', function(data, cb)
    StartNPCJob()
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('cancelJob', function(data, cb)
    CancelCurrentJob()
    cb('ok')
end)

-- Store dispatch calls locally so we don't lose them when accepting
local cachedDispatchCalls = {}

RegisterNUICallback('getDispatchCalls', function(data, cb)
    lib.callback('sv_taxi:getDispatchCalls', false, function(dispatchData)
        -- Cache the calls for later use
        if dispatchData and dispatchData.calls then
            cachedDispatchCalls = {}
            for _, call in ipairs(dispatchData.calls) do
                cachedDispatchCalls[call.id] = call
            end
        end
        cb(dispatchData)
    end)
end)

RegisterNUICallback('acceptCall', function(data, cb)
    local callId = data.callId
    Debug('Accepted dispatch call: ' .. callId)
    StartDispatchCall(callId)
    cb('ok')
end)

RegisterNUICallback('getVehicles', function(data, cb)
    lib.callback('sv_taxi:getVehicles', false, function(vehicles)
        cb(vehicles)
    end)
end)

RegisterNUICallback('getLeaderboard', function(data, cb)
    lib.callback('sv_taxi:getLeaderboard', false, function(leaderboard)
        cb(leaderboard)
    end)
end)

RegisterNUICallback('setNuiFocus', function(data, cb)
    SetNuiFocus(data.focus, data.cursor)
    cb('ok')
end)

RegisterNUICallback('returnVehicle', function(data, cb)
    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
        currentVehicle = nil

        -- Update UI to show no vehicle state
        SendNUIMessage({action = 'setVehicleState', hasVehicle = false})

        -- Hide dispatch when returning vehicle
        SendNUIMessage({action = 'hideDispatch'})

        lib.notify({
            type = 'success',
            description = 'Vehicle returned successfully'
        })
    else
        lib.notify({
            type = 'error',
            description = 'No vehicle to return'
        })
    end
    cb('ok')
end)

-- Vehicle Spawning
function SpawnTaxiVehicle(model, coords)
    local modelHash = joaat(model)

    lib.requestModel(modelHash, 10000)

    if not HasModelLoaded(modelHash) then
        lib.notify({type = 'error', description = 'Failed to load vehicle model'})
        return
    end

    -- Delete current vehicle if exists
    if currentVehicle and DoesEntityExist(currentVehicle) then
        DeleteEntity(currentVehicle)
    end

    -- Create vehicle
    local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, coords.w, true, false)

    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)

    -- Set vehicle properties
    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(vehicle))

    currentVehicle = vehicle

    lib.notify({
        type = 'success',
        description = 'Vehicle spawned! Press O to view available calls.'
    })

    SetModelAsNoLongerNeeded(modelHash)

    -- Update UI to show vehicle state
    SendNUIMessage({action = 'setVehicleState', hasVehicle = true})

    -- Show dispatch overlay after spawning vehicle
    Wait(1000)
    SendNUIMessage({action = 'showDispatch'})
end

-- Taxi Meter System
local function StartMeter()
    if meterActive then return end

    meterActive = true
    tripData.startCoords = GetEntityCoords(PlayerPedId())
    tripData.currentCoords = tripData.startCoords
    tripData.distance = 0.0
    tripData.fare = Config.Fare.baseRate
    tripData.startTime = GetGameTimer()
    tripData.duration = 0

    ShowMeter()

    -- Meter update thread
    if meterThread then
        Debug('Meter thread already running')
        return
    end

    meterThread = CreateThread(function()
        while meterActive do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle == 0 or vehicle ~= currentVehicle then
                Debug('Player left taxi vehicle, stopping meter')
                StopMeter()
                break
            end

            local newCoords = GetEntityCoords(ped)
            local distanceTraveled = #(newCoords - tripData.currentCoords)

            tripData.distance = tripData.distance + distanceTraveled
            tripData.currentCoords = newCoords
            tripData.duration = (GetGameTimer() - tripData.startTime) / 1000

            -- Calculate fare
            local fare = Config.Fare.baseRate
            fare = fare + (tripData.distance * Config.Fare.perMeter)
            fare = fare + (tripData.duration * Config.Fare.perSecond)

            -- Apply vehicle multiplier
            if tripData.vehicle and Config.Vehicles[tripData.vehicle] then
                fare = fare * Config.Vehicles[tripData.vehicle].multiplier
            end

            tripData.fare = math.max(Config.Fare.minimumFare, math.min(fare, Config.Fare.maximumFare))

            -- Update UI
            UpdateMeter({
                fare = tripData.fare,
                distance = tripData.distance,
                duration = math.floor(tripData.duration),
                speed = GetEntitySpeed(vehicle) * (Config.UI.showSpeedInMPH and 2.23694 or 3.6)
            })

            Wait(Config.UI.meterUpdateInterval)
        end

        meterThread = nil
    end)

    Debug('Meter started')
end

local function StopMeter()
    if not meterActive then return end

    meterActive = false
    HideMeter()

    Debug(('Meter stopped - Distance: %.2fm, Fare: $%.2f'):format(tripData.distance, tripData.fare))
end

-- NPC Job System
local function GetRandomPedSpawnLocation()
    -- Use predefined safe locations
    if Config.NPC.safeLocations and #Config.NPC.safeLocations > 0 then
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearbyLocations = {}

        -- Find locations within reasonable distance
        for _, loc in ipairs(Config.NPC.safeLocations) do
            local dist = #(playerCoords - vector3(loc.x, loc.y, loc.z))
            -- Between 200m and 1500m for variety
            if dist >= 200.0 and dist <= 1500.0 then
                table.insert(nearbyLocations, loc)
            end
        end

        -- If we found nearby locations, use one
        if #nearbyLocations > 0 then
            local randomLoc = nearbyLocations[math.random(#nearbyLocations)]
            Debug(('Selected safe pickup location at %.2f, %.2f, %.2f'):format(randomLoc.x, randomLoc.y, randomLoc.z))
            return randomLoc
        end

        -- Otherwise, use any safe location
        local randomLoc = Config.NPC.safeLocations[math.random(#Config.NPC.safeLocations)]
        Debug('Using random safe location (no nearby found)')
        return randomLoc
    end

    -- Fallback to old method if no safe locations defined
    Debug('No safe locations defined, using fallback method')
    local playerCoords = GetEntityCoords(PlayerPedId())
    local attempts = 0
    local maxAttempts = 20

    while attempts < maxAttempts do
        local randomOffset = vector3(
            math.random(-Config.NPC.spawnDistance, Config.NPC.spawnDistance),
            math.random(-Config.NPC.spawnDistance, Config.NPC.spawnDistance),
            0
        )

        local spawnCoords = playerCoords + randomOffset
        local _, groundZ = GetGroundZFor_3dCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z + 999.0, false)

        if groundZ then
            spawnCoords = vector3(spawnCoords.x, spawnCoords.y, groundZ)

            -- Check if location is on a street/road
            local _, heading = GetClosestVehicleNode(spawnCoords.x, spawnCoords.y, spawnCoords.z, 1, 3.0, 0)

            if heading then
                return vector4(spawnCoords.x, spawnCoords.y, spawnCoords.z, heading)
            end
        end

        attempts = attempts + 1
    end

    return nil
end

local function GetRandomDropoffLocation(pickupCoords)
    -- Use predefined safe locations
    if Config.NPC.safeLocations and #Config.NPC.safeLocations > 0 then
        local validDropoffs = {}

        -- Find locations within distance requirements
        for _, loc in ipairs(Config.NPC.safeLocations) do
            local dist = #(pickupCoords - vector3(loc.x, loc.y, loc.z))
            if dist >= Config.NPC.minDistance and dist <= Config.NPC.maxDistance then
                table.insert(validDropoffs, vector3(loc.x, loc.y, loc.z))
            end
        end

        -- If we found valid dropoffs, use one
        if #validDropoffs > 0 then
            local randomDropoff = validDropoffs[math.random(#validDropoffs)]
            Debug(('Selected safe dropoff location at %.2f, %.2f, %.2f'):format(randomDropoff.x, randomDropoff.y, randomDropoff.z))
            return randomDropoff
        end

        -- If no locations in preferred range, find ANY location that's different from pickup
        for _, loc in ipairs(Config.NPC.safeLocations) do
            local dist = #(pickupCoords - vector3(loc.x, loc.y, loc.z))
            -- At least 300m away
            if dist >= 300.0 then
                table.insert(validDropoffs, vector3(loc.x, loc.y, loc.z))
            end
        end

        if #validDropoffs > 0 then
            local randomDropoff = validDropoffs[math.random(#validDropoffs)]
            Debug('Using any safe location (relaxed distance requirements)')
            return randomDropoff
        end
    end

    -- Fallback to old method if no safe locations work
    Debug('Using fallback dropoff method')
    local attempts = 0
    local maxAttempts = 30

    while attempts < maxAttempts do
        local randomAngle = math.random() * 2 * math.pi
        local randomDistance = math.random(Config.NPC.minDistance, Config.NPC.maxDistance)

        local dropoffCoords = vector3(
            pickupCoords.x + math.cos(randomAngle) * randomDistance,
            pickupCoords.y + math.sin(randomAngle) * randomDistance,
            pickupCoords.z
        )

        local _, groundZ = GetGroundZFor_3dCoord(dropoffCoords.x, dropoffCoords.y, dropoffCoords.z + 999.0, false)

        if groundZ then
            dropoffCoords = vector3(dropoffCoords.x, dropoffCoords.y, groundZ)

            local _ = GetClosestVehicleNode(dropoffCoords.x, dropoffCoords.y, dropoffCoords.z, 1, 3.0, 0)

            if _ then
                return dropoffCoords
            end
        end

        attempts = attempts + 1
    end

    return nil
end

-- Start Dispatch Call (based on call type)
function StartDispatchCall(callId)
    if npcJob.active then
        lib.notify({type = 'error', description = 'You already have an active job!'})
        return
    end

    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        lib.notify({type = 'error', description = 'You need to be in a taxi vehicle!'})
        return
    end

    -- Get the actual call data from cached dispatch data
    Debug('Received callId: ' .. callId)

    -- Find the call in cache
    local selectedCall = cachedDispatchCalls[callId]

    if not selectedCall then
        Debug('Failed to find call with ID: ' .. callId .. ' in cache')
        lib.notify({type = 'error', description = 'Call not found - please refresh dispatch'})
        return
    end

    local callTypeId = selectedCall.callTypeId
    local zoneId = selectedCall.zoneId

    Debug('Found call - callTypeId: ' .. callTypeId .. ', zoneId: ' .. zoneId)

    -- Find the call type config
    local callType = nil
    for _, ct in ipairs(Config.CallTypes) do
        if ct.id == callTypeId then
            callType = ct
            break
        end
    end

    if not callType then
        Debug('Failed to find call type for ID: ' .. callTypeId)
        lib.notify({type = 'error', description = 'Invalid call type: ' .. callTypeId})
        return
    end

    -- Continue with the rest of the function
    ProcessDispatchCall(callType, zoneId, selectedCall.coords)
end

-- New function to process the dispatch call after we have all the data
function ProcessDispatchCall(callType, zoneId, providedCoords)
    -- Find the zone config
    local zone = nil
    for _, z in ipairs(Config.NPC.zones) do
        if z.id == zoneId then
            zone = z
            break
        end
    end

    Debug('Starting dispatch call: ' .. callType.label .. ' in zone: ' .. (zone and zone.name or 'Unknown'))

    -- Use the coordinates provided by the server (they already selected the location)
    local pickupLoc = providedCoords
    if not pickupLoc then
        -- Fallback: determine pickup location ourselves
        if callType.fixedPickup then
            -- Use fixed pickup (e.g., Standard Fare at Legion Square)
            pickupLoc = callType.fixedPickup
            Debug('Using fixed pickup location')
        else
            -- Use random location from zone
            if zone and #zone.locations > 0 then
                pickupLoc = zone.locations[math.random(#zone.locations)]
                Debug('Using random zone location')
            else
                -- Fallback to safe locations
                pickupLoc = Config.NPC.safeLocations[math.random(#Config.NPC.safeLocations)]
                Debug('Using fallback safe location')
            end
        end
    else
        Debug('Using pickup coords from server')
    end

    if not pickupLoc then
        lib.notify({type = 'error', description = 'Could not find a suitable pickup location'})
        return
    end

    npcJob.pickupCoords = vector3(pickupLoc.x, pickupLoc.y, pickupLoc.z)

    -- Determine dropoff location based on call type distance range
    local validDropoffs = {}

    -- Use locations from the zone if available
    local locationPool = zone and zone.locations or Config.NPC.safeLocations

    for _, loc in ipairs(locationPool) do
        local dist = #(npcJob.pickupCoords - vector3(loc.x, loc.y, loc.z))
        if dist >= callType.distanceRange[1] and dist <= callType.distanceRange[2] then
            table.insert(validDropoffs, vector3(loc.x, loc.y, loc.z))
        end
    end

    if #validDropoffs == 0 then
        -- Relax requirements
        for _, loc in ipairs(locationPool) do
            local dist = #(npcJob.pickupCoords - vector3(loc.x, loc.y, loc.z))
            if dist >= callType.distanceRange[1] * 0.7 then
                table.insert(validDropoffs, vector3(loc.x, loc.y, loc.z))
            end
        end
    end

    if #validDropoffs == 0 then
        lib.notify({type = 'error', description = 'Could not find a suitable dropoff location'})
        return
    end

    local dropoffLoc = validDropoffs[math.random(#validDropoffs)]
    npcJob.dropoffCoords = dropoffLoc
    npcJob.active = true
    npcJob.inVehicle = false
    npcJob.callType = callType

    -- Create pickup blip
    npcJob.pickupBlip = AddBlipForCoord(npcJob.pickupCoords.x, npcJob.pickupCoords.y, npcJob.pickupCoords.z)
    SetBlipSprite(npcJob.pickupBlip, Config.Blips.job.sprite)
    SetBlipColour(npcJob.pickupBlip, Config.Blips.job.color)
    SetBlipScale(npcJob.pickupBlip, Config.Blips.job.scale)
    SetBlipRoute(npcJob.pickupBlip, Config.Blips.job.route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(callType.label .. ' - Pickup')
    EndTextCommandSetBlipName(npcJob.pickupBlip)

    -- Spawn NPC at pickup location - use exact safe coordinates from config
    local randomModel = Config.NPC.models[math.random(#Config.NPC.models)]
    local modelHash = joaat(randomModel)

    Debug('Requesting model: ' .. randomModel)
    lib.requestModel(modelHash, 10000)

    -- Use the exact coordinates from config - they're already safe locations
    local spawnX = pickupLoc.x
    local spawnY = pickupLoc.y
    local spawnZ = pickupLoc.z
    local spawnHeading = pickupLoc.w

    Debug(('Spawning NPC at: %.2f, %.2f, %.2f, heading: %.2f'):format(spawnX, spawnY, spawnZ, spawnHeading))

    -- Load collision and streaming around spawn point
    RequestCollisionAtCoord(spawnX, spawnY, spawnZ)
    Wait(500) -- Give more time for streaming

    -- Create the ped at exact safe location (network = false, spawn instantly = true)
    npcJob.ped = CreatePed(4, modelHash, spawnX, spawnY, spawnZ, spawnHeading, false, true)

    -- Wait for ped to be created properly
    local timeout = 0
    while not DoesEntityExist(npcJob.ped) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not DoesEntityExist(npcJob.ped) then
        Debug('Failed to spawn NPC entity!')
        lib.notify({type = 'error', description = 'Failed to spawn passenger - try again'})
        SetModelAsNoLongerNeeded(modelHash)
        return
    end

    Debug('NPC entity created: ' .. tostring(npcJob.ped))

    -- Make ped fully visible and solid
    SetEntityAlpha(npcJob.ped, 255, false)
    SetEntityVisible(npcJob.ped, true, false)
    SetEntityCollision(npcJob.ped, true, true)

    -- Configure the ped
    SetEntityAsMissionEntity(npcJob.ped, true, true)
    SetBlockingOfNonTemporaryEvents(npcJob.ped, true)
    SetEntityInvincible(npcJob.ped, true)
    SetPedRelationshipGroupHash(npcJob.ped, GetHashKey("CIVMALE"))
    SetPedCanRagdoll(npcJob.ped, false)
    SetEntityLoadCollisionFlag(npcJob.ped, true)

    -- Place ped at exact spawn position (no validation to avoid moving into buildings)
    SetEntityCoordsNoOffset(npcJob.ped, spawnX, spawnY, spawnZ, false, false, false)
    PlaceObjectOnGroundProperly(npcJob.ped)
    SetEntityHeading(npcJob.ped, spawnHeading)
    FreezeEntityPosition(npcJob.ped, true)

    -- Force render the ped at max distance
    Wait(100)
    SetEntityLodDist(npcJob.ped, 1000)

    local finalPedCoords = GetEntityCoords(npcJob.ped)
    npcJob.pickupCoords = vector3(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z)

    Debug(('NPC spawned at exact coords: %.2f, %.2f, %.2f, heading: %.2f'):format(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z, spawnHeading))
    print('^2[TAXI] NPC Entity: ' .. tostring(npcJob.ped) .. ' | Exists: ' .. tostring(DoesEntityExist(npcJob.ped)) .. ' | Visible: ' .. tostring(IsEntityVisible(npcJob.ped)) .. '^7')

    -- Create blip at actual ped location
    if npcJob.pickupBlip then
        RemoveBlip(npcJob.pickupBlip)
    end
    npcJob.pickupBlip = AddBlipForCoord(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z)
    SetBlipSprite(npcJob.pickupBlip, Config.Blips.job.sprite)
    SetBlipColour(npcJob.pickupBlip, Config.Blips.job.color)
    SetBlipScale(npcJob.pickupBlip, Config.Blips.job.scale)
    SetBlipRoute(npcJob.pickupBlip, Config.Blips.job.route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(callType.label .. ' - Pickup')
    EndTextCommandSetBlipName(npcJob.pickupBlip)

    SetModelAsNoLongerNeeded(modelHash)

    lib.notify({
        type = 'success',
        description = callType.label .. ' accepted! Passenger is waiting for pickup.'
    })

    -- Start pickup monitoring - auto enter when close
    CreateThread(function()
        while npcJob.active and not npcJob.inVehicle do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - npcJob.pickupCoords)

            if distance < 15.0 then
                -- Check if player is in taxi vehicle
                local inVehicle = IsPedInVehicle(playerPed, currentVehicle, false)

                if inVehicle and distance < 10.0 then
                    -- Automatically pick up passenger
                    PickupPassenger()
                    break
                end
            end

            Wait(500)
        end
    end)

    -- Timeout thread
    SetTimeout(Config.NPC.timeout, function()
        if npcJob.active and not npcJob.inVehicle then
            lib.notify({type = 'error', description = 'Passenger got tired of waiting and left'})
            CancelCurrentJob()
        end
    end)
end

function StartNPCJob()
    if npcJob.active then
        lib.notify({type = 'error', description = 'You already have an active job!'})
        return
    end

    if not currentVehicle or not DoesEntityExist(currentVehicle) then
        lib.notify({type = 'error', description = 'You need to be in a taxi vehicle!'})
        return
    end

    -- Get random pickup location
    local pickupLoc = GetRandomPedSpawnLocation()

    if not pickupLoc then
        lib.notify({type = 'error', description = 'Could not find a suitable pickup location'})
        return
    end

    npcJob.pickupCoords = vector3(pickupLoc.x, pickupLoc.y, pickupLoc.z)

    -- Get random dropoff location
    local dropoffLoc = GetRandomDropoffLocation(npcJob.pickupCoords)

    if not dropoffLoc then
        lib.notify({type = 'error', description = 'Could not find a suitable dropoff location'})
        return
    end

    npcJob.dropoffCoords = dropoffLoc
    npcJob.active = true
    npcJob.inVehicle = false

    -- Create pickup blip
    npcJob.pickupBlip = AddBlipForCoord(npcJob.pickupCoords.x, npcJob.pickupCoords.y, npcJob.pickupCoords.z)
    SetBlipSprite(npcJob.pickupBlip, Config.Blips.job.sprite)
    SetBlipColour(npcJob.pickupBlip, Config.Blips.job.color)
    SetBlipScale(npcJob.pickupBlip, Config.Blips.job.scale)
    SetBlipRoute(npcJob.pickupBlip, Config.Blips.job.route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Pickup Location')
    EndTextCommandSetBlipName(npcJob.pickupBlip)

    -- Spawn NPC at pickup location - use exact safe coordinates from config
    local randomModel = Config.NPC.models[math.random(#Config.NPC.models)]
    local modelHash = joaat(randomModel)

    Debug('Requesting model: ' .. randomModel)
    lib.requestModel(modelHash, 10000)

    -- Use the exact coordinates from config - they're already safe locations
    local spawnX = pickupLoc.x
    local spawnY = pickupLoc.y
    local spawnZ = pickupLoc.z
    local spawnHeading = pickupLoc.w

    Debug(('Spawning NPC at: %.2f, %.2f, %.2f, heading: %.2f'):format(spawnX, spawnY, spawnZ, spawnHeading))

    -- Load collision and streaming around spawn point
    RequestCollisionAtCoord(spawnX, spawnY, spawnZ)
    Wait(500) -- Give more time for streaming

    -- Create the ped at exact safe location (network = false, spawn instantly = true)
    npcJob.ped = CreatePed(4, modelHash, spawnX, spawnY, spawnZ, spawnHeading, false, true)

    -- Wait for ped to be created properly
    local timeout = 0
    while not DoesEntityExist(npcJob.ped) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not DoesEntityExist(npcJob.ped) then
        Debug('Failed to spawn NPC entity!')
        lib.notify({type = 'error', description = 'Failed to spawn passenger - try again'})
        SetModelAsNoLongerNeeded(modelHash)
        return
    end

    Debug('NPC entity created: ' .. tostring(npcJob.ped))

    -- Make ped fully visible and solid
    SetEntityAlpha(npcJob.ped, 255, false)
    SetEntityVisible(npcJob.ped, true, false)
    SetEntityCollision(npcJob.ped, true, true)

    -- Configure the ped
    SetEntityAsMissionEntity(npcJob.ped, true, true)
    SetBlockingOfNonTemporaryEvents(npcJob.ped, true)
    SetEntityInvincible(npcJob.ped, true)
    SetPedRelationshipGroupHash(npcJob.ped, GetHashKey("CIVMALE"))
    SetPedCanRagdoll(npcJob.ped, false)
    SetEntityLoadCollisionFlag(npcJob.ped, true)

    -- Place ped at exact spawn position (no validation to avoid moving into buildings)
    SetEntityCoordsNoOffset(npcJob.ped, spawnX, spawnY, spawnZ, false, false, false)
    PlaceObjectOnGroundProperly(npcJob.ped)
    SetEntityHeading(npcJob.ped, spawnHeading)
    FreezeEntityPosition(npcJob.ped, true)

    -- Force render the ped at max distance
    Wait(100)
    SetEntityLodDist(npcJob.ped, 1000)

    local finalPedCoords = GetEntityCoords(npcJob.ped)
    npcJob.pickupCoords = vector3(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z)

    Debug(('NPC spawned at exact coords: %.2f, %.2f, %.2f, heading: %.2f'):format(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z, spawnHeading))
    print('^2[TAXI] NPC Entity: ' .. tostring(npcJob.ped) .. ' | Exists: ' .. tostring(DoesEntityExist(npcJob.ped)) .. ' | Visible: ' .. tostring(IsEntityVisible(npcJob.ped)) .. '^7')

    -- Create blip at actual ped location
    if npcJob.pickupBlip then
        RemoveBlip(npcJob.pickupBlip)
    end
    npcJob.pickupBlip = AddBlipForCoord(finalPedCoords.x, finalPedCoords.y, finalPedCoords.z)
    SetBlipSprite(npcJob.pickupBlip, Config.Blips.job.sprite)
    SetBlipColour(npcJob.pickupBlip, Config.Blips.job.color)
    SetBlipScale(npcJob.pickupBlip, Config.Blips.job.scale)
    SetBlipRoute(npcJob.pickupBlip, Config.Blips.job.route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Pickup Location')
    EndTextCommandSetBlipName(npcJob.pickupBlip)

    SetModelAsNoLongerNeeded(modelHash)

    lib.notify({
        type = 'info',
        description = 'New passenger is waiting for pickup! Check your GPS.'
    })

    -- Start pickup monitoring thread - auto enter when close
    CreateThread(function()
        while npcJob.active and not npcJob.inVehicle do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - npcJob.pickupCoords)

            if distance < 15.0 then
                -- Check if player is in taxi vehicle
                local inVehicle = IsPedInVehicle(playerPed, currentVehicle, false)

                if inVehicle and distance < 10.0 then
                    -- Automatically pick up passenger
                    PickupPassenger()
                    break
                end
            end

            Wait(500)
        end
    end)

    -- Timeout thread
    SetTimeout(Config.NPC.timeout, function()
        if npcJob.active and not npcJob.inVehicle then
            lib.notify({type = 'error', description = 'Passenger got tired of waiting and left'})
            CancelCurrentJob()
        end
    end)

    Debug('NPC job started')
end

function PickupPassenger()
    if not npcJob.active or npcJob.inVehicle then return end

    lib.notify({
        type = 'info',
        description = 'Passenger is getting in...'
    })

    -- Unfreeze and clear tasks
    FreezeEntityPosition(npcJob.ped, false)
    ClearPedTasksImmediately(npcJob.ped)

    -- Find closest back seat
    local pedCoords = GetEntityCoords(npcJob.ped)
    local vehCoords = GetEntityCoords(currentVehicle)

    -- Get vehicle bone positions for back doors
    local leftRearDoor = GetWorldPositionOfEntityBone(currentVehicle, GetEntityBoneIndexByName(currentVehicle, 'door_dside_r'))
    local rightRearDoor = GetWorldPositionOfEntityBone(currentVehicle, GetEntityBoneIndexByName(currentVehicle, 'door_pside_r'))

    -- Calculate distances to each door
    local distLeft = #(pedCoords - leftRearDoor)
    local distRight = #(pedCoords - rightRearDoor)

    -- Choose closest seat (1 = back right, 2 = back left)
    local seatIndex = (distRight < distLeft) and 1 or 2

    -- Task ped to enter vehicle at nearest seat with higher speed
    TaskEnterVehicle(npcJob.ped, currentVehicle, 5000, seatIndex, 2.0, 1, 0)

    -- Wait for ped to enter with longer timeout
    local timeout = 0
    while not IsPedInVehicle(npcJob.ped, currentVehicle, false) and timeout < 200 do
        Wait(100)
        timeout = timeout + 1

        -- Check if ped is stuck
        if timeout > 50 and timeout % 50 == 0 then
            -- Try to warp ped into vehicle if taking too long
            if #(GetEntityCoords(npcJob.ped) - vehCoords) < 5.0 then
                SetPedIntoVehicle(npcJob.ped, currentVehicle, seatIndex)
                break
            end
        end
    end

    if not IsPedInVehicle(npcJob.ped, currentVehicle, false) then
        -- Last resort: warp them in
        SetPedIntoVehicle(npcJob.ped, currentVehicle, seatIndex)
        Wait(100)

        if not IsPedInVehicle(npcJob.ped, currentVehicle, false) then
            lib.notify({type = 'error', description = 'Passenger failed to enter the vehicle'})
            CancelCurrentJob()
            return
        end
    end

    npcJob.inVehicle = true

    -- Remove pickup blip
    if npcJob.pickupBlip then
        RemoveBlip(npcJob.pickupBlip)
        npcJob.pickupBlip = nil
    end

    -- Create dropoff blip
    npcJob.dropoffBlip = AddBlipForCoord(npcJob.dropoffCoords.x, npcJob.dropoffCoords.y, npcJob.dropoffCoords.z)
    SetBlipSprite(npcJob.dropoffBlip, Config.Blips.job.sprite)
    SetBlipColour(npcJob.dropoffBlip, Config.Blips.job.color)
    SetBlipScale(npcJob.dropoffBlip, Config.Blips.job.scale)
    SetBlipRoute(npcJob.dropoffBlip, Config.Blips.job.route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Dropoff Location')
    EndTextCommandSetBlipName(npcJob.dropoffBlip)

    -- Store trip data
    tripData.pickupCoords = npcJob.pickupCoords
    tripData.dropoffCoords = npcJob.dropoffCoords
    tripData.passengerType = 'npc'
    tripData.vehicle = GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)):lower()

    -- Start the meter
    StartMeter()

    -- Notify server
    lib.callback('sv_taxi:startTrip', false, function() end, tripData)

    lib.notify({
        type = 'success',
        description = 'Passenger picked up! Drive to the dropoff location.'
    })

    -- Start dropoff monitoring thread
    CreateThread(function()
        while npcJob.active and npcJob.inVehicle do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - npcJob.dropoffCoords)

            if distance < 15.0 then
                lib.showTextUI('[E] Drop off passenger', {position = 'left-center'})

                if IsControlJustPressed(0, 38) then -- E key
                    DropoffPassenger()
                    break
                end
            else
                lib.hideTextUI()
            end

            Wait(0)
        end

        lib.hideTextUI()
    end)

    Debug('Passenger picked up')
end

function DropoffPassenger()
    if not npcJob.active or not npcJob.inVehicle then return end

    -- Stop meter
    StopMeter()

    -- Make NPC exit vehicle
    TaskLeaveVehicle(npcJob.ped, currentVehicle, 0)

    Wait(2000)

    -- Complete trip on server
    lib.callback('sv_taxi:completeTrip', false, function(result)
        if result then
            local tipText = result.tip > 0 and (' + $%.2f tip!'):format(result.tip) or ''
            lib.notify({
                type = 'success',
                description = ('Trip completed! Earned $%.2f%s (+%d XP)'):format(result.total, tipText, result.xp),
                duration = 5000
            })

            if result.rankUp then
                lib.notify({
                    type = 'success',
                    description = ('🎉 RANK UP! You are now a %s!'):format(result.newRankName),
                    duration = 7000
                })
            end

            -- Refresh driver data
            RefreshDriverData()
        end
    end, {
        pickupCoords = tripData.pickupCoords,
        dropoffCoords = tripData.dropoffCoords,
        distance = tripData.distance,
        passengerType = tripData.passengerType,
        vehicle = tripData.vehicle
    })

    -- Cleanup
    if DoesEntityExist(npcJob.ped) then
        SetTimeout(5000, function()
            DeleteEntity(npcJob.ped)
        end)
    end

    if npcJob.dropoffBlip then
        RemoveBlip(npcJob.dropoffBlip)
    end

    npcJob = {
        active = false,
        ped = nil,
        pickupBlip = nil,
        dropoffBlip = nil,
        pickupCoords = nil,
        dropoffCoords = nil,
        inVehicle = false
    }

    Debug('Passenger dropped off')
end

function CancelCurrentJob()
    if not npcJob.active then return end

    -- Stop meter if running
    if meterActive then
        StopMeter()
    end

    -- Cleanup NPC
    if npcJob.ped and DoesEntityExist(npcJob.ped) then
        if npcJob.inVehicle then
            TaskLeaveVehicle(npcJob.ped, currentVehicle, 0)
            Wait(2000)
        end
        DeleteEntity(npcJob.ped)
    end

    -- Remove blips
    if npcJob.pickupBlip then
        RemoveBlip(npcJob.pickupBlip)
    end

    if npcJob.dropoffBlip then
        RemoveBlip(npcJob.dropoffBlip)
    end

    -- Notify server
    lib.callback('sv_taxi:cancelTrip', false, function() end)

    npcJob = {
        active = false,
        ped = nil,
        pickupBlip = nil,
        dropoffBlip = nil,
        pickupCoords = nil,
        dropoffCoords = nil,
        inVehicle = false
    }

    lib.notify({type = 'error', description = 'Job cancelled'})
    Debug('Job cancelled')
end

-- Refresh driver data from server
function RefreshDriverData()
    lib.callback('sv_taxi:getDriverData', false, function(data)
        driverData = data
        SendNUIMessage({
            action = 'updateDriverData',
            data = data
        })
    end)
end

-- Commands
RegisterCommand('taximenu', function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job and Player.job.name == Config.JobName then
        OpenUI()
    else
        lib.notify({
            type = 'error',
            description = 'You must be employed as a taxi driver!'
        })
    end
end, false)

RegisterCommand('taxidebug', function()
    local Player = QBCore.Functions.GetPlayerData()
    print('^3=== TAXI DEBUG INFO ===^7')
    print('Job Name: ' .. tostring(Player.job.name))
    print('On Duty: ' .. tostring(Player.job.onduty))
    print('Config Job Name: ' .. Config.JobName)
    print('Driver Data: ' .. json.encode(driverData))
    print('^3=====================^7')
end, false)

-- Toggle Dispatch with O key
RegisterCommand('+toggleDispatch', function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job and Player.job.name == Config.JobName and Player.job.onduty then
        if currentVehicle and DoesEntityExist(currentVehicle) then
            SendNUIMessage({action = 'toggleDispatch'})
        else
            lib.notify({type = 'error', description = 'You need to be in a taxi vehicle!'})
        end
    end
end, false)

RegisterCommand('-toggleDispatch', function() end, false)

RegisterKeyMapping('+toggleDispatch', 'Toggle Taxi Dispatch', 'keyboard', 'O')

-- Monitor vehicle state and hide dispatch when exiting vehicle
CreateThread(function()
    local wasInTaxiVehicle = false

    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        local inTaxiVehicle = currentVehicle and DoesEntityExist(currentVehicle) and IsPedInVehicle(ped, currentVehicle, false)

        if wasInTaxiVehicle and not inTaxiVehicle then
            -- Just exited taxi vehicle, hide dispatch
            SendNUIMessage({action = 'hideDispatch'})
            Debug('Exited taxi vehicle, hiding dispatch')
        end

        wasInTaxiVehicle = inTaxiVehicle
    end
end)

-- Callback to get street name for dispatch
lib.callback.register('sv_taxi:getStreetName', function(x, y, z)
    local streetHash, crossingHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossingName = GetStreetNameFromHashKey(crossingHash)

    if crossingName and crossingName ~= '' and crossingName ~= streetName then
        return streetName .. ' / ' .. crossingName
    else
        return streetName or 'Los Santos'
    end
end)

-- Exports
exports('OpenTaxiUI', OpenUI)
exports('StartNPCJob', StartNPCJob)
exports('CancelJob', CancelCurrentJob)

Debug('^2Taxi Job Client Loaded^7')
