--[[ 
    =============================
    FISHING CHALLENGE DEFINITIONS
    =============================

    Each challenge must contain:

    - Title:             (string) What shows to the player.
    - ToComplete:        (number) How much progress is needed to complete the challenge.
    - Match:             (table) Filters to auto-track this challenge during fish rewards.
        Supported Match filters:
            anyFish        = true               -- Accepts any fish.
            fishName       = "goldfish"         -- Only accepts specific fish item name.
            inTournament   = true / false       -- Only counts during tournament or outside.
            inHotZone   = true / false       -- Only counts if you are within a hot zone.
            time           = "night"            -- Only counts at night (20:00 - 06:00 game hours).

        (More filters like rodType, baitUsed, zone, etc can be added later.)

    - Rewards:           (table) Reward given after completion.
        RewardType        = "cash" / "bank"     -- Cash or bank money.
        RewardTypeAmount  = (number)            -- How much money.
        RewardItem        = false or "itemname" -- Optional item reward.
        RewardItemAmount  = (number)            -- How many items to give.

    Example:
        {
            Title = "Catch 5 goldfish",
            ToComplete = 5,
            Match = { fishName = "goldfish" },
            Rewards = {
                RewardType = "cash",
                RewardTypeAmount = 50,
                RewardItem = false,
                RewardItemAmount = 0,
            },
        }

    Progress is automatically added through fish reward logic
    based on the Match conditions.
]]

Config.DailyChallenges = {
    [1] = {
        Title = "Catch 25 fish of any kind",
        ToComplete = 25,
        Match = { anyFish = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 1000, RewardItem = false, RewardItemAmount = 0 },
    },
    [2] = {
        Title = "Catch 7 trout",
        ToComplete = 7,
        Match = { fishName = "rainbowtrout" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 500, RewardItem = false, RewardItemAmount = 0 },
    },
    [3] = {
        Title = "Catch 5 fish during night",
        ToComplete = 5,
        Match = { time = "night" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 750, RewardItem = false, RewardItemAmount = 0 },
    },
    [4] = {
        Title = "Catch 10 goldfish",
        ToComplete = 10,
        Match = { fishName = "goldfish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 800, RewardItem = false, RewardItemAmount = 0 },
    },
    [5] = {
        Title = "Catch 5 fish in a tournament",
        ToComplete = 5,
        Match = { inTournament = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 950, RewardItem = false, RewardItemAmount = 0 },
    },
    [6] = {
        Title = "Catch 4 Cod Fish",
        ToComplete = 4,
        Match = { fishName = "codfish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 700, RewardItem = false, RewardItemAmount = 0 },
    },
    [7] = {
        Title = "Catch 3 different fish species",
        ToComplete = 3,
        Match = { anyFish = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 500, RewardItem = false, RewardItemAmount = 0 },
    },
    [8] = {
        Title = "Catch 5 crawfish",
        ToComplete = 5,
        Match = { fishName = "crawfish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 800, RewardItem = false, RewardItemAmount = 0 },
    },
    [9] = {
        Title = "Catch 25 fish in a hot zone",
        ToComplete = 25,
        Match = { inHotZone = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 1500, RewardItem = false, RewardItemAmount = 0 },
    },
}


Config.WeeklyChallenges = {
    [1] = {
        Title = "Catch 100 fish of any kind",
        ToComplete = 100,
        Match = { anyFish = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3500, RewardItem = false, RewardItemAmount = 0 },
    },
    [2] = {
        Title = "Catch 50 goldfish",
        ToComplete = 50,
        Match = { fishName = "goldfish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 2200, RewardItem = false, RewardItemAmount = 0 },
    },
    [3] = {
        Title = "Catch 35 fish during tournament",
        ToComplete = 35,
        Match = { inTournament = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 4300, RewardItem = false, RewardItemAmount = 0 },
    },
    [4] = {
        Title = "Catch 45 fish at night",
        ToComplete = 45,
        Match = { time = "night" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3700, RewardItem = false, RewardItemAmount = 0 },
    },
    [5] = {
        Title = "Catch 40 Blue Fish",
        ToComplete = 40,
        Match = { fishName = "bluefish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 4200, RewardItem = "skillreel", RewardItemAmount = 1 },
    },
    [6] = {
        Title = "Catch 40 crawfish",
        ToComplete = 40,
        Match = { fishName = "crawfish" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3200, RewardItem = false, RewardItemAmount = 0 },
    },
    [7] = {
        Title = "Catch 15 different fish species",
        ToComplete = 15,
        Match = { anyFish = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3800, RewardItem = false, RewardItemAmount = 0 },
    },
    [8] = {
        Title = "Catch 10 Tiger Shark",
        ToComplete = 10,
        Match = { fishName = "tigershark" },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3400, RewardItem = "treasurechest", RewardItemAmount = 1 },
    },
    [9] = {
        Title = "Catch 55 fish in a hot zone",
        ToComplete = 55,
        Match = { inHotZone = true },
        Rewards = { RewardType = "cash", RewardTypeAmount = 3500, RewardItem = false, RewardItemAmount = 0 },
    },
}
