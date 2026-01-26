---------- [Events] ----------
RegisterServerEvent("Pug:server:RegistersChargeCustomer", function(OtherID, Currency, Price)
    local src = source
    local Biller = Config.FrameworkFunctions.GetPlayer(src)
    if Biller then
        local Billed = Config.FrameworkFunctions.GetPlayer(tonumber(OtherID))
        if Billed then
            local Job = Biller.PlayerData.job.name
            local Amount = tonumber(Price)
            -- local Commission = round(Amount * Config.Commission)
            local BankBalance = Billed.PlayerData.money.cash
            if Currency == "card" then
                BankBalance = Billed.PlayerData.money.bank
            end
            if Amount > 0 then
                if BankBalance >= Amount then
                    local result = MySQL.query.await('SELECT * FROM pug_businesses', {})
                    if result[1] ~= nil then
                        for key, v in pairs(result) do
                            if tostring(result[key]["job"]) == tostring(Job) then
                                for k, _ in pairs(v) do
                                    if k == "registers" then
                                        TriggerClientEvent('Pug:Client:CreateCustomerRegisters', -1, Job, Amount, src, Currency, v)
                                    end
                                end
                            end
                        end
                    end
                    TriggerClientEvent('Pug:client:ShowBusinessNotify', src, Config.LangT["CustomerCanPay"], 'success')
                    TriggerClientEvent('Pug:client:ShowBusinessNotify', OtherID, Config.LangT["PayAtRegister"] .. Amount)
                else
                    TriggerClientEvent("Pug:client:ShowBusinessNotify", src, Config.LangT["MissingMoney"].. Amount - BankBalance, "error")
                    TriggerClientEvent("Pug:client:ShowBusinessNotify", tonumber(OtherID), Config.LangT["MissingMoney"].. Amount - BankBalance, "error")
                end
            else 
                TriggerClientEvent('Pug:client:ShowBusinessNotify', src, Config.LangT["CantChargeNothing"], 'error') 
                return 
            end
        end
    end
end)
RegisterNetEvent("Pug:server:RemoveAllBuinessRegistersForEveryone", function(Logic)
    TriggerClientEvent("Pug:Client:RemoveAllBuinessRegistersForEveryone", -1, Logic)
end)
------------------------------

