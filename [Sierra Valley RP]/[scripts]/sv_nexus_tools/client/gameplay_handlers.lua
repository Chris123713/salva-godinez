-- Client Gameplay Handlers
-- Handles client-side events for gameplay tools

-- ============================================
-- EXPLOSIONS
-- ============================================

RegisterNetEvent('nexus:client:triggerExplosion', function(data)
    local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
    local explosionType = data.explosionType or 0
    local damageScale = data.damageScale or 1.0
    local isAudible = data.isAudible
    local isVisible = data.isVisible
    local noDamage = data.noDamage

    AddExplosion(
        coords.x, coords.y, coords.z,
        explosionType,
        damageScale,
        isAudible,
        not noDamage,
        1.0
    )
end)

-- ============================================
-- WANTED LEVEL
-- ============================================

RegisterNetEvent('nexus:client:setWantedLevel', function(data)
    local level = data.level or 0
    local flash = data.flash

    SetPlayerWantedLevel(PlayerId(), level, false)
    SetPlayerWantedLevelNow(PlayerId(), flash)
end)

-- ============================================
-- SCREEN EFFECTS
-- ============================================

local activeEffects = {}

RegisterNetEvent('nexus:client:screenEffect', function(data)
    local effect = data.effect
    local duration = data.duration or 5000
    local looped = data.looped

    if looped then
        AnimpostfxPlay(effect, 0, true)
        activeEffects[effect] = true
    else
        AnimpostfxPlay(effect, duration, false)
    end

    -- Auto-stop non-looped effects
    if not looped and duration > 0 then
        SetTimeout(duration, function()
            AnimpostfxStop(effect)
        end)
    end
end)

RegisterNetEvent('nexus:client:stopScreenEffect', function(data)
    local effect = data.effect

    AnimpostfxStop(effect)
    activeEffects[effect] = nil
end)

-- ============================================
-- DISTANT SIRENS
-- ============================================

RegisterNetEvent('nexus:client:distantSirens', function(data)
    local duration = data.duration or 30000
    local intensity = data.intensity or 'medium'

    -- Intensity affects volume and frequency
    local volume = 0.3
    local interval = 5000

    if intensity == 'low' then
        volume = 0.15
        interval = 8000
    elseif intensity == 'high' then
        volume = 0.5
        interval = 3000
    end

    DistantCopCarSirens(true)

    -- Stop after duration
    SetTimeout(duration, function()
        DistantCopCarSirens(false)
    end)
end)

-- ============================================
-- VEHICLE CHASE
-- ============================================

RegisterNetEvent('nexus:client:startVehicleChase', function(data)
    local vehicleNetId = data.vehicleNetId
    local targetSource = data.targetSource
    local mode = data.mode or 'chase'
    local drivingFlags = data.drivingFlags or 786468

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

    local driver = GetPedInVehicleSeat(vehicle, -1)
    if not DoesEntityExist(driver) then return end

    -- Get target player's ped
    local targetPlayer = GetPlayerFromServerId(targetSource)
    local targetPed = GetPlayerPed(targetPlayer)

    if mode == 'chase' then
        -- Chase the target
        TaskVehicleChase(driver, targetPed)
        SetDriveTaskDrivingStyle(driver, drivingFlags)
    else
        -- Flee from the target
        local targetCoords = GetEntityCoords(targetPed)
        TaskVehicleFleeCoord(driver, targetCoords.x, targetCoords.y, targetCoords.z, 100.0, drivingFlags)
    end
end)

-- ============================================
-- FLEE AREA
-- ============================================

RegisterNetEvent('nexus:client:fleeArea', function(data)
    local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
    local radius = data.radius or 50.0
    local includeAmbient = data.includeAmbient

    -- Get all peds in area
    local peds = lib.getNearbyPeds(coords, radius, true)

    for _, pedData in ipairs(peds) do
        local ped = pedData.ped

        -- Skip player peds unless includeAmbient is true for ambient NPCs
        if not IsPedAPlayer(ped) then
            TaskSmartFleeCoord(ped, coords.x, coords.y, coords.z, radius * 2, -1, false, false)
            SetPedFleeAttributes(ped, 0, false)
        end
    end
end)

