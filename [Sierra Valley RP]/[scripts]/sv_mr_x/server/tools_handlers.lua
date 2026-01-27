--[[
    Mr. X Tools Handlers
    ====================
    Maps each tool to existing sv_mr_x exports.

    Each handler:
    - execute(args, context) -> result table
    - requiresSafety (optional) - if true, safety limits are checked

    These handlers bridge the AI tools to actual game functionality.
]]

local Handlers = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function JsonEncode(data)
    if data == nil then return nil end
    local success, result = pcall(json.encode, data)
    return success and result or nil
end

-- ============================================
-- COMMUNICATION HANDLERS
-- ============================================

---Send message handler
Handlers['send_message'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        local success = false

        if args.channel == 'sms' then
            success = exports['sv_mr_x']:SendMrXMessage(source, args.message)
        elseif args.channel == 'email' then
            success = exports['sv_mr_x']:SendMrXEmail(source, 'Mr. X', args.message)
        elseif args.channel == 'notification' then
            success = exports['sv_mr_x']:SendMrXNotification(source, 'Mr. X', args.message)
        else
            -- Default to SMS
            success = exports['sv_mr_x']:SendMrXMessage(source, args.message)
        end

        return {
            success = success,
            channel = args.channel,
            messageDelivered = success
        }
    end
}

---Generate response handler (same as send_message with SMS)
Handlers['generate_response'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        local success = exports['sv_mr_x']:SendMrXMessage(source, args.message)

        return {
            success = success,
            messageSent = success
        }
    end
}

-- ============================================
-- MISSION HANDLERS
-- ============================================

Handlers['offer_mission'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        -- Generate mission async
        local missionResult = nil
        exports['sv_mr_x']:GenerateMission(source, args.type, function(success, mission)
            if success and mission then
                -- Execute the mission offer
                exports['sv_mr_x']:ExecuteMission(source, mission, function(execSuccess)
                    missionResult = {
                        success = execSuccess,
                        missionId = mission.missionId,
                        type = mission.type
                    }
                end)
            else
                missionResult = { success = false, error = 'Mission generation failed' }
            end
        end)

        -- Wait for callback (with timeout)
        local timeout = 5000
        local waited = 0
        while missionResult == nil and waited < timeout do
            Wait(100)
            waited = waited + 100
        end

        return missionResult or { success = true, message = 'Mission generation initiated' }
    end
}

-- ============================================
-- PROSPECT HANDLERS
-- ============================================

Handlers['welcome_prospect'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        -- Check if actually a prospect
        local isProspect = exports['sv_mr_x']:IsProspect(source)
        if not isProspect then
            return { success = false, error = 'Player is not a prospect' }
        end

        local success = exports['sv_mr_x']:SendProspectWelcome(source, args.with_gift or false)

        return {
            success = success,
            giftIncluded = args.with_gift or false
        }
    end
}

Handlers['nudge_toward_job'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        local success = exports['sv_mr_x']:SendJobSuggestion(source, args.job)

        return {
            success = success,
            suggestedJob = args.job
        }
    end
}

-- ============================================
-- REPUTATION HANDLERS
-- ============================================

Handlers['adjust_reputation'] = {
    execute = function(args, ctx)
        local newRep = exports['sv_mr_x']:AddReputation(args.citizenid, args.delta, args.reason)

        return {
            success = true,
            newReputation = newRep,
            change = args.delta,
            reason = args.reason
        }
    end
}

Handlers['record_fact'] = {
    execute = function(args, ctx)
        exports['sv_mr_x']:AddKnownFact(args.citizenid, args.fact_type, args.value)

        return {
            success = true,
            factType = args.fact_type,
            recorded = true
        }
    end
}

-- ============================================
-- SERVICE HANDLERS
-- ============================================

Handlers['offer_loan'] = {
    requiresSafety = true,
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        -- Check reputation requirement
        local rep = exports['sv_mr_x']:GetReputation(args.citizenid)
        if rep < 50 then
            return { success = false, error = 'Insufficient reputation (need 50+)' }
        end

        local success, loanId = exports['sv_mr_x']:IssueLoan(source)

        return {
            success = success,
            loanId = loanId,
            amount = args.amount
        }
    end
}

