Config = Config or {}
---------------------------------------------
 -- SW - Truck Simulator | Settings
---------------------------------------------
Config.Framework = 'auto' -- Choose 'auto', 'esx', or 'qbcore' (auto will detect automatically)

Config.TargetSystem = 'auto' -- Choose 'auto' or set a specific target: 'ox_target', 'qb-target'; or set false to disable the target system

Config.UseIdentifier = true -- For QBCore: true = use license identifier, false = use citizenid (default)

Config.JobName = false -- Set to false to allow all players regardless of job, true to restrict by allowed jobs

Config.AllowedJobs = {'trucker', 'unemployed'} -- Allowed jobs when JobName is true

Config.Language = 'en' -- Choose 'en', 'tr', etc.

---------------------------------------------
 -- SW - Menu Visibility Settings
---------------------------------------------

Config.Menu = {
    missions = true,
    quick_jobs = true,
    freights = true,
    special_loads = true,
    story_mode = true,
    markets = true,
    vehicle_marketplace = true,
    drivers_market = false,  -- Disabled NPC driver hiring
    dealership = true,
    bank = true,
    vehicles = true,
    my_trucks = true,
    diagnostics = true,
    skills = true,
    party = true,
    settings = true,
    language = true,
    my_drivers = false  -- Disabled driver management menu
}
---------------------------------------------
 -- SW - Vehicle Keys Settings
---------------------------------------------

Config.VehicleKeys = {
    enabled = true, -- Enable vehicle keys system
    script = 'auto', -- Choose: 'auto', 'qb-vehiclekeys', 'qbx-vehiclekeys', 'wasabi_carlock', 'cd_garage', 'qs-vehiclekeys', 'custom', or false to disable
    giveKeysOnJobStart = true, -- Give keys when job starts
    removeKeysOnJobEnd = true, -- Remove keys when job ends
}

---------------------------------------------
 -- SW - Inventory Settings
---------------------------------------------

Config.Inventory = {
    enabled = false, -- Enable inventory system for job papers
    script = 'ox_inventory', -- Choose: 'ox_inventory', 'qb-inventory', 'custom'
    jobPaperItem = 'trucking_job_paper', -- Item name for job papers
    jobPaperLabel = 'Trucking Job Paper', -- Display name for job papers
    jobPaperDescription = 'A paper containing job details and delivery information', -- Item description
    removeOnJobComplete = true, -- Remove job paper when job is completed
    removeOnJobCancel = true, -- Remove job paper when job is cancelled
}

---------------------------------------------
 -- SW - Bank and Money Settings
---------------------------------------------

Config.Banking = {
    EnableDailyWithdrawalLimit = false, -- Set it to true to activate the daily withdrawal limit, false to disable it.
    EnableLevelRequirement = true, -- Set it to true to enable level requirements for loans, false to disable it.
    MaxTotalLoanAmount =  50000, -- Maximum total loan amount a player can have
    MaxWithdrawalAmount = 50000, -- Maximum amount a player can withdraw at once
    MaxDailyWithdrawalAmount = 50000, -- Maximum amount a player can withdraw per day
    DailyLimitResetHours = 24, -- How many hours after which the daily limit will be reset (default: 24 hours)
    LoanOptions = {
        { amount = 2000,  interestRate = 20,  repaymentDays = 0, repaymentMinutes = 1, collateralPercent = 10, levelRequired = 1 },   -- %10 collateral ($2,000) - 30 minutes - Level 1+
        { amount = 5000,  interestRate = 17.5, repaymentDays = 0, repaymentMinutes = 60, collateralPercent = 8, levelRequired = 3 },   -- %8 collateral ($4,000) - 1 hour - Level 3+
        { amount = 10000, interestRate = 15,  repaymentDays = 1, repaymentMinutes = 0, collateralPercent = 6, levelRequired = 5 },   -- %6 collateral ($6,000) - 1 day - Level 5+
        { amount = 40000, interestRate = 12.5, repaymentDays = 15, repaymentMinutes = 0, collateralPercent = 5, levelRequired = 10 }   -- %5 collateral ($20,000) - 15 days - Level 10+
    }
}
---------------------------------------------
 -- SW - Fuel System Settings