-- ============================================
-- DISABLE VEHICLE
-- ============================================

RegisterNetEvent('nexus:client:disableVehicle', function(data)
    local vehicleNetId = data.vehicleNetId
    local disableType = data.disableType or 'engine'

    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not DoesEntityExist(vehicle) then return end

    if disableType == 'engine' or disableType == 'all' then
        SetVehicleEngineHealth(vehicle, 0.0)
        SetVehicleUndriveable(vehicle, true)
    end

    if disableType == 'tires' or disableType == 'all' then
        for i = 0, 7 do
            SetVehicleTyreBurst(vehicle, i, true, 1000.0)
        end
    end
end)

-- ============================================
-- ISOLATED SCENES
-- ============================================

local currentScene = nil
local originalWeather = nil
local originalTime = nil

RegisterNetEvent('nexus:client:enterIsolatedScene', function(data)
    currentScene = data.sceneId

    -- Store original weather/time
    originalWeather = GetPrevWeatherTypeHashName()
    originalTime = { GetClockHours(), GetClockMinutes() }

    -- Set scene weather
    if data.weather then
        SetWeatherTypeNowPersist(data.weather)
    end

    -- Set scene time
    if data.hour then
        NetworkOverrideClockTime(data.hour, 0, 0)
    end

    -- Set up exit zone if defined
    if data.exitCoords then
        local exitCoords = vector3(data.exitCoords.x, data.exitCoords.y, data.exitCoords.z)
        local exitRadius = data.exitRadius or 50.0

        -- Create thread to check for exit
        CreateThread(function()
            while currentScene == data.sceneId do
                Wait(1000)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - exitCoords)

                if distance <= exitRadius then
                    -- Notify server to end scene for this player
                    TriggerServerEvent('nexus:server:checkSceneExit', data.sceneId)
                    break
                end
            end
        end)
    end

    lib.notify({
        title = 'Isolated Scene',
        description = 'You have entered an isolated instance',
        type = 'info'
    })
end)

RegisterNetEvent('nexus:client:exitIsolatedScene', function(data)
    currentScene = nil

    -- Restore original weather/time
    if originalWeather then
        SetWeatherTypeNowPersist(originalWeather)
        originalWeather = nil
    end

    if originalTime then
        NetworkOverrideClockTime(originalTime[1], originalTime[2], 0)
        originalTime = nil
    end

    ClearOverrideWeather()
    ClearWeatherTypePersist()

    lib.notify({
        title = 'Isolated Scene',
        description = 'You have returned to the main world',
        type = 'info'
    })
end)

RegisterNetEvent('nexus:client:setSceneWeather', function(data)
    if currentScene then
        SetWeatherTypeNowPersist(data.weather)
    end
end)

RegisterNetEvent('nexus:client:setSceneTime', function(data)
    if currentScene then
        NetworkOverrideClockTime(data.hour, data.minute or 0, 0)
    end
end)

-- ============================================
-- HANDOFF POINTS
-- ============================================

local activeHandoffs = {}

RegisterNetEvent('nexus:client:handoffDropLocation', function(data)
    local coords = vector3(data.coords.x, data.coords.y, data.coords.z)

    -- Create blip for drop location
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 501) -- Dead drop icon
    SetBlipColour(blip, 5) -- Yellow
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Dead Drop')
    EndTextCommandSetBlipName(blip)

    activeHandoffs[data.handoffId] = {
        blip = blip,
        coords = coords,
        item = data.item,
        type = 'drop'
    }

    -- Create target zone
    exports.ox_target:addSphereZone({
        coords = coords,
        radius = 2.0,
        options = {{
            name = 'handoff_drop_' .. data.handoffId,
            label = 'Drop ' .. data.item,
            icon = 'fas fa-box',
            onSelect = function()
                -- Check if player has item
                local hasItem = exports.ox_inventory:Search('count', data.item) > 0
                if hasItem then
                    exports.ox_inventory:RemoveItem(data.item, 1)
                    TriggerServerEvent('nexus:server:handoffDropped', data.handoffId)

                    -- Remove blip and zone
                    if activeHandoffs[data.handoffId] then
                        RemoveBlip(activeHandoffs[data.handoffId].blip)
                        exports.ox_target:removeZone('handoff_drop_' .. data.handoffId)
                        activeHandoffs[data.handoffId] = nil
                    end

                    lib.notify({ title = 'Dead Drop', description = 'Item dropped successfully', type = 'success' })
                else
                    lib.notify({ title = 'Dead Drop', description = 'You don\'t have the item', type = 'error' })
                end
            end
        }}
    })

    lib.notify({
        title = 'Dead Drop Location',
        description = 'Drop location marked on map',
        type = 'info'
    })
