--[[
    Mr. X Services (HELP Options)
    =============================
    Premium services available to high-reputation players
]]

local Services = {}

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

local function GetProfile(citizenid)
    return exports['sv_mr_x']:GetProfile(citizenid)
end

local function GetReputation(citizenid)
    return exports['sv_mr_x']:GetReputation(citizenid)
end

local function SendMessage(source, message)
    return exports['sv_mr_x']:SendMrXMessage(source, message)
end

local function SendEmail(source, subject, body, actions)
    return exports['sv_mr_x']:SendMrXEmail(source, subject, body, actions)
end

-- ============================================
-- SERVICE AVAILABILITY CHECKS
-- ============================================

---Check if player can access a service
---@param citizenid string
---@param serviceConfig table Service config from Config.Services
---@param source? number Player source for exemption check
---@return boolean canAccess
---@return string|nil reason
function Services.CanAccess(citizenid, serviceConfig, source)
    -- Check exemption first - exempt players get NO services
    if source then
        local isExempt = exports['sv_mr_x']:IsExempt(source)
        if isExempt then
            return false, 'exempt'
        end
    else
        local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(citizenid)
        if isExempt then
            return false, 'exempt'
        end
    end

    local rep = GetReputation(citizenid)

    if rep < serviceConfig.minRep then
        return false, 'insufficient_reputation'
    end

    return true
end

---Check if player can afford a service
---@param source number
---@param cost number
---@return boolean canAfford
function Services.CanAfford(source, cost)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    return player.PlayerData.money.cash >= cost
end

---Charge player for a service
---@param source number
---@param cost number
---@param reason string
---@return boolean success
function Services.Charge(source, cost, reason)
    return exports.qbx_core:RemoveMoney(source, 'cash', cost, reason)
end

-- ============================================
-- LOCATION TIPS
-- ============================================

-- Pre-defined tip locations (can be expanded)
local TipLocations = {
    -- Low tier tips (rep 20+)
    {minRep = 20, coords = vec3(892.4, -1050.2, 32.8), description = "Abandoned garage. Might find something useful in the back.", value = 'low'},
    {minRep = 20, coords = vec3(-58.9, -1752.4, 29.4), description = "Loading dock. Shipment comes in late.", value = 'low'},
    {minRep = 20, coords = vec3(1208.5, -1402.1, 35.2), description = "Storage unit. Owner hasn't been seen in weeks.", value = 'low'},

    -- Medium tier tips (rep 40+)
    {minRep = 40, coords = vec3(-1117.7, 4950.9, 218.7), description = "Off-grid cabin. Someone's been stockpiling.", value = 'medium'},
    {minRep = 40, coords = vec3(2433.5, 4968.1, 42.4), description = "Farm house. More than crops grow there.", value = 'medium'},
    {minRep = 40, coords = vec3(144.8, -3007.1, 7.0), description = "Container yard. Blue container, third row.", value = 'medium'},

    -- High tier tips (rep 60+)
    {minRep = 60, coords = vec3(1392.5, 1148.2, 114.3), description = "Mansion safe. Security rotates at 3 AM.", value = 'high'},
    {minRep = 60, coords = vec3(-2173.8, 4289.5, 49.2), description = "Military surplus. Guard sleeps on the job.", value = 'high'},
    {minRep = 60, coords = vec3(2512.1, -384.7, 107.1), description = "Executive office. Insurance doesn't cover everything.", value = 'high'}
}

