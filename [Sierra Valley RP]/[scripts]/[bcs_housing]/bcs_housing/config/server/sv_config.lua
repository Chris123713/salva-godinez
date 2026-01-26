sv_config = {
    server = 'Your Roleplay server',
    ['realestate'] = {
        color = 15154977,
        username = 'Housing - Important',
        webhook = "",
    },
    ['action'] = {
        color = 15154977,
        username = 'Housing - Actions',
        webhook = "",
    },
    ['homekey'] = {
        color = 15154977,
        username = 'Housing - Keys',
        webhook = "",
    },
    ['furniture'] = {
        color = 15154977,
        username = 'Housing - Furnitures',
        webhook = "",
    },
    ['mortgage'] = {
        color = 15154977,
        username = 'Housing - Mortgages',
        webhook = "",
    },
    ['rent'] = {
        color = 15154977,
        username = 'Housing - Rent',
        webhook = "",
    },
    ['alert'] = {
        color = 15154977,
        username = 'Housing - Alert',
        webhook = "",
    },
    AntiCheatChecks = {
        CheckEnterHomeDistance = false, -- if enabled may conflict with your spawn selector
        AntiSpamEventCallback = true
    }
}

-- ### Ban / Kick potential cheater

RegisterNetEvent('Housing:server:PotentialCheater', function(event, reason, src)
    local xPlayer = GetPlayerFromId(src or source)
    local resource = GetInvokingResource()
    if resource == GetCurrentResourceName() then
        -- kick them or ban them?
    end
    print('^1[POTENTIAL CHEATER]^0', xPlayer.identifier, event, reason)
end)

-- ### SPAM EVENT PROTECTION ###

local players = {}
local spammer = {}

AddEventHandler('playerDropped', function(reason)
    local source = source
    players[source] = nil
    spammer[source] = nil
end)

if sv_config.AntiCheatChecks.AntiSpamEventCallback then
    local callbackRegister = lib.callback.register
    lib.callback.register = function(eventName, eventCallback)
        callbackRegister(eventName, function(...)
            local source = select(1, ...)
            if players[source] then
                if (os.time() - players[source]) <= 1 then
                    if spammer[source] >= 30 then
                        DropPlayer(source, "Spamming event: " .. eventName)
                        -- print('DROPPED PLAYER FOR SPAMMING')
                        return false
                    else
                        spammer[source] += 1
                        return eventCallback(...)
                    end
                else
                    players[source] = os.time()
                    spammer[source] = 1
                    return eventCallback(...)
                end
            else
                players[source] = os.time()
                spammer[source] = 1
                return eventCallback(...)
            end
        end)
    end

    local spammerEvent = {}
    local playersEvent = {}

    local originalRegisterNetEvent = RegisterNetEvent
    RegisterNetEvent = function(eventName, eventCallback)
        originalRegisterNetEvent(eventName, function(...)
            local source = source
            if playersEvent[source] then
                if (os.time() - playersEvent[source]) <= 1 then
                    if spammerEvent[source] >= 30 then
                        DropPlayer(source, "Spamming event: " .. eventName)
                        -- print('DROPPED PLAYER FOR SPAMMING')
                    else
                        spammerEvent[source] += 1
                    end
                else
                    playersEvent[source] = os.time()
                    spammerEvent[source] = 1
                end
            else
                playersEvent[source] = os.time()
                spammerEvent[source] = 1
            end
            eventCallback(...)
        end)
    end
end
