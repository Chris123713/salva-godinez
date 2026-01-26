Config = {}

Config.UIImageSource = "ox_inventory/web/images"--Path of your inventory item images, examples:
    --QBCore: qb-inventory/html/images
    --Ox: ox_inventory/web/images

Config.ApplyOutfit = true--Apply job outfits
Config.RequiredJob = "miner"--Required job to access the mining job
Config.CheckSpawnRadius = 5.0--If there is no vehicles in this radius, the vehicle will be able to spawn
Config.MaxTruckBedSlots = 70--How manny rocks will fit in the trucks bed before not allowing to add more

Config.RockRenderDistance = 30.0--How far the rocks will be rendered, if you have performance issues, dicrease this value
Config.RockCuttingMachineRenderDistance = 20.0--How far the cutting machine will be rendered, if you have performance issues, dicrease this value

Config.RockMarkers = {
    enabled = true,--Enable rock markers?
    sprite = 0,--Marker sprite id
    move = true,--If true, the marker will move up and down
    size = vec3(0.5, 0.5, 0.5),--Marker size
    color = { r = 255, g = 255, b = 0, a = 250 }--Marker color in rgba format
}

Config.RankStore = {--Currency that is used to pay/purchase things at the rank store
    account = 'bank',-- Supported types: black_money, bank, cash
    accountItem = {
        enabled = false,--Is currency to pay/purchase an item?
        itemName = 'markedbills'--The currency item that is used to pay/purchase things in the pawnshop
    }
}

--[[
    SUPPLY & DEMAND PRICING SYSTEM
    - Prices decrease as players mine more (market saturation)
    - After ~90 min of mining, prices start declining noticeably
    - Hard cap prevents exceeding $30,000 in 24 hours
    - Prices recover over time when not mining
]]
Config.SupplyDemand = {
    enabled = true,

    -- Daily earnings cap (hard limit)
    dailyCap = {
        enabled = true,
        maxEarnings = 30000,        -- $30,000 max per 24 hours
        resetHour = 6,              -- Reset at 6 AM server time
        warningThreshold = 25000,   -- Warn player at $25k
    },

    -- Price decay based on session activity (~90 min threshold)
    priceDecay = {
        enabled = true,
        -- Rocks mined before decay starts (~90 min at various levels)
        decayThreshold = 80,        -- ~80 rocks before prices drop (90 min at L1-L2 avg)

        -- How fast prices drop after threshold
        decayRate = 0.02,           -- 2% drop per rock after threshold
        minMultiplier = 0.50,       -- Prices won't drop below 50% of base

        -- Recovery when not mining
        recoveryRate = 0.10,        -- 10% recovery per 30 min offline
        recoveryInterval = 30,      -- Minutes between recovery ticks
    },

    -- Server-wide market pressure (optional - affects all players)
    marketPressure = {
        enabled = false,            -- Set true for server-wide supply/demand
        serverDecayRate = 0.005,    -- 0.5% drop per rock mined server-wide
        serverRecoveryRate = 0.02,  -- 2% recovery per hour
        serverMinMultiplier = 0.70, -- Server prices won't drop below 70%
    }
}

Config.GroupPassword = {
    type = 'number',--number or char
    length = 6--code length
}

Config.Mining = {
    ['hammer'] = {
        prop = 'prop_tool_hammer',
        dict = "amb@world_human_hammering@male@base",
        anim = "base",
        bone = 57005,
        offset = vector3(0.15, 0.10, -0.0),
        rotation = vector3(0.0, 0.0, 181.0),
        breakChance = 60,--Chance to break the tool
        pressureLength = 50,
        hit = 1
    },

    ['pickaxe'] = {
        prop = 'prop_tool_pickaxe',
        dict = "amb@world_human_hammering@male@base",
        anim = "base",
        bone = 57005,
        offset = vector3(0.09, -0.53, -0.22),
        rotation = vector3(252.0, 180.0, 0.0),
        breakChance = 50,--Chance to break the tool
        pressureLength = 50,
        hit = 2
    },

    ['drill'] = {
        prop = 'hei_prop_heist_drill',
        dict = "anim@heists@fleeca_bank@drilling",
        anim = "drill_straight_fail",
        bone = 57005,
        offset = vector3(0.14, 0, -0.01),
        rotation = vector3(90.0, -90.0, 180.0),
        breakChance = 40,--Chance to break the tool
        pressureLength = 50,
        hit = 3
    },

    ['laser_drill'] = {
        prop = 'ch_prop_laserdrill_01a',
        dict = "anim@heists@fleeca_bank@drilling",
        anim = "drill_straight_fail",
        bone = 57005,
        offset = vector3(0.14, 0, -0.0),
        rotation = vector3(90.0, -90.0, 180.0),
        breakChance = 20,--Chance to break the tool
        pressureLength = 50,
        hit = 4
    },
}

