-- Economy Tools (qbx_core integration)

local Economy = {}

-- Award money to player
function Economy.AwardMoney(source, moneyType, amount, reason)
    local player = Utils.GetPlayer(source)
    if not player then
        return {success = false, error = 'Player not found'}
    end

    moneyType = moneyType or Config.Economy.DefaultMoneyType
    reason = reason or 'Mission reward'

    local success = exports.qbx_core:AddMoney(source, moneyType, amount, reason)

    if success then
        Utils.Debug('Awarded $' .. amount .. ' ' .. moneyType .. ' to', source, 'for:', reason)

        -- Send phone notification if enabled
        if Config.Economy.NotifyOnTransaction then
            exports['sv_nexus_tools']:SendPhoneNotification(source, {
                title = 'Payment Received',
                message = ('$%s deposited to %s'):format(amount, moneyType),
                icon = 'fas fa-money-bill'
            })
        end

        local newBalance = player.PlayerData.money[moneyType] or 0
        return {success = true, newBalance = newBalance + amount}
    end

    return {success = false, error = 'Failed to add money'}
end

-- Deduct money from player
function Economy.DeductMoney(source, moneyType, amount, reason)
    local player = Utils.GetPlayer(source)
    if not player then
        return {success = false, error = 'Player not found'}
    end

    moneyType = moneyType or Config.Economy.DefaultMoneyType
    reason = reason or 'Purchase'

    local currentBalance = player.PlayerData.money[moneyType] or 0
    if currentBalance < amount then
        return {success = false, error = 'Insufficient funds'}
    end

    local success = exports.qbx_core:RemoveMoney(source, moneyType, amount, reason)

    if success then
        Utils.Debug('Deducted $' .. amount .. ' ' .. moneyType .. ' from', source, 'for:', reason)
        return {success = true}
    end

    return {success = false, error = 'Failed to remove money'}
end

-- Check money balance
function Economy.CheckMoney(source, moneyType)
    local player = Utils.GetPlayer(source)
    if not player then
        return {balance = 0}
    end

    moneyType = moneyType or Config.Economy.DefaultMoneyType
    local balance = player.PlayerData.money[moneyType] or 0

    return {balance = balance}
end

-- Register economy tools
RegisterTool('award_money', {
    params = {'source', 'moneyType', 'amount', 'reason'},
    handler = function(params)
        return Economy.AwardMoney(
            params.source,
            params.moneyType,
            params.amount,
            params.reason
        )
    end
})

RegisterTool('deduct_money', {
    params = {'source', 'moneyType', 'amount', 'reason'},
    handler = function(params)
        return Economy.DeductMoney(
            params.source,
            params.moneyType,
            params.amount,
            params.reason
        )
    end
})

RegisterTool('check_money', {
    params = {'source', 'moneyType'},
    handler = function(params)
        return Economy.CheckMoney(params.source, params.moneyType)
    end
})

-- Mission completion rewards helper
function Economy.CompleteMissionRewards(source, missionId, rewards)
    local results = {}

    -- Money rewards
    if rewards.money then
        results.money = Economy.AwardMoney(
            source,
            rewards.money.type or 'cash',
            rewards.money.amount,
            'Mission: ' .. missionId
        )
    end

    -- Send completion mail
    pcall(function()
        exports['sv_nexus_tools']:SendPhoneMail(source, {
            subject = 'Job Complete',
            message = ('Mission "%s" completed. Check your account.'):format(missionId),
            sender = Config.Phone.MissionSender
        })
    end)

    return results
end

-- Exports
exports('AwardMoney', Economy.AwardMoney)
exports('DeductMoney', Economy.DeductMoney)
exports('CheckMoney', Economy.CheckMoney)
exports('CompleteMissionRewards', Economy.CompleteMissionRewards)

return Economy
