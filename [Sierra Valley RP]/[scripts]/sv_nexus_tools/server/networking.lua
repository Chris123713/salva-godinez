-- Network Synchronization Module

local Networking = {}

-- Last sent state for delta sync
local LastSentState = {}

-- Sync mission state to participant
function Networking.SyncMissionState(source, missionId)
    local mission = exports['sv_nexus_tools']:GetMission(missionId)
    if not mission then return end

    local citizenid = Utils.GetCitizenId(source)
    if not citizenid then return end

    local participant = mission.participants[citizenid]
    if not participant then return end

    local currentState = {
        id = missionId,
        status = mission.status,
        brief = mission.brief,
        role = participant.role,
        objectives = participant.objectives
    }

    local stateKey = tostring(source) .. ':' .. missionId
    local lastState = LastSentState[stateKey] or {}

    -- Calculate delta
    local delta = {}
    for key, value in pairs(currentState) do
        if type(value) == 'table' then
            -- Deep compare for tables
            if json.encode(lastState[key]) ~= json.encode(value) then
                delta[key] = value
            end
        elseif lastState[key] ~= value then
            delta[key] = value
        end
    end

    -- Only send if there are changes
    if next(delta) then
        TriggerClientEvent('nexus:client:missionDelta', source, missionId, delta)
        LastSentState[stateKey] = currentState
    end
end

-- Sync entity to all participants
function Networking.SyncEntity(missionId, entityType, netId, data)
    local mission = exports['sv_nexus_tools']:GetMission(missionId)
    if not mission then return end

    for citizenid, _ in pairs(mission.participants) do
        local source = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
        if source then
            TriggerClientEvent('nexus:client:entitySync', source, {
                missionId = missionId,
                entityType = entityType,
                netId = netId,
                data = data
            })
        end
    end
end

-- Broadcast to all mission participants
function Networking.BroadcastToMission(missionId, eventName, data)
    local mission = exports['sv_nexus_tools']:GetMission(missionId)
    if not mission then return end

    for citizenid, _ in pairs(mission.participants) do
        local source = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
        if source then
            TriggerClientEvent(eventName, source, data)
        end
    end
end

-- Periodic state sync thread
CreateThread(function()
    while true do
        Wait(Config.Missions.ObjectiveSyncIntervalMs)

        local missions = exports['sv_nexus_tools']:GetAllMissions()
        for missionId, mission in pairs(missions) do
            if mission.status == Constants.MissionStatus.ACTIVE then
                for citizenid, _ in pairs(mission.participants) do
                    local source = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
                    if source then
                        Networking.SyncMissionState(source, missionId)
                    end
                end
            end
        end
    end
end)

-- Clean up last sent state on player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    for key, _ in pairs(LastSentState) do
        if key:find('^' .. src .. ':') then
            LastSentState[key] = nil
        end
    end
end)

-- Client callback registrations
lib.callback.register('nexus:spawnNpc', function(source, data)
    -- This is handled client-side, but server validates
    return nil
end)

lib.callback.register('nexus:spawnVehicle', function(source, data)
    return nil
end)

lib.callback.register('nexus:spawnProp', function(source, data)
    return nil
end)

lib.callback.register('nexus:verifyZone', function(source, data)
    return nil
end)

-- Exports
exports('SyncMissionState', Networking.SyncMissionState)
exports('SyncEntity', Networking.SyncEntity)
exports('BroadcastToMission', Networking.BroadcastToMission)

return Networking
