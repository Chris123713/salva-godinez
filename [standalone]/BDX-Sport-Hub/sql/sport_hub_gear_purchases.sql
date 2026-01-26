-- ═══════════════════════════════════════════════════════════════
-- BODHIX SPORT HUB - GEAR PURCHASES & VIP SYSTEM
-- Database schema for gear/design purchases, Tebex packages, and Discord verification
-- ═══════════════════════════════════════════════════════════════
--
-- ⚠️ NOTICE: You DO NOT need to manually import this file!
-- Tables are created AUTOMATICALLY when the resource starts.
--
-- 📋 ONLY USE THIS FILE IF:
-- - Gear purchases (skateboard designs, BMX designs, etc.) are NOT saving after restart
-- - VIP packages are not being recognized
-- - Discord verification is not working
--
-- If auto-creation is failing, manually import this file to your database.
-- ═══════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════
-- 🎨 GEAR/DESIGN PURCHASES TABLE
-- Stores all player-purchased gear designs and customizations
-- ═══════════════════════════════════════════════════════════════
-- This table stores purchases for:
-- - Skateboard designs (deck, trucks, wheels)
-- - BMX designs
-- - Hoverboard designs (ultra, retro styles)
-- - Roller skates designs (modern, retro styles)
-- - Scooter designs
-- - Ski designs
-- - Ice skates designs
-- - Snowboard designs
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_purchases` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier (license:xxxx or steam:xxxx)',
    `item_type` VARCHAR(50) NOT NULL COMMENT 'Item category: skateboard, bmx, hoverboard, rollers, scooter, ski, iceskates, snowboard',
    `gender` VARCHAR(10) NOT NULL COMMENT 'For single-part: male/female, For skateboard: deck/trucks/wheels, For styled items: modern/classic/ultra/retro',
    `texture_id` INT NOT NULL DEFAULT 0 COMMENT '0-indexed design/texture ID (0 = first design, 1 = second design, etc.)',
    `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped/active, 0 if owned but not equipped',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Prevent duplicate purchases (player can only own each design once)
    UNIQUE KEY `unique_purchase` (`identifier`, `item_type`, `gender`, `texture_id`),

    -- Performance indexes
    INDEX `identifier_index` (`identifier`),
    INDEX `item_type_index` (`item_type`),
    INDEX `equipped_index` (`identifier`, `item_type`, `gender`, `is_equipped`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 🎁 TEBEX VIP PACKAGES TABLE (OPTIONAL)
-- Tracks Tebex package ownership for VIP/exclusive content
-- ═══════════════════════════════════════════════════════════════
-- This table is used as a backup for Discord role verification.
-- Primary method is Discord role checking, but this allows manual overrides.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_tebex_packages` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player CFX identifier (license:xxxx or fivem:xxxx)',
    `package_id` VARCHAR(50) NOT NULL COMMENT 'Tebex package ID for VIP content',
    `transaction_id` VARCHAR(100) COMMENT 'Tebex transaction ID (for reference)',
    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Prevent duplicate package entries
    UNIQUE KEY `unique_package_ownership` (`identifier`, `package_id`),

    -- Performance indexes
    INDEX `player_packages_index` (`identifier`),
    INDEX `package_id_index` (`package_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 🔗 DISCORD VERIFICATION LINKS TABLE
-- Links player identifiers to Discord IDs for VIP content verification
-- ═══════════════════════════════════════════════════════════════
-- Used for manual Discord verification when automatic role checking fails.
-- Allows admins to manually link Discord IDs to player accounts.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `sport_hub_discord_links` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player CFX identifier (license:xxxx)',
    `discord_id` VARCHAR(30) NOT NULL COMMENT 'Discord user ID (18-character snowflake)',
    `discord_username` VARCHAR(100) COMMENT 'Discord username at time of linking (for reference)',
    `linked_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `verified` TINYINT(1) DEFAULT 1 COMMENT 'Whether the Discord ID has verified VIP roles',

    -- One Discord ID can only link to ONE player account
    UNIQUE KEY `unique_discord_id` (`discord_id`),

    -- One player can only have ONE Discord ID linked
    UNIQUE KEY `unique_player` (`identifier`),

    -- Performance indexes
    INDEX `discord_id_index` (`discord_id`),
    INDEX `identifier_index` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- ✅ INSTALLATION COMPLETE
-- ═══════════════════════════════════════════════════════════════
-- All tables have been created. Your Sport Hub should now save:
-- ✓ Gear purchases (skateboard designs, BMX, hoverboard, etc.)
-- ✓ Equipped status (which designs are currently active)
-- ✓ VIP package ownership (Tebex packages)
-- ✓ Discord verification links (for VIP content access)
--
-- If you continue to experience issues, please check:
-- 1. MySQL connection in your server.cfg
-- 2. Database permissions (CREATE, INSERT, UPDATE, SELECT)
-- 3. Server console for SQL error messages
-- ═══════════════════════════════════════════════════════════════
