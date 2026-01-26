-- Client-side module for sv_job_orchestrator
-- Panel rendering handled by sv_panel_placer
-- This module handles: context menu, DUI data forwarding

local resourceName = GetCurrentResourceName()

-- Listen for DUI updates from server and forward to panel placer
RegisterNetEvent('sv_job_orchestrator:updateDUI', function(jobData)
    -- sv_panel_placer will handle forwarding to job_market panels
    -- This event is caught in sv_panel_placer/client/main.lua
end)

---Open the job market context menu
function OpenJobMarketMenu()
    local jobData = lib.callback.await('sv_job_orchestrator:getJobMarket', false)

    if not jobData then
        lib.notify({
            title = 'Job Market',
            description = 'Unable to load job data',
            type = 'error'
        })
        return
    end

    -- Sort jobs by label
    local sorted = {}
    for jobKey, data in pairs(jobData) do
        table.insert(sorted, { key = jobKey, data = data })
    end
    table.sort(sorted, function(a, b) return a.data.label < b.data.label end)

    -- Build context menu options
    local options = {}
    for _, item in ipairs(sorted) do
        local data = item.data
        local percentStr = string.format('%+d%%', math.floor((data.multiplier - 1) * 100))

        local statusColor = data.reason == 'surge' and '#4ade80' or
                           (data.reason == 'saturated' and '#f87171' or
                           (data.reason == 'declining' and '#fbbf24' or '#94a3b8'))

        local statusText = data.reason == 'surge' and 'High Demand' or
                          (data.reason == 'saturated' and 'Saturated' or
                          (data.reason == 'declining' and 'Cooling' or 'Normal'))

        table.insert(options, {
            title = data.label,
            description = string.format('Workers: %d | Pay: %s | Status: %s', data.workers, percentStr, statusText),
            icon = data.icon or 'fa-solid fa-briefcase',
            iconColor = statusColor,
            readOnly = true
        })
    end

    lib.registerContext({
        id = 'job_market_menu',
        title = 'Job Market',
        options = options
    })

    lib.showContext('job_market_menu')
end

-- Export for other resources to open the menu
exports('OpenJobMarketMenu', OpenJobMarketMenu)

print('^2[' .. resourceName .. ']^7 Client module loaded')
print('^3[' .. resourceName .. ']^7 Use sv_panel_placer to place job_market panels')
