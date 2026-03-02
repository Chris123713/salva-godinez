--[[
    Mr. X HTTP Handler
    ==================
    HTTP endpoint to receive manual commands from web dashboard
]]

local HttpHandler = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function IsAdmin(source)
    return IsPlayerAceAllowed(source, 'admin') or IsPlayerAceAllowed(source, 'command.mrx')
end

-- ============================================
-- REQUEST PROCESSING FUNCTIONS
-- ============================================

local function HandleStatus(req, res)
    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        status = 'online',
        testMode = Config.TestMode,
        chaosEnabled = Config.ChaosEngine.Enabled,
        webServerEnabled = Config.WebServer.Enabled,
        playerCount = #GetPlayers(),
        timestamp = os.time()
    }))
end

local function HandleMrXStatus(req, res)
    -- Get Mr. X financial status
    local balance = 0
    local mood = 'unknown'

    -- Try to get from banking module
    local bankSuccess, bankBalance = pcall(function()
        return exports['sv_mr_x']:GetMrXBalance()
    end)
    if bankSuccess and bankBalance then
        balance = bankBalance
    end

    local moodSuccess, bankMood = pcall(function()
        return exports['sv_mr_x']:GetMrXMood()
    end)
    if moodSuccess and bankMood then
        mood = bankMood
    end

    -- Count active missions from database (with error handling for missing table)
    local activeMissions = 0
    local missionSuccess, missionResult = pcall(function()
        return MySQL.single.await([[
            SELECT COUNT(*) as count FROM mr_x_missions
            WHERE status = 'active'
        ]])
    end)
    if missionSuccess and missionResult then
        activeMissions = missionResult.count or 0
    end

    -- Count pending bounties (with error handling for missing table)
    local pendingBounties = 0
    local bountySuccess, bountyResult = pcall(function()
        return MySQL.single.await([[
            SELECT COUNT(*) as count FROM mr_x_bounties
            WHERE status = 'active'
        ]])
    end)
    if bountySuccess and bountyResult then
        pendingBounties = bountyResult.count or 0
    end

    -- Get last boardroom meeting time (with error handling)
    local lastBoardroom = nil
    local boardroomSuccess, boardroomResult = pcall(function()
        return MySQL.single.await([[
            SELECT created_at FROM mr_x_events
            WHERE event_type = 'boardroom_complete'
            ORDER BY created_at DESC LIMIT 1
        ]])
    end)
    if boardroomSuccess and boardroomResult and boardroomResult.created_at then
        lastBoardroom = boardroomResult.created_at
    end

    -- Count active network (players with profiles)
    local networkSize = 0
    local networkSuccess, networkResult = pcall(function()
        return MySQL.single.await([[
            SELECT COUNT(*) as count FROM mr_x_profiles
            WHERE opted_out = 0 AND last_contact IS NOT NULL
        ]])
    end)
    if networkSuccess and networkResult then
        networkSize = networkResult.count or 0
    end

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        balance = balance,
        mood = mood,
        activeMissions = activeMissions,
        pendingBounties = pendingBounties,
        networkSize = networkSize,
        lastBoardroom = lastBoardroom,
        playerCount = #GetPlayers(),
        fivemConnected = true,
        timestamp = os.time()
    }))
end

