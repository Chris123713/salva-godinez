--[[
    Advanced MultiJob - Clock-In Zones
    Handles physical clock-in location requirements and proximity checking
]]

local QBX = exports.qbx_core
local currentLocationData = {
    atLocation = false,
    locationName = 'Unknown',
    distance = 999
}

-- Check if player is near a clock-in location for their current job
local function CheckLocationProximity()
    if not Config.RequirePhysicalClockin then
        return true, 'Any Location', 0
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerData = QBX:GetPlayerData()

    if not playerData or not playerData.job then
        return false, 'Unknown', 999
    end

    local jobName = playerData.job.name
    local jobLocations = Config.ClockinLocations[jobName]

    if not jobLocations or #jobLocations == 0 then
        -- No specific locations for this job, allow clock-in anywhere
        return true, 'Field Work', 0
    end

    -- Find nearest location
    local nearestLocation = nil
    local nearestDistance = 999

    for _, location in ipairs(jobLocations) do
        local distance = #(playerCoords - location.coords)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestLocation = location
        end
    end

    if nearestLocation then
        local atLocation = nearestDistance <= Config.MaxClockinDistance
        return atLocation, nearestLocation.name, nearestDistance
    end

    return false, 'Unknown', 999
end

-- Update UI with location status
local function UpdateLocationUI()
    local atLocation, locationName, distance = CheckLocationProximity()

    currentLocationData = {
        atLocation = atLocation,
        locationName = locationName,
        distance = distance
    }

    -- Send to NUI
    SendNUIMessage({
        action = 'updateLocation',
        atLocation = atLocation,
        locationName = locationName,
        distance = distance
    })
end

-- Thread to continuously check player location
CreateThread(function()
    while true do
        Wait(1000) -- Check every second

        -- Only check if menu might be open or player is on duty
        local playerData = QBX:GetPlayerData()
        if playerData and playerData.job then
            UpdateLocationUI()
        end
    end
end)

-- Export for other scripts to check location
exports('IsAtClockinLocation', function()
    return CheckLocationProximity()
end)

exports('GetLocationData', function()
    return currentLocationData
end)

-- Callback for server to check if player is at location
lib.callback.register('multijob:client:checkLocation', function()
    local atLocation, locationName, distance = CheckLocationProximity()
    return atLocation
end)

-- Callback for server to get location name
lib.callback.register('multijob:client:getLocationName', function()
    local atLocation, locationName, distance = CheckLocationProximity()
    return locationName
end)

-- Hook into menu opening to update location immediately
RegisterNUICallback('refreshData', function(data, cb)
    UpdateLocationUI()
    cb('ok')
end)

-- Continuous update thread for NUI
local menuOpen = false
local lastJobName = nil

-- Listen for menu open/close from NUI
RegisterNUICallback('menuOpened', function(data, cb)
    menuOpen = true
    if Config.Debug then
        print('^2[MultiJob Client]^7 Menu opened - starting updates')
    end
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    menuOpen = false
    if Config.Debug then
        print('^2[MultiJob Client]^7 Menu closed - stopping updates')
    end
    cb('ok')
end)

