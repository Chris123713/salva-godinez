Config = {}

-- ========================================
-- JOB SETTINGS
-- ========================================

-- Supported jobs that can use this boss menu
Config.SupportedJobs = {'police', 'lscso', 'safr'}

-- Boss ranks by job (ranks that have isboss = true)
Config.BossRanks = {
    police = {'commander', 'deputy chief', 'assistant chief', 'chief'},
    lscso = {'assistant chief deputy', 'chief deputy', 'assistant sheriff', 'under sheriff', 'sheriff'},
    safr = {'assistant chief', 'deputy chief', 'chief'}
}

-- Minimum grade required to pay bonuses (command+)
Config.BonusMinGrade = {
    police = 11,  -- Commander+
    lscso = 11,   -- Assistant Chief Deputy+
    safr = 6      -- Assistant Chief+
}

-- Menu location (legacy - used as fallback)
Config.MenuLocation = vector3(4461.6486, -978.0023, 30.5359)

-- ========================================
-- 3D SCREEN SETTINGS (cr-3dnui integration)
-- Supports multiple panel locations
-- ========================================
Config.Screen3DPanels = {
                        {
        id = "panel_1",
        enabled = true,
        position = vector3(-456.5508, 6031.2051, 35.2009),
        heading = 45.60,
        width = 0.50,
        height = 0.28,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = 1.78,
        zoomFov = 50.0,
        camHeight = 0.09,
        camOffsetX = -0.05,
        camOffsetY = -2.30
    },            {
        id = "panel_2_1668",
        enabled = true,
        position = vector3(-462.5054, 6017.9243, 35.2030),
        heading = -134.05,
        width = 0.50,
        height = 0.28,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = 1.80,
        zoomFov = 50.0,
        camHeight = 0.03,
        camOffsetX = 0.00,
        camOffsetY = -2.27
    },

    -- Add more panels here using /placepanel command
}

-- Legacy single panel support (backwards compatibility)
Config.Screen3D = Config.Screen3DPanels[1]

-- Blip settings
Config.Blip = {
    enabled = true,
    sprite = 60,
    color = 29,
    scale = 0.8,
    label = 'PD Boss Menu'
}

-- ========================================
-- POLICE (LSPD) RANKS - Grades 1-14
-- ========================================
Config.PoliceRanks = {
    {name = 'cadet', label = 'Cadet', grade = 1},
    {name = 'probationary officer', label = 'Probationary Officer', grade = 2},
    {name = 'officer', label = 'Officer', grade = 3},
    {name = 'senior officer', label = 'Senior Officer', grade = 4},
    {name = 'corporal', label = 'Corporal', grade = 5},
    {name = 'sergeant', label = 'Sergeant', grade = 6},
    {name = 'staff sergeant', label = 'Staff Sergeant', grade = 7},
    {name = 'lieutenant', label = 'Lieutenant', grade = 8},
    {name = 'captain', label = 'Captain', grade = 9},
    {name = 'major', label = 'Major', grade = 10},
    {name = 'commander', label = 'Commander', grade = 11},
    {name = 'deputy chief', label = 'Deputy Chief', grade = 12},
    {name = 'assistant chief', label = 'Assistant Chief', grade = 13},
    {name = 'chief', label = 'Chief', grade = 14}
}

-- ========================================
-- LSCSO (Sheriff) RANKS - Grades 1-15
-- ========================================
Config.LSCSOanks = {
    {name = 'cadet', label = 'Cadet', grade = 1},
    {name = 'deputy', label = 'Deputy', grade = 2},
    {name = 'senior deputy', label = 'Senior Deputy', grade = 3},
    {name = 'corporal', label = 'Corporal', grade = 4},
    {name = 'sergeant', label = 'Sergeant', grade = 5},
    {name = 'staff sergeant', label = 'Staff Sergeant', grade = 6},
    {name = 'master sergeant', label = 'Master Sergeant', grade = 7},
    {name = 'lieutenant', label = 'Lieutenant', grade = 8},
    {name = 'captain', label = 'Captain', grade = 9},
    {name = 'major', label = 'Major', grade = 10},
    {name = 'assistant chief deputy', label = 'Assistant Chief Deputy', grade = 11},
    {name = 'chief deputy', label = 'Chief Deputy', grade = 12},
    {name = 'assistant sheriff', label = 'Assistant Sheriff', grade = 13},
    {name = 'under sheriff', label = 'Under Sheriff', grade = 14},
    {name = 'sheriff', label = 'Sheriff', grade = 15}
}

