if Config.Banking == 'okokBanking' then
    local function AddESXSocietyMoney(senderJob, amount)
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. senderJob, function(account)
            account.addMoney(amount)
        end)
    end

    local function RemoveESXSocietyMoney(jobIdentifier, amount)
        local success = false
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. jobIdentifier, function(account)
            if account and account.money >= amount then
                account.removeMoney(amount)
                success = true
            end
        end)
        return success
    end

    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount
        if Config.Framework == 'qb' then
            exports['okokBanking']:AddMoney(senderJob, amount)
        elseif Config.Framework == 'esx' then
            AddESXSocietyMoney(senderJob, amount)
        end
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        if Config.Framework == 'qb' then
            return exports['okokBanking']:RemoveMoney(jobIdentifier, amount)
        elseif Config.Framework == 'esx' then
            return RemoveESXSocietyMoney(jobIdentifier, amount)
        end
        return false
    end
end
