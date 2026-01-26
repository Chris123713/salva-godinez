if Config.Banking == 'your_banking' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        exports['your_banking']:AddMoney(senderJob, amount)
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        return exports['your_banking']:RemoveMoney(jobIdentifier, amount)
    end
end