---------------------------------------------
Config.FuelSystem = {
    enabled = true, -- Fuel system enabled?
    script = 'ox_fuel', --cdn-fuel,ps-fuel,LegacyFuel,ox_fuel
    defaultFuel = 95.0 -- Default fuel level for spawned vehicles
}

---------------------------------------------
 -- SW - Spawn Settings
---------------------------------------------
Config.TruckerLocations = {
    {
        coords = vector4(513.255920, -3056.978027, 6.069623, 0.078348), -- Port of Los Santos
        radius = 3.0,
        pedModel = "s_m_m_trucker_01",
        scenario = "WORLD_HUMAN_CLIPBOARD",
        blipName = "SiberWin Trucker Jobs"
    }
}

---------------------------------------------
 -- SW - Truck Spawn Settings
---------------------------------------------

Config.TruckSpawnPoints = {
    vector4(521.50, -3055.20, 6.07, 270.0),   -- Spawn 1
    vector4(521.50, -3050.00, 6.07, 270.0),   -- Spawn 2
    vector4(521.50, -3044.80, 6.07, 270.0),   -- Spawn 3
    vector4(521.50, -3039.60, 6.07, 270.0),   -- Spawn 4
    vector4(521.50, -3034.40, 6.07, 270.0),   -- Spawn 5
}

---------------------------------------------
 -- SW - Trailer Spawn Settings
---------------------------------------------

Config.TrailerSpawnPoints = {
    vector4(505.00, -3055.00, 6.07, 90.0),
    vector4(505.00, -3050.00, 6.07, 90.0),
    vector4(505.00, -3045.00, 6.07, 90.0),
    vector4(505.00, -3040.00, 6.07, 90.0),
    vector4(505.00, -3035.00, 6.07, 90.0),
}

---------------------------------------------
 -- SW - Truck Return Settings
---------------------------------------------

Config.TruckReturnPoints = {
    vector4(483.12, -3023.35, 6.02, 267.12),   -- Return Point
}

---------------------------------------------
 -- SW - Trailer Models
---------------------------------------------

Config.TrailerModels = {'tanker', 'tr4', 'trailerlogs', 'trailers', 'trailers2', 'trailers3', 'trailers4',"trailers5"}


---------------------------------------------
 -- SW - XP and Money Settings
---------------------------------------------

Config.XPGain = 10.0 -- XP per km (8.0 to 25.0) - Slower progression for grind

Config.MoneyGain = 75.0 -- Money per km - Balanced for ~$3,600/hr at level 1-4 hard

Config.DifficultyMultipliers = {
    ["easy"] = {xp = 0.8, cash = 0.8},     -- Easy: 80% of base
    ["medium"] = {xp = 1.0, cash = 1.0},   -- Medium: 100% of base
    ["hard"] = {xp = 1.2, cash = 1.2}      -- Hard: 120% of base → $90/km at L1
}

-- Level-based pay multipliers - rewards dedicated truckers
Config.LevelMultipliers = {
    [1] = 1.00,  -- $3,600/hr  (baseline)
    [2] = 1.00,
    [3] = 1.00,
    [4] = 1.00,
    [5] = 1.10,  -- $3,960/hr  (+10%)
    [6] = 1.17,  -- $4,210/hr  (+17%)
    [7] = 1.25,  -- $4,500/hr  (+25%)
    [8] = 1.33,  -- $4,790/hr  (+33%)
    [9] = 1.42,  -- $5,110/hr  (+42%)
    [10] = 1.50, -- $5,400/hr  (+50%)
    [11] = 1.60, -- $5,760/hr  (+60%)
    [12] = 1.70, -- $6,120/hr  (+70%)
    [13] = 1.80, -- $6,480/hr  (+80%)
    [14] = 1.92, -- $6,910/hr  (+92%)
    [15] = 2.05, -- $7,380/hr  (+105%)
    [16] = 2.18, -- $7,850/hr  (+118%)
    [17] = 2.33, -- $8,390/hr  (+133%)
    [18] = 2.50, -- $9,000/hr  (+150%)
    [19] = 2.67, -- $9,610/hr  (+167%)
    [20] = 2.85, -- $10,260/hr (+185%)
}

