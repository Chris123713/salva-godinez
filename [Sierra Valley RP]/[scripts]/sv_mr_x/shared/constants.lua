--[[
    Mr. X Shared Constants
    Accessible from both client and server
]]

MrXConstants = {}

-- ============================================
-- PRIMARY BUCKETS (High-level classification)
-- Based on job/role in the city
-- ============================================
MrXConstants.Buckets = {
    AUTHORITY = 'authority',   -- Police, EMS, DOJ - law enforcement/emergency
    CIVILIAN = 'civilian',     -- Legit jobs, businesses - gray area
    CRIMINAL = 'criminal'      -- Gangs, unemployed + crime history
}

-- ============================================
-- ALIGNMENT AXES (GTA-flavored D&D inspiration)
-- ============================================

-- Method Axis: HOW they operate
MrXConstants.MethodAxis = {
    CALCULATED = 'calculated',     -- Plans, patience, minimal collateral
    OPPORTUNISTIC = 'opportunistic', -- Takes chances, flexible morals
    RECKLESS = 'reckless'          -- Violent, impulsive, high heat
}

-- Loyalty Axis: WHO they serve
MrXConstants.LoyaltyAxis = {
    CIVIC = 'civic',   -- Follows rules, protects community
    SELF = 'self',     -- Personal gain, looks out for #1
    CREW = 'crew'      -- Gang/family first, organized
}

-- ============================================
-- ARCHETYPES (Combined from axes)
-- 9 archetypes from 3x3 alignment grid
-- ============================================
MrXConstants.Archetypes = {
    -- Calculated + Civic = GUARDIAN (clean cop, by-the-book EMS)
    GUARDIAN = 'guardian',

    -- Calculated + Self = FIXER (corrupt official, smart hustler)
    FIXER = 'fixer',

    -- Calculated + Crew = SYNDICATE (gang leadership, organized crime)
    SYNDICATE = 'syndicate',

    -- Opportunistic + Civic = REFORMER (vigilante, gray-area justice)
    REFORMER = 'reformer',

    -- Opportunistic + Self = HUSTLER (wheeler-dealer, scammer)
    HUSTLER = 'hustler',

    -- Opportunistic + Crew = SOLDIER (loyal gang member)
    SOLDIER = 'soldier',

    -- Reckless + Civic = LOOSE_CANNON (dirty cop, revenge-seeker)
    LOOSE_CANNON = 'loose_cannon',

    -- Reckless + Self = WILDCARD (unpredictable loner)
    WILDCARD = 'wildcard',

    -- Reckless + Crew = ENFORCER (gang muscle, violent criminal)
    ENFORCER = 'enforcer',

    -- Default/new player (not yet classified)
    UNCLASSIFIED = 'unclassified'
}

-- ============================================
-- ARCHETYPE GRID LOOKUP
-- Maps (method, loyalty) -> archetype
-- ============================================
MrXConstants.ArchetypeGrid = {
    calculated = {
        civic = 'guardian',
        self = 'fixer',
        crew = 'syndicate'
    },
    opportunistic = {
        civic = 'reformer',
        self = 'hustler',
        crew = 'soldier'
    },
    reckless = {
        civic = 'loose_cannon',
        self = 'wildcard',
        crew = 'enforcer'
    }
}

