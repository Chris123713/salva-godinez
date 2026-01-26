
Config.Peds = {
    "mp_m_securoguard_01", "s_m_m_security_01", "s_m_y_airworker", "s_m_y_hwaycop_01", "ig_casey", "a_m_m_business_01"
}

Config.PedDeletionTimeout = 10000 --Time in milliseconds the ped will wander around before getting deleted (better immersion)
Config.ContainerDeletionTimeout = 10000 --Time in milliseconds the container will stand before getting deleted (better immersion)

Config.Contracts = {
    atm = {
        level = 1,
        type = 'atm',
        icon = 'atmjob',
        title = 'FLEECA ATM JOB',
        description = 'Collect money from atms and then deliver them to various fleeca banks',
        bags = { min = 4, max = 8 },
        cooldown = { min = 1, sec = 30 },
        rewards = {
            Rank = {
                groupMultiplier = false, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            },

            Money = {
                account = 'bank',
                groupMultiplier = true, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            }
        },
        stops = {
            pickup = { min = 2, max = 3 },
            deliver = { min = 1, max = 3 },
        },

        pickup = {
            { pos = vector4(-56.81, -1751.43, 29.42, 242.1), ped = true },
            { pos = vector4(33.53, -1348.19, 29.5, 28.87), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
            { pos = vector4(-710.98, -818.89, 23.73, 174.64), ped = true },
            { pos = vector4(-612.87, -704.75, 31.24, 4.64), ped = true },
            { pos = vector4(25.34, -946.36, 29.36, 135.3), ped = true },
            { pos = vector4(-3040.84, 593.51, 7.91, 147.03), ped = true },
            { pos = vector4(-3144.97, 1127.24, 20.86, 222.01), ped = true },
            { pos = vector4(539.76, 2671.03, 42.16, 245.52), ped = true },
        },

        deliver = {
            { pos = vector4(306.35, -282.55, 54.16, 309.80), ped = true }, -- Hawick Ave Fleeca (Near Pillbox)
            { pos = vector4(-358.86, -53.37, 49.04, 309.61), ped = true }, -- Hawick Ave West Fleeca (Near LSC)
            { pos = vector4(-1215.6, -338.97, 37.78, 355.50), ped = true }, -- Blvd Del Perro Fleeca
            { pos = vector4(142.09, -1044.19, 29.37, 307.70), ped = true }, -- Legion Fleeca
            { pos = vector4(-1317.85, -831.95, 16.97, 129.6), ped = true }, -- Maze Bank
            { pos = vector4(-2956.89, 476.47, 15.7, 55.22), ped = true }, -- Great Ocean Highway Fleeca
            { pos = vector4(1181.42, 2712.74, 38.09, 143.65), ped = true }, -- Route 68 Fleeca
            { pos = vector4(-103.06, 6472.36, 31.63, 150.37), ped = true }, -- Paleto
        },

        bag = {-- Money bag carrying
            item = 'money_bag',--If this has a set item name, it will give money bag as an item, to disable this set item = false,
            model = 'xm_prop_x17_bag_01b',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,
            clothing = {--Bag clothing data
                --id is the clothing bag component id, drawable is the clothing item id and texture is the bags texture/color
                male = { id = 5, drawable = 45, texture = 0 },
                female = { id = 5, drawable = 45, texture = 0 }
            },
        },

        vehicle = {--Don't touch this
            model = 'g6speedo',--Vehicle spawn name
            type = 'automobile',
            livery = 1,--Livery id
            extras = {
                -- [extra id] = true or false, enabled?
            },
            cargo = {
                areaSize = vec3(0.8, 1.0, 8.0),
                spacing = vec3(0.29, 0.60, 0.17),
                offsetPos = vec3(0.3, 2.3, -0.25),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        }
    },

    bank = {
        level = 2,
        type = 'bank',
        icon = 'bankjob',
        title = 'FLEECA BANK JOB',
        description = 'Collect packages from various locations and deliver them to the fleeca banks',
        bags = { min = 6, max = 10 },
        cooldown = { min = 2, sec = 30 },
        rewards = {
            Rank = {
                groupMultiplier = false, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            },

            Money = {
                account = 'bank',
                groupMultiplier = true, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            }
        },
        stops = {
            pickup = { min = 2, max = 3 },
            deliver = { min = 2, max = 3 },
        },

        pickup = {
            { pos = vector4(1732.55, 6422.17, 35.04, 158.16), ped = true },
            { pos = vector4(1707.55, 4918.75, 42.06, 48.44), ped = true },
            { pos = vector4(1689.67, 4816.98, 42.06, 9.47), ped = true },
            { pos = vector4(27.4, -1339.03, 29.5, 155.66), ped = true },
            { pos = vector4(166.79, -1553.37, 29.26, 235.22), ped = true },
            { pos = vector4(-42.55, -1748.41, 29.42, 160.26), ped = true },
            { pos = vector4(927.59, 52.33, 81.10, 57.85), ped = true },
            { pos = vector4(1160.80, -311.91, 69.28, 8.93), ped = true },
            { pos = vector4(977.75, -1465.95, 31.43, 91.73), ped = true },
            { pos = vector4(902.40, -2273.35, 32.55, 267.12), ped = true },
            { pos = vector4(1197.21, -3253.39, 7.10, 89.65), ped = true },
            { pos = vector4(858.57, -3202.96, 5.99, 180.49), ped = true },
            { pos = vector4(637.01, -3015.12, 6.23, 354.44), ped = true },
            { pos = vector4(247.89, -3315.87, 5.79, 184.56), ped = true },
            { pos = vector4(-260.44, -2657.32, 6.44, 319.17), ped = true },
            { pos = vector4(-495.92, -2911.08, 6.00, 227.04), ped = true },
            { pos = vector4(-272.63, -2496.22, 7.30, 225.31), ped = true },
            { pos = vector4(89.17, -2564.57, 6.00, 2.94), ped = true },
            { pos = vector4(-733.77, -2465.87, 13.94, 59.87), ped = true },
            { pos = vector4(-752.34, -2550.43, 13.94, 328.39), ped = true },
            { pos = vector4(-1068.92, -2868.37, 13.95, 146.31), ped = true },
            { pos = vector4(-737.77, -2274.66, 13.44, 133.55), ped = true },
            { pos = vector4(-252.96, -2024.95, 29.95, 231.16), ped = true },
            { pos = vector4(-327.20, -1362.07, 31.63, 268.77), ped = true },
            { pos = vector4(-287.58, -1061.37, 27.21, 251.24), ped = true },
            { pos = vector4(-120.29, -612.77, 36.28, 247.59), ped = true },
            { pos = vector4(-46.71, -584.18, 37.95, 74.53), ped = true },
            { pos = vector4(-354.56, -128.22, 39.43, 64.33), ped = true },
            { pos = vector4(-1624.29, -501.71, 36.48, 234.16), ped = true },
            { pos = vector4(-1275.97, 316.71, 65.51, 183.50), ped = true },
            { pos = vector4(-309.70, 221.75, 87.93, 11.70), ped = true },
            { pos = vector4(-2072.48, -318.67, 13.32, 81.96), ped = true },
        },

        deliver = {
            { pos = vector4(306.35, -282.55, 54.16, 309.80), ped = true }, -- Hawick Ave Fleeca (Near Pillbox)
            { pos = vector4(-358.86, -53.37, 49.04, 309.61), ped = true }, -- Hawick Ave West Fleeca (Near LSC)
            { pos = vector4(-1215.6, -338.97, 37.78, 355.50), ped = true }, -- Blvd Del Perro Fleeca
            { pos = vector4(142.09, -1044.19, 29.37, 307.70), ped = true }, -- Legion Fleeca
            { pos = vector4(-2956.89, 476.47, 15.7, 55.22), ped = true }, -- Great Ocean Highway Fleeca
            { pos = vector4(1181.42, 2712.74, 38.09, 143.65), ped = true }, -- Route 68 Fleeca
        },

        bag = {-- Money bag carrying
            item = 'money_bag',--If this has a set item name, it will give money bag as an item, to disable this set item = false,
            model = 'xm_prop_x17_bag_01b',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,      
            clothing = {--Bag clothing data
                --id is the clothing bag component id, drawable is the clothing item id and texture is the bags texture/color
                male = { id = 5, drawable = 45, texture = 0 },
                female = { id = 5, drawable = 45, texture = 0 }
            },
        },

        vehicle = {--Don't touch this
            model = 'g6speedo',--Vehicle spawn name
            type = 'automobile',
            livery = 1,--Livery id
            extras = {
                -- [extra id] = true or false, enabled?
            },
            cargo = {
                areaSize = vec3(0.8, 3.0, 8.0),
                spacing = vec3(0.29, 0.60, 0.17),
                offsetPos = vec3(0.3, 3, 0.43),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        }
    },

    vault = {
        level = 3,
        type = 'vault',
        icon = 'vaultjob',
        title = 'PACIFIC VAULT JOB',
        description = 'You will need to collect a cargo shipment and then transport the money into secure banks',
        bags = { min = 5, max = 10 },
        cooldown = { min = 5, sec = 30 },
        rewards = {
            Rank = {
                groupMultiplier = false, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            },

            Money = {
                account = 'bank',
                groupMultiplier = true, --Multiply this reward by the group count
                amount = { min = 100 , max = 200 } --Per bags
            }
        },
        stops = {
            pickup = { min = 2, max = 3 },
            deliver = { min = 2, max = 3 },
        },

        pickup = {
            {
                pos = vector4(1170.76, -2976.71, 6.1, 90.59),
                ped = false,
                container = {
                    vector4(1170.76, -2976.71, 6.1, 90.59)
                }
            },
            {
                pos = vector4(1054.53, -3207.89, 5.9, 179.85),
                ped = false,
                container = {
                    vector4(1054.53, -3207.89, 5.9, 179.85)
                }
            },
            { 
                pos = vector4(994.79, -2926.97, 6.1, 265.74),
                ped = false,
                container = {
                    vector4(994.79, -2926.97, 6.1, 265.74)
                }
            },
        },

        deliver = {
            { pos = vector4(256.81, 219.97, 106.29, 146.96), ped = true },
            { pos = vector4(-103.21, 6471.64, 31.63, 153.82), ped = true },
            { pos = vector4(146.95, -1045.65, 29.37, 44.28), ped = true },
        },

        bag = {-- Money bag carrying
            item = 'money_crate',--If this has a set item name, it will give money bag as an item, to disable this set item = false,
            model = 'prop_cash_crate_01',--Money bag model this is spawned only when you place it on the ground or in a vehicle
            disableSprint = false,
            disableJump = true,
            disableFight = false,      
            clothing = false,
            carrying = {
                offset = vec3(0.030, -0.25, -0.20),
                bone = 28422
            },
        },

        vehicle = {--Don't touch this
            model = 'g6speedo',--Vehicle spawn name
            type = 'automobile',
            livery = 1,--Livery id
            extras = {
                -- [extra id] = true or false, enabled?
            },
            cargo = {
                areaSize = vec3(0.8, 2.0, 8.0),
                spacing = vec3(0.70, 0.80, 0.30),
                offsetPos = vec3(0.3, 3, 0.43),      
                trunkBones = {
                    -- [door id, rage is 0 - 5] = bone name
                    [2] = 'dside_r',
                    [3] = 'pside_r'
                }
            },
        },

        container = {
            model = "prop_container_03_ld",
            doors = {
                left = "prop_container_door_mb_l",
                right = "prop_container_door_mb_r",
            },

            cargo = {
                model = "prop_cash_crate_01",
                areaSize = vec3(1.8, 6.0, 8.0),
                spacing = vec3(0.70, 0.80, 0.30),
                offsetPos = vec3(0.7, 3, 0.20),
            },
        }
    }
}