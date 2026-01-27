--[[
    Mr. X Action Queue
    ==================
    Manages delayed and scheduled actions for the agent system.

    Use cases:
    - "Send warning now, escalate in 24h if ignored"
    - "Follow up on mission offer after 2 hours"
    - "Check loan repayment in 3 days"

    The queue processor runs every 30 seconds and executes due actions.
]]

local Queue = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function JsonDecode(str)
    if str == nil or str == '' then return nil end
    local success, result = pcall(json.decode, str)
    return success and result or nil
end

-- ============================================
-- QUEUE MANAGEMENT
-- ============================================

---Schedule an action for later execution
---@param toolName string Name of the tool to execute
---@param args table Arguments for the tool
---@param delaySeconds number Seconds to wait before executing
---@param context? table Optional execution context
---@param dependsOn? string Optional action ID that must complete first
---@return string|nil actionId
function Queue.Schedule(toolName, args, delaySeconds, context, dependsOn)
    local id = GenerateUUID()

    local success = MySQL.insert.await([[
        INSERT INTO mr_x_action_queue (id, tool_name, arguments, context, scheduled_for, status, depends_on)
        VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? SECOND), 'pending', ?)
    ]], {
        id,
        toolName,
        JsonEncode(args),
        JsonEncode(context or {}),
        delaySeconds,
        dependsOn
    })

    if not success then
        return nil
    end

    if Config.Debug then
        print(string.format('^3[MR_X:QUEUE]^7 Scheduled %s in %d seconds (ID: %s)',
            toolName, delaySeconds, id))
    end

    return id
end

---Cancel a scheduled action
---@param actionId string Action ID
---@return boolean success
function Queue.Cancel(actionId)
    local affected = MySQL.update.await([[
        UPDATE mr_x_action_queue SET status = 'cancelled' WHERE id = ? AND status = 'pending'
    ]], {actionId})

    return affected > 0
end

---Get a scheduled action by ID
---@param actionId string
---@return table|nil action
function Queue.Get(actionId)
    return MySQL.single.await([[
        SELECT * FROM mr_x_action_queue WHERE id = ?
    ]], {actionId})
end

---Get all pending actions for a target
---@param citizenid string
---@return table actions
function Queue.GetPendingForTarget(citizenid)
    return MySQL.query.await([[
        SELECT * FROM mr_x_action_queue
        WHERE status = 'pending'
          AND JSON_EXTRACT(arguments, '$.citizenid') = ?
        ORDER BY scheduled_for ASC
    ]], {citizenid})
end

-- ============================================
-- QUEUE PROCESSING
-- ============================================

---Process all due actions
---@return number processed Number of actions processed
function Queue.ProcessDue()
    -- Get actions that are due and not blocked by dependencies
    local dueActions = MySQL.query.await([[
        SELECT q1.*
        FROM mr_x_action_queue q1
        LEFT JOIN mr_x_action_queue q2 ON q1.depends_on = q2.id
        WHERE q1.status = 'pending'
          AND q1.scheduled_for <= NOW()
          AND (q1.depends_on IS NULL OR q2.status = 'completed')
        ORDER BY q1.scheduled_for ASC
        LIMIT 10
    ]])

    local processed = 0

    for _, action in ipairs(dueActions or {}) do
        -- Mark as executing
        MySQL.update.await([[
            UPDATE mr_x_action_queue SET status = 'executing' WHERE id = ?
        ]], {action.id})

        -- Parse arguments and context
        local args = JsonDecode(action.arguments) or {}
        local ctx = JsonDecode(action.context) or {}
        ctx.trigger_type = 'scheduled'
        ctx.action_id = action.id

        -- Execute the tool
        local result = nil
        local success = false

        pcall(function()
            local handler = exports['sv_mr_x']:GetToolHandler(action.tool_name)
            if handler then
                result = handler.execute(args, ctx)
                success = result and result.success ~= false
            else
                result = { success = false, error = 'Unknown tool: ' .. action.tool_name }
            end
        end)

        -- Update status
        local newStatus = success and 'completed' or 'failed'
        MySQL.update.await([[
            UPDATE mr_x_action_queue
            SET status = ?, executed_at = NOW(), result = ?
            WHERE id = ?
        ]], {newStatus, JsonEncode(result), action.id})

        processed = processed + 1

        if Config.Debug then
            print(string.format('^3[MR_X:QUEUE]^7 Processed %s: %s (ID: %s)',
                action.tool_name, newStatus, action.id))
        end
    end

    return processed
