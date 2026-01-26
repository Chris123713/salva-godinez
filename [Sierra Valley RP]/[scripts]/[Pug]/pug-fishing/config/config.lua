-- ========================================================================
-- 🎣 Pug Fishing Config
-- ========================================================================

-- Change this single value to swap language at runtime
Config.Language = 'en'   --  'ar','bg','ca','cs','da','de','el','en','es','fa','fr','hi','hu',
                         --  'it','ja','ko','nl','no','pl','pt','ro','ru','sl','sv','th','tr',
                         --  'zh-CN','zh-TW'


-- 🎒 Prop used during the fish-catching animation
Config.BagProp = "prop_med_bag_01" -- some servers have this prop to a wheelchair for some reason.....

-- 🎮 Fishing Interaction
Config.FishingKey = 38 -- [E] Key to start fishing. Find key IDs here: https://docs.fivem.net/docs/game-references/controls/

-- 🛠️ General Toggles
Config.DevMode = false -- Enables developer mode making the fishing rods have 0 wait time to capture fish so that you can spam it to test things
Config.Debug = false -- Enables debug zones using polyzones
Config.BoatRequired = false -- If true, players must be on a boat to fish
Config.EnableScreenShake = true --  Make this false if you do not want the screen shake effect to happen as an intensity when fishing.
Config.LockedZones = false -- If true, players can ONLY fish in the defined zones in `Config.LockedLocationFishingZone`
Config.LockInventory = false -- Locks player inventory while fishing; unlocks after the catch
Config.TreasureChestCompleteMiniGame = true -- Set to false to disable minigame when opening chests
Config.SetWayPointToTreasure = false -- If true, a waypoint will be set to the treasure location when using the map
Config.RemoveFishingRepWhenCraftRod = true -- Removes XP used when crafting a rod
Config.ShowAllFishToSellInMenu = false -- If false, only fish currently in the players inventory will be shown in the sell menu

-- 💎 Gem Shop Setup
Config.GemsBuyingPed = `a_m_m_hasjew_01`
Config.GemsBuyingPedLoc = vector4(-1816.64, -1193.78, 14.3, 334.81)

-- 👨‍✈️ Fisherman Setup
Config.MainFisherManPed = `s_f_y_baywatch_01` -- Ped that appears at lifeguard zones (Config.LifeGuardLocations locations)
Config.SellFishTime = { MinimumTime = 2, MaximumTime = 4 } -- Time in seconds it takes to sell per fish, this multiplies if you sell more and more fish

-- 🦀 Crab Shop Setup
Config.CrabBuyingPed = `a_m_m_farmer_01` -- or any other ped model
Config.CrabBuyingPedLoc = vector4(2848.28, 4450.16, 48.51, 106.79) -- replace with your coordinates

-- 🔧 Fishing Rod Crafting Location
Config.CrafingRodLocation = vector4(1307.66, 4229.85, 33.92, 348.01)

-- 🗝️ Key Mechanics
Config.ChanceToLoseKey = 30 -- % chance to lose your key when failing a chest mini-game

-- 🎣 Fishing Net Limits
Config.AmountOfFishingNetsPerPerson = 1 -- Maximum number of fishing nets a single player can place at once
-- 🦀 Crab Trap Limits
Config.AmountOfCrabTrapsPerPerson = 1 -- Maximum number of crab traps a single player can have active at once

-- ⚓ Deap Sea Settings
Config.DeepSeaDistanceOut = 1000.0 -- Distance out in the water the player needs to be from the coast line

-- 🐟 Biting Wait Times
Config.WaitForFishToBiteMin = 10 -- Min wait in seconds
Config.WaitForFishToBiteMax = 30 -- Max wait in seconds

-- 🔥 Hot Spot Zone Times
Config.HotSpotZoneRadius = 100.0 -- Radius of the hot spot zone
Config.HotZoneLocationActive = { Min = 30, Max = 45 } -- (MINUTES) Time in minute that the hotzone location last for
Config.HotZoneLocationCooldown = { Min = 30, Max = 45 } -- (MINUTES) Time in minute that the hotzone location is on cooldown for

