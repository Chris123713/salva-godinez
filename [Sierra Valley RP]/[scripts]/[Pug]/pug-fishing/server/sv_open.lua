tokens = {}
function ShowItemBoxItem(Item, type, amount, src)
    if Framework == "QBCore" then
        TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items[Item], type, amount or 1)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, FWork.Shared.Items[Item], type, amount or 1)
    end
end
function GetFishingRep(Player)
    local CitizenId = Player.PlayerData.citizenid
    local Result = MySQL.query.await('SELECT * FROM pug_fishing WHERE citizenid = ?', {CitizenId})
    if Result[1] then
        return Result[1].fishingrep
    else
        local PlayerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        if PlayerName then
            local success, err = pcall(function()
                MySQL.insert.await('INSERT INTO pug_fishing (citizenid, fishingrep, name) VALUES (?,?,?)', {
                    CitizenId, 0, PlayerName
                })
            end)

            if not success then
                print("^1[ERROR][FISHING] Failed to insert new player into pug_fishing table.")
                print("^1Likely cause: old pug_fishing table is missing the 'name' column.")
                print("^3Fix: DROP the pug_fishing table in your database and restart the server.")
                print("^8Error: " .. tostring(err))
            end
        else
            print("^1[ERROR] ^2COULD NOT FIND PLAYER'S NAME IN FISHING")
        end
        return 0
    end
end

-- SAVING THIS HERE FOR IF TOO MANY ESX PEOPLE DONT UNDERSTAND THE PRINT ABOVE!
-- function GetFishingRep(Player)
--     local CitizenId = Player.PlayerData.citizenid
--     local Result = MySQL.query.await('SELECT * FROM pug_fishing WHERE citizenid = ?', {CitizenId})
--     if Result[1] then
--         return Result[1].fishingrep
--     else
--         local PlayerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
--         if PlayerName then
--             local success, err = pcall(function()
--                 MySQL.insert.await('INSERT INTO pug_fishing (citizenid, fishingrep, name) VALUES (?,?,?)', {
--                     CitizenId, 0, PlayerName
--                 })
--             end)

--             if not success and tostring(err):find("Unknown column 'name'") and Framework == "ESX" then
--                 print("^1[ERROR][FISHING] 'name' column missing in pug_fishing. Rebuilding table...")

