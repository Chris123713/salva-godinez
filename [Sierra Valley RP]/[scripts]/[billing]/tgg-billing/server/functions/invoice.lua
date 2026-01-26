--#region Getters
lib.callback.register('billing:server:invoice:all', function(source, page, filters)
    local citizenId = Framework?.GetPlayerFromId(source).identifier

    if not citizenId then return nil end

    local whereClauses = {}
    local queryParams = {
        ['@page'] = (page or 0) * 16,
        ['@perPage'] = 16
    }

    -- Get player's company for company recipient filtering
    local player = Framework?.GetPlayerFromId(source)
    local playerCompany = player?.job?.name or player?.getJob()?.name

    if filters.type == '__personal' then
        if filters.society == 'all' then
            -- All personal that are - send by me as __personal, send to me as __personal, send to me from any society
            -- Include company recipients where player's company matches
            table.insert(whereClauses,
                "((`sender_id` = @senderId AND `sender` = '__personal') OR (`recipient_id` = @recipientId AND `sender` = '__personal') OR (`recipient_id` = @recipientId AND `sender` != '__personal') OR (`recipient_type` = 'company' AND `recipient_company` = @playerCompany AND `sender` = '__personal'))")
            queryParams['@senderId'] = citizenId
            queryParams['@recipientId'] = citizenId
            if playerCompany then
                queryParams['@playerCompany'] = playerCompany
            end
        elseif filters.society == 'received' then
            -- Include player recipient invoices and company recipient invoices where player's company matches
            if playerCompany then
                table.insert(whereClauses, "(`recipient_id` = @recipientId OR (`recipient_type` = 'company' AND `recipient_company` = @playerCompany))")
                queryParams['@playerCompany'] = playerCompany
            else
                table.insert(whereClauses, "`recipient_id` = @recipientId")
            end
            queryParams['@recipientId'] = citizenId
        elseif filters.society == 'byMe' then
            table.insert(whereClauses, "`sender_id` = @senderId")
            queryParams['@senderId'] = citizenId

            table.insert(whereClauses, "`sender` = @sender")
            queryParams['@sender'] = '__personal'
        else
            table.insert(whereClauses, "`sender_id` = @sender")
            queryParams['@sender'] = filters.society

            table.insert(whereClauses, "(`recipient_id` = @recipientId OR (`recipient_type` = 'company' AND `recipient_company` = @playerCompany))")
            queryParams['@recipientId'] = citizenId
            if playerCompany then
                queryParams['@playerCompany'] = playerCompany
            end
        end
    else
        if filters.society == 'byMe' then
            -- Include invoices where sender is company (sender_id IS NULL AND sender = @society) OR sender is player in that company
            table.insert(whereClauses, "(`sender_id` = @sender AND `sender` = @society) OR (`sender_id` IS NULL AND `sender` = @society)")
            queryParams['@sender'] = citizenId
        elseif filters.society == 'all' then
            -- Include invoices sent by the company OR sent TO the company
            -- No additional filter needed beyond sender constraint
        end

        table.insert(whereClauses, "(`sender` = @society OR (`recipient_type` = 'company' AND `recipient_company` = @society))")
        queryParams['@society'] = filters.type
    end

    if filters.status ~= 'all' then
        -- If the status is 'unpaid' we should filter for 'not_accepted' and 'unpaid' statuses
        if filters.status == 'unpaid' then
            table.insert(whereClauses, "(`status` = 'not_accepted' OR `status` = 'unpaid')")
        elseif filters.status == 'cancelled' then
            -- If the status is 'cancelled' we should filter for 'cancelled' and 'rejected' statuses
            table.insert(whereClauses, "(`status` = 'cancelled' OR `status` = 'rejected')")
        else
            table.insert(whereClauses, "`status` = @status")
            queryParams['@status'] = filters.status
        end
    end

    if filters.dateRange.dateFrom ~= '' and filters.dateRange.dateTo ~= '' then
        -- Using >= and < comparison instead of BETWEEN for proper date range handling
        table.insert(whereClauses, "`timestamp` >= @startDate AND `timestamp` < DATE_ADD(@endDate, INTERVAL 1 DAY)")
        queryParams['@startDate'] = filters.dateRange.dateFrom
        queryParams['@endDate'] = filters.dateRange.dateTo
    end

    local orderByClause = ""

    if filters.orderBy == 'newest' then
        orderByClause = "ORDER BY `timestamp` DESC"
    elseif filters.orderBy == 'oldest' then
        orderByClause = "ORDER BY `timestamp` ASC"
    elseif filters.orderBy == 'amountAsc' then
        orderByClause = "ORDER BY `total` ASC"
    elseif filters.orderBy == 'amountDesc' then
        orderByClause = "ORDER BY `total` DESC"
    end

    local whereClause = table.concat(whereClauses, " AND ")

    -- * Test generated queries for debugging
    -- debugPrint(queryParams)
    -- debugPrint(whereClause)
    -- debugPrint(orderByClause)

    local countResult = MySQL.single.await([[
        SELECT COUNT(*) as total
        FROM `tgg_billing_invoices`
        WHERE ]] .. whereClause .. " " .. orderByClause .. [[
    ]], queryParams)

    local totalInvoices = countResult?.total

    if totalInvoices == 0 then
        return {
            totalInvoices = 0,
            invoices = {}
        }
    end

    local query = [[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE ]] .. whereClause .. " " .. orderByClause .. [[
        LIMIT @page, @perPage
    ]]

    -- Fetch filtered results with pagination
    local invoiceResult = MySQL.query.await(query, queryParams)

    for i = 1, #invoiceResult do
        invoiceResult[i].items = json.decode(invoiceResult[i].items)
    end

    return {
        totalInvoices = totalInvoices,
        invoices = invoiceResult
    }
end)

