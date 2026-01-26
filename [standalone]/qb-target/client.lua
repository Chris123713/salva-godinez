-- qb-target to ox_target direct compatibility
-- This resource provides qb-target exports that directly call ox_target

print("^2[qb-target] ^7Direct compatibility layer loaded - integrating with ox_target")

-- Debug logging
local function debugLog(message)
    if GetConvar('qb_target_debug', 'false') == 'true' then
        print("^3[qb-target] ^7" .. message)
    end
end

-- Convert qb-target options to ox_target format
local function convertQBToOx(options)
    local oxOptions = {}
    
    if options then
        for i, option in ipairs(options) do
            oxOptions[i] = {
                name = option.name or 'option_' .. i,
                icon = option.icon or 'fas fa-hand',
                label = option.label or 'Interact',
                onSelect = option.action,
                canInteract = option.canInteract,
                distance = option.distance or 2.0
            }
        end
    end
    
    return oxOptions
end

-- AddTargetEntity export
exports('AddTargetEntity', function(entity, options)
    debugLog("AddTargetEntity called")
    
    -- Validate entity parameter
    if not entity or type(entity) ~= 'number' or entity == 0 then
        debugLog("Warning: Invalid entity provided to AddTargetEntity (entity: " .. tostring(entity) .. ", type: " .. type(entity) .. ")")
        return
    end
    
    -- Wait a frame to ensure entity is properly loaded
    CreateThread(function()
        Wait(0)
        
        -- Additional validation before calling DoesEntityExist
        if type(entity) ~= 'number' or entity <= 0 then
            debugLog("Warning: Invalid entity type or value before DoesEntityExist check")
            return
        end
        
        if not DoesEntityExist(entity) then
            debugLog("Warning: Entity does not exist in AddTargetEntity")
            return
        end
        
        local entityOptions = options or {}
        local oxOptions = convertQBToOx(entityOptions.options or {})
        
        if #oxOptions == 0 then
            debugLog("Warning: No valid options found for AddTargetEntity")
            return
        end
        
        -- ox_target addEntity expects a flat array of options, not a hash table
        for _, opt in ipairs(oxOptions) do
            opt.distance = opt.distance or entityOptions.distance or 2.0
        end
        exports.ox_target:addEntity(entity, oxOptions)
    end)
end)

-- RemoveTargetEntity export
exports('RemoveTargetEntity', function(entity)
    debugLog("RemoveTargetEntity called")
    
    -- Validate entity before calling DoesEntityExist
    if not entity or type(entity) ~= 'number' or entity <= 0 then
        debugLog("Warning: Invalid entity provided to RemoveTargetEntity")
        return
    end
    
    if not DoesEntityExist(entity) then 
        debugLog("Warning: Entity does not exist in RemoveTargetEntity")
        return 
    end
    
    exports.ox_target:removeEntity(entity)
end)

-- AddBoxZone export
exports('AddBoxZone', function(name, coords, length, width, options, targetOptions)
    debugLog("AddBoxZone called for: " .. tostring(name))
    
    -- Validate required parameters
    if not name then
        debugLog("Warning: No name provided for AddBoxZone")
        return
    end
    
    if not coords or type(coords) ~= 'vector3' then
        debugLog("Warning: Invalid coords provided for AddBoxZone: " .. tostring(name))
        return
    end
    
    -- Validate length and width parameters
    if not length or type(length) ~= 'number' then
        debugLog("Warning: Invalid length provided for AddBoxZone: " .. tostring(name) .. " (length: " .. tostring(length) .. ")")
        return
    end
    
    if not width or type(width) ~= 'number' then
        debugLog("Warning: Invalid width provided for AddBoxZone: " .. tostring(name) .. " (width: " .. tostring(width) .. ")")
        return
    end
    
    -- Handle different parameter formats
    local boxOptions = options or {}
    local boxTargetOptions = targetOptions or {}
    
    -- Ensure we have valid options
    if not boxTargetOptions.options and boxOptions.options then
        boxTargetOptions.options = boxOptions.options
    end
    
    local oxOptions = convertQBToOx(boxTargetOptions.options or {})
    
    if #oxOptions == 0 then
        debugLog("Warning: No valid options found for AddBoxZone: " .. tostring(name))
        return
    end
    
    -- Ensure height is a valid number
    local height = boxOptions.height or 2.0
    if type(height) ~= 'number' then
        debugLog("Warning: Invalid height for AddBoxZone: " .. tostring(name) .. ", using default")
        height = 2.0
    end
    
    exports.ox_target:addBoxZone({
        name = name,
        coords = coords,
        size = vector3(length, width, height),
        rotation = boxOptions.heading or 0,
        debug = boxOptions.debugPoly or false,
        options = oxOptions
    })
end)

-- RemoveZone export
exports('RemoveZone', function(name)
    debugLog("RemoveZone called for: " .. tostring(name))
    
    if not name then
        debugLog("Warning: No zone name provided for RemoveZone")
        return
    end
    
    -- Check if zone exists before trying to remove it to prevent warnings
    if exports.ox_target:zoneExists(name) then
        exports.ox_target:removeZone(name)
    else
        debugLog("Zone does not exist, skipping removal: " .. tostring(name))
    end
end)

