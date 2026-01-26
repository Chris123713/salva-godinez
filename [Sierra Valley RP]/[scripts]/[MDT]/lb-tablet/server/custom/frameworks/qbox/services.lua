if Config.Framework ~= "qbox" then
    return
end

while not QB do
    Wait(0)
end

---@alias QboxPlayerJob { name: string, onduty: boolean }

---@type { [number]: QboxPlayerJob }
local playerJobs = {}
---@type { [string]: number }
local jobCounts = {}
---@type { [string]: number }
local jobDutyCounts = {}

function RefreshCompanies()
    if Config.QBOldJobMethod then
        debugprint("using old method to refresh companies")

        local openJobs = {}
        local players = QB.Functions.GetQBPlayers()

        for _, qPlayer in pairs(players) do
            if not qPlayer?.PlayerData.job.onduty then
                goto continue
            end

            local job = qPlayer.PlayerData.job.name

            if not openJobs[job] then
                openJobs[job] = true
            end

            ::continue::
        end

        for i = 1, #Config.Services.Companies do
            local jobData = Config.Services.Companies[i]

            jobData.open = openJobs[jobData.job] or false
        end

        return
    end

    for i = 1, #Config.Services.Companies do
        local jobData = Config.Services.Companies[i]

        jobData.open = (jobDutyCounts[jobData.job] or 0) > 0
    end
end

CreateThread(function()
    local players = QB.Functions.GetQBPlayers()

    for _, player in pairs(players) do
        -- Safety check: ensure player is a table with PlayerData
        if type(player) ~= "table" or not player.PlayerData then
            debugprint("qb jobs: skipping invalid player entry", type(player))
            goto continue
        end

        local playerData = player.PlayerData
        local job = playerData.job

        if not job then
            goto continue
        end

        local jobName = job.name
        local onDuty = job.onduty

        playerJobs[playerData.source] = {
            name = jobName,
            onduty = onDuty
        }

        jobCounts[jobName] = (jobCounts[jobName] or 0) + 1
        jobDutyCounts[jobName] = (jobDutyCounts[jobName] or 0) + (onDuty and 1 or 0)

        ::continue::
    end

    debugprint("qb jobs: initial data", playerJobs, jobCounts, jobDutyCounts)
end)

AddEventHandler("QBCore:Server:PlayerLoaded", function(qPlayer)
    local job = qPlayer.PlayerData.job
    local src = qPlayer.PlayerData.source
    local jobName = job?.name
    local onDuty = job?.onduty

    if not jobName then
        return
    end

    playerJobs[src] = {
        name = jobName,
        onduty = onDuty
    }

    jobCounts[jobName] = (jobCounts[jobName] or 0) + 1
    jobDutyCounts[jobName] = (jobDutyCounts[jobName] or 0) + (onDuty and 1 or 0)

    debugprint("qb jobs: player loaded update (src, job, duty)", src, job.name, job.onduty)
end)

---@param src number
---@param job QboxPlayerJob
local function OnPlayerJobUpdate(src, job)
    local shouldRefresh = false
    local lastJob = playerJobs[src]
    local lastName = lastJob and lastJob.name
    local lastDuty = lastJob and lastJob.onduty
    local jobName = job.name
    local onDuty = job.onduty

    debugprint("qb jobs: job/duty update (src, job, duty)", src, job.name, job.onduty)

    if lastJob and lastName == jobName then
        if lastJob.onduty == onDuty then
            return
        end

        jobDutyCounts[jobName] = (jobDutyCounts[jobName] or 0) + (onDuty and 1 or -1)
    else
        if lastJob then
            jobCounts[lastName] = (jobCounts[lastName] or 0) - 1
            jobDutyCounts[lastName] = (jobDutyCounts[lastName] or 0) - (lastDuty and 1 or 0)

            local oldCount = jobDutyCounts[lastName]

            if oldCount == 0 or oldCount == 1 then
                TriggerClientEvent("phone:services:updateOpen", -1, lastName, oldCount == 1)
                shouldRefresh = true
            end
        end

        jobCounts[jobName] = (jobCounts[jobName] or 0) + 1
        jobDutyCounts[jobName] = (jobDutyCounts[jobName] or 0) + (onDuty and 1 or 0)
    end

    playerJobs[src] = {
        name = jobName,
        onduty = onDuty
    }

    local newCount = jobDutyCounts[jobName]

    if newCount == 0 or newCount == 1 then
        TriggerClientEvent("phone:services:updateOpen", -1, jobName, newCount == 1)
        shouldRefresh = true
    end

    if shouldRefresh then
        RefreshCompanies()
    end

    debugprint(playerJobs, jobCounts, jobDutyCounts)
    TriggerEvent("lb-tablet:jobUpdated", src, job.name, job.onduty)