local function HandleProfile(req, res)
    local citizenid = req.headers['X-Citizenid'] or req.headers['x-citizenid']

    if not citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing X-Citizenid header'}))
        return
    end

    -- Try to get existing profile, or create one if player is online
    local profile = exports['sv_mr_x']:GetProfile(citizenid)

    if not profile then
        -- Try to find online player and create profile
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = exports.qbx_core:GetPlayer(tonumber(playerId))
            if player and player.PlayerData.citizenid == citizenid then
                -- Player is online, create profile
                profile = exports['sv_mr_x']:GetOrCreateProfile(citizenid, player.PlayerData)
                break
            end
        end
    end

    if not profile then
        res.writeHead(404, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Profile not found and player not online', citizenid = citizenid}))
        return
    end

    local tier = 'EASY'
    if profile.reputation >= Config.Reputation.Tiers.HIGH_RISK.min then
        tier = 'HIGH_RISK'
    elseif profile.reputation >= Config.Reputation.Tiers.DILEMMA.min then
        tier = 'DILEMMA'
    end

    local charInfo = nil
    local isOnline = false
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            isOnline = true
            local pd = player.PlayerData
            charInfo = {
                name = (pd.charinfo.firstname or '') .. ' ' .. (pd.charinfo.lastname or ''),
                job = pd.job and pd.job.label or 'Unemployed',
                jobGrade = pd.job and pd.job.grade and pd.job.grade.name or '',
                gang = pd.gang and pd.gang.label or 'None',
                cash = pd.money and pd.money.cash or 0,
                bank = pd.money and pd.money.bank or 0
            }
            break
        end
    end

    local response = {
        citizenid = citizenid,
        isOnline = isOnline,
        character = charInfo,
        profile = {
            reputation = profile.reputation or 0,
            tier = tier,
            archetype = profile.archetype or 'civilian',
            totalMissions = profile.total_missions or 0,
            successfulMissions = profile.successful_missions or 0,
            successRate = profile.total_missions > 0
                and math.floor((profile.successful_missions or 0) / profile.total_missions * 100)
                or 0,
            lastMission = profile.last_mission,
            lastContact = profile.last_contact,
            optedOut = profile.opted_out == 1,
            createdAt = profile.created_at
        },
        history = profile.history or {},
        knownFacts = profile.known_facts or {}
    }

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode(response))
end

local function HandleManual(req, res, bodyData)
    -- Check if manual mode is enabled
    if not Config.ManualMode or not Config.ManualMode.Enabled then
        res.writeHead(403, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Manual mode is disabled'}))
        return
    end

    -- Parse body
    print('^3[MR_X:HTTP]^7 Parsing body: ' .. tostring(bodyData))

    local success, body = pcall(json.decode, bodyData or '{}')
    if not success or not body then
        print('^1[MR_X:HTTP]^7 JSON parse failed: ' .. tostring(body))
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Invalid JSON body', received = tostring(bodyData):sub(1, 100)}))
        return
    end

    -- Validate required fields
    if not body.citizenid or not body.message then
        print('^1[MR_X:HTTP]^7 Missing fields. citizenid=' .. tostring(body.citizenid) .. ', message=' .. tostring(body.message))
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing citizenid or message', hascitizenid = body.citizenid ~= nil, hasmessage = body.message ~= nil}))
        return
    end

    -- Find player source by citizenid
    local playerSource = exports['sv_mr_x']:FindPlayerSource(body.citizenid)
    if not playerSource then
        res.writeHead(404, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Player not online', citizenid = body.citizenid}))
        return
    end

    -- Check if player is exempt
    local isExempt, exemptReason = exports['sv_mr_x']:IsExempt(playerSource)
    if isExempt then
        res.writeHead(403, {['Content-Type'] = 'application/json'})
        res.send(json.encode({
            error = 'Player is exempt from Mr. X',
            citizenid = body.citizenid,
            reason = exemptReason
        }))
        return
    end

    -- Determine channel and send message
    local channel = body.channel or 'sms'
    local sendSuccess = false

    if channel == 'sms' then
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, body.message)
    elseif channel == 'email' then
        sendSuccess = exports['sv_mr_x']:SendMrXEmail(
            playerSource,
            body.subject or 'Message from Mr. X',
            body.message
        )
    elseif channel == 'notification' then
        sendSuccess = exports['sv_mr_x']:SendMrXNotification(playerSource, 'Mr. X', body.message)
    else
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Invalid channel: ' .. tostring(channel)}))
        return
    end

    -- Log the manual action
    if sendSuccess and Config.LogEvents then
        MySQL.insert.await([[
            INSERT INTO mr_x_events (citizenid, event_type, data, source)
            VALUES (?, ?, ?, ?)
        ]], {
            body.citizenid,
            MrXConstants.EventTypes.ADMIN_ACTION,
            JsonEncode({
                action = 'manual_message',
                channel = channel,
                message = body.message:sub(1, 100),
                refactored = body.refactored or false,
                adminNote = body.adminNote
            }),
            'web_dashboard'
        })
    end

    -- Note: Webhook is already posted by SendMrXMessage/SendMrXEmail/SendMrXNotification in comms.lua
    -- No need to post again here (was causing duplicate messages)

    -- Send response
    res.writeHead(sendSuccess and 200 or 500, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = sendSuccess,
        citizenid = body.citizenid,
        channel = channel,
        message = sendSuccess and 'Message sent' or 'Failed to send message'
    }))
