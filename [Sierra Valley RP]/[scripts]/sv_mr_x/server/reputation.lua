--[[
    Mr. X Reputation System
    =======================
    Manages player reputation, tiers, and cooldowns
]]

local Reputation = {}

-- Cache for player reputations (updated on changes)
local RepCache = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, JsonEncode(data), source})
end

local function RandomMessage(messageList)
    if not messageList or #messageList == 0 then return nil end
    return messageList[math.random(#messageList)]
end

-- ============================================
-- CORE REPUTATION FUNCTIONS
-- ============================================

---Get a player's current reputation
---@param citizenid string
---@return number reputation (0-100)
function Reputation.Get(citizenid)
    if not citizenid then return 0 end

    -- Check cache first
    if RepCache[citizenid] then
        return RepCache[citizenid]
    end

    local row = MySQL.single.await([[
        SELECT reputation FROM mr_x_profiles WHERE citizenid = ?
    ]], {citizenid})

    local rep = row and row.reputation or 0

    -- Cache it
    RepCache[citizenid] = rep

    return rep
end

---Add (or subtract) reputation for a player
---@param citizenid string
---@param amount number Positive to add, negative to subtract
---@param reason string Reason for the change
---@param source? number Player source for notifications
---@return number newReputation
function Reputation.Add(citizenid, amount, reason, source)
    if not citizenid then return 0 end

    local currentRep = Reputation.Get(citizenid)
    local newRep = math.max(0, math.min(100, currentRep + amount))

    -- Update database
    MySQL.update.await([[
        UPDATE mr_x_profiles SET reputation = ? WHERE citizenid = ?
    ]], {newRep, citizenid})

    -- Update cache
    RepCache[citizenid] = newRep

    -- Log the change
    Log(MrXConstants.EventTypes.REP_CHANGED, citizenid, {
        old = currentRep,
        new = newRep,
        change = amount,
        reason = reason
    }, source)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookRepChange(citizenid, currentRep, newRep, reason)
    end

    -- Send notification to player if online
    if source then
        Reputation.NotifyChange(source, currentRep, newRep, amount)
    else
        -- Try to find player source
        local playerSource = Reputation.FindPlayerSource(citizenid)
        if playerSource then
            Reputation.NotifyChange(playerSource, currentRep, newRep, amount)
        end
    end

    if Config.Debug then
        print(string.format('^3[MR_X]^7 Rep change for %s: %d -> %d (%s%d) - %s',
            citizenid, currentRep, newRep, amount >= 0 and '+' or '', amount, reason))
    end

    return newRep
end

---Set reputation to a specific value
---@param citizenid string
---@param value number New reputation value (0-100)
---@param reason? string
---@param source? number
---@return number newReputation
function Reputation.Set(citizenid, value, reason, source)
    if not citizenid then return 0 end

    local currentRep = Reputation.Get(citizenid)
    local newRep = math.max(0, math.min(100, value))

    MySQL.update.await([[
        UPDATE mr_x_profiles SET reputation = ? WHERE citizenid = ?
    ]], {newRep, citizenid})

    RepCache[citizenid] = newRep

    Log(MrXConstants.EventTypes.REP_CHANGED, citizenid, {
        old = currentRep,
        new = newRep,
        change = newRep - currentRep,
        reason = reason or 'manual_set'
    }, source)

    return newRep
end

-- ============================================
-- TIER SYSTEM
-- ============================================

---Get the reputation tier for a given reputation value
---@param reputation number
---@return string tier (EASY, DILEMMA, or HIGH_RISK)
function Reputation.GetTier(reputation)
    reputation = reputation or 0

    if reputation >= Config.Reputation.Tiers.HIGH_RISK.min then
        return MrXConstants.ReputationTiers.HIGH_RISK
    elseif reputation >= Config.Reputation.Tiers.DILEMMA.min then
        return MrXConstants.ReputationTiers.DILEMMA
    else
        return MrXConstants.ReputationTiers.EASY
    end
end

---Get the tier for a player by citizenid
---@param citizenid string
---@return string tier
function Reputation.GetPlayerTier(citizenid)
    local rep = Reputation.Get(citizenid)
    return Reputation.GetTier(rep)
end

---Check if player meets minimum reputation requirement
---@param citizenid string
---@param minRep number
---@return boolean meetsRequirement
function Reputation.MeetsRequirement(citizenid, minRep)
    return Reputation.Get(citizenid) >= minRep
end

-- ============================================
-- COOLDOWN SYSTEM
-- ============================================

---Get the cooldown (in seconds) for a reputation tier
---@param tier string
---@return number cooldownSeconds
function Reputation.GetCooldown(tier)
    return Config.Reputation.Cooldowns[tier:upper()] or Config.Reputation.Cooldowns.EASY
end

---Get cooldown for a player based on their tier
---@param citizenid string
---@return number cooldownSeconds
function Reputation.GetPlayerCooldown(citizenid)
    local tier = Reputation.GetPlayerTier(citizenid)
    return Reputation.GetCooldown(tier)
end

-- ============================================
-- MISSION OUTCOME HANDLERS
-- ============================================

---Handle mission success - add reputation
---@param citizenid string
---@param missionId? string
---@param source? number
---@return number newRep
function Reputation.HandleSuccess(citizenid, missionId, source)
    local amount = Config.Reputation.Changes.MissionSuccess
    return Reputation.Add(citizenid, amount, 'mission_success:' .. (missionId or 'unknown'), source)
end

---Handle mission failure - subtract reputation and return threat level
---@param citizenid string
---@param missionId? string
---@param source? number
---@return number newRep
---@return boolean isThreat (true if rep dropped below threshold)
function Reputation.HandleFailure(citizenid, missionId, source)
    local amount = Config.Reputation.Changes.MissionFailure
    local newRep = Reputation.Add(citizenid, amount, 'mission_failure:' .. (missionId or 'unknown'), source)

    -- Check if this triggers threat/HARM response
    local isThreat = newRep < Config.ChaosEngine.Criteria.LowRepThreshold

    return newRep, isThreat
end

---Handle mission abandoned - severe reputation loss
---@param citizenid string
---@param missionId? string
---@param source? number
---@return number newRep
---@return boolean isThreat
function Reputation.HandleAbandoned(citizenid, missionId, source)
    local amount = Config.Reputation.Changes.MissionAbandoned
    local newRep = Reputation.Add(citizenid, amount, 'mission_abandoned:' .. (missionId or 'unknown'), source)

    local isThreat = newRep < Config.ChaosEngine.Criteria.LowRepThreshold

    return newRep, isThreat
end

---Handle loan repayment
---@param citizenid string
---@param loanId number
---@param source? number
---@return number newRep
function Reputation.HandleLoanRepaid(citizenid, loanId, source)
    local amount = Config.Reputation.Changes.LoanRepaid
    return Reputation.Add(citizenid, amount, 'loan_repaid:' .. tostring(loanId), source)
end

---Handle loan default
---@param citizenid string
---@param loanId number
---@param source? number
---@return number newRep
---@return boolean isThreat
function Reputation.HandleLoanDefaulted(citizenid, loanId, source)
    local amount = Config.Reputation.Changes.LoanDefaulted
    local newRep = Reputation.Add(citizenid, amount, 'loan_defaulted:' .. tostring(loanId), source)

    return newRep, true  -- Loan default always triggers HARM
end

---Handle completed bounty (hunter perspective)
---@param hunterCid string
---@param bountyId number
---@param source? number
---@return number newRep
function Reputation.HandleBountyCompleted(hunterCid, bountyId, source)
    local amount = Config.Reputation.Changes.BountyCompleted
    return Reputation.Add(hunterCid, amount, 'bounty_completed:' .. tostring(bountyId), source)
end

---Handle betrayal punishment
---@param citizenid string
---@param reason string
---@param source? number
---@return number newRep
function Reputation.HandleBetrayal(citizenid, reason, source)
    local amount = Config.Reputation.Changes.BetrayalPunishment
    return Reputation.Add(citizenid, amount, 'betrayal:' .. reason, source)
end

-- ============================================
-- NOTIFICATIONS
-- ============================================

---Send reputation change notification to player
---@param source number
---@param oldRep number
---@param newRep number
---@param change number
function Reputation.NotifyChange(source, oldRep, newRep, change)
    if GetResourceState('lb-phone') ~= 'started' then return end

    local message
    local title = 'Mr. X'

    if change > 0 then
        message = RandomMessage(MrXConstants.Messages.RepGain)
    else
        message = RandomMessage(MrXConstants.Messages.RepLoss)
    end

    -- Check for tier change
    local oldTier = Reputation.GetTier(oldRep)
    local newTier = Reputation.GetTier(newRep)

    if oldTier ~= newTier then
        if change > 0 then
            message = "You've proven yourself. New opportunities await."
        else
            message = "Your standing has... diminished. Tread carefully."
        end
    end

    if message then
        TriggerClientEvent('lb-phone:notification', source, {
            title = title,
            description = message,
            icon = Config.Comms.NotificationIcon,
            duration = 5000
        })
    end
end

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

---Find player source by citizenid
---@param citizenid string
---@return number|nil source
function Reputation.FindPlayerSource(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

---Clear cache for a player (call when they disconnect)
---@param citizenid string
function Reputation.ClearCache(citizenid)
    RepCache[citizenid] = nil
end

---Get reputation summary for admin display
---@param citizenid string
---@return table summary
function Reputation.GetSummary(citizenid)
    local rep = Reputation.Get(citizenid)
    local tier = Reputation.GetTier(rep)
    local cooldown = Reputation.GetCooldown(tier)

    return {
        reputation = rep,
        tier = tier,
        cooldownSeconds = cooldown,
        canAccessServices = {
            clearWarrant = rep >= Config.Services.ClearWarrant.minRep,
            clearReport = rep >= Config.Services.ClearReport.minRep,
            clearCase = rep >= Config.Services.ClearCase.minRep,
            cleanSlate = rep >= Config.Services.CleanSlate.minRep,
            targetIntel = rep >= Config.Services.TargetIntel.minRep,
            locationTip = rep >= Config.Services.LocationTip.minRep,
            policeDiversion = rep >= Config.Services.PoliceDiversion.minRep,
            earlyWarning = rep >= Config.Services.EarlyWarning.minRep
        }
    }
end

-- ============================================
-- CACHE MANAGEMENT
-- ============================================

-- Clear cache on player disconnect
AddEventHandler('playerDropped', function(reason)
    local source = source
    local citizenid = GetCitizenId(source)
    if citizenid then
        Reputation.ClearCache(citizenid)
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('GetReputation', Reputation.Get)
exports('AddReputation', Reputation.Add)
exports('SetReputation', Reputation.Set)
exports('GetReputationTier', Reputation.GetTier)
exports('GetPlayerTier', Reputation.GetPlayerTier)
exports('MeetsRepRequirement', Reputation.MeetsRequirement)
exports('GetReputationCooldown', Reputation.GetCooldown)
exports('GetPlayerCooldown', Reputation.GetPlayerCooldown)
exports('HandleMissionSuccess', Reputation.HandleSuccess)
exports('HandleMissionFailure', Reputation.HandleFailure)
exports('HandleMissionAbandoned', Reputation.HandleAbandoned)
exports('HandleLoanRepaid', Reputation.HandleLoanRepaid)
exports('HandleLoanDefaulted', Reputation.HandleLoanDefaulted)
exports('HandleBountyCompleted', Reputation.HandleBountyCompleted)
exports('HandleBetrayal', Reputation.HandleBetrayal)
exports('GetReputationSummary', Reputation.GetSummary)

-- Return module
return Reputation
