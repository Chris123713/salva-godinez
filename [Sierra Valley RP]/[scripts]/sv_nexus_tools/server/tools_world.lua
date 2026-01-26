-- World & Atmosphere Tools

local WorldTools = {}

-- Active traffic blocks
local ActiveTrafficBlocks = {}

-- Active ambient events
local ActiveAmbientEvents = {}

-- Active delivery tasks
local ActiveDeliveries = {}

-- Active customer NPCs
local ActiveCustomers = {}

-- Witness events
local ActiveWitnesses = {}

--[[
    TRAFFIC BLOCK
    Creates AI-controlled traffic jam
]]
RegisterTool('traffic_block', {
    params = {'coords', 'radius', 'duration', 'severity'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or 30.0
        local duration = params.duration or 300 -- 5 minutes
        local severity = params.severity or 'moderate' -- light, moderate, heavy

        local blockId = Utils.GenerateUUID()

        -- Vehicle count based on severity
        local vehicleCounts = {
            light = 3,
            moderate = 6,
            heavy = 10
        }
        local vehicleCount = vehicleCounts[severity] or 6

        ActiveTrafficBlocks[blockId] = {
            coords = coords,
            radius = radius,
            severity = severity,
            vehicleNetIds = {},
            status = 'active',
            createdAt = os.time(),
            expiresAt = os.time() + duration
        }

        -- Spawn stopped vehicles
        local vehicleModels = {'sultan', 'primo', 'oracle', 'fugitive', 'stanier', 'emperor'}

        for i = 1, vehicleCount do
            local angle = (i / vehicleCount) * math.pi * 2
            local dist = math.random(5, math.floor(radius * 0.8))
            local vehicleCoords = vector3(
                coords.x + math.cos(angle) * dist,
                coords.y + math.sin(angle) * dist,
                coords.z
            )

            local model = vehicleModels[math.random(#vehicleModels)]

            local spawnResult = lib.callback.await('nexus:spawnVehicle', source, {
                model = model,
                coords = vehicleCoords,
                heading = math.random(0, 360),
                locked = false,
                networked = true
            })

            if spawnResult and spawnResult.success then
                table.insert(ActiveTrafficBlocks[blockId].vehicleNetIds, spawnResult.netId)

                -- Spawn driver NPC
                lib.callback.await('nexus:spawnNpc', source, {
                    model = 'a_m_y_downtown_01',
                    coords = vehicleCoords,
                    heading = 0,
                    behavior = 'idle',
                    networked = true
                })
            end
        end

        -- Notify clients
        TriggerClientEvent('nexus:client:trafficBlock', -1, {
            blockId = blockId,
            coords = coords,
            radius = radius
        })

        -- Schedule cleanup
        SetTimeout(duration * 1000, function()
            if ActiveTrafficBlocks[blockId] then
                -- Delete vehicles
                for _, netId in ipairs(ActiveTrafficBlocks[blockId].vehicleNetIds) do
                    local entity = NetworkGetEntityFromNetworkId(netId)
                    if DoesEntityExist(entity) then
                        DeleteEntity(entity)
                    end
                end
                ActiveTrafficBlocks[blockId].status = 'expired'
                TriggerClientEvent('nexus:client:removeTrafficBlock', -1, {blockId = blockId})
            end
        end)

        Utils.Debug('Traffic block created:', blockId, severity)

        return {
            success = true,
            blockId = blockId,
            vehicleCount = #ActiveTrafficBlocks[blockId].vehicleNetIds
        }
    end
})

--[[
    SPAWN AMBIENT EVENT
    Random world events (car crash, fight, fire, etc)
]]
RegisterTool('spawn_ambient_event', {
    params = {'coords', 'eventType', 'duration', 'alertEmergency'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local eventType = params.eventType or 'car_crash'
        local duration = params.duration or 600
        local alertEmergency = params.alertEmergency ~= false

        local eventId = Utils.GenerateUUID()

        ActiveAmbientEvents[eventId] = {
            coords = coords,
            type = eventType,
            status = 'active',
            netIds = {},
            createdAt = os.time(),
            expiresAt = os.time() + duration
        }

        if eventType == 'car_crash' then
            -- Spawn crashed vehicles
            local vehicle1 = lib.callback.await('nexus:spawnVehicle', source, {
                model = 'sultan',
                coords = vector3(coords.x - 2, coords.y, coords.z),
                heading = 45,
                networked = true
            })

            local vehicle2 = lib.callback.await('nexus:spawnVehicle', source, {
                model = 'primo',
                coords = vector3(coords.x + 2, coords.y + 1, coords.z),
                heading = 225,
                networked = true
            })

            if vehicle1 and vehicle1.success then
                table.insert(ActiveAmbientEvents[eventId].netIds, vehicle1.netId)
                TriggerClientEvent('nexus:client:damageVehicle', -1, {netId = vehicle1.netId, damage = 500})
            end
            if vehicle2 and vehicle2.success then
                table.insert(ActiveAmbientEvents[eventId].netIds, vehicle2.netId)
                TriggerClientEvent('nexus:client:damageVehicle', -1, {netId = vehicle2.netId, damage = 700})
            end

            -- Spawn injured NPC
            exports['sv_nexus_tools']:ExecuteTool('medical_triage', {
                coords = vector3(coords.x, coords.y + 3, coords.z),
                injuryType = 'trauma',
                severity = 'moderate'
            }, source)

            if alertEmergency then
                exports['sv_nexus_tools']:ExecuteTool('alert_dispatch', {
                    coords = coords,
                    code = '10-50',
                    description = 'Vehicle collision with injuries'
                }, source)
            end

        elseif eventType == 'fight' then
            -- Spawn fighting NPCs
            local npc1 = lib.callback.await('nexus:spawnNpc', source, {
                model = 'a_m_y_stwhi_02',
                coords = vector3(coords.x - 1, coords.y, coords.z),
                heading = 90,
                behavior = 'hostile',
                networked = true
            })

            local npc2 = lib.callback.await('nexus:spawnNpc', source, {
                model = 'a_m_m_afriamer_01',
                coords = vector3(coords.x + 1, coords.y, coords.z),
                heading = 270,
                behavior = 'hostile',
                networked = true
            })

            if npc1 and npc1.success then
                table.insert(ActiveAmbientEvents[eventId].netIds, npc1.netId)
            end
            if npc2 and npc2.success then
                table.insert(ActiveAmbientEvents[eventId].netIds, npc2.netId)
            end

            TriggerClientEvent('nexus:client:startFight', -1, {
                npc1NetId = npc1 and npc1.netId,
                npc2NetId = npc2 and npc2.netId
            })

            if alertEmergency then
                exports['sv_nexus_tools']:ExecuteTool('alert_dispatch', {
                    coords = coords,
                    code = '10-10',
                    description = 'Fight in progress'
                }, source)
            end

        elseif eventType == 'fire' then
            -- Create fire effect at location
            TriggerClientEvent('nexus:client:startFire', -1, {
                coords = coords,
                spread = 5.0
            })

            if alertEmergency then
                -- Alert fire department
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    local player = Utils.GetPlayer(playerId)
                    if player and player.PlayerData.job.name == 'fire' then
                        TriggerClientEvent('nexus:client:fireAlert', playerId, {
                            coords = coords,
                            eventId = eventId
                        })
                    end
                end
            end

        elseif eventType == 'robbery' then
            -- Spawn robber and victim
            local robber = lib.callback.await('nexus:spawnNpc', source, {
                model = 's_m_y_dealer_01',
                coords = vector3(coords.x, coords.y, coords.z),
                heading = 0,
                behavior = 'hostile',
                networked = true
            })

            local victim = lib.callback.await('nexus:spawnNpc', source, {
                model = 'a_f_y_business_01',
                coords = vector3(coords.x + 1, coords.y + 1, coords.z),
                heading = 180,
                behavior = 'cower',
                networked = true
            })

            if alertEmergency then
                exports['sv_nexus_tools']:ExecuteTool('alert_dispatch', {
                    coords = coords,
                    code = '10-31',
                    description = 'Robbery in progress'
                }, source)
            end
        end

        -- Schedule cleanup
        SetTimeout(duration * 1000, function()
            if ActiveAmbientEvents[eventId] then
                for _, netId in ipairs(ActiveAmbientEvents[eventId].netIds) do
                    local entity = NetworkGetEntityFromNetworkId(netId)
                    if DoesEntityExist(entity) then
                        DeleteEntity(entity)
                    end
                end
                ActiveAmbientEvents[eventId].status = 'expired'
            end
        end)

        Utils.Debug('Ambient event spawned:', eventId, eventType)

        return {
            success = true,
            eventId = eventId
        }
    end
})

--[[
    CREATE DELIVERY TASK
    Package pickup/dropoff mission
]]
RegisterTool('create_delivery_task', {
    params = {'pickupCoords', 'dropoffCoords', 'item', 'reward', 'timeLimit', 'missionId'},
    async = true,
    handler = function(params, source)
        local pickupCoords = Utils.Vec3FromTable(params.pickupCoords)
        local dropoffCoords = Utils.Vec3FromTable(params.dropoffCoords)
        local item = params.item or {name = 'package', count = 1}
        local reward = params.reward or 500
        local timeLimit = params.timeLimit or 600

        local deliveryId = Utils.GenerateUUID()

        ActiveDeliveries[deliveryId] = {
            pickupCoords = pickupCoords,
            dropoffCoords = dropoffCoords,
            item = item,
            reward = reward,
            timeLimit = timeLimit,
            assignedTo = Utils.GetCitizenId(source),
            missionId = params.missionId,
            status = 'pending', -- pending, picked_up, delivered, failed
            createdAt = os.time(),
            deadline = os.time() + timeLimit
        }

        -- Spawn package at pickup
        local packageResult = lib.callback.await('nexus:spawnProp', source, {
            model = 'prop_box_wood02a',
            coords = pickupCoords,
            interactive = true,
            frozen = true
        })

        if packageResult and packageResult.success then
            ActiveDeliveries[deliveryId].packageNetId = packageResult.netId

            -- Add pickup target
            TriggerClientEvent('nexus:client:addDeliveryPickup', source, {
                deliveryId = deliveryId,
                netId = packageResult.netId,
                pickupCoords = pickupCoords,
                dropoffCoords = dropoffCoords,
                timeLimit = timeLimit
            })
        end

        -- Schedule timeout
        SetTimeout(timeLimit * 1000, function()
            if ActiveDeliveries[deliveryId] and ActiveDeliveries[deliveryId].status ~= 'delivered' then
                ActiveDeliveries[deliveryId].status = 'failed'

                local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(ActiveDeliveries[deliveryId].assignedTo)
                if playerSource then
                    TriggerClientEvent('ox_lib:notify', playerSource, {
                        title = 'Delivery Failed',
                        description = 'Time limit exceeded',
                        type = 'error'
                    })
                end
            end
        end)

        Utils.Debug('Delivery task created:', deliveryId)

        return {
            success = true,
            deliveryId = deliveryId
        }
    end
})

-- Pickup package
lib.callback.register('nexus:pickupDelivery', function(source, data)
    local delivery = ActiveDeliveries[data.deliveryId]
    if not delivery or delivery.status ~= 'pending' then
        return {success = false, error = 'Delivery not available'}
    end

    local citizenid = Utils.GetCitizenId(source)
    if delivery.assignedTo ~= citizenid then
        return {success = false, error = 'Not your delivery'}
    end

    -- Give package item
    exports.ox_inventory:AddItem(source, delivery.item.name, delivery.item.count, {
        deliveryId = data.deliveryId
    })

    -- Delete package prop
    if delivery.packageNetId then
        local entity = NetworkGetEntityFromNetworkId(delivery.packageNetId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    delivery.status = 'picked_up'
    delivery.pickedUpAt = os.time()

    -- Update client with dropoff waypoint
    TriggerClientEvent('nexus:client:deliveryPickedUp', source, {
        deliveryId = data.deliveryId,
        dropoffCoords = delivery.dropoffCoords,
        remainingTime = delivery.deadline - os.time()
    })

    return {success = true}
end)

-- Complete delivery
lib.callback.register('nexus:completeDelivery', function(source, data)
    local delivery = ActiveDeliveries[data.deliveryId]
    if not delivery or delivery.status ~= 'picked_up' then
        return {success = false, error = 'Invalid delivery state'}
    end

    -- Check if has package
    local hasPackage = exports.ox_inventory:Search(source, 'count', delivery.item.name)
    if not hasPackage or hasPackage < delivery.item.count then
        return {success = false, error = 'Package not in inventory'}
    end

    -- Check if at dropoff
    -- (Client validates proximity)

    -- Remove package
    exports.ox_inventory:RemoveItem(source, delivery.item.name, delivery.item.count)

    -- Pay reward
    exports.qbx_core:AddMoney(source, 'cash', delivery.reward, 'Delivery completed')

    delivery.status = 'delivered'
    delivery.deliveredAt = os.time()

    -- Complete mission objective
    if delivery.missionId then
        exports['sv_nexus_tools']:SetMissionObjective(
            delivery.missionId,
            Utils.GetCitizenId(source),
            'complete_delivery',
            Constants.ObjectiveStatus.COMPLETED
        )
    end

    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Delivery Complete',
        description = 'Earned $' .. delivery.reward,
        type = 'success'
    })

    return {
        success = true,
        reward = delivery.reward
    }
end)

--[[
    SPAWN CUSTOMER NPC
    NPC that wants to buy/trade items
]]
RegisterTool('spawn_customer_npc', {
    params = {'coords', 'wantedItems', 'offeredItems', 'offeredMoney', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)

        local customerId = Utils.GenerateUUID()

        -- Spawn customer NPC
        local spawnResult = lib.callback.await('nexus:spawnNpc', source, {
            model = 'a_m_m_business_01',
            coords = coords,
            heading = 0,
            behavior = 'idle',
            networked = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn customer'}
        end

        ActiveCustomers[customerId] = {
            netId = spawnResult.netId,
            coords = coords,
            wantedItems = params.wantedItems or {}, -- [{name, count}]
            offeredItems = params.offeredItems or {},
            offeredMoney = params.offeredMoney or 0,
            missionId = params.missionId,
            tradedWith = nil,
            status = 'waiting'
        }

        -- Add trade target
        TriggerClientEvent('nexus:client:addCustomer', -1, {
            netId = spawnResult.netId,
            customerId = customerId,
            wantedItems = params.wantedItems,
            offeredMoney = params.offeredMoney
        })

        Utils.Debug('Customer NPC spawned:', customerId)

        return {
            success = true,
            customerId = customerId,
            netId = spawnResult.netId
        }
    end
})

-- Trade with customer
lib.callback.register('nexus:tradeWithCustomer', function(source, data)
    local customer = ActiveCustomers[data.customerId]
    if not customer or customer.status ~= 'waiting' then
        return {success = false, error = 'Customer not available'}
    end

    -- Check if player has all wanted items
    for _, item in ipairs(customer.wantedItems) do
        local hasItem = exports.ox_inventory:Search(source, 'count', item.name)
        if not hasItem or hasItem < item.count then
            return {success = false, error = 'Missing item: ' .. item.name}
        end
    end

    -- Remove wanted items
    for _, item in ipairs(customer.wantedItems) do
        exports.ox_inventory:RemoveItem(source, item.name, item.count)
    end

    -- Give offered items
    for _, item in ipairs(customer.offeredItems) do
        exports.ox_inventory:AddItem(source, item.name, item.count)
    end

    -- Give money
    if customer.offeredMoney > 0 then
        exports.qbx_core:AddMoney(source, 'cash', customer.offeredMoney, 'Customer trade')
    end

    customer.status = 'traded'
    customer.tradedWith = Utils.GetCitizenId(source)

    -- Complete objective
    if customer.missionId then
        exports['sv_nexus_tools']:SetMissionObjective(
            customer.missionId,
            customer.tradedWith,
            'complete_trade',
            Constants.ObjectiveStatus.COMPLETED
        )
    end

    -- Customer walks away
    TriggerClientEvent('nexus:client:customerLeave', -1, {
        netId = customer.netId
    })

    return {
        success = true,
        receivedMoney = customer.offeredMoney,
        receivedItems = customer.offeredItems
    }
end)

--[[
    WITNESS EVENT
    NPC that saw something and can share info
]]
RegisterTool('witness_event', {
    params = {'coords', 'witnessType', 'intelType', 'intelData', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local witnessType = params.witnessType or 'civilian' -- civilian, criminal, police_snitch
        local intelType = params.intelType or 'location' -- location, phone, identity, crime

        local witnessId = Utils.GenerateUUID()

        -- Get intel from database based on type
        local intel = params.intelData or {}

        if intelType == 'phone' and intel.targetCitizenid then
            -- Get phone contacts
            local contacts = MySQL.query.await([[
                SELECT c.name, c.number FROM phone_phone_contacts c
                JOIN phone_phones p ON c.phone_id = p.id
                JOIN phone_logged_in_accounts a ON p.id = a.phone_id
                WHERE a.owner = ?
                LIMIT 5
            ]], {intel.targetCitizenid})

            intel.contacts = contacts
        elseif intelType == 'crime' and intel.targetCitizenid then
            -- Get criminal history
            local history = MySQL.query.await([[
                SELECT * FROM lbtablet_police_logs
                WHERE JSON_EXTRACT(data, '$.citizenid') = ?
                ORDER BY created_at DESC LIMIT 3
            ]], {intel.targetCitizenid})

            intel.history = history
        end

        -- Spawn witness
        local models = {
            civilian = 'a_f_m_downtown_01',
            criminal = 's_m_y_dealer_01',
            police_snitch = 'a_m_m_socenlat_01'
        }

        local spawnResult = lib.callback.await('nexus:spawnNpc', source, {
            model = models[witnessType] or models.civilian,
            coords = coords,
            heading = 0,
            behavior = 'idle',
            networked = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn witness'}
        end

        ActiveWitnesses[witnessId] = {
            netId = spawnResult.netId,
            coords = coords,
            witnessType = witnessType,
            intelType = intelType,
            intel = intel,
            missionId = params.missionId,
            talkedTo = {},
            status = 'available'
        }

        -- Add dialog target
        TriggerClientEvent('nexus:client:addWitness', -1, {
            netId = spawnResult.netId,
            witnessId = witnessId,
            witnessType = witnessType
        })

        Utils.Debug('Witness spawned:', witnessId, witnessType)

        return {
            success = true,
            witnessId = witnessId,
            netId = spawnResult.netId
        }
    end
})

-- Talk to witness
lib.callback.register('nexus:talkToWitness', function(source, data)
    local witness = ActiveWitnesses[data.witnessId]
    if not witness or witness.status ~= 'available' then
        return {success = false, error = 'Witness not available'}
    end

    local citizenid = Utils.GetCitizenId(source)

    -- Check if already talked
    if witness.talkedTo[citizenid] then
        return {success = false, error = 'Already talked to this witness'}
    end

    witness.talkedTo[citizenid] = os.time()

    -- Check persuasion (could add skill check)
    local player = Utils.GetPlayer(source)
    local isPolice = player and player.PlayerData.job.name == 'police'

    -- Police get more info
    local intelLevel = isPolice and 'full' or 'partial'

    local sharedIntel = witness.intel
    if intelLevel == 'partial' then
        -- Redact some info for non-police
        sharedIntel = {
            hint = 'The witness remembers seeing something...',
            partialData = witness.intel
        }
    end

    -- Complete objective
    if witness.missionId then
        exports['sv_nexus_tools']:SetMissionObjective(
            witness.missionId,
            citizenid,
            'interview_witness',
            Constants.ObjectiveStatus.COMPLETED
        )
    end

    return {
        success = true,
        intel = sharedIntel,
        intelType = witness.intelType,
        intelLevel = intelLevel
    }
end)

-- Exports
exports('GetActiveTrafficBlocks', function() return ActiveTrafficBlocks end)
exports('GetActiveAmbientEvents', function() return ActiveAmbientEvents end)
exports('GetActiveDeliveries', function() return ActiveDeliveries end)
exports('GetActiveCustomers', function() return ActiveCustomers end)
exports('GetActiveWitnesses', function() return ActiveWitnesses end)

return WorldTools