--                 -- Drop and recreate the table safely
--                 MySQL.query.await("DROP TABLE IF EXISTS pug_fishing")
--                 MySQL.query([[
--                     CREATE TABLE IF NOT EXISTS `pug_fishing` (
--                     `id`                INT(11)      NOT NULL AUTO_INCREMENT,
--                     `citizenid`         VARCHAR(50)  NOT NULL,
--                     `fishcaught`        JSON         NOT NULL DEFAULT ('[]'),
--                     `boats`             JSON         NOT NULL DEFAULT ('[]'),
--                     `skills`            JSON         NOT NULL DEFAULT ('{}'),
--                     `daily_challenges`  JSON         NOT NULL DEFAULT ('{}'),
--                     `weekly_challenges` JSON         NOT NULL DEFAULT ('{}'),
--                     `wins`              INT(11)      NOT NULL DEFAULT 0,
--                     `fishingrep` int(11) DEFAULT NULL,
--                     `name`              VARCHAR(100) DEFAULT NULL,
--                     PRIMARY KEY (`id`),
--                     UNIQUE KEY `unique_citizenid` (`citizenid`)
--                     ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
--                 ]])

--                 print("^2Successfully recreated pug_fishing table. Retrying insert...")
--                 Wait(1000)
--                 MySQL.insert.await('INSERT INTO pug_fishing (citizenid, fishingrep, name) VALUES (?,?,?)', {
--                     CitizenId, 0, PlayerName
--                 })
--             elseif not success then
--                 print("^1[ERROR][FISHING] Insert failed: " .. tostring(err))
--             end
--         else
--             print("^1[ERROR] ^2COULD NOT FIND PLAYER'S NAME IN FISHING")
--         end
--         return 0
--     end
-- end


function SetNewFishingRep(Player, NewRep)
    local CitizenId = Player.PlayerData.citizenid
    local Result = MySQL.query.await('SELECT * FROM pug_fishing WHERE citizenid = ?', {CitizenId})
    if Result[1] then
        MySQL.update('UPDATE pug_fishing SET fishingrep = ? WHERE citizenid = ?', { NewRep, CitizenId })
    else
        local PlayerName = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
        if PlayerName then
            MySQL.insert.await('INSERT INTO pug_fishing (citizenid, fishingrep, name) VALUES (?,?,?)', {
                CitizenId, NewRep, PlayerName
            })
        else
            print("^1[ERROR] ^2COULD NOT FIND PLAYERS NAME IN FISHING")
        end
    end
end
function PugFindPlayersByItentifier(identifier)
    local players = GetPlayers()
    for _, v in ipairs(players) do
        local playerIdentifier = FWork.GetIdentifier(v)
        if playerIdentifier == identifier then
            if Config.Debug then
                print("player found:", v)
            end
            return v
        end
    end
end
function SVAddItem(playerId, item, amount, info)
    amount = amount or 1
    info = info or nil
    local inv = Config.InventoryType

    if inv == "ox_inventory" then
        exports.ox_inventory:AddItem(playerId, item, amount, info)
    elseif inv == "qb-inventory" or inv == "ps-inventory" or inv == "qs-inventory" or inv == "lj-inventory" then
        exports[inv]:AddItem(playerId, item, amount, false, info)
        ShowItemBoxItem(item, "add", amount, playerId)
    elseif inv == "core_inventory" then
        exports["core_inventory"]:addItem(playerId, item, amount)

        if info then
            Wait(100)
            local inventory = exports["core_inventory"]:getInventory(playerId)
            if inventory then
                for slot, itemData in pairs(inventory) do
                    if itemData.name == item then
                        exports["core_inventory"]:setItemData(playerId, slot, info)
                        break
                    end
                end
            end
        end
    elseif inv == "ak47_inventory" then
        exports["ak47_inventory"]:AddItem(playerId, item, amount, nil, info)

    elseif inv == "tgiann-inventory" then
        exports["tgiann-inventory"]:AddItem(playerId, item, amount)

        if info then
            Wait(100)
            local invData = exports["tgiann-inventory"]:GetInventory(playerId)
            if invData then
                for slot, data in pairs(invData) do
                    if data.name == item then
                        exports["tgiann-inventory"]:SetItemData(playerId, item, slot, info)
                        break
                    end
                end
            end
        end
    elseif inv == "codem-inventory" then
        exports['codem-inventory']:AddItem(playerId, item, amount, false, info)
    elseif Framework == "ESX" then
        local xPlayer = FWork.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.addInventoryItem(item, amount, false, info)
        end

    elseif Framework == "QBCore" then
        local xPlayer = FWork.Functions.GetPlayer(playerId)
        if xPlayer then
            xPlayer.Functions.AddItem(item, amount, nil, info)
        end
    end
end

function SVRemoveItem(playerId, item, amount)
    amount = amount or 1
    local inv = Config.InventoryType

    if inv == "ox_inventory" then
        exports.ox_inventory:RemoveItem(playerId, item, amount)

    elseif inv == "qb-inventory" or inv == "ps-inventory" or inv == "qs-inventory" or inv == "lj-inventory" then
        exports[inv]:RemoveItem(playerId, item, amount)

    elseif inv == "core_inventory" then
        exports["core_inventory"]:removeItem(playerId, item, amount)

    elseif inv == "ak47_inventory" then
        exports["ak47_inventory"]:RemoveItem(playerId, item, amount)

    elseif inv == "tgiann-inventory" then
        exports["tgiann-inventory"]:RemoveItem(playerId, item, amount)

    elseif inv == "codem-inventory" then
        exports["codem-inventory"]:RemoveItem(playerId, item, amount)

    elseif Framework == "ESX" then
        local xPlayer = FWork.GetPlayerFromId(playerId)
        if xPlayer then
            xPlayer.removeInventoryItem(item, amount)
        end

    elseif Framework == "QBCore" then
        local xPlayer = FWork.Functions.GetPlayer(playerId)
        if xPlayer then
            xPlayer.Functions.RemoveItem(item, amount)
        end
    end
end


function SVHasItem(playerId, item, amount, returnAmount)
    amount = amount or 1
    local inv = Config.InventoryType

    -- ox_inventory
    if inv == "ox_inventory" then
        local count = exports.ox_inventory:GetItemCount(playerId, item)
        return returnAmount and count or (count >= amount)
    end

    -- ps-inventory / lj-inventory
    if inv == "ps-inventory" or inv == "lj-inventory" then
        if returnAmount then
            local info = exports[inv]:GetItemByName(playerId, item)
            return info and info.amount or 0
        else
            return exports[inv]:HasItem(playerId, item, amount)
        end
    end

    -- qs-inventory 
    if inv == "qs-inventory" then
        local totalAmount = exports[inv]:GetItemTotalAmount(playerId, item)
        return returnAmount and (totalAmount or 0) or (totalAmount and totalAmount >= amount)
    end

    -- core_inventory
    if inv == "core_inventory" then
        if returnAmount then
            local data = exports["core_inventory"]:getItem(playerId, item)
            return data and data.amount or 0
        else
            return exports["core_inventory"]:hasItem(playerId, item, amount)
        end
    end

    -- ak47_inventory
    if inv == "ak47_inventory" then
        local amt = exports[inv]:GetAmount(playerId, item)
        return returnAmount and amt or (amt >= amount)
    end

    -- tgiann-inventory
    if inv == "tgiann-inventory" then
        if returnAmount then
            local data = exports[inv]:GetItem(playerId, item)
            return data and data.amount or 0
        else
            return exports[inv]:HasItem(playerId, item, amount)
        end
    end

    -- codem-inventory
    if inv == "codem-inventory" then
        if returnAmount then
            return exports["codem-inventory"]:GetItemsTotalAmount(playerId, item)
        else
            local itemData = exports["codem-inventory"]:HasItem(playerId, item, amount)
            return itemData ~= nil
        end
    end
    if Config.Debug then
        print("^2NO THIRD PARTY INVENTORY FOUND")
    end

    -- ESX fallback
    if Framework == "ESX" then
        local Player = FWork.GetPlayerFromId(playerId)
        if Player then
            local data = Player.getInventoryItem(item)
            local count = data and data.count or 0
            return returnAmount and count or (count >= amount)
        end
        return returnAmount and 0 or false
    else
        -- QBCore-style fallback
        local data = Config.FrameworkFunctions.GetItemByName(playerId, item, amount)
        local count = data and data.amount or 0
        return returnAmount and count or (count >= amount)
    end

    print("[WARN] SVHasItem: inventory type '"..tostring(inv).."' not recognized, returning false.")
    return returnAmount and 0 or false
end

local function ShowItemLable(Item)
    if Framework == "QBCore" then
        if FWork.Shared.Items[Item] then
            return FWork.Shared.Items[Item].label
        else
            return Item
        end
    else
        return Item
    end
end
local function GetRankInfoFromXP(xp)
    local level = math.floor((xp / 1000) * 100)
    if level > 100 then level = 100 end

    for set, v in ipairs(Config.XPRanks) do
        if xp >= v.min and xp <= v.max or xp >= v.min and tonumber(set) == 8 then
            local range = v.max - v.min
            local progress = math.floor(((xp - v.min) / range) * 100)
            progress = tostring(progress) ~= "inf" and progress or 100
            return {
                title = v.rank,
                level = level,
                percent = progress
            }
        end
    end

    return {
        title = "Unknown",
        level = level,
        percent = 0
    }
end
local function GetRankIndex(rankTitle)
    for i, v in ipairs(Config.XPRanks) do
        if v.rank == rankTitle then
            return i
        end
    end
    return -1
end

if Framework == "QBCore" then
    FWork.Functions.CreateUseableItem("fishingrod", function(source)
        local src = source
        TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod")
    end)
    FWork.Functions.CreateUseableItem("fishingrod2", function(source)
        local src = source
        TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod2")
    end)
    FWork.Functions.CreateUseableItem("fishingrod3", function(source)
        local src = source
        TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod3")
    end)
    FWork.Functions.CreateUseableItem("fishinglure", function(source)
        local src = source
        TriggerClientEvent("Pug:client:StartFishing", src, "fishinglure")
    end)
    FWork.Functions.CreateUseableItem("fishinglure2", function(source)
        local src = source
        TriggerClientEvent("Pug:client:StartFishing", src, "fishinglure2")
    end)
    FWork.Functions.CreateUseableItem(Config.ChestItem, function(source)
        local src = source
        TriggerClientEvent("Pug:client:OpenTreasureChest", src, Config.ChestItem)
    end)
    FWork.Functions.CreateUseableItem("bottlemap", function(source)
        local src = source
        local Player = Config.FrameworkFunctions.GetPlayer(src)
        SVRemoveItem(src, "bottlemap", 1)
        TriggerClientEvent("Pug:client:Openbottlemap", src, "bottlemap")
    end)
    FWork.Functions.CreateUseableItem("treasuremap", function(source)
        local src = source
        TriggerClientEvent("Pug:client:UseTreasureMap", src, "treasuremap")
    end)
    FWork.Functions.CreateUseableItem("fishingtrowl", function(source)
        local src = source
        TriggerClientEvent("Pug:client:DigDirtWithTrowllFishing", src)
    end)
    FWork.Functions.CreateUseableItem("fishingfireplace", function(source)
        local src = source
        TriggerClientEvent("Pug:client:PlaceFishingFirePlace", src)
    end)
    FWork.Functions.CreateUseableItem("fishinganchor", function(source)
        local src = source
        TriggerClientEvent("Pug:client:UseAnchor", src)
    end)
    FWork.Functions.CreateUseableItem("fishinglog", function(source)
        local src = source
        TriggerClientEvent("Pug:client:OpenFishingLog", src)
    end)
    FWork.Functions.CreateUseableItem("cookedfish", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "cookedfish")
    end)
    FWork.Functions.CreateUseableItem("perfectlycookedfish", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "perfectlycookedfish")
    end)
     FWork.Functions.CreateUseableItem("cookedcrab", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "cookedcrab")
    end)
