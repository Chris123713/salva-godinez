-- Social & Faction Tools with Database Integration

local SocialTools = {}

-- Active rumors/gossip
local ActiveRumors = {}

-- Active informants
local ActiveInformants = {}

-- Active meetings
local ActiveMeetings = {}

-- Bounty system
local ActiveBounties = {}

-- News events
local ActiveNewsEvents = {}

--[[
    SPREAD RUMOR
    NPCs start mentioning specific information to players
]]
RegisterTool('spread_rumor', {
    params = {'rumor', 'area', 'radius', 'duration', 'targetJobs', 'truthLevel'},
    async = true,
    handler = function(params, source)
        local area = Utils.Vec3FromTable(params.area)
        local radius = params.radius or 100.0
        local duration = params.duration or 1800 -- 30 minutes
        local truthLevel = params.truthLevel or 'partial' -- true, partial, false

        local rumorId = Utils.GenerateUUID()

        ActiveRumors[rumorId] = {
            text = params.rumor,
            area = area,
            radius = radius,
            targetJobs = params.targetJobs or {}, -- Empty = everyone
            truthLevel = truthLevel,
            heardBy = {},
            createdAt = os.time(),
            expiresAt = os.time() + duration,
            status = 'active'
        }

        -- Notify clients to enable rumor interactions
        TriggerClientEvent('nexus:client:enableRumor', -1, {
            rumorId = rumorId,
            area = area,
            radius = radius
        })

        -- Schedule expiry
        SetTimeout(duration * 1000, function()
            if ActiveRumors[rumorId] then
                ActiveRumors[rumorId].status = 'expired'
                TriggerClientEvent('nexus:client:disableRumor', -1, {rumorId = rumorId})
            end
        end)

        Utils.Debug('Rumor spread:', rumorId)

        return {
            success = true,
            rumorId = rumorId
        }
    end
})

-- Player hears rumor from NPC
lib.callback.register('nexus:hearRumor', function(source, data)
    local rumor = ActiveRumors[data.rumorId]
    if not rumor or rumor.status ~= 'active' then
        return {success = false}
    end

    local citizenid = Utils.GetCitizenId(source)
    local player = Utils.GetPlayer(source)

    -- Check if target job restriction
    if #rumor.targetJobs > 0 then
        local hasJob = false
        for _, job in ipairs(rumor.targetJobs) do
            if player.PlayerData.job.name == job then
                hasJob = true
                break
            end
        end
        if not hasJob then
            return {success = false, error = 'Not the right crowd'}
        end
    end

    -- Check if already heard
    if rumor.heardBy[citizenid] then
        return {success = false, error = 'Already heard this'}
    end

    rumor.heardBy[citizenid] = os.time()

    return {
        success = true,
        rumor = rumor.text,
        truthLevel = rumor.truthLevel
    }
end)

