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
    -- DISABLED: All contact should be triggered via dashboard testing only
    Enabled = false,

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
    },

    -- Special contact types for prospects (separate from normal contacts)
    ProspectContactTypes = {
        WELCOME = 0.25,         -- 25% - Welcome message + optional gift
        JOB_SUGGESTION = 0.30,  -- 30% - Suggest a job Mr. X needs filled
        CHECK_IN = 0.20,        -- 20% - Friendly check-in
        TIP = 0.15,             -- 15% - Free helpful tip
        FIRST_MISSION = 0.10    -- 10% - Offer first easy mission
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
        warning = { tone_shift = 'ominous', intensity = 0.5 },
        -- NEW: Prospect-specific context
        prospect_contact = { tone_shift = 'mentoring', intensity = 0.8 },
        prospect_nudge = { tone_shift = 'helpful', intensity = 0.7 },
        prospect_gift = { tone_shift = 'generous', intensity = 0.6 }
    },

    -- Special tone for prospects (overrides normal reputation-based tone)
    ProspectTone = {
        description = 'Friendly mentor who wants to help new players succeed',
        tone = 'welcoming',
        avoid = {'threatening', 'cold', 'contemptuous'},
        emphasize = {'helpful', 'patient', 'encouraging'}
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
    VehicleTracker = {minRep = -1, weight = 0.1},

    -- Power moves
    PhoneHack = {minRep = -1, weight = 0.15}        -- Take selfie via their phone
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
-- PROSPECT SYSTEM
-- Identifies and nurtures new players, nudging them toward roles Mr. X needs
-- ============================================
Config.Prospect = {
    Enabled = true,

    -- Detection criteria for PROSPECT archetype
    Detection = {
        Job = 'unemployed',           -- Must be unemployed
        MaxMoney = 20000,             -- Total cash + bank < $20k
        MaxPlaytime = 7200,           -- Less than 2 hours playtime (seconds)
        NoGang = true,                -- Must not be in a gang
        MaxReputation = 10            -- Must have low/no Mr. X reputation
    },

    -- How often to scan for new prospects (milliseconds)
    ScanIntervalMs = 300000,  -- 5 minutes

    -- Cooldown before contacting same prospect again (seconds)
    ContactCooldownSec = 1800,  -- 30 minutes

    -- ==========================================
    -- MR. X'S CURRENT NEEDS
    -- These are the roles Mr. X is actively trying to fill
    -- The AI will consider these when nudging prospects
    -- ==========================================
    CurrentNeeds = {
        -- Job placements Mr. X wants insiders in
        JobPlacements = {
            { job = 'mechanic', priority = 3, reason = 'Need eyes on vehicle modifications' },
            { job = 'taxi', priority = 2, reason = 'Mobile intel gatherers' },
            { job = 'trucker', priority = 2, reason = 'Smuggling potential' },
            { job = 'realestate', priority = 1, reason = 'Property access' }
        },

        -- Gang recruitment targets
        GangRecruits = {
            -- { gang = 'ballas', priority = 3, reason = 'Expanding south side influence' },
            -- { gang = 'vagos', priority = 2, reason = 'Need connections in that territory' }
        },

        -- General criminal recruits (no specific gang)
        CriminalRecruits = {
            { type = 'driver', priority = 3, reason = 'Need getaway drivers' },
            { type = 'lookout', priority = 2, reason = 'Surveillance for operations' },
            { type = 'dealer', priority = 2, reason = 'Drug distribution network' }
        },

        -- Authority placements (rare, high value)
        AuthorityPlacements = {
            { job = 'police', priority = 1, reason = 'Inside information (high risk)' },
            { job = 'ems', priority = 1, reason = 'Access to hospital/morgue' }
        }
    },

    -- ==========================================
    -- NUDGE MESSAGING
    -- Mr. X approaches prospects as a FRIENDLY MENTOR
    -- Goal: Be helpful, build loyalty, retain players, exploit later
    -- ==========================================
    Messaging = {
        -- Initial contact - warm, welcoming, helpful
        InitialContact = {
            "Welcome to the city. It can be overwhelming at first. Consider me a friend who knows the ropes.",
            "I noticed you're new in town. If you need guidance, I know how things work around here.",
            "Everyone needs help starting out. I like to look after promising newcomers.",
            "New to Sierra Valley? Let me know if you need anything. The city rewards those who know the right people."
        },

        -- When suggesting a job - helpful career advice
        JobNudge = {
            "Looking for work? I know %s is hiring and they treat their people well. Good way to get started.",
            "A friend at %s mentioned they need help. Could be a solid opportunity for you.",
            "If you want to make honest money, %s is a good place to start. Tell them I recommended you.",
            "%s is always looking for reliable people. It's steady work and you'll learn the city."
        },

        -- Casual check-ins - build rapport
        CheckIn = {
            "How are you settling in? Let me know if you need anything.",
            "Just checking in. Finding your way around okay?",
            "Hope the city's treating you well. Remember, I'm here if you need guidance.",
            "Still getting your bearings? Take your time. Opportunities will come."
        },

        -- Small helpful tips - free value, builds trust
        FreeTips = {
            "Pro tip: The mechanic shop on Strawberry pays better than you'd think.",
            "If you need quick cash, taxi driving is flexible and you learn the streets.",
            "The trucking depot near the docks always needs drivers. Easy way to make money.",
            "Hint: The people at Benny's appreciate reliable workers. Worth checking out."
        },

        -- When they're ready - soft criminal introduction
        CrimeNudge = {
            "You've been working hard. If you ever want to make some real money, I know other ways.",
            "Legitimate work is good, but there are faster paths to success. When you're ready, we'll talk.",
            "Some of my best people started just like you. If you want more than a paycheck, let me know.",
            "I like what I see. When you're ready for something bigger, I might have opportunities."
        },

        -- First mission offer - framed as opportunity, not demand
        FirstMission = {
            "I have a small job that could use someone fresh. Easy money, no strings. Interested?",
            "Want to earn some quick cash? I have something simple. Consider it a favor between friends.",
            "Here's an opportunity: easy task, good pay. A chance to show what you're capable of.",
            "I'm offering you a chance to earn. Simple work, fair payment. What do you say?"
        },

        -- Money gift for brand new prospects (one-time)
        WelcomeGift = {
            "Consider this a welcome gift. The city can be tough on newcomers. $500 to help you get started.",
            "Here's $500 - call it an investment in your future. No strings attached.",
            "A little startup money for you. Use it wisely. We'll be in touch.",
            "Take this $500. Consider it my way of saying welcome to Sierra Valley."
        }
    },

    -- Welcome gift amount for brand new prospects
    WelcomeGiftAmount = 500,
    WelcomeGiftCooldown = 86400,  -- Only once per day across all prospects

    -- Reputation bonus for prospects who follow suggestions
    FollowThroughBonus = {
        JobAccepted = 5,      -- Prospect took the suggested job
        MissionComplete = 8,   -- Prospect completed first mission
        GangJoined = 10        -- Prospect joined suggested gang
    }
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
-- SNITCH NETWORK
-- Players can sell intel about other players to Mr. X
-- ============================================
Config.SnitchNetwork = {
    Enabled = true,

    -- Keywords that trigger snitch mode (checked in player messages)
    TriggerKeywords = {
        'i have info',
        'i have intel',
        'got info on',
        'got intel on',
        'snitch',
        'rat out',
        'sell info',
        'sell intel',
        'information to sell',
        'i saw someone',
        'i know someone',
        'tip about'
    },

    -- Payment tiers based on intel quality
    Payments = {
        -- Location intel (where target is/was seen)
        Location = {
            base = 500,
            verified = 1000,  -- If target is actually there
            stale = 250       -- If info is old (>10 min)
        },
        -- Vehicle intel (what they drive)
        Vehicle = {
            base = 750,
            withPlate = 1500
        },
        -- Activity intel (what they're doing)
        Activity = {
            minor = 500,      -- Legal activities
            criminal = 2000,  -- Criminal activity witnessed
            major = 5000      -- Major crime (heist, murder)
        },
        -- Associate intel (who they hang with)
        Associates = {
            base = 1000,
            gang = 2500       -- Gang affiliation confirmed
        }
    },

    -- Reputation rewards for snitching
    ReputationGain = {
        base = 2,
        verified = 5,
        majorIntel = 10
    },

    -- Cooldowns
    Cooldowns = {
        PerTarget = 3600,     -- Can't snitch on same person within 1 hour
        PerSnitch = 300       -- Must wait 5 min between any snitch reports
    },

    -- Risk of exposure (future feature)
    ExposureRisk = {
        Enabled = false,      -- TODO: Implement snitch exposure mechanic
        BaseChance = 0.05,    -- 5% chance target learns who snitched
        IncreasePerReport = 0.02
    },

    -- Mr. X intro messages when player triggers snitch mode
    IntroMessages = {
        "So you have information to sell. I'm listening. Who are we talking about?",
        "Intel is currency in this city. What do you have for me?",
        "Information... my favorite commodity. Tell me more.",
        "I reward those who keep their eyes open. Who's on your radar?"
    },

    -- Conversation flow prompts
    Prompts = {
        AskTarget = "Give me a name. First and last.",
        AskDetails = "What did you see? Be specific.",
        AskLocation = "Where was this?",
        AskWhen = "When did this happen?",
        Confirm = "I'll verify this. If your intel checks out, you'll be compensated.",
        Invalid = "That name doesn't match anyone in my network. Try again or stop wasting my time.",
        Verified = "Good intel. %s has been deposited to your account. Keep your eyes open.",
        Unverified = "I couldn't verify this. You get half. Don't bring me rumors next time.",
        Duplicate = "I already know this. Don't waste my time with stale information.",
        Cooldown = "You've told me enough for now. Come back later.",
        TargetCooldown = "I have recent intel on this person. Find me someone else."
    }
}

-- ============================================
-- PHONE HACK SYSTEM
-- Mr. X can demonstrate his power by taking control of a player's phone
-- ============================================
Config.PhoneHack = {
    Enabled = true,

    -- Discord webhook for image storage (returns permanent URL)
    DiscordWebhook = 'https://discord.com/api/webhooks/1465185575676936205/Qx7UypgSvMeRU48bs4yL0irYD0Outod_dTcOWbd0U7vEqAn6qasbtRYcCcfKg0k3y5a6',

    -- Messages sent with the selfie
    Messages = {
        -- Sent before the selfie
        Warning = "I can see everything you do.",
        -- Sent with the selfie image
        WithImage = "Nice photo. I took it myself. Your phone, your camera, my control.",
        -- Alternative messages (random selection)
        Alternatives = {
            "Remember - I'm always watching.",
            "You look surprised. You shouldn't be.",
            "Consider this a reminder of who you're dealing with.",
            "Smile for the camera. Or don't. I don't need your permission."
        }
    },

    -- Cooldown per player (seconds) - don't spam this power move
    CooldownSeconds = 3600,  -- 1 hour

    -- Minimum reputation to be targeted (usually negative rep players)
    -- Set to nil to allow targeting anyone
    MinReputation = nil,

    -- Add screen glitch effect during capture
    UseGlitchEffect = true,

    -- Duration of the "hack" effect (milliseconds)
    HackDurationMs = 3000
}

-- ============================================
-- AGENT TOOLS SYSTEM (MCP-Style Autonomous Behavior)
-- Transforms Mr. X from "text generator" to "autonomous agent with tools"
-- The AI decides WHAT to do, not just what to say
-- ============================================
Config.AgentTools = {
    -- Master enable/disable for the agent tools system
    Enabled = true,

    -- Automatically trigger agent on player login
    EnableLoginTrigger = true,

    -- Automatically trigger agent on mission completion
    EnableMissionTrigger = true,

    -- Maximum iterations for agent loop (prevents infinite loops)
    MaxIterations = 5,

    -- OpenAI model for agent decisions (can use more capable model than regular comms)
    Model = 'gpt-4o-mini',

    -- Temperature for agent decisions (lower = more deterministic)
    Temperature = 0.7,

    -- Maximum tokens for agent response
    MaxTokens = 1000,

    -- Delay after player login before triggering agent (milliseconds)
    LoginTriggerDelay = 5000,

    -- Debug logging for agent tool execution
    DebugLogging = true
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
