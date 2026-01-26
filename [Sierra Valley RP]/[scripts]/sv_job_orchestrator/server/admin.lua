-- Server-side admin commands for sv_job_orchestrator

local resourceName = GetCurrentResourceName()

-- /jobmarket - View current job market status
lib.addCommand('jobmarket', {
    help = 'View the current job market status',
    restricted = 'group.admin'
}, function(source)
    local market = GetJobMarket()
    local output = '\n^3=== Job Market Status ===^7\n'

    -- Sort jobs by worker count (descending)
    local sorted = {}
    for jobKey, data in pairs(market) do
        table.insert(sorted, { key = jobKey, data = data })
    end
    table.sort(sorted, function(a, b) return a.data.workers > b.data.workers end)

    for _, item in ipairs(sorted) do
        local data = item.data
        local reasonColor = data.reason == 'surge' and '^2' or
                           (data.reason == 'saturated' and '^1' or
                           (data.reason == 'declining' and '^3' or '^7'))
        local percentStr = string.format('%+d%%', math.floor((data.multiplier - 1) * 100))

        output = output .. string.format(
            '%s%-20s^7 | Workers: %d | %s%s (%s)^7\n',
            reasonColor,
            data.label,
            data.workers,
            reasonColor,
            percentStr,
            data.reason
        )
    end

    if source == 0 then
        print(output)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^3Job Orchestrator', output:gsub('\n', '<br>') }
        })
    end
end)

-- /jobmarketforce [job] [multiplier] [duration] - Force a multiplier for testing
lib.addCommand('jobmarketforce', {
    help = 'Force a multiplier for a job (testing)',
    params = {
        { name = 'job', help = 'Job type key (e.g., mining, taxi)', type = 'string' },
        { name = 'multiplier', help = 'Multiplier value (e.g., 1.5 for +50%)', type = 'number' },
        { name = 'duration', help = 'Duration in seconds (default: 300)', type = 'number', optional = true }
    },
    restricted = 'group.admin'
}, function(source, args)
    local jobType = args.job
    local multiplier = args.multiplier
    local duration = args.duration or 300

    local jobConfig = Config.Jobs[jobType]
    if not jobConfig then
        local msg = '^1[Error]^7 Unknown job type: ' .. tostring(jobType)
        if source == 0 then
            print(msg)
        else
            TriggerClientEvent('ox_lib:notify', source, { title = 'Job Orchestrator', description = 'Unknown job type: ' .. jobType, type = 'error' })
        end
        return
    end

    ForceMultiplier(jobType, multiplier, 'forced', duration)

    local msg = string.format('^2[Success]^7 Forced %s multiplier to %.2fx for %d seconds', jobConfig.label, multiplier, duration)
    if source == 0 then
        print(msg)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Job Orchestrator',
            description = string.format('Forced %s to %.2fx for %ds', jobConfig.label, multiplier, duration),
            type = 'success'
        })
    end
end)

-- /jobmarketreset - Reset all forced multipliers and session tracking
lib.addCommand('jobmarketreset', {
    help = 'Reset forced multipliers and refresh worker tracking',
    restricted = 'group.admin'
}, function(source)
    ClearForcedMultiplier()
    BroadcastDUIUpdate()

    local msg = '^2[Success]^7 Job market reset complete'
    if source == 0 then
        print(msg)
    else
        TriggerClientEvent('ox_lib:notify', source, { title = 'Job Orchestrator', description = 'Job market reset complete', type = 'success' })
    end
end)

-- /jobreport - Manually trigger a Discord report
lib.addCommand('jobreport', {
    help = 'Manually trigger a Discord analytics report',
    restricted = 'group.admin'
}, function(source)
    if SendDailyReport then
        SendDailyReport()
        local msg = '^2[Success]^7 Discord report sent'
        if source == 0 then
            print(msg)
        else
            TriggerClientEvent('ox_lib:notify', source, { title = 'Job Orchestrator', description = 'Discord report sent', type = 'success' })
        end
    else
        local msg = '^1[Error]^7 Discord reporting not available'
        if source == 0 then
            print(msg)
        else
            TriggerClientEvent('ox_lib:notify', source, { title = 'Job Orchestrator', description = 'Discord reporting not available', type = 'error' })
        end
    end
end)

-- /jobstats [hours] - View payment statistics
lib.addCommand('jobstats', {
    help = 'View job payment statistics',
    params = {
        { name = 'hours', help = 'Hours to look back (default: 24)', type = 'number', optional = true }
    },
    restricted = 'group.admin'
}, function(source, args)
    local hours = args.hours or 24
    local stats = GetPaymentStats(hours)
    local uniqueWorkers = GetUniqueWorkerCount(hours)

    local output = string.format('\n^3=== Job Statistics (Last %d hours) ===^7\n', hours)
    output = output .. string.format('Unique Workers: %d\n\n', uniqueWorkers)

    if stats and #stats > 0 then
        for _, row in ipairs(stats) do
            local surgePercent = row.completions > 0 and math.floor((row.surge_count / row.completions) * 100) or 0
            local satPercent = row.completions > 0 and math.floor((row.saturated_count / row.completions) * 100) or 0

            output = output .. string.format(
                '^3%-15s^7 | Completions: %d | Paid: $%s | Surge: %d%% | Saturated: %d%%\n',
                row.job_type,
                row.completions,
                FormatNumber(row.total_paid or 0),
                surgePercent,
                satPercent
            )
        end
    else
        output = output .. 'No payment data for this period.\n'
    end

    if source == 0 then
        print(output)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^3Job Orchestrator', output:gsub('\n', '<br>') }
        })
    end
end)

-- /jobworkers - View current worker distribution
lib.addCommand('jobworkers', {
    help = 'View current worker distribution across jobs',
    restricted = 'group.admin'
}, function(source)
    local counts = GetAllWorkerCounts()
    local total = 0

    local output = '\n^3=== Active Workers ===^7\n'

    -- Sort by worker count
    local sorted = {}
    for jobKey, count in pairs(counts) do
        table.insert(sorted, { key = jobKey, count = count })
        total = total + count
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)

    for _, item in ipairs(sorted) do
        local jobConfig = Config.Jobs[item.key]
        if jobConfig and item.count > 0 then
            local bar = string.rep('|', math.min(item.count, 20))
            output = output .. string.format('%-15s %s %d\n', jobConfig.label, bar, item.count)
        end
    end

    output = output .. string.format('\n^7Total Active Workers: %d\n', total)

    if source == 0 then
        print(output)
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^3Job Orchestrator', output:gsub('\n', '<br>') }
        })
    end
end)

-- Helper function to format numbers with commas
function FormatNumber(num)
    local formatted = tostring(math.floor(num))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

print('^2[' .. resourceName .. ']^7 Admin commands registered')
