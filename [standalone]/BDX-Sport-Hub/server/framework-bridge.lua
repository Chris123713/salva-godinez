--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
-- Framework Bridge (Open Source)
-- This file handles all framework-specific logic
-- Users can modify this file to support custom frameworks
--------------------------------------

-- ═══════════════════════════════════════════════════════════════
-- 🔧 FRAMEWORK INITIALIZATION
-- ═══════════════════════════════════════════════════════════════

local QBCore = nil
local QBX = nil
local ESX = nil
local vRP = nil
local vRPclient = nil

if Config.Framework == "qb" then
    QBCore = exports[Config.FrameworkResourceName or "qb-core"]:GetCoreObject()
elseif Config.Framework == "qbox" then
    QBX = exports[Config.FrameworkResourceName or "qbx_core"]
elseif Config.Framework == "esx" then
    ESX = exports[Config.FrameworkResourceName or "es_extended"]:getSharedObject()
elseif Config.Framework == "vrp" then
    local Proxy = module("vrp", "lib/Proxy")
    local Tunnel = module("vrp", "lib/Tunnel")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP", "BDX-Sport-Hub")
elseif Config.Framework == "creative" then
    local Tunnel = module("vrp","lib/Tunnel")
    local Proxy = module("vrp","lib/Proxy")
    vRPC = Tunnel.getInterface("vRP")
    vRP = Proxy.getInterface("vRP")
    vRPclient = Tunnel.getInterface("vRP", "BDX-Sport-Hub")
elseif Config.Framework == "custom" then
    -- Enter your Framework Logic / References here.
end

-- ═══════════════════════════════════════════════════════════════
-- 💰 MONEY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

---Get player's money amount
---@param src number Player source
---@return number Money amount
function GetPlayerMoney(src)
    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.money["cash"] or 0
        end
    elseif Config.Framework == "qbox" then
        local Player = QBX:GetPlayer(src)
        if Player then
            return Player.PlayerData.money["cash"] or 0
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getMoney()
        end
    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if user_id then
            return vRP.getMoney({user_id}) or 0
        end
    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if Passport then
            return vRP.GetBank(Passport) or 0
        end
        return 0
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end
    return 0
end

---Remove money from player (silently, without framework notifications)
---@param src number Player source
---@param amount number Amount to remove
---@return boolean Success
function RemoveMoney(src, amount)
    if amount <= 0 then
        return true
    end

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.Functions.RemoveMoney("cash", amount)
        end
    elseif Config.Framework == "qbox" then
        local Player = QBX:GetPlayer(src)
        if Player then
            return Player.Functions.RemoveMoney("cash", amount)
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getMoney() >= amount then
            local currentMoney = xPlayer.getAccount('money').money
            xPlayer.setAccountMoney('money', currentMoney - amount)
            return true
        end
    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if user_id then
            return vRP.tryPayment({user_id, amount})
        end
    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if Passport then
            return vRP.RemoveBank(Passport, amount)
        end
        return false
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end
    return false
end


-- ═══════════════════════════════════════════════════════════════
-- 🎒 INVENTORY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

---Give item to player
---@param src number Player source
---@param item string Item name
---@param amount number Amount to give (default: 1)
---@return boolean Success
function GiveItem(src, item, amount)
    amount = amount or 1

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
            return true
        end
    elseif Config.Framework == "qbox" then
        if GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:AddItem(src, item, amount)
            return true
        else
            local Player = QBX:GetPlayer(src)
            if Player then
                Player.Functions.AddItem(item, amount)
                TriggerClientEvent('ox_inventory:notify', src, {text = 'Received ' .. item, type = 'success'})
                return true
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:AddItem(src, item, amount)
            else
                local itemData = xPlayer.getInventoryItem(item)
                if itemData then
                    xPlayer.setInventoryItem(item, itemData.count + amount)
                end
            end
            return true
        end
    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if user_id then
            vRP.giveInventoryItem({user_id, item, amount, true})
            return true
        end
    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if Passport then
            vRP.GiveItem(Passport, item, amount, true)
            return true
        end
        return false
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end
    return false
end

---Remove specific amount of item from player
---@param src number Player source
---@param item string Item name
---@param amount number Amount to remove (default: 1)
---@return boolean Success
function RemoveItem(src, item, amount)
    amount = amount or 1
    local removed = false

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.RemoveItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
            removed = true
        end
    elseif Config.Framework == "qbox" then
        if GetResourceState('ox_inventory') == 'started' then
            exports.ox_inventory:RemoveItem(src, item, amount)
            removed = true
        else
            local Player = QBX:GetPlayer(src)
            if Player then
                Player.Functions.RemoveItem(item, amount)
                removed = true
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if GetResourceState('ox_inventory') == 'started' then
                exports.ox_inventory:RemoveItem(src, item, amount)
            else
                local itemData = xPlayer.getInventoryItem(item)
                if itemData and itemData.count >= amount then
                    xPlayer.setInventoryItem(item, itemData.count - amount)
                end
            end
            removed = true
        end
    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if user_id then
            if vRP.tryGetInventoryItem({user_id, item, amount, true}) then
                removed = true
            end
        end
    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if Passport then
            if vRP.TakeItem(Passport, item, amount, true) then
                removed = true
            end
        end
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end

    return removed
end

---Remove ALL quantity of an item from player
---@param src number Player source
---@param item string Item name
---@return number Amount removed
function RemoveAllItems(src, item)
    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return 0 end

        local removed = 0
        for _, it in pairs(Player.PlayerData.items or {}) do
            if it and it.name == item and (it.amount or 0) > 0 then
                Player.Functions.RemoveItem(item, it.amount, it.slot)
                removed = removed + (it.amount or 0)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
            end
        end
        return removed

    elseif Config.Framework == "qbox" then
        if GetResourceState('ox_inventory') == 'started' then
            local count = exports.ox_inventory:Search(src, 'count', item) or 0
            if count > 0 then
                exports.ox_inventory:RemoveItem(src, item, count)
            end
            return count
        else
            local Player = QBX:GetPlayer(src)
            if not Player then return 0 end

            local removed = 0
            for _, it in pairs(Player.PlayerData.items or {}) do
                if it and it.name == item and (it.amount or 0) > 0 then
                    Player.Functions.RemoveItem(item, it.amount, it.slot)
                    removed = removed + (it.amount or 0)
                end
            end
            return removed
        end

    elseif Config.Framework == "esx" then
        if GetResourceState('ox_inventory') == 'started' then
            local count = exports.ox_inventory:Search(src, 'count', item) or 0
            if count > 0 then
                exports.ox_inventory:RemoveItem(src, item, count)
            end
            return count
        else
            local xPlayer = ESX.GetPlayerFromId(src)
            if not xPlayer then return 0 end
            local itemData = xPlayer.getInventoryItem(item)
            local count = (itemData and (itemData.count or itemData.quantity)) or 0
            if count > 0 then
                xPlayer.setInventoryItem(item, 0)
            end
            return count
        end

    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if not user_id then return 0 end
        local amount = vRP.getInventoryItemAmount({user_id, item}) or 0
        if amount > 0 then
            vRP.tryGetInventoryItem({user_id, item, amount, true})
        end
        return amount

    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if not Passport then return 0 end
        local amount = vRP.InventoryAmount(Passport, item) or 0
        if amount > 0 then
            vRP.TakeItem(Passport, item, amount, true)
        end
        return amount
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end

    return 0
end

---Check if player has an item
---@param src number Player source
---@param item string Item name
---@return boolean Has item
function HasItem(src, item)
    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local playerItem = Player.Functions.GetItemByName(item)
            return playerItem ~= nil
        end
    elseif Config.Framework == "qbox" then
        if GetResourceState('ox_inventory') == 'started' then
            local count = exports.ox_inventory:Search(src, 'count', item) or 0
            return count > 0
        else
            local Player = QBX:GetPlayer(src)
            if Player then
                local playerItem = Player.Functions.GetItemByName(item)
                return playerItem ~= nil
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local itemData = xPlayer.getInventoryItem(item)
            return itemData and (itemData.count or itemData.quantity or 0) > 0
        end
    elseif Config.Framework == "vrp" then
        local user_id = vRP.getUserId({src})
        if user_id then
            return (vRP.getInventoryItemAmount({user_id, item}) or 0) > 0
        end
    elseif Config.Framework == "creative" then
        local Passport = vRP.Passport(src)
        if Passport then
            local it = vRP.ConsultItem(Passport, item)
            if it and ((it.amount or it) >= 1) then
                return true
            end
        end
        return false
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- 📦 USEABLE ITEM REGISTRATION
-- ═══════════════════════════════════════════════════════════════

