-- ============================================
-- Advanced MultiJob - Time Tracking Installation
-- ============================================
-- Run this file in your MySQL database to enable time tracking features
-- You can execute this via HeidiSQL, phpMyAdmin, or command line

-- Create the main clock-in logs table
CREATE TABLE IF NOT EXISTS `job_clockin_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `job` varchar(50) NOT NULL,
  `clockin_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `clockout_time` timestamp NULL DEFAULT NULL,
  `duration` int(11) DEFAULT NULL COMMENT 'Duration in seconds',
  `location` varchar(100) DEFAULT NULL COMMENT 'Clock-in location name',
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_job` (`job`),
  KEY `idx_clockin_time` (`clockin_time`),
  KEY `idx_citizenid_job` (`citizenid`, `job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create index for faster queries on recent work hours
CREATE INDEX IF NOT EXISTS `idx_recent_shifts` ON `job_clockin_logs` (`citizenid`, `clockin_time`, `duration`);

-- Create view for easy querying of complete shifts (with clock-out times)
CREATE OR REPLACE VIEW `view_completed_shifts` AS
SELECT
    `id`,
    `citizenid`,
    `job`,
    `clockin_time`,
    `clockout_time`,
    `duration`,
    `location`,
    ROUND(`duration` / 3600, 2) as `hours`,
    DATE(`clockin_time`) as `shift_date`
FROM `job_clockin_logs`
WHERE `clockout_time` IS NOT NULL AND `duration` IS NOT NULL;

-- Create view for players currently on duty
CREATE OR REPLACE VIEW `view_active_shifts` AS
SELECT
    `id`,
    `citizenid`,
    `job`,
    `clockin_time`,
    `location`,
    TIMESTAMPDIFF(SECOND, `clockin_time`, NOW()) as `duration_seconds`,
    ROUND(TIMESTAMPDIFF(SECOND, `clockin_time`, NOW()) / 3600, 2) as `hours`
FROM `job_clockin_logs`
WHERE `clockout_time` IS NULL;

-- ============================================
-- Installation Complete!
-- ============================================
-- You can now use the following queries to check your data:
--
-- View all active shifts:
-- SELECT * FROM view_active_shifts;
--
-- View completed shifts from last 7 days:
-- SELECT * FROM view_completed_shifts WHERE shift_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);
--
-- Get total hours for a player (replace 'ABC123' with citizenid):
-- SELECT job, SUM(duration)/3600 as total_hours FROM job_clockin_logs WHERE citizenid = 'ABC123' GROUP BY job;
-- ============================================
