-- Multi-Player Mission Tool Handlers

-- Track active mission timers
local MissionTimers = {}

-- ============================================
-- HANDOFF POINTS (Baton-Pass Missions)
-- ============================================

RegisterTool('create_handoff_point', {
    params = {'coords', 'item', 'from_citizenid', 'to_citizenid', 'mission_id', 'timeout_minutes'},
    category = Constants.ToolCategory.MULTIPLAYER,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local item = params.item
        local fromCitizenId = params.from_citizenid
        local toCitizenId = params.to_citizenid
        local missionId = params.mission_id
        local timeoutMinutes = params.timeout_minutes or 30

        local handoffId = Utils.GenerateUUID()
        local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (timeoutMinutes * 60))

        -- Insert handoff point
        local success = MySQL.insert.await([[
            INSERT INTO nexus_handoff_points
            (id, mission_id, coords, item_name, from_citizenid, to_citizenid, status, expires_at)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', ?)
        ]], {
            handoffId,
            missionId,
            json.encode({x = coords.x, y = coords.y, z = coords.z}),
            item,
            fromCitizenId,
            toCitizenId,
            expiresAt
        })

        if not success then
            return {success = false, error = 'Failed to create handoff point'}
        end

        -- Notify the "from" player about drop location
        local fromSource = GetPlayerByCitizenId(fromCitizenId)
        if fromSource then
            TriggerClientEvent('nexus:client:handoffDropLocation', fromSource, {
                handoffId = handoffId,
                coords = coords,
                item = item,
                timeout = timeoutMinutes
            })
        end

        Utils.Success('Created handoff point:', handoffId)
        return {success = true, handoff_id = handoffId}
    end
})

-- Event: Player dropped item at handoff point
RegisterNetEvent('nexus:server:handoffDropped', function(handoffId)
    local src = source
    local citizenid = Utils.GetCitizenId(src)

    -- Update handoff status
    local affected = MySQL.update.await([[
        UPDATE nexus_handoff_points
        SET status = 'dropped', dropped_at = NOW()
        WHERE id = ? AND from_citizenid = ? AND status = 'pending'
    ]], {handoffId, citizenid})

    if affected > 0 then
        -- Get handoff details
        local handoff = MySQL.single.await([[
            SELECT * FROM nexus_handoff_points WHERE id = ?
        ]], {handoffId})

        if handoff then
            -- Notify the "to" player about pickup
            local toSource = GetPlayerByCitizenId(handoff.to_citizenid)
            if toSource then
                local coords = json.decode(handoff.coords)
                TriggerClientEvent('nexus:client:handoffPickupAvailable', toSource, {
                    handoffId = handoffId,
                    coords = coords,
                    item = handoff.item_name
                })
            end
        end

        Utils.Debug('Handoff dropped:', handoffId)
    end
end)

-- Event: Player picked up handoff item
RegisterNetEvent('nexus:server:handoffPickedUp', function(handoffId)
    local src = source
    local citizenid = Utils.GetCitizenId(src)

    -- Update handoff status
    local affected = MySQL.update.await([[
        UPDATE nexus_handoff_points
        SET status = 'picked_up', picked_up_at = NOW()
        WHERE id = ? AND to_citizenid = ? AND status = 'dropped'
    ]], {handoffId, citizenid})

    if affected > 0 then
        -- Get handoff details for mission update
        local handoff = MySQL.single.await([[
            SELECT * FROM nexus_handoff_points WHERE id = ?
        ]], {handoffId})

        if handoff and handoff.mission_id then
            -- Update participant's handoff status
            MySQL.update.await([[
                UPDATE nexus_mission_participants
                SET handoff_completed = TRUE
                WHERE mission_id = ? AND citizenid = ?
            ]], {handoff.mission_id, citizenid})
        end

        Utils.Debug('Handoff picked up:', handoffId)
    end
end)

-- ============================================
-- ADVERSARIAL MISSIONS
-- ============================================

