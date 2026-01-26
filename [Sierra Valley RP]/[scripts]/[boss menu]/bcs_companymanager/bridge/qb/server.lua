local isQb, resourceName = Utils.CheckFramework("QB")
if not isQb then return end

-- Explicitly set Framework as global for Lua 5.4
_G.Framework = {}
Framework = _G.Framework

local query = {
    getAccount = 'SELECT money FROM players WHERE citizenid=?',
    updateAccount = 'UPDATE players SET money=? WHERE citizenid=?',
    selectGrade = "SELECT JSON_EXTRACT(job, '$.grade.level') AS grade_level FROM players WHERE citizenid = ?",
    selectGradeGang = "SELECT JSON_EXTRACT(gang, '$.grade.level') AS grade_level FROM players WHERE citizenid = ?",
    fireOffline = 'UPDATE players SET job = ? WHERE citizenid = ?',
    fireOfflineGang = 'UPDATE players SET gang = ? WHERE citizenid = ?',
    getName =
    "SELECT JSON_EXTRACT(charinfo, '$.firstname') AS firstname, JSON_EXTRACT(charinfo, '$.lastname') AS lastname FROM players WHERE citizenid = ?",
    getEmployees = "SELECT * FROM `players` WHERE JSON_EXTRACT(`job`, '$.name') = '%s'",
    getGangEmployees = "SELECT * FROM `players` WHERE JSON_EXTRACT(`gang`, '$.name') = '%s'"
}

local success, obj = pcall(function(...)
    local QB = exports[resourceName]:GetCoreObject()
    return QB
end)


if not success then
    Utils.DebugWarn('Failed to get core object from QBCORE')
    return
end

QB = obj


local function loadJobs()
    while not obj do
        Wait(100)
    end
    return QB.Shared.Jobs
end

local function loadGangs()
    while not obj do
        Wait(100)
    end
    return QB.Shared.Gangs
end

local function getFrameworkPlayer(fwPlayer)
    if not fwPlayer or not fwPlayer.PlayerData then
        return nil
    end

    local PlayerData = fwPlayer.PlayerData

    -- Safe access helpers
    local charinfo = PlayerData.charinfo or {}
    local jobData = PlayerData.job or {}
    local gangData = PlayerData.gang or {}
    local jobGrade = jobData.grade or {}
    local gangGrade = gangData.grade or {}
    local metadata = PlayerData.metadata or {}

    local self = {
        source = PlayerData.source,
        data = {
            name = ('%s %s'):format(charinfo.firstname or 'Unknown', charinfo.lastname or ''),
            identifier = PlayerData.citizenid or '',
            firstname = charinfo.firstname or 'Unknown',
            lastname = charinfo.lastname or '',
            job = {
                name = jobData.name or 'unemployed',
                label = jobData.label or 'Unemployed',
                grade = jobGrade.level or 0,
                grade_label = jobGrade.name or 'Unknown'
            },
            gang = {
                name = gangData.name or 'none',
                label = gangData.label or 'None',
                grade = gangGrade.level or 0,
                grade_label = gangGrade.name or 'Unknown'
            }
        },
        Functions = {}
    }

    function self.Functions.SetJob(job, grade)
        return fwPlayer.Functions.SetJob(job, grade)
    end

    function self.Functions.SetGang(gang, grade)
        return fwPlayer.Functions.SetGang(gang, grade)
    end

    function self.Functions.SetMetaData(key, val)
        return fwPlayer.Functions.SetMetaData(key, val)
    end

    function self.Functions.IsOnDuty()
        return jobData.onduty or false
    end

    function self.Functions.SetDuty(state)
        fwPlayer.Functions.SetJobDuty(state)
    end

    function self.Functions.GetMugshot()
        return metadata.mugshot or ""
    end

    function self.Functions.GetMoney(type)
        return fwPlayer.Functions.GetMoney(type)
    end

    function self.Functions.RemoveMoney(type, amount, reason)
        return fwPlayer.Functions.RemoveMoney(type, amount, reason)
    end

    function self.Functions.AddMoney(type, amount, reason)
        return fwPlayer.Functions.AddMoney(type, amount, reason)
    end

    return self
end

Jobs = {}
Gangs = {}

