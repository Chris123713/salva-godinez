--[[
    Mr. X Tools Executor
    ====================
    Executes AI tool calls and manages the agent loop.

    The agent loop:
    1. AI receives trigger/context
    2. AI decides which tools to call
    3. Executor runs the tools
    4. Results fed back to AI
    5. AI decides next action or finishes

    This transforms Mr. X from "text generator" to "autonomous agent"
]]

local Executor = {}

-- Handler registry (populated by tools_handlers.lua)
local Handlers = {}

-- Agent prompt cache
local AgentPromptCache = nil

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function JsonDecode(str)
    if str == nil or str == '' then return nil end
    local success, result = pcall(json.decode, str)
    return success and result or nil
end

local function GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

-- ============================================
-- PROMPT LOADING
-- ============================================

---Load the agent system prompt
---@return string prompt
local function LoadAgentPrompt()
    if AgentPromptCache then
        return AgentPromptCache
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local file = io.open(resourcePath .. '/data/MR_X_AGENT_PROMPT.md', 'r')

    if file then
        AgentPromptCache = file:read('*all')
        file:close()
        return AgentPromptCache
    end

    -- Fallback minimal prompt
    AgentPromptCache = [[
You are Mr. X, an autonomous criminal fixer AI. You make DECISIONS and take ACTIONS using tools.
- Query context BEFORE making decisions
- Keep messages SHORT and CRYPTIC
- Never reveal your identity
- Reward competence, punish failure
    ]]

    return AgentPromptCache
end

-- ============================================
-- HANDLER REGISTRATION
-- ============================================

---Register a tool handler
---@param name string Tool name
---@param handler table { execute: function, requiresSafety?: boolean }
function Executor.RegisterHandler(name, handler)
    Handlers[name] = handler
    if Config.Debug then
        print('^3[MR_X:TOOLS]^7 Registered handler: ' .. name)
    end
end

---Get a registered handler
---@param name string
---@return table|nil handler
function Executor.GetHandler(name)
    return Handlers[name]
end

-- ============================================
-- TOOL EXECUTION
-- ============================================

---Execute a single tool call
---@param toolCall table OpenAI tool_call object
---@param context table Execution context
---@return table result
function Executor.ExecuteTool(toolCall, context)
    local funcData = toolCall['function']
    local name = funcData.name
    local argsStr = funcData.arguments

    -- Parse arguments
    local args = JsonDecode(argsStr) or {}

    -- Find handler
    local handler = Handlers[name]
    if not handler then
        return {
            success = false,
            error = 'Unknown tool: ' .. name,
            tool = name
        }
    end

    -- Safety check for harmful tools
    if handler.requiresSafety then
        local allowed, err = exports['sv_mr_x']:CheckSafetyLimit(name, args.citizenid)
        if not allowed then
            return {
                success = false,
                error = err or 'Safety limit reached',
                blocked = true,
                tool = name
            }
        end
    end

    -- Execute the handler
    local success, result = pcall(handler.execute, args, context)

    if not success then
        -- Handler threw an error
        return {
            success = false,
            error = tostring(result),
            tool = name
        }
    end

    -- Ensure result has success field
    if type(result) ~= 'table' then
        result = { success = true, result = result }
    end
    if result.success == nil then
        result.success = true
    end

    result.tool = name

    -- Log execution
    Executor.LogExecution(name, args, result.success ~= false, result, context)

    return result
end

---Execute multiple tool calls
---@param toolCalls table Array of tool_call objects
---@param context table Execution context
---@return table results Array of {tool_call_id, result}
function Executor.ExecuteToolCalls(toolCalls, context)
    local results = {}

    for i, call in ipairs(toolCalls) do
        local result = Executor.ExecuteTool(call, context)

        results[i] = {
            tool_call_id = call.id,
            result = result
        }

        -- Small delay between tool calls to prevent rate limiting
        Wait(100)
    end

    return results
end

-- ============================================
-- AGENT LOOP
-- ============================================

