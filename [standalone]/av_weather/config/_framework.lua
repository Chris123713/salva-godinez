Config = Config or {}
Config.Framework = false

CreateThread(function()
    if GetResourceState("qb-core") == "started" then
        Config.Framework = "qb"
        return
    end
    if GetResourceState("es_extended") == "started" then
        Config.Framework = "esx"
        return
    end
    if GetResourceState("qbx_core") == "started" then
        Config.Framework = "qb"
        return
    end
    if GetResourceState("ox_core") == "started" then
        Config.Framework = "ox"
        return
    end
end)