end

-- ============================================
-- TEST CONVERSATION ENDPOINTS
-- For dashboard testing of AI workflow
-- ============================================

local function HandleTestConversation(req, res, bodyData)
    local success, body = pcall(json.decode, bodyData or '{}')
    if not success or not body or not body.citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing citizenid'}))
        return
    end

    local citizenid = body.citizenid
    local contactType = body.contactType
    local context = body.context or {}
    local customMessage = body.customMessage
    local jobTarget = body.jobTarget

    -- Find player source
    local playerSource = exports['sv_mr_x']:FindPlayerSource(citizenid)
    if not playerSource then
        res.writeHead(404, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Player not online', citizenid = citizenid}))
        return
    end

    -- Check exemption
    local isExempt, exemptReason = exports['sv_mr_x']:IsExempt(playerSource)
    if isExempt then
        res.writeHead(403, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Player is exempt', reason = exemptReason}))
        return
    end

    print('^3[MR_X:TEST]^7 Executing test conversation: ' .. contactType .. ' -> ' .. citizenid)

    local sendSuccess = false
    local message = nil
    local channel = 'sms'

    -- Handle different contact types
    if contactType == 'mission_offer' then
        -- Generate and offer a mission
        local missionSuccess, missionResult = pcall(function()
            return exports['sv_mr_x']:GenerateAndOfferMission(playerSource, 'test')
        end)
        if missionSuccess and missionResult then
            sendSuccess = true
            message = missionResult.message or 'Mission offered'
        else
            message = 'Mission generation failed: ' .. tostring(missionResult)
        end

    elseif contactType == 'check_in' then
        message = exports['sv_mr_x']:GenerateCheckInMessage(citizenid) or 'I may have something for you soon...'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'warning' then
        message = exports['sv_mr_x']:GenerateWarningMessage(citizenid) or 'I have eyes everywhere. Remember that.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'tip' then
        message = exports['sv_mr_x']:GenerateTipMessage(citizenid) or 'A little free intel: there are opportunities if you know where to look.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'reputation_update' then
        local rep = exports['sv_mr_x']:GetReputation(citizenid) or 0
        message = string.format('Your standing with me is at %d. %s', rep,
            rep > 50 and 'Keep up the good work.' or 'There is room for improvement.')
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'prospect_welcome' then
        sendSuccess = exports['sv_mr_x']:SendProspectWelcome(playerSource, false)
        message = 'Welcome message sent'

    elseif contactType == 'prospect_welcome_gift' then
        sendSuccess = exports['sv_mr_x']:SendProspectWelcome(playerSource, true)
        message = 'Welcome message with gift sent'

    elseif contactType == 'prospect_job_nudge' then
        sendSuccess = exports['sv_mr_x']:SendJobSuggestion(playerSource, jobTarget)
        message = 'Job suggestion sent: ' .. (jobTarget or 'auto')

    elseif contactType == 'prospect_checkin' then
        sendSuccess = exports['sv_mr_x']:SendProspectCheckIn(playerSource)
        message = 'Prospect check-in sent'

    elseif contactType == 'prospect_tip' then
        sendSuccess = exports['sv_mr_x']:SendProspectTip(playerSource)
        message = 'Prospect tip sent'

    elseif contactType == 'mission_success' then
        message = exports['sv_mr_x']:GenerateMissionSuccessMessage(citizenid) or 'Well done. We will be in touch.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'mission_failure' then
        message = exports['sv_mr_x']:GenerateMissionFailureMessage(citizenid) or 'Disappointing. I expected more.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'extortion' then
        message = exports['sv_mr_x']:GenerateExtortionMessage(citizenid) or 'You owe me. Pay up, or there will be consequences.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'threat' then
        message = exports['sv_mr_x']:GenerateThreatMessage(citizenid) or 'I know where you are. Do not test me.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'service_offer' then
        message = 'I have services available for those I trust. Record clearing, intel, protection... for a price.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'loan_offer' then
        message = 'Need money? I can help. But understand - my interest rates are not negotiable.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'loan_reminder' then
        message = 'A reminder about what you owe me. Do not make me ask again.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'bounty_notification' then
        message = 'Someone has put a price on your head. Watch your back.'
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)

    elseif contactType == 'custom' then
        -- Use AI to refactor custom message to Mr. X voice
        if customMessage and customMessage ~= '' then
            local refactored = exports['sv_mr_x']:RefactorToMrXVoice(customMessage, citizenid)
            message = refactored or customMessage
            sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)
        else
            res.writeHead(400, {['Content-Type'] = 'application/json'})
            res.send(json.encode({error = 'Custom message required'}))
            return
        end

    else
        -- Unknown type - try to generate AI message with context
        message = 'Contact type not fully implemented: ' .. tostring(contactType)
        sendSuccess = exports['sv_mr_x']:SendMrXMessage(playerSource, message)
    end

    -- Log the test
    if Config.LogEvents then
        MySQL.insert([[
            INSERT INTO mr_x_events (citizenid, event_type, data, source)
            VALUES (?, ?, ?, ?)
        ]], {
            citizenid,
            'test_conversation',
            json.encode({contactType = contactType, message = message, success = sendSuccess}),
            'dashboard_test'
        })
    end

    -- Update last contact
    if sendSuccess then
        exports['sv_mr_x']:UpdateLastContact(citizenid)
    end

    res.writeHead(sendSuccess and 200 or 500, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = sendSuccess,
        message = message,
        channel = channel,
        contactType = contactType,
        citizenid = citizenid
    }))
