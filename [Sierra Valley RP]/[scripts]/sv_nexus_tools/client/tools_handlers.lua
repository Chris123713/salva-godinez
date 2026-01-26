-- Client-side handlers for expanded tools

local ToolHandlers = {}

-- Active UI elements
local ActiveBlips = {}
local ActiveZones = {}

--[[
    HACK TERMINAL HANDLERS
]]
RegisterNetEvent('nexus:client:addHackTerminal', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_hack_' .. data.terminalId,
            label = 'Hack Terminal',
            icon = 'fas fa-laptop-code',
            distance = 2.0,
            onSelect = function()
                StartHackMinigame(data.terminalId, data.difficulty)
            end
        }
    })
end)

function StartHackMinigame(terminalId, difficulty)
    -- Difficulty settings
    local settings = {
        easy = {time = 20, keys = 4},
        medium = {time = 15, keys = 5},
        hard = {time = 10, keys = 6}
    }

    local config = settings[difficulty] or settings.medium

    -- Use ox_lib skill check
    local success = lib.skillCheck({'easy', 'medium', 'hard'}, {'w', 'a', 's', 'd'})

    -- Send result to server
    local result = lib.callback.await('nexus:completeHack', false, {
        terminalId = terminalId,
        success = success
    })

    if result.success then
        lib.notify({
            title = 'Access Granted',
            description = 'Code: ' .. result.password,
            type = 'success',
            duration = 10000
        })
        ClientUtils.PlaySound('SUCCESS')
    else
        lib.notify({
            title = 'Access Denied',
            description = result.error or 'Hack failed',
            type = 'error'
        })
        ClientUtils.PlaySound('ERROR')
    end
end

--[[
    LOOT CONTAINER HANDLERS
]]
RegisterNetEvent('nexus:client:addLootContainer', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_loot_' .. data.containerId,
            label = 'Search Container',
            icon = 'fas fa-box-open',
            distance = 2.0,
            onSelect = function()
                -- Open stash
                exports.ox_inventory:openInventory('stash', data.stashId)

                -- Notify server about potential target item pickup
                Wait(2000)
                TriggerServerEvent('nexus:server:lootTaken', {
                    containerId = data.containerId,
                    targetItem = data.targetItem,
                    missionId = data.missionId,
                    objectiveId = data.objectiveId
                })
            end
        }
    })
end)

--[[
    VEHICLE TRACKER HANDLERS
]]
RegisterNetEvent('nexus:client:addVehicleTracker', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.vehicleNetId)
    if not DoesEntityExist(entity) then return end

    -- Create blip on vehicle
    local blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, 225) -- Target
    SetBlipColour(blip, 1) -- Red
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Tracked Vehicle")
    EndTextCommandSetBlipName(blip)

    ActiveBlips[data.trackerId] = blip
end)

RegisterNetEvent('nexus:client:updateTracker', function(data)
    -- Blip follows entity automatically, this is for confirmation
end)

--[[
    EVIDENCE HANDLERS
]]
RegisterNetEvent('nexus:client:addEvidence', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_evidence_' .. data.evidenceId,
            label = 'Collect Evidence (' .. data.evidenceType .. ')',
            icon = 'fas fa-search',
            distance = 2.0,
            groups = 'police',
            onSelect = function()
                -- Play animation
                lib.requestAnimDict('amb@world_human_gardener_plant@male@base')
                TaskPlayAnim(PlayerPedId(), 'amb@world_human_gardener_plant@male@base', 'base', 8.0, -8.0, 3000, 0, 0, false, false, false)

                lib.progressBar({
                    duration = 3000,
                    label = 'Collecting evidence...',
                    useWhileDead = false,
                    canCancel = true,
                    anim = {
                        dict = 'amb@world_human_gardener_plant@male@base',
                        clip = 'base'
                    }
                })

                local result = lib.callback.await('nexus:collectEvidence', false, {
                    evidenceId = data.evidenceId
                })

                if result.success then
                    lib.notify({
                        title = 'Evidence Collected',
                        description = data.description,
                        type = 'success'
                    })
                else
                    lib.notify({
                        title = 'Collection Failed',
                        description = result.error,
                        type = 'error'
                    })
                end
            end
        }
    })

    -- Add visual marker
    SetEntityDrawOutline(entity, true)
    SetEntityDrawOutlineColor(255, 0, 0, 255)