elseif Framework == "ESX" then
    FWork.RegisterUsableItem("fishingrod", function(source)
		local src = source
		TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod")
	end)
    FWork.RegisterUsableItem("fishingrod2", function(source)
		local src = source
		TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod2")
	end)
    FWork.RegisterUsableItem("fishingrod3", function(source)
		local src = source
		TriggerClientEvent("Pug:client:StartFishing", src, "fishingrod3")
	end)
    FWork.RegisterUsableItem("fishinglure", function(source)
		local src = source
		TriggerClientEvent("Pug:client:StartFishing", src, "fishinglure")
	end)
    FWork.RegisterUsableItem("fishinglure2", function(source)
		local src = source
		TriggerClientEvent("Pug:client:StartFishing", src, "fishinglure")
	end)
    FWork.RegisterUsableItem(Config.ChestItem, function(source)
		local src = source
		TriggerClientEvent("Pug:client:OpenTreasureChest", src, Config.ChestItem)
	end)
    FWork.RegisterUsableItem("bottlemap", function(source)
        local src = source
        local Player = Config.FrameworkFunctions.GetPlayer(src)
        SVRemoveItem(src, "bottlemap", 1)
		TriggerClientEvent("Pug:client:Openbottlemap", src)
	end)
    FWork.RegisterUsableItem("treasuremap", function(source)
        local src = source
		TriggerClientEvent("Pug:client:UseTreasureMap", src)
	end)
    FWork.RegisterUsableItem("fishingtrowl", function(source)
        local src = source
		TriggerClientEvent("Pug:client:DigDirtWithTrowllFishing", src)
	end)
    FWork.RegisterUsableItem("fishingfireplace", function(source)
        local src = source
		TriggerClientEvent("Pug:client:PlaceFishingFirePlace", src)
	end)
    FWork.RegisterUsableItem("fishinganchor", function(source)
        local src = source
        TriggerClientEvent("Pug:client:UseAnchor", src)
	end)
    FWork.RegisterUsableItem("fishinglog", function(source)
        local src = source
        TriggerClientEvent("Pug:client:OpenFishingLog", src)
	end)
    FWork.RegisterUsableItem("cookedfish", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "cookedfish")
	end)
    FWork.RegisterUsableItem("perfectlycookedfish", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "perfectlycookedfish")
	end)
    FWork.RegisterUsableItem("cookedcrab", function(source)
        local src = source
        TriggerClientEvent("Pug:client:FishingEatFish", src, "cookedcrab")
	end)
