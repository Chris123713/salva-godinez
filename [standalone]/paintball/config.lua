Config = {}

-- Paintball Arena Location (Lobby/Entrance)
Config.ArenaLocation = {
    coords = vector3(-282.8578, -1936.6909, 30.4959),
    radius = 50.0,
    interactionRadius = 3.0,
    lobbyDisbandDistance = 150.0 -- Distance in units - if player walks this far away, lobby is automatically disbanded
}

-- Arena Spawn Points
Config.ArenaSpawns = {
    -- Red Team Spawns
    redSpawns = {
        vector4(-282.86, -1936.69, 30.50, 0.0),
        vector4(-280.86, -1936.69, 30.50, 0.0),
        vector4(-278.86, -1936.69, 30.50, 0.0),
        vector4(-276.86, -1936.69, 30.50, 0.0),
        vector4(-274.86, -1936.69, 30.50, 0.0),
        vector4(-272.86, -1936.69, 30.50, 0.0),
    },
    -- Blue Team Spawns
    blueSpawns = {
        vector4(-282.86, -1936.69, 30.50, 180.0),
        vector4(-280.86, -1936.69, 30.50, 180.0),
        vector4(-278.86, -1936.69, 30.50, 180.0),
        vector4(-276.86, -1936.69, 30.50, 180.0),
        vector4(-274.86, -1936.69, 30.50, 180.0),
        vector4(-272.86, -1936.69, 30.50, 180.0),
    },
    -- 1v1 Spawn Points (for FFA with 2 players or 1v1 matches)
    oneVOneSpawns = {
        vector4(120.963478, -424.690491, 42.910690, 9.253058),
        vector4(11.392590, -399.677734, 40.448349, 252.599304),
    },
    -- Team Match Spawn Points (red and blue teams spawn at these two locations, randomly assigned each match)
    teamSpawns = {
        vector4(120.963478, -424.690491, 42.910690, 9.253058),
        vector4(11.392590, -399.677734, 40.448349, 252.599304),
    }
}

-- Game Modes
Config.GameModes = {
    {
        name = 'Team Deathmatch',
        id = 'tdm',
        description = 'First team to reach the score limit wins',
        requiresTeams = true,
        minPlayers = 2,
        maxScore = 30
    },
    {
        name = 'Free For All',
        id = 'ffa',
        description = 'Every player for themselves. First to reach score limit wins',
        requiresTeams = false,
        minPlayers = 2,
        maxScore = 30
    },
    {
        name = 'Capture The Flag',
        id = 'ctf',
        description = 'Capture the enemy flag and return it to your base',
        requiresTeams = true,
        minPlayers = 4,
        maxScore = 3
    },
    {
        name = 'Hold Your Own',
        id = 'hyo',
        description = 'Hold the objective for the longest time',
        requiresTeams = true,
        minPlayers = 4,
        maxScore = 300
    },
    {
        name = 'King of the Hill',
        id = 'koth',
        description = 'Control the hill to earn points',
        requiresTeams = true,
        minPlayers = 4,
        maxScore = 200
    },
    {
        name = 'Gun Game',
        id = 'gungame',
        description = 'Get a kill to advance to the next weapon. First to kill with the final weapon wins!',
        requiresTeams = false,
        minPlayers = 2,
        maxScore = 1
    },
    {
        name = 'Practice Mode (AI)',
        id = 'practice',
        description = 'Fight against AI bots. Perfect for training and practice!',
        requiresTeams = false,
        minPlayers = 1,
        maxScore = 30
    }
}

-- Teams
Config.Teams = {
    red = {
        name = 'Red Team',
        color = { r = 255, g = 0, b = 0 },
        spawnPoints = Config.ArenaSpawns.redSpawns
    },
    blue = {
        name = 'Blue Team',
        color = { r = 0, g = 0, b = 255 },
        spawnPoints = Config.ArenaSpawns.blueSpawns
    }
}

-- Match Settings
Config.MatchSettings = {
    maxPlayersPerTeam = 12,
    maxMatchTime = 30, -- minutes (deprecated - using kill count instead)
    defaultWeapon = 'WEAPON_PISTOL',
    respawnTime = 5, -- seconds
    defaultKillCount = 3 -- Default kills needed to win
}

