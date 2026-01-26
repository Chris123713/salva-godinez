local moduleType = "dispatch" -- Module category
local moduleName = "rcore" -- THIS module name

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

    local data = {
        code = '10-15 - Drugs',
        default_priority = 'medium',
        coords = coords,
        job = 'police',
        text = message,
        type = 'alerts',
        blip_time = 5,
        blip = {
            sprite = 54,
            colour = 3,
            scale = 0.7,
            text = 'Drug',
            flashes = false,
            radius = 0,
        }
    }

    TriggerEvent('rcore_dispatch:server:sendAlert', data)
end

-- Code inside here will happen client side ON ALL COPS CLIENTS
Integrations[moduleType][moduleName].alertPoliceMemberClientSide = function(coords, message, category)
    if IsDuplicityVersion() then return end

    -- Code may also go here
end
