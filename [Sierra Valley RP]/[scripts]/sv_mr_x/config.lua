--[[
    Mr. X Configuration
    ==================
    IMPORTANT: TestMode = true by default - NO automated actions until explicitly enabled!
]]

Config = {}

-- ============================================
-- MASTER CONTROL
-- ============================================
Config.TestMode = true  -- When true, NO automated actions occur. Must be disabled via admin menu or server convar.

-- ============================================
-- REPUTATION SYSTEM
-- ============================================
Config.Reputation = {
    -- Tier thresholds (higher = more trust from Mr. X)
    Tiers = {
        EASY = {min = 0, max = 20},        -- New players, simple tasks
        DILEMMA = {min = 21, max = 50},    -- Proven players, moral choices
        HIGH_RISK = {min = 51, max = 100}  -- Trusted operatives, high stakes
    },

    -- Rep changes per outcome
    Changes = {
        MissionSuccess = 5,
        MissionFailure = -10,
        MissionAbandoned = -15,
        ServicePurchased = 2,
        LoanRepaid = 3,
        LoanDefaulted = -20,
        BountyCompleted = 8,
        BetrayalPunishment = -25
    },

    -- Cooldowns per tier (seconds between Mr. X contacts)
    Cooldowns = {
        EASY = 300,        -- 5 minutes
        DILEMMA = 600,     -- 10 minutes
        HIGH_RISK = 1800   -- 30 minutes (high value contacts)
    }
}

-- ============================================
-- COMMUNICATION SETTINGS
-- ============================================
Config.Comms = {
    -- Maximum back-and-forth exchanges per conversation session
    MaxExchangesPerSession = 5,

    -- Session timeout (seconds of no activity)
    SessionTimeoutSec = 600,  -- 10 minutes

    -- Cooldown between messages (prevent spam)
    MessageCooldownSec = 10,

    -- Mr. X's "phone number" pattern (for identifying inbound messages)
    -- Players reply to this number/channel
    MrXIdentifiers = {
        'Unknown',
        'Anonymous',
        'Blocked Number',
        'Mr. X'
    },

    -- Default sender name for outbound messages
    SenderName = 'Unknown',

    -- Phone notification icon
    NotificationIcon = 'fas fa-user-secret'
}

-- ============================================
-- PROACTIVE CONTACT SETTINGS
-- How often Mr. X reaches out to players with opportunities
-- ============================================
Config.ProactiveContact = {
    -- Master enable/disable for proactive outreach
    Enabled = true,

    -- Minimum time between Mr. X initiating contact (in minutes)
    -- This is GLOBAL per player - includes mission offers, check-ins, etc.
    MinIntervalMinutes = 60,  -- Don't contact same player more than once per hour

    -- Maximum contacts per player per day (resets at midnight server time)
    MaxContactsPerDay = 3,

    -- Time windows when Mr. X is "active" (24h format)
    -- Set to nil to allow contacts at any time
    ActiveHours = {
        start = 8,   -- 8 AM
        stop = 23    -- 11 PM
    },

    -- Chance to initiate contact when player becomes eligible (0.0 - 1.0)
    -- Lower = more selective, Higher = more frequent
    ContactChance = 0.3,  -- 30% chance when conditions are met

    -- Only contact players who have been online for at least X minutes
    -- Prevents bombarding players immediately on login
    MinOnlineMinutes = 15,

    -- Player must be "idle" (not in mission/job activity) to receive contact
    RequireIdle = true,

    -- Cooldown after player completes a mission before offering another
    PostMissionCooldownMinutes = 30,

    -- Contact frequency modifiers by reputation tier
    -- Higher rep = more valuable, so Mr. X contacts them less frequently but with better offers
    TierModifiers = {
        EASY = 1.0,       -- Normal frequency for new players
        DILEMMA = 0.7,    -- 30% less frequent (quality over quantity)
        HIGH_RISK = 0.5   -- 50% less frequent (exclusive opportunities)
    },

    -- Types of proactive contact (weighted random selection)
    ContactTypes = {
        MISSION_OFFER = 0.5,    -- 50% - Offer a mission
        CHECK_IN = 0.2,         -- 20% - "I may have something for you soon..."
        REPUTATION_UPDATE = 0.1, -- 10% - Comment on their recent activity
        WARNING = 0.1,          -- 10% - Subtle threat/reminder (low rep only)
        TIP = 0.1               -- 10% - Free intel tip (high rep only)
    }
}

