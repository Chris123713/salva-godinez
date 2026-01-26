local framework = exports["qb-core"]:GetCoreObject()
func = {}

func.getPlayerData = function(src)
    local data = framework.Functions.GetPlayer(src)

    if not data then return nil end

    local name = {
        first = data.PlayerData.charinfo.firstname or nil,
        last = data.PlayerData.charinfo.lastname or nil
    }

    if name.first and name.last then
        name.full = name.first .. " " .. name.last
    end

    local job = {
        name = data.PlayerData.job.name or nil,
        label = data.PlayerData.job.label or nil,
        onDuty = data.PlayerData.job.onduty or false,
        grade = data.PlayerData.job.grade.level or 0,
        gradeName = data.PlayerData.job.grade.name or nil
    }

    local gang = {
        name = data.PlayerData.gang.name or nil,
        label = data.PlayerData.gang.label or nil,
        rank = data.PlayerData.gang.rank or nil
    }

    local money = {
        cash = data.PlayerData.money.cash or 0,
        bank = data.PlayerData.money.bank or 0
    }

    return {
        identifier = data.PlayerData.citizenid or nil,
        gender = data.PlayerData.charinfo.gender == 1 and "female" or "male",
        name = name,
        job = job,
        gang = gang,
        money = money,
        metadata = data.PlayerData.metadata or nil,
        items = data.PlayerData.items or nil,
        source = data.PlayerData.source or nil
    }
end

func.getPlayerByIdentifier = function(identifier)
    local data = framework.Functions.GetPlayerByCitizenId(identifier)
    if not data then data = framework.Player.GetOfflinePlayer(identifier) end
    if not data then return nil end

    local name = {
        first = data.PlayerData.charinfo.firstname or nil,
        last = data.PlayerData.charinfo.lastname or nil
    }

    if name.first and name.last then
        name.full = name.first .. " " .. name.last
    end

    local job = {
        name = data.PlayerData.job.name or nil,
        label = data.PlayerData.job.label or nil,
        onDuty = data.PlayerData.job.onduty or false,
        grade = data.PlayerData.job.grade.level or 0,
        gradeName = data.PlayerData.job.grade.name or nil
    }

    local gang = {
        name = data.PlayerData.gang.name or nil,
        label = data.PlayerData.gang.label or nil,
        rank = data.PlayerData.gang.rank or nil
    }

    local money = {
        cash = data.PlayerData.money.cash or 0,
        bank = data.PlayerData.money.bank or 0
    }

    return {
        identifier = data.PlayerData.citizenid or nil,
        gender = data.PlayerData.charinfo.gender == 1 and "female" or "male",
        name = name,
        job = job,
        gang = gang,
        money = money,
        source = data.PlayerData.source or nil,
        metadata = data.PlayerData.metadata or nil,
        source = data.PlayerData.source or nil
    }
end

func.addMoney = function(src, moneyType, amount)
    local data = framework.Functions.GetPlayer(src)

    if not data then return false end

    data.Functions.AddMoney(moneyType, amount)

    return true
end

func.removeMoney = function(src, moneyType, amount)
    local data = framework.Functions.GetPlayer(src)

    if not data then return false end

    data.Functions.RemoveMoney(moneyType, amount)

    return true
end

func.createUsableItem = function(name, cb)
    framework.Functions.CreateUseableItem(name, cb)
end

local function convertArgs(args, commandArgs)
    local newArgs = {}

    for i, v in ipairs(commandArgs) do newArgs[v.name] = args[i] end

    return newArgs
end

func.registerCommand = function(name, permission, cb, data)
    data = data ~= nil and data or {}
    data.help = data.help ~= nil and data.help or ""
    data.arguments = data.arguments ~= nil and data.arguments or {}

    local newCb = function(source, args)
        local newArgs = convertArgs(args, data.arguments)

        for _, value in pairs(data.arguments) do
            if not value.optional and newArgs[value.name] == nil then
                Lib.print(
                    ("You haven't filled in all the arguments, specifically ^3%s^0"):format(
                        value.name), "error")
                return
            end
        end

        cb(source, newArgs)
    end

    framework.Commands.Add(name, data.help, data.arguments, false, newCb,
                           permission)
end

local function convertJob(job, v)
    local convertedJob = {name = job, label = v.label, grades = {}}

    for grade, value in pairs(v.grades) do
        local fixGrade = tonumber(grade)

        convertedJob.grades[fixGrade] = {grade = fixGrade, name = value.name}
    end

    return convertedJob
end

func.getAllJobs = function()
    local jobs = framework.Shared.Jobs
    local convertedJobs = {}

    for job, v in pairs(jobs) do convertedJobs[job] = convertJob(job, v) end

    return convertedJobs
end

func.getJob = function(job)
    local jobs = framework.Shared.Jobs
    local convertedJob = {}

    if not jobs[job] then
        Lib.print(("Job %s doesn't exist"):format(job), "error")
        return convertedJob
    end

    return convertJob(job, jobs[job])
end

func.setMetadata = function(src, key, value)
    local data = framework.Functions.GetPlayer(src)

    if not data then return false end

    data.Functions.SetMetaData(key, value)

    return true
end

func.getMetadata = function(src, key)
    local data = framework.Functions.GetPlayer(src)

    if not data then return nil end

    return data.Functions.GetMetaData(key)
end

func.hasPermission = function(src, permission)
    return framework.Functions.HasPermission(src, permission) or
               IsPlayerAceAllowed(src, 'command')
end

return func
