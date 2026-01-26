---------- [STRINGS] ----------
Config.HeistMenuCommand = "robbery" -- Main robbery creator menu command.
Config.ReputationCommand = "robrep" -- Check your individual robbery reputation command.
Config.VehilceKeysGivenToPlayerEvent = "vehiclekeys:client:SetOwner" -- Event used to give player keys to vehicle only if you are making a robbable car heist.
Config.DiscordWebHook = "ADD YOUR CUSTOM WEBHOOK URL HERE" --  If you want to edit the webhook message then you can change it in the server/sv_open.lua
------------------------------
---------- [BOOLS] ----------
Config.Debug = false -- enables debug poly.
Config.AddStolenVehicleToPlayersGarage = true -- Add the vehicle to the players saved garage for ever when stealing a car from a crated car robbery. (its smart to make robbable car robberies really hard)
Config.SaveMenuWhenYouCloseIt = false -- Make this true if you want the robbery creator to save all of the data when you close out of it. (i personally dont make this true because it is annoying)
Config.DontAllowPoliceToDoRobbery = false -- This is to make it so that poice jobs cannot do the robbery. If they can do the robbery then they have the power to exploit the system and make unlimited money.
Config.PullItemsFromOXInventory = false -- Make this true if you want to pull your items from ox inventory instead of qb-core shared (only matters on qbcore servers)
Config.CanPoliceResetStep = true -- Make this false if you do not want Config.DefualPoliceJobs to have the ability to reset a step.
-- THIS ONE IS NOT FINISHED YET --> Config.DrawTextInsteadOfTarget = false -- Make this true if you want to use drawtext instead of qb-target third eye systems.
-- I reccomend keeping this true unless you really just want to build your own robbery system but even then you can just edit my presets. I made lore progression that you can find in the pug-robberycreator/SETUP-AND-INSTALL/progression.md
Config.CreateRobberyPresetsWhenScriptRunFirstTime = true -- This only matters when the script turns on the first time and it auto adds the robberies that i have made with progression to you database automatically.
---------- [INTAGERS] ----------

------------------------------
---------- [TABLES] ----------
------------------------------
Config.DefualPoliceJobs = {'police', 'bcso', 'leo', 'ranger', 'trooper', 'sasp', 'lscso'} -- These are default police jobs for bank truck robbery, lasers, reseting a step, 
------------------------------
Config.Color = {r = 250, g = 250, b = 0, a = 200} -- RGB Color of the line and ball that is displayed when editing a robbery
------------------------------
Config.AtmProps = { -- all atm props that ara robbable
    "prop_atm_02",
    "prop_atm_03",
    "prop_fleeca_atm",
}
Config.CustomDoorModels = {
    "hei_v_ilev_bk_safegate_pris",
    "v_ilev_ct_door02",
}
-- Hacking props (ie. open a door or shut off lasers)
Config.HackableProps = { -- Prop options
    "prop_ld_keypad_01b",
    "v_ilev_gb_vauldr",
    "hei_prop_hei_securitypanel",
    "ch_prop_fingerprint_scanner_01e",
    "tr_prop_tr_elecbox_01a",
    "prop_phonebox_01a",

    -- 2.0 update
    'h4_prop_h4_chain_lock_01a',
}
-- Robabble Props props (ie. Grab loot/money/items)
Config.RobabbleProps = { -- Prop options
    "h4_prop_h4_safe_01a",
    "p_chem_vial_02b_s",
    "tr_prop_tr_elecbox_01a",
    "xm_base_cia_server_01",
    "h4_prop_h4_glass_disp_01a",
    "ch_prop_fingerprint_scanner_01e",
    "ch_prop_gold_trolly_01a",
    "ch_prop_cash_low_trolly_01a", 
    "ch_prop_diamond_trolly_01a",
    "imp_prop_impexp_coke_trolly",
    "h4_prop_h4_cash_stack_01a",
    "h4_prop_h4_gold_stack_01a",
    "h4_prop_h4_weed_stack_01a",
    "h4_prop_h4_coke_stack_01a",
    "tr_prop_tr_container_01a",
    "hei_prop_hei_securitypanel",
    "ch_prop_vault_painting_01a",
    "ch_prop_vault_painting_01e",
    "ch_prop_vault_painting_01i",
    "ch_prop_vault_painting_01d",
    "ch_prop_vault_painting_01h",
    "ch_prop_vault_painting_01j",
    "ch_prop_vault_painting_01f",
    "ch_prop_vault_painting_01b",
    "ch_prop_vault_painting_01g",
    "ch_prop_vault_painting_01c",
    "thrax",
    "zorrusso",
    "taipan",
    "furia",
    "emerus",
    "prop_cash_pile_02",
    'prop_poly_bag_money',
    'hei_prop_cash_crate_half_full',
    'bkr_prop_bkr_cashpile_04',
    'bkr_prop_bkr_cashpile_05',
    'v_ret_gc_gasmask',
    'ch_prop_ch_heist_drill',
    'w_sb_microsmg',

    -- 2.0 update
    'xm3_prop_xm3_crate_01a',
    'tr_prop_tr_adv_case_01a',
}
------------------------------
Config.GuardModels = {
    s_m_m_security_01 = "Security Guard",
    s_m_y_cop_01 = "Police Officer",
    s_m_m_chemsec_01 = "Chemical Security",
    -- Add more models as needed
}

