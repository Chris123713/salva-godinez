Config = {}
Config.devMode = false -- Please always make sure this is false before using the script

Config.Language = 'en'

Config.Framework = 'qb'
Config.Inventory = 'ox' -- ox, qb, codem, qs, core, tgiann, ps, origen

Config.Creator = {
    Command = "crest",
    Job = 'realestate'
}

Config.AdminPassword = 'March292001...!' -- This is the password to use in the admin commands, check the docs on how to use

Config.Blip = {
    Sprite = 106,
    Display = 4,
    Scale = 0.8,
    Color = 1,
    ShortRange = true
}

Config.FriedModels = {
    ['frenchfries'] = {
        item = 'frenchfriesbag',
        label = 'French Fries Bag',
        int = {
            text = 'Pack french fries',
            progressText = 'Packing french fries...',
            icon = 'fa-solid fa-box',
            duration = 3000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        },
        burntLabel = 'Burnt French Fries',
        rewardItem = 'frenchfries',
        count = 2,
        model = 'sn_frenchfries',
        plateModel = 'sn_frenchfries_extended',
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        duration = 5000,
        basketOffset = vector3(0.0, 0.0, 0.2),
        basketRotation = vector3(100.0, 0.0, -16.0),
        fryerOffsets = {
            inside = {
                {x = 0.42, y = -0.03, z = 0.65, w = 180.0},
                {x = 0.0, y = -0.03, z = 0.65, w = 180.0},
                {x = -0.42, y = -0.03, z = 0.65, w = 180.0},
            },
            basket = {
                {x = 0.0, y = 0.0, z = 0.04, w = 180.0},
                {x = 0.0, y = 0.0, z = 0.04, w = 180.0},
                {x = -0.0, y = 0.0, z = 0.04, w = 180.0},
            }
        }
    },
    ['chicken_nuggets'] = {
        item = 'chicken_nuggets_raw',
        label = 'Chicken Nuggets Bag',
        int = {
            text = 'Pack chicken nuggets',
            progressText = 'Packing chicken nuggets...',
            icon = 'fa-solid fa-box',
            duration = 3000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        },
        burntLabel = 'Burnt Chicken Nuggets',
        rewardItem = 'chicken_nuggets',
        count = 2,
        model = 'sn_nuggets',
        plateModel = 'sn_nuggets_extended',
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0),
        duration = 5000,
        basketOffset = vector3(0.0, 0.0, 0.2),
        basketRotation = vector3(100.0, 0.0, -16.0),
        fryerOffsets = {
            inside = {
                {x = 0.42, y = -0.02, z = 0.72, w = 180.0},
                {x = 0.0, y = -0.02, z = 0.72, w = 180.0},
                {x = -0.42, y = -0.02, z = 0.72, w = 180.0},
            },
            basket = {
                {x = 0.0, y = 0.0, z = 0.06, w = 180.0},
                {x = 0.0, y = 0.0, z = 0.06, w = 180.0},
                {x = -0.0, y = 0.0, z = 0.06, w = 180.0},
            }
        }
    }
}

Config.MeatModels = {
    -- Example
    ['rawburgerpatty'] = {
        item = 'rawburgerpatty',
        label = 'Raw Burger Patty',
        cookedLabel = 'Burger Patty',
        model = 'sn_burgerpattyraw',
        cookedModel = 'sn_burgerpatty',
        cookedItem = 'cookedburgerpatty',
        burntModel = 'sn_burgerpattyburnt',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack cooked patty',
            progressText = 'Packing cooked patty...',
            icon = 'fa-solid fa-drumstick-bite',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    },

    -- Raw Salmon → Cooked Salmon
    ['raw_salmon'] = {
        item = 'raw_salmon',
        label = 'Raw Salmon',
        cookedLabel = 'Cooked Salmon',
        model = 'sn_raw_salmon',
        cookedModel = 'sn_cooked_salmon',
        cookedItem = 'cooked_salmon',
        burntModel = 'sn_burnt_salmon',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack cooked salmon',
            progressText = 'Packing cooked salmon...',
            icon = 'fa-solid fa-fish',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    },

    -- Raw Tuna → Cooked Tuna
    ['raw_tuna'] = {
        item = 'raw_tuna',
        label = 'Raw Tuna',
        cookedLabel = 'Cooked Tuna',
        model = 'sn_raw_tuna',
        cookedModel = 'sn_cooked_tuna',
        cookedItem = 'cooked_tuna',
        burntModel = 'sn_burnt_tuna',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack cooked tuna',
            progressText = 'Packing cooked tuna...',
            icon = 'fa-solid fa-fish',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    },

    -- Raw Shrimp → Tempura Shrimp
    ['raw_shrimp'] = {
        item = 'raw_shrimp',
        label = 'Raw Shrimp',
        cookedLabel = 'Tempura Shrimp',
        model = 'sn_raw_shrimp',
        cookedModel = 'sn_tempura_shrimp',
        cookedItem = 'tempura_shrimp',
        burntModel = 'sn_burnt_shrimp',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack tempura shrimp',
            progressText = 'Packing shrimp...',
            icon = 'fa-solid fa-shrimp',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    },

    -- Raw Beef → Grilled Beef
    ['raw_beef'] = {
        item = 'raw_beef',
        label = 'Raw Beef',
        cookedLabel = 'Grilled Beef',
        model = 'sn_raw_beef',
        cookedModel = 'sn_grilled_beef',
        cookedItem = 'grilled_beef',
        burntModel = 'sn_burnt_beef',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack grilled beef',
            progressText = 'Packing beef...',
            icon = 'fa-solid fa-drumstick-bite',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    },

    -- Raw Chicken → Grilled Chicken
    ['raw_chicken'] = {
        item = 'raw_chicken',
        label = 'Raw Chicken',
        cookedLabel = 'Grilled Chicken',
        model = 'sn_raw_chicken',
        cookedModel = 'sn_grilled_chicken',
        cookedItem = 'grilled_chicken',
        burntModel = 'sn_burnt_chicken',
        zOffset = 0.02,
        duration = 15000,
        int = {
            text = 'Pack grilled chicken',
            progressText = 'Packing chicken...',
            icon = 'fa-solid fa-drumstick-bite',
            duration = 2000,
            animation = {
                dict = "creatures@rottweiler@tricks@",
                anim = "petting_franklin",
            }
        }
    }
}