RegisterTool('create_adversarial_mission', {
    params = {'mission_type', 'player_a_citizenid', 'player_a_objective', 'player_b_citizenid', 'player_b_objective', 'shared_target', 'reveal_opponent'},
    category = Constants.ToolCategory.MULTIPLAYER,
    async = true,
    handler = function(params, source)
        local missionType = params.mission_type
        local playerACitizenId = params.player_a_citizenid
        local playerAObjective = params.player_a_objective
        local playerBCitizenId = params.player_b_citizenid
        local playerBObjective = params.player_b_objective
        local sharedTarget = params.shared_target
        local revealOpponent = params.reveal_opponent or false

        -- Create mission
        local Missions = exports['sv_nexus_tools']:GetMissionsModule()
        if not Missions then
            return {success = false, error = 'Missions module not available'}
        end

        local mission = Missions.Create(missionType, {
            brief = 'Adversarial mission',
            area = sharedTarget.value and sharedTarget.value.coords and Utils.Vec3FromTable(sharedTarget.value.coords),
            rewards = {money = {type = 'cash', amount = 5000}}
        })

        if not mission then
            return {success = false, error = 'Failed to create mission'}
        end

        -- Add participants with adversarial role type
        Missions.AddParticipant(mission.id, playerACitizenId, 'player_a', {'complete_objective', 'secure_target'})
        Missions.AddParticipant(mission.id, playerBCitizenId, 'player_b', {'complete_objective', 'secure_target'})

        -- Update participants with adversarial link
        MySQL.update.await([[
            UPDATE nexus_mission_participants
            SET role_type = 'adversarial'
            WHERE mission_id = ? AND citizenid IN (?, ?)
        ]], {mission.id, playerACitizenId, playerBCitizenId})

        -- Notify players with their objectives
        local playerASource = GetPlayerByCitizenId(playerACitizenId)
        local playerBSource = GetPlayerByCitizenId(playerBCitizenId)

        if playerASource then
            TriggerClientEvent('nexus:client:adversarialMissionStart', playerASource, {
                missionId = mission.id,
                objective = playerAObjective,
                target = sharedTarget,
                opponentRevealed = revealOpponent,
                opponentCitizenId = revealOpponent and playerBCitizenId or nil
            })
        end

        if playerBSource then
            TriggerClientEvent('nexus:client:adversarialMissionStart', playerBSource, {
                missionId = mission.id,
                objective = playerBObjective,
                target = sharedTarget,
                opponentRevealed = revealOpponent,
                opponentCitizenId = revealOpponent and playerACitizenId or nil
            })
        end

        -- Start mission
        Missions.Start(mission.id)

        Utils.Success('Created adversarial mission:', mission.id)
        return {success = true, mission_id = mission.id}
    end
})

-- ============================================
-- LINK PARTICIPANTS
-- ============================================

RegisterTool('link_participants', {
    params = {'mission_id', 'participant_a_citizenid', 'participant_b_citizenid', 'link_type'},
    category = Constants.ToolCategory.MULTIPLAYER,
    handler = function(params)
        local missionId = params.mission_id
        local participantA = params.participant_a_citizenid
        local participantB = params.participant_b_citizenid
        local linkType = params.link_type

        -- Get participant IDs
        local rowA = MySQL.single.await([[
            SELECT id FROM nexus_mission_participants WHERE mission_id = ? AND citizenid = ?
        ]], {missionId, participantA})

        local rowB = MySQL.single.await([[
            SELECT id FROM nexus_mission_participants WHERE mission_id = ? AND citizenid = ?
        ]], {missionId, participantB})

        if not rowA or not rowB then
            return {success = false, error = 'One or both participants not found'}
        end

        -- Update both with link
        MySQL.update.await([[
            UPDATE nexus_mission_participants
            SET role_type = ?, linked_participant_id = ?
            WHERE id = ?
        ]], {linkType, rowB.id, rowA.id})

        MySQL.update.await([[
            UPDATE nexus_mission_participants
            SET role_type = ?, linked_participant_id = ?
            WHERE id = ?
        ]], {linkType, rowA.id, rowB.id})

        return {success = true}
    end
})

-- ============================================
-- MISSION TIMERS
-- ============================================

