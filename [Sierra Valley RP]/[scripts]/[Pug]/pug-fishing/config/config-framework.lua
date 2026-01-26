Config = {}
---------- [Framework] ----------
-- (DONT TOUCH THIS UNLESS YOU HAVE A CUSTOM FRAMEWORK)
if GetResourceState('es_extended') == 'started' then
    Framework = "ESX" -- (ESX) or (QBCore)
elseif GetResourceState('qb-core') == 'started' then
    Framework = "QBCore" -- (ESX) or (QBCore)
elseif GetResourceState('qbx_core') == 'started' then
    Framework = "QBCore" -- Qbox uses QBCore compatibility
end
if Framework == "QBCore" then
    Config.CoreName = "qbx_core" -- Changed to qbx_core for Qbox framework
    FWork = exports[Config.CoreName]:GetCoreObject()
elseif Framework == "ESX" then
    Config.CoreName = "es_extended" -- your core name
    FWork = exports[Config.CoreName]:getSharedObject()
end

Config.VehilceKeysGivenToPlayerEvent = "vehiclekeys:client:SetOwner" -- This is the fallback event (the main code runs compatibility for all the main key scripts)

-- [THESE ARE NOT NOT MEANT TO BE TOUCHED UNLESS YOU KNOW WHAT YOU ARE DOING]
Config.CompatibleTargetScripts = { -- Put whatever target script you use in this table if it is not here.
    "ox_target",
    "qb-target",
    "qtarget",
}
Config.CompatibleInputScripts = { -- If you have multiple input scripts in your server, Put only the one you want to use in this table or else dont touch this.
    "ox_lib",
    "qb-input",
    "ps-ui",
}
Config.CompatibleMenuScripts = { -- If you have multiple Menu scripts in your server, Put only the one you want to use in this table or else dont touch this.
    "lation_ui",
    "ox_lib",
    "qb-menu",
    "ps-ui",
}
Config.CompatibleInventoryScripts = { -- Add your inventory here if it's not listed—only explicitly supported FiveM inventories are guaranteed to be compatible.
    "ak47_qb_inventory",
    "ak47_inventory",
    "ox_inventory",
    "qs-inventory",
    "ps-inventory",
    "lj-inventory",
    "core_inventory",
    "tgiann-inventory",
    "codem-inventory",
    "qb-inventory",
}
Config.CompatiblePhoneScripts = { -- Having a compatible phone script is not required
    "qb-phone",
    "qs-smartphone",
    "qs-smartphone-pro",
    "lb-phone",
    "roadphone",
    "jpr-phonesystem",
    "gksphone",
    "okokPhone",
    "yseries",
}
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleTargetScripts) do
    if GetResourceState(v) == 'started' then
        Config.Target = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleMenuScripts) do
    if GetResourceState(v) == 'started' then
        Config.Menu = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleInputScripts) do
    if GetResourceState(v) == 'started' then
        Config.Input = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatibleInventoryScripts) do
    if GetResourceState(v) == 'started' then
        Config.InventoryType = tostring(v)
        break
    end
end
-- (DONT TOUCH ANY OF THIS SECTION)
for _, v in pairs(Config.CompatiblePhoneScripts) do
    if GetResourceState(v) == 'started' then
        Config.Phone = tostring(v)
        break
    end
end
-- Do not touch any of this unless
-- YOU REALLY KNOW WHAT YOU ARE DOING
Config.FrameworkFunctions = {
    -- Client-side trigger callback
    TriggerCallback = function(...)
        if Framework == 'QBCore' then
            FWork.Functions.TriggerCallback(...)
        else
            FWork.TriggerServerCallback(...)
        end
    end,

    -- Server-side register callback
    CreateCallback = function(...)
        if Framework == 'QBCore' then
            FWork.Functions.CreateCallback(...)
        else
            FWork.RegisterServerCallback(...)
        end
    end,

    -- Server-side Get All Players
    GetPlayers = function()
        if Framework == 'QBCore' then
            return FWork.Functions.GetPlayers()
        else
            return FWork.GetPlayers()
        end
    end,

    -- Client Notification Function
    Notify = function(msg, type, length)
        if Framework == 'QBCore' then
            return FWork.Functions.Notify(msg, type, length)
        else
            return FWork.ShowNotification(msg, type, length)
        end
    end,
    

    GetItemByName = function(source, item, amount) 
        if Framework == 'QBCore' then 
            local player = FWork.Functions.GetPlayer(source)
            return player.Functions.GetItemByName(item, amount)
        else
            local player = FWork.GetPlayerFromId(source)
            return player.getInventoryItem(item, amount)
        end
    end,
    
    -- Server-side get player data
    GetPlayer = function(source,cid,client)
        if Framework == 'QBCore' then
            local self = {}
            local player = nil
            if cid then
                player = FWork.Functions.GetPlayerByCitizenId(source)
            elseif client then
                player = FWork.Functions.GetPlayerData()
            else
                player = FWork.Functions.GetPlayer(source)
            end

            if (player ~= nil) then
                self.source = source
                if client then
                    self.PlayerData = { charinfo = { firstname = player.charinfo.firstname, lastname = player.charinfo.lastname}, citizenid = player.citizenid, money = player.money, metadata = player.metadata }
                else
                    self.PlayerData = { charinfo = { firstname = player.PlayerData.charinfo.firstname, lastname = player.PlayerData.charinfo.lastname}, citizenid = player.PlayerData.citizenid, 
                    money = player.PlayerData.money, metadata = player.PlayerData.metadata, items = player.PlayerData.items, source =  player.PlayerData.source, job = {name = player.PlayerData.job.name}}
                end
                self.AddMoney = function(currency, amount) 
                    player.Functions.AddMoney(currency, amount)
                end
                self.RemoveMoney = function(currency, amount) 
                    player.Functions.RemoveMoney(currency, amount)
                end

                self.RemoveItem = function(item, amount) 
                    player.Functions.RemoveItem(item, amount, false)
                end

                self.AddItem = function(item, amount, info) 
                    player.Functions.AddItem(item, amount, false, info)
                end

                self.SetInventory = function(Data) 
                    player.Functions.SetInventory(Data)
                end

                self.SetMetaData = function(metadata, value) 
                    player.Functions.SetMetaData(metadata, value)
                end

                return self
            end
        else
            local self = {}
            local player = nil
            if cid then
                player = FWork.GetPlayerFromId(PugFindPlayersByItentifier(source))
            elseif client then
                player = FWork.GetPlayerData()
            else
                player = FWork.GetPlayerFromId(source)
            end

            if (player ~= nil) then
                self.source = source
                if client then
                    self.PlayerData = { money = {cash = PugGetPlayerMoneyCount()},charinfo = { firstname = player.get('firstName'), lastname = player.get('lastName')} }
                else
                    self.PlayerData = { charinfo = { firstname = player.get('firstName'), lastname = player.get('lastName')}, citizenid = player.identifier, 
                    money = {cash = player.getAccount('money').money, bank = player.getAccount('bank').money}, source = player.source, job = { name = player.job.name }}
                end
                self.AddMoney = function(currency, amount) 
                    player.addMoney(amount)
                end
                self.RemoveMoney = function(currency, amount) 
                    player.removeMoney(amount)
                end

                self.RemoveItem = function(item, amount) 
                    player.removeInventoryItem(item, amount)
                end

                self.AddItem = function(item, amount, info) 
                    player.addInventoryItem(item, amount, false, info)
                end

                return self
            end
        end

        return nil
    end,
}