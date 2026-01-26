-- ═══════════════════════════════════════════════════════════════
-- BODHIX SPORT HUB - EQUIPMENT SYSTEM
-- Database schema for equipment ownership and equipped state
-- ═══════════════════════════════════════════════════════════════
--
-- ⚠️ NOTICE: You DO NOT need to manually import this file!
-- Tables are created AUTOMATICALLY when the resource starts.
-- This file is provided for reference only.
-- ═══════════════════════════════════════════════════════════════

-- Equipment ownership table
-- Stores all equipment owned by players for each sport
CREATE TABLE IF NOT EXISTS `sport_hub_equipment` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier',
    `sport` VARCHAR(50) NOT NULL COMMENT 'Sport type (skateboard, bmx, ski, etc.)',
    `category` VARCHAR(50) NOT NULL COMMENT 'Equipment category (helmet, forearms, shinguards)',
    `model` VARCHAR(100) NOT NULL COMMENT 'Model name (alien_skull, fr_chrome, kn_black_blue)',
    `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped, 0 if owned but not equipped',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_equipment` (`identifier`, `sport`, `category`, `model`),
    INDEX `player_index` (`identifier`),
    INDEX `player_sport_index` (`identifier`, `sport`),
    INDEX `equipped_index` (`identifier`, `sport`, `is_equipped`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Equipment store pricing (extension of store_prices table)
-- This table extends the existing pricing system for equipment
-- Prices are per category (helmet, forearms, shinguards), not per sport
CREATE TABLE IF NOT EXISTS `sport_hub_equipment_prices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL COMMENT 'Store identifier',
    `category` VARCHAR(50) NOT NULL COMMENT 'Equipment category (helmet, forearms, shinguards)',
    `price` INT NOT NULL COMMENT 'Custom price set by store owner',
    UNIQUE KEY `unique_equipment_price` (`store_name`, `category`),
    INDEX `store_equipment_price_index` (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