Config.Crystals = {
    { item = 'gold_ore', prop = 'prop_rock_5_smash1', cuttingTime = 5000 },
    { item = 'ruby_ore', prop = 'v_res_fa_crystal01', cuttingTime = 5000 },
    { item = 'diamond_ore', prop = 'v_res_fa_crystal02', cuttingTime = 5000 },
    { item = 'iron_ore', prop = 'prop_rock_5_smash1', cuttingTime = 5000 },
    { item = 'emerald_ore', prop = 'v_res_fa_crystal03', cuttingTime = 5000 },
    { item = 'sapphire_ore', prop = 'v_res_fa_crystal02', cuttingTime = 5000 },
}

Config.Job = {
    CooldownRock = { min = 1, sec = 30 },
    Payout = {
        account = 'bank',
        groupMultiplier = true,

        -- BALANCED DUAL PAYMENT SYSTEM
        -- Level 1 (40 rocks/hr): $50/rock = $2,000/hr base
        -- Level 4 (120 rocks/hr): $50/rock = $6,000/hr (within cap)
        -- Total with ore processing: L1 ~$4,000/hr, L4 ~$8,000/hr (at cap)

        Rocks = {--Rewards for mining rocks
            money = { min = 20, max = 30 },  -- ~$25 avg
            rankXP = { min = 10, max = 20 },
        },

        Ores = {--Rewards for processing ore - scaled by rarity
            ['iron_ore'] =      { money = { min = 18, max = 28 }, rankXP = { min = 10, max = 20 } },  -- ~$23 avg
            ['gold_ore'] =      { money = { min = 22, max = 32 }, rankXP = { min = 15, max = 25 } },  -- ~$27 avg
            ['ruby_ore'] =      { money = { min = 25, max = 35 }, rankXP = { min = 15, max = 25 } },  -- ~$30 avg
            ['emerald_ore'] =   { money = { min = 28, max = 38 }, rankXP = { min = 20, max = 30 } },  -- ~$33 avg
            ['sapphire_ore'] =  { money = { min = 32, max = 42 }, rankXP = { min = 20, max = 30 } },  -- ~$37 avg
            ['diamond_ore'] =   { money = { min = 38, max = 48 }, rankXP = { min = 25, max = 35 } },  -- ~$43 avg
        }
    }
}

Config.RockCarrying = {
    bone = 28422,
    offset = vec3(0.025, -0.05, -0.10),
    rot = vec3(0.0, 0.0, 181.0)
}

