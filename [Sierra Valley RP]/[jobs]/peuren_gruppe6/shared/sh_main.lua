Config = {}

Config.Keybinds = {
    placeBag = 73,--Keybind to place the bag on the ground
}

Config.PedRenderDistance = 20--The distance required to be to a gruppe 6 ped to be able to see it
Config.BagRenderDistance = 20--The distance required to be to a gruppe 6 vehicle to be able to see the bags inside of the vehicle
Config.JobXPQuitPenalty = 100--How much to remove rank XP points from group leader for not finishing the job, to disable this option set it to false
Config.GroupMemberLimit = 10 --How many players can be in a single group, to disable this option set it to false
Config.ApplyOutfit = true--Apply configured job uniform to player when he starts the work?
Config.TabletCommand = false--Tablet open command or just set it to false, example: Config.TabletCommand = 'tablet'
Config.RequiredJob = false--Required job to access the gruppe6 job, Config.RequiredJob = "your job name here"
Config.TabletItem = 'gruppe6_tablet'--If you want to disable this set it to Config.TabletItem = false

Config.JobTextUI = {
    enabled = true, --Enable the job text UI?
    position = 'middle-right', --Position of the text UI 
}


Config.Dispatch = {
    enabled = true, --Send alert to police
    dispatch_code = '10-90', -- Dispatch code added to the message.
    message = 'Bank truck robbery in progress', -- Dispatch message.
    color = 1, -- Blip Color, more info: https://docs.fivem.net/docs/game-references/blips/#blip-colors
    sprite = 229, -- Blip Sprite, more info: https://docs.fivem.net/docs/game-references/blips/#blips
    scale = 1.5, -- Blip Scale
    time = 500, -- Blip Seconds Visible in seconds.
    delay = 5, -- Dispatch delay after first interaction in seconds.
    police_jobs = { 'lscso', 'police' }
}

Config.Robbery = {
    enabled = true,--Enable bank vehicle robbery?
    requiredWeapon = false,--Should the player have a weapon to start the robbery?
    robberyTime = 5000,--How long does the robbery take in ms?
    callPoliceChance = 50,--Chance to call police during robbery, 0-100%
    rewards = {
        type = 'item', --item, money,
        name  = 'black_money',--item or account name
        amount = { min = 5, max = 10 }--Amount you get per bag/crate in the vehicle
    }
}

Config.Blips = {
    center = {
        disable = false,--Disable this blip?
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Gruppe 6 headquarters",--Blip label
        radius = {
            enabled = false,--If radius is enabled, players will have to find the point in that radius, otherwise it will add a blip directly on the point
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    deliver = {
        disable = false,--Disable this blip?
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Deliver location",--Blip label
        route = true,
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    pickup = {
        disable = false,--Disable this blip?
        sprite = 374,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Pick up location",--Blip label
        route = true,
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    returnVehicle = {
        disable = false,--Disable this blip?
        sprite = 473,--Blip icon id
        color = 1,--Blip color id
        scale = 1.0,--Blip scale
        label = "Vehicle return point",--Blip label
        route = true,
        radius = {
            enabled = false,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },
}

Config.Center = {
    Ped = {
        model = 'cs_casey',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
        pos = vector3(-7.08, -653.9, 33.45),--Dealers positions
        heading = 182.86,--Dealers heading
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

    Territory = {
        pos = vector3(-16.91, -688.31, 32.34),
        radius = 50
    },

    Spawns = {
        { pos = vector3(-5.41, -670.47, 32.34),  heading = 185.04 },
        { pos = vector3(-19.58, -671.1, 32.34),  heading = 185.69 },
        { pos = vector3(-34.23, -673.33, 32.34), heading = 184.78 },
        { pos = vector3(-35.75, -700.61, 32.34), heading = 349.22 },
        { pos = vector3(-19.62, -705.79, 32.34), heading = 348.81 },
        { pos = vector3(-4.01, -711.43, 32.34),  heading = 347.5  },
    },

    Return = vector3(-35.25, -698.88, 32.34)
}

Config.Ranks = {--Don't touch this
    Levels = {--Don't touch this
        [1] = {--Rank level id
            minXP = 0,--minimum needed xp to unlock this level
            job = 'atm'--When a player reaches this rank level he unlocks this job type
        },
        [2] = {--Rank level id
            minXP = 5000,--minimum needed xp to unlock this level
            job = 'bank'--When a player reaches this rank level he unlocks this job type
        },
        [3] = {--Rank level id
            minXP = 10000,--minimum needed xp to unlock this level
            job = 'vault'--When a player reaches this rank level he unlocks this job type
        }
    }
}

Config.Outfits = {
    [`mp_m_freemode_01`] = {
        tshirt_1 = 58,
        tshirt_2 = 0,
        arms     = 37,
        torso_1  = 26,
        torso_2  = 1,
        pants_1  = 33,
        pants_2  = 0,
        shoes_1 = 24,
        shoes_2 = 0,
        chain_1 = 0,
        chain_2 = 0,
        glasses_1 = 0,
        glasses_2 = 0,
        ears_1 = 0,
        ears_2 = 0,
        vest_1 = 0,
        vest_2 = 0
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
        vest_1 = 0,
        vest_2 = 0
    },
}