end)

--[[
    CRIME SCENE HANDLERS
]]
RegisterNetEvent('nexus:client:createCrimeScene', function(data)
    -- Create zone
    local zone = lib.zones.sphere({
        coords = data.coords,
        radius = data.radius,
        debug = Config.Debug.Enabled,
        onEnter = function()
            lib.notify({
                title = 'Crime Scene',
                description = 'Entering active crime scene - ' .. data.crimeType,
                type = 'warning'
            })
        end
    })

    ActiveZones[data.sceneId] = zone

    -- Create perimeter blip
    local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 100)

    ActiveBlips['scene_' .. data.sceneId] = blip
end)

--[[
    SPIKE STRIP HANDLERS
]]
RegisterNetEvent('nexus:client:addSpikeStrip', function(data)
    -- Create zone for spike strip
    local zone = lib.zones.sphere({
        coords = data.coords,
        radius = 3.0,
        debug = false,
        inside = function()
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 and GetEntitySpeed(vehicle) > 5.0 then
                -- Pop tires
                for i = 0, 3 do
                    if not IsVehicleTyreBurst(vehicle, i, false) then
                        SetVehicleTyreBurst(vehicle, i, true, 1000.0)
                    end
                end
            end
        end
    })

    ActiveZones['spike_' .. data.netId] = zone
end)

--[[
    LOCKDOWN HANDLERS
]]
RegisterNetEvent('nexus:client:createLockdown', function(data)
    local zone = lib.zones.sphere({
        coords = data.coords,
        radius = data.radius,
        debug = Config.Debug.Enabled,
        onEnter = function()
            -- Check if allowed
            local result = lib.callback.await('nexus:checkLockdown', false, {
                coords = GetEntityCoords(PlayerPedId())
            })

            if not result.allowed then
                lib.notify({
                    title = 'Restricted Area',
                    description = data.reason,
                    type = 'error'
                })
            end
        end
    })

    ActiveZones[data.lockdownId] = zone

    -- Create blip
    local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 150)

    ActiveBlips[data.lockdownId] = blip
end)

RegisterNetEvent('nexus:client:removeLockdown', function(data)
    if ActiveZones[data.lockdownId] then
        ActiveZones[data.lockdownId]:remove()
        ActiveZones[data.lockdownId] = nil
    end

    if ActiveBlips[data.lockdownId] then
        RemoveBlip(ActiveBlips[data.lockdownId])
        ActiveBlips[data.lockdownId] = nil
    end
end)

--[[
    BOLO HANDLERS
]]
RegisterNetEvent('nexus:client:boloAlert', function(data)
    -- Create alert UI
    lib.notify({
        title = 'BOLO - ' .. data.priority:upper(),
        description = data.description,
        type = 'error',
        duration = 15000
    })

    -- Add to MDT or police tablet
    -- Could integrate with lbtablet
end)

--[[
    MEETING HANDLERS
]]
RegisterNetEvent('nexus:client:meetingInvite', function(data)
    -- Set waypoint to meeting location
    SetNewWaypoint(data.coords.x, data.coords.y)

    lib.notify({
        title = 'Meeting Request',
        description = data.purpose,
        type = 'info',
        duration = 10000
    })
end)

RegisterNetEvent('nexus:client:createMeetingZone', function(data)
    local zone = lib.zones.sphere({
        coords = data.coords,
        radius = 10.0,
        debug = Config.Debug.Enabled,
        onEnter = function()
            lib.callback.await('nexus:arriveAtMeeting', false, {
                meetingId = data.meetingId
            })
        end
    })

    ActiveZones[data.meetingId] = zone
end)

RegisterNetEvent('nexus:client:meetingStarted', function(data)
    lib.notify({
        title = 'Meeting Started',
        description = 'All participants have arrived',
        type = 'success'
    })
    ClientUtils.PlaySound('SUCCESS')
end)

--[[
    BOUNTY HANDLERS
]]
RegisterNetEvent('nexus:client:bountyPosted', function(data)
    lib.notify({
        title = 'Bounty Posted',
        description = ('$%d on %s - %s'):format(data.amount, data.targetName, data.reason),
        type = 'info',
        duration = 15000
    })
end)

