-- Main server entry point

local BlueprintCache = {}

-- Load blueprints from JSON
local function LoadBlueprints()
    local data = LoadResourceFile(GetCurrentResourceName(), 'data/blueprints.json')
    if data then
        local parsed = Utils.JsonDecode(data)
        if parsed and parsed.blueprints then
            BlueprintCache = parsed.blueprints
            Utils.Success('Loaded', #BlueprintCache, 'blueprints')
        end
    else
        Utils.Debug('No blueprints file found')
    end
end

-- Save blueprints to JSON
local function SaveBlueprints()
    local data = json.encode({blueprints = BlueprintCache}, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), 'data/blueprints.json', data, -1)
    Utils.Success('Saved', #BlueprintCache, 'blueprints')
end

-- Get blueprint by ID
local function GetBlueprint(blueprintId)
    for _, bp in ipairs(BlueprintCache) do
        if bp.id == blueprintId then
            return bp
        end
    end
    return nil
end

-- Get blueprints by type
local function GetBlueprintsByType(missionType)
    local results = {}
    for _, bp in ipairs(BlueprintCache) do
        if bp.type == missionType then
            results[#results + 1] = bp
        end
    end
    return results
end

-- Add new blueprint
local function AddBlueprint(blueprint)
    if not blueprint.id then
        blueprint.id = 'bp_' .. Utils.GenerateUUID():sub(1, 8)
    end
    BlueprintCache[#BlueprintCache + 1] = blueprint
    SaveBlueprints()
    return blueprint.id
end

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadBlueprints()
        Utils.Success('sv_nexus_tools initialized')
    end
end)

-- Test commands (admin only)
RegisterCommand('testTool', function(source, args)
    if source > 0 and not Utils.HasPermission(source, 'command.nexus') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Access Denied',
            type = 'error'
        })
        return
    end

    if #args < 1 then
        print('Usage: /testTool <toolName> [param:value ...]')
        return
    end

    local toolName = args[1]
    local params = {source = source}

    -- Parse params like key:value
    for i = 2, #args do
        local key, value = args[i]:match('([^:]+):(.+)')
        if key and value then
            -- Try to parse numbers
            if tonumber(value) then
                value = tonumber(value)
            elseif value == 'true' then
                value = true
            elseif value == 'false' then
                value = false
            end
            params[key] = value
        end
    end

    local result = exports['sv_nexus_tools']:ExecuteTool(toolName, params, source)
    print('^2[testTool]^7 Result:', json.encode(result))

    if source > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Tool Result',
            description = result.success and 'Success' or (result.error or 'Failed'),
            type = result.success and 'success' or 'error'
        })
    end
end, true)

RegisterCommand('testOpenAI', function(source, args)
    if source > 0 and not Utils.HasPermission(source, 'command.nexus') then
        return
    end

    local prompt = table.concat(args, ' ')
    if prompt == '' then
        prompt = 'Generate a brief heist description for a GTA V roleplay server.'
    end

    print('^3[testOpenAI]^7 Sending prompt:', prompt)

    CallOpenAI(prompt, nil, function(success, content, error)
        if success then
            print('^2[testOpenAI]^7 Response:', content)
        else
            print('^1[testOpenAI]^7 Error:', error)
        end

        if source > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'OpenAI Test',
                description = success and 'Check server console' or error,
                type = success and 'success' or 'error'
            })
        end
    end)
end, true)

RegisterCommand('testMission', function(source, args)
    if source > 0 and not Utils.HasPermission(source, 'command.nexus') then
        return
    end

    local missionType = args[1] or 'criminal'
    local citizenid = Utils.GetCitizenId(source) or 'test_citizen'

    print('^3[testMission]^7 Generating', missionType, 'mission for', citizenid)

    local playerContext = {
        citizenid = citizenid,
        job = 'unemployed'
    }

    GenerateAIProfile(missionType, playerContext, function(success, profile, error)
        if not success then
            print('^1[testMission]^7 Profile generation failed:', error)
            return
        end

        print('^2[testMission]^7 Profile:', json.encode(profile))

        -- Create mission
        local mission, createError = exports['sv_nexus_tools']:CreateMission(missionType, profile, source)
        if not mission then
            print('^1[testMission]^7 Mission creation failed:', createError)
            return
        end

        -- Add participant
        local objectives = profile.objectives and profile.objectives[missionType] or {'test_objective'}
        exports['sv_nexus_tools']:AddMissionParticipant(mission.id, citizenid, missionType, objectives)

        -- Start mission
        exports['sv_nexus_tools']:StartMission(mission.id)

        if source > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Test Mission Created',
                description = mission.brief,
                type = 'success'
            })
        end
    end)
