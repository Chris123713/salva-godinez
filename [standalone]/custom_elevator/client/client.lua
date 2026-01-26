-- Initialize framework
local QBCore = nil
local ESX = nil
local PlayerData = {}

if Config.Framework == 'qb-core' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- Local variables
local isNearElevator = false
local currentShaftIndex = nil
local currentFloorId = nil
local isMenuOpen = false
local elevatorBlips = {}
local customElevators = {}

-- Client-side elevator state cache (synced from server)
ClientElevatorState = {}

-- Get player job information
local function GetPlayerJob()
    if Config.Framework == 'qb-core' and QBCore then
        local player = QBCore.Functions.GetPlayerData()
        return player.job.name, player.job.onduty
    elseif Config.Framework == 'esx' and ESX then
        local playerData = ESX.GetPlayerData()
        return playerData.job.name, true
    else
        return 'unemployed', false
    end
end

-- Check if player has access to a floor
local function HasAccessToFloor(floor)
    if not floor.jobLock then
        return true
    end
    
    local playerJob, onDuty = GetPlayerJob()
    
    -- Check if player has required job
    local hasJob = false
    for _, job in ipairs(floor.jobLock.jobs) do
        if job == playerJob then
            hasJob = true
            break
        end
    end
    
    if not hasJob then
        return false
    end
    
    -- Check on-duty requirement
    if floor.jobLock.requireOnDuty and not onDuty then
        return false
    end
    
    return true
end

-- Find which shaft and floor the player is currently at
local function FindCurrentElevator()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for shaftIndex, shaft in ipairs(Config.ElevatorShafts) do
        for _, floor in ipairs(shaft.floors) do
            local markerCoords = floor.markerCoords or floor.coords
            local distance = #(playerCoords - markerCoords)
            
            if distance < Config.InteractionDistance then
                return shaftIndex, floor.id
            end
        end
    end
    
    return nil, nil
end

-- Create blips for elevator entrances
local function CreateElevatorBlips()
    if not Config.ShowBlips then return end
    
    for shaftIndex, shaft in ipairs(Config.ElevatorShafts) do
        for _, floor in ipairs(shaft.floors) do
            if floor.blip then
                local blip = AddBlipForCoord(floor.coords.x, floor.coords.y, floor.coords.z)
                SetBlipSprite(blip, Config.BlipSprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, Config.BlipScale)
                SetBlipColour(blip, Config.BlipColor)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(shaft.name)
                EndTextCommandSetBlipName(blip)
                table.insert(elevatorBlips, blip)
            end
        end
    end
end

-- Remove all elevator blips
local function RemoveElevatorBlips()
    for _, blip in ipairs(elevatorBlips) do
        RemoveBlip(blip)
    end
    elevatorBlips = {}
end

-- Open elevator menu
local function OpenElevatorMenu(shaftIndex, currentFloorId)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then return end

    currentShaftIndex = shaftIndex

    local availableFloors = {}
    local playerJob = GetPlayerJob()

    for floorIndex, floor in ipairs(shaft.floors) do
        -- Don't show current floor in menu
        if floor.id ~= currentFloorId then
            local hasAccess = HasAccessToFloor(floor)
            table.insert(availableFloors, {
                id = floor.id,
                floorIndex = floorIndex,  -- Add floor index for new system
                name = floor.name,
                locked = not hasAccess,
                coords = floor.coords,
                heading = floor.heading
            })
        end
    end

    isMenuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openMenu',
        shaftName = shaft.name,
        floors = availableFloors
    })
end

-- Close elevator menu
local function CloseElevatorMenu()
    isMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeMenu'
    })
end

-- Teleport player to floor
local function TeleportToFloor(coords, heading)
    local playerPed = PlayerPedId()
    
    -- Fade out screen
    if Config.FadeScreen then
        DoScreenFadeOut(Config.FadeTime)
        Wait(Config.FadeTime)
    end
    
    -- Wait for "elevator movement"
    Wait(Config.TeleportDelay)
    
    -- Teleport player
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(playerPed, heading)
    
    -- Fade in screen
    if Config.FadeScreen then
        Wait(500)
        DoScreenFadeIn(Config.FadeTime)
    end
    
    Config.Notify("You have arrived at your destination", "success")
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseElevatorMenu()
    cb('ok')