---Run the agent loop (AI decides, executes, sees results, decides again)
---@param trigger string The trigger/prompt for the agent
---@param context table Context information
---@param maxIterations? number Maximum loop iterations (default 5)
---@return table result { complete: bool, message?: string, iterations: number, actions?: table }
function Executor.RunAgentLoop(trigger, context, maxIterations)
    maxIterations = maxIterations or 5

    -- Check if sv_nexus_tools is available
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        return {
            complete = false,
            message = 'sv_nexus_tools not available',
            iterations = 0
        }
    end

    -- Generate a unique ID for this thought burst
    local thoughtBurstId = GenerateUUID()
    local startTime = os.time()

    -- Get tools schema
    local schema = exports['sv_mr_x']:GetToolsSchema()

    -- Load system prompt and inject personality context
    local systemPrompt = LoadAgentPrompt()

    -- Inject personality context if citizenid is in context
    if context.citizenid then
        local personalityContext = exports['sv_mr_x']:BuildPersonalityContext(context.citizenid) or ''
        systemPrompt = systemPrompt:gsub('{{personality}}', personalityContext)
    else
        systemPrompt = systemPrompt:gsub('{{personality}}', '')
    end

    -- Build initial messages
    local messages = {
        { role = 'system', content = systemPrompt },
        { role = 'user', content = trigger }
    }

    local allActions = {}
    local reasoningSteps = {}
    local toolExecutions = {}

    -- Emit thought burst START event for Brain Feed
    Executor.EmitThoughtBurst({
        id = thoughtBurstId,
        phase = 'start',
        trigger = {
            type = context.trigger_type or 'unknown',
            citizenid = context.citizenid,
            prompt = trigger
        },
        timestamp = startTime
    })

    for i = 1, maxIterations do
        local iterationStart = os.time()

        -- Emit thinking step
        table.insert(reasoningSteps, {
            step = i,
            phase = 'thinking',
            thought = 'Analyzing situation and deciding next action...',
            timestamp = iterationStart
        })

        -- Call OpenAI with tools
        local response = Executor.CallOpenAIWithTools(messages, schema)

        if not response then
            -- Emit failure
            Executor.EmitThoughtBurst({
                id = thoughtBurstId,
                phase = 'error',
                error = 'OpenAI call failed',
                iteration = i,
                timestamp = os.time()
            })
            return {
                complete = false,
                message = 'OpenAI call failed',
                iterations = i
            }
        end

        -- Check if AI returned tool calls
        if not response.tool_calls or #response.tool_calls == 0 then
            -- AI finished - returned text response

            -- Add final reasoning step
            table.insert(reasoningSteps, {
                step = i,
                phase = 'decision',
                thought = response.content or 'Decided to take no further action.',
                timestamp = os.time()
            })

            -- Emit thought burst COMPLETE event
            Executor.EmitThoughtBurst({
                id = thoughtBurstId,
                phase = 'complete',
                trigger = {
                    type = context.trigger_type or 'unknown',
                    citizenid = context.citizenid
                },
                reasoning = reasoningSteps,
                decision = response.content,
                actions = toolExecutions,
                iterations = i,
                duration = os.time() - startTime,
                timestamp = os.time()
            })

            return {
                complete = true,
                message = response.content,
                iterations = i,
                actions = allActions
            }
        end

        -- AI wants to execute tools
        -- Add reasoning step about tool selection
        local toolNames = {}
        for _, tc in ipairs(response.tool_calls) do
            table.insert(toolNames, tc['function'].name)
        end

        table.insert(reasoningSteps, {
            step = i,
            phase = 'tool_selection',
            thought = string.format('Decided to use: %s', table.concat(toolNames, ', ')),
            tools = toolNames,
            timestamp = os.time()
        })

        -- Emit tool execution step
        Executor.EmitThoughtBurst({
            id = thoughtBurstId,
            phase = 'executing',
            iteration = i,
            tools = toolNames,
            timestamp = os.time()
        })

        -- Execute all tool calls
        local results = Executor.ExecuteToolCalls(response.tool_calls, context)

        -- Track actions and results
        for j, r in ipairs(results) do
            local toolCall = response.tool_calls[j]
            local toolName = toolCall['function'].name
            local toolArgs = JsonDecode(toolCall['function'].arguments) or {}

            table.insert(allActions, {
                tool = r.result.tool,
                success = r.result.success,
                blocked = r.result.blocked
            })

            table.insert(toolExecutions, {
                tool = toolName,
                args = toolArgs,
                success = r.result.success ~= false,
                blocked = r.result.blocked,
                result = r.result,
                timestamp = os.time()
            })

            -- Add reasoning step about tool result
            local resultSummary = r.result.success ~= false and 'Success' or ('Failed: ' .. (r.result.error or 'unknown'))
            if r.result.blocked then
                resultSummary = 'Blocked by safety limit'
            end

            table.insert(reasoningSteps, {
                step = i,
                phase = 'tool_result',
                thought = string.format('%s -> %s', toolName, resultSummary),
                tool = toolName,
                success = r.result.success ~= false,
                timestamp = os.time()
            })
        end

        -- Add assistant's tool calls to conversation
        table.insert(messages, {
            role = 'assistant',
            content = response.content,
            tool_calls = response.tool_calls
        })

        -- Add tool results to conversation for AI to see
        for _, r in ipairs(results) do
            table.insert(messages, {
                role = 'tool',
                tool_call_id = r.tool_call_id,
                content = JsonEncode(r.result)
            })
        end
    end

    -- Max iterations reached
    Executor.EmitThoughtBurst({
        id = thoughtBurstId,
        phase = 'complete',
        trigger = {
            type = context.trigger_type or 'unknown',
            citizenid = context.citizenid
        },
        reasoning = reasoningSteps,
        decision = 'Max iterations reached - stopping agent loop.',
        actions = toolExecutions,
        iterations = maxIterations,
        duration = os.time() - startTime,
        timestamp = os.time(),
        maxIterationsReached = true
    })

    return {
        complete = false,
        message = 'Max iterations reached',
        iterations = maxIterations,
        actions = allActions
    }