end

AddEventHandler("QBCore:Server:SetDuty", function(src, duty)
    Wait(0) -- makes it print in server console instead of chat when using commands

    if not playerJobs[src] then
        debugprint("QBCore:Server:SetDuty: player job not found for src", src)
        return
    end

    OnPlayerJobUpdate(src, {
        name = playerJobs[src].name,
        onduty = duty
    })
end)

AddEventHandler("QBCore:Server:OnJobUpdate", function(src, job)
    Wait(0) -- makes it print in server console instead of chat when using commands
    OnPlayerJobUpdate(src, job)
end)

local function UnloadJob(src)
    local lastJob = playerJobs[src]

    if not lastJob then
        return
    end

    jobCounts[lastJob.name] = (jobCounts[lastJob.name] or 0) - 1
    jobDutyCounts[lastJob.name] = (jobDutyCounts[lastJob.name] or 0) - (lastJob.onduty and 1 or 0)
    playerJobs[src] = nil

    debugprint(playerJobs, jobCounts, jobDutyCounts)
end

AddEventHandler("QBCore:Server:OnPlayerUnload", function(src)
    Wait(0)
    debugprint("qb jobs: player unload", src)
    UnloadJob(src)
end)

AddEventHandler("playerDropped", function()
    local src = source

    debugprint("qb jobs: player dropped", src)
    UnloadJob(src)
end)

---@param company string
function GetEmployeeList(company)
    local numberTable = Config.LBPhone and (GetPhoneConfig()?.Item.Unique and "phone_last_phone" or "phone_phones") or nil
    local joinPhone = Config.LBPhone and ("LEFT JOIN %s p ON u.citizenid %s = p.id"):format(numberTable, UsersCollate) or ""

    local employees = MySQL.query.await([[
        SELECT
            u.citizenid, u.charinfo, u.job
            ]] .. (Config.LBPhone and ", p.phone_number AS `number`" or "") .. [[

        FROM players u

        ]] .. joinPhone .. [[

        WHERE JSON_VALUE(u.job, '$.name') = ?
    ]], { company })

    local players = exports.qbx_core:GetQBPlayers()
    local onlineCitizenIds = {}

    for _, qPlayer in pairs(players) do
        if qPlayer?.PlayerData?.job?.name == company then
            onlineCitizenIds[qPlayer.PlayerData.citizenid] = true
        end
    end

    for i = 1, #employees do
        local employee = employees[i]
        local charinfo = json.decode(employee.charinfo)
        local job = json.decode(employee.job)

        employees[i] = {
            firstname = charinfo.firstname,
            lastname = charinfo.lastname,
            number = employee.phone_number,
            gradeLabel = job.grade.name,
            grade = job.grade.level,
            online = onlineCitizenIds[employee.citizenid],
        }
    end

    return employees
end

RegisterCallback("services:getPlayerData", function(source, player)
    local first, last = GetCharacterName(player)

    return {
        name = first .. " " .. last,
        id = GetIdentifier(player),
    }
end)

local function GetSocietyMoney(job)
    return exports["Renewed-Banking"]:getAccountMoney(job) or 0
end

RegisterCallback("qbx:services:getAccount", function(source)
    local job = QB.Functions.GetPlayer(source).PlayerData.job
    local jobName = job.name

    if not job.isboss then
        return 0
    end

    return GetSocietyMoney(jobName)
end)

RegisterCallback("qbx:services:addMoney", function(source, amount)
    local job = QB.Functions.GetPlayer(source).PlayerData.job
    local jobName = job.name

    if amount < 0 or GetBalance(source) < amount then
        return false
    end

    local success = exports["Renewed-Banking"]:addAccountMoney(jobName, amount)

    if not success then
        return false
    end

    RemoveMoney(source, amount)

    return GetSocietyMoney(jobName)
end)

