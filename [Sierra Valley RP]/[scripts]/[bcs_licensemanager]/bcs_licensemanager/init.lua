Shared = {}

---@diagnostic disable-next-line
lib, cache, locale = lib, cache, locale --[[@as function]]

lib.locale()

if GetResourceState("es_extended") == "started" then
    Shared.framework = "esx"
elseif GetResourceState("qbx_core") == "started" and lib.checkDependency('qbx_core', '1.22.0') then
    Shared.framework = "qbx"
elseif GetResourceState("qb-core") == "started" then
    Shared.framework = "qb"
else
    Shared.framework = "custom"
end

if IsDuplicityVersion() then
    require('modules.utils.server')
else
    require('modules.utils.client')
end