-- 🔥 Cooking Config
Config.CookFishTime = { MinimumTime = 8, MaximumTime = 18 } -- Time in seconds per fish cooked

-- 🎯 General Items
Config.FishingBait = 'fishingbait' -- Bait Item Required To Fish
Config.ChestKey = 'chestkey' -- Key Item To Open Treasure Chest
Config.ChestItem = 'treasurechest' -- Trassure Chest Item
Config.SuperRareitem = 'actualbrain' -- Ultra-rare item found in treasure chests

-- 🕸️ Fishing Net Settings
Config.netLifetimeMinutes = 40 -- Net despawns after this many minutes
Config.netLootInterval = { MinAmount = 30, MaxAmount = 90 } -- (SECONDS) How many seconds it takes for a fish to be caught in the fish net [WITH THIS SETUP THE PLAYER CAN CATCH ABOUT 40 ITEMS WITH THE NET IN 40 MINUTES ON AVERAGE]
Config.maxFishingNets = 20 -- Maximum amount of fishing nets allowed to be spawned on the server at once
Config.MaxFishingNetBait = 30 -- Maximum amount of bait a player can put into a fishing net at one time

-- 🕸️ Fishing Crab Trap Settings
Config.crabTrapLifetimeMinutes = 20 -- Crab Trap despawns after this many minutes
Config.crabTrapLootInterval = { MinAmount = 25, MaxAmount = 55 } -- (SECONDS) How many seconds it takes for a fish to be caught in the fish crab trap [WITH THIS SETUP THE PLAYER CAN CATCH ABOUT 40 ITEMS WITH THE CRAB TRAP IN 40 MINUTES ON AVERAGE]
Config.maxFishingCrabTrap = 20 -- Maximum amount of fishing crab traps allowed to be spawned on the server at once
Config.MaxFishingCrabTrapBait = 20 -- Maximum amount of bait a player can put into a fishing crab trap at one time

-- 🔥 Fireplaces
Config.MaxFireplaces = 10 -- Global limit across all players
Config.PerfectlyCookedFishChance = 20 -- % chance of receiving a “perfectly cooked” fish item

-- 🎣 Fishing lure rods
Config.FishingLureRods = { -- These are the rods that you can use the fishing lures with
    -- "fishingrod1",
    -- "fishingrod2",
    "fishingrod3"
}

-- 🎣 Fishing Station Blip
Config.FishingStationBlip = {
    enabled = true,                 -- Show the blip on the map
    label = "Fishing Station",        -- Text label for the blip
    sprite = 68,                    -- Blip icon (68 = seafood restaurant / fitting icon)
    scale = 0.8,                    -- Blip size (0.7–1.0 recommended)
    color = 33,                     -- Blip color (29 = teal/ocean tone)
    shortRange = true,             -- Only visible when nearby
}

-- 🦀 Crab Buyer Blip
Config.CrabBuyerBlip = {
    enabled = true,                     -- Toggle blips for all fishing station locations
    label = "Crab Merchant",          -- Name shown on the map
    sprite = 356,                       -- Blip icon (356 = fish market/fishing style)
    scale = 0.75,                       -- Size of the blip
    color = 33,                         -- Blip color (33 = light blue)
    shortRange = true,                  -- Only show when nearby
}

-- 💎 Gems Buyer Blip
Config.GemsBuyerBlip = {
    enabled = true,                -- Toggle the blip on/off
    label = "Gem Buyer",           -- Name shown on the map
    sprite = 617,                  -- Blip icon (617 = collectible or market-style)
    scale = 0.7,                   -- Size of the blip
    color = 46,                    -- Blip color (46 = purple)
    shortRange = true,             -- Only show when nearby
}


-- 🗺️ Fishing Skill System & Upgrades
Config.FishingSkillUpgrades = {
    biteSpeed = {
        [1] = { rep = 250,  cash = 1000 },
        [2] = { rep = 500, cash = 2500 },
        [3] = { rep = 1000, cash = 3500 }
    },
    rareChance = {
        [1] = { rep = 500,  cash = 1000 },
        [2] = { rep = 1000, cash = 2500 },
        [3] = { rep = 2000, cash = 3500 }
    },
    treasureHunter = {
        [1] = { rep = 750, cash = 1000 },
        [2] = { rep = 1000, cash = 2500 },
        [3] = { rep = 1500, cash = 3500 }
    }
}

