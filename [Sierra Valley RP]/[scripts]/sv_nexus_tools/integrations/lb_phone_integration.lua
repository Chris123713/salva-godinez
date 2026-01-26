--[[
    LB-PHONE INTEGRATION SNIPPET
    For sending Mr. X messages, mission notifications, and communication

    This enables Mr. X to:
    - Send mission briefings via email/SMS
    - Push notifications for mission updates
    - Create interactive email buttons for mission acceptance
    - Track player phone activity for mission triggers
]]

-- Helper function to safely call nexus
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

-- ============================================
-- LB-PHONE MAIL INTEGRATION
-- ============================================

-- Send email from Mr. X or mission system
---@param source number Player source
---@param mailData table {subject: string, message: string, sender?: string, actions?: table}
---@return boolean success
local function SendMrXEmail(source, mailData)
    if GetResourceState('lb-phone') ~= 'started' then return false end

    -- Get player's phone number
    local phoneNumber = exports['lb-phone']:GetEquippedPhoneNumber(source)
    if not phoneNumber then return false end

    -- Get email address
    local emailAddress = exports['lb-phone']:GetEmailAddress(phoneNumber)
    if not emailAddress then return false end

    -- Send the email
    local success = exports['lb-phone']:SendMail({
        to = emailAddress,
        sender = mailData.sender or 'Unknown Contact',
        subject = mailData.subject,
        message = mailData.message,
        actions = mailData.actions  -- Optional: buttons for interaction
    })

    return success ~= nil
end

-- Send email with accept/decline buttons for missions
---@param source number Player source
---@param missionData table Mission briefing data
local function SendMissionBriefing(source, missionData)
    local actions = nil

    if missionData.acceptEvent then
        actions = {
            {
                label = missionData.acceptLabel or 'Accept Job',
                data = {
                    event = missionData.acceptEvent,
                    isServer = true,
                    data = {
                        missionId = missionData.missionId,
                        citizenid = GetCitizenId(source)
                    }
                }
            }
        }
    end

    SendMrXEmail(source, {
        sender = 'Mr. X',
        subject = missionData.subject or 'New Opportunity',
        message = missionData.message,
        actions = actions
    })

    -- Report to nexus that briefing was sent
    ReportToNexus('mission_briefing_sent', {
        missionId = missionData.missionId,
        missionType = missionData.type
    }, source)
end

-- ============================================
-- NOTIFICATION INTEGRATION
-- ============================================

-- Send quick notification to player's phone
---@param source number Player source
---@param notifyData table {title: string, message: string, icon?: string}
local function SendPhoneNotification(source, notifyData)
    if GetResourceState('lb-phone') ~= 'started' then return end

    TriggerClientEvent('lb-phone:notification', source, {
        title = notifyData.title or 'Alert',
        description = notifyData.message,
        icon = notifyData.icon or 'fas fa-info-circle',
        duration = notifyData.duration or 5000
    })
end

-- ============================================
-- QB-PHONE COMPATIBILITY (for lb-phone)
-- ============================================

-- Send mail using QB-phone event format (lb-phone intercepts these)
---@param source number Player source
---@param data table {sender, subject, message, button?}
local function SendQBStyleMail(source, data)
    TriggerEvent('qb-phone:server:sendNewMail', source, data)
end

-- Send mail to offline player
---@param citizenid string Player's citizenid
---@param data table {sender, subject, message, button?}
local function SendMailToOffline(citizenid, data)
    TriggerEvent('qb-phone:server:sendNewMailToOffline', citizenid, data)
end

-- ============================================
-- EXAMPLE: Mr. X Mission Delivery
-- ============================================

--[[
-- When Mr. X wants to offer a mission:

local function OfferMissionToPlayer(source, missionProfile)
    SendMissionBriefing(source, {
        missionId = missionProfile.id,
        type = missionProfile.type,
        subject = 'Business Proposal',
        message = missionProfile.brief .. '\n\n' ..
                  'Location: ' .. missionProfile.areaName .. '\n' ..
                  'Estimated Value: $' .. missionProfile.estimatedValue .. '\n\n' ..
                  'Reply to this email to accept.',
        acceptEvent = 'sv_nexus_tools:server:acceptMission',
        acceptLabel = 'Accept Job'
    })

    -- Also send a quick notification
    SendPhoneNotification(source, {
        title = 'New Message',
        message = 'Mr. X has a business proposal for you.',
        icon = 'fas fa-user-secret'
    })
end
]]

-- ============================================
-- EXAMPLE: Mission Update Notifications
-- ============================================

--[[
-- During mission, send updates:

-- Objective completed
SendPhoneNotification(source, {
    title = 'Objective Complete',
    message = 'Package secured. Proceed to the drop-off.',
    icon = 'fas fa-check-circle'
})

-- Mission warning
SendPhoneNotification(source, {
    title = 'Warning',
    message = 'Police activity detected nearby. Stay alert.',
    icon = 'fas fa-exclamation-triangle'
})

-- Mission complete
SendMrXEmail(source, {
    sender = 'Mr. X',
    subject = 'Good Work',
    message = 'The job is done. Payment has been deposited.\n\n' ..
              'Stay low for a while. I\'ll be in touch.'
})
]]

-- ============================================
-- EXPORT FUNCTIONS FOR SV_NEXUS_TOOLS
-- ============================================

-- These can be called from sv_nexus_tools main resource
if GetCurrentResourceName() ~= 'sv_nexus_tools' then
    -- Export these functions if used as a standalone snippet
    exports('SendMrXEmail', SendMrXEmail)
    exports('SendMissionBriefing', SendMissionBriefing)
    exports('SendPhoneNotification', SendPhoneNotification)
end

-- Return module for require()
return {
    SendMrXEmail = SendMrXEmail,
    SendMissionBriefing = SendMissionBriefing,
    SendPhoneNotification = SendPhoneNotification,
    SendQBStyleMail = SendQBStyleMail,
    SendMailToOffline = SendMailToOffline
}
