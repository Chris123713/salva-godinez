local webhook = "" -- Add your Discord webhook here

function sendLogs(src,data,type)
    if webhook == "" then return end -- <-- DON'T ADD ANYTHING HERE PLEASE AND THANK U...
    local name = GetPlayerName(src)
    local discord_user = GetPlayerIdentifierByType(src, 'discord')
    discord_user = getDiscord(discord_user)
    local title = "Zone(s) Updated"
    local description = false
    if type == "zones" then
        local zones = capitalizeZones(data.zones)
        description = {
            "**User:** "..name..(discord_user and " <@"..discord_user..">" or ""),
            "**Zone(s):** "..zones,
            "**Weather:** "..(data.weather or ""),
            "**Freeze:** "..(data.freeze and data.freeze == "yes" and "Yes" or "No"),
            "**Temperature:** "..(data.temperature or ""),
            "**Fog: **"..(data.fog or ""),
            "**Wind: **"..(data.wind or "")
        }
    elseif type == "server" then
        title = "Server Time Updated"
        description = {
            "**User:** "..name..(discord_user and " <@"..discord_user..">" or ""),
            "**Time: **"..(data.hour or serverTime.hour)..":"..(data.minutes or serverTime.minutes),
            "**Freeze:** "..(data.freezeTime and "Yes" or "No"),
            "**Moon:** "..(data.moon and moonTypes[tostring(data.moon)] or ""),
        }
    elseif type == "random" then
        title = "Random Weather"
        local zones = capitalizeZones(data.zones)
        description = {
            "**User:** "..name..(discord_user and " <@"..discord_user..">" or ""),
            "**Zone(s):** "..zones,
        }
    elseif type == "blackout" then
        title = "Toggle Blackout"
        local state = data and "Enabled" or "Disabled"
        description = {
            "**User:** "..name..(discord_user and " <@"..discord_user..">" or ""),
            "**State:** "..state,
        }
    end
    if description then
        local message = {
            {
                ['title'] = title,
                ['description'] = table.concat(description, "\n"),
                ['color'] = "5793266",
                ['footer'] = {
                    ['text'] = os.date('%c'),
                },
            } 
        }
        PerformHttpRequest(webhook, function() end, 'POST', json.encode({ username = 'AV Scripts', embeds = message }), { ['Content-Type'] = 'application/json' })
    end
end

function getDiscord(input)
    if not input or input == "" then
      return false
    end
    local result = input:gsub("^discord:", "")
    return result
end

function capitalizeZones(zones)
    local capitalizedZones = {}
    for _, zone in ipairs(zones) do
        table.insert(capitalizedZones, zone:sub(1, 1):upper() .. zone:sub(2):lower())
    end
    return table.concat(capitalizedZones, ", ")
end