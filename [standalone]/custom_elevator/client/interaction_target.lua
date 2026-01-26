--[[
    OX_TARGET INTERACTION SYSTEM

    Creates interactive zones using ox_target for modern elevator interaction
]]

-- Store created zones for cleanup
local createdZones = {}

-- Initialize all ox_target zones for elevators
function InitializeTargetZones()
    -- Skip if interaction mode doesn't include target
    if Config.Interaction.mode == "text" then
        return
    end

    for shaftIndex, shaft in ipairs(Config.ElevatorShafts) do
        for floorIndex, floor in ipairs(shaft.floors) do
            -- Create call button zone (outside elevator - to summon it)
            local callButtonCoords = floor.callButtonCoords or (floor.coords + Config.Interaction.callButtonOffset)
            local callZoneName = string.format("elevator_call_%d_%d", shaftIndex, floorIndex)

            exports.ox_target:addBoxZone({
                name = callZoneName,
                coords = callButtonCoords,
                size = vec3(1.5, 1.5, 2.0),
                rotation = floor.heading,
                debug = false,
                options = {
                    {
                        name = 'call_elevator',
                        label = function()
                            local state = ClientElevatorState[shaftIndex]
                            if not state then return "Call Elevator" end

                            if state.currentFloor == floorIndex and state.status == "doors_open" then
                                return "Enter Elevator"
                            elseif state.currentFloor == floorIndex then
                                return "Elevator Here"
                            else
                                return "Call Elevator"
                            end
                        end,
                        icon = 'fa-solid fa-elevator',
                        iconColor = '#4CAF50',
                        distance = Config.Interaction.targetDistance,
                        onSelect = function()
                            CallElevatorToFloor(shaftIndex, floorIndex)
                        end,
                        canInteract = function()
                            local state = ClientElevatorState[shaftIndex]
                            if not state then return true end

                            -- Can always interact with call button
                            return true
                        end
                    }
                }
            })

            table.insert(createdZones, callZoneName)

            -- Create floor panel zone (inside elevator - to select destination)
            local panelCoords = floor.panelCoords or (floor.coords + Config.Interaction.panelOffset)
            local panelZoneName = string.format("elevator_panel_%d_%d", shaftIndex, floorIndex)

            exports.ox_target:addBoxZone({
                name = panelZoneName,
                coords = panelCoords,
                size = vec3(1.0, 1.0, 2.0),
                rotation = floor.heading,
                debug = false,
                options = {
                    {
                        name = 'open_panel',
                        label = function()
                            local state = ClientElevatorState[shaftIndex]
                            if not state then return "Elevator Panel" end

                            if state.status == "moving_up" then
                                return "Moving Up..."
                            elseif state.status == "moving_down" then
                                return "Moving Down..."
                            elseif state.status == "doors_open" then
                                return "Select Floor"
                            elseif state.status == "doors_opening" then
                                return "Doors Opening..."
                            elseif state.status == "doors_closing" then
                                return "Doors Closing..."
                            else
                                return "Please Wait"
                            end
                        end,
                        icon = 'fa-solid fa-list',
                        iconColor = '#2196F3',
                        distance = Config.Interaction.targetDistance,
                        onSelect = function()
                            OpenFloorSelectionMenu(shaftIndex, floorIndex)
                        end,
                        canInteract = function()
                            local state = ClientElevatorState[shaftIndex]
                            if not state then return false end

                            -- Only allow interaction when doors are open and at this floor
                            return state.status == "doors_open" and state.currentFloor == floorIndex
                        end
                    }
                }
            })

            table.insert(createdZones, panelZoneName)
        end
    end

    print(string.format("^2[Custom Elevator]^7 Created %d ox_target zones", #createdZones))
end

-- Remove all target zones
function RemoveAllTargetZones()
    for _, zoneName in ipairs(createdZones) do
        exports.ox_target:removeZone(zoneName)
    end

    createdZones = {}
    print("^2[Custom Elevator]^7 Removed all ox_target zones")
end

-- Update target zone labels dynamically (called periodically)
function UpdateTargetLabels()
    -- ox_target automatically updates labels via the function return
    -- No manual update needed
end

-- Initialize on resource start
CreateThread(function()
    Wait(2000)  -- Wait for ox_target to load
    InitializeTargetZones()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveAllTargetZones()
    end
end)

print("^2[Custom Elevator]^7 ox_target interaction system loaded")