-- ============================================
-- MISSION GENERATION
-- ============================================
Config.Missions = {
    -- Payout ranges by tier
    Payouts = {
        EASY = {min = 1000, max = 5000},
        DILEMMA = {min = 5000, max = 15000},
        HIGH_RISK = {min = 15000, max = 50000}
    },

    -- Cooldown between mission offers (seconds)
    MissionCooldownSec = 1800,  -- 30 minutes

    -- Mission timeout (how long player has to complete)
    MissionTimeoutMin = 30
}

-- ============================================
-- HELP SERVICES (Paid services for high-rep players)
-- ============================================
Config.Services = {
    -- ==========================================
    -- RECORD CLEARING (lb-tablet integration)
    -- These are EXPENSIVE - Mr. X has to bribe judges, destroy evidence, etc.
    -- ==========================================

    ClearWarrant = {
        cost = 75000,           -- $75k per warrant
        minRep = 70,
        rarity = 0.15,
        description = "Remove a single active warrant"
    },

    ClearReport = {
        cost = 50000,           -- $50k per report
        minRep = 60,
        rarity = 0.2,
        description = "Delete an incident report from MDT"
    },

    ClearCase = {
        cost = 150000,          -- $150k - these are complex
        minRep = 80,
        rarity = 0.08,
        description = "Get an active investigation dropped"
    },

    ClearBOLO = {
        cost = 25000,
        minRep = 50,
        rarity = 0.25,
        description = "Remove a Be On Lookout alert"
    },

    ClearJailRecord = {
        cost = 100000,
        minRep = 75,
        rarity = 0.1,
        description = "Expunge a jail/conviction record"
    },

    -- CLEAN SLATE - Wipe EVERYTHING (tiered pricing)
    CleanSlate = {
        baseCost = 500000,      -- $500k minimum
        perFelony = 100000,     -- +$100k per felony conviction
        perWarrant = 50000,     -- +$50k per active warrant
        perCase = 75000,        -- +$75k per open case
        minRep = 95,
        rarity = 0.01,
        description = "Complete record wipe - start fresh"
    },

    -- ==========================================
    -- INTEL SERVICES
    -- ==========================================

    TargetIntel = {
        cost = 15000,
        minRep = 45,
        description = "Location, job, gang affiliation of a target"
    },

    LocationTip = {
        cost = 5000,
        minRep = 20,
        description = "Coordinates to valuable locations"
    },

    PoliceScanner = {
        cost = 10000,
        minRep = 35,
        duration = 1800,
        description = "Temporary access to police dispatch info"
    },

    GangTerritoryIntel = {
        cost = 20000,
        minRep = 50,
        description = "Which gang controls what, power dynamics"
    },

    -- ==========================================
    -- EMERGENCY/TACTICAL SERVICES
    -- ==========================================

    PoliceDiversion = {
        cost = 25000,
        minRep = 65,
        cooldown = 3600,
        description = "Fake 911 call to draw police elsewhere"
    },

    EarlyWarning = {
        passive = true,
        minRep = 45,
        description = "Alerts when police are dispatched to your area"
    },

    SafeHouse = {
        cost = 30000,
        minRep = 55,
        duration = 7200,
        description = "Temporary safe location to lay low"
    },

    FakeIdentity = {
        cost = 75000,
        minRep = 70,
        duration = 86400,
        description = "Temporary alternate identity"
    },

    -- ==========================================
    -- EMERGENCY LOANS
    -- ==========================================
    Loans = {
        MinAmount = 5000,
        MaxAmount = 25000,
        InterestRate = 0.25,    -- 25% interest (Mr. X isn't a charity)
        DueHours = 48,          -- 48 REAL hours (2 days) to repay
        UseRealTime = true,     -- When true, DueHours is real-world hours
        DefaultPenalty = -25,
        minRep = 40
    }
}

-- ============================================
-- BANKING INTEGRATION
-- Primary banking via tgg-banking, transactions via lb-phone
-- ============================================
Config.Banking = {
    PrimaryResource = 'tgg-banking',
    PaymentMethods = {'cash', 'bank'},
    DefaultMethod = 'bank',
    AllowBalanceCheck = true,
    AllowTransfers = true,
    MinBalanceForHighTier = 100000
}

-- ============================================
-- SCARCITY SYSTEM (Mr. X's Personal Finances)
-- Mr. X has a real bank account - his mood affects rewards/behavior
-- ============================================
Config.Scarcity = {
    Enabled = true,
    AccountId = 'MRX0001',           -- ownerId in tgg_banking_accounts

    -- Balance thresholds for mood
    Thresholds = {
        Expansive = 100000,          -- > $100k = generous/expansive
        Neutral = 20000,             -- $20k-$100k = neutral
        Tense = 5000,                -- $5k-$20k = tense
        Desperate = 0                -- < $5k = desperate
    },

    -- Multipliers for mission rewards/costs based on mood
    Multipliers = {
        Expansive = { rewardBonus = 1.5, extortionChance = 0.1 },
        Neutral = { rewardBonus = 1.0, extortionChance = 0.3 },
        Tense = { rewardBonus = 0.8, extortionChance = 0.5 },
        Desperate = { rewardBonus = 0.5, extortionChance = 0.8 }
    },

    -- Income/expense events
    IncomeEvents = {
        MissionCut = 0.15,           -- 15% of completed mission rewards
        ExtortionSuccess = true,
        ServiceFee = 500
    }
}

-- ============================================
-- PERSONALITY SYSTEM
-- Dynamic tone based on reputation + balance + context
-- ============================================
Config.Personality = {
    Enabled = true,

    -- Reputation-based tones
    ReputationTiers = {
        { min = 81, max = 100, tier = 'elite', tone = 'possessive', desc = 'Treats player as prized asset' },
        { min = 51, max = 80, tier = 'trusted', tone = 'confident', desc = 'Professional respect' },
        { min = 21, max = 50, tier = 'tested', tone = 'calculating', desc = 'Testing, probing' },
        { min = 0, max = 20, tier = 'unknown', tone = 'cold', desc = 'Distant, no emotional investment' },
        { min = -100, max = -1, tier = 'disgraced', tone = 'contemptuous', desc = 'Disgust, disappointment' }
    },

    -- Situational context modifiers
    ContextModifiers = {
        mission_success = { tone_shift = 'pleased', intensity = 0.3 },
        mission_failure = { tone_shift = 'disappointed', intensity = 0.5 },
        dilemma_moral = { tone_shift = 'testing', intensity = 0.4 },
        dilemma_risk = { tone_shift = 'calculating', intensity = 0.3 },
        extortion = { tone_shift = 'threatening', intensity = 0.6 },
        reward = { tone_shift = 'magnanimous', intensity = 0.4 },
        warning = { tone_shift = 'ominous', intensity = 0.5 }
    }
}

-- ============================================
-- BOARDROOM SYSTEM
-- Periodic AI strategic planning sessions
-- ============================================
Config.Boardroom = {
    Enabled = true,
    IntervalHours = 24,                      -- Auto-run every 24 hours
    ManualCooldownMinutes = 60,              -- Min time between manual triggers

    AI = {
        Model = 'gpt-5.1',                   -- More powerful model for strategic planning
        Temperature = 0.7,
        MaxTokens = 2000
    },

    Context = {
        RecentEventsLimit = 50,              -- Events to include in context
        ActivePlayersOnly = true,            -- Only include online players
        IncludeFinancials = true,            -- Include balance/mood
        IncludeRepStats = true               -- Include reputation distribution
    },

    OutputDir = 'data/boardroom',            -- Meeting minutes storage
    NotifyAdmins = true                      -- Notify admins when meeting completes
}

-- ============================================
-- HARM OPTIONS (Punishments/Chaos)
-- ============================================
Config.Harm = {
    -- Fake police records (lb-tablet)
    FakeWarrant = {minRep = -1, weight = 0.3},      -- Target has negative rep
    FakeReport = {minRep = -1, weight = 0.2},
    FakeCase = {minRep = -1, weight = 0.1},
    FakeBOLO = {minRep = -1, weight = 0.15},
    FakeJailRecord = {minRep = -1, weight = 0.05},

    -- Physical threats
    HitSquad = {minRep = -1, weight = 0.1},         -- Armed NPCs
    DebtCollector = {minRep = -1, weight = 0.2},    -- Single NPC demanding payment
    Ambush = {minRep = -1, weight = 0.15},

    -- Player vs Player
    PlayerBounty = {minRep = -1, weight = 0.15},    -- Offer bounty to criminals
    GangContract = {minRep = -1, weight = 0.1},     -- Contact rival gang
    GangBetrayal = {minRep = -1, weight = 0.05},    -- Turn same gang against each other

    -- Information warfare
    LeakLocation = {minRep = -1, weight = 0.2},
    AnonymousTip = {minRep = -1, weight = 0.25},    -- Alert police
    VehicleTracker = {minRep = -1, weight = 0.1}
}

-- ============================================
-- BOUNTY SYSTEM
-- ============================================
Config.Bounties = {
    -- Bounty amount ranges
    AmountMin = 5000,
    AmountMax = 50000,

    -- Expiration (hours)
    ExpirationHours = 48,

    -- Who can receive bounty offers
    EligibleJobs = {'unemployed'},  -- Generic criminal
    EligibleGangs = {},  -- Will be populated from qbx_core gangs

    -- Notification settings
    NotifyRadius = -1  -- -1 = all eligible players, otherwise radius in units
}

-- ============================================
-- CHAOS ENGINE
-- ============================================
Config.ChaosEngine = {
    -- DISABLED BY DEFAULT - must be enabled via admin
    Enabled = false,

    -- How often to scan for chaos candidates (milliseconds)
    ScanIntervalMs = 1800000,  -- 30 minutes

    -- Criteria for chaos targeting
    Criteria = {
        LowRepThreshold = 10,       -- Rep below this triggers attention
        RecentFailures = 2,         -- Failures in 24h to trigger chaos
        AbandonedMissions = 1       -- Abandoned missions to trigger chaos
    },

    -- Cooldown between surprises per player (seconds)
    SurpriseCooldownSec = 3600,  -- 1 hour

    -- Warning message delay before surprise (seconds)
    WarningDelaySec = 45
}

-- ============================================
-- OPENAI SETTINGS (inherited from sv_nexus_tools)
-- Token optimization: Keep costs low while maintaining quality
-- ============================================
Config.OpenAI = {
    Model = 'gpt-5-mini',                    -- Faster model for normal AI actions
    Temperature = 0.8,

    -- Token limits (lower = cheaper)
    MaxTokens = {
        Mission = 500,      -- Mission generation (was 1000)
        Response = 150,     -- Conversation responses
        Analysis = 300      -- Player analysis
    },

    -- System prompt optimization
    UseCompactPrompt = true,       -- Use condensed system prompt
    CacheSystemPrompt = true,      -- Cache prompt in memory
    ExcludeVerboseContext = true,  -- Skip detailed history in prompts

    -- Response caching (avoid duplicate API calls)
    CacheResponses = true,
    CacheDurationSec = 300,        -- 5 minute cache

    -- Fallback behavior
    UseFallbackOnError = true,     -- Use template responses if API fails
    MaxRetriesOnError = 1          -- Only retry once to save costs
}

-- ============================================
-- OPT-OUT SYSTEM
-- Players who are exempt from Mr. X entirely
-- IMPORTANT: Opted-out players get NO contact from Mr. X:
--   - No missions offered
--   - No HARM surprises
--   - No HELP services (loans, intel, record clearing, etc.)
--   - No reputation tracking
-- This is for players bound by anti-corruption rules (PD/EMS leadership)
-- ============================================
Config.OptOut = {
    -- ACE permission that grants opt-out (add to permissions.cfg)
    -- Example: add_ace identifier.discord:123456789 sv_mr_x.optout allow
    AcePermission = 'sv_mr_x.optout',

    -- Jobs that are ALWAYS exempt (regardless of grade)
    -- These players will NEVER receive Mr. X contact
    ExemptJobs = {
        -- 'judge',  -- Uncomment to exempt all judges
    },

    -- Jobs exempt at or above a certain grade
    -- Format: {job = 'jobname', minGrade = X}
    -- Players at grade X or higher are exempt
    ExemptJobGrades = {
        {job = 'police', minGrade = 11},      -- Police Sergeant+ (department leadership)
        {job = 'lscso', minGrade = 11},        -- BCSO Sergeant+
        {job = 'lspd', minGrade = 3},        -- LSPD Sergeant+
        {job = 'sast', minGrade = 8},        -- SASP Sergeant+
        {job = 'safr', minGrade = 3},   -- EMS Supervisor+
        {job = 'doj', minGrade = 0},         -- All DOJ members (always exempt)
    },

    -- Gangs that are exempt (if any - usually none)
    ExemptGangs = {
        -- 'police_gang',  -- Example only
    },

    -- Allow players to self-opt-out via command (requires below permission)
    AllowSelfOptOut = false,

    -- ACE permission required to use /mrx_optout command (if AllowSelfOptOut is true)
    SelfOptOutPermission = 'sv_mr_x.canoptout',

    -- Message to send if Mr. X tries to contact an exempt player
    -- Set to nil to send nothing (silent exemption)
    ExemptMessage = nil,  -- Or: "I have no business with someone in your position."
}

-- ============================================
-- WEB SERVER / DASHBOARD
-- Bridge to localhost Node.js dashboard for observation and manual control
-- ============================================
Config.WebServer = {
    -- Master enable - must enable manually after setting up dashboard
    Enabled = true,

    -- Dashboard URL (Node.js Express server)
    URL = 'http://localhost:3000',

    -- API endpoints on the dashboard
    Endpoints = {
        Events = '/api/events',
        Status = '/api/status'
    },

    -- Shared secret for authentication (change this!)
    -- Must match WEBHOOK_SECRET in dashboard .env file
    Secret = 'Kx9mT4vR2nPq',

    -- Retry settings for failed webhooks
    RetryCount = 3,
    RetryDelayMs = 1000,

    -- HTTP request timeout (milliseconds)
    Timeout = 5000
}

-- ============================================
-- MANUAL MODE
-- Allow admins to send messages via web dashboard
-- ============================================
Config.ManualMode = {
    -- Enable/disable manual message sending
    Enabled = true,

    -- Only admins can send manual messages (recommended)
    RequireAdmin = true,

    -- Allow AI to refactor plain messages to Mr. X voice
    AllowAIRefactor = true
}

-- ============================================
-- DEBUG & LOGGING
-- ============================================
Config.Debug = false
Config.LogEvents = true  -- Log all events to mr_x_events table

-- ============================================
-- ARCHETYPES (Player classification)
-- NEW: 9-archetype system based on psychology axes
-- See shared/constants.lua for full archetype definitions
-- ============================================
Config.Archetypes = {
    -- Classification is now dynamic based on behavior tracking
    -- See MrXConstants.Archetypes, MrXConstants.Buckets, MrXConstants.MethodAxis, MrXConstants.LoyaltyAxis

    -- ==========================================
    -- CLASSIFICATION TIMING (Don't bucket too early!)
    -- We need clear signals from direct interactions before classifying
    -- ==========================================

    -- Minimum behavior events before archetype changes from UNCLASSIFIED
    MinEventsForClassification = 8,

    -- Minimum time (seconds) player must exist before classification
    MinTimeBeforeClassification = 7200,  -- 2 hours of gameplay

    -- Require at least one direct Mr. X interaction before full classification
    RequireDirectInteraction = true,

    -- Weight thresholds for axis determination (higher = need more evidence)
    AxisThresholds = {
        method = 3.0,   -- Need 3.0+ score difference to lock method axis
        loyalty = 3.0   -- Need 3.0+ score difference to lock loyalty axis
    },

    -- Confidence levels (how sure we are about classification)
    ConfidenceLevels = {
        LOW = {minEvents = 0, label = 'Observing'},
        MEDIUM = {minEvents = 8, label = 'Preliminary'},
        HIGH = {minEvents = 20, label = 'Confident'}
    },

    -- Archetype reevaluation settings
    ReevaluateOnMission = true,
    ReevaluateOnFact = true,
    ReevaluateInterval = 3600,       -- Also reevaluate every hour (seconds)

    -- Decay rate for old behaviors
    BehaviorDecayRate = 0.05,        -- 5% decay per reevaluation
    BehaviorDecayIntervalSec = 86400 -- Decay check every 24 hours
}

-- ============================================
-- CAMERA-AWARE INTELLIGENCE
-- Mr. X only gathers certain intel when players are in camera range
-- ============================================
Config.CameraIntel = {
    Enabled = true,
    CameraRange = 140.0,

    -- These fact types require player to be visible on a camera
    -- Physical activities that must be visually observed
    RequireCamera = {
        'VEHICLE_THEFT', 'LOCKPICK', 'WEAPON_PURCHASE', 'DRUG_ACTIVITY',
        'STORE_ROBBERY', 'BANK_ROBBERY', 'JEWELRY_HEIST', 'ASSOCIATION',
        'KILL', 'DEATH', 'CRAFTED_ITEM', 'GANG_TERRITORY', 'VEHICLE_REPAIR',
        -- Cash transactions are physical (counting/exchanging cash on camera)
        'LARGE_CASH_TRANSACTION', 'LARGE_CASH_DEPOSIT', 'LARGE_CASH_WITHDRAWAL'
    },

    -- These fact types are always recorded regardless of camera
    -- Administrative/electronic records, conversations, legal matters
    AlwaysRecord = {
        'JOB_CHANGE', 'GANG_CHANGE', 'POLICE_REPORT', 'WARRANT', 'BOLO',
        'ARRESTED', 'JAILED', 'LOAN', 'MISSION_OUTCOME', 'CONVERSATION'
    },

    TrackAssociations = true,
    AssociationRange = 20.0,
    AssociationScanInterval = 120000
}

-- ============================================
-- FINANCIAL INTELLIGENCE
-- Bank/electronic transactions are NOT visible on camera
-- They require Mr. X to have financial network access
-- ============================================
Config.FinancialIntel = {
    Enabled = true,

    -- Mr. X's current level of bank system access
    -- 'none'     = Cannot see any bank transactions
    -- 'basic'    = Can see large transactions (>$50k) but no details
    -- 'full'     = Can see all transactions with details
    -- Future: This could be upgraded via missions/services
    BankAccessLevel = 'basic',

    -- Minimum transaction amount to record as bank intel
    MinTransactionAmount = 50000,

    -- Fact types recorded via financial intel (not cameras)
    FinancialFactTypes = {
        'BANK_INTEL_TRANSACTION',
        'BANK_INTEL_DEPOSIT',
        'BANK_INTEL_WITHDRAWAL'
    },

    -- Note: To expand this system, Mr. X could:
    -- 1. Run missions to "hack" or "bribe" bank employees
    -- 2. Purchase bank access as a service
    -- 3. Gradually lose access if the bank detects intrusion
}

return Config