---------- [Callbacks] ----------
Config.FrameworkFunctions.CreateCallback('Pug:serverCB:GetBalanceBusinessCreator', function(source, cb, Type, Amount, Seller)
    local src = source
    local PayedForOrder
    local PyamentType
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if Player then
        local BankBalance
        if Type == "card" then
            PyamentType = "bank"
            BankBalance = Player.PlayerData.money.bank
        else
            if Framework == "QBCore" then
                PyamentType = "cash"
            else
                PyamentType = "money"
            end
            BankBalance = Player.PlayerData.money.cash
        end
        if BankBalance >= Amount then
            local PlayersTable = {}
            local AmountOfWorkers = 0
            -- Getting the on duty workers
            local Biller = Config.FrameworkFunctions.GetPlayer(Seller)
            local BillerJob = tostring(Biller.PlayerData.job.name)
            local PlayerCoords = GetEntityCoords(GetPlayerPed(src))
            for _, v in pairs(Config.FrameworkFunctions.GetPlayers()) do
                local Player = Config.FrameworkFunctions.GetPlayer(v)
                if Player then
                    if Player.PlayerData.job.name == BillerJob then
                        local TCoords = GetEntityCoords(GetPlayerPed(v))
                        local Dist = #(PlayerCoords - TCoords)
                        if Dist <= 150.0 then
                            AmountOfWorkers = AmountOfWorkers + 1
                            table.insert(PlayersTable, v)
                        end
                    end
                end
            end
            Wait(100)
            -- On duty workers pay
            if AmountOfWorkers > 0 then
                WorkersCommission = Config.WorkersCommission / AmountOfWorkers
            end
            local OnDutyWorkersPay = math.ceil(Amount * WorkersCommission)
            for _, v in pairs(PlayersTable) do
                local Player = Config.FrameworkFunctions.GetPlayer(v)
                if Player then
                    local Currency = "cash"
                    if Framework == "ESX" then
                        Currency = "money"
                    end
                    Player.AddMoney(Currency, OnDutyWorkersPay)
                    TriggerClientEvent("Pug:client:ShowBusinessNotify", v, "You have earned +"..OnDutyWorkersPay.." as commission for sale.", "success")
                end
            end
            -- Business Pay
            local BusinessCommission = math.ceil(Amount * Config.BusinessCommission)
            if Config.ManagementScript == "okokBanking" then
                local SenderNameFirst = Player.PlayerData.charinfo.firstname
                TriggerEvent('okokBanking:AddNewTransaction', BillerJob, BillerJob, SenderNameFirst, Seller, Amount, "Cash register transaction")
            end
            
            if Config.ManagementScript then
                if Framework == "ESX" then
                    TriggerEvent('esx_addonaccount:getSharedAccount', "society_"..BillerJob, function(account)
                        account.addMoney(BusinessCommission)
                    end)
                else
                    if GetResourceState("nfs-billing") == 'started' then
                        exports['nfs-billing']:depositSociety(BillerJob, BusinessCommission)
                    elseif GetResourceState("snipe-banking") == 'started' then
                        exports["snipe-banking"]:AddMoneyToAccount(BillerJob, BusinessCommission)
                    elseif Config.ManagementScript == "Renewed-Banking" then
                        exports[Config.ManagementScript]:addAccountMoney(BillerJob, BusinessCommission)
                    else
                        exports[Config.ManagementScript]:AddMoney(BillerJob, BusinessCommission)
                    end
                end
            end
            -- Biller Pay
            local BillerCommission = Config.BillerCommission
            local BillerMoneyMake = math.ceil(Amount * BillerCommission)
            local Currency = "cash"
            if Framework == "ESX" then
                Currency = "money"
            end
            Biller.AddMoney(Currency, BillerMoneyMake)
            TriggerClientEvent("Pug:client:ShowBusinessNotify", Seller, "You have earned +"..BillerMoneyMake.." for making the sale.", "success")
            -- Customer Purchase
            Player.RemoveMoney(PyamentType, math.ceil(Amount))
            ----------------------
            PayedForOrder = true
        else
            TriggerClientEvent("Pug:client:ShowBusinessNotify", src, Config.LangT["MissingMoney"].. Amount - BankBalance, "error")
        end
    end
    cb(PayedForOrder)
end)
------------------------------

---------- [ESX SOCIETY SUPPORT] ----------
CreateThread(function()
    if Framework == "ESX" then
        if GetResourceState("esx_society") ~= 'missing' then
            if GetResourceState("esx_addonaccount") ~= 'missing' then
                local result3 = MySQL.query.await('SELECT * FROM pug_businesses', {})
                if result3[1] ~= nil then
                    for k, _ in pairs(result3) do
                        local ThisJob = result3[k]["job"]
                        local DoesSocietyExist = MySQL.query.await('SELECT * FROM addon_account WHERE name = ?', {"society_"..ThisJob})
                        if DoesSocietyExist[1] then
                            TriggerEvent('esx_society:registerSociety', tostring(ThisJob), tostring(ThisJob), 'society_'..tostring(ThisJob), 'society_'..tostring(ThisJob), 'society_'..tostring(ThisJob), { type = 'public' })
                        else
                            MySQL.insert('INSERT INTO addon_account (name, label, shared) VALUES (?, ?, ?)', {"society_"..ThisJob, ThisJob, 1})
                            TriggerEvent('esx_society:registerSociety', tostring(ThisJob), tostring(ThisJob), 'society_'..tostring(ThisJob), 'society_'..tostring(ThisJob), 'society_'..tostring(ThisJob), { type = 'public' })
                        end
                    end
                end
            end
        end
    end
end)
------------------------------