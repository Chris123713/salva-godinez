RegisterNUICallback('billing:misc:get-config', function(_, cb)
    cb({
        language = Config.Language,
        dateFormat = Config.DateFormat,
        showFullName = Config.ShowFullName,
        societyFilters = Config.SocietyFilters,
        dateTimeFormat = Config.DateTimeFormat,
        currencyFormat = Config.CurrencyFormat,
        currencySymbol = Config.CurrencySymbol,
        allowOverdraft = Config.AllowOverdraft,
        overdraftLimit = Config.OverdraftLimit,
        highlightNewInvoiceDuration = Config.HighlightNewInvoiceDuration,
        primaryColor = Config.PrimaryColor,
        secondaryColor = Config.SecondaryColor,
        backgroundMain = Config.BackgroundMain,
        backgroundSecondary = Config.BackgroundSecondary,
    })
end)

RegisterNuiCallback('billing:get-available-recipients', function(_, cb)
    local availableRecipients = GetNearbyAvailablePlayers()

    -- Collect companies from nearby players, checking representative grades
    local nearbyCompanies = {}
    for i = 1, #availableRecipients do
        local recipient = availableRecipients[i]
        if recipient.jobName and recipient.jobName ~= 'unemployed' and recipient.jobGrade then
            -- Check if player has representative grade for their company
            local companyConfig = GetCompanyConfig(recipient.jobName)
            local representativeGrades = companyConfig.representativeGrades or {}
            local isRepresentative = false

            for _, grade in pairs(representativeGrades) do
                if grade == -1 or (recipient.jobGrade and grade == recipient.jobGrade) then
                    isRepresentative = true
                    break
                end
            end

            if isRepresentative then
                nearbyCompanies[recipient.jobName] = true
            end
        end
    end

    -- Add companies that can receive invoices and have nearby representatives
    -- Server callback filters out player's current job dynamically
    local availableCompanies = lib.callback.await('billing:server:get-available-companies', false)

    if availableCompanies then
        for i = 1, #availableCompanies do
            -- Only add if company has nearby representatives (excludes player's own job via server)
            if nearbyCompanies[availableCompanies[i].companyId] then
                availableCompanies[i].type = 'company'
                table.insert(availableRecipients, availableCompanies[i])
            end
        end
    end

    cb(availableRecipients)
end)

---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendUIAction(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end
