-- ============================================
-- MIGRATION 001: Enhanced Archetype System
-- Run this after the base mr_x_schema.sql
-- This migration is IDEMPOTENT - safe to run multiple times
-- ============================================

-- Drop and recreate stored procedure for safe column addition
DROP PROCEDURE IF EXISTS AddColumnIfNotExists;
DELIMITER //
CREATE PROCEDURE AddColumnIfNotExists(
    IN tableName VARCHAR(64),
    IN colName VARCHAR(64),
    IN colDef VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = tableName
          AND COLUMN_NAME = colName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` ADD COLUMN `', colName, '` ', colDef);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

-- Add new columns to mr_x_profiles for archetype classification (if they don't exist)
CALL AddColumnIfNotExists('mr_x_profiles', 'bucket', "ENUM('authority', 'civilian', 'criminal') DEFAULT 'civilian' AFTER `archetype`");
CALL AddColumnIfNotExists('mr_x_profiles', 'method_axis', "ENUM('calculated', 'opportunistic', 'reckless') DEFAULT 'opportunistic' AFTER `bucket`");
CALL AddColumnIfNotExists('mr_x_profiles', 'loyalty_axis', "ENUM('civic', 'self', 'crew') DEFAULT 'self' AFTER `method_axis`");
CALL AddColumnIfNotExists('mr_x_profiles', 'behavior_metrics', "JSON DEFAULT NULL COMMENT 'Tracked behaviors for archetype calculation' AFTER `loyalty_axis`");
CALL AddColumnIfNotExists('mr_x_profiles', 'archetype_updated_at', "TIMESTAMP NULL DEFAULT NULL AFTER `behavior_metrics`");

-- Add indexes if they don't exist (MySQL will error on duplicate, but we ignore it)
-- Use a procedure to safely add indexes
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;
DELIMITER //
CREATE PROCEDURE AddIndexIfNotExists(
    IN tableName VARCHAR(64),
    IN indexName VARCHAR(64),
    IN indexDef VARCHAR(255)
)
BEGIN
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = tableName
          AND INDEX_NAME = indexName
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tableName, '` ADD INDEX `', indexName, '` ', indexDef);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL AddIndexIfNotExists('mr_x_profiles', 'idx_bucket', '(`bucket`)');
CALL AddIndexIfNotExists('mr_x_profiles', 'idx_archetype_combined', '(`bucket`, `archetype`)');

-- Cleanup helper procedures
DROP PROCEDURE IF EXISTS AddColumnIfNotExists;
DROP PROCEDURE IF EXISTS AddIndexIfNotExists;

-- Create table for gang eligibility cache (synced from brutal_gangs)
CREATE TABLE IF NOT EXISTS `mr_x_eligible_gangs` (
    `gang_name` VARCHAR(50) NOT NULL COMMENT 'Gang identifier from brutal_gangs',
    `gang_label` VARCHAR(100) DEFAULT NULL COMMENT 'Display name',
    `hq_name` VARCHAR(50) DEFAULT NULL COMMENT 'HQ location key from brutal_gangs config',
    `is_eligible` TINYINT(1) DEFAULT 1 COMMENT 'Whether gang members can receive bounty offers',
    `cached_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`gang_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed with known gangs from brutal_gangs config HQS
INSERT INTO `mr_x_eligible_gangs` (`gang_name`, `gang_label`, `hq_name`, `is_eligible`) VALUES
    ('ballas', 'Ballas', 'ballas', 1),
    ('triads', 'Triads', 'triads', 1),
    ('vagos', 'Vagos', 'vagos', 1),
    ('lostmc', 'The Lost MC', 'lostmc', 1),
    ('families', 'Families', 'families', 1),
    ('devilschildren', 'Devils Children MC', 'devilschildren', 1),
    ('sonsofanarchy', 'Sons of Anarchy', 'sonsofanarchy', 1),
    ('aztecas', 'Aztecas', 'aztecas', 1)
ON DUPLICATE KEY UPDATE
    `gang_label` = VALUES(`gang_label`),
    `hq_name` = VALUES(`hq_name`);

-- Table to track behavioral events for archetype calculation
CREATE TABLE IF NOT EXISTS `mr_x_behavior_events` (
    `id` INT AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `event_category` ENUM(
        'violence',       -- Kills, assaults, weapon use
        'stealth',        -- Clean missions, no witnesses
        'trade',          -- Large transactions, smuggling
        'loyalty_crew',   -- Gang activity, team missions
        'loyalty_self',   -- Solo activity, betrayals
        'loyalty_civic',  -- Legal job activity, helping NPCs
        'reckless',       -- High heat, collateral damage
        'calculated',     -- Clean execution, planning
        'opportunistic'   -- Mixed approach
    ) NOT NULL,
    `event_type` VARCHAR(50) NOT NULL COMMENT 'Specific event (e.g., kill, heist_clean, drug_sale)',
    `weight` DECIMAL(3,2) DEFAULT 1.00 COMMENT 'How much this counts toward classification',
    `context` JSON DEFAULT NULL COMMENT 'Additional event context',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_category` (`event_category`),
    INDEX `idx_created` (`created_at`),
    CONSTRAINT `fk_behavior_profile` FOREIGN KEY (`citizenid`)
        REFERENCES `mr_x_profiles` (`citizenid`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Update existing profiles to have default behavior_metrics
UPDATE `mr_x_profiles`
SET `behavior_metrics` = JSON_OBJECT(
    'violence_score', 0,
    'stealth_score', 0,
    'trade_score', 0,
    'crew_loyalty', 0,
    'self_interest', 0,
    'civic_duty', 0,
    'reckless_score', 0,
    'calculated_score', 0,
    'total_events', 0,
    'last_calculated', UNIX_TIMESTAMP()
)
WHERE `behavior_metrics` IS NULL;