end

local function HandleAIStatus(req, res)
    -- Check if sv_nexus_tools is available
    local hasNexusTools = GetResourceState('sv_nexus_tools') == 'started'

    local status = {
        nexusTools = hasNexusTools,
        testMode = Config.TestMode,
        aiModel = Config.OpenAI and Config.OpenAI.Model or 'unknown'
    }

    -- Try a simple API check
    if hasNexusTools then
        local pingSuccess, pingResult = pcall(function()
            return exports['sv_nexus_tools']:Ping()
        end)
        status.apiResponding = pingSuccess and pingResult
    end

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode(status))
end

-- ============================================
-- AGENT LOOP TESTING ENDPOINT
-- Triggers agent loop manually for testing (bypasses TestMode)
-- ============================================

local function HandleAgentLoop(req, res, bodyData)
    local success, body = pcall(json.decode, bodyData or '{}')
    if not success or not body or not body.citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing citizenid'}))
        return
    end

    local citizenid = body.citizenid
    local customPrompt = body.prompt
    local triggerType = body.triggerType or 'manual_test'

    print('^3[MR_X:AGENT]^7 Manual agent loop triggered for ' .. citizenid)

    -- Find player source (optional - agent can work with offline players too)
    local playerSource = exports['sv_mr_x']:FindPlayerSource(citizenid)
    local isOnline = playerSource ~= nil

    -- Check exemption if online
    if playerSource then
        local isExempt, exemptReason = exports['sv_mr_x']:IsExempt(playerSource)
        if isExempt then
            res.writeHead(403, {['Content-Type'] = 'application/json'})
            res.send(json.encode({error = 'Player is exempt', reason = exemptReason}))
            return
        end
    end

    -- Build the trigger prompt
    local prompt = customPrompt
    if not prompt or prompt == '' then
        -- Default prompts based on trigger type
        if triggerType == 'login' then
            local isProspect = playerSource and exports['sv_mr_x']:IsProspect(playerSource)
            if isProspect then
                prompt = string.format(
                    'New player %s has logged in. They appear to be new to the city (prospect). ' ..
                    'Consider welcoming them and building rapport.',
                    citizenid
                )
            else
                local profile = exports['sv_mr_x']:GetProfile(citizenid)
                local rep = profile and profile.reputation or 50
                prompt = string.format(
                    'Player %s has logged in. Reputation: %d. ' ..
                    'Consider whether any proactive contact is appropriate.',
                    citizenid, rep
                )
            end
        elseif triggerType == 'mission_complete' then
            prompt = string.format(
                'Player %s completed a mission successfully. ' ..
                'Decide on appropriate response (message, reputation adjustment, follow-up).',
                citizenid
            )
        elseif triggerType == 'mission_failed' then
            prompt = string.format(
                'Player %s failed a mission. ' ..
                'Decide on appropriate response (disappointment message, reputation penalty, follow-up).',
                citizenid
            )
        elseif triggerType == 'debt_check' then
            prompt = string.format(
                'Check if player %s has any outstanding debts or loans. ' ..
                'If so, consider sending a reminder or escalating collection.',
                citizenid
            )
        else
            prompt = string.format(
                'Analyze player %s and decide if any action is needed. ' ..
                'Check their context first, then determine the appropriate response.',
                citizenid
            )
        end
    end

    -- Run the agent loop (this bypasses TestMode check since we're calling directly)
    local startTime = os.time()

    -- Call the executor directly (not through the trigger functions that check TestMode)
    local result = exports['sv_mr_x']:RunAgentLoop(prompt, {
        citizenid = citizenid,
        source = playerSource,
        trigger_type = triggerType
    }, 5)

    local endTime = os.time()
    local duration = endTime - startTime

    print(string.format('^3[MR_X:AGENT]^7 Agent loop complete: %s, Iterations: %d, Actions: %d, Duration: %ds',
        tostring(result.complete),
        result.iterations or 0,
        result.actions and #result.actions or 0,
        duration
    ))

    -- Build response
    local response = {
        success = result.complete or false,
        citizenid = citizenid,
        isOnline = isOnline,
        triggerType = triggerType,
        prompt = prompt,
        iterations = result.iterations or 0,
        actions = result.actions or {},
        message = result.message,
        duration = duration,
        timestamp = os.time()
    }

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode(response))
end