Config.Levels = {
    {level = 1, requiredExp = 0},      -- Start
    {level = 2, requiredExp = 300},    -- First levels (+50% XP required)
    {level = 3, requiredExp = 600},
    {level = 4, requiredExp = 900},
    {level = 5, requiredExp = 1350},
    {level = 6, requiredExp = 1875},   -- Medium levels
    {level = 7, requiredExp = 2475},
    {level = 8, requiredExp = 3150},
    {level = 9, requiredExp = 3900},
    {level = 10, requiredExp = 4800},  -- Advanced levels
    {level = 11, requiredExp = 5850},
    {level = 12, requiredExp = 7050},
    {level = 13, requiredExp = 8400},
    {level = 14, requiredExp = 9900},
    {level = 15, requiredExp = 11550}, -- Top levels
    {level = 16, requiredExp = 13350},
    {level = 17, requiredExp = 15300},
    {level = 18, requiredExp = 17400},
    {level = 19, requiredExp = 19650},
    {level = 20, requiredExp = 22050}  -- Top level (+50% grind)
}

Config.CargoBonus = {
    ["general"] = {xp = 0},              -- General cargo: No bonus
    ["keepdry"] = {xp = 5},              -- Keep dry: Minimal XP bonus
    ["fragile"] = {xp = 12},             -- Fragile: Medium level bonus
    ["petrol"] = {xp = 18},              -- Petrol: Dangerous cargo bonus
    ["valuable"] = {xp = 22},            -- Valuable cargo: High bonus
    ["adr1"] = {xp = 35}                 -- ADR 1: Explosives - Dangerous cargo
}

---------------------------------------------
 -- SW - Key Settings
---------------------------------------------

Config.Jobs = {
    settings = {
        cancel_key = {id = 167, key = "F6"},  -- Cancel job key (F6)
        cooldown = 2,               -- Job cooldown (minutes)
        summaryScreenDuration = 10, -- Job summary screen duration (seconds)
        refreshTimer = 1,          -- Job refresh timer (minutes)
        enableAutoShuffle = true    -- Enable automatic job shuffling
    }
}

Config.Keybinds = {
    toggleTaskList = {id = 249, key = "N"} -- FiveM Control ID. Check https://docs.fivem.net/docs/game-references/controls/ for more information.
}


---------------------------------------------
 -- SW - Sound Settings
---------------------------------------------

Config.Sound = {
    missionCompleteVolume = 0.3, -- Sound volume (0.0 to 1.0)
    objectiveSoundVolume = 0.2,   -- Objective sound volume (0.0 to 1.0)
    backgroundVolume = 0.1,       -- Background music volume (0.0 to 1.0)
    backgroundEnabled = true 
}

---------------------------------------------
 -- SW - Dealership Vehicles
---------------------------------------------

Config.VehicleSellRate = 0.7 -- The rate the player will receive when selling a vehicle (0.7 = %70)