-- Thread to continuously update NUI while menu is open
CreateThread(function()
    while true do
        Wait(500) -- Update every 500ms

        if menuOpen then
            local playerData = QBX:GetPlayerData()
            if playerData and playerData.job then
                -- Send location update
                local atLocation, locationName, distance = CheckLocationProximity()

                if Config.Debug and (not lastJobName or lastJobName ~= playerData.job.name) then
                    print('^3[MultiJob Client]^7 Sending updates for job: ' .. playerData.job.name)
                    print('  At Location: ' .. tostring(atLocation))
                    print('  Location: ' .. locationName)
                    print('  On Duty: ' .. tostring(playerData.job.onduty))
                    lastJobName = playerData.job.name
                end

                SendNUIMessage({
                    action = 'updateLocation',
                    atLocation = atLocation,
                    locationName = locationName,
                    distance = distance
                })

                -- Send theme update
                local theme = Config.JobThemes[playerData.job.name]
                if theme then
                    SendNUIMessage({
                        action = 'updateTheme',
                        theme = theme
                    })
                end

                -- Send enhanced job data
                SendNUIMessage({
                    action = 'updateData',
                    data = {
                        currentJob = {
                            department = theme and theme.name or playerData.job.label,
                            theme = theme,
                            atLocation = atLocation,
                            locationName = locationName,
                            distance = distance,
                            onduty = playerData.job.onduty
                        }
                    }
                })

                -- Get clock-in time from server if on duty
                if playerData.job.onduty and Config.EnableTimeTracking then
                    lib.callback('multijob:server:getShiftStartTime', false, function(timestamp)
                        if timestamp then
                            SendNUIMessage({
                                action = 'updateData',
                                data = {
                                    currentJob = {
                                        clockInTime = timestamp,
                                        onduty = true
                                    }
                                }
                            })
                        end
                    end)
                end
            end
        end
    end
end)

-- Create ox_target zones for each job's clock-in locations
CreateThread(function()
    Wait(1000) -- Wait for ox_target to load

    for jobName, locations in pairs(Config.ClockinLocations) do
        for i, location in ipairs(locations) do
            exports.ox_target:addBoxZone({
                coords = location.coords,
                size = vec3(2.0, 2.0, 2.0),
                rotation = 0,
                debug = Config.Debug,
                options = {
                    {
                        name = 'clockin_' .. jobName .. '_' .. i,
                        icon = 'fas fa-clock',
                        label = 'Clock In/Out',
                        canInteract = function()
                            local playerData = QBX:GetPlayerData()
                            return playerData and playerData.job and playerData.job.name == jobName
                        end,
                        onSelect = function()
                            -- Open the job menu when interacting with clock-in point
                            ExecuteCommand(Config.Command)
                        end
                    }
                }
            })

            if Config.Debug then
                print('^2[MultiJob]^7 Created clock-in zone for ' .. jobName .. ' at ' .. location.name)
            end
        end
    end
end)

-- Apply job theme when job changes
AddEventHandler('QBCore:Client:OnJobUpdate', function(jobInfo)
    Wait(500) -- Small delay to ensure data is updated

    local theme = Config.JobThemes[jobInfo.name]
    if theme then
        SendNUIMessage({
            action = 'updateTheme',
            theme = theme
        })
    end

    -- Update location status for new job
    UpdateLocationUI()
end)

-- Send theme on resource start/player loaded
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)

    local playerData = QBX:GetPlayerData()
    if playerData and playerData.job then
        local theme = Config.JobThemes[playerData.job.name]
        if theme then
            SendNUIMessage({
                action = 'updateTheme',
                theme = theme
            })
        end
    end
end)

-- Debug command to check location and theme
if Config.Debug then
    RegisterCommand('jobdebug', function()
        local playerData = QBX:GetPlayerData()
        if playerData and playerData.job then
            local atLocation, locationName, distance = CheckLocationProximity()
            local theme = Config.JobThemes[playerData.job.name]

            print('^3[MultiJob Debug]^7')
            print('  Job: ' .. playerData.job.name .. ' (' .. playerData.job.label .. ')')
            print('  On Duty: ' .. tostring(playerData.job.onduty))
            print('  At Location: ' .. tostring(atLocation))
            print('  Location: ' .. locationName)
            print('  Distance: ' .. string.format('%.2f', distance) .. 'm')
            print('  Theme Color: ' .. (theme and theme.color or 'none'))
            print('  Department: ' .. (theme and theme.name or 'none'))
        else
            print('^1[MultiJob Debug]^7 No player data found')
        end
    end, false)

    print('^2[MultiJob]^7 Clock-in zones loaded successfully')
    print('^2[MultiJob]^7 Use /jobdebug to check location and theme data')
end
