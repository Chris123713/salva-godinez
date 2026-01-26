--[[
    SERVER-SIDE ELEVATOR BUILDER
    Handles saving, loading, and managing elevator configurations created in-game
]]

local elevatorData = {} -- Stores elevator configurations
local configFilePath = GetResourcePath(GetCurrentResourceName()) .. '/config.lua'

-- Check if player has admin permission
local function HasAdminPermission(source)
    return IsPlayerAceAllowed(source, 'admin') or IsPlayerAceAllowed(source, 'god')
end

-- Load existing elevator shafts from config
local function LoadElevatorData()
    elevatorData = {
        shafts = Config.ElevatorShafts or {}
    }
    print('^2[Elevator Builder]^7 Loaded ' .. #elevatorData.shafts .. ' elevator shafts from config')
end

-- Save elevator data to config.lua file
local function SaveToConfigFile()
    local file = io.open(configFilePath, 'r')
    if not file then
        print('^1[Elevator Builder]^7 Could not open config.lua for reading')
        return false
    end

    local content = file:read('*all')
    file:close()

    -- Generate the elevator shafts table as Lua code
    local elevatorCode = "Config.ElevatorShafts = {\n"

    for shaftIdx, shaft in ipairs(elevatorData.shafts) do
        elevatorCode = elevatorCode .. "    \n    -- " .. shaft.name .. "\n"
        elevatorCode = elevatorCode .. "    {\n"
        elevatorCode = elevatorCode .. "        name = \"" .. shaft.name .. "\",\n"
        elevatorCode = elevatorCode .. "        floors = {\n"

        for floorIdx, floor in ipairs(shaft.floors) do
            elevatorCode = elevatorCode .. "            {\n"
            elevatorCode = elevatorCode .. string.format("                id = \"%s\",\n", floor.id)
            elevatorCode = elevatorCode .. string.format("                name = \"%s\",\n", floor.name)
            elevatorCode = elevatorCode .. string.format("                coords = vector3(%.2f, %.2f, %.2f),\n",
                floor.coords.x, floor.coords.y, floor.coords.z)
            elevatorCode = elevatorCode .. string.format("                heading = %.2f", floor.heading)

            if floor.blip then
                elevatorCode = elevatorCode .. ",\n                blip = true"
            end

            if floor.jobLock then
                elevatorCode = elevatorCode .. ",\n                jobLock = {\n"
                elevatorCode = elevatorCode .. "                    jobs = {"
                for jobIdx, job in ipairs(floor.jobLock.jobs) do
                    elevatorCode = elevatorCode .. "\"" .. job .. "\""
                    if jobIdx < #floor.jobLock.jobs then
                        elevatorCode = elevatorCode .. ", "
                    end
                end
                elevatorCode = elevatorCode .. "},\n"
                elevatorCode = elevatorCode .. "                    requireOnDuty = " .. tostring(floor.jobLock.requireOnDuty or false) .. "\n"
                elevatorCode = elevatorCode .. "                }"
            end

            elevatorCode = elevatorCode .. "\n            }"
            if floorIdx < #shaft.floors then
                elevatorCode = elevatorCode .. ","
            end
            elevatorCode = elevatorCode .. "\n"
        end

        elevatorCode = elevatorCode .. "        }\n"
        elevatorCode = elevatorCode .. "    }"
        if shaftIdx < #elevatorData.shafts then
            elevatorCode = elevatorCode .. ","
        end
        elevatorCode = elevatorCode .. "\n"
    end

    elevatorCode = elevatorCode .. "}\n"

    -- Replace the Config.ElevatorShafts section
    local pattern = "Config%.ElevatorShafts%s*=%s*{.-%n}"
    content = content:gsub(pattern, elevatorCode)

    -- Write back to file
    file = io.open(configFilePath, 'w')
    if not file then
        print('^1[Elevator Builder]^7 Could not open config.lua for writing')
        return false
    end

    file:write(content)
    file:close()

    print('^2[Elevator Builder]^7 Successfully saved elevator data to config.lua')
    return true
end

-- Initialize on resource start
CreateThread(function()
    Wait(1000) -- Wait for config to load
    LoadElevatorData()
end)

-- Get all elevator shafts
lib.callback.register('custom_elevator:builder:getShafts', function(source)
    if not HasAdminPermission(source) then return nil end
    return elevatorData.shafts
end)

-- Create new elevator shaft
lib.callback.register('custom_elevator:builder:createShaft', function(source, name)
    if not HasAdminPermission(source) then return false end

    local newShaft = {
        name = name,
        floors = {}
    }

    table.insert(elevatorData.shafts, newShaft)

    TriggerClientEvent('custom_elevator:builder:shaftsUpdated', -1, elevatorData.shafts)
    return true, #elevatorData.shafts
end)

-- Delete elevator shaft
lib.callback.register('custom_elevator:builder:deleteShaft', function(source, shaftIndex)
    if not HasAdminPermission(source) then return false end

    if elevatorData.shafts[shaftIndex] then
        table.remove(elevatorData.shafts, shaftIndex)
        TriggerClientEvent('custom_elevator:builder:shaftsUpdated', -1, elevatorData.shafts)
        return true
    end

    return false
end)

-- Add floor to shaft
lib.callback.register('custom_elevator:builder:addFloor', function(source, shaftIndex, floorData)
    if not HasAdminPermission(source) then return false end

    if elevatorData.shafts[shaftIndex] then
        table.insert(elevatorData.shafts[shaftIndex].floors, floorData)
        TriggerClientEvent('custom_elevator:builder:shaftsUpdated', -1, elevatorData.shafts)
        return true
    end

    return false
end)

-- Update floor in shaft
lib.callback.register('custom_elevator:builder:updateFloor', function(source, shaftIndex, floorIndex, floorData)
    if not HasAdminPermission(source) then return false end

    if elevatorData.shafts[shaftIndex] and elevatorData.shafts[shaftIndex].floors[floorIndex] then
        elevatorData.shafts[shaftIndex].floors[floorIndex] = floorData
        TriggerClientEvent('custom_elevator:builder:shaftsUpdated', -1, elevatorData.shafts)
        return true
    end

    return false
end)

-- Delete floor from shaft
lib.callback.register('custom_elevator:builder:deleteFloor', function(source, shaftIndex, floorIndex)
    if not HasAdminPermission(source) then return false end

    if elevatorData.shafts[shaftIndex] and elevatorData.shafts[shaftIndex].floors[floorIndex] then
        table.remove(elevatorData.shafts[shaftIndex].floors, floorIndex)
        TriggerClientEvent('custom_elevator:builder:shaftsUpdated', -1, elevatorData.shafts)
        return true
    end

    return false
end)

-- Save all changes to config file
lib.callback.register('custom_elevator:builder:saveToFile', function(source)
    if not HasAdminPermission(source) then return false end

    local success = SaveToConfigFile()
    if success then
        -- Update the Config table in memory
        Config.ElevatorShafts = elevatorData.shafts

        -- Notify all clients to reload elevators
        TriggerClientEvent('custom_elevator:reloadElevators', -1)
    end

    return success
end)

-- Admin command to open builder
RegisterCommand('elevatorbuilder', function(source, args, rawCommand)
    print('^3[Elevator Builder]^7 Command /elevatorbuilder used by player ' .. source)

    if not HasAdminPermission(source) then
        print('^1[Elevator Builder]^7 Permission denied for player ' .. source)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Elevator Builder',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    print('^2[Elevator Builder]^7 Opening builder for player ' .. source)
    TriggerClientEvent('custom_elevator:builder:open', source)
end, false)

RegisterCommand('eb', function(source, args, rawCommand)
    print('^3[Elevator Builder]^7 Command /eb used by player ' .. source)

    if not HasAdminPermission(source) then
        print('^1[Elevator Builder]^7 Permission denied for player ' .. source)
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Elevator Builder',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    print('^2[Elevator Builder]^7 Opening builder for player ' .. source)
    TriggerClientEvent('custom_elevator:builder:open', source)
end, false)

print('^2[Elevator Builder]^7 Commands registered: /elevatorbuilder, /eb')
