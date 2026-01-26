-- Server-side spawn verification and management

local Spawning = {}

-- Safe zone pools loaded from data file
local SafeZones = {}

-- Entity ownership tracking
local EntityOwnership = {}

-- Load safe zones from JSON
local function LoadSafeZones()
    local data = LoadResourceFile(GetCurrentResourceName(), 'data/safe_zones.json')
    if data then
        SafeZones = Utils.JsonDecode(data) or {}
        Utils.Debug('Loaded', Utils.TableSize(SafeZones), 'safe zone themes')
    else
        Utils.Debug('No safe zones file found, using empty pools')
    end
end

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadSafeZones()
    end
end)

-- Track entity ownership
function Spawning.TrackEntity(netId, source, missionId)
    EntityOwnership[netId] = {
        source = source,
        missionId = missionId,
        createdAt = os.time()
    }
end

-- Get entity owner
function Spawning.GetEntityOwner(netId)
    return EntityOwnership[netId]
end

-- Cleanup entity tracking
function Spawning.CleanupEntity(netId)
    EntityOwnership[netId] = nil
end

-- Get safe coordinates by theme
function Spawning.GetSafeCoords(theme, nearCoords, radius)
    local pool = SafeZones[theme]
    if not pool or #pool == 0 then
        Utils.Debug('No safe zones for theme:', theme)
        return nil
    end

    -- If nearCoords provided, find closest
    if nearCoords then
        local coords = Utils.Vec3FromTable(nearCoords)
        local closest = nil
        local closestDist = math.huge

        for _, zone in ipairs(pool) do
            local zoneCoords = Utils.Vec3FromTable(zone.coords)
            local dist = #(coords - zoneCoords)
            if dist < closestDist and (not radius or dist <= radius) then
                closestDist = dist
                closest = zone
            end
        end

        if closest then
            return Utils.Vec3FromTable(closest.coords), closest.heading or 0
        end
    end

    -- Random from pool
    local zone = pool[math.random(#pool)]
    return Utils.Vec3FromTable(zone.coords), zone.heading or 0
end

-- Verify spawn location via client raycast
function Spawning.VerifySpawnLocation(source, coords, radius, entityType, callback)
    local callbackId = Utils.GenerateUUID()

    -- Register one-time callback
    lib.callback.register('nexus:verifySpawn:' .. callbackId, function(src, result)
        -- Unregister immediately
        lib.callback.register('nexus:verifySpawn:' .. callbackId, nil)
        callback(result)
        return true
    end)

    -- Request client verification
    TriggerClientEvent('nexus:client:verifySpawnLocation', source, {
        callbackId = callbackId,
        coords = coords,
        radius = radius or Config.Spawning.MinClearance,
        type = entityType or 'any'
    })

    -- Timeout fallback
    SetTimeout(5000, function()
        lib.callback.register('nexus:verifySpawn:' .. callbackId, nil)
    end)
end

-- Register spawn tools
RegisterTool('safe_spawn_npc', {
    params = {'model', 'coords', 'heading', 'behavior', 'dialog', 'networked'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local heading = params.heading or 0
        local model = params.model or Constants.DefaultModels.NPC
        local networked = params.networked ~= false

        -- Request client to spawn and verify
        local result = lib.callback.await('nexus:spawnNpc', source, {
            model = model,
            coords = coords,
            heading = heading,
            behavior = params.behavior or Constants.NpcBehavior.IDLE,
            dialog = params.dialog,
            networked = networked
        })

        if result and result.success then
            if result.netId then
                Spawning.TrackEntity(result.netId, source, params.missionId)
            end
            return {
                success = true,
                netId = result.netId,
                coords = result.coords,
                adjusted = result.adjusted or false
            }
        end

        return {success = false, error = result and result.error or 'Spawn failed'}
    end
})

RegisterTool('safe_spawn_vehicle', {
    params = {'model', 'coords', 'heading', 'locked', 'fuel', 'color', 'networked'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local heading = params.heading or 0
        local model = params.model or Constants.DefaultModels.VEHICLE
        local networked = params.networked ~= false

        local result = lib.callback.await('nexus:spawnVehicle', source, {
            model = model,
            coords = coords,
            heading = heading,
            locked = params.locked or false,
            fuel = params.fuel or 100,
            color = params.color,
            networked = networked
        })

        if result and result.success then
            if result.netId then
                Spawning.TrackEntity(result.netId, source, params.missionId)
            end
            return {
                success = true,
                netId = result.netId,
                coords = result.coords,
                plate = result.plate
            }
        end

        return {success = false, error = result and result.error or 'Spawn failed'}
    end
})

RegisterTool('safe_spawn_prop', {
    params = {'model', 'coords', 'heading', 'interactive', 'frozen'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local heading = params.heading or 0
        local model = params.model or Constants.DefaultModels.PROP

        local result = lib.callback.await('nexus:spawnProp', source, {
            model = model,
            coords = coords,
            heading = heading,
            interactive = params.interactive or false,
            frozen = params.frozen ~= false
        })

        if result and result.success then
            if result.netId then
                Spawning.TrackEntity(result.netId, source, params.missionId)
            end
            return {
                success = true,
                netId = result.netId,
                coords = result.coords
            }
        end

        return {success = false, error = result and result.error or 'Spawn failed'}
    end
})

RegisterTool('verify_spawn_zone', {
    params = {'coords', 'radius', 'type'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or Config.Spawning.MinClearance
        local entityType = params.type or 'any'

        local result = lib.callback.await('nexus:verifyZone', source, {
            coords = coords,
            radius = radius,
            type = entityType
        })

        return {
            valid = result and result.valid or false,
            adjustedCoords = result and result.adjustedCoords,
            reason = result and result.reason or 'Verification failed'
        }
    end
})

RegisterTool('get_safe_coords', {
    params = {'theme', 'nearCoords', 'radius'},
    handler = function(params)
        local coords, heading = Spawning.GetSafeCoords(
            params.theme,
            params.nearCoords,
            params.radius
        )

        if coords then
            return {
                success = true,
                coords = coords,
                heading = heading,
                theme = params.theme
            }
        end

        return {success = false, error = 'No safe coords found for theme'}
    end
})

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    local toCleanup = {}

    for netId, data in pairs(EntityOwnership) do
        if data.source == src then
            toCleanup[#toCleanup + 1] = netId
        end
    end

    -- Schedule cleanup (delay to allow mission transfer)
    if #toCleanup > 0 then
        SetTimeout(30000, function()
            for _, netId in ipairs(toCleanup) do
                if EntityOwnership[netId] then
                    -- Check if entity still exists
                    local entity = NetworkGetEntityFromNetworkId(netId)
                    if DoesEntityExist(entity) then
                        DeleteEntity(entity)
                    end
                    EntityOwnership[netId] = nil
                end
            end
            Utils.Debug('Cleaned up', #toCleanup, 'entities from disconnected player')
        end)
    end
end)

-- Exports
exports('TrackEntity', Spawning.TrackEntity)
exports('GetEntityOwner', Spawning.GetEntityOwner)
exports('CleanupEntity', Spawning.CleanupEntity)
exports('GetSafeCoords', Spawning.GetSafeCoords)

return Spawning
