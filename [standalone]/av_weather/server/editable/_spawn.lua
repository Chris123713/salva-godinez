-- The following events are used to detect when a player is loaded (qb-qbx and esx)
-- init function is triggered along with player source id to receive all info from zones, time, etc

AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
    init(Player.PlayerData.source)
end)

RegisterServerEvent('esx:onPlayerJoined')
AddEventHandler("esx:onPlayerJoined", function(Player)
    local src = Player
    if not src or not tonumber(src) then src = source end
    init(src)
end)

AddEventHandler("ox:playerLoaded", function(playerId)
    if not playerId or not tonumber(playerId) then return end
    init(playerId)
end)