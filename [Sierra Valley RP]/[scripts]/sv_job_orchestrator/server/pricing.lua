-- Server-side pricing module for sv_job_orchestrator
-- Calculates dynamic multipliers based on worker counts

local resourceName = GetCurrentResourceName()

-- Cache for forced multipliers (admin override)
---@type table<string, {multiplier: number, reason: string, expires: number}>
ForcedMultipliers = {}

---Calculate the multiplier for a job based on active workers
---@param jobType string The job type key (e.g., 'mining', 'taxi')
---@param activeWorkers number|nil Number of active workers (auto-fetched if nil)
---@return number multiplier The calculated multiplier
---@return string reason The reason for the multiplier (surge/normal/declining/saturated)
function CalculateMultiplier(jobType, activeWorkers)
    -- Check for forced multiplier (admin override)
    if ForcedMultipliers[jobType] then
        local forced = ForcedMultipliers[jobType]
        if forced.expires > os.time() then
            return forced.multiplier, forced.reason
        else
            ForcedMultipliers[jobType] = nil
        end
    end

    local jobConfig = Config.Jobs[jobType]
    if not jobConfig then
        return 1.0, 'normal'
    end

    -- Get active workers if not provided
    if activeWorkers == nil then
        activeWorkers = GetActiveWorkers(jobType)
    end

    -- Determine multiplier zone based on thresholds
    local surgeThreshold = jobConfig.surgeThreshold or 2
    local normalThreshold = jobConfig.normalThreshold or 5
    local decliningThreshold = jobConfig.decliningThreshold or 7
    local saturationThreshold = jobConfig.saturationThreshold or 8

    if activeWorkers <= surgeThreshold then
        -- Surge zone: 0 to surgeThreshold workers
        return Config.Multipliers.surge, 'surge'
    elseif activeWorkers <= normalThreshold then
        -- Normal zone: surgeThreshold+1 to normalThreshold workers
        return Config.Multipliers.normal, 'normal'
    elseif activeWorkers <= decliningThreshold then
        -- Declining zone: normalThreshold+1 to decliningThreshold workers
        -- Linear interpolation between normal and declining
        local progress = (activeWorkers - normalThreshold) / (decliningThreshold - normalThreshold)
        local multiplier = Config.Multipliers.normal - (progress * (Config.Multipliers.normal - Config.Multipliers.declining))
        return multiplier, 'declining'
    else
        -- Saturated zone: decliningThreshold+ workers
        return Config.Multipliers.saturated, 'saturated'
    end
end

---Get multiplier data for a job
---@param jobType string The job type key
---@return table data Multiplier data with multiplier, reason, and thresholds
function GetMultiplierData(jobType)
    local multiplier, reason = CalculateMultiplier(jobType)
    local activeWorkers = GetActiveWorkers(jobType)
    local jobConfig = Config.Jobs[jobType]

    return {
        multiplier = multiplier,
        reason = reason,
        activeWorkers = activeWorkers,
        thresholds = jobConfig and {
            surge = jobConfig.surgeThreshold,
            normal = jobConfig.normalThreshold,
            declining = jobConfig.decliningThreshold,
            saturated = jobConfig.saturationThreshold,
        } or nil
    }
end

---Get all multipliers for all tracked jobs
---@return table<string, {multiplier: number, reason: string}> Multipliers by job type
function GetAllMultipliers()
    local multipliers = {}
    for jobKey, _ in pairs(Config.Jobs) do
        local multiplier, reason = CalculateMultiplier(jobKey)
        multipliers[jobKey] = {
            multiplier = multiplier,
            reason = reason
        }
    end
    return multipliers
end

---Force a multiplier for testing (admin command)
---@param jobType string The job type key
---@param multiplier number The forced multiplier value
---@param reason string|nil The reason to show (default: 'forced')
---@param duration number|nil Duration in seconds (default: 300 = 5 minutes)
function ForceMultiplier(jobType, multiplier, reason, duration)
    duration = duration or 300
    ForcedMultipliers[jobType] = {
        multiplier = multiplier,
        reason = reason or 'forced',
        expires = os.time() + duration
    }
    print('^3[' .. resourceName .. ']^7 Forced multiplier for ' .. jobType .. ': ' .. tostring(multiplier) .. ' for ' .. tostring(duration) .. 's')
    BroadcastDUIUpdate()
end

---Clear a forced multiplier
---@param jobType string|nil The job type key (nil = clear all)
function ClearForcedMultiplier(jobType)
    if jobType then
        ForcedMultipliers[jobType] = nil
    else
        ForcedMultipliers = {}
    end
    BroadcastDUIUpdate()
end

---Get the multiplier message for player notifications
---@param reason string The multiplier reason
---@param multiplier number The multiplier value
---@return string message The notification message
function GetMultiplierMessage(reason, multiplier)
    local percentChange = math.floor((multiplier - 1.0) * 100)
    local sign = percentChange >= 0 and '+' or ''

    local messages = {
        surge = 'High demand - surge bonus! (' .. sign .. percentChange .. '%)',
        normal = 'Standard market rate',
        declining = 'Market cooling (' .. sign .. percentChange .. '%)',
        saturated = 'Market saturated - reduced pay (' .. sign .. percentChange .. '%)',
        forced = 'Admin override (' .. sign .. percentChange .. '%)'
    }

    return messages[reason] or messages.normal
end

-- Export functions
exports('CalculateMultiplier', CalculateMultiplier)
exports('GetMultiplierData', GetMultiplierData)
exports('GetAllMultipliers', GetAllMultipliers)
exports('ForceMultiplier', ForceMultiplier)
exports('ClearForcedMultiplier', ClearForcedMultiplier)
exports('GetMultiplierMessage', GetMultiplierMessage)