lib.callback.register('billing:invoice:get-by-uuid', function(_, uuid)
    local invoice = MySQL.single.await([[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE `uuid` = @uuid
    ]], {
        ['@uuid'] = uuid
    })

    if invoice == nil then return nil end

    invoice.items = json.decode(invoice.items)

    return invoice
end)

lib.callback.register('billing:server:invoice:search-by-uuid', function(_, uuidQuery, playerIdentifier)
    local additionalFilter = ""
    if Config.GlobalSearchAllowed == false then
        additionalFilter = string.format(" AND (sender_id = '%s' OR recipient_id = '%s')", playerIdentifier,
            playerIdentifier)
    end

    local invoice = MySQL.single.await([[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE `uuid` LIKE CONCAT(@uuid, '%%')]] .. additionalFilter .. [[
        ORDER BY LENGTH(uuid), uuid
        LIMIT 1
    ]], {
        ['@uuid'] = uuidQuery
    })

    if invoice == nil then return nil end

    invoice.items = json.decode(invoice.items)

    return invoice
end)
--#endregion

--#region Create, Cancel, Pay, Accept, Reject

---@param source number
---@param invoiceData table
---@return table|nil
function CreateInvoice(source, invoiceData)
    -- Validate required fields
    if not invoiceData.total or type(invoiceData.total) ~= 'number' or invoiceData.total <= 0 then
        debugPrint('CreateInvoice: Invalid total amount')
        return nil
    end

    if not invoiceData.items or type(invoiceData.items) ~= 'table' or #invoiceData.items == 0 then
        debugPrint('CreateInvoice: Invalid items')
        return nil
    end

    if not invoiceData.taxPercentage or type(invoiceData.taxPercentage) ~= 'number' or invoiceData.taxPercentage < 0 then
        debugPrint('CreateInvoice: Invalid tax percentage')
        return nil
    end

    -- Validate sender
    if invoiceData.sender == '__personal' then
        if not invoiceData.senderId or invoiceData.senderId == '' then
            debugPrint('CreateInvoice: senderId required when sender is __personal')
            return nil
        end
    else
        -- Validate sender company exists
        local senderCompanyConfig = GetCompanyConfig(invoiceData.sender)
        if not senderCompanyConfig or senderCompanyConfig.jobIdentifier == 'other' and invoiceData.sender ~= 'other' then
            debugPrint('CreateInvoice: Invalid sender company: ' .. tostring(invoiceData.sender))
            return nil
        end
        -- senderId can be nil for company senders, but sender_company_name should be provided if senderId is nil
        if not invoiceData.senderId and not invoiceData.senderCompanyName then
            invoiceData.senderCompanyName = senderCompanyConfig.name
        end
    end

    -- Validate recipient type
    local recipientType = invoiceData.recipientType or 'player'
    if recipientType ~= 'player' and recipientType ~= 'company' then
        debugPrint('CreateInvoice: Invalid recipientType: ' .. tostring(recipientType))
        recipientType = 'player'
    end

    -- Validate recipient based on type
    if recipientType == 'company' then
        if not invoiceData.recipientCompany or invoiceData.recipientCompany == '' then
            debugPrint('CreateInvoice: recipientCompany required when recipientType is company')
            return nil
        end

        -- Prevent creating invoice to your own company
        if invoiceData.sender ~= '__personal' and invoiceData.sender == invoiceData.recipientCompany then
            debugPrint('CreateInvoice: Cannot create invoice to your own company')
            return nil
        end

        -- Prevent company invoice features for 'other' category
        if invoiceData.recipientCompany == 'other' then
            debugPrint('CreateInvoice: Company invoice features are disabled for "other" category')
            return nil
        end

        -- Validate company can receive invoices
        if not IsCompanyReceivable(invoiceData.recipientCompany) then
            debugPrint('CreateInvoice: Company cannot receive invoices: ' .. invoiceData.recipientCompany)
            return nil
        end

        -- Validate sender has permission to create company invoices
        if invoiceData.sender ~= '__personal' then
            -- Prevent company-to-company invoices from 'other' category
            if invoiceData.sender == 'other' then
                debugPrint('CreateInvoice: Company invoice features are disabled for "other" category')
                return nil
            end

            local senderCompanyConfig = GetCompanyConfig(invoiceData.sender)
            local senderGrade = nil
            if source then
                local sender = Framework.GetPlayerFromId(source)
                if sender then
                    senderGrade = sender.job?.grade or sender.getJob()?.grade
                end
            end

            local createCompanyInvoice = senderCompanyConfig.createCompanyInvoice or {}
            local canCreate = false
            for _, grade in pairs(createCompanyInvoice) do
                if grade == -1 or (senderGrade and grade == senderGrade) then
                    canCreate = true
                    break
                end
            end

            if not canCreate then
                debugPrint('CreateInvoice: Player grade does not allow creating company invoices')
                return nil
            end
        end

        local recipientCompanyConfig = GetCompanyConfig(invoiceData.recipientCompany)
        invoiceData.recipientId = nil
        invoiceData.recipientName = recipientCompanyConfig.name
        invoiceData.recipient_company = invoiceData.recipientCompany
    else
        -- Validate player recipient
        if not invoiceData.recipientId or invoiceData.recipientId == '' then
            debugPrint('CreateInvoice: recipientId required when recipientType is player')
            return nil
        end
        invoiceData.recipient_company = nil
    end

    invoiceData.uuid = GenerateSequentalUUID()

    local senderCompanyConfig = GetCompanyConfig(invoiceData.sender)
    local isCompanyToCompany = invoiceData.sender ~= '__personal' and recipientType == 'company'

    -- Check if skipAcceptance flag is set to bypass acceptance requirement
    -- Company-to-company and player-to-company invoices always require acceptance unless skipAcceptance is explicitly set
    if invoiceData.skipAcceptance then
        invoiceData.status = 'unpaid'
    elseif isCompanyToCompany or recipientType == 'company' then
        -- Company-to-company and player-to-company invoices always require acceptance
        invoiceData.status = 'not_accepted'
    elseif senderCompanyConfig?.acceptFirst or (Config.PersonalAcceptFirst and invoiceData.sender == '__personal') then
        invoiceData.status = 'not_accepted'
    else
        invoiceData.status = 'unpaid'
    end

    local invoiceId = MySQL.insert.await([[
        INSERT INTO `tgg_billing_invoices` (
            `uuid`,
            `items`,
            `total`,
            `notes`,
            `sender`,
            `status`,
            `sender_id`,
            `sender_name`,
            `recipient_id`,
            `recipient_name`,
            `recipient_type`,
            `recipient_company`,
            `tax_percentage`,
            `sender_company_name`
        )
        VALUES (
            @uuid,
            @items,
            @total,
            @notes,
            @sender,
            @status,
            @sender_id,
            @sender_name,
            @recipient_id,
            @recipient_name,
            @recipient_type,
            @recipient_company,
            @tax_percentage,
            @sender_company_name
        )
    ]], {
        ['@uuid'] = invoiceData.uuid,
        ['@total'] = invoiceData.total,
        ['@notes'] = invoiceData.notes,
        ['@status'] = invoiceData.status,
        ['@sender'] = invoiceData.sender,
        ['@sender_id'] = invoiceData.senderId,
        ['@sender_name'] = invoiceData.senderName,
        ['@recipient_id'] = invoiceData.recipientId,
        ['@items'] = json.encode(invoiceData.items),
        ['@recipient_name'] = invoiceData.recipientName,
        ['@recipient_type'] = recipientType,
        ['@recipient_company'] = invoiceData.recipient_company,
        ['@tax_percentage'] = invoiceData.taxPercentage,
        ['@sender_company_name'] = invoiceData.senderCompanyName,
    })

    if not invoiceId then return nil end

    local invoice = GetInvoiceById(invoiceId)

    -- Trigger acceptance request for player recipients only
    -- Company recipients see invoices in their list and can accept/reject from there
    if invoiceData.status == 'not_accepted' and not invoiceData.skipAcceptance and recipientType == 'player' then
        if senderCompanyConfig?.acceptFirst or (Config.PersonalAcceptFirst and invoiceData.sender == '__personal') then
            local recipientSource = Framework.GetPlayerFromIdentifier(invoiceData.recipientId)?.source

            if recipientSource then
                TriggerClientEvent('billing:client:ask-invoice-acceptance',
                    recipientSource, invoice)
            end
        end
    end

    TriggerEvent('billing:server:on-invoice-created', invoice)

    return invoice
