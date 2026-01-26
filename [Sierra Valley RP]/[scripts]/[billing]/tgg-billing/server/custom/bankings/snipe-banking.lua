if Config.Banking == 'snipe-banking' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        exports["snipe-banking"]:AddMoneyToAccount(senderJob, amount)
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        return exports["snipe-banking"]:RemoveMoneyFromAccount(jobIdentifier, amount)
    end
end