RegisterTool('start_mission_timer', {
    params = {'mission_id', 'duration_seconds', 'fail_on_expire', 'show_to_sources'},
    category = Constants.ToolCategory.MISSION,
    handler = function(params)
        local missionId = params.mission_id
        local duration = params.duration_seconds
        local failOnExpire = params.fail_on_expire ~= false
        local showToSources = params.show_to_sources

        local timerId = Utils.GenerateUUID()
        local expiresAt = GetGameTimer() + (duration * 1000)

        MissionTimers[missionId] = {
            id = timerId,
            expires_at = expiresAt,
            duration = duration,
            fail_on_expire = failOnExpire,
            active = true
        }

        -- Notify specified players
        if showToSources then
            for _, playerSource in ipairs(showToSources) do
                TriggerClientEvent('nexus:client:missionTimerStart', playerSource, {
                    missionId = missionId,
                    duration = duration
                })
            end
        else
            -- Notify all mission participants
            local mission = exports['sv_nexus_tools']:GetMission(missionId)
            if mission then
                for citizenid, _ in pairs(mission.participants) do
                    local playerSource = GetPlayerByCitizenId(citizenid)
                    if playerSource then
                        TriggerClientEvent('nexus:client:missionTimerStart', playerSource, {
                            missionId = missionId,
                            duration = duration
                        })
                    end
                end
            end
        end

        -- Schedule expiry check
        SetTimeout(duration * 1000, function()
            local timer = MissionTimers[missionId]
            if timer and timer.active then
                timer.active = false
                if timer.fail_on_expire then
                    -- Fail the mission
                    local Missions = exports['sv_nexus_tools']:GetMissionsModule()
                    if Missions then
                        Missions.Complete(missionId, Constants.MissionStatus.FAILED)
                    end
                end
            end
        end)

        return {success = true, timer_id = timerId}
    end
})

RegisterTool('check_mission_timer', {
    params = {'mission_id'},
    category = Constants.ToolCategory.MISSION,
    handler = function(params)
        local missionId = params.mission_id
        local timer = MissionTimers[missionId]

        if not timer then
            return {active = false, remaining_seconds = 0, expired = true}
        end

        local now = GetGameTimer()
        local remaining = math.max(0, timer.expires_at - now) / 1000

        return {
            active = timer.active,
            remaining_seconds = remaining,
            expired = remaining <= 0
        }
    end
})

