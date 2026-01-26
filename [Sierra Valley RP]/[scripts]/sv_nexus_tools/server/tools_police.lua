-- Police & Emergency Tools with Database Integration

local PoliceTools = {}

-- Active evidence markers
local ActiveEvidence = {}

-- Active crime scenes
local ActiveCrimeScenes = {}

-- Active BOLOs
local ActiveBOLOs = {}

-- Active lockdown areas
local ActiveLockdowns = {}

-- Barrier tracking
local ActiveBarriers = {}

--[[
    SPAWN EVIDENCE
    Creates collectible evidence prop with r14-evidence integration
]]
RegisterTool('spawn_evidence', {
    params = {'coords', 'evidenceType', 'description', 'linkedTo', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local evidenceType = params.evidenceType or 'generic'

        local evidenceId = Utils.GenerateUUID()

        -- Model based on evidence type
        local models = {
            weapon = 'prop_cs_box_clothes',
            document = 'prop_cs_documents_01',
            blood = 'prop_blood_splat_01',
            shell_casing = 'prop_cs_milk_box',
            phone = 'prop_phone_ing',
            drugs = 'prop_drug_package',
            money = 'prop_money_bag_01',
            generic = 'prop_cs_cardbox_01'
        }

        local model = models[evidenceType] or models.generic

        -- Spawn evidence prop
        local spawnResult = lib.callback.await('nexus:spawnProp', source, {
            model = model,
            coords = coords,
            heading = math.random(0, 360),
            interactive = true,
            frozen = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn evidence'}
        end

        ActiveEvidence[evidenceId] = {
            netId = spawnResult.netId,
            coords = coords,
            type = evidenceType,
            description = params.description or 'Unknown evidence',
            linkedTo = params.linkedTo, -- citizenid of suspect
            missionId = params.missionId,
            collectedBy = nil,
            collectedAt = nil,
            status = 'uncollected'
        }

        -- Insert into wsb_mdt_evidence or r14-evidence if available
        MySQL.insert.await([[
            INSERT INTO nexus_evidence
            (evidence_id, type, description, coords, linked_to, mission_id, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 'uncollected', NOW())
        ]], {evidenceId, evidenceType, params.description, json.encode(coords), params.linkedTo, params.missionId})

        -- Add ox_target for evidence collection
        TriggerClientEvent('nexus:client:addEvidence', -1, {
            netId = spawnResult.netId,
            evidenceId = evidenceId,
            evidenceType = evidenceType,
            description = params.description
        })

        Utils.Debug('Spawned evidence:', evidenceId, evidenceType)

        return {
            success = true,
            evidenceId = evidenceId,
            netId = spawnResult.netId
        }
    end
})

-- Evidence collection callback
lib.callback.register('nexus:collectEvidence', function(source, data)
    local evidence = ActiveEvidence[data.evidenceId]
    if not evidence then
        return {success = false, error = 'Evidence not found'}
    end

    local player = Utils.GetPlayer(source)
    if not player then
        return {success = false, error = 'Player not found'}
    end

    -- Check if police
    if player.PlayerData.job.name ~= 'police' then
        return {success = false, error = 'Only law enforcement can collect evidence'}
    end

    local citizenid = player.PlayerData.citizenid

    -- Update evidence status
    evidence.status = 'collected'
    evidence.collectedBy = citizenid
    evidence.collectedAt = os.time()

    -- Update database
    MySQL.update.await([[
        UPDATE nexus_evidence
        SET status = 'collected', collected_by = ?, collected_at = NOW()
        WHERE evidence_id = ?
    ]], {citizenid, data.evidenceId})

    -- Give evidence item to player
    exports.ox_inventory:AddItem(source, 'evidence_bag', 1, {
        evidenceId = data.evidenceId,
        type = evidence.type,
        description = evidence.description,
        linkedTo = evidence.linkedTo,
        collectedAt = evidence.collectedAt
    })

    -- Complete objective if linked to mission
    if evidence.missionId then
        exports['sv_nexus_tools']:SetMissionObjective(
            evidence.missionId,
            citizenid,
            'collect_evidence',
            Constants.ObjectiveStatus.COMPLETED
        )
    end

    -- Delete the prop
    local entity = NetworkGetEntityFromNetworkId(evidence.netId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end

    Utils.Debug('Evidence collected:', data.evidenceId, 'by', citizenid)

    return {success = true, evidence = evidence}
end)

--[[
    MARK CRIME SCENE
    Creates investigation zone with multiple evidence points
]]
RegisterTool('mark_crime_scene', {
    params = {'coords', 'radius', 'crimeType', 'evidenceCount', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or 25.0
        local crimeType = params.crimeType or 'unknown'
        local evidenceCount = params.evidenceCount or 3

        local sceneId = Utils.GenerateUUID()

        ActiveCrimeScenes[sceneId] = {
            coords = coords,
            radius = radius,
            crimeType = crimeType,
            missionId = params.missionId,
            evidenceIds = {},
            status = 'active',
            createdAt = os.time()
        }

        -- Spawn evidence points around the scene
        local evidenceTypes = {'blood', 'shell_casing', 'document', 'weapon', 'phone'}

        for i = 1, evidenceCount do
            -- Random position within radius
            local angle = (i / evidenceCount) * math.pi * 2
            local dist = math.random() * radius * 0.8
            local evidenceCoords = vector3(
                coords.x + math.cos(angle) * dist,
                coords.y + math.sin(angle) * dist,
                coords.z
            )

            local evidenceType = evidenceTypes[math.random(#evidenceTypes)]

            local evidenceResult = exports['sv_nexus_tools']:ExecuteTool('spawn_evidence', {
                coords = evidenceCoords,
                evidenceType = evidenceType,
                description = 'Evidence from ' .. crimeType,
                missionId = params.missionId
            }, source)

            if evidenceResult.success then
                table.insert(ActiveCrimeScenes[sceneId].evidenceIds, evidenceResult.evidenceId)
            end
        end

        -- Create crime scene zone on client
        TriggerClientEvent('nexus:client:createCrimeScene', -1, {
            sceneId = sceneId,
            coords = coords,
            radius = radius,
            crimeType = crimeType
        })

        -- Insert into MDT
        MySQL.insert.await([[
            INSERT INTO wsb_mdt_incidents
            (id, type, description, location, status, created_at)
            VALUES (?, ?, ?, ?, 'open', NOW())
        ]], {sceneId, crimeType, 'Crime scene established', json.encode(coords)})

        Utils.Success('Crime scene created:', sceneId, 'with', #ActiveCrimeScenes[sceneId].evidenceIds, 'evidence')

        return {
            success = true,
            sceneId = sceneId,
            evidenceIds = ActiveCrimeScenes[sceneId].evidenceIds
        }
    end
})

--[[
    SPAWN BARRIER
    Creates police barriers/cones for roadblocks
]]
RegisterTool('spawn_barrier', {
    params = {'coords', 'barrierType', 'heading', 'count'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local barrierType = params.barrierType or 'barrier'
        local heading = params.heading or 0
        local count = params.count or 1

        local models = {
            barrier = 'prop_barrier_work05',
            cone = 'prop_mp_cone_02',
            spike_strip = 'p_ld_stinger_s',
            barrier_large = 'prop_barrier_work06b',
            police_barrier = 'prop_barrier_work01a'
        }

        local model = models[barrierType] or models.barrier
        local barrierId = Utils.GenerateUUID()

        ActiveBarriers[barrierId] = {
            type = barrierType,
            coords = coords,
            netIds = {},
            createdAt = os.time(),
            createdBy = Utils.GetCitizenId(source)
        }

        -- Spawn barriers in a line
        for i = 1, count do
            local offsetX = math.cos(math.rad(heading + 90)) * (i - 1) * 2
            local offsetY = math.sin(math.rad(heading + 90)) * (i - 1) * 2

            local barrierCoords = vector3(
                coords.x + offsetX,
                coords.y + offsetY,
                coords.z
            )

            local spawnResult = lib.callback.await('nexus:spawnProp', source, {
                model = model,
                coords = barrierCoords,
                heading = heading,
                frozen = true
            })

            if spawnResult and spawnResult.success then
                table.insert(ActiveBarriers[barrierId].netIds, spawnResult.netId)

                -- If spike strip, set up tire popping detection
                if barrierType == 'spike_strip' then
                    TriggerClientEvent('nexus:client:addSpikeStrip', -1, {
                        netId = spawnResult.netId,
                        coords = barrierCoords
                    })
                end
            end
        end

        Utils.Debug('Spawned barriers:', barrierId, count, 'x', barrierType)

        return {
            success = true,
            barrierId = barrierId,
            count = #ActiveBarriers[barrierId].netIds
        }
    end
})

--[[
    CREATE BOLO
    Broadcast vehicle/ped description to all police
]]
RegisterTool('create_bolo', {
    params = {'type', 'description', 'plate', 'model', 'lastSeen', 'suspectDescription', 'priority'},
    async = true,
    handler = function(params, source)
        local boloId = Utils.GenerateUUID()
        local priority = params.priority or 'medium' -- low, medium, high, critical

        ActiveBOLOs[boloId] = {
            type = params.type or 'vehicle', -- vehicle, person
            description = params.description,
            plate = params.plate,
            model = params.model,
            lastSeen = params.lastSeen,
            suspectDescription = params.suspectDescription,
            priority = priority,
            createdBy = Utils.GetCitizenId(source),
            createdAt = os.time(),
            status = 'active'
        }

        -- Insert into MDT
        MySQL.insert.await([[
            INSERT INTO wsb_mdt_bolos
            (id, type, description, plate, suspect, priority, created_by, status, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'active', NOW())
        ]], {boloId, params.type, params.description, params.plate, params.suspectDescription, priority, Utils.GetCitizenId(source)})

        -- Notify all police players
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = Utils.GetPlayer(playerId)
            if player and player.PlayerData.job.name == 'police' then
                TriggerClientEvent('nexus:client:boloAlert', playerId, {
                    boloId = boloId,
                    type = params.type,
                    description = params.description,
                    plate = params.plate,
                    priority = priority
                })

                -- Also send phone notification
                exports['sv_nexus_tools']:SendPhoneNotification(playerId, {
                    title = 'BOLO Alert - ' .. priority:upper(),
                    message = params.description,
                    icon = 'fas fa-bullhorn'
                })
            end
        end

        Utils.Success('BOLO created:', boloId)

        return {
            success = true,
            boloId = boloId
        }
    end
})

--[[
    MEDICAL TRIAGE
    Sets NPC injury state for EMS rescue
]]
RegisterTool('medical_triage', {
    params = {'coords', 'injuryType', 'severity', 'patientModel', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local injuryType = params.injuryType or 'trauma'
        local severity = params.severity or 'moderate' -- minor, moderate, severe, critical
        local model = params.patientModel or 'a_m_m_downtown_01'

        local patientId = Utils.GenerateUUID()

        -- Spawn injured NPC
        local spawnResult = lib.callback.await('nexus:spawnNpc', source, {
            model = model,
            coords = coords,
            heading = 0,
            behavior = 'cower',
            networked = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn patient'}
        end

        -- Set NPC to downed state
        TriggerClientEvent('nexus:client:setPatientState', -1, {
            netId = spawnResult.netId,
            injuryType = injuryType,
            severity = severity
        })

        -- Alert EMS
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = Utils.GetPlayer(playerId)
            if player and (player.PlayerData.job.name == 'ambulance' or player.PlayerData.job.name == 'ems') then
                TriggerClientEvent('nexus:client:medicalAlert', playerId, {
                    patientId = patientId,
                    coords = coords,
                    injuryType = injuryType,
                    severity = severity
                })

                exports['sv_nexus_tools']:SendPhoneNotification(playerId, {
                    title = 'Medical Emergency',
                    message = severity:upper() .. ' ' .. injuryType .. ' victim reported',
                    icon = 'fas fa-ambulance'
                })
            end
        end

        Utils.Debug('Medical triage created:', patientId)

        return {
            success = true,
            patientId = patientId,
            netId = spawnResult.netId
        }
    end
})

--[[
    LOCKDOWN AREA
    Creates restricted zone with police perimeter
]]
RegisterTool('lockdown_area', {
    params = {'coords', 'radius', 'reason', 'policeOnly', 'duration'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or 50.0
        local reason = params.reason or 'Police operation'
        local policeOnly = params.policeOnly ~= false
        local duration = params.duration or 600 -- 10 minutes default

        local lockdownId = Utils.GenerateUUID()

        ActiveLockdowns[lockdownId] = {
            coords = coords,
            radius = radius,
            reason = reason,
            policeOnly = policeOnly,
            createdAt = os.time(),
            expiresAt = os.time() + duration,
            status = 'active'
        }

        -- Notify all players
        TriggerClientEvent('nexus:client:createLockdown', -1, {
            lockdownId = lockdownId,
            coords = coords,
            radius = radius,
            reason = reason,
            policeOnly = policeOnly
        })

        -- Create perimeter barriers
        local barrierCount = math.floor(radius / 10) * 4
        for i = 1, barrierCount do
            local angle = (i / barrierCount) * math.pi * 2
            local barrierCoords = vector3(
                coords.x + math.cos(angle) * radius,
                coords.y + math.sin(angle) * radius,
                coords.z
            )

            exports['sv_nexus_tools']:ExecuteTool('spawn_barrier', {
                coords = barrierCoords,
                barrierType = 'police_barrier',
                heading = math.deg(angle) + 90,
                count = 1
            }, source)
        end

        -- Schedule expiry
        SetTimeout(duration * 1000, function()
            if ActiveLockdowns[lockdownId] then
                ActiveLockdowns[lockdownId].status = 'expired'
                TriggerClientEvent('nexus:client:removeLockdown', -1, {lockdownId = lockdownId})
            end
        end)

        Utils.Success('Lockdown created:', lockdownId, 'radius:', radius)

        return {
            success = true,
            lockdownId = lockdownId
        }
    end
})

-- Detection: Check if player enters lockdown
lib.callback.register('nexus:checkLockdown', function(source, data)
    local player = Utils.GetPlayer(source)
    if not player then return {allowed = false} end

    local coords = Utils.Vec3FromTable(data.coords)

    for lockdownId, lockdown in pairs(ActiveLockdowns) do
        if lockdown.status == 'active' then
            local distance = #(coords - lockdown.coords)
            if distance <= lockdown.radius then
                -- In lockdown zone
                if lockdown.policeOnly and player.PlayerData.job.name ~= 'police' then
                    return {
                        allowed = false,
                        lockdownId = lockdownId,
                        reason = lockdown.reason
                    }
                end
            end
        end
    end

    return {allowed = true}
end)

-- Exports
exports('GetActiveEvidence', function() return ActiveEvidence end)
exports('GetActiveCrimeScenes', function() return ActiveCrimeScenes end)
exports('GetActiveBOLOs', function() return ActiveBOLOs end)
exports('GetActiveLockdowns', function() return ActiveLockdowns end)
exports('GetActiveBarriers', function() return ActiveBarriers end)

return PoliceTools