---Register useable items for all gear categories
function RegisterUseableItems()
    -- Skateboard
    if GetResourceState('BDX-Skate') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("skateboard", function(source, item)
                TriggerClientEvent('bodhix-skating:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("skateboard", function(source, item)
                TriggerClientEvent('bodhix-skating:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("skateboard", function(source, item)
                TriggerClientEvent('bodhix-skating:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("skateboard", {
                name = "skateboard",
                description = "Ride your skateboard",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-skating:client:start', player, {name = "skateboard"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "skateboard" then
                    TriggerClientEvent("bodhix-skating:client:start", source, { name = "skateboard" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Hoverboard
    if GetResourceState('BDX-Hoverboard') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("hoverboard", function(source, item)
                TriggerClientEvent('bodhix-Retro:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("hoverboard", function(source, item)
                TriggerClientEvent('bodhix-Retro:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("hoverboard", function(source, item)
                TriggerClientEvent('bodhix-Retro:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("hoverboard", {
                name = "hoverboard",
                description = "Ride your hoverboard",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-Retro:client:start', player, {name = "hoverboard"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "hoverboard" then
                    TriggerClientEvent("bodhix-Retro:client:start", source, { name = "hoverboard" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- BMX
    if GetResourceState('BDX-Bmx') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("bmx", function(source, item)
                TriggerClientEvent('bodhix-bmx:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("bmx", function(source, item)
                TriggerClientEvent('bodhix-bmx:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("bmx", function(source, item)
                TriggerClientEvent('bodhix-bmx:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("bmx", {
                name = "bmx",
                description = "Ride your BMX",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-bmx:client:start', player, {name = "bmx"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "bmx" then
                    TriggerClientEvent("bodhix-bmx:client:start", source, { name = "bmx" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Scooter
    if GetResourceState('BDX-Scooter') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("scooter", function(source, item)
                TriggerClientEvent('bodhix-Scooter:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("scooter", function(source, item)
                TriggerClientEvent('bodhix-Scooter:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("scooter", function(source, item)
                TriggerClientEvent('bodhix-Scooter:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("scooter", {
                name = "scooter",
                description = "Ride your scooter",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-Scooter:client:start', player, {name = "scooter"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "scooter" then
                    TriggerClientEvent("bodhix-Scooter:client:start", source, { name = "scooter" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Rollers
    if GetResourceState('BDX-Rollers') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("rollers", function(source, item)
                TriggerClientEvent('bodhix-Roller:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("rollers", function(source, item)
                TriggerClientEvent('bodhix-Roller:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("rollers", function(source, item)
                TriggerClientEvent('bodhix-Roller:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("rollers", {
                name = "rollers",
                description = "Wear your rollers",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-Roller:client:start', player, {name = "rollers"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "rollers" then
                    TriggerClientEvent("bodhix-Roller:client:start", source, { name = "rollers" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Skis
    if GetResourceState('BDX-Ski') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("skis", function(source, item)
                TriggerClientEvent('bodhix-Ski:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("skis", function(source, item)
                TriggerClientEvent('bodhix-Ski:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("skis", function(source, item)
                TriggerClientEvent('bodhix-Ski:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("skis", {
                name = "skis",
                description = "Use your skis",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-Ski:client:start', player, {name = "skis"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "skis" then
                    TriggerClientEvent("bodhix-Ski:client:start", source, { name = "skis" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Ice Skates
    if GetResourceState('BDX-Ice-Skate') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("iceskates", function(source, item)
                TriggerClientEvent('bodhix-IceSkating:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("iceskates", function(source, item)
                TriggerClientEvent('bodhix-IceSkating:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("iceskates", function(source, item)
                TriggerClientEvent('bodhix-IceSkating:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("iceskates", {
                name = "iceskates",
                description = "Wear your ice skates",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-IceSkating:client:start', player, {name = "iceskates"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "iceskates" then
                    TriggerClientEvent("bodhix-IceSkating:client:start", source, { name = "iceskates" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    -- Snowboard
    if GetResourceState('BDX-Snowboarding') == 'started' then
        if Config.Framework == "qb" then
            QBCore.Functions.CreateUseableItem("snowboard", function(source, item)
                TriggerClientEvent('bodhix-snowboarding:client:start', source, item)
            end)
        elseif Config.Framework == "qbox" then
            QBX:CreateUseableItem("snowboard", function(source, item)
                TriggerClientEvent('bodhix-snowboarding:client:start', source, item)
            end)
        elseif Config.Framework == "esx" then
            ESX.RegisterUsableItem("snowboard", function(source, item)
                TriggerClientEvent('bodhix-snowboarding:client:start', source, item)
            end)
        elseif Config.Framework == "vrp" then
            vRP.defInventoryItem("snowboard", {
                name = "snowboard",
                description = "Use your snowboard",
                choices = {
                    ["Use"] = function(player, choice)
                        local user_id = vRP.getUserId({player})
                        if user_id then
                            TriggerClientEvent('bodhix-snowboarding:client:start', player, {name = "snowboard"})
                        end
                    end
                },
                weight = 1.0
            })
        elseif Config.Framework == "creative" then
            AddEventHandler("inventory:UseItem", function(source, itemName)
                if itemName == "snowboard" then
                    TriggerClientEvent("bodhix-snowboarding:client:start", source, { name = "snowboard" })
                end
            end)
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
        end
    end

    if Config.Debug then
        print("^2[Sport Hub] Useable items registered for all available gear categories^0")
    end
end


-- Register items on resource start
CreateThread(function()
    -- Wait for framework to be ready
    Wait(1000)
    RegisterUseableItems()
end)

---Show notification to player using Sport Hub language config
---@param src number Player source
---@param messageKey string Language key from Config.Language.Info (e.g., 'purchase', 'failed')
---@param type string Notification type ('success', 'error', 'info')
function ShowNotification(src, messageKey, type)
    -- Get message from Sport Hub config language
    local message = Config.Language.Info[messageKey] or messageKey

    if Config.Framework == "qb" then
        local QBCore = exports[Config.FrameworkResourceName or "qb-core"]:GetCoreObject()
        TriggerClientEvent('QBCore:Notify', src, message, type or 'primary')
    elseif Config.Framework == "qbox" then
        -- Qbox uses ox_lib for notifications
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Sport Hub',
            description = message,
            type = type or 'inform'
        })
    elseif Config.Framework == "esx" then
        TriggerClientEvent('esx:showNotification', src, message)
    elseif Config.Framework == "vrp" then
        TriggerClientEvent('vRP:Notify', src, message)
    elseif Config.Framework == "creative" then
        TriggerClientEvent("Notify", src, "Sport Hub", message, "default", 5000)
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 💾 DATABASE STORAGE FUNCTIONS (Replaces client-side KVP)
-- ═══════════════════════════════════════════════════════════════

-- Create database table on resource start (ONLY if using SQL storage)
CreateThread(function()
    -- Skip SQL initialization if using KVP storage
    if not Config.UseSQLStorage then
        print("^2[Sport Hub Storage] Using KVP storage mode - skipping SQL initialization^0")
        return
    end

    -- Wait for MySQL to be ready
    local maxAttempts = 10
    local attempt = 0

    while not MySQL and attempt < maxAttempts do
        Wait(1000)
        attempt = attempt + 1
        if Config.Debug then
            print(string.format("^3[Sport Hub Storage] Waiting for MySQL... (attempt %d/%d)^0", attempt, maxAttempts))
        end
    end

    if not MySQL then
        print("^1[Sport Hub Storage ERROR] MySQL not available! Make sure oxmysql is started before BDX-Sport-Hub.^0")
        return
    end

    if Config.Debug then
        print("^2[Sport Hub Storage] MySQL is ready, creating database table...^0")
    end

    local success = MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `sport_hub_purchases` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier',
            `item_type` VARCHAR(50) NOT NULL COMMENT 'iceskates, rollers, skateboard, etc.',
            `gender` VARCHAR(10) NOT NULL COMMENT 'male, female, or style name',
            `texture_id` INT NOT NULL DEFAULT 0 COMMENT '0-indexed texture/design ID',
            `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped, 0 if owned but not equipped',
            `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY `unique_purchase` (`identifier`, `item_type`, `gender`, `texture_id`),
            INDEX `identifier_index` (`identifier`),
            INDEX `item_type_index` (`item_type`),
            INDEX `equipped_index` (`identifier`, `item_type`, `gender`, `is_equipped`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])

    if success then
        if Config.Debug then
            print("^2[Sport Hub Storage] Database table 'sport_hub_purchases' created/verified^0")
        end

        -- ✅ Check if is_equipped column exists, add if missing (for existing tables)
        local checkColumn = MySQL.Sync.fetchAll([[
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'sport_hub_purchases'
            AND COLUMN_NAME = 'is_equipped'
        ]])

        if not checkColumn or #checkColumn == 0 then
            -- Column doesn't exist, add it
            if Config.Debug then
                print("^3[Sport Hub Storage] 'is_equipped' column missing, adding it...^0")
            end

            local alterSuccess = MySQL.Sync.execute([[
                ALTER TABLE `sport_hub_purchases`
                ADD COLUMN `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped, 0 if owned but not equipped'
            ]])

            if alterSuccess then
                if Config.Debug then
                    print("^2[Sport Hub Storage] ✅ Added 'is_equipped' column^0")
                end
            else
                print("^1[Sport Hub Storage ERROR] Failed to add 'is_equipped' column^0")
            end
        else
            if Config.Debug then
                print("^2[Sport Hub Storage] 'is_equipped' column already exists^0")
            end
        end

        -- 🔧 Check if UNIQUE KEY is correct, only recreate if needed
        local checkUniqueKey = MySQL.Sync.fetchAll([[
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.STATISTICS
            WHERE TABLE_SCHEMA = DATABASE()
            AND TABLE_NAME = 'sport_hub_purchases'
            AND INDEX_NAME = 'unique_purchase'
            ORDER BY SEQ_IN_INDEX
        ]])

        local hasCorrectUniqueKey = false
        if checkUniqueKey and #checkUniqueKey == 4 then
            -- Check if all 4 columns are correct: identifier, item_type, gender, texture_id
            local columns = {}
            for _, row in ipairs(checkUniqueKey) do
                table.insert(columns, row.COLUMN_NAME)
            end
            if columns[1] == "identifier" and columns[2] == "item_type" and columns[3] == "gender" and columns[4] == "texture_id" then
                hasCorrectUniqueKey = true
            end
        end

        if not hasCorrectUniqueKey then
            print("^1[Sport Hub Storage] ⚠️  UNIQUE KEY is INCORRECT - needs to be fixed!^0")
            print("^1[Sport Hub Storage] ⚠️  ALL purchase data will be lost - recreating table...^0")

            -- Drop entire table
            MySQL.Sync.execute([[DROP TABLE IF EXISTS `sport_hub_purchases`]])

            Wait(200)

            -- Recreate table with correct UNIQUE KEY
            MySQL.Sync.execute([[
                CREATE TABLE `sport_hub_purchases` (
                    `id` INT AUTO_INCREMENT PRIMARY KEY,
                    `identifier` VARCHAR(60) NOT NULL COMMENT 'Player identifier',
                    `item_type` VARCHAR(50) NOT NULL COMMENT 'iceskates, rollers, skateboard, etc.',
                    `gender` VARCHAR(10) NOT NULL COMMENT 'male, female, or style name',
                    `texture_id` INT NOT NULL DEFAULT 0 COMMENT '0-indexed texture/design ID',
                    `is_equipped` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 if currently equipped, 0 if owned but not equipped',
                    `purchased_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE KEY `unique_purchase` (`identifier`, `item_type`, `gender`, `texture_id`),
                    INDEX `identifier_index` (`identifier`),
                    INDEX `item_type_index` (`item_type`),
                    INDEX `equipped_index` (`identifier`, `item_type`, `gender`, `is_equipped`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ]])

            if Config.Debug then
                print("^2[Sport Hub Storage] ✅ Table recreated with correct UNIQUE KEY!^0")
            end
        else
            if Config.Debug then
                print("^2[Sport Hub Storage] ✅ UNIQUE KEY is correct - no recreation needed^0")
            end
        end

        if Config.Debug then
            print("^2[Sport Hub Storage] Database table 'sport_hub_purchases' ready^0")
        end
    else
        print("^1[Sport Hub Storage ERROR] Failed to create database table! Check MySQL connection.^0")
    end
end)

---Helper function to get a specific identifier type from player using FiveM natives
---@param src number Player source
---@param idType string Identifier type (license, steam, discord, fivem, xbl, live)
---@return string|nil Identifier or nil if not found
local function GetIdentifierByType(src, idType)
    -- Use FiveM native to get all player identifiers
    local identifiers = GetPlayerIdentifiers(src)
    if not identifiers then return nil end

    for _, id in pairs(identifiers) do
        if id and string.find(id, idType .. ":") then
            return id
        end
    end
    return nil
end

---Get player identifier based on framework (with retry for timing issues)
---@param src number Player source
---@param maxRetries number|nil Maximum retry attempts (default: 10)
---@return string|nil Player identifier
function GetPlayerIdentifier(src, maxRetries)
    maxRetries = maxRetries or 10
    local retryDelay = 500 -- ms between retries

    for attempt = 1, maxRetries do
        local identifier = nil

        if Config.Framework == "qb" then
            -- QBCore: Check Config.IdentifierType to determine which identifier to use
            local idType = Config.IdentifierType or "auto"

            if idType == "auto" then
                -- Use QBCore's citizenid (default behavior)
                local Player = QBCore.Functions.GetPlayer(src)
                if Player then
                    identifier = Player.PlayerData.citizenid
                end
            else
                -- Use specific identifier type from FiveM natives
                identifier = GetIdentifierByType(src, idType)

                -- Fallback to citizenid if specific type not found
                if not identifier then
                    local Player = QBCore.Functions.GetPlayer(src)
                    if Player then
                        identifier = Player.PlayerData.citizenid
                        if Config.Debug then
                            print(string.format("^3[Sport Hub Storage] Requested identifier type '%s' not found, falling back to citizenid: %s^0", idType, identifier))
                        end
                    end
                end
            end
        elseif Config.Framework == "qbox" then
            -- QBox: Check Config.IdentifierType to determine which identifier to use
            local idType = Config.IdentifierType or "auto"

            if idType == "auto" then
                -- Use QBox's citizenid (default behavior)
                local Player = QBX:GetPlayer(src)
                if Player then
                    identifier = Player.PlayerData.citizenid
                end
            else
                -- Use specific identifier type from FiveM natives
                identifier = GetIdentifierByType(src, idType)

                -- Fallback to citizenid if specific type not found
                if not identifier then
                    local Player = QBX:GetPlayer(src)
                    if Player then
                        identifier = Player.PlayerData.citizenid
                        if Config.Debug then
                            print(string.format("^3[Sport Hub Storage] Requested identifier type '%s' not found, falling back to citizenid: %s^0", idType, identifier))
                        end
                    end
                end
            end
        elseif Config.Framework == "esx" then
            -- ESX: Check Config.IdentifierType to determine which identifier to use
            local idType = Config.IdentifierType or "auto"

            if idType == "auto" then
                -- Use ESX's configured identifier (default behavior)
                local xPlayer = ESX.GetPlayerFromId(src)
                if xPlayer then
                    identifier = xPlayer.identifier
                end
            else
                -- Use specific identifier type from FiveM natives
                identifier = GetIdentifierByType(src, idType)

                -- Fallback to ESX identifier if specific type not found
                if not identifier then
                    local xPlayer = ESX.GetPlayerFromId(src)
                    if xPlayer then
                        identifier = xPlayer.identifier
                        if Config.Debug then
                            print(string.format("^3[Sport Hub Storage] Requested identifier type '%s' not found, falling back to ESX identifier: %s^0", idType, identifier))
                        end
                    end
                end
            end
        elseif Config.Framework == "vrp" then
            local user_id = vRP.getUserId({src})
            if user_id then
                identifier = tostring(user_id)
            end
        elseif Config.Framework == "creative" then
            local Passport = vRP.Passport(src)
            if Passport then
                identifier = Passport
            end
        elseif Config.Framework == "custom" then
            -- Enter your Framework Logic / References here.
            -- You can use GetIdentifierByType(src, "license") for specific types
            -- Or implement your own logic here
        end

        -- If we got an identifier, return it
        if identifier then
            if attempt > 1 and Config.Debug then
                print(string.format("^2[Sport Hub Storage] Got identifier for player %d on attempt %d: %s^0", src, attempt, identifier))
            end
            return identifier
        end

        -- If this is the last attempt, don't wait
        if attempt >= maxRetries then
            break
        end

        -- Wait before retry (player might still be loading)
        if Config.Debug then
            print(string.format("^3[Sport Hub Storage] Player %d not fully loaded, waiting... (attempt %d/%d)^0", src, attempt, maxRetries))
        end
        Wait(retryDelay)
    end

    -- Failed after all retries
    if Config.Debug then
        print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d after %d attempts^0", src, maxRetries))
    end
    return nil
end

---Save player purchase to database (allows multiple designs per category)
---@param identifier string Player identifier
---@param itemType string Item type (iceskates, rollers, skateboard, etc.)
---@param gender string Gender (male/female)
---@param textureId number 0-indexed texture ID
---@param setAsEquipped boolean Whether to set this as the equipped design (default: true)
---@return boolean Success
function SavePurchase(identifier, itemType, gender, textureId, setAsEquipped)
    if setAsEquipped == nil then setAsEquipped = true end

    -- Note: textureId can be 0 (valid), so check for nil specifically
    if not identifier or not itemType or not gender or textureId == nil then
        if Config.Debug then
            print(string.format("^1[Sport Hub Storage] Invalid parameters: identifier=%s, itemType=%s, gender=%s, textureId=%s^0",
                tostring(identifier), tostring(itemType), tostring(gender), tostring(textureId)))
        end
        return false
    end

    -- 🚫 BLOCK suspicious parameters from corrupted individual resource events
    -- ✅ ALLOW hoverboard-style/last (this is legitimate for saving last used style)
    if not (itemType == "hoverboard-style" and gender == "last") then
        if itemType:match("%-style$") or itemType:match("%-last$") or gender == "last" then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] 🚫 BLOCKED suspicious save! itemType='%s' gender='%s'^0",
                    itemType, gender))
                print("^1[Sport Hub Storage] This is from a corrupted individual resource event - IGNORING IT!^0")
            end
            return false
        end
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] ⚡ SAVE CALLED: identifier=%s, itemType=%s, gender=%s, textureId=%d, equipped=%s^0",
                identifier, itemType, gender, textureId, setAsEquipped and "yes" or "no"))
        end

        local success = KVPStorage.SaveGearPurchase(identifier, itemType, gender, textureId, setAsEquipped)

        if Config.Debug then
            if success then
                print(string.format("^2[Sport Hub Storage KVP] ✅ SAVED purchase: %s | %s | %s | texture=%d | equipped=%s^0",
                    identifier, itemType, gender, textureId, setAsEquipped and "yes" or "no"))
            else
                print(string.format("^1[Sport Hub Storage KVP] ❌ FAILED to save purchase: %s | %s | %s | texture=%d^0",
                    identifier, itemType, gender, textureId))
            end
        end

        return success
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    -- Wait for MySQL to be available (with retry)
    local attempts = 0
    while not MySQL and attempts < 5 do
        Wait(500)
        attempts = attempts + 1
        if Config.Debug then
            print(string.format("^3[Sport Hub Storage] Waiting for MySQL in SavePurchase (attempt %d/5)^0", attempts))
        end
    end

    if not MySQL then
        print("^1[Sport Hub Storage] MySQL not available after 5 attempts! Cannot save purchase.^0")
        print("^1[Sport Hub Storage] Make sure 'oxmysql' is started BEFORE 'BDX-Sport-Hub' in your server.cfg^0")
        if Config.Debug then
            print("^3[Sport Hub Storage] TIP: Set Config.UseSQLStorage = false to use KVP storage instead^0")
        end
        return false
    end

    -- If setting as equipped, unequip all other designs for this category (but not this texture!)
    if setAsEquipped then
        MySQL.Sync.execute(
            'UPDATE sport_hub_purchases SET is_equipped = 0 WHERE identifier = ? AND item_type = ? AND gender = ? AND texture_id != ?',
            {identifier, itemType, gender, textureId}
        )
    end

    -- Insert new purchase or update if already exists
    if Config.Debug then
        print(string.format("^6[Sport Hub Storage] ⚡ SAVE CALLED: identifier=%s, itemType=%s, gender=%s, textureId=%d, equipped=%s^0",
            identifier, itemType, gender, textureId, setAsEquipped and "yes" or "no"))
    end

    local success = MySQL.Sync.execute(
        'INSERT INTO sport_hub_purchases (identifier, item_type, gender, texture_id, is_equipped) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE is_equipped = ?, purchased_at = CURRENT_TIMESTAMP',
        {identifier, itemType, gender, textureId, setAsEquipped and 1 or 0, setAsEquipped and 1 or 0}
    )

    if Config.Debug then
        if success then
            print(string.format("^2[Sport Hub Storage] ✅ SAVED purchase: %s | %s | %s | texture=%d | equipped=%s | affectedRows=%s^0",
                identifier, itemType, gender, textureId, setAsEquipped and "yes" or "no", tostring(success)))

            -- Query database to show ALL current rows for this identifier/itemType/gender
            local allRows = MySQL.Sync.fetchAll(
                'SELECT texture_id, is_equipped FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ?',
                {identifier, itemType, gender}
            )
            print(string.format("^5[Sport Hub Storage] 📊 Total rows in DB for %s/%s: %d^0", itemType, gender, #allRows))
            for i, row in ipairs(allRows) do
                local equipped = type(row.is_equipped) == "boolean" and (row.is_equipped and 1 or 0) or row.is_equipped
                print(string.format("^5  Row %d: texture_id=%d, is_equipped=%d^0", i, row.texture_id, equipped))
            end

            -- Also show ALL purchases for this player to see the complete picture
            local allPlayerRows = MySQL.Sync.fetchAll(
                'SELECT item_type, gender, texture_id, is_equipped FROM sport_hub_purchases WHERE identifier = ? ORDER BY item_type, gender, texture_id',
                {identifier}
            )
            print(string.format("^5[Sport Hub Storage] 🗄️  ALL purchases in database for this player: %d rows^0", #allPlayerRows))
            for i, row in ipairs(allPlayerRows) do
                local equipped = type(row.is_equipped) == "boolean" and (row.is_equipped and 1 or 0) or row.is_equipped
                print(string.format("^5  %d: %s/%s/texture_%d (equipped=%d)^0", i, row.item_type, row.gender, row.texture_id, equipped))
            end
        else
            print(string.format("^1[Sport Hub Storage] ❌ FAILED to save purchase: %s | %s | %s | texture=%d^0",
                identifier, itemType, gender, textureId))
        end
    end

    return success
end

---Get player purchase from database or KVP
---@param identifier string Player identifier
---@param itemType string Item type (iceskates, rollers, skateboard, etc.)
---@param gender string Gender (male/female)
---@return number|nil Texture ID (0-indexed) or nil if not found
function GetPurchase(identifier, itemType, gender)
    if not identifier or not itemType or not gender then
        if Config.Debug then
            print(string.format("^1[Sport Hub Storage] Invalid parameters for GetPurchase: identifier=%s, itemType=%s, gender=%s^0",
                tostring(identifier), tostring(itemType), tostring(gender)))
        end
        return nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] GetPurchase: identifier=%s, itemType=%s, gender=%s^0",
                identifier, itemType, gender))
        end

        -- First try to get equipped gear
        local equipped = KVPStorage.GetEquippedGear(identifier, itemType, gender)
        if equipped then
            if Config.Debug then
                print(string.format("^2[Sport Hub Storage KVP] Found equipped purchase: texture=%d^0", equipped.texture_id))
            end
            return equipped.texture_id
        end

        -- Fallback to any purchase
        local purchases = KVPStorage.GetGearPurchases(identifier, itemType, gender)
        if purchases and #purchases > 0 then
            if Config.Debug then
                print(string.format("^2[Sport Hub Storage KVP] Found purchase (not equipped): texture=%d^0", purchases[1].texture_id))
            end
            return purchases[1].texture_id
        end

        if Config.Debug then
            print(string.format("^3[Sport Hub Storage KVP] No purchase found: %s | %s | %s^0",
                identifier, itemType, gender))
        end
        return nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    -- Wait for MySQL to be available (with retry)
    local attempts = 0
    while not MySQL and attempts < 5 do
        Wait(500)
        attempts = attempts + 1
        if Config.Debug then
            print(string.format("^3[Sport Hub Storage] Waiting for MySQL in GetPurchase (attempt %d/5)^0", attempts))
        end
    end

    if not MySQL then
        print("^1[Sport Hub Storage] MySQL not available after 5 attempts! Cannot get purchase.^0")
        print("^1[Sport Hub Storage] Make sure 'oxmysql' is started BEFORE 'BDX-Sport-Hub' in your server.cfg^0")
        return nil
    end

    -- First try to get the EQUIPPED design
    local result = MySQL.Sync.fetchAll(
        'SELECT texture_id FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ? AND is_equipped = 1 LIMIT 1',
        {identifier, itemType, gender}
    )

    -- If no equipped design found, fallback to any purchase (for backwards compatibility)
    if not result or not result[1] then
        result = MySQL.Sync.fetchAll(
            'SELECT texture_id FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ? LIMIT 1',
            {identifier, itemType, gender}
        )
    end

    if result and result[1] then
        local textureId = result[1].texture_id
        if Config.Debug then
            print(string.format("^2[Sport Hub Storage] Retrieved purchase: %s | %s | %s | texture=%d^0",
                identifier, itemType, gender, textureId))
        end
        return textureId
    end

    if Config.Debug then
        print(string.format("^3[Sport Hub Storage] No purchase found: %s | %s | %s^0",
            identifier, itemType, gender))
    end
    return nil
end

---Get ALL purchased designs for a player for a specific category
---@param identifier string Player identifier
---@param itemType string Item type (iceskates, rollers, skateboard, etc.)
---@param gender string Gender (male/female)
---@return table Array of purchased texture IDs
function GetAllPurchases(identifier, itemType, gender)
    if not identifier or not itemType or not gender then
        if Config.Debug then
            print(string.format("^1[Sport Hub Storage] GetAllPurchases called with invalid params: identifier=%s, itemType=%s, gender=%s^0",
                tostring(identifier), tostring(itemType), tostring(gender)))
        end
        return {}
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] GetAllPurchases: identifier=%s, itemType=%s, gender=%s^0",
                identifier, itemType, gender))
        end

        local purchases = KVPStorage.GetGearPurchases(identifier, itemType, gender)

        if purchases and #purchases > 0 then
            if Config.Debug then
                print(string.format("^2[Sport Hub Storage KVP] Retrieved %d purchased designs^0", #purchases))
                for i, purchase in ipairs(purchases) do
                    print(string.format("^2  - Purchase %d: texture_id=%d, is_equipped=%d^0",
                        i, purchase.texture_id, purchase.is_equipped))
                end
            end
            return purchases
        end

        -- ⚠️ NO PURCHASES FOUND - Enhanced diagnostic logging for KVP mode
        print(string.format("^3[Sport Hub Storage KVP] ⚠️ No purchases found for identifier: %s^0", identifier))
        print(string.format("^3[Sport Hub Storage KVP] ⚠️ Searched: item_type='%s', gender='%s'^0", itemType, gender))

        -- Check if this identifier has ANY KVP data at all
        local key = string.format("sporthub:%s:gear_purchases", identifier)
        local rawData = GetResourceKvpString(key)

        if rawData then
            local allData = json.decode(rawData)
            if allData then
                local count = 0
                for k in pairs(allData) do count = count + 1 end
                if count > 0 then
                    print(string.format("^3[Sport Hub Storage KVP] This identifier HAS %d purchases, but not for %s/%s:^0", count, itemType, gender))
                    for k, v in pairs(allData) do
                        print(string.format("^3  - Found: %s (texture=%d)^0", k, v.texture_id))
                    end
                else
                    print("^3[Sport Hub Storage KVP] KVP key exists but has no data^0")
                end
            end
        else
            print("^3[Sport Hub Storage KVP] No KVP data exists for this identifier^0")
            print("^3[Sport Hub Storage KVP] Player may not have purchased anything yet, or identifier changed^0")
        end

        return {}
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    if not MySQL then
        print("^1[Sport Hub Storage] MySQL not available in GetAllPurchases!^0")
        return {}
    end

    if Config.Debug then
        print(string.format("^6[Sport Hub Storage] Querying purchases: identifier=%s, itemType=%s, gender=%s^0",
            identifier, itemType, gender))
    end

    local result = MySQL.Sync.fetchAll(
        'SELECT texture_id, is_equipped FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ? ORDER BY purchased_at ASC',
        {identifier, itemType, gender}
    )

    if result and #result > 0 then
        if Config.Debug then
            print(string.format("^2[Sport Hub Storage] Retrieved %d purchased designs for %s | %s | %s^0",
                #result, identifier, itemType, gender))
            for i, purchase in ipairs(result) do
                local equipped = type(purchase.is_equipped) == "boolean" and (purchase.is_equipped and 1 or 0) or purchase.is_equipped
                print(string.format("^2  - Purchase %d: texture_id=%d, is_equipped=%d^0",
                    i, purchase.texture_id, equipped))
            end
        end
        return result
    end

    -- ⚠️ NO PURCHASES FOUND - Enhanced diagnostic logging (always shown)
    -- This helps diagnose why purchases aren't loading on some servers
    print(string.format("^3[Sport Hub Storage] ⚠️ No purchases found for identifier: %s^0", identifier))
    print(string.format("^3[Sport Hub Storage] ⚠️ Searched: item_type='%s', gender='%s'^0", itemType, gender))

    -- Check if this identifier has ANY purchases at all
    local anyPurchases = MySQL.Sync.fetchAll(
        'SELECT item_type, gender, texture_id FROM sport_hub_purchases WHERE identifier = ? LIMIT 5',
        {identifier}
    )

    if anyPurchases and #anyPurchases > 0 then
        print(string.format("^3[Sport Hub Storage] This identifier HAS %d+ purchases, but not for %s/%s:^0", #anyPurchases, itemType, gender))
        for _, p in ipairs(anyPurchases) do
            print(string.format("^3  - Found: %s/%s/texture_%d^0", p.item_type, p.gender, p.texture_id))
        end
    else
        -- Check if there are ANY purchases in the database at all
        local totalRows = MySQL.Sync.fetchAll('SELECT COUNT(*) as cnt FROM sport_hub_purchases', {})
        local total = totalRows and totalRows[1] and totalRows[1].cnt or 0

        if total > 0 then
            -- There are purchases but not for this identifier - show samples
            print(string.format("^1[Sport Hub Storage] ❌ This identifier has NO purchases! But database has %d total rows.^0", total))
            print("^1[Sport Hub Storage] ❌ IDENTIFIER MISMATCH DETECTED! Showing sample identifiers from database:^0")

            local samples = MySQL.Sync.fetchAll('SELECT DISTINCT identifier FROM sport_hub_purchases LIMIT 3', {})
            for _, s in ipairs(samples or {}) do
                print(string.format("^1  - DB has: %s^0", s.identifier))
            end
            print(string.format("^1  - Current: %s^0", identifier))
            print("^1[Sport Hub Storage] ❌ FIX: Set Config.IdentifierType = \"license\" in config.lua^0")
        else
            print("^3[Sport Hub Storage] Database table is empty - no purchases have been saved yet^0")
        end
    end

    return {}
end

---Set a design as equipped (equip functionality - no charge)
---@param identifier string Player identifier
---@param itemType string Item type
---@param gender string Gender
---@param textureId number Texture ID to equip
---@return boolean Success
function SetEquippedDesign(identifier, itemType, gender, textureId)
    if not identifier or not itemType or not gender or textureId == nil then
        return false
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] SetEquippedDesign: identifier=%s, itemType=%s, gender=%s, textureId=%d^0",
                identifier, itemType, gender, textureId))
        end

        local success = KVPStorage.SetEquippedGear(identifier, itemType, gender, textureId)

        if Config.Debug then
            if success then
                print(string.format("^2[Sport Hub Storage KVP] Equipped design: texture=%d^0", textureId))
            else
                print(string.format("^1[Sport Hub Storage KVP] Failed to equip design (not owned?)^0"))
            end
        end

        return success
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    if not MySQL then
        return false
    end

    -- First check if player owns this design
    local result = MySQL.Sync.fetchAll(
        'SELECT id FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ? AND texture_id = ? LIMIT 1',
        {identifier, itemType, gender, textureId}
    )

    if not result or not result[1] then
        if Config.Debug then
            print(string.format("^1[Sport Hub Storage] Player %s doesn't own design %d for %s/%s^0",
                identifier, textureId, itemType, gender))
        end
        return false
    end

    -- Unequip all other designs for this category
    MySQL.Sync.execute(
        'UPDATE sport_hub_purchases SET is_equipped = 0 WHERE identifier = ? AND item_type = ? AND gender = ?',
        {identifier, itemType, gender}
    )

    -- Equip the selected design
    local success = MySQL.Sync.execute(
        'UPDATE sport_hub_purchases SET is_equipped = 1 WHERE identifier = ? AND item_type = ? AND gender = ? AND texture_id = ?',
        {identifier, itemType, gender, textureId}
    )

    if Config.Debug then
        if success then
            print(string.format("^2[Sport Hub Storage] Equipped design: %s | %s | %s | texture=%d^0",
                identifier, itemType, gender, textureId))
        else
            print(string.format("^1[Sport Hub Storage] Failed to equip design^0"))
        end
    end

    return success
end

---Get the currently equipped design for a player in a specific category
---@param identifier string Player identifier
---@param itemType string Item type (e.g., "hoverboard", "scooter")
---@param gender string Gender/style (e.g., "ultra", "retro", "male", "female", "unisex")
---@return table|nil The equipped design data or nil if none equipped
function GetEquippedDesign(identifier, itemType, gender)
    if not identifier or not itemType or not gender then
        return nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] GetEquippedDesign: identifier=%s, itemType=%s, gender=%s^0",
                identifier, itemType, gender))
        end

        local equipped = KVPStorage.GetEquippedGear(identifier, itemType, gender)

        if equipped then
            if Config.Debug then
                print(string.format("^2[Sport Hub Storage KVP] Found equipped design: texture=%d^0", equipped.texture_id))
            end
            return equipped
        end

        if Config.Debug then
            print(string.format("^3[Sport Hub Storage KVP] No equipped design found for: %s/%s^0", itemType, gender))
        end
        return nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    if not MySQL then
        return nil
    end

    local result = MySQL.Sync.fetchAll(
        'SELECT * FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND gender = ? AND is_equipped = 1 LIMIT 1',
        {identifier, itemType, gender}
    )

    if result and result[1] then
        if Config.Debug then
            print(string.format("^2[Sport Hub] Found equipped design: %s/%s/texture_%d^0",
                itemType, gender, result[1].texture_id))
        end
        return result[1]
    end

    if Config.Debug then
        print(string.format("^3[Sport Hub] No equipped design found for: %s/%s^0", itemType, gender))
    end

    return nil
end

---Get the equipped purchase for a player across ALL styles (returns texture_id AND style)
---This is useful for items with multiple styles (hoverboard, rollers) when you don't know which style is equipped
---@param identifier string Player identifier
---@param itemType string Item type (e.g., "hoverboard", "scooter")
---@return number|nil, string|nil texture_id, gender/style (or nil if none equipped)
function GetEquippedPurchase(identifier, itemType)
    if not identifier or not itemType then
        return nil, nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] GetEquippedPurchase: identifier=%s, itemType=%s^0",
                identifier, itemType))
        end

        -- Get all purchases for this item type and find equipped one
        local allPurchases = KVPStorage.GetGearPurchases(identifier, itemType, nil)
        for _, purchase in pairs(allPurchases) do
            if purchase.is_equipped == 1 then
                if Config.Debug then
                    print(string.format("^2[Sport Hub Storage KVP] Found equipped purchase: %s/%s/texture_%d^0",
                        itemType, purchase.gender, purchase.texture_id))
                end
                return purchase.texture_id, purchase.gender
            end
        end

        if Config.Debug then
            print(string.format("^3[Sport Hub Storage KVP] No equipped purchase found for %s^0", itemType))
        end
        return nil, nil
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    if not MySQL then
        return nil, nil
    end

    -- Find equipped design across ALL styles
    local result = MySQL.Sync.fetchAll(
        'SELECT texture_id, gender FROM sport_hub_purchases WHERE identifier = ? AND item_type = ? AND is_equipped = 1 LIMIT 1',
        {identifier, itemType}
    )

    if result and result[1] then
        if Config.Debug then
            print(string.format("^2[Sport Hub] GetEquippedPurchase: %s/%s/texture_%d^0",
                itemType, result[1].gender, result[1].texture_id))
        end
        return result[1].texture_id, result[1].gender
    end

    if Config.Debug then
        print(string.format("^3[Sport Hub] No equipped purchase found for %s | %s^0",
            identifier, itemType))
    end
    return nil, nil
end

---Remove ALL purchases for a player (for dev/testing purposes)
---@param identifier string Player identifier
---@return boolean Success
function RemoveAllPurchasesForPlayer(identifier)
    if not identifier then
        return false
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 💾 KVP STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════
    if not Config.UseSQLStorage then
        if Config.Debug then
            print(string.format("^5[Sport Hub Storage KVP] RemoveAllPurchasesForPlayer: %s^0", identifier))
        end

        -- Clear the gear purchases key for this player
        local key = string.format("sporthub:%s:gear_purchases", identifier)
        DeleteResourceKvp(key)

        if Config.Debug then
            print(string.format("^2[Sport Hub Storage KVP] Removed all purchases for player: %s^0", identifier))
        end
        return true
    end

    -- ═══════════════════════════════════════════════════════════════
    -- 🗄️ SQL STORAGE MODE
    -- ═══════════════════════════════════════════════════════════════

    if not MySQL then
        return false
    end

    local success = MySQL.Sync.execute(
        'DELETE FROM sport_hub_purchases WHERE identifier = ?',
        {identifier}
    )

    if Config.Debug then
        if success then
            print(string.format("^2[Sport Hub Storage] Removed all purchases for player: %s^0", identifier))
        else
            print(string.format("^1[Sport Hub Storage] Failed to remove purchases for player: %s^0", identifier))
        end
    end

    return success
end

-- ════════════════════════════════════════════════════════════════
-- 📡 SERVER CALLBACKS FOR PURCHASE DATA
-- ════════════════════════════════════════════════════════════════

---Client requests purchase data
RegisterNetEvent("sport-hub:server:getPurchase")
AddEventHandler("sport-hub:server:getPurchase", function(itemType, gender)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Received getPurchase request from player %d: itemType=%s, gender=%s^0",
                src, tostring(itemType), tostring(gender)))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            TriggerClientEvent("sport-hub:client:receivePurchase", src, itemType, gender, nil)
            return
        end

        -- ✅ Map Sport Hub style names to individual resource style names for database query
        local dbGender = gender
        if itemType == "hoverboard" then
            if gender == "ultra" then
                dbGender = "modern"
            elseif gender == "retro" then
                dbGender = "classic"
            end
            if Config.Debug and dbGender ~= gender then
                print(string.format("^3[Sport Hub Server] Mapped hoverboard style: %s → %s (for DB query)^0", gender, dbGender))
            end
        end

        local textureId = GetPurchase(identifier, itemType, dbGender)

        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Sending response to player %d (getPurchase for %s/%s): textureId=%s^0",
                src, itemType, gender, tostring(textureId)))
        end

        TriggerClientEvent("sport-hub:client:receivePurchase", src, itemType, gender, textureId)
    end)
end)

---Client saves purchase data
RegisterNetEvent("sport-hub:server:savePurchase")
AddEventHandler("sport-hub:server:savePurchase", function(itemType, gender, textureId)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Received savePurchase request from player %d: itemType=%s, gender=%s, textureId=%s^0",
                src, tostring(itemType), tostring(gender), tostring(textureId)))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            return
        end

        -- Save the purchase
        local success = SavePurchase(identifier, itemType, gender, textureId, true) -- true = set as equipped

        if success then
            -- ✅ Send updated purchase list back to client so NUI refreshes
            local purchases = GetAllPurchases(identifier, itemType, gender)

            if Config.Debug then
                print(string.format("^2[Sport Hub Server] Purchase saved! Sending %d purchases back to client^0", #purchases))
            end

            TriggerClientEvent("sport-hub:client:receiveAllPurchases", src, itemType, gender, purchases)
        end
    end)
end)

---Client requests ALL purchased designs for a category
RegisterNetEvent("sport-hub:server:getAllPurchases")
AddEventHandler("sport-hub:server:getAllPurchases", function(itemType, gender)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Received getAllPurchases request from player %d: itemType=%s, gender=%s^0",
                src, tostring(itemType), tostring(gender)))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            TriggerClientEvent("sport-hub:client:receiveAllPurchases", src, itemType, gender, {})
            return
        end

        -- ✅ Map Sport Hub style names to individual resource style names for database query
        local dbGender = gender
        if itemType == "hoverboard" then
            if gender == "ultra" then
                dbGender = "modern"
            elseif gender == "retro" then
                dbGender = "classic"
            end
            if Config.Debug and dbGender ~= gender then
                print(string.format("^3[Sport Hub Server] Mapped hoverboard style: %s → %s (for DB query)^0", gender, dbGender))
            end
        end

        local purchases = GetAllPurchases(identifier, itemType, dbGender)

        if Config.Debug then
            print(string.format("^6[Sport Hub Server] 📤 [%s] Sending %d purchases to player %d (getAllPurchases request for %s/%s)^0",
                os.date("%H:%M:%S"), #purchases, src, itemType, gender))
            for i, p in ipairs(purchases) do
                local equipped = type(p.is_equipped) == "boolean" and (p.is_equipped and 1 or 0) or p.is_equipped
                print(string.format("^6  Purchase %d: texture_id=%d, is_equipped=%d^0", i, p.texture_id, equipped))
            end
        end

        TriggerClientEvent("sport-hub:client:receiveAllPurchases", src, itemType, gender, purchases)
    end)
end)

---Fallback: Client requests saved design reload when sport starts
---This handles rare cases where database timeout causes design not to load
RegisterNetEvent("sporthub:reloadSavedDesign")
AddEventHandler("sporthub:reloadSavedDesign", function(itemType)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^5[Sport Hub Server] Fallback: Reload saved design request for %s from player %d^0",
                tostring(itemType), src))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            return
        end

        -- Define styles to check for each item type
        -- IMPORTANT: Items without styles use "unisex" in the database, NOT nil!
        local stylesToCheck = {
            skateboard = {"modern", "classic"},
            hoverboard = {"modern", "classic"},  -- DB uses modern/classic
            rollers = {"modern", "retro"},
            bmx = {"unisex"},  -- Single style items use "unisex"
            scooter = {"unisex"},
            ski = {"unisex"},
            iceskates = {"male", "female"},  -- Sex-based
            snowboard = {"unisex"}
        }

        local styles = stylesToCheck[itemType] or {"unisex"}

        -- Check each style for equipped design
        for _, style in ipairs(styles) do
            local textureId = GetPurchase(identifier, itemType, style)

            if textureId then
                -- Map DB style back to Sport Hub style names for hoverboard
                local returnStyle = style
                if itemType == "hoverboard" then
                    if style == "modern" then
                        returnStyle = "ultra"
                    elseif style == "classic" then
                        returnStyle = "retro"
                    end
                end

                if Config.Debug then
                    print(string.format("^2[Sport Hub Server] Fallback: Found equipped design for %s/%s: texture=%d^0",
                        itemType, tostring(style), textureId))
                end

                TriggerClientEvent("sporthub:client:applySavedDesign", src, itemType, returnStyle, textureId)
                return  -- Found equipped design, no need to check other styles
            end
        end

        if Config.Debug then
            print(string.format("^3[Sport Hub Server] Fallback: No equipped design found for %s^0", itemType))
        end
    end)
end)

---Client requests to equip a design (no charge - already owned)
RegisterNetEvent("sport-hub:server:equipDesign")
AddEventHandler("sport-hub:server:equipDesign", function(itemType, gender, textureId)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Received equipDesign request from player %d: itemType=%s, gender=%s, textureId=%d^0",
                src, tostring(itemType), tostring(gender), tostring(textureId)))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            ShowNotification(src, Config.Language.Info['error'], "error")
            TriggerClientEvent("sport-hub:client:equipResult", src, false)
            return
        end

        -- Equip the design in the database
        local success = SetEquippedDesign(identifier, itemType, gender, textureId)

        if success then
            -- Send success notification
            ShowNotification(src, "Design equipped successfully!", "success")

            -- Send updated purchase list to client so NUI shows EQUIPPED label
            local purchases = GetAllPurchases(identifier, itemType, gender)
            TriggerClientEvent("sport-hub:client:receiveAllPurchases", src, itemType, gender, purchases)

            if Config.Debug then
                print(string.format("^2[Sport Hub Server] ✅ Design equipped! Sending %d purchases to client^0", #purchases))
            end

            -- Tell client to equip result (this triggers individual resource events)
            TriggerClientEvent("sport-hub:client:equipResult", src, true, itemType, gender, textureId)
        else
            ShowNotification(src, "Failed to equip design. You may not own this design.", "error")
            TriggerClientEvent("sport-hub:client:equipResult", src, false)
        end
    end)
end)

---Client requests equipped design only (no fallback to non-equipped)
RegisterNetEvent("sport-hub:server:getEquippedDesign")
AddEventHandler("sport-hub:server:getEquippedDesign", function(itemType, gender)
    local src = source

    -- Use CreateThread to allow Wait() to work inside GetPlayerIdentifier
    CreateThread(function()
        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Received getEquippedDesign request from player %d: itemType=%s, gender=%s^0",
                src, tostring(itemType), tostring(gender)))
        end

        local identifier = GetPlayerIdentifier(src)

        if not identifier then
            if Config.Debug then
                print(string.format("^1[Sport Hub Storage] Could not get identifier for player %d^0", src))
            end
            TriggerClientEvent("sport-hub:client:receiveEquippedDesign", src, itemType, gender, nil)
            return
        end

        local textureId = GetEquippedDesign(identifier, itemType, gender)

        if Config.Debug then
            print(string.format("^6[Sport Hub Server] Sending equipped design to player %d (getEquippedDesign for %s/%s): textureId=%s^0",
                src, itemType, gender, tostring(textureId)))
        end

        TriggerClientEvent("sport-hub:client:receiveEquippedDesign", src, itemType, gender, textureId)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- 🔧 DEVELOPER COMMANDS
-- ═══════════════════════════════════════════════════════════════

---Command to remove all purchases for a player (dev/testing purposes)
RegisterCommand("removedesigns", function(source, args, rawCommand)
    local src = source

    -- Check if player has permission (adjust based on your framework)
    local hasPermission = false

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and QBCore.Functions.HasPermission(src, "admin") then
            hasPermission = true
        end
    elseif Config.Framework == "qbox" then
        -- Qbox uses ox_lib for permissions or ace permissions
        if IsPlayerAceAllowed(src, "command.removedesigns") then
            hasPermission = true
        else
            local Player = QBX:GetPlayer(src)
            if Player and Player.PlayerData.group == "admin" then
                hasPermission = true
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup() == "admin" then
            hasPermission = true
        end
    elseif Config.Framework == "vrp" then
        if vRP.hasPermission({vRP.getUserId({src}), "admin.permission"}) then
            hasPermission = true
        end
    elseif Config.Framework == "creative" then
        -- Add your creative permission check here
        hasPermission = true -- For now, allow anyone (change this!)
    elseif Config.Framework == "custom" then
        -- Enter your Framework Logic / References here.
    end

    if not hasPermission then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "You don't have permission to use this command!"}
        })
        return
    end

    if not args[1] then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 165, 0},
            multiline = true,
            args = {"Sport Hub", "Usage: /removedesigns [PlayerID]"}
        })
        return
    end

    local targetSrc = tonumber(args[1])
    if not targetSrc then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "Invalid PlayerID!"}
        })
        return
    end

    local identifier = GetPlayerIdentifier(targetSrc)
    if not identifier then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "Player not found or could not get identifier!"}
        })
        return
    end

    -- First, clean up any corrupted purchases
    if MySQL then
        MySQL.Sync.execute(
            'DELETE FROM sport_hub_purchases WHERE identifier = ? AND (item_type LIKE "%-style" OR gender = "last")',
            {identifier}
        )
    end

    local success = RemoveAllPurchasesForPlayer(identifier)

    if success then
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Sport Hub", string.format("✅ Removed all purchases for player %d (%s)", targetSrc, identifier)}
        })

        -- Notify the target player
        TriggerClientEvent('chat:addMessage', targetSrc, {
            color = {255, 165, 0},
            multiline = true,
            args = {"Sport Hub", "Your design purchases have been reset by an admin."}
        })
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "Failed to remove purchases! Check server console for errors."}
        })
    end
end, false)

---Command to clean up ALL corrupted purchases globally (admin only)
RegisterCommand("cleancorruptedpurchases", function(source, args, rawCommand)
    local src = source

    -- Check if player has permission
    local hasPermission = false

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and QBCore.Functions.HasPermission(src, "admin") then
            hasPermission = true
        end
    elseif Config.Framework == "qbox" then
        -- Qbox uses ox_lib for permissions or ace permissions
        if IsPlayerAceAllowed(src, "command.cleancorruptedpurchases") then
            hasPermission = true
        else
            local Player = QBX:GetPlayer(src)
            if Player and Player.PlayerData.group == "admin" then
                hasPermission = true
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup() == "admin" then
            hasPermission = true
        end
    elseif Config.Framework == "vrp" then
        if vRP.hasPermission({vRP.getUserId({src}), "Admin"}) then
            hasPermission = true
        end
    else
        hasPermission = IsPlayerAceAllowed(src, "command.cleancorruptedpurchases")
    end

    if not hasPermission then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "You don't have permission to use this command!"}
        })
        return
    end

    if MySQL then
        local result = MySQL.Sync.execute(
            'DELETE FROM sport_hub_purchases WHERE item_type LIKE "%-style" OR gender = "last"',
            {}
        )

        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"Sport Hub", string.format("✅ Removed %d corrupted purchase entries from database", result or 0)}
        })

        if Config.Debug then
            print(string.format("^2[Sport Hub] Admin %d cleaned up %d corrupted purchase entries^0", src, result or 0))
        end
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "MySQL not available!"}
        })
    end
