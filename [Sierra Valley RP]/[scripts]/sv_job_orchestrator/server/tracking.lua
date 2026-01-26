-- Server-side worker tracking module for sv_job_orchestrator
-- Tracks active workers per job type in real-time

local resourceName = GetCurrentResourceName()

-- Session state: tracks all active workers by job type
---@type table<string, table<number, boolean>> JobType -> { [source] = true }
SessionState = {
    workers = {},       -- { jobType = { [source] = true } }
    lastUpdate = 0,
}

-- Initialize worker tracking for all configured jobs
for jobKey, _ in pairs(Config.Jobs) do
    SessionState.workers[jobKey] = {}
end

---Get the number of active workers for a job type
---@param jobType string The job type key (e.g., 'mining', 'taxi')
---@return number count Number of active workers
function GetActiveWorkers(jobType)
    if not SessionState.workers[jobType] then
        return 0
    end
    local count = 0
    for _ in pairs(SessionState.workers[jobType]) do
        count = count + 1
    end
    return count
end

---Get all active worker counts
---@return table<string, number> Worker counts by job type
function GetAllWorkerCounts()
    local counts = {}
    for jobKey, _ in pairs(Config.Jobs) do
        counts[jobKey] = GetActiveWorkers(jobKey)
    end
    return counts
end

---Add a worker to tracking
---@param source number Player source
---@param jobType string The job type key
local function AddWorker(source, jobType)
    if not SessionState.workers[jobType] then
        SessionState.workers[jobType] = {}
    end
    if not SessionState.workers[jobType][source] then
        SessionState.workers[jobType][source] = true
        SessionState.lastUpdate = os.time()
        TriggerEvent('sv_job_orchestrator:workerCountChanged', jobType, GetActiveWorkers(jobType))
    end
end

---Remove a worker from tracking
---@param source number Player source
---@param jobType string The job type key (optional - removes from all if nil)
local function RemoveWorker(source, jobType)
    if jobType then
        if SessionState.workers[jobType] and SessionState.workers[jobType][source] then
            SessionState.workers[jobType][source] = nil
            SessionState.lastUpdate = os.time()
            TriggerEvent('sv_job_orchestrator:workerCountChanged', jobType, GetActiveWorkers(jobType))
        end
    else
        -- Remove from all jobs
        for key, workers in pairs(SessionState.workers) do
            if workers[source] then
                workers[source] = nil
                SessionState.lastUpdate = os.time()
                TriggerEvent('sv_job_orchestrator:workerCountChanged', key, GetActiveWorkers(key))
            end
        end
    end
end

---Update worker tracking when job changes
---@param source number Player source
---@param newJobName string New job name
local function UpdateWorkerJob(source, newJobName)
    -- Find the config key for this job name
    local newJobKey = Config.JobNameLookup[newJobName]

    -- Remove from all current jobs
    RemoveWorker(source)

    -- Add to new job if it's tracked
    if newJobKey and Config.Jobs[newJobKey] and Config.Jobs[newJobKey].tracked then
        AddWorker(source, newJobKey)
    end
end

-- Listen for job updates from qbx_core
AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    if not job or not job.name then return end
    UpdateWorkerJob(source, job.name)
end)

-- Alternative event name (compatibility)
AddEventHandler('qbx_core:server:onJobUpdate', function(source, job)
    if not job or not job.name then return end
    UpdateWorkerJob(source, job.name)
end)

-- Handle player joining - check their current job
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local source = player.PlayerData.source
    local job = player.PlayerData.job
    if job and job.name then
        UpdateWorkerJob(source, job.name)
    end
end)

-- Alternative event name (compatibility)
AddEventHandler('qbx_core:server:playerLoaded', function(player)
    local source = player.PlayerData.source
    local job = player.PlayerData.job
    if job and job.name then
        UpdateWorkerJob(source, job.name)
    end
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    RemoveWorker(source)
end)

-- Initialize tracking for all online players on resource start
CreateThread(function()
    Wait(2000) -- Wait for qbx_core to be ready

    local players = exports.qbx_core:GetQBPlayers()
    if players then
        for _, player in pairs(players) do
            if player and player.PlayerData then
                local source = player.PlayerData.source
                local job = player.PlayerData.job
                if job and job.name then
                    UpdateWorkerJob(source, job.name)
                end
            end
        end
    end

    print('^2[' .. resourceName .. ']^7 Worker tracking initialized')
end)

-- Periodic DUI broadcast
CreateThread(function()
    while true do
        Wait(Config.DUIUpdateInterval or 5000)
        BroadcastDUIUpdate()
    end
end)

---Broadcast current job market state to all clients for DUI
function BroadcastDUIUpdate()
    local workerCounts = GetAllWorkerCounts()
    local multipliers = GetAllMultipliers() -- From pricing.lua

    local jobData = {}
    for jobKey, jobConfig in pairs(Config.Jobs) do
        jobData[jobKey] = {
            label = jobConfig.label,
            icon = jobConfig.icon,
            workers = workerCounts[jobKey] or 0,
            multiplier = multipliers[jobKey] and multipliers[jobKey].multiplier or 1.0,
            reason = multipliers[jobKey] and multipliers[jobKey].reason or 'normal',
        }
    end

    TriggerClientEvent('sv_job_orchestrator:updateDUI', -1, jobData)

    -- Update session snapshot in database
    if UpdateSessionSnapshot then
        UpdateSessionSnapshot(workerCounts, multipliers)
    end
end

-- Export functions
exports('GetActiveWorkers', GetActiveWorkers)
exports('GetAllWorkerCounts', GetAllWorkerCounts)
exports('BroadcastDUIUpdate', BroadcastDUIUpdate)
