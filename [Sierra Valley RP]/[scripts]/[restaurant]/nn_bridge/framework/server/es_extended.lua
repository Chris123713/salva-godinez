local framework = exports["es_extended"]:getSharedObject()
func = {}

func.getPlayerData = function(src)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end

    local name = {
        first = data.variables.firstName or nil,
        last = data.variables.lastName or nil,
    }

    if name.first and name.last then
        name.full = name.first .. " " .. name.last
    end

    local job = {
        name = data.job.name or nil,
        label = data.job.label or nil,
        onDuty = true,
        grade = data.job.grade or 0,
        gradeName = data.job.grade_name or nil,
    }

    local money = {
        cash = data.getAccount("money").money or 0,
        bank = data.getAccount("bank").money or 0,
    }

    return {
        identifier = data.identifier or nil,
        gender = data.variables.sex == "m" and "male" or "female",
        name = name,
        job = job,
        gang = job,
        money = money,
        source = data.source or nil,
    }
end

func.getPlayerByIdentifier = function(identifier)
    local data = framework.GetPlayerFromIdentifier(identifier)

    if not data then return nil end

    local name = {
        first = data.variables.firstName or nil,
        last = data.variables.lastName or nil,
    }

    if name.first and name.last then
        name.full = name.first .. " " .. name.last
    end

    local job = {
        name = data.job.name or nil,
        label = data.job.label or nil,
        onDuty = true,
        grade = data.job.grade or 0,
        gradeName = data.job.grade_name or nil,
    }

    local money = {
        cash = data.getAccount("money").money or 0,
        bank = data.getAccount("bank").money or 0,
    }

    return {
        identifier = data.identifier or nil,
        gender = data.variables.sex == "m" and "male" or "female",
        name = name,
        job = job,
        gang = job,
        money = money,
        source = data.source or nil,
    }
end

func.addMoney = function(src, moneyType, amount)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end

    data.addAccountMoney(moneyType, amount)

    return true
end

func.removeMoney = function(src, moneyType, amount)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end
    if moneyType == "cash" then moneyType = "money" end
    data.removeAccountMoney(moneyType, amount)
    return true
end

func.createUsableItem = function(name, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    framework.RegisterUsableItem(name, func)
end

func.registerCommand = function(name, permission, cb, data)
    data = data ~= nil and data or {}
    data.help = data.help ~= nil and data.help or ""
    data.arguments = data.arguments ~= nil and data.arguments or {}

    local newCb = function(source, args)
        for _, value in pairs(data.arguments) do
            if not value.optional and args[value.name] == nil then
                Lib.print(("You haven't filled in all the arguments, specifically ^3%s^0"):format(value.name), "error")
                return
            end
        end

        cb(source.source, args)
    end

    if data.arguments then
        for _, v in pairs(data.arguments) do
            v.type = "any" 
        end
    end

    framework.RegisterCommand(name, permission, newCb, false, data)
end

local function convertJob(job, v)
    local convertedJob = {
        name = job,
        label = v.label,
        grades = {},
    }

    for grade, value in pairs(v.grades) do
        local fixGrade = tonumber(grade)

        convertedJob.grades[fixGrade] = {
            grade = fixGrade,
            name = value.label,
        }
    end

    return convertedJob
end

func.getAllJobs = function()
    local jobs = framework.GetJobs()
    local convertedJobs = {}

    for job, v in pairs(jobs) do
        convertedJobs[job] = convertJob(job, v)
    end

    return convertedJobs
end

func.getJob = function(job)
    local jobs = framework.GetJobs()
    local convertedJob = {}

    if not jobs[job] then
        Lib.print(("Job %s doesn't exist"):format(job), "error")
        return convertedJob 
    end

    return convertJob(job, jobs[job])
end

func.setMetadata = function(src, key, value)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end

    data.setMeta(key, value)

    return true
end

func.getMetadata = function(src, key)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end

    return data.getMeta(key)
end

func.hasPermission = function(src, permission)
    local data = framework.GetPlayerFromId(src)

    if not data then return nil end

    return data.getGroup() == permission
end

return func