end

local function GenerateNewToken(src)
    -- REPLACE THIS with your existing token generator
    return tostring(math.random(10000000, 99999999)) .. ":" .. tostring(os.time())
end

AddEventHandler("playerDropped", function()
    tokens[source] = nil
end)

RegisterNetEvent("Pug:Server:GiveFishingRep", function(rep, SentToken)
    local src = source

    if tokens[src] ~= SentToken then
        print("^1[CHEATER DETECTED] ^2 PLAYER WITH ID: "..src.." IS USING A LUA INJECTION MENU, THEY WERE KICKED FROM THE SERVER WITH A TROLL MESSAGE")
        DropPlayer(src, "Oops that was not meant to happen...")
        return
    end

    local Player
    if Framework == "QBCore" then
        Player = FWork.Functions.GetPlayer(src)
    else
        Player = Config.FrameworkFunctions.GetPlayer(src)
    end
    -- Rotate token AFTER success
    local newToken = GenerateNewToken(src)
    tokens[src] = newToken
    TriggerClientEvent("Pug:client:UpdateFishingToken", src, newToken)

    if not Player then return end

    local repAmount = tonumber(rep) or 0
    if repAmount <= 0 then
        return
    end

    local NewRep = (GetFishingRep(Player) + repAmount)
    SetNewFishingRep(Player, NewRep)
    TriggerClientEvent('Pug:client:FishingNotify', src, '+'..repAmount..Translations.error.success, 'success')
end)


Config.FrameworkFunctions.CreateCallback('Pug:server:GetPlayerHasItemFishing', function(source, cb, item, amount)
    local PlayerHasItem = SVHasItem(source, item, amount)
    cb(PlayerHasItem)
end)

Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:CanCraftRod', function(source, cb, item)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return cb(false) end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local stationCoords = vector3(Config.CrafingRodLocation.x, Config.CrafingRodLocation.y, Config.CrafingRodLocation.z)
    if #(playerCoords - stationCoords) > 5.0 then
        DropPlayer(src, "Cheating detected (nowhere near the crafting rod location)")
        return
    end

    local rodInfo = Config.CraftRods and Config.CraftRods[item]
    if not rodInfo then
        TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.invalid_config or "Invalid craft config.", 'error')
        return cb(false)
    end

    local price = tonumber(rodInfo.price or 0) or 0
    local cash = (Player.PlayerData and Player.PlayerData.money and Player.PlayerData.money.cash) or 0
    if cash < price then
        TriggerClientEvent('Pug:client:FishingNotify', src, (Translations.error.missing_cash or "Missing cash: $") .. (price - cash), 'error')
        return cb(false)
    end

    local reqs = rodInfo.requirements
    if reqs and type(reqs) == "table" and next(reqs) ~= nil then
        for _, req in ipairs(reqs) do
            local reqItem = req and req.item
            local reqAmt  = tonumber(req and req.amount or 1) or 1
            if reqItem and reqAmt > 0 then
                local haveCount = SVHasItem(src, reqItem, reqAmt, true)
                if haveCount < reqAmt then
                    local missing = reqAmt - haveCount
                    local label = ShowItemLable(reqItem)
                    TriggerClientEvent('Pug:client:FishingNotify', src,
                        (Translations.error.missing_item or "Missing item: ") .. tostring(missing) .. 'x ' .. tostring(label),
                        'error'
                    )
                    return cb(false)
                end
            end
        end
    end

    local CurrentFishingRep = GetFishingRep(Player)
    local rankInfo = GetRankInfoFromXP(CurrentFishingRep)
    local playerRankIndex = GetRankIndex(rankInfo.title)
    local requiredRankIndex = GetRankIndex(rodInfo.requiredRank)
    if playerRankIndex < requiredRankIndex then
        TriggerClientEvent('Pug:client:FishingNotify', src,
            (Translations.error.rank_too_low or "Rank too low: ") .. tostring(rodInfo.requiredRank) .. (Translations.error.rank_too_low2 or ""),
            'error'
        )
        return cb(false)
    end

    if Config.InventoryType == "ox_inventory" then
        if not exports.ox_inventory:CanCarryItem(src, item, 1) then
            TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.inventory_full or "Inventory full.", 'error')
            return cb(false)
        end
    end

    cb(true)
