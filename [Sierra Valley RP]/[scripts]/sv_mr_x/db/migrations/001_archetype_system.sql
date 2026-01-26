-- ============================================
-- MIGRATION 001: Enhanced Archetype System
-- Run this after the base mr_x_schema.sql
-- ============================================

-- Add new columns to mr_x_profiles for archetype classification
ALTER TABLE `mr_x_profiles`
    -- Primary bucket (AUTHORITY, CIVILIAN, CRIMINAL)
    ADD COLUMN `bucket` ENUM('authority', 'civilian', 'criminal') DEFAULT 'civilian' AFTER `archetype`,

    -- Alignment axes (GTA-flavored D&D alignment)
    ADD COLUMN `method_axis` ENUM('calculated', 'opportunistic', 'reckless') DEFAULT 'opportunistic' AFTER `bucket`,
    ADD COLUMN `loyalty_axis` ENUM('civic', 'self', 'crew') DEFAULT 'self' AFTER `method_axis`,

    -- Behavioral metrics for classification (updated over time)
    ADD COLUMN `behavior_metrics` JSON DEFAULT NULL COMMENT 'Tracked behaviors for archetype calculation' AFTER `loyalty_axis`,

    -- Last time archetype was recalculated
    ADD COLUMN `archetype_updated_at` TIMESTAMP NULL DEFAULT NULL AFTER `behavior_metrics`,

    -- Add index for new columns
    ADD INDEX `idx_bucket` (`bucket`),
    ADD INDEX `idx_archetype_combined` (`bucket`, `archetype`);

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