end)

RegisterNUICallback('selectFloor', function(data, cb)
    CloseElevatorMenu()

    if not Config.CallSystem.enabled then
        -- Old teleport system
        if data.floorId and data.coords and data.heading then
            local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
            TeleportToFloor(coords, data.heading)
        end
    else
        -- New elevator system - use lib.callback
        if data.floorIndex and currentShaftIndex then
            lib.callback('elevator:selectDestination', false, function(result)
                if result.success then
                    if not result.alreadyHere then
                        Config.Notify(result.message or "Elevator moving", "success")
                    end
                else
                    Config.Notify(result.message or "Cannot select floor", "error")
                end
            end, currentShaftIndex, data.floorIndex)
        end
    end

    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    cb('ok')
end)

-- Main thread for detecting elevator proximity
CreateThread(function()
    while true do
        local sleep = 1000
        local shaftIndex, floorId = FindCurrentElevator()
        
        if shaftIndex then
            sleep = 0
            isNearElevator = true
            currentShaftIndex = shaftIndex
            currentFloorId = floorId
            
            -- Draw marker
            if Config.DrawMarkers then
                local shaft = Config.ElevatorShafts[shaftIndex]
                for _, floor in ipairs(shaft.floors) do
                    if floor.id == floorId then
                        local markerCoords = floor.markerCoords or floor.coords
                        DrawMarker(
                            Config.MarkerType,
                            markerCoords.x, markerCoords.y, markerCoords.z - 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                            Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                            false, false, 2, false, nil, nil, false
                        )
                        break
                    end
                end
            end
            
            -- Show help text
            if not isMenuOpen then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentString("Press ~INPUT_CONTEXT~ to call elevator")
                EndTextCommandDisplayHelp(0, false, true, -1)
            end
            
            -- Check for key press
            if IsControlJustReleased(0, Config.InteractionKey) and not isMenuOpen then
                OpenElevatorMenu(shaftIndex, floorId)
            end
        else
            isNearElevator = false
            currentShaftIndex = nil
            currentFloorId = nil
        end
        
        Wait(sleep)
    end
end)

-- Handle ESC key to close menu
CreateThread(function()
    while true do
        Wait(0)
        if isMenuOpen then
            DisableControlAction(0, 322, true) -- ESC key
            DisableControlAction(0, 200, true) -- ESC key alternative
            
            if IsDisabledControlJustPressed(0, 322) or IsDisabledControlJustPressed(0, 200) then
                CloseElevatorMenu()
            end
        end
    end
end)

-- Initialize on resource start
CreateThread(function()
    Wait(1000)
    CreateElevatorBlips()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveElevatorBlips()
        if isMenuOpen then
            CloseElevatorMenu()
        end
    end
end)

-- Update player data on job change (QBCore)
if Config.Framework == 'qb-core' then
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        if isMenuOpen then
            CloseElevatorMenu()
        end
    end)
    
    RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
        if isMenuOpen then
            CloseElevatorMenu()
        end
    end)
end

-- Update player data on job change (ESX)
if Config.Framework == 'esx' then
    RegisterNetEvent('esx:setJob', function(job)
        if isMenuOpen then
            CloseElevatorMenu()
        end
    end)
end

-- ==========================================
-- NEW ADVANCED ELEVATOR SYSTEM FUNCTIONS
-- ==========================================

-- Receive state updates from server
RegisterNetEvent('elevator:stateUpdate', function(shaftIndex, newState)
    ClientElevatorState[shaftIndex] = newState

    -- Update NUI if menu is open for this elevator
    if isMenuOpen and currentShaftIndex == shaftIndex then
        local shaft = Config.ElevatorShafts[shaftIndex]
        local currentFloorName = shaft.floors[newState.currentFloor] and shaft.floors[newState.currentFloor].name or "Unknown"

        SendNUIMessage({
            action = 'updateElevatorStatus',
            status = newState.status,
            currentFloor = currentFloorName,
            direction = newState.direction
        })
    end
end)