end)


RegisterNetEvent("Pug:server:IncrementFishCaught", function(fish, amount, SentToken)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)

    if tokens[src] ~= SentToken then print("^1[CHEATER DETECTED] ^2 PLAYER WITH ID: "..src.." IS USING A LUA INJECTION MENU, THEY WERE KICKED FROM THE SERVER WITH A TROLL MESSAGE") DropPlayer(src, "Oops that was not meant to happen...") end

    local newToken = GenerateNewToken(src) 
    tokens[src] = newToken
    TriggerClientEvent("Pug:client:UpdateFishingToken", src, newToken)
    
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await("SELECT fishcaught FROM pug_fishing WHERE citizenid = ?", { cid })
    local data = result[1] and json.decode(result[1].fishcaught or "[]") or {}

    data.total = (data.total or 0) + amount
    data[fish] = (data[fish] or 0) + amount

    MySQL.update("UPDATE pug_fishing SET fishcaught = ? WHERE citizenid = ?", { json.encode(data), cid })
end)

Config.FrameworkFunctions.CreateCallback("Pug:ServerCB:GetFishCaughtData", function(source, cb)
    local Player = Config.FrameworkFunctions.GetPlayer(source)
    if not Player then return cb({}, {}) end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await("SELECT name, citizenid, fishcaught FROM pug_fishing")
    local leaderboard = {}
    local myData = {}

    for _, row in ipairs(result) do
        local data = json.decode(row.fishcaught or "[]") or {}
        local total = data.total or 0

        if row.citizenid == cid then
            myData = data
        end

        table.insert(leaderboard, {
            name = row.name or "Unknown",
            total = total
        })
    end

    table.sort(leaderboard, function(a, b) return a.total > b.total end)
    cb(myData, leaderboard)
end)

Config.FrameworkFunctions.CreateCallback("Pug:ServerCB:GetFishLogbookData", function(source, cb)
    local Player = Config.FrameworkFunctions.GetPlayer(source)
    if not Player then return cb({}) end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await("SELECT fishcaught FROM pug_fishing WHERE citizenid = ?", { cid })
    
    if result[1] then
        local fishData = json.decode(result[1].fishcaught or "[]") or {}
        fishData.total = nil
        cb(fishData)
    else
        cb({})
    end
end)



Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:SellGems', function(source, cb, item)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return cb(false) end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local stationCoords = vector3(Config.GemsBuyingPedLoc.x, Config.GemsBuyingPedLoc.y, Config.GemsBuyingPedLoc.z)
    if #(playerCoords - stationCoords) > 5.0 then 
        DropPlayer(src, "Cheating detected (not near the selling location)")
        return
    end

    if not Config.SellGems[item] then
        DropPlayer(src, "Cheating detected (Invalid item: " .. tostring(item) .. ")")
        return
    end

    local amountOnPlayer = SVHasItem(src, item, 0, true)
    if amountOnPlayer < 1 then return cb(false) end

    local payout = amountOnPlayer * math.random(Config.SellGems[item].pricemin, Config.SellGems[item].pricemax)
    Player.AddMoney('cash', payout, "sell-gems")
    SVRemoveItem(src, item, amountOnPlayer)
    TriggerClientEvent('Pug:client:FishingNotify', src, Translations.success.soldfish .. amountOnPlayer .. 'x ' .. ShowItemLable(item) .. ' for $' .. payout, 'success')
    cb(true)
end)

Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:SellCrabs', function(source, cb, item)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return cb(false) end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local stationCoords = vector3(Config.CrabBuyingPedLoc.x, Config.CrabBuyingPedLoc.y, Config.CrabBuyingPedLoc.z)
    if #(playerCoords - stationCoords) > 5.0 then 
        DropPlayer(src, "Cheating detected (not near the selling location)")
        return
    end

    if not Config.SellCrabs[item] then
        DropPlayer(src, "Cheating detected (Invalid item: " .. tostring(item) .. ")")
        return
    end

    local amountOnPlayer = SVHasItem(src, item, 0, true)
    if amountOnPlayer < 1 then return cb(false) end

    local payout = amountOnPlayer * math.random(Config.SellCrabs[item].pricemin, Config.SellCrabs[item].pricemax)
    Player.AddMoney('cash', payout, "sell-crabs")
    SVRemoveItem(src, item, amountOnPlayer)
    TriggerClientEvent('Pug:client:FishingNotify', src, Translations.success.soldfish .. amountOnPlayer .. 'x ' .. ShowItemLable(item) .. ' for $' .. payout, 'success')
    cb(true)
