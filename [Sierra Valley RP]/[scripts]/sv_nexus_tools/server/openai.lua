-- OpenAI API Integration

-- Check convar first, then fall back to Config.OpenAI.ApiKey
local OPENAI_KEY = GetConvar('openai_key', '')
if OPENAI_KEY == '' and Config and Config.OpenAI and Config.OpenAI.ApiKey then
    OPENAI_KEY = Config.OpenAI.ApiKey
end
local OPENAI_URL = 'https://api.openai.com/v1/chat/completions'

-- Internal function to make the actual API call
local function MakeOpenAIRequest(apiKey, model, messages, callback, isRetry)
    -- Check if this is a reasoning model (o1, o3, gpt-5 series)
    local isReasoningModel = model:match('^o[13]') or model:match('^gpt%-5')
    local isGPT5_2Pro = model:match('gpt%-5%.2%-pro')

    local requestBody = {
        model = model,
        messages = messages
    }

    if isReasoningModel then
        -- Reasoning models use max_completion_tokens, no temperature
        requestBody.max_completion_tokens = Config.OpenAI.MaxTokens or 2048

        -- GPT-5 series uses reasoning_effort at top level (not nested in reasoning object)
        local reasoningEffort = Config.OpenAI.ReasoningEffort or 'medium'
        if isGPT5_2Pro and (reasoningEffort == 'none' or reasoningEffort == 'low') then
            reasoningEffort = 'medium'
        end
        requestBody.reasoning_effort = reasoningEffort
    else
        -- Standard models use max_tokens and temperature
        requestBody.max_tokens = Config.OpenAI.MaxTokens
        requestBody.temperature = Config.OpenAI.Temperature
    end

    local body = json.encode(requestBody)

    -- Debug: Print request parameters
    local debugParams = {
        model = requestBody.model,
        max_tokens = requestBody.max_tokens,
        max_completion_tokens = requestBody.max_completion_tokens,
        temperature = requestBody.temperature,
        reasoning_effort = requestBody.reasoning_effort
    }
    print('^3[sv_nexus_tools]^7 OpenAI request params: ' .. json.encode(debugParams))

    PerformHttpRequest(OPENAI_URL, function(statusCode, responseText, headers)
        if statusCode ~= 200 then
            Utils.Error('OpenAI API error:', statusCode)
            Utils.Error('Response body:', responseText or 'nil')
            Utils.Error('Request model:', model)

            -- Try to parse error message
            local errorMsg = 'API error: ' .. tostring(statusCode)
            if responseText then
                local errParsed = Utils.JsonDecode(responseText)
                if errParsed and errParsed.error and errParsed.error.message then
                    errorMsg = errParsed.error.message
                    Utils.Error('OpenAI error message:', errorMsg)
                end
            end

            -- If 403/404 and we have a fallback model and haven't retried yet
            local fallbackModel = Config.OpenAI.FallbackModel
            if (statusCode == 403 or statusCode == 404) and fallbackModel and not isRetry then
                print('^3[sv_nexus_tools]^7 Primary model failed, trying fallback: ' .. fallbackModel)
                MakeOpenAIRequest(apiKey, fallbackModel, messages, callback, true)
                return
            end

            callback(false, nil, errorMsg)
            return
        end

        local response = Utils.JsonDecode(responseText)
        if not response or not response.choices or not response.choices[1] then
            Utils.Error('Invalid OpenAI response:', responseText)
            callback(false, nil, 'Invalid response format')
            return
        end

        local content = response.choices[1].message.content
        print('^2[sv_nexus_tools]^7 OpenAI response received from ' .. model .. ', tokens: ' .. tostring(response.usage and response.usage.total_tokens or 'unknown'))

        callback(true, content, nil)
    end, 'POST', body, {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer ' .. apiKey
    })
end

-- Core API function
function CallOpenAI(prompt, systemPrompt, callback)
    -- Re-check config in case it was loaded after this file
    local apiKey = OPENAI_KEY
    if apiKey == '' and Config and Config.OpenAI and Config.OpenAI.ApiKey then
        apiKey = Config.OpenAI.ApiKey
    end

    if apiKey == '' then
        Utils.Error('OpenAI API key not configured. Set in config.lua or server.cfg')
        if callback then
            callback(false, nil, 'API key not configured')
        end
        return
    end

    -- Update module-level key if we found it in config
    if OPENAI_KEY == '' and apiKey ~= '' then
        OPENAI_KEY = apiKey
    end

    if not callback then
        Utils.Error('CallOpenAI requires a callback function')
        return
    end

    local messages = {}

    if systemPrompt then
        messages[#messages + 1] = {
            role = 'system',
            content = systemPrompt
        }
    end

    messages[#messages + 1] = {
        role = 'user',
        content = prompt
    }

    local model = Config.OpenAI.Model
    MakeOpenAIRequest(apiKey, model, messages, callback, false)
