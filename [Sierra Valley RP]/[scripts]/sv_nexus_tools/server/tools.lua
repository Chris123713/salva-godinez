-- Toolbox Core - Tool Registry and Execution

local ToolRegistry = {}

-- Register a tool
function RegisterTool(name, config)
    ToolRegistry[name] = {
        name = name,
        params = config.params or {},
        handler = config.handler,
        roleHint = config.roleHint or 'any',
        async = config.async or false,
        category = config.category
    }
    Utils.Debug('Registered tool:', name)
end

-- Get tool definition
function GetTool(name)
    return ToolRegistry[name]
end

-- Execute a single tool
local function ExecuteToolInternal(toolName, params, source)
    local tool = ToolRegistry[toolName]
    if not tool then
        return {success = false, error = 'Unknown tool: ' .. tostring(toolName)}
    end

    -- Rate limit check
    local allowed, waitTime = Utils.RateLimitCheck(source, 'tool:' .. toolName, 100)
    if not allowed then
        return {success = false, error = 'Rate limited, wait ' .. waitTime .. 'ms'}
    end

    -- Execute handler
    local success, result = pcall(function()
        return tool.handler(params, source)
    end)

    if not success then
        Utils.Error('Tool execution failed:', toolName, result)
        return {success = false, error = 'Execution error'}
    end

    return result or {success = true}
end