end)



Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:SellFish', function(source, cb, item)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return cb(false) end

    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local isNearSellingSpot = false

    for _, data in pairs(Config.LifeGuardLocations) do
        local lifeguardCoord = vector3(data.LifeGuard.x, data.LifeGuard.y, data.LifeGuard.z)
        if #(playerCoords - lifeguardCoord) <= 5.0 then
            isNearSellingSpot = true
            break
        end
    end

    if not isNearSellingSpot then
        DropPlayer(src, "Cheating detected (not near any selling location)")
        return
    end

    if not Config.SellFishies[item] then
        DropPlayer(src, "Cheating detected (Invalid item: " .. tostring(item) .. ")")
        return
    end

    local amountOnPlayer = SVHasItem(src, item, 0, true)
    if amountOnPlayer < 1 then return cb(false) end

    local payout = amountOnPlayer * math.random(Config.SellFishies[item].pricemin, Config.SellFishies[item].pricemax)
    Player.AddMoney('cash', payout, "sell-fish")
    SVRemoveItem(src, item, amountOnPlayer)
    TriggerClientEvent('Pug:client:FishingNotify', src, Translations.success.soldfish .. amountOnPlayer .. 'x ' .. ShowItemLable(item) .. ' for $' .. payout, 'success')
    cb(true)
end)


RegisterServerEvent('Pug:server:FishingRemoveMoeny')
AddEventHandler('Pug:server:FishingRemoveMoeny', function(amount)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    Player.RemoveMoney('cash', amount, "buy-item")
end)

RegisterServerEvent('Pug:server:ToggleFish', function(bool, fish, amnt, SentToken)
    local src = source

    if tokens[src] ~= SentToken then
        print("^1[CHEATER DETECTED] ^2 PLAYER WITH ID: "..src.." IS USING A LUA INJECTION MENU, THEY WERE KICKED FROM THE SERVER WITH A TROLL MESSAGE")
        DropPlayer(src, "Oops that was not meant to happen...")
        return
    end

    local amount = tonumber(amnt) or 1

    if bool then
        if Config.InventoryType == "ox_inventory" then
            if exports.ox_inventory:CanCarryItem(src, fish, amount) then
                SVAddItem(src, fish, amount)
            else
                TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.inventory_full, 'error')
            end
        else
            SVAddItem(src, fish, amount)
            ShowItemBoxItem(fish, "add", amount, src)
        end
    else
        SVRemoveItem(src, fish, amount)
        ShowItemBoxItem(fish, "remove", amount, src)
    end

    local newToken = GenerateNewToken(src)
    tokens[src] = newToken

    TriggerClientEvent("Pug:client:UpdateFishingToken", src, newToken)
end)

RegisterNetEvent("Pug:server:RemoveFishingRep", function(Amount)
	local src = source
    local Player
    if Framework == "QBCore" then
        Player = FWork.Functions.GetPlayer(src)
    else
        Player = Config.FrameworkFunctions.GetPlayer(src)
    end
    if not Player then return end
    local FinalAmount = Amount or 0
	local NewRep = (GetFishingRep(Player) - FinalAmount)
    SetNewFishingRep(Player, NewRep)
	TriggerClientEvent('Pug:client:FishingNotify', src, Amount..Translations.error.minus_rep, 'error')
end)

RegisterServerEvent("Pug:Server:BuyFishingItem", function(item, amount)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local Amount = amount or 1
    
    
    if not Player then return end

    local itemData = nil
    for _, v in pairs(Config.FishingEquipment) do
        if v.item == item then
            itemData = v
            break
        end
    end

    if not itemData then
        DropPlayer(src, "Cheating detected (Invalid shop item: " .. tostring(item) .. ")")
        return
    end

    local price = itemData.price and itemData.price * Amount or 0
    local cash = Player.PlayerData.money.cash or 0

    if cash < price then
        TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.not_enough_money .. price .. ")", "error")
        return
    end

    Player.RemoveMoney('cash', price)
    local info = item == "fishinglure" and {uses = 1000} or item == "fishinglure2" and {uses = 1500} or nil
    SVAddItem(src, item, Amount, info)
    ShowItemBoxItem(item, "add", Amount, src)
    TriggerClientEvent('Pug:client:FishingNotify', src, Translations.success.purchased_item .. ShowItemLable(item) .. " for $" .. price, "success")
end)

local ActiveFireplaces = {}
RegisterServerEvent('Pug:server:AddFishingFirePlace', function(location, heading)
    local src = source

    local now = os.time()
    for i = #ActiveFireplaces, 1, -1 do
        if ActiveFireplaces[i].expires <= now then
            table.remove(ActiveFireplaces, i)
        end
    end

    if #ActiveFireplaces >= Config.MaxFireplaces then
        TriggerClientEvent("Pug:client:FishingNotify", src, Translations.error.max_fireplaces, "error")
        return
    end

    local entry = {
        coords = location,
        heading = heading,
        expires = now + (5 * 60)
    }
    table.insert(ActiveFireplaces, entry)

    TriggerClientEvent("Pug:client:AddFishingFirePlace", -1, location, heading)

    CreateThread(function()
        Wait(5 *60000)

        -- Has it been manually removed?
        for i = #ActiveFireplaces, 1, -1 do
            local dist = #(vector3(location.x, location.y, location.z) - vector3(ActiveFireplaces[i].coords.x, ActiveFireplaces[i].coords.y, ActiveFireplaces[i].coords.z))
            if dist < 1.5 then
                table.remove(ActiveFireplaces, i)
                TriggerClientEvent("Pug:client:RemoveFirePlace", -1, location)
                break
            end
        end
    end)
end)


