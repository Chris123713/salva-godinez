--[[
    Mr. X Prospect System
    =====================
    Identifies and nurtures new players, nudging them toward roles Mr. X needs.

    Philosophy:
    - Be FRIENDLY and HELPFUL to new players
    - Build loyalty and rapport early
    - Guide them toward positions that benefit Mr. X
    - Invest now, exploit later

    A prospect is:
    - Unemployed
    - Low money (<$20k)
    - New to the city (low playtime)
    - No gang affiliation
    - Low/no Mr. X reputation
]]

local Prospect = {}

-- Track welcome gifts to prevent spam
local welcomeGiftsSent = {}
local lastGlobalGiftTime = 0

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

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
    ]], {citizenid, eventType, JsonEncode(data), source or 'prospect_system'})
end

local function RandomFromTable(tbl)
    if not tbl or #tbl == 0 then return nil end
    return tbl[math.random(#tbl)]
end

local function WeightedRandom(weights)
    local total = 0
    for _, weight in pairs(weights) do
        total = total + weight
    end

    local random = math.random() * total
    local cumulative = 0

    for key, weight in pairs(weights) do
        cumulative = cumulative + weight
        if random <= cumulative then
            return key
        end
    end

    -- Fallback
    for key, _ in pairs(weights) do
        return key
    end
end

-- ============================================
-- PROSPECT DETECTION
-- ============================================

---Check if a player qualifies as a prospect
---@param source number Player source
---@return boolean isProspect
---@return table|nil playerInfo
function Prospect.IsProspect(source)
    if not Config.Prospect or not Config.Prospect.Enabled then
        return false, nil
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false, nil end

    local pd = player.PlayerData
    local citizenid = pd.citizenid
    local detection = Config.Prospect.Detection

    -- Check 1: Must be unemployed (or configured job)
    local job = pd.job and pd.job.name or 'unemployed'
    if job ~= detection.Job then
        return false, nil
    end

    -- Check 2: Low money (cash + bank)
    local cash = pd.money and pd.money.cash or 0
    local bank = pd.money and pd.money.bank or 0
    local totalMoney = cash + bank
    if totalMoney > detection.MaxMoney then
        return false, nil
    end

    -- Check 3: No gang affiliation
    if detection.NoGang then
        local gang = pd.gang and pd.gang.name
        if gang and gang ~= '' and gang ~= 'none' then
            return false, nil
        end
    end

    -- Check 4: Low Mr. X reputation
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    if profile then
        local rep = profile.reputation or 0
        if rep > detection.MaxReputation then
            return false, nil
        end
    end

    -- All checks passed - this is a prospect!
    local playerInfo = {
        source = source,
        citizenid = citizenid,
        name = (pd.charinfo.firstname or '') .. ' ' .. (pd.charinfo.lastname or ''),
        totalMoney = totalMoney,
        hasProfile = profile ~= nil
    }

    return true, playerInfo
end

---Get all current prospects on the server
---@return table prospects List of prospect info tables
function Prospect.GetAllProspects()
    local prospects = {}

    for _, playerId in ipairs(GetPlayers()) do
        local isProspect, info = Prospect.IsProspect(tonumber(playerId))
        if isProspect then
            table.insert(prospects, info)
        end
    end

    return prospects
end

-- ============================================
-- NEED SELECTION
-- What direction should Mr. X nudge this prospect?
-- ============================================

---Select a need to nudge the prospect toward
---@param citizenid string
---@return table|nil need { type: string, target: string, reason: string, priority: number }
function Prospect.SelectNeed(citizenid)
    local needs = Config.Prospect.CurrentNeeds
    if not needs then return nil end

    -- Collect all needs with their priorities
    local allNeeds = {}

    -- Job placements
    for _, job in ipairs(needs.JobPlacements or {}) do
        table.insert(allNeeds, {
            type = 'job',
            target = job.job,
            reason = job.reason,
            priority = job.priority
        })
    end

    -- Criminal recruits
    for _, crim in ipairs(needs.CriminalRecruits or {}) do
        table.insert(allNeeds, {
            type = 'criminal',
            target = crim.type,
            reason = crim.reason,
            priority = crim.priority
        })
    end

    -- Gang recruits (if any configured)
    for _, gang in ipairs(needs.GangRecruits or {}) do
        table.insert(allNeeds, {
            type = 'gang',
            target = gang.gang,
            reason = gang.reason,
            priority = gang.priority
        })
    end

    -- Authority placements (rare)
    for _, auth in ipairs(needs.AuthorityPlacements or {}) do
        table.insert(allNeeds, {
            type = 'authority',
            target = auth.job,
            reason = auth.reason,
            priority = auth.priority
        })
    end

    if #allNeeds == 0 then return nil end

    -- Weight by priority (higher priority = more likely)
    local weights = {}
    for i, need in ipairs(allNeeds) do
        weights[i] = need.priority
    end

    -- Pick weighted random
    local total = 0
    for _, w in ipairs(weights) do total = total + w end
    local random = math.random() * total
    local cumulative = 0

    for i, weight in ipairs(weights) do
        cumulative = cumulative + weight
        if random <= cumulative then
            return allNeeds[i]
        end
    end

    return allNeeds[1]
end

-- ============================================
-- MESSAGE GENERATION
-- ============================================

---Get a welcome message for a prospect
---@param includeGift boolean Whether to include welcome gift
---@return string message
function Prospect.GetWelcomeMessage(includeGift)
    local messaging = Config.Prospect.Messaging

    if includeGift then
        return RandomFromTable(messaging.WelcomeGift)
    else
        return RandomFromTable(messaging.InitialContact)
    end
end

---Get a job nudge message
---@param jobName string The job being suggested
---@return string message
function Prospect.GetJobNudgeMessage(jobName)
    local messaging = Config.Prospect.Messaging
    local template = RandomFromTable(messaging.JobNudge)

    -- Get job label if available
    local jobLabel = jobName
    local jobs = exports.qbx_core:GetJobs()
    if jobs and jobs[jobName] then
        jobLabel = jobs[jobName].label or jobName
    end

    return string.format(template, jobLabel)
end

---Get a check-in message
---@return string message
function Prospect.GetCheckInMessage()
    local messaging = Config.Prospect.Messaging
    return RandomFromTable(messaging.CheckIn)
end

---Get a free tip message
---@return string message
function Prospect.GetTipMessage()
    local messaging = Config.Prospect.Messaging
    return RandomFromTable(messaging.FreeTips)
end

---Get a first mission offer message
---@return string message
function Prospect.GetFirstMissionMessage()
    local messaging = Config.Prospect.Messaging
    return RandomFromTable(messaging.FirstMission)
end

-- ============================================
-- PROSPECT ACTIONS
-- ============================================

---Send a welcome message to a prospect (optionally with gift)
---@param source number Player source
---@param withGift boolean Give welcome money?
---@return boolean success
function Prospect.SendWelcome(source, withGift)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false end

    local citizenid = info.citizenid

    -- Check if already welcomed
    if welcomeGiftsSent[citizenid] then
        return false
    end

    -- Check global gift cooldown (don't spam gifts)
    if withGift then
        local cooldown = Config.Prospect.WelcomeGiftCooldown or 86400
        if os.time() - lastGlobalGiftTime < 60 then  -- Max 1 gift per minute globally
            withGift = false
        end
    end

    -- Get or create profile with PROSPECT archetype
    local profile = exports['sv_mr_x']:GetOrCreateProfile(citizenid)
    if profile then
        exports['sv_mr_x']:UpdateProfile(citizenid, {
            archetype = MrXConstants.Archetypes.PROSPECT
        })
    end

    -- Send welcome message
    local message = Prospect.GetWelcomeMessage(withGift)
    local sendSuccess = exports['sv_mr_x']:SendMrXMessage(source, message)

    if sendSuccess and withGift then
        -- Give welcome gift
        local giftAmount = Config.Prospect.WelcomeGiftAmount or 500
        exports.qbx_core:AddMoney(source, 'cash', giftAmount, 'Mr. X welcome gift')

        welcomeGiftsSent[citizenid] = os.time()
        lastGlobalGiftTime = os.time()

        -- Log the gift
        Log('prospect_welcome_gift', citizenid, {
            amount = giftAmount,
            message = message
        }, source)

        -- Deposit cost from Mr. X account
        if Config.Scarcity and Config.Scarcity.Enabled then
            exports['sv_mr_x']:WithdrawFromMrX(giftAmount, 'prospect_welcome_gift:' .. citizenid)
        end
    end

    -- Log the welcome
    Log('prospect_welcome', citizenid, {
        withGift = withGift,
        message = message
    }, source)

    -- Update last contact
    exports['sv_mr_x']:UpdateLastContact(citizenid)

    if Config.Debug then
        print('^2[MR_X:PROSPECT]^7 Welcomed ' .. citizenid .. (withGift and ' with gift' or ''))
    end

    return true
end

---Send a job suggestion to a prospect
---@param source number Player source
---@param jobName? string Specific job to suggest (or auto-select)
---@return boolean success
function Prospect.SendJobSuggestion(source, jobName)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false end

    local citizenid = info.citizenid

    -- Select job if not specified
    if not jobName then
        local need = Prospect.SelectNeed(citizenid)
        if need and need.type == 'job' then
            jobName = need.target
        else
            -- Default to first job placement
            local placements = Config.Prospect.CurrentNeeds.JobPlacements
            if placements and #placements > 0 then
                jobName = placements[1].job
            else
                jobName = 'mechanic'  -- Fallback
            end
        end
    end

    local message = Prospect.GetJobNudgeMessage(jobName)
    local sendSuccess = exports['sv_mr_x']:SendMrXMessage(source, message)

    if sendSuccess then
        -- Store the suggested job in profile for tracking
        local profile = exports['sv_mr_x']:GetProfile(citizenid)
        if profile then
            local facts = profile.known_facts or {}
            facts.SUGGESTED_JOB = {
                data = jobName,
                discovered_at = os.time()
            }
            exports['sv_mr_x']:UpdateProfile(citizenid, {known_facts = facts})
        end

        Log('prospect_job_suggestion', citizenid, {
            suggestedJob = jobName,
            message = message
        }, source)

        exports['sv_mr_x']:UpdateLastContact(citizenid)
    end

    return sendSuccess
end

---Send a friendly check-in to a prospect
---@param source number Player source
---@return boolean success
function Prospect.SendCheckIn(source)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false end

    local message = Prospect.GetCheckInMessage()
    local sendSuccess = exports['sv_mr_x']:SendMrXMessage(source, message)

    if sendSuccess then
        Log('prospect_checkin', info.citizenid, {message = message}, source)
        exports['sv_mr_x']:UpdateLastContact(info.citizenid)
    end

    return sendSuccess
end

---Send a helpful tip to a prospect
---@param source number Player source
---@return boolean success
function Prospect.SendTip(source)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false end

    local message = Prospect.GetTipMessage()
    local sendSuccess = exports['sv_mr_x']:SendMrXMessage(source, message)

    if sendSuccess then
        Log('prospect_tip', info.citizenid, {message = message}, source)
        exports['sv_mr_x']:UpdateLastContact(info.citizenid)
    end

    return sendSuccess
end

---Offer first mission to a prospect
---@param source number Player source
---@return boolean success
function Prospect.OfferFirstMission(source)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false end

    -- TODO: Generate actual first mission via mission_gen
    -- For now, just send the message
    local message = Prospect.GetFirstMissionMessage()
    local sendSuccess = exports['sv_mr_x']:SendMrXMessage(source, message)

    if sendSuccess then
        Log('prospect_first_mission_offer', info.citizenid, {message = message}, source)
        exports['sv_mr_x']:UpdateLastContact(info.citizenid)
    end

    return sendSuccess
end

---Execute proactive outreach to a prospect
---@param source number Player source
---@return boolean success
---@return string contactType
function Prospect.ProactiveOutreach(source)
    local isProspect, info = Prospect.IsProspect(source)
    if not isProspect then return false, 'not_prospect' end

    local citizenid = info.citizenid

    -- Check cooldown
    local cooldown = Config.Prospect.ContactCooldownSec or 1800
    local canContact = exports['sv_mr_x']:CanContact(citizenid, cooldown)
    if not canContact then
        return false, 'cooldown'
    end

    -- Select contact type
    local contactTypes = Config.ProactiveContact.ProspectContactTypes
    local contactType = WeightedRandom(contactTypes)

    local success = false

    if contactType == 'WELCOME' then
        -- Check if already welcomed
        if not welcomeGiftsSent[citizenid] then
            success = Prospect.SendWelcome(source, true)
        else
            -- Already welcomed, send check-in instead
            success = Prospect.SendCheckIn(source)
            contactType = 'CHECK_IN'
        end
    elseif contactType == 'JOB_SUGGESTION' then
        success = Prospect.SendJobSuggestion(source)
    elseif contactType == 'CHECK_IN' then
        success = Prospect.SendCheckIn(source)
    elseif contactType == 'TIP' then
        success = Prospect.SendTip(source)
    elseif contactType == 'FIRST_MISSION' then
        success = Prospect.OfferFirstMission(source)
    end

    if Config.Debug then
        print('^3[MR_X:PROSPECT]^7 Outreach to ' .. citizenid .. ': ' .. contactType .. ' (' .. (success and 'success' or 'failed') .. ')')
    end

    return success, contactType
end

-- ============================================
-- FOLLOW-THROUGH DETECTION
-- Track when prospects take suggested actions
-- ============================================

---Check if prospect took a suggested job
---@param citizenid string
---@param newJob string
local function CheckJobFollowThrough(citizenid, newJob)
    local profile = exports['sv_mr_x']:GetProfile(citizenid)
    if not profile then return end

    -- Check if this was a suggested job
    local facts = profile.known_facts or {}
    local suggested = facts.SUGGESTED_JOB

    if suggested and suggested.data == newJob then
        -- They followed through!
        local bonus = Config.Prospect.FollowThroughBonus.JobAccepted or 5
        exports['sv_mr_x']:UpdateReputation(citizenid, bonus, 'Followed career advice')

        -- Clear the suggestion
        facts.SUGGESTED_JOB = nil
        facts.FOLLOWED_JOB_ADVICE = {
            data = newJob,
            discovered_at = os.time()
        }
        exports['sv_mr_x']:UpdateProfile(citizenid, {known_facts = facts})

        Log('prospect_job_followthrough', citizenid, {
            suggestedJob = newJob,
            reputationBonus = bonus
        })

        -- Re-evaluate archetype (no longer prospect if employed)
        exports['sv_mr_x']:ReevaluateArchetype(citizenid)

        if Config.Debug then
            print('^2[MR_X:PROSPECT]^7 ' .. citizenid .. ' followed job advice -> ' .. newJob)
        end
    end
end

-- Listen for job changes
RegisterNetEvent('qbx_core:server:onGroupUpdate', function(groupName, groupGrade)
    local source = source
    if not source then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local job = player.PlayerData.job and player.PlayerData.job.name

    if job and job ~= 'unemployed' then
        CheckJobFollowThrough(citizenid, job)
    end
end)

-- Also listen for setJob events
AddEventHandler('QBCore:Server:OnJobUpdate', function(source, job)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    if job and job.name and job.name ~= 'unemployed' then
        CheckJobFollowThrough(citizenid, job.name)
    end
end)

-- ============================================
-- PROSPECT SCANNER
-- Periodically finds and contacts prospects
-- ============================================

CreateThread(function()
    if not Config.Prospect or not Config.Prospect.Enabled then
        return
    end

    -- Wait for server to start
    Wait(60000)  -- 1 minute

    while true do
        Wait(Config.Prospect.ScanIntervalMs or 300000)  -- 5 minutes default

        if Config.TestMode then
            -- Don't auto-contact in test mode
            if Config.Debug then
                print('^3[MR_X:PROSPECT]^7 Scan skipped (test mode)')
            end
        else
            local prospects = Prospect.GetAllProspects()

            if Config.Debug then
                print('^3[MR_X:PROSPECT]^7 Scan found ' .. #prospects .. ' prospects')
            end

            for _, prospect in ipairs(prospects) do
                -- Random chance to contact (don't spam all prospects at once)
                if math.random() < 0.3 then  -- 30% chance per prospect per scan
                    Prospect.ProactiveOutreach(prospect.source)
                    Wait(5000)  -- Small delay between contacts
                end
            end
        end
    end
end)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_prospects', function(source)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local prospects = Prospect.GetAllProspects()

    print('^3[MR_X:PROSPECT]^7 Current prospects: ' .. #prospects)
    for _, p in ipairs(prospects) do
        print('  - ' .. p.name .. ' (' .. p.citizenid .. ') - $' .. p.totalMoney)
    end
end, false)

RegisterCommand('mrx_welcome', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local target = tonumber(args[1])
    if not target then
        print('^1[MR_X]^7 Usage: mrx_welcome [player_id]')
        return
    end

    local withGift = args[2] == 'gift'
    local success = Prospect.SendWelcome(target, withGift)

    if success then
        print('^2[MR_X]^7 Welcome sent to player ' .. target)
    else
        print('^1[MR_X]^7 Failed to send welcome (player may not be a prospect)')
    end
end, false)

RegisterCommand('mrx_nudge', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local target = tonumber(args[1])
    local jobName = args[2]

    if not target then
        print('^1[MR_X]^7 Usage: mrx_nudge [player_id] [optional_job]')
        return
    end

    local success = Prospect.SendJobSuggestion(target, jobName)

    if success then
        print('^2[MR_X]^7 Job suggestion sent to player ' .. target)
    else
        print('^1[MR_X]^7 Failed to send suggestion (player may not be a prospect)')
    end
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('IsProspect', Prospect.IsProspect)
exports('GetAllProspects', Prospect.GetAllProspects)
exports('SelectNeed', Prospect.SelectNeed)
exports('SendProspectWelcome', Prospect.SendWelcome)
exports('SendJobSuggestion', Prospect.SendJobSuggestion)
exports('SendProspectCheckIn', Prospect.SendCheckIn)
exports('SendProspectTip', Prospect.SendTip)
exports('OfferFirstMission', Prospect.OfferFirstMission)
exports('ProspectOutreach', Prospect.ProactiveOutreach)

return Prospect
