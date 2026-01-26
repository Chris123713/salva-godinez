---------- [Door Locks] ----------
function SetDoorLockStatus(DoorID, Lock, src)
    if GetResourceState("ox_doorlock") == 'started' then
        TriggerEvent('ox_doorlock:setState', DoorID, Lock) -- LOCKS DOOR
    elseif GetResourceState("nui_doorlock") == 'started' then
        TriggerEvent('nui_doorlock:server:updateState', DoorID, Lock, false, false, true)
    elseif GetResourceState("qb-doorlock") == 'started' then
        if not src then
            local players = GetPlayers()
            if #players > 0 then
                src = tonumber(players[math.random(#players)])
            else
                PrintDebug("No players available to assign as 'src'.")
                return
            end
        end
        TriggerEvent('qb-doorlock:server:updateState', DoorID, Lock, false, false, true, false, false, src)
    elseif GetResourceState("doors_creator") == 'started' then
        exports["doors_creator"]:setDoorState(DoorID, Lock)
    elseif GetResourceState("rcore_doorlock") == 'started' then
        local doorState = Lock and 1 or 0  
        exports["rcore_doorlock"]:changeDoorState(DoorID, doorState)
    else
        PrintDebug("Please use either ox_doorlock or a qb-doorlock variant. (OX_DOORLOCK IS THE BEST AND ITS FREE)")
    end
end
RegisterNetEvent('Pug:server:SetDoorLockStatus', function(DoorID, Lock, FakeDoor)
    local src = source
    if FakeDoor then
        TriggerClientEvent('Pug:client:SetFakeDoorOpen',-1, DoorID, Lock)
    else
        SetDoorLockStatus(DoorID, Lock, src)
    end
end)
RegisterNetEvent('Pug:server:SendLBTabletDispatch', function(dispatchData)
    local dispatchId = exports["lb-tablet"]:AddDispatch(dispatchData)
end)
------------------------------
function SendCustomWebhook(message)
    local WebHookURL = Config.DiscordWebHook
    local Data = {
        {
            ["title"] = "Robbery Creator",
            ["color"] = 16711680,
            ["footer"] = {
                ["text"] = os.date("%c"),
            },
            ["description"] = message,
        }
    }
    PerformHttpRequest(WebHookURL, function(err, text, headers) end, 'POST', json.encode({ username = "Server Logs", embeds = Data}), { ['Content-Type'] = 'application/json' })
end

---------- [CUSTOMER CUSTOM CALLBACK] ----------
Config.FrameworkFunctions.CreateCallback('Pug:serverCB:CustomCanDoRobberyStepCheck', function(source, cb)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)

    local CustomCheck = true
    if Config.DiscordWebHook ~= "ADD YOUR CUSTOM WEBHOOK URL HERE" then
        local Message = Player.PlayerData.charinfo.firstname.. " ".. Player.PlayerData.charinfo.lastname .. " is robbing a store or bank."
        SendCustomWebhook(Message)
    end

    ---------- [ADD WHATEVER CUSTOM CODE YOU WANT TO HERE TO DO A CHECK FOR THE PLAYER TO BE ABLE TO DO A ROBBERY] ----------

    cb(CustomCheck)
end)
------------------------------

--// FRAMEWORK STUFF //--
if Framework == "ESX" then
    Config.FrameworkFunctions.CreateCallback('Pug:serverESX:GetItemESXRobberyCreator', function(source, cb, item, amount)
        local retval = false
        local Player = FWork.GetPlayerFromId(source)
        local PlayerItem = Player.getInventoryItem(item)
        local Cost = amount or 1
        if PlayerItem then
            if PlayerItem.count ~= nil then
                if tonumber(PlayerItem.count) >= Cost then
                    retval = true
                end
            end
        end
        cb(retval)
    end)
elseif Framework == "QBCore" then
    local function GetFirstSlotByItem(items, itemName)
        if not items then return nil end
        for slot, item in pairs(items) do
            if item.name:lower() == itemName:lower() then
                return tonumber(slot)
            end
        end
        return nil
    end
    function GetItemByName(source, item)
        local Player = Config.FrameworkFunctions.GetPlayer(source)
        item = tostring(item):lower()
        local slot = GetFirstSlotByItem(Player.PlayerData.items, item)
        return Player.PlayerData.items[slot]
    end
    Config.FrameworkFunctions.CreateCallback('Pug:server:GetItemQBCoreRobberyCreator', function(source, cb, items, amount)
        local src = source
        items = string.lower(items)
        print(Config.InventoryType,"Config.InventoryType")
        if Config.InventoryType == "ox_inventory" then
            local ox_inventory = exports.ox_inventory
            if ox_inventory:GetItem(src, items, false, true) then
                if ox_inventory:GetItem(src, items, false, true) >= amount then
                    cb(true)
                else
                    cb(false)
                end
            else
                cb(false)
            end
        elseif Config.InventoryType == "codem-inventory" then
            if exports['codem-inventory']:GetItemsTotalAmount(src,items) >= amount then
                cb(true)
            else
                cb(false)
            end
        else
            local retval = false
            local isTable = type(items) == 'table'
            local isArray = isTable and table.type(items) == 'array' or false
            local totalItems = #items
            local count = 0
            local kvIndex = 2
            print(amount,"amount")
            if amount == 'hidden' then
                amount = 1
            end
            if isTable and not isArray then
                totalItems = 0
                for _ in pairs(items) do totalItems += 1 end
                kvIndex = 1
            end
            if isTable then
                for k, v in pairs(items) do
                    local itemKV = {k, v}
                    local item = GetItemByName(src, itemKV[kvIndex])
                    if item and ((amount and item.amount >= amount) or (not isArray and item.amount >= v) or (not amount and isArray)) then
                        count += 1
                    end
                end
                if count == totalItems then
                    retval = true
                end
            else 
                local item = GetItemByName(src, items)
                if item and (not amount or (item and amount and item.amount and item.amount >= amount)) then
                    retval = true
                elseif item and not item.amount then
                    print(item.amount,"item.amount is nil for some reason?")
                end
            end
            print(retval,"retval")
            cb(retval)
        end
    end)
end
------------------------------

local function readDataFile(fileName)
    local content = LoadResourceFile(GetCurrentResourceName(), fileName)
    if not content then 
        PrintDebug("Could not open file:", fileName)
        return nil 
    end
    PrintDebug("File content loaded successfully.")
    return json.decode(content)
end

-- Function to insert heist data into the database
local function insertHeistData(heistData)
    for _, heist in ipairs(heistData) do
        local query = [[
            INSERT INTO pug_heist (heist_name, stages, settings)
            VALUES (@heist_name, @stages, @settings)
            ON DUPLICATE KEY UPDATE
            stages = VALUES(stages),
            settings = VALUES(settings)
        ]]
        
        local heistName = heist.heist_name
        local stages = json.encode(heist.stages)
        local settings = json.encode(heist.settings)

        -- Insert into the database with ON DUPLICATE KEY to avoid duplicates
        MySQL.query(query, {
            ['@heist_name'] = heistName,
            ['@stages'] = stages,
            ['@settings'] = settings
        }, function(affectedRows)
            -- if affectedRows > 0 then
            --     PrintDebug("Inserted/Updated heist data for:"..heistName)
            -- end
        end)
    end
end

local function isCloseEnough(val1, val2, tolerance)
    return math.abs(val1 - val2) < tolerance
end

local function tablesEqual(tbl1, tbl2)
    if tbl1 == tbl2 then return true end
    if type(tbl1) ~= "table" or type(tbl2) ~= "table" then return false end
    for k, v in pairs(tbl1) do
        if tbl2[k] == nil then return false end
        if type(v) == "number" and type(tbl2[k]) == "number" then
            if not isCloseEnough(v, tbl2[k], 0.0001) then
                return false
            end
        elseif type(v) == "table" and type(tbl2[k]) == "table" then
            if not tablesEqual(v, tbl2[k]) then return false end
        elseif v ~= tbl2[k] then
            return false
        end
    end
    for k, v in pairs(tbl2) do
        if tbl1[k] == nil then return false end
    end
    return true
end


local function insertDoorLockData(doorLockData)
    PrintDebug("Inserting Door Lock Data")
    for _, door in ipairs(doorLockData) do
        local id = door.id
        local name = door.name
        local data = json.encode(door.data)
        local coords = door.data.coords
        local x, y, z = coords.x, coords.y, coords.z
        local distanceThreshold = 2.0

        local queryDelete = [[
            DELETE FROM ox_doorlock
            WHERE id != @id
            AND SQRT(POW(CAST(JSON_UNQUOTE(JSON_EXTRACT(data, '$.coords.x')) AS DECIMAL(10, 5)) - @x, 2) +
                     POW(CAST(JSON_UNQUOTE(JSON_EXTRACT(data, '$.coords.y')) AS DECIMAL(10, 5)) - @y, 2) +
                     POW(CAST(JSON_UNQUOTE(JSON_EXTRACT(data, '$.coords.z')) AS DECIMAL(10, 5)) - @z, 2)) <= @distanceThreshold
        ]]
        
        MySQL.query(queryDelete, {
            ['@id'] = id,
            ['@x'] = x,
            ['@y'] = y,
            ['@z'] = z,
            ['@distanceThreshold'] = distanceThreshold
        }, function(affectedRows)
            -- if affectedRows > 0 then
            --     PrintDebug("Deleted nearby doors within distance threshold for:"..name)
            -- end

            local queryCheck = [[
                SELECT data FROM ox_doorlock WHERE id = @id
            ]]

            MySQL.query(queryCheck, { ['@id'] = id }, function(results)
                if #results > 0 then
                    local existingData = json.decode(results[1].data)
                    local newData = door.data 
                    if tablesEqual(existingData, newData) then
                        PrintDebug("Skipping update for door:"..name)
                    else
                        PrintDebug("Existing data:", json.encode(existingData))
                        PrintDebug("New data:", json.encode(newData))
                        -- Data is different, update the entry
                        local queryUpdate = [[
                            UPDATE ox_doorlock SET name = @name, data = @data WHERE id = @id
                        ]]
                        MySQL.query(queryUpdate, {
                            ['@id'] = id,
                            ['@name'] = name,
                            ['@data'] = data
                        }, function(affectedRows)
                            PrintDebug("Updating door lock data for:"..name)
                        end)
                    end
                else
                    -- Door does not exist, insert new entry
                    local queryInsert = [[
                        INSERT INTO ox_doorlock (id, name, data)
                        VALUES (@id, @name, @data)
                    ]]
                    MySQL.query(queryInsert, {
                        ['@id'] = id,
                        ['@name'] = name,
                        ['@data'] = data
                    }, function(affectedRows)
                        PrintDebug("Inserted new door lock data for:"..name)
                    end)
                end
                
            end)
        end)
    end
end

function GetRobberyRep(Player)
    if Framework == "QBCore" then
        if Player.PlayerData.metadata["robberyrep"] ~= nil then
            return Player.PlayerData.metadata["robberyrep"]
        else
            Player.Functions.SetMetaData("robberyrep", 0)
            Player.Functions.Save()
            return 0
        end
    elseif Framework == "ESX" then
        local CitizenId = Player.PlayerData.citizenid
        local Result = MySQL.query.await('SELECT * FROM pug_robberyrep WHERE citizenid = ?', {CitizenId})
        if Result[1] then
            return Result[1].robberyrep
        else
            return 0
        end
    end
end
function SetNewRobberyRep(Player, NewRep)
    if Framework == "QBCore" then
        Player.Functions.SetMetaData("robberyrep", NewRep)
    elseif Framework == "ESX" then
        local CitizenId = Player.PlayerData.citizenid
        local Result = MySQL.query.await('SELECT * FROM pug_robberyrep WHERE citizenid = ?', {CitizenId})
        if Result[1] then
            MySQL.update('UPDATE pug_robberyrep SET robberyrep = ? WHERE citizenid = ?', { NewRep, CitizenId })
        else
            MySQL.insert.await('INSERT INTO pug_robberyrep (citizenid, robberyrep) VALUES (?,?)', {
                CitizenId, NewRep
            })
        end
    end
end

-- Unified Callback for ESX and QB-Core to get the count of police on duty, with a customizable table of police jobs
Config.FrameworkFunctions.CreateCallback('Pug:serverCB:getPoliceCount', function(source, cb, policeJobs)
    local policeCount = 0
    local policeJobsTable = policeJobs or Config.DefualPoliceJobs -- Default to 'police' if no table is passed

    if Framework == "ESX" then
        local players = FWork.GetPlayers()
        for _, playerId in ipairs(players) do
            local xPlayer = FWork.GetPlayerFromId(playerId)
            if xPlayer ~= nil then
                PrintDebug("GOING THROUGH 1")
                if xPlayer.job then
                    PrintDebug("GOING THROUGH 2")
                    if xPlayer.job and xPlayer.job.name ~= nil then
                        PrintDebug("GOING THROUGH 3")
                        if policeJobsTable and xPlayer.job.name then
                            if table.contains(policeJobsTable, xPlayer.job.name) then
                                PrintDebug("GOING THROUGH 4")
                                policeCount = policeCount + 1
                            end
                        end
                    else
                        print("xPlayer.job.name is nil or invalid")
                    end
                end
            end
        end
    elseif Framework == "QBCore" then
        local players = FWork.Functions.GetPlayers()
        for _, playerId in ipairs(players) do
            local Player = FWork.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.job and Player.PlayerData.job.onduty and table.contains(policeJobsTable, Player.PlayerData.job.name) then
                policeCount = policeCount + 1
            end
        end
    end
    cb(policeCount) -- Return the count of police officers on duty
end)


---------- [Commands] ----------
if Framework == "QBCore" then
    FWork.Commands.Add(Config.HeistMenuCommand, "Create heist menu", {}, false, function(source, args)
        local src = source
        local heistData = getHeists()
        local BankTruckData = getBankTruckSettings()
        local SellItemsData = getSellItemsSettings()
        local AtmRobberyData = getAtmRobberySettings()
        TriggerClientEvent('heist:showHeistUI', src, heistData, BankTruckData, SellItemsData, AtmRobberyData)
    end, "admin")
    FWork.Functions.CreateUseableItem("gasmask", function(source, item)
        TriggerClientEvent('Pug:client:UseGasMaskItem', source)
    end)
    -- Create a usable item for attaching the hook
    FWork.Functions.CreateUseableItem("ropehook", function(source, item)
        TriggerClientEvent('Pug:client:AttachHookToVehicle', source)
    end)
    -- Check your criminal reputation.
    FWork.Commands.Add(Config.ReputationCommand, "Check Robbery Reputation", {}, false, function(source, args)
        local src = source
        local Player = FWork.Functions.GetPlayer(src)
        if Player then
            local MyRep = GetRobberyRep(Player)
            TriggerClientEvent('Pug:client:ShowHeistNotify', src, "You have "..MyRep.. " robbery reputation.")
        end
    end)
else
    FWork.RegisterCommand(Config.HeistMenuCommand, 'admin', function(xPlayer, args)
        local src = xPlayer.source
        local heistData = getHeists()
        local BankTruckData = getBankTruckSettings()
        local SellItemsData = getSellItemsSettings()
        local AtmRobberyData = getAtmRobberySettings()
        TriggerClientEvent('heist:showHeistUI', src, heistData, BankTruckData, SellItemsData, AtmRobberyData)
    end, true, {help = 'Create heist menu', validate = true, arguments = {}})
    FWork.RegisterUsableItem("gasmask", function(playerId)
        TriggerClientEvent('Pug:client:UseGasMaskItem', playerId)
    end)
    -- ESX version of usable item
    FWork.RegisterUsableItem("ropehook", function(playerId)
        TriggerClientEvent('Pug:client:AttachHookToVehicle', playerId)
    end)
    -- Check your criminal reputation.
    FWork.RegisterCommand(Config.ReputationCommand, 'user', function(xPlayer, args)
        local src = xPlayer.source
        local Player = Config.FrameworkFunctions.GetPlayer(src)
        if Player then
            local MyRep = GetRobberyRep(Player)
            TriggerClientEvent('Pug:client:ShowHeistNotify', src, "You have "..MyRep.. " robbery reputation.")
        end
    end)
end
------------------------------


-- AUTO SQL
CreateThread(function()
    while GetResourceState("es_extended") ~= 'started' and GetResourceState("qb-core") ~= 'started' do Wait(1000) end
    Wait(1000)
    local RobberyTable = 'pug_heist'
    -- Check if the `pug_heist` table exists
    local success, result = pcall(MySQL.scalar.await, ('SELECT 1 FROM `%s` LIMIT 1'):format(RobberyTable))
    if not success then
        -- Table doesn't exist, so create it
        MySQL.query([[ 
            CREATE TABLE IF NOT EXISTS pug_heist (
                id int(11) NOT NULL AUTO_INCREMENT,
                heist_name varchar(50) NOT NULL UNIQUE,
                stages MEDIUMTEXT DEFAULT '[]',
                settings text DEFAULT '[]',
                PRIMARY KEY (id)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
        ]], function()
            PrintDebug("^2Created `pug_heist` table.")
            
            -- Table created, now load and insert data from JSON file
            local heistData = readDataFile("preset-info/presets.json")
            if heistData then
                insertHeistData(heistData)
            else
                print("^1Failed to read presets.json")
            end
        end)
    else
        local columns = MySQL.query.await('SHOW COLUMNS FROM pug_heist')
        for i = 1, #columns do
            local column = columns[i]
            if column.Field == 'stages' and column.Type:upper() ~= 'MEDIUMTEXT' then
                print"UPDATED"
                MySQL.query('ALTER TABLE pug_heist MODIFY COLUMN stages MEDIUMTEXT DEFAULT \'[]\'')
                PrintDebug("^3Updated `stages` column to MEDIUMTEXT.")
                break
            end
        end
    end

    if GetResourceState("ox_doorlock") == 'started' and Config.CreateRobberyPresetsWhenScriptRunFirstTime then
        -- Check if the `ox_doorlock` table exists
        local success, result = pcall(MySQL.scalar.await, 'SELECT 1 FROM ox_doorlock LIMIT 1')
        if success then
            local doorLockData = readDataFile("preset-info/ox_doorlocks.json")
            if doorLockData then
                insertDoorLockData(doorLockData)
            else
                PrintDebug("^1Failed to read ox_doorlocks.json")
            end
        end
    end

    -- Check and create pug_atm table
    local AtmRobberyTable = 'pug_atm'
    local AtmRobberysuccess, AtmRobberyresult = pcall(MySQL.scalar.await, ('SELECT 1 FROM `%s` LIMIT 1'):format(AtmRobberyTable))
    if not AtmRobberysuccess then
        MySQL.query([[ 
            CREATE TABLE IF NOT EXISTS `pug_atm` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `settings` text DEFAULT '[]',
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
        ]], function()
            PrintDebug("^2Created `pug_atm` table.")
            
            local atmData = [[
                {"rewardType":"cash","minMoney":"250","cooldown":"30","moneyReward":true,"maxMoney":"1500","rewardItems":[{"maxAmount":"1","minAmount":"1","chance":"10","itemName":"BANKCARD"},{"maxAmount":"40","minAmount":"10","chance":"60","itemName":"STACKSOFCASH"},{"maxAmount":"55","minAmount":"30","chance":"70","itemName":"BANDSOFNOTES"}],"atmRobberyPoliceRequired":"3","requiredItems":[{"chance":"50","itemName":"DRILL","amount":"1"},{"chance":"100","itemName":"UNMARKEDSIMCARD","amount":"1"}],"robberyMethod":"rope","minigameOption":"maze","nightOnly":true}
            ]]
            MySQL.query("INSERT INTO pug_atm (id, settings) VALUES (1, @settings)", {
                ['@settings'] = atmData
            })
        end)
    end

    -- Check and create pug_banktruck table
    local BankTruckTable = 'pug_banktruck'
    local banktrucksuccess, banktruckresult = pcall(MySQL.scalar.await, ('SELECT 1 FROM `%s` LIMIT 1'):format(BankTruckTable))
    if not banktrucksuccess then
        MySQL.query([[ 
            CREATE TABLE IF NOT EXISTS `pug_banktruck` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `settings` text DEFAULT '[]',
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
        ]], function()
            PrintDebug("^2Created `pug_banktruck` table.")
            
            local bankTruckData = [[
                {"rewardMoney":[],"bankTruckLootCooldown":10,"bankTruckRestartCooldown":30,"initiatingStartingPoint":[],"miniGame":"inspired-thermite","policeRequired":1,"securityLevel":0,"dynamicSpawnLocations":true,"guardsShootOption":true,"rewardItem":[{"chance":100,"minAmount":200,"maxAmount":500,"name":"BANDSOFNOTES"},{"chance":100,"minAmount":50,"maxAmount":200,"name":"STACKSOFCASH"}],"otherRobberiesCooldown":{"cooldownTime":35,"enabled":true},"spawnLocations":[{"vector":[1208.77,2705.67,37.61],"heading":174},{"vector":[241.96,193.21,104.69],"heading":66},{"vector":[-1238,-874.66,12.1],"heading":128}],"BankTruckpoliceRequired":5,"bankTruckCooldown":70,"requiredItem":[{"quantityNeeded":1,"chanceToLose":100,"name":"BANKCARD"}],"lockBankTruck":true}
            ]]
            MySQL.query("INSERT INTO pug_banktruck (id, settings) VALUES (1, @settings)", {
                ['@settings'] = bankTruckData
            })
        end)
    end

    -- Check and create pug_sellitems table
    local SellItemsTable = 'pug_sellitems'
    local sellitemssuccess, sellitemsresult = pcall(MySQL.scalar.await, ('SELECT 1 FROM `%s` LIMIT 1'):format(SellItemsTable))
    if not sellitemssuccess then
        MySQL.query([[ 
            CREATE TABLE IF NOT EXISTS `pug_sellitems` (
                `id` int(11) NOT NULL AUTO_INCREMENT,
                `settings` text DEFAULT '[]',
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
        ]], function()
            PrintDebug("^2Created `pug_sellitems` table.")
            
            local sellItemsData = [[
                {"targets":[{"pedCoords":"1211.88, 1858.16, 77.97","sellAllItems":true,"targetText":"Trade Vile","sellItem":true,"targetVector":"1211.57, 1857.23, 79.04","animation":"8","sendAlert":true,"requireQuantity":true,"propHeading":"0.00","propName":"","playerHeading":"216.00","sellItems":[{"rewardMoneyMin":"0","rewardItems":[{"rewardItemMin":"2","rewardItemName":"C4","rewardItemChance":"100","rewardItemMax":"5"}],"delayReward":true,"quantity":"5","rewardMoneyType":"cash","itemName":"HUMANECO2","rewardDelayTime":"10","rewardMoneyMax":"0"}]}]}
            ]]
            MySQL.query("INSERT INTO pug_sellitems (id, settings) VALUES (1, @settings)", {
                ['@settings'] = sellItemsData
            })
        end)
    end

    -- Only create the 'pug_robberyrep' table for ESX servers
    if Framework == "ESX" then
        local repTable = 'pug_robberyrep'
        local successRep, resultRep = pcall(MySQL.scalar.await, ('SELECT 1 FROM %s LIMIT 1'):format(repTable))
        
        if not successRep then
            MySQL.query([[
                CREATE TABLE IF NOT EXISTS pug_robberyrep (
                    citizenid varchar(50) NOT NULL,
                    robberyrep int(11) DEFAULT 0,
                    PRIMARY KEY (citizenid)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ]])
            PrintDebug("^2PUG: `pug_robberyrep` table created for ESX servers.")
        end
    end

    if GetResourceState("qb-bankrobbery") == 'started' then
        PrintDebug("^1PUG: ^2REMOVE QB-BANKROBBERY FROM YOUR SERVER WHEN USING ROBBERY CREATOR")
    end
    if GetResourceState("qb-storerobbery") == 'started' then
        PrintDebug("^1PUG: ^2REMOVE QB-STOREROBBERY FROM YOUR SERVER WHEN USING ROBBERY CREATOR")
    end
    if GetResourceState("qb-jewelery") == 'started' then
        PrintDebug("^1PUG: ^2REMOVE QB-JEWLERY FROM YOUR SERVER WHEN USING ROBBERY CREATOR")
    end

    Wait(1000)
    local heists = getHeists() 
    for _, heist in ipairs(heists) do
        local heistName = heist.heist_name
        generateUniquePasscode(heistName)
        local stages = json.decode(heist.stages)

        -- Loop through the stages to lock the doors
        for _, stage in ipairs(stages) do
            if stage.doorId then
                if stage.type ~= "custom_door" then
                    if tostring(stage.doorId):match("^%d+$") then
                        if GetResourceState("doors_creator") == 'started' then
                            -- Lock the door for this stage is jaksam door creator
                            local doors = exports["doors_creator"]:getAllDoors()
                            if doors then
                                for k, doorData in pairs(doors) do
                                    if tonumber(stage.doorId) == tonumber(doorData.id) then
                                        SetDoorLockStatus(tonumber(stage.doorId), true)
                                        break
                                    end
                                end
                            end
                        else
                            -- Lock the door for this stage
                            PrintDebug("Locking door ID: " .. stage.doorId .. " for heist: " .. heistName)
                            SetDoorLockStatus(tonumber(stage.doorId), true)
                        end
                    else
                        PrintDebug("Invalid door ID: " .. stage.doorId .. " (not numbers only)")
                    end 
                end
            end
            if stage.passcodes then
                if heistPasscodes[heistName] then
                    heistPasscodesLocation[heistName..stage.stepNumber] = math.random(1,#stage.passcodes)
                end
            end
        end
    end

    -- Start bank truck cooldown if applicable
    StartBankTruckCooldownOnRestart()
    -- Create bank truck usable items if there are any
    RegisterBankTruckUsableItem()
    -- Set any robbery on server start cooldown
    SetRobberiesOnCooldownBasedOnMinutesUntilRobbery()
    -- Remove any city wide blackout
    SetCityWideBlackOutOff()

end)