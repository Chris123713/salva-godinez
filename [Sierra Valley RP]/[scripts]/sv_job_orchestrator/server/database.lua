-- Server-side database module for sv_job_orchestrator
-- Auto-initializes tables on resource start

local resourceName = GetCurrentResourceName()
local sessionId = nil

-- Initialize database tables
CreateThread(function()
    -- Wait for oxmysql to be ready
    repeat Wait(100) until MySQL.ready

    -- Create payments table if not exists
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `job_orchestrator_payments` (
            `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
            `citizenid` VARCHAR(50) NOT NULL,
            `job_type` VARCHAR(50) NOT NULL,
            `base_amount` INT NOT NULL,
            `multiplier` DECIMAL(4,2) NOT NULL,
            `final_amount` INT NOT NULL,
            `multiplier_reason` ENUM('surge', 'normal', 'declining', 'saturated') NOT NULL,
            `active_workers_at_time` INT NOT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_citizenid` (`citizenid`),
            INDEX `idx_job_type_time` (`job_type`, `created_at`),
            INDEX `idx_created_at` (`created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])

    -- Create session snapshots table if not exists
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `job_orchestrator_sessions` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `session_start` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `session_end` TIMESTAMP NULL,
            `snapshot_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            `active_workers` JSON NOT NULL,
            `multipliers` JSON NOT NULL,
            INDEX `idx_session_time` (`session_start`, `session_end`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])

    -- Create hourly aggregates view
    MySQL.query.await([[
        CREATE OR REPLACE VIEW `view_job_hourly_stats` AS
        SELECT
            job_type,
            DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') as hour_bucket,
            COUNT(*) as payment_count,
            AVG(active_workers_at_time) as avg_workers,
            AVG(multiplier) as avg_multiplier,
            SUM(base_amount) as total_base,
            SUM(final_amount) as total_paid,
            AVG(final_amount) as avg_payment
        FROM job_orchestrator_payments
        GROUP BY job_type, hour_bucket
    ]])

    -- Create new session record
    local result = MySQL.insert.await(
        'INSERT INTO job_orchestrator_sessions (active_workers, multipliers) VALUES (?, ?)',
        { '{}', '{}' }
    )
    sessionId = result

    print('^2[' .. resourceName .. ']^7 Database tables initialized')
    print('^2[' .. resourceName .. ']^7 Session ID: ' .. tostring(sessionId))
end)

-- Close session on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= resourceName then return end
    if sessionId then
        MySQL.update.await(
            'UPDATE job_orchestrator_sessions SET session_end = CURRENT_TIMESTAMP WHERE id = ?',
            { sessionId }
        )
    end
end)

---Log a job payment to the database
---@param citizenid string Player's citizen ID
---@param jobType string The job type key (e.g., 'mining', 'taxi')
---@param baseAmount number Base payment amount
---@param multiplier number Applied multiplier
---@param finalAmount number Final payment after multiplier
---@param reason string Multiplier reason (surge/normal/declining/saturated)
---@param activeWorkers number Number of active workers at time of payment
function LogPayment(citizenid, jobType, baseAmount, multiplier, finalAmount, reason, activeWorkers)
    MySQL.insert('INSERT INTO job_orchestrator_payments (citizenid, job_type, base_amount, multiplier, final_amount, multiplier_reason, active_workers_at_time) VALUES (?, ?, ?, ?, ?, ?, ?)',
        { citizenid, jobType, baseAmount, multiplier, finalAmount, reason, activeWorkers }
    )
end

---Update session snapshot with current worker counts and multipliers
---@param workers table Active workers by job type
---@param multipliers table Current multipliers by job type
function UpdateSessionSnapshot(workers, multipliers)
    if not sessionId then return end
    MySQL.update('UPDATE job_orchestrator_sessions SET active_workers = ?, multipliers = ? WHERE id = ?',
        { json.encode(workers), json.encode(multipliers), sessionId }
    )
end

---Get payment statistics for a time period
---@param hours number Hours to look back (default 24)
---@return table stats Statistics grouped by job type
function GetPaymentStats(hours)
    hours = hours or 24
    local stats = MySQL.query.await([[
        SELECT
            job_type,
            COUNT(*) as completions,
            SUM(base_amount) as total_base,
            SUM(final_amount) as total_paid,
            AVG(multiplier) as avg_multiplier,
            SUM(CASE WHEN multiplier_reason = 'surge' THEN 1 ELSE 0 END) as surge_count,
            SUM(CASE WHEN multiplier_reason = 'normal' THEN 1 ELSE 0 END) as normal_count,
            SUM(CASE WHEN multiplier_reason = 'declining' THEN 1 ELSE 0 END) as declining_count,
            SUM(CASE WHEN multiplier_reason = 'saturated' THEN 1 ELSE 0 END) as saturated_count,
            SUM(CASE WHEN multiplier_reason = 'surge' THEN final_amount - base_amount ELSE 0 END) as surge_bonus_paid,
            SUM(CASE WHEN multiplier_reason = 'saturated' THEN base_amount - final_amount ELSE 0 END) as saturation_penalty
        FROM job_orchestrator_payments
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? HOUR)
        GROUP BY job_type
        ORDER BY completions DESC
    ]], { hours })

    return stats
end

---Get unique worker count for a time period
---@param hours number Hours to look back (default 24)
---@return number count Number of unique workers
function GetUniqueWorkerCount(hours)
    hours = hours or 24
    local count = MySQL.scalar.await([[
        SELECT COUNT(DISTINCT citizenid)
        FROM job_orchestrator_payments
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL ? HOUR)
    ]], { hours })

    return count or 0
end

---Get hourly breakdown for a job type
---@param jobType string The job type key
---@param hours number Hours to look back (default 24)
---@return table breakdown Hourly stats
function GetHourlyBreakdown(jobType, hours)
    hours = hours or 24
    local breakdown = MySQL.query.await([[
        SELECT * FROM view_job_hourly_stats
        WHERE job_type = ?
        AND hour_bucket >= DATE_SUB(NOW(), INTERVAL ? HOUR)
        ORDER BY hour_bucket DESC
    ]], { jobType, hours })

    return breakdown
end

-- Export functions
exports('LogPayment', LogPayment)
exports('GetPaymentStats', GetPaymentStats)
exports('GetUniqueWorkerCount', GetUniqueWorkerCount)
exports('GetHourlyBreakdown', GetHourlyBreakdown)
