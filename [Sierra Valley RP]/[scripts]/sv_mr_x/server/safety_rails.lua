--[[
    Mr. X Safety Rails
    ==================
    Rate limits and budget constraints for harmful tools.

    Prevents the AI from going overboard with:
    - Too many bounties
    - Too many hit squads
    - Excessive harassment of individual players
    - Spending beyond budget

    These are server-side safety limits that the AI cannot bypass.
]]

local Safety = {}

-- ============================================
-- LIMIT CONFIGURATION
-- ============================================

Safety.Limits = {
    -- Harm tools - global limits
    place_bounty = {
        global_per_day = 10,
        per_player_per_day = 1,
        min_interval_minutes = 60
    },
    trigger_surprise = {
        global_per_day = 5,
        per_player_per_day = 1,
        per_player_per_2days = 1,
        min_interval_minutes = 120
    },

    -- Specific surprise types
    hit_squad = {
        global_per_day = 3,
        per_player_per_day = 1
    },
    fake_warrant = {
        global_per_day = 10,
        per_player_per_day = 1
    },
    leak_location = {
        global_per_day = 15,
        per_player_per_day = 2
    },
    debt_collector = {
        global_per_day = 5,
        per_player_per_day = 1
    },

    -- Service tools
    offer_loan = {
        per_player_per_week = 1,
        max_outstanding_per_player = 1
    },

    -- Communication limits (prevent spam)
    send_message = {
        per_player_per_hour = 10,
        global_per_minute = 20
    },

    -- Reputation changes
    adjust_reputation = {
        max_negative_per_day = -100,  -- Can't tank someone's rep in one day
        max_positive_per_day = 50     -- Prevent instant max rep
    }
}

-- Budget limits (costs Mr. X money)
Safety.Budget = {
    daily_bounty_spend = 100000,
    daily_gift_spend = 50000,
    daily_loan_disbursement = 500000
}

-- Cumulative daily spend tracking
local DailySpend = {
    bounty = 0,
    gift = 0,
    loan = 0,
    lastReset = os.date('%j')
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function ResetDailyIfNeeded()
    local today = os.date('%j')
    if today ~= DailySpend.lastReset then
        DailySpend.bounty = 0
        DailySpend.gift = 0
        DailySpend.loan = 0
        DailySpend.lastReset = today
    end
end

-- ============================================
-- LIMIT CHECKING
-- ============================================

---Check if a tool call is within safety limits
---@param toolName string Tool name
---@param citizenid? string Target citizenid (if applicable)
---@param amount? number Amount (for budget checks)
---@return boolean allowed
---@return string|nil reason
function Safety.CheckLimit(toolName, citizenid, amount)
    ResetDailyIfNeeded()

    local limits = Safety.Limits[toolName]
    if not limits then
        return true -- No limits defined = allowed
    end

    -- Global per day limit
    if limits.global_per_day then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
        ]], {toolName})

        if count >= limits.global_per_day then
            return false, 'Global daily limit reached (' .. limits.global_per_day .. '/day)'
        end
    end

    -- Global per minute limit (anti-spam)
    if limits.global_per_minute then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND created_at > DATE_SUB(NOW(), INTERVAL 1 MINUTE)
        ]], {toolName})

        if count >= limits.global_per_minute then
            return false, 'Global rate limit reached (' .. limits.global_per_minute .. '/min)'
        end
    end

    -- Per-player per day limit
    if citizenid and limits.per_player_per_day then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND target_citizenid = ?
              AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
        ]], {toolName, citizenid})

        if count >= limits.per_player_per_day then
            return false, 'Per-player daily limit reached (' .. limits.per_player_per_day .. '/day)'
        end
    end

    -- Per-player per 2 days limit
    if citizenid and limits.per_player_per_2days then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND target_citizenid = ?
              AND created_at > DATE_SUB(NOW(), INTERVAL 2 DAY)
        ]], {toolName, citizenid})

        if count >= limits.per_player_per_2days then
            return false, 'Per-player 2-day limit reached'
        end
    end

    -- Per-player per hour limit
    if citizenid and limits.per_player_per_hour then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND target_citizenid = ?
              AND created_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)
        ]], {toolName, citizenid})

        if count >= limits.per_player_per_hour then
            return false, 'Per-player hourly limit reached (' .. limits.per_player_per_hour .. '/hr)'
        end
    end

    -- Per-player per week limit
    if citizenid and limits.per_player_per_week then
        local count = MySQL.scalar.await([[
            SELECT COUNT(*) FROM mr_x_tool_log
            WHERE tool_name = ? AND target_citizenid = ?
              AND created_at > DATE_SUB(NOW(), INTERVAL 7 DAY)
        ]], {toolName, citizenid})

        if count >= limits.per_player_per_week then
            return false, 'Per-player weekly limit reached (' .. limits.per_player_per_week .. '/week)'
        end
    end

    -- Minimum interval check
    if citizenid and limits.min_interval_minutes then
        local lastUse = MySQL.single.await([[
            SELECT created_at FROM mr_x_tool_log
            WHERE tool_name = ? AND target_citizenid = ?
            ORDER BY created_at DESC LIMIT 1
        ]], {toolName, citizenid})

        if lastUse then
            local lastTime = lastUse.created_at
            -- This is a rough check - proper implementation would parse the timestamp
            local recent = MySQL.scalar.await([[
                SELECT COUNT(*) FROM mr_x_tool_log
                WHERE tool_name = ? AND target_citizenid = ?
                  AND created_at > DATE_SUB(NOW(), INTERVAL ? MINUTE)
            ]], {toolName, citizenid, limits.min_interval_minutes})

            if recent > 0 then
                return false, 'Minimum interval not met (' .. limits.min_interval_minutes .. ' min)'
            end
        end
    end

    return true
