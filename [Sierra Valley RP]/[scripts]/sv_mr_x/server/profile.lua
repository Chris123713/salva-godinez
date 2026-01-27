--[[
    Mr. X Profile System
    ====================
    Manages player profiles, archetypes, and behavioral psychology tracking

    Archetype System:
    - 3 Buckets: AUTHORITY, CIVILIAN, CRIMINAL (based on job/role)
    - 2 Axes: Method (calculated/opportunistic/reckless) + Loyalty (civic/self/crew)
    - 9 Archetypes from 3x3 grid intersection

    Psychology Framework:
    - Tracks behavioral signals to infer personality
    - Uses Cialdini influence principles for manipulation
    - Applies loss aversion and framing effects
]]

local Profile = {}

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

local function JsonDecode(str)
    if str == nil or str == '' then return nil end
    local success, result = pcall(json.decode, str)
    return success and result or nil
end

local function Log(eventType, citizenid, data, source)
    if not Config.LogEvents then return end
    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {citizenid, eventType, JsonEncode(data), source})
end

---Get gang data directly from MySQL players table
---@param citizenid string
---@return table|nil gangData { name: string, label: string, grade: table, isboss: boolean }
local function GetGangFromDatabase(citizenid)
    if not citizenid then return nil end

    local row = MySQL.single.await([[
        SELECT gang FROM players WHERE citizenid = ?
    ]], {citizenid})

    if not row or not row.gang then return nil end

    local gangData = JsonDecode(row.gang)
    if not gangData then return nil end

    -- Return nil if no gang affiliation (name is "none")
    if gangData.name == 'none' or gangData.name == '' then
        return nil
    end

    return gangData
end

---Check if a player has gang affiliation (from database)
---@param citizenid string
---@return boolean hasGang
---@return string|nil gangName
local function HasGangAffiliation(citizenid)
    local gangData = GetGangFromDatabase(citizenid)
    if gangData and gangData.name and gangData.name ~= 'none' and gangData.name ~= '' then
        return true, gangData.name
    end
    return false, nil
end

-- ============================================
-- JOB/GANG CLASSIFICATION TABLES
-- ============================================

-- Jobs that place someone in the AUTHORITY bucket
local AUTHORITY_JOBS = {
    'police', 'lscso', 'lspd', 'sast', 'bcso', 'sahp',  -- Law enforcement
    'safr', 'ambulance', 'ems', 'fire',                  -- Emergency services
    'doj', 'judge', 'lawyer', 'da'                       -- Justice system
}

-- Jobs that lean CIVIC loyalty (even if criminal bucket)
local CIVIC_LEANING_JOBS = {
    'mechanic', 'taxi', 'bus', 'trucker', 'garbage',     -- Public service
    'realestate', 'banker', 'reporter'                    -- Business professionals
}

-- Jobs/indicators for CRIMINAL bucket (besides gang membership)
local CRIMINAL_INDICATOR_JOBS = {
    'unemployed'  -- Default criminal starting point
}

-- ============================================
-- BEHAVIOR METRICS STRUCTURE
-- ============================================

local function CreateDefaultMetrics()
    return {
        -- Violence vs Stealth vs Trade (what they DO)
        violence_score = 0,
        stealth_score = 0,
        trade_score = 0,

        -- Loyalty axis scores
        crew_loyalty = 0,
        self_interest = 0,
        civic_duty = 0,

        -- Method axis scores
        reckless_score = 0,
        calculated_score = 0,
        opportunistic_score = 0,

        -- Psychology indicators (Big Five adjacent)
        impulsivity = 0,          -- High = reckless decisions
        risk_tolerance = 50,      -- 0-100 scale, 50 = neutral
        aggression = 0,           -- Violence tendency
        loyalty_stability = 50,   -- Low = flips sides often

        -- Influence susceptibility (Cialdini)
        reciprocity_responsive = 50,   -- Responds to "I did you a favor"
        scarcity_responsive = 50,      -- Responds to "limited time"
        authority_responsive = 50,     -- Responds to power displays
        social_proof_responsive = 50,  -- Responds to "others are doing it"

        -- Tracking
        total_events = 0,
        last_calculated = os.time()
    }
end

-- ============================================
-- PROFILE CRUD
-- ============================================

---Get a player's Mr. X profile
---@param citizenid string
---@return table|nil profile
function Profile.Get(citizenid)
    if not citizenid then return nil end

    local row = MySQL.single.await([[
        SELECT * FROM mr_x_profiles WHERE citizenid = ?
    ]], {citizenid})

    if not row then return nil end

    -- Parse JSON fields
    row.history = JsonDecode(row.history) or {}
    row.known_facts = JsonDecode(row.known_facts) or {}
    row.vector = JsonDecode(row.vector)
    row.behavior_metrics = JsonDecode(row.behavior_metrics) or CreateDefaultMetrics()

    return row
end

---Check if player data indicates a prospect (new player to be nurtured)
---@param playerData? table Player data from qbx_core
---@return boolean isProspect
local function CheckIsProspect(playerData)
    if not Config.Prospect or not Config.Prospect.Enabled then
        return false
    end

    if not playerData then return false end

    local detection = Config.Prospect.Detection

    -- Check job
    local job = playerData.job and playerData.job.name or 'unemployed'
    if job ~= detection.Job then
        return false
    end

    -- Check money
    local cash = playerData.money and playerData.money.cash or 0
    local bank = playerData.money and playerData.money.bank or 0
    if (cash + bank) > detection.MaxMoney then
        return false
    end

    -- Check gang
    if detection.NoGang then
        local gang = playerData.gang and playerData.gang.name
        if gang and gang ~= '' and gang ~= 'none' then
            return false
        end
    end

    return true
end

