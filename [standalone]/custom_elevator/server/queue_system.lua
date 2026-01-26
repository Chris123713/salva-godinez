--[[
    ELEVATOR QUEUE SYSTEM

    Manages the call queue for each elevator shaft.
    Implements priority-based queue processing for efficient elevator routing.
]]

-- Add call to elevator queue
function AddCallToQueue(shaftIndex, floorIndex, direction)
    local state = ElevatorState[shaftIndex]
    local shaft = Config.ElevatorShafts[shaftIndex]

    if not state or not shaft or not shaft.floors[floorIndex] then
        return false
    end

    -- Don't queue if already at this floor with doors open
    if state.currentFloor == floorIndex and state.status == ElevatorStates.DOORS_OPEN then
        return true
    end

    -- Check if this floor is already in queue
    for _, call in ipairs(state.queue) do
        if call.floorIndex == floorIndex then
            -- Already queued, don't add duplicate
            return true
        end
    end

    -- Add to queue
    local call = {
        floorIndex = floorIndex,
        direction = direction,  -- Can be nil, "up", or "down"
        timestamp = GetGameTimer(),
        priority = CalculateCallPriority(shaftIndex, floorIndex, direction)
    }

    table.insert(state.queue, call)

    -- Sort queue by priority (lower number = higher priority)
    table.sort(state.queue, function(a, b)
        return a.priority < b.priority
    end)

    print(string.format(
        "^3[Custom Elevator]^7 Shaft %d: Added call for floor %d (Queue size: %d)",
        shaftIndex, floorIndex, #state.queue
    ))

    -- Broadcast updated state
    BroadcastStateUpdate(shaftIndex)

    -- Process queue if elevator is idle
    if state.status == ElevatorStates.IDLE or state.status == ElevatorStates.DOORS_OPEN then
        ProcessQueue(shaftIndex)
    end

    return true
end

-- Calculate priority for a call
function CalculateCallPriority(shaftIndex, targetFloorIndex, requestDirection)
    local state = ElevatorState[shaftIndex]
    if not state then return 999 end

    local currentFloor = state.currentFloor
    local distance = math.abs(targetFloorIndex - currentFloor)

    local priority = distance

    -- If elevator is moving, check if call is in same direction
    if IsElevatorMoving(state.status) then
        local elevatorDirection = state.direction
        local callDirection = targetFloorIndex > currentFloor and "up" or "down"

        if elevatorDirection ~= callDirection then
            priority = priority + 10  -- Lower priority if different direction
        end

        -- Additional penalty if already moving
        priority = priority + 5
    end

    return priority
end

-- Process the elevator queue
function ProcessQueue(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    -- Don't process if elevator is moving or in transition
    if IsElevatorMoving(state.status) or AreDoorsInTransition(state.status) then
        return false
    end

    -- Don't process if locked
    if state.locked then
        return false
    end

    -- Get next call from queue
    local nextCall = GetNextCall(shaftIndex)
    if not nextCall then
        return false
    end

    print(string.format(
        "^3[Custom Elevator]^7 Shaft %d: Processing call for floor %d",
        shaftIndex, nextCall.floorIndex
    ))

    -- Move elevator to the called floor
    MoveElevator(shaftIndex, nextCall.floorIndex)

    return true
end

-- Get and remove next call from queue
function GetNextCall(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state or #state.queue == 0 then
        return nil
    end

    -- Remove and return first call (highest priority)
    local nextCall = table.remove(state.queue, 1)

    -- Broadcast updated state
    BroadcastStateUpdate(shaftIndex)

    return nextCall
end

-- Remove specific floor from queue
function RemoveCallFromQueue(shaftIndex, floorIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    for i, call in ipairs(state.queue) do
        if call.floorIndex == floorIndex then
            table.remove(state.queue, i)
            BroadcastStateUpdate(shaftIndex)
            return true
        end
    end

    return false
end

-- Clear entire queue
function ClearQueue(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return false end

    state.queue = {}
    BroadcastStateUpdate(shaftIndex)

    print(string.format("^3[Custom Elevator]^7 Shaft %d: Queue cleared", shaftIndex))
    return true
end

-- Get queue position for a floor
function GetQueuePosition(shaftIndex, floorIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return nil end

    for i, call in ipairs(state.queue) do
        if call.floorIndex == floorIndex then
            return i
        end
    end

    return nil
end

-- Calculate ETA (estimated time of arrival) in milliseconds
function CalculateETA(shaftIndex, targetFloorIndex)
    local state = ElevatorState[shaftIndex]
    local shaft = Config.ElevatorShafts[shaftIndex]

    if not state or not shaft then return 0 end

    local totalTime = 0

    -- If elevator is currently moving, add remaining travel time
    if IsElevatorMoving(state.status) and state.targetFloor then
        local remainingTime = CalculateTravelTime(state.currentFloor, state.targetFloor)
        local elapsed = GetGameTimer() - state.moveStartTime
        totalTime = totalTime + math.max(0, remainingTime - elapsed)
    end

    -- If doors are in transition, add that time
    if AreDoorsInTransition(state.status) then
        totalTime = totalTime + Config.CallSystem.doorAnimationTime
    end

    -- If doors are open, add door closing time
    if state.status == ElevatorStates.DOORS_OPEN then
        local doorOpenDuration = GetGameTimer() - state.doorOpenTime
        local remainingDoorTime = math.max(0, Config.CallSystem.doorOpenTime - doorOpenDuration)
        totalTime = totalTime + remainingDoorTime + Config.CallSystem.doorAnimationTime
    end

    -- Add time for any calls before this one in queue
    local position = GetQueuePosition(shaftIndex, targetFloorIndex)
    if position then
        local currentFloor = state.targetFloor or state.currentFloor

        for i = 1, position - 1 do
            local call = state.queue[i]
            -- Add travel time to that floor
            totalTime = totalTime + CalculateTravelTime(currentFloor, call.floorIndex)
            -- Add door operation times
            totalTime = totalTime + (Config.CallSystem.doorAnimationTime * 2) + Config.CallSystem.doorOpenTime
            currentFloor = call.floorIndex
        end

        -- Add travel time from last stop to target
        totalTime = totalTime + CalculateTravelTime(currentFloor, targetFloorIndex)
    else
        -- Not in queue, direct travel
        local startFloor = state.targetFloor or state.currentFloor
        totalTime = totalTime + CalculateTravelTime(startFloor, targetFloorIndex)
    end

    -- Add door opening time at destination
    totalTime = totalTime + Config.CallSystem.doorAnimationTime

    return math.ceil(totalTime / 1000)  -- Return in seconds
end

-- Get queue size
function GetQueueSize(shaftIndex)
    local state = ElevatorState[shaftIndex]
    if not state then return 0 end

    return #state.queue
end

-- Get full queue information
function GetQueueInfo(shaftIndex)
    local state = ElevatorState[shaftIndex]
    local shaft = Config.ElevatorShafts[shaftIndex]

    if not state or not shaft then return nil end

    local queueInfo = {}
    for i, call in ipairs(state.queue) do
        local floor = shaft.floors[call.floorIndex]
        table.insert(queueInfo, {
            position = i,
            floorIndex = call.floorIndex,
            floorName = floor and floor.name or "Unknown",
            priority = call.priority,
            eta = CalculateETA(shaftIndex, call.floorIndex)
        })
    end

    return queueInfo
end

print("^2[Custom Elevator]^7 Queue system loaded successfully")
