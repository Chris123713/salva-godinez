RegisterNetEvent('CompanyManager:company:client:toggleDuty', function()
    TriggerServerEvent('CompanyManager:company:server:toggleDuty')
end)

function CheckPermission(permission, job)
    while not PlayerData do
        Wait(150)
    end
    if not Config.bossmenu[PlayerData.job.name] and (PlayerData.gang and not Config.gangs[PlayerData.gang.name]) then
        return false
    else
        if job then
            if not PlayerData.job.name == job and (PlayerData.gang and not PlayerData.gang.name == job) then
                return false
            end
        end
        if Config.bossmenu[job] and GetPlayerGrade() >= Utils.GetNestedObjectValue(permission, Config.bossmenu[job]) then
            return true
        elseif Config.gangs[job] and PlayerData.gang and GetPlayerGrade(true) >= Utils.GetNestedObjectValue(permission, Config.gangs[job]) then
            return true
        end
    end
    return false
end

-- RegisterKeyMapping(Config.BillCommand, 'Open bill menu', 'keyboard', 'F7')

function IsJobAllowed(job, duty)
    while not PlayerLoaded do
        Wait(100)
    end

    if duty then
        return PlayerData and PlayerData.job and (PlayerData.job.name == job or PlayerData.job.name == 'off' .. job)
    else
        return PlayerData and PlayerData.job.name == job or PlayerData.gang and PlayerData.gang.name == job
    end
end

function GetName()
    while not PlayerLoaded do
        Wait(100)
    end

    return PlayerData and PlayerData.name
end

function GetPlayerGrade(isGang)
    while not PlayerLoaded do
        Wait(100)
    end

    if isGang then
        return PlayerData and PlayerData.gang and PlayerData.gang.grade
    else
        return PlayerData and PlayerData.job and PlayerData.job.grade
    end
end