-- Execute an array of tools
local function ExecuteToolsArrayInternal(toolsArray, source, callback)
    local results = {}
    local errors = {}
    local pending = 0
    local totalTools = #toolsArray

    if totalTools == 0 then
        if callback then
            callback({success = true, results = {}, errors = {}})
        end
        return {success = true, results = {}, errors = {}}
    end

    for i, toolCall in ipairs(toolsArray) do
        local tool = ToolRegistry[toolCall.name]
        if not tool then
            errors[#errors + 1] = {index = i, error = 'Unknown tool: ' .. toolCall.name}
        elseif tool.async then
            pending = pending + 1

            -- Async execution
            CreateThread(function()
                local result = ExecuteToolInternal(toolCall.name, toolCall.params, source)
                results[i] = result
                pending = pending - 1

                if pending == 0 and callback then
                    callback({
                        success = #errors == 0,
                        results = results,
                        errors = errors
                    })
                end
            end)
        else
            -- Sync execution
            results[i] = ExecuteToolInternal(toolCall.name, toolCall.params, source)
        end
    end

    -- If no async tools, return immediately
    if pending == 0 then
        local finalResult = {
            success = #errors == 0,
            results = results,
            errors = errors
        }
        if callback then
            callback(finalResult)
        end
        return finalResult
    end

    -- For async, return a pending indicator
    return {pending = true}
end

-- Get available tools for AI prompt building
local function GetAvailableToolsInternal()
    local tools = {}
    for name, tool in pairs(ToolRegistry) do
        tools[#tools + 1] = {
            name = name,
            description = ToolsDefinitions[name] and ToolsDefinitions[name].description or '',
            params = ToolsDefinitions[name] and ToolsDefinitions[name].params or tool.params,
            category = tool.category or ToolsDefinitions[name] and ToolsDefinitions[name].category,
            roleHint = tool.roleHint
        }
    end
    return tools
end

-- Register mission tools
RegisterTool('set_objective', {
    params = {'missionId', 'citizenid', 'objectiveId', 'status'},
    handler = function(params)
        -- This will be implemented in missions.lua
        local Missions = exports['sv_nexus_tools']:GetMissionsModule()
        if Missions then
            return Missions.SetObjective(
                params.missionId,
                params.citizenid,
                params.objectiveId,
                params.status
            )
        end
        return {success = false, error = 'Missions module not available'}
    end
})

RegisterTool('unlock_objective', {
    params = {'missionId', 'citizenid', 'objectiveId'},
    handler = function(params)
        local Missions = exports['sv_nexus_tools']:GetMissionsModule()
        if Missions then
            return Missions.SetObjective(
                params.missionId,
                params.citizenid,
                params.objectiveId,
                Constants.ObjectiveStatus.PENDING
            )
        end
        return {success = false, error = 'Missions module not available'}
    end
})

RegisterTool('trigger_dialog', {
    params = {'source', 'npcNetId', 'dialogTree'},
    handler = function(params)
        TriggerClientEvent('nexus:client:dialogStart', params.source, {
            npcNetId = params.npcNetId,
            dialogTree = params.dialogTree
        })
        return {success = true}
    end
})

RegisterTool('mark_escape_route', {
    params = {'source', 'coords', 'blipSprite', 'blipColor'},
    handler = function(params)
        local coords = Utils.Vec3FromTable(params.coords)
        TriggerClientEvent('nexus:client:setWaypoint', params.source, {
            coords = coords,
            blipSprite = params.blipSprite or 1,
            blipColor = params.blipColor or 1
        })
        return {success = true}
    end
})

RegisterTool('alert_dispatch', {
    params = {'coords', 'code', 'description'},
    async = true,
    handler = function(params)
        local coords = Utils.Vec3FromTable(params.coords)
        local alertId = Utils.GenerateUUID()

        -- Notify all police players
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = Utils.GetPlayer(playerId)
            if player and player.PlayerData.job.name == 'police' then
                TriggerClientEvent('nexus:client:dispatchAlert', playerId, {
                    alertId = alertId,
                    coords = coords,
                    code = params.code,
                    description = params.description
                })
            end
        end

        return {success = true, alertId = alertId}
    end
})

RegisterTool('spawn_enemy_wave', {
    params = {'coords', 'count', 'model', 'weapons', 'spread'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local count = params.count or 3
        local model = params.model or 's_m_y_blackops_01'
        local spread = params.spread or 10.0
        local weapons = params.weapons or {'WEAPON_PISTOL'}

        local netIds = {}

        for i = 1, count do
            -- Calculate spread position
            local angle = (i / count) * math.pi * 2
            local offsetX = math.cos(angle) * spread
            local offsetY = math.sin(angle) * spread
            local spawnCoords = vector3(
                coords.x + offsetX,
                coords.y + offsetY,
                coords.z
            )

            local result = lib.callback.await('nexus:spawnNpc', source, {
                model = model,
                coords = spawnCoords,
                heading = math.random(0, 360),
                behavior = Constants.NpcBehavior.HOSTILE,
                weapons = weapons,
                networked = true
            })

            if result and result.success then
                netIds[#netIds + 1] = result.netId
            end
        end

        return {
            success = #netIds > 0,
            netIds = netIds,
            count = #netIds
        }
    end
})

RegisterTool('create_checkpoint', {
    params = {'coords', 'radius', 'objectiveId', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local radius = params.radius or 5.0
        local zoneId = 'checkpoint_' .. Utils.GenerateUUID()

        -- Notify relevant clients to create zone
        -- This will be handled by the networking module
        TriggerClientEvent('nexus:client:createCheckpoint', -1, {
            zoneId = zoneId,
            coords = coords,
            radius = radius,
            objectiveId = params.objectiveId,
            missionId = params.missionId
        })

        return {success = true, zoneId = zoneId}
    end
})

-- Event handler for tool execution from clients/other resources
RegisterNetEvent('nexus:server:executeTools', function(toolsArray, missionContext)
    local src = source

    -- Validate source
    if not Utils.HasPermission(src, 'command.nexus') and not missionContext then
        Utils.Error('Unauthorized tool execution attempt from', src)
        return
    end

    ExecuteToolsArrayInternal(toolsArray, src, function(result)
        TriggerClientEvent('nexus:client:toolsComplete', src, result)
    end)
end)

-- Exports
exports('ExecuteTool', ExecuteToolInternal)
exports('ExecuteToolsArray', ExecuteToolsArrayInternal)
exports('GetAvailableTools', GetAvailableToolsInternal)
exports('RegisterTool', RegisterTool)
exports('GetTool', GetTool)

-- Make global for other server files
_G.RegisterTool = RegisterTool
_G.GetTool = GetTool