Config.Blips = {
    center = {
        disable = false,--Disable this blip?
        sprite = 85,--Blip icon id
        color = 5,--Blip color id
        scale = 1.0,--Blip scale
        label = "Mining job site",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    processing = {
        disable = false,--Disable this blip?
        sprite = 527,--Blip icon id
        color = 5,--Blip color id
        scale = 1.0,--Blip scale
        label = "Rock processing",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    rock = {
        disable = false,--Disable this blip?
        sprite = 625,--Blip icon id
        color = 5,--Blip color id
        scale = 1.0,--Blip scale
        label = "Rock",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    cutting = {
        disable = false,--Disable this blip?
        sprite = 354,--Blip icon id
        color = 5,--Blip color id
        scale = 1.0,--Blip scale
        label = "Ore processing",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    }
}

Config.Center = {
    Orders = {--New order listings
        Pickup = { min = 0, sec = 10 },--Generate a new pickup job every min = x and sec = x
        Deliver = { min = 0, sec = 10 },--Generate a new deliver job every min = x and sec = x
    },

    ped = {
        model = 's_m_y_construct_01',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
        pos = vector3(2569.25, 2720.29, 42.96),--Dealers positions
        heading = 204.39,--Dealers heading
        animation = {--This controls dealer animation, if you don't want this, make it to: animation = false
            --Supported anim data format:
                -- anim = ''
                -- dict = ''
                -- scenario = ''
            --Examples:
                -- anim = 'missexile3'
                -- dict = 'ex03_dingy_search_case_base_michael'
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        }
    },

    Vehicle = {
        model = 'TipTruck',
        extras = {
            [2] = true
        },
        cargo = {
            areaSize = vec3(1.5, 3, 1.0),
            spacing = vec3(0.5, 0.5, 0.17),
            offsetPos = vec3(0.8, 3.0, 0.7),      
            trunkBones = {
                -- [door id, rage is 0 - 5] = bone name
                [2] = 'dside_r',
                [3] = 'pside_r'
            }
        },
    },

    Spawns = {
        { pos = vector3(2585.37, 2712.22, 42.96), heading = 291.99 },
        { pos = vector3(2595.05, 2717.0, 42.6), heading = 295.51 },
        { pos = vector3(2604.81, 2722.04, 41.72),heading = 295.21 },
        { pos = vector3(2614.51, 2725.31, 41.28), heading = 287.6 },
    },
}

Config.Ranks = {
    -- BALANCED PROGRESSION SYSTEM
    -- XP earned: ~37 XP per rock cycle (15 rock + 22 ore avg)
    -- Level 1: ~40 rocks/hr = ~1,480 XP/hr = $4,000/hr
    -- Level 2: ~80 rocks/hr = ~2,960 XP/hr = $5,500/hr
    -- Level 3: ~120 rocks/hr = ~4,440 XP/hr = $7,000/hr
    -- Level 4: ~160 rocks/hr = $8,000/hr (cap)
    -- Tool prices = 90 min earnings at current level
    Levels = {
        [1] = {
            level = 1,
            minXP = 0,          -- Start here
            tool = {
                name = 'hammer',
                item = 'hammer',
                title = "Hammer",
                description = "Basic mining tool - slow but reliable",
                price = 250,    -- Trivial cost to start
            }
        },
        [2] = {
            level = 2,
            minXP = 750,        -- ~20 rocks at L1 = ~30 min work
            tool = {
                name = 'pickaxe',
                item = 'pickaxe',
                title = "Pickaxe",
                description = "2x mining speed, lower break chance",
                price = 6000,   -- 90 min earnings at L1 ($4k/hr)
            }
        },
        [3] = {
            level = 3,
            minXP = 3000,       -- ~75 rocks at L2 = ~1 hr work after L2
            tool = {
                name = 'drill',
                item = 'drill',
                title = "Drill",
                description = "3x mining speed, durable construction",
                price = 8250,   -- 90 min earnings at L2 ($5.5k/hr)
            }
        },
        [4] = {
            level = 4,
            minXP = 8000,       -- ~125 rocks at L3 = ~1 hr work after L3
            tool = {
                name = 'laser_drill',
                item = 'laser_drill',
                title = "Laser Drill",
                description = "4x mining speed, rarely breaks",
                price = 10500,  -- 90 min earnings at L3 ($7k/hr)
            }
        }
    }
}

Config.Outfits = {
    [`mp_m_freemode_01`] = {
        tshirt_1 = 15,
        tshirt_2 = 0,
        arms     = 19,
        torso_1  = 22,
        torso_2  = 0,
        pants_1  = 90,
        pants_2  = 0,
        shoes_1 = 1,
        shoes_2 = 0,
        chain_1 = 0,
        chain_2 = 0,
        glasses_1 = 0,
        glasses_2 = 0,
        ears_1 = 0,
        ears_2 = 0,
    },
    [`mp_f_freemode_01`] = {
        tshirt_1 = 14,
        tshirt_2 = 0,
        arms     = 15,
        torso_1  = 173,
        torso_2  = 0,
        pants_1  = 78,
        pants_2  = 2,
        shoes_1 = 77,
        shoes_2 = 0,
        chain_1 = 0,
        chain_2 = 0,
        glasses_1 = 0,
        glasses_2 = 0,
        ears_1 = 0,
        ears_2 = 0,
    },
}