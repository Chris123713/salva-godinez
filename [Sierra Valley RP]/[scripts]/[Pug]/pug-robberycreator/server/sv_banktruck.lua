local bankTruckCooldown = {}
local StartedBankTruckRobbery
function getBankTruckSettings()
    local result = MySQL.query.await('SELECT settings FROM pug_banktruck WHERE id = 1 LIMIT 1')
    if result and result[1] then
        return result[1].settings
    else
        return '[]' 
    end
end

function SetAllRobberiesOnCooldown(cooldownMinutes)
    if cooldownMinutes and cooldownMinutes > 0 then
        local cooldownTime = cooldownMinutes * 60 
        local endTime = os.time() + cooldownTime

        local heists = getHeists()
        for _, heist in ipairs(heists) do
            local heistName = heist.heist_name
            AllRobberysCooldDownTable[heistName] = endTime
        end

        AllRobberysCooldDownTable["banktruck"] = endTime

        CreateThread(function()
            while true do
                Wait(1000) 
                local currentTime = os.time()
                if currentTime >= endTime then
                    for k, _ in pairs(AllRobberysCooldDownTable) do
                        if AllRobberysCooldDownTable[k] and AllRobberysCooldDownTable[k] <= currentTime then
                            AllRobberysCooldDownTable[k] = nil
                        end
                    end
                    PrintDebug("All robberies cooldown has ended.")
                    break
                end
            end
        end)
    end
end

RegisterNetEvent('Pug:server:TriggerAllRobberiesCooldown', function()
    local bankTruckData = getBankTruckSettings()
    if bankTruckData and bankTruckData.otherRobberiesCooldown and bankTruckData.otherRobberiesCooldown.enabled then
        local cooldownMinutes = bankTruckData.otherRobberiesCooldown.cooldownTime
        SetAllRobberiesOnCooldown(cooldownMinutes)
    end
end)

RegisterNetEvent('Pug:server:ResetBankTruckStartProps', function()
    TriggerClientEvent("Pug:client:ResetBankTruckPropSetup",  -1)
end)

RegisterNetEvent('Pug:saveBankTruckData', function(newBankTruckData)
    local src = source

    MySQL.query('SELECT settings FROM pug_banktruck WHERE id = 1', {}, function(results)
        local currentData = {}

        if results and #results > 0 then
            currentData = json.decode(results[1].settings) or {}
        end

        for key, value in pairs(newBankTruckData) do
            currentData[key] = value
        end

        local updatedData = json.encode(currentData)

        MySQL.query('INSERT INTO pug_banktruck (id, settings) VALUES (1, @settings) ON DUPLICATE KEY UPDATE settings = @settings', {
            ['@settings'] = updatedData,
        }, function(result)
            if result then
                TriggerClientEvent("Pug:client:UpdateBankTruckData", -1, updatedData)
                RegisterBankTruckUsableItem()
                StartBankTruckCooldownOnRestart()
                Wait(50)
                TriggerClientEvent('Pug:client:ShowHeistNotify', src, Config.LangT["BankTruckDataSaved"])
            else
                TriggerClientEvent('Pug:client:ShowHeistNotify', src, Config.LangT["ErrorSavingBankTruckData"])
            end
        end)
    end)
end)


local function SpawnBankTruck(locationData, Owned)
    local players = GetPlayers()
    if #players == 0 then
        PrintDebug("No players connected. Cannot spawn bank truck.")
        return
    end

    local closestPlayer = nil
    local closestDistance = math.huge
    if not Owned then
        for _, playerId in ipairs(players) do
            local ped = GetPlayerPed(playerId)
            if DoesEntityExist(ped) then
                local playerCoords = GetEntityCoords(ped)
                local distance = #(playerCoords - locationData.coords)
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = playerId
                end
            end
        end
    else
        closestPlayer = Owned
    end

    if closestPlayer then
        TriggerClientEvent('Pug:client:SpawnBankTruck', tonumber(closestPlayer), locationData, Owned)
    else
        PrintDebug("Could not find a suitable player to spawn the bank truck.")
    end
end