end

lib.callback.register('billing:server:invoice:create', CreateInvoice)

---@param source number
---@param invoiceId number
---@return boolean
function CancelInvoice(source, invoiceId)
    if not invoiceId then return false end

    local invoice = GetInvoiceById(invoiceId)
    if not invoice then return false end

    local player = Framework.GetPlayerFromId(source)
    if not player then return false end

    local identifier = player.identifier
    local playerJob = player.job?.name or player.getJob()?.name
    local playerGrade = player.job?.grade or player.getJob()?.grade

    -- Check if player can cancel this invoice
    local canCancel = false

    -- Personal sender can always cancel their own invoices
    if invoice.sender == '__personal' and invoice.senderId == identifier then
        canCancel = true
    elseif invoice.sender ~= '__personal' then
        -- Company sender invoices
        local senderCompanyConfig = GetCompanyConfig(invoice.sender)
        local cancelGrades = senderCompanyConfig.cancel or {}

        if #cancelGrades > 0 and invoice.sender == playerJob then
            for _, grade in pairs(cancelGrades) do
                local gradeNum = tonumber(grade)
                local playerGradeNum = tonumber(playerGrade)
                if gradeNum == -1 or (playerGradeNum and gradeNum == playerGradeNum) then
                    canCancel = true
                    break
                end
            end
        end
    end

    -- For company recipient invoices, allow cancel if player is member of recipient company and has cancel grade
    local recipientType = invoice.recipientType or (invoice.recipientCompany and 'company' or 'player')
    if recipientType == 'company' and invoice.recipientCompany then
        local recipientCompanyConfig = GetCompanyConfig(invoice.recipientCompany)
        local cancelGrades = recipientCompanyConfig.cancel or {}

        if invoice.recipientCompany == playerJob and #cancelGrades > 0 then
            for _, grade in pairs(cancelGrades) do
                local gradeNum = tonumber(grade)
                local playerGradeNum = tonumber(playerGrade)
                if gradeNum == -1 or (playerGradeNum and gradeNum == playerGradeNum) then
                    canCancel = true
                    break
                end
            end
        end
    end

    if not canCancel then
        debugPrint('CancelInvoice: Player does not have permission to cancel this invoice')
        return false
    end

    local cancelled = MySQL.update.await([[
        UPDATE `tgg_billing_invoices`
        SET `status` = 'cancelled'
        WHERE `id` = @id
    ]], {
        ['@id'] = invoiceId
    })

    if cancelled > 0 then
        TriggerEvent('billing:server:on-invoice-cancelled', invoice)
    end

    return cancelled > 0
