-- ============================================
-- MR. X AGENT TOOLS MIGRATION
-- Adds tables for autonomous agent behavior
-- Run after mr_x_schema.sql
-- This migration is IDEMPOTENT - safe to run multiple times
-- ============================================

-- ============================================
-- TABLE: mr_x_action_queue
-- Delayed and scheduled actions for the agent
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_action_queue` (
    `id` VARCHAR(36) NOT NULL COMMENT 'UUID for action identification',
    `tool_name` VARCHAR(100) NOT NULL COMMENT 'Name of the tool to execute',
    `arguments` JSON NOT NULL COMMENT 'Arguments to pass to the tool',
    `context` JSON DEFAULT NULL COMMENT 'Execution context (trigger type, etc)',
    `scheduled_for` TIMESTAMP NOT NULL COMMENT 'When to execute this action',
    `executed_at` TIMESTAMP NULL DEFAULT NULL COMMENT 'When action was executed',
    `status` ENUM('pending', 'executing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
    `result` JSON DEFAULT NULL COMMENT 'Execution result',
    `depends_on` VARCHAR(36) DEFAULT NULL COMMENT 'Action ID that must complete first',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_scheduled_for` (`scheduled_for`),
    INDEX `idx_tool_name` (`tool_name`),
    INDEX `idx_depends_on` (`depends_on`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_tool_log
-- Execution log for all tool calls
-- Used for safety limits, analytics, and dashboard
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_tool_log` (
    `id` INT AUTO_INCREMENT,
    `tool_name` VARCHAR(100) NOT NULL COMMENT 'Name of the tool executed',
    `arguments` JSON DEFAULT NULL COMMENT 'Arguments passed to the tool',
    `target_citizenid` VARCHAR(50) DEFAULT NULL COMMENT 'Target player if applicable',
    `result` JSON DEFAULT NULL COMMENT 'Execution result',
    `success` TINYINT(1) DEFAULT 1 COMMENT 'Whether execution succeeded',
    `trigger_type` VARCHAR(50) DEFAULT NULL COMMENT 'What triggered this (login, message, mission, scheduled, manual)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_tool_name` (`tool_name`),
    INDEX `idx_target` (`target_citizenid`),
    INDEX `idx_success` (`success`),
    INDEX `idx_trigger_type` (`trigger_type`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_tool_target_date` (`tool_name`, `target_citizenid`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_safety_limits
-- Runtime tracking for safety rate limits
-- Used to prevent AI from going overboard
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_safety_limits` (
    `limit_type` VARCHAR(50) NOT NULL COMMENT 'Type of limit (bounty, hit_squad, etc)',
    `scope` VARCHAR(50) NOT NULL COMMENT 'Scope (global or citizenid)',
    `max_count` INT NOT NULL COMMENT 'Maximum allowed in time window',
    `time_window_seconds` INT DEFAULT 86400 COMMENT 'Time window in seconds (default 24h)',
    `current_count` INT DEFAULT 0 COMMENT 'Current count in window',
    `window_start` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When current window started',
    PRIMARY KEY (`limit_type`, `scope`),
    INDEX `idx_window_start` (`window_start`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INITIAL SAFETY LIMITS
-- Configure default limits
-- ============================================
INSERT IGNORE INTO `mr_x_safety_limits` (`limit_type`, `scope`, `max_count`, `time_window_seconds`) VALUES
-- Global daily limits
('place_bounty', 'global', 10, 86400),
('trigger_surprise', 'global', 5, 86400),
('hit_squad', 'global', 3, 86400),
('fake_warrant', 'global', 10, 86400),
('leak_location', 'global', 15, 86400),
('debt_collector', 'global', 5, 86400),
('send_message', 'global', 1200, 60),  -- 20/minute = 1200/hour

-- Bounty spending limit (amount, not count)
('bounty_spend', 'global', 100000, 86400),
('gift_spend', 'global', 50000, 86400),
('loan_disbursement', 'global', 500000, 86400);

-- ============================================
-- CLEANUP EVENT
-- Remove old completed/failed queue entries
-- ============================================
DELIMITER //
CREATE EVENT IF NOT EXISTS `mr_x_cleanup_action_queue`
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- Delete completed/failed/cancelled actions older than 7 days
    DELETE FROM `mr_x_action_queue`
    WHERE `status` IN ('completed', 'failed', 'cancelled')
      AND `created_at` < DATE_SUB(NOW(), INTERVAL 7 DAY);

    -- Delete old tool logs older than 30 days
    DELETE FROM `mr_x_tool_log`
    WHERE `created_at` < DATE_SUB(NOW(), INTERVAL 30 DAY);
END//
DELIMITER ;

-- ============================================
-- VIEWS FOR DASHBOARD
-- ============================================

-- Tool usage summary (last 24h)
CREATE OR REPLACE VIEW `mr_x_tool_usage_24h` AS
SELECT
    tool_name,
    COUNT(*) as total_calls,
    SUM(CASE WHEN success = 1 THEN 1 ELSE 0 END) as successful,
    SUM(CASE WHEN success = 0 THEN 1 ELSE 0 END) as failed,
    COUNT(DISTINCT target_citizenid) as unique_targets
FROM `mr_x_tool_log`
WHERE created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY tool_name
ORDER BY total_calls DESC;

-- Pending actions summary
CREATE OR REPLACE VIEW `mr_x_pending_actions` AS
SELECT
    id,
    tool_name,
    JSON_UNQUOTE(JSON_EXTRACT(arguments, '$.citizenid')) as target,
    scheduled_for,
    TIMESTAMPDIFF(MINUTE, NOW(), scheduled_for) as minutes_until
FROM `mr_x_action_queue`
WHERE status = 'pending'
ORDER BY scheduled_for ASC;

-- Most targeted players (last 24h)
CREATE OR REPLACE VIEW `mr_x_most_targeted_24h` AS
SELECT
    target_citizenid,
    COUNT(*) as action_count,
    GROUP_CONCAT(DISTINCT tool_name) as tools_used
FROM `mr_x_tool_log`
WHERE target_citizenid IS NOT NULL
  AND created_at > DATE_SUB(NOW(), INTERVAL 24 HOUR)
GROUP BY target_citizenid
ORDER BY action_count DESC
LIMIT 20;
