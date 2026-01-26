CreateThread(function()
    local firstSpawn = true
    if Config.framework ~= 'QB' then return end
    QBCore = exports[Config.exportname.qb_core]:GetCoreObject()

    function GetIdentifier()
        return PlayerData and PlayerData.citizenid
    end

    function GetPlayerGrade()
        return PlayerData and PlayerData.job and PlayerData.job.grade or nil
    end

    function GetName()
        return PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
    end

    while QBCore.Functions.GetPlayerData().job == nil do
        Wait(100)
    end

    local function ReOrderJob(job)
        return {
            label = job.label,
            grade_label = job.grade.name,
            name = job.name,
            grade = job.grade.level,
            salary = job.grade.payment
        }
    end

    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerData.job = ReOrderJob(PlayerData.job)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        PlayerData = val
        PlayerData.job = ReOrderJob(PlayerData.job)
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        RemoveAllBlip()
    end)

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
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
end)
