Config.framework = 'custom' -- ESX or QB or custom
if IsResourceStarted(Config.exportname.es_extended) then
    Config.framework = 'ESX'
elseif IsResourceStarted(Config.exportname.qbx_core) then
    Config.framework = 'QBX'
elseif IsResourceStarted(Config.exportname.qb_core) then
    Config.framework = 'QB'
end

---@diagnostic disable-next-line
lib, cache, locale = lib, cache, locale --[[@as function]]

lib.locale(Config.Lang)
