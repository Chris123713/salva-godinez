local Zones = {}
Utils.Target = {}

local function convert(options)
    local distance = options.distance
    options = options.options

    for _, v in pairs(options) do
        v.onSelect = v.action
        v.distance = v.distance or distance
        v.name = v.name or v.label
        v.groups = v.job
        v.items = v.item or v.required_item

        if v.event and v.type and v.type ~= 'client' then
            if v.type == 'server' then
                v.serverEvent = v.event
            elseif v.type == 'command' then
                v.command = v.event
            end

            v.event = nil
            v.type = nil
        end

        v.action = nil
        v.job = nil
        v.item = nil
        v.required_item = nil
        v.qtarget = true
    end

    return options
end

function Utils.Target.GetTarget()
    if Utils.IsResourceStarted('ox_target') then
        return 'ox_target'
    elseif Utils.IsResourceStarted('qtarget') then
        return 'qtarget'
    elseif Utils.IsResourceStarted('qb-target') then
        return 'qb-target'
    else
        return false
    end
end

function Utils.Target.AddTargetBoxZone(name, data, options)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        local id = exports['ox_target']:addBoxZone({
            coords = data.coords,
            size = vec3(data.width, data.length, data.maxZ - data.minZ),
            rotation = data.heading,
            debug = data.debugPoly,
            options = convert(options)
        })
        if Utils.IsResourceStarted('crm-target') then
            Zones[name] = true
        else
            Zones[id] = name
        end
    else
        data.name = name
        exports[target]:AddBoxZone(name, data.coords, data.length, data.width, data, options)
    end
end

function Utils.Target.AddTargetEntity(name, object, options)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        exports['ox_target']:addLocalEntity(object, convert(options))
    elseif target == 'qtarget' then
        exports[target]:AddEntityZone(name, object, {
            name = name,
            debugPoly = Config.Debug,
            useZ = true,
        }, options)
    else
        options.name = name
        exports[target]:AddTargetEntity(object, options)
    end
end

function Utils.Target.AddTargetPlayer(options)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        exports['ox_target']:addGlobalPlayer(convert(options))
    elseif target == 'qtarget' then
        exports[target]:Player(options)
    elseif target == Config.exportname.qbtarget then
        exports[target]:AddGlobalPlayer(options)
    end
end

function Utils.Target.AddTargetModel(models, options)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        exports['ox_target']:addModel(models, convert(options))
    else
        exports[target]:AddTargetModel(models, options)
    end
end

function Utils.Target.RemoveTargetEntity(object, labels)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        exports['ox_target']:removeLocalEntity(object, labels)
    else
        exports[target]:RemoveTargetEntity(object, labels)
    end
end

function Utils.Target.RemoveTargetZone(name)
    local target = Utils.Target.GetTarget()
    if target == 'ox_target' then
        for id, label in pairs(Zones) do
            if label == name then
                exports['ox_target']:removeZone(id)
                break
            end
        end
    else
        exports[target]:RemoveZone(name)
    end
end
