if Config.Banking == 'fd_banking' then
    function AddCompanyMoney(senderJob, companyAmount, taxdata)
        local amount = taxdata.receiveTax and companyAmount + taxdata.taxAmount or companyAmount

        exports["fd_banking"]:AddMoney(senderJob, amount, "Billing")
    end

    ---@param jobIdentifier string
    ---@param amount number
    ---@return boolean
    function RemoveCompanyMoney(jobIdentifier, amount)
        return exports["fd_banking"]:RemoveMoney(jobIdentifier, amount, "Billing")
    end
end
