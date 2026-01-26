-- Client-side entity spawning and verification

local Spawning = {}

-- Entity pools for reuse
local EntityPool = {
    npcs = {},
    vehicles = {},
    props = {}
}

-- Raycast cooldown
local LastRaycastTime = 0

-- Optimized raycast with cooldown
function Spawning.Raycast(startPos, endPos, flags)
    local now = GetGameTimer()
    if (now - LastRaycastTime) < Config.Performance.RaycastCooldownMs then
        return nil
    end
    LastRaycastTime = now

    local ray = StartShapeTestRay(
        startPos.x, startPos.y, startPos.z,
        endPos.x, endPos.y, endPos.z,
        flags or -1, PlayerPedId(), 7
    )

    return GetShapeTestResult(ray)
end

-- Verify spawn location
function Spawning.VerifyLocation(coords, radius, entityType)
    radius = radius or Config.Spawning.MinClearance

    -- Check ground level
    local groundZ = ClientUtils.GetGroundZ(coords)
    local adjustedCoords = vector3(coords.x, coords.y, groundZ + 1.0)

    -- Check if area is clear
    local isClear = ClientUtils.IsPositionClear(adjustedCoords, radius)

    -- For vehicles, check road validity
    if entityType == 'vehicle' then
        local isRoad = IsPointOnRoad(adjustedCoords.x, adjustedCoords.y, adjustedCoords.z, nil)
        if not isRoad then
            -- Try to find nearest road
            local success, roadX, roadY, roadZ = GetClosestVehicleNodeWithHeading(
                adjustedCoords.x, adjustedCoords.y, adjustedCoords.z, 1, 3.0, 0
            )
            if success then
                adjustedCoords = vector3(roadX, roadY, roadZ)
            end
        end
    end

    return {
        valid = isClear,
        adjustedCoords = adjustedCoords,
        reason = isClear and 'Clear' or 'Obstructed'
    }
end

-- Get pooled entity if available
local function GetPooledEntity(type, model)
    local pool = EntityPool[type]
    if not pool then return nil end

    local modelHash = type(model) == 'string' and joaat(model) or model

    for i, entity in ipairs(pool) do
        if DoesEntityExist(entity) and GetEntityModel(entity) == modelHash then
            table.remove(pool, i)
            SetEntityVisible(entity, true, false)
            FreezeEntityPosition(entity, false)
            return entity
        end
    end

    return nil
end

-- Return entity to pool
local function ReturnToPool(entityType, entity)
    if not DoesEntityExist(entity) then return end

    local pool = EntityPool[entityType]
    if not pool then return end

    if #pool >= Config.Performance.EntityPoolSize then
        -- Pool full, delete oldest
        local oldest = table.remove(pool, 1)
        if DoesEntityExist(oldest) then
            DeleteEntity(oldest)
        end
    end

    SetEntityVisible(entity, false, false)
    FreezeEntityPosition(entity, true)
    SetEntityCoords(entity, 0, 0, -100) -- Move out of way
    table.insert(pool, entity)
end

-- Spawn NPC with safety checks
function Spawning.SpawnNpc(data)
    local model = data.model or Constants.DefaultModels.NPC
    local coords = data.coords
    local heading = data.heading or 0
    local networked = data.networked ~= false

    -- Verify location
    local verification = Spawning.VerifyLocation(coords, 1.5, 'npc')
    if not verification.valid then
        -- Try adjusted coords
        coords = verification.adjustedCoords
        verification = Spawning.VerifyLocation(coords, 1.5, 'npc')
    end

    -- Check for pooled entity
    local entity = GetPooledEntity('npcs', model)

    if not entity then
        -- Request model
        if not ClientUtils.RequestModel(model) then
            return {success = false, error = 'Failed to load model: ' .. model}
        end

        -- Create ped
        entity = CreatePed(4, joaat(model), coords.x, coords.y, coords.z, heading, networked, true)
        SetModelAsNoLongerNeeded(joaat(model))
    else
        SetEntityCoords(entity, coords.x, coords.y, coords.z)
        SetEntityHeading(entity, heading)
    end

    if not DoesEntityExist(entity) then
        return {success = false, error = 'Failed to create NPC'}
    end

    -- Configure NPC behavior
    SetBlockingOfNonTemporaryEvents(entity, true)
    SetPedFleeAttributes(entity, 0, false)

    if data.behavior == Constants.NpcBehavior.HOSTILE then
        SetPedCombatAttributes(entity, 46, true)
        SetPedCombatAbility(entity, 100)

        -- Give weapons if specified
        if data.weapons then
            for _, weapon in ipairs(data.weapons) do
                GiveWeaponToPed(entity, joaat(weapon), 255, false, true)
            end
        end
    elseif data.behavior == Constants.NpcBehavior.GUARD then
        TaskGuardCurrentPosition(entity, 15.0, 10.0, true)
    elseif data.behavior == Constants.NpcBehavior.WANDER then
        TaskWanderStandard(entity, 10.0, 10)
    elseif data.behavior == Constants.NpcBehavior.COWER then
        TaskReactAndFleePed(entity, PlayerPedId())
    end

    local netId = networked and NetworkGetNetworkIdFromEntity(entity) or nil

    ClientUtils.Debug('Spawned NPC:', model, 'netId:', netId)

    return {
        success = true,
        entity = entity,
        netId = netId,
        coords = GetEntityCoords(entity),
        adjusted = coords ~= data.coords
    }
