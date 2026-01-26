--[[
    SERVER-SIDE STATE MANAGER

    Manages the state of all elevator shafts on the server.
    This is the single source of truth for elevator positions and status.
]]

-- Global elevator state storage
ElevatorState = {}

-- Helper function to get players within radius of coordinates
local function GetPlayersInRadius(coords, radius)
    local players = {}
    local allPlayers = GetPlayers()

    for _, playerId in ipairs(allPlayers) do
        local playerPed = GetPlayerPed(playerId)
        if DoesEntityExist(playerPed) then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - coords)

            if distance <= radius then
                table.insert(players, playerId)
            end
        end
    end

    return players
end

-- Initialize state for a single elevator shaft
function InitializeElevatorState(shaftIndex)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft then
        print(string.format("^1[Custom Elevator]^7 Error: Shaft index %d does not exist", shaftIndex))
        return false
    end

    ElevatorState[shaftIndex] = {
        currentFloor = 1,                    -- Start at first floor
        targetFloor = nil,                   -- No destination
        status = ElevatorStates.IDLE,        -- Start idle
        direction = nil,                     -- No direction
        queue = {},                          -- Empty call queue
        passengersInside = {},               -- No passengers
        doorOpenTime = 0,                    -- Last time doors opened
        lastUpdateTime = GetGameTimer(),     -- For timing calculations
        locked = false,                      -- Not locked
        moveStartTime = 0                    -- When movement started
    }

    return true
end

