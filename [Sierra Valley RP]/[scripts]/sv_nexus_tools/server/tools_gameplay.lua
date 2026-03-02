-- Gameplay Tool Handlers (Direct Game Manipulation)

-- ============================================
-- EXPLOSION TOOLS
-- ============================================

-- Explosion type mapping
local ExplosionTypes = {
    GRENADE = 0,
    GRENADELAUNCHER = 1,
    STICKYBOMB = 2,
    MOLOTOV = 3,
    ROCKET = 4,
    TANKSHELL = 5,
    HI_OCTANE = 6,
    CAR = 7,
    PLANE = 8,
    PETROL_PUMP = 9,
    BIKE = 10,
    TRUCK = 17,
    BULLET = 18,
    SMOKEGRENADE = 20,
    FLARE = 22,
    BARREL = 27,
    PROPANE = 28,
    FIREWORK = 35
}

RegisterTool('trigger_explosion', {
    params = {'coords', 'type', 'damage_scale', 'is_audible', 'is_visible', 'no_damage'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local explosionType = ExplosionTypes[string.upper(params.type or 'GRENADE')] or 0
        local damageScale = math.max(0.1, math.min(2.0, params.damage_scale or 1.0))
        local isAudible = params.is_audible ~= false
        local isVisible = params.is_visible ~= false
        local noDamage = params.no_damage or false

        -- Trigger explosion on all clients
        TriggerClientEvent('nexus:client:triggerExplosion', -1, {
            coords = coords,
            explosionType = explosionType,
            damageScale = damageScale,
            isAudible = isAudible,
            isVisible = isVisible,
            noDamage = noDamage
        })

        Utils.Debug('Triggered explosion at', coords, 'type:', explosionType)
        return {success = true}
    end
})

-- ============================================
-- WANTED LEVEL
-- ============================================

RegisterTool('set_wanted_level', {
    params = {'source', 'level', 'flash'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local targetSource = params.source
        local level = math.max(0, math.min(5, params.level or 0))
        local flash = params.flash ~= false

        TriggerClientEvent('nexus:client:setWantedLevel', targetSource, {
            level = level,
            flash = flash
        })

        Utils.Debug('Set wanted level', level, 'for player', targetSource)
        return {success = true, level = level}
    end
})

-- ============================================
-- SCREEN EFFECTS
-- ============================================

-- Screen effect mapping
local ScreenEffects = {
    DRUG_DRIVING = 'DrugsDrivingIn',
    DRUG_MICHAEL = 'DrugsMichaelAliensFightIn',
    DRUG_TREVOR = 'DrugsTrevorClownsFightIn',
    DRUNK = 'DrunkVision',
    FOCUS = 'FocusIn',
    MINDCONTROL = 'MindControlSceneIn',
    RACETURBO = 'RaceTurbo',
    RAMPAGE = 'Rampage',
    DAMAGE = 'Damage',
    DEATH_FAIL = 'DeathFailMPIn',
    DONT_TAZE = 'DontTazeMe',
    MP_CORONA = 'MP_corona_switch',
    NIGHT_VISION = 'NightVision',
    SPECTATOR1 = 'spectator1',
    SPECTATOR2 = 'spectator2',
    SPECTATOR3 = 'spectator3'
}

RegisterTool('screen_effect', {
    params = {'source', 'effect', 'duration', 'looped'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local targetSource = params.source
        local effectName = ScreenEffects[string.upper(params.effect or '')] or params.effect
        local duration = params.duration or 5000
        local looped = params.looped or false

        TriggerClientEvent('nexus:client:screenEffect', targetSource, {
            effect = effectName,
            duration = duration,
            looped = looped
        })

        return {success = true}
    end
})

RegisterTool('stop_screen_effect', {
    params = {'source', 'effect'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local targetSource = params.source
        local effectName = ScreenEffects[string.upper(params.effect or '')] or params.effect

        TriggerClientEvent('nexus:client:stopScreenEffect', targetSource, {
            effect = effectName
        })

        return {success = true}
    end
})

-- ============================================
-- AUDIO EFFECTS
-- ============================================

RegisterTool('distant_sirens', {
    params = {'source', 'duration', 'intensity'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local targetSource = params.source
        local duration = params.duration or 30000
        local intensity = params.intensity or 'medium'

        TriggerClientEvent('nexus:client:distantSirens', targetSource, {
            duration = duration,
            intensity = intensity
        })

        return {success = true}
    end
})

-- ============================================
-- VEHICLE CHASE/FLEE
-- ============================================

RegisterTool('start_vehicle_chase', {
    params = {'vehicle_net_id', 'target_source', 'mode', 'driving_style'},
    category = Constants.ToolCategory.GAMEPLAY,
    async = true,
    handler = function(params, source)
        local vehicleNetId = params.vehicle_net_id
        local targetSource = params.target_source
        local mode = params.mode or 'chase'
        local drivingStyle = params.driving_style or 'aggressive'

        -- Map driving style to flags
        local drivingFlags = {
            normal = 786603,
            aggressive = 786468,
            reckless = 1076
        }

        TriggerClientEvent('nexus:client:startVehicleChase', -1, {
            vehicleNetId = vehicleNetId,
            targetSource = targetSource,
            mode = mode,
            drivingFlags = drivingFlags[drivingStyle] or drivingFlags.aggressive
        })

        return {success = true}
    end
})

-- ============================================
-- FLEE AREA
-- ============================================

RegisterTool('flee_area', {
    params = {'coords', 'radius', 'include_ambient'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or 50.0
        local includeAmbient = params.include_ambient or false

        TriggerClientEvent('nexus:client:fleeArea', -1, {
            coords = coords,
            radius = radius,
            includeAmbient = includeAmbient
        })

        return {success = true, affected_count = -1} -- Count determined client-side
    end
})

-- ============================================
-- DISABLE VEHICLE
-- ============================================

RegisterTool('disable_vehicle', {
    params = {'vehicle_net_id', 'disable_type', 'repairable'},
    category = Constants.ToolCategory.GAMEPLAY,
    handler = function(params)
        local vehicleNetId = params.vehicle_net_id
        local disableType = params.disable_type or 'engine'
        local repairable = params.repairable ~= false

        TriggerClientEvent('nexus:client:disableVehicle', -1, {
            vehicleNetId = vehicleNetId,
            disableType = disableType,
            repairable = repairable
        })

        return {success = true}
    end
})

-- ============================================
-- ISOLATED SCENES (Routing Buckets)
-- ============================================

-- Track active isolated scenes
local IsolatedScenes = {}

RegisterTool('create_isolated_scene', {
    params = {'sources', 'scene_id', 'weather', 'hour', 'exit_coords', 'exit_radius'},
    category = Constants.ToolCategory.WORLD,
    handler = function(params, source)
        local sources = params.sources
        local sceneId = params.scene_id
        local weather = params.weather
        local hour = params.hour
        local exitCoords = params.exit_coords and Utils.Vec3FromTable(params.exit_coords)
        local exitRadius = params.exit_radius or 50.0

        if not sources or #sources == 0 then
            return {success = false, error = 'No players specified'}
        end

        -- Generate unique bucket ID (high number to avoid conflicts)
        local bucketId = 1000 + math.random(1, 9000)
        while IsolatedScenes[bucketId] do
            bucketId = 1000 + math.random(1, 9000)
        end

        -- Store scene data
        IsolatedScenes[sceneId] = {
            bucket_id = bucketId,
            sources = sources,
            weather = weather,
            hour = hour,
            exit_coords = exitCoords,
            exit_radius = exitRadius,
            original_buckets = {}
        }

        -- Move players to isolated bucket
        for _, playerSource in ipairs(sources) do
            -- Store original bucket
            IsolatedScenes[sceneId].original_buckets[playerSource] = GetPlayerRoutingBucket(playerSource)

            -- Move to isolated bucket
            SetPlayerRoutingBucket(playerSource, bucketId)

            -- Set weather/time for player
            TriggerClientEvent('nexus:client:enterIsolatedScene', playerSource, {
                sceneId = sceneId,
                weather = weather,
                hour = hour,
                exitCoords = exitCoords,
                exitRadius = exitRadius
            })

            Utils.Debug('Moved player', playerSource, 'to isolated bucket', bucketId)
        end

        -- Store in database
        MySQL.insert.await([[
            INSERT INTO nexus_isolated_scenes
            (id, scene_id, bucket_id, weather, hour, exit_coords, exit_radius, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'active')
        ]], {
            Utils.GenerateUUID(),
            sceneId,
            bucketId,
            weather,
            hour,
            exitCoords and json.encode({x = exitCoords.x, y = exitCoords.y, z = exitCoords.z}),
            exitRadius
        })

        Utils.Success('Created isolated scene:', sceneId, 'bucket:', bucketId)
        return {success = true, bucket_id = bucketId}
    end
})

RegisterTool('end_isolated_scene', {
    params = {'sources', 'scene_id'},
    category = Constants.ToolCategory.WORLD,
    handler = function(params)
        local sources = params.sources
        local sceneId = params.scene_id

        local scene = IsolatedScenes[sceneId]
        if not scene then
            return {success = false, error = 'Scene not found: ' .. tostring(sceneId)}
        end

        -- Return players to original buckets
        for _, playerSource in ipairs(sources) do
            local originalBucket = scene.original_buckets[playerSource] or 0
            SetPlayerRoutingBucket(playerSource, originalBucket)

            TriggerClientEvent('nexus:client:exitIsolatedScene', playerSource, {
                sceneId = sceneId
            })

            Utils.Debug('Returned player', playerSource, 'to bucket', originalBucket)
        end

        -- Update database
        MySQL.update.await([[
            UPDATE nexus_isolated_scenes
            SET status = 'ended', ended_at = NOW()
            WHERE scene_id = ?
        ]], {sceneId})

        -- Cleanup memory
        IsolatedScenes[sceneId] = nil

        Utils.Success('Ended isolated scene:', sceneId)
        return {success = true}
    end
})

RegisterTool('set_scene_weather', {
    params = {'scene_id', 'weather'},
    category = Constants.ToolCategory.WORLD,
    handler = function(params)
        local sceneId = params.scene_id
        local weather = params.weather

        local scene = IsolatedScenes[sceneId]
        if not scene then
            return {success = false, error = 'Scene not found'}
        end

        scene.weather = weather

        for _, playerSource in ipairs(scene.sources) do
            TriggerClientEvent('nexus:client:setSceneWeather', playerSource, {
                weather = weather
            })
        end

        return {success = true}
    end
})

RegisterTool('set_scene_time', {
    params = {'scene_id', 'hour', 'minute'},
    category = Constants.ToolCategory.WORLD,
    handler = function(params)
        local sceneId = params.scene_id
        local hour = params.hour
        local minute = params.minute or 0

        local scene = IsolatedScenes[sceneId]
        if not scene then
            return {success = false, error = 'Scene not found'}
        end

        scene.hour = hour

        for _, playerSource in ipairs(scene.sources) do
            TriggerClientEvent('nexus:client:setSceneTime', playerSource, {
                hour = hour,
                minute = minute
            })
        end

        return {success = true}
    end
})

-- Auto-exit check when player reaches exit coords
RegisterNetEvent('nexus:server:checkSceneExit', function(sceneId)
    local src = source
    local scene = IsolatedScenes[sceneId]
    if scene and scene.exit_coords then
        -- Return this player to main world
        local originalBucket = scene.original_buckets[src] or 0
        SetPlayerRoutingBucket(src, originalBucket)

        TriggerClientEvent('nexus:client:exitIsolatedScene', src, {
            sceneId = sceneId
        })

        -- Remove from scene sources
        for i, playerSource in ipairs(scene.sources) do
            if playerSource == src then
                table.remove(scene.sources, i)
                break
            end
        end

        -- If no players left, cleanup scene
        if #scene.sources == 0 then
            MySQL.update.await([[
                UPDATE nexus_isolated_scenes
                SET status = 'ended', ended_at = NOW()
                WHERE scene_id = ?
            ]], {sceneId})
            IsolatedScenes[sceneId] = nil
        end
    end
end)

Utils.Success('Registered gameplay tools')
