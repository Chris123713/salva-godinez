func = {}

local function createCache(entity, data, invoker)
    bridge.target.cache[entity] = {
        hideSquare = data.hideSquare or false,
        checkVisibility = data.checkVisibility or false,
        showInVehicle = data.showInVehicle or false,
        distance = data.squareDistance or 5.0,
        distanceText = data.distance or 2.5,
        offset = data.offset or {
            text = {x = 0.0, y = 0.0, z = 1.0},
            target = {x = 0.0, y = 0.0, z = 0.0},
        },
        options = data.options,
    }

    exports["nn_interaction"]:addInteractionLocalEntity("pd_bridge:" .. invoker .. ":" .. entity, entity, bridge.target.cache[entity])
end

local function isOptionWithNameExist(tbl, name)
    for i, v in ipairs(tbl) do
        if v.name == name then
            return true, i
        end
    end

    return false, nil
end

local function updateCache(entity, data, invoker)
    local cache = bridge.target.cache[entity]

    cache.hideSquare = data.hideSquare ~= nil and data.hideSquare or cache.hideSquare
    cache.checkVisibility = data.checkVisibility ~= nil and data.checkVisibility or cache.checkVisibility
    cache.showInVehicle = data.showInVehicle ~= nil and data.showInVehicle or cache.showInVehicle
    cache.distance = data.distance ~= nil and data.distance or cache.distance
    cache.distanceText = data.distanceText ~= nil and data.distanceText or cache.distanceText
    cache.offset = data.offset ~= nil and data.offset or cache.offset

    for _, v in ipairs(data.options) do
        local optionExist, index = isOptionWithNameExist(cache.options, v.name)

        if not optionExist then
            table.insert(cache.options, v)
        else
            cache.options[index] = v
        end
    end

    exports["nn_interaction"]:addInteractionLocalEntity("pd_bridge:" .. invoker .. ":" .. entity, entity, bridge.target.cache[entity])
end

func.addEntity = function(entity, data)
    if not DoesEntityExist(entity) then return end

    local invoker = GetInvokingResource() or GetCurrentResourceName()

    for _, v in ipairs(data.options) do
        v.invoker = invoker
        v.key = v.key or "E"
        v.duration = v.duration or 1000
    end

    if not bridge.target.cache[entity] then
        createCache(entity, data, invoker)
    else
        updateCache(entity, data, invoker)
    end
end

func.removeEntity = function(entity, option, invoker)
    if not DoesEntityExist(entity) or not bridge.target.cache[entity] then return end

    local invoker = invoker or GetCurrentResourceName() or GetInvokingResource()

    if not option then
        for _, v in ipairs(bridge.target.cache[entity].options) do
            exports["nn_interaction"]:removeLocalEntity(entity, "pd_bridge:" .. invoker .. ":" .. entity, v.name)
        end

        bridge.target.cache[entity] = nil
        return
    end

    for i, v in ipairs(bridge.target.cache[entity].options) do
        if v.name == option then
            table.remove(bridge.target.cache[entity].options, i)
            exports["nn_interaction"]:removeLocalEntity(entity, "pd_bridge:" .. invoker .. ":" .. entity, option)

            if #bridge.target.cache[entity].options == 0 then bridge.target.cache[entity] = nil end
            break
        end
    end
end

return func