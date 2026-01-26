-- Main server module for sv_job_orchestrator
-- Primary exports for job payment processing

local resourceName = GetCurrentResourceName()

---Get the current effective pay for a job type
---@param jobType string The job type key (e.g., 'mining', 'taxi', 'bus')
---@param payType string|nil Optional sub-category (e.g., 'ores', 'perMile')
---@param subType string|nil Optional sub-sub-category (e.g., 'gold_ore')
---@return table|number pay The adjusted pay (table with min/max or single value)
function GetJobPay(jobType, payType, subType)
    local jobConfig, jobKey = Config.GetJobConfig(jobType)
    if not jobConfig then
        print('^1[' .. resourceName .. ']^7 GetJobPay: Unknown job type: ' .. tostring(jobType))
        return 0
    end

    local basePay = jobConfig.basePay
    local multiplier, _ = CalculateMultiplier(jobKey)

    -- Navigate nested pay structures
    if payType and type(basePay) == 'table' and basePay[payType] then
        basePay = basePay[payType]
    end
    if subType and type(basePay) == 'table' and basePay[subType] then
        basePay = basePay[subType]
    end

    -- Apply multiplier and return
    if type(basePay) == 'table' then
        if basePay.min and basePay.max then
            return {
                min = math.floor(basePay.min * multiplier),
                max = math.floor(basePay.max * multiplier)
            }
        else
            -- Return entire table with multiplier applied to numeric values
            local result = {}
            for k, v in pairs(basePay) do
                if type(v) == 'number' then
                    result[k] = math.floor(v * multiplier)
                elseif type(v) == 'table' and v.min and v.max then
                    result[k] = {
                        min = math.floor(v.min * multiplier),
                        max = math.floor(v.max * multiplier)
                    }
                else
                    result[k] = v
                end
            end
            return result
        end
    elseif type(basePay) == 'number' then
        return math.floor(basePay * multiplier)
    end

    return 0
end

---Process a job payment with multiplier and logging
---@param source number Player server ID
---@param jobType string The job type key
---@param baseAmount number The base payment amount (before multiplier)
---@param moneyType string Money type ('cash' or 'bank')
---@param reason string|nil Optional reason for the payment
---@return number finalAmount The actual amount paid after multiplier
function ProcessJobPayment(source, jobType, baseAmount, moneyType, reason)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        print('^1[' .. resourceName .. ']^7 ProcessJobPayment: Player not found for source ' .. tostring(source))
        return 0
    end

    local jobConfig, jobKey = Config.GetJobConfig(jobType)
    if not jobConfig then
        print('^1[' .. resourceName .. ']^7 ProcessJobPayment: Unknown job type: ' .. tostring(jobType))
        return 0
    end

    -- Calculate multiplier
    local multiplier, multReason = CalculateMultiplier(jobKey)
    local activeWorkers = GetActiveWorkers(jobKey)

    -- Calculate final amount
    local finalAmount = math.floor(baseAmount * multiplier)

    -- Add money to player
    moneyType = moneyType or 'cash'
    reason = reason or (jobConfig.label .. ' payment')
    exports.qbx_core:AddMoney(source, moneyType, finalAmount, reason)

    -- Log to database
    local citizenid = player.PlayerData.citizenid
    LogPayment(citizenid, jobKey, baseAmount, multiplier, finalAmount, multReason, activeWorkers)

    -- Notify player about multiplier effect
    local message = GetMultiplierMessage(multReason, multiplier)
    if multReason ~= 'normal' then
        TriggerClientEvent('ox_lib:notify', source, {
            title = jobConfig.label,
            description = '$' .. finalAmount .. ' - ' .. message,
            type = multReason == 'surge' and 'success' or (multReason == 'saturated' and 'error' or 'inform'),
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = jobConfig.label,
            description = '$' .. finalAmount,
            type = 'inform',
            duration = 3000
        })
    end

    return finalAmount
end

---Get the current job market status for a job
---@param jobType string The job type key
---@return table|nil status Job market status or nil if not found
function GetJobStatus(jobType)
    local jobConfig, jobKey = Config.GetJobConfig(jobType)
    if not jobConfig then return nil end

    local multiplier, reason = CalculateMultiplier(jobKey)
    local activeWorkers = GetActiveWorkers(jobKey)

    return {
        jobKey = jobKey,
        label = jobConfig.label,
        workers = activeWorkers,
        multiplier = multiplier,
        reason = reason,
        thresholds = {
            surge = jobConfig.surgeThreshold,
            normal = jobConfig.normalThreshold,
            declining = jobConfig.decliningThreshold,
            saturated = jobConfig.saturationThreshold
        }
    }
end

---Get full job market overview
---@return table market Full market data for all jobs
function GetJobMarket()
    local market = {}
    for jobKey, jobConfig in pairs(Config.Jobs) do
        if jobConfig.tracked then
            local multiplier, reason = CalculateMultiplier(jobKey)
            local activeWorkers = GetActiveWorkers(jobKey)

            market[jobKey] = {
                label = jobConfig.label,
                icon = jobConfig.icon,
                workers = activeWorkers,
                multiplier = multiplier,
                reason = reason,
                basePay = jobConfig.basePay
            }
        end
    end
    return market
end

-- Callback for clients to get job market data
lib.callback.register('sv_job_orchestrator:getJobMarket', function(source)
    return GetJobMarket()
end)

-- Callback for clients to get specific job status
lib.callback.register('sv_job_orchestrator:getJobStatus', function(source, jobType)
    return GetJobStatus(jobType)
end)

-- Export the main functions
exports('GetJobPay', GetJobPay)
exports('ProcessJobPayment', ProcessJobPayment)
exports('GetJobStatus', GetJobStatus)
exports('GetJobMarket', GetJobMarket)

-- Resource start notification
CreateThread(function()
    Wait(1000)
    print('^2[' .. resourceName .. ']^7 Job Orchestrator initialized')
    print('^2[' .. resourceName .. ']^7 Tracking ' .. tostring(#Config.Jobs) .. ' job types')
end)
