-- Initialize framework
local QBCore = nil
local ESX = nil

if Config.Framework == 'qb-core' then
    -- Qbox framework - no need to cache GetPlayer function
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- Initialize elevator system on resource start
CreateThread(function()
    Wait(1000)  -- Wait for config to load
    print("^2[Custom Elevator]^7 Elevator system initialized")
    print("^3[Custom Elevator]^7 Total elevator shafts: ^3" .. #Config.ElevatorShafts .. "^7")
    print("^3[Custom Elevator]^7 Features: Call system, Queue management, State synchronization")
end)

-- Get player job information
function GetPlayerJob(source)
    if Config.Framework == 'qb-core' then
        -- Qbox framework integration
        local Player = exports.qbx_core:GetPlayer(source)
        if Player then
            return Player.PlayerData.job.name, Player.PlayerData.job.onduty
        end
    elseif Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.job.name, true
        end
    end
    return nil, false
end

-- Validate floor access
function ValidateFloorAccess(source, shaftIndex, floorId)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then
        return false, "Invalid elevator shaft"
    end
    
    local targetFloor = nil
    for _, floor in ipairs(shaft.floors) do
        if floor.id == floorId then
            targetFloor = floor
            break
        end
    end
    
    if not targetFloor then
        return false, "Invalid floor"
    end
    
    -- Check if floor has job lock
    if targetFloor.jobLock then
        local playerJob, onDuty = GetPlayerJob(source)
        
        if not playerJob then
            return false, "Unable to verify employment"
        end
        
        -- Check if player has required job
        local hasJob = false
        for _, job in ipairs(targetFloor.jobLock.jobs) do
            if job == playerJob then
                hasJob = true
                break
            end
        end
        
        if not hasJob then
            return false, "You do not have clearance for this floor"
        end
        
        -- Check on-duty requirement
        if targetFloor.jobLock.requireOnDuty and not onDuty then
            return false, "You must be on duty to access this floor"
        end
    end
    
    return true, "Access granted"
end

-- Server event to validate floor access (optional, for extra security)
RegisterNetEvent('custom_elevator:server:validateAccess', function(shaftIndex, floorId)
    local source = source
    local hasAccess, message = ValidateFloorAccess(source, shaftIndex, floorId)
    
    if not hasAccess then
        TriggerClientEvent('QBCore:Notify', source, message, 'error')
    end
end)

-- Command to teleport to a specific floor (admin only)
RegisterCommand('tpfloor', function(source, args, rawCommand)
    if source == 0 then
        print("This command can only be used in-game")
        return
    end
    
    -- Check if player is admin
    local isAdmin = false
    if Config.Framework == 'qb-core' and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and QBCore.Functions.HasPermission(source, 'admin') then
            isAdmin = true
        end
    elseif Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
            isAdmin = true
        end
    end
    
    if not isAdmin then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command', 'error')
        return
    end
    
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /tpfloor [shaft_index] [floor_id]', 'error')
        return
    end
    
    local shaftIndex = tonumber(args[1])
    local floorId = args[2]
    
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid shaft index', 'error')
        return
    end
    
    for _, floor in ipairs(shaft.floors) do
        if floor.id == floorId then
            TriggerClientEvent('custom_elevator:client:adminTeleport', source, floor.coords, floor.heading)
            TriggerClientEvent('QBCore:Notify', source, 'Teleported to ' .. floor.name, 'success')
            return
        end
    end
    
    TriggerClientEvent('QBCore:Notify', source, 'Invalid floor ID', 'error')
end, false)

-- Command to list all elevators and floors
RegisterCommand('listelevators', function(source, args, rawCommand)
    if source == 0 then
        print("=== ELEVATOR SHAFTS ===")
        for i, shaft in ipairs(Config.ElevatorShafts) do
            print(string.format("\n[%d] %s", i, shaft.name))
            for _, floor in ipairs(shaft.floors) do
                local jobLockInfo = ""
                if floor.jobLock then
                    jobLockInfo = " [LOCKED: " .. table.concat(floor.jobLock.jobs, ", ") .. "]"
                end
                print(string.format("  - %s: %s%s", floor.id, floor.name, jobLockInfo))
            end
        end
        print("\n======================")
        return
    end
    
    -- Check if player is admin
    local isAdmin = false
    if Config.Framework == 'qb-core' and QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and QBCore.Functions.HasPermission(source, 'admin') then
            isAdmin = true
        end
    elseif Config.Framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
            isAdmin = true
        end
    end
    
    if not isAdmin then
        TriggerClientEvent('QBCore:Notify', source, 'You do not have permission to use this command', 'error')
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {255, 255, 0},
        multiline = true,
        args = {"Elevator System", "Check server console for elevator list"}
    })
    
    print("\n=== ELEVATOR SHAFTS (Requested by " .. GetPlayerName(source) .. ") ===")
    for i, shaft in ipairs(Config.ElevatorShafts) do
        print(string.format("\n[%d] %s", i, shaft.name))
        for _, floor in ipairs(shaft.floors) do
            local jobLockInfo = ""
            if floor.jobLock then
                jobLockInfo = " [LOCKED: " .. table.concat(floor.jobLock.jobs, ", ") .. "]"
            end
            print(string.format("  - %s: %s%s", floor.id, floor.name, jobLockInfo))
        end
    end
    print("\n======================")
end, false)

-- Client event handler for admin teleport
RegisterNetEvent('custom_elevator:client:adminTeleport', function(coords, heading)
    -- This is registered here but executed client-side via TriggerClientEvent
end)

-- Log elevator usage (optional, for tracking)
RegisterNetEvent('custom_elevator:server:logUsage', function(shaftName, floorName)
    local source = source
    local playerName = GetPlayerName(source)
    print(string.format("[ELEVATOR] %s used %s to travel to %s", playerName, shaftName, floorName))
end)

-- Export functions for other resources
exports('ValidateFloorAccess', ValidateFloorAccess)
exports('GetPlayerJob', GetPlayerJob)

print("^2[Custom Elevator]^7 Server script loaded successfully")
print("^2[Custom Elevator]^7 Total elevator shafts configured: ^3" .. #Config.ElevatorShafts .. "^7")
