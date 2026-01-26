Config.CollectionTime = 5000 --Garbage collection time in ms

Config.RecyclingMaterials = {
    ['metal'] = {
        interaction = "Recycle metal",
        pos = vector3(-581.7, -1601.02, 26),
        heading = 173.34,
        model = 'prop_skip_02a',
        rewards = {
            { item = "phone", min = 1, max = 2, chance = 100 }
        }
    },

    ['plastic'] = {
        interaction = "Recycle plastic",
        pos = vector3(-587.74, -1600.53, 26),
        heading = 173.34,
        model = 'tr_prop_tr_skip_ramp_01a',
        rewards = {
            { item = "phone", min = 1, max = 2, chance = 100 }
        }
    },

    ['paper'] = {
        interaction = "Recycle paper",
        pos = vector3(-579.36, -1602.29, 26),
        heading = 348.12,
        model = 'prop_skip_03',
        rewards = {
            { item = "phone", min = 1, max = 2, chance = 100 }
        }
    },
}

Config.RecyclingLine = {
    pos = vector3(-601.09, -1601.6, 30.41),
    heading = 85.75,
    width = 5,
    length = 7,
    points = {
        {
            coords = vector3(-599.34, -1603.9, 30.10),
            rot = { x = 0.0, y = 0.0, z = 70.0 },
            speed = 0.05,
        },
        {
            coords = vector3(-598.9, -1598.49, 27.57),
            rot = { x = 0.0, y = 0.0, z = 70.0 },
            speed = 0.05,
        },
        {
            coords = vector3(-598.87, -1596.8, 27.02),
            rot = { x = 0.0, y = 0.0, z = 70.0 },
            speed = 0.05,
        },
    }
}