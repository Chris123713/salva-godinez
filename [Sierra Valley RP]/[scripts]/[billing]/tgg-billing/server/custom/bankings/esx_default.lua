if Config.Framework == 'esx' and Config.Banking == 'esx_addonaccount' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. senderJob, function(account)
            account.addMoney(amount)
        end)
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        local success = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobIdentifier, function(account)
            if account and account.money >= amount then
                account.removeMoney(amount)
                success = true
            end
        end)
        return success
    end
end
