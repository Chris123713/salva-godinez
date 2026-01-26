-- Server-side Discord webhook module for sv_job_orchestrator
-- Sends scheduled daily reports with job analytics

local resourceName = GetCurrentResourceName()

---Send a Discord webhook message
---@param webhook string The webhook URL
---@param embed table The embed object
local function SendDiscordWebhook(webhook, embed)
    if not webhook or webhook == '' then return end

    PerformHttpRequest(webhook, function(statusCode, response, headers)
        if statusCode == 204 then
            print('^2[' .. resourceName .. ']^7 Discord report sent successfully')
        else
            print('^1[' .. resourceName .. ']^7 Discord webhook failed: ' .. tostring(statusCode))
        end
    end, 'POST', json.encode({
        username = 'Sierra Valley Job Market',
        avatar_url = 'https://i.imgur.com/AfFp7pu.png',
        embeds = { embed }
    }), { ['Content-Type'] = 'application/json' })
end

---Build the daily report embed
---@param stats table Payment statistics by job type
---@param uniqueWorkers number Number of unique workers
---@return table embed The Discord embed object
local function BuildReportEmbed(stats, uniqueWorkers)
    -- Calculate totals
    local totalCompletions = 0
    local totalBase = 0
    local totalPaid = 0
    local totalSurgeBonus = 0
    local totalSaturationPenalty = 0

    local popularJobs = {}
    local unpopularJobs = {}

    for _, row in ipairs(stats or {}) do
        totalCompletions = totalCompletions + (row.completions or 0)
        totalBase = totalBase + (row.total_base or 0)
        totalPaid = totalPaid + (row.total_paid or 0)
        totalSurgeBonus = totalSurgeBonus + (row.surge_bonus_paid or 0)
        totalSaturationPenalty = totalSaturationPenalty + (row.saturation_penalty or 0)

        local jobConfig = Config.Jobs[row.job_type]
        local label = jobConfig and jobConfig.label or row.job_type

        table.insert(popularJobs, {
            label = label,
            completions = row.completions or 0,
            surgePercent = row.completions > 0 and math.floor(((row.surge_count or 0) / row.completions) * 100) or 0,
            satPercent = row.completions > 0 and math.floor(((row.saturated_count or 0) / row.completions) * 100) or 0
        })
    end

    -- Sort for most/least popular
    table.sort(popularJobs, function(a, b) return a.completions > b.completions end)

    -- Build strings for embed
    local mostPopularStr = ''
    local leastPopularStr = ''
    local surgeStr = ''
    local satStr = ''

    for i = 1, math.min(3, #popularJobs) do
        local job = popularJobs[i]
        mostPopularStr = mostPopularStr .. string.format('%d. %s - %d completions\n', i, job.label, job.completions)
    end

    for i = math.max(1, #popularJobs - 2), #popularJobs do
        local job = popularJobs[i]
        if job then
            leastPopularStr = leastPopularStr .. string.format('- %s - %d completions\n', job.label, job.completions)
        end
    end

    -- Find jobs with highest surge/saturation
    local surgeJobs = {}
    local satJobs = {}
    for _, job in ipairs(popularJobs) do
        if job.surgePercent > 50 then
            table.insert(surgeJobs, string.format('%s (%d%%)', job.label, job.surgePercent))
        end
        if job.satPercent > 30 then
            table.insert(satJobs, string.format('%s (%d%%)', job.label, job.satPercent))
        end
    end

    surgeStr = #surgeJobs > 0 and table.concat(surgeJobs, ', ') or 'None (all jobs adequately staffed)'
    satStr = #satJobs > 0 and table.concat(satJobs, ', ') or 'None (no oversaturation)'

    local avgPayment = totalCompletions > 0 and math.floor(totalPaid / totalCompletions) or 0

    local embed = {
        title = 'Sierra Valley Job Market Report',
        description = 'Daily analytics for ' .. os.date('%Y-%m-%d'),
        color = 3447003, -- Blue
        fields = {
            {
                name = 'Most Popular Jobs (24hr)',
                value = mostPopularStr ~= '' and mostPopularStr or 'No data',
                inline = true
            },
            {
                name = 'Least Popular Jobs',
                value = leastPopularStr ~= '' and leastPopularStr or 'No data',
                inline = true
            },
            {
                name = '\u{200B}', -- Empty field for spacing
                value = '\u{200B}',
                inline = false
            },
            {
                name = 'Total Payouts',
                value = string.format('$%s distributed\n$%s avg per task', FormatNumber(totalPaid), FormatNumber(avgPayment)),
                inline = false
            },
            {
                name = 'Surge Bonuses Paid',
                value = string.format('$%s (+35%% bonuses)\nHigh surge: %s', FormatNumber(totalSurgeBonus), surgeStr),
                inline = true
            },
            {
                name = 'Saturation Penalties',
                value = string.format('$%s reduced (-30%% penalties)\nHigh saturation: %s', FormatNumber(totalSaturationPenalty), satStr),
                inline = true
            },
            {
                name = 'Unique Workers',
                value = string.format('%d players worked jobs today', uniqueWorkers),
                inline = false
            },
        },
        footer = { text = 'Report generated from job_orchestrator_payments' },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }

    return embed
end

---Send the daily report
function SendDailyReport()
    if not Config.DiscordReports.enabled then return end
    if not Config.DiscordReports.webhook or Config.DiscordReports.webhook == '' then
        print('^3[' .. resourceName .. ']^7 Discord webhook not configured, skipping report')
        return
    end

    -- Query last 24 hours
    local stats = GetPaymentStats(24)
    local uniqueWorkers = GetUniqueWorkerCount(24)

    -- Build and send embed
    local embed = BuildReportEmbed(stats, uniqueWorkers)
    SendDiscordWebhook(Config.DiscordReports.webhook, embed)
end

-- Scheduled report loop
CreateThread(function()
    if not Config.DiscordReports.enabled then
        print('^3[' .. resourceName .. ']^7 Discord reports disabled')
        return
    end

    print('^2[' .. resourceName .. ']^7 Discord reports enabled, scheduled at: ' .. table.concat(Config.DiscordReports.scheduledTimes, ', '))

    while true do
        Wait(30000) -- Check every 30 seconds

        local currentTime = os.date('%H:%M')
        for _, scheduledTime in ipairs(Config.DiscordReports.scheduledTimes) do
            if currentTime == scheduledTime then
                print('^2[' .. resourceName .. ']^7 Sending scheduled report...')
                SendDailyReport()
                Wait(61000) -- Wait 61 seconds to avoid duplicate sends
                break
            end
        end
    end
end)

-- Export for manual triggering
exports('SendDailyReport', SendDailyReport)
