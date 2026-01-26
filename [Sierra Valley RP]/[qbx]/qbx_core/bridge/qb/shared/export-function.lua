return function (name, cb)
    -- Register exports using ONLY FiveM's event handler system
    -- NOTE: Cannot use direct assignment (exports['qb-core'][name] = cb) with provide directive
    -- Must use AddEventHandler and exports() function instead
    
    -- Register using exports() function for immediate availability
    exports(name, cb)
    
    -- Also register via event handlers for full compatibility
    -- Register export for qb-core (compatibility via provide directive)
    AddEventHandler(('__cfx_export_qb-core_%s'):format(name), function(setCB)
        setCB(cb)
    end)
    
    -- Register export for qbx_core (actual resource name)
    AddEventHandler(('__cfx_export_qbx_core_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end