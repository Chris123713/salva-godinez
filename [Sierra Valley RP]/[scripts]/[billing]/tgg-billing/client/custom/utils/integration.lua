RegisterCommand('billing', function()
    OpenBillingMenu()
end, false)

RegisterKeyMapping('billing', 'Open Billing', 'keyboard', Config.OpenBillingKey)

RegisterCommand('quickcreateinvoice', function()
    if
        BillingDisabled or
        IsDead or
        IsHandcuffed or
        BillingOpen or
        AcceptInvoiceOpen or
        not lib.callback.await('billing:main:get-correct-resource-name') then
        return
    end

    UpdateData()

    -- Get company config (same logic as getBillingConfig in cl_main.lua)
    local companyConfig = Config.Companies[PlayerData.job.name]
    if not companyConfig then
        companyConfig = Config.Companies.other
    end

    local quickCreateData = {
        companyConfig = companyConfig,
        jobInfo = GetJobInfo(),
        playerData = GetPlayerData()
    }

    QuickCreateInvoiceOpen = true
    SendUIAction('billing:open-quick-create-invoice', quickCreateData)

    PlayAnimation()

    -- Set focus after UI is ready (matches the 500ms delay in App.tsx)
    CreateThread(function()
        Wait(600)
        if QuickCreateInvoiceOpen then
            SetNuiFocus(true, true)
        end
    end)
end, false)

RegisterKeyMapping('quickcreateinvoice', 'Quick Create Invoice', 'keyboard', Config.QuickCreateInvoiceKey)
