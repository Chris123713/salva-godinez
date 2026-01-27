--[[
    Mr. X Phone Hack System - Server Side
    =====================================
    Orchestrates the phone hack and sends the captured image back to the player.
]]

local PhoneHack = {}
local hackCooldowns = {}  -- citizenid -> timestamp

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function GetRandomMessage()
    if not Config.PhoneHack.Messages.Alternatives then
        return Config.PhoneHack.Messages.WithImage
    end

    local messages = Config.PhoneHack.Messages.Alternatives
    return messages[math.random(#messages)]
end

local function IsOnCooldown(citizenid)
    local lastHack = hackCooldowns[citizenid]
    if not lastHack then return false end

    local cooldown = Config.PhoneHack.CooldownSeconds or 3600
    return (os.time() - lastHack) < cooldown
end

local function SetCooldown(citizenid)
    hackCooldowns[citizenid] = os.time()
end

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end

    local encodedData = data and json.encode(data) or '{}'
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, encodedData, source or 0})
end

-- ============================================
-- PHONE HACK INITIATION
-- ============================================

---Initiate a phone hack on a player
---@param source number Player server ID
---@param silent? boolean Don't send warning message first
---@return boolean success
function PhoneHack.Initiate(source, silent)
    if not Config.PhoneHack or not Config.PhoneHack.Enabled then
        print('^3[MR_X:PHONE_HACK]^7 Phone hack system is disabled')
        return false
    end

    if not Config.PhoneHack.DiscordWebhook or Config.PhoneHack.DiscordWebhook == '' then
        print('^1[MR_X:PHONE_HACK]^7 Discord webhook not configured in config')
        return false
    end

    local citizenid = GetCitizenId(source)
    if not citizenid then
        print('^1[MR_X:PHONE_HACK]^7 Could not get citizenid for source:', source)
        return false
    end

    -- Check cooldown
    if IsOnCooldown(citizenid) then
        local remaining = (Config.PhoneHack.CooldownSeconds or 3600) - (os.time() - hackCooldowns[citizenid])
        print('^3[MR_X:PHONE_HACK]^7 Player on cooldown:', citizenid, '- remaining:', remaining, 'seconds')
        return false
    end

    -- Check reputation if configured
    if Config.PhoneHack.MinReputation then
        local rep = exports['sv_mr_x']:GetReputation(citizenid) or 0
        if rep > Config.PhoneHack.MinReputation then
            print('^3[MR_X:PHONE_HACK]^7 Player rep too high for targeting:', rep)
            return false
        end
    end

    print('^3[MR_X:PHONE_HACK]^7 Initiating phone hack on:', citizenid)

    -- Send warning message first (optional)
    if not silent and Config.PhoneHack.Messages.Warning then
        exports['sv_mr_x']:SendMrXMessage(source, Config.PhoneHack.Messages.Warning)
        Wait(2000)  -- Dramatic pause
    end

    -- Trigger client-side capture
    TriggerClientEvent('mrx:client:phoneHack', source)

    Log('phone_hack_initiated', citizenid, {
        silent = silent or false
    }, source)

    return true
end

-- ============================================
-- COMPLETION HANDLERS
-- ============================================

RegisterNetEvent('mrx:server:phoneHackComplete', function(imageUrl)
    local source = source
    local citizenid = GetCitizenId(source)

    if not citizenid then return end
    if not imageUrl or imageUrl == '' then return end

    print('^2[MR_X:PHONE_HACK]^7 Hack complete for:', citizenid, '- Image:', imageUrl)

    -- Set cooldown
    SetCooldown(citizenid)

    -- Get phone number for the player
    local player = exports.qbx_core:GetPlayer(source)
    local phoneNumber = player and player.PlayerData.charinfo and player.PlayerData.charinfo.phone

    -- Send the image via SMS
    local message = GetRandomMessage()

    if GetResourceState('lb-phone') == 'started' then
        -- Use lb-phone's SendMessage with attachment
        exports['lb-phone']:SendMessage({
            from = 'Unknown',
            to = phoneNumber,
            message = message,
            attachments = {imageUrl}
        }, function(success)
            if success then
                print('^2[MR_X:PHONE_HACK]^7 Selfie sent successfully to:', phoneNumber)
            else
                print('^1[MR_X:PHONE_HACK]^7 Failed to send selfie via lb-phone')
                -- Fallback: Try notification
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'Mr. X',
                    description = message,
                    type = 'inform',
                    duration = 10000
                })
            end
        end)
    else
        -- Fallback notification if lb-phone not available
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Mr. X',
            description = message,
            type = 'inform',
            duration = 10000
        })
    end

    -- Log the successful hack
    Log('phone_hack_complete', citizenid, {
        imageUrl = imageUrl,
        message = message
    }, source)

    -- Webhook to dashboard if enabled
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhook('event', {
            type = 'phone_hack',
            citizenid = citizenid,
            imageUrl = imageUrl,
            timestamp = os.time()
        })
    end
end)

RegisterNetEvent('mrx:server:phoneHackFailed', function(error)
    local source = source
    local citizenid = GetCitizenId(source)

    print('^1[MR_X:PHONE_HACK]^7 Hack failed for:', citizenid, '- Error:', error)

    Log('phone_hack_failed', citizenid, {
        error = error
    }, source)
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

-- Admin command to trigger phone hack on self (for testing)
RegisterCommand('mrx_phonehack', function(source, args)
    if source == 0 then
        print('This command must be run in-game')
        return
    end

    if not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local targetSource = source
    if args[1] then
        targetSource = tonumber(args[1]) or source
    end

    local success = PhoneHack.Initiate(targetSource, true)  -- Silent (no warning)
    if success then
        print('^2[MR_X]^7 Phone hack initiated on player:', targetSource)
    else
        print('^1[MR_X]^7 Phone hack failed - check config')
    end
end, false)

-- Admin command to preview the glitch effect
RegisterCommand('mrx_hackeffect', function(source)
    if source == 0 then return end
    if not IsPlayerAceAllowed(source, 'admin') then return end

    TriggerClientEvent('mrx:client:previewHackEffect', source)
end, false)

-- ============================================
-- ADMIN CALLBACK (For admin menu)
-- ============================================

CreateThread(function()
    while not lib do Wait(100) end

    lib.callback.register('mrx:admin:phoneHack', function(source, targetSource)
        if not IsPlayerAceAllowed(source, 'admin') then return false end

        targetSource = targetSource or source
        return PhoneHack.Initiate(targetSource, false)
    end)

    lib.callback.register('mrx:admin:phoneHackSilent', function(source, targetSource)
        if not IsPlayerAceAllowed(source, 'admin') then return false end

        targetSource = targetSource or source
        return PhoneHack.Initiate(targetSource, true)
    end)
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('InitiatePhoneHack', PhoneHack.Initiate)

return PhoneHack
