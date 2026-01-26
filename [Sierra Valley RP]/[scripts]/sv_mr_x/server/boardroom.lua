--[[
    Mr. X Boardroom System
    ======================
    Periodic AI strategic planning sessions.
    Mr. X analyzes his network and makes strategic decisions.
]]

local Boardroom = {}
local lastMeeting = 0

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function FormatMoney(amount)
    local formatted = tostring(math.floor(amount))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
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

-- ============================================
-- CONTEXT GATHERING
-- ============================================

---Wait for MySQL to be ready
local function WaitForMySQL()
    local attempts = 0
    while not MySQL or not MySQL.single do
        Wait(100)
        attempts = attempts + 1
        if attempts > 50 then -- 5 second timeout
            print('^1[MR_X:BOARDROOM]^7 MySQL not available after 5 seconds')
            return false
        end
    end
    return true
end

---Gather all context for a boardroom meeting
---@return table context
local function GatherContext()
    -- Ensure MySQL is ready before gathering context
    if not WaitForMySQL() then
        return {
            timestamp = os.time(),
            dateStr = os.date('%Y-%m-%d %H:%M:%S'),
            financial = { balance = 100000, mood = 'neutral', multipliers = { rewardBonus = 1.0, extortionChance = 0.3 } },
            players = {},
            events = {},
            stats = { totalPlayers = 0, onlinePlayers = 0, repDistribution = { elite = 0, trusted = 0, tested = 0, unknown = 0, disgraced = 0 } }
        }
    end
    local context = {
        timestamp = os.time(),
        dateStr = os.date('%Y-%m-%d %H:%M:%S'),
        financial = {
            balance = 50000,
            mood = 'neutral',
            multipliers = { rewardBonus = 1.0, extortionChance = 0.3 }
        },
        players = {},
        events = {},
        stats = {
            totalPlayers = 0,
            onlinePlayers = 0,
            repDistribution = {
                elite = 0,
                trusted = 0,
                tested = 0,
                unknown = 0,
                disgraced = 0
            }
        }
    }

    -- Get financial status (with pcall for safety)
    pcall(function()
        local balance = exports['sv_mr_x']:GetMrXBalance()
        if balance then context.financial.balance = balance end
    end)
    pcall(function()
        local mood = exports['sv_mr_x']:GetMrXMood()
        if mood then context.financial.mood = mood end
    end)
    pcall(function()
        local mult = exports['sv_mr_x']:GetMrXMultipliers()
        if mult then context.financial.multipliers = mult end
    end)

    -- Gather player data
    local activeOnly = Config.Boardroom and Config.Boardroom.Context and Config.Boardroom.Context.ActivePlayersOnly
    if activeOnly == nil then activeOnly = true end -- Default to active players only
    if activeOnly then
        for _, playerId in ipairs(GetPlayers()) do
            local success, player = pcall(function()
                return exports.qbx_core:GetPlayer(tonumber(playerId))
            end)
            if success and player then
                local cid = player.PlayerData.citizenid
                local rep = 50
                pcall(function()
                    rep = exports['sv_mr_x']:GetReputation(cid) or 50
                end)
                local tier = 'unknown'

                -- Categorize by reputation tier
                if rep >= 81 then tier = 'elite'
                elseif rep >= 51 then tier = 'trusted'
                elseif rep >= 21 then tier = 'tested'
                elseif rep >= 0 then tier = 'unknown'
                else tier = 'disgraced' end

                context.stats.repDistribution[tier] = context.stats.repDistribution[tier] + 1

                table.insert(context.players, {
                    citizenid = cid,
                    name = player.PlayerData.charinfo and
                           (player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname) or 'Unknown',
                    job = player.PlayerData.job and player.PlayerData.job.name or 'unemployed',
                    gang = player.PlayerData.gang and player.PlayerData.gang.name or 'none',
                    reputation = rep,
                    tier = tier,
                    online = true
                })
            end
        end
        context.stats.onlinePlayers = #context.players
    end

    -- Get total player count from database (with pcall for safety)
    pcall(function()
        local totalResult = MySQL.single.await('SELECT COUNT(*) as count FROM mr_x_profiles')
        context.stats.totalPlayers = totalResult and totalResult.count or 0
    end)

    -- Recent events from database
    local eventsLimit = Config.Boardroom and Config.Boardroom.Context and Config.Boardroom.Context.RecentEventsLimit or 50
    if eventsLimit > 0 then
        pcall(function()
            context.events = MySQL.query.await([[
                SELECT event_type, citizenid, data, created_at
                FROM mr_x_events
                ORDER BY created_at DESC
                LIMIT ?
            ]], { eventsLimit }) or {}
        end)

        -- Parse JSON data in events
        for i, event in ipairs(context.events) do
            if event.data then
                context.events[i].parsedData = JsonDecode(event.data)
            end
        end
    end

    return context