-- Initialize all elevator states
function InitializeAllElevators()
    for shaftIndex, _ in ipairs(Config.ElevatorShafts) do
        InitializeElevatorState(shaftIndex)
    end

    print(string.format("^2[Custom Elevator]^7 Initialized %d elevator shafts", #Config.ElevatorShafts))
end

-- Get elevator state
function GetElevatorState(shaftIndex)
    return ElevatorState[shaftIndex]
end

-- Update elevator state and broadcast to nearby players
function UpdateElevatorState(shaftIndex, updates)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    -- Validate state transition if status is being changed
    if updates.status and updates.status ~= state.status then
        if not IsValidStateTransition(state.status, updates.status) then
            print(string.format(
                "^3[Custom Elevator]^7 Warning: Invalid state transition from %s to %s for shaft %d",
                state.status, updates.status, shaftIndex
            ))
            return false
        end
    end

    -- Apply updates
    for key, value in pairs(updates) do
        state[key] = value
    end

    -- Update timestamp
    state.lastUpdateTime = GetGameTimer()

    -- Broadcast to nearby players
    BroadcastStateUpdate(shaftIndex)

    return true
end

-- Broadcast state update to all nearby players
function BroadcastStateUpdate(shaftIndex)
    local state = ElevatorState[shaftIndex]
    local shaft = Config.ElevatorShafts[shaftIndex]

    if not state or not shaft then return end

    -- Get coordinates of current floor
    local currentFloor = shaft.floors[state.currentFloor]
    if not currentFloor then return end

    -- Find all players within 50m of elevator
    local nearbyPlayers = GetPlayersInRadius(currentFloor.coords, 50.0)

    -- Send state to each nearby player
    for _, playerId in ipairs(nearbyPlayers) do
        TriggerClientEvent('elevator:stateUpdate', playerId, shaftIndex, state)
    end
end

-- Set elevator to specific floor (without movement)
function SetElevatorFloor(shaftIndex, floorIndex)
    local shaft = Config.ElevatorShafts[shaftIndex]
    if not shaft or not shaft.floors[floorIndex] then
        return false
    end

    return UpdateElevatorState(shaftIndex, {
        currentFloor = floorIndex,
        targetFloor = nil,
        status = ElevatorStates.IDLE,
        direction = nil
    })
end

-- Calculate travel time between floors
function CalculateTravelTime(currentFloor, targetFloor)
    local floorDistance = math.abs(targetFloor - currentFloor)
    local baseTime = floorDistance * Config.Movement.speedPerFloor
    local accelTime = Config.Movement.acceleration + Config.Movement.deceleration

    return baseTime + accelTime
end

-- Open elevator doors
function OpenDoors(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    -- First set to opening
    UpdateElevatorState(shaftIndex, {
        status = ElevatorStates.DOORS_OPENING,
        doorOpenTime = GetGameTimer()
    })

    -- After animation time, set to fully open
    SetTimeout(Config.CallSystem.doorAnimationTime, function()
        local currentState = GetElevatorState(shaftIndex)
        if currentState and currentState.status == ElevatorStates.DOORS_OPENING then
            UpdateElevatorState(shaftIndex, {
                status = ElevatorStates.DOORS_OPEN
            })

            -- Auto-close doors after configured time
            if Config.CallSystem.autoCloseDoors then
                SetTimeout(Config.CallSystem.doorOpenTime, function()
                    AutoCloseDoors(shaftIndex)
                end)
            end
        end
    end)

    return true
end

-- Auto-close doors (only if still open and no passengers selecting floors)
function AutoCloseDoors(shaftIndex)
    local state = GetElevatorState(shaftIndex)
    if not state or state.status ~= ElevatorStates.DOORS_OPEN then
        return
    end

    -- Check if there are pending calls in queue
    if #state.queue > 0 then
        CloseDoors(shaftIndex)
    else
        -- Just go back to idle
        UpdateElevatorState(shaftIndex, {
            status = ElevatorStates.IDLE
        })
    end
end

-- Close elevator doors
function CloseDoors(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    UpdateElevatorState(shaftIndex, {
        status = ElevatorStates.DOORS_CLOSING
    })

    -- After animation, check if we need to move
    SetTimeout(Config.CallSystem.doorAnimationTime, function()
        local currentState = GetElevatorState(shaftIndex)
        if currentState and currentState.status == ElevatorStates.DOORS_CLOSING then
            if currentState.targetFloor and currentState.targetFloor ~= currentState.currentFloor then
                -- Start movement
                StartMovement(shaftIndex)
            else
                -- Just go to idle
                UpdateElevatorState(shaftIndex, {
                    status = ElevatorStates.IDLE
                })
            end
        end
    end)

    return true
end

-- Start elevator movement
function StartMovement(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state or not state.targetFloor then return false end

    local direction = state.targetFloor > state.currentFloor and "up" or "down"
    local travelTime = CalculateTravelTime(state.currentFloor, state.targetFloor)

    UpdateElevatorState(shaftIndex, {
        status = direction == "up" and ElevatorStates.MOVING_UP or ElevatorStates.MOVING_DOWN,
        direction = direction,
        moveStartTime = GetGameTimer()
    })

    -- Notify clients to start movement animations
    local shaft = Config.ElevatorShafts[shaftIndex]
    local currentFloor = shaft.floors[state.currentFloor]
    local nearbyPlayers = GetPlayersInRadius(currentFloor.coords, 50.0)

    for _, playerId in ipairs(nearbyPlayers) do
        TriggerClientEvent('elevator:startMovement', playerId, shaftIndex, direction, travelTime)
    end

    -- Progressive state updates (every second for ETA)
    local updates = math.floor(travelTime / 1000)
    for i = 1, updates do
        SetTimeout(i * 1000, function()
            BroadcastStateUpdate(shaftIndex)
        end)
    end

    -- Arrival at destination
    SetTimeout(travelTime, function()
        ArriveAtFloor(shaftIndex)
    end)

    return true
end

-- Handle arrival at destination floor
function ArriveAtFloor(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state or not state.targetFloor then return end

    local arrivedFloor = state.targetFloor

    -- Update state to arrived floor
    UpdateElevatorState(shaftIndex, {
        currentFloor = arrivedFloor,
        targetFloor = nil,
        status = ElevatorStates.DOORS_OPENING,
        direction = nil
    })

    -- Notify clients of arrival
    local shaft = Config.ElevatorShafts[shaftIndex]
    local floor = shaft.floors[arrivedFloor]
    local nearbyPlayers = GetPlayersInRadius(floor.coords, 50.0)

    for _, playerId in ipairs(nearbyPlayers) do
        TriggerClientEvent('elevator:arrival', playerId, shaftIndex, arrivedFloor, floor.name)
    end

    -- Open doors after arrival animation
    SetTimeout(Config.CallSystem.doorAnimationTime, function()
        local currentState = GetElevatorState(shaftIndex)
        if currentState and currentState.status == ElevatorStates.DOORS_OPENING then
            UpdateElevatorState(shaftIndex, {
                status = ElevatorStates.DOORS_OPEN,
                doorOpenTime = GetGameTimer()
            })

            -- Auto-close after configured time
            if Config.CallSystem.autoCloseDoors then
                SetTimeout(Config.CallSystem.doorOpenTime, function()
                    -- Process next call in queue if any
                    ProcessNextCall(shaftIndex)
                end)
            end
        end
    end)
end

-- Move elevator to target floor
function MoveElevator(shaftIndex, targetFloorIndex)
    local state = ElevatorState[shaftIndex]
    local shaft = Config.ElevatorShafts[shaftIndex]

    if not state or not shaft or not shaft.floors[targetFloorIndex] then
        return false
    end

    -- If already at target floor, just open doors
    if state.currentFloor == targetFloorIndex then
        if state.status ~= ElevatorStates.DOORS_OPEN then
            OpenDoors(shaftIndex)
        end
        return true
    end

    -- Set target floor
    UpdateElevatorState(shaftIndex, {
        targetFloor = targetFloorIndex
    })

    -- Close doors and start movement
    if state.status == ElevatorStates.DOORS_OPEN then
        CloseDoors(shaftIndex)
    elseif state.status == ElevatorStates.IDLE then
        UpdateElevatorState(shaftIndex, {
            status = ElevatorStates.DOORS_CLOSING
        })
        SetTimeout(Config.CallSystem.doorAnimationTime, function()
            StartMovement(shaftIndex)
        end)
    end

    return true
end

-- Add passenger to elevator
function AddPassenger(shaftIndex, playerId)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    if not table.contains(state.passengersInside, playerId) then
        table.insert(state.passengersInside, playerId)
    end

    return true
end

-- Remove passenger from elevator
function RemovePassenger(shaftIndex, playerId)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    for i, pid in ipairs(state.passengersInside) do
        if pid == playerId then
            table.remove(state.passengersInside, i)
            break
        end
    end

    return true
end

-- Lock/unlock elevator
function LockElevator(shaftIndex, locked, reason)
    return UpdateElevatorState(shaftIndex, {
        locked = locked,
        status = locked and ElevatorStates.MAINTENANCE or ElevatorStates.IDLE
    })
end

-- Helper function for table.contains
if not table.contains then
    function table.contains(tbl, value)
        for _, v in ipairs(tbl) do
            if v == value then
                return true
            end
        end
        return false
    end
end

-- Process next call in queue (called from queue_system)
function ProcessNextCall(shaftIndex)
    if GetNextCall then
        GetNextCall(shaftIndex)
    end
end

print("^2[Custom Elevator]^7 State manager loaded successfully")