local function HandlePlayerContext(req, res)
    local citizenid = req.headers['X-Citizenid'] or req.headers['x-citizenid']

    if not citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing X-Citizenid header'}))
        return
    end

    -- Get profile
    local profile = exports['sv_mr_x']:GetProfile(citizenid)

    -- Get player data if online
    local playerData = nil
    local isOnline = false
    local playerSource = exports['sv_mr_x']:FindPlayerSource(citizenid)
    if playerSource then
        isOnline = true
        local player = exports.qbx_core:GetPlayer(playerSource)
        if player then
            local pd = player.PlayerData
            playerData = {
                name = (pd.charinfo.firstname or '') .. ' ' .. (pd.charinfo.lastname or ''),
                job = pd.job and pd.job.name or 'unemployed',
                jobGrade = pd.job and pd.job.grade and pd.job.grade.level or 0,
                gang = pd.gang and pd.gang.name or 'none',
                cash = pd.money and pd.money.cash or 0,
                bank = pd.money and pd.money.bank or 0
            }
        end
    end

    -- Get personality context
    local personalityContext = exports['sv_mr_x']:BuildPersonalityContext(citizenid, nil)

    -- Check exemption
    local isExempt, exemptReason = exports['sv_mr_x']:IsExemptByCitizenId(citizenid)

    -- Check prospect status
    local isProspect = false
    if playerSource then
        isProspect = exports['sv_mr_x']:IsProspect(playerSource)
    end

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        citizenid = citizenid,
        isOnline = isOnline,
        playerData = playerData,
        profile = profile,
        personalityContext = personalityContext,
        isExempt = isExempt,
        exemptReason = exemptReason,
        isProspect = isProspect,
        mrxMood = exports['sv_mr_x']:GetMrXMood(),
        mrxBalance = exports['sv_mr_x']:GetMrXBalance()
    }))
