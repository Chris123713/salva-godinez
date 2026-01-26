-- server.lua

-- Whitelist | Steam | Discord | FiveM

local BMXWhitelist = {
    "discord:423261248243892224", -- Creator Discord ID.
    "steam:110000112345678", -- Your ID.
    "fivem:17703310",   -- Add your Clients!
}

--- Function to check if an identifier is whitelisted
function isPlayerWhitelisted(identifier)
    for _, id in ipairs(BMXWhitelist) do
        if id == identifier then
            return true
        end
    end
    return false
end

-- Event to check if the player is whitelisted
RegisterNetEvent('CheckBMXWhitelist')
AddEventHandler('CheckBMXWhitelist', function()
    local _source = source
    local identifiers = GetPlayerIdentifiers(_source)
    local isWhitelisted = false

    for _, identifier in ipairs(identifiers) do
        if isPlayerWhitelisted(identifier) then
            isWhitelisted = true
            break
        end
    end

    -- Notify the client about the whitelist status
    TriggerClientEvent('ReceiveBMXWhitelistStatus', _source, isWhitelisted)
end)