Config.MarketVehicles = {
    trucks = {
    ['hauler'] = {
        name = 'Hauler',
        price = 85000,
        engine = "Turbo Charged Diesel",
        transmission = "14-Speed Manual",
        hp = '1450',
        images = {
            'trucks/hauler1.png',
            'trucks/hauler2.png',
            'trucks/hauler3.png',
            'trucks/hauler4.png',
            'trucks/hauler5.png',
            'trucks/hauler6.png',
            'trucks/hauler7.png',
            'trucks/hauler8.png',
        },
        description = 'The Hauler is a heavy-duty truck built for extreme conditions, featuring high ground clearance, specialized suspension, and reinforced chassis designed for off-road and industrial transport operations.',
        driver_bonus = 4,
        level_required = 1
    },
    ['phantom'] = {
        name = 'Phantom',
        price = 95000,
        engine = "Cummins Turbo Diesel",
        transmission = "18-Speed Manual",
        hp = '1650',
        images = {
            'trucks/phantom1.png',
            'trucks/phantom2.png',
            'trucks/phantom3.png',
            'trucks/phantom4.png',
            'trucks/phantom5.png',
            'trucks/phantom6.png',
            'trucks/phantom7.png',
            'trucks/phantom8.png',
        },
        description = 'The Phantom combines classic styling with modern technology, featuring distinctive chrome accents, advanced powertrain, and luxurious interior with premium leather and wood accents for long-haul comfort.',
        driver_bonus = 4,
        level_required = 1
    },
    ['packer'] = {
        name = 'Packer',
        price = 125000,
        engine = "Cummins Turbo Diesel",
        transmission = "10-Speed Automatic",
        hp = '1850',
        images = {
            'trucks/packer1.png',
            'trucks/packer2.png',
            'trucks/packer3.png',
            'trucks/packer4.png',
            'trucks/packer5.png',
            'trucks/packer6.png',
            'trucks/packer7.png',
            'trucks/packer8.png',
        },
        description = 'The Packer represents American trucking evolution with its angular design and optimized frame that balances strength with weight efficiency for improved aerodynamics and payload capabilities.',
        driver_bonus = 4,
        level_required = 7
    },
    ['vetirs'] = {
        name = 'Vetir Semi 1965',
        price = 35000,
        engine = "2445 CC V8",
        transmission = "5-Speed Manual",
        hp = '450',
        images = {
            'trucks/vetirs1.png',
            'trucks/vetirs2.png',
            'trucks/vetirs3.png',
            'trucks/vetirs4.png',
            'trucks/vetirs5.png',
            'trucks/vetirs6.png',
            'trucks/vetirs7.png',
            'trucks/vetirs8.png',
        },
        description = 'The Vetir Semi 1965 is a family of four wheel drive off-road vans and light trucks with body-on-frame construction and cab over engine design, built by the Vetir Automobile Plant (VAZ) since 1965.',
        driver_bonus = 4,
        level_required = 1
    },
    ['biff3'] = {
        name = 'Biff 3',
        price = 45000,
        engine = "Detroit Diesel",
        transmission = "10-Speed Manual",
        hp = '650',
        images = {
            'trucks/biff3_1.png',
            'trucks/biff3_2.png',
            'trucks/biff3_3.png',
            'trucks/biff3_4.png',
            'trucks/biff3_5.png',
            'trucks/biff3_6.png',
            'trucks/biff3_7.png',
            'trucks/biff3_8.png',
        },
        description = 'The Biff 3 is a dependable medium-duty truck with an aerodynamic design, reinforced steel chassis, and intuitive controls, making it ideal for local deliveries and medium-range transport operations.',
        driver_bonus = 4,
        level_required = 1
    },
    ['roadkiller'] = {
        name = 'Roadkiller',
        price = 65000,
        engine = "Cummins Turbo Diesel",
        transmission = "6-Speed Automatic",
        hp = '850',
        images = {
            'trucks/roadkiller1.png',
            'trucks/roadkiller2.png',
            'trucks/roadkiller3.png',
            'trucks/roadkiller4.png',
            'trucks/roadkiller5.png',
            'trucks/roadkiller6.png',
            'trucks/roadkiller7.png',
            'trucks/roadkiller8.png',
        },
        description = 'The Roadkiller is a robust old-school truck known for exceptional durability in harsh conditions, featuring a heavy-duty frame for oversize loads and vintage styling with modern amenities.',
        driver_bonus = 4,
        level_required = 3
    },
    ['towsemi'] = {
        name = 'Tow Semi',
        price = 110000,
        engine = "Paccar Turbo Charged",
        transmission = "12-Speed Manual",
        hp = '1050',
        images = {
            'trucks/towsemi1.png',
            'trucks/towsemi2.png',
            'trucks/towsemi3.png',
            'trucks/towsemi4.png',
            'trucks/towsemi5.png',
            'trucks/towsemi6.png',
            'trucks/towsemi7.png',
            'trucks/towsemi8.png',
        },
        description = 'The Tow Semi is a specialized recovery vehicle featuring an integrated towing system, reinforced frame, and advanced hydraulics designed for precision handling of heavy recovery operations.',
        driver_bonus = 4,
        level_required = 6
    },
    ['phantom3'] = {
        name = 'Phantom 3',
        price = 145000,
        engine = "Detroit Turbo Diesel",
        transmission = "14-Speed Manual",
        hp = '2050',
        images = {
            'trucks/phantom3_1.png',
            'trucks/phantom3_2.png',
            'trucks/phantom3_3.png',
            'trucks/phantom3_4.png',
            'trucks/phantom3_5.png',
            'trucks/phantom3_6.png',
            'trucks/phantom3_7.png',
            'trucks/phantom3_8.png',
        },
        description = 'The Phantom 3 is the flagship of modern trucking technology, featuring digital dashboard, adaptive cruise control, lane-keeping systems, and premium sleeping quarters designed for elite long-haul operations.',
        driver_bonus = 4,
        level_required = 8
    },
    ['ramvan'] = {
        name = 'Ramvan',
        price = 165000,
        engine = "Euro 6 Diesel",
        transmission = "Clutch 12-Speed",
        hp = '1250',
        images = {
            'trucks/ramvan1.png',
            'trucks/ramvan2.png',
            'trucks/ramvan3.png',
            'trucks/ramvan4.png',
            'trucks/ramvan5.png',
            'trucks/ramvan6.png',
            'trucks/ramvan7.png',
            'trucks/ramvan8.png',
        },
        description = 'The Ramvan is the pinnacle of European truck engineering with cutting-edge aerodynamics, a fuel-efficient powertrain, and intelligent driving assistance systems designed for eco-conscious long-distance transport.',
        driver_bonus = 4,
        level_required = 9
    },
    },
}

