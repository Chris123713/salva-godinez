Config = {}

Config.DumpsterRenderDistance = 20 --The render distance in which the dumpsters are visible to players
Config.GroupMemberLimit = 10 --How many players can be in a single group, to disable this option set it to false
Config.ApplyOutfit = true --When starting a job apply job clothes to players
Config.RequiredJob = false--Required job to access the garbage job, Config.RequiredJob = "you job name here"

Config.JobTextUI = {
    enabled = true, --Enable the job text UI?
    position = 'middle-right', --Position of the text UI 
}

Config.Keybinds = {
    placeTrash = 73,--Keybind to place the trash object on the ground
}

Config.Blips = {
    center = {
        disable = false,--Disable this blip?
        sprite = 318,--Blip icon id
        color = 10,--Blip color id
        scale = 1.0,--Blip scale
        label = "Garbage depot",--Blip label
    },

    recyclingCenter = {
        disable = false,--Disable this blip?
        sprite = 365,--Blip icon id
        color = 24,--Blip color id
        scale = 1.0,--Blip scale
        label = "Recycling center",--Blip label
    },

    garbageZone = {
        disable = false,--Disable this blip?
        sprite = 318,--Blip icon id
        color = 10,--Blip color id
        scale = 1.0,--Blip scale
        label = "Garbage collection zone",--Blip label
        radius = {
            enabled = true,--If radius is enabled, players will have to find the car in that radius, otherwise it will add a blip directly on the car
            sprite = 9,--Radius id
            color = 18,--Radius color id
            offsets = math.random(-170.0, 170.0),--Radius offset,
            radius = 250--Radius size,
        }
    },

    garbage = {
        disable = false,--Disable this blip?
        sprite = 467,--Blip icon id
        color = 11,--Blip color id
        scale = 1.0,--Blip scale
        label = "Garbage",--Blip label
    },

    returnVehicle = {
        disable = false,--Disable this blip?
        sprite = 473,--Blip icon id
        color = 1,--Blip color id
        scale = 1.0,--Blip scale
        route = true,
        label = "Vehicle return point",--Blip label
    },

    deliverTrash = {
        disable = false,--Disable this blip?
        sprite = 473,--Blip icon id
        color = 1,--Blip color id
        scale = 1.0,--Blip scale
        route = true,
        label = "Trash delivery location",--Blip label
    }
}

Config.Center = {
    Ped = {
        model = 's_m_y_construct_01',--Dealers ped model, model names can be found @ https://docs.fivem.net/docs/game-references/ped-models/
        pos = vector3(-354.63, -1546.0, 27.72),--Dealers positions
        heading = 274.33,--Dealers heading
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
        model = 'trash2',
        livery = 0,
        extras = {
            [2] = true
        },
    },

    Spawns = {
        { pos = vector3(-369.61, -1525.16, 27.76),  heading = 196.22 },
        { pos = vector3(-370.0, -1539.63, 27.06),   heading = 176.21 },
        { pos = vector3(-369.23, -1552.22, 25.92),  heading = 196.22 },
        { pos = vector3(-363.33, -1565.63, 24.91),  heading = 203.5  },
        { pos = vector3(-356.65, -1579.84, 23.47),  heading = 201.84 },
        { pos = vector3(-353.72, -1593.21, 22.06),  heading = 180.18 },
    },

    Return = {--Vehicle return point
        pos = vector3(-353.89, -1560.84, 25.19)
    },

    Recycling = {---garbage hq trash locations
        Pickups = {
            { pos = vector3(-349.0, -1554.82, 24.5),   heading = 4.43   },
            { pos = vector3(-352.22, -1554.71, 24.5),  heading = 3.36   },
            { pos = vector3(-358.68, -1553.93, 24.5),  heading = 359.76 },
        },

        Deliver = {
            pos = vector3(-600.44, -1592.37, 25.5),   heading = 176.28
        }
    },

    TrashLimit = 200,--How many times can players do the garbage collection job before it reaches the limit
    RecyclingLimit = 200,--How many times can players do the recycling job before it reaches the limit
}

Config.Outfits = {--Job outfits
    [`mp_m_freemode_01`] = {--Male
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
    [`mp_f_freemode_01`] = {--Female
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