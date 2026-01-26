--[[
    Mr. X Banking System
    ====================
    Mr. X has a real bank account via tgg-banking.
    His financial state affects his mood and behavior.
]]

local Banking = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function Log(category, action, data)
    if not Config.LogEvents then return end

    local eventType = 'banking:' .. (category or 'unknown') .. ':' .. (action or 'unknown')
    local encodedData = data and json.encode(data) or '{}'

    MySQL.insert.await([[
        INSERT INTO mr_x_events (citizenid, event_type, data, source)
        VALUES (?, ?, ?, ?)
    ]], {'MRX_SYSTEM', eventType, encodedData, 0})
end

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
-- CORE BANKING OPERATIONS
-- ============================================

---Get Mr. X's current balance
---@return number balance
function Banking.GetBalance()
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return 100000 -- Default balance when scarcity disabled
    end

    -- Safety check for MySQL availability
    if not MySQL or not MySQL.single then
        if Config.Debug then print('^3[MR_X:BANK]^7 MySQL not ready yet, returning default balance') end
        return 100000
    end

    local accountId = Config.Scarcity.AccountId
    if not accountId or accountId == '' then
        if Config.Debug then print('^1[MR_X:BANK]^7 AccountId not configured') end
        return 100000
    end

    local success, result = pcall(function()
        return MySQL.single.await([[
            SELECT balance FROM tgg_banking_accounts
            WHERE ownerId = ?
        ]], { accountId })
    end)

    if not success then
        if Config.Debug then print('^1[MR_X:BANK]^7 MySQL query failed: ' .. tostring(result)) end
        return 100000
    end

    return result and tonumber(result.balance) or 0
end

---Deposit to Mr. X's account
---@param amount number
---@param reason string
---@return boolean success
function Banking.Deposit(amount, reason)
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return true -- Always succeed when scarcity disabled
    end

    if not amount or amount <= 0 then
        return false
    end

    local accountId = Config.Scarcity.AccountId
    if not accountId or accountId == '' then
        return false
    end

    reason = reason or 'unknown'

    local affected = MySQL.update.await([[
        UPDATE tgg_banking_accounts
        SET balance = balance + ?
        WHERE ownerId = ? AND frozen = 0 AND closed = 0
    ]], { amount, accountId })

    if affected > 0 then
        local newBalance = Banking.GetBalance()
        Log('banking', 'deposit', { amount = amount, reason = reason, newBalance = newBalance })

        if Config.Debug then
            print(string.format('^2[MR_X:BANK]^7 Deposit: $%s (%s) | Balance: $%s',
                FormatMoney(amount), reason, FormatMoney(newBalance)))
        end

        -- Webhook to dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhook('banking', {
                event = 'deposit',
                amount = amount,
                reason = reason,
                newBalance = newBalance,
                mood = Banking.GetMood()
            })
        end

        return true
    end

    return false
end

---Withdraw from Mr. X's account
---@param amount number
---@param reason string
---@return boolean success
function Banking.Withdraw(amount, reason)
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return true -- Always succeed when scarcity disabled
    end

    if not amount or amount <= 0 then
        return false
    end

    local accountId = Config.Scarcity.AccountId
    if not accountId or accountId == '' then
        return false
    end

    reason = reason or 'unknown'

    local balance = Banking.GetBalance()
    if balance < amount then
        if Config.Debug then
            print(string.format('^1[MR_X:BANK]^7 Withdraw failed: $%s requested, $%s available',
                FormatMoney(amount), FormatMoney(balance)))
        end
        return false
    end

    local affected = MySQL.update.await([[
        UPDATE tgg_banking_accounts
        SET balance = balance - ?
        WHERE ownerId = ? AND frozen = 0 AND closed = 0 AND balance >= ?
    ]], { amount, accountId, amount })

    if affected > 0 then
        local newBalance = Banking.GetBalance()
        Log('banking', 'withdraw', { amount = amount, reason = reason, newBalance = newBalance })

        if Config.Debug then
            print(string.format('^3[MR_X:BANK]^7 Withdraw: $%s (%s) | Balance: $%s',
                FormatMoney(amount), reason, FormatMoney(newBalance)))
        end

        -- Webhook to dashboard
        if Config.WebServer and Config.WebServer.Enabled then
            exports['sv_mr_x']:PostWebhook('banking', {
                event = 'withdraw',
                amount = amount,
                reason = reason,
                newBalance = newBalance,
                mood = Banking.GetMood()
            })
        end

        return true
    end

    return false
end

-- ============================================
-- MOOD SYSTEM
-- ============================================

---Get Mr. X's financial mood based on balance
---@return string mood 'expansive'|'neutral'|'tense'|'desperate'
function Banking.GetMood()
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return 'neutral'
    end

    local balance = Banking.GetBalance()
    local t = Config.Scarcity.Thresholds

    if balance >= t.Expansive then
        return 'expansive'
    elseif balance >= t.Neutral then
        return 'neutral'
    elseif balance >= t.Tense then
        return 'tense'
    else
        return 'desperate'
    end
