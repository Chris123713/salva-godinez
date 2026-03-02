-- Shared constants for sv_nexus_tools

Constants = {}

-- Mission Status
Constants.MissionStatus = {
    SETUP = 'setup',
    ACTIVE = 'active',
    COMPLETED = 'completed',
    FAILED = 'failed',
    CANCELLED = 'cancelled'
}

-- Objective Status
Constants.ObjectiveStatus = {
    PENDING = 'pending',
    ACTIVE = 'active',
    COMPLETED = 'completed',
    FAILED = 'failed',
    LOCKED = 'locked'
}

-- Entity Types
Constants.EntityType = {
    NPC = 'npc',
    VEHICLE = 'vehicle',
    PROP = 'prop'
}

-- Money Types
Constants.MoneyType = {
    CASH = 'cash',
    BANK = 'bank',
    CRYPTO = 'crypto'
}

-- Tool Categories
Constants.ToolCategory = {
    SPAWNING = 'spawning',
    ECONOMY = 'economy',
    INVENTORY = 'inventory',
    DIALOG = 'dialog',
    MISSION = 'mission',
    PHONE = 'phone',
    UTILITY = 'utility',
    CRIMINAL = 'criminal',
    POLICE = 'police',
    SOCIAL = 'social',
    WORLD = 'world',
    ELEMENTS = 'elements',       -- Element library operations
    GAMEPLAY = 'gameplay',       -- Direct gameplay manipulation
    MULTIPLAYER = 'multiplayer'  -- Multi-player mission coordination
}

-- Spawn Types (for zone verification)
Constants.SpawnType = {
    NPC = 'npc',
    VEHICLE = 'vehicle',
    PROP = 'prop',
    ANY = 'any'
}

-- NPC Behaviors
Constants.NpcBehavior = {
    IDLE = 'idle',
    WANDER = 'wander',
    GUARD = 'guard',
    COWER = 'cower',
    HOSTILE = 'hostile',
    FLEE = 'flee'
}

-- Dialog Outcome Types
Constants.DialogOutcome = {
    MONEY = 'money',
    ITEM = 'item',
    OBJECTIVE = 'objective',
    REP = 'rep',
    EVENT = 'event'
}

-- Blueprint Element Types
Constants.BlueprintElement = {
    NPC = 'npc',
    VEHICLE = 'vehicle',
    PROP = 'prop',
    ZONE = 'zone',
    BLIP = 'blip'
}

-- Event Names (for consistency)
Constants.Events = {
    -- Server events
    SERVER = {
        EXECUTE_TOOLS = 'nexus:server:executeTools',
        CREATE_MISSION = 'nexus:server:createMission',
        UPDATE_OBJECTIVE = 'nexus:server:updateObjective',
        SPAWN_ENTITY = 'nexus:server:spawnEntity',
        CLEANUP_MISSION = 'nexus:server:cleanupMission'
    },
    -- Client events
    CLIENT = {
        MISSION_SYNC = 'nexus:client:missionSync',
        OBJECTIVE_UPDATE = 'nexus:client:objectiveUpdate',
        ENTITY_SPAWNED = 'nexus:client:entitySpawned',
        DIALOG_START = 'nexus:client:dialogStart',
        TOOLS_COMPLETE = 'nexus:client:toolsComplete',
        SHOW_PERF = 'nexus:client:showPerf'
    }
}