-- 🛠️ Bite Speed Skill Upgrade Amount
Config.BiteSpeedReductionPerTier = {
    [0] = 0.0,   -- no reduction
    [1] = 0.15,  -- 15% faster
    [2] = 0.30,  -- 30% faster
    [3] = 0.45   -- 45% faster
}
-- 🛠️ Treasure Hunter Skill Upgrade Rates
Config.TreasureDropChances = {
    [0] = 250,  -- 1 in 250
    [1] = 175,  -- 1 in 175
    [2] = 100,  -- 1 in 100
    [3] = 50    -- 1 in 50
}
-- 🛠️ Rare Artifacts Skill Upgrade Rates
Config.RareFishDropChances = {
    [0] = 300,  -- 1 in 300
    [1] = 200,  -- 1 in 200
    [2] = 125,  -- 1 in 125
    [3] = 75    -- 1 in 75
}

-- 🪓 Trowl Loot Config
-- Items that can be dug up using a trowl. Add new items as needed.
-- Weight = how likely the item is to drop (higher is more likely).
Config.TrowlProgressBarTime = 17 -- Time in seconds to complete shovel progress bar
Config.TrowlItems = {
    ["fishingbait"] = { MinAmount = 1, MaxAmount = 3, Weight = 85 }, -- 🟢 Common
    ["diamond"] = { MinAmount = 1, MaxAmount = 1, Weight = 2 },      -- 🔴 Rare
    ["emerald"] = { MinAmount = 1, MaxAmount = 1, Weight = 2 },
    ["sapphire"] = { MinAmount = 1, MaxAmount = 1, Weight = 2 },
    ["ruby"] = { MinAmount = 1, MaxAmount = 1, Weight = 2 },
    ["yellowdiamond"] = { MinAmount = 1, MaxAmount = 1, Weight = 2 },
    ["captainskull"] = { MinAmount = 1, MaxAmount = 1, Weight = 1 },
    -- Add more loot options here
}

-- 🗺️ Lifeguard NPC & Boat Spawn Zones
Config.LifeGuardLocations = {
    AlamoSea = {
        LifeGuard = vector4(1304.34, 4229.44, 33.91, 36.66), -- Where the main fishing hub location ped spawns
        BoatSpawns = {
            vector4(1292.12, 4222.53, 30.68, 166.68),
            vector4(1294.98, 4237.0, 30.25, 167.24),
            vector4(1300.08, 4211.69, 30.56, 262.82),
        }
    },
    Pier = {
        LifeGuard = vector4(-3428.37, 968.45, 8.35, 269.97), -- Where the main fishing hub location ped spawns
        BoatSpawns = {
            vector4(-3423.69, 948.18, 0.94, 96.69),
            vector4(-3414.69, 948.48, 0.74, 96.65),
        }
    },
    PaletoCove = {
        LifeGuard = vector4(-1592.22, 5201.61, 4.31, 293.82), -- Where the main fishing hub location ped spawns
        BoatSpawns = {
            vector4(-1603.11, 5260.78, 0.58, 24.2),
            vector4(-1598.36, 5250.23, 0.54, 24.2),
            vector4(-1593.74, 5239.95, 0.63, 24.2),
        }
    },
    ElGordaDrive = {
        LifeGuard = vector4(3866.98, 4462.46, 2.73, 62.95), -- Where the main fishing hub location ped spawns
        BoatSpawns = {
            vector4(3858.09, 4455.99, 0.1, 270.83),
            vector4(3849.63, 4455.83, 0.12, 270.98),
            vector4(3863.99, 4468.09, 0.12, 268.22),
            vector4(3856.28, 4468.34, 0.11, 268.21),
            vector4(3872.95, 4463.98, 0.12, 269.29),
        }
    },
    -- Add more lifeguard locations here
}

