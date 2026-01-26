-- ═══════════════════════════════════════════════════════════════
-- BODHIX SPORT HUB - STORE OWNERSHIP SYSTEM
-- Database schema for store ownership, custom pricing, and hours
-- ═══════════════════════════════════════════════════════════════
--
-- ⚠️ NOTICE: You DO NOT need to manually import this file!
-- Tables are created AUTOMATICALLY when the resource starts.
-- This file is provided for reference only.
-- ═══════════════════════════════════════════════════════════════

-- Store ownership table
CREATE TABLE IF NOT EXISTS `sport_hub_store_ownership` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Store identifier from Config.Spots',
    `owner_identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier who owns the store',
    `owner_name` VARCHAR(100) NOT NULL COMMENT 'Player name for easy reference',
    `purchase_price` INT NOT NULL DEFAULT 0 COMMENT 'How much the owner paid for the store',
    `for_sale` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if owner is selling the store, 0 if not',
    `sale_price` INT NOT NULL DEFAULT 0 COMMENT 'Price the owner is asking if selling',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `store_index` (`store_name`),
    INDEX `owner_index` (`owner_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Store custom pricing table (owner-set prices)
CREATE TABLE IF NOT EXISTS `sport_hub_store_prices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL COMMENT 'Store identifier',
    `category` VARCHAR(50) NOT NULL COMMENT 'Category (skateboard, bmx, etc.)',
    `item_type` VARCHAR(50) NULL COMMENT 'For multi-part items (deck, trucks, wheels)',
    `style` VARCHAR(50) NULL COMMENT 'For styled items (modern, classic, ultra, retro)',
    `price` INT NOT NULL COMMENT 'Custom price set by store owner',
    UNIQUE KEY `unique_price` (`store_name`, `category`, `item_type`, `style`),
    INDEX `store_price_index` (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Store custom hours table (owner-set operating hours)
CREATE TABLE IF NOT EXISTS `sport_hub_store_hours` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Store identifier',
    `open_hour` INT NOT NULL DEFAULT 0 COMMENT 'Opening hour (0-23)',
    `close_hour` INT NOT NULL DEFAULT 24 COMMENT 'Closing hour (1-24)',
    INDEX `store_hours_index` (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
