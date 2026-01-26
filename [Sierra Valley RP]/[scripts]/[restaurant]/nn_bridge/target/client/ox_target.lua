func = {}

local function createCache(entity, data, invoker)
    bridge.target.cache[entity] = {
        distance = data.distance or 2.5,
        options = data.options,
    }

    for _, v in ipairs(bridge.target.cache[entity].options) do
        v.distance = bridge.target.cache[entity].distance
    end

    exports["ox_target"]:addLocalEntity(entity, bridge.target.cache[entity].options)
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

    for _, v in ipairs(cache.options) do
        v.distance = cache.distance
    end

    for _, v in ipairs(data.options) do
        local optionExist, index = isOptionWithNameExist(cache.options, v.name)

        if not optionExist then
            table.insert(cache.options, v)
        else
            cache.options[index] = v
        end
    end

    exports["ox_target"]:addLocalEntity(entity, cache.options)
end

func.addEntity = function(entity, data)
    if not DoesEntityExist(entity) then return end

    local invoker = GetInvokingResource() or GetCurrentResourceName()

    for _, v in ipairs(data.options) do
        v.invoker = invoker
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
            exports["ox_target"]:removeLocalEntity(entity, v.name)
        end

        bridge.target.cache[entity] = nil
        return
    end

    for i, v in ipairs(bridge.target.cache[entity].options) do
        if v.name == option then
            table.remove(bridge.target.cache[entity].options, i)
            exports["ox_target"]:removeLocalEntity(entity, option)

            if #bridge.target.cache[entity].options == 0 then bridge.target.cache[entity] = nil end
            break
        end
    end
end

func.addGlobalVehicle = function(data)
    exports["ox_target"]:addGlobalVehicle(data)
end

func.addGlobalPlayer = function(data)
    local formattedOptions = {}

    if data.options then
        for i, option in ipairs(data.options) do
            local formattedOption = {
                name = option.name or option.event,
                icon = option.icon,
                label = option.label,
                distance = option.distance or data.distance,
                onSelect = option.action or option.onSelect
            }

            if option.canInteract then
                formattedOption.canInteract = option.canInteract
            end

            table.insert(formattedOptions, formattedOption)
        end
    end

    exports["ox_target"]:addGlobalPlayer(formattedOptions)
end

return func