Config.CustomZAxisTargetsOnProps = { -- This table is for changing the targets position on certain props that you add to Config.RobabbleProps because by default some targets wont allign right with all props.
    ["v_ilev_gb_vauldr"] = {
        Xoffset = 0.8,
        Yoffset = 0.0,
        zoffset = 0.0,
    },
    ["xm_base_cia_server_01"] = {
        Xoffset = 0.0,
        Yoffset = -0.3,
        zoffset = 1.0,
    },
    
    -- 2.0 update
    ["xm3_prop_xm3_crate_01a"] = {
        Xoffset = 0.0,
        Yoffset = -0.4,
        zoffset = 1.0,
    },
    ["tr_prop_tr_adv_case_01a"] = {
        Xoffset = 0.0,
        Yoffset = -0.4,
        zoffset = 0.4,
    },
    ["prop_phonebox_01a"] = {
        Xoffset = 0.0,
        Yoffset = 0.0,
        zoffset = 1.0,
    },
}

Config.BankDoorModels = { -- DO NOT REMOVE ANY OF THESE. Only add more bank vault door models if you need to.
    "v_ilev_bk_vaultdoor",  -- Big bank vault
    "v_ilev_gb_vauldr", -- Silver vault door
    "hei_prop_heist_sec_door", -- Fleeca bank door
    "v_ilev_cbankvauldoor01",  --  Paleto bank door
    
}

-- So this is for unique vault doors that need to be shut forcefully at all times like the paleto vault door. (ADD YOUR UNIQUE VAULT DOOR MODEL TO Config.BankDoorModels  IF YOU NEED TOO)
Config.UniqueBankDoors = {
  --YOUR NAME   |   DOOR LOCATION         |        HEADING TO SET TO FOR THE DOOR TO BE LOCKED | IF REVERSEHEADING IS TRUE THEN THE VAULT DOOR WILL OPEN THE OPPOSITE WAY NORMAL BANK VAULT DOORS OPEN.
    paleto = {location =  vector3(-104.89, 6471.16, 31.63), LockedHeading = 45.45, ReverseHeading = true},
}

Config.WeaponList = { -- Guard weapon options
    "weapon_assaultrifle",
    "weapon_assaultrifle_mk2",
    "weapon_carbinerifle",
    "weapon_carbinerifle_mk2",
    "weapon_advancedrifle",
    "weapon_specialcarbine",
    "weapon_bullpuprifle",
    "weapon_compactrifle",
    "weapon_specialcarbine_mk2",
    "weapon_bullpuprifle_mk2",
    "weapon_militaryrifle",
    "weapon_mg",
    "weapon_combatmg",
    "weapon_raycarbine",
    "weapon_combatmg_mk2",
    "weapon_sniperrifle",
    "weapon_heavysniper",
    "weapon_marksmanrifle",
    "weapon_heavysniper_mk2",
    "weapon_marksmanrifle_mk2",
    "weapon_minigun",
    "weapon_railgun",
    "weapon_pumpshotgun",
    "weapon_sawnoffshotgun",
    "weapon_assaultshotgun",
    "weapon_bullpupshotgun",
    "weapon_musket",
    "weapon_heavyshotgun",
    "weapon_dbshotgun",
    "weapon_autoshotgun",
    "weapon_pumpshotgun_mk2",
    "weapon_combatshotgun",
    "weapon_gusenberg",
    "weapon_microsmg",
    "weapon_smg",
    "weapon_smg_mk2",
    "weapon_assaultsmg",
    "weapon_combatpdw",
    "weapon_machinepistol",
    "weapon_minismg",
    "weapon_pistol",
    "weapon_pistol_mk2",
    "weapon_combatpistol",
    "weapon_appistol",
    "weapon_pistol50",
    "weapon_snspistol",
    "weapon_heavypistol",
    "weapon_vintagepistol",
    "weapon_marksmanpistol",
    "weapon_revolver",
    "weapon_revolver_mk2",
    "weapon_doubleaction",
    "weapon_snspistol_mk2",
    "weapon_ceramicpistol",
    "weapon_navyrevolver",
    "weapon_gadgetpistol",
}

