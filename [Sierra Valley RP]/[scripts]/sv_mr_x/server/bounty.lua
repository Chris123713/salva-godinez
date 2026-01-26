--[[
    Mr. X Bounty & Betrayal System
    ==============================
    Player vs Player HARM options:
    - Bounties on players
    - Gang contracts (rival gangs)
    - Gang betrayal (same gang members turn on each other)
]]

local Bounty = {}

-- Active bounties cache
local ActiveBounties = {}

-- Gang betrayal tracking
local ActiveBetrayals = {}

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

local function SendMessage(source, message)
    return exports['sv_mr_x']:SendMrXMessage(source, message)
end

local function FindPlayerSource(citizenid)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            return tonumber(playerId)
        end
    end
    return nil
end

-- ============================================
-- BOUNTY SYSTEM
-- ============================================

---Post a bounty on a player
---@param targetCid string Target's citizenid
---@param amount number Bounty amount
---@param reason? string Reason for bounty
---@param postedBy? string Who posted (default 'mr_x')
---@return number|nil bountyId
function Bounty.Post(targetCid, amount, reason, postedBy)
    -- Check if target is exempt - can't put bounty on exempt players
    local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(targetCid)
    if isExempt then
        if Config.Debug then
            print('^3[MR_X]^7 Cannot post bounty on exempt player: ' .. targetCid)
        end
        return nil
    end

    -- Clamp amount to config range
    amount = math.max(Config.Bounties.AmountMin, math.min(Config.Bounties.AmountMax, amount))

    -- Calculate expiration
    local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (Config.Bounties.ExpirationHours * 3600))

    -- Insert bounty
    local bountyId = MySQL.insert.await([[
        INSERT INTO mr_x_bounties (target_cid, amount, reason, posted_by, expires_at, status)
        VALUES (?, ?, ?, ?, ?, 'active')
    ]], {targetCid, amount, reason or 'Mr. X has marked this target', postedBy or 'mr_x', expiresAt})

    if not bountyId then return nil end

    -- Cache it
    ActiveBounties[bountyId] = {
        id = bountyId,
        targetCid = targetCid,
        amount = amount,
        reason = reason,
        status = 'active',
        acceptedBy = nil
    }

    -- Notify eligible hunters
    Bounty.NotifyEligibleHunters(bountyId, targetCid, amount)

    -- Send early warning to target if they qualify
    local targetSource = FindPlayerSource(targetCid)
    if targetSource then
        exports['sv_mr_x']:SendEarlyWarning(targetSource, 'BOUNTY', {bountyId = bountyId, amount = amount})
    end

    Log(MrXConstants.EventTypes.BOUNTY_POSTED, targetCid, {
        bountyId = bountyId,
        amount = amount,
        reason = reason
    })

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookBounty('posted', {
            bountyId = bountyId,
            targetCid = targetCid,
            amount = amount,
            reason = reason
        })
    end

    if Config.Debug then
        print('^3[MR_X]^7 Posted bounty #' .. bountyId .. ' ($' .. amount .. ') on ' .. targetCid)
    end

    return bountyId
end

---Get eligible bounty hunters
---@param excludeCid? string Citizenid to exclude (the target)
---@return table hunters Array of {source, citizenid, gangName?}
function Bounty.GetEligibleHunters(excludeCid)
    local hunters = {}
    local players = GetPlayers()

    for _, playerId in ipairs(players) do
        local source = tonumber(playerId)
        local player = exports.qbx_core:GetPlayer(source)
        if player then
            local cid = player.PlayerData.citizenid

            -- Skip exempt players - they can't participate in bounties
            local isExempt = exports['sv_mr_x']:IsExempt(source)
            if isExempt then goto continue end

            if cid ~= excludeCid then
                local job = player.PlayerData.job and player.PlayerData.job.name
                local gang = player.PlayerData.gang and player.PlayerData.gang.name

                local isEligible = false
                local eligibleReason = nil

                -- Check job eligibility
                for _, eligibleJob in ipairs(Config.Bounties.EligibleJobs) do
                    if job == eligibleJob then
                        isEligible = true
                        eligibleReason = 'job'
                        break
                    end
                end

                -- Check gang eligibility (any gang member is eligible)
                if gang and gang ~= 'none' and gang ~= '' then
                    isEligible = true
                    eligibleReason = 'gang'
                end

                -- Also check for criminal archetype
                local profile = exports['sv_mr_x']:GetProfile(cid)
                if profile and profile.archetype == 'thug' then
                    isEligible = true
                    eligibleReason = 'archetype'
                end

                if isEligible then
                    table.insert(hunters, {
                        source = source,
                        citizenid = cid,
                        gangName = gang,
                        reason = eligibleReason
                    })
                end
            end

            ::continue::
        end
    end

    return hunters
