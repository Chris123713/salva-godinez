if Config.Banking == 'renewed-banking' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        exports['Renewed-Banking']:addAccountMoney(senderJob, amount)
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        return exports['Renewed-Banking']:removeAccountMoney(jobIdentifier, amount)
    end
end