end

---Cleanup old completed/failed actions
function Queue.Cleanup()
    -- Delete actions older than 7 days that are completed/failed/cancelled
    MySQL.query([[
        DELETE FROM mr_x_action_queue
        WHERE status IN ('completed', 'failed', 'cancelled')
          AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY)
    ]])
end

-- ============================================
-- QUEUE STATISTICS
-- ============================================

---Get queue statistics
---@return table stats
function Queue.GetStats()
    local stats = MySQL.single.await([[
        SELECT
            COUNT(*) as total,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending,
            SUM(CASE WHEN status = 'executing' THEN 1 ELSE 0 END) as executing,
            SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
            SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
            SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled
        FROM mr_x_action_queue
        WHERE created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
    ]])

    return stats or {
        total = 0,
        pending = 0,
        executing = 0,
        completed = 0,
        failed = 0,
        cancelled = 0
    }
end

-- ============================================
-- QUEUE PROCESSOR THREAD
-- ============================================

CreateThread(function()
    -- Wait for system initialization
    Wait(10000)

    while true do
        Wait(30000)  -- Process every 30 seconds

        if not Config.TestMode then
            local processed = Queue.ProcessDue()

            if processed > 0 and Config.Debug then
                print('^3[MR_X:QUEUE]^7 Processed ' .. processed .. ' due action(s)')
            end
        end
    end
end)

-- Cleanup thread (runs hourly)
CreateThread(function()
    Wait(60000)  -- Initial delay

    while true do
        Wait(3600000)  -- Every hour
        Queue.Cleanup()
    end
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_queue', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then return end

    local action = args[1]

    if action == 'stats' then
        local stats = Queue.GetStats()
        print('^3[MR_X:QUEUE]^7 Queue Stats (last 24h):')
        print('  Pending: ' .. stats.pending)
        print('  Executing: ' .. stats.executing)
        print('  Completed: ' .. stats.completed)
        print('  Failed: ' .. stats.failed)
        print('  Cancelled: ' .. stats.cancelled)
        print('  Total: ' .. stats.total)

    elseif action == 'process' then
        local processed = Queue.ProcessDue()
        print('^3[MR_X:QUEUE]^7 Manually processed ' .. processed .. ' action(s)')

    elseif action == 'pending' then
        local pending = MySQL.query.await([[
            SELECT id, tool_name, scheduled_for, JSON_EXTRACT(arguments, '$.citizenid') as target
            FROM mr_x_action_queue WHERE status = 'pending'
            ORDER BY scheduled_for ASC LIMIT 20
        ]])

        print('^3[MR_X:QUEUE]^7 Pending actions:')
        for _, a in ipairs(pending or {}) do
            print(string.format('  %s: %s -> %s (at %s)',
                a.id:sub(1, 8), a.tool_name, a.target or '?', a.scheduled_for))
        end

    elseif action == 'cancel' and args[2] then
        local success = Queue.Cancel(args[2])
        print('^3[MR_X:QUEUE]^7 Cancel ' .. args[2] .. ': ' .. (success and 'SUCCESS' or 'FAILED'))

    else
        print('^3[MR_X:QUEUE]^7 Usage: mrx_queue [stats|process|pending|cancel <id>]')
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('ScheduleAction', Queue.Schedule)
exports('CancelAction', Queue.Cancel)
exports('GetAction', Queue.Get)
exports('GetPendingActions', Queue.GetPendingForTarget)
exports('ProcessDueActions', Queue.ProcessDue)
exports('GetQueueStats', Queue.GetStats)

return Queue