end

lib.callback.register('billing:server:invoice:cancel', CancelInvoice)

---@param source number
---@param invoiceId number
---@return boolean, number?
function PayInvoice(source, invoiceId)
    local _playerSource = source
    local citizenId = Framework?.GetPlayerFromId(_playerSource)?.identifier
    if not citizenId then return false end

    local invoice = GetInvoiceById(invoiceId)
    if not invoice then
        debugPrint('Payment Failed: Invoice not found.')
        return false
    end

    -- Check if recipient is a company
    local recipientType = invoice.recipientType or (invoice.recipientCompany and 'company' or 'player')
    local isCompanyRecipient = recipientType == 'company' or invoice.recipientCompany ~= nil

    if isCompanyRecipient then
        local payer = Framework.GetPlayerFromId(_playerSource)
        if not payer then
            debugPrint('Payment Failed: Payer not found.')
            return false
        end

        local payerJob = payer.job?.name or payer.getJob()?.name
        local recipientCompany = invoice.recipientCompany or invoice.recipient_company

        if payerJob ~= recipientCompany then
            debugPrint('Payment Failed: Player is not a member of the recipient company.')
            return false
        end

        -- Check grade-based payment permission
        local recipientCompanyConfig = GetCompanyConfig(recipientCompany)
        local canPayCompanyInvoice = recipientCompanyConfig.canPayCompanyInvoice or {}
        local payerGrade = payer.job?.grade or payer.getJob()?.grade

        if #canPayCompanyInvoice > 0 then
            -- Grade-based restriction is configured
            local hasPermission = false
            for _, grade in pairs(canPayCompanyInvoice) do
                local gradeNum = tonumber(grade)
                local payerGradeNum = tonumber(payerGrade)
                if gradeNum == -1 or (payerGradeNum and gradeNum == payerGradeNum) then
                    hasPermission = true
                    break
                end
            end

            if not hasPermission then
                debugPrint('Payment Failed: Player grade does not allow paying company invoices.')
                return false
            end
        else
            -- If canPayCompanyInvoice is empty, allow anyone (default behavior)
            -- No additional checks needed
        end
    else
        -- Player recipient - existing validation
        if invoice.recipientId ~= citizenId and not Config.GlobalSearchAllowed then
            debugPrint('Payment Failed: Player is not the recipient of the invoice.')
            return false
        end
    end

    local success, amountPaid = Pay(source, invoice)

    if success then
        if not isCompanyRecipient and citizenId ~= invoice.recipientId then
            local recipientSource = Framework.GetPlayerFromIdentifier(invoice.recipientId)?.source
            if recipientSource then
                TriggerClientEvent('billing:client:on-external-invoice-paid', recipientSource, invoice)
            end
        end

        TriggerEvent('billing:server:on-invoice-paid', invoice)
    end

    return success, amountPaid
end

lib.callback.register('billing:server:invoice:pay', PayInvoice)

