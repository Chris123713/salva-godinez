local moduleType = "logs" -- Module category
local moduleName = "custom" -- THIS module name

-- Don't touch, required to appear in in-game settings
-- Don't touch, required to appear in in-game settings
Integrations.modules = Integrations.modules or {}
Integrations.modules[moduleType] = Integrations.modules[moduleType] or {}
Integrations[moduleType] = Integrations[moduleType] or {}
Integrations[moduleType][moduleName] = {}
table.insert(Integrations.modules[moduleType], moduleName)

--[[
    You can edit below here
]] 

Integrations[moduleType][moduleName].log = function(playerId, title, description, type, logType)
    if(not config.areDiscordLogsActive) then return end

    lib.log(playerId, title, description)
end