end

-- ============================================
-- BUDGET CHECKING
-- ============================================

---Check if a spending action is within budget
---@param category string 'bounty'|'gift'|'loan'
---@param amount number Amount to spend
---@return boolean allowed
---@return string|nil reason
function Safety.CheckBudget(category, amount)
    ResetDailyIfNeeded()

    local budgetLimit = Safety.Budget['daily_' .. category .. '_spend']
    if not budgetLimit then
        return true -- No budget defined
    end

    local currentSpend = DailySpend[category] or 0

    if currentSpend + amount > budgetLimit then
        return false, string.format(
            'Daily %s budget exceeded ($%d spent, limit $%d)',
            category, currentSpend, budgetLimit
        )
    end

    return true
end

---Record a spend against the budget
---@param category string
---@param amount number
function Safety.RecordSpend(category, amount)
    ResetDailyIfNeeded()
    DailySpend[category] = (DailySpend[category] or 0) + amount
end

-- ============================================
-- REPUTATION CHANGE LIMITS
-- ============================================

---Check if a reputation change is within limits
---@param citizenid string
---@param delta number Change amount (positive or negative)
---@return boolean allowed
---@return string|nil reason
function Safety.CheckReputationChange(citizenid, delta)
    local limits = Safety.Limits.adjust_reputation
    if not limits then return true end

    -- Get today's cumulative changes for this player
    local todaysChanges = MySQL.single.await([[
        SELECT
            COALESCE(SUM(CASE WHEN JSON_EXTRACT(arguments, '$.delta') < 0 THEN JSON_EXTRACT(arguments, '$.delta') ELSE 0 END), 0) as negative_total,
            COALESCE(SUM(CASE WHEN JSON_EXTRACT(arguments, '$.delta') > 0 THEN JSON_EXTRACT(arguments, '$.delta') ELSE 0 END), 0) as positive_total
        FROM mr_x_tool_log
        WHERE tool_name = 'adjust_reputation'
          AND target_citizenid = ?
          AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
    ]], {citizenid})

    if delta < 0 then
        local currentNegative = todaysChanges and todaysChanges.negative_total or 0
        if currentNegative + delta < limits.max_negative_per_day then
            return false, string.format(
                'Daily negative rep limit reached (already %d, limit %d)',
                currentNegative, limits.max_negative_per_day
            )
        end
    else
        local currentPositive = todaysChanges and todaysChanges.positive_total or 0
        if currentPositive + delta > limits.max_positive_per_day then
            return false, string.format(
                'Daily positive rep limit reached (already +%d, limit +%d)',
                currentPositive, limits.max_positive_per_day
            )
        end
    end

    return true