---- Paying Function ----
---@param source number | nil
---@param invoice table
---@return boolean, number?
function Pay(source, invoice)
    if not invoice then return false end

    local tax = invoice.total * (invoice.taxPercentage / 100)
    local sender = nil
    local senderJob = nil
    local senderGrade = nil
    local isSenderOffline = false
    local enforcementAgent = false

    if not source then enforcementAgent = true end -- We are going to use the enforcment agent!

    -- Handle nullable senderId
    if invoice.senderId then
        sender = Framework.GetPlayerFromIdentifier(invoice.senderId)
        if not sender then
            sender = GetOfflinePlayer(invoice.senderId)
            isSenderOffline = true
        end
    end

    if invoice.sender ~= '__personal' then
        if sender then
            senderJob = sender.job?.name or sender.getJob()?.name
            senderGrade = sender.job?.grade or sender.getJob()?.grade
        else
            -- Company sender without senderId - use sender field as job identifier
            senderJob = invoice.sender
        end
    end

    local totalPayment = invoice.total + tax
    local recipientType = invoice.recipientType or (invoice.recipientCompany and 'company' or 'player')
    local isCompanyRecipient = recipientType == 'company' or invoice.recipientCompany ~= nil

    -- Get payer identifier for transaction tracking
    -- This is the player who is paying the invoice (not the invoice sender)
    local payerIdentifier = nil
    if not enforcementAgent and source then
        local payer = Framework.GetPlayerFromId(source)
        if payer then
            payerIdentifier = payer.identifier
            debugPrint('Pay: Payer identifier for transaction: ' .. payerIdentifier)
        end
    end

    -- Handle payment from company or player recipient
    if not enforcementAgent then
        if isCompanyRecipient then
            -- Company recipient - remove money from company account
            local recipientCompany = invoice.recipientCompany or invoice.recipient_company
            if not recipientCompany then
                debugPrint('Pay: Company recipient but no recipientCompany specified')
                return false, 0
            end

            -- Check if RemoveCompanyMoney function exists
            if not RemoveCompanyMoney then
                debugPrint('Pay: RemoveCompanyMoney function not available for banking system')
                return false, 0
            end

            -- Check company account balance (framework-specific)
            -- Try to get company account balance
            local hasEnoughFunds = true
            if Config.Banking == 'tgg-banking' then
                local companyAccount = exports['tgg-banking']:GetSocietyAccount(recipientCompany)
                if not companyAccount then
                    debugPrint('Pay: Company account not found: ' .. recipientCompany)
                    return false, 0
                end
                local balance = tonumber(companyAccount.balance) or 0
                if balance < totalPayment then
                    hasEnoughFunds = false
                end
            end

            if not hasEnoughFunds and not Config.AllowOverdraft then
                debugPrint('Pay: Company has insufficient funds: ' .. recipientCompany)
                return false, 0
            end

            local success = RemoveCompanyMoney(recipientCompany, totalPayment)
            if not success then
                debugPrint('Pay: Failed to remove money from company account: ' .. recipientCompany)
                return false, 0
            end
        else
            -- Player recipient - existing logic
            local targetPlayer = Framework.GetPlayerFromId(source)

            if targetPlayer then
                -- Ensure payerIdentifier is set for Player→Player transactions
                if not payerIdentifier then
                    payerIdentifier = targetPlayer.identifier
                end

                local targetPlayerMoney = targetPlayer.getAccount('bank')?.money
                if targetPlayerMoney >= totalPayment then
                    -- Remove money(bank) from recipient.
                    RemoveRecipientMoney(source, totalPayment)
                else
                    return false, 0
                end
            end
        end
    else
        -- Enforcement agent - handle both player and company recipients
        local recipientIdentifier = invoice.recipientId or invoice.recipientCompany or invoice.recipient_company

        if isCompanyRecipient and not invoice.recipientCompany and not invoice.recipient_company then
            debugPrint('Pay: Enforcement agent cannot pay company recipient invoice - no company identifier')
            return false, 0
        end

        local success = EnforcementAgentRemoveRecipientMoney(
            recipientIdentifier,
            totalPayment,
            isCompanyRecipient,
            invoice.recipientCompany or invoice.recipient_company
        )
        if not success then return false, 0 end
    end

    local workerAmount = 0
    local companyAmount = 0

    local isPersonal = invoice.sender == '__personal'
    if isPersonal and not isSenderOffline then
        AddWorkerMoney(invoice.senderId, invoice.total)
    elseif isPersonal and isSenderOffline then
        AddOfflineWorkerMoney(invoice.senderId, invoice.total)
    else
        local data = {
            jobFound = false,
            receiveTax = false
        }

        for _, company in pairs(Config.Companies) do
            if company.jobIdentifier == senderJob then
                data = { jobFound = true, receiveTax = company.companyReceiveTax and not Config.Government.CollectTax }
                break
            end
        end

        if not data.jobFound then senderJob = 'other' end

        debugPrint("Sender Job is: " .. senderJob)

        if Config.Companies[senderJob].comission ~= {} then
            local comissionPercentage = 0

            for _, comission in pairs(Config.Companies[senderJob].comission) do
                if comission.grade == senderGrade then
                    comissionPercentage = comission.percentage / 100
                    debugPrint("Comission Percentage is: " .. comissionPercentage)
                    break
                end
            end

            if comissionPercentage > 0 then
                workerAmount = invoice.total * comissionPercentage
                companyAmount = invoice.total - workerAmount
            else
                companyAmount = invoice.total
            end

            debugPrint("Worker will receive: " .. workerAmount)
            debugPrint("Company will receive: " .. companyAmount)
        elseif Config.Companies[senderJob].comission == {} then
            companyAmount = invoice.total
        end

        if companyAmount > 0 then
            local taxdata = {
                receiveTax = data.receiveTax,
                taxAmount = tax
            }

            AddCompanyMoney(senderJob, companyAmount, taxdata)
        end

        if workerAmount > 0 then
            if not isSenderOffline then
                AddWorkerMoney(invoice.senderId, workerAmount)
            else
                AddOfflineWorkerMoney(invoice.senderId, workerAmount)
            end
        end
    end

    if Config.Government.CollectTax and Config.Government.Account then
        AddCompanyMoney(Config.Government.Account, 0, { receiveTax = true, taxAmount = tax })
    end

    local updated = MySQL.update.await([[
        UPDATE `tgg_billing_invoices`
        SET `status` = 'paid'
        WHERE `id` = @id
    ]], {
        ['@id'] = invoice.id
    }) > 0

    if updated and Config.Banking == 'tgg-banking' and LogInvoiceTransactions then
        -- Determine invoice type
        local invoiceType = nil
        if isPersonal and not isCompanyRecipient then
            invoiceType = 'p2p' -- Player to Player
        elseif not isPersonal and not isCompanyRecipient then
            invoiceType = 'c2p' -- Company to Player
        elseif not isPersonal and isCompanyRecipient then
            invoiceType = 'c2c' -- Company to Company
        elseif isPersonal and isCompanyRecipient then
            invoiceType = 'p2c' -- Player to Company
        end

        if invoiceType and not enforcementAgent then
            LogInvoiceTransactions(invoiceType, invoice, payerIdentifier, senderJob, workerAmount, companyAmount, totalPayment)
        end
    end

    return updated, totalPayment