end, false)

---Command to diagnose storage issues for a player (shows identifier and all purchases)
RegisterCommand("sporthubdiagnose", function(source, args, rawCommand)
    local src = source

    -- Check if player has permission
    local hasPermission = false

    if Config.Framework == "qb" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and QBCore.Functions.HasPermission(src, "admin") then
            hasPermission = true
        end
    elseif Config.Framework == "qbox" then
        if IsPlayerAceAllowed(src, "command.sporthubdiagnose") then
            hasPermission = true
        else
            local Player = QBX:GetPlayer(src)
            if Player and Player.PlayerData.group == "admin" then
                hasPermission = true
            end
        end
    elseif Config.Framework == "esx" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup() == "admin" then
            hasPermission = true
        end
    elseif Config.Framework == "vrp" then
        if vRP.hasPermission({vRP.getUserId({src}), "admin.permission"}) then
            hasPermission = true
        end
    else
        hasPermission = IsPlayerAceAllowed(src, "command.sporthubdiagnose")
    end

    if not hasPermission then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub", "You don't have permission to use this command!"}
        })
        return
    end

    local targetSrc = tonumber(args[1]) or src

    -- Get identifier info
    local identifier = GetPlayerIdentifier(targetSrc)

    print("^5═══════════════════════════════════════════════════════════════^0")
    print("^5[Sport Hub Diagnostic] Running diagnosis for player " .. targetSrc .. "^0")
    print("^5═══════════════════════════════════════════════════════════════^0")

    print(string.format("^3[Diagnostic] Framework: %s^0", Config.Framework or "none"))
    print(string.format("^3[Diagnostic] UseSQLStorage: %s^0", Config.UseSQLStorage and "true (SQL)" or "false (KVP)"))
    print(string.format("^3[Diagnostic] IdentifierType setting: %s^0", Config.IdentifierType or "auto"))

    -- Show framework-specific info for QB/QBox
    if Config.Framework == "qb" or Config.Framework == "qbox" then
        local Player = nil
        if Config.Framework == "qb" then
            Player = QBCore.Functions.GetPlayer(targetSrc)
        else
            Player = QBX:GetPlayer(targetSrc)
        end

        if Player then
            local citizenid = Player.PlayerData.citizenid
            local license = GetIdentifierByType(targetSrc, "license")
            print("^5[Diagnostic] === QB/QBox Specific Info ===^0")
            print(string.format("^6[Diagnostic] citizenid: %s^0", citizenid or "N/A"))
            print(string.format("^6[Diagnostic] FiveM license: %s^0", license or "N/A"))

            if (Config.IdentifierType or "auto") == "auto" then
                print("^3[Diagnostic] Currently using: citizenid (default for QB/QBox)^0")
                print("^3[Diagnostic] TIP: If purchases aren't loading after reconnect, try:^0")
                print("^3[Diagnostic]   Config.IdentifierType = \"license\" in config.lua^0")
            else
                print(string.format("^3[Diagnostic] Currently using: %s identifier type^0", Config.IdentifierType))
            end
        end
    end

    -- Show ALL available identifiers for this player
    local allIdentifiers = GetPlayerIdentifiers(targetSrc)
    if allIdentifiers and #allIdentifiers > 0 then
        print("^3[Diagnostic] ALL available FiveM identifiers for this player:^0")
        for _, id in ipairs(allIdentifiers) do
            print(string.format("^6  - %s^0", id))
        end
    else
        print("^3[Diagnostic] No identifiers found (player may not exist)^0")
    end

    if not identifier then
        print("^1[Diagnostic] ❌ Could not get identifier for player!^0")
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sport Hub Diagnostic", "❌ Could not get identifier for player " .. targetSrc}
        })
        return
    end

    print(string.format("^2[Diagnostic] ✅ Player Identifier: %s^0", identifier))
    print(string.format("^3[Diagnostic] Identifier length: %d characters^0", #identifier))

    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 255},
        multiline = true,
        args = {"Sport Hub Diagnostic", "Player " .. targetSrc .. " identifier: " .. identifier}
    })

    -- Check storage mode
    if not Config.UseSQLStorage then
        -- KVP MODE
        print("^5[Diagnostic] === KVP Storage Mode ===^0")

        local key = string.format("sporthub:%s:gear_purchases", identifier)
        local data = GetResourceKvpString(key)

        if data then
            local purchases = json.decode(data)
            local count = 0
            for _ in pairs(purchases) do count = count + 1 end

            print(string.format("^2[Diagnostic] KVP data found! %d total purchases^0", count))

            for purchaseKey, purchase in pairs(purchases) do
                print(string.format("^6  - %s: texture=%d, equipped=%d^0",
                    purchaseKey, purchase.texture_id, purchase.is_equipped))
            end

            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", string.format("✅ KVP has %d purchases for this player (check server console)", count)}
            })
        else
            print("^3[Diagnostic] No KVP data found for this player^0")
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 165, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", "⚠️ No KVP data found for this player"}
            })
        end
    else
        -- SQL MODE
        print("^5[Diagnostic] === SQL Storage Mode ===^0")

        if not MySQL then
            print("^1[Diagnostic] ❌ MySQL not available!^0")
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", "❌ MySQL not available!"}
            })
            return
        end

        -- Check if table exists
        local tableCheck = MySQL.Sync.fetchAll("SHOW TABLES LIKE 'sport_hub_purchases'", {})
        if not tableCheck or #tableCheck == 0 then
            print("^1[Diagnostic] ❌ Table 'sport_hub_purchases' does not exist!^0")
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", "❌ Table 'sport_hub_purchases' does not exist! Run SQL install."}
            })
            return
        end

        print("^2[Diagnostic] ✅ Table 'sport_hub_purchases' exists^0")

        -- Get all purchases for this player
        local purchases = MySQL.Sync.fetchAll(
            'SELECT * FROM sport_hub_purchases WHERE identifier = ? ORDER BY item_type, gender',
            {identifier}
        )

        if purchases and #purchases > 0 then
            print(string.format("^2[Diagnostic] ✅ Found %d purchases in database^0", #purchases))

            for i, p in ipairs(purchases) do
                local equipped = type(p.is_equipped) == "boolean" and (p.is_equipped and 1 or 0) or p.is_equipped
                print(string.format("^6  %d: %s/%s/texture_%d (equipped=%d)^0",
                    i, p.item_type, p.gender, p.texture_id, equipped))
            end

            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", string.format("✅ Found %d purchases in database (check server console for details)", #purchases)}
            })
        else
            print("^3[Diagnostic] ⚠️ No purchases found in database for this identifier^0")

            -- Check if there are ANY purchases in the table
            local totalPurchases = MySQL.Sync.fetchAll('SELECT COUNT(*) as count FROM sport_hub_purchases', {})
            local total = totalPurchases and totalPurchases[1] and totalPurchases[1].count or 0

            print(string.format("^3[Diagnostic] Total rows in sport_hub_purchases table: %d^0", total))

            if total > 0 then
                -- Show some sample identifiers
                local samples = MySQL.Sync.fetchAll(
                    'SELECT DISTINCT identifier FROM sport_hub_purchases LIMIT 5',
                    {}
                )
                print("^3[Diagnostic] Sample identifiers in database:^0")
                for _, s in ipairs(samples) do
                    print(string.format("^3  - %s^0", s.identifier))
                end
            end

            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 165, 0},
                multiline = true,
                args = {"Sport Hub Diagnostic", string.format("⚠️ No purchases found for this player. Table has %d total rows. Check server console.", total)}
            })
        end
    end

    print("^5═══════════════════════════════════════════════════════════════^0")
    print("^5[Sport Hub Diagnostic] Diagnosis complete^0")
    print("^5═══════════════════════════════════════════════════════════════^0")