-- Handle elevator starting movement
RegisterNetEvent('elevator:startMovement', function(shaftIndex, direction, duration)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then return end

    local state = ClientElevatorState[shaftIndex]
    if not state then return end

    local currentFloor = shaft.floors[state.currentFloor]
    if not currentFloor then return end

    -- Play movement animation and sounds
    PlayMovementAnimation(direction, duration)
    PlayMovementLoop(duration, currentFloor.coords)
    PlayElevatorSound('doorClose', currentFloor.coords)
end)

-- Handle elevator arrival
RegisterNetEvent('elevator:arrival', function(shaftIndex, floorIndex, floorName)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then return end

    local floor = shaft.floors[floorIndex]
    if not floor then return end

    -- Play arrival sound and animation
    PlayElevatorSound('ding', floor.coords)
    PlayDoorOpenAnimation()

    -- Notify player
    Config.Notify(string.format("Arrived at %s", floorName), "success")
end)

-- Call elevator to a specific floor
function CallElevatorToFloor(shaftIndex, floorIndex)
    if not Config.CallSystem.enabled then
        -- Fallback to old system
        OpenElevatorMenu(shaftIndex, Config.ElevatorShafts[shaftIndex].floors[floorIndex].id)
        return
    end

    -- Call via lib.callback (secure)
    lib.callback('elevator:callToFloor', false, function(result)
        if result.success then
            if Config.CallSystem.showArrivalTime and result.eta then
                Config.Notify(result.message, "success")
            else
                Config.Notify("Elevator called", "success")
            end
        else
            Config.Notify(result.message or "Failed to call elevator", "error")
        end
    end, shaftIndex, floorIndex)
end

-- Open floor selection menu (when inside elevator)
function OpenFloorSelectionMenu(shaftIndex, currentFloorIndex)
    OpenElevatorMenu(shaftIndex, Config.ElevatorShafts[shaftIndex].floors[currentFloorIndex].id)
end

-- Get floor name by index
function GetFloorName(shaftIndex, floorIndex)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft or not shaft.floors[floorIndex] then
        return "Unknown"
    end

    return shaft.floors[floorIndex].name
end

-- Load custom elevators and initialize on resource start
CreateThread(function()
    -- The elevators are already loaded from config.lua
    -- No need to fetch from server on startup since config is already loaded

    -- Request state updates
    Wait(2000)
    for shaftIndex, _ in ipairs(Config.ElevatorShafts) do
        TriggerServerEvent('elevator:requestStateUpdate', shaftIndex)
    end

    -- Create blips after elevators are loaded
    CreateElevatorBlips()
end)

-- Reload elevators when builder saves changes
RegisterNetEvent('custom_elevator:builder:reload', function(elevatorData)
    -- Remove old blips
    RemoveElevatorBlips()

    -- Reset config to original (remove custom elevators)
    -- Note: This assumes the first X elevators in Config are from config.lua
    local originalCount = #Config.ElevatorShafts - #customElevators
    for i = #Config.ElevatorShafts, originalCount + 1, -1 do
        Config.ElevatorShafts[i] = nil
    end

    -- Add new custom elevators
    customElevators = elevatorData
    for _, customShaft in ipairs(customElevators) do
        table.insert(Config.ElevatorShafts, customShaft)
    end

    -- Recreate blips
    CreateElevatorBlips()

    print('^2[Elevator System]^7 Reloaded with ' .. #customElevators .. ' custom elevators')
end)

-- Export functions for other resources
exports('OpenElevator', function(shaftIndex, floorId)
    OpenElevatorMenu(shaftIndex, floorId)
end)

exports('TeleportToFloor', function(coords, heading)
    TeleportToFloor(coords, heading)
end)

exports('CallElevator', function(shaftIndex, floorIndex)
    CallElevatorToFloor(shaftIndex, floorIndex)
end)

exports('GetElevatorState', function(shaftIndex)
    return ClientElevatorState[shaftIndex]
end)