-- 🔥 Hotspot Fishing Zones
Config.HotspotConfig = {
    -- Add as many hotspot vector3s as you'd like
    vector3(2278.96, 4133.27, 29.28),
    vector3(-2282.46, -893.32, 1.98),
    vector3(-2438.37, 4781.98, 1.21),
    vector3(2058.46, -3034.77, -0.42),
}

-- 🚤 Boat Purchase Options
Config.Boats = {
    { model = 'dinghy',  name = 'Dinghy',  xpRequired = 0,   storage = 55000,  slots = 5,  cost = 7500, image = "https://static.wikia.nocookie.net/gtawiki/images/b/b4/Dinghy4-GTAV-front.png" },
    { model = 'marquis', name = 'Marquis', xpRequired = 100, storage = 75000,  slots = 10, cost = 18000, image = "https://static.wikia.nocookie.net/gtawiki/images/2/22/Marquis-GTAV-front.png" },
    { model = 'squalo',  name = 'Squalo',  xpRequired = 250, storage = 100000, slots = 15, cost = 45000, image = "https://static.wikia.nocookie.net/gtawiki/images/3/37/Squalo-GTAV-front.png" },
    { model = 'toro',    name = 'Toro',    xpRequired = 500, storage = 150000, slots = 25, cost = 85000, image = "https://static.wikia.nocookie.net/gtawiki/images/9/95/Toro-GTAV-front.png" },
}

-- 🛒 Equipment Shop
Config.FishingEquipment = {
    { item = "fishingrod",       price = 350, xpRequired = 0  },
    { item = "fishingbait",      price = 25, xpRequired = 0  },
    { item = "fishinglure",      price = 1500, xpRequired = 0 },
    { item = "fishinglure2",     price = 3000, xpRequired = 0 },
    { item = "fishingtrowl",     price = 500, xpRequired = 0  },
    { item = "fishingfireplace", price = 750, xpRequired = 0 },
    { item = "fishinganchor",    price = 400, xpRequired = 0  },
    { item = "fishinglog",       price = 350, xpRequired = 0  },
    { item = "fishingcrabtrap",  price = 1200, xpRequired = 100 },
    { item = "fishingnet",       price = 2000, xpRequired = 200 },
}


-- 🚫 Blacklisted Fishing Areas
Config.BlacklistedLocation = {
    vector3(-504.05, 486.44, 107.43), -- Example: pool area
    -- Add more vector3 coordinates to restrict fishing
}

-- 🎯 Locked Fishing Zones (only used if Config.LockedZones is true)
Config.LockedLocationFishingZone = {
    ["LockedZone1"] = {
        center = vector3(-1758.8, 4535.23, 6.72),
        radius = 100.0
    },
    -- Add more zones here
}

-- 🧠 XP Ranks (used in crafting + rewards)
Config.XPRanks = {
    { min = 0,     max = 99,   rank = "Beginner" },
    { min = 100,   max = 199,  rank = "Rookie" },
    { min = 200,   max = 349,  rank = "Angler" },
    { min = 350,   max = 499,  rank = "Skilled" },
    { min = 500,   max = 699,  rank = "Veteran" },
    { min = 700,   max = 849,  rank = "Master" },
    { min = 850,   max = 999,  rank = "Legend" },
    { min = 1000,  max = 1000, rank = "Mythic" }
}