-- Sound Effects
Constants.Sounds = {
    PLACE = {soundId = 'PICK_UP_WEAPON', soundSet = 'HUD_FRONTEND_WEAPONS_PICKUPS_SOUNDSET'},
    ERROR = {soundId = 'ERROR', soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'},
    ROTATE = {soundId = 'NAV_UP_DOWN', soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'},
    SUCCESS = {soundId = 'SELECT', soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'},
    DIALOG = {soundId = 'CLICK_BACK', soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET'}
}

-- Default Models
Constants.DefaultModels = {
    NPC = 's_m_m_scientist_01',
    VEHICLE = 'sultan',
    PROP = 'prop_box_wood02a'
}

-- Zone Themes (for get_safe_coords)
Constants.ZoneThemes = {
    'alley',
    'parking',
    'industrial',
    'residential',
    'commercial',
    'rural',
    'beach',
    'dock'
}

-- Element Tag Categories (for element library)
Constants.TagCategory = {
    ROLE = 'role',
    LOCATION = 'location',
    USE_CASE = 'use_case',
    SCENARIO = 'scenario',
    CUSTOM = 'custom'
}

-- Role Tags (what the element represents)
Constants.RoleTags = {
    'contact_npc', 'informant', 'enemy', 'guard', 'victim', 'hostage',
    'witness', 'getaway_driver', 'lookout', 'hacker', 'vip', 'buyer',
    'seller', 'patrol', 'civilian', 'boss'
}

-- Location Tags (where the element is)
Constants.LocationTags = {
    'alley', 'parking', 'industrial', 'residential', 'commercial',
    'dock', 'rooftop', 'interior', 'rural', 'beach', 'highway',
    'underground', 'warehouse', 'office', 'bar', 'club'
}

-- Use Case Tags (how the element behaves)
Constants.UseCaseTags = {
    'npc_standing', 'npc_sitting', 'npc_prone', 'npc_working',
    'vehicle_parked', 'vehicle_crashed', 'vehicle_running',
    'prop_interactive', 'prop_loot', 'prop_cover', 'prop_decoration',
    'zone_restricted', 'zone_safe', 'zone_combat', 'zone_objective'
}

-- Scenario Tags (mission context)
Constants.ScenarioTags = {
    'crash_scene', 'heist', 'investigation', 'delivery', 'pursuit',
    'rescue', 'gang_meeting', 'stakeout', 'ambush', 'escort',
    'extraction', 'sabotage', 'surveillance', 'territory'
}

-- Mission Patterns (for pattern-based generation)
Constants.MissionPattern = {
    HEIST = 'heist',
    ESCORT = 'escort',
    PURSUIT = 'pursuit',
    STEALTH = 'stealth',
    INVESTIGATION = 'investigation',
    SABOTAGE = 'sabotage',
    SURVEILLANCE = 'surveillance',
    EXTRACTION = 'extraction',
    AMBUSH = 'ambush',
    CLEANUP = 'cleanup',
    TERRITORY = 'territory',
    COURIER = 'courier'
}

-- Multi-player Role Types
Constants.RoleType = {
    COOPERATIVE = 'cooperative',
    BATON_PASS = 'baton_pass',
    ADVERSARIAL = 'adversarial'
}

-- Explosion Types (for trigger_explosion)
Constants.ExplosionType = {
    GRENADE = 0,
    GRENADELAUNCHER = 1,
    STICKYBOMB = 2,
    MOLOTOV = 3,
    ROCKET = 4,
    TANKSHELL = 5,
    HI_OCTANE = 6,
    CAR = 7,
    PLANE = 8,
    PETROL_PUMP = 9,
    BIKE = 10,
    DIR_STEAM = 11,
    DIR_FLAME = 12,
    DIR_WATER_HYDRANT = 13,
    DIR_GAS_CANISTER = 14,
    BOAT = 15,
    SHIP_DESTROY = 16,
    TRUCK = 17,
    BULLET = 18,
    SMOKEGRENADELAUNCHER = 19,
    SMOKEGRENADE = 20,
    BZGAS = 21,
    FLARE = 22,
    GAS_CANISTER = 23,
    EXTINGUISHER = 24,
    PROGRAMMABLEAR = 25,
    TRAIN = 26,
    BARREL = 27,
    PROPANE = 28,
    BLIMP = 29,
    DIR_FLAME_EXPLODE = 30,
    TANKER = 31,
    PLANE_ROCKET = 32,
    VEHICLE_BULLET = 33,
    GAS_TANK = 34,
    FIREWORK = 35,
    SNOWBALL = 36,
    PROXMINE = 37,
    VALKYRIE_CANNON = 38
}

-- Screen Effect Types (for screen_effect)
Constants.ScreenEffect = {
    DRUG_DRIVING = 'DrugsDrivingIn',
    DRUG_MICHAEL = 'DrugsMichaelAliensFightIn',
    DRUG_TREVOR = 'DrugsTrevorClownsFightIn',
    DRUNK = 'DrunkVision',
    FOCUS = 'FocusIn',
    MINDCONTROL = 'MindControlSceneIn',
    RACETURBO = 'RaceTurbo',
    RAMPAGE = 'Rampage',
    DAMAGE = 'Damage',
    DEATH_FAIL = 'DeathFailMPIn',
    DONT_TAZE = 'DontTazeMe',
    MP_CORONA = 'MP_corona_switch',
    NIGHT_VISION = 'NightVision',
    SPECTATOR1 = 'spectator1',
    SPECTATOR2 = 'spectator2',
    SPECTATOR3 = 'spectator3'
}
