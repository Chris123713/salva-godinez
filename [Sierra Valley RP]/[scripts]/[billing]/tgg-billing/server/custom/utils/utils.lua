RegisterNetEvent('billing:server:on-invoice-created', function(invoice)
    debugPrint('Invoice Created: billing:server:on-invoice-created')

    local recipientSource = Framework.GetPlayerFromIdentifier(invoice.recipientId)?.source
    if (recipientSource) then
        -- Will update the invoices for the recipient if the UI is open.
        -- Otherwise, it will send a notification to the recipient based on the `Config.AlertsMode`.
        TriggerClientEvent('billing:client:on-invoice-created', recipientSource, invoice)
    end

    Logs.InvoiceCreated(invoice)
end)

RegisterNetEvent('billing:server:on-invoice-paid', function(invoice)
    debugPrint('Invoice Paid: billing:server:on-invoice-paid')

    local senderSource = Framework.GetPlayerFromIdentifier(invoice.senderId)?.source
    if senderSource then
        TriggerClientEvent('billing:client:on-invoice-paid', senderSource, invoice)
    end

    Logs.PayInvoice(invoice)
end)

RegisterNetEvent('billing:server:on-invoice-cancelled', function(data)
    debugPrint('Invoice Cancelled: billing:server:on-invoice-cancelled')

    local recipientSource = Framework.GetPlayerFromIdentifier(data.recipientId)?.source
    if recipientSource then
        TriggerClientEvent('billing:client:on-invoice-cancelled', recipientSource, data.id)
    end

    Logs.CancelInvoice(data)
end)

RegisterNetEvent('billing:server:on-invoice-accepted', function(data)
    debugPrint('Invoice Accepted: billing:server:on-invoice-accepted')

    local recipientSource = Framework.GetPlayerFromIdentifier(data.senderId)?.source
    if recipientSource then
        TriggerClientEvent('billing:client:on-invoice-accepted', recipientSource, data.id)
    end

    Logs.InvoiceAccepted(data)
end)

RegisterNetEvent('billing:server:on-invoice-rejected', function(data)
    debugPrint('Invoice Rejected: billing:server:on-invoice-rejected')

    local recipientSource = Framework.GetPlayerFromIdentifier(data.senderId)?.source
    if recipientSource then
        TriggerClientEvent('billing:client:on-invoice-rejected', recipientSource, data.id)
    end

    Logs.InvoiceRejected(data)
end)

lib.callback.register('billing:server:get-player-data', function(_, playerId)
    local player = Framework.GetPlayerFromId(playerId)
    local jobName = nil
    local jobGrade = nil

    if not player then
        local playerIdentifier = Framework.GetPlayerFromId(playerId)?.identifier
        player = GetOfflinePlayer(playerIdentifier)
        if not player then return false end
    end

    local playerIdentifier = player.identifier
    jobName = player.job?.name or player.getJob()?.name
    jobGrade = player.job?.grade or player.getJob()?.grade

    return {
        id = playerId,
        citizenId = playerIdentifier,
        name = player.getName(),
        jobName = jobName,
        jobGrade = jobGrade,
    }
end)
