local framework = exports["es_extended"]:getSharedObject()
func = {}

RegisterNetEvent('esx:setJob', function(job) 
    TriggerEvent('pd_bridge:updateJob', {
        name = job.name or nil,
        label = job.label or nil,
        onDuty = true,
        grade = job.grade or 0,
        gradeName = job.grade_name or nil,
    })
end)

func.getPlayerData = function()
    local data = framework.GetPlayerData()

    if not data then return nil end
    
    local name = {
        first = data.firstName or nil,
        last = data.lastName or nil,
    }

    if name.first and name.last then
        name.full = name.first .. " " .. name.last
    end

    local job = {
        name = data.job and data.job.name or nil,
        label = data.job and data.job.label or nil,
        onDuty = true,
        grade = data.job and data.job.grade or 0,
        gradeName = data.job and data.job.grade_name or nil,
    }

    local gang = {
        name = data.gang and data.gang.name or nil,
        label = data.gang and data.gang.label or nil,
        grade = data.gang and data.gang.grade or 0,
        gradeName = data.gang and data.gang.grade_name or nil,
    }

    return {
        identifier = data.identifier or nil,
        gender = data.sex == "m" and "male" or "female",
        name = name,
        job = job,
        gang = gang,
        metadata = data.metadata or nil,
    }
end

func.isLoaded = function()
    return bridge.framework.getPlayerData().identifier ~= nil
end

local function convertArgs(args, commandArgs)
    local newArgs = {}

    for i, v in ipairs(commandArgs) do
        newArgs[v.name] = args[i]
    end

    return newArgs
end

local function hasJob(player_job, requiredJob)
    local reqJobType = type(requiredJob)

    if reqJobType == "string" and player_job == requiredJob then return true end

    if reqJobType == "table" then
        for _, jobName in pairs(requiredJob) do
            if player_job == jobName then return true end
        end
    end

    return false
end

func.registerCommand = function(name, job, cb, data)
    data = data ~= nil and data or {}
    data.help = data.help ~= nil and data.help or ""
    data.arguments = data.arguments ~= nil and data.arguments or {}

    local newCb = function(_, args, __)
        local newArgs = convertArgs(args, data.arguments)

        if job then
            local playerHasJob = hasJob(bridge.framework.getPlayerData().job.name, job)

            if not playerHasJob then
                Lib.print("You don't have the required Job", "error")
                return
            end
        end

        for _, value in pairs(data.arguments) do
            if not value.optional and newArgs[value.name] == nil then
                Lib.print(("You haven't filled in all the arguments, specifically ^3%s^0"):format(value.name), "error")


                return
            end
        end
        
        cb(newArgs)
    end

    RegisterCommand(name, newCb, false)

    TriggerEvent("chat:addSuggestion", "/" .. name, data.help, data.arguments)
end

return func