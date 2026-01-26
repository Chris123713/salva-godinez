local isESX, resourceName = Utils.CheckFramework("ESX")
if not isESX then return end

-- Explicitly set Framework as global for Lua 5.4
_G.Framework = {}
Framework = _G.Framework

local query = {
    getAccount = 'SELECT accounts FROM users WHERE identifier = ?',
    updateAccount = 'UPDATE users SET accounts = ? WHERE identifier = ?',
    selectGrade = 'SELECT job_grade FROM users WHERE identifier = ?',
    selectGradeGang = "SELECT JSON_EXTRACT(gang, '$.grade.level') AS grade_level FROM players WHERE citizenid = ?",
    fireOffline = 'UPDATE users SET job = "unemployed", job_grade = 0 WHERE identifier = ?',
    fireOfflineGang = 'UPDATE players SET gang = ? WHERE citizenid = ?',
    getName = 'SELECT firstname, lastname FROM users WHERE identifier = ?',
    selectJobName = 'SELECT name FROM jobs WHERE name=?',
    insertToJobs = 'INSERT INTO jobs (name, label) VALUES (?,?)',
    gradeExist = 'SELECT name FROM job_grades WHERE job_name= ? AND grade = ?',
    insertNewJobs =
    "INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, '{}', '{}')",
    deleteRank = "DELETE FROM job_grades WHERE job_name = ? AND name = ? AND grade = ?",
    editRank = "UPDATE job_grades SET label = ?, salary = ? WHERE job_name = ? AND grade = ?",
}

local success, obj = pcall(function(...)
    local ESX = exports[resourceName]:getSharedObject()
    return ESX
end)


if not success then
    Utils.DebugWarn('Failed to get shared object from ESX')
    return
end

ESX = obj


Config.DutyPrefix = not lib.checkDependency("es_extended", "1.12.4")


local function loadJobs()
    while not obj do
        Wait(100)
    end
    while not obj.RefreshJobs do
        Wait(100)
    end
    obj.RefreshJobs()
    return obj.GetJobs()
end

local function getFrameworkPlayer(fwPlayer)
    local self = {
        source = fwPlayer.source,
        data = {
            name = fwPlayer.getName(),
            identifier = fwPlayer.identifier,
            firstname = fwPlayer.get('firstName'),
            lastname = fwPlayer.get('lastName'),
            job = {
                name = fwPlayer.job.name,
                label = fwPlayer.job.label,
                grade = fwPlayer.job.grade,
                grade_label = fwPlayer.job?.grade_label
            }
        },
        Functions = {}
    }

    if fwPlayer.gang then
        fwPlayer.data.gang = {
            name = fwPlayer.gang.name,
            label = fwPlayer.gang.label,
            grade = fwPlayer.gang.grade,
            grade_label = fwPlayer.gang?.grade_label
        }
    end

    function self.Functions.SetJob(job, grade)
        return fwPlayer.setJob(job, grade)
    end

    function self.Functions.SetGang(gang, grade)
        if not fwPlayer.gang then
            Utils.DebugWarn('Your Framework Doesn\'t have setGang in classes/player.lua')
            return
        end

        return fwPlayer.setGang(gang, grade)
    end

    function self.Functions.SetMetaData(key, val)
        if key == "mugshot" then
            if fwPlayer.setMugshot then
                return fwPlayer.setMugshot(val)
            end
        end
        return fwPlayer.setMeta(key, val)
    end

    function self.Functions.IsOnDuty(job)
        if not Config.DutyPrefix then
            return fwPlayer.job.onDuty
        end

        if job then
            return fwPlayer.job.name == job
        else
            local duty = string.find(fwPlayer.job.name, Config.OffJobPrefix)
            return not duty
        end
    end

    function self.Functions.SetDuty(state)
        if Config.DutyPrefix then
            local job = state and string.gsub(fwPlayer.job.name, Config.OffJobPrefix, "") or
                Config.OffJobPrefix .. fwPlayer.job.name
            fwPlayer.setJob(job, fwPlayer.job.grade)
        else
            fwPlayer.setJob(fwPlayer.job.name, fwPlayer.job.grade, state)
        end
    end

    function self.Functions.GetMugshot()
        return fwPlayer.mugshot or fwPlayer.metadata?.mugshot
    end

    function self.Functions.GetMoney(type)
        return fwPlayer.getAccount(type)?.money
    end

    function self.Functions.RemoveMoney(type, amount, reason)
        return fwPlayer.removeAccountMoney(type, amount, reason)
    end

    function self.Functions.AddMoney(type, amount, reason)
        return fwPlayer.addAccountMoney(type, amount, reason)
    end

    return self
