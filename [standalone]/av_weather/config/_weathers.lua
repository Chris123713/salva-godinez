Config = Config or {}
Config.Weathers = {
    -- index should match a region value from config/_zones.lua > Config.Regions
    ['santos'] = { -- zone config
        -- The sum of all chance fields can't be higher than 100
        {type = "CLEAR", chance = 20}, -- % chance of getting this weather (high priority)
        {type = "EXTRASUNNY", chance = 20}, -- % chance of getting this weather (high priority)
        {type = "CLOUDS", chance = 15}, -- % chance of getting this weather (high priority)
        {type = "OVERCAST", chance = 10}, -- % chance of getting this weather (medium priority)
        {type = "RAIN", chance = 1}, -- % chance of getting this weather (medium priority)
        {type = "SMOG", chance = 5}, -- % chance of getting this weather (medium priority)
        {type = "CLEARING", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "FOGGY", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "THUNDER", chance = 1}, -- % chance of getting this weather (low priority)
        {type = "SNOW", chance = 2}, -- % chance of getting this weather (low priority)
        {type = "XMAS", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOWLIGHT", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "BLIZZARD", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "HALLOWEEN", chance = 0}, -- % chance of getting this weather (disabled)
    },
    ['paleto'] = {
        -- The sum of all chance fields can't be higher than 100
        {type = "CLOUDS", chance = 25}, -- % chance of getting this weather (high priority)
        {type = "OVERCAST", chance = 20}, -- % chance of getting this weather (high priority)
        {type = "EXTRASUNNY", chance = 15}, -- % chance of getting this weather (high priority)
        {type = "FOGGY", chance = 15}, -- % chance of getting this weather (normal priority)
        {type = "CLEAR", chance = 10}, -- % chance of getting this weather (normal priority)
        {type = "SMOG", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "RAIN", chance = 1}, -- % chance of getting this weather (low priority)
        {type = "CLEARING", chance = 2}, -- % chance of getting this weather (low priority)
        {type = "THUNDER", chance = 1}, -- % chance of getting this weather (low priority)
        {type = "SNOW", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "XMAS", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOWLIGHT", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "BLIZZARD", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "HALLOWEEN", chance = 0}, -- % chance of getting this weather (disabled)
    },
    ['sandy'] = {
        -- The sum of all chance fields can't be higher than 100
        {type = "EXTRASUNNY", chance = 40}, -- % chance of getting this weather (high priority)
        {type = "CLEAR", chance = 30}, -- % chance of getting this weather (high priority)
        {type = "CLOUDS", chance = 10}, -- % chance of getting this weather (medium priority)
        {type = "OVERCAST", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "RAIN", chance = 1}, -- % chance of getting this weather (rare in desert)
        {type = "FOGGY", chance = 3}, -- % chance of getting this weather (low priority)
        {type = "SMOG", chance = 5}, -- % chance of getting this weather (medium priority)
        {type = "CLEARING", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "THUNDER", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOW", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "XMAS", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOWLIGHT", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "BLIZZARD", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "HALLOWEEN", chance = 0}, -- % chance of getting this weather (disabled)
    },
    ['cayo'] = {
        -- The sum of all chance fields can't be higher than 100
        {type = "EXTRASUNNY", chance = 30}, -- % chance of getting this weather (high priority)
        {type = "CLEAR", chance = 25}, -- % chance of getting this weather (high priority)
        {type = "CLOUDS", chance = 15}, -- % chance of getting this weather (medium priority)
        {type = "OVERCAST", chance = 10}, -- % chance of getting this weather (medium priority)
        {type = "RAIN", chance = 1}, -- % chance of getting this weather (possible in tropical climate)
        {type = "FOGGY", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "CLEARING", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "SMOG", chance = 0}, -- % chance of getting this weather (disabled for tropical climate)
        {type = "THUNDER", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOW", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "XMAS", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOWLIGHT", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "BLIZZARD", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "HALLOWEEN", chance = 0}, -- % chance of getting this weather (disabled)
    },
    ['roxwood'] = {
        -- The sum of all chance fields can't be higher than 100
        {type = "CLOUDS", chance = 25}, -- % chance of getting this weather (high priority)
        {type = "OVERCAST", chance = 20}, -- % chance of getting this weather (high priority)
        {type = "EXTRASUNNY", chance = 15}, -- % chance of getting this weather (high priority)
        {type = "FOGGY", chance = 15}, -- % chance of getting this weather (normal priority)
        {type = "CLEAR", chance = 10}, -- % chance of getting this weather (normal priority)
        {type = "SMOG", chance = 5}, -- % chance of getting this weather (low priority)
        {type = "RAIN", chance = 1}, -- % chance of getting this weather (low priority)
        {type = "CLEARING", chance = 2}, -- % chance of getting this weather (low priority)
        {type = "THUNDER", chance = 1}, -- % chance of getting this weather (low priority)
        {type = "SNOW", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "XMAS", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "SNOWLIGHT", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "BLIZZARD", chance = 0}, -- % chance of getting this weather (disabled)
        {type = "HALLOWEEN", chance = 0}, -- % chance of getting this weather (disabled)
    },
    ['chiliad'] = { -- Chiliad Mountain
        -- The sum of all chance fields can't be higher than 100
        {type = "SNOW", chance = 10}, -- % chance of getting this weather
        {type = "XMAS", chance = 10}, -- % chance of getting this weather
        {type = "SNOWLIGHT", chance = 10}, -- % chance of getting this weather
        {type = "BLIZZARD", chance = 10}, -- % chance of getting this weather
    },
}