end

---Notify eligible hunters about a bounty
---@param bountyId number
---@param targetCid string
---@param amount number
function Bounty.NotifyEligibleHunters(bountyId, targetCid, amount)
    local hunters = Bounty.GetEligibleHunters(targetCid)

    -- Get target name
    local targetSource = FindPlayerSource(targetCid)
    local targetName = 'Unknown'
    if targetSource then
        local player = exports.qbx_core:GetPlayer(targetSource)
        if player then
            local charinfo = player.PlayerData.charinfo
            targetName = charinfo.firstname .. ' ' .. charinfo.lastname
        end
    end

    local message = string.format("A bounty of $%s awaits. Target: %s. Reply 'accept bounty' if interested.", amount, targetName)

    for _, hunter in ipairs(hunters) do
        SendMessage(hunter.source, message)
    end

    if Config.Debug then
        print('^3[MR_X]^7 Notified ' .. #hunters .. ' eligible hunters about bounty #' .. bountyId)
    end
end

---Accept a bounty
---@param hunterSource number
---@param bountyId? number Specific bounty, or find any available
---@return boolean success
function Bounty.Accept(hunterSource, bountyId)
    local hunterCid = GetCitizenId(hunterSource)
    if not hunterCid then return false end

    -- Find bounty
    local bounty
    if bountyId then
        bounty = ActiveBounties[bountyId]
        if not bounty then
            -- Load from DB
            bounty = MySQL.single.await([[
                SELECT * FROM mr_x_bounties WHERE id = ? AND status = 'active'
            ]], {bountyId})
        end
    else
        -- Find any active bounty not targeting the hunter
        bounty = MySQL.single.await([[
            SELECT * FROM mr_x_bounties
            WHERE status = 'active' AND target_cid != ? AND accepted_by IS NULL
            ORDER BY amount DESC LIMIT 1
        ]], {hunterCid})
    end

    if not bounty then
        SendMessage(hunterSource, "No available contracts right now.")
        return false
    end

    -- Can't accept bounty on yourself
    if bounty.target_cid == hunterCid then
        SendMessage(hunterSource, "You can't collect on yourself.")
        return false
    end

    -- Update bounty
    MySQL.update.await([[
        UPDATE mr_x_bounties SET accepted_by = ?, accepted_at = NOW(), status = 'accepted'
        WHERE id = ?
    ]], {hunterCid, bounty.id})

    -- Update cache
    if ActiveBounties[bounty.id] then
        ActiveBounties[bounty.id].acceptedBy = hunterCid
        ActiveBounties[bounty.id].status = 'accepted'
    end

    -- Get target info
    local targetSource = FindPlayerSource(bounty.target_cid)
    local lastSeen = 'Unknown'
    if targetSource then
        local ped = GetPlayerPed(targetSource)
        local coords = GetEntityCoords(ped)
        if coords then
            local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            lastSeen = GetStreetNameFromHashKey(streetHash) or 'Unknown'
        end
    end

    SendMessage(hunterSource, string.format(
        "Contract accepted. Target last seen near %s. Bring proof of completion.",
        lastSeen
    ))

    Log(MrXConstants.EventTypes.BOUNTY_ACCEPTED, hunterCid, {
        bountyId = bounty.id,
        targetCid = bounty.target_cid,
        amount = bounty.amount
    }, hunterSource)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookBounty('accepted', {
            bountyId = bounty.id,
            targetCid = bounty.target_cid,
            hunterCid = hunterCid,
            amount = bounty.amount
        })
    end

    return true
end

---Claim a bounty (after killing target)
---@param hunterCid string Hunter's citizenid
---@param targetCid string Target's citizenid
---@return boolean success
---@return number|nil amount
function Bounty.Claim(hunterCid, targetCid)
    -- Find active bounty accepted by this hunter for this target
    local bounty = MySQL.single.await([[
        SELECT * FROM mr_x_bounties
        WHERE target_cid = ? AND accepted_by = ? AND status = 'accepted'
    ]], {targetCid, hunterCid})

    if not bounty then return false end

    -- Update bounty status
    MySQL.update.await([[
        UPDATE mr_x_bounties SET claimed_by = ?, claimed_at = NOW(), status = 'claimed'
        WHERE id = ?
    ]], {hunterCid, bounty.id})

    -- Pay the hunter
    local hunterSource = FindPlayerSource(hunterCid)
    if hunterSource then
        exports.qbx_core:AddMoney(hunterSource, 'cash', bounty.amount, 'mr_x_bounty_' .. bounty.id)
        exports['sv_mr_x']:HandleBountyCompleted(hunterCid, bounty.id, hunterSource)
        SendMessage(hunterSource, string.format("Contract complete. $%s deposited. Good work.", bounty.amount))
    end

    -- Clean up cache
    ActiveBounties[bounty.id] = nil

    Log(MrXConstants.EventTypes.BOUNTY_CLAIMED, hunterCid, {
        bountyId = bounty.id,
        targetCid = targetCid,
        amount = bounty.amount
    }, hunterSource)

    -- Post webhook for dashboard
    if Config.WebServer and Config.WebServer.Enabled then
        exports['sv_mr_x']:PostWebhookBounty('claimed', {
            bountyId = bounty.id,
            targetCid = targetCid,
            hunterCid = hunterCid,
            amount = bounty.amount
        })
    end

    return true, bounty.amount
end

---Get active bounty on a player
---@param targetCid string
---@return table|nil bounty
function Bounty.GetOnPlayer(targetCid)
    return MySQL.single.await([[
        SELECT * FROM mr_x_bounties
        WHERE target_cid = ? AND status IN ('active', 'accepted')
    ]], {targetCid})
end

-- ============================================
-- GANG CONTRACT SYSTEM (Rival Gangs)
-- ============================================

---Post a gang contract (offer bounty to rival gang)
---@param targetCid string Target's citizenid
---@param targetGang string Target's gang name
---@param amount number
---@param reason? string
---@return boolean success
function Bounty.PostGangContract(targetCid, targetGang, amount, reason)
    -- Find online players in rival gangs
    local players = GetPlayers()
    local rivalMembers = {}

    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player then
            local gang = player.PlayerData.gang and player.PlayerData.gang.name
            if gang and gang ~= 'none' and gang ~= '' and gang ~= targetGang then
                local cid = player.PlayerData.citizenid
                if cid ~= targetCid then
                    table.insert(rivalMembers, {
                        source = tonumber(playerId),
                        citizenid = cid,
                        gang = gang
                    })
                end
            end
        end
    end

    if #rivalMembers == 0 then
        if Config.Debug then
            print('^3[MR_X]^7 No rival gang members online for gang contract')
        end
        return false
    end

    -- Post the bounty
    local bountyId = Bounty.Post(targetCid, amount, reason or 'Gang contract', 'mr_x')
    if not bountyId then return false end

    -- Notify rival gang members specifically
    local targetSource = FindPlayerSource(targetCid)
    local targetName = 'a member of ' .. targetGang
    if targetSource then
        local player = exports.qbx_core:GetPlayer(targetSource)
        if player then
            local charinfo = player.PlayerData.charinfo
            targetName = charinfo.firstname .. ' ' .. charinfo.lastname .. ' (' .. targetGang .. ')'
        end
    end

    local message = string.format(
        "Contract on %s. $%s for their elimination. Interested?",
        targetName, amount
    )

    for _, rival in ipairs(rivalMembers) do
        SendMessage(rival.source, message)
    end

    Log(MrXConstants.EventTypes.BOUNTY_POSTED, targetCid, {
        bountyId = bountyId,
        type = 'gang_contract',
        targetGang = targetGang,
        rivalCount = #rivalMembers
    })

    return true
end

-- ============================================
-- GANG BETRAYAL SYSTEM (Same Gang)
-- ============================================

---Initiate a gang betrayal (turn gang member against their own)
---@param targetCid string Target's citizenid (the one to be betrayed)
---@param reason? string Reason for the betrayal
---@return boolean success
function Bounty.InitiateGangBetrayal(targetCid, reason)
    -- Check if target is exempt - can't betray exempt players
    local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(targetCid)
    if isExempt then
        if Config.Debug then
            print('^3[MR_X]^7 Cannot initiate gang betrayal on exempt player: ' .. targetCid)
        end
        return false
    end

    -- Get target's gang
    local targetSource = FindPlayerSource(targetCid)
    local targetGang = nil
    local targetName = 'Unknown'

    if targetSource then
        local player = exports.qbx_core:GetPlayer(targetSource)
        if player then
            targetGang = player.PlayerData.gang and player.PlayerData.gang.name
            local charinfo = player.PlayerData.charinfo
            targetName = charinfo.firstname .. ' ' .. charinfo.lastname
        end
    else
        -- Try to get from profile
        local profile = exports['sv_mr_x']:GetProfile(targetCid)
        -- Would need gang info stored in profile
        return false
    end

    if not targetGang or targetGang == 'none' or targetGang == '' then
        if Config.Debug then
            print('^3[MR_X]^7 Target has no gang for betrayal')
        end
        return false
    end

    -- Find OTHER members of the SAME gang
    local players = GetPlayers()
    local sameGangMembers = {}

    for _, playerId in ipairs(players) do
        local source = tonumber(playerId)
        local player = exports.qbx_core:GetPlayer(source)
        if player then
            local gang = player.PlayerData.gang and player.PlayerData.gang.name
            local cid = player.PlayerData.citizenid

            -- Skip exempt players - they can't participate in betrayals
            local isExempt = exports['sv_mr_x']:IsExempt(source)
            if isExempt then goto continue end

            if gang == targetGang and cid ~= targetCid then
                table.insert(sameGangMembers, {
                    source = source,
                    citizenid = cid,
                    gang = gang
                })
            end

            ::continue::
        end
    end

    if #sameGangMembers == 0 then
        if Config.Debug then
            print('^3[MR_X]^7 No other gang members online for betrayal')
        end
        return false
    end

    -- Calculate betrayal payment (higher than normal bounty)
    local amount = math.random(
        math.floor(Config.Bounties.AmountMax * 0.8),
        math.floor(Config.Bounties.AmountMax * 1.5)
    )

    -- Calculate expiration (shorter than normal bounty - 24h)
    local expiresAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (24 * 3600))

    -- Insert into gang_relations table
    for _, member in ipairs(sameGangMembers) do
        local betrayalId = MySQL.insert.await([[
            INSERT INTO mr_x_gang_relations (instigator_cid, target_cid, gang, amount, status, expires_at)
            VALUES (?, ?, ?, ?, 'offered', ?)
        ]], {member.citizenid, targetCid, targetGang, amount, expiresAt})

        -- Send cryptic offer
        local message = string.format(
            "Loyalty is expensive. %s is worth $%s to me. One of you could benefit from their... departure. Reply 'betray' to accept.",
            targetName, amount
        )

        SendMessage(member.source, message)

        -- Cache it
        ActiveBetrayals[betrayalId] = {
            id = betrayalId,
            instigatorCid = member.citizenid,
            targetCid = targetCid,
            gang = targetGang,
            amount = amount,
            status = 'offered'
        }
    end

    Log(MrXConstants.EventTypes.GANG_BETRAYAL, targetCid, {
        gang = targetGang,
        membersContacted = #sameGangMembers,
        amount = amount,
        reason = reason
    })

    if Config.Debug then
        print(string.format('^3[MR_X]^7 Initiated gang betrayal: %d members of %s contacted about %s',
            #sameGangMembers, targetGang, targetCid))
    end

    return true
end

---Accept a gang betrayal offer
---@param instigatorSource number The gang member accepting
---@return boolean success
function Bounty.AcceptBetrayal(instigatorSource)
    local instigatorCid = GetCitizenId(instigatorSource)
    if not instigatorCid then return false end

    -- Find their pending betrayal offer
    local betrayal = MySQL.single.await([[
        SELECT * FROM mr_x_gang_relations
        WHERE instigator_cid = ? AND status = 'offered'
        ORDER BY offered_at DESC LIMIT 1
    ]], {instigatorCid})

    if not betrayal then
        SendMessage(instigatorSource, "I don't recall making you an offer.")
        return false
    end

    -- Update status
    MySQL.update.await([[
        UPDATE mr_x_gang_relations SET status = 'accepted' WHERE id = ?
    ]], {betrayal.id})

    -- Get target info
    local targetSource = FindPlayerSource(betrayal.target_cid)
    local targetInfo = 'Unknown location'
    if targetSource then
        local ped = GetPlayerPed(targetSource)
        local coords = GetEntityCoords(ped)
        if coords then
            local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            targetInfo = GetStreetNameFromHashKey(streetHash) or 'Unknown'
        end
    end

    SendMessage(instigatorSource, string.format(
        "So be it. Your 'friend' was last seen near %s. Make it look like an accident... or don't. I don't care.",
        targetInfo
    ))

    -- Warn target if they have early warning
    if targetSource then
        exports['sv_mr_x']:SendEarlyWarning(targetSource, 'GANG_CONTRACT', {
            gang = betrayal.gang,
            isBetrayal = true
        })
    end

    Log(MrXConstants.EventTypes.GANG_BETRAYAL, betrayal.target_cid, {
        accepted = true,
        acceptedBy = instigatorCid,
        gang = betrayal.gang
    }, instigatorSource)

    return true
end

---Complete a gang betrayal (when target is killed by their gang member)
---@param killerCid string
---@param victimCid string
---@return boolean success
---@return number|nil amount
function Bounty.CompleteBetrayal(killerCid, victimCid)
    -- Find accepted betrayal matching this scenario
    local betrayal = MySQL.single.await([[
        SELECT * FROM mr_x_gang_relations
        WHERE instigator_cid = ? AND target_cid = ? AND status = 'accepted'
    ]], {killerCid, victimCid})

    if not betrayal then return false end

    -- Update status
    MySQL.update.await([[
        UPDATE mr_x_gang_relations SET status = 'completed', completed_at = NOW() WHERE id = ?
    ]], {betrayal.id})

    -- Pay the betrayer
    local killerSource = FindPlayerSource(killerCid)
    if killerSource then
        exports.qbx_core:AddMoney(killerSource, 'cash', betrayal.amount, 'mr_x_betrayal_' .. betrayal.id)
        exports['sv_mr_x']:HandleBountyCompleted(killerCid, betrayal.id, killerSource)
        SendMessage(killerSource, string.format(
            "Business is business. $%s deposited. Your former friend won't be missed.",
            betrayal.amount
        ))
    end

    -- Apply reputation loss to the betrayer (for betraying their gang)
    exports['sv_mr_x']:HandleBetrayal(killerCid, 'gang_betrayal_completed', killerSource)

    Log(MrXConstants.EventTypes.GANG_BETRAYAL, victimCid, {
        completed = true,
        completedBy = killerCid,
        gang = betrayal.gang,
        amount = betrayal.amount
    }, killerSource)

    return true, betrayal.amount
end

-- ============================================
-- DEATH DETECTION HOOKS
-- ============================================

-- Hook player death to check for bounty/betrayal completion
AddEventHandler('qbx_medical:server:playerDied', function(victimSource, killerSource)
    if not killerSource then return end

    local victimCid = GetCitizenId(victimSource)
    local killerCid = GetCitizenId(killerSource)

    if not victimCid or not killerCid then return end

    -- Check for bounty
    local bounty = Bounty.GetOnPlayer(victimCid)
    if bounty and bounty.accepted_by == killerCid then
        Bounty.Claim(killerCid, victimCid)
    end

    -- Check for gang betrayal
    local success, amount = Bounty.CompleteBetrayal(killerCid, victimCid)
    if success then
        if Config.Debug then
            print('^3[MR_X]^7 Gang betrayal completed: ' .. killerCid .. ' killed ' .. victimCid)
        end
    end
end)

-- Also try to hook into other death systems
RegisterNetEvent('baseevents:onPlayerDied', function()
    -- Source is the dead player
    local victimSource = source
    local victimCid = GetCitizenId(victimSource)
    if not victimCid then return end

    -- Check if any accepted bounty should be checked
    local bounty = Bounty.GetOnPlayer(victimCid)
    if bounty and bounty.accepted_by then
        -- Hunter needs to claim manually or be nearby
        local hunterSource = FindPlayerSource(bounty.accepted_by)
        if hunterSource then
            local hunterPed = GetPlayerPed(hunterSource)
            local victimPed = GetPlayerPed(victimSource)
            local dist = #(GetEntityCoords(hunterPed) - GetEntityCoords(victimPed))

            if dist < 50.0 then
                -- Close enough to auto-claim
                Bounty.Claim(bounty.accepted_by, victimCid)
            end
        end
    end
end)

RegisterNetEvent('baseevents:onPlayerKilled', function(killerId)
    local victimSource = source
    local killerSource = killerId

    if not killerSource then return end

    local victimCid = GetCitizenId(victimSource)
    local killerCid = GetCitizenId(killerSource)

    if not victimCid or not killerCid then return end

    -- Same logic as qbx_medical hook
    local bounty = Bounty.GetOnPlayer(victimCid)
    if bounty and bounty.accepted_by == killerCid then
        Bounty.Claim(killerCid, victimCid)
    end

    Bounty.CompleteBetrayal(killerCid, victimCid)
end)

-- ============================================
-- INBOUND MESSAGE HANDLERS
-- ============================================

RegisterNetEvent('sv_mr_x:server:acceptBounty', function()
    local source = source
    Bounty.Accept(source)
end)

RegisterNetEvent('sv_mr_x:server:acceptBetrayal', function()
    local source = source
    Bounty.AcceptBetrayal(source)
end)

-- Check for keywords in comms
AddEventHandler('sv_mr_x:internal:checkBountyKeywords', function(source, message)
    local lowerMsg = message:lower()

    if lowerMsg:match('accept bounty') or lowerMsg:match('accept contract') then
        Bounty.Accept(source)
    elseif lowerMsg:match('betray') then
        Bounty.AcceptBetrayal(source)
    end
end)

-- ============================================
-- CLEANUP THREAD
-- ============================================

CreateThread(function()
    while true do
        Wait(300000)  -- Every 5 minutes

        -- Expire old bounties
        MySQL.update.await([[
            UPDATE mr_x_bounties SET status = 'expired'
            WHERE status IN ('active', 'accepted') AND expires_at < NOW()
        ]])

        -- Expire old betrayal offers
        MySQL.update.await([[
            UPDATE mr_x_gang_relations SET status = 'expired'
            WHERE status = 'offered' AND expires_at < NOW()
        ]])
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('PostBounty', Bounty.Post)
exports('AcceptBounty', Bounty.Accept)
exports('ClaimBounty', Bounty.Claim)
exports('GetBountyOnPlayer', Bounty.GetOnPlayer)
exports('GetEligibleHunters', Bounty.GetEligibleHunters)
exports('PostGangContract', Bounty.PostGangContract)
exports('InitiateGangBetrayal', Bounty.InitiateGangBetrayal)
exports('AcceptBetrayal', Bounty.AcceptBetrayal)
exports('CompleteBetrayal', Bounty.CompleteBetrayal)

-- Return module
return Bounty
