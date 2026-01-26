local moduleType = "dispatch" -- Module category
local moduleName = "roadphone" -- THIS module name

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

    for jobName, _ in pairs(POLICE_JOBS_NAMES) do
        exports['roadphone']:sendDispatchAnonym(jobName, "10-15 - Drugs", message, coords, nil)
    end
end

-- Code inside here will happen client side ON ALL COPS CLIENTS
Integrations[moduleType][moduleName].alertPoliceMemberClientSide = function(coords, message, category)
    if IsDuplicityVersion() then return end

    -- Code may also go here
end
