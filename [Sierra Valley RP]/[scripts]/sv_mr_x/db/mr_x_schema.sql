-- ============================================
-- MR. X DATABASE SCHEMA
-- Run this SQL against your FiveM database
-- ============================================

-- ============================================
-- TABLE: mr_x_profiles
-- Player profiles with reputation and history
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_profiles` (
    `citizenid` VARCHAR(50) NOT NULL,
    `reputation` INT DEFAULT 0,
    `archetype` VARCHAR(50) DEFAULT 'civilian',
    `history` JSON DEFAULT NULL COMMENT 'Array of past mission outcomes',
    `known_facts` JSON DEFAULT NULL COMMENT 'Facts Mr. X knows about this player',
    `vector` JSON DEFAULT NULL COMMENT 'Embedding vector for AI personalization',
    `last_contact` TIMESTAMP NULL DEFAULT NULL,
    `last_mission` TIMESTAMP NULL DEFAULT NULL,
    `total_missions` INT DEFAULT 0,
    `successful_missions` INT DEFAULT 0,
    `total_loans` INT DEFAULT 0,
    `active_loan_id` INT DEFAULT NULL,
    `opted_out` TINYINT(1) DEFAULT 0 COMMENT 'Whether player has opted out of Mr. X (1 = opted out)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`citizenid`),
    INDEX `idx_reputation` (`reputation`),
    INDEX `idx_archetype` (`archetype`),
    INDEX `idx_last_contact` (`last_contact`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_sessions
-- Active conversation sessions with Mr. X
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_sessions` (
    `session_id` VARCHAR(36) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `exchange_count` INT DEFAULT 0,
    `started_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_message_at` TIMESTAMP NULL DEFAULT NULL,
    `context` JSON DEFAULT NULL COMMENT 'Conversation context for AI continuity',
    `status` ENUM('active', 'completed', 'timeout') DEFAULT 'active',
    `channel` VARCHAR(20) DEFAULT 'sms' COMMENT 'Communication channel used',
    PRIMARY KEY (`session_id`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_status` (`status`),
    INDEX `idx_last_message` (`last_message_at`),
    CONSTRAINT `fk_session_profile` FOREIGN KEY (`citizenid`)
        REFERENCES `mr_x_profiles` (`citizenid`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_events
-- Activity logging for audit and analytics
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_events` (
    `id` INT AUTO_INCREMENT,
    `citizenid` VARCHAR(50) DEFAULT NULL,
    `event_type` VARCHAR(50) NOT NULL,
    `data` JSON DEFAULT NULL COMMENT 'Event-specific data',
    `source` INT DEFAULT NULL COMMENT 'Server source ID if applicable',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_event_type` (`event_type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_bounties
-- Active and historical bounties on players
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_bounties` (
    `id` INT AUTO_INCREMENT,
    `target_cid` VARCHAR(50) NOT NULL COMMENT 'Citizenid of bounty target',
    `amount` INT NOT NULL,
    `reason` TEXT DEFAULT NULL COMMENT 'Why the bounty was placed',
    `posted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `status` ENUM('active', 'accepted', 'claimed', 'expired', 'cancelled') DEFAULT 'active',
    `posted_by` VARCHAR(50) DEFAULT 'mr_x' COMMENT 'Who posted (mr_x or citizenid)',
    `accepted_by` VARCHAR(50) DEFAULT NULL COMMENT 'Citizenid who accepted',
    `accepted_at` TIMESTAMP NULL DEFAULT NULL,
    `claimed_by` VARCHAR(50) DEFAULT NULL COMMENT 'Citizenid who completed',
    `claimed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_target` (`target_cid`),
    INDEX `idx_status` (`status`),
    INDEX `idx_posted_at` (`posted_at`),
    INDEX `idx_accepted_by` (`accepted_by`),
    CONSTRAINT `fk_bounty_target` FOREIGN KEY (`target_cid`)
        REFERENCES `mr_x_profiles` (`citizenid`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_loans
-- Emergency loans with interest tracking
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_loans` (
    `id` INT AUTO_INCREMENT,
    `citizenid` VARCHAR(50) NOT NULL,
    `amount` INT NOT NULL COMMENT 'Principal amount',
    `interest` INT NOT NULL COMMENT 'Interest amount due',
    `total_due` INT GENERATED ALWAYS AS (`amount` + `interest`) STORED,
    `issued_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `due_at` TIMESTAMP NOT NULL,
    `paid_at` TIMESTAMP NULL DEFAULT NULL,
    `status` ENUM('active', 'paid', 'overdue', 'defaulted') DEFAULT 'active',
    `reminder_sent` TINYINT(1) DEFAULT 0,
    `collection_attempts` INT DEFAULT 0,
    PRIMARY KEY (`id`),
    INDEX `idx_citizenid` (`citizenid`),
    INDEX `idx_status` (`status`),
    INDEX `idx_due_at` (`due_at`),
    CONSTRAINT `fk_loan_profile` FOREIGN KEY (`citizenid`)
        REFERENCES `mr_x_profiles` (`citizenid`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: mr_x_gang_relations
-- Track gang betrayal state for same-gang attacks
-- ============================================
CREATE TABLE IF NOT EXISTS `mr_x_gang_relations` (
    `id` INT AUTO_INCREMENT,
    `instigator_cid` VARCHAR(50) NOT NULL COMMENT 'Who Mr. X contacted to betray',
    `target_cid` VARCHAR(50) NOT NULL COMMENT 'The betrayal target',
    `gang` VARCHAR(50) NOT NULL COMMENT 'The gang both belong to',
    `amount` INT NOT NULL COMMENT 'Payment offered',
    `status` ENUM('offered', 'accepted', 'completed', 'declined', 'expired') DEFAULT 'offered',
    `offered_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NULL DEFAULT NULL,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_instigator` (`instigator_cid`),
    INDEX `idx_target` (`target_cid`),
    INDEX `idx_gang` (`gang`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TRIGGERS
-- ============================================

-- Auto-update overdue loans
DELIMITER //
CREATE EVENT IF NOT EXISTS `mr_x_check_overdue_loans`
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    UPDATE `mr_x_loans`
    SET `status` = 'overdue'
    WHERE `status` = 'active'
      AND `due_at` < NOW();
END//
DELIMITER ;

-- ============================================
-- INITIAL DATA / SEED
-- ============================================
-- No initial data needed - profiles created on player join