RegisterNetEvent("Pug:Server:SpawnRandomBankTruck", function()
    local src = source
    local bankTruckDataJson = getBankTruckSettings()
    local bankTruckData = json.decode(bankTruckDataJson)

    local dynamicSpawnEnabled = bankTruckData.dynamicSpawnLocations
    local spawnLocations = bankTruckData.spawnLocations or {}
    local hasSpawnLocations = dynamicSpawnEnabled and #spawnLocations > 0

    local initiatingStartingPoint = bankTruckData.initiatingStartingPoint or {}
    local initiatingStartingPointEnabled = bankTruckData.initiatingStartingPointEnabled or false
    local hasInitiatingStartingPoint = initiatingStartingPointEnabled and #initiatingStartingPoint > 0


    if hasSpawnLocations and not hasInitiatingStartingPoint then

        local randomIndex = math.random(1, #spawnLocations)
        local selectedLocation = spawnLocations[randomIndex]

        local locationData = {
            coords = vector3(
                selectedLocation.vector[1],
                selectedLocation.vector[2],
                selectedLocation.vector[3]
            ),
            heading = selectedLocation.heading
        }

        SpawnBankTruck(locationData, src)
        CreateThread(function()
            if bankTruckData and bankTruckData.bankTruckCooldown and bankTruckData.bankTruckCooldown > 0 then
                StartedBankTruckRobbery = true
                local cooldownTime = bankTruckData.bankTruckCooldown * 60
                local Endtime = os.time() + cooldownTime
                while os.time() < Endtime do
                    Wait(1000) 
                end
                PrintDebug("END COOLDOWN")
                StartedBankTruckRobbery = false
            end
        end)
    else
        PrintDebug("Conditions not met for spawning bank truck.")
    end
end)

function StartBankTruckCooldownOnRestart()
    Wait(1000)
    local bankTruckData = getBankTruckSettings()
    bankTruckData = json.decode(bankTruckData)
    if bankTruckData and bankTruckData.bankTruckRestartCooldown and bankTruckData.bankTruckRestartCooldown > 0 then
        local cooldownTime = bankTruckData.bankTruckRestartCooldown * 60
        bankTruckCooldown.isOnCooldown = true
        bankTruckCooldown.endTime = os.time() + cooldownTime

        AllRobberysCooldDownTable["banktruck"] = bankTruckCooldown.endTime
        CreateThread(function()
            while os.time() < bankTruckCooldown.endTime do
                Wait(1000) 
            end
            bankTruckCooldown.isOnCooldown = false
            AllRobberysCooldDownTable["banktruck"] = nil
            PrintDebug("Bank truck cooldown after server restart has ended.")
        end)
    end
end

function RegisterBankTruckUsableItem()
    local bankTruckDataJson = getBankTruckSettings()
    local bankTruckData = json.decode(bankTruckDataJson)

    if bankTruckData and bankTruckData.requiredItem and #bankTruckData.requiredItem > 0 then
        local firstRequiredItem = bankTruckData.requiredItem[1]
        local itemName = firstRequiredItem.name

        if itemName and itemName ~= '' then
            if Framework == "ESX" then
                if not ESXRegisteredItems then ESXRegisteredItems = {} end
                if not ESXRegisteredItems[itemName] then
                    FWork.RegisterUsableItem(string.lower(tostring(itemName)), function(playerId)
                        TriggerClientEvent('Pug:client:UseBankTruckItem', playerId)
                    end)
                    ESXRegisteredItems[itemName] = true
                    PrintDebug("^2[BankTruck] Registered usable item for bank truck robbery: ^0" .. itemName)
                else
                    PrintDebug("^3[BankTruck] Item " .. itemName .. " is already registered as usable")
                end
            elseif Framework == "QBCore" then
                FWork.Functions.CreateUseableItem(string.lower(tostring(itemName)), function(source, item)
                    TriggerClientEvent('Pug:client:UseBankTruckItem', source)
                end)
                PrintDebug("^2[BankTruck] Registered usable item for bank truck robbery: ^0" .. itemName)
            end
        else
           PrintDebug("^1[BankTruck] First required item name is invalid")
        end
    else
        PrintDebug("^3[BankTruck] No required items found for bank truck robbery")
    end
end

Config.FrameworkFunctions.CreateCallback('Pug:server:IsBankTruckOnCooldown', function(source, cb)
    local currentTime = os.time()
    local cooldownEndTime = AllRobberysCooldDownTable["banktruck"]
    if cooldownEndTime and currentTime < cooldownEndTime then
        local timeRemaining = cooldownEndTime - currentTime
        cb(true, timeRemaining)
    else
        cb(false, 0)
    end
end)

Config.FrameworkFunctions.CreateCallback('Pug:server:IsBankTruckBeingInitiated', function(source, cb)
    cb(StartedBankTruckRobbery)
end)

CreateThread(function()
    while true do
        Wait(3600000)
        local bankTruckDataJson = getBankTruckSettings()
        local bankTruckData = json.decode(bankTruckDataJson)

        local dynamicSpawnEnabled = bankTruckData.dynamicSpawnLocations
        local spawnLocations = bankTruckData.spawnLocations or {}
        local hasSpawnLocations = dynamicSpawnEnabled and #spawnLocations > 0

        local initiatingStartingPoint = bankTruckData.initiatingStartingPoint or {}
        local initiatingStartingPointEnabled = bankTruckData.initiatingStartingPointEnabled or false
        local hasInitiatingStartingPoint = initiatingStartingPointEnabled and #initiatingStartingPoint > 0


        if hasSpawnLocations and not hasInitiatingStartingPoint then
            local randomIndex = math.random(1, #spawnLocations)
            local selectedLocation = spawnLocations[randomIndex]

            local locationData = {
                coords = vector3(
                    selectedLocation.vector[1],
                    selectedLocation.vector[2],
                    selectedLocation.vector[3]
                ),
                heading = selectedLocation.heading
            }

            SpawnBankTruck(locationData)
        else
            PrintDebug("Conditions not met for spawning bank truck.")
        end
    end
end)

RegisterNetEvent("Pug:server:CreateBankTruckBlipForEveryone", function(locationCoords)
    TriggerClientEvent("Pug:client:CreateBankTruckBlipForEveryone", -1, locationCoords)
end)

RegisterNetEvent('Pug:server:StartBankTruckRobbery', function(Location)
    local src = source
    local bankTruckDataJson = getBankTruckSettings()
    local bankTruckData = json.decode(bankTruckDataJson)

    local cooldownMinutes = bankTruckData.bankTruckCooldown or 30 -- Default to 30 minutes
    local currentTime = os.time()
    local endTime = currentTime + (cooldownMinutes * 60)
    AllRobberysCooldDownTable["banktruck"] = endTime

    CreateThread(function()
        while os.time() < endTime do
            Wait(1000)
        end
        AllRobberysCooldDownTable["banktruck"] = nil
        PrintDebug("Bank truck cooldown has ended.")
    end)

    if bankTruckData.otherRobberiesCooldown and bankTruckData.otherRobberiesCooldown.enabled then
        local otherCooldownMinutes = bankTruckData.otherRobberiesCooldown.cooldownTime
        SetAllRobberiesOnCooldown(otherCooldownMinutes)
    end

    TriggerClientEvent("Pug:client:SomeoneHitBankTruck", -1, src)
    
    local lootCooldownMinutes = bankTruckData.bankTruckLootCooldown or 1
    if not lootCooldownMinutes or lootCooldownMinutes < 1 then
        lootCooldownMinutes = 1 
    end
    Wait(lootCooldownMinutes * 60000)

    TriggerClientEvent("Pug:client:AllowAllToLootBankTruck", -1, Location)
end)

RegisterNetEvent('Pug:server:PlayerCompletedRobbery', function(LootTime)
    local src = source
    local Player = Config.FrameworkFunctions.GetPlayer(src)
    local bankTruckDataJson = getBankTruckSettings()
    local bankTruckData = json.decode(bankTruckDataJson)

    local rewardItems = bankTruckData.rewardItem or {}
    for _, itemData in ipairs(rewardItems) do
        local itemName = itemData.name
        local minAmount = itemData.minAmount or 1
        local maxAmount = itemData.maxAmount or 1
        local amount = math.random(minAmount, maxAmount)
        if GetResourceState("tgiann-inventory") == 'started' then
            exports["tgiann-inventory"]:AddItem(src, itemName, amount or 1)
        elseif GetResourceState("ox_inventory") == 'started' then
            if exports.ox_inventory:CanCarryItem(src, itemName, amount or 1) then
                exports.ox_inventory:AddItem(src, itemName, amount or 1)
            else
                exports.ox_inventory:CustomDrop('ItemDropOx', {
                    {itemName, amount or 1},
                }, GetEntityCoords(GetPlayerPed(src)), 10, 10000)
                TriggerClientEvent('Pug:client:ShowHeistNotify', src, Config.LangT["ItemsFellOnGround"], "error")
            end
        else
            Player.AddItem(itemName, amount)
        end
        if Framework == "QBCore" then
            TriggerClientEvent('inventory:client:ItemBox', src, FWork.Shared.Items[itemName], "add", amount)
        end
    end

    local rewardMoney = bankTruckData.rewardMoney or {}
    for _, moneyData in ipairs(rewardMoney) do
        local moneyType = moneyData.account or 'cash'
        local minAmount = moneyData.minAmount or 0
        local maxAmount = moneyData.maxAmount or 0
        local amount = math.random(minAmount, maxAmount)
        if GetResourceState("ox_inventory") == 'started' then
            if moneyType == "cash" or moneyType == "money" then
                exports.ox_inventory:AddItem(src, "cash", amount)
            else
                Player.AddMoney(moneyType, amount)
            end
        else
            Player.AddMoney(moneyType, amount)
        end
    end

    local robberyRep = bankTruckData.robberyRep or 0
    if robberyRep > 0 then
        local currentRep = GetRobberyRep(Player)
        SetNewRobberyRep(Player, currentRep + robberyRep)
    end

    TriggerClientEvent('Pug:client:ShowHeistNotify', src, Config.LangT["RewardsReceived"], "success")
end)


RegisterNetEvent('Pug:server:PlayerStartedLootingBankTruck', function()
    local src = source
    TriggerClientEvent('Pug:client:RemoveBankTruckTarget', -1)
end)

RegisterNetEvent('Pug:server:DeleteMoneyProp', function(propIndex)
    TriggerClientEvent('Pug:client:DeleteMoneyProp', -1, propIndex)
end)
