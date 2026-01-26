--[[
    ELEVATOR SYNCHRONIZATION & CALLBACKS

    Handles client-server communication using lib.callback for security.
    All elevator actions go through server validation before execution.
]]

-- Rate limiting storage
local PlayerCooldowns = {}
local COOLDOWN_TIME = 2000  -- 2 seconds between elevator actions

-- Helper function to check cooldown
local function IsPlayerOnCooldown(source)
    local lastUse = PlayerCooldowns[source]
    if not lastUse then
        return false
    end

    local timeSinceLastUse = GetGameTimer() - lastUse
    return timeSinceLastUse < COOLDOWN_TIME
end

-- Helper function to set cooldown
local function SetPlayerCooldown(source)
    PlayerCooldowns[source] = GetGameTimer()
end

-- Helper function to get floor by index
local function GetFloorByIndex(shaftIndex, floorIndex)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then return nil end

    return shaft.floors[floorIndex]
end

-- Helper function to validate player distance
local function ValidatePlayerDistance(source, coords, maxDistance)
    local playerPed = GetPlayerPed(source)
    if not DoesEntityExist(playerPed) then
        return false
    end

    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - coords)

    return distance <= maxDistance
end

-- Log security events
local function LogSecurityEvent(source, event, details)
    local playerName = GetPlayerName(source)
    print(string.format(
        "^1[Custom Elevator - Security]^7 Player %s (%d): %s - %s",
        playerName, source, event, tostring(details)
    ))
end

--[[
    CALLBACK: Call Elevator to Floor

    Player requests elevator to come to their current floor
]]
lib.callback.register('elevator:callToFloor', function(source, shaftIndex, floorIndex)
    -- 1. Validate parameters
    if not shaftIndex or not floorIndex then
        return {success = false, message = "Invalid parameters"}
    end

    -- 2. Validate shaft and floor exist
    local floor = GetFloorByIndex(shaftIndex, floorIndex)
    if not floor then
        return {success = false, message = "Invalid elevator or floor"}
    end

    -- 3. Check cooldown
    if IsPlayerOnCooldown(source) then
        return {success = false, message = "Please wait before calling elevator again"}
    end

    -- 4. Validate distance (anti-cheat - player must be within 10m)
    if not ValidatePlayerDistance(source, floor.coords, 10.0) then
        LogSecurityEvent(source, "Call elevator from too far", string.format("Shaft %d, Floor %d", shaftIndex, floorIndex))
        return {success = false, message = "You are too far from the elevator"}
    end

    -- 5. Validate access permissions
    local hasAccess, reason = ValidateFloorAccess(source, shaftIndex, floor.id)
    if not hasAccess then
        return {success = false, message = reason or "Access denied"}
    end

    -- 6. Add to queue
    local added = AddCallToQueue(shaftIndex, floorIndex, nil)
    if not added then
        return {success = false, message = "Failed to add call to queue"}
    end

    -- 7. Set cooldown
    SetPlayerCooldown(source)

    -- 8. Calculate ETA
    local eta = CalculateETA(shaftIndex, floorIndex)

    -- 9. Log usage
    local playerName = GetPlayerName(source)
    print(string.format(
        "^2[Custom Elevator]^7 %s called elevator (Shaft %d) to %s (ETA: %ds)",
        playerName, shaftIndex, floor.name, eta
    ))

    return {
        success = true,
        eta = eta,
        message = string.format("Elevator arriving in %d seconds", eta)
    }
end)

