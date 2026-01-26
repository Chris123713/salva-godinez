CreateThread(function()
    local firstSpawn = true
    if Config.framework ~= 'ESX' then return end
    ESX = exports[Config.exportname.es_extended]:getSharedObject()

    function GetIdentifier()
        return PlayerData and PlayerData.identifier
    end

    function TriggerServerCallback(func, ...)
        ESX.TriggerServerCallback(func, ...)
    end

    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        RemoveAllBlip()
        TriggerEvent("Housing:initialize")
        if not firstSpawn then
            if Homes and next(Homes) then
                for homeId, home in pairs(Homes) do
                    home:InitZones()
                    if home.properties.data and home.properties.data.signboard then
                        LoadSignboard(home.properties.data.signboard, home.properties.realestate)
                    end
                    if home.properties.complex == 'Individual' then
                        Individuals[home.identifier]:SetEntranceZone(home.properties.entry, home.properties.name)
                    elseif home.properties.complex == 'Apartment' then
                        Apartments[home.identifier]:SetEntranceZone(home.properties.entry, home.properties.name)
                    end
                end
            end
        end
        firstSpawn = false
    end)

    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
    end)

    while ESX.GetPlayerData().job == nil do
        Wait(100)
    end

    PlayerData = ESX.GetPlayerData()

    function GetPlayerGrade()
        return PlayerData and PlayerData.job and PlayerData.job.grade
    end

    function GetName()
        return PlayerData.firstName .. ' ' .. PlayerData.lastName
    end
end)