end

Jobs = {}

function Framework.AddOffDutyJobs(job, grade_label, grade_name, grade)
    if Config.Duty[job] then
        local offDutyJob = Config.OffJobPrefix .. job
        local result = MySQL.query.await(query.selectJobName, { offDutyJob })
        if not result or not result[1] then
            local offDuty = MySQL.insert.await(query.insertToJobs,
                { offDutyJob, locale('offduty') })
        end
        local gradeExist = MySQL.single.await(query.gradeExist,
            { offDutyJob, grade })
        if not gradeExist then
            local offDutyRows = MySQL.insert.await(
                query.insertNewJobs,
                {
                    offDutyJob,
                    grade,
                    grade_name,
                    grade_label,
                    0,
                }
            )
        end
    end
end

function Framework.RefreshJobs()
    local jobs = loadJobs()
    local newJobs = {}
    for k, v in pairs(jobs) do
        if not newJobs[v.name] then
            newJobs[v.name] = {
                name = v.name,
                label = v.label,
                grades = {}
            }
        end

        for a, b in pairs(v.grades) do
            newJobs[tostring(v.name)].grades[tostring(b.grade)] = {
                label = b.label,
                salary = b.salary,
                grade = b.grade,
                name = b.name
            }

            if Config.DutyPrefix then
                Framework.AddOffDutyJobs(v.name, b.label, b.name, b.grade)
            end
        end
    end
    Jobs = newJobs
    return Jobs
end

function Framework.RegisterUsableItem(name, cb)
    return obj.RegisterUsableItem(name, cb)
end

function Framework.GetPlayerFromId(source)
    if not source then return end
    local fwPlayer = obj.GetPlayerFromId(source)
    if not fwPlayer then return end
    return getFrameworkPlayer(fwPlayer)
end

function Framework.GetPlayerFromIdentifier(identifier)
    local fwPlayer = obj.GetPlayerFromIdentifier(identifier)
    if not fwPlayer then return end
    return getFrameworkPlayer(fwPlayer)
end

function Framework.GetFrameworkPlayers()
    local players = {}
    local fwPlayers = obj.GetExtendedPlayers()
    for _, fwPlayer in pairs(fwPlayers) do
        players[#players + 1] = Framework.GetPlayerFromId(fwPlayer.source)
    end
    return players
end

function Framework.GetOfflineAccount(identifier)
    local result = MySQL.single.await(query.getAccount, { identifier })
    if not result then
        Utils.DebugPrint(('\27[31m[%s] ^0 GetOfflineAccount ESX failed! player %s not found'):format(
            'GetOfflineAccount', identifier))
        return
    end
    return result and next(result) and json.decode(result.accounts)
end

function Framework.UpdateOfflineAccount(account, identifier)
    return MySQL.update.await(query.updateAccount, { json.encode(account), identifier })
end

function Framework.Demote(targetIdentifier, job, grade, sourceIdentifier)
    if Config.Multijob == "core_multijob" then
        MySQL.update.await(
            "UPDATE `user_jobs` SET grade=@newgrade WHERE identifier=@identifier AND job = @job AND grade = @grade",
            {
                ["@identifier"] = targetIdentifier,
                ["@job"] = job,
                ["@grade"] = grade + 1,
                ["@newgrade"] = grade,
            }
        )
        MySQL.update.await(
            "UPDATE `user_jobs` SET grade=@newgrade WHERE identifier=@identifier AND job = @job AND grade = @grade",
            {
                ["@identifier"] = targetIdentifier,
                ["@job"] = Config.OffJobPrefix .. job,
                ["@grade"] = grade + 1,
                ["@newgrade"] = grade,
            }
        )
    elseif Config.Multijob == "wasabi_multijob" then
        if Config.Framework == 'ESX' then
            local xPlayer = Framework.GetPlayerFromIdentifier(targetIdentifier)
            if xPlayer then
                xPlayer.Functions.SetJob(job, grade)
            else
                local response = MySQL.query.await('SELECT * FROM users WHERE identifier = ? AND job =?', {
                    targetIdentifier, job
                })
                if response then
                    MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier =?', {
                        job, grade, targetIdentifier
                    }, function(affectedRows) end)
                end
            end
        end
        MySQL.update.await(
            "UPDATE wasabi_multijob SET grade = ? WHERE identifier = ? AND job = ?",
            { grade, targetIdentifier, job }
        )
    elseif Config.Multijob == 'ps-multijob' then
        exports['ps-multijob']:AddJob(targetIdentifier, job, grade)
    elseif Config.Multijob == 'cs_multijob' then
        TriggerEvent('cs:multijob:addjob', targetIdentifier, job, grade)
    end