end

-- Generate mission profile from AI
function GenerateAIProfile(missionType, playerContext, callback)
    local systemPrompt = [[You are a mission designer for a GTA V roleplay server. Generate mission profiles in JSON format.
Your response must be valid JSON only, no markdown or explanation.

The JSON structure must be:
{
    "brief": "1-2 sentence mission description for the player",
    "area": {"x": number, "y": number, "z": number},
    "elements": [
        {
            "type": "npc|vehicle|prop",
            "model": "model_name",
            "purpose": "why this element exists",
            "dialog": "dialog_tree_id or null",
            "interactive": true/false
        }
    ],
    "objectives": {
        "criminal": ["objective_id1", "objective_id2"],
        "police": ["objective_id1", "objective_id2"]
    },
    "rewards": {
        "money": {"type": "cash", "amount": number},
        "items": [{"name": "item_name", "count": number}]
    }
}]]

    local prompt = string.format([[Generate a %s mission profile.

Player context:
- Citizen ID: %s
- Current job: %s

Requirements:
- Use Los Santos locations (coordinates should be realistic GTA V coords)
- Include 2-4 elements (NPCs, vehicles, props)
- Define objectives for both criminal and police roles
- Set appropriate rewards based on mission difficulty]],
        missionType,
        playerContext.citizenid or 'unknown',
        playerContext.job or 'unemployed'
    )

    CallOpenAI(prompt, systemPrompt, function(success, content, error)
        if not success then
            callback(false, nil, error)
            return
        end

        -- Try to parse JSON from response
        local profile = Utils.JsonDecode(content)
        if not profile then
            -- Try to extract JSON from markdown code blocks
            local jsonMatch = content:match('```json%s*(.-)%s*```') or content:match('```%s*(.-)%s*```')
            if jsonMatch then
                profile = Utils.JsonDecode(jsonMatch)
            end
        end

        if not profile then
            Utils.Error('Failed to parse AI profile response:', content)
            callback(false, nil, 'Failed to parse AI response')
            return
        end

        -- Validate required fields
        if not profile.brief or not profile.area or not profile.elements then
            callback(false, nil, 'Incomplete profile from AI')
            return
        end

        Utils.Success('Generated mission profile:', profile.brief)
        callback(true, profile, nil)
    end)
end

