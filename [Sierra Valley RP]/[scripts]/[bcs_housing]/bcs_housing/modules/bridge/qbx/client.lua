local firstSpawn = true
if Config.framework ~= 'QBX' then return end
QBX = exports[Config.exportname.qbx_core]

local function ReOrderJob(job)
    return {
        label = job.label,
        grade_label = job.grade.name,
        name = job.name,
        grade = job.grade.level,
        salary = job.grade.payment
    }
end

CreateThread(function()
    while QBX:GetPlayerData().job == nil do
        Wait(100)
    end

    PlayerData = QBX:GetPlayerData()
    PlayerData.job = ReOrderJob(PlayerData.job)
end)


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

function GetIdentifier()
    return PlayerData and PlayerData.citizenid
end

function GetPlayerGrade()
    return PlayerData and PlayerData.job and PlayerData.job.grade
end

function GetName()
    return PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
end