end, false)

-- ═══════════════════════════════════════════════════════════════
-- 📤 EXPORTS (For use by other resources)
-- ═══════════════════════════════════════════════════════════════

exports('GetPlayerMoney', GetPlayerMoney)
exports('RemoveMoney', RemoveMoney)
exports('GiveItem', GiveItem)
exports('RemoveItem', RemoveItem)
exports('RemoveAllItems', RemoveAllItems)
exports('HasItem', HasItem)
exports('ShowNotification', ShowNotification)
exports('GetPlayerIdentifier', GetPlayerIdentifier)
exports('SavePurchase', SavePurchase)
exports('GetPurchase', GetPurchase)
exports('GetAllPurchases', GetAllPurchases)
exports('SetEquippedDesign', SetEquippedDesign)
exports('GetEquippedDesign', GetEquippedDesign)
exports('GetEquippedPurchase', GetEquippedPurchase)

-- ═══════════════════════════════════════════════════════════════
-- 🎣 INDIVIDUAL RESOURCE PURCHASE HOOKS - REMOVED
-- Purchase list is now sent directly in store-purchase.lua after save
-- Individual resource success events have corrupted parameters, so we ignore them
-- ═══════════════════════════════════════════════════════════════

if Config.Debug then
    print("^2[Sport Hub] Framework bridge loaded successfully^0")
    print("^2[Sport Hub] Framework: " .. (Config.Framework or "none") .. "^0")
end
