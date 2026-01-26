--[[
    Mr. X Webhook Module
    ====================
    Posts events to web dashboard for real-time observation
]]

local Webhook = {}

-- Queue for failed webhooks (retry later)
local WebhookQueue = {}

-- ============================================
-- CORE WEBHOOK FUNCTION
-- ============================================

---Post event to web dashboard
---@param eventType string Event type (message, mission, chaos, bounty, reputation, etc.)
---@param data table Event data
---@param priority? string 'high' | 'normal' (high = immediate for real-time display)
function Webhook.Post(eventType, data, priority)
    if not Config.WebServer or not Config.WebServer.Enabled then
        return
    end

    priority = priority or 'normal'

    local payload = {
        type = eventType,
        data = data,
        timestamp = os.time(),
        secret = Config.WebServer.Secret
    }

    local url = Config.WebServer.URL .. Config.WebServer.Endpoints.Events
    local jsonPayload = json.encode(payload)

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            if Config.Debug then
                print('^2[MR_X:WEBHOOK]^7 Posted: ' .. eventType)
            end
        else
            print('^1[MR_X:WEBHOOK]^7 Failed (' .. tostring(statusCode or 'nil') .. '): ' .. eventType)
            -- Queue for retry
            table.insert(WebhookQueue, {payload = payload, retries = 0})
        end
    end, 'POST', jsonPayload, {
        ['Content-Type'] = 'application/json',
        ['X-MrX-Secret'] = Config.WebServer.Secret
    })
end

-- ============================================
-- SPECIALIZED POST FUNCTIONS
-- ============================================

---Post player profile update
---@param citizenid string
---@param profile table
function Webhook.PostProfile(citizenid, profile)
    Webhook.Post('profile_update', {
        citizenid = citizenid,
        profile = profile
    })
end

---Post message event (SMS, email, notification)
---@param direction string 'outbound' | 'inbound'
---@param citizenid string
---@param channel string 'sms' | 'email' | 'notification' | 'call'
---@param content string Message content (truncated)
---@param source number|string Player source or 'manual'
function Webhook.PostMessage(direction, citizenid, channel, content, source)
    Webhook.Post('message', {
        direction = direction,
        citizenid = citizenid,
        channel = channel,
        content = content and content:sub(1, 200) or '',
        source = source
    }, 'high')  -- Messages are high priority for real-time display
end

---Post mission event
---@param eventType string 'generated' | 'accepted' | 'completed' | 'failed' | 'abandoned'
---@param citizenid string
---@param missionData table Mission details
function Webhook.PostMission(eventType, citizenid, missionData)
    Webhook.Post('mission', {
        event = eventType,
        citizenid = citizenid,
        mission = missionData
    })
end

---Post chaos/surprise event
---@param eventType string 'warning' | 'triggered' | 'scan'
---@param citizenid string|nil
---@param surpriseType string|nil
---@param details table|nil Additional details
function Webhook.PostChaos(eventType, citizenid, surpriseType, details)
    Webhook.Post('chaos', {
        event = eventType,
        citizenid = citizenid,
        surpriseType = surpriseType,
        details = details
    }, 'high')
end

---Post bounty event
---@param eventType string 'posted' | 'accepted' | 'claimed' | 'expired'
---@param data table Bounty details
function Webhook.PostBounty(eventType, data)
    Webhook.Post('bounty', {
        event = eventType,
        data = data
    })
end

---Post reputation change
---@param citizenid string
---@param oldRep number
---@param newRep number
---@param reason string
function Webhook.PostRepChange(citizenid, oldRep, newRep, reason)
    Webhook.Post('reputation', {
        citizenid = citizenid,
        oldRep = oldRep,
        newRep = newRep,
        change = newRep - oldRep,
        reason = reason
    })
end

---Post loan event
---@param eventType string 'issued' | 'repaid' | 'defaulted' | 'overdue'
---@param data table Loan details
function Webhook.PostLoan(eventType, data)
    Webhook.Post('loan', {
        event = eventType,
        data = data
    })
end

