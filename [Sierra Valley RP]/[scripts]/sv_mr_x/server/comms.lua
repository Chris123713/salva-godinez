--[[
    Mr. X Communications Handler
    ============================
    Handles all lb-phone integration for SMS, email, calls, and notifications
]]

local Comms = {}

-- Active sessions cache
local ActiveSessions = {}

-- Message queue for players with busy phones
local MessageQueue = {}

-- Phone state tracking (updated by client)
local PhoneState = {}  -- [source] = {open = bool, lastUpdate = timestamp}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
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

local function RandomMessage(messageList)
    if not messageList or #messageList == 0 then return nil end
    return messageList[math.random(#messageList)]
end

-- ============================================
-- LB-PHONE INTEGRATION
-- ============================================

---Check if lb-phone is available
---@return boolean
local function IsPhoneAvailable()
    return GetResourceState('lb-phone') == 'started'
end

---Get player's phone number
---@param source number
---@return string|nil phoneNumber
local function GetPlayerPhoneNumber(source)
    if not IsPhoneAvailable() then return nil end
    return exports['lb-phone']:GetEquippedPhoneNumber(source)
end

---Get player's email address
---@param source number
---@return string|nil email
local function GetPlayerEmail(source)
    if not IsPhoneAvailable() then return nil end
    local phoneNumber = GetPlayerPhoneNumber(source)
    if not phoneNumber then return nil end
    return exports['lb-phone']:GetEmailAddress(phoneNumber)
end

-- ============================================
-- MESSAGE SENDING
-- ============================================

---Send an anonymous SMS message to a player
---@param source number Player source
---@param message string Message content
---@param queueIfBusy? boolean Queue message if phone is busy (default true)
---@return boolean success
function Comms.SendMessage(source, message, queueIfBusy)
    -- Check if player is exempt from Mr. X
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then print('^3[MR_X]^7 Skipped message to exempt player') end
        return false
    end

    if not IsPhoneAvailable() then
        if Config.Debug then print('^1[MR_X]^7 lb-phone not available') end
        return false
    end

    queueIfBusy = queueIfBusy ~= false  -- Default to true

    -- Check if phone is busy
    if queueIfBusy and PhoneState[source] and PhoneState[source].open then
        Comms.QueueMessage(source, 'sms', {message = message})
        return true
    end

    local phoneNumber = GetPlayerPhoneNumber(source)
    if not phoneNumber then
        if Config.Debug then print('^1[MR_X]^7 Could not get phone number for source ' .. source) end
        return false
    end

    -- Send as anonymous/unknown
    exports['lb-phone']:SendMessage(
        Config.Comms.SenderName,  -- from: "Unknown"
        phoneNumber,              -- to: player's number
        message,                  -- message content
        nil,                      -- attachments
        nil,                      -- callback
        nil                       -- channelId
    )

    local citizenid = GetCitizenId(source)
    Log(MrXConstants.EventTypes.MESSAGE_SENT, citizenid, {
        channel = 'sms',
        message = message:sub(1, 100)  -- Log first 100 chars only
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookMessage('outbound', citizenid, 'sms', message, source)
    end

    if Config.Debug then
        print('^2[MR_X]^7 Sent SMS to ' .. phoneNumber .. ': ' .. message:sub(1, 50) .. '...')
    end

    return true
end

---Send an email to a player
---@param source number Player source
---@param subject string Email subject
---@param body string Email body
---@param actions? table Optional action buttons [{label, data}]
---@return boolean success
function Comms.SendEmail(source, subject, body, actions)
    -- Check if player is exempt from Mr. X
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then print('^3[MR_X]^7 Skipped email to exempt player') end
        return false
    end

    if not IsPhoneAvailable() then return false end

    local email = GetPlayerEmail(source)
    if not email then
        if Config.Debug then print('^1[MR_X]^7 Could not get email for source ' .. source) end
        return false
    end

    local mailData = {
        to = email,
        sender = Config.Comms.SenderName,
        subject = subject,
        message = body,
        actions = actions
    }

    local success = exports['lb-phone']:SendMail(mailData)

    local citizenid = GetCitizenId(source)
    Log(MrXConstants.EventTypes.EMAIL_SENT, citizenid, {
        subject = subject,
        hasActions = actions ~= nil
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookMessage('outbound', citizenid, 'email', body, source)
    end

    if Config.Debug then
        print('^2[MR_X]^7 Sent email to ' .. email .. ': ' .. subject)
    end

    return success ~= nil
end

---Send a push notification to a player's phone
---@param source number Player source
---@param title string Notification title
---@param message string Notification message
---@param icon? string Font Awesome icon class
---@param duration? number Duration in ms
---@return boolean success
function Comms.SendNotification(source, title, message, icon, duration)
    -- Check if player is exempt from Mr. X
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then return false end

    if not IsPhoneAvailable() then return false end

    TriggerClientEvent('lb-phone:notification', source, {
        title = title or 'Mr. X',
        description = message,
        icon = icon or Config.Comms.NotificationIcon,
        duration = duration or 5000
    })

    local citizenid = GetCitizenId(source)
    Log(MrXConstants.EventTypes.NOTIFICATION_SENT, citizenid, {
        title = title,
        message = message:sub(1, 100)
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookMessage('outbound', citizenid, 'notification', message, source)
    end

    return true
end

---Create an anonymous incoming call
---@param source number Player source
---@param onAnswer? function Callback when call is answered
---@param voiceMessage? string Optional automated message
---@return boolean success
function Comms.CreateCall(source, onAnswer, voiceMessage)
    if not IsPhoneAvailable() then return false end

    local phoneNumber = GetPlayerPhoneNumber(source)
    if not phoneNumber then return false end

    -- Create anonymous call
    exports['lb-phone']:CreateCall(
        {source = 0, phoneNumber = 'Anonymous'},  -- caller
        phoneNumber,                               -- callee
        {hideNumber = true}                        -- options
    )

    local citizenid = GetCitizenId(source)
    Log(MrXConstants.EventTypes.CALL_INITIATED, citizenid, {}, source)

    if Config.Debug then
        print('^2[MR_X]^7 Initiated anonymous call to source ' .. source)
    end

    return true
end

-- ============================================
-- MESSAGE QUEUE (for busy phones)
-- ============================================

---Queue a message for later delivery
---@param source number
---@param msgType string 'sms'|'email'|'notification'
---@param data table Message data
function Comms.QueueMessage(source, msgType, data)
    if not MessageQueue[source] then
        MessageQueue[source] = {}
    end

    table.insert(MessageQueue[source], {
        type = msgType,
        data = data,
        queuedAt = os.time()
    })

    if Config.Debug then
        print('^3[MR_X]^7 Queued ' .. msgType .. ' for source ' .. source .. ' (phone busy)')
    end
end

---Deliver all queued messages for a player
---@param source number
function Comms.DeliverQueuedMessages(source)
    local queue = MessageQueue[source]
    if not queue or #queue == 0 then return end

    for _, msg in ipairs(queue) do
        if msg.type == 'sms' then
            Comms.SendMessage(source, msg.data.message, false)
        elseif msg.type == 'email' then
            Comms.SendEmail(source, msg.data.subject, msg.data.body, msg.data.actions)
        elseif msg.type == 'notification' then
            Comms.SendNotification(source, msg.data.title, msg.data.message)
        end
    end

    MessageQueue[source] = nil

    if Config.Debug then
        print('^2[MR_X]^7 Delivered ' .. #queue .. ' queued messages to source ' .. source)
    end
end

-- ============================================
-- SESSION MANAGEMENT
-- ============================================

---Create a new conversation session
---@param citizenid string
---@param channel? string Communication channel
---@return string sessionId
function Comms.CreateSession(citizenid, channel)
    local sessionId = GenerateUUID()

    MySQL.insert.await([[
        INSERT INTO mr_x_sessions (session_id, citizenid, channel, started_at, last_message_at, status)
        VALUES (?, ?, ?, NOW(), NOW(), 'active')
    ]], {sessionId, citizenid, channel or 'sms'})

    ActiveSessions[citizenid] = {
        sessionId = sessionId,
        exchangeCount = 0,
        startedAt = os.time(),
        lastMessageAt = os.time()
    }

    return sessionId
end

---Get active session for a player
---@param citizenid string
---@return table|nil session
function Comms.GetSession(citizenid)
    -- Check memory cache first
    if ActiveSessions[citizenid] then
        return ActiveSessions[citizenid]
    end

    -- Check database for recent active session
    local row = MySQL.single.await([[
        SELECT * FROM mr_x_sessions
        WHERE citizenid = ? AND status = 'active'
        ORDER BY last_message_at DESC LIMIT 1
    ]], {citizenid})

    if row then
        ActiveSessions[citizenid] = {
            sessionId = row.session_id,
            exchangeCount = row.exchange_count,
            startedAt = row.started_at,
            lastMessageAt = row.last_message_at,
            context = JsonDecode(row.context)
        }
        return ActiveSessions[citizenid]
    end

    return nil
end

---Update session with new exchange
---@param citizenid string
---@param context? table Conversation context for AI
---@return boolean success
---@return boolean|nil limitReached
function Comms.UpdateSession(citizenid, context)
    local session = Comms.GetSession(citizenid)
    if not session then return false end

    session.exchangeCount = session.exchangeCount + 1
    session.lastMessageAt = os.time()
    session.context = context

    MySQL.update.await([[
        UPDATE mr_x_sessions
        SET exchange_count = ?, last_message_at = NOW(), context = ?
        WHERE session_id = ?
    ]], {session.exchangeCount, JsonEncode(context), session.sessionId})

    -- Check if limit reached
    local limitReached = session.exchangeCount >= Config.Comms.MaxExchangesPerSession

    return true, limitReached
end

---End a session
---@param citizenid string
---@param status? string 'completed'|'timeout'
function Comms.EndSession(citizenid, status)
    local session = Comms.GetSession(citizenid)
    if not session then return end

    MySQL.update.await([[
        UPDATE mr_x_sessions SET status = ? WHERE session_id = ?
    ]], {status or 'completed', session.sessionId})

    ActiveSessions[citizenid] = nil
end

-- ============================================
-- INBOUND MESSAGE HANDLING
-- ============================================

---Check if a recipient matches Mr. X identifiers
---@param recipient string
---@return boolean isMrX
local function IsMrXRecipient(recipient)
    if not recipient then return false end

    for _, identifier in ipairs(Config.Comms.MrXIdentifiers) do
        if recipient:lower() == identifier:lower() then
            return true
        end
    end

    return false
end

---Handle an inbound message from a player
---@param source number Player source
---@param message string Message content
---@return boolean processed
function Comms.HandleInbound(source, message)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    -- Check if player is exempt - they can't use Mr. X services
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then print('^3[MR_X]^7 Ignored message from exempt player') end
        return false
    end

    -- Log the inbound message
    Log(MrXConstants.EventTypes.MESSAGE_RECEIVED, citizenid, {
        message = message:sub(1, 100)
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookMessage('inbound', citizenid, 'sms', message, source)
    end

    -- Extract facts from conversation (Mr. X is always listening)
    exports['sv_mr_x']:ExtractFactsFromConversation(citizenid, message)

    -- Get or create session
    local session = Comms.GetSession(citizenid)
    if not session then
        session = {sessionId = Comms.CreateSession(citizenid), exchangeCount = 0}
    end

    -- Check exchange limit
    if session.exchangeCount >= Config.Comms.MaxExchangesPerSession then
        Comms.SendMessage(source, "We've spoken enough for now. I'll be in touch.")
        Comms.EndSession(citizenid, 'completed')
        return true
    end

    -- Update session
    local success, limitReached = Comms.UpdateSession(citizenid, {
        lastMessage = message,
        timestamp = os.time()
    })

    -- Check for service requests
    local serviceHandled = Comms.CheckServiceRequest(source, citizenid, message)
    if serviceHandled then return true end

    -- Generate AI response
    Comms.GenerateResponse(source, citizenid, message, session)

    -- Warn about limit
    if limitReached then
        SetTimeout(2000, function()
            Comms.SendMessage(source, "This conversation is ending. Choose your next words carefully.")
        end)
    end

    return true
end

---Check if message is a service request
---@param source number
---@param citizenid string
---@param message string
---@return boolean handled
function Comms.CheckServiceRequest(source, citizenid, message)
    local lowerMsg = message:lower()

    -- Snitch network - check first as it has its own conversation flow
    local snitchHandled = exports['sv_mr_x']:HandleSnitchMessage(source, citizenid, message)
    if snitchHandled then
        return true
    end

    -- Loan request patterns
    if lowerMsg:match('need money') or lowerMsg:match('loan') or lowerMsg:match('borrow') then
        TriggerEvent('sv_mr_x:server:requestLoan', source)
        return true
    end

    -- Clear record patterns
    if lowerMsg:match('clear my record') or lowerMsg:match('clean slate') or lowerMsg:match('remove warrant') then
        TriggerEvent('sv_mr_x:server:requestRecordClear', source, message)
        return true
    end

    -- Intel request patterns
    if lowerMsg:match('where should i go') or lowerMsg:match('tip') or lowerMsg:match('location') then
        TriggerEvent('sv_mr_x:server:requestTip', source)
        return true
    end

    -- Target intel patterns (player asking for intel on someone)
    if lowerMsg:match('info on') or lowerMsg:match('intel on') or lowerMsg:match('find someone') then
        TriggerEvent('sv_mr_x:server:requestIntel', source, message)
        return true
    end

    return false
end

---Generate an AI response to player message
---@param source number
---@param citizenid string
---@param message string
---@param session table
function Comms.GenerateResponse(source, citizenid, message, session)
    -- This will be handled by mission_gen.lua with OpenAI
    -- For now, use template responses

    if Config.TestMode then
        -- Test mode: use canned responses
        local responses = {
            "Interesting...",
            "I've noted that.",
            "We'll see.",
            "Patience.",
            "Soon."
        }
        Comms.SendMessage(source, RandomMessage(responses))
        return
    end

    -- Trigger AI generation (handled in mission_gen.lua)
    TriggerEvent('sv_mr_x:internal:generateResponse', source, citizenid, message, session)
end

-- ============================================
-- LB-PHONE EVENT HOOKS
-- ============================================

-- Hook into lb-phone message sent event for inbound handling
AddEventHandler('lb-phone:messages:messageSent', function(message)
    -- message: {channelId, messageId, sender, recipient, message, attachments?}
    if not message or not message.recipient then return end

    -- Check if this message is directed to Mr. X
    if IsMrXRecipient(message.recipient) then
        -- Find the player source from sender phone number
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local phoneNumber = GetPlayerPhoneNumber(tonumber(playerId))
            if phoneNumber == message.sender then
                Comms.HandleInbound(tonumber(playerId), message.message)
                break
            end
        end
    end
end)

-- ============================================
-- CLIENT EVENTS
-- ============================================

-- Track phone open/closed state
RegisterNetEvent('sv_mr_x:phoneStateChanged', function(isOpen)
    local source = source
    PhoneState[source] = {
        open = isOpen,
        lastUpdate = os.time()
    }

    -- When phone closes, deliver queued messages
    if not isOpen then
        SetTimeout(1000, function()  -- Small delay to let phone fully close
            Comms.DeliverQueuedMessages(source)
        end)
    end
end)

-- ============================================
-- SESSION TIMEOUT MANAGEMENT
-- ============================================

-- Periodic check for stale sessions
CreateThread(function()
    while true do
        Wait(60000)  -- Check every minute

        local now = os.time()
        local timeoutSec = Config.Comms.SessionTimeoutSec

        for citizenid, session in pairs(ActiveSessions) do
            if now - session.lastMessageAt > timeoutSec then
                -- Send timeout message
                local source = exports['sv_mr_x']:FindPlayerSource(citizenid)
                if source then
                    Comms.SendMessage(source, "Silence speaks volumes. This conversation is over.")
                end
                Comms.EndSession(citizenid, 'timeout')
            end
        end
    end
end)

-- ============================================
-- CLEANUP
-- ============================================

AddEventHandler('playerDropped', function(reason)
    local source = source
    local citizenid = GetCitizenId(source)

    -- Clear phone state
    PhoneState[source] = nil
    MessageQueue[source] = nil

    -- Don't end session - player might reconnect
end)

-- ============================================
-- MESSAGE GENERATION FUNCTIONS (for test console)
-- These generate contextual messages based on player profile
-- ============================================

---Generate a check-in message
---@param citizenid string
---@return string message
function Comms.GenerateCheckInMessage(citizenid)
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    local rep = profile and profile.reputation or 0
    local archetype = profile and profile.archetype or 'unclassified'

    -- Prospect check-in is friendlier
    if archetype == 'prospect' then
        return RandomMessage(Config.Prospect.Messaging.CheckIn) or 'How are you settling in? Let me know if you need anything.'
    end

    -- Reputation-based messages
    if rep > 70 then
        return RandomMessage({
            "Just checking in on my most valuable asset.",
            "I have something big coming up. Stay ready.",
            "Your services may be required soon. Keep your schedule open."
        })
    elseif rep > 40 then
        return RandomMessage({
            "I may have something for you soon...",
            "Keep your eyes open. Opportunities are coming.",
            "I've been watching your progress. Interesting."
        })
    else
        return RandomMessage({
            "I haven't forgotten about you.",
            "Prove yourself useful, and there will be rewards.",
            "Patience. Your time will come."
        })
    end
end

---Generate a warning message
---@param citizenid string
---@return string message
function Comms.GenerateWarningMessage(citizenid)
    return RandomMessage(MrXConstants.Messages.Warnings) or "Your actions have consequences. Remember that."
end

---Generate a tip message
---@param citizenid string
---@return string message
function Comms.GenerateTipMessage(citizenid)
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    local archetype = profile and profile.archetype or 'unclassified'

    if archetype == 'prospect' then
        return RandomMessage(Config.Prospect.Messaging.FreeTips) or 'Pro tip: The mechanic shop is always hiring.'
    end

    return RandomMessage({
        "A little free intel: there are opportunities if you know where to look.",
        "I heard something that might interest you. Keep your ears open near the docks.",
        "Word on the street: something big is happening soon. Position yourself well.",
        "A tip from a friend: avoid the south side tonight."
    })
end

---Generate a mission success message
---@param citizenid string
---@return string message
function Comms.GenerateMissionSuccessMessage(citizenid)
    return RandomMessage(MrXConstants.Messages.Success) or "Well done. We'll be in touch."
end

---Generate a mission failure message
---@param citizenid string
---@return string message
function Comms.GenerateMissionFailureMessage(citizenid)
    return RandomMessage(MrXConstants.Messages.Failure) or "Disappointing. I expected more from you."
end

---Generate an extortion message
---@param citizenid string
---@return string message
function Comms.GenerateExtortionMessage(citizenid)
    return RandomMessage({
        "You owe me. I'm calling in the debt. Pay up or face consequences.",
        "Consider this your final notice. I want what you owe me.",
        "You have 24 hours. After that, I take matters into my own hands.",
        "I've been patient. That patience has run out. Pay. Now."
    })
end

---Generate a threat message
---@param citizenid string
---@return string message
function Comms.GenerateThreatMessage(citizenid)
    return RandomMessage({
        "I know where you are. I know who you care about. Do not test me.",
        "Consider this your only warning. Cross me again and you will regret it.",
        "Some people make the mistake of thinking I'm bluffing. Ask around about what happened to them.",
        "I have eyes everywhere. You cannot hide from me."
    })
end

---Refactor a custom message to Mr. X's voice using AI
---@param message string Original message
---@param citizenid string Target player
---@return string Refactored message
function Comms.RefactorToMrXVoice(message, citizenid)
    -- Check if AI is available
    local hasNexusTools = GetResourceState('sv_nexus_tools') == 'started'

    if not hasNexusTools or Config.TestMode then
        -- Fallback: just return the original with some Mr. X flavor
        return message
    end

    -- Get personality context
    local personalityContext = exports['sv_mr_x']:BuildPersonalityContext(citizenid, nil)

    -- Build AI prompt
    local prompt = [[You are rewriting a message in the voice of Mr. X, an omniscient crime lord.

Original message to convey: "]] .. message .. [["

]] .. personalityContext .. [[

Rewrite this message in Mr. X's voice. Keep it brief (1-2 sentences). Be cryptic, confident, and menacing but not cartoonish.
Output ONLY the rewritten message, nothing else.]]

    -- Call AI
    local success, response = pcall(function()
        return exports['sv_nexus_tools']:CallOpenAI({
            model = Config.OpenAI.Model or 'gpt-4o-mini',
            temperature = 0.8,
            max_tokens = 100,
            messages = {
                { role = 'user', content = prompt }
            }
        })
    end)

    if success and response and response.content then
        return response.content
    end

    -- Fallback
    return message
end

-- ============================================
-- EXPORTS
-- ============================================

exports('SendMrXMessage', Comms.SendMessage)
exports('GenerateCheckInMessage', Comms.GenerateCheckInMessage)
exports('GenerateWarningMessage', Comms.GenerateWarningMessage)
exports('GenerateTipMessage', Comms.GenerateTipMessage)
exports('GenerateMissionSuccessMessage', Comms.GenerateMissionSuccessMessage)
exports('GenerateMissionFailureMessage', Comms.GenerateMissionFailureMessage)
exports('GenerateExtortionMessage', Comms.GenerateExtortionMessage)
exports('GenerateThreatMessage', Comms.GenerateThreatMessage)
exports('RefactorToMrXVoice', Comms.RefactorToMrXVoice)
exports('SendMrXEmail', Comms.SendEmail)
exports('SendMrXNotification', Comms.SendNotification)
exports('CreateMrXCall', Comms.CreateCall)
exports('GetCommsSession', Comms.GetSession)
exports('CreateCommsSession', Comms.CreateSession)
exports('EndCommsSession', Comms.EndSession)
exports('HandleInboundMessage', Comms.HandleInbound)
exports('QueueMessage', Comms.QueueMessage)

-- Return module
return Comms
