return {
    debug = false,

    -- Police jobs that can use these actions
    policeJobs = {
        'police',
        'lscso',
        'sast'
    },

    -- Minimum grade required for certain actions (0 = all grades)
    gradeRequirements = {
        frisk = 0,
        softcuff = 0,
        hardcuff = 0,
        uncuff = 0,
        escort = 0,
        unescort = 0,
        search = 0,
        checkId = 0,
        putInVehicle = 0,
        removeFromVehicle = 0,
        tackle = 1, -- Requires grade 1+
        checkWarrants = 0,
        seizeLicense = 2, -- Requires grade 2+
    },

    -- Distance settings
    distances = {
        target = 2.5,      -- Max distance for ox_target interaction
        escort = 1.5,      -- Distance to keep escorted player
    },

    -- Animation settings
    animations = {
        frisk = {
            dict = 'mini@repair',
            anim = 'fixing_a_player',
            duration = 5000
        },
        friskTarget = {
            dict = 'random@mugging3',
            anim = 'handsup_standing_base',
            duration = 5000
        },
        cuff = {
            dict = 'mp_arresting',
            anim = 'a_uncuff',
            duration = 3000
        },
        search = {
            dict = 'anim@gangops@facility@servers@bodysearch@',
            anim = 'player_search',
            duration = 8000
        },
        checkId = {
            dict = 'anim@amb@board_room@supervising@',
            anim = 'think_01_hi_amy_skater_01',
            duration = 3000
        },
        tackle = {
            dict = 'missmic2ig_11',
            anim = 'mic_2_ig_11_intro_goodguy',
            duration = 1000
        }
    },

    -- Cuff settings
    cuffs = {
        softCuffWalkStyle = 'move_m@prisoner_cuffed',
        hardCuffWalkStyle = 'move_m@prisoner_cuffed',
        preventActions = true, -- Prevent cuffed players from using weapons, inventory, etc.
    },

    -- Tackle settings
    tackle = {
        enabled = true,
        cooldown = 10000,   -- 10 second cooldown
        maxSpeed = 15.0,    -- Max speed player can be running to tackle
        stunDuration = 3000 -- How long target is stunned
    },

    -- Keybinds (set to false to disable)
    keybinds = {
        escort = 'G',      -- Toggle escort
        uncuff = false,    -- Use target menu only
    },

    -- Notifications
    notifications = {
        frisked = 'You were frisked by an officer',
        cuffed = 'You have been handcuffed',
        hardcuffed = 'You have been hard-cuffed. Resistance is futile.',
        uncuffed = 'You have been uncuffed',
        escorted = 'You are being escorted',
        unescorted = 'You are no longer being escorted',
        searched = 'You were searched by an officer',
        idChecked = 'An officer checked your ID',
        tackled = 'You were tackled!',
        putInVehicle = 'You were placed in a vehicle',
        removedFromVehicle = 'You were removed from the vehicle',
    },

    -- Integration settings
    integrations = {
        -- lb-tablet MDT integration
        lbTablet = {
            enabled = true,
            checkProfiles = true,  -- Allow checking player profiles
            checkWarrants = true,  -- Allow checking warrants
        },
        -- bcs_licensemanager integration
        licenseManager = {
            enabled = true,
            showLicense = true,    -- Show player's license when checking ID
        },
        -- ox_inventory integration
        oxInventory = {
            enabled = true,
            searchInventory = true, -- Allow searching player inventory
        }
    },

    -- Dispatch integration (lb-tablet)
    dispatch = {
        enabled = true,
        codes = {
            arrest = '10-15',
            pursuit = '10-80',
            backup = '10-78',
        }
    },

    -- Police/EMS blips on minimap
    unitBlips = {
        enabled = true,
        updateInterval = 5000, -- Update every 5 seconds (in ms)
        showOnlyOnDuty = true, -- Only show units who are on duty

        -- Jobs that can SEE blips (police + EMS)
        viewerJobs = {
            'police',
            'lscso',
            'sast',
            'ambulance',
            'ems'
        },

        -- Blip settings per job (jobs that SHOW on map)
        blips = {
            ['police'] = {
                sprite = 1,              -- Circle blip (on foot)
                spriteInVehicle = 56,    -- Player in vehicle
                spriteLightsOn = 60,     -- Police car blip (lights on)
                color = 3,               -- Blue
                colorLightsOn = 38,      -- Flashing blue
                scale = 0.8,
                scaleLightsOn = 1.0,
                name = 'LSPD'
            },
            ['lscso'] = {
                sprite = 1,
                spriteInVehicle = 56,
                spriteLightsOn = 60,
                color = 17,              -- Orange
                colorLightsOn = 17,
                scale = 0.8,
                scaleLightsOn = 1.0,
                name = 'LSCSO'
            },
            ['sast'] = {
                sprite = 1,
                spriteInVehicle = 56,
                spriteLightsOn = 60,
                color = 27,              -- Dark green
                colorLightsOn = 27,
                scale = 0.8,
                scaleLightsOn = 1.0,
                name = 'SAST'
            },
            ['ambulance'] = {
                sprite = 61,             -- Medic cross (on foot)
                spriteInVehicle = 61,
                spriteLightsOn = 61,     -- Ambulance blip
                color = 1,               -- Red
                colorLightsOn = 1,
                scale = 0.8,
                scaleLightsOn = 1.0,
                name = 'EMS'
            },
            ['ems'] = {
                sprite = 61,
                spriteInVehicle = 61,
                spriteLightsOn = 61,
                color = 1,
                colorLightsOn = 1,
                scale = 0.8,
                scaleLightsOn = 1.0,
                name = 'EMS'
            }
        },

        -- Show rank/callsign in blip name
        showCallsign = true,
        showRank = true
    }
}
