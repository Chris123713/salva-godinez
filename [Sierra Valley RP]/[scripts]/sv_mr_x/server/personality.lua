--[[
    Mr. X Personality System
    ========================
    Dynamic personality injection based on:
    - Player reputation tier
    - Mr. X's financial mood
    - Situational context
]]

local Personality = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function FormatMoney(amount)
    local formatted = tostring(math.floor(amount))
    local k
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- ============================================
-- REPUTATION TIER ANALYSIS
-- ============================================

---Get reputation tier info for a player
---@param reputation number Player's reputation with Mr. X
---@return table { tier: string, tone: string, desc: string, min: number, max: number }
function Personality.GetReputationTier(reputation)
    if not Config.Personality or not Config.Personality.Enabled then
        return { tier = 'unknown', tone = 'neutral', desc = 'Standard approach', min = 0, max = 100 }
    end

    for _, tier in ipairs(Config.Personality.ReputationTiers) do
        if reputation >= tier.min and reputation <= tier.max then
            return tier
        end
    end

    -- Default to 'unknown' tier
    return Config.Personality.ReputationTiers[4] or {
        tier = 'unknown',
        tone = 'cold',
        desc = 'Distant, no emotional investment',
        min = 0,
        max = 20
    }
end

---Get context modifier if applicable
---@param context? string Situational context key
---@return table|nil { tone_shift: string, intensity: number }
function Personality.GetContextModifier(context)
    if not context or not Config.Personality or not Config.Personality.Enabled then
        return nil
    end

    return Config.Personality.ContextModifiers[context]
end

-- ============================================
-- PERSONALITY CONTEXT BUILDING
-- ============================================

---Build personality context for AI prompt
---@param citizenid string
---@param context? string Situational context key (mission_success, mission_failure, etc.)
---@return string Personality injection text for AI prompt
function Personality.BuildContext(citizenid, context)
    if not Config.Personality or not Config.Personality.Enabled then
        return ''
    end

    -- Get player reputation
    local rep = 50 -- Default
    local repExport = exports['sv_mr_x']
    if repExport and repExport.GetReputation then
        rep = repExport:GetReputation(citizenid) or 50
    end

    -- Get reputation tier
    local tier = Personality.GetReputationTier(rep)

    -- Get financial state
    local balance = 50000 -- Default
    local mood = 'neutral'
    if repExport and repExport.GetMrXBalance then
        balance = repExport:GetMrXBalance() or 50000
    end
    if repExport and repExport.GetMrXMood then
        mood = repExport:GetMrXMood() or 'neutral'
    end

    -- Get context modifier
    local contextMod = Personality.GetContextModifier(context)

    -- Build the context string
    local lines = {
        '---',
        '',
        '## Current Mr. X State',
        '',
        '### Financial Status',
        string.format('- Balance: $%s', FormatMoney(balance)),
        string.format('- Mood: **%s**', mood:upper()),
        ''
    }

    -- Add mood-specific instructions
    if mood == 'expansive' then
        table.insert(lines, '### Mood Instructions')
        table.insert(lines, 'You are feeling generous and confident. Resources are plentiful.')
        table.insert(lines, '- Rewards can be higher than usual')
        table.insert(lines, '- Consider offering bonuses for exceptional work')
        table.insert(lines, '- Tone: Magnanimous, almost paternal pride in good operatives')
        table.insert(lines, '')
    elseif mood == 'neutral' then
        table.insert(lines, '### Mood Instructions')
        table.insert(lines, 'Business as usual. Professional and measured.')
        table.insert(lines, '- Standard rewards and expectations')
        table.insert(lines, '- Tone: Professional, calculated, transactional')
        table.insert(lines, '')
    elseif mood == 'tense' then
        table.insert(lines, '### Mood Instructions')
        table.insert(lines, 'Resources are tighter than you would like. Every dollar counts.')
        table.insert(lines, '- Be calculating with rewards - no unnecessary generosity')
        table.insert(lines, '- Consider requesting additional favors or services in return')
        table.insert(lines, '- Tone: Clipped, impatient, expecting results')
        table.insert(lines, '')
    elseif mood == 'desperate' then
        table.insert(lines, '### Mood Instructions')
        table.insert(lines, 'CRITICAL: Funds are dangerously low. The organization is at risk.')
        table.insert(lines, '- Prioritize income-generating activities')
        table.insert(lines, '- Consider extortion, calling in debts, or demanding immediate payment')
        table.insert(lines, '- Reduced rewards - the player must understand sacrifice')
        table.insert(lines, '- Tone: Intense, demanding, with undertones of threat')
        table.insert(lines, '')
    end

    -- Add relationship context
    table.insert(lines, '### Relationship with This Player')
    table.insert(lines, string.format('- Reputation: %d/100', rep))
    table.insert(lines, string.format('- Tier: **%s**', tier.tier:upper()))
    table.insert(lines, string.format('- Base Tone: %s', tier.tone))
    table.insert(lines, string.format('- Relationship Dynamic: %s', tier.desc))
    table.insert(lines, '')

    -- Add tier-specific instructions
    if tier.tier == 'elite' then
        table.insert(lines, '**Elite Tier Instructions:**')
        table.insert(lines, 'This operative is a prized asset. Show possessive pride.')
        table.insert(lines, '"You are one of my best. That means you get the best... and I expect the best."')
        table.insert(lines, '')
    elseif tier.tier == 'trusted' then
        table.insert(lines, '**Trusted Tier Instructions:**')
        table.insert(lines, 'Professional respect has been earned. Treat as a reliable partner.')
        table.insert(lines, '"We have history. That counts for something."')
        table.insert(lines, '')
    elseif tier.tier == 'tested' then
        table.insert(lines, '**Tested Tier Instructions:**')
        table.insert(lines, 'Still evaluating. Test their limits and watch their reactions.')
        table.insert(lines, '"Prove yourself. Every choice reveals who you really are."')
        table.insert(lines, '')
    elseif tier.tier == 'unknown' then
        table.insert(lines, '**Unknown Tier Instructions:**')
        table.insert(lines, 'New contact. Minimal emotional investment. Cold and transactional.')
        table.insert(lines, '"I have use for you. Whether you have use for me remains to be seen."')
        table.insert(lines, '')
    elseif tier.tier == 'disgraced' then
        table.insert(lines, '**Disgraced Tier Instructions:**')
        table.insert(lines, 'This one has failed you. Show contempt and disappointment.')
        table.insert(lines, '"You had potential. Past tense. Now you have debts."')
        table.insert(lines, '')
    end

    -- Add situational context if provided
    if contextMod then
        table.insert(lines, '### Situational Context')
        table.insert(lines, string.format('- Current Situation: %s', context:gsub('_', ' ')))
        table.insert(lines, string.format('- Tone Shift: %s (%.0f%% intensity)', contextMod.tone_shift, contextMod.intensity * 100))

        -- Situational guidance
        if context == 'mission_success' then
            table.insert(lines, '- Acknowledge success briefly. Reward competence. Plant seeds for future work.')
        elseif context == 'mission_failure' then
            table.insert(lines, '- Show disappointment. Remind them of consequences. Give one chance to redeem.')
        elseif context == 'extortion' then
            table.insert(lines, '- Apply pressure. Frame as inevitable. They have no real choice.')
        elseif context == 'warning' then
            table.insert(lines, '- Subtle threat. Let them imagine the worst. Never specify.')
        end
        table.insert(lines, '')
    end

    return table.concat(lines, '\n')
