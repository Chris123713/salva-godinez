Account = {}
Account.__index = Account
Account.__newindex = function(self, name, fn) rawset(self, name, fn) end

-- Constants
local SOCIETY_INTEGRATIONS = {
    ESX_ADDONACCOUNT = 'esx_addonaccount',
    QB_BANKING = 'qb-banking',
    QB_MANAGEMENT = 'qb-management',
    FD_BANKING = 'fd_banking',
    RENEWED_BANKING = 'Renewed-Banking',
    CRM_BANKING = 'crm-banking',
    TGG_BANKING = 'tgg-banking',
    OKOK_BANKING = 'okokBanking',
    LGMODS_BANKING = 'LGMods_Banking'
}

local ACCOUNT_TYPES = {
    MONEY = 'money',
    BLACK_MONEY = 'black_money'
}

local TRANSACTION_ACTIONS = {
    DEPOSIT = 'deposit',
    WITHDRAW = 'withdraw',
    PAY_BILL = 'pay_bill',
    PAID_OFF = 'paid_off'
}

-- Constructor - Account
---@param name string
---@param isGang? boolean
function Account:New(name, isGang)
    return setmetatable({
        company = name,
        isGang = isGang,
        money = 0,
        blackMoney = 0,
        earning = 0
    }, Account):Initialize()
end

-- Initialization
function Account:Initialize()
    self:InitializeMoney()
    return self
end

function Account:InitializeMoney()
    local tableName = self:GetTableName()
    local integration = self:GetSocietyIntegration()

    if integration then
        self:InitializeWithSocietyIntegration(integration, tableName)
    else
        self:InitializeWithDatabase(tableName)
    end
end

-- Helper Methods
function Account:GetTableName()
    return Config.Database.Company
end

function Account:GetSocietyIntegration()
    local integration = Config.SocietyIntegration.ScriptName
    local resourceName = Config.SocietyIntegration.ResourceName or integration
    if integration == '' or not integration then return end
    if not Utils.IsResourceStarted(resourceName) then
        Utils.DebugWarn(('[%s] is not started'):format(resourceName))
        return nil
    end
    return integration
end

-- Society Integration Handlers
function Account:InitializeWithSocietyIntegration(integration, tableName)
    local handlers = {
        [SOCIETY_INTEGRATIONS.ESX_ADDONACCOUNT] = self.InitializeESX,
        [SOCIETY_INTEGRATIONS.QB_BANKING] = self.InitializeQB,
        [SOCIETY_INTEGRATIONS.QB_MANAGEMENT] = self.InitializeQBManagement,
        [SOCIETY_INTEGRATIONS.FD_BANKING] = self.InitializeFDBanking,
        [SOCIETY_INTEGRATIONS.RENEWED_BANKING] = self.InitializeRenewedBanking,
        [SOCIETY_INTEGRATIONS.CRM_BANKING] = self.InitializeCRMBanking,
        [SOCIETY_INTEGRATIONS.TGG_BANKING] = self.InitializeTGG,
        [SOCIETY_INTEGRATIONS.OKOK_BANKING] = self.InitializeOKOK,
        [SOCIETY_INTEGRATIONS.LGMODS_BANKING] = self.InitializeLGModsBanking
    }

    local handler = handlers[integration]
    if handler then
        handler(self)
    else
        self:InitializeWithDatabase(tableName)
    end
end

function Account:InitializeESX()
    local p = promise.new()
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. self.company, function(account)
        self.money = account and account.money or 0
        p:resolve()
    end)
    Citizen.Await(p)
end

function Account:InitializeQB()
    local success, account = pcall(function()
        return exports[Config.SocietyIntegration.ResourceName]:GetAccount(self.company)
    end)
    if success then
        self.money = account.account_balance
    end
end

function Account:InitializeLGModsBanking()
    exports['LGMods_Banking']:GetAccountDetails(self.company, "business", nil, function(data)
        if data.success then
            self.money = data.account.balance
        else
            print("Error: " .. data.error)
        end
    end)
end

function Account:InitializeQBManagement()
    local success, money = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        return self.isGang and export:GetGangAccount(export, self.company) or export:GetAccount(export, self.company)
    end)
    if success and money then
        self.money = money
    end
end

function Account:InitializeFDBanking()
    self:InitializeQBManagement() -- Same logic as QB Management
end

function Account:InitializeRenewedBanking()
    local success, money = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        return export:getAccountMoney(self.company)
    end)
    if success then
        self.money = money
    end
end

function Account:InitializeCRMBanking()
    local success, money = pcall(function()
        return exports[Config.SocietyIntegration.ResourceName]:crm_get_money(self.company)
    end)
    if success then
        self.money = money
    end
end