end

function Framework.Promote(targetIdentifier, job, grade, sourceIdentifier)
    if Config.Multijob == "core_multijob" then
        MySQL.update.await(
            "UPDATE `user_jobs` SET grade=@newgrade WHERE identifier=@identifier AND job = @job AND grade = @grade",
            {
                ["@identifier"] = targetIdentifier,
                ["@job"] = job,
                ["@grade"] = grade - 1,
                ["@newgrade"] = grade,
            }
        )
        MySQL.update.await(
            "UPDATE `user_jobs` SET grade=@newgrade WHERE identifier=@identifier AND job = @job AND grade = @grade",
            {
                ["@identifier"] = targetIdentifier,
                ["@job"] = Config.OffJobPrefix .. job,
                ["@grade"] = grade - 1,
                ["@newgrade"] = grade,
            }
        )
    elseif Config.Multijob == "wasabi_multijob" then
        if Config.Framework == 'ESX' then
            local xPlayer = Framework.GetPlayerFromIdentifier(targetIdentifier)
            if xPlayer then
                xPlayer.Functions.SetJob(job, grade)
            else
                local response = MySQL.query.await('SELECT * FROM users WHERE identifier = ? AND job =?', {
                    targetIdentifier, job
                })
                if response then
                    MySQL.update('UPDATE users SET job = ?, job_grade = ? WHERE identifier =?', {
                        job, grade, targetIdentifier
                    }, function(affectedRows) end)
                end
            end
        end
        MySQL.update(
            "UPDATE wasabi_multijob SET grade = ? WHERE identifier = ? AND job = ?",
            { grade, targetIdentifier, job }
        )
    elseif Config.Multijob == 'ps-multijob' then
        exports['ps-multijob']:AddJob(targetIdentifier, job, grade)
    elseif Config.Multijob == 'cs_multijob' then
        TriggerEvent('cs:multijob:updateJob', targetIdentifier, job, grade)
    end
end

function Framework.Fire(target, xPlayer, isGang, job)
    if Config.Multijob == "wasabi_multijob" then
        local q = MySQL.single.await('SELECT job FROM wasabi_multijob WHERE identifier = ? AND job = ?', { target, job })
        if not q then return end
        if q.job ~= job then return end
        MySQL.query.await('DELETE FROM wasabi_multijob WHERE identifier = ? AND job = ?', { target, job })
    elseif Config.Multijob == "ps-multijob" then
        exports['ps-multijob']:RemoveJob(target, job)
    elseif Config.Multijob == "cs_multijob" then
        TriggerEvent('cs:multijob:removeJob', target, job)
    elseif Config.Multijob == "core_multijob" then
        local q = MySQL.single.await('SELECT job FROM user_jobs WHERE identifier = ? AND job = ?', { target, job })
        if not q then return end
        MySQL.query.await('DELETE FROM user_jobs WHERE identifier = ? AND job = ?', { target, job })
    end
end

function Framework.FireOffline(target, xPlayer, isGang)
    local targetGrade = MySQL.scalar.await(query.selectGrade, { target })
    if not targetGrade then
        return false
    end

    if targetGrade >= xPlayer.data.job.grade then
        Utils.Notify(xPlayer.source, locale('company'), locale('grade_is_higher'), 'error', 3000)
        return false
    end

    Utils.Notify(xPlayer.source, locale("company"),
        locale("you_have_fired"), "error", 5000)
    local rowUpdated = MySQL.update.await(query.fireOffline, { target })
    local job = xPlayer.data.job.name
    if Config.Multijob == "wasabi_multijob" then
        local q = MySQL.single.await('SELECT job FROM wasabi_multijob WHERE identifier = ? AND job = ?', { target, job })
        if q and q.job == job then
            MySQL.query.await('DELETE FROM wasabi_multijob WHERE identifier = ? AND job = ?', { target, job })
        end
    elseif Config.Multijob == "ps-multijob" then
        exports['ps-multijob']:RemoveJob(target, job)
    elseif Config.Multijob == "cs_multijob" then
        TriggerEvent('cs:multijob:removeJob', target, job)
    elseif Config.Multijob == "core_multijob" then
        local q = MySQL.single.await('SELECT job FROM user_jobs WHERE identifier = ? AND job = ?', { target, job })
        if q then
            MySQL.query.await('DELETE FROM user_jobs WHERE identifier = ? AND job = ?', { target, job })
        end
    end

    return rowUpdated and true