---Create a new Mr. X profile for a player
---@param citizenid string
---@param playerData? table Optional player data for archetype detection
---@return table profile
function Profile.Create(citizenid, playerData)
    if not citizenid then
        error('Profile.Create: citizenid is required')
    end

    -- Check if this is a PROSPECT first
    local isProspect = CheckIsProspect(playerData)

    -- Determine initial classification (using database for gang lookup)
    local bucket = Profile.DetermineBucket(playerData, citizenid)
    local methodAxis = MrXConstants.MethodAxis.OPPORTUNISTIC
    local loyaltyAxis = Profile.DetermineInitialLoyalty(playerData, bucket, citizenid)

    -- Use PROSPECT archetype if they qualify, otherwise calculate normally
    local archetype
    if isProspect then
        archetype = MrXConstants.Archetypes.PROSPECT
        if Config.Debug then
            print('^2[MR_X]^7 New player detected as PROSPECT: ' .. citizenid)
        end
    else
        archetype = Profile.CalculateArchetype(methodAxis, loyaltyAxis)
    end

    -- Initial profile data
    local history = {}
    local known_facts = {}
    local behavior_metrics = CreateDefaultMetrics()

    MySQL.insert.await([[
        INSERT INTO mr_x_profiles
        (citizenid, reputation, archetype, bucket, method_axis, loyalty_axis, history, known_facts, behavior_metrics)
        VALUES (?, 0, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid,
        archetype,
        bucket,
        methodAxis,
        loyaltyAxis,
        JsonEncode(history),
        JsonEncode(known_facts),
        JsonEncode(behavior_metrics)
    })

    Log(MrXConstants.EventTypes.PROFILE_CREATED, citizenid, {
        archetype = archetype,
        bucket = bucket,
        method_axis = methodAxis,
        loyalty_axis = loyaltyAxis
    })

    if Config.Debug then
        print('^2[MR_X]^7 Created profile for ' .. citizenid .. ' as ' .. bucket .. '/' .. archetype)
    end

    return Profile.Get(citizenid)
end

---Update a player's profile
---@param citizenid string
---@param updates table Fields to update
---@return boolean success
function Profile.Update(citizenid, updates)
    if not citizenid or not updates then return false end

    -- Build dynamic UPDATE query
    local setClauses = {}
    local values = {}

    for field, value in pairs(updates) do
        -- Handle JSON fields
        if field == 'history' or field == 'known_facts' or field == 'vector' or field == 'behavior_metrics' then
            value = JsonEncode(value)
        end

        table.insert(setClauses, field .. ' = ?')
        table.insert(values, value)
    end

    if #setClauses == 0 then return false end

    -- Add citizenid for WHERE clause
    table.insert(values, citizenid)

    local query = 'UPDATE mr_x_profiles SET ' .. table.concat(setClauses, ', ') .. ' WHERE citizenid = ?'

    local affectedRows = MySQL.update.await(query, values)

    return affectedRows > 0
end

---Get or create a profile for a player
---@param citizenid string
---@param playerData? table Optional player data
---@return table profile
function Profile.GetOrCreate(citizenid, playerData)
    local profile = Profile.Get(citizenid)

    if not profile then
        profile = Profile.Create(citizenid, playerData)
    else
        -- Migrate legacy archetypes if needed
        if MrXConstants.LegacyArchetypeMap[profile.archetype] then
            local newArchetype = MrXConstants.LegacyArchetypeMap[profile.archetype]
            Profile.Update(citizenid, {archetype = newArchetype})
            profile.archetype = newArchetype
        end

        -- Ensure behavior_metrics exists
        if not profile.behavior_metrics or not profile.behavior_metrics.total_events then
            profile.behavior_metrics = CreateDefaultMetrics()
            Profile.Update(citizenid, {behavior_metrics = profile.behavior_metrics})
        end
    end

    return profile
end

-- ============================================
-- BUCKET DETERMINATION (Primary Classification)
-- ============================================

---Determine which bucket a player belongs to
---@param playerData? table Player data from qbx_core
---@param citizenid? string Optional citizenid for database lookup
---@return string bucket
function Profile.DetermineBucket(playerData, citizenid)
    local job = 'unemployed'
    local hasGang = false

    -- Get job from playerData if available
    if playerData and playerData.job then
        job = playerData.job.name or 'unemployed'
    end

    -- Check AUTHORITY jobs first
    for _, authJob in ipairs(AUTHORITY_JOBS) do
        if job == authJob then
            return MrXConstants.Buckets.AUTHORITY
        end
    end

    -- Check for gang membership from DATABASE (authoritative source)
    local cid = citizenid or (playerData and playerData.citizenid)
    if cid then
        hasGang = HasGangAffiliation(cid)
    end

    -- Fallback: check playerData gang if no citizenid
    if not hasGang and playerData and playerData.gang then
        local gang = playerData.gang.name
        hasGang = gang and gang ~= '' and gang ~= 'none'
    end

    if hasGang then
        return MrXConstants.Buckets.CRIMINAL
    end

    -- Check criminal indicator jobs
    for _, crimJob in ipairs(CRIMINAL_INDICATOR_JOBS) do
        if job == crimJob then
            return MrXConstants.Buckets.CIVILIAN
        end
    end

    -- Default to civilian
    return MrXConstants.Buckets.CIVILIAN
end

---Determine initial loyalty axis based on job/gang
---@param playerData? table
---@param bucket string
---@param citizenid? string Optional citizenid for database lookup
---@return string loyaltyAxis
function Profile.DetermineInitialLoyalty(playerData, bucket, citizenid)
    local job = 'unemployed'

    if playerData and playerData.job then
        job = playerData.job.name or 'unemployed'
    end

    -- Authority bucket defaults to civic
    if bucket == MrXConstants.Buckets.AUTHORITY then
        return MrXConstants.LoyaltyAxis.CIVIC
    end

    -- Check gang from DATABASE (authoritative source)
    local cid = citizenid or (playerData and playerData.citizenid)
    local hasGang = false
    if cid then
        hasGang = HasGangAffiliation(cid)
    end

    -- Fallback: check playerData gang if no citizenid
    if not hasGang and playerData and playerData.gang then
        local gang = playerData.gang.name
        hasGang = gang and gang ~= '' and gang ~= 'none'
    end

    -- Gang members default to crew
    if hasGang then
        return MrXConstants.LoyaltyAxis.CREW
    end

    -- Civic-leaning jobs
    for _, civicJob in ipairs(CIVIC_LEANING_JOBS) do
        if job == civicJob then
            return MrXConstants.LoyaltyAxis.CIVIC
        end
    end

    -- Default to self-interest
    return MrXConstants.LoyaltyAxis.SELF
end

-- ============================================
-- ARCHETYPE CALCULATION
-- ============================================

---Calculate archetype from method and loyalty axes
---@param method string Method axis value
---@param loyalty string Loyalty axis value
---@return string archetype
function Profile.CalculateArchetype(method, loyalty)
    local grid = MrXConstants.ArchetypeGrid

    if grid[method] and grid[method][loyalty] then
        return grid[method][loyalty]
    end

    return MrXConstants.Archetypes.UNCLASSIFIED
end

---Legacy function for backward compatibility
---@param playerData? table Player data from qbx_core
---@param citizenid? string Optional citizenid for database lookup
---@return string archetype
function Profile.DetermineArchetype(playerData, citizenid)
    local cid = citizenid or (playerData and playerData.citizenid)
    local bucket = Profile.DetermineBucket(playerData, cid)
    local loyalty = Profile.DetermineInitialLoyalty(playerData, bucket, cid)
    local method = MrXConstants.MethodAxis.OPPORTUNISTIC

    return Profile.CalculateArchetype(method, loyalty)
end

-- ============================================
-- BEHAVIOR TRACKING
-- Records in-game actions that inform psychology classification
-- ============================================

---Record a behavioral event for psychology tracking
---@param citizenid string
---@param category string From MrXConstants.BehaviorCategories
---@param eventType string Specific event identifier
---@param weight? number How much this counts (default 1.0)
---@param context? table Additional context
function Profile.RecordBehavior(citizenid, category, eventType, weight, context)
    if not citizenid or not category then return end

    weight = weight or 1.0

    -- Insert into behavior events table
    MySQL.insert([[
        INSERT INTO mr_x_behavior_events (citizenid, event_category, event_type, weight, context)
        VALUES (?, ?, ?, ?, ?)
    ]], {citizenid, category, eventType, weight, JsonEncode(context)})

    -- Update metrics
    Profile.UpdateBehaviorMetrics(citizenid, category, weight)

    if Config.Debug then
        print('^3[MR_X]^7 Behavior recorded: ' .. citizenid .. ' - ' .. category .. '/' .. eventType)
    end
end

---Update behavior metrics based on recorded event
---@param citizenid string
---@param category string
---@param weight number
function Profile.UpdateBehaviorMetrics(citizenid, category, weight)
    local profile = Profile.Get(citizenid)
    if not profile then return end

    local metrics = profile.behavior_metrics or CreateDefaultMetrics()

    -- Map category to metric updates
    local categoryMetrics = {
        violence = {violence_score = weight, aggression = weight * 2, impulsivity = weight},
        stealth = {stealth_score = weight, calculated_score = weight * 0.5},
        trade = {trade_score = weight, calculated_score = weight * 0.3},
        loyalty_crew = {crew_loyalty = weight, loyalty_stability = weight * 0.5},
        loyalty_self = {self_interest = weight, loyalty_stability = -weight * 0.3},
        loyalty_civic = {civic_duty = weight, loyalty_stability = weight * 0.5},
        reckless = {reckless_score = weight, impulsivity = weight, risk_tolerance = weight * 2},
        calculated = {calculated_score = weight, impulsivity = -weight * 0.5},
        opportunistic = {opportunistic_score = weight}
    }

    local updates = categoryMetrics[category]
    if updates then
        for metric, delta in pairs(updates) do
            if metrics[metric] then
                metrics[metric] = metrics[metric] + delta
            end
        end
    end

    metrics.total_events = (metrics.total_events or 0) + 1
    metrics.last_calculated = os.time()

    Profile.Update(citizenid, {behavior_metrics = metrics})
end

-- ============================================
-- ARCHETYPE REEVALUATION
-- Recalculates archetype based on accumulated behavior
-- ============================================

---Check if we have enough data to classify a player
---@param profile table
---@return boolean canClassify
---@return string confidence
function Profile.CanClassify(profile)
    if not profile then return false, 'none' end

    local metrics = profile.behavior_metrics or CreateDefaultMetrics()
    local totalEvents = metrics.total_events or 0
    local archetypeConfig = Config.Archetypes or {}

    -- Check minimum events threshold
    local minEvents = archetypeConfig.MinEventsForClassification or 8
    if totalEvents < minEvents then
        return false, 'LOW'
    end

    -- Check minimum time threshold
    local minTime = archetypeConfig.MinTimeBeforeClassification or 7200
    local createdAt = profile.created_at
    if createdAt then
        local pattern = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
        local y, m, d, h, min, s = tostring(createdAt):match(pattern)
        if y then
            local profileAge = os.time() - os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
            if profileAge < minTime then
                return false, 'LOW'
            end
        end
    end

    -- Check for direct interaction requirement
    if archetypeConfig.RequireDirectInteraction then
        local hadInteraction = profile.last_contact ~= nil
        if not hadInteraction then
            return false, 'LOW'
        end
    end

    -- Determine confidence level
    local confidence = 'MEDIUM'
    local confidenceLevels = archetypeConfig.ConfidenceLevels or {}
    if confidenceLevels.HIGH and totalEvents >= confidenceLevels.HIGH.minEvents then
        confidence = 'HIGH'
    end

    return true, confidence
end

---Re-evaluate and potentially update a player's archetype
---@param citizenid string
---@param source? number
---@return string newArchetype
function Profile.ReevaluateArchetype(citizenid, source)
    local profile = Profile.Get(citizenid)
    if not profile then return MrXConstants.Archetypes.UNCLASSIFIED end

    local player = source and exports.qbx_core:GetPlayer(source)
    local playerData = player and player.PlayerData

    -- Check if they're currently a PROSPECT
    local wasProspect = profile.archetype == MrXConstants.Archetypes.PROSPECT

    -- Check if they still qualify as a prospect
    local stillProspect = CheckIsProspect(playerData)

    -- If they were a prospect but no longer qualify (got a job, money, etc.)
    -- transition them out of prospect status
    if wasProspect and not stillProspect then
        if Config.Debug then
            print('^3[MR_X]^7 ' .. citizenid .. ' transitioning from PROSPECT to regular classification')
        end
        -- They're no longer a prospect - proceed with normal classification
    elseif stillProspect then
        -- Still a prospect, keep them that way
        return MrXConstants.Archetypes.PROSPECT
    end

    -- Recalculate bucket (job/gang can change) - uses DATABASE for gang lookup
    local bucket = Profile.DetermineBucket(playerData, citizenid)

    -- Calculate axes from behavior metrics
    local metrics = profile.behavior_metrics or CreateDefaultMetrics()

    -- Check if we have enough data to classify
    local canClassify, confidence = Profile.CanClassify(profile)

    local methodAxis, loyaltyAxis, newArchetype

    if not canClassify then
        -- Not enough data - stay UNCLASSIFIED but update bucket
        methodAxis = MrXConstants.MethodAxis.OPPORTUNISTIC
        loyaltyAxis = Profile.DetermineInitialLoyalty(playerData, bucket, citizenid)
        newArchetype = MrXConstants.Archetypes.UNCLASSIFIED

        if Config.Debug then
            print('^3[MR_X]^7 Not enough data to classify ' .. citizenid .. ' (confidence: ' .. confidence .. ')')
        end
    else
        -- Check axis thresholds (need clear evidence before locking axes)
        local thresholds = Config.Archetypes and Config.Archetypes.AxisThresholds or {method = 3.0, loyalty = 3.0}

        -- Determine Method axis (with threshold check)
        methodAxis = Profile.CalculateMethodAxisWithThreshold(metrics, thresholds.method)

        -- Determine Loyalty axis (with threshold check) - uses DATABASE for gang lookup
        loyaltyAxis = Profile.CalculateLoyaltyAxisWithThreshold(metrics, playerData, thresholds.loyalty, citizenid)

        -- Calculate archetype
        newArchetype = Profile.CalculateArchetype(methodAxis, loyaltyAxis)
    end

    -- Check if anything changed
    local changed = (
        newArchetype ~= profile.archetype or
        bucket ~= profile.bucket or
        methodAxis ~= profile.method_axis or
        loyaltyAxis ~= profile.loyalty_axis
    )

    if changed then
        Profile.Update(citizenid, {
            archetype = newArchetype,
            bucket = bucket,
            method_axis = methodAxis,
            loyalty_axis = loyaltyAxis,
            classification_confidence = confidence,
            archetype_updated_at = os.date('%Y-%m-%d %H:%M:%S')
        })

        Log(MrXConstants.EventTypes.ARCHETYPE_CHANGED, citizenid, {
            old_archetype = profile.archetype,
            new_archetype = newArchetype,
            bucket = bucket,
            method = methodAxis,
            loyalty = loyaltyAxis,
            confidence = confidence
        }, source)

        if Config.Debug then
            print('^2[MR_X]^7 Archetype changed: ' .. citizenid .. ' -> ' .. newArchetype .. ' (confidence: ' .. confidence .. ')')
        end
    end

    return newArchetype
end

---Calculate method axis from behavior metrics
---@param metrics table
---@return string methodAxis
function Profile.CalculateMethodAxis(metrics)
    local calculated = metrics.calculated_score or 0
    local reckless = metrics.reckless_score or 0
    local opportunistic = metrics.opportunistic_score or 0

    -- Also factor in impulsivity
    reckless = reckless + (metrics.impulsivity or 0) * 0.5
    calculated = calculated - (metrics.impulsivity or 0) * 0.3

    -- Find dominant
    if calculated > reckless and calculated > opportunistic then
        return MrXConstants.MethodAxis.CALCULATED
    elseif reckless > calculated and reckless > opportunistic then
        return MrXConstants.MethodAxis.RECKLESS
    else
        return MrXConstants.MethodAxis.OPPORTUNISTIC
    end
end

---Calculate method axis with threshold (requires clear evidence)
---@param metrics table
---@param threshold number Minimum score difference needed
---@return string methodAxis
function Profile.CalculateMethodAxisWithThreshold(metrics, threshold)
    local calculated = metrics.calculated_score or 0
    local reckless = metrics.reckless_score or 0
    local opportunistic = metrics.opportunistic_score or 0

    -- Factor in impulsivity
    reckless = reckless + (metrics.impulsivity or 0) * 0.5
    calculated = calculated - (metrics.impulsivity or 0) * 0.3

    -- Check if any axis has clear dominance (meets threshold)
    local max = math.max(calculated, reckless, opportunistic)
    local scores = {calculated, reckless, opportunistic}
    table.sort(scores)
    local secondMax = scores[2]

    -- Need threshold difference to lock in an axis
    local difference = max - secondMax
    if difference < threshold then
        -- Not enough evidence - default to opportunistic
        return MrXConstants.MethodAxis.OPPORTUNISTIC
    end

    -- Clear winner
    if calculated == max then
        return MrXConstants.MethodAxis.CALCULATED
    elseif reckless == max then
        return MrXConstants.MethodAxis.RECKLESS
    else
        return MrXConstants.MethodAxis.OPPORTUNISTIC
    end
end

---Calculate loyalty axis from behavior metrics and player data
---@param metrics table
---@param playerData? table
---@param citizenid? string Optional citizenid for database lookup
---@return string loyaltyAxis
function Profile.CalculateLoyaltyAxis(metrics, playerData, citizenid)
    local crew = metrics.crew_loyalty or 0
    local self_ = metrics.self_interest or 0
    local civic = metrics.civic_duty or 0

    -- Check gang from DATABASE (authoritative source)
    local cid = citizenid or (playerData and playerData.citizenid)
    local hasGang = false
    if cid then
        hasGang = HasGangAffiliation(cid)
    end

    -- Fallback: check playerData gang if no citizenid
    if not hasGang and playerData and playerData.gang then
        local gang = playerData.gang.name
        hasGang = gang and gang ~= '' and gang ~= 'none'
    end

    -- Gang membership boosts crew loyalty
    if hasGang then
        crew = crew + 10
    end

    -- Authority job boosts civic
    if playerData then
        local job = playerData.job and playerData.job.name
        for _, authJob in ipairs(AUTHORITY_JOBS) do
            if job == authJob then
                civic = civic + 10
                break
            end
        end
    end

    -- Find dominant
    if crew > self_ and crew > civic then
        return MrXConstants.LoyaltyAxis.CREW
    elseif civic > self_ and civic > crew then
        return MrXConstants.LoyaltyAxis.CIVIC
    else
        return MrXConstants.LoyaltyAxis.SELF
    end
end

---Calculate loyalty axis with threshold (requires clear evidence)
---@param metrics table
---@param playerData? table
---@param threshold number Minimum score difference needed
---@param citizenid? string Optional citizenid for database lookup
---@return string loyaltyAxis
function Profile.CalculateLoyaltyAxisWithThreshold(metrics, playerData, threshold, citizenid)
    local crew = metrics.crew_loyalty or 0
    local self_ = metrics.self_interest or 0
    local civic = metrics.civic_duty or 0

    -- Check gang from DATABASE (authoritative source)
    local cid = citizenid or (playerData and playerData.citizenid)
    local hasGang = false
    if cid then
        hasGang = HasGangAffiliation(cid)
    end

    -- Fallback: check playerData gang if no citizenid
    if not hasGang and playerData and playerData.gang then
        local gang = playerData.gang.name
        hasGang = gang and gang ~= '' and gang ~= 'none'
    end

    -- Gang membership boosts crew loyalty
    if hasGang then
        crew = crew + 10
    end

    -- Authority job boosts civic
    if playerData then
        local job = playerData.job and playerData.job.name
        for _, authJob in ipairs(AUTHORITY_JOBS) do
            if job == authJob then
                civic = civic + 10
                break
            end
        end
    end

    -- Check if any axis has clear dominance
    local max = math.max(crew, self_, civic)
    local scores = {crew, self_, civic}
    table.sort(scores)
    local secondMax = scores[2]

    -- Need threshold difference to lock in an axis
    local difference = max - secondMax
    if difference < threshold then
        -- Not enough evidence - default to self
        return MrXConstants.LoyaltyAxis.SELF
    end

    -- Clear winner
    if crew == max then
        return MrXConstants.LoyaltyAxis.CREW
    elseif civic == max then
        return MrXConstants.LoyaltyAxis.CIVIC
    else
        return MrXConstants.LoyaltyAxis.SELF
    end
end

-- ============================================
-- PSYCHOLOGY HELPERS
-- Used by AI system for manipulation tactics
-- ============================================

---Get recommended influence tactics for a player
---@param citizenid string
---@return table tactics
function Profile.GetInfluenceTactics(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then
        return {primary = 'reciprocity', secondary = 'scarcity', avoid = {}}
    end

    local metrics = profile.behavior_metrics or CreateDefaultMetrics()
    local archetype = profile.archetype or 'unclassified'

    -- Archetype-based primary tactics
    local archetypeTactics = {
        guardian = {primary = 'authority', secondary = 'social_proof', frame = 'duty'},
        fixer = {primary = 'reciprocity', secondary = 'authority', frame = 'profit'},
        syndicate = {primary = 'commitment', secondary = 'social_proof', frame = 'power'},
        reformer = {primary = 'social_proof', secondary = 'reciprocity', frame = 'justice'},
        hustler = {primary = 'scarcity', secondary = 'reciprocity', frame = 'profit'},
        soldier = {primary = 'commitment', secondary = 'authority', frame = 'loyalty'},
        loose_cannon = {primary = 'scarcity', secondary = 'authority', frame = 'revenge'},
        wildcard = {primary = 'scarcity', secondary = 'liking', frame = 'thrill'},
        enforcer = {primary = 'authority', secondary = 'commitment', frame = 'power'},
        unclassified = {primary = 'reciprocity', secondary = 'scarcity', frame = 'opportunity'}
    }

    local tactics = archetypeTactics[archetype] or archetypeTactics.unclassified

    -- Adjust based on responsiveness metrics
    if metrics.reciprocity_responsive > 70 then
        tactics.boost_reciprocity = true
    end
    if metrics.scarcity_responsive > 70 then
        tactics.boost_scarcity = true
    end
    if metrics.authority_responsive < 30 then
        tactics.avoid = tactics.avoid or {}
        table.insert(tactics.avoid, 'authority')
    end

    -- Loss aversion framing (almost always effective)
    tactics.use_loss_aversion = true

    return tactics
end

---Get psychological profile summary for AI context
---@param citizenid string
---@return table summary
function Profile.GetPsychologySummary(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then
        return {archetype = 'unknown', approach = 'cautious observation'}
    end

    local metrics = profile.behavior_metrics or CreateDefaultMetrics()
    local archetype = profile.archetype or 'unclassified'
    local info = MrXConstants.ArchetypeInfo[archetype] or {}

    -- Build natural language summary for AI
    local traits = {}

    if metrics.impulsivity > 5 then
        table.insert(traits, 'impulsive')
    elseif metrics.calculated_score > 5 then
        table.insert(traits, 'calculating')
    end

    if metrics.aggression > 5 then
        table.insert(traits, 'aggressive')
    end

    if metrics.risk_tolerance > 70 then
        table.insert(traits, 'risk-seeking')
    elseif metrics.risk_tolerance < 30 then
        table.insert(traits, 'cautious')
    end

    if metrics.crew_loyalty > metrics.self_interest * 1.5 then
        table.insert(traits, 'loyal to crew')
    elseif metrics.self_interest > metrics.crew_loyalty * 1.5 then
        table.insert(traits, 'self-serving')
    end

    return {
        archetype = archetype,
        archetype_label = info.label or archetype,
        bucket = profile.bucket or 'civilian',
        method = profile.method_axis or 'opportunistic',
        loyalty = profile.loyalty_axis or 'self',
        approach = info.mrx_approach or 'standard',
        traits = traits,
        tactics = Profile.GetInfluenceTactics(citizenid),
        reputation = profile.reputation or 0
    }
end

-- ============================================
-- VECTOR EMBEDDING STORAGE
-- Stores AI embeddings for personalized responses
-- ============================================

---Generate and store a vector embedding for a player's profile
---@param citizenid string
---@return table|nil embedding
function Profile.GenerateEmbedding(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then return nil end

    -- Build text representation of player for embedding
    local textParts = {
        'Archetype: ' .. (profile.archetype or 'unclassified'),
        'Bucket: ' .. (profile.bucket or 'civilian'),
        'Method: ' .. (profile.method_axis or 'opportunistic'),
        'Loyalty: ' .. (profile.loyalty_axis or 'self'),
        'Reputation: ' .. tostring(profile.reputation or 0)
    }

    -- Add known facts summary
    local facts = profile.known_facts or {}
    local factCount = 0
    for factKey, factData in pairs(facts) do
        factCount = factCount + 1
        if factCount <= 10 then  -- Limit to top 10 facts
            if type(factData) == 'table' and factData.data then
                table.insert(textParts, 'Fact ' .. factKey .. ': ' .. tostring(factData.data))
            else
                table.insert(textParts, 'Fact ' .. factKey .. ': ' .. tostring(factData))
            end
        end
    end

    -- Add behavior metrics summary
    local metrics = profile.behavior_metrics or {}
    if metrics.violence_score and metrics.violence_score > 5 then
        table.insert(textParts, 'Violent tendencies')
    end
    if metrics.calculated_score and metrics.calculated_score > 5 then
        table.insert(textParts, 'Calculating personality')
    end
    if metrics.crew_loyalty and metrics.crew_loyalty > 5 then
        table.insert(textParts, 'Strong crew loyalty')
    end

    local profileText = table.concat(textParts, '. ')

    -- Check if sv_nexus_tools is available for embeddings
    local hasNexusTools = GetResourceState('sv_nexus_tools') == 'started'
    if not hasNexusTools then
        if Config.Debug then
            print('^3[MR_X]^7 sv_nexus_tools not available for embeddings')
        end
        return nil
    end

    -- Generate embedding via OpenAI
    local success, response = pcall(function()
        return exports['sv_nexus_tools']:GetEmbedding(profileText)
    end)

    if not success or not response then
        if Config.Debug then
            print('^1[MR_X]^7 Failed to generate embedding: ' .. tostring(response))
        end
        return nil
    end

    -- Store the embedding
    local embedding = {
        vector = response,
        text_hash = GetHashKey(profileText),
        generated_at = os.time(),
        profile_version = profile.archetype_updated_at or os.time()
    }

    Profile.Update(citizenid, {vector = embedding})

    if Config.Debug then
        print('^2[MR_X]^7 Generated embedding for ' .. citizenid)
    end

    return embedding
end

---Get the stored embedding for a player
---@param citizenid string
---@return table|nil embedding
function Profile.GetEmbedding(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then return nil end
    return profile.vector
end

---Check if embedding needs refresh (stale > 24 hours or profile changed)
---@param citizenid string
---@return boolean needsRefresh
function Profile.EmbeddingNeedsRefresh(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then return true end

    local embedding = profile.vector
    if not embedding or not embedding.generated_at then
        return true
    end

    -- Check age (24 hours = 86400 seconds)
    local age = os.time() - embedding.generated_at
    if age > 86400 then
        return true
    end

    -- Check if profile changed since embedding
    if profile.archetype_updated_at and embedding.profile_version then
        if profile.archetype_updated_at > embedding.profile_version then
            return true
        end
    end

    return false
end

---Get or generate embedding for a player
---@param citizenid string
---@return table|nil embedding
function Profile.GetOrGenerateEmbedding(citizenid)
    if Profile.EmbeddingNeedsRefresh(citizenid) then
        return Profile.GenerateEmbedding(citizenid)
    end
    return Profile.GetEmbedding(citizenid)
end

---Find similar players by embedding similarity (for AI context)
---@param citizenid string
---@param limit? number Max results (default 5)
---@return table similarPlayers
function Profile.FindSimilarPlayers(citizenid, limit)
    limit = limit or 5

    local sourceProfile = Profile.Get(citizenid)
    if not sourceProfile or not sourceProfile.vector then
        return {}
    end

    -- This would require vector similarity search
    -- For now, fall back to archetype matching
    local results = MySQL.query.await([[
        SELECT citizenid, reputation, archetype, bucket
        FROM mr_x_profiles
        WHERE citizenid != ?
          AND archetype = ?
          AND bucket = ?
        ORDER BY ABS(reputation - ?) ASC
        LIMIT ?
    ]], {
        citizenid,
        sourceProfile.archetype or 'unclassified',
        sourceProfile.bucket or 'civilian',
        sourceProfile.reputation or 0,
        limit
    })

    return results or {}
end

-- ============================================
-- HISTORY MANAGEMENT
-- ============================================

---Add an entry to player's mission history
---@param citizenid string
---@param entry table {missionId, type, outcome, timestamp, rewards?, notes?}
---@return boolean success
function Profile.AddToHistory(citizenid, entry)
    local profile = Profile.Get(citizenid)
    if not profile then return false end

    local history = profile.history or {}

    -- Add timestamp if not provided
    entry.timestamp = entry.timestamp or os.time()

    -- Insert at beginning (most recent first)
    table.insert(history, 1, entry)

    -- Keep only last 50 entries
    while #history > 50 do
        table.remove(history)
    end

    -- Update mission counts
    local updates = {
        history = history,
        total_missions = (profile.total_missions or 0) + 1
    }

    if entry.outcome == MrXConstants.MissionOutcome.SUCCESS then
        updates.successful_missions = (profile.successful_missions or 0) + 1
    end

    updates.last_mission = os.date('%Y-%m-%d %H:%M:%S')

    -- Record behavior based on mission type and outcome
    if entry.type then
        local category = 'opportunistic'
        if entry.type == 'combat' or entry.type == 'enforcement' or entry.type == 'hit' then
            category = 'violence'
        elseif entry.type == 'stealth' or entry.type == 'infiltration' then
            category = 'stealth'
        elseif entry.type == 'trade' or entry.type == 'smuggling' then
            category = 'trade'
        end

        -- Success = calculated, failure = reckless indicator
        if entry.outcome == MrXConstants.MissionOutcome.SUCCESS then
            Profile.RecordBehavior(citizenid, 'calculated', 'mission_success', 0.5)
        elseif entry.outcome == MrXConstants.MissionOutcome.FAILURE then
            Profile.RecordBehavior(citizenid, 'reckless', 'mission_failure', 0.3)
        end

        Profile.RecordBehavior(citizenid, category, 'mission_' .. entry.type, 1.0)
    end

    return Profile.Update(citizenid, updates)
end

---Get player's recent history
---@param citizenid string
---@param limit? number Max entries to return (default 10)
---@return table history
function Profile.GetHistory(citizenid, limit)
    local profile = Profile.Get(citizenid)
    if not profile then return {} end

    local history = profile.history or {}
    limit = limit or 10

    local result = {}
    for i = 1, math.min(#history, limit) do
        result[i] = history[i]
    end

    return result
end

-- ============================================
-- KNOWN FACTS MANAGEMENT
-- ============================================

---Add a known fact about the player
---@param citizenid string
---@param factKey string Unique identifier for the fact
---@param factData any The fact data
---@return boolean success
function Profile.AddKnownFact(citizenid, factKey, factData)
    local profile = Profile.Get(citizenid)
    if not profile then return false end

    local known_facts = profile.known_facts or {}

    -- Add or update fact
    known_facts[factKey] = {
        data = factData,
        discovered_at = os.time()
    }

    -- Record behavior based on fact type
    local factBehaviors = {
        KILL = {'violence', 'player_kill', 2.0},
        ARREST = {'civic_duty', 'made_arrest', 1.0},
        GANG_ACTIVITY = {'loyalty_crew', 'gang_activity', 1.0},
        ROBBERY = {'reckless', 'robbery', 1.0},
        DRUG_SALE = {'trade', 'drug_sale', 1.0},
        LARGE_TRANSACTION = {'trade', 'large_transaction', 0.5}
    }

    local behavior = factBehaviors[factKey:upper()]
    if behavior then
        Profile.RecordBehavior(citizenid, behavior[1], behavior[2], behavior[3])
    end

    return Profile.Update(citizenid, {known_facts = known_facts})
end

---Get a specific known fact
---@param citizenid string
---@param factKey string
---@return any|nil factData
function Profile.GetKnownFact(citizenid, factKey)
    local profile = Profile.Get(citizenid)
    if not profile then return nil end

    local facts = profile.known_facts or {}
    local fact = facts[factKey]

    return fact and fact.data or nil
end

---Get all known facts about a player
---@param citizenid string
---@return table facts
function Profile.GetAllKnownFacts(citizenid)
    local profile = Profile.Get(citizenid)
    if not profile then return {} end

    return profile.known_facts or {}
end

-- ============================================
-- CONTACT TRACKING
-- ============================================

---Update last contact time
---@param citizenid string
---@return boolean success
function Profile.UpdateLastContact(citizenid)
    return Profile.Update(citizenid, {
        last_contact = os.date('%Y-%m-%d %H:%M:%S')
    })
end

---Check if enough time has passed since last contact
---@param citizenid string
---@param cooldownSec number Cooldown in seconds
---@return boolean canContact
function Profile.CanContact(citizenid, cooldownSec)
    local profile = Profile.Get(citizenid)
    if not profile then return true end  -- New player, can contact

    if not profile.last_contact then return true end

    -- Parse timestamp
    local lastContact = profile.last_contact
    if type(lastContact) == 'string' then
        -- Convert MySQL timestamp string to unix time
        local pattern = '(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)'
        local y, m, d, h, min, s = lastContact:match(pattern)
        if y then
            lastContact = os.time({year = y, month = m, day = d, hour = h, min = min, sec = s})
        else
            return true
        end
    end

    local elapsed = os.time() - lastContact
    return elapsed >= cooldownSec
end

-- ============================================
-- PLAYER LOAD HOOK
-- ============================================

-- Create profile when player loads
AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData then return end

    local citizenid = Player.PlayerData.citizenid
    Profile.GetOrCreate(citizenid, Player.PlayerData)
end)

-- Also listen for qbx_core event
RegisterNetEvent('qbx_core:server:playerLoaded', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    Profile.GetOrCreate(citizenid, player.PlayerData)
end)

-- ============================================
-- OPT-OUT / EXEMPTION SYSTEM
-- ============================================

---Check if a player is exempt from Mr. X (opted out)
---Exempt players receive NO contact - no HARM, no HELP, nothing
---@param source number Player source
---@return boolean isExempt
---@return string|nil reason
function Profile.IsExempt(source)
    if not source then return true, 'no_source' end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return true, 'player_not_found' end

    local citizenid = player.PlayerData.citizenid

    -- Check 1: ACE permission
    if IsPlayerAceAllowed(source, Config.OptOut.AcePermission) then
        return true, 'ace_permission'
    end

    -- Check 2: Always-exempt jobs
    local job = player.PlayerData.job
    if job and job.name then
        for _, exemptJob in ipairs(Config.OptOut.ExemptJobs) do
            if job.name == exemptJob then
                return true, 'exempt_job'
            end
        end

        -- Check 3: Job + grade exemption
        local grade = job.grade and job.grade.level or 0
        for _, exemption in ipairs(Config.OptOut.ExemptJobGrades) do
            if job.name == exemption.job and grade >= exemption.minGrade then
                return true, 'exempt_job_grade'
            end
        end
    end

    -- Check 4: Exempt gangs
    local gang = player.PlayerData.gang
    if gang and gang.name then
        for _, exemptGang in ipairs(Config.OptOut.ExemptGangs) do
            if gang.name == exemptGang then
                return true, 'exempt_gang'
            end
        end
    end

    -- Check 5: Database opt-out flag
    local profile = Profile.Get(citizenid)
    if profile and profile.opted_out then
        return true, 'manual_optout'
    end

    -- Check 6: Guardian archetype with exempt_default
    if profile and profile.archetype then
        local info = MrXConstants.ArchetypeInfo[profile.archetype]
        if info and info.exempt_default then
            return true, 'archetype_exempt'
        end
    end

    return false, nil
end

---Check if a citizenid is exempt (for offline checks)
---@param citizenid string
---@return boolean isExempt
---@return string|nil reason
function Profile.IsExemptByCitizenId(citizenid)
    if not citizenid then return true, 'no_citizenid' end

    -- Try to find online player first
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player and player.PlayerData.citizenid == citizenid then
            return Profile.IsExempt(tonumber(playerId))
        end
    end

    -- Player offline - check database flag only
    local profile = Profile.Get(citizenid)
    if profile and profile.opted_out then
        return true, 'manual_optout'
    end

    return false, nil
end

---Set opt-out status for a player (admin use)
---@param citizenid string
---@param optedOut boolean
---@return boolean success
function Profile.SetOptOut(citizenid, optedOut)
    if not citizenid then return false end

    local success = Profile.Update(citizenid, {
        opted_out = optedOut and 1 or 0
    })

    if success then
        Log(MrXConstants.EventTypes.ADMIN_ACTION, citizenid, {
            action = 'set_optout',
            optedOut = optedOut
        })
    end

    return success
end

---Get opt-out status display info
---@param source number
---@return table info
function Profile.GetOptOutInfo(source)
    local isExempt, reason = Profile.IsExempt(source)

    local reasonLabels = {
        ace_permission = 'ACE Permission (sv_mr_x.optout)',
        exempt_job = 'Exempt Job',
        exempt_job_grade = 'Exempt Job Grade (Leadership)',
        exempt_gang = 'Exempt Gang',
        manual_optout = 'Manual Opt-Out',
        archetype_exempt = 'Archetype Exempt (Guardian)',
        no_source = 'Invalid Source',
        player_not_found = 'Player Not Found'
    }

    return {
        isExempt = isExempt,
        reason = reason,
        reasonLabel = reasonLabels[reason] or reason or 'Not Exempt'
    }
end

-- ============================================
-- GANG ELIGIBILITY
-- ============================================

---Get list of eligible gangs for bounties
---@return table gangs
function Profile.GetEligibleGangs()
    local rows = MySQL.query.await([[
        SELECT gang_name, gang_label FROM mr_x_eligible_gangs WHERE is_eligible = 1
    ]])

    local gangs = {}
    for _, row in ipairs(rows or {}) do
        table.insert(gangs, row.gang_name)
    end

    return gangs
end

---Check if a gang is eligible for bounty offers
---@param gangName string
---@return boolean eligible
function Profile.IsGangEligible(gangName)
    if not gangName or gangName == '' or gangName == 'none' then
        return false
    end

    local row = MySQL.single.await([[
        SELECT is_eligible FROM mr_x_eligible_gangs WHERE gang_name = ?
    ]], {gangName})

    return row and row.is_eligible == 1
end

-- ============================================
-- GANG CHANGE LISTENER
-- Auto-reevaluate archetype when player's gang changes
-- ============================================

-- Listen for gang changes (qbx_core)
RegisterNetEvent('qbx_core:server:onGroupUpdate', function(groupName, groupGrade)
    local source = source
    if not source then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    -- Reevaluate archetype using DATABASE for current gang status
    local oldProfile = Profile.Get(citizenid)
    local oldBucket = oldProfile and oldProfile.bucket or 'unknown'

    Profile.ReevaluateArchetype(citizenid, source)

    local newProfile = Profile.Get(citizenid)
    local newBucket = newProfile and newProfile.bucket or 'unknown'

    if Config.Debug then
        local hasGang, gangName = HasGangAffiliation(citizenid)
        print(string.format('^3[MR_X]^7 Gang update for %s: hasGang=%s, gang=%s, bucket %s -> %s',
            citizenid,
            tostring(hasGang),
            gangName or 'none',
            oldBucket,
            newBucket
        ))
    end
end)

-- Also listen for setPlayerData changes (covers gang updates via SetPlayerData)
RegisterNetEvent('QBCore:Server:OnPlayerUpdate', function()
    local source = source
    if not source then return end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    -- Debounce: only reevaluate if bucket might have changed
    local profile = Profile.Get(citizenid)
    if profile then
        local currentBucket = Profile.DetermineBucket(player.PlayerData, citizenid)
        if currentBucket ~= profile.bucket then
            Profile.ReevaluateArchetype(citizenid, source)
            if Config.Debug then
                print('^3[MR_X]^7 Bucket changed for ' .. citizenid .. ': ' .. profile.bucket .. ' -> ' .. currentBucket)
            end
        end
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('GetProfile', Profile.Get)
exports('CreateProfile', Profile.Create)
exports('UpdateProfile', Profile.Update)
exports('GetOrCreateProfile', Profile.GetOrCreate)
exports('DetermineArchetype', Profile.DetermineArchetype)
exports('DetermineBucket', Profile.DetermineBucket)
exports('ReevaluateArchetype', Profile.ReevaluateArchetype)
exports('CanClassify', Profile.CanClassify)
exports('RecordBehavior', Profile.RecordBehavior)
exports('GetInfluenceTactics', Profile.GetInfluenceTactics)
exports('GetPsychologySummary', Profile.GetPsychologySummary)
exports('AddToHistory', Profile.AddToHistory)
exports('GetHistory', Profile.GetHistory)
exports('AddKnownFact', Profile.AddKnownFact)
exports('GetKnownFact', Profile.GetKnownFact)
exports('GetAllKnownFacts', Profile.GetAllKnownFacts)
exports('UpdateLastContact', Profile.UpdateLastContact)
exports('CanContact', Profile.CanContact)
exports('IsExempt', Profile.IsExempt)
exports('IsExemptByCitizenId', Profile.IsExemptByCitizenId)
exports('SetOptOut', Profile.SetOptOut)
exports('GetOptOutInfo', Profile.GetOptOutInfo)
exports('GetEligibleGangs', Profile.GetEligibleGangs)
exports('IsGangEligible', Profile.IsGangEligible)
exports('HasGangAffiliation', HasGangAffiliation)
exports('GetGangFromDatabase', GetGangFromDatabase)
exports('GenerateEmbedding', Profile.GenerateEmbedding)
exports('GetEmbedding', Profile.GetEmbedding)
exports('EmbeddingNeedsRefresh', Profile.EmbeddingNeedsRefresh)
exports('GetOrGenerateEmbedding', Profile.GetOrGenerateEmbedding)
exports('FindSimilarPlayers', Profile.FindSimilarPlayers)

-- Return module
return Profile