end

-- ============================================
-- BRAIN FEED EMISSION
-- ============================================

---Emit a thought burst event to the dashboard for Brain Feed visualization
---@param data table Thought burst data
function Executor.EmitThoughtBurst(data)
    if not Config.WebServer or not Config.WebServer.Enabled then return end

    -- Determine event type for Brain Feed categorization
    local eventType = 'agent'
    if data.actions then
        for _, action in ipairs(data.actions) do
            if action.tool == 'place_bounty' or action.tool == 'trigger_surprise' then
                eventType = 'harm'
                break
            elseif action.tool == 'offer_loan' or action.tool == 'offer_mission' then
                eventType = 'reward'
                break
            elseif action.tool == 'send_message' then
                eventType = 'message'
            end
        end
    end

    -- Send to dashboard webhook
    exports['sv_mr_x']:PostWebhook('thought_burst', {
        id = data.id,
        type = eventType,
        phase = data.phase,
        trigger = data.trigger,
        reasoning = data.reasoning,
        decision = data.decision,
        actions = data.actions,
        iterations = data.iterations,
        duration = data.duration,
        timestamp = data.timestamp,
        error = data.error,
        maxIterationsReached = data.maxIterationsReached
    })

    if Config.Debug then
        print(string.format('^3[MR_X:BRAIN]^7 Thought burst [%s]: %s', data.phase, data.id))
    end
end

-- ============================================
-- OPENAI INTEGRATION
-- ============================================

---Call OpenAI with function calling support
---@param messages table Conversation messages
---@param tools table Tool schemas
---@return table|nil response
function Executor.CallOpenAIWithTools(messages, tools)
    -- Use sv_nexus_tools for the API call
    local success, response = pcall(function()
        return exports['sv_nexus_tools']:CallOpenAI({
            model = Config.OpenAI and Config.OpenAI.Model or 'gpt-4o-mini',
            temperature = 0.7,
            max_tokens = 1000,
            messages = messages,
            tools = tools,
            tool_choice = 'auto'
        })
    end)

    if not success then
        if Config.Debug then
            print('^1[MR_X:TOOLS]^7 OpenAI call failed: ' .. tostring(response))
        end
        return nil
    end

    -- Extract the assistant message
    if response and response.choices and response.choices[1] then
        return response.choices[1].message
    end

    return response
end

-- ============================================
-- LOGGING
-- ============================================

