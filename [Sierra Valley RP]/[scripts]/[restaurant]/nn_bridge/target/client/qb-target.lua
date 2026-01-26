func = {}

local function createCache(entity, data, invoker)
    bridge.target.cache[entity] = {
        distance = data.distance or 2.5,
        options = data.options,
    }

    exports["qb-target"]:AddTargetEntity(entity, bridge.target.cache[entity])
end

local function fixOptionsNum(entity)
    for i, v in ipairs(bridge.target.cache[entity].options) do
        v.num = i
    end
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

    cache.distance = data.distance ~= nil and data.distance or cache.distance

    for _, v in ipairs(data.options) do
        local optionExist, index = isOptionWithNameExist(cache.options, v.name)

        if not optionExist then
            table.insert(cache.options, v)
        else
            cache.options[index] = v
        end
    end

    fixOptionsNum(entity)

    exports["qb-target"]:AddTargetEntity(entity, cache)
end

func.addEntity = function(entity, data)
    if not DoesEntityExist(entity) then return end

    local invoker = GetInvokingResource() or GetCurrentResourceName()

    local totalOptions = bridge.target.cache[entity] and #bridge.target.cache[entity].options or 0

    for i, v in ipairs(data.options) do
        v.num = i + totalOptions
        v.invoker = invoker
        v.action = v.onSelect
        v.onSelect = nil
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
            exports["qb-target"]:RemoveTargetEntity(entity, v.label)
        end

        bridge.target.cache[entity] = nil
        return
    end

    for i, v in ipairs(bridge.target.cache[entity].options) do
        if v.name == option then
            table.remove(bridge.target.cache[entity].options, i)
            exports["qb-target"]:RemoveTargetEntity(entity, v.label)

            if #bridge.target.cache[entity].options == 0 then
                bridge.target.cache[entity] = nil
            end
            break
        end
    end

    if bridge.target.cache[entity] then
        fixOptionsNum(entity)
        exports["qb-target"]:AddTargetEntity(entity, bridge.target.cache[entity])
    end
end

func.addGlobalVehicle = function(data)
    exports["qb-target"]:AddGlobalVehicle(data)
end

return func