---------------------------------------------
 -- SW - Diagnostic Prices Setting
---------------------------------------------

Config.RepairCosts = {
    engine_per_percent = 10,       -- Engine repair cost per percent
    body_per_percent = 8,          -- Body repair cost per percent
    wheels_per_percent = 6,        -- Wheels repair cost per percent
    transmission_per_percent = 12, -- Transmission repair cost per percent
    refuel_cost_per_unit = 2,      -- Refuel cost per unit
    color_change_cost = 250         -- Color change cost (fixed price)
}

---------------------------------------------
 -- SW - Skill System Setting
---------------------------------------------

Config.SkillPointsPerLevel = 1 -- Skill points per level

-- Skill types and maximum levels
Config.Skills = {
    engine_repair = { -- Engine repair
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of engine repairs"
    },
    body_repair = { -- Body repair
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of body repairs"
    },
    wheels_repair = { -- Wheels repair
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of wheel repairs"
    },
    refuel = { -- Refuel
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of refueling"
    },
    color_change = { -- Color change
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of vehicle color changes"
    },
    transmission_repair = { -- Transmission repair
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %10 per level
        description = "Reduce the cost of transmission repairs"
    },
    vehicle_discount = { -- Vehicle discount
        maxLevel = 5,
        effectPerLevel = 10, -- Discount of %2 per level
        description = "Reduce the cost of vehicle purchases"
    },
    freight_value = { -- Freight value
        maxLevel = 5,
        effectPerLevel = 2, -- Increase of %2 per level
        description = "Increase the value of freight jobs"
    }
}

---------------------------------------------
 -- SW - Market Vehicles (NPC Driver) Settings
---------------------------------------------

