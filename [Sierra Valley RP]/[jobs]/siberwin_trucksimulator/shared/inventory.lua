Inventory = {}

function Inventory.GetPlayerInventory(playerId)
    if not Config.Inventory.enabled then return nil end
    
    local inventoryScript = Config.Inventory.script
    
    if inventoryScript == 'ox_inventory' then
        return exports.ox_inventory:GetInventory(playerId)
    elseif inventoryScript == 'qb-inventory' then
        local QBCore = exports['siberwin_trucksimulator']:GetQBCore()
        local Player = QBCore.Functions.GetPlayer(playerId)
        return Player and Player.PlayerData.items or nil
    elseif inventoryScript == 'qs-inventory' then
        return exports['qs-inventory']:GetInventory(playerId)
    elseif inventoryScript == 'ps-inventory' then
        return exports['ps-inventory']:GetInventory(playerId)
    elseif inventoryScript == 'custom' then
        return nil
    end
    
    return nil
end

function Inventory.AddItem(playerId, item, amount, metadata)
    if not Config.Inventory.enabled then return false end
    
    local inventoryScript = Config.Inventory.script
    amount = amount or 1
    metadata = metadata or {}
    
    if inventoryScript == 'ox_inventory' then
        return exports.ox_inventory:AddItem(playerId, item, amount, metadata)
    elseif inventoryScript == 'qb-inventory' then
        local QBCore = exports['siberwin_trucksimulator']:GetQBCore()
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            return Player.Functions.AddItem(item, amount, false, metadata)
        end
    elseif inventoryScript == 'qs-inventory' then
        return exports['qs-inventory']:AddItem(playerId, item, amount, false, metadata)
    elseif inventoryScript == 'ps-inventory' then
        return exports['ps-inventory']:AddItem(playerId, item, amount, false, metadata)
    elseif inventoryScript == 'custom' then
        return false
    end
    
    return false
end

function Inventory.RemoveItem(playerId, item, amount, metadata)
    if not Config.Inventory.enabled then return false end
    
    local inventoryScript = Config.Inventory.script
    amount = amount or 1
    metadata = metadata or {}
    
    if inventoryScript == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(playerId, item, amount, metadata)
    elseif inventoryScript == 'qb-inventory' then
        local QBCore = exports['siberwin_trucksimulator']:GetQBCore()
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            return Player.Functions.RemoveItem(item, amount)
        end
    elseif inventoryScript == 'qs-inventory' then
        return exports['qs-inventory']:RemoveItem(playerId, item, amount, false, metadata)
    elseif inventoryScript == 'ps-inventory' then
        return exports['ps-inventory']:RemoveItem(playerId, item, amount, false, metadata)
    elseif inventoryScript == 'custom' then
        return false
    end
    
    return false
end

function Inventory.HasItem(playerId, item, amount)
    if not Config.Inventory.enabled then return false end
    
    local inventoryScript = Config.Inventory.script
    amount = amount or 1
    
    if inventoryScript == 'ox_inventory' then
        local count = exports.ox_inventory:GetItemCount(playerId, item)
        return count >= amount
    elseif inventoryScript == 'qb-inventory' then
        local QBCore = exports['siberwin_trucksimulator']:GetQBCore()
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local item = Player.Functions.GetItemByName(item)
            return item and item.amount >= amount
        end
    elseif inventoryScript == 'qs-inventory' then
        local count = exports['qs-inventory']:GetItemTotalAmount(playerId, item)
        return count >= amount
    elseif inventoryScript == 'ps-inventory' then
        local count = exports['ps-inventory']:GetItemCount(playerId, item)
        return count >= amount
    elseif inventoryScript == 'custom' then
        return false
    end
    
    return false
end

function Inventory.GetItemCount(playerId, item)
    if not Config.Inventory.enabled then return 0 end
    
    local inventoryScript = Config.Inventory.script
    
    if inventoryScript == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(playerId, item)
    elseif inventoryScript == 'qb-inventory' then
        local QBCore = exports['siberwin_trucksimulator']:GetQBCore()
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local item = Player.Functions.GetItemByName(item)
            return item and item.amount or 0
        end
    elseif inventoryScript == 'qs-inventory' then
        return exports['qs-inventory']:GetItemTotalAmount(playerId, item)
    elseif inventoryScript == 'ps-inventory' then
        return exports['ps-inventory']:GetItemCount(playerId, item)
    elseif inventoryScript == 'custom' then
        return 0
    end
    
    return 0
end

function Inventory.GiveJobPaper(playerId, jobData)
    if not Config.Inventory.enabled then return false end
    
    local jobName = jobData.jobName or 'Unknown Job'
    local cargo = jobData.cargo or jobData.cargoType or 'Unknown Cargo'
    local driverName = jobData.driverFullName or 'Unknown Driver'
    local truckModel = jobData.truckModel or 'Unknown Truck'
    local truckPlate = jobData.truckPlate or jobData.plate or 'Unknown Plate'
    
    local dynamicLabel = string.format('%s - %s', Config.Inventory.jobPaperLabel, jobName)
    local dynamicDescription = string.format('Job: %s | Cargo: %s | Driver: %s | Truck: %s | Plate: %s', 
        jobName, cargo, driverName, truckModel, truckPlate)
    
    local metadata = {
        label = dynamicLabel,
        description = dynamicDescription,
        jobName = jobName,
        cargo = cargo,
        driverName = driverName,
        truckModel = truckModel,
        truckPlate = truckPlate
    }
    
    return Inventory.AddItem(playerId, Config.Inventory.jobPaperItem, 1, metadata)
end

function Inventory.GetJobPaperSlots(playerId)
    if Config.Inventory.script ~= 'ox_inventory' then return {} end
    
    local inventory = exports.ox_inventory:GetInventory(playerId)
    if not inventory or not inventory.items then return {} end
    
    local slots = {}
    for slot, item in pairs(inventory.items) do
        if item.name == Config.Inventory.jobPaperItem then
            table.insert(slots, slot)
        end
    end
    
    return slots
end

function Inventory.RemoveJobPaperBySlot(playerId, slot)
    if Config.Inventory.script ~= 'ox_inventory' then return false end
    
    return exports.ox_inventory:RemoveItem(playerId, Config.Inventory.jobPaperItem, 1, nil, slot)
end

function Inventory.RemoveAllJobPapersOx(playerId)
    local slots = Inventory.GetJobPaperSlots(playerId)
    
  
    if #slots == 0 then
        return true
    end
    
    local removedCount = 0
    for _, slot in ipairs(slots) do
        if Inventory.RemoveJobPaperBySlot(playerId, slot) then
            removedCount = removedCount + 1
        end
    end
    
    
    return removedCount > 0
end


function Inventory.RemoveAllJobPapers(playerId)
    if not Config.Inventory.enabled then return false end
    
    local inventoryScript = Config.Inventory.script
    
    if inventoryScript == 'ox_inventory' then
        return Inventory.RemoveAllJobPapersOx(playerId)
    else
        local count = Inventory.GetItemCount(playerId, Config.Inventory.jobPaperItem)
        if count > 0 then
            return Inventory.RemoveItem(playerId, Config.Inventory.jobPaperItem, count)
        end
        return true
    end
end

function Inventory.Notify(playerId, message, type)
    type = type or 'info'
    
    if Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', playerId, message, type)
    elseif Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', playerId, message)
    else
        TriggerClientEvent('chat:addMessage', playerId, {
            color = {255, 255, 255},
            multiline = true,
            args = {"Trucking", message}
        })
    end
end