RegisterTool('cancel_mission_timer', {
    params = {'mission_id'},
    category = Constants.ToolCategory.MISSION,
    handler = function(params)
        local missionId = params.mission_id
        local timer = MissionTimers[missionId]

        if timer then
            timer.active = false
            MissionTimers[missionId] = nil

            -- Notify participants
            local mission = exports['sv_nexus_tools']:GetMission(missionId)
            if mission then
                for citizenid, _ in pairs(mission.participants) do
                    local playerSource = GetPlayerByCitizenId(citizenid)
                    if playerSource then
                        TriggerClientEvent('nexus:client:missionTimerCancel', playerSource, {
                            missionId = missionId
                        })
                    end
                end
            end

            return {success = true}
        end

        return {success = false, error = 'Timer not found'}
    end
})

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Get player source by citizen ID
function GetPlayerByCitizenId(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = Utils.GetPlayer(playerId)
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

-- ============================================
-- MISSION DRAFT TOOLS
-- ============================================

RegisterTool('generate_mission_draft', {
    params = {'archetype', 'pattern', 'area_coords', 'difficulty', 'player_count'},
    category = Constants.ToolCategory.MISSION,
    async = true,
    handler = function(params, source)
        local archetype = params.archetype
        local pattern = params.pattern
        local areaCoords = params.area_coords and Utils.Vec3FromTable(params.area_coords)
        local difficulty = params.difficulty or 'medium'
        local playerCount = params.player_count or 1

        -- Call OpenAI to generate draft
        local GenerateMissionDraft = exports['sv_nexus_tools']:GenerateMissionDraft
        if not GenerateMissionDraft then
            return {success = false, error = 'Draft generation not available'}
        end

        local draftId = Utils.GenerateUUID()

        -- Insert draft record
        MySQL.insert.await([[
            INSERT INTO nexus_mission_drafts
            (id, type, target_archetype, pattern_id, area_coords, status, created_by)
            VALUES (?, ?, ?, ?, ?, 'draft', ?)
        ]], {
            draftId,
            pattern or 'general',
            archetype,
            pattern,
            areaCoords and json.encode({x = areaCoords.x, y = areaCoords.y, z = areaCoords.z}),
            Utils.GetCitizenId(source) or tostring(source)
        })

        -- Generate draft asynchronously via OpenAI
        GenerateMissionDraft(source, {
            archetype = archetype,
            pattern = pattern,
            difficulty = difficulty,
            playerCount = playerCount,
            areaCoords = areaCoords
        }, function(result)
            if result and result.success then
                -- Update draft with generated content
                MySQL.update.await([[
                    UPDATE nexus_mission_drafts
                    SET synopsis = ?, story_brief = ?, intended_outcomes = ?, required_assets = ?
                    WHERE id = ?
                ]], {
                    result.synopsis,
                    result.story_brief,
                    result.intended_outcomes and json.encode(result.intended_outcomes),
                    result.required_assets and json.encode(result.required_assets),
                    draftId
                })

                -- Notify admin
                TriggerClientEvent('nexus:client:draftGenerated', source, {
                    draftId = draftId,
                    synopsis = result.synopsis,
                    required_assets = result.required_assets
                })
            end
        end)

        return {
            success = true,
            draft_id = draftId,
            synopsis = 'Generating...',
            required_assets = {}
        }
    end
})

RegisterTool('get_mission_draft', {
    params = {'draft_id'},
    category = Constants.ToolCategory.MISSION,
    handler = function(params)
        local draftId = params.draft_id

        local draft = MySQL.single.await([[
            SELECT * FROM nexus_mission_drafts WHERE id = ?
        ]], {draftId})

        if draft then
            draft.intended_outcomes = draft.intended_outcomes and json.decode(draft.intended_outcomes)
            draft.required_assets = draft.required_assets and json.decode(draft.required_assets)
            draft.area_coords = draft.area_coords and json.decode(draft.area_coords)
            return {success = true, draft = draft}
        end

        return {success = false, error = 'Draft not found'}
    end
})

RegisterTool('instantiate_draft', {
    params = {'draft_id', 'target_citizenid'},
    category = Constants.ToolCategory.MISSION,
    async = true,
    handler = function(params, source)
        local draftId = params.draft_id
        local targetCitizenId = params.target_citizenid

        local draft = MySQL.single.await([[
            SELECT * FROM nexus_mission_drafts WHERE id = ? AND status = 'ready'
        ]], {draftId})

        if not draft then
            return {success = false, error = 'Draft not found or not ready'}
        end

        -- Create mission from draft
        local Missions = exports['sv_nexus_tools']:GetMissionsModule()
        if not Missions then
            return {success = false, error = 'Missions module not available'}
        end

        local areaCoords = draft.area_coords and json.decode(draft.area_coords)
        local requiredAssets = draft.required_assets and json.decode(draft.required_assets)

        local mission = Missions.Create(draft.type, {
            brief = draft.synopsis,
            area = areaCoords and Utils.Vec3FromTable(areaCoords),
            rewards = {money = {type = 'cash', amount = 2500}}
        })

        if not mission then
            return {success = false, error = 'Failed to create mission'}
        end

        -- Add participant
        Missions.AddParticipant(mission.id, targetCitizenId, 'primary', {'complete_objective'})

        -- Update draft status
        MySQL.update.await([[
            UPDATE nexus_mission_drafts SET status = 'instantiated' WHERE id = ?
        ]], {draftId})

        -- Spawn elements from required assets
        if requiredAssets then
            for _, asset in ipairs(requiredAssets) do
                if asset.element_id then
                    -- Spawn from existing element
                    exports['sv_nexus_tools']:ExecuteTool('spawn_from_element', {
                        element_id = asset.element_id,
                        mission_id = mission.id,
                        role = asset.role or 'asset'
                    }, source)
                end
            end
        end

        -- Start mission
        Missions.Start(mission.id)

        Utils.Success('Instantiated draft', draftId, 'as mission', mission.id)
        return {success = true, mission_id = mission.id}
    end
})

Utils.Success('Registered multiplayer tools')