end

function Framework.GetOfflineJobGrade(identifier)
    local result = MySQL.scalar.await(query.selectGrade, {
        identifier
    })
    return result or 0
end

function Framework.GetOfflineName(identifier)
    local result = MySQL.scalar.await(query.getName, {
        identifier
    })
    return result and ('%s %s'):format(result.firstname, result.lastname) or 'Unknown'
end

function Framework.GetEmployees(job, isGang)
    local employees = {}
    local q = Config.SQLQueries[Config.Framework].GetEmployees

    -- Multijob query
    if Config.Multijob then
        q = Config.SQLQueries[Config.Framework][Config.Multijob].GetEmployees
    end

    if not q or type(q) ~= 'string' then
        Utils.DebugWarn(('Framework.GetEmployees ESX - invalid query for job %s (multijob=%s, framework=%s)'):format(
            tostring(job), tostring(Config.Multijob), tostring(Config.Framework)))
        return {}
    end

    local ok, result = pcall(function()
        return MySQL.Sync.fetchAll(q, { ["@job"] = job, ["@offjob"] = Config.OffJobPrefix .. job })
    end)
    if not ok then
        Utils.DebugWarn(('Framework.GetEmployees ESX - MySQL fetch failed for job %s: %s'):format(tostring(job), tostring(result)))
        result = {}
    end
    local onlinePlayers = obj.GetExtendedPlayers('job', job)
    -- Incase of a new player set to the job that has not been saved within database
    for _, xPlayer in pairs(onlinePlayers) do
        local playerJob = string.gsub(xPlayer.job.name, Config.OffJobPrefix, "")
        if playerJob == job and not Utils.IsInTable(employees, xPlayer.identifier, 'identifier') then
            if Jobs[playerJob] and Jobs[playerJob].grades[tostring(xPlayer.job.grade)] then
                employees[#employees + 1] = {
                    identifier = xPlayer.identifier,
                    firstname = xPlayer.get('firstName') or xPlayer.getName(),
                    lastname = xPlayer.get('lastName') or "",
                    mugshot = Config.Mugshot and (xPlayer.mugshot or xPlayer.metadata?.mugshot) or "",
                    grade = xPlayer.job.grade,
                    grade_label = Jobs[playerJob].grades[tostring(xPlayer.job.grade)].label,
                    job_label = xPlayer.job.label,
                }
            else
                print(("In Game User %s (ID: %s) has a job or job grade that does not exist!"):format(
                    xPlayer.identifier, xPlayer.source))
            end
        end
    end

    if result then
        for i = 1, #result do
            local v = result[i]
            -- Multijob set job_grade
            if Config.Multijob == "core_multijob" or Config.Multijob == 'wasabi_multijob' or Config.Multijob == 'cs_multijob' then
                v.job_grade = v.grade
            end

            if Jobs[v.job] and Jobs[v.job].grades[tostring(v.job_grade)] then
                if not Utils.IsInTable(employees, v.identifier, 'identifier') then
                    employees[#employees + 1] = {
                        identifier = v.identifier,
                        firstname = v.firstname,
                        lastname = v.lastname,
                        mugshot = json.decode(v.mugshot) or "",
                        grade = v.job_grade,
                        grade_label = Jobs[v.job].grades[tostring(v.job_grade)].label,
                        job_label = Jobs[v.job].label,
                    }
                end
            else
                print(("User %s has a job (%s) and job grade (%s) that does not exist!"):format(v.identifier, v.job,
                    v.job_grade))
            end
        end
    end
    return employees
end