-- Available Weapons (Categorized)
Config.AvailableWeapons = {
    {
        name = 'Pistols',
        description = 'Small and deadly',
        weapons = {
            { name = 'Pistol', weapon = 'WEAPON_PISTOL' },
            { name = 'Combat Pistol', weapon = 'WEAPON_COMBATPISTOL' },
            { name = 'AP Pistol', weapon = 'WEAPON_APPISTOL' },
            { name = 'SNS Pistol', weapon = 'WEAPON_SNSPISTOL' },
            { name = 'Heavy Pistol', weapon = 'WEAPON_HEAVYPISTOL' },
            { name = 'Vintage Pistol', weapon = 'WEAPON_VINTAGEPISTOL' },
            { name = 'Marksman Pistol', weapon = 'WEAPON_MARKSMANPISTOL' },
            { name = 'Revolver', weapon = 'WEAPON_REVOLVER' },
            { name = 'Double Action Revolver', weapon = 'WEAPON_DOUBLEACTION' },
            { name = 'Perico Pistol', weapon = 'WEAPON_CERAMICPISTOL' },
        }
    },
    {
        name = 'SMGs',
        description = 'Lightweight machine guns',
        weapons = {
            { name = 'Micro SMG', weapon = 'WEAPON_MICROSMG' },
            { name = 'SMG', weapon = 'WEAPON_SMG' },
            { name = 'Assault SMG', weapon = 'WEAPON_ASSAULTSMG' },
            { name = 'Combat PDW', weapon = 'WEAPON_COMBATPDW' },
            { name = 'Mini SMG', weapon = 'WEAPON_MINISMG' },
            { name = 'Unholy Hellbringer', weapon = 'WEAPON_RAYCARBINE' },
        }
    },
    {
        name = 'Shotguns',
        description = 'Heavy close range shotguns',
        weapons = {
            { name = 'Pump Shotgun', weapon = 'WEAPON_PUMPSHOTGUN' },
            { name = 'Sawed-Off Shotgun', weapon = 'WEAPON_SAWNOFFSHOTGUN' },
            { name = 'Assault Shotgun', weapon = 'WEAPON_ASSAULTSHOTGUN' },
            { name = 'Bullpup Shotgun', weapon = 'WEAPON_BULLPUPSHOTGUN' },
            { name = 'Musket', weapon = 'WEAPON_MUSKET' },
            { name = 'Heavy Shotgun', weapon = 'WEAPON_HEAVYSHOTGUN' },
            { name = 'Double Barrel Shotgun', weapon = 'WEAPON_DBSHOTGUN' },
            { name = 'Sweeper Shotgun', weapon = 'WEAPON_AUTOSHOTGUN' },
        }
    },
    {
        name = 'Assault Rifles',
        description = 'Versatile automatic rifles',
        weapons = {
            { name = 'Assault Rifle', weapon = 'WEAPON_ASSAULTRIFLE' },
            { name = 'Carbine Rifle', weapon = 'WEAPON_CARBINERIFLE' },
            { name = 'Advanced Rifle', weapon = 'WEAPON_ADVANCEDRIFLE' },
            { name = 'Special Carbine', weapon = 'WEAPON_SPECIALCARBINE' },
            { name = 'Bullpup Rifle', weapon = 'WEAPON_BULLPUPRIFLE' },
            { name = 'Compact Rifle', weapon = 'WEAPON_COMPACTRIFLE' },
        }
    },
    {
        name = 'Sniper Rifles',
        description = 'Long range precision',
        weapons = {
            { name = 'Sniper Rifle', weapon = 'WEAPON_SNIPERRIFLE' },
            { name = 'Heavy Sniper', weapon = 'WEAPON_HEAVYSNIPER' },
            { name = 'Marksman Rifle', weapon = 'WEAPON_MARKSMANRIFLE' },
        }
    },
}

-- Gun Game Weapon Progression
Config.GunGameWeapons = {
    'WEAPON_PISTOL',
    'WEAPON_COMBATPISTOL',
    'WEAPON_REVOLVER',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_SMG',
    'WEAPON_ASSAULTRIFLE',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_SPECIALCARBINE',
    'WEAPON_BULLPUPRIFLE',
    'WEAPON_COMPACTRIFLE',
    'WEAPON_MG',
    'WEAPON_COMBATMG',
    'WEAPON_SNIPERRIFLE',
    'WEAPON_HEAVYSNIPER',
    'WEAPON_MARKSMANRIFLE',
    'WEAPON_RPG', -- Final weapon
}