--[[
    CALLBACK: Select Destination Floor

    Player selects a destination floor from inside the elevator
]]
lib.callback.register('elevator:selectDestination', function(source, shaftIndex, targetFloorIndex)
    -- 1. Validate parameters
    if not shaftIndex or not targetFloorIndex then
        return {success = false, message = "Invalid parameters"}
    end

    -- 2. Get elevator state
    local state = GetElevatorState(shaftIndex)
    if not state then
        return {success = false, message = "Invalid elevator"}
    end

    -- 3. Validate target floor exists
    local targetFloor = GetFloorByIndex(shaftIndex, targetFloorIndex)
    if not targetFloor then
        return {success = false, message = "Invalid floor"}
    end

    -- 4. Check if elevator doors are open
    if state.status ~= ElevatorStates.DOORS_OPEN then
        return {success = false, message = "Please wait for doors to open"}
    end

    -- 5. Validate player is near elevator
    local currentFloor = GetFloorByIndex(shaftIndex, state.currentFloor)
    if not ValidatePlayerDistance(source, currentFloor.coords, 5.0) then
        return {success = false, message = "You must be inside the elevator"}
    end

    -- 6. Check cooldown
    if IsPlayerOnCooldown(source) then
        return {success = false, message = "Please wait"}
    end

    -- 7. Validate access to destination floor
    local hasAccess, reason = ValidateFloorAccess(source, shaftIndex, targetFloor.id)
    if not hasAccess then
        return {success = false, message = reason or "Access denied to this floor"}
    end

    -- 8. If already at target floor, just notify
    if state.currentFloor == targetFloorIndex then
        return {success = true, message = "You are already at this floor", alreadyHere = true}
    end

    -- 9. Set cooldown
    SetPlayerCooldown(source)

    -- 10. Close doors and move
    MoveElevator(shaftIndex, targetFloorIndex)

    -- 11. Calculate travel time
    local travelTime = CalculateTravelTime(state.currentFloor, targetFloorIndex)

    -- 12. Log usage
    local playerName = GetPlayerName(source)
    print(string.format(
        "^2[Custom Elevator]^7 %s traveling from %s to %s (Shaft %d, %ds)",
        playerName, currentFloor.name, targetFloor.name, shaftIndex, math.ceil(travelTime / 1000)
    ))

    return {
        success = true,
        travelTime = travelTime,
        message = string.format("Traveling to %s", targetFloor.name)
    }
end)

--[[
    CALLBACK: Get Elevator State

    Client requests current state of an elevator
]]
lib.callback.register('elevator:getState', function(source, shaftIndex)
    local state = GetElevatorState(shaftIndex)
    if not state then
        return nil
    end

    -- Return sanitized state (don't expose internal IDs if not needed)
    return {
        currentFloor = state.currentFloor,
        targetFloor = state.targetFloor,
        status = state.status,
        direction = state.direction,
        queueSize = #state.queue,
        locked = state.locked
    }
end)

--[[
    CALLBACK: Get Queue Information

    Admin/debug command to see queue status
]]
lib.callback.register('elevator:getQueueInfo', function(source, shaftIndex)
    -- Optional: Add admin check here
    return GetQueueInfo(shaftIndex)
end)

--[[
    EVENT: Request State Update

    Client requests a state update for specific elevator
]]
RegisterNetEvent('elevator:requestStateUpdate', function(shaftIndex)
    local source = source

    local state = GetElevatorState(shaftIndex)
    if state then
        TriggerClientEvent('elevator:stateUpdate', source, shaftIndex, state)
    end
end)

--[[
    EVENT: Player Entering Elevator

    Track when player enters elevator area (for passenger management)
]]
RegisterNetEvent('elevator:playerEntered', function(shaftIndex)
    local source = source
    AddPassenger(shaftIndex, source)
end)

--[[
    EVENT: Player Exiting Elevator

    Track when player leaves elevator area
]]
RegisterNetEvent('elevator:playerExited', function(shaftIndex)
    local source = source
    RemovePassenger(shaftIndex, source)
end)

--[[
    Cleanup on player disconnect
]]
AddEventHandler('playerDropped', function(reason)
    local source = source

    -- Remove player from all elevator passenger lists
    for shaftIndex, _ in ipairs(Config.ElevatorShafts) do
        RemovePassenger(shaftIndex, source)
    end

    -- Clear cooldown
    PlayerCooldowns[source] = nil
end)

--[[
    Periodic cleanup of cooldowns (every 5 minutes)
]]
CreateThread(function()
    while true do
        Wait(300000)  -- 5 minutes

        local currentTime = GetGameTimer()
        for playerId, lastUse in pairs(PlayerCooldowns) do
            if currentTime - lastUse > 300000 then  -- 5 minutes old
                PlayerCooldowns[playerId] = nil
            end
        end
    end
end)

print("^2[Custom Elevator]^7 Sync & callbacks loaded successfully")