--[[
    SPAWN INFORMANT
    NPC with database intel to sell
]]
RegisterTool('spawn_informant', {
    params = {'coords', 'intelType', 'intelData', 'price', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local intelType = params.intelType or 'location' -- location, person, phone, vehicle
        local price = params.price or 500

        local informantId = Utils.GenerateUUID()

        -- Get real intel from database based on type
        local intel = {}

        if intelType == 'phone' and params.intelData and params.intelData.citizenid then
            -- Get phone number from database
            local phoneData = MySQL.single.await([[
                SELECT phone_number FROM phone_phones
                WHERE id IN (SELECT phone_id FROM phone_logged_in_accounts WHERE owner = ?)
                LIMIT 1
            ]], {params.intelData.citizenid})

            if phoneData then
                intel.phoneNumber = phoneData.phone_number
            end
        elseif intelType == 'location' and params.intelData and params.intelData.citizenid then
            -- Get last known location (would need position tracking)
            intel.location = params.intelData.location or 'Unknown'
        elseif intelType == 'vehicle' and params.intelData and params.intelData.citizenid then
            -- Get vehicle info from database
            local vehicles = MySQL.query.await([[
                SELECT vehicle, plate FROM player_vehicles
                WHERE citizenid = ?
                LIMIT 3
            ]], {params.intelData.citizenid})

            intel.vehicles = vehicles
        elseif intelType == 'criminal_history' and params.intelData and params.intelData.citizenid then
            -- Get police profile
            local profile = MySQL.single.await([[
                SELECT * FROM lbtablet_police_profiles
                WHERE cid = ?
            ]], {params.intelData.citizenid})

            intel.profile = profile
        else
            intel = params.intelData or {info = 'No specific intel available'}
        end

        -- Spawn informant NPC
        local spawnResult = lib.callback.await('nexus:spawnNpc', source, {
            model = 's_m_y_dealer_01',
            coords = coords,
            heading = 0,
            behavior = 'idle',
            networked = true
        })

        if not spawnResult or not spawnResult.success then
            return {success = false, error = 'Failed to spawn informant'}
        end

        ActiveInformants[informantId] = {
            netId = spawnResult.netId,
            coords = coords,
            intelType = intelType,
            intel = intel,
            price = price,
            missionId = params.missionId,
            soldTo = nil,
            status = 'available'
        }

        -- Add dialog target
        TriggerClientEvent('nexus:client:addInformant', -1, {
            netId = spawnResult.netId,
            informantId = informantId,
            intelType = intelType,
            price = price
        })

        Utils.Debug('Spawned informant:', informantId, 'intel type:', intelType)

        return {
            success = true,
            informantId = informantId,
            netId = spawnResult.netId
        }
    end
})

-- Buy intel from informant
lib.callback.register('nexus:buyIntel', function(source, data)
    local informant = ActiveInformants[data.informantId]
    if not informant or informant.status ~= 'available' then
        return {success = false, error = 'Intel not available'}
    end

    local player = Utils.GetPlayer(source)
    if not player then return {success = false} end

    local citizenid = player.PlayerData.citizenid

    -- Check money
    if player.PlayerData.money.cash < informant.price then
        return {success = false, error = 'Insufficient funds'}
    end

    -- Deduct money
    exports.qbx_core:RemoveMoney(source, 'cash', informant.price, 'Intel purchase')

    -- Mark as sold
    informant.soldTo = citizenid
    informant.status = 'sold'

    -- Complete objective if mission-linked
    if informant.missionId then
        exports['sv_nexus_tools']:SetMissionObjective(
            informant.missionId,
            citizenid,
            'buy_intel',
            Constants.ObjectiveStatus.COMPLETED
        )
    end

    return {
        success = true,
        intel = informant.intel,
        intelType = informant.intelType
    }
end)

--[[
    CREATE MEETING
    Multi-party coordination point
]]
RegisterTool('create_meeting', {
    params = {'coords', 'participants', 'purpose', 'requiredItems', 'missionId'},
    async = true,
    handler = function(params, source)
        local coords = Utils.Vec3FromTable(params.coords)
        local participants = params.participants or {} -- {citizenid1, citizenid2}

        local meetingId = Utils.GenerateUUID()

        ActiveMeetings[meetingId] = {
            coords = coords,
            participants = {},
            expectedParticipants = participants,
            purpose = params.purpose or 'Unknown',
            requiredItems = params.requiredItems or {},
            missionId = params.missionId,
            status = 'pending', -- pending, in_progress, completed, failed
            arrivedParticipants = {},
            createdAt = os.time()
        }

        -- Notify expected participants
        for _, citizenid in ipairs(participants) do
            local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(citizenid)
            if playerSource then
                TriggerClientEvent('nexus:client:meetingInvite', playerSource, {
                    meetingId = meetingId,
                    coords = coords,
                    purpose = params.purpose
                })

                exports['sv_nexus_tools']:SendPhoneMail(playerSource, {
                    subject = 'Meeting Request',
                    message = 'You have been invited to a meeting. Location has been marked.',
                    sender = 'Unknown Contact'
                })
            end
        end

        -- Create meeting zone
        TriggerClientEvent('nexus:client:createMeetingZone', -1, {
            meetingId = meetingId,
            coords = coords,
            radius = 10.0
        })

        Utils.Debug('Created meeting:', meetingId)

        return {
            success = true,
            meetingId = meetingId
        }
    end
})

-- Player arrives at meeting
lib.callback.register('nexus:arriveAtMeeting', function(source, data)
    local meeting = ActiveMeetings[data.meetingId]
    if not meeting then return {success = false} end

    local citizenid = Utils.GetCitizenId(source)

    -- Check if expected
    local isExpected = false
    for _, expected in ipairs(meeting.expectedParticipants) do
        if expected == citizenid then
            isExpected = true
            break
        end
    end

    if not isExpected then
        return {success = false, error = 'Not invited to this meeting'}
    end

    -- Check required items
    for _, item in ipairs(meeting.requiredItems) do
        local hasItem = exports.ox_inventory:Search(source, 'count', item.name)
        if not hasItem or hasItem < (item.count or 1) then
            return {success = false, error = 'Missing required item: ' .. item.name}
        end
    end

    -- Mark as arrived
    meeting.arrivedParticipants[citizenid] = os.time()

    -- Check if all have arrived
    local allArrived = true
    for _, expected in ipairs(meeting.expectedParticipants) do
        if not meeting.arrivedParticipants[expected] then
            allArrived = false
            break
        end
    end

    if allArrived then
        meeting.status = 'in_progress'

        -- Notify all participants
        for expected, _ in pairs(meeting.arrivedParticipants) do
            local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(expected)
            if playerSource then
                TriggerClientEvent('nexus:client:meetingStarted', playerSource, {
                    meetingId = data.meetingId
                })
            end
        end

        -- Complete objective
        if meeting.missionId then
            for expected, _ in pairs(meeting.arrivedParticipants) do
                exports['sv_nexus_tools']:SetMissionObjective(
                    meeting.missionId,
                    expected,
                    'attend_meeting',
                    Constants.ObjectiveStatus.COMPLETED
                )
            end
        end
    end

    return {
        success = true,
        allArrived = allArrived,
        waiting = #meeting.expectedParticipants - Utils.TableSize(meeting.arrivedParticipants)
    }
end)

--[[
    TRIGGER NEWS EVENT
    Server-wide notification/news broadcast
]]
RegisterTool('trigger_news_event', {
    params = {'headline', 'description', 'category', 'image', 'tweet'},
    async = true,
    handler = function(params, source)
        local eventId = Utils.GenerateUUID()
        local category = params.category or 'breaking' -- breaking, crime, business, sports

        ActiveNewsEvents[eventId] = {
            headline = params.headline,
            description = params.description,
            category = category,
            createdAt = os.time()
        }

        -- Notify all players via phone
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            exports['sv_nexus_tools']:SendPhoneNotification(playerId, {
                title = 'BREAKING NEWS',
                message = params.headline,
                icon = 'fas fa-newspaper'
            })
        end

        -- Post to Twitter if enabled
        if params.tweet then
            MySQL.insert.await([[
                INSERT INTO phone_twitter_tweets
                (authorId, content, attachments, replyTo, likes, retweets, views, createdAt)
                VALUES (
                    (SELECT id FROM phone_twitter_accounts WHERE username = 'WeazelNews' LIMIT 1),
                    ?, '', NULL, 0, 0, 0, NOW()
                )
            ]], {params.headline .. '\n\n' .. (params.description or '')})
        end

        Utils.Success('News event triggered:', eventId)

        return {
            success = true,
            eventId = eventId
        }
    end
})

--[[
    BOUNTY SYSTEM
    Put price on player or NPC head
]]
RegisterTool('bounty_system', {
    params = {'targetCitizenid', 'amount', 'reason', 'anonymous', 'deadline', 'missionId'},
    async = true,
    handler = function(params, source)
        local posterCitizenid = Utils.GetCitizenId(source)
        local targetCitizenid = params.targetCitizenid
        local amount = params.amount or 1000
        local deadline = params.deadline or 86400 -- 24 hours

        -- Check if poster has funds
        local poster = Utils.GetPlayer(source)
        if poster.PlayerData.money.cash < amount then
            return {success = false, error = 'Insufficient funds for bounty'}
        end

        -- Deduct bounty amount (held in escrow)
        exports.qbx_core:RemoveMoney(source, 'cash', amount, 'Bounty posted')

        local bountyId = Utils.GenerateUUID()

        ActiveBounties[bountyId] = {
            targetCitizenid = targetCitizenid,
            amount = amount,
            reason = params.reason or 'Unknown',
            postedBy = params.anonymous and 'Anonymous' or posterCitizenid,
            anonymous = params.anonymous or false,
            deadline = os.time() + deadline,
            missionId = params.missionId,
            status = 'active',
            claimedBy = nil,
            createdAt = os.time()
        }

        -- Get target name for broadcast
        local targetPlayer = MySQL.single.await([[
            SELECT JSON_EXTRACT(charinfo, '$.firstname') as firstname,
                   JSON_EXTRACT(charinfo, '$.lastname') as lastname
            FROM players WHERE citizenid = ?
        ]], {targetCitizenid})

        local targetName = 'Unknown'
        if targetPlayer then
            targetName = (targetPlayer.firstname or 'Unknown'):gsub('"', '') .. ' ' ..
                        (targetPlayer.lastname or ''):gsub('"', '')
        end

        -- Notify criminal players (darkchat style)
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = Utils.GetPlayer(playerId)
            if player then
                -- Could check for criminal background/gang membership
                TriggerClientEvent('nexus:client:bountyPosted', playerId, {
                    bountyId = bountyId,
                    targetName = targetName,
                    amount = amount,
                    reason = params.reason,
                    deadline = deadline
                })
            end
        end

        -- Store in database
        MySQL.insert.await([[
            INSERT INTO nexus_bounties
            (bounty_id, target_citizenid, amount, reason, posted_by, deadline, status, created_at)
            VALUES (?, ?, ?, ?, ?, FROM_UNIXTIME(?), 'active', NOW())
        ]], {bountyId, targetCitizenid, amount, params.reason, posterCitizenid, os.time() + deadline})

        Utils.Success('Bounty posted:', bountyId, '$' .. amount, 'on', targetCitizenid)

        return {
            success = true,
            bountyId = bountyId,
            targetName = targetName
        }
    end
})

-- Claim bounty (when target is killed/captured)
lib.callback.register('nexus:claimBounty', function(source, data)
    local bounty = ActiveBounties[data.bountyId]
    if not bounty or bounty.status ~= 'active' then
        return {success = false, error = 'Bounty not available'}
    end

    -- Check deadline
    if os.time() > bounty.deadline then
        bounty.status = 'expired'
        return {success = false, error = 'Bounty expired'}
    end

    local claimerCitizenid = Utils.GetCitizenId(source)

    -- Verify target is dead or captured (would need death/arrest detection)
    -- For now, trust the claim

    bounty.status = 'claimed'
    bounty.claimedBy = claimerCitizenid
    bounty.claimedAt = os.time()

    -- Pay bounty
    exports.qbx_core:AddMoney(source, 'cash', bounty.amount, 'Bounty claimed')

    -- Update database
    MySQL.update.await([[
        UPDATE nexus_bounties
        SET status = 'claimed', claimed_by = ?, claimed_at = NOW()
        WHERE bounty_id = ?
    ]], {claimerCitizenid, data.bountyId})

    Utils.Success('Bounty claimed:', data.bountyId, 'by', claimerCitizenid)

    return {
        success = true,
        amount = bounty.amount
    }
end)

--[[
    ADJUST FACTION REP
    Modify player standing with gang/faction
]]
RegisterTool('adjust_faction_rep', {
    params = {'citizenid', 'faction', 'amount', 'reason'},
    handler = function(params)
        local amount = params.amount or 0
        local faction = params.faction

        -- Update in brutal_gangs or player_groups
        local currentRep = MySQL.scalar.await([[
            SELECT COALESCE(reputation, 0) FROM player_groups
            WHERE citizenid = ? AND `group` = ?
        ]], {params.citizenid, faction}) or 0

        local newRep = currentRep + amount

        MySQL.query.await([[
            INSERT INTO player_groups (citizenid, `group`, grade, reputation)
            VALUES (?, ?, 0, ?)
            ON DUPLICATE KEY UPDATE reputation = ?
        ]], {params.citizenid, faction, newRep, newRep})

        -- Notify player if online
        local playerSource = exports['sv_nexus_tools']:GetMissionsModule().GetParticipantSource(params.citizenid)
        if playerSource then
            local changeText = amount > 0 and ('+' .. amount) or tostring(amount)
            TriggerClientEvent('ox_lib:notify', playerSource, {
                title = 'Faction Reputation',
                description = faction .. ': ' .. changeText,
                type = amount > 0 and 'success' or 'error'
            })
        end

        Utils.Debug('Adjusted faction rep:', params.citizenid, faction, amount)

        return {
            success = true,
            newReputation = newRep
        }
    end
})

-- Exports
exports('GetActiveRumors', function() return ActiveRumors end)
exports('GetActiveInformants', function() return ActiveInformants end)
exports('GetActiveMeetings', function() return ActiveMeetings end)
exports('GetActiveBounties', function() return ActiveBounties end)
exports('GetActiveNewsEvents', function() return ActiveNewsEvents end)

return SocialTools