Config.Fridges = {
    Slots = 15,
    Weight = 600000
}


Config.Restaurants = {
    ['uniqx_burgershot'] = {
        Enabled = true, -- Enabled for your server
        coords = vector3(-1195.44, -898.24, 13.89),
        CookingStations = {
            {
                coords = vector3(-1202.39, -895.5, 13.69),
            },
            {
                coords = vector3(-1200.3, -894.47, 13.69)
            }
        },
        Speakers = {
            vector3(-1186.99, -880.45, 18.41),
            vector3(-1198.84, -886.8, 17.69),
            vector3(-1184.54, -899.64, 19.15),
            vector3(-1176.56, -894.21, 18.63),
            vector3(-1186.84, -888.24, 17.76),
            vector3(-1200.45, -893.4, 18.16)
        },
        Fridges = {
            vector3(-1202.39, -897.38, 13.69),
            vector3(-1203.27, -896.05, 13.69)
        },
        DrinksMachines = {
            {
                coords = vector3(-1191.66, -898.71, 13.89),
                type = "soda_juice",
            },
            {
                coords = vector3(-1190.54, -898.01, 13.89),
                type = "coffee",
            }
        }, 
        TrashCans = {
            {
                prop = 'prop_bin_07d',
                coords = vector3(-1199.44, -899.29, 12.88),
                rotation = vector3(0.0, 0.0, 0.0),
                limit = 10
            },
        },
        Dumpsters = {
            vector3(-1190.81, -901.82, 13.63),
            vector3(-1188.83, -900.67, 13.63)
        },
        Spatulas = {
            prop = 'sn_spatula',
            objects = {
                {
                    coords = vector3(-1194.11, -898.04, 13.8),
                    rotation = vector3(0.00, -0.00, 109.30)
                }
            }
        },
        NpcEnabled = true,
        NpcModels = {
            'a_f_m_business_02',
            'a_f_y_eastsa_03',
            'a_f_o_ktown_01',
            'a_m_m_bevhills_01',
            'a_m_m_business_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_02',
        },
        NpcInterval = 60000,
        NpcWaitingLocations = {
            [1] = vector4(-1191.34, -893.47, 13.89, 167.52),
            [2] = vector4(-1192.73, -893.13, 13.89, 159.63),
            [3] = vector4(-1194.72, -892.58, 13.89, 170.09),
            [4] = vector4(-1196.69, -892.04, 13.89, 165.34),
        },
        NpcRoutes = {
            [1] = {
                {coords = vector3(-1199.45, -881.39, 13.38), heading = 294.46},
                {coords = vector3(-1185.15, -872.33, 13.88), heading = 244.54},
                {coords = vector3(-1178.0, -883.24, 13.89), heading = 193.75},
                {coords = vector3(-1183.36, -887.76, 13.89), heading = 81.31},
                {coords = vector3(-1186.03, -885.96, 13.89), heading = 28.67, freeze = true, kiosk=true, wait = 10000},
                {coords = vector3(-1182.31, -887.22, 13.89), freeze = false},
                {coords = vector3(-1176.95, -883.31, 13.92)},
                {coords = vector3(-1181.63, -870.12, 13.99)},
                {coords = vector3(-1125.71, -833.5, 13.38), delete = true},
            },

        },
        Fryers = {
            prop = 'sn_fryer',
            particle = {
                dict = 'core',
                anim = 'ent_amb_foundry_heat_haze',
                looped = true,
                scale = 0.3,
                alpha = 7.0,
                duration = 10000,
                offset = vector3(0.0, 0.0, 0.4),
                rotation = vector3(0.0, 0.0, 0.0)
            },
            coords = {
                vector4(-1196.700439, -899.696472, 12.926175, 163.777969),
                vector4(-1195.428711, -900.043274, 12.926175, 163.77423)
            }
        },
        Grills = {
            [1] = {
                particleCoords = vector3(-1195.72, -897.19, 13.89),
                particle = {
                    dict = 'core',
                    anim = 'ent_anim_bbq',
                    looped = true,
                    scale = 0.5,
                    alpha = 1.0,
                    duration = 10000,
                    offset = vector3(0.0, 0.0, -0.5),
                    rotation = vector3(0.0, 0.0, 0.0)
                },
                intCoords = vector3(-1195.99, -897.97, 13.89),
                grillCoords = {
                    ['rawburgerpatty'] = {
                        [1] = {
                            coords = vector3(-1195.87, -897.05, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [2] = {
                            coords = vector3(-1195.70, -897.09, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [3] = {
                            coords = vector3(-1195.53, -897.13, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [4] = {
                            coords = vector3(-1195.91, -897.23, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [5] = {
                            coords = vector3(-1195.74, -897.27, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [6] = {
                            coords = vector3(-1195.57, -897.31, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        }
                    }
                }
            },
            [2] = {
                particleCoords = vector3(-1194.94, -897.41, 13.88),
                particle = {
                    dict = 'core',
                    anim = 'ent_anim_bbq',
                    looped = true,
                    scale = 1.0,
                    alpha = 1.0,
                    duration = 10000,
                    offset = vector3(0.0, 0.0, -0.5),
                    rotation = vector3(0.0, 0.0, 0.0)
                },
                intCoords = vector3(-1195.16, -898.2, 13.89),
                grillCoords = {
                    ['rawburgerpatty'] = {
                        [1] = {
                            coords = vector3(-1195.14, -897.29, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [2] = {
                            coords = vector3(-1194.97, -897.30, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [3] = {
                            coords = vector3(-1194.77, -897.35, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [4] = {
                            coords = vector3(-1195.20, -897.44, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [5] = {
                            coords = vector3(-1195.01, -897.48, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [6] = {
                            coords = vector3(-1194.81, -897.53, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        }
                    }
                }
            }
        },
        FriesPlates = {
            prop = 'prop_food_tray_01',
            plates = {
                {
                    plateCoords = {
                        coords = vector3(-1197.53, -896.94, 13.81),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(-1197.54, -896.92, 13.70),
                            rotation = vector3(87.35, 1.90, -79.41)
                        },
                        ['chicken_nuggets'] = {
                            coords = vector3(-1197.54, -896.92, 14.15),
                            rotation = vector3(0.0, 0.0, 0.0)
                        }
                    },
                    meatCoords = {
                        ['rawburgerpatty'] = {
                            coords = vector3(-1197.48, -896.88, 13.68),
                            rotation = vector3(90.0, 0.0, 0.0)
                        }
                    }
                },
                {
                    plateCoords = {
                        coords = vector3(-1197.85, -899.48, 13.81),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(-1197.841, -899.50, 13.70),
                            rotation = vector3(-80.174, -0.00, -0.00)
                        },
                        ['chicken_nuggets'] = {
                            coords = vector3(-1197.841, -899.50, 14.15),
                            rotation = vector3(0.0, 0.0, 0.0)
                        }
                    },
                    meatCoords = {
                        ['rawburgerpatty'] = {
                            coords = vector3(-1197.79, -899.46, 13.68),
                            rotation = vector3(90.0, 0.0, 0.0)
                        }
                    }
                }
            }
        }
    },
    ['kingmaps_burgershot'] = {
        Enabled = false,
        coords = vector3(-1195.65, -897.82, 13.91),
        CookingStations = {
            {
                coords = vector3(-1195.39, -900.68, 13.75),
            },
            {
                coords = vector3(-1198.43, -900.33, 13.75)
            },
            {
                coords = vector3(-1196.59, -898.85, 13.75)
            }
        },
        DrinksMachines = {},
        Speakers = {
            vector3(-1198.96, -889.01, 17.37),
            vector3(-1188.59, -882.37, 17.36),
            vector3(-1181.06, -893.3, 17.29),
            vector3(-1188.92, -898.46, 17.12),
            vector3(-1189.91, -890.22, 16.53),
            vector3(-1195.05, -899.01, 17.15)
        },
        Fridges = {
            vector3(-1199.45, -897.03, 13.91),
        },
        TrashCans = {
            {
                prop = 'prop_bin_07d',
                coords = vector3(-1196.44, -893.88, 12.91),
                rotation = vector3(0.0, 0.0, 0.0),
                limit = 20
            },
        },
        Dumpsters = {
            vector3(-1185.95, -903.15, 13.8),
        },
        Spatulas = {
            prop = 'sn_spatula',
            objects = {
                {
                    coords = vector3(-1196.31, -903.46, 13.92),
                    rotation = vector3(0.00, -0.00, 0.0)
                },
                {
                    coords = vector3(-1195.91, -903.08, 13.92),
                    rotation = vector3(0.00, -0.00, 30.00)
                },
                {
                    coords = vector3(-1195.51, -902.70, 13.92),
                    rotation = vector3(0.00, -0.00, 80.00)
                },
                {
                    coords = vector3(-1196.45, -900.81, 13.93),
                    rotation = vector3(0.00, -0.00, 0.00)
                },
                {
                    coords = vector3(-1198.753, -900.70, 13.93),
                    rotation = vector3(0.00, -0.00, 0.00)
                }
            }
        },
        NpcEnabled = true,
        NpcModels = {
            'a_f_m_business_02',
            'a_f_y_eastsa_03',
            'a_f_o_ktown_01',
            'a_m_m_bevhills_01',
            'a_m_m_business_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_02',
        },
        NpcInterval = 50000,
        NpcWaitingLocations = {
            [1] = vector4(-1195.21, -892.13, 13.91, 277.17),
            [2] = vector4(-1191.87, -896.63, 13.91, 127.62),
            [3] = vector4(-1192.83, -895.36, 13.91, 125.87),
            [4] = vector4(-1193.78, -893.9, 13.91, 132.55),
        },
        NpcRoutes = {
            [1] = {
                {coords = vector4(-1193.79, -878.69, 13.54, 119.5)},
                {coords = vector4(-1199.05, -882.48, 13.36, 183.71)},
                {coords = vector4(-1197.46, -886.41, 13.67, 208.44)},
                {coords = vector4(-1189.33, -898.36, 13.91, 214.82), freeze = true, kiosk=true, wait = 10000},
                {coords = vector4(-1197.94, -886.02, 13.59, 34.32), freeze = false},
                {coords = vector4(-1200.96, -882.57, 13.33, 115.24)},
                {coords = vector4(-1214.18, -890.95, 12.9, 120.29)},
                {coords = vector4(-1233.99, -904.83, 12.04, 133.87)},
                {coords = vector4(-1231.12, -911.08, 11.71, 13.59), delete = true},
            },

        },
        Fryers = {
            prop = 'sn_fryer',
            particle = {
                dict = 'core',
                anim = 'ent_amb_foundry_heat_haze',
                looped = true,
                scale = 0.3,
                alpha = 5.0,
                duration = 15000,
                offset = vector3(0.0, 0.0, 0.4),
                rotation = vector3(0.0, 0.0, 0.0)
            },
            coords = {
                vector4(-1194.13, -901.98, 12.95, -145.85),
            }
        },
        Grills = {
            [1] = {
                particleCoords = vector3(-1197.838135, -902.460449, 13.89),
                particle = {
                    dict = 'core',
                    anim = 'ent_anim_bbq',
                    looped = true,
                    scale = 1.0,
                    alpha = 0.8,
                    duration = 10000,
                    offset = vector3(0.0, 0.0, -0.5),
                    rotation = vector3(0.0, 0.0, 0.0)
                },
                intCoords = vector3(-1197.01, -902.03, 13.91),
                grillCoords = {
                    ['rawburgerpatty'] = {
                        [1] = {
                            coords = vector3(-1197.598389, -903.089783, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [2] = {
                            coords = vector3(-1197.39, -902.918823, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [3] = {
                            coords = vector3(-1197.222168, -902.775024, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [4] = {
                            coords = vector3(-1197.804443, -902.691223, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [5] = {
                            coords = vector3(-1197.624634, -902.534668, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [6] = {
                            coords = vector3(-1197.407349, -902.437683, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [7] = {
                            coords = vector3(-1198.022339, -902.392090, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [8] = {
                            coords = vector3(-1197.806763, -902.223206, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [9] = {
                            coords = vector3(-1197.658691, -902.096069, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [10] = {
                            coords = vector3(-1198.276367, -902.064331, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [11] = {
                            coords = vector3(-1198.066406, -901.914062, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                        [12] = {
                            coords = vector3(-1197.864136, -901.757629, 13.86),
                            rotation = vector3(90.0, 0.00, 0.00)
                        },
                    }
                }
            }
        },
        FriesPlates = {
            prop = 'prop_food_tray_01',
            plates = {
                {
                    plateCoords = {
                        coords = vector3(-1199.12, -900.50, 13.91),
                        rotation = vector3(0.0, 0.0, 30.0)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(-1199.101562, -900.496033, 13.80),
                            rotation = vector3(90.0, 0.0, 0.0)
                        },
                        ['chicken_nuggets'] = {
                            coords = vector3(-1199.101562, -900.496033, 14.25),
                            rotation = vector3(0.0, 0.0, 0.0)
                        }
                    },
                    meatCoords = {
                        ['rawburgerpatty'] = {
                            coords = vector3(-1199.105957, -900.502441, 13.77),
                            rotation = vector3(90.0, 0.0, 0.0)
                        }
                    }
                },
                {
                    plateCoords = {
                        coords = vector3(-1196.93, -899.70, 13.91),
                        rotation = vector3(0.0, 0.0, 33.0)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(-1196.920, -899.67, 13.80),
                            rotation = vector3(90.0, 0.0, 0.0)
                        },
                        ['chicken_nuggets'] = {
                            coords = vector3(-1196.920, -899.67, 14.25),
                            rotation = vector3(0.0, 0.0, 0.0)
                        }
                    },
                    meatCoords = {
                        ['rawburgerpatty'] = {
                            coords = vector3(-1196.95, -899.69, 13.77),
                            rotation = vector3(90.0, 0.0, 0.0)
                        }
                    }
                },
                {
                    plateCoords = {
                        coords = vector3(-1195.13, -899.93, 13.9),
                        rotation = vector3(0.0, 0.0, 30.0)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(-1195.126, -899.965, 13.9),
                            rotation = vector3(90.0, 0.0, 0.0)
                        },
                        ['chicken_nuggets'] = {
                            coords = vector3(-1195.126, -899.965, 14.25),
                            rotation = vector3(0.0, 0.0, 0.0)
                        }
                    },
                    meatCoords = {
                        ['rawburgerpatty'] = {
                            coords = vector3(-1195.12, -899.94, 13.77),
                            rotation = vector3(90.0, 0.0, 0.0)
                        }
                    }
                }
            }
        }
    },
    ['kiiya_r68_diner_p'] = {
        Enabled = false,
        coords = vector3(1037.20, 2662.41, 39.91),
        CookingStations = {
            {
                coords = vector3(1035.74, 2656.47, 39.31),
            },
            {
                coords = vector3(1036.98, 2656.48, 39.31),
            },
            {
                coords = vector3(1036.89, 2657.67, 39.31),
            },
        },
        DrinksMachines = {},
        Speakers = {
            vector3(1033.00, 2668.13, 42.52),
            vector3(1040.38, 2668.13, 42.73),
            vector3(1050.42, 2665.51, 42.80),
            vector3(1050.48, 2658.90, 42.89),
            vector3(1033.19, 2659.76, 42.80),
        },
        Fridges = {
            vector3(1036.12, 2658.12, 39.31),
        },
        TrashCans = {
            {
                prop = 'prop_bin_07d',
                coords = vector3(1033.10, 2656.99, 38.87),
                rotation = vector3(0.00, 0.00, 0.00),
                limit = 20
            },
        },
        Dumpsters = {
            vector3(1018.90, 2650.26, 39.60),
            vector3(1020.87, 2650.23, 39.55),
        },
        Spatulas = {
            prop = 'sn_spatula',
            objects = {
                {
                    coords = vector3(1035.99, 2656.87, 39.9),
                    rotation = vector3(-5.64, -4.51, 141.47)
                },
            }
        },
        Fryers = {
            prop = 'sn_fryer',
            particle = {
                dict = 'core',
                anim = 'ent_amb_foundry_heat_haze',
                looped = true,
                scale = 0.3,
                alpha = 5.0,
                duration = 15000,
                offset = vector3(0.0, 0.0, 0.4),
                rotation = vector3(0.0, 0.0, 0.0)
            },
            coords = {
                vector4(1036.81, 2655.30, 38.95, 179.72),
            }
        },
        FriesPlates = {
            prop = 'prop_food_tray_01',
            plates = {
                {
                    plateCoords = {
                        coords = vector3(1037.35, 2656.91, 39.90),
                        rotation = vector3(0.0, 0.0, -7.73)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(1037.35, 2656.91, 39.90),
                            rotation = vector3(0.0, 0.0, 0.0)
                        },
                        meatCoords = {
                            ['rawburgerpatty'] = {
                                coords = vector3(1037.35, 2656.91, 39.90),
                                rotation = vector3(0.0, 0.0, 0.0)
                            }
                        }
                    }
                },
                {
                    plateCoords = {
                        coords = vector3(1038.77, 2655.98, 39.90),
                        rotation = vector3(0.0, 0.0, 0.24)
                    },
                    friesCoords = {
                        ['frenchfries'] = {
                            coords = vector3(1038.77, 2655.98, 39.90),
                            rotation = vector3(0.0, 0.0, 0.0)
                        },
                        meatCoords = {
                            ['rawburgerpatty'] = {
                                coords = vector3(1038.77, 2655.98, 39.90),
                                rotation = vector3(0.0, 0.0, 0.0)
                            }
                        }
                    }
                },
            },
        },
        Grills = {
            [1] = {
                intCoords = vector3(1035.50, 2656.04, 39.91),
                particleCoords = vector3(1035.51, 2655.26, 39.87),
                particle = {
                    dict = 'core',
                    anim = 'ent_anim_bbq',
                    looped = true,
                    scale = 1.0,
                    alpha = 0.8,
                    duration = 10000,
                    offset = vector3(0.0, 0.0, -0.5),
                    rotation = vector3(0.0, 0.0, 0.0)
                },
                grillCoords = {
                    ['rawburgerpatty'] = {
                        [1] = {
                            coords = vector3(1035.83, 2655.04, 39.86),
                            rotation = vector3(84.89, 0.00, 0.00)
                        },
                        [2] = {
                            coords = vector3(1035.85, 2655.23, 39.86),
                            rotation = vector3(87.05, 0.00, 0.00)
                        },
                        [3] = {
                            coords = vector3(1035.84, 2655.42, 39.86),
                            rotation = vector3(92.92, 0.00, 0.00)
                        },
                        [4] = {
                            coords = vector3(1035.52, 2655.04, 39.86),
                            rotation = vector3(86.31, 0.00, 0.00)
                        },
                        [5] = {
                            coords = vector3(1035.52, 2655.25, 39.86),
                            rotation = vector3(89.20, 0.00, 0.00)
                        },
                        [6] = {
                            coords = vector3(1035.49, 2655.42, 39.86),
                            rotation = vector3(93.79, 0.00, 0.00)
                        },
                        [7] = {
                            coords = vector3(1035.19, 2655.05, 39.86),
                            rotation = vector3(94.10, 0.00, 0.00)
                        },
                        [8] = {
                            coords = vector3(1035.18, 2655.25, 39.86),
                            rotation = vector3(91.52, 0.00, 0.00)
                        },
                        [9] = {
                            coords = vector3(1035.19, 2655.44, 39.86),
                            rotation = vector3(88.45, 0.00, 0.00)
                        },
                    },
                },
            },
        },
        NpcEnabled = true,
        NpcModels = {
            'a_f_m_business_02',
            'a_f_y_eastsa_03',
            'a_f_o_ktown_01',
            'a_m_m_bevhills_01',
            'a_m_m_business_01',
            'a_m_m_fatlatin_01',
            'a_m_m_genfat_02',
        },
        NpcInterval = 60000,
    },
}

Config.Musics = {
    {
        name = "Pixies - Where Is My Mind",
        link = 'https://cdn.discordapp.com/attachments/817769850566606848/1391119599650734130/Pixies_-_Where_Is_My_Mind__Official_Lyric_Video.mp3?ex=68789456&is=687742d6&hm=a81469f9d1c93106da87acf42a6c4022e5f1f977bc5c7489d12ec8cac5f64a70&',
    },
    {
        name = 'Arctic Monkeys - 505',
        link = 'https://cdn.discordapp.com/attachments/817769850566606848/1391079047185830009/505_-_arctic_monkeys_-_sau_d_-_SoundLoadMate.com.mp3?ex=686a96d1&is=68694551&hm=f2c9395a10474a4fd52dcb58ed62af2defe74bb1d48dbdbe743f0a5727e0a540&',   
    },
    {
        name = "Pearl Jam - Even Flow",
        link = 'https://cdn.discordapp.com/attachments/817769850566606848/1381823757227786400/pearljam.mp3?ex=686a8968&is=686937e8&hm=82357f14ac3199373d8aab3963b1cdcf8ce3fc2b7512f8f532b5231dce287bc2&',
    },
    {
        name = "Vargas - 6 Stars",
        link = 'https://cdn.discordapp.com/attachments/817769850566606848/1391103532551114802/VARGAS_-_6_STARS_OFFICIAL_MUSIC_VIDEO.mp3?ex=686aad9f&is=68695c1f&hm=3e01e89c9564fb8f16caa8c568c1665ba9ae4300d516b063ea40065edfee1790&',
    },
}


Config.SupplyDelivery = {
    
    deliveryWaitTime = 10,
    
    
    deliveryLocations = {
        ['uniqx_burgershot'] = {
            coords = vector3(-1202.18, -906.09, 13.62),
            heading = 0.0,
            label = "Burger Shot Delivery Area"
        }
        
    },
    
    
    boxProp = {
        model = 'prop_box_wood02a',
        offset = vector3(0.0, 0.0, 0.0),
        rotation = vector3(0.0, 0.0, 0.0)
    },
    
    
    unpacking = {
        duration = 5000,
        animation = {
            dict = "mini@repair",
            anim = "fixing_a_ped",
            flag = 49
        },
        progressBar = {
            label = "Unpacking Supplies",
            duration = 5000
        }
    }
}

Config.TicketSystem = {
    TicketItem = 'restaurant_ticket',
    TaxRate = 0.085,
    DefaultServerName = 'Staff'
}

Config.PriceLimits = {
    enabled = true, -- Set to true to enable price limits
    maxPrice = 100.00, -- Maximum price allowed for menu items
    allowOverride = true -- Allow restaurant owners to override price limits
}

Config.RoleAccess = {
    Boss = {
        overview = true,
        general = true,
        employees = true,
        recipes = true,
        menu = true,
        pos = true,
        display = true,
        finance = true
    },
    Manager = {
        overview = true,
        general = true,
        employees = true,
        recipes = true,
        menu = true,
        pos = true,
        display = true,
        finance = false
    },
    Employee = {
        overview = false,
        general = false,
        employees = false,
        recipes = false,
        menu = false,
        pos = false,
        display = false,
        finance = false
    }
}

Config.Models = {
    ["prop_tv_flat_03b"] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.027,
        Offset = vector3(-0.320, -0.070, 0.210)
    },
}

Config.SoundEffects = {
    ['fryer'] = {
        url = 'https://nanoscripts.cloud/nn_restaurant/frying_sound_effect.mp3',
        volume = 0.05
    },
    ['grill'] = {
        url = 'https://nanoscripts.cloud/nn_restaurant/grilling_sound_effect.mp3',
        volume = 0.8
    }
}

-- Drinks Machine Configuration
Config.DrinksMachines = {
    ['soda_juice'] = {
        label = 'Soda & Juice Machine',
        model = 'prop_vend_coffe_01',
        supplies = {
            ['cola_syrup'] = { label = 'Cola Syrup', maxCapacity = 100, item = 'cola_syrup' },
            ['sprite_syrup'] = { label = 'Sprite Syrup', maxCapacity = 100, item = 'sprite_syrup' },
            ['orange_concentrate'] = { label = 'Orange Concentrate', maxCapacity = 100, item = 'orange_concentrate' },
            ['tea_leaves'] = { label = 'Tea Leaves', maxCapacity = 100, item = 'tea_leaves' },
            ['oolong_leaves'] = { label = 'Oolong Leaves', maxCapacity = 100, item = 'oolong_leaves' },
            ['sake'] = { label = 'Sake', maxCapacity = 50, item = 'sake' },
            ['beer'] = { label = 'Beer', maxCapacity = 50, item = 'beer' },
            ['ramune_syrup'] = { label = 'Ramune Syrup', maxCapacity = 100, item = 'ramune_syrup' },
            ['water'] = { label = 'Water', maxCapacity = 200, item = 'water' },
            ['carbonation'] = { label = 'Carbonation', maxCapacity = 150, item = 'carbonation' }
        },
        drinks = {
            ['cola'] = {
                label = 'Cola',
                item = 'cola',
                color = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
                pourTime = 30000,
                supplies = {
                    ['cola_syrup'] = 5,
                    ['water'] = 3,
                    ['carbonation'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'easy',
                    perfectZone = {min = 0.3, max = 0.7},
                    pourSpeed = 3.0
                }
            },
            ['sprite'] = {
                label = 'Sprite',
                item = 'sprite',
                color = {r = 0.9, g = 0.9, b = 0.9, a = 0.8},
                pourTime = 10000,
                supplies = {
                    ['sprite_syrup'] = 5,
                    ['water'] = 3,
                    ['carbonation'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'easy',
                    perfectZone = {min = 0.3, max = 0.7},
                    pourSpeed = 3.0
                }
            },
            ['juice'] = {
                label = 'Orange Juice',
                item = 'orange_juice',
                color = {r = 1.0, g = 0.6, b = 0.0, a = 0.8},
                pourTime = 10000,
                supplies = {
                    ['orange_concentrate'] = 8,
                    ['water'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'medium',
                    perfectZone = {min = 0.2, max = 0.8},
                    pourSpeed = 2.5
                }
            },
            ['water'] = {
                label = 'Water',
                item = 'water',
                color = {r = 0.8, g = 0.9, b = 1.0, a = 0.6},
                pourTime = 10000,
                supplies = {
                    ['water'] = 10
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'easy',
                    perfectZone = {min = 0.4, max = 0.6},
                    pourSpeed = 3.5
                }
            },
            ['green_tea'] = {
                label = 'Green Tea',
                item = 'green_tea',
                color = {r = 0.6, g = 0.8, b = 0.4, a = 0.8},
                pourTime = 12000,
                supplies = {
                    ['tea_leaves'] = 6,
                    ['water'] = 4
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'medium',
                    perfectZone = {min = 0.2, max = 0.7},
                    pourSpeed = 2.8
                }
            },
            ['oolong_tea'] = {
                label = 'Oolong Tea',
                item = 'oolong_tea',
                color = {r = 0.7, g = 0.5, b = 0.3, a = 0.8},
                pourTime = 12000,
                supplies = {
                    ['oolong_leaves'] = 6,
                    ['water'] = 4
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'medium',
                    perfectZone = {min = 0.2, max = 0.7},
                    pourSpeed = 2.5
                }
            },
            ['ramune'] = {
                label = 'Ramune Soda',
                item = 'ramune',
                color = {r = 0.2, g = 0.6, b = 1.0, a = 0.8},
                pourTime = 8000,
                supplies = {
                    ['ramune_syrup'] = 6,
                    ['water'] = 3,
                    ['carbonation'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'easy',
                    perfectZone = {min = 0.3, max = 0.6},
                    pourSpeed = 3.2
                }
            },
            ['sake'] = {
                label = 'Sake',
                item = 'sake',
                color = {r = 1.0, g = 1.0, b = 0.8, a = 0.9},
                pourTime = 15000,
                supplies = {
                    ['sake_stock'] = 5,
                    ['water'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'hard',
                    perfectZone = {min = 0.4, max = 0.55},
                    pourSpeed = 2.0
                }
            },
            ['japanese_beer'] = {
                label = 'Japanese Beer',
                item = 'japanese_beer',
                color = {r = 1.0, g = 0.85, b = 0.3, a = 0.8},
                pourTime = 12000,
                supplies = {
                    ['beer_stock'] = 5,
                    ['water'] = 2,
                    ['carbonation'] = 2
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'medium',
                    perfectZone = {min = 0.35, max = 0.65},
                    pourSpeed = 2.5
                }
            },
            ['water_bottle'] = {
                label = 'Water Bottle',
                item = 'water_bottle',
                color = {r = 0.7, g = 0.9, b = 1.0, a = 0.8},
                pourTime = 9000,
                supplies = {
                    ['water'] = 8
                },
                minigame = {
                    type = 'pouring',
                    difficulty = 'easy',
                    perfectZone = {min = 0.3, max = 0.6},
                    pourSpeed = 3.5
                }
            }
        }
    },
    ['coffee'] = {
        label = 'Coffee Machine',
        model = 'prop_coffee_mac_02',
        supplies = {
            ['coffee_beans'] = { label = 'Coffee Beans', maxCapacity = 100, item = 'coffee_beans' },
            ['milk'] = { label = 'Milk', maxCapacity = 150, item = 'milk' },
            ['foam_powder'] = { label = 'Foam Powder', maxCapacity = 80, item = 'foam_powder' },
            ['water'] = { label = 'Water', maxCapacity = 200, item = 'water' }
        },
        drinks = {
            ['coffee_black'] = {
                label = 'Black Coffee',
                item = 'coffee_black',
                color = {r = 0.3, g = 0.2, b = 0.1, a = 0.9},
                pourTime = 10000,
                supplies = {
                    ['coffee_beans'] = 3,
                    ['water'] = 7
                },
                minigame = {
                    type = 'coffee_multi_step',
                    difficulty = 'medium',
                    steps = {
                        {name = 'coffee', label = 'Coffee', color = {r = 0.3, g = 0.2, b = 0.1, a = 0.9}, ratio = 1.0, pourSpeed = 2.0},
                    },
                }
            },
            ['coffee_latte'] = {
                label = 'Latte',
                item = 'coffee_latte',
                color = {r = 0.8, g = 0.7, b = 0.5, a = 0.9},
                pourTime = 10000,
                supplies = {
                    ['coffee_beans'] = 3,
                    ['milk'] = 5,
                    ['water'] = 2
                },
                minigame = {
                    type = 'coffee_multi_step',
                    difficulty = 'medium',
                    steps = {
                        {name = 'coffee', label = 'Coffee', color = {r = 0.3, g = 0.2, b = 0.1, a = 0.9}, ratio = 0.7, pourSpeed = 2.0},
                        {name = 'milk', label = 'Milk', color = {r = 0.9, g = 0.9, b = 0.9, a = 0.8}, ratio = 0.3, pourSpeed = 1.5}
                    }
                }
            },
            ['coffee_cappuccino'] = {
                label = 'Cappuccino',
                item = 'coffee_cappuccino',
                color = {r = 0.9, g = 0.8, b = 0.6, a = 0.9},
                pourTime = 10000,
                supplies = {
                    ['coffee_beans'] = 3,
                    ['milk'] = 3,
                    ['foam_powder'] = 2,
                    ['water'] = 2
                },
                minigame = {
                    type = 'coffee_multi_step',
                    difficulty = 'hard',
                    steps = {
                        {name = 'coffee', label = 'Coffee', color = {r = 0.3, g = 0.2, b = 0.1, a = 0.9}, ratio = 0.5, pourSpeed = 1.8},
                        {name = 'milk', label = 'Milk', color = {r = 0.9, g = 0.9, b = 0.9, a = 0.8}, ratio = 0.3, pourSpeed = 1.5},
                        {name = 'foam', label = 'Foam', color = {r = 0.95, g = 0.95, b = 0.95, a = 0.9}, ratio = 0.2, pourSpeed = 1.0}
                    }
                }
            },
            ['coffee_espresso'] = {
                label = 'Espresso',
                item = 'coffee_espresso',
                color = {r = 0.2, g = 0.1, b = 0.05, a = 0.9},
                pourTime = 10000,
                supplies = {
                    ['coffee_beans'] = 4,
                    ['water'] = 6
                },
                minigame = {
                    type = 'coffee_multi_step',
                    difficulty = 'hard',
                    steps = {
                        {name = 'coffee', label = 'Coffee', color = {r = 0.3, g = 0.2, b = 0.1, a = 0.9}, ratio = 1.0, pourSpeed = 1.8},
                    }
                }
            },
        }
    }
}


function GetTranslation(key, ...)
    local lang = Config.Language or 'en'
    local translation = Translations[lang] and Translations[lang][key] or Translations['en'][key] or key
    
    if select('#', ...) > 0 then
        return string.format(translation, ...)
    end
    
    return translation
end


function T(key, ...)
    return GetTranslation(key, ...)
end