------------------------------
Config.Animations = { -- Animations that can be used.
    [1] = {
        Name = "Mechanic",
        AnimDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        AnimAction = "machinic_loop_mechandplayer",
    },
    [2] = {
        Name = "Mechanic2",
        AnimDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        AnimAction = "machinic_loop_mechandplayer",
        EmoteMoving = true,
    },
    [3] = {
        Name = "Mechanic3",
        AnimDict = "mini@repair",
        AnimAction = "fixing_a_ped",
    },
    [4] = {
        Name = "Type",
        AnimDict = "anim@heists@prison_heiststation@cop_reactions", 
        AnimAction = "cop_b_idle",
        EmoteLoop = true,
        EmoteMoving = true,
    },
    [5] = {
        Name = "Type2",
        AnimDict = "anim@heists@prison_heistig1_p1_guard_checks_bus",
        AnimAction = "loop",
        EmoteLoop = true,
        EmoteMoving = true,
    },
    [6] = {
        Name = "Type3",
        AnimDict = "mp_prison_break",
        AnimAction = "hack_loop",
        EmoteLoop = true,
        EmoteMoving = true,
    },
    [7] = {
        Name = "Type4",
        AnimDict = "mp_fbi_heist",
        AnimAction = "loop",
        EmoteLoop = true,
    },
    [8] = {
        Name = "Keypad Type",
        AnimDict = "anim@heists@keypad@",
        AnimAction = "idle_a",
    },
    [9] = {
        Name = "Guard",
        AnimDict = "WORLD_HUMAN_GUARD_STAND",
        IsScenario = true,
    },
    [10] = {
        Name = "Thermite and Bag scene",
        AnimDict = "anim@heists@ornate_bank@thermal_charge", -- Thermite and Bag scene
        AnimAction = "thermal_charge",
        IsNetWorkedScene = true, -- THIS IS WHAT MAKES THE THERMITE SPECIAL SETUP IN THE ANIMATION EVENT
        XOffset = 0.3,
        YOffset = 0.4,
        ZOffset = 0.1,
        DoCustomCam = false,
        AnimationOptions = {
            AttachWaitDuration = 1500,
            Prop = 'hei_p_m_bag_var22_arm_s',
            PropBone = 28422,
            PropPlacement = {0, 0, 0, 0, 0},
            PropAnimationDict = "anim@heists@ornate_bank@thermal_charge",
            PropAnimation = "bag_thermal_charge",
            TimeUntilFreezePropPosition = 3000,
            SecondProp = 'hei_prop_heist_thermite',
            SecondPropBone = 28422,
            SecondPropPlacement = {0, 0, 0, 0, 0},
        }
    },
    [11] = {
        Name = "Laptop and Bag scene",
        NetworkedAnimations = { -- Laptop and Bag scene
            [1] = {
                AnimDict = "anim@heists@ornate_bank@hack",
                AnimAction = "hack_enter",
                WaitTime = 6200,
                XOffset = 0.01,
                YOffset = 0.85, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.4,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim@heists@ornate_bank@hack",
                    PropAnimation = "hack_enter_bag",
                    SecondProp = 'hei_prop_hst_laptop',
                    SecondPropAnimationDict = "anim@heists@ornate_bank@hack",
                    SecondPropAnimation = "hack_enter_laptop",
                    ThirdProp = 'hei_prop_heist_card_hack_02',  
                    ThirdPropAnimationDict = "anim@heists@ornate_bank@hack",
                    ThirdPropAnimation = "hack_enter_card",  
                    ThirdPropPlacement = {0.1, 0.0, 0.0, -20.0, -100.0, -54.0},
                }
            },
            [2] = {
                AnimDict = "anim@heists@ornate_bank@hack",
                AnimAction = "hack_loop",
                WaitTime = 3500,
                XOffset = 0.01,
                YOffset = 0.85, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.4,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim@heists@ornate_bank@hack",
                    PropAnimation = "hack_loop_bag",
                    SecondProp = 'hei_prop_hst_laptop',
                    SecondPropAnimationDict = "anim@heists@ornate_bank@hack",
                    SecondPropAnimation = "hack_loop_laptop",
                    ThirdProp = 'hei_prop_heist_card_hack_02',  
                    ThirdPropAnimationDict = "anim@heists@ornate_bank@hack",
                    ThirdPropAnimation = "hack_loop_card",  
                    ThirdPropPlacement = {0.1, 0.0, 0.0, -20.0, -120.0, -54.0},
                }
            },
            [3] = {
                AnimDict = "anim@heists@ornate_bank@hack",
                AnimAction = "hack_exit",
                WaitTime = 7500,
                XOffset = 0.09,
                YOffset = 0.79, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.402,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim@heists@ornate_bank@hack",
                    PropAnimation = "hack_exit_bag",
                    SecondProp = 'hei_prop_hst_laptop',
                    SecondPropAnimationDict = "anim@heists@ornate_bank@hack",
                    SecondPropAnimation = "hack_exit_laptop",
                    ThirdProp = 'hei_prop_heist_card_hack_02',  
                    ThirdPropAnimationDict = "anim@heists@ornate_bank@hack",
                    ThirdPropAnimation = "hack_exit_card",  
                    ThirdPropPlacement = {0.1, 0.0, 0.0, -20.0, -100.0, -54.0},
                }
            },
        }
    },
    [12] = {
        Name = "Drilling and bag scene",
        NetworkedAnimations = { -- Drilling and bag scene
            [1] = {
                AnimDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                AnimAction = "intro",
                WaitTime = 6200,
                XOffset = 0.2,
                YOffset = 0.85, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.3,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                    PropAnimation = "bag_intro",
                    SecondProp = 'ch_prop_ch_heist_drill',
                    SecondPropAnimationDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                    SecondPropAnimation = "intro_drill_bit",
                }
            },
            [2] = {
                AnimDict = "anim@heists@fleeca_bank@drilling",
                AnimAction = "drill_straight_fail",
                WaitTime = 7500,
                XOffset = 0.2,
                YOffset = 0.85, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.3,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim@heists@fleeca_bank@drilling",
                    PropAnimation = "bag_drill_straight_fail",
                    SecondProp = 'ch_prop_ch_heist_drill',
                    SecondPropAnimationDict = "anim@heists@fleeca_bank@drilling",
                    SecondPropAnimation = "drill_straight_fail_drill_bit",
                }
            },
            [3] = {
                AnimDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                AnimAction = "exit",
                WaitTime = 3500,
                XOffset = 0.2,
                YOffset = 0.79, -- Changing the y offset moves forward and backward to set the best position to line up with the preview animation
                ZOffset = 0.3,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'hei_p_m_bag_var22_arm_s',
                    PropAnimationDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                    PropAnimation = "bag_exit",
                    SecondProp = 'ch_prop_ch_heist_drill',
                    SecondPropAnimationDict = "anim_heist@hs3f@ig9_vault_drill@laser_drill@",
                    SecondPropAnimation = "exit_drill_bit",
                }
            },
        }
    },
    [13] = {
        Name = "USB hack control pad device",
        NetworkedAnimations = { -- USB hack control pad device
            [1] = {
                AnimDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                AnimAction = "action_var_01",
                WaitTime = 6200,
                XOffset = 0.2,
                YOffset = 0.85, -- Adjust as needed for proper alignment
                ZOffset = 0.35,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309, -- Right hand
                    Prop = 'ch_prop_ch_usb_drive01x', -- USB drive
                    PropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    PropAnimation = "action_var_01_ch_prop_ch_usb_drive01x",
                    SecondProp = 'prop_phone_ing', -- Phone
                    SecondPropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    SecondPropAnimation = "action_var_01_prop_phone_ing",
                }
            },
            [2] = {
                AnimDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                AnimAction = "hack_loop_var_01",
                WaitTime = 7500,
                XOffset = 0.2,
                YOffset = 0.85,
                ZOffset = 0.35,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'ch_prop_ch_usb_drive01x', -- USB drive
                    PropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    PropAnimation = "hack_loop_var_01_ch_prop_ch_usb_drive01x",
                    SecondProp = 'prop_phone_ing', -- Phone
                    SecondPropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    SecondPropAnimation = "hack_loop_var_01_prop_phone_ing",
                }
            },
            [3] = {
                AnimDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                AnimAction = "success_react_exit_var_01",
                WaitTime = 3500,
                XOffset = 0.1,
                YOffset = 0.79,
                ZOffset = 0.35,
                AnimationOptions = {
                    AttachWaitDuration = 1500,
                    TimeUntilFreezePropPosition = 3000,
                    PropBone = 60309,
                    Prop = 'ch_prop_ch_usb_drive01x', -- USB drive
                    PropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    PropAnimation = "success_react_exit_var_01_ch_prop_ch_usb_drive01x",
                    SecondProp = 'prop_phone_ing', -- Phone
                    SecondPropAnimationDict = "anim_heist@hs3f@ig1_hack_keypad@arcade@male@",
                    SecondPropAnimation = "success_react_exit_var_01_prop_phone_ing",
                }
            },
        }
    },
    [14] = {
        Name = "Smash case",
        AnimDict = "missheist_jewel",
        AnimAction = "smash_case_b",
        EmoteMoving = true,
        SkipWaitTime = true,
    },
    [15] = {
        Name = "Money Grab",
        AnimDict = "anim@heists@ornate_bank@grab_cash_heels", -- Thermite and Bag scene
        AnimAction = "grab",
        XOffset = 0.3,
        YOffset = 0.4,
        ZOffset = 0.1,
        SkipWaitTime = true,
        ReplacePropMini = true, -- Make this true and it will delete the prop that this animation is used on.
        AnimationOptions = {
            AttachWaitDuration = 0,
            PropBone = 57005,
            PropPlacement = {0.0, 0.0, -0.16, 250.0, -30.0, 0.0},
            Prop = 'prop_cs_heist_bag_02',
            PropAnimationDict = "anim@heists@ornate_bank@grab_cash_heels",
            TimeUntilFreezePropPosition = 0,
        }
    },
    [16] = {
        Name = "Quick Grab",
        AnimDict = "anim@am_hold_up@male",
        AnimAction = "shoplift_mid",
        ReplacePropMini = true, -- Make this true and it will delete the prop that this animation is used on.
        SkipWaitTime = true,
    },
    [17] = {
        Name = "Welding",
        AnimDict = "WORLD_HUMAN_WELDING",
        IsScenario = true,
    },
    [18] = {
        Name = "Stand Mobile",
        AnimDict = "WORLD_HUMAN_STAND_MOBILE",
        IsScenario = true,
    },
    [19] = {
        Name = "Safe Crack",
        AnimDict = "mini@safe_cracking",
        AnimAction = "idle_base",
        SkipWaitTime = true,
    },
}

