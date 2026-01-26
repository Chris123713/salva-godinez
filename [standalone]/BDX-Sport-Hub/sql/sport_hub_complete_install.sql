-- ═══════════════════════════════════════════════════════════════
-- BODHIX SPORT HUB - COMPLETE DATABASE INSTALLATION
-- ALL tables required for Sport Hub functionality
-- ═══════════════════════════════════════════════════════════════
--
-- ⚠️ NOTICE: You DO NOT need to manually import this file!
-- Tables are created AUTOMATICALLY when the resource starts.
--
-- 📋 ONLY USE THIS FILE IF:
-- - You are experiencing issues with auto-table creation
-- - Data is not saving after server restarts
-- - You want to manually install all tables at once
--
-- This file contains ALL Sport Hub tables in one place for easy installation.
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- 1️⃣ GEAR/DESIGN PURCHASES TABLE
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_purchases` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier',
    `item_type` VARCHAR(50) NOT NULL COMMENT 'skateboard, bmx, hoverboard, rollers, scooter, ski, iceskates, snowboard',
    `gender` VARCHAR(10) NOT NULL COMMENT 'male/female or style name (deck/trucks/wheels, modern/classic/ultra/retro)',
    `texture_id` INT NOT NULL DEFAULT 0 COMMENT '0-indexed texture/design ID',
    `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped, 0 if owned but not equipped',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_purchase` (`identifier`, `item_type`, `gender`, `texture_id`),
    INDEX `identifier_index` (`identifier`),
    INDEX `item_type_index` (`item_type`),
    INDEX `equipped_index` (`identifier`, `item_type`, `gender`, `is_equipped`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 2️⃣ EQUIPMENT OWNERSHIP TABLE
-- ═══════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════
-- 3️⃣ STORE OWNERSHIP TABLE
-- ═══════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════
-- 4️⃣ STORE CUSTOM PRICING TABLE
-- ═══════════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════════
-- 5️⃣ STORE CUSTOM HOURS TABLE
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_store_hours` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Store identifier',
    `open_hour` INT NOT NULL DEFAULT 0 COMMENT 'Opening hour (0-23)',
    `close_hour` INT NOT NULL DEFAULT 24 COMMENT 'Closing hour (1-24)',
    INDEX `store_hours_index` (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 6️⃣ EQUIPMENT CUSTOM PRICING TABLE
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_equipment_prices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(50) NOT NULL COMMENT 'Store identifier',
    `category` VARCHAR(50) NOT NULL COMMENT 'Equipment category (helmet, forearms, shinguards)',
    `price` INT NOT NULL COMMENT 'Custom price set by store owner',
    UNIQUE KEY `unique_equipment_price` (`store_name`, `category`),
    INDEX `store_equipment_price_index` (`store_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 7️⃣ TEBEX VIP PACKAGES TABLE (OPTIONAL)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_tebex_packages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player CFX identifier (license:xxxx or fivem:xxxx)',
    `package_id` VARCHAR(50) NOT NULL COMMENT 'Tebex package ID',
    `transaction_id` VARCHAR(100) COMMENT 'Tebex transaction ID',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_package_ownership` (`identifier`, `package_id`),
    INDEX `player_packages_index` (`identifier`),
    INDEX `package_id_index` (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 8️⃣ DISCORD VERIFICATION LINKS TABLE
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_discord_links` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player CFX identifier (license:xxxx)',
    `discord_id` VARCHAR(30) NOT NULL COMMENT 'Discord user ID',
    `discord_username` VARCHAR(100) COMMENT 'Discord username at time of linking',
    `linked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `verified` TINYINT(1) DEFAULT 1 COMMENT 'Whether the Discord ID has verified roles',
    UNIQUE KEY `unique_discord_id` (`discord_id`),
    UNIQUE KEY `unique_player` (`identifier`),
    INDEX `discord_id_index` (`discord_id`),
    INDEX `identifier_index` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- ✅ INSTALLATION COMPLETE
-- ═══════════════════════════════════════════════════════════════
-- All 8 Sport Hub tables have been created successfully!
--
-- Your database now includes:
-- ✓ sport_hub_purchases - Gear/design purchases (skateboard, BMX, etc.)
-- ✓ sport_hub_equipment - Equipment ownership (helmets, pads, guards)
-- ✓ sport_hub_store_ownership - Store ownership system
-- ✓ sport_hub_store_prices - Custom store pricing
-- ✓ sport_hub_store_hours - Custom store hours
-- ✓ sport_hub_equipment_prices - Custom equipment pricing
-- ✓ sport_hub_tebex_packages - VIP package tracking
-- ✓ sport_hub_discord_links - Discord verification
--
-- 🎮 Your Sport Hub should now save all player data correctly!
--
-- If you continue to experience issues, please verify:
-- 1. MySQL connection is working (check server.cfg)
-- 2. Database user has correct permissions (CREATE, INSERT, UPDATE, SELECT)
-- 3. Check server console for any SQL error messages
-- 4. Ensure Config.UseSQLStorage is set correctly in config.lua
-- ═══════════════════════════════════════════════════════════════
