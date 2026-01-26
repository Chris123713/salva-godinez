-- Special job list for special loads (30% reduced rewards for economy balance)
local SpecialJobList = {
    jobs = {
        {
            id = 1,
            name = "Special and Confidential Cargo",
            description = "The employer didn't provide any details. But the pay is good!",
            difficulty = "hard",
            reward = {
                cash = { min = 1750, max = 3500 },  -- was 2500/5000
                xp   = { min = 140,  max = 280 }    -- was 200/400
            },
            trailerModel = "trailers2",
            destination = "LS Docks",
            destination_coords = vector4(928.33, -1221.89, 25.20, 86),
            trailer_spawn_coords = vector4(1117.40, -970.50, 46.18, 8)
        },
        {
            id = 2,
            name = "Special and Confidential Cargo",
            description = "The employer didn't provide any details. But the pay is good!",
            difficulty = "extreme",
            reward = {
                cash = { min = 2800, max = 5250 },  -- was 4000/7500
                xp   = { min = 210,  max = 420 }    -- was 300/600
            },
            trailerModel = "trailers2",
            destination = "Sandy Depot",
            destination_coords = vector4(-282.87, 315.37, 92.83, 86),
            trailer_spawn_coords = vector4(1374.07, -739.71, 66.81, 74)
        },
        {
            id = 3,
            name = "Special and Confidential Cargo",
            description = "The employer didn't provide any details. But the pay is good!",
            difficulty = "extreme",
            reward = {
                cash = { min = 4200, max = 7000 },  -- was 6000/10000
                xp   = { min = 350,  max = 560 }    -- was 500/800
            },
            trailerModel = "trailers2",
            destination = "Paleto Lumber",
            destination_coords = vector4(-1159.09, 935.41, 197.52, 324),
            trailer_spawn_coords = vector4(1180.85, -314.77, 68.75, 278)
        },
        {
            id = 4,
            name = "Special and Confidential Cargo",
            description = "The employer didn't provide any details. But the pay is good!",
            difficulty = "hard",
            reward = {
                cash = { min = 2450, max = 4200 },  -- was 3500/6000
                xp   = { min = 175,  max = 315 }    -- was 250/450
            },
            trailerModel = "trailers2",
            destination = "Del Perro Freight Hub",
            destination_coords = vector4(-1917.19, 2037.85, 140.31, 256),
            trailer_spawn_coords = vector4(1909.85, 570.43, 175.35, 243)
        },
        {
            id = 5,
            name = "Special and Confidential Cargo",
            description = "The employer didn't provide any details. But the pay is good!",
            difficulty = "hard",
            reward = {
                cash = { min = 2800, max = 4550 },  -- was 4000/6500
                xp   = { min = 210,  max = 350 }    -- was 300/500
            },
            trailerModel = "trailers2",
            destination = "Vinewood Tech Park",
            destination_coords = vector4(-197.42, 3784.02, 39.17, 16),
            trailer_spawn_coords = vector4(1562.36, 877.77, 77.05, 357)
        }
    }
}

return SpecialJobList