Config.RobberyAnimations = {} -- DO NOT DELETE THIS. VERY IMPORTANT
Config.MiniGames = { --  THE REST OF THE MINIGAMES ARE IN CONFIG.MINI GAMES. YOU CAN REALLY CUSTOMIZE MINI GAMES A LOT.
    ["none"] ={ -- NEVER REMOVE THIS ONE
        label = "None",
        Game = function()
            return true
        end,
    },
    ["numberpad"] ={ -- NEVER REMOVE THIS ONE
        label = "Number Pad (ONLY FOR THE PROP_LD_KEYPAD_01B PROP)",
        Game = function(stage, heist)
            -- Mini Game code here
            local result = promise.new()

            CreateThread(function()
                local success = DoNumberPadMiniGame(stage, heist)
                result:resolve(success)
            end)

            local won = Citizen.Await(result)
            return won
        end,
    },
    ["drilllaser"] ={
        label = "Laser Drill Mini Game",
        Game = function()
            local result = promise.new()

            StartDrilling(function(success)
                result:resolve(success)
            end, 'Laser')

            local won = Citizen.Await(result)
            return won
        end,
    },
    ["drillregular"] ={
        label = "Regular Drill Mini Game",
        Game = function()
            local result = promise.new()

            StartDrilling(function(success)
                result:resolve(success)
            end, 'Normal')

            local won = Citizen.Await(result)
            return won
        end,
    },
}
------------------------------