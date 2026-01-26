--[[
    ELEVATOR STATE MACHINE

    This file defines all possible elevator states and their valid transitions.
    The state machine ensures consistent behavior and prevents invalid state changes.
]]

-- Possible elevator states
ElevatorStates = {
    IDLE = "idle",                          -- Elevator is stationary with doors closed
    DOORS_OPENING = "doors_opening",        -- Door opening animation in progress
    DOORS_OPEN = "doors_open",              -- Doors are fully open, ready for boarding
    DOORS_CLOSING = "doors_closing",        -- Door closing animation in progress
    MOVING_UP = "moving_up",                -- Elevator is traveling upward
    MOVING_DOWN = "moving_down",            -- Elevator is traveling downward
    EMERGENCY = "emergency",                -- Emergency stop (for future use)
    MAINTENANCE = "maintenance"             -- Maintenance mode (for future use)
}

-- Valid state transitions
-- Format: [current_state] = { valid_next_state1, valid_next_state2, ... }
StateTransitions = {
    [ElevatorStates.IDLE] = {
        ElevatorStates.DOORS_OPENING,
        ElevatorStates.EMERGENCY,
        ElevatorStates.MAINTENANCE
    },
    [ElevatorStates.DOORS_OPENING] = {
        ElevatorStates.DOORS_OPEN,
        ElevatorStates.EMERGENCY,
        ElevatorStates.IDLE
    },
    [ElevatorStates.DOORS_OPEN] = {
        ElevatorStates.DOORS_CLOSING,
        ElevatorStates.EMERGENCY,
        ElevatorStates.DOORS_OPEN  -- Can stay open
    },
    [ElevatorStates.DOORS_CLOSING] = {
        ElevatorStates.MOVING_UP,
        ElevatorStates.MOVING_DOWN,
        ElevatorStates.IDLE,
        ElevatorStates.DOORS_OPENING,  -- Can reopen while closing
        ElevatorStates.EMERGENCY
    },
    [ElevatorStates.MOVING_UP] = {
        ElevatorStates.DOORS_OPENING,
        ElevatorStates.EMERGENCY,
        ElevatorStates.MOVING_UP  -- Can continue moving
    },
    [ElevatorStates.MOVING_DOWN] = {
        ElevatorStates.DOORS_OPENING,
        ElevatorStates.EMERGENCY,
        ElevatorStates.MOVING_DOWN  -- Can continue moving
    },
    [ElevatorStates.EMERGENCY] = {
        ElevatorStates.IDLE,
        ElevatorStates.DOORS_OPENING
    },
    [ElevatorStates.MAINTENANCE] = {
        ElevatorStates.IDLE
    }
}

-- Validate if a state transition is allowed
function IsValidStateTransition(currentState, newState)
    if not StateTransitions[currentState] then
        return false
    end

    for _, validState in ipairs(StateTransitions[currentState]) do
        if validState == newState then
            return true
        end
    end

    return false
end

-- Get human-readable state description
function GetStateDescription(state)
    local descriptions = {
        [ElevatorStates.IDLE] = "Idle",
        [ElevatorStates.DOORS_OPENING] = "Doors Opening",
        [ElevatorStates.DOORS_OPEN] = "Doors Open",
        [ElevatorStates.DOORS_CLOSING] = "Doors Closing",
        [ElevatorStates.MOVING_UP] = "Moving Up",
        [ElevatorStates.MOVING_DOWN] = "Moving Down",
        [ElevatorStates.EMERGENCY] = "Emergency Stop",
        [ElevatorStates.MAINTENANCE] = "Under Maintenance"
    }

    return descriptions[state] or "Unknown"
end

-- Check if elevator is currently in motion
function IsElevatorMoving(state)
    return state == ElevatorStates.MOVING_UP or state == ElevatorStates.MOVING_DOWN
end

-- Check if doors are in transition
function AreDoorsInTransition(state)
    return state == ElevatorStates.DOORS_OPENING or state == ElevatorStates.DOORS_CLOSING
end

-- Check if elevator is available for new calls
function IsElevatorAvailableForCalls(state)
    return state == ElevatorStates.IDLE or
           state == ElevatorStates.DOORS_OPEN or
           IsElevatorMoving(state)
end

-- Check if players can board/exit
function CanPlayersInteract(state)
    return state == ElevatorStates.DOORS_OPEN
end

print("^2[Custom Elevator]^7 State machine loaded successfully")
