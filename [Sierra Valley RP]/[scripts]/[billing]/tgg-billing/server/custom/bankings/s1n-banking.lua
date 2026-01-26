if Config.Banking == 's1n-banking' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        if Config.Framework == 'qb' then
            exports["s1n_banking"]:AddMoneyToSociety(senderJob, amount, "Billing")
        elseif Config.Framework == 'esx' then
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. senderJob, function(account)
                account.addMoney(amount)
            end)
        end
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        if Config.Framework == 'qb' then
            return exports["s1n_banking"]:RemoveMoneyFromSociety(jobIdentifier, amount, "Billing")
        elseif Config.Framework == 'esx' then
            local success = false
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobIdentifier, function(account)
                if account and account.money >= amount then
                    account.removeMoney(amount)
                    success = true
                end
            end)
            return success
        end
        return false
    end
end