function Framework.CreateJob(source, playerJob, data)
    local rowId = MySQL.insert.await(
        query.insertNewJobs,
        {
            playerJob,
            data.grade,
            data.name,
            data.label,
            data.salary,
        }
    )
    if Config.DutyPrefix then
        Framework.AddOffDutyJobs(playerJob, data.label, data.name, data.grade)
    end
    if rowId then
        local companyGrade = Core.GetCompany(playerJob).grades
        companyGrade[#companyGrade + 1] = {
            job_name = playerJob,
            grade = data.grade,
            name = data.name,
            label = data.label,
            salary = data.salary,
            skin_male = {},
            skin_female = {},
        }
        Utils.Notify(source, locale("company"), locale("rank_added"),
            "success", 3000)
    else
        Utils.Notify(source, locale("company"), locale("rank_failed"),
            "error", 3000)
    end
    Jobs = Framework.RefreshJobs()
end

function Framework.RemoveRank(source, data)
    if Config.Duty[data.playerJob] and Config.DutyPrefix then
        MySQL.update.await(query.deleteRank, { Config.OffJobPrefix .. data.playerJob, data.jobName, data.jobGrade })
    end
    local affectedRows = MySQL.update.await(query.deleteRank, { data.playerJob, data.jobName, data.jobGrade })
    local deleted = affectedRows > 0
    if deleted then
        Jobs[data.playerJob].grades[tostring(data.grade)] = nil
    end
    return deleted
end

function Framework.SaveChanges(source, data)
    for _, job in pairs(data.job) do
        local jobGrade = data.company.grades[tostring(job.grade)]
        if jobGrade then
            if
                (not Config.bossmenu[data.playerJob].maxSalary
                    or (Config.bossmenu[data.playerJob].maxSalary >= job.salary)) and data.editSalary
            then
                jobGrade.salary = job.salary
            end
            if data.editRank then
                jobGrade.label = job.label
            end
            MySQL.update(
                query.editRank,
                {
                    jobGrade.label,
                    jobGrade.salary,
                    data.playerJob,
                    job.grade,
                }
            )
        end
    end
    ESX.RefreshJobs()
    Jobs = Framework.RefreshJobs()
    return true
end

