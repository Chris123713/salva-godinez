CreateThread(function()
    if Config.framework ~= 'custom' then return end

    --When player logs in to the server
    RegisterNetEvent('framework:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        RemoveAllBlip()
        TriggerEvent("Housing:initialize")
    end)

    PlayerData = GetPlayerData()

    RegisterNetEvent('framework:setJob')
    AddEventHandler('framework:setJob', function(job)
        PlayerData.job = job
    end)

    function GetIdentifier()
        return PlayerData and PlayerData.citizenid
    end
end)