---Log tool execution to database
---@param name string Tool name
---@param args table Tool arguments
---@param success boolean Execution success
---@param result table Execution result
---@param context table Execution context
function Executor.LogExecution(name, args, success, result, context)
    MySQL.insert([[
        INSERT INTO mr_x_tool_log (tool_name, arguments, target_citizenid, result, success, trigger_type)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        name,
        JsonEncode(args),
        args.citizenid,
        JsonEncode(result),
        success,
        context.trigger_type or 'unknown'
    })

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhook('tool_execution', {
            tool = name,
            target = args.citizenid,
            success = success,
            trigger = context.trigger_type,
            result = result
        })
    end

    if Config.Debug then
        print(string.format('^3[MR_X:TOOLS]^7 Executed %s: %s', name, success and 'SUCCESS' or 'FAILED'))
    end
end

-- ============================================
-- TRIGGER HELPERS
-- ============================================

---Trigger agent for a player login event
---@param source number Player source
---@param citizenid string Player citizenid
function Executor.TriggerPlayerLogin(source, citizenid)
    if Config.TestMode then return end

    local isProspect = exports['sv_mr_x']:IsProspect(source)
    local profile = exports['sv_mr_x']:GetProfile(citizenid)

    local triggerPrompt
    if isProspect then
        triggerPrompt = string.format(
            'New player %s has logged in. They appear to be new to the city (prospect). ' ..
            'Consider welcoming them and building rapport.',
            citizenid
        )
    else
        local rep = profile and profile.reputation or 50
        triggerPrompt = string.format(
            'Player %s has logged in. Reputation: %d. ' ..
            'Consider whether any proactive contact is appropriate.',
            citizenid, rep
        )
    end

    -- Run agent in async to not block
    CreateThread(function()
        Wait(5000) -- Give player time to fully load
        Executor.RunAgentLoop(triggerPrompt, {
            citizenid = citizenid,
            source = source,
            trigger_type = 'login'
        }, 3)
    end)
end

---Trigger agent for mission completion
---@param citizenid string Player citizenid
---@param missionId string Mission ID
---@param outcome string Mission outcome
function Executor.TriggerMissionComplete(citizenid, missionId, outcome)
    if Config.TestMode then return end

    local triggerPrompt = string.format(
        'Player %s completed mission %s with outcome: %s. ' ..
        'Decide on appropriate response (message, reputation adjustment, follow-up).',
        citizenid, missionId, outcome
    )

    CreateThread(function()
        local source = exports['sv_mr_x']:FindPlayerSource(citizenid)
        Executor.RunAgentLoop(triggerPrompt, {
            citizenid = citizenid,
            source = source,
            missionId = missionId,
            outcome = outcome,
            trigger_type = 'mission'
        }, 3)
    end)
end

---Trigger agent for inbound player message
---@param source number Player source
---@param citizenid string Player citizenid
---@param message string Player's message
function Executor.TriggerInboundMessage(source, citizenid, message)
    if Config.TestMode then return end

    local triggerPrompt = string.format(
        'Player %s sent you a message: "%s"\n\n' ..
        'First use get_player_context to understand who you\'re dealing with, ' ..
        'then decide how to respond. Keep responses SHORT and CRYPTIC.',
        citizenid, message
    )

    CreateThread(function()
        local result = Executor.RunAgentLoop(triggerPrompt, {
            citizenid = citizenid,
            source = source,
            inbound_message = message,
            trigger_type = 'inbound_message'
        }, 4)

        -- If agent finished with a message, send it
        if result.complete and result.message then
            exports['sv_mr_x']:SendMrXMessage(source, result.message)
        end
    end)
end

---Trigger agent manually (admin/debug)
---@param citizenid string Target citizenid
---@param prompt string Custom prompt
---@return table result
function Executor.TriggerManual(citizenid, prompt)
    local source = exports['sv_mr_x']:FindPlayerSource(citizenid)

    return Executor.RunAgentLoop(prompt, {
        citizenid = citizenid,
        source = source,
        trigger_type = 'manual'
    }, 5)
end

-- ============================================
-- EVENT HOOKS
-- ============================================

-- Player login hook (optional - can be enabled)
if Config.AgentTools and Config.AgentTools.EnableLoginTrigger then
    AddEventHandler('qbx_core:server:playerLoaded', function(source)
        local player = exports.qbx_core:GetPlayer(source)
        if not player then return end

        local citizenid = player.PlayerData.citizenid

        -- Check if player is exempt
        local isExempt = exports['sv_mr_x']:IsExempt(source)
        if isExempt then return end

        Executor.TriggerPlayerLogin(source, citizenid)
    end)
end

-- Mission completion hook (optional - can be enabled)
if Config.AgentTools and Config.AgentTools.EnableMissionTrigger then
    AddEventHandler('sv_nexus_tools:missionComplete', function(missionId, outcome, participantCid)
        if not participantCid then return end
        Executor.TriggerMissionComplete(participantCid, missionId, outcome)
    end)
end

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_agent', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then return end

    local targetCid = args[1]
    local prompt = table.concat(args, ' ', 2)

    if not targetCid then
        print('^1[MR_X]^7 Usage: mrx_agent [citizenid] [prompt]')
        return
    end

    if not prompt or prompt == '' then
        prompt = 'Check on this player and decide if any action is needed.'
    end

    print('^3[MR_X:AGENT]^7 Running agent for ' .. targetCid .. '...')

    local result = Executor.TriggerManual(targetCid, prompt)

    print(string.format('^3[MR_X:AGENT]^7 Complete: %s, Iterations: %d, Actions: %d',
        tostring(result.complete),
        result.iterations,
        result.actions and #result.actions or 0
    ))

    if result.message then
        print('^3[MR_X:AGENT]^7 Response: ' .. result.message)
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('RegisterToolHandler', Executor.RegisterHandler)
exports('GetToolHandler', Executor.GetHandler)
exports('ExecuteTool', Executor.ExecuteTool)
exports('ExecuteToolCalls', Executor.ExecuteToolCalls)
exports('RunAgentLoop', Executor.RunAgentLoop)
exports('CallOpenAIWithTools', Executor.CallOpenAIWithTools)
exports('TriggerPlayerLogin', Executor.TriggerPlayerLogin)
exports('TriggerMissionComplete', Executor.TriggerMissionComplete)
exports('TriggerInboundMessage', Executor.TriggerInboundMessage)
exports('TriggerAgentManual', Executor.TriggerManual)

return Executor