end

---@param source number
---@param invoiceId number
function AcceptInvoice(source, invoiceId)
    debugPrint('Accepting invoice: ' .. invoiceId)
    if not invoiceId then return false end

    local invoice = GetInvoiceById(invoiceId)
    if not invoice then return false end

    -- Check grade restrictions for company recipient invoices
    local recipientType = invoice.recipientType or (invoice.recipientCompany and 'company' or 'player')
    if recipientType == 'company' and invoice.recipientCompany then
        local recipientCompanyConfig = GetCompanyConfig(invoice.recipientCompany)
        local accepter = Framework?.GetPlayerFromId(source)
        if accepter then
            local accepterJob = accepter.job?.name or accepter.getJob()?.name
            local accepterGrade = accepter.job?.grade or accepter.getJob()?.grade

            -- Verify accepter is member of recipient company
            if accepterJob ~= invoice.recipientCompany then
                debugPrint('AcceptInvoice: Player is not a member of the recipient company')
                return false
            end

            -- Check grade permission
            local acceptCompanyInvoice = recipientCompanyConfig.acceptCompanyInvoice or {}
            local canAccept = false
            for _, grade in pairs(acceptCompanyInvoice) do
                if grade == -1 or (accepterGrade and grade == accepterGrade) then
                    canAccept = true
                    break
                end
            end

            if not canAccept then
                debugPrint('AcceptInvoice: Player grade does not allow accepting company invoices')
                return false
            end
        end
    end

    local accepted = MySQL.update.await([[
        UPDATE `tgg_billing_invoices`
        SET `status` = 'unpaid'
        WHERE `id` = @id
    ]], {
        ['@id'] = invoiceId
    })

    if accepted > 0 then
        if not invoice then invoice = GetInvoiceById(invoiceId) end
        TriggerEvent('billing:server:on-invoice-accepted', invoice)
    end

    return accepted
end

lib.callback.register('billing:server:invoice:accept', AcceptInvoice)

---@param source number
---@param invoiceId number
function RejectInvoice(source, invoiceId)
    if not invoiceId then return false end

    local invoice = GetInvoiceById(invoiceId)
    if not invoice then return false end

    -- Check grade restrictions for company recipient invoices
    local recipientType = invoice.recipientType or (invoice.recipientCompany and 'company' or 'player')
    if recipientType == 'company' and invoice.recipientCompany then
        local recipientCompanyConfig = GetCompanyConfig(invoice.recipientCompany)
        local rejecter = Framework?.GetPlayerFromId(source)
        if rejecter then
            local rejecterJob = rejecter.job?.name or rejecter.getJob()?.name
            local rejecterGrade = rejecter.job?.grade or rejecter.getJob()?.grade

            -- Verify rejecter is member of recipient company
            if rejecterJob ~= invoice.recipientCompany then
                debugPrint('RejectInvoice: Player is not a member of the recipient company')
                return false
            end

            -- Check grade permission
            local rejectCompanyInvoice = recipientCompanyConfig.rejectCompanyInvoice or {}
            local canReject = false
            for _, grade in pairs(rejectCompanyInvoice) do
                if grade == -1 or (rejecterGrade and grade == rejecterGrade) then
                    canReject = true
                    break
                end
            end

            if not canReject then
                debugPrint('RejectInvoice: Player grade does not allow rejecting company invoices')
                return false
            end
        end
    end

    local rejected = MySQL.update.await([[
        UPDATE `tgg_billing_invoices`
        SET `status` = 'rejected'
        WHERE `id` = @id
    ]], {
        ['@id'] = invoiceId
    })


    if rejected > 0 then
        if not invoice then invoice = GetInvoiceById(invoiceId) end
        TriggerEvent('billing:server:on-invoice-rejected', invoice)
    end

    return rejected
