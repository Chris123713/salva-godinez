-- Criminal Tools with Database Integration and Detection

local CriminalTools = {}

-- Active hacking sessions for detection
local ActiveHackSessions = {}

-- Active hostage situations
local ActiveHostages = {}

-- Active vehicle trackers
local ActiveTrackers = {}

--[[
    HACK TERMINAL
    Spawns a hackable terminal that requires minigame completion
    Returns a password/phrase for Mr. X verification
]]
RegisterTool('hack_terminal', {
    params = {'coords', 'difficulty', 'passwordType', 'missionId', 'objectiveId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local difficulty = params.difficulty or 'medium'
        local passwordType = params.passwordType or 'alphanumeric'

        -- Generate password based on type
        local password
        if passwordType == 'alphanumeric' then
            password = GenerateAlphanumericPassword(8)
        elseif passwordType == 'phrase' then
            password = GeneratePhrase()
        elseif passwordType == 'numeric' then
            password = GenerateNumericPassword(6)
        end

        local terminalId = Utils.GenerateUUID()

        -- Spawn terminal prop via client
        local spawnResult = lib.callback.await('nexus:spawnProp', source, {
            model = 'prop_laptop_01a',
            coords = coords,
            heading = 0,
            interactive = true,
            frozen = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn terminal'}
        end

        -- Store hack session for detection
        ActiveHackSessions[terminalId] = {
            netId = spawnResult.netId,
            coords = coords,
            difficulty = difficulty,
            password = password,
            missionId = params.missionId,
            objectiveId = params.objectiveId,
            createdAt = os.time(),
            completedBy = nil,
            status = 'pending'
        }

        -- Add ox_target to terminal
        TriggerClientEvent('nexus:client:addHackTerminal', -1, {
            netId = spawnResult.netId,
            terminalId = terminalId,
            difficulty = difficulty
        })

        Utils.Debug('Created hack terminal:', terminalId, 'password:', password)

        return {
            success = true,
            terminalId = terminalId,
            netId = spawnResult.netId,
            password = password -- Mr. X can verify this
        }
    end
})

-- Generate password helpers
function GenerateAlphanumericPassword(length)
    local chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    local password = ''
    for i = 1, length do
        local idx = math.random(1, #chars)
        password = password .. chars:sub(idx, idx)
    end
    return password
end

function GenerateNumericPassword(length)
    local password = ''
    for i = 1, length do
        password = password .. tostring(math.random(0, 9))
    end
    return password
end

function GeneratePhrase()
    local phrases = {
        'DELTA WOLF',
        'SHADOW NINE',
        'ECHO BRAVO',
        'NIGHT HAWK',
        'RED ALPHA',
        'GHOST SEVEN',
        'STORM RIDER',
        'BLACK LOTUS'
    }
    return phrases[math.random(#phrases)]
end

-- Client callback for hack completion
lib.callback.register('nexus:completeHack', function(source, data)
    local session = ActiveHackSessions[data.terminalId]
    if not session then
        return {success = false, error = 'Session not found'}
    end

    if session.status ~= 'pending' then
        return {success = false, error = 'Already completed'}
    end

    local citizenid = Utils.GetCitizenId(source)

    -- Verify minigame was passed
    if data.success then
        session.status = 'completed'
        session.completedBy = citizenid
        session.completedAt = os.time()

        -- Update mission objective if linked
        if session.missionId and session.objectiveId then
            exports['sv_nexus_tools']:SetMissionObjective(
                session.missionId,
                citizenid,
                session.objectiveId,
                Constants.ObjectiveStatus.COMPLETED
            )
        end

        -- Return password to player for Mr. X
        return {
            success = true,
            password = session.password,
            message = 'Access granted. Code: ' .. session.password
        }
    else
        -- Failed attempt - could trigger alarm
        session.failedAttempts = (session.failedAttempts or 0) + 1

        if session.failedAttempts >= 3 then
            -- Trigger alarm
            exports['sv_nexus_tools']:ExecuteTool('alert_dispatch', {
                coords = session.coords,
                code = '10-31',
                description = 'Silent alarm triggered at terminal'
            }, source)
        end

        return {success = false, error = 'Hack failed'}
    end
end)

--[[
    CREATE HOSTAGE SITUATION
    Converts an NPC to hostage with negotiation states
]]
RegisterTool('create_hostage_situation', {
    params = {'coords', 'npcModel', 'missionId', 'criminalCitizenid'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local model = params.npcModel or 'a_f_y_business_01'

        local hostageId = Utils.GenerateUUID()

        -- Spawn hostage NPC
        local spawnResult = lib.callback.await('nexus:spawnNpc', source, {
            model = model,
            coords = coords,
            heading = 0,
            behavior = 'cower',
            networked = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn hostage'}
        end

        ActiveHostages[hostageId] = {
            netId = spawnResult.netId,
            coords = coords,
            missionId = params.missionId,
            criminalCitizenid = params.criminalCitizenid,
            status = 'held', -- held, negotiating, released, dead
            demands = {},
            createdAt = os.time()
        }

        -- Alert police
        exports['sv_nexus_tools']:ExecuteTool('alert_dispatch', {
            coords = coords,
            code = '10-35',
            description = 'Hostage situation reported'
        }, source)

        -- Create lockdown area around hostage
        exports['sv_nexus_tools']:ExecuteTool('lockdown_area', {
            coords = coords,
            radius = 50.0,
            reason = 'Hostage situation',
            policeOnly = false
        }, source)

        Utils.Debug('Created hostage situation:', hostageId)

        return {
            success = true,
            hostageId = hostageId,
            netId = spawnResult.netId
        }
    end
})

-- Hostage negotiation handler
lib.callback.register('nexus:negotiateHostage', function(source, data)
    local hostage = ActiveHostages[data.hostageId]
    if not hostage then
        return {success = false, error = 'Hostage not found'}
    end

    local citizenid = Utils.GetCitizenId(source)
    local player = Utils.GetPlayer(source)
    local isPolice = player and player.PlayerData.job.name == 'police'

    if data.action == 'release' then
        -- Criminal releases hostage
        if hostage.criminalCitizenid == citizenid then
            hostage.status = 'released'

            -- Complete criminal objective
            if hostage.missionId then
                exports['sv_nexus_tools']:SetMissionObjective(
                    hostage.missionId,
                    citizenid,
                    'release_hostage',
                    Constants.ObjectiveStatus.COMPLETED
                )
            end

            return {success = true, message = 'Hostage released'}
        end
    elseif data.action == 'demand' and hostage.criminalCitizenid == citizenid then
        -- Criminal sets demands
        hostage.demands = data.demands
        hostage.status = 'negotiating'

        -- Notify police
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local p = Utils.GetPlayer(playerId)
            if p and p.PlayerData.job.name == 'police' then
                TriggerClientEvent('nexus:client:hostageUpdate', playerId, {
                    hostageId = data.hostageId,
                    demands = data.demands,
                    status = 'negotiating'
                })
            end
        end

        return {success = true}
    elseif data.action == 'accept_demands' and isPolice then
        -- Police accepts demands
        hostage.status = 'demands_accepted'

        return {success = true, message = 'Demands accepted'}
    end

    return {success = false, error = 'Invalid action'}
end)

--[[
    SPAWN LOOT CONTAINER
    Creates a searchable container with specific target item + bonus items
]]
RegisterTool('spawn_loot_container', {
    params = {'coords', 'containerModel', 'targetItem', 'bonusItems', 'missionId', 'objectiveId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local model = params.containerModel or 'prop_box_wood02a'

        local containerId = Utils.GenerateUUID()

        -- Spawn container prop
        local spawnResult = lib.callback.await('nexus:spawnProp', source, {
            model = model,
            coords = coords,
            heading = math.random(0, 360),
            interactive = true,
            frozen = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn container'}
        end

        -- Create ox_inventory stash for this container
        local stashId = 'nexus_loot_' .. containerId

        -- Prepare items
        local items = {}

        -- Add target item
        if params.targetItem then
            items[#items + 1] = {
                name = params.targetItem.name,
                count = params.targetItem.count or 1,
                metadata = params.targetItem.metadata or {mission = params.missionId}
            }
        end

        -- Add bonus items
        if params.bonusItems then
            for _, item in ipairs(params.bonusItems) do
                items[#items + 1] = {
                    name = item.name,
                    count = item.count or 1,
                    metadata = item.metadata
                }
            end
        end

        -- Register stash and add items
        exports.ox_inventory:RegisterStash(stashId, 'Mission Loot', 10, 50000)
        for _, item in ipairs(items) do
            exports.ox_inventory:AddItem(stashId, item.name, item.count, item.metadata)
        end

        -- Add ox_target to container
        TriggerClientEvent('nexus:client:addLootContainer', -1, {
            netId = spawnResult.netId,
            containerId = containerId,
            stashId = stashId,
            targetItem = params.targetItem and params.targetItem.name,
            missionId = params.missionId,
            objectiveId = params.objectiveId
        })

        Utils.Debug('Created loot container:', containerId)

        return {
            success = true,
            containerId = containerId,
            netId = spawnResult.netId,
            stashId = stashId
        }
    end
})

-- Detection: Monitor when target item is taken
RegisterNetEvent('nexus:server:lootTaken', function(data)
    local src = source
    local citizenid = Utils.GetCitizenId(src)

    -- Check if target item was taken
    if data.missionId and data.objectiveId then
        local hasItem = exports.ox_inventory:Search(src, 'count', data.targetItem)
        if hasItem and hasItem > 0 then
            exports['sv_nexus_tools']:SetMissionObjective(
                data.missionId,
                citizenid,
                data.objectiveId,
                Constants.ObjectiveStatus.COMPLETED
            )
        end
    end
end)

--[[
    VEHICLE TRACKER
    Attaches GPS tracker to vehicle for mission tracking
]]
RegisterTool('vehicle_tracker', {
    params = {'vehicleNetId', 'trackerType', 'missionId', 'visibleToRoles'},
    async = true,
    handler = function(params, source)
        local trackerId = Utils.GenerateUUID()

        ActiveTrackers[trackerId] = {
            vehicleNetId = params.vehicleNetId,
            trackerType = params.trackerType or 'gps', -- gps, radio, visual
            missionId = params.missionId,
            visibleToRoles = params.visibleToRoles or {'police', 'criminal'},
            installedBy = Utils.GetCitizenId(source),
            installedAt = os.time(),
            active = true
        }

        -- Query vehicle info from database
        local vehicleEntity = NetworkGetEntityFromNetworkId(params.vehicleNetId)
        local plate = GetVehicleNumberPlateText(vehicleEntity)

        -- Store in database for persistence
        MySQL.insert.await([[
            INSERT INTO nexus_vehicle_trackers (tracker_id, vehicle_plate, mission_id, installed_by, installed_at)
            VALUES (?, ?, ?, ?, NOW())
        ]], {trackerId, plate, params.missionId, Utils.GetCitizenId(source)})

        -- Notify eligible players
        local mission = exports['sv_nexus_tools']:GetMission(params.missionId)
        if mission then
            for citizenid, participant in pairs(mission.participants) do
                if Utils.TableContains(params.visibleToRoles, participant.role) then
                    local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
                    if playerSource then
                        TriggerClientEvent('nexus:client:addVehicleTracker', playerSource, {
                            trackerId = trackerId,
                            vehicleNetId = params.vehicleNetId,
                            trackerType = params.trackerType
                        })
                    end
                end
            end
        end

        Utils.Debug('Installed tracker:', trackerId, 'on vehicle')

        return {
            success = true,
            trackerId = trackerId
        }
    end
})

-- Tracker position update thread
CreateThread(function()
    while true do
        Wait(5000) -- Update every 5 seconds

        for trackerId, tracker in pairs(ActiveTrackers) do
            if tracker.active then
                local entity = NetworkGetEntityFromNetworkId(tracker.vehicleNetId)
                if DoesEntityExist(entity) then
                    local coords = GetEntityCoords(entity)

                    -- Broadcast to eligible players
                    local mission = exports['sv_nexus_tools']:GetMission(tracker.missionId)
                    if mission then
                        for citizenid, participant in pairs(mission.participants) do
                            if Utils.TableContains(tracker.visibleToRoles, participant.role) then
                                local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
                                if playerSource then
                                    TriggerClientEvent('nexus:client:updateTracker', playerSource, {
                                        trackerId = trackerId,
                                        coords = coords
                                    })
                                end
                            end
                        end
                    end
                else
                    -- Vehicle no longer exists
                    tracker.active = false
                end
            end
        end
    end
end)

--[[
    FORGE IDENTITY
    Creates temporary fake identity documents
]]
RegisterTool('forge_identity', {
    params = {'source', 'fakeName', 'fakeJob', 'duration', 'cost'},
    async = true,
    handler = function(params)
        local player = Utils.GetPlayer(params.source)
        if not player then
            return {success = false, error = 'Player not found'}
        end

        local citizenid = player.PlayerData.citizenid
        local duration = params.duration or 3600 -- 1 hour default
        local cost = params.cost or 5000

        -- Check and deduct money
        if player.PlayerData.money.cash < cost then
            return {success = false, error = 'Insufficient funds'}
        end

        exports.qbx_core:RemoveMoney(params.source, 'cash', cost, 'Forged documents')

        -- Store real identity
        local realIdentity = {
            firstname = player.PlayerData.charinfo.firstname,
            lastname = player.PlayerData.charinfo.lastname,
            job = player.PlayerData.job.name
        }

        -- Generate fake name if not provided
        local fakeName = params.fakeName or GenerateFakeName()
        local fakeJob = params.fakeJob or 'unemployed'

        local forgeId = Utils.GenerateUUID()

        -- Create fake license item with metadata
        local fakeMetadata = {
            firstname = fakeName.first,
            lastname = fakeName.last,
            citizenid = 'FAKE' .. math.random(10000, 99999),
            job = fakeJob,
            forgeId = forgeId,
            expiresAt = os.time() + duration
        }

        exports.ox_inventory:AddItem(params.source, 'id_card', 1, fakeMetadata)

        -- Store in database for detection
        MySQL.insert.await([[
            INSERT INTO nexus_forged_identities
            (forge_id, real_citizenid, fake_name, fake_job, expires_at, created_at)
            VALUES (?, ?, ?, ?, FROM_UNIXTIME(?), NOW())
        ]], {forgeId, citizenid, fakeName.first .. ' ' .. fakeName.last, fakeJob, os.time() + duration})

        -- Schedule expiry
        SetTimeout(duration * 1000, function()
            -- Remove fake ID
            exports.ox_inventory:RemoveItem(params.source, 'id_card', 1, fakeMetadata)

            -- Notify player
            TriggerClientEvent('ox_lib:notify', params.source, {
                title = 'Forged Documents',
                description = 'Your fake ID has expired',
                type = 'warning'
            })
        end)

        Utils.Success('Forged identity created for', citizenid)

        return {
            success = true,
            forgeId = forgeId,
            fakeName = fakeName,
            expiresIn = duration
        }
    end
})

function GenerateFakeName()
    local firstNames = {'James', 'Michael', 'Robert', 'John', 'David', 'William', 'Richard', 'Joseph', 'Thomas', 'Charles'}
    local lastNames = {'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'}

    return {
        first = firstNames[math.random(#firstNames)],
        last = lastNames[math.random(#lastNames)]
    }
end

-- Utility helper
function Utils.TableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- Exports
exports('GetActiveHackSessions', function() return ActiveHackSessions end)
exports('GetActiveHostages', function() return ActiveHostages end)
exports('GetActiveTrackers', function() return ActiveTrackers end)

return CriminalTools