-- ========================================
-- SAFR (Fire/EMS) RANKS - Grades 1-8
-- ========================================
Config.SAFRRanks = {
    {name = 'emt', label = 'EMT', grade = 1},
    {name = 'paramedic', label = 'Paramedic', grade = 2},
    {name = 'doctor', label = 'Doctor', grade = 3},
    {name = 'captain', label = 'Captain', grade = 4},
    {name = 'medical coordinator', label = 'Medical Coordinator', grade = 5},
    {name = 'assistant chief', label = 'Assistant Chief', grade = 6},
    {name = 'deputy chief', label = 'Deputy Chief', grade = 7},
    {name = 'chief', label = 'Chief', grade = 8}
}

-- Legacy support - default ranks (used by server if job not specified)
Config.Ranks = Config.PoliceRanks

-- Proximity settings for hiring
Config.HiringProximity = 10.0 -- Distance in meters to check for nearby players

-- ========================================
-- DISCORD WEBHOOK SETTINGS
-- Leave URLs empty ('') to disable specific webhooks
-- ========================================
Config.Webhooks = {
    -- Webhook for personnel actions (hire, fire, promotions)
    personnel = '',  -- Example: 'https://discord.com/api/webhooks/xxx/xxx'

    -- Webhook for financial actions (deposits, withdrawals, bonuses)
    finance = '',    -- Example: 'https://discord.com/api/webhooks/xxx/xxx'

    -- Optional: Use a single webhook for all actions (fallback if specific ones aren't set)
    all = ''         -- Example: 'https://discord.com/api/webhooks/xxx/xxx'
}

-- Department theme colors for webhooks (decimal format)
Config.DepartmentColors = {
    police = {
        primary = 1720831,   -- Dark Blue (#1A3A5F)
        hire = 3066993,      -- Green (#2ECC71)
        fire = 15158332,     -- Red (#E74C3C)
        promote = 3447003,   -- Blue (#3498DB)
        demote = 15105570,   -- Orange (#E67E22)
        deposit = 3066993,   -- Green (#2ECC71)
        withdraw = 15158332, -- Red (#E74C3C)
        bonus = 15844367     -- Gold (#F1C40F)
    },
    lscso = {
        primary = 6045747,   -- Brown (#5C4033)
        hire = 7048739,      -- Olive Green (#6B8E23)
        fire = 11674146,     -- Dark Red (#B22222)
        promote = 13938487,  -- Tan (#D4A574)
        demote = 9127187,    -- Sienna (#8B4513)
        deposit = 7048739,   -- Olive Green (#6B8E23)
        withdraw = 11674146, -- Dark Red (#B22222)
        bonus = 9127187      -- Gold/Brown (#8B6914)
    },
    safr = {
        primary = 11674146,  -- Dark Red (#B22222)
        hire = 3066993,      -- Green (#2ECC71)
        fire = 15158332,     -- Red (#E74C3C)
        promote = 16711680,  -- Bright Red (#FF0000)
        demote = 15105570,   -- Orange (#E67E22)
        deposit = 3066993,   -- Green (#2ECC71)
        withdraw = 15158332, -- Red (#E74C3C)
        bonus = 15844367     -- Gold (#F1C40F)
    }
}

-- Department display names and icons for webhooks
Config.DepartmentInfo = {
    police = {
        name = 'Los Santos Police Department',
        shortName = 'LSPD',
        icon = 'https://i.imgur.com/8JqWVzR.png',  -- Replace with your LSPD logo URL
        footer = 'LSPD Boss Menu System'
    },
    lscso = {
        name = 'Los Santos County Sheriff\'s Office',
        shortName = 'LSCSO',
        icon = 'https://i.imgur.com/YqZKepL.png',  -- Replace with your LSCSO logo URL
        footer = 'LSCSO Boss Menu System'
    },
    safr = {
        name = 'San Andreas Fire Rescue',
        shortName = 'SAFR',
        icon = 'https://i.imgur.com/placeholder.png',  -- Replace with your SAFR logo URL
        footer = 'SAFR Boss Menu System'
    }
}