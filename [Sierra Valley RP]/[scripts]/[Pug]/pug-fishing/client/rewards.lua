-- ====================
-- Local Variables
-- ====================
local TreasureItems = {
    Config.ChestItem,
    Config.ChestKey,
    "bottlemap",
    "treasuremap"
}
local RareFishItems = {
    "skillreel",
    "proreel",
    "diamond",
    "emerald",
    "sapphire",
    "yellowdiamond",
    "captainskull"
}

-- ====================
-- Utility Functions
-- ====================
function IncrementFishCaught(item, amount)
    SendProtected("Pug:server:IncrementFishCaught", item, amount)
end
local function TryAwardTreasureItem()
    local tier = FishingSkills.treasureHunter or 0
    local chance = Config.TreasureDropChances[tier] or 250

    if math.random(1, chance) == 1 then
        local item = TreasureItems[math.random(1, #TreasureItems)]
        PugFishToggleItem(true, item)
        IncrementFishCaught(item, 1)
    end
end

local function TryAwardRareFishItem()
    local tier = FishingSkills.rareChance or 0
    local chance = Config.RareFishDropChances[tier] or 300

    if math.random(1, chance) == 1 then
        local item = RareFishItems[math.random(1, #RareFishItems)]
        PugFishToggleItem(true, item)
        IncrementFishCaught(item, 1)
    end
end



local function CheckChallengeMatch(matchTable, data)
    if not matchTable then return false end
    if matchTable.anyFish then return true end
    if matchTable.fishName and matchTable.fishName ~= data.fishName then return false end
    if matchTable.inTournament ~= nil and matchTable.inTournament ~= data.inTournament then return false end
    if matchTable.inHotZone ~= nil and matchTable.inHotZone ~= data.isInHotZone then return false end
    if matchTable.time == "night" and (GetClockHours() < 20 and GetClockHours() >= 6) then return false end
    return true
end


-- chanceForSpecial: percent chance to roll any special item (e.g. 1 = 1%)
-- specialItemDrops: your weighted list (each entry has a 'chance' weight)
local function TrySpecialDrop(chanceForSpecial, specialItemDrops)
    if math.random(1, 100) > chanceForSpecial then
        return nil -- No special item this time
    end

    -- Weighted raffle logic
    local total = 0
    for _, drop in ipairs(specialItemDrops) do
        total = total + (drop.chance or 0)
    end
    if total <= 0 then return nil end

    local roll = math.random(1, total)
    local acc = 0
    for _, drop in ipairs(specialItemDrops) do
        acc = acc + (drop.chance or 0)
        if roll <= acc then
            return drop
        end
    end
end


local function AwardReputation(amountOrRange)
    if type(amountOrRange) == "table" then
        local minPoints, maxPoints = amountOrRange[1] or 1, amountOrRange[2] or 2
        GiveFishingRep(math.random(minPoints, maxPoints))
    else
        GiveFishingRep(amountOrRange)
    end
end


local function AwardTournamentPoints(pointsOrRange)
    if not pointsOrRange then
        return
    end

    local points = type(pointsOrRange) == "table"
        and math.random(pointsOrRange[1], pointsOrRange[2])
        or pointsOrRange

    TriggerServerEvent("Pug:Server:UpdateFishingLeaderBoard", points)
end


-- ====================
-- Core Loot Processor
-- ====================
local function HandleLoot(config)

    local inTournament = GetTournInfo().intournarea and GetTournInfo().started

    local lootSection = inTournament and config.tournament or config.nonTournament

    if not lootSection then
        FishingNotify(Translations.error.cant_use_in_tourn, "error")
        return
    end

    -- 1% chance overall to get any special item
    local special = TrySpecialDrop(lootSection.specialDropChance or 0, lootSection.specialItemDrops)
    if special then
        if special.item then
            PugFishToggleItem(true, special.item)
            IncrementFishCaught(tostring(special.item), 1)
        end
        AwardReputation(special.reputationRange or special.reputation)
    end



    local roll = math.random(1, lootSection.fishRollRange)
    local selectedEntry

    for _, entry in ipairs(lootSection.fishDropTable) do
        if roll >= entry.min and roll <= entry.max then
            selectedEntry = entry
            break
        end
    end

    if not selectedEntry then
        selectedEntry = lootSection.defaultFishDrop
    end

    if inTournament and selectedEntry.leaderboardRange then
        AwardTournamentPoints(selectedEntry.leaderboardRange)
    end

    if selectedEntry.reputation or selectedEntry.reputationRange then
        AwardReputation(selectedEntry.reputationRange or selectedEntry.reputation)
    elseif selectedEntry.reputationCondition then
        local rep = selectedEntry.reputationCondition()
        if rep then AwardReputation(rep) end
    end

    PugFishToggleItem(true, selectedEntry.item)
    IncrementFishCaught(tostring(selectedEntry.item), 1)


    local challengeData = {
        fishName = selectedEntry.item,
        inTournament = inTournament,
        isInHotZone = inHotZone,
    }

    for id, challenge in pairs(Config.DailyChallenges) do
        if CheckChallengeMatch(challenge.Match, challengeData) then
            TriggerServerEvent('Pug:Server:TryUpdateChallengeProgress', "daily", id, 1)
        end
    end

    for id, challenge in pairs(Config.WeeklyChallenges) do
        if CheckChallengeMatch(challenge.Match, challengeData) then
            TriggerServerEvent('Pug:Server:TryUpdateChallengeProgress', "weekly", id, 1)
        end
    end

    TryAwardTreasureItem()
    TryAwardRareFishItem()
end

function GiveFishingRodRewards(RewardRod)
    if RewardRod == "fishinglure2" then RewardRod = "fishinglure" end
    HandleLoot(Config.lootRwards[RewardRod])
end