end

---Build context string for AI prompt
---@param context table
---@return table { financial: string, network: string, events: string }
local function BuildContextStrings(context)
    local strings = {
        financial = '',
        network = '',
        events = ''
    }

    -- Financial status
    strings.financial = string.format([[
- Current Balance: $%s
- Financial Mood: %s
- Reward Multiplier: %.1fx
- Extortion Likelihood: %.0f%%
]], FormatMoney(context.financial.balance),
    context.financial.mood:upper(),
    context.financial.multipliers.rewardBonus,
    context.financial.multipliers.extortionChance * 100)

    -- Network summary
    local networkLines = {
        string.format('Total Known Contacts: %d', context.stats.totalPlayers),
        string.format('Currently Active: %d', context.stats.onlinePlayers),
        '',
        'Reputation Distribution:',
        string.format('  - Elite (81+): %d', context.stats.repDistribution.elite),
        string.format('  - Trusted (51-80): %d', context.stats.repDistribution.trusted),
        string.format('  - Tested (21-50): %d', context.stats.repDistribution.tested),
        string.format('  - Unknown (0-20): %d', context.stats.repDistribution.unknown),
        string.format('  - Disgraced (<0): %d', context.stats.repDistribution.disgraced),
        ''
    }

    if #context.players > 0 then
        table.insert(networkLines, 'Active Operatives:')
        for _, p in ipairs(context.players) do
            table.insert(networkLines, string.format('  - %s | Job: %s | Rep: %d (%s)',
                p.citizenid, p.job, p.reputation, p.tier))
        end
    end

    strings.network = table.concat(networkLines, '\n')

    -- Recent events summary
    if #context.events > 0 then
        local eventLines = {'Recent Activity (last ' .. #context.events .. ' events):'}
        local eventCounts = {}
        for _, e in ipairs(context.events) do
            eventCounts[e.event_type] = (eventCounts[e.event_type] or 0) + 1
        end
        for eventType, count in pairs(eventCounts) do
            table.insert(eventLines, string.format('  - %s: %d', eventType, count))
        end
        strings.events = table.concat(eventLines, '\n')
    else
        strings.events = 'No recent activity recorded.'
    end

    return strings
end

-- ============================================
-- MEETING EXECUTION
-- ============================================

---Run a boardroom meeting
---@param manual? boolean Whether this was manually triggered
---@return table|nil meetingResult
function Boardroom.RunMeeting(manual)
    if not Config.Boardroom or not Config.Boardroom.Enabled then
        return { error = 'Boardroom system is disabled' }
    end

    -- Cooldown check for manual triggers
    if manual then
        local elapsed = os.time() - lastMeeting
        local cooldown = Config.Boardroom.ManualCooldownMinutes * 60
        if elapsed < cooldown then
            local remaining = math.ceil((cooldown - elapsed) / 60)
            return { error = string.format('Cooldown active: %d minutes remaining', remaining) }
        end
    end

    print('^3[MR_X:BOARDROOM]^7 Convening strategic session...')

    -- Gather context
    local context = GatherContext()
    local contextStrings = BuildContextStrings(context)

    -- Load prompt template
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local promptFile = io.open(resourcePath .. '/data/MR_X_BOARDROOM_PROMPT.md', 'r')
    local promptTemplate

    if promptFile then
        promptTemplate = promptFile:read('*all')
        promptFile:close()
    else
        -- Fallback minimal prompt
        promptTemplate = [[
You are Mr. X conducting a strategic planning session.
Analyze the current state and output a JSON plan.

{{financial_status}}

{{player_network}}

{{recent_events}}

Output valid JSON with: reasoning, plan (array of actions), overall_mood, next_boardroom_suggestion
]]
    end

    -- Substitute context into prompt
    -- Note: gsub treats '%' as special in replacement strings, so we escape them
    local function escapeGsub(str)
        return str:gsub('%%', '%%%%')
    end

    local prompt = promptTemplate
    prompt = prompt:gsub('{{financial_status}}', escapeGsub(contextStrings.financial))
    prompt = prompt:gsub('{{player_network}}', escapeGsub(contextStrings.network))
    prompt = prompt:gsub('{{recent_events}}', escapeGsub(contextStrings.events))

    -- Check if sv_nexus_tools is available
    if GetResourceState('sv_nexus_tools') ~= 'started' then
        print('^1[MR_X:BOARDROOM]^7 sv_nexus_tools not available - using fallback')
        return Boardroom.GenerateFallbackMeeting(context)
    end

    -- Call AI asynchronously using proper callback pattern
    -- sv_nexus_tools:CallOpenAI(prompt, systemPrompt, callback)
    local meetingResult = nil
    local aiComplete = false
    local aiError = nil

    exports['sv_nexus_tools']:CallOpenAI(
        'Conduct your boardroom analysis now. Output only valid JSON.',
        prompt,
        function(success, content, error)
            if not success then
                print('^1[MR_X:BOARDROOM]^7 AI call failed: ' .. tostring(error))
                aiError = error
                aiComplete = true
                return
            end

            -- Try to parse response as JSON
            local responseContent = content or ''

            -- Extract JSON from response (handle markdown code blocks)
            local jsonStr = responseContent
            local jsonMatch = responseContent:match('```json%s*(.-)%s*```')
            if jsonMatch then
                jsonStr = jsonMatch
            else
                jsonMatch = responseContent:match('```%s*(.-)%s*```')
                if jsonMatch then
                    jsonStr = jsonMatch
                end
            end

            local parseSuccess, parsed = pcall(json.decode, jsonStr)
            if parseSuccess and parsed then
                meetingResult = parsed
            else
                meetingResult = {
                    reasoning = responseContent,
                    plan = {},
                    overall_mood = context.financial.mood,
                    parse_error = 'Could not parse AI response as JSON'
                }
            end

            -- Add metadata
            meetingResult.timestamp = os.time()
            meetingResult.dateStr = os.date('%Y-%m-%d %H:%M:%S')
            meetingResult.context = context
            meetingResult.manual = manual or false

            -- Save meeting minutes
            local saved = Boardroom.SaveMeeting(meetingResult)

            -- Post webhook
            if Config.WebServer and Config.WebServer.Enabled then
                pcall(function()
                    exports['sv_mr_x']:PostWebhook('boardroom', {
                        event = 'meeting_complete',
                        filename = saved.filename,
                        mood = meetingResult.overall_mood,
                        planCount = meetingResult.plan and #meetingResult.plan or 0,
                        timestamp = meetingResult.timestamp
                    })
                end)
            end

            -- Notify admins if configured
            if Config.Boardroom.NotifyAdmins then
                print(string.format('^2[MR_X:BOARDROOM]^7 Meeting complete. Mood: %s | Actions: %d | File: %s',
                    meetingResult.overall_mood or 'unknown',
                    meetingResult.plan and #meetingResult.plan or 0,
                    saved.filename or 'unsaved'))

                -- Print plan summary
                if meetingResult.plan and #meetingResult.plan > 0 then
                    print('^3[MR_X:BOARDROOM]^7 Strategic Plan:')
                    for i, action in ipairs(meetingResult.plan) do
                        print(string.format('  %d. [%s] %s',
                            action.priority or i,
                            action.risk_level or 'unknown',
                            action.action or 'Unknown action'))
                    end
                end
            end

            lastMeeting = os.time()
            aiComplete = true
        end
    )

    -- Wait for AI response (with timeout)
    local timeout = (Config.Boardroom.AI and Config.Boardroom.AI.TimeoutMs or 60000) / 1000
    local waited = 0
    while not aiComplete and waited < timeout do
        Wait(100)
        waited = waited + 0.1
    end

    if not aiComplete then
        print('^1[MR_X:BOARDROOM]^7 AI call timed out after ' .. timeout .. 's')
        return Boardroom.GenerateFallbackMeeting(context)
    end

    if aiError then
        print('^1[MR_X:BOARDROOM]^7 Using fallback due to AI error')
        return Boardroom.GenerateFallbackMeeting(context)
    end

    return meetingResult
end

---Generate a fallback meeting without AI
---@param context table
---@return table
function Boardroom.GenerateFallbackMeeting(context)
    local mood = context.financial.mood
    local plan = {}

    -- Generate basic strategic recommendations based on mood
    if mood == 'desperate' then
        table.insert(plan, {
            priority = 1,
            action = 'Call in outstanding debts',
            target = 'general',
            method = 'Contact all players with negative reputation for payment',
            resource_cost = 0,
            expected_return = 10000,
            risk_level = 'medium',
            rationale = 'Immediate cash flow needed'
        })
        table.insert(plan, {
            priority = 2,
            action = 'Increase service fees',
            target = 'general',
            method = 'Raise prices on all HELP services by 20%',
            resource_cost = 0,
            expected_return = 5000,
            risk_level = 'low',
            rationale = 'Market will bear the increase given desperation'
        })
    elseif mood == 'tense' then
        table.insert(plan, {
            priority = 1,
            action = 'Focus on high-value targets',
            target = 'elite',
            method = 'Prioritize missions to trusted operatives',
            resource_cost = 5000,
            expected_return = 25000,
            risk_level = 'low',
            rationale = 'Reliable returns from proven assets'
        })
    elseif mood == 'expansive' then
        table.insert(plan, {
            priority = 1,
            action = 'Expand network',
            target = 'unknown',
            method = 'Recruit new operatives with signing bonuses',
            resource_cost = 10000,
            expected_return = 50000,
            risk_level = 'medium',
            rationale = 'Invest in growth while resources allow'
        })
    else
        table.insert(plan, {
            priority = 1,
            action = 'Maintain current operations',
            target = 'general',
            method = 'Continue standard mission flow',
            resource_cost = 0,
            expected_return = 15000,
            risk_level = 'low',
            rationale = 'Steady state operations'
        })
    end

    local result = {
        reasoning = string.format('Fallback analysis: Financial mood is %s. %d operatives currently active. %d total contacts in network.',
            mood, context.stats.onlinePlayers, context.stats.totalPlayers),
        plan = plan,
        overall_mood = mood,
        next_boardroom_suggestion = 'Reconvene in 24 hours or when financial situation changes significantly',
        timestamp = os.time(),
        dateStr = os.date('%Y-%m-%d %H:%M:%S'),
        context = context,
        isFallback = true
    }

    local saved = Boardroom.SaveMeeting(result)
    result.savedAs = saved.filename

    return result
end

---Save meeting minutes to file
---@param meeting table
---@return table { success: boolean, filename: string, path: string }
function Boardroom.SaveMeeting(meeting)
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local outputDir = resourcePath .. '/' .. (Config.Boardroom.OutputDir or 'data/boardroom')

    -- Ensure directory exists (best effort)
    os.execute('mkdir "' .. outputDir .. '" 2>nul')

    local filename = string.format('meeting_%s.json', os.date('%Y%m%d_%H%M%S'))
    local filePath = outputDir .. '/' .. filename

    local file = io.open(filePath, 'w')
    if file then
        -- Pretty print JSON
        local jsonStr = json.encode(meeting)
        file:write(jsonStr)
        file:close()

        if Config.Debug then
            print('^2[MR_X:BOARDROOM]^7 Saved meeting: ' .. filename)
        end

        return { success = true, filename = filename, path = filePath }
    else
        print('^1[MR_X:BOARDROOM]^7 Failed to save meeting to ' .. filePath)
        return { success = false, filename = filename, path = filePath }
    end
end

---Get list of past meetings
---@param limit? number
---@return table meetings
function Boardroom.GetMeetings(limit)
    limit = limit or 20
    local resourcePath = GetResourcePath(GetCurrentResourceName())
    local outputDir = resourcePath .. '/' .. (Config.Boardroom.OutputDir or 'data/boardroom')

    local meetings = {}

    -- List files in directory (platform-specific)
    local handle = io.popen('dir /b /o-d "' .. outputDir .. '\\*.json" 2>nul')
    if handle then
        for filename in handle:lines() do
            if #meetings >= limit then break end

            local file = io.open(outputDir .. '/' .. filename, 'r')
            if file then
                local content = file:read('*all')
                file:close()

                local success, meeting = pcall(json.decode, content)
                if success and meeting then
                    table.insert(meetings, {
                        filename = filename,
                        timestamp = meeting.timestamp,
                        mood = meeting.overall_mood,
                        planCount = meeting.plan and #meeting.plan or 0,
                        reasoning = meeting.reasoning and meeting.reasoning:sub(1, 200) or ''
                    })
                end
            end
        end
        handle:close()
    end

    return meetings
end

-- ============================================
-- AUTO SCHEDULER
-- ============================================

CreateThread(function()
    if not Config.Boardroom or not Config.Boardroom.Enabled then
        return
    end

    -- Initial delay before first auto meeting (wait for server to stabilize)
    Wait(60000) -- 1 minute

    while true do
        -- Wait for interval
        local intervalMs = (Config.Boardroom.IntervalHours or 24) * 60 * 60 * 1000
        Wait(intervalMs)

        -- Run automatic meeting
        print('^3[MR_X:BOARDROOM]^7 Running scheduled strategic session...')
        Boardroom.RunMeeting(false)
    end
end)

-- ============================================
-- CONSOLE COMMANDS
-- ============================================

-- Manual trigger command
RegisterCommand('mrx_boardroom', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        print('^1[MR_X:BOARDROOM]^7 Permission denied')
        return
    end

    print('^3[MR_X:BOARDROOM]^7 Manually triggering boardroom session...')
    local result = Boardroom.RunMeeting(true)

    if result then
        if result.error then
            print('^1[MR_X:BOARDROOM]^7 ' .. result.error)
        elseif result.pending then
            print('^3[MR_X:BOARDROOM]^7 ' .. result.message)
        else
            print(string.format('^2[MR_X:BOARDROOM]^7 Complete. Mood: %s | Actions: %d',
                result.overall_mood or 'unknown',
                result.plan and #result.plan or 0))

            -- Print plan summary
            if result.plan and #result.plan > 0 then
                print('^3[MR_X:BOARDROOM]^7 Strategic Plan:')
                for i, action in ipairs(result.plan) do
                    print(string.format('  %d. [%s] %s - %s',
                        action.priority or i,
                        action.risk_level or 'unknown',
                        action.action or 'Unknown action',
                        action.rationale or ''))
                end
            end
        end
    end
end, false)

-- List past meetings
RegisterCommand('mrx_meetings', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local limit = tonumber(args[1]) or 10
    local meetings = Boardroom.GetMeetings(limit)

    print(string.format('^3[MR_X:BOARDROOM]^7 Last %d meetings:', #meetings))
    for _, m in ipairs(meetings) do
        print(string.format('  - %s | Mood: %s | Actions: %d',
            m.filename, m.mood or 'unknown', m.planCount))
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('RunBoardroom', Boardroom.RunMeeting)
exports('GetBoardroomMeetings', Boardroom.GetMeetings)

return Boardroom
