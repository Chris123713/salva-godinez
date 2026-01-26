-- List of all logTypes if you want to filter them
-- 'withdraw', 'deposit', 'transfer', 'card_created, card_item_given',
-- 'card_frozen_due_to_too_many_attempts', 'pin_change_failed', 'pin_changed_successfully',
-- 'card_name_updated', 'card_limits_updated', 'card_unfrozen', 'card_frozen', 'card_terminated',
-- 'account_created', 'account_freeze_failed', 'account_unfreeze_failed', 'account_terminate_failed',
-- 'account_freeze', 'account_unfreeze', 'account_terminate', 'account_member_added',
-- 'account_member_removed', 'account_name_updated', 'account_member_modified',
-- 'account_transfer_ownership_failed', 'account_transfer_ownership', 'loan', 'loan_payment', 'loan_payoff', 'custom'

local excludedLogTypes = {
    'account_member_modified',
    'account_name_updated',
    'card_limits_updated',
    'card_name_updated',
}

local logsTimeout = 10
local webhook = GetConvar("bankingLogs", "SET_YOUR_API_KEY_IN_SERVER.CFG")

local logQueue = {}

local defaultAvatarUrl = 'https://r2.fivemanage.com/tQ3N61asBhnHrsT4FJakP/image/d1.png'

RegisterNetEvent('banking:server:logs:create', function(iban, playerId, logType, logMessage)
    local postData = {}

    if not webhook then
        debugPrint('Tried to post a log that doesn\'t have webhook')
        return
    end

    -- Check if the logType is in the excluded list
    for i = 1, #excludedLogTypes do
        if excludedLogTypes[i] == logType then
            return
        end
    end

    -- Create an embed
    local embed = {
        ['type'] = 'rich',
        ['color'] = 0x128b7d,
        ['footer'] = {
            ['text'] = os.date('%c'),
        },
        ['author'] = {
            ['name'] = "Banking Logs",
            ['icon_url'] = defaultAvatarUrl,
        },
        ['fields'] = {
            {
                ['name'] = 'Player Identifier / IBAN / Log Type',
                ['value'] = "```" .. playerId .. " / " .. iban .. " / " .. logType .. "```",
            },
            {
                ['name'] = 'Log Message:',
                ['value'] = "```" .. logMessage .. "```",
            },
        }

    }

    if not logQueue[iban] then logQueue[iban] = {} end
    logQueue[iban][#logQueue[iban] + 1] = { webhook = webhook, data = embed }

    -- Process the logQueue when it reaches a certain size or based on other criteria
    if #logQueue[iban] >= 10 then
        postData = {
            username = "Banking Logs",
            avatar_url = defaultAvatarUrl,
            embeds = {},
        }

        for i = 1, #logQueue[iban] do
            postData.embeds[#postData.embeds + 1] = logQueue[iban][i].data
        end

        PerformHttpRequest(webhook, function() end, 'POST', json.encode(postData), { ['Content-Type'] = 'application/json' })
        logQueue[iban] = {}
    end
end)

CreateThread(function()
    local timer = 0
    while true do
        Wait(5000)

        timer = timer + 5
        if timer >= logsTimeout then -- If 60 seconds(default) have passed, post the logs.
            timer = 0
            for iban, queue in pairs(logQueue) do
                if #queue > 0 then
                    local postData = {
                        username = "Banking Logs",
                        avatar_url = defaultAvatarUrl,
                        embeds = {}
                    }

                    for i = 1, #queue do
                        -- Directly add the embed from each log entry in the queue
                        postData.embeds[#postData.embeds + 1] = queue[i].data
                    end

                    -- Send the logs to Discord
                    PerformHttpRequest(queue[1].webhook, function() end, 'POST', json.encode(postData), { ['Content-Type'] = 'application/json' })

                    -- Clear the queue for this iban after sending
                    logQueue[iban] = {}
                end
            end
        end
    end
end)
