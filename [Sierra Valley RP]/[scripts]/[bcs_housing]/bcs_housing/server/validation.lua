function isAdmin(xPlayer)
    for k, v in pairs(Config.Admin.Groups) do
        if CheckAdminGroup(xPlayer, v) then
            return true
        end
    end
    return false
end

function CheckRealestateGrade(action, job, grade)
    if JobConfig.jobs[job] and JobConfig.jobs[job].grade[action] then
        return JobConfig.jobs[job].grade[action] <= grade
    else
        return false
    end
end

function isAgent(xPlayer, job, perm)
    if job and GetJobName(xPlayer) == job then
        if perm then
            return JobConfig.jobs[job].permission[perm] <= GetJobGrade(xPlayer)
        else
            return true
        end
    else
        return false
    end
end

lib.callback.register("Housing:server:EnterCheck", function(source, homeId, aptId, teleport)
    local home = Homes[homeId]
    if home and not exports[GetCurrentResourceName()]:isLocked(homeId, aptId) or teleport then
        local xPlayer = GetPlayerFromId(source)
        local entrance = home:GetEntryCoords()
        if isAdmin(xPlayer) then
            return true
        end
        if sv_config.AntiCheatChecks.CheckEnterHomeDistance then
            local dist = #(ToVector3(teleport or entrance) - GetEntityCoords(GetPlayerPed(source)))
            if dist > 10.0 then
                TriggerEvent('Housing:server:PotentialCheater', 'Housing:client:EnterHome',
                    ('%s (%s) tried to enter a house (%s) from %s distance'):format(GetName(xPlayer), xPlayer.identifier,
                        homeId, dist), source)
                return false
            end
        end

        if Config.robbery.disableVisit then
            if not home:isKeyOwner(xPlayer.identifier, aptId) then
                TriggerEvent('Housing:server:PotentialCheater', 'Housing:client:EnterHome',
                    ('%s (%s) tried to enter a house (%s) that is not owned'):format(GetName(xPlayer), xPlayer
                        .identifier, homeId), source)
                return false
            end
        end
        return true
    elseif Player(source).state.firstSpawn then
        Player(source).state:set('firstSpawn', false)
        return true
    end
end)