-- ============================================
-- ARCHETYPE METADATA
-- Used for AI personality adaptation and mission selection
-- ============================================
MrXConstants.ArchetypeInfo = {
    guardian = {
        label = 'Guardian',
        description = 'By-the-book, protects the community',
        mrx_approach = 'exempt_or_rare_intel',
        typical_bucket = 'authority',
        mission_types = {'intel_tip'},
        exempt_default = true
    },
    fixer = {
        label = 'Fixer',
        description = 'Smart operator, works the system',
        mrx_approach = 'high_value_services',
        typical_bucket = 'civilian',
        mission_types = {'trade', 'smuggling', 'intel', 'blackmail'},
        exempt_default = false
    },
    syndicate = {
        label = 'Syndicate',
        description = 'Organized crime leadership',
        mrx_approach = 'strategic_partnership',
        typical_bucket = 'criminal',
        mission_types = {'coordination', 'territory', 'high_stakes'},
        exempt_default = false
    },
    reformer = {
        label = 'Reformer',
        description = 'Vigilante, bends rules for good',
        mrx_approach = 'moral_dilemmas',
        typical_bucket = 'civilian',
        mission_types = {'vigilante', 'dilemma', 'gray_area'},
        exempt_default = false
    },
    hustler = {
        label = 'Hustler',
        description = 'Money-focused opportunist',
        mrx_approach = 'profit_focused',
        typical_bucket = 'civilian',
        mission_types = {'scam', 'trade', 'quick_cash'},
        exempt_default = false
    },
    soldier = {
        label = 'Soldier',
        description = 'Loyal gang member, follows orders',
        mrx_approach = 'standard_criminal',
        typical_bucket = 'criminal',
        mission_types = {'enforcement', 'delivery', 'gang_work'},
        exempt_default = false
    },
    loose_cannon = {
        label = 'Loose Cannon',
        description = 'Unstable, unpredictable authority',
        mrx_approach = 'chaos_opportunities',
        typical_bucket = 'authority',
        mission_types = {'revenge', 'chaos', 'dirty_work'},
        exempt_default = false
    },
    wildcard = {
        label = 'Wildcard',
        description = 'Unpredictable loner',
        mrx_approach = 'high_risk_high_reward',
        typical_bucket = 'criminal',
        mission_types = {'any', 'high_risk', 'solo'},
        exempt_default = false
    },
    enforcer = {
        label = 'Enforcer',
        description = 'Gang muscle, violence specialist',
        mrx_approach = 'harm_heavy',
        typical_bucket = 'criminal',
        mission_types = {'violence', 'intimidation', 'hits'},
        exempt_default = false
    },
    unclassified = {
        label = 'Unclassified',
        description = 'New player, not yet evaluated',
        mrx_approach = 'observation',
        typical_bucket = 'civilian',
        mission_types = {'simple', 'test'},
        exempt_default = false
    }
}

-- ============================================
-- BEHAVIOR EVENT CATEGORIES
-- For tracking and classification
-- ============================================
MrXConstants.BehaviorCategories = {
    -- Violence indicators
    VIOLENCE = 'violence',
    STEALTH = 'stealth',
    TRADE = 'trade',

    -- Loyalty indicators
    LOYALTY_CREW = 'loyalty_crew',
    LOYALTY_SELF = 'loyalty_self',
    LOYALTY_CIVIC = 'loyalty_civic',

    -- Method indicators
    RECKLESS = 'reckless',
    CALCULATED = 'calculated',
    OPPORTUNISTIC = 'opportunistic'
}

-- ============================================
-- LEGACY ARCHETYPES (backward compatibility)
-- Map old archetypes to new system
-- ============================================
MrXConstants.LegacyArchetypeMap = {
    thug = 'enforcer',
    wheeler_dealer = 'hustler',
    silent_pro = 'fixer',
    wildcard = 'wildcard',
    civilian = 'unclassified'
}

-- ============================================
-- REPUTATION TIERS
-- ============================================
MrXConstants.ReputationTiers = {
    EASY = 'easy',           -- 0-20: Simple tasks, low stakes
    DILEMMA = 'dilemma',     -- 21-50: Moral choices, moderate risk
    HIGH_RISK = 'high_risk'  -- 51+: Complex operations, high stakes
}

-- ============================================
-- COMMUNICATION CHANNELS
-- ============================================
MrXConstants.CommsChannels = {
    SMS = 'sms',
    EMAIL = 'email',
    CALL = 'call',
    NOTIFICATION = 'notification'
}

-- ============================================
-- MISSION OUTCOMES
-- ============================================
MrXConstants.MissionOutcome = {
    SUCCESS = 'success',
    FAILURE = 'failure',
    ABANDONED = 'abandoned',
    TIMEOUT = 'timeout'
}

-- ============================================
-- SESSION STATUS
-- ============================================
MrXConstants.SessionStatus = {
    ACTIVE = 'active',
    COMPLETED = 'completed',
    TIMEOUT = 'timeout'
}

-- ============================================
-- EVENT TYPES (for logging)
-- ============================================
MrXConstants.EventTypes = {
    -- Communication events
    MESSAGE_SENT = 'message_sent',
    MESSAGE_RECEIVED = 'message_received',
    EMAIL_SENT = 'email_sent',
    CALL_INITIATED = 'call_initiated',
    NOTIFICATION_SENT = 'notification_sent',

    -- Profile events
    PROFILE_CREATED = 'profile_created',
    ARCHETYPE_CHANGED = 'archetype_changed',
    REP_CHANGED = 'rep_changed',

    -- Mission events
    MISSION_OFFERED = 'mission_offered',
    MISSION_ACCEPTED = 'mission_accepted',
    MISSION_COMPLETED = 'mission_completed',
    MISSION_FAILED = 'mission_failed',
    MISSION_ABANDONED = 'mission_abandoned',

    -- Service events
    SERVICE_REQUESTED = 'service_requested',
    SERVICE_COMPLETED = 'service_completed',
    LOAN_ISSUED = 'loan_issued',
    LOAN_REPAID = 'loan_repaid',
    LOAN_DEFAULTED = 'loan_defaulted',

    -- HARM events
    SURPRISE_WARNING = 'surprise_warning',
    SURPRISE_TRIGGERED = 'surprise_triggered',
    BOUNTY_POSTED = 'bounty_posted',
    BOUNTY_ACCEPTED = 'bounty_accepted',
    BOUNTY_CLAIMED = 'bounty_claimed',
    GANG_BETRAYAL = 'gang_betrayal',

    -- Tablet events
    FAKE_WARRANT_CREATED = 'fake_warrant_created',
    FAKE_REPORT_CREATED = 'fake_report_created',
    FAKE_CASE_CREATED = 'fake_case_created',
    RECORD_CLEARED = 'record_cleared',

    -- Chaos events
    CHAOS_SCAN = 'chaos_scan',
    CHAOS_CANDIDATE = 'chaos_candidate',
    CHAOS_TRIGGERED = 'chaos_triggered',

    -- Admin events
    TEST_MODE_TOGGLED = 'test_mode_toggled',
    ADMIN_ACTION = 'admin_action'
}

