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
-- HTTP HANDLER REGISTRATION
-- ============================================

SetHttpHandler(function(req, res)
    -- Debug: Log all incoming requests
    print('^3[MR_X:HTTP]^7 Request: ' .. req.method .. ' ' .. req.path)

    -- Only handle our endpoints
    -- FiveM strips resource name prefix, so /sv_mr_x/manual becomes /manual
    if req.path ~= '/manual' and req.path ~= '/status' and req.path ~= '/profile' then
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

    -- PROFILE ENDPOINT (no body needed, uses headers)
    if req.path == '/profile' then
        HandleProfile(req, res)
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