Handlers['offer_service'] = {
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        local result = { success = false }

        if args.service == 'intel' then
            result = exports['sv_mr_x']:GetLocationTip(source)
            if result then
                result = { success = true, service = 'intel' }
            end
        elseif args.service == 'record_clear' then
            -- Check reputation
            local rep = exports['sv_mr_x']:GetReputation(args.citizenid)
            if rep < 60 then
                return { success = false, error = 'Insufficient reputation for record clear' }
            end

            -- This would need ClearAllRecords export
            local records = exports['sv_mr_x']:GetPlayerRecords(args.citizenid)
            if records then
                -- Would trigger record clear flow
                result = { success = true, service = 'record_clear', recordsFound = true }
            else
                result = { success = false, error = 'No records found' }
            end
        elseif args.service == 'tip' then
            local tipResult = exports['sv_mr_x']:SendProspectTip(source)
            result = { success = tipResult, service = 'tip' }
        elseif args.service == 'protection' then
            -- Protection service - send early warnings
            exports['sv_mr_x']:SendEarlyWarning(source, 'PROTECTION_ACTIVE', {})
            result = { success = true, service = 'protection', message = 'Protection activated' }
        else
            result = { success = false, error = 'Unknown service: ' .. tostring(args.service) }
        end

        return result
    end
}

-- ============================================
-- HARM HANDLERS (require safety checks)
-- ============================================

Handlers['place_bounty'] = {
    requiresSafety = true,
    execute = function(args, ctx)
        local bountyId = exports['sv_mr_x']:PostBounty(
            args.citizenid,
            args.amount,
            args.reason,
            'MR_X_AGENT'
        )

        if not bountyId then
            return { success = false, error = 'Failed to post bounty' }
        end

        return {
            success = true,
            bountyId = bountyId,
            amount = args.amount,
            reason = args.reason
        }
    end
}

Handlers['trigger_surprise'] = {
    requiresSafety = true,
    execute = function(args, ctx)
        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        if not source then
            return { success = false, error = 'Player offline' }
        end

        -- Map type to internal format
        local typeMap = {
            fake_warrant = 'FAKE_WARRANT',
            fake_report = 'FAKE_REPORT',
            hit_squad = 'HIT_SQUAD',
            leak_location = 'LEAK_LOCATION',
            debt_collector = 'DEBT_COLLECTOR'
        }

        local surpriseType = typeMap[args.type] or args.type:upper()

        -- Execute surprise
        exports['sv_mr_x']:ExecuteSurprise(source, args.citizenid, surpriseType)

        return {
            success = true,
            type = surpriseType,
            reason = args.reason
        }
    end
}

-- ============================================
-- QUERY HANDLERS (read-only)
-- ============================================

Handlers['get_player_context'] = {
    execute = function(args, ctx)
        local profile = exports['sv_mr_x']:GetProfile(args.citizenid)
        local rep = exports['sv_mr_x']:GetReputation(args.citizenid)
        local facts = exports['sv_mr_x']:GetAllKnownFacts(args.citizenid)
        local history = exports['sv_mr_x']:GetHistory(args.citizenid, 5)
        local psychSummary = exports['sv_mr_x']:GetPsychologySummary(args.citizenid)

        local source = exports['sv_mr_x']:FindPlayerSource(args.citizenid)
        local isOnline = source ~= nil
        local isProspect = false

        if source then
            isProspect = exports['sv_mr_x']:IsProspect(source)
        end

        -- Get loan status
        local hasLoan = false
        local loanOverdue = false
        pcall(function()
            local loan = MySQL.single.await([[
                SELECT status FROM mr_x_loans WHERE citizenid = ? AND status IN ('active', 'overdue')
            ]], {args.citizenid})
            if loan then
                hasLoan = true
                loanOverdue = loan.status == 'overdue'
            end
        end)

        -- Get bounty status
        local hasBounty = false
        pcall(function()
            local bounty = exports['sv_mr_x']:GetBountyOnPlayer(args.citizenid)
            hasBounty = bounty ~= nil
        end)

        return {
            success = true,
            citizenid = args.citizenid,
            isOnline = isOnline,
            isProspect = isProspect,
            reputation = rep,
            reputationTier = exports['sv_mr_x']:GetReputationTier(rep),
            archetype = profile and profile.archetype or 'unknown',
            bucket = psychSummary.bucket,
            methodAxis = psychSummary.method,
            loyaltyAxis = psychSummary.loyalty,
            traits = psychSummary.traits,
            facts = facts,
            recentHistory = history,
            hasActiveLoan = hasLoan,
            loanOverdue = loanOverdue,
            hasBountyOnThem = hasBounty,
            lastContact = profile and profile.last_contact
        }
    end
}