end, true)

RegisterCommand('nexusPerf', function(source)
    local stats = {
        activeMissions = Utils.TableSize(exports['sv_nexus_tools']:GetAllMissions()),
        cachedBlueprints = #BlueprintCache
    }

    print('^3[nexusPerf]^7 Stats:', json.encode(stats))

    if source > 0 then
        TriggerClientEvent('nexus:client:showPerf', source, stats)
    end
end, true)

-- Generate mission for player (for Mr. X integration)
local function GenerateMissionForPlayer(source, missionType)
    local player = Utils.GetPlayer(source)
    if not player then
        return nil, 'Player not found'
    end

    local context = {
        citizenid = player.PlayerData.citizenid,
        job = player.PlayerData.job.name
    }

    local result = {pending = true}

    GenerateAIProfile(missionType, context, function(success, profile, error)
        if not success then
            result = {success = false, error = error}
            return
        end

        GenerateToolsArray(profile, {context.job}, function(toolSuccess, tools, toolError)
            if not toolSuccess then
                result = {success = false, error = toolError}
                return
            end

            -- Execute tools
            exports['sv_nexus_tools']:ExecuteToolsArray(tools, source, function(execResult)
                result = {
                    success = true,
                    profile = profile,
                    toolResults = execResult
                }
            end)
        end)
    end)

    return result
end

-- Spawn mission from blueprint
local function SpawnMissionFromBlueprint(blueprintId, participants)
    local blueprint = GetBlueprint(blueprintId)
    if not blueprint then
        return nil, 'Blueprint not found'
    end

    -- Create mission from blueprint profile
    local mission, err = exports['sv_nexus_tools']:CreateMission(blueprint.type, blueprint)
    if not mission then
        return nil, err
    end

    -- Add participants
    for citizenid, role in pairs(participants or {}) do
        local objectives = blueprint.objectives and blueprint.objectives[role]
        exports['sv_nexus_tools']:AddMissionParticipant(mission.id, citizenid, role, objectives)
    end

    -- Spawn elements
    if blueprint.elements then
        for _, element in ipairs(blueprint.elements) do
            local coords = Utils.Vec4FromTable(element.coords)

            if element.type == 'npc' then
                -- Would trigger client spawn
                -- For now, just track intention
                Utils.Debug('Would spawn NPC:', element.model, 'at', coords)
            elseif element.type == 'vehicle' then
                Utils.Debug('Would spawn vehicle:', element.model, 'at', coords)
            elseif element.type == 'prop' then
                Utils.Debug('Would spawn prop:', element.model, 'at', coords)
            end
        end
    end

    return mission
end

-- Exports for Mr. X integration
exports('GenerateMissionForPlayer', GenerateMissionForPlayer)
exports('SpawnMissionFromBlueprint', SpawnMissionFromBlueprint)
exports('GetBlueprint', GetBlueprint)
exports('GetBlueprintsByType', GetBlueprintsByType)
exports('AddBlueprint', AddBlueprint)
exports('SaveBlueprints', SaveBlueprints)

-- Event handler for saving blueprints from mission creator
RegisterNetEvent('nexus:server:saveBlueprint', function(blueprint)
    local src = source
    if not Utils.HasPermission(src, 'command.nexus') then
        Utils.Error('Unauthorized blueprint save attempt from', src)
        return
    end

    local id = AddBlueprint(blueprint)
    Utils.Success('Blueprint saved:', id, 'by', src)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Blueprint Saved',
        description = 'ID: ' .. id,
        type = 'success'
    })
end)

-- Active mission query for player
lib.callback.register('nexus:getActiveMission', function(source)
    local citizenid = Utils.GetCitizenId(source)
    if not citizenid then return nil end

    local mission = exports['sv_nexus_tools']:GetMissionByParticipant(citizenid)
    if not mission then return nil end

    local participant = mission.participants[citizenid]
    return {
        id = mission.id,
        type = mission.type,
        status = mission.status,
        brief = mission.brief,
        role = participant.role,
        objectives = participant.objectives
    }
end)
