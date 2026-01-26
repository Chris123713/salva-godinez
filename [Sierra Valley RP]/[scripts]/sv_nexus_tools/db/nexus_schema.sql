-- sv_nexus_tools Database Schema
-- Run this SQL to create all required tables for the Nexus AI toolbox

-- ============================================
-- CORE MISSION TRACKING
-- ============================================

CREATE TABLE IF NOT EXISTS `nexus_missions` (
    `id` VARCHAR(36) PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL,
    `brief` TEXT,
    `area_coords` JSON,
    `status` ENUM('setup', 'active', 'completed', 'failed', 'cancelled') DEFAULT 'setup',
    `created_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nexus_mission_participants` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `mission_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `role` VARCHAR(50) NOT NULL,
    `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `left_at` TIMESTAMP NULL,
    UNIQUE KEY `uk_mission_player` (`mission_id`, `citizenid`),
    INDEX `idx_citizenid` (`citizenid`),
    FOREIGN KEY (`mission_id`) REFERENCES `nexus_missions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nexus_mission_objectives` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `mission_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `objective_id` VARCHAR(100) NOT NULL,
    `status` ENUM('pending', 'in_progress', 'completed', 'failed', 'locked') DEFAULT 'pending',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_objective` (`mission_id`, `citizenid`, `objective_id`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`mission_id`) REFERENCES `nexus_missions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- CRIMINAL TOOLS
-- ============================================

-- Vehicle trackers for tracking objectives
CREATE TABLE IF NOT EXISTS `nexus_vehicle_trackers` (
    `id` VARCHAR(36) PRIMARY KEY,
    `plate` VARCHAR(20) NOT NULL,
    `vehicle_model` VARCHAR(50),
    `mission_id` VARCHAR(36),
    `placed_by` VARCHAR(50) NOT NULL,
    `faction` VARCHAR(50),
    `last_coords` JSON,
    `last_update` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `status` ENUM('active', 'removed', 'destroyed') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_plate` (`plate`),
    INDEX `idx_status` (`status`),
    INDEX `idx_faction` (`faction`),
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Forged identities for undercover missions
CREATE TABLE IF NOT EXISTS `nexus_forged_identities` (
    `id` VARCHAR(36) PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `fake_name` VARCHAR(100) NOT NULL,
    `fake_dob` VARCHAR(20),
    `fake_address` VARCHAR(255),
    `document_type` VARCHAR(50) DEFAULT 'drivers_license',
    `quality` ENUM('poor', 'average', 'good', 'excellent') DEFAULT 'average',
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `used_count` INT DEFAULT 0,
    `detected_count` INT DEFAULT 0,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Hostage situations for tracking negotiations
CREATE TABLE IF NOT EXISTS `nexus_hostage_situations` (
    `id` VARCHAR(36) PRIMARY KEY,
    `mission_id` VARCHAR(36),
    `coords` JSON NOT NULL,
    `hostage_count` INT DEFAULT 1,
    `demands` TEXT,
    `status` ENUM('active', 'negotiating', 'resolved', 'failed') DEFAULT 'active',
    `created_by` VARCHAR(50),
    `resolved_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` TIMESTAMP NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- POLICE & EMERGENCY TOOLS
-- ============================================

-- Evidence collection tracking
CREATE TABLE IF NOT EXISTS `nexus_evidence` (
    `evidence_id` VARCHAR(36) PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL,
    `description` TEXT,
    `coords` JSON,
    `linked_to` VARCHAR(50) COMMENT 'citizenid of suspect if linked',
    `mission_id` VARCHAR(36),
    `status` ENUM('uncollected', 'collected', 'processed', 'destroyed') DEFAULT 'uncollected',
    `collected_by` VARCHAR(50),
    `collected_at` TIMESTAMP NULL,
    `processed_by` VARCHAR(50),
    `processed_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_mission` (`mission_id`),
    INDEX `idx_linked` (`linked_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Crime scene tracking
CREATE TABLE IF NOT EXISTS `nexus_crime_scenes` (
    `id` VARCHAR(36) PRIMARY KEY,
    `crime_type` VARCHAR(50) NOT NULL,
    `coords` JSON NOT NULL,
    `radius` FLOAT DEFAULT 25.0,
    `mission_id` VARCHAR(36),
    `status` ENUM('active', 'investigated', 'closed') DEFAULT 'active',
    `lead_investigator` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `closed_at` TIMESTAMP NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`crime_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- BOLO tracking (extends wsb_mdt_bolos)
CREATE TABLE IF NOT EXISTS `nexus_bolos` (
    `id` VARCHAR(36) PRIMARY KEY,
    `type` ENUM('vehicle', 'person') NOT NULL,
    `description` TEXT NOT NULL,
    `plate` VARCHAR(20),
    `vehicle_model` VARCHAR(50),
    `suspect_description` TEXT,
    `last_seen_coords` JSON,
    `priority` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    `created_by` VARCHAR(50) NOT NULL,
    `status` ENUM('active', 'located', 'cancelled') DEFAULT 'active',
    `located_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` TIMESTAMP NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Lockdown zones
CREATE TABLE IF NOT EXISTS `nexus_lockdowns` (
    `id` VARCHAR(36) PRIMARY KEY,
    `coords` JSON NOT NULL,
    `radius` FLOAT DEFAULT 50.0,
    `reason` VARCHAR(255),
    `police_only` BOOLEAN DEFAULT TRUE,
    `created_by` VARCHAR(50),
    `status` ENUM('active', 'expired', 'cancelled') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL,
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- SOCIAL & FACTION TOOLS
-- ============================================

-- Rumor system tracking
CREATE TABLE IF NOT EXISTS `nexus_rumors` (
    `id` VARCHAR(36) PRIMARY KEY,
    `content` TEXT NOT NULL,
    `linked_info` TEXT COMMENT 'Intel attached to rumor',
    `origin_coords` JSON,
    `spread_radius` FLOAT DEFAULT 50.0,
    `mission_id` VARCHAR(36),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL,
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `nexus_rumor_heard` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `rumor_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `heard_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_rumor_player` (`rumor_id`, `citizenid`),
    FOREIGN KEY (`rumor_id`) REFERENCES `nexus_rumors`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Informant interactions
CREATE TABLE IF NOT EXISTS `nexus_informant_interactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `informant_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `info_type` VARCHAR(50),
    `info_content` TEXT,
    `price_paid` INT DEFAULT 0,
    `mission_id` VARCHAR(36),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_informant` (`informant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Meeting system
CREATE TABLE IF NOT EXISTS `nexus_meetings` (
    `id` VARCHAR(36) PRIMARY KEY,
    `title` VARCHAR(255),
    `coords` JSON NOT NULL,
    `radius` FLOAT DEFAULT 10.0,
    `required_parties` JSON COMMENT 'Array of citizenids required',
    `current_parties` JSON COMMENT 'Array of citizenids present',
    `mission_id` VARCHAR(36),
    `status` ENUM('pending', 'in_progress', 'completed', 'failed') DEFAULT 'pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,
    INDEX `idx_status` (`status`),
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Bounty system
CREATE TABLE IF NOT EXISTS `nexus_bounties` (
    `id` VARCHAR(36) PRIMARY KEY,
    `target_citizenid` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `reason` TEXT,
    `posted_by` VARCHAR(50) NOT NULL,
    `faction` VARCHAR(50),
    `anonymous` BOOLEAN DEFAULT TRUE,
    `status` ENUM('active', 'claimed', 'cancelled', 'expired') DEFAULT 'active',
    `claimed_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL,
    `claimed_at` TIMESTAMP NULL,
    INDEX `idx_target` (`target_citizenid`),
    INDEX `idx_status` (`status`),
    INDEX `idx_faction` (`faction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Faction reputation adjustments
CREATE TABLE IF NOT EXISTS `nexus_faction_rep_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `faction` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL,
    `reason` VARCHAR(255),
    `mission_id` VARCHAR(36),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_faction` (`faction`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- WORLD & ECONOMY TOOLS
-- ============================================

-- Delivery tasks
CREATE TABLE IF NOT EXISTS `nexus_deliveries` (
    `id` VARCHAR(36) PRIMARY KEY,
    `assigned_to` VARCHAR(50) NOT NULL,
    `pickup_coords` JSON NOT NULL,
    `dropoff_coords` JSON NOT NULL,
    `item_name` VARCHAR(100) NOT NULL,
    `item_count` INT DEFAULT 1,
    `reward_amount` INT DEFAULT 0,
    `mission_id` VARCHAR(36),
    `status` ENUM('pending', 'picked_up', 'delivered', 'failed') DEFAULT 'pending',
    `picked_up_at` TIMESTAMP NULL,
    `delivered_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_assigned` (`assigned_to`),
    INDEX `idx_status` (`status`),
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ambient events log
CREATE TABLE IF NOT EXISTS `nexus_ambient_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `event_type` VARCHAR(50) NOT NULL,
    `coords` JSON NOT NULL,
    `mission_id` VARCHAR(36),
    `responded_by` VARCHAR(50),
    `status` ENUM('active', 'responded', 'resolved', 'expired') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `resolved_at` TIMESTAMP NULL,
    INDEX `idx_type` (`event_type`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customer/trade interactions
CREATE TABLE IF NOT EXISTS `nexus_customer_trades` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `item_wanted` VARCHAR(100),
    `item_count` INT DEFAULT 1,
    `payment_amount` INT DEFAULT 0,
    `mission_id` VARCHAR(36),
    `status` ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_customer` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Witness events
CREATE TABLE IF NOT EXISTS `nexus_witness_events` (
    `id` VARCHAR(36) PRIMARY KEY,
    `witness_net_id` INT,
    `coords` JSON NOT NULL,
    `info_type` VARCHAR(50),
    `info_content` TEXT,
    `related_citizenid` VARCHAR(50) COMMENT 'Who the info is about',
    `mission_id` VARCHAR(36),
    `interviewed_by` VARCHAR(50),
    `status` ENUM('active', 'interviewed', 'fled') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_mission` (`mission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- ACTIVITY TRACKING (for integrations)
-- ============================================

-- Activity log from integrated scripts
CREATE TABLE IF NOT EXISTS `nexus_activity_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `event_type` VARCHAR(50) NOT NULL,
    `citizenid` VARCHAR(50),
    `data` JSON,
    `coords` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_event_type` (`event_type`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Reactive trigger cooldowns
CREATE TABLE IF NOT EXISTS `nexus_trigger_cooldowns` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `trigger_name` VARCHAR(100) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `expires_at` TIMESTAMP NOT NULL,
    UNIQUE KEY `uk_trigger_player` (`trigger_name`, `citizenid`),
    INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- AI & BLUEPRINT MANAGEMENT
-- ============================================

-- AI generated missions log
CREATE TABLE IF NOT EXISTS `nexus_ai_generations` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `request_type` VARCHAR(50) NOT NULL,
    `prompt` TEXT,
    `response` TEXT,
    `tokens_used` INT DEFAULT 0,
    `model` VARCHAR(50),
    `source` INT COMMENT 'Player source who requested',
    `success` BOOLEAN DEFAULT TRUE,
    `error` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_type` (`request_type`),
    INDEX `idx_success` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Saved blueprints (admin-curated missions)
CREATE TABLE IF NOT EXISTS `nexus_blueprints` (
    `id` VARCHAR(36) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `brief` TEXT,
    `area_coords` JSON,
    `elements` JSON COMMENT 'NPCs, vehicles, props',
    `objectives` JSON COMMENT 'Role-based objectives',
    `created_by` VARCHAR(50),
    `approved` BOOLEAN DEFAULT FALSE,
    `use_count` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_type` (`type`),
    INDEX `idx_approved` (`approved`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- CLEANUP VIEWS
-- ============================================

-- View for active missions with participant count
CREATE OR REPLACE VIEW `nexus_active_missions_view` AS
SELECT
    m.id,
    m.type,
    m.brief,
    m.status,
    m.created_at,
    COUNT(DISTINCT p.citizenid) as participant_count
FROM nexus_missions m
LEFT JOIN nexus_mission_participants p ON m.id = p.mission_id AND p.left_at IS NULL
WHERE m.status IN ('setup', 'active')
GROUP BY m.id;

-- View for player mission history
CREATE OR REPLACE VIEW `nexus_player_history_view` AS
SELECT
    p.citizenid,
    m.id as mission_id,
    m.type,
    p.role,
    m.status as mission_status,
    COUNT(CASE WHEN o.status = 'completed' THEN 1 END) as objectives_completed,
    COUNT(o.id) as total_objectives,
    p.joined_at,
    p.left_at
FROM nexus_mission_participants p
JOIN nexus_missions m ON p.mission_id = m.id
LEFT JOIN nexus_mission_objectives o ON m.id = o.mission_id AND p.citizenid = o.citizenid
GROUP BY p.citizenid, m.id;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Ensure we have proper indexes for common queries
-- (Most are already defined inline above)

-- ============================================
-- SCHEDULED CLEANUP (run via cron or scheduled task)
-- ============================================

-- Example cleanup procedure (call periodically)
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS `nexus_cleanup_expired`()
BEGIN
    -- Expire old forged identities
    DELETE FROM nexus_forged_identities WHERE expires_at < NOW() - INTERVAL 1 DAY;

    -- Mark expired lockdowns
    UPDATE nexus_lockdowns SET status = 'expired' WHERE expires_at < NOW() AND status = 'active';

    -- Expire old bounties (30 days)
    UPDATE nexus_bounties SET status = 'expired' WHERE expires_at < NOW() AND status = 'active';

    -- Clean up old AI generation logs (keep 30 days)
    DELETE FROM nexus_ai_generations WHERE created_at < NOW() - INTERVAL 30 DAY;

    -- Archive completed missions older than 7 days
    UPDATE nexus_missions SET status = 'completed'
    WHERE status = 'active' AND created_at < NOW() - INTERVAL 7 DAY;
END //
DELIMITER ;