--[[
    TRAFFIC BLOCK HANDLERS
]]
RegisterNetEvent('nexus:client:trafficBlock', function(data)
    -- Visual feedback
    local blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    SetBlipColour(blip, 47) -- Yellow
    SetBlipAlpha(blip, 100)

    ActiveBlips['traffic_' .. data.blockId] = blip
end)

RegisterNetEvent('nexus:client:removeTrafficBlock', function(data)
    if ActiveBlips['traffic_' .. data.blockId] then
        RemoveBlip(ActiveBlips['traffic_' .. data.blockId])
        ActiveBlips['traffic_' .. data.blockId] = nil
    end
end)

--[[
    INFORMANT HANDLERS
]]
RegisterNetEvent('nexus:client:addInformant', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_informant_' .. data.informantId,
            label = 'Buy Intel ($' .. data.price .. ')',
            icon = 'fas fa-user-secret',
            distance = 2.0,
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Buy Intel',
                    content = ('Pay $%d for %s information?'):format(data.price, data.intelType),
                    centered = true,
                    cancel = true
                })

                if confirm == 'confirm' then
                    local result = lib.callback.await('nexus:buyIntel', false, {
                        informantId = data.informantId
                    })

                    if result.success then
                        lib.notify({
                            title = 'Intel Acquired',
                            description = 'Check your phone for details',
                            type = 'success'
                        })

                        -- Display intel (could send to phone instead)
                        local intelText = json.encode(result.intel, {indent = true})
                        lib.alertDialog({
                            header = 'Intel: ' .. result.intelType,
                            content = intelText
                        })
                    else
                        lib.notify({
                            title = 'Failed',
                            description = result.error,
                            type = 'error'
                        })
                    end
                end
            end
        }
    })
end)

--[[
    DELIVERY HANDLERS
]]
RegisterNetEvent('nexus:client:addDeliveryPickup', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    -- Create pickup blip
    local pickupBlip = AddBlipForCoord(data.pickupCoords.x, data.pickupCoords.y, data.pickupCoords.z)
    SetBlipSprite(pickupBlip, 478) -- Package
    SetBlipColour(pickupBlip, 2) -- Green
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Pickup Location")
    EndTextCommandSetBlipName(pickupBlip)

    ActiveBlips['delivery_pickup_' .. data.deliveryId] = pickupBlip

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_delivery_pickup_' .. data.deliveryId,
            label = 'Pick Up Package',
            icon = 'fas fa-box',
            distance = 2.0,
            onSelect = function()
                local result = lib.callback.await('nexus:pickupDelivery', false, {
                    deliveryId = data.deliveryId
                })

                if result.success then
                    lib.notify({
                        title = 'Package Picked Up',
                        description = 'Deliver to marked location',
                        type = 'success'
                    })
                end
            end
        }
    })
end)

RegisterNetEvent('nexus:client:deliveryPickedUp', function(data)
    -- Remove pickup blip
    if ActiveBlips['delivery_pickup_' .. data.deliveryId] then
        RemoveBlip(ActiveBlips['delivery_pickup_' .. data.deliveryId])
    end

    -- Create dropoff blip
    local dropoffBlip = AddBlipForCoord(data.dropoffCoords.x, data.dropoffCoords.y, data.dropoffCoords.z)
    SetBlipSprite(dropoffBlip, 478)
    SetBlipColour(dropoffBlip, 1) -- Red
    SetBlipRoute(dropoffBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Dropoff Location")
    EndTextCommandSetBlipName(dropoffBlip)

    ActiveBlips['delivery_dropoff_' .. data.deliveryId] = dropoffBlip

    -- Create dropoff zone
    local zone = lib.zones.sphere({
        coords = data.dropoffCoords,
        radius = 5.0,
        onEnter = function()
            lib.notify({
                title = 'Dropoff Zone',
                description = 'Press E to complete delivery',
                type = 'info'
            })
        end,
        inside = function()
            if IsControlJustPressed(0, 38) then -- E key
                local result = lib.callback.await('nexus:completeDelivery', false, {
                    deliveryId = data.deliveryId
                })

                if result.success then
                    -- Clean up
                    if ActiveBlips['delivery_dropoff_' .. data.deliveryId] then
                        RemoveBlip(ActiveBlips['delivery_dropoff_' .. data.deliveryId])
                    end
                    zone:remove()
                end
            end
        end
    })

    ActiveZones['delivery_' .. data.deliveryId] = zone
end)

--[[
    CUSTOMER HANDLERS
]]
RegisterNetEvent('nexus:client:addCustomer', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    local itemList = ''
    for _, item in ipairs(data.wantedItems or {}) do
        itemList = itemList .. item.count .. 'x ' .. item.name .. ', '
    end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_customer_' .. data.customerId,
            label = 'Trade (' .. itemList .. ')',
            icon = 'fas fa-handshake',
            distance = 2.0,
            onSelect = function()
                local confirm = lib.alertDialog({
                    header = 'Trade Offer',
                    content = ('Customer wants: %s\nOffering: $%d'):format(itemList, data.offeredMoney),
                    centered = true,
                    cancel = true
                })

                if confirm == 'confirm' then
                    local result = lib.callback.await('nexus:tradeWithCustomer', false, {
                        customerId = data.customerId
                    })

                    if result.success then
                        lib.notify({
                            title = 'Trade Complete',
                            description = 'Received $' .. result.receivedMoney,
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'Trade Failed',
                            description = result.error,
                            type = 'error'
                        })
                    end
                end
            end
        }
    })
