--[[
    Mr. X Mission Generation
    ========================
    AI-powered mission generation using sv_nexus_tools
]]

local MissionGen = {}

-- Cache for system prompt
local SystemPromptCache = nil
local CompactPromptCache = nil

-- Response cache (avoid duplicate API calls)
local ResponseCache = {}
local CACHE_DURATION = 300 -- 5 minutes

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

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

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, JsonEncode(data), source})
end

local function GetProfile(citizenid)
    return exports['sv_mr_x']:GetProfile(citizenid)
end

local function GetReputation(citizenid)
    return exports['sv_mr_x']:GetReputation(citizenid)
end

local function GetTier(rep)
    return exports['sv_mr_x']:GetReputationTier(rep)
end

local function SendMessage(source, message)
    return exports['sv_mr_x']:SendMrXMessage(source, message)
end

local function SendEmail(source, subject, body, actions)
    return exports['sv_mr_x']:SendMrXEmail(source, subject, body, actions)
end

local function RandomMessage(messageList)
    if not messageList or #messageList == 0 then return nil end
    return messageList[math.random(#messageList)]
end

-- ============================================
-- SYSTEM PROMPT BUILDING
-- ============================================

---Load the Mr. X system prompt template
---@return string template
local function LoadSystemPromptTemplate()
    if SystemPromptCache then
        return SystemPromptCache
    end

    -- Try to load from file
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local file = io.open(resourcePath .. '/data/MR_X_SYSTEM_PROMPT.md', 'r')

    if file then
        SystemPromptCache = file:read('*all')
        file:close()
        return SystemPromptCache
    end

    -- Fallback template
    SystemPromptCache = [[
You are Mr. X, a mysterious fixer in Sierra Valley.
- Be brief and cryptic
- Never reveal your identity
- Reward competence, punish failure
- Generate missions appropriate to player reputation
    ]]

    return SystemPromptCache
end

---Build a personalized system prompt for a player
---@param citizenid string
---@param profile table Player profile
---@return string prompt
function MissionGen.BuildPrompt(citizenid, profile)
    local template = LoadSystemPromptTemplate()

    local rep = profile.reputation or 0
    local tier = GetTier(rep)
    local history = profile.history or {}
    local known_facts = profile.known_facts or {}

    -- Get player data
    local source = exports['sv_mr_x']:FindPlayerSource(citizenid)
    local player = source and exports.qbx_core:GetPlayer(source)

    local job = 'unemployed'
    local gang = 'none'
    local cash = 0

    if player then
        job = player.PlayerData.job and player.PlayerData.job.name or 'unemployed'
        gang = player.PlayerData.gang and player.PlayerData.gang.name or 'none'
        cash = player.PlayerData.money and player.PlayerData.money.cash or 0
    end

    -- Get psychology summary
    local psychSummary = exports['sv_mr_x']:GetPsychologySummary(citizenid)

    -- Build history summary
    local historyStr = 'No prior history'
    if #history > 0 then
        local successes = 0
        local failures = 0
        for _, entry in ipairs(history) do
            if entry.outcome == 'success' then
                successes = successes + 1
            else
                failures = failures + 1
            end
        end
        historyStr = string.format('%d missions completed, %d failures', successes, failures)
    end

    -- Build known facts summary
    local factsStr = 'Nothing notable'
    if next(known_facts) then
        local factsList = {}
        for key, fact in pairs(known_facts) do
            table.insert(factsList, key .. ': ' .. tostring(fact.data))
        end
        factsStr = table.concat(factsList, '; ')
    end

    -- Build traits summary
    local traitsStr = 'Unknown'
    if psychSummary.traits and #psychSummary.traits > 0 then
        traitsStr = table.concat(psychSummary.traits, ', ')
    end

    -- Build tactics summary
    local tacticsStr = 'Standard approach'
    if psychSummary.tactics then
        local parts = {}
        if psychSummary.tactics.primary then
            table.insert(parts, 'Primary: ' .. psychSummary.tactics.primary)
        end
        if psychSummary.tactics.secondary then
            table.insert(parts, 'Secondary: ' .. psychSummary.tactics.secondary)
        end
        if psychSummary.tactics.frame then
            table.insert(parts, 'Frame: ' .. psychSummary.tactics.frame)
        end
        if psychSummary.tactics.use_loss_aversion then
            table.insert(parts, 'Use loss aversion')
        end
        tacticsStr = table.concat(parts, '; ')
    end

    -- Substitute variables
    local prompt = template
    prompt = prompt:gsub('{citizenid}', citizenid)
    prompt = prompt:gsub('{archetype}', profile.archetype or 'unclassified')
    prompt = prompt:gsub('{reputation}', tostring(rep))
    prompt = prompt:gsub('{tier}', tier)
    prompt = prompt:gsub('{history}', historyStr)
    prompt = prompt:gsub('{known_facts}', factsStr)
    prompt = prompt:gsub('{current_job}', job)
    prompt = prompt:gsub('{gang}', gang)
    prompt = prompt:gsub('{cash_balance}', tostring(cash))

    -- New psychology context
    prompt = prompt:gsub('{bucket}', psychSummary.bucket or 'civilian')
    prompt = prompt:gsub('{method_axis}', psychSummary.method or 'opportunistic')
    prompt = prompt:gsub('{loyalty_axis}', psychSummary.loyalty or 'self')
    prompt = prompt:gsub('{traits}', traitsStr)
    prompt = prompt:gsub('{tactics}', tacticsStr)

    -- Personality context injection (scarcity/mood system)
    local personalityContext = ''
    local success, result = pcall(function()
        return exports['sv_mr_x']:BuildPersonalityContext(citizenid)
    end)
    if success and result then
        personalityContext = result
    end
    prompt = prompt:gsub('{{personality}}', personalityContext)

    return prompt
end

-- ============================================
-- MISSION GENERATION
-- ============================================

---Generate a mission for a player
---@param source number
---@param forceType? string Force a specific mission type
---@param callback function(success, mission, error)
function MissionGen.Generate(source, forceType, callback)
    local citizenid = GetCitizenId(source)
    if not citizenid then
        callback(false, nil, 'Player not found')
        return
    end

    -- Check if player is exempt - no missions for exempt players
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then print('^3[MR_X]^7 Blocked mission generation for exempt player') end
        callback(false, nil, 'Player is exempt from Mr. X')
        return
    end

    local profile = GetProfile(citizenid)
    if not profile then
        callback(false, nil, 'Profile not found')
        return
    end

    local rep = profile.reputation or 0
    local tier = GetTier(rep)

    -- Check if sv_nexus_tools is available
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        -- Use fallback generation
        local mission = MissionGen.GenerateFallback(citizenid, profile, tier, forceType)
        callback(true, mission)
        return
    end

    -- Build context for AI (token-optimized)
    local player = exports.qbx_core:GetPlayer(source)

    -- Token optimization: Only include essential context
    local includeVerboseContext = not (Config.OpenAI and Config.OpenAI.ExcludeVerboseContext)

    -- Get psychology summary for the AI
    local psychSummary = exports['sv_mr_x']:GetPsychologySummary(citizenid)

    -- Base context (always included)
    local playerContext = {
        citizenid = citizenid,
        job = player and player.PlayerData.job.name or 'unemployed',
        repLevel = rep,
        additionalContext = forceType and ('Generate a ' .. forceType .. ' mission.') or '',
        archetype = psychSummary.archetype,
        bucket = psychSummary.bucket
    }

    -- Verbose context (only if not optimizing tokens)
    if includeVerboseContext then
        playerContext.gangAffiliation = player and player.PlayerData.gang.name
        playerContext.cashBalance = player and player.PlayerData.money.cash or 0
        playerContext.location = 'city'
        playerContext.archetypeLabel = psychSummary.archetype_label
        playerContext.methodAxis = psychSummary.method
        playerContext.loyaltyAxis = psychSummary.loyalty
        playerContext.traits = psychSummary.traits
        playerContext.tactics = psychSummary.tactics
        playerContext.approach = psychSummary.approach
    end

    -- Use sv_nexus_tools AI generation
    exports['sv_nexus_tools']:GenerateMrXMission(source, playerContext, function(success, mission, error)
        if not success then
            -- Fallback to template mission
            if Config.Debug then
                print('^1[MR_X]^7 AI generation failed: ' .. tostring(error) .. ', using fallback')
            end
            mission = MissionGen.GenerateFallback(citizenid, profile, tier, forceType)
            callback(true, mission)
            return
        end

        -- Scale rewards based on config
        if mission.rewards and mission.rewards.money then
            local payoutConfig = Config.Missions.Payouts[tier:upper()]
            if payoutConfig then
                local baseAmount = math.random(payoutConfig.min, payoutConfig.max)

                -- Apply personality-based reward multiplier
                local modifiers = nil
                local modSuccess, modResult = pcall(function()
                    return exports['sv_mr_x']:GetMissionModifiers(citizenid)
                end)
                if modSuccess then
                    modifiers = modResult
                end
                if modifiers and modifiers.rewardMult then
                    mission.rewards.money.amount = math.floor(baseAmount * modifiers.rewardMult)
                else
                    mission.rewards.money.amount = baseAmount
                end
            end
        end

        callback(true, mission)
    end)
end

---Generate a fallback mission without AI
---@param citizenid string
---@param profile table
---@param tier string
---@param forceType? string
---@return table mission
function MissionGen.GenerateFallback(citizenid, profile, tier, forceType)
    local archetype = profile.archetype or 'civilian'
    local payoutConfig = Config.Missions.Payouts[tier:upper()] or Config.Missions.Payouts.EASY

    -- Mission templates by tier
    local templates = {
        easy = {
            {type = 'delivery', brief = 'Pick up a package and deliver it across town. No questions.'},
            {type = 'surveillance', brief = 'Watch a location and report what you see.'},
            {type = 'collection', brief = 'Someone owes money. Collect it.'}
        },
        dilemma = {
            {type = 'choice', brief = 'Two targets. One has to go. Your choice.'},
            {type = 'theft', brief = "Something valuable needs to change hands. Quietly."},
            {type = 'escort', brief = 'Someone important needs safe passage. Protect them.'}
        },
        high_risk = {
            {type = 'heist', brief = 'A vault full of opportunity. Plan carefully.'},
            {type = 'elimination', brief = 'A problem that needs a permanent solution.'},
            {type = 'infiltration', brief = 'Get in. Get the data. Get out. No witnesses.'}
        }
    }

    local tierTemplates = templates[tier] or templates.easy
    local template = tierTemplates[math.random(#tierTemplates)]

    -- Override type if forced
    if forceType then
        template.type = forceType
    end

    -- Generate mission
    local missionId = 'mrx_' .. citizenid:sub(1, 8) .. '_' .. os.time()
    local payout = math.random(payoutConfig.min, payoutConfig.max)

    return {
        missionId = missionId,
        type = template.type,
        brief = template.brief,
        smsMessage = RandomMessage(MrXConstants.Messages.MissionOffers),
        area = {x = 0, y = 0, z = 0},  -- Will be set by execution
        tools = {},  -- Fallback has no tools
        objectives = {
            {id = 'complete_task', description = 'Complete the objective', status = 'pending'}
        },
        rewards = {
            money = {type = 'cash', amount = payout},
            reputation = Config.Reputation.Changes.MissionSuccess
        },
        consequences = {
            failure_rep_loss = Config.Reputation.Changes.MissionFailure,
            timeout_minutes = Config.Missions.MissionTimeoutMin
        },
        isFallback = true
    }
end

-- ============================================
-- MISSION VALIDATION
-- ============================================

---Validate a generated mission
---@param mission table
---@return boolean valid
---@return table|nil errors
function MissionGen.Validate(mission)
    local errors = {}

    if not mission.missionId then
        table.insert(errors, 'Missing missionId')
    end

    if not mission.type then
        table.insert(errors, 'Missing mission type')
    end

    if not mission.brief then
        table.insert(errors, 'Missing mission brief')
    end

    if not mission.objectives or #mission.objectives == 0 then
        table.insert(errors, 'No objectives defined')
    end

    -- Validate tools exist (if using sv_nexus_tools)
    if mission.tools and #mission.tools > 0 and GetResourceState('sv_nexus_tools') == 'started' then
        for _, tool in ipairs(mission.tools) do
            -- Tools validation handled by sv_nexus_tools
        end
    end

    return #errors == 0, errors
end

-- ============================================
-- MISSION EXECUTION
-- ============================================

---Execute a generated mission
---@param source number
---@param mission table
---@param callback function(success, error)
function MissionGen.Execute(source, mission, callback)
    local citizenid = GetCitizenId(source)
    if not citizenid then
        callback(false, 'Player not found')
        return
    end

    -- Check if player is exempt
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        callback(false, 'Player is exempt from Mr. X')
        return
    end

    -- Validate mission
    local valid, errors = MissionGen.Validate(mission)
    if not valid then
        callback(false, 'Invalid mission: ' .. table.concat(errors, ', '))
        return
    end

    -- Send mission briefing
    if mission.smsMessage then
        SendMessage(source, mission.smsMessage)
    end

    -- Use sv_nexus_tools for execution if available
    if GetResourceState('sv_nexus_tools') == 'started' and mission.tools and #mission.tools > 0 then
        exports['sv_nexus_tools']:ExecuteMrXMission(source, mission, function(success, result)
            if success then
                Log(MrXConstants.EventTypes.MISSION_ACCEPTED, citizenid, {
                    missionId = mission.missionId,
                    type = mission.type
                }, source)
                callback(true)
            else
                callback(false, result or 'Execution failed')
            end
        end)
    else
        -- Fallback: just send email with mission details
        local emailBody = string.format([[
**MISSION BRIEFING**

%s

**Objectives:**
%s

**Reward:** $%s

Accept this job to proceed. Failure is not an option.
        ]],
            mission.brief,
            mission.objectives[1] and mission.objectives[1].description or 'Complete the task',
            mission.rewards and mission.rewards.money and mission.rewards.money.amount or '???'
        )

        SendEmail(source, 'New Assignment', emailBody, {
            {
                label = 'Accept Job',
                data = {
                    event = 'sv_mr_x:server:acceptMission',
                    isServer = true,
                    data = {
                        missionId = mission.missionId,
                        citizenid = citizenid
                    }
                }
            }
        })

        Log(MrXConstants.EventTypes.MISSION_OFFERED, citizenid, {
            missionId = mission.missionId,
            type = mission.type
        }, source)

        -- Post webhook for dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhookMission('generated', citizenid, {
                id = mission.missionId,
                type = mission.type,
                tier = GetTier(profile.reputation or 0),
                reward = mission.rewards and mission.rewards.money and mission.rewards.money.amount
            })
        end

        callback(true)
    end
end

-- ============================================
-- MISSION COMPLETION HANDLERS
-- ============================================

---Handle mission completion
---@param citizenid string
---@param missionId string
---@param outcome string 'success'|'failure'|'abandoned'
---@param source? number
function MissionGen.HandleCompletion(citizenid, missionId, outcome, source)
    -- Update profile history
    exports['sv_mr_x']:AddToHistory(citizenid, {
        missionId = missionId,
        outcome = outcome,
        timestamp = os.time()
    })

    -- Update reputation
    if outcome == MrXConstants.MissionOutcome.SUCCESS then
        exports['sv_mr_x']:HandleMissionSuccess(citizenid, missionId, source)

        if source then
            SendMessage(source, RandomMessage(MrXConstants.Messages.Success))
        end

        -- Process Mr. X's cut from the mission reward (scarcity system)
        -- Note: The actual reward was already paid to player by the mission system
        -- This deposits Mr. X's cut into his account
        pcall(function()
            -- Estimate reward based on tier (we don't have the exact amount here)
            local profile = GetProfile(citizenid)
            local rep = profile and profile.reputation or 50
            local tier = GetTier(rep)
            local payoutConfig = Config.Missions.Payouts[tier:upper()] or Config.Missions.Payouts.EASY
            local estimatedReward = math.floor((payoutConfig.min + payoutConfig.max) / 2)
            local mrxCut = exports['sv_mr_x']:ProcessMissionCut(estimatedReward, missionId)

            if Config.Debug and mrxCut > 0 then
                print(string.format('^3[MR_X]^7 Took $%d cut from mission %s', mrxCut, missionId))
            end
        end)

        Log(MrXConstants.EventTypes.MISSION_COMPLETED, citizenid, {
            missionId = missionId,
            outcome = outcome
        }, source)

        -- Post webhook for dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhookMission('completed', citizenid, {id = missionId, outcome = outcome})
        end

    elseif outcome == MrXConstants.MissionOutcome.FAILURE then
        local newRep, isThreat = exports['sv_mr_x']:HandleMissionFailure(citizenid, missionId, source)

        if source then
            SendMessage(source, RandomMessage(MrXConstants.Messages.Failure))
        end

        -- Trigger HARM if threshold crossed
        if isThreat then
            TriggerEvent('sv_mr_x:internal:playerBecameThreat', citizenid, source)
        end

        Log(MrXConstants.EventTypes.MISSION_FAILED, citizenid, {
            missionId = missionId,
            outcome = outcome,
            isThreat = isThreat
        }, source)

        -- Post webhook for dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhookMission('failed', citizenid, {id = missionId, outcome = outcome, isThreat = isThreat})
        end

    elseif outcome == MrXConstants.MissionOutcome.ABANDONED then
        local newRep, isThreat = exports['sv_mr_x']:HandleMissionAbandoned(citizenid, missionId, source)

        if source then
            SendMessage(source, "Abandonment has consequences. Remember that.")
        end

        if isThreat then
            TriggerEvent('sv_mr_x:internal:playerBecameThreat', citizenid, source)
        end

        Log(MrXConstants.EventTypes.MISSION_ABANDONED, citizenid, {
            missionId = missionId,
            outcome = outcome,
            isThreat = isThreat
        }, source)

        -- Post webhook for dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhookMission('abandoned', citizenid, {id = missionId, outcome = outcome, isThreat = isThreat})
        end
    end

    -- Update last contact
    exports['sv_mr_x']:UpdateLastContact(citizenid)
end

-- ============================================
-- AI RESPONSE GENERATION
-- ============================================

---Get a cached response or nil if not found/expired
---@param cacheKey string
---@return string|nil
local function GetCachedResponse(cacheKey)
    local cached = ResponseCache[cacheKey]
    if cached and os.time() - cached.timestamp < CACHE_DURATION then
        return cached.response
    end
    return nil
end

---Cache a response
---@param cacheKey string
---@param response string
local function CacheResponse(cacheKey, response)
    if Config.OpenAI and Config.OpenAI.CacheResponses then
        ResponseCache[cacheKey] = {
            response = response,
            timestamp = os.time()
        }
    end
end

---Build a compact system prompt for token efficiency
---@param citizenid string
---@param profile table
---@return string
function MissionGen.BuildCompactPrompt(citizenid, profile)
    if CompactPromptCache then
        return CompactPromptCache
    end

    -- Minimal Mr. X personality (saves tokens vs full prompt)
    CompactPromptCache = [[You are Mr. X, a mysterious fixer. Rules:
- Brief (1-2 sentences max)
- Cryptic, professional
- Never reveal identity
- Use "Mr. X" in third person occasionally
- No emojis
Respond in character.]]

    return CompactPromptCache
end

---Generate an AI response to a player message
---@param source number
---@param citizenid string
---@param message string
---@param session table
function MissionGen.GenerateAIResponse(source, citizenid, message, session)
    local profile = GetProfile(citizenid)
    if not profile then
        SendMessage(source, "...")
        return
    end

    -- Check if sv_nexus_tools OpenAI is available
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        -- Use canned response
        local responses = {
            "Interesting.",
            "We'll see.",
            "Perhaps.",
            "Noted.",
            "I'll consider it."
        }
        SendMessage(source, RandomMessage(responses))
        return
    end

    -- Token optimization: Check cache first
    local cacheKey = citizenid .. ':' .. message:sub(1, 50):lower()
    local cachedResponse = GetCachedResponse(cacheKey)
    if cachedResponse then
        if Config.Debug then
            print('^3[MR_X]^7 Using cached response for: ' .. citizenid)
        end
        SendMessage(source, cachedResponse)
        return
    end

    -- Token optimization: Use compact prompt if configured
    local systemPrompt
    if Config.OpenAI and Config.OpenAI.UseCompactPrompt then
        systemPrompt = MissionGen.BuildCompactPrompt(citizenid, profile)
    else
        systemPrompt = MissionGen.BuildPrompt(citizenid, profile)
    end

    -- Token optimization: Limit user prompt
    local userPrompt = string.format('Player: "%s"\nRespond briefly (1-2 sentences).', message:sub(1, 200))

    -- Token optimization: Use configured max tokens
    local maxTokens = 150
    if Config.OpenAI and Config.OpenAI.MaxTokens and Config.OpenAI.MaxTokens.Response then
        maxTokens = Config.OpenAI.MaxTokens.Response
    end

    exports['sv_nexus_tools']:CallOpenAI(userPrompt, systemPrompt, function(success, response, error)
        if success and response then
            -- Clean up response (remove quotes if AI wrapped it)
            response = response:gsub('^"', ''):gsub('"$', '')
            response = response:gsub("^'", ""):gsub("'$", "")

            -- Cache the response
            CacheResponse(cacheKey, response)

            SendMessage(source, response)
        else
            -- Use fallback on error
            if Config.OpenAI and Config.OpenAI.UseFallbackOnError then
                local fallbacks = {
                    "Interesting.",
                    "We'll see.",
                    "Noted.",
                    "Perhaps."
                }
                SendMessage(source, RandomMessage(fallbacks))
            else
                SendMessage(source, "...")
            end
        end
    end, maxTokens)
end

-- ============================================
-- EVENT HANDLERS
-- ============================================

-- Handle AI response generation request
RegisterNetEvent('sv_mr_x:internal:generateResponse', function(source, citizenid, message, session)
    MissionGen.GenerateAIResponse(source, citizenid, message, session)
end)

-- Handle mission acceptance from email button
RegisterNetEvent('sv_mr_x:server:acceptMission', function(data)
    local source = source
    local citizenid = GetCitizenId(source)

    if not data or not data.missionId then return end

    -- Verify this is the right player
    if data.citizenid and data.citizenid ~= citizenid then
        SendMessage(source, "This offer wasn't for you.")
        return
    end

    Log(MrXConstants.EventTypes.MISSION_ACCEPTED, citizenid, {
        missionId = data.missionId
    }, source)

    SendMessage(source, "Good. Don't disappoint me.")
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('GenerateMission', MissionGen.Generate)
exports('ValidateMission', MissionGen.Validate)
exports('ExecuteMission', MissionGen.Execute)
exports('HandleMissionCompletion', MissionGen.HandleCompletion)
exports('BuildMrXPrompt', MissionGen.BuildPrompt)
exports('GenerateAIResponse', MissionGen.GenerateAIResponse)

-- Return module
return MissionGen