function Framework.RefreshJobs()
    local jobs = loadJobs()
    local newJobs = {}

    -- Safety check: ensure jobs is a valid table
    if not jobs or type(jobs) ~= 'table' then
        Utils.DebugWarn('[RefreshJobs] loadJobs() returned nil or invalid data')
        Jobs = {}
        return Jobs
    end

    for k, v in pairs(jobs) do
        if not newJobs[k] then
            newJobs[k] = {
                name = k,
                label = v.label or k,
                grades = {}
            }
        end

        -- Safety check: ensure grades exist
        if v.grades and type(v.grades) == 'table' then
            for a, b in pairs(v.grades) do
                newJobs[k].grades[tostring(a)] = {
                    label = b.name or 'Unknown',
                    salary = b.payment or 0,
                    grade = tonumber(a) or 0,
                    level = tonumber(a) or 0,
                    name = b.name or 'Unknown'
                }
            end
        end
    end
    Jobs = newJobs
    return Jobs
end

function Framework.RefreshGangs()
    local gangs = loadGangs()
    local newGangs = {}

    -- Safety check: ensure gangs is a valid table
    if not gangs or type(gangs) ~= 'table' then
        Utils.DebugWarn('[RefreshGangs] loadGangs() returned nil or invalid data')
        Gangs = {}
        return Gangs
    end

    for k, v in pairs(gangs) do
        if not newGangs[k] then
            newGangs[k] = {
                name = k,
                label = v.label or k,
                grades = {}
            }
        end

        -- Safety check: ensure grades exist
        if v.grades and type(v.grades) == 'table' then
            for a, b in pairs(v.grades) do
                newGangs[k].grades[tostring(a)] = {
                    label = b.name or 'Unknown',
                    grade = tonumber(a) or 0,
                    name = b.name or 'Unknown'
                }
            end
        end
    end
    Gangs = newGangs
    return Gangs
end

function Framework.RegisterUsableItem(name, cb)
    return obj.RegisterUsableItem(name, cb)
end

function Framework.GetPlayerFromId(source)
    if not source then return end
    local fwPlayer = obj.Functions.GetPlayer(source)
    if not fwPlayer then return end
    return getFrameworkPlayer(fwPlayer)
end

function Framework.GetPlayerFromIdentifier(identifier)
    local fwPlayer = obj.Functions.GetPlayerByCitizenId(identifier)
    if not fwPlayer then return end
    return getFrameworkPlayer(fwPlayer)
end