end

-- ============================================
-- COMBINED SAFETY CHECK
-- ============================================

---Combined safety check for a tool call
---@param toolName string
---@param citizenid? string
---@param extraChecks? table { amount?: number, repDelta?: number, budgetCategory?: string }
---@return boolean allowed
---@return string|nil reason
function Safety.Check(toolName, citizenid, extraChecks)
    extraChecks = extraChecks or {}

    -- Basic tool limit check
    local allowed, reason = Safety.CheckLimit(toolName, citizenid)
    if not allowed then
        return false, reason
    end

    -- Budget check if amount specified
    if extraChecks.amount and extraChecks.budgetCategory then
        allowed, reason = Safety.CheckBudget(extraChecks.budgetCategory, extraChecks.amount)
        if not allowed then
            return false, reason
        end
    end

    -- Reputation change check
    if extraChecks.repDelta then
        allowed, reason = Safety.CheckReputationChange(citizenid, extraChecks.repDelta)
        if not allowed then
            return false, reason
        end
    end

    -- Check for exempt players (can't target them)
    if citizenid then
        local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(citizenid)
        if isExempt then
            return false, 'Target player is exempt from Mr. X actions'
        end
    end

    return true
end

-- ============================================
-- STATISTICS
-- ============================================

---Get safety statistics for dashboard
---@return table stats
function Safety.GetStats()
    ResetDailyIfNeeded()

    local toolUsage = MySQL.query.await([[
        SELECT tool_name, COUNT(*) as count
        FROM mr_x_tool_log
        WHERE created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
        GROUP BY tool_name
        ORDER BY count DESC
    ]])

    local blockedCount = MySQL.scalar.await([[
        SELECT COUNT(*) FROM mr_x_tool_log
        WHERE created_at > DATE_SUB(NOW(), INTERVAL 1 DAY)
          AND JSON_EXTRACT(result, '$.blocked') = true
    ]])

    return {
        dailySpend = DailySpend,
        budgetLimits = Safety.Budget,
        toolUsage = toolUsage or {},
        blockedAttempts = blockedCount or 0
    }
end

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_safety', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then return end

    local action = args[1]

    if action == 'stats' then
        local stats = Safety.GetStats()
        print('^3[MR_X:SAFETY]^7 Daily spend:')
        print('  Bounty: $' .. (stats.dailySpend.bounty or 0) .. ' / $' .. stats.budgetLimits.daily_bounty_spend)
        print('  Gift: $' .. (stats.dailySpend.gift or 0) .. ' / $' .. stats.budgetLimits.daily_gift_spend)
        print('  Loan: $' .. (stats.dailySpend.loan or 0) .. ' / $' .. stats.budgetLimits.daily_loan_disbursement)
        print('  Blocked attempts: ' .. stats.blockedAttempts)

    elseif action == 'check' and args[2] then
        local toolName = args[2]
        local citizenid = args[3]
        local allowed, reason = Safety.CheckLimit(toolName, citizenid)
        print(string.format('^3[MR_X:SAFETY]^7 Check %s: %s%s',
            toolName,
            allowed and '^2ALLOWED^7' or '^1BLOCKED^7',
            reason and (' - ' .. reason) or ''
        ))

    elseif action == 'reset' then
        DailySpend.bounty = 0
        DailySpend.gift = 0
        DailySpend.loan = 0
        print('^3[MR_X:SAFETY]^7 Daily spend reset')

    else
        print('^3[MR_X:SAFETY]^7 Usage: mrx_safety [stats|check <tool> [citizenid]|reset]')
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('CheckSafetyLimit', Safety.Check)
exports('CheckToolLimit', Safety.CheckLimit)
exports('CheckBudget', Safety.CheckBudget)
exports('RecordSpend', Safety.RecordSpend)
exports('CheckReputationChange', Safety.CheckReputationChange)
exports('GetSafetyStats', Safety.GetStats)

return Safety