end)

RegisterNetEvent('nexus:client:customerLeave', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if DoesEntityExist(entity) then
        TaskWanderStandard(entity, 10.0, 10)
        SetTimeout(30000, function()
            if DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end)
    end
end)

--[[
    WITNESS HANDLERS
]]
RegisterNetEvent('nexus:client:addWitness', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_witness_' .. data.witnessId,
            label = 'Talk to Witness',
            icon = 'fas fa-comments',
            distance = 2.0,
            onSelect = function()
                local result = lib.callback.await('nexus:talkToWitness', false, {
                    witnessId = data.witnessId
                })

                if result.success then
                    lib.alertDialog({
                        header = 'Witness Statement',
                        content = json.encode(result.intel, {indent = true})
                    })
                else
                    lib.notify({
                        title = 'No Information',
                        description = result.error,
                        type = 'warning'
                    })
                end
            end
        }
    })
end)

--[[
    RUMOR HANDLERS
]]
RegisterNetEvent('nexus:client:enableRumor', function(data)
    local zone = lib.zones.sphere({
        coords = data.area,
        radius = data.radius,
        debug = false,
        inside = function()
            -- Random chance to hear rumor from nearby NPCs
            if math.random() < 0.01 then -- 1% per tick
                local result = lib.callback.await('nexus:hearRumor', false, {
                    rumorId = data.rumorId
                })

                if result.success then
                    lib.notify({
                        title = 'Overheard',
                        description = result.rumor,
                        type = 'info',
                        duration = 10000
                    })
                end
            end
        end
    })

    ActiveZones['rumor_' .. data.rumorId] = zone
end)

RegisterNetEvent('nexus:client:disableRumor', function(data)
    if ActiveZones['rumor_' .. data.rumorId] then
        ActiveZones['rumor_' .. data.rumorId]:remove()
        ActiveZones['rumor_' .. data.rumorId] = nil
    end
end)

--[[
    MEDICAL PATIENT HANDLERS
]]
RegisterNetEvent('nexus:client:setPatientState', function(data)
    local entity = NetworkGetEntityFromNetworkId(data.netId)
    if not DoesEntityExist(entity) then return end

    -- Set to ragdoll/downed state
    SetPedToRagdoll(entity, 10000, 10000, 0, false, false, false)

    -- Add revive target for EMS
    exports.ox_target:addLocalEntity(entity, {
        {
            name = 'nexus_patient_' .. data.netId,
            label = 'Treat Patient (' .. data.severity .. ')',
            icon = 'fas fa-heartbeat',
            distance = 2.0,
            groups = {'ambulance', 'ems'},
            onSelect = function()
                lib.progressBar({
                    duration = 10000,
                    label = 'Treating patient...',
                    useWhileDead = false,
                    canCancel = true
                })

                lib.notify({
                    title = 'Patient Treated',
                    description = 'Patient stabilized',
                    type = 'success'
                })

                -- Wake up NPC
                ClearPedTasksImmediately(entity)
            end
        }
    })
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, blip in pairs(ActiveBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end

        for _, zone in pairs(ActiveZones) do
            if zone.remove then
                zone:remove()
            end
        end
    end
end)

return ToolHandlers
