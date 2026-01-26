return {
    ['testburger'] = {
        label = 'Test Burger',
        weight = 220,
        degrade = 60,
        client = {
            image = 'burger_chicken.png',
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            export = 'ox_inventory_examples.testburger'
        },
        server = {
            export = 'ox_inventory_examples.testburger',
            test = 'what an amazingly delicious burger, amirite?'
        },
        buttons = {
            {
                label = 'Lick it',
                action = function(slot)
                    print('You licked the burger')
                end
            },
            {
                label = 'Squeeze it',
                action = function(slot)
                    print('You squeezed the burger :(')
                end
            },
            {
                label = 'What do you call a vegan burger?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('A misteak.')
                end
            },
            {
                label = 'What do frogs like to eat with their hamburgers?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('French flies.')
                end
            },
            {
                label = 'Why were the burger and fries running?',
                group = 'Hamburger Puns',
                action = function(slot)
                    print('Because they\'re fast food.')
                end
            }
        },
        consume = 0.3
    },

    ['bandage'] = {
        label = 'Bandage',
        weight = 115,
    },

    ['vehicle_manual'] = {
        label = 'Vehicle Manual',
        weight = 100,
        stack = true,
        close = true,
    },

    ['burger'] = {
        label = 'Burger',
        weight = 220,
        client = {
            status = { hunger = 200000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
            notification = 'You ate a delicious burger'
        },
    },

    ['sprunk'] = {
        label = 'Sprunk',
        weight = 350,
        client = {
            status = { thirst = 200000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
            usetime = 2500,
            notification = 'You quenched your thirst with a sprunk'
        }
    },

    ['parachute'] = {
        label = 'Parachute',
        weight = 8000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 1500
        }
    },

    ['garbage'] = {
        label = 'Garbage',
    },

    ['paperbag'] = {
        label = 'Paper Bag',
        weight = 1,
        stack = false,
        close = false,
        consume = 0
    },

    ['panties'] = {
        label = 'Knickers',
        weight = 10,
        consume = 0,
        client = {
            status = { thirst = -100000, stress = -25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
            usetime = 2500,
        }
    },

    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
    },

    ['phone'] = {
        label = 'Phone',
        weight = 190,
        stack = false,
        consume = 0,
        client = {
            add = function(total)
                if total > 0 then
                    pcall(function() return exports.npwd:setPhoneDisabled(false) end)
                end
            end,

            remove = function(total)
                if total < 1 then
                    pcall(function() return exports.npwd:setPhoneDisabled(true) end)
                end
            end
        }
    },

    ['mustard'] = {
        label = 'Mustard',
        weight = 500,
        client = {
            status = { hunger = 25000, thirst = 25000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
            usetime = 2500,
            notification = 'You... drank mustard'
        }
    },

    ['water'] = {
        label = 'Water',
        weight = 500,
        client = {
            status = { thirst = 400000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
            usetime = 2500,
            cancel = true,
            notification = 'You drank some refreshing water'
        }
    },

    ['armour'] = {
        label = 'Bulletproof Vest',
        weight = 3000,
        stack = false,
        client = {
            anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
            usetime = 3500
        }
    },

    ['clothing'] = {
        label = 'Clothing',
        consume = 0,
    },

    ['money'] = {
        label = 'Money',
    },

    ['black_money'] = {
        label = 'Dirty Money',
    },

    ['id_card'] = {
        label = 'Identification Card',
    },

    ['driver_license'] = {
        label = 'Drivers License',
    },

    ['weaponlicense'] = {
        label = 'Weapon License',
    },

    ['lawyerpass'] = {
        label = 'Lawyer Pass',
    },

    ['class1'] = {
        label = 'Weapon License Class 1',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
        }
    },

    ['class2'] = {
        label = 'Weapon License Class 2',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
        }
    },

    -- Drive School Licenses
     driver_car = {
        id_length = 8,
        label = "Car Driving License",
        manager = 'dmv', -- must belong to one of Config.Manager list
        requires = {
            'dmv',       -- this license requires dmv license to have first
        },
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_bike = {
        id_length = 8,
        label = "Bike Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_truck = {
        id_length = 8,
        label = "Truck Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_helicopter = {
        id_length = 8,
        label = "Helicopter Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_boat = {
        id_length = 8,
        label = "Boat Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    driver_plane = {
        id_length = 8,
        label = "Plane Driving License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        lostPrice = 1000
    },
    theory_driver_car = {
        id_length = 8,
        label = "Car Theory License",
        manager = 'dmv', -- must belong to one of Config.Manager list
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_bike = {
        id_length = 8,
        label = "Bike Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_truck = {
        id_length = 8,
        label = "Truck Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_helicopter = {
        id_length = 8,
        label = "Helicopter Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_boat = {
        id_length = 8,
        label = "Boat Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },
    theory_driver_plane = {
        id_length = 8,
        label = "Plane Theory License",
        manager = 'dmv',
        job = 'police',
        validFor = 31,
        price = 2500,
        nonItem = true,
        lostPrice = 1000
    },

['weapon'] = {
        label = 'Firearm License',
        description = 'Kartu Ijin Senjata',
        weight = 50,
        stack = false,
        close = true,
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
        }
    },

    ['radio'] = {
        label = 'Radio',
        weight = 1000,
        allowArmed = true,
        consume = 0,
        client = {
            event = 'zerio-radio:client:open'
        }
    },

    ['jammer'] = {
        label = 'Radio Jammer',
        weight = 10000,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:usejammer'
        }
    },

    ['radiocell'] = {
        label = 'AAA Cells',
        weight = 1000,
        stack = true,
        allowArmed = true,
        client = {
            event = 'mm_radio:client:recharge'
        }
    },

    ['advancedlockpick'] = {
        label = 'Advanced Lockpick',
        weight = 500,
    },

    ['screwdriverset'] = {
        label = 'Screwdriver Set',
        weight = 500,
    },

    ['electronickit'] = {
        label = 'Electronic Kit',
        weight = 500,
    },

    ['cleaningkit'] = {
        label = 'Cleaning Kit',
        weight = 500,
    },

    ['repairkit'] = {
        label = 'Repair Kit',
        weight = 2500,
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repair Kit',
        weight = 4000,
    },

    ['diamond_ring'] = {
        label = 'Diamond',
        weight = 1500,
    },

    ['rolex'] = {
        label = 'Golden Watch',
        weight = 1500,
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1500,
    },

    ['goldchain'] = {
        label = 'Golden Chain',
        weight = 1500,
    },

    ['crack_baggy'] = {
        label = 'Crack Baggy',
        weight = 100,
    },

    ['cokebaggy'] = {
        label = 'Bag of Coke',
        weight = 100,
    },

    ['coke_brick'] = {
        label = 'Coke Brick',
        weight = 2000,
    },

    ['coke_small_brick'] = {
        label = 'Coke Package',
        weight = 1000,
    },

    ['xtcbaggy'] = {
        label = 'Bag of Ecstasy',
        weight = 100,
    },

    ['meth'] = {
        label = 'Methamphetamine',
        weight = 100,
    },

    ['oxy'] = {
        label = 'Oxycodone',
        weight = 100,
    },

    ['weed_ak47'] = {
        label = 'AK47 2g',
        weight = 200,
    },

    ['weed_ak47_seed'] = {
        label = 'AK47 Seed',
        weight = 1,
    },

    ['weed_skunk'] = {
        label = 'Skunk 2g',
        weight = 200,
    },

    ['weed_skunk_seed'] = {
        label = 'Skunk Seed',
        weight = 1,
    },

    ['weed_amnesia'] = {
        label = 'Amnesia 2g',
        weight = 200,
    },

    ['weed_amnesia_seed'] = {
        label = 'Amnesia Seed',
        weight = 1,
    },

    ['weed_og-kush'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_og-kush_seed'] = {
        label = 'OGKush Seed',
        weight = 1,
    },

    ['weed_white-widow'] = {
        label = 'OGKush 2g',
        weight = 200,
    },

    ['weed_white-widow_seed'] = {
        label = 'White Widow Seed',
        weight = 1,
    },

    ['weed_purple-haze'] = {
        label = 'Purple Haze 2g',
        weight = 200,
    },

    ['weed_purple-haze_seed'] = {
        label = 'Purple Haze Seed',
        weight = 1,
    },

    ['weed_brick'] = {
        label = 'Weed Brick',
        weight = 2000,
    },

    ['weed_nutrition'] = {
        label = 'Plant Fertilizer',
        weight = 2000,
    },

    ['joint'] = {
        label = 'Joint',
        weight = 200,
    },

    ['rolling_paper'] = {
        label = 'Rolling Paper',
        weight = 0,
    },

    ['empty_weed_bag'] = {
        label = 'Empty Weed Bag',
        weight = 0,
    },

    ['firstaid'] = {
        label = 'First Aid',
        weight = 2500,
    },

    ['ifaks'] = {
        label = 'Individual First Aid Kit',
        weight = 2500,
    },

    ['painkillers'] = {
        label = 'Painkillers',
        weight = 400,
    },

    ['firework1'] = {
        label = '2Brothers',
        weight = 1000,
    },

    ['firework2'] = {
        label = 'Poppelers',
        weight = 1000,
    },

    ['firework3'] = {
        label = 'WipeOut',
        weight = 1000,
    },

    ['firework4'] = {
        label = 'Weeping Willow',
        weight = 1000,
    },

    ['steel'] = {
        label = 'Steel',
        weight = 100,
    },

    ['rubber'] = {
        label = 'Rubber',
        weight = 100,
    },

    ['metalscrap'] = {
        label = 'Metal Scrap',
        weight = 100,
    },

    ['iron'] = {
        label = 'Iron',
        weight = 100,
    },

    ['copper'] = {
        label = 'Copper',
        weight = 100,
    },

    ['aluminum'] = {
        label = 'Aluminium',
        weight = 100,
    },

    ['plastic'] = {
        label = 'Plastic',
        weight = 100,
    },

    ['glass'] = {
        label = 'Glass',
        weight = 100,
    },

    ['gatecrack'] = {
        label = 'Gatecrack',
        weight = 1000,
    },

    ['cryptostick'] = {
        label = 'Crypto Stick',
        weight = 100,
    },

    ['trojan_usb'] = {
        label = 'Trojan USB',
        weight = 100,
    },

    ['toaster'] = {
        label = 'Toaster',
        weight = 5000,
    },

    ['small_tv'] = {
        label = 'Small TV',
        weight = 100,
    },

    ['security_card_01'] = {
        label = 'Security Card A',
        weight = 100,
    },

    ['security_card_02'] = {
        label = 'Security Card B',
        weight = 100,
    },

    ['drill'] = {
        label = 'Drill',
        weight = 5000,
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
    },

    ['diving_gear'] = {
        label = 'Diving Gear',
        weight = 30000,
    },

    ['diving_fill'] = {
        label = 'Diving Tube',
        weight = 3000,
    },

    ['antipatharia_coral'] = {
        label = 'Antipatharia',
        weight = 1000,
    },

    ['dendrogyra_coral'] = {
        label = 'Dendrogyra',
        weight = 1000,
    },

    ['jerry_can'] = {
        label = 'Jerrycan',
        weight = 3000,
    },

    ['nitrous'] = {
        label = 'Nitrous',
        weight = 1000,
    },

    ['wine'] = {
        label = 'Wine',
        weight = 500,
    },

    ['grape'] = {
        label = 'Grape',
        weight = 10,
    },

    ['grapejuice'] = {
        label = 'Grape Juice',
        weight = 200,
    },

    ['coffee'] = {
        label = 'Coffee',
        weight = 200,
    },

    ['vodka'] = {
        label = 'Vodka',
        weight = 500,
    },

    ['whiskey'] = {
        label = 'Whiskey',
        weight = 200,
    },

    ['beer'] = {
        label = 'Beer',
        weight = 200,
    },

    ['sandwich'] = {
        label = 'Sandwich',
        weight = 200,
    },

    ['walking_stick'] = {
        label = 'Walking Stick',
        weight = 1000,
    },

    ['lighter'] = {
        label = 'Lighter',
        weight = 200,
    },

    ['binoculars'] = {
        label = 'Binoculars',
        weight = 800,
    },

    ['stickynote'] = {
        label = 'Sticky Note',
        weight = 0,
    },

    ['empty_evidence_bag'] = {
        label = 'Empty Evidence Bag',
        weight = 200,
    },

    ['filled_evidence_bag'] = {
        label = 'Filled Evidence Bag',
        weight = 200,
    },

    ['harness'] = {
        label = 'Harness',
        weight = 200,
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    -- rcore_police items
    ['megaphone'] = {
        label = 'Megaphone',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['barrier'] = {
        label = 'Barricade',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['handcuffs_key'] = {
        label = 'Keys',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['spikes'] = {
        label = 'Spikes',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['speed_camera'] = {
        label = 'Speed camera',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['zipties'] = {
        label = 'Zip ties',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['paper_bag_rcore'] = {
        label = 'Paper Bag',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['panic_button'] = {
        label = 'Panic Button',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['zipties_cutter'] = {
        label = 'Zipties cutter',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['bodycam'] = {
        label = 'Bodycam',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['bodycam_tablet'] = {
        label = 'Bodycam tablet',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
    },

    ['photo'] = {
        label = 'Photo',
        weight = 100,
        stack = false,
        close = true,
        consume = 0,
    },

    -- ['camera'] = {
    --     label = 'Camera',
    --     weight = 100,
    --     stack = true,
    --     close = true,
    --     consume = 0,
    --     -- DISABLED: Using r14-evidence 'nikon' camera instead
    -- },

    ['wheel_clamp'] = {
        label = 'Wheel Clamp',
        weight = 1,
        stack = true,
        close = true,
    },

    ['wheel_clamp_wrench'] = {
        label = 'Wheel Clamp Wrench',
        weight = 1,
        stack = true,
        close = true,
    },

    -- Enhanced Police Equipment Items
    ['police_shield'] = {
        label = 'Police Shield',
        weight = 2500,
        stack = true,
        close = true,
        consume = 0,
        description = "Tactical police shield for protection"
    },

    ['police_bodycam'] = {
        label = 'Bodycam',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
        description = "Police body-worn camera for evidence collection"
    },

    ['police_snakecam'] = {
        label = 'Snake Camera',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
        description = "Flexible camera for surveillance and search operations"
    },

    ['police_panic'] = {
        label = 'Panic Button',
        weight = 50,
        stack = true,
        close = true,
        consume = 0,
        description = "Emergency panic button for officers in distress",
        client = {
            export = 'tugamars-police_tools.OpenPager',
        }
    },

    ['filled_evidence_bag'] = {
        label = 'Collected Evidence',
        weight = 0,
        stack = false,
        close = true,
        consume = 0,
        description = 'This is police evidence.',
        server = {export = 'r14-evidence.filled_evidence_bag'},
    },

    ['empty_evidence_bag'] = {
        label = 'Evidence Bag',
        weight = 0,
        stack = true,
        close = true,
        consume = 1,
        description = 'An empty evidence bag for collecting evidence.'
    },

    ['nikon'] = {
        consume = 0,
        label = 'Nikoff G600',
        weight = 500,
        stack = false,
        description = 'Caught in 4k',
        server = {export = 'r14-evidence.nikon'},
    },

    ['sdcard'] = {
        consume = 0,
        label = 'SD Card',
        weight = 100,
        stack = false,
        description = 'People still use these??',
        server = {export = 'r14-evidence.sdcard'},
    },

    ['tgm_police_tools-tactical-door-wedge'] = {
        label = 'Door Wedge',
        description = 'The tactical solution to block a door',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
        client = {
            export = 'tugamars-police_tools.tactical-door-wedge',
        }
    },

    ['handcuffs'] = {
        label = 'Handcuffs',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
        description = 'Standard police handcuffs for restraining suspects'
    },

    ['drone1'] = {
        label = "Police Drone",
        weight = 10,
        image = "drone1.png",
        stack = false,
        close = true,
        consume = 0,
        server = { export = 'policedrone.OxUseDrone' },
        description = "A police surveillance drone for aerial reconnaissance"
    },

    ['tracker_dart'] = {
        label = 'Tracker Cartridge',
        weight = 220,
        stack = true,
        close = true,
        consume = 0,
        description = 'GPS tracking dart for vehicle pursuit',
        server = {
            export = 'policetracker.OxUseTrackerDart',
        },
    },

    ['tracker'] = {
        label = 'GPS Tracker',
        weight = 220,
        stack = true,
        close = true,
        consume = 0,
        description = 'Portable GPS tracking device',
        server = {
            export = 'policetracker.OxUseTracker',
        },
    },

    ['radio'] = {
        label = 'Police Radio',
        weight = 500,
        stack = false,
        close = true,
        consume = 0,
        description = 'Standard police communication radio'
    },

    ['police_stormram'] = {
        label = 'Battering Ram',
        weight = 8000,
        stack = false,
        close = true,
        consume = 0,
        description = 'Heavy-duty door breaching tool'
    },

    ['armor'] = {
        label = 'Body Armor',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
        description = 'Ballistic protection vest'
    },

    ['nikkit'] = {
        label = 'NIK Drug Test Kit',
        weight = 100,
        stack = true,
        close = true,
        consume = 0,
        description = 'Field drug testing kit for substance identification'
    },

    ['policepouches'] = {
        label = "Police Pouch",
        weight = 5,
        stack = false,
        close = true,
        consume = 0,
        description = "A pouch used by police officers to store and carry essential supplies such as handcuffs, pepper spray, and other tactical equipment."
    },

    ['policepouches1'] = {
        label = "Police Pouch",
        weight = 5,
        stack = false,
        close = true,
        consume = 0,
        description = "Standard police utility pouch"
    },

    -- Additional Barrier Types
    ['sand_block1'] = {
        label = 'Sand Barricade',
        description = 'A police barricade to close off entry.',
        image = 'barricade.png',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['sand_block2'] = {
        label = 'Sand Barricade 2',
        description = 'A police barricade to close off entry.',
        image = 'barricade.png',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['sand_block3'] = {
        label = 'Sand Barricade 3',
        description = 'A police barricade to close off entry.',
        image = 'barricade.png',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['sand_block4'] = {
        label = 'Sand Barricade 4',
        description = 'A police barricade to close off entry.',
        image = 'barricade.png',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['sand_block5'] = {
        label = 'Sand Barricade 5',
        description = 'A police barricade to close off entry.',
        image = 'barricade.png',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['hesco_barrier'] = {
        label = 'Hesco Barrier',
        description = 'A military-grade defensive barrier.',
        image = 'barricade.png',
        weight = 7500,
        stack = false,
        close = true,
        consume = 1,
    },

    ['roadblock'] = {
        label = 'Road Block',
        description = 'A large sign to block off a road.',
        image = 'roadblock.png',
        weight = 10000,
        stack = false,
        close = true,
        consume = 1,
    },

    -- R14-Objects Items
    ['cone'] = {
        label = 'Traffic Cone',
        weight = 2000,
        stack = true,
        close = true,
        consume = 1,
    },

    ['barricade'] = {
        label = 'Barricade',
        weight = 5000,
        stack = true,
        close = true,
        consume = 1,
    },

    ['roadblock'] = {
        label = 'Roadblock',
        weight = 3000,
        stack = true,
        close = true,
        consume = 1,
    },

    ['spikestrip'] = {
        label = 'Spike Strip',
        weight = 2500,
        stack = true,
        close = true,
        consume = 1,
    },

    ['stoppedvehicles'] = {
        label = 'Caution Sign',
        weight = 1500,
        stack = true,
        close = true,
        consume = 1,
    },

    ['tent'] = {
        label = 'Canopy',
        weight = 8000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['campfire'] = {
        label = 'Campfire',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['camptent'] = {
        label = 'Small Tent',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['camptent2'] = {
        label = 'Small Tent Style 2',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['camptent3'] = {
        label = 'Large Tent',
        weight = 7000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['camptent4'] = {
        label = 'Large Tent Style 2',
        weight = 7000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['picnictable'] = {
        label = 'Picnic Table',
        weight = 12000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['foldingtable'] = {
        label = 'Folding Table',
        weight = 8000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['umbrella'] = {
        label = 'Beach Umbrella',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['umbrella2'] = {
        label = 'Beach Umbrella Style 2',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['umbrella3'] = {
        label = 'Beach Umbrella Style 3',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['beachtowel'] = {
        label = 'Beach Towel',
        weight = 500,
        stack = true,
        close = true,
        consume = 1,
    },

    ['foldingchair'] = {
        label = 'Folding Chair',
        weight = 2000,
        stack = true,
        close = true,
        consume = 1,
    },

    ['foldingchair2'] = {
        label = 'Folding Chair Style 2',
        weight = 2000,
        stack = true,
        close = true,
        consume = 1,
    },

    ['monobloc'] = {
        label = 'Plastic Chair',
        weight = 1500,
        stack = true,
        close = true,
        consume = 1,
    },

    ['boombox'] = {
        label = 'Boombox',
        weight = 4000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['miniradio'] = {
        label = 'Mini Radio',
        weight = 1000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['cdplayer'] = {
        label = 'CD Player',
        weight = 2000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['light'] = {
        label = 'Mobile Lighting',
        weight = 6000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['generator'] = {
        label = 'Generator',
        weight = 15000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['cooler'] = {
        label = 'Cooler',
        weight = 8000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['medbag'] = {
        label = 'Medical Bag',
        weight = 5000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['bbq'] = {
        label = 'Grill',
        weight = 12000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['bomb'] = {
        label = 'Bomb',
        weight = 3000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['storage_container'] = {
        label = 'Storage Container',
        weight = 50000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['garage_container'] = {
        label = 'Vehicle Storage Container',
        weight = 50000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['gunrepair_container'] = {
        label = 'Firearm Repair Container',
        weight = 50000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['largesafe'] = {
        label = 'Large Safe',
        weight = 25000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['smallsafe'] = {
        label = 'Small Safe',
        weight = 15000,
        stack = false,
        close = true,
        consume = 1,
    },

    ['storagecontract'] = {
        label = 'Storage Contract',
        weight = 100,
        stack = false,
        close = true,
        consume = 1,
    },

    ['diffusedbomb'] = {
        label = 'Diffused Bomb',
        weight = 3000,
        stack = false,
        close = true,
        consume = 0,
    },

    -- Medical Items for Hospital Armory
    ['radio'] = {
        label = 'Radio',
        weight = 200,
        stack = false,
        close = true,
        consume = 0,
        client = {
            event = 'zerio-radio:client:open'
        }
    },

    ['pager'] = {
        label = 'Pager',
        weight = 100,
    },

    ['ecg'] = {
        label = 'ECG',
        weight = 500,
        client = {
            target = {
                {
                    label = 'Use ECG Device',
                    icon = 'fas fa-heartbeat',
                    distance = 2.0,
                    canInteract = function(entity, distance, coords, name)
                        return IsPedAPlayer(entity) and entity ~= cache.ped
                    end,
                    onSelect = function(data)
                        TriggerServerEvent('osp_ambulance:activate')
                    end
                }
            }
        }
    },

    ['tourniquet'] = {
        label = 'Tourniquet',
        weight = 50,
    },

    ['field_dressing'] = {
        label = 'Field Dressing',
        weight = 25,
    },

    ['elastic_bandage'] = {
        label = 'Elastic Bandage',
        weight = 30,
    },

    ['quick_clot'] = {
        label = 'Quick Clot',
        weight = 40,
    },

    ['packing_bandage'] = {
        label = 'Packing Bandage',
        weight = 35,
    },

    ['sewing_kit'] = {
        label = 'Sewing Kit',
        weight = 150,
    },

    ['epinephrine'] = {
        label = 'Epinephrine',
        weight = 20,
    },

    ['morphine'] = {
        label = 'Morphine',
        weight = 25,
    },

    ['propofol'] = {
        label = 'Propofol',
        weight = 30,
    },

    ['blood250ml'] = {
        label = 'Blood Pack 250ml',
        weight = 300,
    },

    ['blood500ml'] = {
        label = 'Blood Pack 500ml',
        weight = 550,
    },

    ['saline250ml'] = {
        label = 'Saline 250ml',
        weight = 280,
    },

    ['saline500ml'] = {
        label = 'Saline 500ml',
        weight = 520,
    },

    ['stretcher'] = {
        label = 'Stretcher',
        weight = 5000,
        stack = false,
    },

    ['wheelchair'] = {
        label = 'Wheelchair',
        weight = 8000,
        stack = false,
    },

    ['crutch'] = {
        label = 'Crutch',
        weight = 800,
        stack = false,
    },

    ['ifak'] = {
        label = 'IFAK',
        weight = 400,
    },

    ['revivekit'] = {
        label = 'Revive Kit',
        weight = 600,
    },

    ['legsplint'] = {
        label = 'Leg Splint',
        weight = 300,
    },

    ['legcast'] = {
        label = 'Leg Cast',
        weight = 500,
    },

    ['armsplint'] = {
        label = 'Arm Splint',
        weight = 250,
    },

    ['armcast'] = {
        label = 'Arm Cast',
        weight = 400,
    },

    ['neckbrace'] = {
        label = 'Neck Brace',
        weight = 200,
    },

    ['neckcast'] = {
        label = 'Neck Cast',
        weight = 350,
    },

    ['castsaw'] = {
        label = 'Cast Saw',
        weight = 1200,
        stack = false,
    },

    -- Pug Robbery Creator Items
    ['lockpick'] = {
        label = 'Lockpick',
        weight = 160,
        stack = true,
        close = true,
        description = 'A small tool used to pick locks',
        client = {
            image = 'lockpick.png',
        }
    },

    ['thermite'] = {
        label = 'Thermite',
        weight = 1000,
        stack = true,
        close = true,
        description = 'A highly reactive chemical mixture',
        client = {
            image = 'thermite.png',
        }
    },

    ['drill'] = {
        label = 'Drill',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A powerful drilling tool',
        client = {
            image = 'drill.png',
        }
    },

    ['laptop'] = {
        label = 'Laptop',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A portable computer for hacking',
        client = {
            image = 'laptop.png',
        }
    },

    ['usb'] = {
        label = 'USB Drive',
        weight = 50,
        stack = true,
        close = true,
        description = 'A small storage device',
        client = {
            image = 'usb.png',
        }
    },

    ['bag'] = {
        label = 'Money Bag',
        weight = 200,
        stack = true,
        close = true,
        description = 'A bag for carrying money',
        client = {
            image = 'bag.png',
        }
    },

    ['goldbar'] = {
        label = 'Gold Bar',
        weight = 1000,
        stack = true,
        close = true,
        description = 'A valuable gold bar',
        client = {
            image = 'goldbar.png',
        }
    },

    ['diamond'] = {
        label = 'Diamond',
        weight = 100,
        stack = true,
        close = true,
        description = 'A precious diamond',
        client = {
            image = 'diamond.png',
        }
    },

    ['rolex'] = {
        label = 'Rolex Watch',
        weight = 200,
        stack = true,
        close = true,
        description = 'An expensive watch',
        client = {
            image = 'rolex.png',
        }
    },

    ['necklace'] = {
        label = 'Necklace',
        weight = 150,
        stack = true,
        close = true,
        description = 'A valuable necklace',
        client = {
            image = 'necklace.png',
        }
    },

    ['ring'] = {
        label = 'Ring',
        weight = 50,
        stack = true,
        close = true,
        description = 'A valuable ring',
        client = {
            image = 'ring.png',
        }
    },

    ['earrings'] = {
        label = 'Earrings',
        weight = 30,
        stack = true,
        close = true,
        description = 'Valuable earrings',
        client = {
            image = 'earrings.png',
        }
    },

    ['c4'] = {
        label = 'C4 Explosive',
        weight = 1000,
        stack = true,
        close = true,
        description = 'A powerful explosive device',
        client = {
            image = 'c4.png',
        }
    },

    ['detonator'] = {
        label = 'Detonator',
        weight = 200,
        stack = true,
        close = true,
        description = 'A device to detonate explosives',
        client = {
            image = 'detonator.png',
        }
    },

    ['keycard'] = {
        label = 'Keycard',
        weight = 10,
        stack = true,
        close = true,
        description = 'A security keycard',
        client = {
            image = 'keycard.png',
        }
    },

    ['sticky_note'] = {
        label = 'Sticky Note',
        weight = 5,
        stack = true,
        close = true,
        description = 'A small note with information',
        client = {
            image = 'sticky_note.png',
        }
    },

    ['crowbar'] = {
        label = 'Crowbar',
        weight = 1000,
        stack = false,
        close = true,
        description = 'A metal bar used for prying',
        client = {
            image = 'crowbar.png',
        }
    },

    ['sledgehammer'] = {
        label = 'Sledgehammer',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A heavy hammer for breaking things',
        client = {
            image = 'sledgehammer.png',
        }
    },

    ['cutting_torch'] = {
        label = 'Cutting Torch',
        weight = 1500,
        stack = false,
        close = true,
        description = 'A torch for cutting metal',
        client = {
            image = 'cutting_torch.png',
        }
    },

    ['safe_cracker'] = {
        label = 'Safe Cracker',
        weight = 500,
        stack = false,
        close = true,
        description = 'A device for cracking safes',
        client = {
            image = 'safe_cracker.png',
        }
    },

    ['money'] = {
        label = 'Money',
        weight = 0,
        stack = true,
        close = true,
        description = 'Cash money',
        client = {
            image = 'money.png',
        }
    },

    -- Drugs Creator Items
    -- Harvestable Items
    ['codeine'] = {
        label = 'Codeine',
        weight = 50,
        stack = true,
        close = true,
        description = 'A pharmaceutical drug',
        client = {
            image = 'codeine.png',
        }
    },

    ['liquid_sulfur'] = {
        label = 'Liquid Sulfur',
        weight = 100,
        stack = true,
        close = true,
        description = 'A chemical compound',
        client = {
            image = 'liquid_sulfur.png',
        }
    },

    ['ammonium_nitrate'] = {
        label = 'Ammonium Nitrate',
        weight = 80,
        stack = true,
        close = true,
        description = 'A chemical compound',
        client = {
            image = 'ammonium_nitrate.png',
        }
    },

    ['sodium_hydroxide'] = {
        label = 'Sodium Hydroxide',
        weight = 60,
        stack = true,
        close = true,
        description = 'A chemical compound',
        client = {
            image = 'sodium_hydroxide.png',
        }
    },

    ['pseudoefedrine'] = {
        label = 'Pseudoefedrine',
        weight = 40,
        stack = true,
        close = true,
        description = 'A pharmaceutical drug',
        client = {
            image = 'pseudoefedrine.png',
        }
    },

    ['carbon'] = {
        label = 'Carbon',
        weight = 30,
        stack = true,
        close = true,
        description = 'A chemical element',
        client = {
            image = 'carbon.png',
        }
    },

    ['hydrogen'] = {
        label = 'Hydrogen',
        weight = 20,
        stack = true,
        close = true,
        description = 'A chemical element',
        client = {
            image = 'hydrogen.png',
        }
    },

    ['nitrogen'] = {
        label = 'Nitrogen',
        weight = 25,
        stack = true,
        close = true,
        description = 'A chemical element',
        client = {
            image = 'nitrogen.png',
        }
    },

    ['oxygen'] = {
        label = 'Oxygen',
        weight = 25,
        stack = true,
        close = true,
        description = 'A chemical element',
        client = {
            image = 'oxygen.png',
        }
    },

    -- Crafting Ingredients
    ['drink_sprite'] = {
        label = 'Sprite Drink',
        weight = 200,
        stack = true,
        close = true,
        description = 'A refreshing drink',
        client = {
            image = 'drink_sprite.png',
        }
    },

    ['jolly_ranchers'] = {
        label = 'Jolly Ranchers',
        weight = 10,
        stack = true,
        close = true,
        description = 'Sweet candy',
        client = {
            image = 'jolly_ranchers.png',
        }
    },

    ['ice'] = {
        label = 'Ice',
        weight = 5,
        stack = true,
        close = true,
        description = 'Frozen water',
        client = {
            image = 'ice.png',
        }
    },

    ['red_sulfur'] = {
        label = 'Red Sulfur',
        weight = 70,
        stack = true,
        close = true,
        description = 'A chemical compound',
        client = {
            image = 'red_sulfur.png',
        }
    },

    ['muriatic_acid'] = {
        label = 'Muriatic Acid',
        weight = 90,
        stack = true,
        close = true,
        description = 'A strong acid',
        client = {
            image = 'muriatic_acid.png',
        }
    },

    ['water'] = {
        label = 'Water',
        weight = 10,
        stack = true,
        close = true,
        description = 'Clean water',
        client = {
            image = 'water.png',
        }
    },

    -- Final Drug Products
    ['drug_lean'] = {
        label = 'Lean',
        weight = 100,
        stack = true,
        close = true,
        description = 'A purple drink',
        client = {
            image = 'drug_lean.png',
        }
    },

    ['drug_meth'] = {
        label = 'Methamphetamine',
        weight = 50,
        stack = true,
        close = true,
        description = 'A dangerous drug',
        client = {
            image = 'drug_meth.png',
        }
    },

    ['drug_ecstasy'] = {
        label = 'Ecstasy',
        weight = 30,
        stack = true,
        close = true,
        description = 'A party drug',
        client = {
            image = 'drug_ecstasy.png',
        }
    },

    ['drug_lsd'] = {
        label = 'LSD',
        weight = 20,
        stack = true,
        close = true,
        description = 'A hallucinogenic drug',
        client = {
            image = 'drug_lsd.png',
        }
    },

    -- Tools
    ['scale'] = {
        label = 'Scale',
        weight = 200,
        stack = false,
        close = true,
        description = 'A precision scale',
        client = {
            image = 'scale.png',
        }
    },

    ['shears'] = {
        label = 'Shears',
        weight = 300,
        stack = false,
        close = true,
        description = 'Cutting tool',
        client = {
            image = 'shears.png',
        }
    },

    -- Drugs Creator Field Items
    ['cannabis'] = {
        label = 'Cannabis',
        weight = 50,
        stack = true,
        close = true,
        description = 'Raw cannabis plant',
        client = {
            image = 'cannabis.png',
        }
    },

    ['green_gelato_cannabis'] = {
        label = 'Green Gelato Cannabis',
        weight = 50,
        stack = true,
        close = true,
        description = 'Premium cannabis strain',
        client = {
            image = 'green_gelato_cannabis.png',
        }
    },

    ['opium'] = {
        label = 'Opium',
        weight = 60,
        stack = true,
        close = true,
        description = 'Raw opium',
        client = {
            image = 'opium.png',
        }
    },

    ['cocaine'] = {
        label = 'Cocaine',
        weight = 40,
        stack = true,
        close = true,
        description = 'Raw cocaine',
        client = {
            image = 'cocaine.png',
        }
    },

    -- ============================================
    -- ADVANCED MINING JOB ITEMS
    -- ============================================
    ['pickaxe'] = {
        label = 'Pickaxe',
        weight = 2000,
        stack = false,
        close = true,
        description = 'A sturdy pickaxe for mining ores',
        client = {
            image = 'pickaxe.png',
        }
    },

    ['iron_ore'] = {
        label = 'Iron Ore',
        weight = 500,
        stack = true,
        close = true,
        description = 'Raw iron ore',
        client = {
            image = 'iron_ore.png',
        }
    },

    ['copper_ore'] = {
        label = 'Copper Ore',
        weight = 500,
        stack = true,
        close = true,
        description = 'Raw copper ore',
        client = {
            image = 'copper_ore.png',
        }
    },

    ['gold_ore'] = {
        label = 'Gold Ore',
        weight = 600,
        stack = true,
        close = true,
        description = 'Raw gold ore',
        client = {
            image = 'gold_ore.png',
        }
    },

    ['silver_ore'] = {
        label = 'Silver Ore',
        weight = 550,
        stack = true,
        close = true,
        description = 'Raw silver ore',
        client = {
            image = 'silver_ore.png',
        }
    },

    ['diamond_ore'] = {
        label = 'Diamond Ore',
        weight = 400,
        stack = true,
        close = true,
        description = 'Raw diamond ore',
        client = {
            image = 'diamond_ore.png',
        }
    },

    ['coal'] = {
        label = 'Coal',
        weight = 300,
        stack = true,
        close = true,
        description = 'Raw coal',
        client = {
            image = 'coal.png',
        }
    },

    ['stone'] = {
        label = 'Stone',
        weight = 200,
        stack = true,
        close = true,
        description = 'Raw stone',
        client = {
            image = 'stone.png',
        }
    },

    ['iron_ingot'] = {
        label = 'Iron Ingot',
        weight = 800,
        stack = true,
        close = true,
        description = 'Refined iron ingot',
        client = {
            image = 'iron_ingot.png',
        }
    },

    ['copper_ingot'] = {
        label = 'Copper Ingot',
        weight = 750,
        stack = true,
        close = true,
        description = 'Refined copper ingot',
        client = {
            image = 'copper_ingot.png',
        }
    },

    ['gold_ingot'] = {
        label = 'Gold Ingot',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Refined gold ingot',
        client = {
            image = 'gold_ingot.png',
        }
    },

    ['silver_ingot'] = {
        label = 'Silver Ingot',
        weight = 900,
        stack = true,
        close = true,
        description = 'Refined silver ingot',
        client = {
            image = 'silver_ingot.png',
        }
    },

    ['diamond'] = {
        label = 'Diamond',
        weight = 200,
        stack = true,
        close = true,
        description = 'Refined diamond',
        client = {
            image = 'diamond.png',
        }
    },

    ['refined_coal'] = {
        label = 'Refined Coal',
        weight = 400,
        stack = true,
        close = true,
        description = 'Refined coal',
        client = {
            image = 'refined_coal.png',
        }
    },

    -- ============================================
    -- ADVANCED FISHING JOB ITEMS
    -- ============================================
    ['fishingrod'] = {
        label = 'Fishing Rod',
        weight = 1500,
        stack = false,
        close = true,
        description = 'A fishing rod for catching fish',
        client = {
            image = 'fishingrod.png',
        }
    },

    ['fishingbait'] = {
        label = 'Fishing Bait',
        weight = 50,
        stack = true,
        close = true,
        description = 'Bait for fishing',
        client = {
            image = 'fishingbait.png',
        }
    },

    ['tuna'] = {
        label = 'Tuna',
        weight = 3000,
        stack = true,
        close = true,
        description = 'Fresh tuna',
        client = {
            image = 'tuna.png',
        }
    },

    ['salmon'] = {
        label = 'Salmon',
        weight = 2500,
        stack = true,
        close = true,
        description = 'Fresh salmon',
        client = {
            image = 'salmon.png',
        }
    },

    ['cod'] = {
        label = 'Cod',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Fresh cod',
        client = {
            image = 'cod.png',
        }
    },

    ['bass'] = {
        label = 'Bass',
        weight = 1800,
        stack = true,
        close = true,
        description = 'Fresh bass',
        client = {
            image = 'bass.png',
        }
    },

    ['mackerel'] = {
        label = 'Mackerel',
        weight = 1500,
        stack = true,
        close = true,
        description = 'Fresh mackerel',
        client = {
            image = 'mackerel.png',
        }
    },

    ['trout'] = {
        label = 'Trout',
        weight = 1200,
        stack = true,
        close = true,
        description = 'Fresh trout',
        client = {
            image = 'trout.png',
        }
    },

    ['perch'] = {
        label = 'Perch',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Fresh perch',
        client = {
            image = 'perch.png',
        }
    },

    ['pike'] = {
        label = 'Pike',
        weight = 2200,
        stack = true,
        close = true,
        description = 'Fresh pike',
        client = {
            image = 'pike.png',
        }
    },

    ['catfish'] = {
        label = 'Catfish',
        weight = 2800,
        stack = true,
        close = true,
        description = 'Fresh catfish',
        client = {
            image = 'catfish.png',
        }
    },

    ['carp'] = {
        label = 'Carp',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Fresh carp',
        client = {
            image = 'carp.png',
        }
    },

    ['sea_bass'] = {
        label = 'Sea Bass',
        weight = 3200,
        stack = true,
        close = true,
        description = 'Fresh sea bass',
        client = {
            image = 'sea_bass.png',
        }
    },

    ['tuna_fillet'] = {
        label = 'Tuna Fillet',
        weight = 1500,
        stack = true,
        close = true,
        description = 'Processed tuna fillet',
        client = {
            image = 'tuna_fillet.png',
        }
    },

    ['salmon_fillet'] = {
        label = 'Salmon Fillet',
        weight = 1200,
        stack = true,
        close = true,
        description = 'Processed salmon fillet',
        client = {
            image = 'salmon_fillet.png',
        }
    },

    ['cod_fillet'] = {
        label = 'Cod Fillet',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Processed cod fillet',
        client = {
            image = 'cod_fillet.png',
        }
    },

    ['bass_fillet'] = {
        label = 'Bass Fillet',
        weight = 900,
        stack = true,
        close = true,
        description = 'Processed bass fillet',
        client = {
            image = 'bass_fillet.png',
        }
    },

    ['mackerel_fillet'] = {
        label = 'Mackerel Fillet',
        weight = 750,
        stack = true,
        close = true,
        description = 'Processed mackerel fillet',
        client = {
            image = 'mackerel_fillet.png',
        }
    },

    -- ============================================
    -- ADVANCED FARMING JOB ITEMS
    -- ============================================
    ['shovel'] = {
        label = 'Shovel',
        weight = 2500,
        stack = false,
        close = true,
        description = 'A shovel for farming',
        client = {
            image = 'shovel.png',
        }
    },

    ['watering_can'] = {
        label = 'Watering Can',
        weight = 1000,
        stack = false,
        close = true,
        description = 'A watering can for crops',
        client = {
            image = 'watering_can.png',
        }
    },

    ['wheat_seed'] = {
        label = 'Wheat Seeds',
        weight = 10,
        stack = true,
        close = true,
        description = 'Seeds for planting wheat',
        client = {
            image = 'wheat_seed.png',
        }
    },

    ['corn_seed'] = {
        label = 'Corn Seeds',
        weight = 15,
        stack = true,
        close = true,
        description = 'Seeds for planting corn',
        client = {
            image = 'corn_seed.png',
        }
    },

    ['tomato_seed'] = {
        label = 'Tomato Seeds',
        weight = 5,
        stack = true,
        close = true,
        description = 'Seeds for planting tomatoes',
        client = {
            image = 'tomato_seed.png',
        }
    },

    ['carrot_seed'] = {
        label = 'Carrot Seeds',
        weight = 5,
        stack = true,
        close = true,
        description = 'Seeds for planting carrots',
        client = {
            image = 'carrot_seed.png',
        }
    },

    ['potato_seed'] = {
        label = 'Potato Seeds',
        weight = 20,
        stack = true,
        close = true,
        description = 'Seeds for planting potatoes',
        client = {
            image = 'potato_seed.png',
        }
    },

    ['strawberry_seed'] = {
        label = 'Strawberry Seeds',
        weight = 3,
        stack = true,
        close = true,
        description = 'Seeds for planting strawberries',
        client = {
            image = 'strawberry_seed.png',
        }
    },

    ['wheat'] = {
        label = 'Wheat',
        weight = 200,
        stack = true,
        close = true,
        description = 'Harvested wheat',
        client = {
            image = 'wheat.png',
        }
    },

    ['corn'] = {
        label = 'Corn',
        weight = 300,
        stack = true,
        close = true,
        description = 'Harvested corn',
        client = {
            image = 'corn.png',
        }
    },

    ['tomato'] = {
        label = 'Tomato',
        weight = 100,
        stack = true,
        close = true,
        description = 'Fresh tomato',
        client = {
            image = 'tomato.png',
        }
    },

    ['carrot'] = {
        label = 'Carrot',
        weight = 80,
        stack = true,
        close = true,
        description = 'Fresh carrot',
        client = {
            image = 'carrot.png',
        }
    },

    ['potato'] = {
        label = 'Potato',
        weight = 150,
        stack = true,
        close = true,
        description = 'Fresh potato',
        client = {
            image = 'potato.png',
        }
    },

    ['strawberry'] = {
        label = 'Strawberry',
        weight = 20,
        stack = true,
        close = true,
        description = 'Fresh strawberry',
        client = {
            image = 'strawberry.png',
        }
    },

    ['animal_feed'] = {
        label = 'Animal Feed',
        weight = 500,
        stack = true,
        close = true,
        description = 'Feed for farm animals',
        client = {
            image = 'animal_feed.png',
        }
    },

    ['milk'] = {
        label = 'Milk',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Fresh milk from cows',
        client = {
            image = 'milk.png',
        }
    },

    ['eggs'] = {
        label = 'Eggs',
        weight = 50,
        stack = true,
        close = true,
        description = 'Fresh eggs from chickens',
        client = {
            image = 'eggs.png',
        }
    },

    ['pork'] = {
        label = 'Pork',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Fresh pork',
        client = {
            image = 'pork.png',
        }
    },

    ['wool'] = {
        label = 'Wool',
        weight = 300,
        stack = true,
        close = true,
        description = 'Wool from sheep',
        client = {
            image = 'wool.png',
        }
    },

    ['goat_milk'] = {
        label = 'Goat Milk',
        weight = 800,
        stack = true,
        close = true,
        description = 'Fresh goat milk',
        client = {
            image = 'goat_milk.png',
        }
    },

    ['flour'] = {
        label = 'Flour',
        weight = 500,
        stack = true,
        close = true,
        description = 'Processed flour from wheat',
        client = {
            image = 'flour.png',
        }
    },

    ['cheese'] = {
        label = 'Cheese',
        weight = 600,
        stack = true,
        close = true,
        description = 'Processed cheese from milk',
        client = {
            image = 'cheese.png',
        }
    },

    ['egg_carton'] = {
        label = 'Egg Carton',
        weight = 200,
        stack = true,
        close = true,
        description = 'Carton of processed eggs',
        client = {
            image = 'egg_carton.png',
        }
    },

    ['bacon'] = {
        label = 'Bacon',
        weight = 800,
        stack = true,
        close = true,
        description = 'Processed bacon from pork',
        client = {
            image = 'bacon.png',
        }
    },

    ['yarn'] = {
        label = 'Yarn',
        weight = 200,
        stack = true,
        close = true,
        description = 'Processed yarn from wool',
        client = {
            image = 'yarn.png',
        }
    },

    ['casino_chip'] = {
        label = 'Betting Chips',
        weight = 3,
        stack = true,
        close = false,
        description = 'Diamond Casino Chips',
        client = {
            image = 'casino_chip.png',
        }
    },

    ['casinochips'] = {
        label = 'Casino Chips',
        weight = 3,
        stack = true,
        close = false,
        description = 'Diamond Casino Chips',
        client = {
            image = 'casino_chip.png',
        }
    },

    ['casino_chips'] = {
        label = 'Casino Chips',
        weight = 3,
        stack = true,
        close = false,
        description = 'Diamond Casino Chips',
        client = {
            image = 'casino_chips.png',
        }
    },

    ['casino_gumball'] = {
        label = 'Gumball',
        weight = 100,
        stack = true,
        close = true,
        description = 'A shiny gumball',
        client = {
            image = 'casino_gumball.png',
        }
    },

    ['casino_member'] = {
        label = 'Member Card',
        weight = 50,
        stack = false,
        close = false,
        description = 'Diamond Casino Membership Card',
        client = {
            image = 'casino_member.png',
        }
    },

    ['casino_vip'] = {
        label = 'V.I.P Pass',
        weight = 70,
        stack = false,
        close = false,
        description = 'Diamond Casino V.I.P ALL ACCESS Pass',
        client = {
            image = 'casino_vip.png',
        }
    },

    -- ============================================
    -- CRAFTING SYSTEM
    -- ============================================
    ['ironoxide'] = {
        label = 'Iron Oxide',
        weight = 100,
        stack = true,
        close = true,
        description = 'Iron oxide compound used in crafting',
        client = {
            image = 'ironoxide.png',
        }
    },

    ['aluminumoxide'] = {
        label = 'Aluminum Oxide',
        weight = 100,
        stack = true,
        close = true,
        description = 'Aluminum oxide compound used in crafting',
        client = {
            image = 'aluminumoxide.png',
        }
    },

    ['heavyarmor'] = {
        label = 'Heavy Armor',
        weight = 5000,
        stack = false,
        close = true,
        description = 'Heavy protective armor',
        client = {
            image = 'heavyarmor.png',
        }
    },

    ['radioscanner'] = {
        label = 'Radio Scanner',
        weight = 500,
        stack = false,
        close = true,
        description = 'A device for scanning radio frequencies',
        client = {
            image = 'radioscanner.png',
        }
    },

 ['surfboard'] = {
        label = 'surfboard',
        weight = 3000,
        stack = false,
        close = true,
        description = 'a surfboard',
        client = {
            image = 'surfboard.png',
        }
    },


    ['smg_ammo'] = {
        label = 'SMG Ammunition',
        weight = 20,
        stack = true,
        close = true,
        description = 'Ammunition for SMG weapons',
        client = {
            image = 'smg_ammo.png',
        }
    },



    ['spraycan'] = {
        label = 'Spray Can',
        weight = 1,
        stack = true,
        close = false,
    },

    ['sprayremover'] = {
        label = 'Spray Remover',
        weight = 1,
        stack = true,
        close = false,
    },


    -- ============================================
    -- JG MECHANIC ITEMS
    -- ============================================
    ['engine_oil'] = {
        label = 'Engine Oil',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Engine oil for vehicle maintenance',
        client = {
            image = 'engine_oil.png',
        }
    },
    ['tyre_replacement'] = {
        label = 'Tyre Replacement',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Replacement tyres for vehicles',
        client = {
            image = 'tyre_replacement.png',
        }
    },
    ['clutch_replacement'] = {
        label = 'Clutch Replacement',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Replacement clutch for vehicles',
        client = {
            image = 'clutch_replacement.png',
        }
    },
    ['air_filter'] = {
        label = 'Air Filter',
        weight = 100,
        stack = true,
        close = true,
        description = 'Air filter for vehicle engines',
        client = {
            image = 'air_filter.png',
        }
    },
    ['spark_plug'] = {
        label = 'Spark Plug',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Spark plugs for vehicle engines',
        client = {
            image = 'spark_plug.png',
        }
    },
    ['suspension_parts'] = {
        label = 'Suspension Parts',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Suspension components for vehicles',
        client = {
            image = 'suspension_parts.png',
        }
    },
    ['brakepad_replacement'] = {
        label = 'Brakepad Replacement',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Replacement brake pads for vehicles',
        client = {
            image = 'brakepad_replacement.png',
        }
    },
    ['turbocharger'] = {
        label = 'Turbo Charger',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Turbocharger for vehicle performance upgrades',
        client = {
            image = 'turbocharger.png',
        }
    },
    ['v8_engine'] = {
        label = 'V8 Engine Upgrade',
        weight = 1000,
        stack = true,
        close = true,
        description = 'V8 engine upgrade for vehicles',
        client = {
            image = 'v8_engine.png',
        }
    },
    ['ceramic_brakes'] = {
        label = 'Ceramic Brakes',
        weight = 1000,
        stack = true,
        close = true,
        description = 'High-performance ceramic brake system',
        client = {
            image = 'ceramic_brakes.png',
        }
    },
    ['mechanic_tablet'] = {
        label = 'Mechanic Tablet',
        weight = 1000,
        stack = false,
        close = true,
        description = 'Tablet for mechanic shop management',
        client = {
            image = 'mechanic_tablet.png',
            event = 'jg-mechanic:client:use-tablet',
        }
    },

    ['tablet'] = {
        label = 'LB Tablet',
        weight = 800,
        stack = false,
        close = true,
        description = 'Law enforcement tablet for MDT / LB-Tablet',
        client = {
            image = 'lb_tablet.png',
            event = 'tablet:toggleOpen',
        }
    },

    ['cosmetic_part'] = {
        label = 'Cosmetic Part',
        weight = 500,
        stack = true,
        close = true,
        description = 'Generic cosmetic part for vehicle appearance upgrades',
        client = { image = 'cosmetic_part.png' }
    },

    ['headlight_kit'] = {
        label = 'Headlight Kit',
        weight = 600,
        stack = true,
        close = true,
        description = 'Kit used to upgrade or replace vehicle headlights',
        client = { image = 'headlight_kit.png' }
    },

    -- Additional tuning items for TM mechanic
    ['i4_engine'] = {
        label = 'I4 Engine',
        weight = 1000,
        stack = true,
        close = true,
        description = 'I4 engine swap part',
        client = { image = 'i4_engine.png' }
    },
    ['v6_engine'] = {
        label = 'V6 Engine',
        weight = 1000,
        stack = true,
        close = true,
        description = 'V6 engine swap part',
        client = { image = 'v6_engine.png' }
    },
    ['v12_engine'] = {
        label = 'V12 Engine',
        weight = 1000,
        stack = true,
        close = true,
        description = 'V12 engine swap part',
        client = { image = 'v12_engine.png' }
    },
    ['slick_tyres'] = {
        label = 'Slick Tyres',
        weight = 1000,
        stack = true,
        close = true,
        description = 'High-grip slick tyres',
        client = { image = 'slick_tyres.png' }
    },
    ['semi_slick_tyres'] = {
        label = 'Semi-slick Tyres',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Semi-slick tyres for improved traction',
        client = { image = 'semi_slick_tyres.png' }
    },
    ['offroad_tyres'] = {
        label = 'Offroad Tyres',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Tyres optimized for offroad use',
        client = { image = 'offroad_tyres.png' }
    },
    ['awd_drivetrain'] = {
        label = 'AWD Drivetrain',
        weight = 2000,
        stack = true,
        close = true,
        description = 'All-wheel drive conversion parts',
        client = { image = 'awd_drivetrain.png' }
    },
    ['rwd_drivetrain'] = {
        label = 'RWD Drivetrain',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Rear-wheel drive conversion parts',
        client = { image = 'rwd_drivetrain.png' }
    },
    ['fwd_drivetrain'] = {
        label = 'FWD Drivetrain',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Front-wheel drive conversion parts',
        client = { image = 'fwd_drivetrain.png' }
    },
    ['drift_tuning_kit'] = {
        label = 'Drift Tuning Kit',
        weight = 1500,
        stack = true,
        close = true,
        description = 'Drift tuning kit used to tune handling for drifting',
        client = { image = 'drift_tuning_kit.png' }
    },
    ['manual_gearbox'] = {
        label = 'Manual Gearbox',
        weight = 1500,
        stack = true,
        close = true,
        description = 'Manual gearbox conversion part',
        client = { image = 'manual_gearbox.png' }
    },

    -- Additional JG Mechanic items (added to match jg-mechanic install/config)
    ['lighting_controller'] = {
        label = 'Lighting Controller',
        weight = 100,
        stack = true,
        close = true,
        description = 'Controller used to configure lighting/LEDs',
        client = { image = 'lighting_controller.png', event = 'jg-mechanic:client:show-lighting-controller' }
    },
    ['stancing_kit'] = {
        label = 'Stancer Kit',
        weight = 100,
        stack = true,
        close = true,
        description = 'Kit used to adjust vehicle stance',
        client = { image = 'stancing_kit.png', event = 'jg-mechanic:client:show-stancer-kit' }
    },
    ['respray_kit'] = {
        label = 'Respray Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Kit used for vehicle resprays',
        client = { image = 'respray_kit.png' }
    },
    ['vehicle_wheels'] = {
        label = 'Vehicle Wheels Set',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Set of wheels for vehicles',
        client = { image = 'vehicle_wheels.png' }
    },
    ['tyre_smoke_kit'] = {
        label = 'Tyre Smoke Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Kit for creating tyre smoke effects',
        client = { image = 'tyre_smoke_kit.png' }
    },
    ['bulletproof_tyres'] = {
        label = 'Bulletproof Tyres',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Bulletproof tyre set',
        client = { image = 'bulletproof_tyres.png' }
    },
    ['extras_kit'] = {
        label = 'Extras Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Extras package for vehicles',
        client = { image = 'extras_kit.png' }
    },
    ['nitrous_bottle'] = {
        label = 'Nitrous Bottle',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Nitrous bottle for boosting vehicles',
        client = { image = 'nitrous_bottle.png', event = 'jg-mechanic:client:use-nitrous-bottle' }
    },
    ['empty_nitrous_bottle'] = {
        label = 'Empty Nitrous Bottle',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Empty nitrous bottle (after use)',
        client = { image = 'empty_nitrous_bottle.png' }
    },
    ['nitrous_install_kit'] = {
        label = 'Nitrous Install Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Kit used to install nitrous systems',
        client = { image = 'nitrous_install_kit.png' }
    },
    ['cleaning_kit'] = {
        label = 'Cleaning Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Kit used to clean vehicles',
        client = { image = 'cleaning_kit.png', event = 'jg-mechanic:client:clean-vehicle' }
    },
    ['repair_kit'] = {
        label = 'Repair Kit',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Repair kit for vehicle repairs',
        client = { image = 'repair_kit.png', event = 'jg-mechanic:client:repair-vehicle' }
    },
    ['duct_tape'] = {
        label = 'Duct Tape',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Duct tape for emergency repairs',
        client = { image = 'duct_tape.png', event = 'jg-mechanic:client:use-duct-tape' }
    },
    ['performance_part'] = {
        label = 'Performance Part',
        weight = 1000,
        stack = true,
        close = true,
        description = 'Generic performance upgrade part',
        client = { image = 'performance_part.png' }
    },
    ['ev_motor'] = {
        label = 'EV Motor',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Electric vehicle motor',
        client = { image = 'ev_motor.png' }
    },
    ['ev_battery'] = {
        label = 'EV Battery',
        weight = 2000,
        stack = true,
        close = true,
        description = 'Electric vehicle battery pack',
        client = { image = 'ev_battery.png' }
    },
    ['ev_coolant'] = {
        label = 'EV Coolant',
        weight = 500,
        stack = true,
        close = true,
        description = 'Coolant for electric vehicle systems',
        client = { image = 'ev_coolant.png' }
    },

    ['blue_bin'] = {
        label = 'Blue Bin',
        weight = 200,
        stack = true,
        close = true,
        description = 'A blue recycling bin',
        client = {
            image = 'blue_bin.png',
        }
    },

['skateboard'] = {
    label = 'Skateboard',
    weight = 3000,
    close = true,
    stack = false,
    client = {
        event = 'bodhix-skating:client:start'  
    }
},

['bmx'] = {
    label = 'Bmx',
    weight = 3000,
    close = true,
    stack = false,
    client = {
        event = 'bodhix-bmx:client:start'  
    }
},

    -- Peuren Gruppe6 Job Items
    ['money_bag'] = {
        label = 'Money Bag',
        weight = 500,
        stack = false,
        close = false,
        description = 'Gruppe 6 money bag',
    },
    ['money_crate'] = {
        label = 'Money Crate',
        weight = 500,
        stack = false,
        close = false,
        description = 'Gruppe 6 money crate',
    },
    ['black_money'] = {
        label = 'Black Money',
        weight = 0,
        stack = true,
        close = false,
        description = 'Gruppe 6 black money',
    },
    ['gruppe6_tablet'] = {
        label = 'Gruppe 6 Tablet',
        weight = 500,
        stack = false,
        close = false,
        description = 'Gruppe 6 tablet',
    },

    -- Peuren Miner Job Items
    ['hammer'] = {
        label = 'Hammer',
        description = "",
        weight = 500,
        stack = true,
    },
    ['pickaxe'] = {
        label = 'Pickaxe',
        description = "",
        weight = 500,
        stack = true,
    },
    ['drill'] = {
        label = 'Drill',
        description = "",
        weight = 500,
        stack = true,
    },
    ['laser_drill'] = {
        label = 'Laser drill',
        description = "",
        weight = 500,
        stack = true,
    },
    ['gold_ore'] = {
        label = 'Gold ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['crystal_ore'] = {
        label = 'Crystal ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['diamond_ore'] = {
        label = 'Diamond ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['iron_ore'] = {
        label = 'Iron ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['emerald_ore'] = {
        label = 'Emerald ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['ruby_ore'] = {
        label = 'Ruby ore',
        description = "",
        weight = 500,
        stack = true,
    },
    ['sapphire_ore'] = {
        label = 'Sapphire ore',
        description = "",
        weight = 500,
        stack = true,
    },

    -- Banking System Items
    ['debitcard_personal'] = {
        label = 'Personal Debit Card',
        stack = false,
        weight = 10,
        consume = 0,
        client = {
            export = "tgg-banking.UseCardOnAtm"
        }
    },
    ['debitcard_shared'] = {
        label = 'Shared Debit Card',
        stack = false,
        weight = 10,
        consume = 0,
        client = {
            export = "tgg-banking.UseCardOnAtm"
        }
    },
    ['debitcard_business'] = {
        label = 'Business Debit Card',
        stack = false,
        weight = 10,
        consume = 0,
        client = {
            export = "tgg-banking.UseCardOnAtm"
        }
    },

    -- Restaurant System Items
    ['frenchfries'] = {
        label = 'French Fries',
        weight = 10,
        stack = true,
        close = true,
        description = 'A plate of crispy, golden-brown french fries.',
        client = {
            status = { hunger = 50000 },
            anim = 'eating',
            usetime = 2500,
        }
    },
    
    ['frenchfriesbag'] = {
        label = 'French Fries Bag',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh french fries ready for frying.'
    },
    
    ['burntfrenchfries'] = {
        label = 'Burnt French Fries',
        weight = 10,
        stack = true,
        close = true,
        description = 'A plate of burnt, black french fries.'
    },
    
    ['rawburgerpatty'] = {
        label = 'Raw Burger Patty',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh beef patty for grilling.'
    },
    
    ['cookedburgerpatty'] = {
        label = 'Cooked Burger Patty',
        weight = 10,
        stack = true,
        close = true,
        description = 'A cooked burger patty.'
    },
    
    ['restaurant_ticket'] = {
        label = 'Restaurant Ticket',
        weight = 0,
        stack = false,
        close = true,
        description = 'A receipt from a restaurant order.'
    },
    
    ['cheese'] = {
        label = 'Cheese',
        weight = 10,
        stack = true,
        close = true,
        description = 'Cheese slices for burgers.'
    },
    
    ['lettuce'] = {
        label = 'Lettuce',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh lettuce leaves.'
    },
    
    ['tomato'] = {
        label = 'Tomato',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh tomato slices.'
    },
    
    ['onion'] = {
        label = 'Onion',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh onion slices.'
    },
    
    ['avocado'] = {
        label = 'Avocado',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh avocado slices.'
    },
    
    ['texmex_sauce'] = {
        label = 'TexMex Sauce',
        weight = 10,
        stack = true,
        close = true,
        description = 'Spicy TexMex sauce.'
    },
    
    ['burgerbun'] = {
        label = 'Burger Bun',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh burger buns.'
    },
    
    ['fish_filet'] = {
        label = 'Fish Filet',
        weight = 10,
        stack = true,
        close = true,
        description = 'Fresh fish filet.'
    },
    
    ['beaten_egg'] = {
        label = 'Beaten Egg',
        weight = 10,
        stack = true,
        close = true,
        description = 'Beaten egg for cooking.'
    },
    
    ['double_cheese_burger'] = {
        label = 'Double Cheese Burger',
        weight = 15,
        stack = true,
        close = true,
        description = 'A delicious double cheese burger.',
        client = {
            status = { hunger = 100000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
        }
    },
    
    ['cheese_burger'] = {
        label = 'Cheese Burger',
        weight = 12,
        stack = true,
        close = true,
        description = 'A classic cheese burger.',
        client = {
            status = { hunger = 80000 },
            anim = 'eating',
            prop = 'burger',
            usetime = 2500,
        }
    },
    
    ['pizza_pepperoni'] = {
        label = 'Pepperoni Pizza',
        weight = 20,
        stack = true,
        close = true,
        description = 'Delicious pepperoni pizza.',
        client = {
            status = { hunger = 120000 },
            anim = 'eating',
            usetime = 3000,
        }
    },
    
    ['pizza_mushroom'] = {
        label = 'Mushroom Pizza',
        weight = 20,
        stack = true,
        close = true,
        description = 'Fresh mushroom pizza.',
        client = {
            status = { hunger = 120000 },
            anim = 'eating',
            usetime = 3000,
        }
    },
    
    ['mojito'] = {
        label = 'Mojito',
        weight = 8,
        stack = true,
        close = true,
        description = 'Refreshing mojito cocktail.',
        client = {
            status = { thirst = 60000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['cola'] = {
        label = 'Cola',
        weight = 8,
        stack = true,
        close = true,
        description = 'Classic cola drink.',
        client = {
            status = { thirst = 400000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['water'] = {
        label = 'Water',
        weight = 5,
        stack = true,
        close = true,
        description = 'Fresh drinking water.',
        client = {
            status = { thirst = 400000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['juice'] = {
        label = 'Juice',
        weight = 8,
        stack = true,
        close = true,
        description = 'Fresh fruit juice.',
        client = {
            status = { thirst = 55000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['sunday'] = {
        label = 'Sunday',
        weight = 10,
        stack = true,
        close = true,
        description = 'Delicious sunday dessert.',
        client = {
            status = { hunger = 40000 },
            anim = 'eating',
            usetime = 2500,
        }
    },
    
    ['sprite'] = {
        label = 'Sprite',
        weight = 8,
        stack = true,
        close = true,
        description = 'Refreshing sprite drink.',
        client = {
            status = { thirst = 50000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['coffee_cup'] = {
        label = 'Coffee Cup',
        weight = 8,
        stack = true,
        close = true,
        description = 'Hot coffee in a cup.',
        client = {
            status = { thirst = 35000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['mayonnaise'] = {
        label = 'Mayonnaise',
        weight = 5,
        stack = true,
        close = true,
        description = 'Creamy mayonnaise sauce.'
    },
    
    ['ketchup'] = {
        label = 'Ketchup',
        weight = 5,
        stack = true,
        close = true,
        description = 'Ketchup is a condiment made from tomatoes and vinegar.'
    },
    
    ['cooking_oil'] = {
        label = 'Cooking Oil',
        weight = 15,
        stack = true,
        close = true,
        description = 'High-quality cooking oil for frying.'
    },
    
    ['chicken_nuggets_raw'] = {
        label = 'Chicken Nuggets Raw',
        weight = 10,
        stack = true,
        close = true,
        description = 'Raw chicken nuggets ready for frying.'
    },
    
    ['chicken_nuggets'] = {
        label = 'Chicken Nuggets',
        weight = 10,
        stack = true,
        close = true,
        description = 'Crispy chicken nuggets.',
        client = {
            status = { hunger = 60000 },
            anim = 'eating',
            usetime = 2500,
        }
    },
    
    ['cola_syrup'] = {
        label = 'Cola Syrup',
        weight = 10,
        stack = true,
        close = true,
        description = 'Cola Syrup'
    },
    
    ['sprite_syrup'] = {
        label = 'Sprite Syrup',
        weight = 10,
        stack = true,
        close = true,
        description = 'Sprite Syrup'
    },
    
    ['orange_concentrate'] = {
        label = 'Orange Concentrate',
        weight = 10,
        stack = true,
        close = true,
        description = 'Orange Concentrate'
    },
    
    ['carbonation'] = {
        label = 'Carbonation',
        weight = 10,
        stack = true,
        close = true,
        description = 'Carbonation'
    },
    
    ['orange_juice'] = {
        label = 'Orange Juice',
        weight = 10,
        stack = true,
        close = true,
        description = 'Orange Juice',
        client = {
            status = { thirst = 55000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['coffee_beans'] = {
        label = 'Coffee Beans',
        weight = 10,
        stack = true,
        close = true,
        description = 'Coffee Beans'
    },
    
    ['milk'] = {
        label = 'Milk',
        weight = 10,
        stack = true,
        close = true,
        description = 'Milk'
    },
    
    ['foam_powder'] = {
        label = 'Foam Powder',
        weight = 10,
        stack = true,
        close = true,
        description = 'Foam Powder'
    },
    
    ['coffee_black'] = {
        label = 'Coffee Black',
        weight = 10,
        stack = true,
        close = true,
        description = 'Coffee Black',
        client = {
            status = { thirst = 35000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['coffee_latte'] = {
        label = 'Coffee Latte',
        weight = 10,
        stack = true,
        close = true,
        description = 'Coffee Latte',
        client = {
            status = { thirst = 40000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['coffee_cappuccino'] = {
        label = 'Coffee Cappuccino',
        weight = 10,
        stack = true,
        close = true,
        description = 'Coffee Cappuccino',
        client = {
            status = { thirst = 40000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },
    
    ['coffee_espresso'] = {
        label = 'Espresso',
        weight = 10,
        stack = true,
        close = true,
        description = 'Strong espresso coffee',
        client = {
            status = { thirst = 30000 },
            anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
            usetime = 2500,
        }
    },

    ['tirekit'] = {
        label = 'Tire Kit',
        weight = 250,
        stack = true,
        close = true,
        description = 'A toolbox to repair vehicle tires',
        client = {
            image = 'tirekit.png',
        },
        server = {
            export = 'vehiclehandler.tirekit'
        }
    },

    ['repairkit'] = {
        label = 'Repairkit',
        weight = 2500,
        stack = true,
        close = true,
        description = 'A toolbox to repair your vehicle (basic)',
        client = {
            image = 'repairkit.png',
        },
        server = {
            export = 'vehiclehandler.repairkit',
        }
    },

    ['advancedrepairkit'] = {
        label = 'Advanced Repairkit',
        weight = 5000,
        stack = true,
        close = true,
        description = 'A toolbox to repair your vehicle (advanced)',
        client = {
            image = 'advancedrepairkit.png',
        },
        server = {
            export = 'vehiclehandler.advancedrepairkit',
        }
    },

 ['weapon'] = {
		label = 'Firearm License',
		description = 'Can carry a firearm legally.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'weapon_license.png',
		}
	},
 
	['driver_car'] = {
		label = 'Driver License',
		description = 'Can drive a car legally.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},

    ['theory_driver_car'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

    ['theory_driver_bike'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

    ['theory_driver_plane'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

    ['theory_driver_helicopter'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

    ['theory_driver_boat'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

    ['theory_driver_truck'] = {
		label = 'Certificate of completion',
		description = 'Eligible to take the practical exam.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
		}
	},

 
	['driver_truck'] = {
		label = 'CDL License',
		weight = 1,
		stack = false,
		close = true,
		description = 'Can operate a Commercial vehicle legally.',
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},
 
	['driver_bike'] = {
		label = 'Motorcycle License',
		weight = 1,
		stack = false,
		close = true,
		description = 'Can operate a motorcycle legally.',
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},
 
	['identification'] = {
		label = 'Identification',
		weight = 1,
		stack = false,
		close = true,
		description = 'ID Card',
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
		}
	},

    ['dmv'] = {
        label = 'Theory Driving License',
        weight = 1,
        stack = false,
        close = true,
        description = 'Theory driving license certificate.',
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
            image = 'driver-theory.png',
        }
    },

    ['surgeon_license'] = {
        label = 'Surgeon License',
        weight = 1,
        stack = false,
        close = true,
        description = 'Medical surgeon professional license.',
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
            image = 'medical-license.png',
        }
    },

    ['nurse_license'] = {
        label = 'Nurse License',
        weight = 1,
        stack = false,
        close = true,
        description = 'Registered nurse professional license.',
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
            image = 'medical-license.png',
        }
    },

    ['work_permit'] = {
        label = 'Work Permit',
        weight = 1,
        stack = false,
        close = true,
        description = 'Official work permit document.',
        consume = 0,
        client = {
            export = 'bcs_licensemanager.showCard',
            image = 'work-permit.png',
        }
    },

    ['driver_helicopter'] = {
		label = 'Pilot(H) License',
		description = 'An FAA approved license to fly helicopters.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},

    ['driver_plane'] = {
		label = 'Pilot(F) License',
		description = 'An FAA approved license to fly fixed wing aircraft.',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},

    ['driver_boat'] = {
		label = 'Boat License',
		description = 'A license to drive boats',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'bcs_licensemanager.showCard',
            image = 'driving-license.png',
		}
	},

    ['special_attach'] = {
        label = 'Special Attachment License',
        weight = 0,
        stack = false,
		close = true,
        consume = 0,
        description = 'A government-issued license permitting the possession and use of special firearm attachments such as suppressors. Features the Great Seal of San Andreas.',
    	client = {
		    export = 'bcs_licensemanager.showCard',
            image = 'special_attach.png',
		}
    },

    ['tow'] = {
        label = 'Towing Operator License',
        weight = 0,
        stack = false,
		close = true,
		consume = 0,
        description = 'Official SADOT certification for towing operators. Required for legal towing operations within San Andreas. DOT certified with official state seal.',
    	client = {
		    export = 'bcs_licensemanager.showCard',
            image = 'tow.png',
		}
    },

    ['bounty_hunter'] = {
        label = 'Fugitive Recovery Agent License',
        weight = 0,
        stack = false,
		close = true,
		consume = 0,
        description = 'Official authorization to work as a Fugitive Recovery Agent (Bounty Hunter) within San Andreas. Features tactical design and official state certification.',
    	client = {
		    export = 'bcs_licensemanager.showCard',
            image = 'bounty_hunter.png',
		}
    },

    ['class3'] = {
        label = 'Class III Weapon License',
        weight = 0,
        stack = false,
		close = true,
		consume = 0,
        description = 'Government-issued license authorizing the possession and use of Class III firearms and weapons. Required for specific regulated firearms.',
    	client = {
		    export = 'bcs_licensemanager.showCard',
            image = 'class3.png',
		}
    },

    ['class4'] = {
        label = 'Class IV Weapon License',
        weight = 0,
        stack = false,
        close = true,
        consume = 0,
        description = 'High-level weapons authorization license for Class IV firearms. Required for advanced tactical weapons and specialized military-grade equipment.',
        client = {
            export = 'bcs_licensemanager.showCard',
            image = 'class4.png',
        },
    },

    -- Pug Fishing Items
    ['fishingrod'] = {
    label = 'Fishing Rod',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A fishing rod for adventures with friends!!',
    client = {
        image = 'fishingrod.png',
    }
},

['fishingrod2'] = {
    label = 'Skilled Fishing Rod',
    weight = 5000,
    stack = false,
    close = true,
    description = 'This rod is better than most, but not the best.',
    client = {
        image = 'fishingrod2.png',
    }
},

['fishingrod3'] = {
    label = 'Professional Rod',
    weight = 5000,
    stack = false,
    close = true,
    description = 'S+ tier fishing rod!!',
    client = {
        image = 'fishingrod3.png',
    }
},

['fishinglure'] = {
    label = 'Fishing Lure',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A colorful lure',
    client = {
        image = 'fishinglure.png',
    }
},

['fishinglure2'] = {
    label = 'Pro Fishing Lure',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A realistic lure',
    client = {
        image = 'fishinglure2.png',
    }
},

['skillreel'] = {
    label = 'Skill Fishing Reel',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A skilled fishing reel.',
    client = {
        image = 'skillreel.png',
    }
},

['proreel'] = {
    label = 'Pro Fishing Reel',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A professional fishing reel.',
    client = {
        image = 'proreel.png',
    }
},

['fishingbait'] = {
    label = 'Fish Bait',
    weight = 1000,
    stack = true,
    close = true,
    description = 'Worm bait!',
    client = {
        image = 'fishingbait.png',
    }
},

['fishingshovel'] = {
    label = 'Dirt Shovel',
    weight = 3000,
    stack = false,
    close = true,
    description = 'A shovel that has something to do with fishing!',
    client = {
        image = 'fishingshovel.png',
    }
},

['fishingfireplace'] = {
    label = 'Fire Place',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A fire place used to cook fish!',
    client = {
        image = 'fishingfireplace.png',
    }
},

['fishingnet'] = {
    label = 'Fish Net',
    weight = 5000,
    stack = false,
    close = true,
    description = 'A net used for catching fish!',
    client = {
        image = 'fishingnet.png',
    }
},

['fishingtrowl'] = {
    label = 'Dirt Trowl',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A trowl that has something to do with fishing!',
    client = {
        image = 'fishingtrowl.png',
    }
},

['cookedfish'] = {
    label = 'Cooked Fish',
    weight = 1000,
    stack = false,
    close = false,
    description = 'A cooked fish!',
    client = {
        image = 'cookedfish.png',
    }
},

['perfectlycookedfish'] = {
    label = 'Perfectly Cooked Fish',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A perfectly cooked fish!',
    client = {
        image = 'perfectlycookedfish.png',
    }
},

['fishinganchor'] = {
    label = 'Anchor',
    weight = 1000,
    stack = true,
    close = true,
    description = 'An anchor used for anchoring a boat! [Use this while sitting in a boat]',
    client = {
        image = 'fishinganchor.png',
    }
},

['fishinglog'] = {
    label = 'Fishing Log',
    weight = 1000,
    stack = false,
    close = true,
    description = 'A log book that allows you to view all of the fish you have caught!',
    client = {
        image = 'fishinglog.png',
    }
},

-- Fish Items
['killerwhale'] = {
    label = 'Killer Whale',
    weight = 7000,
    stack = true,
    close = true,
    description = 'This is a whole ass Shamu.',
    client = {
        image = 'killerwhale.png',
    }
},

['stingraymeat'] = {
    label = 'Stingray',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Stingray Meat',
    client = {
        image = 'stingraymeat.png',
    }
},

['tigershark'] = {
    label = 'Tigershark',
    weight = 7000,
    stack = true,
    close = true,
    description = 'There are bigger sharks but this is still impressive..',
    client = {
        image = 'tigershark.png',
    }
},

['catfish'] = {
    label = 'Catfish',
    weight = 3000,
    stack = true,
    close = true,
    description = 'A Catfish',
    client = {
        image = 'catfish.png',
    }
},

['fish'] = {
    label = 'Fish',
    weight = 1000,
    stack = true,
    close = false,
    description = 'A fish',
    client = {
        image = 'fish.png',
    }
},

['salmon'] = {
    label = 'Salmon',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A Salmon Fish',
    client = {
        image = 'salmon.png',
    }
},

['largemouthbass'] = {
    label = 'Largemouth Bass',
    weight = 3000,
    stack = true,
    close = true,
    description = 'Fish for Fishing.',
    client = {
        image = 'largemouthbass.png',
    }
},

['goldfish'] = {
    label = 'Goldfish',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A Goldfish... I wonder how he got there...',
    client = {
        image = 'goldfish.png',
    }
},

['redfish'] = {
    label = 'Redfish',
    weight = 2000,
    stack = true,
    close = true,
    description = 'One fish two fish...',
    client = {
        image = 'redfish.png',
    }
},

['bluefish'] = {
    label = 'Bluefish',
    weight = 1000,
    stack = true,
    close = true,
    description = 'One fish two fish redfish...',
    client = {
        image = 'bluefish.png',
    }
},

['stripedbass'] = {
    label = 'Striped Bass',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A Striped Bass',
    client = {
        image = 'stripedbass.png',
    }
},

['rainbowtrout'] = {
    label = 'Rainbow Trout',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A colorful Trout',
    client = {
        image = 'rainbowtrout.png',
    }
},

['gholfish'] = {
    label = 'Ghol',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A big Ghol',
    client = {
        image = 'gholfish.png',
    }
},

['codfish'] = {
    label = 'Cod',
    weight = 3000,
    stack = true,
    close = true,
    description = 'A cody fish',
    client = {
        image = 'codfish.png',
    }
},

['eelfish'] = {
    label = 'Eel',
    weight = 4000,
    stack = true,
    close = true,
    description = 'An eel.. pretty useless.',
    client = {
        image = 'eelfish.png',
    }
},

['swordfish'] = {
    label = 'Sword Fish',
    weight = 3000,
    stack = true,
    close = true,
    description = 'This has a giant ass needle for a face.',
    client = {
        image = 'swordfish.png',
    }
},

['tunafish'] = {
    label = 'Tuna',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Chicken of the sea, but fucking massive.',
    client = {
        image = 'tunafish.png',
    }
},

['anglerfish'] = {
    label = 'Angler Fish',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Very creepy looking',
    client = {
        image = 'anglerfish.png',
    }
},

['fishinghalibut'] = {
    label = 'Halibut',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Halibut?',
    client = {
        image = 'fishinghalibut.png',
    }
},

['flyfish'] = {
    label = 'Exocoetidae',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Not a bird',
    client = {
        image = 'flyfish.png',
    }
},

['kingsalmon'] = {
    label = 'King Salmon',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A Salmon fit for a king',
    client = {
        image = 'kingsalmon.png',
    }
},

['mahimahi'] = {
    label = 'Mahi-Mahi',
    weight = 2000,
    stack = true,
    close = true,
    description = 'So nice they named it twice',
    client = {
        image = 'mahimahi.png',
    }
},

['oceansturgeon'] = {
    label = 'Sturgeon',
    weight = 2000,
    stack = true,
    close = true,
    description = 'A big boy',
    client = {
        image = 'oceansturgeon.png',
    }
},

['rockfish'] = {
    label = 'Rock Fish',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Rock Fish',
    client = {
        image = 'rockfish.png',
    }
},

['sockeyesalmon'] = {
    label = 'Sockeye Salmon',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Naturally Pink',
    client = {
        image = 'sockeyesalmon.png',
    }
},

['tarponfish'] = {
    label = 'Tarpon',
    weight = 2000,
    stack = true,
    close = true,
    description = 'Tarpon fish',
    client = {
        image = 'tarponfish.png',
    }
},

-- Crabs
['bluecrab'] = {
    label = 'Blue Crab',
    weight = 1200,
    stack = true,
    close = true,
    description = 'A tasty Blue Crab',
    client = {
        image = 'bluecrab.png',
    }
},

['dungenesscrab'] = {
    label = 'Dungeness Crab',
    weight = 1600,
    stack = true,
    close = true,
    description = 'A large Dungeness Crab',
    client = {
        image = 'dungenesscrab.png',
    }
},

['rockcrab'] = {
    label = 'Rock Crab',
    weight = 1400,
    stack = true,
    close = true,
    description = 'A small but meaty Rock Crab',
    client = {
        image = 'rockcrab.png',
    }
},

['redcrab'] = {
    label = 'Red Crab',
    weight = 1500,
    stack = true,
    close = true,
    description = 'Bright red crab, delicious cooked',
    client = {
        image = 'redcrab.png',
    }
},

['snowcrab'] = {
    label = 'Snow Crab',
    weight = 1700,
    stack = true,
    close = true,
    description = 'Cold water Snow Crab',
    client = {
        image = 'snowcrab.png',
    }
},

['cookedcrab'] = {
    label = 'Cooked Crab',
    weight = 1700,
    stack = true,
    close = true,
    description = 'A cooked crab!',
    client = {
        image = 'cookedcrab.png',
    }
},

['crawfish'] = {
    label = 'Crawfish',
    weight = 2000,
    stack = true,
    close = true,
    description = 'This is not a lobster',
    client = {
        image = 'crawfish.png',
    }
},

-- Chest Items
['chestkey'] = {
    label = 'Key',
    weight = 1000,
    stack = true,
    close = true,
    description = 'A gold key.',
    client = {
        image = 'chestkey.png',
    }
},

['treasurechest'] = {
    label = 'Treasure Chest',
    weight = 5000,
    stack = false,
    close = true,
    description = 'Ye, Treasure mighty.',
    client = {
        image = 'treasurechest.png',
    }
},

['bottlemap'] = {
    label = 'Treasure Bottle',
    weight = 1000,
    stack = false,
    close = true,
    description = 'looks very old.',
    client = {
        image = 'bottlemap.png',
    }
},

['treasuremap'] = {
    label = 'Treasure Map',
    weight = 500,
    stack = false,
    close = true,
    description = 'This could lead somewhere...',
    client = {
        image = 'treasuremap.png',
    }
},

['captainskull'] = {
    label = 'Captain Skull',
    weight = 4000,
    stack = true,
    close = false,
    description = 'An old skull of a captain!',
    client = {
        image = 'captainskull.png',
    }
},

    ['fishingcrabtrap'] = {
        label = 'Crab Trap',
        weight = 4000,
        stack = false,
        close = true,
        description = 'A crab trap used for catching crabs and other tiny fish!',
        client = {
            image = 'fishingcrabtrap.png',
        }
    },
}