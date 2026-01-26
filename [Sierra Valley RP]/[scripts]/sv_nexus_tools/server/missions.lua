-- Networked Mission System

local Missions = {}

-- Active missions cache
local ActiveMissions = {}

-- Create a new mission
function Missions.Create(missionType, profile, creatorSource)
    local missionId = Utils.GenerateUUID()

    local mission = {
        id = missionId,
        type = missionType,
        brief = profile.brief or 'Mission',
        area = Utils.Vec3FromTable(profile.area or vector3(0, 0, 0)),

        -- Entity tracking
        entities = {
            npcs = {},
            vehicles = {},
            props = {}
        },

        -- Participant objectives
        participants = {},

        -- Mission state
        status = Constants.MissionStatus.SETUP,
        createdAt = os.time(),
        createdBy = creatorSource,

        -- Profile for AI regeneration
        profile = profile
    }

    -- Check max missions
    if Utils.TableSize(ActiveMissions) >= Config.Missions.MaxActiveMissions then
        return nil, 'Maximum active missions reached'
    end

    ActiveMissions[missionId] = mission
    Utils.Success('Created mission:', missionId, '-', mission.brief)

    return mission
end

-- Get mission by ID
function Missions.Get(missionId)
    return ActiveMissions[missionId]
end

-- Get all active missions
function Missions.GetAll()
    return ActiveMissions
end

-- Get mission by participant
function Missions.GetByParticipant(citizenid)
    for missionId, mission in pairs(ActiveMissions) do
        if mission.participants[citizenid] then
            return mission
        end
    end
    return nil
end

-- Add participant to mission
function Missions.AddParticipant(missionId, citizenid, role, objectives)
    local mission = ActiveMissions[missionId]
    if not mission then
        return false, 'Mission not found'
    end

    if Utils.TableSize(mission.participants) >= Config.Missions.MaxParticipants then
        return false, 'Mission full'
    end

    mission.participants[citizenid] = {
        role = role,
        joinedAt = os.time(),
        objectives = {}
    }

    -- Set up objectives
    if objectives then
        for i, objectiveId in ipairs(objectives) do
            mission.participants[citizenid].objectives[objectiveId] = {
                id = objectiveId,
                status = i == 1 and Constants.ObjectiveStatus.PENDING or Constants.ObjectiveStatus.LOCKED,
                completedAt = nil
            }
        end
    end

    Utils.Debug('Added participant', citizenid, 'to mission', missionId, 'as', role)
    return true
end

-- Remove participant from mission
function Missions.RemoveParticipant(missionId, citizenid)
    local mission = ActiveMissions[missionId]
    if not mission then return false end

    mission.participants[citizenid] = nil

    -- If no participants left, schedule cleanup
    if Utils.TableSize(mission.participants) == 0 then
        Missions.ScheduleCleanup(missionId)
    end

    return true
end

-- Set objective status
function Missions.SetObjective(missionId, citizenid, objectiveId, status)
    local mission = ActiveMissions[missionId]
    if not mission then
        return {success = false, error = 'Mission not found'}
    end

    local participant = mission.participants[citizenid]
    if not participant then
        return {success = false, error = 'Participant not found'}
    end

    local objective = participant.objectives[objectiveId]
    if not objective then
        return {success = false, error = 'Objective not found'}
    end

    local oldStatus = objective.status
    objective.status = status

    if status == Constants.ObjectiveStatus.COMPLETED then
        objective.completedAt = os.time()

        -- Unlock next objective
        local unlockNext = true
        for oid, obj in pairs(participant.objectives) do
            if obj.status == Constants.ObjectiveStatus.LOCKED and unlockNext then
                obj.status = Constants.ObjectiveStatus.PENDING
                unlockNext = false
            end
        end

        -- Check for conflicting objectives in other roles
        Missions.HandleObjectiveConflicts(missionId, citizenid, objectiveId)
    end

    -- Sync to participant
    local source = Missions.GetParticipantSource(citizenid)
    if source then
        TriggerClientEvent('nexus:client:objectiveUpdate', source, {
            missionId = missionId,
            objectiveId = objectiveId,
            status = status,
            oldStatus = oldStatus
        })
    end

    Utils.Debug('Objective', objectiveId, 'set to', status, 'for', citizenid)

    -- Check mission completion
    Missions.CheckCompletion(missionId)

    return {success = true}
end

-- Handle conflicting objectives between roles
function Missions.HandleObjectiveConflicts(missionId, completedBy, objectiveId)
    local mission = ActiveMissions[missionId]
    if not mission then return end

    -- Define conflict mappings
    local conflicts = {
        steal_vehicle = {police = 'prevent_theft'},
        escape_area = {police = 'arrest_suspect'},
        complete_delivery = {criminal = 'intercept_delivery'}
    }

    local objectiveConflicts = conflicts[objectiveId]
    if not objectiveConflicts then return end

    local completedByRole = mission.participants[completedBy] and mission.participants[completedBy].role

    for citizenid, participant in pairs(mission.participants) do
        if citizenid ~= completedBy then
            local conflictingObjective = objectiveConflicts[participant.role]
            if conflictingObjective and participant.objectives[conflictingObjective] then
                local obj = participant.objectives[conflictingObjective]
                if obj.status == Constants.ObjectiveStatus.PENDING or obj.status == Constants.ObjectiveStatus.ACTIVE then
                    obj.status = Constants.ObjectiveStatus.FAILED

                    local source = Missions.GetParticipantSource(citizenid)
                    if source then
                        TriggerClientEvent('nexus:client:objectiveUpdate', source, {
                            missionId = missionId,
                            objectiveId = conflictingObjective,
                            status = Constants.ObjectiveStatus.FAILED,
                            reason = 'Objective failed by opposing player'
                        })
                    end
                end
            end
        end
    end
