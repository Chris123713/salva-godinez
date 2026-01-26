--[[
    3D TEXT INTERACTION SYSTEM

    Fallback interaction system using 3D text and key presses
    Works without ox_target dependency
]]

-- Get interaction text based on elevator state
function GetInteractionText(shaftIndex, floorIndex, state)
    if not state then
        return "~g~[E]~w~ Call Elevator"
    end

    -- If elevator is at this floor
    if state.currentFloor == floorIndex then
        if state.status == "doors_open" then
            return "~g~[E]~w~ Select Floor"
        elseif state.status == "doors_opening" then
            return "~y~Doors Opening..."
        elseif state.status == "doors_closing" then
            return "~y~Doors Closing..."
        else
            return "~y~Elevator Here"
        end
    else
        -- Elevator is on another floor
        if state.status == "moving_up" or state.status == "moving_down" then
            return "~y~Elevator Moving..."
        else
            return "~g~[E]~w~ Call Elevator"
        end
    end
end

-- Handle interaction when player presses E key
function HandleTextInteraction(shaftIndex, floorIndex)
    local state = ClientElevatorState[shaftIndex]

    -- If elevator is at this floor with doors open, show floor selection
    if state and state.currentFloor == floorIndex and state.status == "doors_open" then
        OpenFloorSelectionMenu(shaftIndex, floorIndex)
    else
        -- Otherwise, call elevator to this floor
        CallElevatorToFloor(shaftIndex, floorIndex)
    end
end

-- Main thread for 3D text interaction
CreateThread(function()
    while true do
        local sleep = 1000

        -- Only run if text mode is enabled
        if Config.Interaction.mode == "text" or Config.Interaction.mode == "both" then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearAnyElevator = false

            for shaftIndex, shaft in ipairs(Config.ElevatorShafts) do
                for floorIndex, floor in ipairs(shaft.floors) do
                    local distance = #(playerCoords - floor.coords)

                    if distance < Config.Interaction.textDistance then
                        nearAnyElevator = true
                        sleep = 0

                        -- Get elevator state
                        local state = ClientElevatorState[shaftIndex]

                        -- Get interaction text
                        local text = GetInteractionText(shaftIndex, floorIndex, state)

                        -- Draw 3D text above floor marker
                        local textCoords = floor.coords + vector3(0, 0, 1.0)
                        Draw3DText(textCoords, text, 0.35)

                        -- Check for key press
                        if distance < Config.InteractionDistance or distance < 2.5 then
                            if IsControlJustReleased(0, Config.InteractionKey) then
                                HandleTextInteraction(shaftIndex, floorIndex)
                            end
                        end
                    end
                end
            end

            -- If not near any elevator, sleep longer
            if not nearAnyElevator then
                sleep = 1000
            end
        end

        Wait(sleep)
    end
end)

print("^2[Custom Elevator]^7 3D text interaction system loaded")