-- AI Practice Mode Settings
Config.AIPractice = {
    enabled = true,
    botCount = 5,
    botDifficulty = 'medium',
    botRespawnTime = 1, -- Respawn after 1 second
    maxConcurrentBots = 20, -- Maximum number of bots that can be alive at once (prevents too many bots spawning)
    botModels = {
        's_m_y_swat_01',
        's_m_y_cop_01',
        's_m_y_marine_01',
        's_m_y_blackops_01',
        's_m_y_blackops_02'
    },
    botWeapon = 'WEAPON_PISTOL',
    botAccuracy = 0.3,
    botHealth = 100,
    botArmor = 50,
    -- AI spawn location (center point for fallback)
    spawnLocation = vector4(45.708305, -314.339050, 44.918453, 223.112686),
    -- Specific spawn points for AI bots (randomly selected)
    spawnPoints = {
        vector4(124.650978, -408.574615, 41.039043, 50.693157),
        vector4(110.857079, -445.799133, 41.129410, 150.626022),
        vector4(75.253838, -450.092926, 37.552341, 80.051064),
        vector4(30.201817, -430.599121, 39.921974, 347.900146)
    },
    useSpawnPoints = true, -- Set to true to use specific spawn points, false to use radius/area
    spawnRadius = 50.0, -- Radius around spawn location to spawn bots (fallback if useSpawnPoints is false)
    minDistanceFromPlayer = 15.0, -- Minimum distance bots should spawn from player
    -- Spawn area boundaries (defines a rectangular area for bot spawning)
    spawnArea = {
        minX = 0.0,  -- Minimum X offset from spawnLocation (negative = west, positive = east)
        maxX = 0.0,  -- Maximum X offset from spawnLocation
        minY = 0.0,  -- Minimum Y offset from spawnLocation (negative = south, positive = north)
        maxY = 0.0,  -- Maximum Y offset from spawnLocation
        minZ = -5.0, -- Minimum Z offset (height variation)
        maxZ = 5.0   -- Maximum Z offset (height variation)
    },
    -- If spawnArea is not set (all zeros), use circular spawnRadius instead
    useSpawnArea = false, -- Set to true to use rectangular area, false to use circular radius
    playerRespawnTime = 1, -- Seconds before player respawns in practice mode
    useRoutingBucket = true, -- Use separate dimension for practice mode
    routingBucket = 200, -- Routing bucket ID for practice mode (base, will add matchId)
}

-- Match Routing Buckets
Config.MatchRoutingBucket = {
    enabled = true, -- Enable routing buckets for regular matches (1v1, team matches, etc.)
    baseBucket = 100, -- Base routing bucket ID for regular matches (each match gets baseBucket + matchId)
}

-- Rewards
Config.Rewards = {
    enabled = true,
    killReward = 10,
    winReward = 100
}

-- ============================================
-- PROGRESSION & RANKED SYSTEM CONFIG
-- ============================================

-- Enable/Disable Ranked PvP System
Config.EnableRankedPvP = true -- Set to false to disable ranked features in UI

-- Enable/Disable XP/Progression System
Config.EnableXPSystem = true -- Set to false to disable XP progression

-- XP Rewards (only used if Config.EnableXPSystem = true)
Config.XPRewards = {
    kill = 50,              -- XP per kill
    headshot = 75,          -- XP per headshot kill
    assist = 25,            -- XP per assist
    matchWin = 200,         -- XP for winning a match
    matchLoss = 50,         -- XP for losing a match
    practiceKill = 25,      -- XP per AI kill in practice mode
    practiceWin = 100,      -- XP for completing practice mode
    firstBlood = 100,       -- XP for first kill in match
    killStreak = {          -- Bonus XP for kill streaks
        [3] = 50,           -- 3 kills = +50 XP
        [5] = 100,          -- 5 kills = +100 XP
        [10] = 200,         -- 10 kills = +200 XP
        [15] = 300,         -- 15 kills = +300 XP
    }
}

-- XP Requirements per Level
Config.XPPerLevel = 1000 -- Base XP required per level
Config.XPPerLevelMultiplier = 1.15 -- Each level requires 15% more XP than previous

-- Rank System (only used if Config.EnableRankedPvP = true)
Config.Ranks = {
    { name = "Rookie", insignia = "🎖️", minRating = 0, maxRating = 499 },
    { name = "Bronze", insignia = "🥉", minRating = 500, maxRating = 999 },
    { name = "Silver", insignia = "🥈", minRating = 1000, maxRating = 1499 },
    { name = "Gold", insignia = "🥇", minRating = 1500, maxRating = 1999 },
    { name = "Platinum", insignia = "💎", minRating = 2000, maxRating = 2499 },
    { name = "Diamond", insignia = "💠", minRating = 2500, maxRating = 2999 },
    { name = "Master", insignia = "👑", minRating = 3000, maxRating = 3499 },
    { name = "Grandmaster", insignia = "🌟", minRating = 3500, maxRating = 9999 },
}

-- Prestige System (only used if Config.EnableXPSystem = true)
Config.PrestigeSystem = {
    enabled = true,
    maxPrestige = 5,
    xpRequiredForPrestige = 50000, -- Total XP needed to prestige
    prestigeRewards = { -- Rewards for each prestige level
        [0] = { title = "Recruit", icon = "🛡️", symbol = "shield" }, -- Starting prestige - Bronze Shield
        [1] = { title = "Veteran", icon = "⚔️", symbol = "sword" }, -- Silver Shield with Crossed Swords
        [2] = { title = "Elite", icon = "⚡", symbol = "lightning" }, -- Gold Shield with Lightning
        [3] = { title = "Legend", icon = "🔥", symbol = "flame" }, -- Platinum Shield with Flame
        [4] = { title = "Master", icon = "👑", symbol = "crown" }, -- Diamond Shield with Crown
        [5] = { title = "Grandmaster", icon = "🐉", symbol = "dragon" }, -- Legendary Shield with Dragon
    }
}