---Get a location tip for a player
---@param source number
---@return boolean success
function Services.GetLocationTip(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    local canAccess, reason = Services.CanAccess(citizenid, Config.Services.LocationTip, source)
    if not canAccess then
        SendMessage(source, "You haven't earned that privilege yet.")
        return false
    end

    local cost = Config.Services.LocationTip.cost
    if not Services.CanAfford(source, cost) then
        SendMessage(source, "This information isn't free. Come back with $" .. cost .. ".")
        return false
    end

    -- Get eligible tips based on reputation
    local rep = GetReputation(citizenid)
    local eligibleTips = {}

    for _, tip in ipairs(TipLocations) do
        if rep >= tip.minRep then
            table.insert(eligibleTips, tip)
        end
    end

    if #eligibleTips == 0 then
        SendMessage(source, "I have nothing for you right now. Check back later.")
        return false
    end

    -- Select random tip
    local tip = eligibleTips[math.random(#eligibleTips)]

    -- Charge player
    Services.Charge(source, cost, 'mr_x_location_tip')

    -- Send location via lb-phone coordinates
    if GetResourceState('lb-phone') == 'started' then
        exports['lb-phone']:SendCoords(source, tip.coords.x, tip.coords.y)
    end

    -- Send description
    SendMessage(source, tip.description)

    Log(MrXConstants.EventTypes.SERVICE_COMPLETED, citizenid, {
        service = 'location_tip',
        cost = cost,
        coords = {x = tip.coords.x, y = tip.coords.y, z = tip.coords.z}
    }, source)

    return true
end

-- ============================================
-- TARGET INTEL
-- ============================================

---Get intel on another player
---@param source number Requester source
---@param targetIdentifier string Target name, citizenid, or phone number
---@return boolean success
function Services.GetTargetIntel(source, targetIdentifier)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    local canAccess, reason = Services.CanAccess(citizenid, Config.Services.TargetIntel, source)
    if not canAccess then
        SendMessage(source, "I don't share intel with just anyone.")
        return false
    end

    local cost = Config.Services.TargetIntel.cost
    if not Services.CanAfford(source, cost) then
        SendMessage(source, "Information like this costs $" .. cost .. ".")
        return false
    end

    -- Find target player
    local targetSource, targetPlayer
    local players = GetPlayers()

    for _, playerId in ipairs(players) do
        local player = exports.qbx_core:GetPlayer(tonumber(playerId))
        if player then
            local charinfo = player.PlayerData.charinfo
            local fullName = charinfo.firstname .. ' ' .. charinfo.lastname

            if player.PlayerData.citizenid:lower():find(targetIdentifier:lower()) or
               fullName:lower():find(targetIdentifier:lower()) then
                targetSource = tonumber(playerId)
                targetPlayer = player
                break
            end
        end
    end

    if not targetPlayer then
        SendMessage(source, "I can't find anyone matching that description.")
        return false
    end

    -- Charge player
    Services.Charge(source, cost, 'mr_x_target_intel')

    -- Gather intel
    local charinfo = targetPlayer.PlayerData.charinfo
    local job = targetPlayer.PlayerData.job
    local gang = targetPlayer.PlayerData.gang
    local ped = GetPlayerPed(targetSource)
    local coords = GetEntityCoords(ped)

    -- Get area name
    local areaName = 'Unknown'
    if coords then
        local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        areaName = GetStreetNameFromHashKey(streetHash) or 'Unknown'
    end

    -- Build intel report
    local intel = string.format([[
**INTEL REPORT**

Subject: %s %s
Employment: %s (%s)
Affiliation: %s
Last Seen: %s
Status: %s

This information is current as of now.
    ]],
        charinfo.firstname, charinfo.lastname,
        job.label, job.grade.name,
        gang.name ~= 'none' and gang.label or 'Unaffiliated',
        areaName,
        IsPedDeadOrDying(ped) and 'Incapacitated' or 'Active'
    )

    SendEmail(source, 'Intel Report', intel)

    Log(MrXConstants.EventTypes.SERVICE_COMPLETED, citizenid, {
        service = 'target_intel',
        cost = cost,
        target = targetPlayer.PlayerData.citizenid
    }, source)

    return true
end

-- ============================================
-- EMERGENCY LOANS
-- ============================================

---Issue an emergency loan to a player
---@param source number
---@return boolean success
---@return number|nil loanId
function Services.IssueLoan(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    -- Check exemption - no services for exempt players
    local isExempt = exports['sv_mr_x']:IsExempt(source)
    if isExempt then
        if Config.Debug then print('^3[MR_X]^7 Blocked loan for exempt player') end
        return false
    end

    local rep = GetReputation(citizenid)
    if rep < 50 then
        SendMessage(source, "I don't extend credit to strangers.")
        return false
    end

    -- Check for existing active loan
    local existingLoan = MySQL.single.await([[
        SELECT id FROM mr_x_loans WHERE citizenid = ? AND status IN ('active', 'overdue')
    ]], {citizenid})

    if existingLoan then
        SendMessage(source, "You already owe me. Pay that first.")
        return false
    end

    -- Calculate loan amount based on reputation
    local loanConfig = Config.Services.Loans
    local amount = math.floor(loanConfig.MinAmount + (rep / 100) * (loanConfig.MaxAmount - loanConfig.MinAmount))
    local interest = math.floor(amount * loanConfig.InterestRate)

    -- Calculate due date
    local dueAt = os.date('%Y-%m-%d %H:%M:%S', os.time() + (loanConfig.DueHours * 3600))

    -- Insert loan record
    local loanId = MySQL.insert.await([[
        INSERT INTO mr_x_loans (citizenid, amount, interest, due_at, status)
        VALUES (?, ?, ?, ?, 'active')
    ]], {citizenid, amount, interest, dueAt})

    -- Update profile
    MySQL.update.await([[
        UPDATE mr_x_profiles SET active_loan_id = ?, total_loans = total_loans + 1 WHERE citizenid = ?
    ]], {loanId, citizenid})

    -- Give money
    exports.qbx_core:AddMoney(source, 'cash', amount, 'mr_x_loan')

    -- Send confirmation
    local message = string.format(
        "$%d has been deposited. You owe $%d in %d hours. Don't be late.",
        amount, amount + interest, loanConfig.DueHours
    )
    SendMessage(source, message)

    Log(MrXConstants.EventTypes.LOAN_ISSUED, citizenid, {
        loanId = loanId,
        amount = amount,
        interest = interest,
        totalDue = amount + interest
    }, source)

    return true, loanId
end

---Repay an active loan
---@param source number
---@return boolean success
function Services.RepayLoan(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    -- Get active loan
    local loan = MySQL.single.await([[
        SELECT * FROM mr_x_loans WHERE citizenid = ? AND status IN ('active', 'overdue')
    ]], {citizenid})

    if not loan then
        SendMessage(source, "You don't owe me anything... yet.")
        return false
    end

    local totalDue = loan.amount + loan.interest

    -- Check if player can afford
    if not Services.CanAfford(source, totalDue) then
        SendMessage(source, string.format("You owe $%d. Come back when you have it.", totalDue))
        return false
    end

    -- Take payment
    Services.Charge(source, totalDue, 'mr_x_loan_repayment')

    -- Update loan status
    MySQL.update.await([[
        UPDATE mr_x_loans SET status = 'paid', paid_at = NOW() WHERE id = ?
    ]], {loan.id})

    -- Clear active loan from profile
    MySQL.update.await([[
        UPDATE mr_x_profiles SET active_loan_id = NULL WHERE citizenid = ?
    ]], {citizenid})

    -- Add reputation
    exports['sv_mr_x']:HandleLoanRepaid(citizenid, loan.id, source)

    SendMessage(source, "Debt paid. We're even... for now.")

    Log(MrXConstants.EventTypes.LOAN_REPAID, citizenid, {
        loanId = loan.id,
        amount = totalDue
    }, source)

    return true
end

---Check and handle overdue loans
function Services.CheckOverdueLoans()
    -- Get all overdue loans that haven't been defaulted yet
    local overdueLoans = MySQL.query.await([[
        SELECT l.*, p.reputation FROM mr_x_loans l
        JOIN mr_x_profiles p ON l.citizenid = p.citizenid
        WHERE l.status = 'overdue' AND l.collection_attempts < 3
    ]])

    for _, loan in ipairs(overdueLoans or {}) do
        -- Find if player is online
        local playerSource
        local players = GetPlayers()
        for _, playerId in ipairs(players) do
            local player = exports.qbx_core:GetPlayer(tonumber(playerId))
            if player and player.PlayerData.citizenid == loan.citizenid then
                playerSource = tonumber(playerId)
                break
            end
        end

        if playerSource then
            -- Send reminder/threat based on collection attempts
            local messages = {
                "You're late on your payment. Don't make me come looking.",
                "Final warning. Pay what you owe.",
                "Your debt is now... being collected differently."
            }

            SendMessage(playerSource, messages[loan.collection_attempts + 1] or messages[3])

            -- Increment collection attempts
            MySQL.update.await([[
                UPDATE mr_x_loans SET collection_attempts = collection_attempts + 1, reminder_sent = 1
                WHERE id = ?
            ]], {loan.id})

            -- On third attempt, default the loan and trigger HARM
            if loan.collection_attempts >= 2 then
                Services.DefaultLoan(loan.citizenid, loan.id, playerSource)
            end
        end
    end
end

---Default a loan and trigger consequences
---@param citizenid string
---@param loanId number
---@param source? number
function Services.DefaultLoan(citizenid, loanId, source)
    -- Update loan status
    MySQL.update.await([[
        UPDATE mr_x_loans SET status = 'defaulted' WHERE id = ?
    ]], {loanId})

    -- Clear active loan from profile
    MySQL.update.await([[
        UPDATE mr_x_profiles SET active_loan_id = NULL WHERE citizenid = ?
    ]], {citizenid})

    -- Apply reputation penalty
    exports['sv_mr_x']:HandleLoanDefaulted(citizenid, loanId, source)

    -- Trigger HARM consequence (debt collector)
    if source then
        TriggerEvent('sv_mr_x:internal:triggerSurprise', source, citizenid, 'DEBT_COLLECTOR')
    end

    Log(MrXConstants.EventTypes.LOAN_DEFAULTED, citizenid, {loanId = loanId}, source)
end

-- ============================================
-- POLICE DIVERSION
-- ============================================

---Create a fake dispatch to divert police away from player
---@param source number
---@return boolean success
function Services.CreateDiversion(source)
    local citizenid = GetCitizenId(source)
    if not citizenid then return false end

    local canAccess, reason = Services.CanAccess(citizenid, Config.Services.PoliceDiversion, source)
    if not canAccess then
        SendMessage(source, "That kind of favor requires more trust.")
        return false
    end

    local cost = Config.Services.PoliceDiversion.cost
    if not Services.CanAfford(source, cost) then
        SendMessage(source, "Distractions cost money. $" .. cost .. ".")
        return false
    end

    -- Get player coords
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)

    -- Find a distant location (opposite side of map)
    local diversionCoords
    if playerCoords.x > 0 then
        diversionCoords = vec3(-1200.0 + math.random(-200, 200), -800.0 + math.random(-200, 200), 40.0)
    else
        diversionCoords = vec3(1200.0 + math.random(-200, 200), -800.0 + math.random(-200, 200), 40.0)
    end

    -- Charge player
    Services.Charge(source, cost, 'mr_x_police_diversion')

    -- Create fake dispatch via lb-tablet
    if GetResourceState('lb-tablet') == 'started' then
        exports['lb-tablet']:AddDispatch({
            job = 'police',
            priority = 'high',
            code = '10-31',
            title = 'Armed Robbery in Progress',
            description = 'Multiple armed suspects. Shots fired. All available units.',
            location = {
                label = 'Commercial District',
                coords = vector2(diversionCoords.x, diversionCoords.y)
            },
            time = 300  -- 5 minute dispatch
        })
    end

    SendMessage(source, "Police will be... occupied elsewhere. You have a window.")

    Log(MrXConstants.EventTypes.SERVICE_COMPLETED, citizenid, {
        service = 'police_diversion',
        cost = cost,
        diversionCoords = {x = diversionCoords.x, y = diversionCoords.y}
    }, source)

    return true
end

-- ============================================
-- EARLY WARNING SYSTEM
-- ============================================

---Check if player qualifies for early warning (passive service)
---@param citizenid string
---@return boolean qualifies
function Services.QualifiesForEarlyWarning(citizenid)
    -- Check exemption - no services for exempt players
    local isExempt = exports['sv_mr_x']:IsExemptByCitizenId(citizenid)
    if isExempt then return false end

    local rep = GetReputation(citizenid)
    return rep >= Config.Services.EarlyWarning.minRep
end

---Send early warning about threat to player
---@param source number
---@param threatType string Type of threat
---@param details? table Additional details
function Services.SendEarlyWarning(source, threatType, details)
    local citizenid = GetCitizenId(source)
    if not citizenid then return end

    if not Services.QualifiesForEarlyWarning(citizenid) then return end

    local warnings = {
        BOUNTY = "Someone has put a price on your head. Watch your back.",
        WARRANT = "The police have taken an interest in you. Lay low.",
        BOLO = "There's a BOLO out. They're looking for you.",
        GANG_CONTRACT = "A rival crew has been offered money to find you.",
        INVESTIGATION = "Detectives are asking questions about you."
    }

    local message = warnings[threatType] or "Someone is looking for you."

    SendMessage(source, message)

    Log(MrXConstants.EventTypes.SERVICE_COMPLETED, citizenid, {
        service = 'early_warning',
        threatType = threatType,
        details = details
    }, source)
end

-- ============================================
-- LOAN CHECK THREAD
-- ============================================

CreateThread(function()
    while true do
        Wait(300000)  -- Check every 5 minutes

        if not Config.TestMode then
            Services.CheckOverdueLoans()
        end
    end
end)

-- ============================================
-- EVENT HANDLERS
-- ============================================

RegisterNetEvent('sv_mr_x:server:requestLoan', function()
    local source = source
    Services.IssueLoan(source)
end)

RegisterNetEvent('sv_mr_x:server:repayLoan', function()
    local source = source
    Services.RepayLoan(source)
end)

RegisterNetEvent('sv_mr_x:server:requestTip', function()
    local source = source
    Services.GetLocationTip(source)
end)

RegisterNetEvent('sv_mr_x:server:requestIntel', function(targetIdentifier)
    local source = source
    if targetIdentifier and type(targetIdentifier) == 'string' then
        -- Extract name from message like "info on John Doe"
        local name = targetIdentifier:match('info on%s+(.+)') or
                     targetIdentifier:match('intel on%s+(.+)') or
                     targetIdentifier:match('find%s+(.+)') or
                     targetIdentifier
        Services.GetTargetIntel(source, name)
    end
end)

RegisterNetEvent('sv_mr_x:server:requestDiversion', function()
    local source = source
    Services.CreateDiversion(source)
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('CanAccessService', Services.CanAccess)
exports('IssueLoan', Services.IssueLoan)
exports('RepayLoan', Services.RepayLoan)
exports('GetLocationTip', Services.GetLocationTip)
exports('GetTargetIntel', Services.GetTargetIntel)
exports('CreateDiversion', Services.CreateDiversion)
exports('SendEarlyWarning', Services.SendEarlyWarning)
exports('QualifiesForEarlyWarning', Services.QualifiesForEarlyWarning)

-- Return module
return Services
