-- Main client entry point

-- Mission state
local CurrentMission = nil
local MissionBlips = {}
local MissionCheckpoints = {}

-- Adaptive tick thread
local function StartAdaptiveTick()
    CreateThread(function()
        while true do
            local sleep = Config.Performance.AdaptiveTickFar

            if CurrentMission then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local missionCoords = CurrentMission.area

                if missionCoords then
                    local distance = #(playerCoords - vector3(missionCoords.x, missionCoords.y, missionCoords.z))
                    if distance < 100.0 then
                        sleep = Config.Performance.AdaptiveTickNear
                    end
                end

                -- Check objectives proximity
                for objectiveId, objective in pairs(CurrentMission.objectives or {}) do
                    if objective.coords and objective.status == Constants.ObjectiveStatus.PENDING then
                        if ClientUtils.IsNear(objective.coords, 50.0) then
                            sleep = Config.Performance.AdaptiveTickNear
                            break
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

-- Handle mission start
RegisterNetEvent('nexus:client:missionStart', function(data)
    CurrentMission = {
        id = data.missionId,
        brief = data.brief,
        role = data.role,
        objectives = data.objectives,
        area = data.area
    }

    -- Create mission blip
    if data.area then
        local blip = ClientUtils.CreateBlip(
            vector3(data.area.x, data.area.y, data.area.z),
            161, -- Mission star
            1,   -- Red
            'Mission: ' .. data.brief:sub(1, 30)
        )
        MissionBlips[data.missionId] = blip
    end

    -- Show notification
    lib.notify({
        title = 'Mission Started',
        description = data.brief,
        type = 'info',
        duration = 8000
    })

    -- Show objectives
    if data.objectives then
        for objectiveId, objective in pairs(data.objectives) do
            if objective.status == Constants.ObjectiveStatus.PENDING then
                ClientUtils.Notify('Objective', objectiveId:gsub('_', ' '):gsub('^%l', string.upper), 'info')
            end
        end
    end

    ClientUtils.PlaySound('SUCCESS')
    ClientUtils.Debug('Mission started:', data.missionId)
end)

-- Handle objective update
RegisterNetEvent('nexus:client:objectiveUpdate', function(data)
    if not CurrentMission or CurrentMission.id ~= data.missionId then return end

    if CurrentMission.objectives[data.objectiveId] then
        CurrentMission.objectives[data.objectiveId].status = data.status
    end

    local objectiveName = data.objectiveId:gsub('_', ' '):gsub('^%l', string.upper)

    if data.status == Constants.ObjectiveStatus.COMPLETED then
        lib.notify({
            title = 'Objective Complete',
            description = objectiveName,
            type = 'success',
            duration = 5000
        })
        ClientUtils.PlaySound('SUCCESS')
    elseif data.status == Constants.ObjectiveStatus.FAILED then
        lib.notify({
            title = 'Objective Failed',
            description = data.reason or objectiveName,
            type = 'error',
            duration = 5000
        })
        ClientUtils.PlaySound('ERROR')
    elseif data.status == Constants.ObjectiveStatus.PENDING and data.oldStatus == Constants.ObjectiveStatus.LOCKED then
        lib.notify({
            title = 'New Objective',
            description = objectiveName,
            type = 'info',
            duration = 5000
        })
    end
end)

-- Handle mission complete
RegisterNetEvent('nexus:client:missionComplete', function(data)
    if not CurrentMission or CurrentMission.id ~= data.missionId then return end

    -- Clean up blips
    if MissionBlips[data.missionId] then
        ClientUtils.RemoveBlip(MissionBlips[data.missionId])
        MissionBlips[data.missionId] = nil
    end

    -- Show completion
    if data.status == Constants.MissionStatus.COMPLETED then
        lib.notify({
            title = 'Mission Complete!',
            description = data.brief,
            type = 'success',
            duration = 10000
        })
    else
        lib.notify({
            title = 'Mission Failed',
            description = data.brief,
            type = 'error',
            duration = 10000
        })
    end

    CurrentMission = nil
    ClientUtils.PlaySound('SUCCESS')
end)

-- Handle mission delta sync
RegisterNetEvent('nexus:client:missionDelta', function(missionId, delta)
    if not CurrentMission or CurrentMission.id ~= missionId then return end

    -- Apply delta updates
    for key, value in pairs(delta) do
        CurrentMission[key] = value
    end
end)

-- Handle entity sync
RegisterNetEvent('nexus:client:entitySync', function(data)
    -- Entity sync handled by spawning module
    ClientUtils.Debug('Entity sync:', data.entityType, data.netId)
end)

-- Handle waypoint setting
RegisterNetEvent('nexus:client:setWaypoint', function(data)
    local coords = data.coords

    -- Create blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, data.blipSprite or 1)
    SetBlipColour(blip, data.blipColor or 1)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, data.blipColor or 1)

    -- Set waypoint
    SetNewWaypoint(coords.x, coords.y)

    ClientUtils.Notify('Waypoint Set', 'Route marked on GPS', 'info')