end

-- Check if mission is complete
function Missions.CheckCompletion(missionId)
    local mission = ActiveMissions[missionId]
    if not mission then return end

    local allComplete = true
    local anyFailed = false

    for citizenid, participant in pairs(mission.participants) do
        for objectiveId, objective in pairs(participant.objectives) do
            if objective.status ~= Constants.ObjectiveStatus.COMPLETED and
               objective.status ~= Constants.ObjectiveStatus.FAILED and
               objective.status ~= Constants.ObjectiveStatus.LOCKED then
                allComplete = false
            end
            if objective.status == Constants.ObjectiveStatus.FAILED then
                anyFailed = true
            end
        end
    end

    if allComplete then
        if anyFailed then
            Missions.Complete(missionId, Constants.MissionStatus.FAILED)
        else
            Missions.Complete(missionId, Constants.MissionStatus.COMPLETED)
        end
    end
end

-- Complete a mission
function Missions.Complete(missionId, status)
    local mission = ActiveMissions[missionId]
    if not mission then return end

    mission.status = status
    mission.completedAt = os.time()

    -- Notify all participants
    for citizenid, participant in pairs(mission.participants) do
        local source = Missions.GetParticipantSource(citizenid)
        if source then
            TriggerClientEvent('nexus:client:missionComplete', source, {
                missionId = missionId,
                status = status,
                brief = mission.brief
            })

            -- Award rewards if completed
            if status == Constants.MissionStatus.COMPLETED and mission.profile and mission.profile.rewards then
                local rewards = mission.profile.rewards

                -- Award based on role
                if rewards.money then
                    exports['sv_nexus_tools']:AwardMoney(
                        source,
                        rewards.money.type or 'cash',
                        rewards.money.amount,
                        'Mission: ' .. missionId
                    )
                end

                if rewards.items then
                    for _, item in ipairs(rewards.items) do
                        exports['sv_nexus_tools']:AwardItem(source, item.name, item.count)
                    end
                end
            end
        end
    end

    Utils.Success('Mission', missionId, 'completed with status:', status)
    Missions.ScheduleCleanup(missionId)
end

-- Schedule mission cleanup
function Missions.ScheduleCleanup(missionId)
    SetTimeout(Config.Missions.CleanupDelayMs, function()
        Missions.Cleanup(missionId)
    end)
end

-- Cleanup mission
function Missions.Cleanup(missionId)
    local mission = ActiveMissions[missionId]
    if not mission then return end

    -- Delete all spawned entities
    for netId, _ in pairs(mission.entities.npcs) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    for netId, _ in pairs(mission.entities.vehicles) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    for netId, _ in pairs(mission.entities.props) do
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end

    ActiveMissions[missionId] = nil
    Utils.Debug('Cleaned up mission:', missionId)
end

-- Get source from citizen ID
function Missions.GetParticipantSource(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = Utils.GetPlayer(playerId)
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

-- Track entity in mission
function Missions.TrackEntity(missionId, entityType, netId, data)
    local mission = ActiveMissions[missionId]
    if not mission then return false end

    local container = mission.entities[entityType .. 's']
    if container then
        container[netId] = data or true
        return true
    end
    return false
end

-- Start mission (transition from setup to active)
function Missions.Start(missionId)
    local mission = ActiveMissions[missionId]
    if not mission then
        return false, 'Mission not found'
    end

    if mission.status ~= Constants.MissionStatus.SETUP then
        return false, 'Mission already started'
    end

    mission.status = Constants.MissionStatus.ACTIVE
    mission.startedAt = os.time()

    -- Notify all participants
    for citizenid, participant in pairs(mission.participants) do
        local source = Missions.GetParticipantSource(citizenid)
        if source then
            TriggerClientEvent('nexus:client:missionStart', source, {
                missionId = missionId,
                brief = mission.brief,
                role = participant.role,
                objectives = participant.objectives
            })
        end
    end

    Utils.Success('Mission started:', missionId)
    return true
end

-- Exports
exports('CreateMission', Missions.Create)
exports('GetMission', Missions.Get)
exports('GetAllMissions', Missions.GetAll)
exports('GetMissionByParticipant', Missions.GetByParticipant)
exports('AddMissionParticipant', Missions.AddParticipant)
exports('RemoveMissionParticipant', Missions.RemoveParticipant)
exports('SetMissionObjective', Missions.SetObjective)
exports('StartMission', Missions.Start)
exports('CompleteMission', Missions.Complete)
exports('CleanupMission', Missions.Cleanup)
exports('TrackMissionEntity', Missions.TrackEntity)
exports('GetMissionsModule', function() return Missions end)

return Missions
