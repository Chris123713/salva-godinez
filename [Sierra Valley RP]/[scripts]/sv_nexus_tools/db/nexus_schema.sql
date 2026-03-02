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
-- ELEMENT LIBRARY (Reusable Mission Assets)
-- ============================================

-- Core element storage - reusable placement points
CREATE TABLE IF NOT EXISTS `nexus_elements` (
    `id` VARCHAR(36) PRIMARY KEY,
    `element_type` ENUM('npc', 'vehicle', 'prop', 'zone') NOT NULL,
    `model` VARCHAR(100),
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `heading` FLOAT DEFAULT 0.0,
    `radius` FLOAT DEFAULT NULL COMMENT 'For zone-type elements',

    `source_mission_id` VARCHAR(36),
    `source_blueprint_id` VARCHAR(36),

    `reusable` BOOLEAN DEFAULT TRUE,
    `verified` BOOLEAN DEFAULT FALSE,
    `quality_score` FLOAT DEFAULT 0.5 COMMENT '0-1 based on usage success',

    `primary_tag` VARCHAR(50),
    `location_tag` VARCHAR(50),
    `notes` TEXT,
    `created_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX `idx_type` (`element_type`),
    INDEX `idx_tags` (`primary_tag`, `location_tag`),
    INDEX `idx_reusable` (`reusable`, `verified`),
    INDEX `idx_quality` (`quality_score`),
    INDEX `idx_coords` (`coords_x`, `coords_y`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Multi-tag junction table for flexible tagging
CREATE TABLE IF NOT EXISTS `nexus_element_tags` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `element_id` VARCHAR(36) NOT NULL,
    `tag_name` VARCHAR(50) NOT NULL,
    `tag_category` ENUM('role', 'location', 'use_case', 'scenario', 'custom') NOT NULL,
    `weight` FLOAT DEFAULT 1.0 COMMENT 'Tag relevance weight',

    UNIQUE KEY `uk_element_tag` (`element_id`, `tag_name`),
    INDEX `idx_tag_name` (`tag_name`),
    INDEX `idx_tag_category` (`tag_category`),
    FOREIGN KEY (`element_id`) REFERENCES `nexus_elements`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Track element usage across missions for quality scoring
CREATE TABLE IF NOT EXISTS `nexus_element_usage` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `element_id` VARCHAR(36) NOT NULL,
    `mission_id` VARCHAR(36) NOT NULL,
    `role_in_mission` VARCHAR(100) NOT NULL,
    `spawned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `was_successful` BOOLEAN COMMENT 'Mission completed successfully',

    UNIQUE KEY `uk_element_mission` (`element_id`, `mission_id`),
    INDEX `idx_element` (`element_id`),
    INDEX `idx_mission` (`mission_id`),
    FOREIGN KEY (`element_id`) REFERENCES `nexus_elements`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- MISSION PATTERNS (Template Definitions)
-- ============================================

CREATE TABLE IF NOT EXISTS `nexus_mission_patterns` (
    `id` VARCHAR(36) PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `category` ENUM('heist', 'escort', 'pursuit', 'stealth', 'investigation',
                    'sabotage', 'surveillance', 'extraction', 'ambush',
                    'cleanup', 'territory', 'courier') NOT NULL,

    `phases` JSON NOT NULL COMMENT 'Array of phase names and requirements',
    `required_elements` JSON NOT NULL COMMENT 'Element types needed',
    `optional_elements` JSON COMMENT 'Nice-to-have elements',

    `min_players` INT DEFAULT 1,
    `max_players` INT DEFAULT 4,
    `role_definitions` JSON COMMENT 'Available roles for multi-player',

    `compatible_modifiers` JSON COMMENT 'Modifiers that work with this pattern',

    `generation_hints` TEXT COMMENT 'Tips for LLM when generating this pattern',
    `example_brief` TEXT COMMENT 'Example mission brief',

    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_category` (`category`),
    INDEX `idx_players` (`min_players`, `max_players`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- MULTI-PLAYER MISSION SUPPORT
-- ============================================

-- Handoff points for baton-pass missions
CREATE TABLE IF NOT EXISTS `nexus_handoff_points` (
    `id` VARCHAR(36) PRIMARY KEY,
    `mission_id` VARCHAR(36) NOT NULL,
    `coords` JSON NOT NULL,
    `item_name` VARCHAR(100) NOT NULL,
    `from_citizenid` VARCHAR(50) NOT NULL,
    `to_citizenid` VARCHAR(50) NOT NULL,
    `status` ENUM('pending', 'dropped', 'picked_up', 'expired') DEFAULT 'pending',
    `dropped_at` TIMESTAMP NULL,
    `picked_up_at` TIMESTAMP NULL,
    `expires_at` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX `idx_mission` (`mission_id`),
    INDEX `idx_from` (`from_citizenid`),
    INDEX `idx_to` (`to_citizenid`),
    INDEX `idx_status` (`status`),
    FOREIGN KEY (`mission_id`) REFERENCES `nexus_missions`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Isolated scenes (routing bucket tracking)
CREATE TABLE IF NOT EXISTS `nexus_isolated_scenes` (
    `id` VARCHAR(36) PRIMARY KEY,
    `scene_id` VARCHAR(100) NOT NULL UNIQUE,
    `bucket_id` INT NOT NULL,
    `weather` VARCHAR(50),
    `hour` INT,
    `exit_coords` JSON COMMENT 'Auto-exit when reaching these coords',
    `exit_radius` FLOAT DEFAULT 50.0,
    `status` ENUM('active', 'ended') DEFAULT 'active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ended_at` TIMESTAMP NULL,

    INDEX `idx_scene_id` (`scene_id`),
    INDEX `idx_bucket` (`bucket_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Players in isolated scenes
CREATE TABLE IF NOT EXISTS `nexus_isolated_scene_players` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `scene_db_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `original_bucket` INT DEFAULT 0,
    `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `left_at` TIMESTAMP NULL,

    UNIQUE KEY `uk_scene_player` (`scene_db_id`, `citizenid`),
    FOREIGN KEY (`scene_db_id`) REFERENCES `nexus_isolated_scenes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Element placement requests (human-assisted workflow)
CREATE TABLE IF NOT EXISTS `nexus_placement_requests` (
    `id` VARCHAR(36) PRIMARY KEY,
    `mission_draft_id` VARCHAR(36),
    `element_type` ENUM('npc', 'vehicle', 'prop', 'zone') NOT NULL,
    `requirements` TEXT NOT NULL,
    `suggested_tags` JSON,
    `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
    `status` ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    `assigned_to` VARCHAR(50),
    `result_element_id` VARCHAR(36),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL,

    INDEX `idx_status` (`status`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_assigned` (`assigned_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Mission drafts (LLM-generated specs awaiting human placement)
CREATE TABLE IF NOT EXISTS `nexus_mission_drafts` (
    `id` VARCHAR(36) PRIMARY KEY,
    `type` VARCHAR(50) NOT NULL,
    `synopsis` TEXT,
    `story_brief` TEXT,
    `intended_outcomes` JSON,
    `area_coords` JSON,
    `required_assets` JSON COMMENT 'Checklist of assets to place',
    `pattern_id` VARCHAR(36),
    `target_archetype` VARCHAR(50),
    `status` ENUM('draft', 'placing', 'ready', 'instantiated', 'cancelled') DEFAULT 'draft',
    `created_by` VARCHAR(50),
    `placed_by` VARCHAR(50),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ready_at` TIMESTAMP NULL,

    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- MODIFY EXISTING TABLES
-- ============================================

-- Add multi-player role fields to participants
ALTER TABLE `nexus_mission_participants`
ADD COLUMN `role_type` ENUM('cooperative', 'baton_pass', 'adversarial') DEFAULT 'cooperative' AFTER `role`,
ADD COLUMN `linked_participant_id` INT DEFAULT NULL AFTER `role_type`,
ADD COLUMN `handoff_item` VARCHAR(100) DEFAULT NULL AFTER `linked_participant_id`,
ADD COLUMN `handoff_completed` BOOLEAN DEFAULT FALSE AFTER `handoff_item`;

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

-- View for high-quality reusable elements
CREATE OR REPLACE VIEW `nexus_reusable_elements_view` AS
SELECT
    e.id,
    e.element_type,
    e.model,
    e.coords_x,
    e.coords_y,
    e.coords_z,
    e.heading,
    e.primary_tag,
    e.location_tag,
    e.quality_score,
    COUNT(u.id) as usage_count,
    SUM(CASE WHEN u.was_successful = TRUE THEN 1 ELSE 0 END) as successful_uses,
    GROUP_CONCAT(DISTINCT t.tag_name) as all_tags
FROM nexus_elements e
LEFT JOIN nexus_element_usage u ON e.id = u.element_id
LEFT JOIN nexus_element_tags t ON e.id = t.element_id
WHERE e.reusable = TRUE AND e.verified = TRUE
GROUP BY e.id
ORDER BY e.quality_score DESC, usage_count DESC;

-- View for pending placement requests
CREATE OR REPLACE VIEW `nexus_pending_placements_view` AS
SELECT
    pr.id,
    pr.element_type,
    pr.requirements,
    pr.priority,
    pr.created_at,
    md.type as mission_type,
    md.synopsis
FROM nexus_placement_requests pr
LEFT JOIN nexus_mission_drafts md ON pr.mission_draft_id = md.id
WHERE pr.status = 'pending'
ORDER BY
    CASE pr.priority
        WHEN 'urgent' THEN 1
        WHEN 'high' THEN 2
        WHEN 'normal' THEN 3
        WHEN 'low' THEN 4
    END,
    pr.created_at ASC;

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

    -- Expire handoff points
    UPDATE nexus_handoff_points SET status = 'expired'
    WHERE expires_at < NOW() AND status IN ('pending', 'dropped');

    -- End stale isolated scenes (12 hours old)
    UPDATE nexus_isolated_scenes SET status = 'ended', ended_at = NOW()
    WHERE status = 'active' AND created_at < NOW() - INTERVAL 12 HOUR;

    -- Cancel old placement requests (7 days)
    UPDATE nexus_placement_requests SET status = 'cancelled'
    WHERE status = 'pending' AND created_at < NOW() - INTERVAL 7 DAY;

    -- Cancel old mission drafts (14 days)
    UPDATE nexus_mission_drafts SET status = 'cancelled'
    WHERE status IN ('draft', 'placing') AND created_at < NOW() - INTERVAL 14 DAY;

    -- Update element quality scores based on usage success rate
    UPDATE nexus_elements e
    SET quality_score = (
        SELECT COALESCE(
            (SUM(CASE WHEN u.was_successful = TRUE THEN 1.0 ELSE 0.0 END) / COUNT(u.id)),
            0.5
        )
        FROM nexus_element_usage u
        WHERE u.element_id = e.id
    )
    WHERE EXISTS (SELECT 1 FROM nexus_element_usage u WHERE u.element_id = e.id);
END //
DELIMITER ;

-- ============================================
-- ELEMENT QUALITY SCORING TRIGGER
-- ============================================

DELIMITER //
CREATE TRIGGER IF NOT EXISTS `trg_element_usage_quality`
AFTER INSERT ON `nexus_element_usage`
FOR EACH ROW
BEGIN
    -- Update quality score when new usage is recorded
    IF NEW.was_successful IS NOT NULL THEN
        UPDATE nexus_elements
        SET quality_score = (
            SELECT (SUM(CASE WHEN was_successful = TRUE THEN 1.0 ELSE 0.0 END) / COUNT(*))
            FROM nexus_element_usage
            WHERE element_id = NEW.element_id
        )
        WHERE id = NEW.element_id;
    END IF;
END //
DELIMITER ;
