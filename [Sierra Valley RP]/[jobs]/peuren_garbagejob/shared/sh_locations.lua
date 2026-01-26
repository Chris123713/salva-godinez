Config.MarkerColor = {
    r = 81,
    g = 145,
    b = 107,
    a = 250
}

Config.TrashDeletionTimeout = 10000 --Time in milliseconds the trash model will get deleted (better immersion)

Config.Job = {
    rewards = {--Payout after doing the jobs - ~$4,000/hr target
        account = 'bank',
        amount = { min = 130 , max = 190 } --Per picked up garbage, bag or container (~$160 avg)
    },

    zones = { min = 1, max = 3 },-- How many zones will have the player drive to collect garbage
    stops = { min = 3, max = 5 },-- How many garbage pick ups will be in one zone

    recycling = {--Recycling job
        bags = { min = 5, max = 8 },--How many bags do player need to collect to be able to drive to the recycling center

        bag = {---Trash bag carrying animation
            model = "prop_cs_rub_binbag_01",
        }
    }
}

Config.Searching = {--Dumpster searching configuration
    enabled = true, --Enable searching dumpsters for trash
    searchTime = 5000, --Time in milliseconds it takes to search a dumpster
    itemsPerDumpster = { min = 1, max = 3 }, --How many different items can be found in a dumpster
    items = { --Item rewards from searching a dumpster
        { name = 'water', min = 1, max = 2, chance = 30}, --Chance is in percent
        { name = 'sandwich', min = 1, max = 2, chance = 30 },
        { name = 'cigarette', min = 1, max = 2, chance = 30 },
        { name = 'phone', min = 1, max = 2, chance = 30 }
    }
}

--All supported trash models and their carrying animation offsets and rotations
Config.TrashModels = {
    ['prop_dumpster_02a'] =           { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['prop_dumpster_01a'] =           { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['m23_2_prop_m32_dumpster_01a'] = { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['prop_dumpster_02b'] =           { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['prop_cs_dumpster_01a'] =        { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['p_dumpster_t'] =                { offset = vec3(0.0, 1.00, -1.0),   rot = vec3(0.0, 0.0, 0.0),  bone = "SKEL_Pelvis" },
    ['prop_bin_07d'] =                { offset = vec3(0.0, -0.420, -1.290),  rot = vec3(0.0, 0.0, 0.0),  bone = 28422 },
    ['prop_bin_08a'] =                { offset = vec3(0.0, -0.420, -1.290),  rot = vec3(0.0, 0.0, 0.0),  bone = 28422 },
    ['prop_cs_rub_binbag_01'] =       { offset = vec3(0.12, 0.0, -0.05),  rot = vec3(220.0, 120.0, 0.0),  bone = 57005, dict = 'missfbi4prepp1',  anim = '_bag_walk_garbage_man' },
}

--Garbage collection locations
Config.Locations = {
    {
        pos = vector3(436.15, -1921.08, 24.56),--Zone center
        stops = {--Pick up locations in the zone
            { pos = vector4(426.89, -1924.62, 24.43, 227.78) },
            { pos = vector4(407.02, -1937.02, 23.9, 204.33) },
            { pos = vector4(519.35, -1885.79, 25.48, 31.06) },
            { pos = vector4(543.81, -1910.46, 24.98, 122.52) },
            { pos = vector4(380.27, -1980.92, 24.21, 257.39) },
            { pos = vector4(423.37, -1856.48, 27.37, 43.92) },
            { pos = vector4(470.62, -1855.97, 27.67, 132.43) },
        }
    },

    {
        pos = vector3(132.27, -250.47, 51.41),--Zone center
        stops = {--Pick up locations in the zone
            { pos = vector4(132.0, -244.89, 51.47, 166.78) },
            { pos = vector4(72.24, -206.91, 54.49, 252.35) },
            { pos = vector4(144.11, -290.18, 46.3, 154.31) },
            { pos = vector4(130.69, -337.7, 45.97, 341.34) },
            { pos = vector4(214.05, -317.23, 45.26, 73.68) },
            { pos = vector4(231.56, -293.37, 49.65, 152.46) },
            { pos = vector4(201.43, -261.94, 51.25, 266.18) },
            { pos = vector4(203.89, -368.27, 44.21, 19.08) },
        }
    },

    {
        pos = vector3(-1298.93, -1113.05, 6.78),--Zone center
        stops = {--Pick up locations in the zone
            { pos = vector4(-1291.37, -1108.27, 6.84, 99.59) },
            { pos = vector4(-1327.67, -1137.99, 4.32, 267.45) },
            { pos = vector4(-1320.87, -1163.83, 4.85, 94.98) },
            { pos = vector4(-1321.09, -1221.8, 5.73, 270.52) },
            { pos = vector4(-1344.4, -1211.64, 4.65, 1.74) },
            { pos = vector4(-1251.34, -1183.32, 6.88, 19.01) },
            { pos = vector4(-1246.87, -1158.32, 7.56, 217.06) },
            { pos = vector4(-1246.97, -1101.77, 8.15, 281.42) },
        }
    },
}