-- ox_target Integration for NPCs and Props

local Targeting = {}

-- Tracked target entities
local TargetedEntities = {}

-- Add dialog target to NPC
function Targeting.AddNpcDialogTarget(entity, dialogTreeId, options)
    if TargetedEntities[entity] then return end

    options = options or {}

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_npc_talk_' .. entity,
            label = options.label or 'Talk',
            icon = options.icon or 'fas fa-comment',
            distance = options.distance or Config.Dialogs.InteractionDistance,
            onSelect = function()
                -- Request dialog tree from server or use cached
                if options.dialogTree then
                    Dialogs.Start(NetworkGetNetworkIdFromEntity(entity), options.dialogTree)
                else
                    TriggerServerEvent('nexus:server:requestDialog', {
                        npcNetId = NetworkGetNetworkIdFromEntity(entity),
                        dialogTreeId = dialogTreeId
                    })
                end
            end,
            canInteract = function()
                -- Check if in active mission or specific conditions
                if options.requireMission then
                    local mission = lib.callback.await('nexus:getActiveMission', false)
                    return mission ~= nil
                end
                return true
            end
        }
    })

    TargetedEntities[entity] = true
    ClientUtils.Debug('Added dialog target to entity:', entity)
end

-- Add interactive target to prop
function Targeting.AddPropInteraction(entity, options)
    if TargetedEntities[entity] then return end

    options = options or {}

    local targetOptions = {
        {
            name = 'nexus_prop_interact_' .. entity,
            label = options.label or 'Interact',
            icon = options.icon or 'fas fa-hand-pointer',
            distance = options.distance or 2.0,
            onSelect = function()
                if options.onSelect then
                    options.onSelect(entity)
                elseif options.eventName then
                    TriggerServerEvent(options.eventName, {
                        netId = NetworkGetNetworkIdFromEntity(entity),
                        data = options.eventData
                    })
                end
            end,
            canInteract = options.canInteract
        }
    }

    -- Add pickup option if specified
    if options.canPickup then
        targetOptions[#targetOptions + 1] = {
            name = 'nexus_prop_pickup_' .. entity,
            label = 'Pick Up',
            icon = 'fas fa-box',
            distance = 1.5,
            onSelect = function()
                TriggerServerEvent('nexus:server:pickupProp', {
                    netId = NetworkGetNetworkIdFromEntity(entity),
                    item = options.item,
                    count = options.count or 1
                })
                -- Remove entity locally
                DeleteEntity(entity)
            end
        }
    end

    exports.ox_target:addLocalEntity(entity, targetOptions)
    TargetedEntities[entity] = true
end

-- Add checkpoint zone target
function Targeting.AddCheckpointZone(zoneData)
    local zoneId = zoneData.zoneId or ('checkpoint_' .. math.random(100000, 999999))

    exports.ox_target:addSphereZone({
        coords = zoneData.coords,
        radius = zoneData.radius or 5.0,
        debug = Config.Debug.Enabled,
        options = {
            {
                name = 'nexus_checkpoint_' .. zoneId,
                label = zoneData.label or 'Checkpoint',
                icon = zoneData.icon or 'fas fa-flag-checkered',
                onSelect = function()
                    TriggerServerEvent('nexus:server:checkpointReached', {
                        zoneId = zoneId,
                        missionId = zoneData.missionId,
                        objectiveId = zoneData.objectiveId
                    })
                end,
                canInteract = function()
                    -- Only show if in relevant mission
                    if zoneData.missionId then
                        local mission = lib.callback.await('nexus:getActiveMission', false)
                        return mission and mission.id == zoneData.missionId
                    end
                    return true
                end
            }
        }
    })

    return zoneId
end

-- Remove target from entity
function Targeting.RemoveTarget(entity)
    if TargetedEntities[entity] then
        exports.ox_target:removeLocalEntity(entity, {
            'nexus_npc_talk_' .. entity,
            'nexus_prop_interact_' .. entity,
            'nexus_prop_pickup_' .. entity
        })
        TargetedEntities[entity] = nil
    end
end

-- Event to add target from server
RegisterNetEvent('nexus:client:addNpcTarget', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if DoesEntityExist(entity) then
        Targeting.AddNpcDialogTarget(entity, data.dialogTreeId, data.options)
    end
end)

RegisterNetEvent('nexus:client:addPropTarget', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if DoesEntityExist(entity) then
        Targeting.AddPropInteraction(entity, data.options)
    end
end)

RegisterNetEvent('nexus:client:createCheckpoint', function(data)
    Targeting.AddCheckpointZone(data)
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for entity, _ in pairs(TargetedEntities) do
            if DoesEntityExist(entity) then
                Targeting.RemoveTarget(entity)
            end
        end
    end
end)

return Targeting