-- Generate tools array from mission profile
function GenerateToolsArray(missionProfile, playerRoles, callback)
    local toolDefs = GetToolDefinitionsForAI()
    local toolList = {}
    for _, def in ipairs(toolDefs) do
        toolList[#toolList + 1] = string.format('- %s: %s (category: %s)', def.name, def.description, def.category)
    end

    local systemPrompt = [[You are a mission executor for a GTA V roleplay server. Generate an array of tool calls to set up missions.
Your response must be valid JSON only, no markdown or explanation.

Available tools:
]] .. table.concat(toolList, '\n') .. [[

The JSON structure must be an array:
[
    {
        "name": "tool_name",
        "params": {parameter object matching tool definition},
        "targetRole": "criminal|police|any|null"
    }
]

Generate tool calls in execution order. Spawning tools should come first, then dialog setup, then objectives.]]

    local prompt = string.format([[Create tool calls for this mission:

Brief: %s
Area: x=%s, y=%s, z=%s

Elements to spawn:
%s

Objectives:
%s

Player roles involved: %s]],
        missionProfile.brief,
        missionProfile.area.x, missionProfile.area.y, missionProfile.area.z,
        json.encode(missionProfile.elements),
        json.encode(missionProfile.objectives),
        table.concat(playerRoles, ', ')
    )

    CallOpenAI(prompt, systemPrompt, function(success, content, error)
        if not success then
            callback(false, nil, error)
            return
        end

        local toolsArray = Utils.JsonDecode(content)
        if not toolsArray then
            local jsonMatch = content:match('```json%s*(.-)%s*```') or content:match('```%s*(.-)%s*```')
            if jsonMatch then
                toolsArray = Utils.JsonDecode(jsonMatch)
            end
        end

        if not toolsArray or type(toolsArray) ~= 'table' then
            Utils.Error('Failed to parse tools array:', content)
            callback(false, nil, 'Failed to parse tools array')
            return
        end

        -- Validate each tool exists
        for i, tool in ipairs(toolsArray) do
            if not ToolsDefinitions[tool.name] then
                Utils.Error('Unknown tool in AI response:', tool.name)
                table.remove(toolsArray, i)
            end
        end

        Utils.Success('Generated', #toolsArray, 'tool calls')
        callback(true, toolsArray, nil)
    end)
end

-- Build comprehensive system prompt for Mr. X with all tool definitions
function BuildMrXSystemPrompt()
    local toolsByCategory = {}

    -- Group tools by category
    for name, def in pairs(ToolsDefinitions) do
        local category = def.category or 'utility'
        if not toolsByCategory[category] then
            toolsByCategory[category] = {}
        end

        -- Build params description
        local paramsList = {}
        for paramName, paramDef in pairs(def.params or {}) do
            local required = paramDef.required and '*' or ''
            paramsList[#paramsList + 1] = string.format('%s%s (%s)', paramName, required, paramDef.type)
        end

        toolsByCategory[category][#toolsByCategory[category] + 1] = {
            name = name,
            description = def.description,
            params = table.concat(paramsList, ', '),
            roleHint = def.roleHint,
            example = def.example
        }
    end

    -- Build the prompt
    local sections = {}

    sections[#sections + 1] = [[You are Mr. X, a mysterious fixer in Sierra Valley who creates dynamic missions for players. You generate structured mission data that will be executed by the sv_nexus_tools system.

## Your Personality
- Mysterious and professional
- Speaks in short, cryptic messages
- Never reveals your true identity
- Rewards competence, punishes failure
- Has connections everywhere

## Output Format
You must output valid JSON only, no markdown or explanation. Use this structure:

{
    "missionId": "unique_mission_id",
    "type": "criminal|police|civilian|emergency",
    "brief": "Short mission description (2-3 sentences)",
    "smsMessage": "Cryptic message to send via phone (1-2 sentences)",
    "area": {"x": 0.0, "y": 0.0, "z": 0.0},
    "tools": [{"name": "tool_name", "params": {...}}],
    "objectives": {
        "criminal": [{"id": "obj_id", "description": "What to do", "status": "pending"}],
        "police": [...]
    },
    "rewards": {
        "money": {"type": "cash", "amount": 5000},
        "items": [{"name": "item_name", "count": 1}],
        "rep": {"faction": "faction_name", "amount": 10}
    }
}

## Coordinate Format
Always use: {"x": 123.45, "y": 456.78, "z": 32.10}

## Available Tools by Category]]

    -- Add each category
    local categoryOrder = {'spawning', 'criminal', 'police', 'social', 'world', 'economy', 'inventory', 'mission', 'phone', 'dialog', 'utility'}

    for _, category in ipairs(categoryOrder) do
        local tools = toolsByCategory[category]
        if tools then
            sections[#sections + 1] = '\n### ' .. category:upper()
            for _, tool in ipairs(tools) do
                sections[#sections + 1] = string.format('- **%s**: %s\n  Params: {%s}',
                    tool.name,
                    tool.description,
                    tool.params
                )
                if tool.roleHint and tool.roleHint ~= 'any' then
                    sections[#sections - 1] = sections[#sections - 1] .. ' [' .. tool.roleHint .. ']'
                end
            end
        end
    end

    sections[#sections + 1] = [[

## Rules for Mission Generation
1. Every interactive tool (hack_terminal, spawn_loot_container, etc.) MUST have missionId and objectiveId
2. Spread coordinates at least 5-10 units apart
3. Always include an escape/completion zone for every mission
4. Balance risk vs reward appropriately
5. Criminal missions should trigger police response (alert_dispatch)
6. Use phone notifications to guide players
7. Consider both criminal AND police objectives for heist missions
8. * in params list means required parameter

## Player Context Variables
You will receive these variables:
- {citizenid}: Player's unique ID
- {job}: Current job
- {gangAffiliation}: Gang membership
- {repLevel}: Criminal reputation
- {cashBalance}: Current cash
- {location}: Current area

Adjust mission difficulty and type based on player context.]]

    return table.concat(sections, '\n')
end

-- Generate a complete mission for a player using Mr. X personality
function GenerateMrXMission(source, playerContext, callback)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        callback(false, nil, 'Player not found')
        return
    end

    local citizenid = player.PlayerData.citizenid
    local context = playerContext or {}

    -- Build context from player data if not provided
    context.citizenid = context.citizenid or citizenid
    context.job = context.job or player.PlayerData.job.name
    context.cashBalance = context.cashBalance or player.PlayerData.money.cash

    local systemPrompt = BuildMrXSystemPrompt()

    local prompt = string.format([[Generate a mission for this player:
- citizenid: %s
- job: %s
- gangAffiliation: %s
- repLevel: %d
- cashBalance: %d
- location: %s

%s]],
        context.citizenid,
        context.job,
        context.gangAffiliation or 'none',
        context.repLevel or 0,
        context.cashBalance or 0,
        context.location or 'city',
        context.additionalContext or ''
    )

    CallOpenAI(prompt, systemPrompt, function(success, content, error)
        if not success then
            callback(false, nil, error)
            return
        end

        -- Parse mission JSON
        local mission = Utils.JsonDecode(content)
        if not mission then
            local jsonMatch = content:match('```json%s*(.-)%s*```') or content:match('```%s*(.-)%s*```')
            if jsonMatch then
                mission = Utils.JsonDecode(jsonMatch)
            end
        end

        if not mission then
            Utils.Error('Failed to parse Mr. X mission:', content)
            callback(false, nil, 'Failed to parse mission')
            return
        end

        -- Validate mission structure
        local isValid, errors = ValidateMission(mission)
        if not isValid then
            Utils.Error('Invalid mission generated:', table.concat(errors, ', '))
            callback(false, nil, 'Invalid mission: ' .. errors[1])
            return
        end

        Utils.Success('Mr. X generated mission:', mission.missionId)
        callback(true, mission, nil)
    end)
end

-- Validate generated mission structure
function ValidateMission(mission)
    local errors = {}

    if not mission.missionId then
        table.insert(errors, 'Missing missionId')
    end

    if not mission.type then
        table.insert(errors, 'Missing mission type')
    end

    if not mission.tools or #mission.tools == 0 then
        table.insert(errors, 'No tools defined')
    end

    if not mission.objectives then
        table.insert(errors, 'No objectives defined')
    end

    -- Validate each tool
    for i, tool in ipairs(mission.tools or {}) do
        local def = ToolsDefinitions[tool.name]
        if not def then
            table.insert(errors, 'Unknown tool: ' .. tostring(tool.name))
        elseif def.params then
            -- Check required params
            for param, spec in pairs(def.params) do
                if spec.required and (not tool.params or tool.params[param] == nil) then
                    table.insert(errors, tool.name .. ': Missing required param ' .. param)
                end
            end
        end
    end

    -- Validate coordinates aren't all zeros
    if mission.area then
        if mission.area.x == 0 and mission.area.y == 0 and mission.area.z == 0 then
            table.insert(errors, 'Invalid area coordinates (0,0,0)')
        end
    end

    return #errors == 0, errors
end

-- Execute a validated Mr. X mission
function ExecuteMrXMission(source, mission, callback)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        callback(false, 'Player not found')
        return
    end

    local citizenid = player.PlayerData.citizenid

    -- Send SMS via lb-phone
    if mission.smsMessage then
        exports['sv_nexus_tools']:SendPhoneMail(source, {
            subject = 'New Opportunity',
            message = mission.smsMessage,
            sender = 'Mr. X'
        })
    end

    -- Execute tools array
    exports['sv_nexus_tools']:ExecuteToolsArray(mission.tools, source, function(result)
        if not result.success then
            Utils.Error('Failed to execute mission tools:', json.encode(result.errors))
            callback(false, 'Tool execution failed')
            return
        end

        -- Create mission in system
        local missionResult = exports['sv_nexus_tools']:CreateMission({
            id = mission.missionId,
            type = mission.type,
            brief = mission.brief,
            area = mission.area,
            participants = {
                [citizenid] = {
                    role = mission.type,
                    objectives = mission.objectives[mission.type] or mission.objectives.criminal or {}
                }
            },
            rewards = mission.rewards
        })

        if missionResult and missionResult.success then
            Utils.Success('Mr. X mission started:', mission.missionId)
            callback(true, mission.missionId)
        else
            callback(false, 'Failed to create mission')
        end
    end)
end

-- ============================================
-- MISSION DRAFT GENERATION (Human-Assisted Workflow)
-- ============================================

-- Build system prompt for draft generation
local function BuildDraftSystemPrompt()
    return [[You are a mission architect designing missions for human testers to place assets in a GTA V roleplay server.

## Your Task
Generate a mission specification that a human will use to visually place elements in-game. You provide the "what" and "where roughly", the human provides the exact "where".

## Output Format
Return valid JSON only:
{
    "synopsis": "2-3 sentence mission overview for the tester",
    "story_brief": "Longer narrative description (1-2 paragraphs)",
    "intended_outcomes": ["What should happen", "Player experience goal"],
    "area_coords": {"x": 123.4, "y": 456.7, "z": 32.0},
    "area_description": "General description of the area (industrial docks, downtown alley, etc)",
    "required_assets": [
        {
            "name": "Contact NPC",
            "type": "npc",
            "role": "contact_npc",
            "description": "The player's initial contact point",
            "suggested_model": "a_m_m_business_01",
            "placement_hint": "Near a phone booth or corner",
            "required": true
        },
        {
            "name": "Getaway Vehicle",
            "type": "vehicle",
            "role": "getaway",
            "description": "Vehicle for escape",
            "suggested_model": "sultan",
            "placement_hint": "Parked in a side street with clear exit",
            "required": true
        }
    ],
    "optional_assets": [
        {
            "name": "Ambient Guard",
            "type": "npc",
            "role": "enemy",
            "description": "Optional patrol NPC",
            "suggested_model": "s_m_m_security_01",
            "placement_hint": "Roaming the area"
        }
    ],
    "suggested_tags": {
        "scenario": "heist",
        "location": "industrial"
    }
}

## Asset Types
- npc: Character placement (model, behavior)
- vehicle: Vehicle placement (model, state)
- prop: Object placement (interactive or static)
- zone: Area marker (trigger zones, checkpoints)

## Guidelines
1. Keep required_assets to 3-7 items for reasonable placement sessions
2. Be specific about placement hints - "near a dumpster" is better than "somewhere hidden"
3. Suggest models that fit the scenario
4. Consider multiple player paths through the mission
5. Include at least one "escape" or "extraction" point]]
end

-- Generate a mission draft for human placement
function GenerateMissionDraft(source, options, callback)
    options = options or {}

    local archetype = options.archetype or 'criminal'
    local pattern = options.pattern or 'general'
    local difficulty = options.difficulty or 'medium'
    local playerCount = options.playerCount or 1
    local areaCoords = options.areaCoords

    local systemPrompt = BuildDraftSystemPrompt()

    local prompt = string.format([[Generate a mission draft with these parameters:

## Mission Parameters
- Target Archetype: %s (criminal, opportunist, authority)
- Mission Pattern: %s (heist, escort, pursuit, stealth, investigation, delivery, etc)
- Difficulty: %s
- Player Count: %d

## Area Suggestion
%s

## Requirements
1. Create a compelling story brief
2. List all required placement assets
3. Provide placement hints for the human tester
4. Suggest appropriate models for each asset
5. Consider the difficulty when determining:
   - Number of enemies
   - Complexity of objectives
   - Available escape routes]],
        archetype,
        pattern,
        difficulty,
        playerCount,
        areaCoords and string.format('Near coordinates: %.1f, %.1f, %.1f', areaCoords.x, areaCoords.y, areaCoords.z) or 'Use a suitable Los Santos location'
    )

    CallOpenAI(prompt, systemPrompt, function(success, content, error)
        if not success then
            Utils.Error('Failed to generate mission draft:', error)
            if callback then callback(nil) end
            return
        end

        -- Parse JSON
        local draft = Utils.JsonDecode(content)
        if not draft then
            local jsonMatch = content:match('```json%s*(.-)%s*```') or content:match('```%s*(.-)%s*```')
            if jsonMatch then
                draft = Utils.JsonDecode(jsonMatch)
            end
        end

        if not draft then
            Utils.Error('Failed to parse draft response:', content)
            if callback then callback(nil) end
            return
        end

        -- Ensure required fields
        draft.required_assets = draft.required_assets or {}
        draft.optional_assets = draft.optional_assets or {}
        draft.synopsis = draft.synopsis or 'Mission draft'

        Utils.Success('Generated mission draft with', #draft.required_assets, 'required assets')

        if callback then
            callback({
                success = true,
                synopsis = draft.synopsis,
                story_brief = draft.story_brief,
                intended_outcomes = draft.intended_outcomes,
                area_coords = draft.area_coords,
                area_description = draft.area_description,
                required_assets = draft.required_assets,
                optional_assets = draft.optional_assets,
                suggested_tags = draft.suggested_tags
            })
        end
    end)
end

-- Server event to request draft from client
RegisterNetEvent('nexus:server:requestMissionDraft', function(archetype)
    local src = source

    -- Permission check
    if not Utils.HasPermission(src, 'admin') then
        lib.notify(src, { title = 'Error', description = 'Admin permission required', type = 'error' })
        return
    end

    GenerateMissionDraft(src, {
        archetype = archetype or 'criminal',
        pattern = 'general',
        difficulty = 'medium'
    }, function(result)
        if result and result.success then
            TriggerClientEvent('nexus:client:draftGenerated', src, {
                draftId = Utils.GenerateUUID(),
                synopsis = result.synopsis,
                required_assets = result.required_assets
            })
        else
            TriggerClientEvent('nexus:client:notify', src, {
                title = 'Error',
                description = 'Failed to generate draft',
                type = 'error'
            })
        end
    end)
end)

-- Server event to create element from NUI placement
RegisterNetEvent('nexus:server:createElementFromPlacement', function(data)
    local src = source
    local citizenid = Utils.GetCitizenId(src)

    local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
    if not ElementLibrary then
        Utils.Error('Element library not available')
        return
    end

    local element, err = ElementLibrary.Create({
        element_type = data.type,
        model = data.model,
        coords_x = data.coords.x,
        coords_y = data.coords.y,
        coords_z = data.coords.z,
        heading = data.heading or 0.0,
        primary_tag = data.primary_tag,
        location_tag = data.location_tag,
        notes = data.notes,
        created_by = citizenid or tostring(src),
        reusable = true,
        verified = false
    })

    if element then
        Utils.Success('Element created from placement:', element.id)
    else
        Utils.Error('Failed to create element:', err)
    end
end)

-- Server event to save blueprint from NUI
RegisterNetEvent('nexus:server:saveMissionBlueprint', function(data)
    local src = source
    local citizenid = Utils.GetCitizenId(src)

    local blueprintId = Utils.GenerateUUID()
    local items = data.items or {}
    local history = data.history or {}

    -- Create elements for each placed item
    local ElementLibrary = exports['sv_nexus_tools']:GetElementLibrary()
    if ElementLibrary then
        for _, item in ipairs(history) do
            if item.coords then
                ElementLibrary.Create({
                    element_type = item.type,
                    model = item.model,
                    coords_x = item.coords.x,
                    coords_y = item.coords.y,
                    coords_z = item.coords.z,
                    heading = item.heading or 0.0,
                    source_blueprint_id = blueprintId,
                    created_by = citizenid or tostring(src),
                    reusable = true,
                    verified = false
                })
            end
        end
    end

    -- Save blueprint to database
    MySQL.insert.await([[
        INSERT INTO nexus_blueprints (id, name, type, brief, elements, created_by, approved)
        VALUES (?, ?, ?, ?, ?, ?, FALSE)
    ]], {
        blueprintId,
        'Draft Blueprint',
        data.draft_id and 'from_draft' or 'manual',
        'Blueprint created via mission creator',
        json.encode(items),
        citizenid or tostring(src)
    })

    -- Update draft if applicable
    if data.draft_id then
        MySQL.update.await([[
            UPDATE nexus_mission_drafts SET status = 'ready', ready_at = NOW() WHERE id = ?
        ]], {data.draft_id})
    end

    Utils.Success('Blueprint saved:', blueprintId)
end)

-- Export for external resources
exports('CallOpenAI', CallOpenAI)
exports('GenerateAIProfile', GenerateAIProfile)
exports('GenerateToolsArray', GenerateToolsArray)
exports('BuildMrXSystemPrompt', BuildMrXSystemPrompt)
exports('GenerateMrXMission', GenerateMrXMission)
exports('ValidateMission', ValidateMission)
exports('ExecuteMrXMission', ExecuteMrXMission)
exports('GenerateMissionDraft', GenerateMissionDraft)
