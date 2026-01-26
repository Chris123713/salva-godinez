if Config.Banking == 'tgg-banking' then
    ---@param senderJob string
    ---@param companyAmount number
    ---@param taxdata { receiveTax: boolean, taxAmount: number }
    ---@return boolean
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        return exports['tgg-banking']:AddSocietyMoney(senderJob, amount)
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        return exports['tgg-banking']:RemoveSocietyMoney(jobIdentifier, amount)
    end

    ---@param invoiceType string
    ---@param invoice table
    ---@param payerIdentifier string|nil - The player identifier who is paying (for p2p, p2c, c2p scenarios)
    ---@param senderJob string|nil - The company job identifier (for c2p, c2c scenarios)
    ---@param workerAmount number|nil - Commission amount (for c2p scenarios)
    ---@param companyAmount number|nil - Company amount (for c2p scenarios)
    ---@param totalPayment number|nil - Total payment amount including tax
    ---@return boolean
    function LogInvoiceTransactions(invoiceType, invoice, payerIdentifier, senderJob, workerAmount, companyAmount, totalPayment)
        local description = 'Invoice Payment Id: #' .. invoice.id .. (invoice.notes and invoice.notes ~= '' and ' - ' .. invoice.notes or '')

        if invoiceType == 'p2p' then
            -- Player to Player: Receiver (payer) → Sender (invoice creator)
            -- Receiver sees: Outgoing transaction
            -- Sender sees: Incoming transaction
            local receiverAccount = exports['tgg-banking']:GetPersonalAccountByPlayerIdentifier(payerIdentifier)
            local senderAccount = exports['tgg-banking']:GetPersonalAccountByPlayerIdentifier(invoice.senderId)

            if not receiverAccount or not senderAccount then
                debugPrint('LogInvoiceTransactions: Account not found for P2P transaction')
                return false
            end

            -- Transaction 1: Receiver (payer) sees outgoing transaction
            exports['tgg-banking']:AddTransaction(
                nil,
                receiverAccount.iban,
                'invoice_payment_p2p',
                totalPayment,
                description .. ' - Player to Player Payment',
                payerIdentifier,
                nil,
                'Invoice Payment: #' .. invoice.id
            )

            -- Transaction 2: Sender (invoice creator) sees incoming transaction
            exports['tgg-banking']:AddTransaction(
                senderAccount.iban,
                nil,
                'invoice_payment_p2p',
                totalPayment,
                description .. ' - Player to Player Payment',
                invoice.senderId,
                nil,
                'Invoice Payment: #' .. invoice.id
            )
        elseif invoiceType == 'c2p' then
            -- Company to Player: Player Recipient pays → Company receives, then Company → Worker (if commission)
            local payerAccount = exports['tgg-banking']:GetPersonalAccountByPlayerIdentifier(payerIdentifier)
            local companyAccount = exports['tgg-banking']:GetSocietyAccount(senderJob)

            if not payerAccount or not companyAccount then
                debugPrint('LogInvoiceTransactions: Account not found for C2P transaction')
                return false
            end

            -- Transaction 1: Player pays → Company receives
            exports['tgg-banking']:AddTransaction(
                companyAccount.iban,
                payerAccount.iban,
                'invoice_payment_c2p',
                totalPayment,
                description .. ' - Company to Player Payment',
                payerIdentifier,
                nil,
                'Invoice Payment: #' .. invoice.id
            )

            -- Transaction 2: Company → Worker (commission, if applicable)
            if workerAmount and workerAmount > 0 then
                local workerAccount = exports['tgg-banking']:GetPersonalAccountByPlayerIdentifier(invoice.senderId)
                if workerAccount then
                    exports['tgg-banking']:AddTransaction(
                        workerAccount.iban,
                        companyAccount.iban,
                        'invoice_payment_commission',
                        workerAmount,
                        description .. ' - Worker Commission Payment',
                        invoice.senderId,
                        nil,
                        'Invoice Payment: #' .. invoice.id
                    )
                end
            end
        elseif invoiceType == 'c2c' then
            -- Company to Company: Sender Company → Recipient Company
            local senderCompanyAccount = exports['tgg-banking']:GetSocietyAccount(senderJob)
            local recipientCompany = invoice.recipientCompany or invoice.recipient_company
            local recipientCompanyAccount = exports['tgg-banking']:GetSocietyAccount(recipientCompany)

            if not senderCompanyAccount or not recipientCompanyAccount then
                debugPrint('LogInvoiceTransactions: Account not found for C2C transaction')
                return false
            end

            exports['tgg-banking']:AddTransaction(
                recipientCompanyAccount.iban,
                senderCompanyAccount.iban,
                'invoice_payment_c2c',
                totalPayment,
                description .. ' - Company to Company Payment',
                nil,
                nil,
                'Invoice Payment: #' .. invoice.id
            )
        elseif invoiceType == 'p2c' then
            -- Player to Company: Company withdrawal + Sender deposit
            local companyAccount = exports['tgg-banking']:GetSocietyAccount(invoice.recipientCompany or invoice.recipient_company)
            local senderAccount = exports['tgg-banking']:GetPersonalAccountByPlayerIdentifier(invoice.senderId)

            if not companyAccount or not senderAccount then
                debugPrint('LogInvoiceTransactions: Account not found for P2C transaction')
                return false
            end

            -- Transaction 1: Company withdrawal (outgoing)
            exports['tgg-banking']:AddTransaction(
                nil,
                companyAccount.iban,
                'invoice_payment_p2c',
                totalPayment,
                description .. ' - Player to Company Payment',
                nil,
                nil,
                'Invoice Payment: #' .. invoice.id
            )

            -- Transaction 2: Sender deposit (incoming)
            exports['tgg-banking']:AddTransaction(
                senderAccount.iban,
                nil,
                'invoice_payment_p2c',
                invoice.total,
                description .. ' - Player to Company Payment',
                invoice.senderId,
                nil,
                'Invoice Payment: #' .. invoice.id
            )
        end

        return true
    end
end
