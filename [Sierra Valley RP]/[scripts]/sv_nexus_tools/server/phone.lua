-- lb-phone Integration

local Phone = {}

-- Check if lb-phone is available
local function IsPhoneAvailable()
    return GetResourceState('lb-phone') == 'started'
end

-- Get player's phone number and email
function Phone.GetPlayerPhone(source)
    if not IsPhoneAvailable() then
        return nil, nil
    end

    local identifier = GetPlayerIdentifier(source, 'license')
    if not identifier then
        return nil, nil
    end

    local success, phoneNum = pcall(function()
        return exports['lb-phone']:GetEquippedPhoneNumber(identifier)
    end)

    if not success or not phoneNum then
        return nil, nil
    end

    local emailSuccess, email = pcall(function()
        return exports['lb-phone']:GetEmailAddress(phoneNum)
    end)

    return phoneNum, emailSuccess and email or nil
end

-- Send mail via lb-phone
function Phone.SendMail(source, data)
    if not IsPhoneAvailable() then
        Utils.Debug('lb-phone not available, skipping mail')
        return false, 'Phone not available'
    end

    local phoneNum, email = Phone.GetPlayerPhone(source)
    if not email then
        return false, 'Player has no phone or email'
    end

    local success, result = pcall(function()
        return exports['lb-phone']:SendMail({
            to = email,
            subject = data.subject or 'No Subject',
            message = data.message or '',
            sender = data.sender or Config.Phone.DefaultSender
        })
    end)

    if success and result then
        Utils.Debug('Mail sent to', email)
        return true, result
    end

    return false, 'Failed to send mail'
end

-- Send notification via lb-phone
function Phone.SendNotification(source, data)
    if not IsPhoneAvailable() then
        -- Fallback to ox_lib notification
        TriggerClientEvent('ox_lib:notify', source, {
            title = data.title,
            description = data.message,
            type = data.type or 'info'
        })
        return true
    end

    TriggerClientEvent('lb-phone:notification', source, {
        title = data.title or 'Notification',
        description = data.message or '',
        icon = data.icon or 'fas fa-info-circle'
    })

    return true
end

-- Register phone tools
RegisterTool('send_phone_mail', {
    params = {'source', 'subject', 'message', 'sender'},
    async = true,
    handler = function(params)
        local success, result = Phone.SendMail(params.source, {
            subject = params.subject,
            message = params.message,
            sender = params.sender or Config.Phone.MissionSender
        })
        return {success = success, mailId = result}
    end
})

RegisterTool('send_phone_notification', {
    params = {'source', 'title', 'message', 'icon'},
    handler = function(params)
        local success = Phone.SendNotification(params.source, {
            title = params.title,
            message = params.message,
            icon = params.icon
        })
        return {success = success}
    end
})

-- Exports
exports('SendPhoneMail', Phone.SendMail)
exports('SendPhoneNotification', Phone.SendNotification)

return Phone
