local moduleType = "dispatch" -- Module category
local moduleName = "default" -- THIS module name

-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

--[[
    You can edit below here
]]

-- Code inside here will happen once per call server side
Integrations[moduleType][moduleName].alertPoliceServerSide = function(coords, message, category)
    if not IsDuplicityVersion() then return end

    -- Add your code here (most dispatch scripts uses server side events to alert police members, for example an export to call or a event to trigger to a single client)
end

-- Code inside here will happen client side ON ALL COPS CLIENTS
Integrations[moduleType][moduleName].alertPoliceMemberClientSide = function(coords, message, category)
    if IsDuplicityVersion() then return end

    coords = vecFromTable(coords)
    local blip = AddBlipForRadius(coords, 50.0)

    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 150)

    local streetName = GetStreetNameAtCoord(coords.x, coords.y, coords.z)

    local streetLabel = GetStreetNameFromHashKey(streetName)

    notifyClient(message)
    notifyClient("~y~" .. streetLabel .. "~s~")

    local blipTime = (BLIP_TIME_AFTER_POLICE_ALERT or 120) * 1000

    SetTimeout(blipTime, function()
        if(DoesBlipExist(blip)) then
            RemoveBlip(blip)
        end
    end)
end
