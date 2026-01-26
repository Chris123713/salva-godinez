Config = {}

-- OpenAI Configuration
-- API key can be set here OR in server.cfg: set openai_key "sk-your-key-here"
Config.OpenAI = {
    ApiKey = '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',
    Model = 'gpt-5.2',           -- Primary model (gpt-5.2-pro only works with Responses API)
    FallbackModel = 'gpt-4o',    -- Fallback if primary returns 403/404 (API key access)
    MaxTokens = 2048,
    Temperature = 0.7,           -- Only used for non-reasoning models
    ReasoningEffort = 'medium',  -- For gpt-5.2: none, low, medium, high, xhigh
    TimeoutMs = 60000
}

-- Spawning Configuration
Config.Spawning = {
    MaxAttempts = 3,                  -- Max raycast attempts before fallback
    DefaultRadius = 50.0,             -- Default search radius for safe coords
    MinClearance = 2.0,               -- Minimum clearance around spawn point
    GroundCheckOffset = 5.0,          -- Height to check ground from
    StreamDistance = 100.0            -- Entity streaming distance
}

-- Mission Configuration
Config.Missions = {
    MaxActiveMissions = 10,           -- Max concurrent active missions
    CleanupDelayMs = 300000,          -- 5 min cleanup delay after completion
    ObjectiveSyncIntervalMs = 1000,   -- Objective sync rate
    MaxParticipants = 8               -- Max players per mission
}

-- Dialog Configuration
Config.Dialogs = {
    InteractionDistance = 2.5,        -- Distance to interact with NPCs
    DefaultTimeout = 30000            -- Dialog timeout in ms
}

-- Mission Creator Configuration
Config.MissionCreator = {
    MockupAlpha = 150,                -- Transparency for mockup entities
    RotationStep = 15.0,              -- Degrees per rotation press
    MaxElements = 50                  -- Max elements per blueprint
}

-- Economy Configuration
Config.Economy = {
    DefaultMoneyType = 'cash',
    NotifyOnTransaction = true        -- Send phone notification on money changes
}

-- Phone Integration (lb-phone)
Config.Phone = {
    DefaultSender = 'Unknown',
    MissionSender = 'Mr. X'
}

-- Performance Configuration
Config.Performance = {
    EntityPoolSize = 20,              -- Pooled entities per type
    UIUpdateIntervalMs = 50,          -- UI batch update rate
    RaycastCooldownMs = 100,          -- Min time between raycasts
    AdaptiveTickNear = 100,           -- Tick rate when near mission
    AdaptiveTickFar = 1000            -- Tick rate when away from mission
}

-- Debug Configuration
Config.Debug = {
    Enabled = false,                  -- Enable debug prints
    ShowPerformance = false           -- Show performance stats
}

-- Role Definitions
Config.Roles = {
    criminal = {'thief', 'getaway_driver', 'lookout', 'hacker'},
    civilian = {'witness', 'victim', 'helper', 'informant'},
    emergency = {'police', 'ems', 'fire', 'dispatch'}
}

-- Mission Types
Config.MissionTypes = {
    'heist',
    'robbery',
    'delivery',
    'escort',
    'investigation',
    'pursuit',
    'rescue'
}