Config.NPCDrivers = {
    MaxDriversPerPlayer = 4, -- The maximum number of drivers a player can hire
    RefreshInterval = 60, -- The time in minutes for new drivers to be refreshed
    PriceRange = {5000, 15000}, -- The price range for hiring drivers (min, max)
    CompensationEnabled = true, -- Enable/disable driver compensation when firing (true/false)
    CompensationAmount = 2500, -- Compensation amount when firing a driver (deducted from withdrawable cash)
    DriverNames = {
        Male = {
            "Royal Livingston", "Milton Nixon", "Williams Lambert", "Graig Carson", 
            "Linwood Wolfe", "Kendrick Mccann", "Santo Gibson", "Marcos Bowen", 
            "Fidel Russell", "Ike Noble", "Rico Cruz", "Abram Potter", "Anderson Kirk", 
            "Chet Weaver", "Ronnie Kerr", "Adrian Rose", "Neal Liu", "Rolf Lee", 
            "Jerrold Howell", "Kendall Dean", "Gonzalo Mays", "Clifton Austin", 
            "Hassan Knight", "Fletcher Jefferson", "Hiram Bender", "Billy Zavala", 
            "Van Oconnell", "Edmundo Watson"
        }
    },
    SkillTypes = {
        "driving_skill", -- Driving skill (causes accidents, affects fuel and engine damage)
        "fragile_cargo", -- Fragile cargo handling skill
        "on_time_delivery", -- On-time delivery skill
        "valuable_cargo", -- Valuable cargo handling skill
        "product_type" -- Product type expertise
    },
    DeliveryStages = {
        {name = "truck_boarded", duration = 30}, -- 1 minute
        {name = "cargo_loaded", duration = 30}, -- 1 minute
        {name = "on_the_way", duration = 30}, -- 1 minute
        {name = "trailer_arrived", duration = 30}, -- 1 minute
        {name = "unloading", duration = 30}, -- 1 minute
        {name = "delivery_completed", duration = 0} -- Completed
    },
    EarningsPerDelivery = {200, 400}, -- Earnings per NPC driver delivery (passive income)
    FatiguePerDelivery = 10, -- Fatigue increase after each delivery
    RestingTime = 5, -- Resting time in minutes
    AvatarCount = 50, -- Total avatar count
    
    DamagePerDelivery = {
        Engine = {2, 10}, -- Damage to engine per delivery (min, max)
        Body = {4, 10},   -- Damage to body per delivery (min, max)
        Fuel = {5, 15}    -- Fuel consumption per delivery (min, max)
    }
}





---------------------------------------------
 -- SW - Special Loads Settings
---------------------------------------------

Config.SpecialLoads = {
    enabled = true, -- Activates/deactivates the special loads feature
    dailyLimit = 12, -- How many special loads can be done per day
    cooldownMinutes = 30, -- How many minutes to wait when the limit is exceeded
    cooldownSeconds = 0, -- Additional seconds (added to minutes)

    -- ox_lib skillCheck for trailer control in special loads
    trailerCheckSkill = {
        enabled = true, -- If true, control is performed
        difficulties = {'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'},
        keys = {'w', 'a', 's'}
    },

    -- Police alert when SkillCheck fails
    policeAlertOnCheckFail = {
        enabled = true, -- If true, police alert is triggered on failure
        policeJobs = {'police'}, -- Police job(s) (name-list check for QB)
        useJobTypeLeo = true, -- job.type == 'leo' and onduty check for QB-Core (recommended)
        coordsSource = 'server', -- 'server' (recommended) or 'client' (data.coords from client will be used)
        notifyMessage = 'Special loads trailer check failed! Suspicious activity reported.',
        -- Server owners can define their own dispatch/event systems here
        qb = {
            eventName = 'police:client:policeAlert',  
            eventType = 'client' --- 'client' or 'server'
        },
        esx = {
            eventName = 'wf-alerts:svNotify', 
            eventType = 'server' -- 'client' or 'server'
        }
    }
}

---------------------------------------------
-- SW - Story Mode Settings
---------------------------------------------
Config.StoryMode = {
    enabled = false 
}

---------------------------------------------
-- SW - Diamond Exchange System
---------------------------------------------
Config.DiamondExchange = {
    enabled = true, -- Enable diamond exchange system
    npcModel = 'a_m_m_business_01', -- NPC model
    npcCoords = vector4(1225.79, -3002.00, 9.48, 54), -- NPC coordinates (x, y, z, heading) - Near Legion Square Bank
    commissionRate = 0.10, -- 10% commission rate (0.10 = 10%)
    exchangeRate = 100, -- 1 diamond = 100$ (before commission)
    minExchange = 1, -- Minimum exchange amount
    maxExchange = 1000 -- Maximum exchange amount
}




