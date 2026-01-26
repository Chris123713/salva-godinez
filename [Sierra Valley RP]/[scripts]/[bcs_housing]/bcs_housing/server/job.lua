for job, _ in pairs(JobConfig.jobs) do
    TriggerEvent('esx_society:registerSociety', job, 'Real Estate', 'society_' .. job,
        'society_' .. job, 'society_' .. job, { type = 'public' })
end


---When furniture is sold if you want to use the money to go to some job
---@param data {price: number, model: number, label: string}
function FurnitureSold(data)
end

function GetCompanyMoney(job)
    if IsResourceStarted('esx_addonaccount') then
        local p = promise.new()
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. job, function(account)
            p:resolve(account.money)
        end)
        return Citizen.Await(p)
    elseif IsResourceStarted('okokBanking') then
        return exports['okokBanking']:GetAccount(job)
    elseif IsResourceStarted('qb-banking') and Config.QBBanking then
        return exports['qb-banking']:GetAccountBalance(job)
    elseif IsResourceStarted('qb-management') or IsResourceStarted('Renewed-Banking') then
        return exports['qb-management']:GetAccount(job)
    elseif IsResourceStarted('bcs_companymanager') then
       return exports.bcs_companymanager:GetCompanyMoney(job, 'money')
    end
end

function AddCompanyMoney(job, amount)
    if IsResourceStarted('esx_addonaccount') then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. job, function(account)
            account.addMoney(amount)
        end)
    elseif IsResourceStarted('okokBanking') then
        exports['okokBanking']:AddMoney(job, amount)
    elseif IsResourceStarted('qb-banking') and Config.QBBanking then
        exports['qb-banking']:AddMoney(job, amount)
    elseif IsResourceStarted('qb-management') or IsResourceStarted('Renewed-Banking') then
        exports['qb-management']:AddMoney(job, amount)
    elseif IsResourceStarted('bcs_companymanager') then
        exports.bcs_companymanager:AddCompanyMoney(job, 'money', amount)
    end
end

function RemoveCompanyMoney(job, amount)
    if IsResourceStarted('esx_addonaccount') then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. job, function(account)
            account.removeMoney(amount)
        end)
    elseif IsResourceStarted('okokBanking') then
        exports['okokBanking']:RemoveMoney(job, amount)
    elseif IsResourceStarted('qb-banking') and Config.QBBanking then
        exports['qb-banking']:RemoveMoney(job, amount)
    elseif IsResourceStarted('qb-management') or IsResourceStarted('Renewed-Banking') then
        exports['qb-management']:RemoveMoney(job, amount)
    elseif IsResourceStarted('bcs_companymanager') then
        exports.bcs_companymanager:RemoveCompanyMoney(job, 'money', amount)
    end
end
