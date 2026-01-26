RegisterCommand('tebex_house', function(src, args)
    if src == 0 then
        print('[^1HOUSING TEBEX^0] Incoming tebex command', args[1], args[2])
        local home = Homes[args[1]]
        if home then
            print('[^1HOUSING TEBEX^0] Redeem code successfully set in DB')
            MySQL.update("UPDATE house SET tebex = ? WHERE identifier = ?", { args[2], args[1] })
        end
    end
end)

RegisterCommand(commands.redeemhome.name, function(src, args)
    local xPlayer = GetPlayerFromId(src)
    local home = Homes[args[1]]
    if home and xPlayer then
        MySQL.scalar('SELECT tebex FROM house WHERE identifier = ?', { args[1] }, function(tbxId)
            if tbxId and tbxId == args[2] then
                if home.owner or (home.complex == 'Apartment' and OwnApartment(xPlayer.identifier, args[1])) then
                    home:ExtendHouse(xPlayer.identifier)
                else
                    GiveHouse(args[1], tonumber(src))
                end
                MySQL.update("UPDATE house SET tebex = ? WHERE identifier = ?", { nil, args[1] })
                TriggerClientEvent('Housing:notify', src, locale('housing'), locale('redeemed_house', home.name),
                    'success', 5000)
            else
                TriggerClientEvent('Housing:notify', src, locale('housing'), locale('invalid_input'),
                    'error', 5000)
            end
        end)
    end
end)
