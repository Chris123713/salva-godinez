Config = {}

-- General Settings
Config.JobName = 'taxi' -- Must match job name in qbx_core/shared/jobs.lua
Config.EnableDebug = true

-- Rank System Configuration
Config.Ranks = {
    [1] = {
        name = 'Rookie Driver',
        xpRequired = 0,
        color = '#95A5A6',
        unlocks = {'taxi'} -- Available vehicles
    },
    [2] = {
        name = 'Junior Driver',
        xpRequired = 500,
        color = '#3498DB',
        unlocks = {'taxi', 'taxi2'}
    },
    [3] = {
        name = 'Professional Driver',
        xpRequired = 1500,
        color = '#2ECC71',
        unlocks = {'taxi', 'taxi2', 'stretch'}
    },
    [4] = {
        name = 'Senior Driver',
        xpRequired = 3500,
        color = '#9B59B6',
        unlocks = {'taxi', 'taxi2', 'stretch', 'washington'}
    },
    [5] = {
        name = 'Elite Driver',
        xpRequired = 7500,
        color = '#E74C3C',
        unlocks = {'taxi', 'taxi2', 'stretch', 'washington', 'schafter3'}
    },
    [6] = {
        name = 'Master Driver',
        xpRequired = 15000,
        color = '#F39C12',
        unlocks = {'taxi', 'taxi2', 'stretch', 'washington', 'schafter3', 'cognoscenti'}
    },
    [7] = {
        name = 'Legendary Driver',
        xpRequired = 30000,
        color = '#FFD700',
        unlocks = {'taxi', 'taxi2', 'stretch', 'washington', 'schafter3', 'cognoscenti', 'superd'}
    }
}

-- Vehicle Information (Only Standard Taxi for now)
Config.Vehicles = {
    ['taxi'] = {
        label = 'Standard Taxi',
        model = 'taxi',
        rank = 1,
        multiplier = 1.0
    }
    -- Additional vehicles disabled for now
    -- ['taxi2'] = { label = 'Modern Taxi', model = 'taxi2', rank = 2, multiplier = 1.1 },
    -- ['stretch'] = { label = 'Luxury Limousine', model = 'stretch', rank = 3, multiplier = 1.5 },
    -- ['washington'] = { label = 'Executive Sedan', model = 'washington', rank = 4, multiplier = 1.3 },
    -- ['schafter3'] = { label = 'Premium Sedan', model = 'schafter3', rank = 5, multiplier = 1.4 },
    -- ['cognoscenti'] = { label = 'Elite Limousine', model = 'cognoscenti', rank = 6, multiplier = 1.6 },
    -- ['superd'] = { label = 'Super Diamond', model = 'superd', rank = 7, multiplier = 2.0 }
}

-- Fare Calculation
Config.Fare = {
    baseRate = 15, -- Base fare when entering taxi
    perMeter = 0.50, -- Per meter traveled
    perSecond = 0.10, -- Per second of trip
    minimumFare = 20, -- Minimum total fare
    maximumFare = 5000, -- Maximum total fare
    tipChance = 70, -- % chance NPC gives tip
    tipMin = 5, -- Minimum tip %
    tipMax = 25 -- Maximum tip %
}

-- XP System
Config.XP = {
    perTrip = 10, -- Base XP per completed trip
    perMeter = 0.05, -- XP per meter traveled
    bonusShortTrip = 5, -- Bonus for trips under 500m
    bonusMediumTrip = 15, -- Bonus for trips 500m-2000m
    bonusLongTrip = 30, -- Bonus for trips over 2000m
    tipBonus = 20, -- Bonus XP if tip received
    perfectDelivery = 50 -- Bonus for fast, safe delivery
}

-- NPC Job System
Config.NPC = {
    enabled = true,
    cooldown = 30000, -- 30 seconds between NPC job spawns
    spawnDistance = 100.0, -- Max distance from player to spawn NPC
    minDistance = 500.0, -- Minimum trip distance
    maxDistance = 3000.0, -- Maximum trip distance
    timeout = 300000, -- 5 minutes to complete trip

    -- NPC Pedestrian Models
    models = {
        'a_f_m_beach_01',
        'a_f_m_bevhills_01',
        'a_f_m_bodybuild_01',
        'a_f_m_business_02',
        'a_f_y_business_01',
        'a_m_m_beach_01',
        'a_m_m_business_01',
        'a_m_y_business_01',
        'a_m_y_hipster_01',
        's_m_m_doctor_01'
    },

    -- Zone-based pickup locations (organized by area with rank requirements)
    zones = {
        {
            id = 'los_santos',
            name = 'Los Santos',
            minRank = 1,
            locations = {
                vector4(144.897125, -848.453003, 30.874922, 251.998169), -- Legion Square
                vector4(143.823120, -852.508545, 30.825029, 255.759079),
                vector4(432.976044, -1387.218262, 29.447643, 147.244522),
                vector4(-92.643524, -1485.421143, 32.877686, 221.986069),
                vector4(-361.328369, -671.555603, 31.662569, 357.210114),
                vector4(-793.994446, -592.854187, 30.276201, 327.140198),
                vector4(-1375.571655, -958.170532, 9.341399, 127.445709),
                vector4(-517.411743, -1180.439575, 19.899708, 343.967621)
            }
        },
        {
            id = 'blaine_county',
            name = 'Blaine County',
            minRank = 3,
            locations = {
                vector4(1960.98, 3740.95, 32.34, 300.0),
                vector4(1695.94, 3588.03, 35.39, 210.0),
                vector4(1905.28, 3823.64, 33.44, 30.0)
            }
        },
        {
            id = 'paleto_bay',
            name = 'Paleto Bay',
            minRank = 5,
            locations = {
                vector4(111.29, 6607.95, 31.66, 220.0),
                vector4(-104.54, 6467.39, 31.63, 135.0),
                vector4(-378.15, 6062.05, 31.50, 315.0)
            }
        }
    },

    -- Legacy safeLocations for backward compatibility
    safeLocations = {
        vector4(144.897125, -848.453003, 30.874922, 251.998169),
        vector4(143.823120, -852.508545, 30.825029, 255.759079),
        vector4(432.976044, -1387.218262, 29.447643, 147.244522),
        vector4(-92.643524, -1485.421143, 32.877686, 221.986069),
        vector4(-361.328369, -671.555603, 31.662569, 357.210114),
        vector4(-793.994446, -592.854187, 30.276201, 327.140198),
        vector4(-1375.571655, -958.170532, 9.341399, 127.445709),
        vector4(-517.411743, -1180.439575, 19.899708, 343.967621)
    }
}

