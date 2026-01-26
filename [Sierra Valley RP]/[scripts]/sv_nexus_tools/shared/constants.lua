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
    WORLD = 'world'
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