end

lib.callback.register('billing:server:invoice:reject', RejectInvoice)

---@param id number
---@return table|nil
function GetInvoiceById(id)
    local invoice = MySQL.single.await([[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE `id` = @id
    ]], {
        ['@id'] = id
    })

    if invoice == nil then return nil end

    invoice.items = json.decode(invoice.items)

    return invoice
end

lib.callback.register('billing:server:invoice:get', function(_, id)
    return GetInvoiceById(id)
end)

lib.callback.register('billing:invoice:server:get-total-payment-amount', function(_, recipientId)
    local invoiceResult = MySQL.query.await([[
        SELECT
            total,
            sender,
            recipient_type as recipientType,
            recipient_company as recipientCompany
        FROM `tgg_billing_invoices`
        WHERE (`recipient_id` = @recipientId OR (`recipient_type` = 'company' AND `recipient_company` = @recipientId)) AND `status` = 'unpaid'
    ]], {
        ['@recipientId'] = recipientId
    })

    local totalPayment = 0

    if not invoiceResult then return totalPayment end

    for i = 1, #invoiceResult do
        local companyConfig = GetCompanyConfig(invoiceResult[i].sender)

        local taxPercentage = companyConfig.taxPercentage / 100

        local tax = invoiceResult[i].total * taxPercentage

        totalPayment += invoiceResult[i].total + tax
    end

    return totalPayment
end)

lib.callback.register('billing:invoice:server:pay-all', function(_, playerIdentifier, totalPayment)
    local playerMoney = Framework.GetPlayerFromIdentifier(playerIdentifier)?.getAccount('bank')?.money

    if not playerMoney then return false end

    if tonumber(playerMoney) < tonumber(totalPayment) then return false end

    local invoices = MySQL.query.await([[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE (`recipient_id` = @recipientId OR (`recipient_type` = 'company' AND `recipient_company` = @recipientId)) AND `status` = 'unpaid'
    ]], {
        ['@recipientId'] = playerIdentifier
    })

    if not invoices then return false end

    local playerSource = Framework.GetPlayerFromIdentifier(playerIdentifier)?.source
    if not playerSource then return false end

    for i = 1, #invoices do
        local errors, success = pcall(Pay, playerSource, invoices[i])

        if errors then
            debugPrint('Error paying invoice: ' .. invoices[i].id .. ' Error:')
            debugPrint(errors)
        end

        if success then TriggerEvent('billing:server:on-invoice-paid', invoices[i]) end
    end

    return true
end)
--#endregion

--#region Statistics
local intervals = {
    today = "INTERVAL 1 DAY",
    last_week = "INTERVAL 1 WEEK",
    month = "INTERVAL 1 MONTH",
    year = "INTERVAL 1 YEAR"
}

lib.callback.register('billing:invoice:server:count', function(_, period, status, sender, senderId)
    -- status: all, paid, unpaid, cancelled, rejected, not_accepted
    -- sender: society, '__personal'

    local interval = intervals[period]
    if not interval then
        -- Handle error: Invalid period specified
        debugPrint("Invalid period specified: " .. tostring(period))
        return 0 -- Early return to prevent SQL execution with invalid data
    end

    local whereClauses = {}

    -- Add sender constraints
    if sender == '__personal' and senderId then
        table.insert(whereClauses, string.format("`sender` = '__personal' AND `sender_id` = '%s'", senderId))
    else
        -- Include both company invoices (sender_id IS NULL) and player invoices (sender_id = senderId)
        table.insert(whereClauses, string.format("`sender` = '%s'", sender))
    end

    -- Add status constraints
    if status ~= 'all' then
        if status == 'unpaid' then
            table.insert(whereClauses, "(`status` = 'not_accepted' OR `status` = 'unpaid')")
        elseif status == 'cancelled' then
            table.insert(whereClauses, "(`status` = 'cancelled' OR `status` = 'rejected')")
        else
            table.insert(whereClauses, string.format("`status` = '%s'", status))
        end
    end

    -- Add time period constraint
    table.insert(whereClauses, string.format("`timestamp` >= DATE_SUB(NOW(), %s)", interval))

    local statusCondition = table.concat(whereClauses, " AND ")

    local query = string.format([[
        SELECT COUNT(*) as total
        FROM `tgg_billing_invoices`
        WHERE %s
    ]], statusCondition)

    local countResult = MySQL.query.await(query, {})

    return countResult[1]?.total or 0
end)