end

---Get multipliers for current mood
---@return table { rewardBonus: number, extortionChance: number }
function Banking.GetMultipliers()
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return { rewardBonus = 1.0, extortionChance = 0.3 }
    end

    local mood = Banking.GetMood()
    -- Capitalize first letter to match config keys
    local moodKey = mood:sub(1,1):upper() .. mood:sub(2)
    return Config.Scarcity.Multipliers[moodKey] or Config.Scarcity.Multipliers.Neutral
end

---Get full financial summary
---@return table { balance: number, mood: string, multipliers: table }
function Banking.GetSummary()
    return {
        balance = Banking.GetBalance(),
        mood = Banking.GetMood(),
        multipliers = Banking.GetMultipliers(),
        formattedBalance = '$' .. FormatMoney(Banking.GetBalance())
    }
end

-- ============================================
-- INCOME TRACKING
-- ============================================

---Process Mr. X's cut from a completed mission
---@param missionReward number Total mission reward
---@param missionId string
---@return number mrxCut Amount Mr. X received
function Banking.ProcessMissionCut(missionReward, missionId)
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return 0
    end

    local cutPercent = Config.Scarcity.IncomeEvents.MissionCut or 0.15
    local mrxCut = math.floor(missionReward * cutPercent)

    if mrxCut > 0 then
        Banking.Deposit(mrxCut, 'mission_cut:' .. (missionId or 'unknown'))
    end

    return mrxCut
end

---Process service fee income
---@param serviceCost number What the player paid
---@param serviceType string
---@return boolean success
function Banking.ProcessServiceFee(serviceCost, serviceType)
    if not Config.Scarcity or not Config.Scarcity.Enabled then
        return true
    end

    -- Mr. X keeps a portion (not all - he has expenses too)
    local keepPercent = 0.5 -- Keep 50% of service fees
    local income = math.floor(serviceCost * keepPercent)

    if income > 0 then
        return Banking.Deposit(income, 'service_fee:' .. (serviceType or 'unknown'))
    end

    return true
end

-- ============================================
-- ADMIN COMMANDS
-- ============================================

-- Admin command to deposit to Mr. X
RegisterCommand('mrx_deposit', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local amount = tonumber(args[1])
    local reason = args[2] or 'admin_deposit'

    if not amount or amount <= 0 then
        print('^1[MR_X:BANK]^7 Usage: mrx_deposit <amount> [reason]')
        return
    end

    local success = Banking.Deposit(amount, reason)
    if success then
        print(string.format('^2[MR_X:BANK]^7 Deposited $%s. New balance: $%s | Mood: %s',
            FormatMoney(amount), FormatMoney(Banking.GetBalance()), Banking.GetMood():upper()))
    else
        print('^1[MR_X:BANK]^7 Deposit failed')
    end
end, false)

-- Admin command to withdraw from Mr. X
RegisterCommand('mrx_withdraw', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local amount = tonumber(args[1])
    local reason = args[2] or 'admin_withdraw'

    if not amount or amount <= 0 then
        print('^1[MR_X:BANK]^7 Usage: mrx_withdraw <amount> [reason]')
        return
    end

    local success = Banking.Withdraw(amount, reason)
    if success then
        print(string.format('^2[MR_X:BANK]^7 Withdrew $%s. New balance: $%s | Mood: %s',
            FormatMoney(amount), FormatMoney(Banking.GetBalance()), Banking.GetMood():upper()))
    else
        print('^1[MR_X:BANK]^7 Withdraw failed (insufficient funds or account frozen)')
    end
end, false)

-- Admin command to check Mr. X's financial status
RegisterCommand('mrx_balance', function(source)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        return
    end

    local summary = Banking.GetSummary()
    print(string.format([[
^3[MR_X:BANK]^7 Financial Status
  Balance: %s
  Mood: %s
  Reward Bonus: %.1fx
  Extortion Chance: %.0f%%
    ]], summary.formattedBalance, summary.mood:upper(),
        summary.multipliers.rewardBonus,
        summary.multipliers.extortionChance * 100))
end, false)

-- ============================================
-- EXPORTS
-- ============================================

exports('GetMrXBalance', Banking.GetBalance)
exports('DepositToMrX', Banking.Deposit)
exports('WithdrawFromMrX', Banking.Withdraw)
exports('GetMrXMood', Banking.GetMood)
exports('GetMrXMultipliers', Banking.GetMultipliers)
exports('GetMrXFinancialSummary', Banking.GetSummary)
exports('ProcessMissionCut', Banking.ProcessMissionCut)
exports('ProcessServiceFee', Banking.ProcessServiceFee)

return Banking