function Framework.GetFrameworkPlayers()
    local players = {}
    local fwPlayers = obj.Functions.GetQBPlayers()
    for _, fwPlayer in pairs(fwPlayers) do
        -- QBX Fix: Handle if fwPlayer is a source ID instead of player object
        if type(fwPlayer) == "number" then
            fwPlayer = obj.Functions.GetPlayer(fwPlayer)
        end
        if fwPlayer and fwPlayer.PlayerData then
            players[#players + 1] = Framework.GetPlayerFromId(fwPlayer.PlayerData.source)
        end
    end
    return players
end

function Framework.GetOfflineAccount(identifier)
    local result = MySQL.single.await(query.getAccount, { identifier })
    if not result then
        Utils.DebugPrint(('\27[31m[%s] ^0 GetOfflineAccount QB failed! player %s not found'):format(
            'GetOfflineAccount', identifier))
        return
    end
    return result and next(result) and json.decode(result.accounts)
end

function Framework.UpdateOfflineAccount(account, identifier)
    return MySQL.update.await(query.updateAccount, { json.encode(account), identifier })
end

function Framework.Demote(targetIdentifier, job, grade, sourceIdentifier)
    if Config.Multijob == "qbox" then
        exports.qbx_core:AddPlayerToJob(targetIdentifier, job, grade)
    elseif Config.Multijob == "core_multijob" then
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
    elseif Config.Multijob == 'randol_multijob' then
        MySQL.query.await(
            'INSERT INTO save_jobs (cid, job, grade) VALUES (@cid, @job, @grade) ON DUPLICATE KEY UPDATE job = @job, grade = @grade',
            {
                ['@cid'] = targetIdentifier,
                ['@job'] = job,
                ['@grade'] = grade
            })
    end
end

function Framework.Promote(targetIdentifier, job, grade, sourceIdentifier)
    if Config.Multijob == "qbox" then
        exports.qbx_core:AddPlayerToJob(targetIdentifier, job, grade)
    elseif Config.Multijob == "core_multijob" then
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
    elseif Config.Multijob == 'randol_multijob' then
        MySQL.query.await(
            'INSERT INTO save_jobs (cid, job, grade) VALUES (@cid, @job, @grade) ON DUPLICATE KEY UPDATE job = @job, grade = @grade',
            {
                ['@cid'] = targetIdentifier,
                ['@job'] = job,
                ['@grade'] = grade
            })
    end
end

function Framework.Fire(target, xPlayer, isGang, job)
    if Config.Multijob == "qbox" then
        if isGang then
            exports.qbx_core:RemovePlayerFromGang(target, job)
        else
            exports.qbx_core:RemovePlayerFromJob(target, job)
        end
    elseif Config.Multijob == "wasabi_multijob" then
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
    elseif Config.Multijob == "randol_multijob" then
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', { target, job })
    end
end

function Framework.FireOffline(target, xPlayer, isGang)
    if Config.Multijob == "qbox" then
        if isGang then
            exports.qbx_core:RemovePlayerFromGang(target, xPlayer.data.job.name)
        else
            exports.qbx_core:RemovePlayerFromJob(target, xPlayer.data.job.name)
        end
    
    elseif Config.Multijob == 'ps-multijob' and not isGang then
        query.selectGrade = Config.SQLQueries[Config.Framework][Config.Multijob].SelectOfflineGrade:format(xPlayer.data
            .job.name)
    end

    local targetGrade = MySQL.scalar.await(isGang and query.selectGradeGang or query.selectGrade, { target })
    if not targetGrade then
        return false
    end

    if tonumber(targetGrade) >= xPlayer.data[isGang and 'gang' or 'job'].grade then
        Utils.Notify(xPlayer.source, locale('company'), locale('grade_is_higher'), 'error', 3000)
        return false
    end

    local job = isGang and Gangs['none'] or Jobs['unemployed']

    local data = {
        isboss = false,
        grade = job and job.grades['0'] or {
            name = 'Freelancer',
            level = 0,
        },
        name = isGang and 'none' or 'unemployed',
        payment = job and job.payment or 10,
        type = 'none',
        label = job and job.label or 'Civilian'
    }

    Utils.Notify(xPlayer.source, locale("company"),
        locale("you_have_fired"), "error", 5000)
    local rowUpdated = MySQL.update.await(isGang and query.fireOfflineGang or query.fireOffline,
        { json.encode(data), target })
    if Config.Multijob == "ps-multijob" and not isGang then
        exports['ps-multijob']:RemoveJob(target, xPlayer.data.job.name)
        rowUpdated = true
    elseif Config.Multijob == "randol_multijob" then
        MySQL.query.await('DELETE FROM save_jobs WHERE cid = ? AND job = ?', { target, xPlayer.data.job.name })
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

    -- Safety check: ensure job is valid
    if not job or job == '' then
        Utils.DebugWarn('[GetEmployees] Invalid job parameter - returning empty array')
        return {}
    end

    local object = isGang and Gangs or Jobs

    -- Safety check: ensure object exists
    if not object then
        Utils.DebugWarn(('[GetEmployees] %s table is nil - returning empty array'):format(isGang and 'Gangs' or 'Jobs'))
        return {}
    end

    -- Determine the appropriate query based on job type and multijob configuration
    local q = isGang and query.getGangEmployees:format(job) or query.getEmployees:format(job)
    if Config.Multijob == "qbox" then
        if Config.SQLQueries[Config.Framework] and Config.SQLQueries[Config.Framework][Config.Multijob] then
            q = Config.SQLQueries[Config.Framework][Config.Multijob].GetEmployees:format(job)
        end
    elseif Config.Multijob == 'ps-multijob' then
        if Config.SQLQueries[Config.Framework] and Config.SQLQueries[Config.Framework][Config.Multijob] then
            q = Config.SQLQueries[Config.Framework][Config.Multijob].GetEmployees:format(job, job)
        end
    elseif Config.Multijob == 'randol_multijob' then
        if Config.SQLQueries[Config.Framework] and Config.SQLQueries[Config.Framework][Config.Multijob] then
            q = Config.SQLQueries[Config.Framework][Config.Multijob].GetEmployees:format(job)
        end
    end

    -- Fetch employee data from database
    if not q or type(q) ~= 'string' then
        Utils.DebugWarn(('Framework.GetEmployees QB - invalid query for job %s (multijob=%s, framework=%s)'):format(
            tostring(job), tostring(Config.Multijob), tostring(Config.Framework)))
        return {}
    end

    local ok, result = pcall(function()
        return MySQL.Sync.fetchAll(q, {})
    end)
    if not ok then
        Utils.DebugWarn(('Framework.GetEmployees QB - MySQL fetch failed for job %s: %s'):format(tostring(job), tostring(result)))
        result = {}
    end

    -- Safety check: ensure result is a table
    if not result or type(result) ~= 'table' then
        result = {}
    end

    local onlinePlayers = QB.Functions.GetQBPlayers() or {}

    if result then
        for _, v in ipairs(result) do
            local success, employeeData = pcall(function()
                -- Safely decode JSON data
                local jobData = type(v.job) == 'string' and json.decode(v.job) or v.job
                local gangData = type(v.gang) == 'string' and json.decode(v.gang) or v.gang
                local charinfo = type(v.charinfo) == 'string' and json.decode(v.charinfo) or v.charinfo
                local metadata = type(v.metadata) == 'string' and json.decode(v.metadata) or v.metadata

                -- Handle online players first
                local Player = Framework.GetPlayerFromIdentifier(v.citizenid)
                if Player then
                    local playerJob = isGang and Player.data.gang.name or Player.data.job.name
                    local playerGrade = isGang and Player.data.gang.grade or Player.data.job.grade

                    if playerJob == job then
                        return {
                            identifier = v.citizenid,
                            firstname = Player.data.firstname,
                            lastname = Player.data.lastname,
                            mugshot = Player.Functions.GetMugshot() or "",
                            grade = playerGrade,
                            grade_label = isGang and Player.data.gang.grade_label or Player.data.job.grade_label,
                            job_label = isGang and Player.data.gang.label or Player.data.job.label,
                        }
                    end
                end

                -- Helper function to safely get grade label
                local function safeGetGradeLabel(jobObj, gradeNum)
                    if not jobObj or not jobObj.grades then return 'Unknown' end
                    local gradeData = jobObj.grades[tostring(gradeNum)]
                    if not gradeData then return 'Unknown' end
                    return gradeData.label or gradeData.name or 'Unknown'
                end

                -- Handle multijob scenario
                if Config.Multijob == 'qbox' then
                    local qboxJobs = exports.qbx_core:GetJobs()
                    if qboxJobs and type(qboxJobs) == 'table' then
                        for jobName, data in pairs(qboxJobs) do
                            if jobName == job and object[jobName] then
                                return {
                                    identifier = v.citizenid,
                                    firstname = charinfo and charinfo.firstname or 'Unknown',
                                    lastname = charinfo and charinfo.lastname or '',
                                    mugshot = (metadata and metadata.mugshot) or "",
                                    grade = v.grade or 0,
                                    grade_label = safeGetGradeLabel(object[jobName], v.grade),
                                    job_label = object[jobName].label or job,
                                }
                            end
                        end
                    end
                elseif Config.Multijob == 'ps-multijob' and type(jobData) == 'table' then
                    for jobName, grade in pairs(jobData) do
                        if jobName == job and object[jobName] then
                            return {
                                identifier = v.citizenid,
                                firstname = charinfo and charinfo.firstname or 'Unknown',
                                lastname = charinfo and charinfo.lastname or '',
                                mugshot = (metadata and metadata.mugshot) or "",
                                grade = grade or 0,
                                grade_label = safeGetGradeLabel(object[jobName], grade),
                                job_label = object[jobName].label or job,
                            }
                        end
                    end
                elseif Config.Multijob == 'randol_multijob' and type(jobData) == 'table' then
                    local randolJob = QB.Shared.Jobs and QB.Shared.Jobs[jobData.job]
                    return {
                        identifier = v.citizenid,
                        firstname = charinfo and charinfo.firstname or 'Unknown',
                        lastname = charinfo and charinfo.lastname or '',
                        mugshot = (metadata and metadata.mugshot) or "",
                        grade = jobData.grade or 0,
                        grade_label = safeGetGradeLabel(randolJob, jobData.grade),
                        job_label = (randolJob and randolJob.label) or job,
                    }
                end

                -- Fallback for offline players
                if not Player then
                    local targetData = isGang and gangData or jobData
                    local gradeLevel = 0
                    local gradeName = 'Unknown'
                    local jobLabel = 'Unknown'

                    if targetData then
                        if targetData.grade then
                            gradeLevel = targetData.grade.level or 0
                            gradeName = targetData.grade.name or 'Unknown'
                        end
                        jobLabel = targetData.label or 'Unknown'
                    end

                    local data = {
                        identifier = v.citizenid,
                        firstname = charinfo and charinfo.firstname or 'Unknown',
                        lastname = charinfo and charinfo.lastname or '',
                        mugshot = (metadata and metadata.mugshot) or "",
                        grade = gradeLevel,
                        grade_label = gradeName,
                        job_label = jobLabel,
                    }
                    return data
                end
            end)

            -- Add to employees if data was successfully processed
            if success and employeeData then
                table.insert(employees, employeeData)
            else
                print(("Error processing employee %s: %s"):format(v.citizenid, tostring(employeeData)))
            end
        end
    end

    -- Add online players not in initial result
    for _, Player in pairs(onlinePlayers) do
        -- QBX Fix: Convert source ID to player object if needed
        if type(Player) == "number" then
            Player = QB.Functions.GetPlayer(Player)
        end
        if not Player or not Player.PlayerData then goto continue end

        local playerData = Player.PlayerData

        -- Safety checks for nested data
        local gangData = playerData.gang or {}
        local jobDataPD = playerData.job or {}
        local charinfoData = playerData.charinfo or {}
        local metadataData = playerData.metadata or {}

        local playerJob = isGang and (gangData.name or '') or (jobDataPD.name or '')
        local playerGrade = 0
        local playerGradeLabel = 'Unknown'
        local playerJobLabel = 'Unknown'

        if isGang then
            if gangData.grade then
                playerGrade = gangData.grade.level or 0
                playerGradeLabel = gangData.grade.name or 'Unknown'
            end
            playerJobLabel = gangData.label or 'Unknown'
        else
            if jobDataPD.grade then
                playerGrade = jobDataPD.grade.level or 0
                playerGradeLabel = jobDataPD.grade.name or 'Unknown'
            end
            playerJobLabel = jobDataPD.label or 'Unknown'
        end

        -- Check if player is in the job and not already in employees
        if playerJob == job and not Utils.IsInTable(employees, playerData.citizenid, 'identifier') then
            local employeeEntry = {
                identifier = playerData.citizenid,
                firstname = charinfoData.firstname or 'Unknown',
                lastname = charinfoData.lastname or '',
                mugshot = metadataData.mugshot or "",
                grade = playerGrade,
                grade_label = playerGradeLabel,
                job_label = playerJobLabel,
            }
            table.insert(employees, employeeEntry)
        end
        ::continue::
    end
    return employees
end

function Framework.CreateJob(source, playerJob, data)
    -- Add a new rank to the job
    if not Jobs[playerJob] then
        Utils.Notify(source, locale("company"), locale("rank_failed"), "error", 3000)
        return false
    end
    
    local gradeLevel = tonumber(data.grade)
    if Jobs[playerJob].grades[gradeLevel] then
        Utils.Notify(source, locale("company"), locale("rank_failed"), "error", 3000)
        return false
    end
    
    -- Create new grade
    Jobs[playerJob].grades[gradeLevel] = {
        name = data.name,
        payment = tonumber(data.salary) or 0
    }
    
    -- Update QBX Core shared data
    QB.Shared.Jobs[playerJob] = Jobs[playerJob]
    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', playerJob, Jobs[playerJob])
    
    Utils.Notify(source, locale("company"), locale("rank_added"), "success", 3000)
    Jobs = Framework.RefreshJobs()
    return true
end

function Framework.RemoveRank(source, data)
    -- Remove a rank from the job
    local playerJob = data.playerJob
    local gradeLevel = tonumber(data.grade)
    
    if not Jobs[playerJob] or not Jobs[playerJob].grades[gradeLevel] then
        Utils.Notify(source, locale("company"), locale("failed_delete_rank"), "error", 3000)
        return false
    end
    
    -- Remove the grade
    Jobs[playerJob].grades[gradeLevel] = nil
    
    -- Update QBX Core shared data
    QB.Shared.Jobs[playerJob] = Jobs[playerJob]
    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', playerJob, Jobs[playerJob])
    
    Jobs = Framework.RefreshJobs()
    return true
end

function Framework.SaveChanges(source, data)
    -- Save changes to existing ranks (salary/name updates)
    if not data or not data.job then
        Utils.Notify(source, locale("company"), locale("failed"), "error", 3000)
        return false
    end
    
    -- data.job is an array of modified jobs
    for _, jobData in pairs(data.job) do
        local playerJob = data.company.name
        if not Jobs[playerJob] then
            Utils.Notify(source, locale("company"), locale("failed"), "error", 3000)
            return false
        end
        
        local gradeLevel = tonumber(jobData.grade)
        local gradeData = data.company.grades[tostring(gradeLevel)]
        
        if Jobs[playerJob].grades[gradeLevel] and gradeData then
            -- Update grade name
            if gradeData.name then
                Jobs[playerJob].grades[gradeLevel].name = gradeData.name
            end
            -- Update grade salary
            if gradeData.salary then
                Jobs[playerJob].grades[gradeLevel].payment = tonumber(gradeData.salary)
            end
        end
    end
    
    -- Update QBX Core shared data
    local playerJob = data.company.name
    QB.Shared.Jobs[playerJob] = Jobs[playerJob]
    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Jobs', playerJob, Jobs[playerJob])
    
    Utils.Notify(source, locale("company"), locale("success_saved_rank"), "success", 3000)
    Jobs = Framework.RefreshJobs()
    return true
end

function Framework.Initializes()
    Jobs = Framework.RefreshJobs()
    Gangs = Framework.RefreshGangs()

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

AddEventHandler("QBCore:Server:OnJobUpdate", function(source, job)
    local Player = Framework.GetPlayerFromId(source)
    if not Player then return end
    if job.onduty then
        Duty.Start(job.name, Player.data.identifier, Player.data.name)
    else
        Duty.End(source, job.name, Player.data.identifier)
    end
end)

AddEventHandler("QBCore:Server:PlayerLoaded", function(FwPlayer, isNew)
    local xPlayer = Framework.GetPlayerFromId(FwPlayer.PlayerData.source)
    if not xPlayer then return end
    Player(xPlayer.source).state:set('name', xPlayer.data.name, true)
    if xPlayer.Functions.IsOnDuty() then
        Duty.Init(xPlayer)
    end
end)

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
    JSON_UNQUOTE(JSON_EXTRACT(u.charinfo, '$.firstname')) as firstname,
    JSON_UNQUOTE(JSON_EXTRACT(u.charinfo, '$.lastname')) as lastname,
    JSON_UNQUOTE(JSON_EXTRACT(issuer_user.charinfo, '$.firstname')) AS issuer_firstname,
    JSON_UNQUOTE(JSON_EXTRACT(issuer_user.charinfo, '$.lastname')) AS issuer_lastname
FROM ]] .. Config.Database.Bill .. [[ b
LEFT JOIN
    players u ON b.identifier = u.citizenid
LEFT JOIN
    players issuer_user ON b.issuer = issuer_user.citizenid
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
    JSON_UNQUOTE(JSON_EXTRACT(u.charinfo, '$.firstname')) as firstname,
    JSON_UNQUOTE(JSON_EXTRACT(u.charinfo, '$.lastname')) as lastname,
    JSON_UNQUOTE(JSON_EXTRACT(issuer_user.charinfo, '$.firstname')) AS issuer_firstname,
    JSON_UNQUOTE(JSON_EXTRACT(issuer_user.charinfo, '$.lastname')) AS issuer_lastname
FROM ]] .. Config.Database.Bill .. [[ b
LEFT JOIN
    players u ON b.identifier = u.citizenid
LEFT JOIN
    players issuer_user ON b.issuer = issuer_user.citizenid
WHERE b.id = ?]]

Config.SQLQueries[framework]['ps-multijob'] = {
    GetEmployees =
    "SELECT m.citizenid, m.jobdata AS job, p.charinfo, p.gang, p.metadata FROM `multijobs` m JOIN players p ON p.citizenid = m.citizenid WHERE m.jobdata LIKE '%%%s%%' or JSON_EXTRACT(`job`, '$.name') = '%s'",
    SelectOfflineGrade =
    "SELECT JSON_UNQUOTE(JSON_EXTRACT(jobdata, '$.%s')) AS grade_level FROM multijobs WHERE citizenid = ?"
}

Config.SQLQueries[framework]['randol_multijob'] = {
    GetEmployees =
    "SELECT m.cid, m.job, m.grade, p.charinfo, p.gang, p.metadata FROM `save_jobs` m JOIN players p ON p.citizenid = m.cid WHERE m.job = '%s'",
}

Config.SQLQueries[framework]['qbox'] = {
    GetEmployees = "SELECT m.citizenid, m.group AS job, m.grade, p.charinfo, p.gang, p.metadata FROM `player_groups` m JOIN players p ON p.citizenid = m.citizenid WHERE m.group = '%s' AND m.type = 'job'"
}