end

-- ============================================
-- PROSPECT ENDPOINTS
-- ============================================

local function HandleProspects(req, res)
    -- Get all current prospects
    local prospects = {}

    local success, allProspects = pcall(function()
        return exports['sv_mr_x']:GetAllProspects()
    end)

    if success and allProspects then
        for _, p in ipairs(allProspects) do
            table.insert(prospects, {
                citizenid = p.citizenid,
                name = p.name,
                totalMoney = p.totalMoney,
                source = p.source
            })
        end
    end

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = true,
        prospects = prospects,
        count = #prospects
    }))
end

local function HandleProspectNeeds(req, res)
    -- Return current Mr. X needs from config
    local needs = {
        jobs = {},
        criminal = {},
        authority = {}
    }

    if Config.Prospect and Config.Prospect.CurrentNeeds then
        local cn = Config.Prospect.CurrentNeeds

        for _, job in ipairs(cn.JobPlacements or {}) do
            table.insert(needs.jobs, {
                target = job.job,
                priority = job.priority,
                reason = job.reason
            })
        end

        for _, crim in ipairs(cn.CriminalRecruits or {}) do
            table.insert(needs.criminal, {
                target = crim.type,
                priority = crim.priority,
                reason = crim.reason
            })
        end

        for _, auth in ipairs(cn.AuthorityPlacements or {}) do
            table.insert(needs.authority, {
                target = auth.job,
                priority = auth.priority,
                reason = auth.reason
            })
        end
    end

    res.writeHead(200, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = true,
        needs = needs
    }))
end

local function HandleProspectWelcome(req, res, bodyData)
    local success, body = pcall(json.decode, bodyData or '{}')
    if not success or not body or not body.citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing citizenid'}))
        return
    end

    -- Find player source
    local playerSource = exports['sv_mr_x']:FindPlayerSource(body.citizenid)
    if not playerSource then
        res.writeHead(404, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Player not online'}))
        return
    end

    -- Send welcome
    local welcomeSuccess = exports['sv_mr_x']:SendProspectWelcome(playerSource, body.withGift or false)

    res.writeHead(welcomeSuccess and 200 or 500, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = welcomeSuccess,
        citizenid = body.citizenid
    }))
end