function Account:InitializeTGG()
    local success, money = pcall(function()
        return exports[Config.SocietyIntegration.ResourceName]:GetSocietyAccountMoney(self.company)
    end)
    if success then
        self.money = money
    end
end

function Account:InitializeOKOK()
    local success, money = pcall(function()
        return exports[Config.SocietyIntegration.ResourceName]:GetAccount(self.company)
    end)
    if success then
        self.money = money
    end
end

function Account:InitializeWithDatabase(tableName)
    self:EnsureDatabaseAccount()
    local query = 'SELECT %s, earning FROM %s WHERE %s = ?'
    local result = MySQL.single.await(query:format(
        Config.Database.CompanyColumns.Amount,
        tableName,
        Config.Database.CompanyColumns.Job
    ), { self.company })

    if result then
        self.money = result[Config.Database.CompanyColumns.Amount] or 0
        self.earning = result.earning or 0
    end

    if Config.Framework ~= 'QB' then
        self:InitializeBlackMoney(tableName)
    end
end

function Account:InitializeBlackMoney(tableName)
    local result = MySQL.single.await(
        'SELECT black_money, earning FROM ' .. tableName .. ' WHERE ' .. Config.Database.CompanyColumns.Job .. ' = ?',
        { self.company }
    )
    if result then
        self.earning = result.earning
        self.blackMoney = result.black_money
    end
end

-- Money Operations
function Account:GetMoney(accountType)
    return accountType == ACCOUNT_TYPES.BLACK_MONEY and self.blackMoney or self.money
end

function Account:AddEarning(amount)
    local tableName = self:GetTableName()
    self.earning = self.earning + tonumber(amount)
    self:EnsureDatabaseAccount()
    MySQL.prepare.await(
        'UPDATE ' .. tableName .. ' SET earning = ? WHERE ' .. Config.Database.CompanyColumns.Job .. ' = ?',
        { self.earning, self.company }
    )
end

function Account:AddMoney(accountType, amount, identifier, reason, isPaying)
    if amount <= 0 then return end

    local integration = self:GetSocietyIntegration()
    local tableName = self:GetTableName()

    if accountType == ACCOUNT_TYPES.MONEY and integration then
        self:HandleSocietyMoneyAdd(integration, amount, reason)
    else
        self:HandleDatabaseMoneyAdd(accountType, amount, tableName)
    end

    if identifier then
        self:InsertTransaction(amount, accountType,
            isPaying and TRANSACTION_ACTIONS.PAID_OFF or TRANSACTION_ACTIONS.DEPOSIT,
            reason, identifier)
    end
end

function Account:RemoveMoney(accountType, amount, identifier, reason, isPaying)
    if amount <= 0 then return end

    local integration = self:GetSocietyIntegration()
    local tableName = self:GetTableName()

    if accountType == ACCOUNT_TYPES.MONEY and integration then
        self:HandleSocietyMoneyRemove(integration, amount)
    else
        self:HandleDatabaseMoneyRemove(accountType, amount, tableName)
    end

    if identifier then
        self:InsertTransaction(amount, accountType, isPaying and TRANSACTION_ACTIONS.PAY_BILL or TRANSACTION_ACTIONS
            .WITHDRAW, reason, identifier)
    end
end

-- Database Operations
function Account:EnsureDatabaseAccount()
    local tableName = self:GetTableName()
    if Config.Framework == 'QB' then
        self:EnsureQBAccount()
    else
        local exists = MySQL.scalar.await(
            'SELECT 1 FROM ' .. tableName .. ' WHERE ' .. Config.Database.CompanyColumns.Job .. ' = ?',
            { self.company }
        )
        if not exists then
            MySQL.insert.await(
                ('INSERT INTO %s (%s, %s, earning) VALUES (?, 0, 0)'):format(
                    tableName,
                    Config.Database.CompanyColumns.Job,
                    Config.Database.CompanyColumns.Amount
                ),
                { self.company }
            )
        end
    end
end

function Account:EnsureQBAccount()
    local query = 'SELECT 1 FROM %s WHERE %s = ?'
    local exists = MySQL.scalar.await(query:format(
        Config.Database.Company,
        Config.Database.CompanyColumns.Job
    ), { self.company })
    
    if not exists then
        local integration = self:GetSocietyIntegration()
        if integration == SOCIETY_INTEGRATIONS.QB_BANKING or integration == SOCIETY_INTEGRATIONS.QB_MANAGEMENT then
            local export = exports[Config.SocietyIntegration.ResourceName]
            local method = self.isGang and 'CreateGangAccount' or 'CreateJobAccount'
            pcall(function() export[method](export, self.company, 0) end)
        else
            -- No integration, create the account directly in database
            local accountType = self.isGang and 'gang' or 'boss'
            local insertQuery = string.format(
                'INSERT INTO %s (%s, %s, %s, earning) VALUES (?, 0, ?, 0)',
                Config.Database.Company,
                Config.Database.CompanyColumns.Job,
                Config.Database.CompanyColumns.Amount,
                Config.Database.CompanyColumns.Type
            )
            MySQL.insert.await(insertQuery, { self.company, accountType })
        end
    end