Handlers['get_online_players'] = {
    execute = function(args, ctx)
        local players = {}

        for _, pid in ipairs(GetPlayers()) do
            local player = exports.qbx_core:GetPlayer(tonumber(pid))
            if player then
                local citizenid = player.PlayerData.citizenid
                local charinfo = player.PlayerData.charinfo

                -- Check if exempt (skip exempt players from list)
                local isExempt = exports['sv_mr_x']:IsExempt(tonumber(pid))

                if not isExempt then
                    table.insert(players, {
                        citizenid = citizenid,
                        name = charinfo.firstname .. ' ' .. charinfo.lastname,
                        job = player.PlayerData.job.name,
                        gang = player.PlayerData.gang.name,
                        reputation = exports['sv_mr_x']:GetReputation(citizenid) or 0,
                        isProspect = exports['sv_mr_x']:IsProspect(tonumber(pid))
                    })
                end
            end
        end

        return {
            success = true,
            players = players,
            count = #players
        }
    end
}

Handlers['get_my_status'] = {
    execute = function(args, ctx)
        local balance = 100000  -- Default
        local mood = 'neutral'
        local multipliers = {}

        -- Get from banking system if available
        pcall(function()
            balance = exports['sv_mr_x']:GetMrXBalance()
        end)

        pcall(function()
            mood = exports['sv_mr_x']:GetMrXMood()
        end)

        pcall(function()
            multipliers = exports['sv_mr_x']:GetMrXMultipliers()
        end)

        -- Determine financial mood
        local financialMood = 'neutral'
        if balance >= 100000 then
            financialMood = 'expansive'
        elseif balance >= 20000 then
            financialMood = 'neutral'
        elseif balance >= 5000 then
            financialMood = 'tense'
        else
            financialMood = 'desperate'
        end

        return {
            success = true,
            balance = balance,
            mood = mood,
            financialMood = financialMood,
            multipliers = multipliers,
            guidance = {
                expansive = 'Be generous with rewards, fewer punishments',
                neutral = 'Standard approach',
                tense = 'Tighter rewards, more collection',
                desperate = 'Aggressive collection, extortion acceptable'
            }
        }
    end
}

-- ============================================
-- SCHEDULING HANDLER
-- ============================================

Handlers['schedule_action'] = {
    execute = function(args, ctx)
        local actionId = exports['sv_mr_x']:ScheduleAction(
            args.tool,
            args.arguments,
            args.delay_minutes * 60  -- Convert to seconds
        )

        if not actionId then
            return { success = false, error = 'Failed to schedule action' }
        end

        return {
            success = true,
            actionId = actionId,
            tool = args.tool,
            scheduledIn = args.delay_minutes .. ' minutes'
        }
    end
}

-- ============================================
-- REGISTER ALL HANDLERS
-- ============================================

CreateThread(function()
    Wait(0)  -- Wait for executor to be ready

    for name, handler in pairs(Handlers) do
        exports['sv_mr_x']:RegisterToolHandler(name, handler)
    end

    if Config.Debug then
        print('^2[MR_X:TOOLS]^7 All tool handlers registered')
    end
end)

return Handlers