-- AddEntityZone export
exports('AddEntityZone', function(name, entity, options, targetOptions)
    debugLog("AddEntityZone called for: " .. tostring(name))
    
    -- Validate entity before calling DoesEntityExist
    if not entity or type(entity) ~= 'number' or entity <= 0 then
        debugLog("Warning: Invalid entity provided to AddEntityZone")
        return
    end
    
    if not DoesEntityExist(entity) then 
        debugLog("Warning: Entity does not exist in AddEntityZone")
        return 
    end
    
    local oxOptions = convertQBToOx((targetOptions or {}).options or {})
    
    if #oxOptions == 0 then
        debugLog("Warning: No valid options found for AddEntityZone: " .. tostring(name))
        return
    end
    
    -- ox_target addEntity expects a flat array of options, not a hash table
    local entityDistance = (options or {}).distance or 2.0
    for _, opt in ipairs(oxOptions) do
        opt.distance = opt.distance or entityDistance
    end
    exports.ox_target:addEntity(entity, oxOptions)
end)

-- AddTargetModel export
exports('AddTargetModel', function(models, options)
    debugLog("AddTargetModel called")
    
    if not models then
        debugLog("Warning: No models provided for AddTargetModel")
        return
    end
    
    if type(models) ~= 'table' then
        models = {models}
    end
    
    local oxOptions = convertQBToOx((options or {}).options or {})
    
    if #oxOptions == 0 then
        debugLog("Warning: No valid options found for AddTargetModel")
        return
    end
    
    for _, model in ipairs(models) do
        exports.ox_target:addModel(model, oxOptions)
    end
end)

-- RemoveTargetModel export
exports('RemoveTargetModel', function(models)
    debugLog("RemoveTargetModel called")
    
    if not models then
        debugLog("Warning: No models provided for RemoveTargetModel")
        return
    end
    
    if type(models) ~= 'table' then
        models = {models}
    end
    
    for _, model in ipairs(models) do
        exports.ox_target:removeModel(model)
    end
end)

-- AddCircleZone export
exports('AddCircleZone', function(name, coords, radius, options, targetOptions)
    debugLog("AddCircleZone called for: " .. tostring(name))
    
    -- Validate parameters
    if not name then
        debugLog("Warning: No name provided for AddCircleZone")
        return
    end
    
    if not coords or type(coords) ~= 'vector3' then
        debugLog("Warning: Invalid coords provided for AddCircleZone: " .. tostring(name))
        return
    end
    
    if not radius or type(radius) ~= 'number' or radius <= 0 then
        debugLog("Warning: Invalid radius provided for AddCircleZone: " .. tostring(name))
        return
    end
    
    local circleOptions = options or {}
    local circleTargetOptions = targetOptions or {}
    
    if not circleTargetOptions.options and circleOptions.options then
        circleTargetOptions.options = circleOptions.options
    end
    
    local oxOptions = convertQBToOx(circleTargetOptions.options or {})
    
    if #oxOptions == 0 then
        debugLog("Warning: No valid options found for AddCircleZone: " .. tostring(name))
        return
    end
    
    exports.ox_target:addSphereZone({
        name = name,
        coords = coords,
        radius = radius,
        debug = circleOptions.debugPoly or false,
        options = oxOptions
    })
end)

-- AddPolyZone export
exports('AddPolyZone', function(name, points, options, targetOptions)
    debugLog("AddPolyZone called for: " .. tostring(name))
    
    -- Validate parameters
    if not name then
        debugLog("Warning: No name provided for AddPolyZone")
        return
    end
    
    if not points or type(points) ~= 'table' or #points < 3 then
        debugLog("Warning: Invalid points provided for AddPolyZone: " .. tostring(name))
        return
    end
    
    local polyOptions = options or {}
    local polyTargetOptions = targetOptions or {}
    
    if not polyTargetOptions.options and polyOptions.options then
        polyTargetOptions.options = polyOptions.options
    end
    
    local oxOptions = convertQBToOx(polyTargetOptions.options or {})
    
    if #oxOptions == 0 then
        debugLog("Warning: No valid options found for AddPolyZone: " .. tostring(name))
        return
    end
    
    exports.ox_target:addPolyZone({
        name = name,
        points = points,
        thickness = polyOptions.thickness or 2.0,
        debug = polyOptions.debugPoly or false,
        options = oxOptions
    })
end)

-- Legacy compatibility exports (these are often called but don't need to do anything with ox_target)
exports('RemoveGlobalPlayer', function(playerId)
    debugLog("RemoveGlobalPlayer called for player: " .. tostring(playerId))
    -- This functionality is handled differently in ox_target
    return true
end)

exports('AddGlobalPlayer', function(options)
    debugLog("AddGlobalPlayer called")
    -- This functionality is handled differently in ox_target
    return true
end)

-- SpawnPed export (utility function)
exports('SpawnPed', function(model, coords, freeze, invincible, scenario)
    debugLog("SpawnPed called with model: " .. tostring(model))
    
    if not model or not coords then
        debugLog("Warning: Invalid model or coords provided to SpawnPed")
        return nil
    end
    
    local pedHash = type(model) == 'string' and GetHashKey(model) or model
    
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Wait(10)
    end
    
    local ped = CreatePed(0, pedHash, coords.x, coords.y, coords.z, coords.w or 0.0, false, false)
    
    if freeze then
        FreezeEntityPosition(ped, true)
    end
    
    if invincible then
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end
    
    if scenario then
        TaskStartScenarioInPlace(ped, scenario, 0, true)
    end
    
    SetModelAsNoLongerNeeded(pedHash)
    return ped
end)

print("^2[qb-target] ^7Direct compatibility layer loaded successfully!")