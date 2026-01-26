-- payments.lua
-- Provides a small helper to credit company/boss funds when an invoice is paid

-- Usage (from another resource):
-- exports['bcs_companymanager']:AddPaidBill(companyName, amount, identifier, reason)
-- or TriggerEvent('bcs_companymanager:PayBillToCompany', companyName, amount, identifier, reason)

local function AddPaidBill(company, amount, identifier, reason)
    if not company or not amount or tonumber(amount) == nil then return false end
    amount = tonumber(amount)
    if amount <= 0 then return false end

    -- Normalize company identifier (many billing resources send lowercase)
    local targetCompany = tostring(company):lower()

    -- Map aliases (e.g. job names) to actual company identifiers
    -- Configure aliases in bcs_companymanager/config/config.lua as:
    -- Config.CompanyAliases = { safr = 'tff', police = 'police', lscso = 'lscso' }
    if Config and Config.CompanyAliases then
        local mapped = Config.CompanyAliases[targetCompany]
        if mapped and type(mapped) == 'string' then
            targetCompany = tostring(mapped):lower()
        end
    end

    -- Validate the company exists in boss menu (prevents crediting wrong department)
    local ok, co = pcall(function()
        return Core.GetCompany(targetCompany)
    end)

    if not ok or not co then
        Utils.DebugWarn(('[bcs_companymanager] AddPaidBill: company not found: %s'):format(tostring(targetCompany)))
        return false
    end

    -- Credit only the validated company account
    -- Credit only the validated company account
    print(('[bcs_companymanager] AddPaidBill: company=%s amount=%s identifier=%s reason=%s'):format(
        tostring(targetCompany), tostring(amount), tostring(identifier or ""), tostring(reason or "")))

    local success, err = pcall(function()
        AddCompanyMoney(targetCompany, 'money', amount, identifier or nil, reason or 'invoice paid', true)
    end)

    if success then
        print(('[bcs_companymanager] AddPaidBill: credited %s %.2f to %s'):format(tostring(identifier or ""), tonumber(amount) or 0, tostring(targetCompany)))
    else
        print(('[bcs_companymanager] Failed to AddPaidBill for %s: %s'):format(tostring(targetCompany), tostring(err)))
    end

    return success
end

exports('AddPaidBill', AddPaidBill)

RegisterNetEvent('bcs_companymanager:PayBillToCompany', function(company, amount, identifier, reason)
    AddPaidBill(company, amount, identifier, reason)
end)

-- Backwards compatibility / convenience: also expose a global function
_G.AddPaidBillToCompany = AddPaidBill