function Framework.Initializes()
    Jobs = Framework.RefreshJobs()
    for job in pairs(Jobs) do
        if Config.bossmenu[job] or (Config.Tax.Enable and Config.Tax.Job == job) then
            Companies[#Companies + 1] = Company:new(job, false)
        end
    end

    for gang in pairs(Gangs) do
        if Config.gangs[gang] then
            Companies[#Companies + 1] = Company:new(gang, true)
        end
    end
    FrameworkLoaded = true
    Duty.GetDuty()
end

AddEventHandler('esx:setJob', function(playerId, job, lastJob)
    if job.name == "unemployed" then return end
    local xPlayer = Framework.GetPlayerFromId(playerId)
    if not xPlayer then return end
    if Config.DutyPrefix and job.name:match('^' .. Config.OffJobPrefix) ~= Config.OffJobPrefix then
        Duty.Init(xPlayer)
    elseif not Config.DutyPrefix and xPlayer.Functions.IsOnDuty(job.name) and lastJob.name ~= job.name then
        Duty.Init(xPlayer)
    end

    if Config.DutyPrefix and lastJob then
        Duty.End(playerId, lastJob.name, xPlayer?.data?.identifier)
    elseif not Config.DutyPrefix and xPlayer.Functions.IsOnDuty(lastJob.name) and lastJob.name ~= job.name then
        Duty.End(playerId, lastJob.name, xPlayer?.data?.identifier)
    end
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local Player = Framework.GetPlayerFromId(playerId)
    if Player?.Functions.IsOnDuty(xPlayer) then
        Duty.Init(Player)
    end
end)

--------------------------------------
-- ESX BILLING BACKWARDS COMPATIBILITY
--------------------------------------
RegisterNetEvent("esx_billing:sendBill", function(target, society, description, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    local identifier = xPlayer.identifier
    if society ~= "" then
        identifier = society
        society = string.gsub(society, "society_", "")
    end
    local from = {
        name = society ~= "" and society or "",
        label = society ~= "" and Jobs[society].label or "",
        job = society ~= "" and society or xPlayer.job.name,
        identifier = identifier,
    }
    Billing.Create(xPlayer.source, target, amount, description, nil, from)
end)

ESX.RegisterServerCallback("esx_billing:getTargetBills", function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)

    if xPlayer then
        MySQL.query(
            "SELECT price, id, label FROM "
            .. Config.Database.Bill
            .. ' WHERE identifier = ? AND `status`="unpaid"',
            { xPlayer.identifier },
            function(result)
                local bills = {}
                for i = 1, #result, 1 do
                    table.insert(bills, {
                        id = result[i].id,
                        label = result[i].description,
                        amount = result[i].price,
                    })
                end
                cb(bills)
            end
        )
    else
        cb({})
    end
end)

ESX.RegisterServerCallback("esx_billing:payBill", function(source, cb, invoiceId)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll(
        "SELECT * FROM " .. Config.Database.Bill .. " WHERE id=@id",
        { ["@id"] = invoiceId },
        function(result)
            for _, v in pairs(result) do
                Billing.PayBill(invoiceId, v.price, v.company, v.biller_id, xPlayer)
            end
            cb()
        end
    )
end)
--------------------------------------
-- END ESX BILLING BACKWARDS COMPATIBILITY
--------------------------------------

local framework = Config.Framework

Config.SQLQueries[framework] = {}
Config.SQLQueries[framework].GetBills = [[
    SELECT
    b.id,
    b.identifier,
    b.company,
    b.price,
    UNIX_TIMESTAMP(b.created) as created,
    UNIX_TIMESTAMP(b.deadline) as deadline,
    b.`description`,
    b.`status`,
    b.issuer,
    b.`items`,
    u.firstname,
    u.lastname,
    issuer_user.firstname AS issuer_firstname,
    issuer_user.lastname AS issuer_lastname
FROM ]] .. Config.Database.Bill .. [[ b
LEFT JOIN
    users u ON b.identifier = u.identifier
LEFT JOIN
    users issuer_user ON b.issuer = issuer_user.identifier
WHERE ]]

Config.SQLQueries[framework].GetBill = [[
    SELECT
    b.id,
    b.identifier,
    b.company,
    b.price,
    UNIX_TIMESTAMP(b.created) as created,
    UNIX_TIMESTAMP(b.deadline) as deadline,
    b.`description`,
    b.`status`,
    b.issuer,
    b.`items`,
    u.firstname,
    u.lastname,
    issuer_user.firstname AS issuer_firstname,
    issuer_user.lastname AS issuer_lastname
FROM ]] .. Config.Database.Bill .. [[ b
LEFT JOIN
    users u ON b.identifier = u.identifier
LEFT JOIN
    users issuer_user ON b.issuer = issuer_user.identifier
WHERE b.id = ?]]


Config.SQLQueries[framework].GetEmployees =
    "SELECT identifier, firstname, lastname, job, job_grade" ..
    (Config.Mugshot and ', JSON_EXTRACT(metadata, "$.mugshot") as mugshot' or '') ..
    " FROM users WHERE job LIKE @job or job LIKE @offjob"

Config.SQLQueries[framework]['core_multijob'] = {
    GetEmployees = [[SELECT j.identifier, j.job, j.grade, u.firstname, u.lastname]] ..
        (Config.Mugshot and ', JSON_EXTRACT(u.metadata, "$.mugshot") as mugshot' or '') .. [[ FROM user_jobs j
			LEFT JOIN users u ON j.identifier = u.identifier
			WHERE j.job LIKE @job or j.job LIKE @offjob]]
}

Config.SQLQueries[framework]['wasabi_multijob'] = {
    GetEmployees = "SELECT w.identifier, w.job, w.grade, u.firstname, u.lastname" ..
        (Config.Mugshot and ', JSON_EXTRACT(u.metadata, "$.mugshot") as mugshot' or '')
        ..
        " FROM wasabi_multijob w JOIN users u ON w.identifier = u.identifier WHERE w.job LIKE @job or w.job LIKE @offjob"
}

Config.SQLQueries[framework]['cs_multijob'] = {
    GetEmployees = "SELECT c.identifier, c.job, c.grade, u.firstname, u.lastname" ..
        (Config.Mugshot and ', JSON_EXTRACT(u.metadata, "$.mugshot") as mugshot' or '')
        ..
        " FROM player_multijob c JOIN users u ON c.identifier = u.identifier WHERE c.job LIKE @job or c.job LIKE @offjob"
}