RegisterCallback("qbx:services:removeMoney", function(source, amount)
    local job = QB.Functions.GetPlayer(source).PlayerData.job
    local jobName = job.name

    if not job.isboss or amount < 0 or GetSocietyMoney(jobName) < amount then
        return false
    end

    local success = exports["Renewed-Banking"]:removeAccountMoney(jobName, amount)

    if not success then
        return false
    end

    AddMoney(source, amount)

    return GetSocietyMoney(jobName)
end)

RegisterCallback("services:addMoney", function(source, amount)
    local job = GetJob(source).name

    if amount < 0 or GetBalance(source) < amount then
        return false
    end

    local success, _ = pcall(function()
        return exports["qb-management"]:AddMoney(job, amount)
    end)

    if success or exports["qb-banking"]:AddMoney(job, amount) then
        RemoveMoney(source, amount)
    end

    return GetSocietyMoney(job)
end)

RegisterCallback("services:removeMoney", function(source, amount)
    local job = GetJob(source).name

    if amount < 0 or GetSocietyMoney(job) < amount then
        return
    end

    local success, res = pcall(function()
        return exports["qb-management"]:RemoveMoney(job, amount)
    end)

    if not success then
        res = exports["qb-banking"]:RemoveMoney(job, amount)
    end

    if res then
        AddMoney(source, amount)
    end

    return GetSocietyMoney(job)
end)

RegisterCallback("qbx:services:getEmployees", function(source)
    local employees = {}
    local player = QB.Functions.GetPlayer(source)

    if not player or not player.PlayerData or not player.PlayerData.job then
        return employees
    end

    local job = player.PlayerData.job

    if not job.isboss then
        return employees
    end

    local members = exports.qbx_core:GetGroupMembers(job.name, "job")

    -- Safety check: ensure members is a table
    if not members or type(members) ~= "table" then
        return employees
    end

    for i = 1, #members do
        local member = members[i]
        if member and member.citizenid then
            local gradeLevel = member.grade or 0
            local citizenid = member.citizenid
            local targetPlayer = exports.qbx_core:GetPlayerByCitizenId(citizenid) or exports.qbx_core:GetOfflinePlayer(citizenid)

            if targetPlayer and targetPlayer.PlayerData and targetPlayer.PlayerData.charinfo and targetPlayer.PlayerData.job then
                local charinfo = targetPlayer.PlayerData.charinfo
                local jobData = targetPlayer.PlayerData.job

                employees[#employees+1] = {
                    name = (charinfo.firstname or "??") .. " " .. (charinfo.lastname or ""),
                    id = citizenid,

                    gradeLabel = (jobData.grade and jobData.grade.name) or "??",
                    grade = gradeLevel,

                    canInteract = not (targetPlayer.PlayerData.job.isboss),

                    online = not targetPlayer.Offline
                }
            end
        end
    end

    -- DEBUG: Log employees before returning
    print("^3[LB-Tablet Server Debug] Returning " .. tostring(#employees) .. " employees")
    print("^3[LB-Tablet Server Debug] Employees: " .. json.encode(employees))

    return employees
end)

RegisterCallback("qbx:services:hireEmployee", function(source, playerId)
    local player = QB.Functions.GetPlayer(source)
    local target = QB.Functions.GetPlayer(playerId)

    if not player.PlayerData.job.isboss or not target then
        return false
    end

    local success = exports.qbx_core:AddPlayerToJob(target.PlayerData.citizenid, player.PlayerData.job.name, 0)

    if not success then
        return false
    end

    success = exports.qbx_core:SetPlayerPrimaryJob(target.PlayerData.citizenid, player.PlayerData.job.name)

    return success
end)

RegisterCallback("qbx:services:fireEmployee", function(source, citizenid)
    local player = QB.Functions.GetPlayer(source)

    if not player.PlayerData.job.isboss then
        return false
    end

    local success = exports.qbx_core:RemovePlayerFromJob(citizenid, player.PlayerData.job.name)

    return success
end)

RegisterCallback("qbx:services:setGrade", function(source, citizenid, newGrade)
    local player = QB.Functions.GetPlayer(source)

    if not player.PlayerData.job.isboss then
        return false
    end

    local success = exports.qbx_core:AddPlayerToJob(citizenid, player.PlayerData.job.name, newGrade)

    return success
end)