end

function Account:InsertTransaction(amount, accountType, action, reason, identifier)
    MySQL.insert(
        'INSERT INTO transaction_history (amount, account, action, reason, company, identifier) VALUES (?, ?, ?, ?, ?, ?)',
        { amount, accountType, action, reason or locale("unknown"), self.company, identifier }
    )
end

-- Money Operation Handlers
function Account:HandleSocietyMoneyAdd(integration, amount, reason)
    local handlers = {
        [SOCIETY_INTEGRATIONS.ESX_ADDONACCOUNT] = self.HandleESXMoneyAdd,
        [SOCIETY_INTEGRATIONS.QB_BANKING] = self.HandleQBMoneyAdd,
        [SOCIETY_INTEGRATIONS.QB_MANAGEMENT] = self.HandleQBManagementMoneyAdd,
        [SOCIETY_INTEGRATIONS.FD_BANKING] = self.HandleFDBankingMoneyAdd,
        [SOCIETY_INTEGRATIONS.RENEWED_BANKING] = self.HandleRenewedBankingMoneyAdd,
        [SOCIETY_INTEGRATIONS.CRM_BANKING] = self.HandleCRMBankingMoneyAdd,
        [SOCIETY_INTEGRATIONS.TGG_BANKING] = self.HandleTGGMoneyAdd,
        [SOCIETY_INTEGRATIONS.OKOK_BANKING] = self.HandleOKOKMoneyAdd,
        [SOCIETY_INTEGRATIONS.LGMODS_BANKING] = self.HandleLGModsBankingMoneyAdd
    }

    local handler = handlers[integration]
    if handler then handler(self, amount, reason) end
end

function Account:HandleSocietyMoneyRemove(integration, amount)
    local handlers = {
        [SOCIETY_INTEGRATIONS.ESX_ADDONACCOUNT] = self.HandleESXMoneyRemove,
        [SOCIETY_INTEGRATIONS.QB_BANKING] = self.HandleQBMoneyRemove,
        [SOCIETY_INTEGRATIONS.QB_MANAGEMENT] = self.HandleQBManagementMoneyRemove,
        [SOCIETY_INTEGRATIONS.FD_BANKING] = self.HandleFDBankingMoneyRemove,
        [SOCIETY_INTEGRATIONS.RENEWED_BANKING] = self.HandleRenewedBankingMoneyRemove,
        [SOCIETY_INTEGRATIONS.CRM_BANKING] = self.HandleCRMBankingMoneyRemove,
        [SOCIETY_INTEGRATIONS.TGG_BANKING] = self.HandleTGGMoneyRemove,
        [SOCIETY_INTEGRATIONS.OKOK_BANKING] = self.HandleOKOKMoneyRemove,
        [SOCIETY_INTEGRATIONS.LGMODS_BANKING] = self.HandleLGModsBankingMoneyRemove
    }

    local handler = handlers[integration]
    if handler then handler(self, amount) end
end

-- Add Money Handlers
function Account:HandleESXMoneyAdd(amount)
    local p = promise.new()
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. self.company, function(account)
        self.money = self.money + amount
        account.addMoney(amount)
        p:resolve()
    end)
    Citizen.Await(p)
end

function Account:HandleQBMoneyAdd(amount, reason)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:AddMoney(self.company, amount, reason)
    end)
    if success then self.money = self.money + amount end
end

function Account:HandleQBManagementMoneyAdd(amount, reason)
    local success = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        local method = self.isGang and 'AddGangMoney' or 'AddMoney'
        export[method](export, self.company, amount, reason)
    end)
    if success then self.money = self.money + amount end
end

function Account:HandleFDBankingMoneyAdd(amount, reason)
    self:HandleQBManagementMoneyAdd(amount, reason)
end

function Account:HandleLGModsBankingMoneyAdd(amount, reason)
    exports[Config.SocietyIntegration.ResourceName]:AddMoney(nil, amount, "business", self.company)
end

function Account:HandleCRMBankingMoneyAdd(amount, reason)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:crm_add_money(self.company, amount)
    end)
    if success then self.money = self.money + amount end
end

function Account:HandleRenewedBankingMoneyAdd(amount, reason)
    local success = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        export:addAccountMoney(self.company, amount, reason)
    end)
    if success then self.money = self.money + amount end
end