---Post service event
---@param eventType string 'requested' | 'completed' | 'failed'
---@param citizenid string
---@param serviceType string
---@param details table|nil
function Webhook.PostService(eventType, citizenid, serviceType, details)
    Webhook.Post('service', {
        event = eventType,
        citizenid = citizenid,
        serviceType = serviceType,
        details = details
    })
end

-- ============================================
-- RETRY QUEUE PROCESSOR
-- ============================================

-- Process failed webhooks every 30 seconds
CreateThread(function()
    while true do
        Wait(30000)

        if Config.WebServer and Config.WebServer.Enabled and #WebhookQueue > 0 then
            local toRetry = WebhookQueue
            WebhookQueue = {}

            for _, item in ipairs(toRetry) do
                if item.retries < Config.WebServer.RetryCount then
                    item.retries = item.retries + 1

                    local url = Config.WebServer.URL .. Config.WebServer.Endpoints.Events
                    PerformHttpRequest(url, function(statusCode)
                        if statusCode ~= 200 then
                            table.insert(WebhookQueue, item)
                        elseif Config.Debug then
                            print('^2[MR_X:WEBHOOK]^7 Retry succeeded: ' .. (item.payload.type or 'unknown'))
                        end
                    end, 'POST', json.encode(item.payload), {
                        ['Content-Type'] = 'application/json',
                        ['X-MrX-Secret'] = Config.WebServer.Secret
                    })

                    Wait(100)  -- Small delay between retries
                else
                    if Config.Debug then
                        print('^1[MR_X:WEBHOOK]^7 Dropped after max retries: ' .. (item.payload.type or 'unknown'))
                    end
                end
            end
        end
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('PostWebhook', Webhook.Post)
exports('PostWebhookProfile', Webhook.PostProfile)
exports('PostWebhookMessage', Webhook.PostMessage)
exports('PostWebhookMission', Webhook.PostMission)
exports('PostWebhookChaos', Webhook.PostChaos)
exports('PostWebhookBounty', Webhook.PostBounty)
exports('PostWebhookRepChange', Webhook.PostRepChange)
exports('PostWebhookLoan', Webhook.PostLoan)
exports('PostWebhookService', Webhook.PostService)

-- ============================================
-- PLAYER CONNECT/DISCONNECT EVENTS
-- Keep dashboard in sync with online players
-- ============================================

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    if not Config.WebServer or not Config.WebServer.Enabled then return end

    local src = player.PlayerData.source
    local citizenid = player.PlayerData.citizenid
    local charinfo = player.PlayerData.charinfo or {}
    local job = player.PlayerData.job or {}

    Webhook.Post('player_online', {
        citizenid = citizenid,
        name = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or ''),
        job = job.name or 'unemployed',
        source = src
    })
end)

AddEventHandler('playerDropped', function(reason)
    if not Config.WebServer or not Config.WebServer.Enabled then return end

    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if player and player.PlayerData then
        Webhook.Post('player_offline', {
            citizenid = player.PlayerData.citizenid,
            reason = reason,
            source = src
        })
    end
end)

-- ============================================
-- STARTUP SYNC
-- Post all online players when resource starts
-- ============================================

CreateThread(function()
    -- Wait for server to be ready and dashboard to potentially be up
    Wait(5000)

    if not Config.WebServer or not Config.WebServer.Enabled then
        return
    end

    local players = GetPlayers()
    if #players == 0 then
        return
    end

    print('^3[MR_X:WEBHOOK]^7 Syncing ' .. #players .. ' online player(s) to dashboard...')

    for _, playerId in ipairs(players) do
        local src = tonumber(playerId)
        local player = exports.qbx_core:GetPlayer(src)

        if player and player.PlayerData then
            local citizenid = player.PlayerData.citizenid
            local charinfo = player.PlayerData.charinfo or {}
            local job = player.PlayerData.job or {}

            Webhook.Post('player_online', {
                citizenid = citizenid,
                name = (charinfo.firstname or '') .. ' ' .. (charinfo.lastname or ''),
                job = job.name or 'unemployed',
                source = src
            })

            Wait(50)  -- Small delay to avoid flooding
        end
    end

    print('^2[MR_X:WEBHOOK]^7 Player sync complete')
end)

-- Return module
return Webhook
