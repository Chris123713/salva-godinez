if Config.Command then
    lib.addCommand(Config.Command, {
        help = 'Open Weather Menu',
        params = {},
        restricted = Config.AdminLevel
    }, function(source, args, raw)
        openMenu(source)
    end)
end