-- 🛠️ All Fishing Rod Fishing Settings
-- You can add unlimited rods here. Each rod controls its own minigame difficulty, speed, and visual colors.
-- If a rod isn't found, it will use the "default" settings below.
Config.FishingRods = {
    default = {
        name = "Default Rod",                           -- Display name (used as fallback if rod isn't listed)
        sweetSpotStart = 85,                            -- The percentage where the "sweet spot" begins (higher = harder)
        sweetSpotEnd = 100,                             -- The percentage where the "sweet spot" ends
        sweetSpotLength = 10,                           -- Width of the sweet spot (smaller = more precise timing)
        minigameSpeed = 0.0005,                         -- Speed that the progress bar moves (lower = slower movement)
        attemptsMin = 4,                                -- Minimum number of successful catches required
        attemptsMax = 8,                                -- Maximum number of successful catches required
        colors = {                                      -- Colors for the minigame circle UI
            base = "rgba(255, 255, 255, 1)",            -- Main ring color
            sweet = "rgba(255, 255, 255, 0.5)",         -- Highlight color for the sweet spot
            backdrop = "rgba(255, 255, 255, 0.15)",     -- Background circle color
        },
    },
    -- 🎣 Basic Fishing Rod (Beginner)
    ["fishingrod"] = {
        name = "Basic Fishing Rod",                     -- Name shown in menus/notifications
        sweetSpotStart = 85,                            -- Hardest timing window start
        sweetSpotEnd = 100,                             -- End of sweet spot
        sweetSpotLength = 10,                           -- Very small margin for success
        minigameSpeed = 0.0005,                         -- Slowest bar movement (beginner difficulty)
        attemptsMin = 4,                                -- Needs 4–8 successful skillchecks
        attemptsMax = 8,
        colors = {
            base = "rgba(255, 255, 255, 1)",            -- White base color
            sweet = "rgba(255, 255, 255, 0.5)",         -- Semi-transparent white sweet spot
            backdrop = "rgba(255, 255, 255, 0.15)",     -- Faint white background
        },
    },
    -- 🪝 Skilled Fishing Rod (Intermediate)
    ["fishingrod2"] = {
        name = "Skilled Fishing Rod",
        sweetSpotStart = 80,                            -- Slightly easier sweet spot start
        sweetSpotEnd = 100,
        sweetSpotLength = 20,                           -- Larger timing window than basic rod
        minigameSpeed = 0.001,                          -- Faster bar movement
        attemptsMin = 3,                                -- Needs 3–7 successful skillchecks
        attemptsMax = 7,
        colors = {
            base = "rgba(205, 127, 50, 1)",             -- Bronze base color
            sweet = "rgba(205, 127, 50, 0.5)",          -- Bronze sweet spot
            backdrop = "rgba(205, 127, 50, 0.15)",      -- Bronze background glow
        },
    },
    -- 🐟 Professional Fishing Rod (Advanced)
    ["fishingrod3"] = {
        name = "Professional Rod",
        sweetSpotStart = 70,                            -- Easiest sweet spot start
        sweetSpotEnd = 100,
        sweetSpotLength = 30,                           -- Widest timing window (most forgiving)
        minigameSpeed = 0.001,                          -- Faster bar movement but easy sweet spot
        attemptsMin = 2,                                -- Only 2–6 successful skillchecks required
        attemptsMax = 6,
        colors = {
            base = "rgba(255, 215, 0, 1)",              -- Gold base color
            sweet = "rgba(255, 215, 0, 0.5)",           -- Gold sweet spot
            backdrop = "rgba(255, 215, 0, 0.15)",       -- Gold background
        },
    },
}


-- 🛠️ Rod Crafting Requirements
Config.CraftRods = {
    ["fishingrod2"] = {
        name = "Skilled Fishing Rod",
        requiredRank = "Angler",
        price = 3500,
        requirements = {
            { item = "fishingrod", amount = 1 },
            { item = "skillreel",  amount = 1 },
        },
    },
    ["fishingrod3"] = {
        name = "Professional Rod",
        requiredRank = "Veteran",
        price = 8000,
        requirements = {
            { item = "fishingrod2", amount = 1 },
            { item = "proreel",     amount = 1 },
        },
    },
}

-- 🐟 Fish Sell Prices (~$4,000/hr target at 40 fish/hr = ~$100 avg for common)
Config.SellFishies = {
    -- Common fish (most caught) - ~$80-130 avg
    ["fish"] = { pricemin = 70, pricemax = 100 },
    ["crawfish"] = { pricemin = 75, pricemax = 105 },
    ["stripedbass"] = { pricemin = 85, pricemax = 115 },
    ["bluefish"] = { pricemin = 90, pricemax = 120 },
    ["eelfish"] = { pricemin = 95, pricemax = 125 },
    ["redfish"] = { pricemin = 100, pricemax = 130 },
    ["rockfish"] = { pricemin = 105, pricemax = 135 },
    -- Mid-tier fish - ~$130-180 avg
    ["goldfish"] = { pricemin = 120, pricemax = 150 },
    ["rainbowtrout"] = { pricemin = 125, pricemax = 160 },
    ["codfish"] = { pricemin = 130, pricemax = 170 },
    ["catfish"] = { pricemin = 140, pricemax = 175 },
    ["gholfish"] = { pricemin = 155, pricemax = 195 },
    ["largemouthbass"] = { pricemin = 150, pricemax = 185 },
    ["salmon"] = { pricemin = 165, pricemax = 200 },
    ["flyfish"] = { pricemin = 170, pricemax = 210 },
    ["swordfish"] = { pricemin = 175, pricemax = 215 },
    -- Uncommon fish - ~$200-280 avg
    ["sockeyesalmon"] = { pricemin = 190, pricemax = 240 },
    ["fishinghalibut"] = { pricemin = 200, pricemax = 250 },
    ["tarponfish"] = { pricemin = 210, pricemax = 265 },
    ["stingraymeat"] = { pricemin = 220, pricemax = 270 },
    ["mahimahi"] = { pricemin = 240, pricemax = 300 },
    ["tunafish"] = { pricemin = 250, pricemax = 300 },
    ["kingsalmon"] = { pricemin = 280, pricemax = 350 },
    -- Rare fish - ~$350-550 avg (bonus rewards for patience/skill)
    ["oceansturgeon"] = { pricemin = 320, pricemax = 400 },
    ["anglerfish"] = { pricemin = 350, pricemax = 450 },
    ["tigershark"] = { pricemin = 450, pricemax = 550 },
    ["killerwhale"] = { pricemin = 600, pricemax = 750 },
}

-- 🦀 Crab Sell Prices
Config.SellCrabs = {
    ["crawfish"]       = { pricemin = 65,  pricemax = 85 },
    ["bluecrab"]       = { pricemin = 90, pricemax = 115 },
    ["rockcrab"]       = { pricemin = 110, pricemax = 140 },
    ["dungenesscrab"]  = { pricemin = 130, pricemax = 165 },
    ["redcrab"]        = { pricemin = 145, pricemax = 180 },
    ["snowcrab"]       = { pricemin = 170, pricemax = 210 },
    ["cookedcrab"]     = { pricemin = 225, pricemax = 275 },
}


-- 💎 Gem Sell Prices
Config.SellGems = {
    ["diamond"] = { pricemin = 800, pricemax = 1200 },
    ["emerald"] = { pricemin = 850, pricemax = 1300 },
    ["sapphire"] = { pricemin = 750, pricemax = 1100 },
    ["ruby"] = { pricemin = 900, pricemax = 1400 },
    ["yellowdiamond"] = { pricemin = 1200, pricemax = 1800 },
    ["captainskull"] = { pricemin = 2500, pricemax = 4000 },
    -- Add more items here if you like
}

-- Locations where the treasure chest can be found when using the treasure map
Config.TreasureLocations = {
    vector3(-385.71, 4929.79, 191.19),
    vector3(-537.28, 5955.06, 35.25),
    vector3(268.35, 6511.3, 30.56),
    vector3(1672.04, 6647.94, 10.43),
    vector3(3688.46, 4939.28, 18.99),
    vector3(-2621.12, 4481.75, -34.07),
    vector3(-2826.86, 4136.66, -47.5),
    vector3(-2918.78, 3354.25, 27.26),
    vector3(-1872.77, 3823.91, 186.08),
    vector3(-1645.35, 3047.32, 31.24),
    vector3(-547.34, 3559.78, 239.07),
    vector3(-13.99, 3777.88, 30.64),
    vector3(-198.96, 3604.64, 52.26),
    vector3(-56.58, 3096.97, 26.74),
    vector3(-246.3, 3023.47, 21.12),
    vector3(-912.58, 2545.76, 61.12),
    vector3(-1702.95, 2301.95, 70.09),
    vector3(-2138.68, 2561.38, 2.87),
    vector3(-2458.48, 2725.17, 2.88),
    vector3(-2625.99, 2482.43, 2.89),
    vector3(-2907.75, 2614.68, -13.24),
    vector3(-3419.84, 1428.31, -34.84),
    vector3(-3280.41, 954.76, 2.93),
    vector3(-3154.45, 841.88, 2.21),
    vector3(-3047.96, 570.93, 3.34),
    vector3(-3320.98, 199.82, -13.81),
    vector3(-2528.6, 585.45, 236.63),
    vector3(-2194.37, 1460.66, 298.28),
    vector3(679.52, 1302.43, 357.26),
    vector3(1359.36, 2174.14, 95.63),
    vector3(1636.65, 1700.92, 104.34),
    vector3(2080.0, 1949.08, 86.16),
    vector3(2281.45, 2329.77, 59.99),
    vector3(2712.8, 1954.21, 46.03),
    vector3(2427.05, 1397.22, 45.7),
    vector3(3105.6, 1141.58, 15.99),
    vector3(3056.19, 1444.67, 14.1),
    vector3(3082.99, 1614.91, 5.78),
    vector3(3236.32, 2266.77, 16.06),
    vector3(3484.35, 2586.78, 14.07),
    vector3(3945.25, 3711.71, 21.93),
    vector3(4061.42, 4213.11, 12.39),
    vector3(4121.24, 4497.79, 16.96),
    vector3(3624.95, 5029.1, 11.04),
    vector3(3326.22, 5194.84, 17.69),
    vector3(2937.96, 5336.93, 102.0),
    vector3(3625.58, 5674.14, 8.05),
    vector3(2449.1, 6341.63, 78.93),
    vector3(1186.89, 6546.99, 3.51),
    vector3(1999.43, 6453.28, 73.39),
    vector3(2194.44, 5947.14, 75.67),
    vector3(2182.82, 5577.5, 54.0),
    vector3(2082.1, 5081.16, 43.69),
    vector3(2351.13, 4970.27, 42.8),
    vector3(2669.76, 4841.7, 33.24),
    vector3(2437.74, 4658.32, 32.94),
    vector3(2254.95, 4656.26, 31.1),
    vector3(1827.96, 4735.53, 33.44),
    vector3(1552.85, 5126.57, 110.7),
    vector3(1988.94, 5184.95, 47.79),
    vector3(1892.76, 4234.39, -7.23),
    vector3(1645.82, 4154.97, 3.16),
    vector3(1336.33, 4119.94, 8.28),
    vector3(1185.54, 4034.84, 5.0),
    vector3(905.72, 3932.61, -7.47),
    vector3(464.66, 1653.64, 268.33),
    vector3(672.41, 279.41, 100.97),
    vector3(540.23, -1739.97, 30.68),
    vector3(542.77, -2004.89, 23.16),
    vector3(408.05, -2115.25, 19.5),
    vector3(225.38, -2214.23, 7.58),
    vector3(-458.21, -2111.48, 15.81),
    vector3(-699.29, -1766.04, 27.9),
    vector3(-1255.46, -2092.46, 13.25),
    vector3(-1308.22, -1431.86, 4.63),
    vector3(-1033.21, -521.2, 36.51),
    vector3(-1111.2, -668.65, 14.33),
    vector3(-1065.85, 19.3, 46.8),
    vector3(-926.35, 61.65, 50.5),
    vector3(-1728.25, -579.34, 36.34),
    vector3(-1638.09, -386.53, 43.02),
    vector3(-783.91, 146.79, 63.85),
    vector3(-188.84, 354.55, 105.83),
    vector3(1066.88, 17.8, 79.29),
    vector3(1644.97, -1630.06, 111.63),
    vector3(1986.03, -2156.4, 98.17),
    vector3(2831.25, -1462.9, 11.23),
    vector3(1661.41, -2356.56, 96.86),
    vector3(1560.44, -2817.91, 1.23),
    vector3(1146.73, -2582.01, 18.29),
}