-- ============================================
-- SURPRISE TYPES (HARM mechanisms)
-- ============================================
MrXConstants.SurpriseTypes = {
    -- Physical threats
    AMBUSH = 'ambush',
    HIT_SQUAD = 'hit_squad',
    DEBT_COLLECTOR = 'debt_collector',

    -- Information warfare
    LEAK_LOCATION = 'leak_location',
    ANONYMOUS_TIP = 'anonymous_tip',
    VEHICLE_TRACKER = 'vehicle_tracker',

    -- Record manipulation
    FAKE_WARRANT = 'fake_warrant',
    FAKE_REPORT = 'fake_report',
    FAKE_CASE = 'fake_case',
    FAKE_BOLO = 'fake_bolo',
    FAKE_JAIL_RECORD = 'fake_jail_record',

    -- Player vs Player
    PLAYER_BOUNTY = 'player_bounty',
    GANG_CONTRACT = 'gang_contract',
    GANG_BETRAYAL = 'gang_betrayal'
}

-- ============================================
-- SERVICE TYPES (HELP options)
-- ============================================
MrXConstants.ServiceTypes = {
    -- Record clearing
    CLEAR_WARRANT = 'clear_warrant',
    CLEAR_REPORT = 'clear_report',
    CLEAR_CASE = 'clear_case',
    CLEAN_SLATE = 'clean_slate',

    -- Intel
    TARGET_INTEL = 'target_intel',
    LOCATION_TIP = 'location_tip',

    -- Emergency
    POLICE_DIVERSION = 'police_diversion',
    EARLY_WARNING = 'early_warning',
    EMERGENCY_LOAN = 'emergency_loan'
}

-- ============================================
-- BOUNTY STATUS
-- ============================================
MrXConstants.BountyStatus = {
    ACTIVE = 'active',
    ACCEPTED = 'accepted',
    CLAIMED = 'claimed',
    EXPIRED = 'expired',
    CANCELLED = 'cancelled'
}

-- ============================================
-- LOAN STATUS
-- ============================================
MrXConstants.LoanStatus = {
    ACTIVE = 'active',
    PAID = 'paid',
    OVERDUE = 'overdue',
    DEFAULTED = 'defaulted'
}

-- ============================================
-- MR. X PERSONALITY MESSAGES
-- ============================================
MrXConstants.Messages = {
    -- Greetings
    Greetings = {
        "I've been watching you.",
        "Your reputation precedes you.",
        "I have a proposition.",
        "The right person at the right time.",
        "I believe we can help each other."
    },

    -- Mission offers
    MissionOffers = {
        "A simple task. Don't disappoint me.",
        "Prove yourself worthy.",
        "An opportunity awaits.",
        "This requires... discretion.",
        "High risk. High reward."
    },

    -- Success messages
    Success = {
        "Well done. We'll be in touch.",
        "Efficient. I like that.",
        "Your reputation grows.",
        "Payment has been arranged.",
        "You've earned my trust."
    },

    -- Failure messages
    Failure = {
        "Disappointing.",
        "I expected more.",
        "This changes things.",
        "Failure has consequences.",
        "Perhaps I misjudged you."
    },

    -- Warning messages (before HARM)
    Warnings = {
        "I know where you are.",
        "Your actions have consequences.",
        "Someone is looking for you.",
        "Watch your back.",
        "You should have been more careful."
    },

    -- Rep change notifications
    RepGain = {
        "Your standing improves.",
        "Noted.",
        "Trust is earned."
    },

    RepLoss = {
        "Disappointing.",
        "We'll remember this.",
        "Trust is fragile."
    }
}

return MrXConstants