RegisterServerEvent('Pug:server:RemoveFirePlaceForAll', function(location)
    for i = #ActiveFireplaces, 1, -1 do
        local dist = #(vector3(location.x, location.y, location.z) - vector3(ActiveFireplaces[i].coords.x, ActiveFireplaces[i].coords.y, ActiveFireplaces[i].coords.z))
        if dist < 1.5 then
            table.remove(ActiveFireplaces, i)
            break
        end
    end

    TriggerClientEvent("Pug:client:RemoveFirePlace", -1, location)
end)

Config.FrameworkFunctions.CreateCallback("Pug:ServerCB:GetFireplacePercent", function(source, cb, location)
    for _, fire in pairs(ActiveFireplaces) do
        if #(vector3(location.x, location.y, location.z) - vector3(fire.coords.x, fire.coords.y, fire.coords.z)) < 1.5 then
            local now = os.time()
            local remaining = fire.expires - now
            local total = 5 * 60
            local percent = math.max(0, math.floor((remaining / total) * 100))
            cb(percent)
            return
        end
    end
    cb(0)
end)

Config.FrameworkFunctions.CreateCallback("Pug:ServerCB:GetFishingSkills", function(source, cb)
    local Player = Config.FrameworkFunctions.GetPlayer(source)
    if not Player then return cb({}) end

    local FishRep = GetFishingRep(Player)

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await("SELECT skills FROM pug_fishing WHERE citizenid = ?", { cid })

    local rawSkills = result[1] and result[1].skills
    local skills = type(rawSkills) == "string" and json.decode(rawSkills) or {}
    cb(skills)
end)


RegisterServerEvent("Pug:Server:UpgradeFishingSkill", function(skillName)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await("SELECT skills FROM pug_fishing WHERE citizenid = ?", { cid })
    local rawSkills = result[1] and result[1].skills
    local skills = type(rawSkills) == "string" and json.decode(rawSkills) or {}

    local currentTier = skills[skillName] or 0
    local nextTier = currentTier + 1
    if nextTier > 3 then return end

    local req = Config.FishingSkillUpgrades[skillName] and Config.FishingSkillUpgrades[skillName][nextTier]
    if not req then return end

    local rep = GetFishingRep(Player)
    local cash = Player.PlayerData.money.cash or 0

    if rep < req.rep then
        TriggerClientEvent("Pug:client:FishingNotify", src, "Not enough fishing rep (need " .. req.rep .. ")", "error")
        return
    end

    if cash < req.cash then
        TriggerClientEvent("Pug:client:FishingNotify", src, "Not enough cash ($" .. req.cash .. " needed)", "error")
        return
    end

    Player.RemoveMoney('cash', req.cash)
    skills[skillName] = nextTier
    MySQL.update("UPDATE pug_fishing SET skills = ? WHERE citizenid = ?", { json.encode(skills), cid })

    TriggerClientEvent("Pug:client:FishingNotify", src, "Upgraded "..skillName.." to Tier "..nextTier, "success")
    TriggerClientEvent("Pug:client:SetFishingSkills", src, skills)
end)

RegisterServerEvent('Pug:server:FullyRemoveVehicleFishing', function(netid)
    local vehicle = NetworkGetEntityFromNetworkId(netid)
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end
end)

-- lb-phone email event support
RegisterNetEvent("Pug:Server:SendLbPhoneMailFishing", function(SubjectSent, MessageSent)
    local src = source
    local MyNumber = exports["lb-phone"]:GetEquippedPhoneNumber(src)

    if not MyNumber or type(MyNumber) ~= "string" then
        print(("Pug:Server:SendLbPhoneMailFishing - No valid phone number for %s"):format(src))
        return
    end

    local MyEmail = exports["lb-phone"]:GetEmailAddress(MyNumber)
    if not MyEmail or type(MyEmail) ~= "string" then
        print(("Pug:Server:SendLbPhoneMailFishing - No valid email for phone %s"):format(MyNumber))
        return
    end

    local success, id = exports["lb-phone"]:SendMail({
        to = MyEmail,
        subject = SubjectSent,
        message = MessageSent,
    })

    if not success then
        print(("Pug:Server:SendLbPhoneMailFishing - Failed to send mail to %s"):format(MyEmail))
    end
end)

-- yseries email event support
RegisterNetEvent("Pug:Server:SendyseriesMailFishing", function(SubjectSent, MessageSent)
    local src = source
    local receiverType = "source"
    local receiver = src

    exports["yseries"]:SendMail({
        title = SubjectSent,
        sender = "Fisher Joe",
        senderDisplayName = SubjectSent,
        content = MessageSent,
    }, receiverType, receiver)
end)

RegisterNetEvent("Pug:server:BulkIncrementTreasureFound", function(src, map, SentToken)
    if tokens[src] ~= SentToken then
        print("^1[CHEATER DETECTED]^7 PLAYER ID: "..src.." USING LUA INJECTION, KICKED")
        DropPlayer(src, "Oops that was not meant to happen...")
        return
    end

    local Player = Config.FrameworkFunctions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local row  = MySQL.query.await("SELECT fishcaught FROM pug_fishing WHERE citizenid = ?", { cid })
    local data = row[1] and json.decode(row[1].fishcaught or "{}") or {}

    data.total = (data.total or 0)

    for k, v in pairs(map) do
        data[k] = (data[k] or 0) + v
        data.total = data.total + v
    end

    MySQL.update("UPDATE pug_fishing SET fishcaught = ? WHERE citizenid = ?", { json.encode(data), cid })
end)


