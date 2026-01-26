--[[
    Loot Table Configuration Guide

    1. Top‑Level Table
       • Config.lootRwards holds one sub‑table per rod or reward type (fishing, FishingRod2, FishingRod3, Fishing Lures, and Treassure Chest).

    2. Modes
       Each sub‑table has two modes:
       - tournament: when you’re in a tournament area
       - nonTournament: open‑water behavior

    3. specialItemDrops (list)
       • chance         = relative weight for this drop (higher = more likely)
       • item or callback = what to give (either an item name or a Lua function)
       • reputationRange = how much rep to award (min, max)

       To adjust rarity: bump the chance up or down.

    4. fishRollRange (number)
       The maximum roll used to pick from fishDropTable (roll is 1…fishRollRange).

       To make fish overall more or less rare, adjust this number and the ranges below.

    5. fishDropTable (list)
       Each entry has:
       • min, max           = roll range that triggers this fish
       • item               = fish/item name
       • reputation or reputationRange = rep given (fixed or range)
       • leaderboardRange   = leaderboard points (fixed or range)

       To add a new fish: copy an existing entry, change min/max, item, and reward values.

    6. defaultFishDrop
       Fallback if no fishDropTable entry matches. You can tweak its item and reputation.

    7. ChestRewards (optional)
       • rollRange = maximum roll for chest prizes
       • entries   = flat list of possible chest rewards (chance, item/money, min/max)

       To add a chest reward: append a new entry with your desired chance and item.

    Quick Tips
    - All “chance” values are weights, not percentages. The system picks a random number up to the rollRange (or fishRollRange) and finds the matching entry.
    - Keep ranges non‑overlapping and within the rollRange.
    - To make something super rare, give it a tiny chance or narrow min/max span.
]]
-- ====================
-- Loot Table Configuration
-- ====================
Config.lootRwards = {
    -- Tier 1: Starter Fishing Rod
    fishingrod = {

        -- Tournament-area loot behavior
        tournament = {
            
            -- Special items for open water
            --[[ 
                specialItemDrops use WEIGHTS (raffle tickets). Higher = more common.
                Total = 228 in this example:
                - ChestItem:       95/228 ≈ 41.7%
                - skillreel:      100/228 ≈ 43.9%
                - diamond:         10/228 ≈ 4.4%
                - emerald:          8/228 ≈ 3.5%
                - sapphire:         7/228 ≈ 3.1%
                - yellowdiamond:    6/228 ≈ 2.6%
                - captainskull:     2/228 ≈ 0.9%
            ]]
            specialDropChance = 5, -- 1% chance to roll any special
            specialItemDrops = {
                { chance = 95, item = Config.ChestItem,   reputationRange = {3, 5} },
                { chance = 100, item = "skillreel",        reputationRange = {4, 6} },
                { chance = 10,  item = "diamond",          reputationRange = {2, 3} },
                { chance = 8,   item = "emerald",          reputationRange = {2, 4} },
                { chance = 7,   item = "sapphire",         reputationRange = {2, 3} },
                { chance = 6,   item = "yellowdiamond",    reputationRange = {3, 5} },
                { chance = 2,   item = "captainskull",     reputationRange = {4, 6} },
            },

            -- Range for fish roll (1 to fishRollRange)
            fishRollRange = 200,

            -- Table of fish drops with odds ranges, reputation, and leaderboard points
            fishDropTable = {
                { min = 200, max = 200, item = "killerwhale",    reputation = 3, leaderboardRange = {15, 20} },
                { min = 195, max = 199, item = "anglerfish",     reputationRange = {2,  3}, leaderboardRange = {7, 12} },
                { min = 189, max = 194, item = "tigershark",     reputationRange = {2,  2}, leaderboardRange = {5, 11} },
                { min = 184, max = 188, item = "swordfish",      reputationRange = {1,  2}, leaderboardRange = {5, 11} },
                { min = 180, max = 183, item = "fishinghalibut", reputationRange = {1,  2}, leaderboardRange = {6, 10} },
                { min = 175, max = 179, item = "tunafish",       reputation = 1,            leaderboardRange = {4,  9} },
                { min = 170, max = 174, item = "catfish",        reputation = 1,            leaderboardRange = {4,  9} },
                { min = 166, max = 169, item = "salmon",         reputation = 1,            leaderboardRange = {4,  9} },
                { min = 162, max = 165, item = "largemouthbass", reputationRange = {1,  1}, leaderboardRange = {4,  8} },
                { min = 158, max = 161, item = "rockfish",       reputationRange = {1,  1}, leaderboardRange = {3,  6} },
                { min = 155, max = 157, item = "goldfish",       reputationRange = {1,  1}, leaderboardRange = {3,  6} },
                { min = 151, max = 154, item = "sockeyesalmon",  reputationRange = {0,  1}, leaderboardRange = {3,  6} },
                { min = 148, max = 150, item = "redfish",        reputation = 1,            leaderboardRange = {3,  6} },
                { min = 145, max = 147, item = "bluefish",       reputation = 1,            leaderboardRange = {3,  6} },
                { min = 142, max = 144, item = "crawfish",       reputation = 0,            leaderboardRange = {2,  5} },
                { min = 140, max = 141, item = "stripedbass",    reputation = 0,            leaderboardRange = {2,  5} },
                { min = 136, max = 139, item = "flyfish",        reputation = 0,            leaderboardRange = {2,  5} },
                { min = 130, max = 135, item = "mahimahi",       reputation = 0,            leaderboardRange = {2,  5} },
                { min = 125, max = 129, item = "oceansturgeon",  reputation = 0,            leaderboardRange = {1,  4} },
                { min = 120, max = 124, item = "tarponfish",     reputation = 0,            leaderboardRange = {1,  4} },
            },

            -- Default fish if no other entry matches
            defaultFishDrop = {
                item            = "fish",
                reputation      = 0,
                leaderboardRange = {1, 3},
            },
        },

        -- Non-tournament (open-water) loot behavior
        nonTournament = {

            -- Special items for open water
            --[[ 
                specialItemDrops use WEIGHTS (raffle tickets). Higher = more common.
                Total = 228 in this example:
                - ChestItem:       95/228 ≈ 41.7%
                - skillreel:      100/228 ≈ 43.9%
                - diamond:         10/228 ≈ 4.4%
                - emerald:          8/228 ≈ 3.5%
                - sapphire:         7/228 ≈ 3.1%
                - yellowdiamond:    6/228 ≈ 2.6%
                - captainskull:     2/228 ≈ 0.9%
            ]]
            specialDropChance = 1, -- 1% chance to roll any special
            specialItemDrops = {
                { chance = 95, item = Config.ChestItem,   reputationRange = {3, 5} },
                { chance = 100, item = "skillreel",        reputationRange = {3, 5} },
                { chance = 10,  item = "diamond",          reputationRange = {2, 3} },
                { chance = 8,   item = "emerald",          reputationRange = {2, 3} },
                { chance = 7,   item = "sapphire",         reputationRange = {2, 3} },
                { chance = 6,   item = "yellowdiamond",    reputationRange = {2, 4} },
                { chance = 2,   item = "captainskull",     reputationRange = {3, 5} },
            },


            fishRollRange = 200,
            fishDropTable = {
                { min = 200, max = 200, item = "killerwhale", reputation = 3 },
                { min = 196, max = 199, item = "anglerfish",  reputation = 2 },
                { min = 189, max = 195, item = "goldfish",    reputation = 1 },
                { min = 185, max = 188, item = "redfish",     reputation = 1 },
                { min = 181, max = 184, item = "bluefish",    reputation = 0 },
                { min = 178, max = 180, item = "mahimahi",    reputation = 0 },
                { min = 174, max = 177, item = "stripedbass", reputation = 0 },
                { min = 170, max = 173, item = "rockfish",    reputation = 0 },
                { min = 166, max = 169, item = "crawfish",    reputation = 0 },
                { min = 162, max = 165, item = "sockeyesalmon", reputation = 0 },
                { min = 158, max = 161, item = "fishinghalibut", reputation = 0 },
                { min = 154, max = 157, item = "tarponfish",  reputation = 0 },
                { min = 150, max = 153, item = "oceansturgeon", reputation = 0 },
                { min = 145, max = 149, item = "flyfish",     reputation = 0 },
                { min = 140, max = 144, item = "tunafish",    reputation = 0 },
                { min = 136, max = 139, item = "eelfish",     reputation = 0}, -- EEL DUD
                { min = 130, max = 135, item = "tigershark", reputation = 0 },
            },

            -- Default fish has a 10% chance to give 1 rep (reduced from 30%)
            defaultFishDrop = {
                item = "fish",
                reputationCondition = function()
                    return math.random(1, 10) <= 1 and 1 or nil
                end,
            },
        },
    },

    -- Tier 2: Skilled Fishing Rod
    fishingrod2 = {

        tournament = {
            specialDropChance = 10, -- 2% chance
            specialItemDrops = {
                { chance = 95, item = Config.ChestItem, reputationRange = {2,3} },
                { chance = 90,  callback = function() TriggerEvent("Pug:client:GiveLure") end,  reputationRange = {2,3} },
                { chance = 80,  callback = function() TriggerEvent("Pug:client:GiveLure2") end, reputationRange = {2,3} },
                { chance = 100, item = Config.ChestKey,  reputationRange = {2,4} },
                { chance = 60,  item = "bottlemap",      reputationRange = {5,7} },
                { chance = 30,  item = "proreel",        reputationRange = {3,4} },
                { chance = 10,  item = "diamond",        reputationRange = {2,3} },
                { chance = 8,   item = "emerald",        reputationRange = {2,4} },
                { chance = 6,   item = "sapphire",       reputationRange = {2,3} },
                { chance = 4,   item = "yellowdiamond",  reputationRange = {3,5} },
                { chance = 2,   item = "captainskull",   reputationRange = {4,6} },
            },

            fishRollRange = 200,
            fishDropTable = {
                { min = 200, max = 200, item = "killerwhale",    reputationRange = {3,4}, leaderboardRange = {15,20} },
                { min = 196, max = 199, item = "anglerfish",     reputationRange = {2, 3}, leaderboardRange = {8,15} },
                { min = 192, max = 195, item = "tigershark",     reputation = 2,            leaderboardRange = {8,15} },
                { min = 187, max = 191, item = "tunafish",       reputationRange = {1,2},   leaderboardRange = {4,9} },
                { min = 182, max = 186, item = "swordfish",      reputationRange = {1,1},   leaderboardRange = {5,11} },
                { min = 177, max = 181, item = "fishinghalibut", reputationRange = {1, 2}, leaderboardRange = {5, 10} },
                { min = 171, max = 176, item = "catfish",        reputationRange = {1,1},   leaderboardRange = {4,9} },
                { min = 165, max = 170, item = "salmon",         reputationRange = {0,1},   leaderboardRange = {4,9} },
                { min = 159, max = 164, item = "largemouthbass", reputationRange = {0,1}, leaderboardRange = {4,8} },
                { min = 153, max = 158, item = "rockfish",       reputationRange = {0,1}, leaderboardRange = {3,6} },
                { min = 147, max = 152, item = "goldfish",       reputationRange = {0,1}, leaderboardRange = {3,6} },
                { min = 141, max = 146, item = "redfish",        reputationRange = {0,1}, leaderboardRange = {3,6} },
                { min = 136, max = 140, item = "flyfish",        reputation = 0,           leaderboardRange = {3,6} },
                { min = 130, max = 135, item = "stripedbass",    reputation = 0,           leaderboardRange = {2,5} },
                { min = 125, max = 129, item = "mahimahi",       reputation = 0,           leaderboardRange = {2,5} },
                { min = 120, max = 124, item = "oceansturgeon",  reputation = 0,           leaderboardRange = {1,4} },
                { min = 115, max = 119, item = "sockeyesalmon",  reputation = 0,           leaderboardRange = {1,4} },
                { min = 110, max = 114, item = "tarponfish",     reputation = 0,           leaderboardRange = {1,4} },
                { min = 105, max = 109, item = "crawfish",       reputation = 0,           leaderboardRange = {1,4} },
                { min = 100, max = 104, item = "eelfish"         }, -- EEL DUD
            },

            defaultFishDrop = { item = "fish", reputation = 0, leaderboardRange = {1,3} },
        },

        nonTournament = {
            specialDropChance = 5, -- 2% chance
            specialItemDrops = {
                { chance = 100, item = Config.ChestItem, reputationRange = {2,4} },
                { chance = 90,  callback = function() TriggerEvent("Pug:client:GiveLure") end, reputationRange = {2,3} },
                { chance = 80,  callback = function() TriggerEvent("Pug:client:GiveLure2") end, reputationRange = {2,3} },
                { chance = 95, item = "proreel",       reputationRange = {2,4} },
                { chance = 10,  item = "diamond",       reputationRange = {2,3} },
                { chance = 8,   item = "emerald",       reputationRange = {2,3} },
                { chance = 6,   item = "sapphire",      reputationRange = {2,3} },
                { chance = 4,   item = "yellowdiamond", reputationRange = {3,4} },
                { chance = 2,   item = "captainskull",  reputationRange = {4,6} },
            },

            fishRollRange = 200,
            fishDropTable = {
                { min = 200, max = 200, item = "killerwhale", reputation = 4 },
                { min = 196, max = 199, item = "anglerfish",  reputation = 3 },
                { min = 192, max = 195, item = "tigershark",  reputationRange = {2,2} },
                { min = 187, max = 191, item = "swordfish",   reputationRange = {1,2} },
                { min = 181, max = 186, item = "fishinghalibut", reputationRange = {1,2} },
                { min = 175, max = 180, item = "tunafish",    reputation = 1 },
                { min = 169, max = 174, item = "catfish",     reputation = 1 },
                { min = 163, max = 168, item = "salmon",      reputation = 1 },
                { min = 157, max = 162, item = "largemouthbass", reputation = 1 },
                { min = 151, max = 156, item = "rockfish",    reputation = 1 },
                { min = 146, max = 150, item = "goldfish",    reputation = 1 },
                { min = 140, max = 145, item = "bluefish",    reputation = 0 },
                { min = 136, max = 139, item = "sockeyesalmon", reputation = 0 },
                { min = 130, max = 135, item = "tarponfish",  reputation = 0 },
                { min = 125, max = 129, item = "mahimahi",    reputation = 0 },
                { min = 120, max = 124, item = "flyfish",     reputation = 0 },
                { min = 115, max = 119, item = "crawfish",    reputation = 0 },
                { min = 110, max = 114, item = "eelfish",     reputation = 0}, -- EEL DUD
                { min = 105, max = 109, item = "tigershark", reputation = 0 }  -- fallback
            },

            defaultFishDrop = { item = "fish", reputation = 0 },
        },
    },

    -- Tier 3: Pro Fishing Rod
    fishingrod3 = {
        tournament = {
            specialDropChance = 15, -- 3% chance
            specialItemDrops = {
                { chance = 95, item = Config.ChestItem,      reputationRange = {4,6} },
                { chance = 80,  callback = function() TriggerEvent("Pug:client:GiveLure") end, reputationRange = {3,4} },
                { chance = 90,  callback = function() TriggerEvent("Pug:client:GiveLure2") end, reputationRange = {3,4} },
                { chance = 100, item = Config.ChestKey,      reputationRange = {4,6} },
                { chance = 120, item = "bottlemap",          reputationRange = {5,8} },
                { chance = 15,  item = "diamond",            reputationRange = {2,4} },
                { chance = 12,  item = "emerald",            reputationRange = {3,4} },
                { chance = 9,   item = "sapphire",           reputationRange = {2,4} },
                { chance = 7,   item = "yellowdiamond",      reputationRange = {4,6} },
                { chance = 3,   item = "captainskull",       reputationRange = {5,7} },
            },

            fishRollRange = 200,
            fishDropTable = {
                { min = 200, max = 200, item = "killerwhale",    reputationRange = {4,6}, leaderboardRange = {15,20} },
                { min = 197, max = 199, item = "anglerfish",     reputationRange = {3,4},  leaderboardRange = {10,15} },
                { min = 194, max = 196, item = "eelfish",        reputation = 0,            leaderboardRange = 0 },
                { min = 190, max = 193, item = "tunafish",       reputationRange = {2,3},   leaderboardRange = {4,9} },
                { min = 185, max = 189, item = "swordfish",      reputationRange = {2,3},   leaderboardRange = {5,11} },
                { min = 179, max = 184, item = "fishinghalibut", reputationRange = {2,3},   leaderboardRange = {5,10} },
                { min = 173, max = 178, item = "largemouthbass", reputationRange = {2,3},   leaderboardRange = {4,8} },
                { min = 167, max = 172, item = "tigershark",     reputationRange = {2,3},   leaderboardRange = {5,11} },
                { min = 161, max = 166, item = "salmon",         reputationRange = {1,2},   leaderboardRange = {4,9} },
                { min = 156, max = 160, item = "catfish",        reputationRange = {1,2},   leaderboardRange = {4,9} },
                { min = 150, max = 155, item = "rockfish",       reputationRange = {1,2},   leaderboardRange = {4,8} },
                { min = 144, max = 149, item = "goldfish",       reputationRange = {1,2},   leaderboardRange = {3,6} },
                { min = 138, max = 143, item = "redfish",        reputationRange = {1,1},   leaderboardRange = {3,6} },
                { min = 132, max = 137, item = "flyfish",        reputationRange = {0,1},   leaderboardRange = {3,6} },
                { min = 126, max = 131, item = "stripedbass",    reputation = 0,          leaderboardRange = {2,5} },
                { min = 120, max = 125, item = "mahimahi",       reputation = 0,            leaderboardRange = {1,4} },
                { min = 115, max = 119, item = "oceansturgeon",  reputation = 0,            leaderboardRange = {1,4} },
                { min = 110, max = 114, item = "sockeyesalmon",  reputation = 0,            leaderboardRange = {1,4} },
                { min = 105, max = 109, item = "tarponfish",     reputation = 0,            leaderboardRange = {1,4} },
                { min = 100, max = 104, item = "crawfish",       reputation = 0,            leaderboardRange = {1,4} },
                { min =  95, max =  99, item = "fishinghalibut", reputation = 0,            leaderboardRange = {1,4} },
                { min =  90, max =  94, item = "eelfish"         },  -- EEL DUD
            },
            defaultFishDrop = {
                item            = "fish",
                reputation      = 0,
                leaderboardRange = {1,3},
            },
        },

        nonTournament = {
            specialDropChance = 10, -- 3% chance
            specialItemDrops = {
                { chance = 95, item = Config.ChestItem,      reputationRange = {4,7} },
                { chance = 80,  callback = function() TriggerEvent("Pug:client:GiveLure") end, reputationRange = {3,4} },
                { chance = 90,  callback = function() TriggerEvent("Pug:client:GiveLure2") end, reputationRange = {3,4} },
                { chance = 100, item = Config.ChestKey,      reputationRange = {4,7} },
                { chance = 120, item = "bottlemap",          reputationRange = {5,8} },
                { chance = 15,  item = "diamond",            reputationRange = {2,4} },
                { chance = 12,  item = "emerald",            reputationRange = {3,5} },
                { chance = 9,   item = "sapphire",           reputationRange = {2,4} },
                { chance = 7,   item = "yellowdiamond",      reputationRange = {4,6} },
                { chance = 3,   item = "captainskull",       reputationRange = {5,8} },
            },

            fishRollRange = 120,
            fishDropTable = {
                { min = 120, max = 120, item = "killerwhale", reputationRange = {5,7} },
                { min = 118, max = 119, item = "anglerfish", reputationRange = {4,6}   }, -- top tier special fish
                { min = 117, max = 117, item = "tigershark", reputationRange = {3,4} },
                { min = 116, max = 116, item = "catfish",    reputationRange = {2,3} },
                { min = 115, max = 115, item = "swordfish", reputationRange = {2,3} },
                { min = 113, max = 114, item = "fishinghalibut", reputationRange = {2,3} },
                { min = 110, max = 112, item = "salmon",     reputationRange = {2,3} },
                { min = 107, max = 109, item = "largemouthbass", reputationRange = {2,2} },
                { min = 104, max = 106, item = "rockfish",   reputationRange = {1,2} },
                { min = 101, max = 103, item = "goldfish",   reputationRange = {1,2} },
                { min =  98, max = 100, item = "redfish",    reputationRange = {1,1} },
                { min =  95, max =  97, item = "bluefish",   reputationRange = {1,1} },
                { min =  92, max =  94, item = "stripedbass", reputationRange = {1,1} },
                { min =  89, max =  91, item = "mahimahi",   reputationRange = {0,1} },
                { min =  86, max =  88, item = "oceansturgeon", reputationRange = {0,1} },
                { min =  83, max =  85, item = "flyfish",    reputationRange = {0,1} },
                { min =  80, max =  82, item = "sockeyesalmon", reputation = 0 },
                { min =  77, max =  79, item = "tarponfish", reputation = 0 },
                { min =  74, max =  76, item = "crawfish",   reputation = 0 },
                { min =  70, max =  73, item = "eelfish"     }, -- EEL DUD
            },
            defaultFishDrop = { item = "fish", reputation = 0 },
        },
    },

    -- Tier Lure: Special lure-only rod (no tournament use)
    fishinglure = {
        tournament = nil,
        nonTournament = {
            specialItemDrops = {
                { chance = 200, item = Config.ChestItem, reputationRange = {10,20} },
                { chance = 100, callback = function() TriggerEvent("Pug:client:GiveLure") end, reputationRange = {7,10} },
                { chance = 150, callback = function() TriggerEvent("Pug:client:GiveLure2") end, reputationRange = {7,10} },
                { chance = 300, item = Config.ChestKey, reputationRange = {10,20} },
                { chance = 400, item = "bottlemap",      reputationRange = {10,20} },
            },
            fishRollRange = 120,
            fishDropTable = {
                { min = 120, max = 120, item = "tunafish",       reputationRange = {10,20} },
                { min = 118, max = 119, item = "anglerfish"                                },
                { min = 117, max = 117, item = "tigershark",     reputationRange = {5,10} },
                { min = 116, max = 116, item = "tigershark",     reputationRange = {3,5} },
                { min = 115, max = 115, item = "fishinghalibut", reputationRange = {3,5} },
                { min = 113, max = 114, item = "salmon",         reputationRange = {3,5} },
                { min = 110, max = 112, item = "largemouthbass", reputationRange = {3,5} },
                { min = 107, max = 109, item = "killerwhale",    reputationRange = {3,5} },
                { min = 104, max = 106, item = "redfish",        reputationRange = {3,4} },
                { min = 101, max = 103, item = "bluefish",       reputationRange = {3,5} },
                { min =  98, max = 100, item = "stripedbass",    reputationRange = {2,3} },
                { min =  95, max =  97, item = "mahimahi",       reputationRange = {2,3} },
                { min =  92, max =  94, item = "rockfish",       reputationRange = {2,3} },
                { min =  89, max =  91, item = "crawfish",       reputationRange = {2,3} },
                { min =  86, max =  88, item = "flyfish",        reputationRange = {2,3} },
                { min =  83, max =  85, item = "oceansturgeon",  reputationRange = {2,3} },
                { min =  80, max =  82, item = "sockeyesalmon",  reputationRange = {2,3} },
                { min =  77, max =  79, item = "tarponfish",     reputationRange = {2,3} },
                { min =  75, max =  76, item = "eelfish"         }, -- EEL DUD
            },
            defaultFishDrop = {
                item = "tigershark",
                reputationRange = {2,3},
            },
        },
    },

    -- add ChestRewards if you would like too
    ChestRewards = {
        -- maximum value for the roll
        rollRange = 100,

        -- flat list of reward entries
        entries = {
            { chance = 30, item = 'emerald',       min = 1, max = 4 },
            { chance = 30, item = 'diamond',       min = 1, max = 4 },
            { chance = 30, item = 'ruby',          min = 1, max = 4 },
            { chance = 30, item = 'sapphire',      min = 1, max = 3 },
            { chance = 25, item = 'yellowdiamond', min = 1, max = 4 },
            { chance = 3,  item = 'captainskull',  min = 1, max = 1 },
            { chance = 1,  item = Config.ChestKey,  min = 1, max = 1 },
            { chance = 30, item = 'rolex',         min = 1, max = 5 },
            { chance = 40, item = 'diamond_ring',  min = 1, max = 7 },
            { chance = 1,  item = 'bottlemap',     min = 1, max = 1 },
            { chance = 4,  item = 'fishinglure',   min = 1, max = 1 },
            { chance = 1,  item = 'fishinglure2',  min = 1, max = 1 },
            { chance = 10, item = 'weapon_pistol', min = 1, max = 1 },
            { chance = 55, money = true,           min = 500, max = 3500 },
            { chance = 1,  item = Config.SuperRareitem, min = 1, max = 1 },
        },
    },


    CrabTrap = {
        fishRollRange = 100,

        fishDropTable = {
            -- Common crab rewards
            { min = 96,  max = 100, item = "snowcrab" },
            { min = 91,  max = 95,  item = "dungenesscrab" },
            { min = 86,  max = 90,  item = "redcrab" },
            { min = 81,  max = 85,  item = "rockcrab" },
            { min = 76,  max = 80,  item = "bluecrab" },
            { min = 70,  max = 75,  item = "crawfish" },

            -- Occasional bycatch
            { min = 64,  max = 69,  item = "fishinghalibut" },
            { min = 58,  max = 63,  item = "rockfish" },
            { min = 52,  max = 57,  item = "mahimahi" },

            -- Rare sea junk or treasure
            { min = 48,  max = 51,  item = "bottlemap" },
            { min = 44,  max = 47,  item = "captainskull" },
        },

        defaultFishDrop = {
            item = "crawfish"
        }
    },


}
