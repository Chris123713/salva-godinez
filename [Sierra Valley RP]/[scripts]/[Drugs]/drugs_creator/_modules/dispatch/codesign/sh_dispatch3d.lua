local moduleType = "dispatch" -- Module category
local moduleName = "codesign3d" -- THIS module name

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

    -- Remove FiveM color codes (e.g., ~r~, ~b~, etc.) from the message
    local uncoloredMessage = message:gsub('~.-~', ''):gsub('^%s*', ''):gsub('%s*$', '')

    TriggerEvent('cd_dispatch:AddNotification', {
        job_table = {'police', },
        coords = coords,
        title = '10-15 - Drugs',
        message = uncoloredMessage,
        flash = 0,
        sound = 1,
        blip = {
            sprite = 431,
            scale = 1.2,
            colour = 3,
            flashes = false,
            text = '911 - Drugs',
            time = 5,
            radius = 0,
        }
    })
end

-- Code inside here will happen client side ON ALL COPS CLIENTS
Integrations[moduleType][moduleName].alertPoliceMemberClientSide = function(coords, message, category)
    if IsDuplicityVersion() then return end

    -- Code may also go here
end