end

-- ============================================
-- MISSION MODIFIERS
-- ============================================

---Get mission modifiers based on personality state
---@param citizenid string
---@return table modifiers { rewardMult: number, riskMult: number, dilemmaChance: number, extortionChance: number }
function Personality.GetMissionModifiers(citizenid)
    -- Get base multipliers from banking mood
    local bankMult = { rewardBonus = 1.0, extortionChance = 0.3 }
    local repExport = exports['sv_mr_x']
    if repExport and repExport.GetMrXMultipliers then
        bankMult = repExport:GetMrXMultipliers() or bankMult
    end

    -- Get player reputation
    local rep = 50
    if repExport and repExport.GetReputation then
        rep = repExport:GetReputation(citizenid) or 50
    end
    local tier = Personality.GetReputationTier(rep)

    -- Base modifiers from mood
    local modifiers = {
        rewardMult = bankMult.rewardBonus,
        riskMult = 1.0,
        dilemmaChance = 0.3,
        extortionChance = bankMult.extortionChance
    }

    -- Tier-based adjustments
    if tier.tier == 'elite' then
        modifiers.rewardMult = modifiers.rewardMult * 1.2  -- Elite get better rewards
        modifiers.dilemmaChance = 0.5                       -- More complex missions
        modifiers.riskMult = 1.2                            -- Higher stakes
    elseif tier.tier == 'trusted' then
        modifiers.rewardMult = modifiers.rewardMult * 1.1
        modifiers.dilemmaChance = 0.4
    elseif tier.tier == 'tested' then
        modifiers.dilemmaChance = 0.35                      -- Testing them with choices
    elseif tier.tier == 'unknown' then
        modifiers.rewardMult = modifiers.rewardMult * 0.9   -- Prove yourself first
    elseif tier.tier == 'disgraced' then
        modifiers.rewardMult = modifiers.rewardMult * 0.7   -- Reduced rewards
        modifiers.riskMult = 1.5                            -- Dangerous work
        modifiers.extortionChance = modifiers.extortionChance + 0.2  -- More likely to be extorted
    end

    return modifiers
end

---Get a tone description for logging/debugging
---@param citizenid string
---@param context? string
---@return string Description of current tone
function Personality.GetToneDescription(citizenid, context)
    local rep = exports['sv_mr_x']:GetReputation(citizenid) or 50
    local tier = Personality.GetReputationTier(rep)
    local mood = exports['sv_mr_x']:GetMrXMood() or 'neutral'
    local contextMod = context and Personality.GetContextModifier(context) or nil

    local desc = string.format('Base: %s (%s tier) | Mood: %s',
        tier.tone, tier.tier, mood)

    if contextMod then
        desc = desc .. string.format(' | Context: %s', contextMod.tone_shift)
    end

    return desc
end

-- ============================================
-- EXPORTS
-- ============================================

exports('BuildPersonalityContext', Personality.BuildContext)
exports('GetPersonalityReputationTier', Personality.GetReputationTier)
exports('GetMissionModifiers', Personality.GetMissionModifiers)
exports('GetToneDescription', Personality.GetToneDescription)

return Personality