function Account:HandleTGGMoneyAdd(amount, reason)
    print(('[bcs_companymanager] TGG AddSocietyMoney called: company=%s amount=%s reason=%s'):format(
        tostring(self.company), tostring(amount), tostring(reason or "")))
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:AddSocietyMoney(self.company, amount, reason)
    end)
    if success then
        self.money = self.money + amount
        print(('[bcs_companymanager] TGG AddSocietyMoney succeeded: company=%s amount=%s'):format(tostring(self.company), tostring(amount)))
    else
        print(('[bcs_companymanager] TGG AddSocietyMoney failed for company=%s amount=%s'):format(tostring(self.company), tostring(amount)))
    end
end

function Account:HandleOKOKMoneyAdd(amount, reason)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:AddMoney(self.company, amount, reason)
    end)
    if success then self.money = self.money + amount end
end

function Account:Refresh()
    local integration = self:GetSocietyIntegration()
    if integration then
        self:InitializeWithSocietyIntegration(integration, self:GetTableName())
    end
end

-- Remove Money Handlers
function Account:HandleESXMoneyRemove(amount)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. self.company, function(account)
        if account.money >= amount then
            self.money = self.money - amount
            account.removeMoney(amount)
        end
    end)
end

function Account:HandleQBMoneyRemove(amount)
    local success, account = pcall(function()
        return exports[Config.SocietyIntegration.ResourceName]:GetAccount(self.company)
    end)
    if success and account.account_balance >= amount then
        pcall(function()
            exports[Config.SocietyIntegration.ResourceName]:RemoveMoney(self.company, amount)
        end)
        self.money = self.money - amount
    end
end

function Account:HandleQBManagementMoneyRemove(amount)
    local success, money = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        return self.isGang and export:GetGangAccount(self.company) or export:GetAccount(self.company)
    end)
    if success and money >= amount then
        pcall(function()
            local export = exports[Config.SocietyIntegration.ResourceName]
            local method = self.isGang and 'RemoveGangMoney' or 'RemoveMoney'
            export[method](export, self.company, amount)
        end)
        self.money = self.money - amount
    end
end

function Account:HandleFDBankingMoneyRemove(amount)
    self:HandleQBManagementMoneyRemove(amount)
end

function Account:HandleLGModsBankingMoneyRemove(amount)
    exports[Config.SocietyIntegration.ResourceName]:RemoveMoney(nil, amount, "business", self.company)
end

function Account:HandleRenewedBankingMoneyRemove(amount)
    local success = pcall(function()
        local export = exports[Config.SocietyIntegration.ResourceName]
        export:removeAccountMoney(self.company, amount)
    end)
    if success then self.money = self.money - amount end
end

function Account:HandleCRMBankingMoneyRemove(amount)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:crm_remove_money(self.company, amount)
    end)
    if success then self.money = self.money - amount end
end

function Account:HandleTGGMoneyRemove(amount)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:RemoveSocietyMoney(self.company, amount)
    end)
    if success then self.money = self.money - amount end
end

function Account:HandleOKOKMoneyRemove(amount)
    local success = pcall(function()
        exports[Config.SocietyIntegration.ResourceName]:RemoveMoney(self.company, amount)
    end)
    if success then self.money = self.money - amount end
end

function Account:HandleDatabaseMoneyAdd(accountType, amount, tableName)
    if accountType == ACCOUNT_TYPES.MONEY then
        self.money = self.money + amount
        self:EnsureDatabaseAccount()
        MySQL.prepare.await(
            'UPDATE ' ..
            tableName ..
            ' SET ' ..
            Config.Database.CompanyColumns.Amount .. ' = ? WHERE ' .. Config.Database.CompanyColumns.Job .. ' = ?',
            { self.money, self.company }
        )
    else
        self.blackMoney = self.blackMoney + amount
        MySQL.prepare.await(
            'UPDATE ' .. tableName .. ' SET black_money = ? WHERE name = ?',
            { self.blackMoney, self.company }
        )
    end
end

function Account:HandleDatabaseMoneyRemove(accountType, amount, tableName)
    if accountType == ACCOUNT_TYPES.MONEY then
        self.money = self.money - amount
        self:EnsureDatabaseAccount()
        MySQL.update(
            'UPDATE ' ..
            tableName ..
            ' SET ' ..
            Config.Database.CompanyColumns.Amount .. ' = ? WHERE ' .. Config.Database.CompanyColumns.Job .. ' = ?',
            { self.money, self.company }
        )
    else
        self.blackMoney = self.blackMoney - amount
        MySQL.prepare.await(
            'UPDATE ' .. tableName .. ' SET black_money = ? WHERE name = ?',
            { self.blackMoney, self.company }
        )
    end
end