end)

-- Handle dispatch alert (for police)
RegisterNetEvent('nexus:client:dispatchAlert', function(data)
    local coords = data.coords

    -- Create blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.2)
    SetBlipFlashes(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.code .. ': ' .. data.description)
    EndTextCommandSetBlipName(blip)

    -- Auto-remove blip after 5 minutes
    SetTimeout(300000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)

    lib.notify({
        title = 'Dispatch Alert',
        description = ('%s: %s'):format(data.code, data.description),
        type = 'error',
        duration = 10000
    })

    ClientUtils.PlaySound('ERROR')
end)

-- Handle performance stats display
RegisterNetEvent('nexus:client:showPerf', function(stats)
    lib.alertDialog({
        header = 'Nexus Tools Performance',
        content = ('**Active Missions:** %d\n**Cached Blueprints:** %d'):format(
            stats.activeMissions or 0,
            stats.cachedBlueprints or 0
        )
    })
end)

-- Handle tools completion
RegisterNetEvent('nexus:client:toolsComplete', function(result)
    if result.success then
        ClientUtils.Notify('Tools Executed', 'All tools completed successfully', 'success')
    else
        ClientUtils.Notify('Tools Error', 'Some tools failed to execute', 'error')
    end
    ClientUtils.Debug('Tools result:', json.encode(result))
end)

-- Dialog outcome handler (server side, but needs client trigger registration)
RegisterNetEvent('nexus:server:dialogOutcome', function(data)
    -- Handled server-side
end)

-- Profile generation request handler
RegisterNetEvent('nexus:server:generateProfile', function(data)
    -- Forward to server for AI generation
end)

-- Request dialog from server
RegisterNetEvent('nexus:server:requestDialog', function(data)
    -- Handled server-side
end)

-- Checkpoint reached handler
RegisterNetEvent('nexus:server:checkpointReached', function(data)
    -- Handled server-side
end)

-- Pickup prop handler
RegisterNetEvent('nexus:server:pickupProp', function(data)
    -- Handled server-side
end)

-- Get current mission export
exports('GetCurrentMission', function()
    return CurrentMission
end)

-- Initialize
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        StartAdaptiveTick()
        ClientUtils.Debug('sv_nexus_tools client initialized')
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Remove all mission blips
        for _, blip in pairs(MissionBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end
end)

-- Debug command
RegisterCommand('nexusMission', function()
    if CurrentMission then
        print('^3[Current Mission]^7')
        print('ID:', CurrentMission.id)
        print('Brief:', CurrentMission.brief)
        print('Role:', CurrentMission.role)
        print('Objectives:', json.encode(CurrentMission.objectives))
    else
        print('^3[No active mission]^7')
    end
end, false)

-- Performance debug command
local perfEnabled = false
RegisterCommand('nexusPerfClient', function()
    perfEnabled = not perfEnabled

    if perfEnabled then
        ClientUtils.Notify('Debug', 'Performance monitoring enabled', 'info')
        CreateThread(function()
            while perfEnabled do
                local start = GetGameTimer()

                -- Simulate typical frame work
                if CurrentMission then
                    local _ = #(GetEntityCoords(PlayerPedId()) - vector3(0, 0, 0))
                end

                local elapsed = GetGameTimer() - start
                if elapsed > 1 then
                    print(('^1[PERF]^7 Frame took %dms'):format(elapsed))
                end

                Wait(0)
            end
        end)
    else
        ClientUtils.Notify('Debug', 'Performance monitoring disabled', 'info')
    end
end, false)
