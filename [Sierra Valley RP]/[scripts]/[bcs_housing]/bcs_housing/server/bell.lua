RegisterNetEvent('Housing:server:Bell', function(homeId)
    local home = Homes[homeId]
    if not home then return end

    local players = home:GetPlayersInside()

    for i = 1, #players, 1 do
        TriggerClientEvent('Housing:client:Bell', players[i], homeId)
    end
end)
