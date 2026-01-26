if Config.Framework ~= "esx" then
    return
end

local ESX = exports.es_extended:getSharedObject()

RegisterNetEvent("esx:playerLoaded", function(playerData)
    ESX.PlayerData = playerData
end)

RegisterNetEvent("esx:setJob", function(job)
    ESX.PlayerData.job = job
end)

function GetJob()
    return ESX.PlayerData.job.name
end
