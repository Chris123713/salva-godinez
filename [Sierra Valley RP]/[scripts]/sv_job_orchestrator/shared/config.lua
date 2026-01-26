Config = {}

-- Dynamic pricing thresholds
Config.Multipliers = {
    surge = 1.35,       -- +35% when understaffed
    normal = 1.0,       -- Standard rate
    declining = 0.90,   -- -10% when getting busy
    saturated = 0.70    -- -30% when oversaturated
}

-- NOTE: Panel placement is handled by sv_panel_placer
-- Use /placepanel job_market to place panels in-game

-- Discord webhook reports
Config.DiscordReports = {
    enabled = true,
    webhook = "", -- Set your Discord webhook URL here

    -- Schedule times (24hr format, server timezone)
    scheduledTimes = {
        "12:00",  -- Noon report
        "00:00",  -- Midnight report
    },

    -- What to include
    includeTopEarners = true,
    includeJobPopularity = true,
    includeMultiplierStats = true,
    includeHourlyBreakdown = false,
}

-- Update interval for DUI (milliseconds)
Config.DUIUpdateInterval = 5000

-- All tracked jobs with centralized config
Config.Jobs = {
    ------------------------------------
    -- [jobs] folder - Peuren/Siberwin (encrypted)
    ------------------------------------
    mining = {
        label = "Mining",
        jobName = "miner",
        icon = "fa-solid fa-gem",
        basePay = {
            rocks = { min = 20, max = 30 },
            ores = {
                iron_ore = { min = 18, max = 28 },
                gold_ore = { min = 22, max = 32 },
                ruby_ore = { min = 25, max = 35 },
                emerald_ore = { min = 28, max = 38 },
                sapphire_ore = { min = 32, max = 42 },
                diamond_ore = { min = 38, max = 48 },
            }
        },
        surgeThreshold = 2,      -- 0-2 workers = surge
        normalThreshold = 5,     -- 3-5 workers = normal
        decliningThreshold = 7,  -- 6-7 workers = declining
        saturationThreshold = 8, -- 8+ workers = saturated
        tracked = true,
        encrypted = true,
    },

    garbage = {
        label = "Garbage Collection",
        jobName = "garbage",
        icon = "fa-solid fa-trash",
        basePay = { min = 130, max = 190 },
        surgeThreshold = 1,
        normalThreshold = 4,
        decliningThreshold = 6,
        saturationThreshold = 7,
        tracked = true,
        encrypted = true,
    },

    trucking = {
        label = "Trucking",
        jobName = "trucker",
        icon = "fa-solid fa-truck",
        basePay = {
            perKm = 85.0,
            difficultyMultipliers = {
                easy = 1.0,
                medium = 1.5,
                hard = 2.0
            }
        },
        surgeThreshold = 2,
        normalThreshold = 6,
        decliningThreshold = 8,
        saturationThreshold = 10,
        tracked = true,
        encrypted = true,
    },

    security = {
        label = "Security Transport",
        jobName = "gruppe6",
        icon = "fa-solid fa-shield-halved",
        basePay = { min = 200, max = 400 },
        surgeThreshold = 1,
        normalThreshold = 3,
        decliningThreshold = 4,
        saturationThreshold = 5,
        tracked = true,
        encrypted = true,
    },

    ------------------------------------
    -- [qbx] folder - Open Source
    ------------------------------------
    taxi = {
        label = "Taxi",
        jobName = "taxi",
        icon = "fa-solid fa-taxi",
        basePay = { perMile = 165.0 },
        surgeThreshold = 1,
        normalThreshold = 3,
        decliningThreshold = 5,
        saturationThreshold = 6,
        tracked = true,
        encrypted = false,
    },

    bus = {
        label = "Bus Driver",
        jobName = "bus",
        icon = "fa-solid fa-bus",
        basePay = { min = 300, max = 430 },
        surgeThreshold = 0,
        normalThreshold = 2,
        decliningThreshold = 3,
        saturationThreshold = 4,
        tracked = true,
        encrypted = false,
    },

    tow = {
        label = "Tow Truck",
        jobName = "tow",
        icon = "fa-solid fa-truck-pickup",
        basePay = { bailPrice = 1050, tax = 5 },
        surgeThreshold = 1,
        normalThreshold = 3,
        decliningThreshold = 4,
        saturationThreshold = 5,
        tracked = true,
        encrypted = false,
    },

    recycle = {
        label = "Recycling",
        jobName = "recycle",
        icon = "fa-solid fa-recycle",
        basePay = { min = 50, max = 100 },
        surgeThreshold = 1,
        normalThreshold = 3,
        decliningThreshold = 5,
        saturationThreshold = 6,
        tracked = true,
        encrypted = false,
    },

    news = {
        label = "News Reporter",
        jobName = "reporter",
        icon = "fa-solid fa-newspaper",
        basePay = { perStory = 500 },
        surgeThreshold = 0,
        normalThreshold = 1,
        decliningThreshold = 2,
        saturationThreshold = 3,
        tracked = true,
        encrypted = false,
    },

    diving = {
        label = "Diving",
        jobName = "diver",
        icon = "fa-solid fa-water",
        basePay = { min = 80, max = 150 },
        surgeThreshold = 1,
        normalThreshold = 3,
        decliningThreshold = 4,
        saturationThreshold = 5,
        tracked = true,
        encrypted = false,
    },

    vineyard = {
        label = "Vineyard",
        jobName = "vineyard",
        icon = "fa-solid fa-wine-bottle",
        basePay = { min = 40, max = 80 },
        surgeThreshold = 2,
        normalThreshold = 5,
        decliningThreshold = 7,
        saturationThreshold = 8,
        tracked = true,
        encrypted = false,
    },

    ------------------------------------
    -- [scripts] folder
    ------------------------------------
    fishing = {
        label = "Fishing",
        jobName = "fisherman",
        icon = "fa-solid fa-fish",
        basePay = {
            common = { min = 70, max = 100 },
            uncommon = { min = 100, max = 150 },
            rare = { min = 200, max = 350 },
        },
        surgeThreshold = 2,
        normalThreshold = 6,
        decliningThreshold = 8,
        saturationThreshold = 10,
        tracked = true,
        encrypted = true,
    },
}

-- Lookup table: jobName -> configKey
Config.JobNameLookup = {}
for key, job in pairs(Config.Jobs) do
    Config.JobNameLookup[job.jobName] = key
end

-- Helper function to get job config by either key or jobName
function Config.GetJobConfig(identifier)
    if Config.Jobs[identifier] then
        return Config.Jobs[identifier], identifier
    end
    local key = Config.JobNameLookup[identifier]
    if key then
        return Config.Jobs[key], key
    end
    return nil, nil
end