lib.callback.register('billing:invoice:server:income', function(_, period, sender, senderId)
    local interval = intervals[period]

    if not interval then
        -- Handle error: Invalid period specified
        debugPrint("Invalid period specified: " .. tostring(period))
    end

    local senderConstraint = ""
    if sender == '__personal' and senderId then
        senderConstraint = string.format("AND `sender` = '__personal' AND `sender_id` = '%s'", senderId)
    elseif sender then
        -- Include both company invoices (sender_id IS NULL) and player invoices
        senderConstraint = string.format("AND `sender` = '%s'", sender)
    end

    local query = string.format([[
        SELECT SUM(`total` * (1 + `tax_percentage` / 100)) AS total
        FROM `tgg_billing_invoices`
        WHERE `status` = 'paid' AND `timestamp` >= DATE_SUB(NOW(), %s) %s
    ]], interval, senderConstraint)

    local income = MySQL.query.await(query)

    return income[1]?.total or 0
end)

lib.callback.register('billing:invoice:server:expected-income', function(_, period, sender, senderId)
    local interval = intervals[period]
    if not interval then
        -- Handle error: Invalid period specified
        debugPrint("Invalid period specified: " .. tostring(period))
    end

    local senderConstraint = ""
    if sender == '__personal' and senderId then
        senderConstraint = string.format("AND `sender` = '__personal' AND `sender_id` = '%s'", senderId)
    elseif sender then
        -- Include both company invoices (sender_id IS NULL) and player invoices
        senderConstraint = string.format("AND `sender` = '%s'", sender)
    end

    local query = string.format([[
        SELECT SUM(`total` * (1 + `tax_percentage` / 100)) AS total
        FROM `tgg_billing_invoices`
        WHERE `status` = 'unpaid' AND `timestamp` >= DATE_SUB(NOW(), %s) %s
    ]], interval, senderConstraint)

    local income = MySQL.query.await(query)

    return income[1]?.total or 0
end)

lib.callback.register('billing:invoice:server:last-15-daily-income', function(_, sender, senderId)
    -- Generate dates for the last 15 days in the desired format
    local today = os.time()
    local dates = {}
    for i = 0, 14 do
        local date = os.date('*t', today - (i * 86400)) -- Generate date table
        local formattedDate = string.format('%s %02d, %02d', os.date('%b', today - (i * 86400)), date.day,
            date.year % 100)
        dates[formattedDate] = 0 -- Initialize all dates with 0 total
    end

    local senderConstraint = ""
    if sender == '__personal' and senderId then
        senderConstraint = string.format("AND `sender` = '__personal' AND `sender_id` = '%s'", senderId)
    else
        senderConstraint = string.format("AND `sender` = '%s'", sender)
    end

    local query = string.format([[
        SELECT
            DATE_FORMAT(`last_modified`, '%%b %%d, %%y') as date,
            SUM(`total` * (1 + `tax_percentage` / 100)) AS total
        FROM `tgg_billing_invoices`
        WHERE `status` = 'paid' AND `last_modified` >= DATE_SUB(NOW(), INTERVAL 15 DAY) %s
        GROUP BY DATE(`last_modified`)
        ORDER BY DATE(`last_modified`) DESC
    ]], senderConstraint)

    local sales = MySQL.query.await(query)
    -- Update the map with actual sales data
    for _, sale in ipairs(sales) do
        dates[sale.date] = sale.total
    end

    -- Convert map to array
    local completeSales = {}
    for date, total in pairs(dates) do
        -- Format total to two decimal places
        local formattedTotal = string.format("%.2f", total)
        table.insert(completeSales, { date = date, total = tonumber(formattedTotal) })
    end

    -- Sort by date
    table.sort(completeSales, function(a, b) return a.date > b.date end)

    return completeSales
end)

lib.callback.register('billing:invoice:server:recent-payments', function(_, sender, senderId)
    local senderConstraint = ""
    if sender == '__personal' and senderId then
        senderConstraint = string.format("AND `sender` = '__personal' AND `sender_id` = '%s'", senderId)
    else
        senderConstraint = string.format("AND `sender` = '%s'", sender)
    end

    local query = string.format([[
        SELECT
            id,
            uuid,
            items,
            total,
            notes,
            status,
            sender,
            timestamp,
            sender_id as senderId,
            sender_name as senderName,
            recipient_id as recipientId,
            last_modified as lastModified,
            recipient_name as recipientName,
            recipient_type as recipientType,
            recipient_company as recipientCompany,
            tax_percentage as taxPercentage,
            sender_company_name as senderCompanyName
        FROM `tgg_billing_invoices`
        WHERE `status` = 'paid' %s
        ORDER BY `last_modified` DESC
        LIMIT %d
    ]], senderConstraint, Config.RecentPayments or 25)

    local recentPayments = MySQL.query.await(query)

    for i = 1, #recentPayments do
        recentPayments[i].items = json.decode(recentPayments[i].items)
    end

    return recentPayments
end)

--#endregion