end

-- Spawn vehicle with safety checks
function Spawning.SpawnVehicle(data)
    local model = data.model or Constants.DefaultModels.VEHICLE
    local coords = data.coords
    local heading = data.heading or 0
    local networked = data.networked ~= false

    -- Verify location for vehicle
    local verification = Spawning.VerifyLocation(coords, 5.0, 'vehicle')
    coords = verification.adjustedCoords

    -- Check for pooled entity
    local entity = GetPooledEntity('vehicles', model)

    if not entity then
        if not ClientUtils.RequestModel(model) then
            return {success = false, error = 'Failed to load model: ' .. model}
        end

        entity = CreateVehicle(joaat(model), coords.x, coords.y, coords.z, heading, networked, true)
        SetModelAsNoLongerNeeded(joaat(model))
    else
        SetEntityCoords(entity, coords.x, coords.y, coords.z)
        SetEntityHeading(entity, heading)
    end

    if not DoesEntityExist(entity) then
        return {success = false, error = 'Failed to create vehicle'}
    end

    -- Configure vehicle
    if data.locked then
        SetVehicleDoorsLocked(entity, 2)
    end

    if data.fuel then
        -- ox_fuel integration if available
        if GetResourceState('ox_fuel') == 'started' then
            exports.ox_fuel:SetFuel(entity, data.fuel)
        end
    end

    if data.color then
        if data.color.primary then
            SetVehicleColours(entity, data.color.primary, data.color.secondary or data.color.primary)
        end
    end

    local plate = GetVehicleNumberPlateText(entity)
    local netId = networked and NetworkGetNetworkIdFromEntity(entity) or nil

    ClientUtils.Debug('Spawned vehicle:', model, 'plate:', plate)

    return {
        success = true,
        entity = entity,
        netId = netId,
        coords = GetEntityCoords(entity),
        plate = plate
    }
end

-- Spawn prop with safety checks
function Spawning.SpawnProp(data)
    local model = data.model or Constants.DefaultModels.PROP
    local coords = data.coords
    local heading = data.heading or 0

    -- Verify location
    local verification = Spawning.VerifyLocation(coords, 1.0, 'prop')
    coords = verification.adjustedCoords

    if not ClientUtils.RequestModel(model) then
        return {success = false, error = 'Failed to load model: ' .. model}
    end

    local entity = CreateObject(joaat(model), coords.x, coords.y, coords.z, true, true, false)
    SetModelAsNoLongerNeeded(joaat(model))

    if not DoesEntityExist(entity) then
        return {success = false, error = 'Failed to create prop'}
    end

    SetEntityHeading(entity, heading)

    if data.frozen ~= false then
        FreezeEntityPosition(entity, true)
    end

    local netId = NetworkGetNetworkIdFromEntity(entity)

    ClientUtils.Debug('Spawned prop:', model, 'netId:', netId)

    return {
        success = true,
        entity = entity,
        netId = netId,
        coords = GetEntityCoords(entity)
    }
end

-- Cleanup entity
function Spawning.Cleanup(entity, entityType)
    if not DoesEntityExist(entity) then return end

    if entityType and Config.Performance.EntityPoolSize > 0 then
        ReturnToPool(entityType, entity)
    else
        DeleteEntity(entity)
    end
end

-- Server callbacks for spawning
lib.callback.register('nexus:spawnNpc', function(data)
    return Spawning.SpawnNpc(data)
end)

lib.callback.register('nexus:spawnVehicle', function(data)
    return Spawning.SpawnVehicle(data)
end)

lib.callback.register('nexus:spawnProp', function(data)
    return Spawning.SpawnProp(data)
end)

lib.callback.register('nexus:verifyZone', function(data)
    return Spawning.VerifyLocation(data.coords, data.radius, data.type)
end)

-- Event handler for spawn verification request
RegisterNetEvent('nexus:client:verifySpawnLocation', function(data)
    local result = Spawning.VerifyLocation(data.coords, data.radius, data.type)
    TriggerServerEvent('nexus:verifySpawn:' .. data.callbackId, result)
end)

return Spawning