local function HandleProspectNudge(req, res, bodyData)
    local success, body = pcall(json.decode, bodyData or '{}')
    if not success or not body or not body.citizenid then
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Missing citizenid'}))
        return
    end

    -- Find player source
    local playerSource = exports['sv_mr_x']:FindPlayerSource(body.citizenid)
    if not playerSource then
        res.writeHead(404, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Player not online'}))
        return
    end

    -- Send nudge based on type
    local nudgeSuccess = false
    if body.type == 'job' then
        nudgeSuccess = exports['sv_mr_x']:SendJobSuggestion(playerSource, body.target)
    elseif body.type == 'checkin' then
        nudgeSuccess = exports['sv_mr_x']:SendProspectCheckIn(playerSource)
    elseif body.type == 'tip' then
        nudgeSuccess = exports['sv_mr_x']:SendProspectTip(playerSource)
    else
        res.writeHead(400, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Invalid nudge type'}))
        return
    end

    res.writeHead(nudgeSuccess and 200 or 500, {['Content-Type'] = 'application/json'})
    res.send(json.encode({
        success = nudgeSuccess,
        citizenid = body.citizenid,
        type = body.type,
        target = body.target
    }))
end

-- ============================================
-- HTTP HANDLER REGISTRATION
-- ============================================

SetHttpHandler(function(req, res)
    -- Debug: Log all incoming requests
    print('^3[MR_X:HTTP]^7 Request: ' .. req.method .. ' ' .. req.path)

    -- Only handle our endpoints
    -- FiveM strips resource name prefix, so /sv_mr_x/manual becomes /manual
    local validPaths = {'/manual', '/status', '/profile', '/mrx-status', '/prospects', '/prospect-needs', '/prospect-welcome', '/prospect-nudge', '/test-conversation', '/ai-status', '/player-context', '/agent-loop'}
    local isValidPath = false
    for _, path in ipairs(validPaths) do
        if req.path == path then
            isValidPath = true
            break
        end
    end
    if not isValidPath then
        res.send('')
        return
    end

    -- Validate secret header (case-insensitive header lookup)
    local secret = req.headers['X-MrX-Secret'] or req.headers['x-mrx-secret']
    if not secret or secret ~= Config.WebServer.Secret then
        res.writeHead(401, {['Content-Type'] = 'application/json'})
        res.send(json.encode({error = 'Unauthorized'}))
        return
    end

    -- STATUS ENDPOINT (no body needed)
    if req.path == '/status' then
        HandleStatus(req, res)
        return
    end

    -- MR. X STATUS ENDPOINT (balance, mood, active missions)
    if req.path == '/mrx-status' then
        HandleMrXStatus(req, res)
        return
    end

    -- TEST CONVERSATION ENDPOINT
    if req.path == '/test-conversation' and req.method == 'POST' then
        local bodyChunks = {}
        req.setDataHandler(function(data)
            table.insert(bodyChunks, data)
        end, 'text')
        Citizen.SetTimeout(50, function()
            local bodyData = table.concat(bodyChunks)
            HandleTestConversation(req, res, bodyData)
        end)
        return
    end

    -- AI STATUS ENDPOINT
    if req.path == '/ai-status' then
        HandleAIStatus(req, res)
        return
    end

    -- PLAYER CONTEXT ENDPOINT
    if req.path == '/player-context' then
        HandlePlayerContext(req, res)
        return
    end

    -- AGENT LOOP ENDPOINT (for testing Brain Feed)
    if req.path == '/agent-loop' and req.method == 'POST' then
        local bodyChunks = {}
        req.setDataHandler(function(data)
            table.insert(bodyChunks, data)
        end, 'text')
        Citizen.SetTimeout(50, function()
            local bodyData = table.concat(bodyChunks)
            HandleAgentLoop(req, res, bodyData)
        end)
        return
    end

    -- PROFILE ENDPOINT (no body needed, uses headers)
    if req.path == '/profile' then
        HandleProfile(req, res)
        return
    end

    -- PROSPECT ENDPOINTS
    if req.path == '/prospects' then
        HandleProspects(req, res)
        return
    end

    if req.path == '/prospect-needs' then
        HandleProspectNeeds(req, res)
        return
    end

    if req.path == '/prospect-welcome' and req.method == 'POST' then
        local bodyChunks = {}
        req.setDataHandler(function(data)
            table.insert(bodyChunks, data)
        end, 'text')
        Citizen.SetTimeout(50, function()
            local bodyData = table.concat(bodyChunks)
            HandleProspectWelcome(req, res, bodyData)
        end)
        return
    end

    if req.path == '/prospect-nudge' and req.method == 'POST' then
        local bodyChunks = {}
        req.setDataHandler(function(data)
            table.insert(bodyChunks, data)
        end, 'text')
        Citizen.SetTimeout(50, function()
            local bodyData = table.concat(bodyChunks)
            HandleProspectNudge(req, res, bodyData)
        end)
        return
    end

    -- MANUAL ENDPOINT (needs body - use async handler)
    if req.path == '/manual' and req.method == 'POST' then
        local bodyChunks = {}

        req.setDataHandler(function(data)
            table.insert(bodyChunks, data)
        end, 'text')

        -- Process after body is received
        Citizen.SetTimeout(50, function()
            local bodyData = table.concat(bodyChunks)
            print('^3[MR_X:HTTP]^7 Body received (' .. #bodyData .. ' bytes)')
            HandleManual(req, res, bodyData)
        end)
        return
    end

    -- Default: not found
    res.writeHead(404, {['Content-Type'] = 'application/json'})
    res.send(json.encode({error = 'Not found'}))
end)

-- ============================================
-- ADMIN COMMANDS FOR TESTING
-- ============================================

RegisterCommand('mrx_testweb', function(source, args)
    if source ~= 0 and not IsAdmin(source) then
        print('^1[MR_X]^7 No permission')
        return
    end

    if not Config.WebServer or not Config.WebServer.Enabled then
        print('^3[MR_X]^7 WebServer is disabled in config')
        return
    end

    local url = Config.WebServer.URL .. '/api/status'

    print('^3[MR_X]^7 Testing connection to: ' .. url)

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            print('^2[MR_X]^7 Web server connected!')
            print('^2[MR_X]^7 Response: ' .. (response or 'ok'))
        else
            print('^1[MR_X]^7 Web server connection failed!')
            print('^1[MR_X]^7 Status: ' .. tostring(statusCode or 'nil'))
            print('^1[MR_X]^7 Response: ' .. tostring(response or 'none'))
        end
    end, 'GET', '', {
        ['X-MrX-Secret'] = Config.WebServer.Secret
    })
end, false)

RegisterCommand('mrx_testwebhook', function(source, args)
    if source ~= 0 and not IsAdmin(source) then
        print('^1[MR_X]^7 No permission')
        return
    end

    if not Config.WebServer or not Config.WebServer.Enabled then
        print('^3[MR_X]^7 WebServer is disabled in config')
        return
    end

    exports['sv_mr_x']:PostWebhook('test', {
        message = 'Test event from Lua',
        source = source,
        timestamp = os.time()
    })

    print('^2[MR_X]^7 Test webhook sent to dashboard')
end, false)

-- Run a full fact scan on a player
RegisterCommand('mrx_scan', function(source, args)
    if source ~= 0 and not IsAdmin(source) then
        print('^1[MR_X]^7 No permission')
        return
    end

    local target = args[1]
    if not target then
        print('^3[MR_X]^7 Usage: mrx_scan [player_id or citizenid]')
        return
    end

    local targetId = tonumber(target)
    local citizenid = nil
    local player = nil

    if targetId then
        player = exports.qbx_core:GetPlayer(targetId)
        if player then
            citizenid = player.PlayerData.citizenid
        end
    else
        citizenid = target
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local p = exports.qbx_core:GetPlayer(tonumber(playerId))
            if p and p.PlayerData.citizenid == citizenid then
                player = p
                targetId = tonumber(playerId)
                break
            end
        end
    end

    if not citizenid then
        print('^1[MR_X]^7 Player not found')
        return
    end

    print('^3[MR_X]^7 Running full fact scan on ' .. citizenid .. '...')

    local facts = exports['sv_mr_x']:FullFactScan(citizenid, targetId)

    print('^2[MR_X]^7 Fact scan complete. Found facts:')
    local factCount = 0
    for k, v in pairs(facts) do
        factCount = factCount + 1
        if type(v) == 'table' then
            print('  - ' .. k .. ': ' .. json.encode(v))
        else
            print('  - ' .. k .. ': ' .. tostring(v))
        end
    end

    if factCount == 0 then
        print('^3[MR_X]^7 No new facts discovered from this scan.')
    end

    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    if profile and profile.known_facts then
        local existingCount = 0
        for _ in pairs(profile.known_facts) do existingCount = existingCount + 1 end
        print('^2[MR_X]^7 Total known facts in profile: ' .. existingCount)
    end
end, false)

return HttpHandler