RegisterServerEvent('Pug:server:GiveChestItems', function(SentToken)
    local src = source

    if tokens[src] ~= SentToken then
        print("^1[CHEATER DETECTED]^7 PLAYER ID: "..src.." USING LUA INJECTION, KICKED")
        DropPlayer(src, "Oops that was not meant to happen...")
        return
    end

    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local itemsfound = false
    local cfg = Config.lootRwards.ChestRewards
    local rollMax = cfg.rollRange or 100

    local gained = {}

    for _, reward in ipairs(cfg.entries) do
        local roll = math.random(1, rollMax)
        if roll <= reward.chance then
            TriggerClientEvent('Pug:client:PlayPickupAnim', src)
            Wait(1000)
            itemsfound = true

            if reward.money then
                local amt = math.random(reward.min, reward.max)
                Player.AddMoney('cash', amt)
                gained.cash = (gained.cash or 0) + amt
            else
                local count = math.random(reward.min, reward.max)
                SVAddItem(src, reward.item, count, false)
                ShowItemBoxItem(reward.item, 'add', count, src)
                gained[reward.item] = (gained[reward.item] or 0) + count
            end
        end
    end

    local newToken = GenerateNewToken(src) 
    tokens[src] = newToken
    TriggerClientEvent("Pug:client:UpdateFishingToken", src, newToken)

    if next(gained) ~= nil then
        TriggerEvent("Pug:server:BulkIncrementTreasureFound", src, gained, newToken)
    end

    RandomizeChestLocation()

    if not itemsfound then
        TriggerClientEvent('Pug:client:FishingNotify', src, Translations.error.empty_chest, 'error')
    end

    TriggerClientEvent('Pug:client:DeleteOpenChest', src)
end)





if Framework == "QBCore" then
    FWork.Commands.Add("fishrep", "Check your reputation", {}, false, function(source, args)
        local Player = FWork.Functions.GetPlayer(source)
        if not Player then return end
        local fishing = GetFishingRep(Player)
        TriggerClientEvent('Pug:client:FishingNotify', Player.PlayerData.source, Translations.success.Fishing_reputation_is..fishing)
    end)
else
    FWork.RegisterCommand('fishrep', "admin", function(xPlayer, args, showError)
        local Player = Config.FrameworkFunctions.GetPlayer(xPlayer.source)
        if not Player then return end
        local fishing = GetFishingRep(Player)
        TriggerClientEvent('Pug:client:FishingNotify', xPlayer.source, Translations.success.Fishing_reputation_is..fishing)
    end,"admin")
end

Config.FrameworkFunctions.CreateCallback('Pug:ServerCB:GetFishingRep', function(source, cb)
    local Player
    if Framework == "QBCore" then
        Player = FWork.Functions.GetPlayer(source)
    else
        Player = Config.FrameworkFunctions.GetPlayer(source)
    end
    if not Player then return end
    local FishingRep = GetFishingRep(Player)
    cb(FishingRep)
end)

CreateThread(function()
    while GetResourceState("es_extended") ~= 'started'
       and GetResourceState("qb-core")     ~= 'started' do
        Wait(1000)
    end
    Wait(1000)

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `pug_fishing` (
        `id`                INT(11)      NOT NULL AUTO_INCREMENT,
        `citizenid`         VARCHAR(50)  NOT NULL,
        `fishcaught`        JSON         NOT NULL DEFAULT ('[]'),
        `boats`             JSON         NOT NULL DEFAULT ('[]'),
        `skills`            JSON         NOT NULL DEFAULT ('{}'),
        `daily_challenges`  JSON         NOT NULL DEFAULT ('{}'),
        `weekly_challenges` JSON         NOT NULL DEFAULT ('{}'),
        `wins`              INT(11)      NOT NULL DEFAULT 0,
        `fishingrep` int(11) DEFAULT NULL,
        `name`              VARCHAR(100) DEFAULT NULL,
        PRIMARY KEY (`id`),
        UNIQUE KEY `unique_citizenid` (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

-- Disabled for Qbox - Qbox uses ox_inventory items instead of QB-Core shared items
--[[
if Framework == "QBCore" then
    local function VerifyFishingItems()
        local requiredItems = {
            "fishingrod", "fishingrod2", "fishingrod3",
            "fishinglure", "fishinglure2", "skillreel", "proreel", "fishingbait",
            "killerwhale", "stingraymeat", "tigershark", "catfish", "fish", "salmon",
            "largemouthbass", "goldfish", "redfish", "bluefish", "stripedbass",
            "rainbowtrout", "gholfish", "codfish", "eelfish", "swordfish", "tunafish",
            "chestkey", "treasurechest", "bottlemap", "treasuremap",
            "diamond", "emerald", "sapphire", "ruby", "yellowdiamond", "captainskull"
        }

        for _, itemName in pairs(requiredItems) do
            if not FWork.Shared.Items[itemName] then
                print("^1[WARNING]^0 Missing item in shared items: " .. itemName.. " ^2 make sure to add these items from pug-fishing/(QBCORE-ONLY) to your qb-core/shared/items.lua")
            end
        end
    end
    VerifyFishingItems()
end
--]]