-- Taxi Stands (ox_target locations)
Config.TaxiStands = {
    {
        name = 'Sierra Valley Taxi HQ',
        coords = vec3(448.908020, -559.135681, 28.494055),
        heading = 347.664337,
        blip = true,
        vehicleSpawn = vec4(448.908020, -559.135681, 28.494055, 347.664337)
    },
    {
        name = 'Downtown Cab Co.',
        coords = vec3(895.38, -179.20, 74.70),
        heading = 238.5,
        blip = true,
        vehicleSpawn = vec4(902.02, -191.26, 73.88, 238.5)
    },
    {
        name = 'Airport Taxi Service',
        coords = vec3(-1041.08, -2746.15, 21.36),
        heading = 329.44,
        blip = true,
        vehicleSpawn = vec4(-1037.72, -2738.60, 20.17, 329.44)
    },
    {
        name = 'Sandy Shores Taxi',
        coords = vec3(1693.05, 3584.89, 35.62),
        heading = 211.93,
        blip = false,
        vehicleSpawn = vec4(1695.94, 3588.03, 35.39, 211.93)
    },
    {
        name = 'Paleto Bay Taxi',
        coords = vec3(107.79, 6613.82, 31.86),
        heading = 222.99,
        blip = false,
        vehicleSpawn = vec4(111.29, 6607.95, 31.66, 222.99)
    }
}

-- Blip Settings
Config.Blips = {
    stand = {
        sprite = 198,
        color = 5,
        scale = 0.8,
        display = 4,
        shortRange = true
    },
    job = {
        sprite = 280,
        color = 46,
        scale = 0.9,
        route = true
    }
}

-- UI Settings
Config.UI = {
    defaultPosition = 'top-right', -- top-right, top-left, bottom-right, bottom-left
    meterUpdateInterval = 100, -- Update meter every 100ms
    showSpeedInMPH = false -- false = KM/H, true = MPH
}

-- Dispatch Call Types (unlocked by rank)
Config.CallTypes = {
    {
        id = 'short_trip',
        label = 'Short Trip',
        description = 'Quick ride around the neighborhood',
        icon = 'fa-solid fa-location-dot',
        minRank = 1,
        distanceRange = {300, 800},
        baseReward = 50,
        xpReward = 15,
        color = '#95A5A6'
    },
    {
        id = 'standard_trip',
        label = 'Local Residents',
        description = 'Regular city transportation',
        icon = 'fa-solid fa-taxi',
        minRank = 1,
        distanceRange = {800, 1500},
        baseReward = 86,
        xpReward = 66,
        color = '#3498DB',
        fixedPickup = vector4(144.897125, -848.453003, 30.874922, 251.998169)
    },
    {
        id = 'airport_pickup',
        label = 'Airport Pickup',
        description = 'Pick up passenger from airport',
        icon = 'fa-solid fa-plane',
        minRank = 2,
        distanceRange = {1500, 2500},
        baseReward = 200,
        xpReward = 40,
        color = '#2ECC71',
        fixedPickup = vector3(-1037.72, -2738.60, 20.17)
    },
    {
        id = 'long_distance',
        label = 'Long Distance',
        description = 'Cross-city travel',
        icon = 'fa-solid fa-road',
        minRank = 3,
        distanceRange = {2000, 3500},
        baseReward = 300,
        xpReward = 60,
        color = '#9B59B6'
    },
    {
        id = 'vip_client',
        label = 'VIP Client',
        description = 'High-paying executive transport',
        icon = 'fa-solid fa-star',
        minRank = 4,
        distanceRange = {1000, 2000},
        baseReward = 500,
        xpReward = 100,
        color = '#F39C12'
    },
    {
        id = 'luxury_tour',
        label = 'Luxury Tour',
        description = 'Scenic route for wealthy tourists',
        icon = 'fa-solid fa-gem',
        minRank = 5,
        distanceRange = {2500, 4000},
        baseReward = 800,
        xpReward = 150,
        color = '#E74C3C'
    },
    {
        id = 'celebrity',
        label = 'Celebrity Transport',
        description = 'Discreet VIP transportation',
        icon = 'fa-solid fa-crown',
        minRank = 6,
        distanceRange = {1500, 3000},
        baseReward = 1200,
        xpReward = 250,
        color = '#FFD700'
    }
}

-- Dispatch Settings
Config.Dispatch = {
    callGenerationInterval = 30000, -- Generate new call every 30 seconds
    maxActiveCalls = 5, -- Maximum calls shown at once
    callExpireTime = 120000, -- Calls expire after 2 minutes
    minCallsPerRank = 2, -- Minimum calls available per rank
    maxCallsPerRank = 4 -- Maximum calls shown per rank
}