end)

RegisterNetEvent('nexus:client:handoffPickupAvailable', function(data)
    local coords = vector3(data.coords.x, data.coords.y, data.coords.z)

    -- Create blip for pickup location
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 501)
    SetBlipColour(blip, 2) -- Green
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Pickup Location')
    EndTextCommandSetBlipName(blip)

    activeHandoffs[data.handoffId] = {
        blip = blip,
        coords = coords,
        item = data.item,
        type = 'pickup'
    }

    -- Create target zone
    exports.ox_target:addSphereZone({
        coords = coords,
        radius = 2.0,
        options = {{
            name = 'handoff_pickup_' .. data.handoffId,
            label = 'Pickup ' .. data.item,
            icon = 'fas fa-hand-holding',
            onSelect = function()
                TriggerServerEvent('nexus:server:handoffPickedUp', data.handoffId)

                -- Remove blip and zone
                if activeHandoffs[data.handoffId] then
                    RemoveBlip(activeHandoffs[data.handoffId].blip)
                    exports.ox_target:removeZone('handoff_pickup_' .. data.handoffId)
                    activeHandoffs[data.handoffId] = nil
                end

                lib.notify({ title = 'Pickup', description = 'Item collected', type = 'success' })
            end
        }}
    })

    lib.notify({
        title = 'Package Available',
        description = 'A package is waiting for pickup',
        type = 'info'
    })
end)

-- ============================================
-- ADVERSARIAL MISSIONS
-- ============================================

RegisterNetEvent('nexus:client:adversarialMissionStart', function(data)
    lib.notify({
        title = 'Mission Started',
        description = data.objective,
        type = 'info',
        duration = 10000
    })

    -- Mark shared target if applicable
    if data.target then
        if data.target.type == 'vehicle' then
            -- Will need vehicle tracking
        elseif data.target.type == 'coords' then
            local coords = data.target.value
            SetNewWaypoint(coords.x, coords.y)
        end
    end

    -- Show opponent info if revealed
    if data.opponentRevealed and data.opponentCitizenId then
        lib.notify({
            title = 'Warning',
            description = 'Another player is working against you',
            type = 'warning',
            duration = 5000
        })
    end
end)

-- ============================================
-- MISSION TIMERS
-- ============================================

local missionTimers = {}

RegisterNetEvent('nexus:client:missionTimerStart', function(data)
    local missionId = data.missionId
    local duration = data.duration

    missionTimers[missionId] = {
        endTime = GetGameTimer() + (duration * 1000),
        duration = duration
    }

    -- Create timer display thread
    CreateThread(function()
        while missionTimers[missionId] do
            Wait(1000)

            local remaining = (missionTimers[missionId].endTime - GetGameTimer()) / 1000
            if remaining <= 0 then
                missionTimers[missionId] = nil
                lib.notify({ title = 'Time Expired', description = 'Mission timer has ended', type = 'error' })
                break
            end

            -- Display timer (using lib.showTextUI or similar)
            local minutes = math.floor(remaining / 60)
            local seconds = math.floor(remaining % 60)
            lib.showTextUI(string.format('Time: %02d:%02d', minutes, seconds), { position = 'top-center' })
        end
        lib.hideTextUI()
    end)
end)

RegisterNetEvent('nexus:client:missionTimerCancel', function(data)
    missionTimers[data.missionId] = nil
    lib.hideTextUI()
end)

-- ============================================
-- PLACEMENT REQUESTS (Admin)
-- ============================================

RegisterNetEvent('nexus:client:newPlacementRequest', function(data)
    lib.notify({
        title = 'New Placement Request',
        description = data.requirements,
        type = 'info',
        duration = 10000
    })
end)
