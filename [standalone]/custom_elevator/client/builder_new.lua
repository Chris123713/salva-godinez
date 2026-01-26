--[[
    INTERACTIVE ELEVATOR BUILDER
    Walk around and build elevators on the fly - no menus needed!
]]

local builderMode = false
local currentShaft = nil
local currentFloors = {}
local previewMarkers = {}
local helpTextVisible = false

-- Colors
local COLORS = {
    GREEN = {r = 0, g = 255, b = 0},
    BLUE = {r = 0, g = 150, b = 255},
    RED = {r = 255, g = 0, b = 0},
    YELLOW = {r = 255, g = 255, b = 0}
}

-- Get current player position
local function GetCurrentPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading
    }
end

-- Add a preview marker
local function AddPreviewMarker(coords, color, label)
    local marker = {
        active = true,
        coords = coords,
        color = color or COLORS.GREEN,
        label = label or "Floor"
    }

    table.insert(previewMarkers, marker)

    CreateThread(function()
        while marker.active and builderMode do
            -- Draw cylinder marker
            DrawMarker(
                1, -- Cylinder
                marker.coords.x, marker.coords.y, marker.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.5, 1.5, 1.0,
                marker.color.r, marker.color.g, marker.color.b, 150,
                false, true, 2, nil, nil, false
            )

            -- Draw text label above marker
            local onScreen, _x, _y = World3dToScreen2d(marker.coords.x, marker.coords.y, marker.coords.z + 1.0)
            if onScreen then
                SetTextScale(0.35, 0.35)
                SetTextFont(4)
                SetTextProportional(1)
                SetTextColour(255, 255, 255, 215)
                SetTextEntry("STRING")
                SetTextCentre(true)
                AddTextComponentString(marker.label)
                DrawText(_x, _y)
            end

            Wait(0)
        end
    end)

    return marker
end

-- Clear all preview markers
local function ClearPreviewMarkers()
    for _, marker in ipairs(previewMarkers) do
        marker.active = false
    end
    previewMarkers = {}
end

-- Add floor at current position
local function AddFloorAtCurrentPosition()
    local pos = GetCurrentPosition()
    local floorNum = #currentFloors + 1

    local input = lib.inputDialog('Add Floor', {
        {type = 'input', label = 'Floor Name', description = 'Give this floor a name', placeholder = 'Floor ' .. floorNum, required = true}
    })

    if not input or not input[1] then return end

    local floor = {
        id = 'floor_' .. GetGameTimer(),
        name = input[1],
        coords = vector3(pos.x, pos.y, pos.z),
        heading = pos.heading,
        blip = false,
        jobLock = nil
    }

    table.insert(currentFloors, floor)

    -- Add visual marker
    AddPreviewMarker(floor.coords, COLORS.GREEN, floor.name)

    lib.notify({
        title = 'Elevator Builder',
        description = string.format('Added floor: %s (%d floors total)', floor.name, #currentFloors),
        type = 'success'
    })
end

-- Remove last floor
local function RemoveLastFloor()
    if #currentFloors == 0 then
        lib.notify({
            title = 'Elevator Builder',
            description = 'No floors to remove',
            type = 'error'
        })
        return
    end

    local removedFloor = table.remove(currentFloors)

    -- Remove the marker
    if #previewMarkers > 0 then
        local marker = table.remove(previewMarkers)
        marker.active = false
    end

    lib.notify({
        title = 'Elevator Builder',
        description = string.format('Removed floor: %s (%d floors remaining)', removedFloor.name, #currentFloors),
        type = 'info'
    })
end

-- Save elevator
local function SaveElevator()
    if not currentShaft then
        lib.notify({
            title = 'Elevator Builder',
            description = 'No elevator shaft started. Press E to start.',
            type = 'error'
        })
        return
    end

    if #currentFloors < 2 then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Need at least 2 floors to save',
            type = 'error'
        })
        return
    end

    -- Create shaft on server
    local success, shaftIndex = lib.callback.await('custom_elevator:builder:createShaft', false, currentShaft.name)

    if not success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to create elevator shaft',
            type = 'error'
        })
        return
    end

    -- Add all floors
    for _, floor in ipairs(currentFloors) do
        lib.callback.await('custom_elevator:builder:addFloor', false, shaftIndex, floor)
    end

    -- Ask to save to file
    local alert = lib.alertDialog({
        header = 'Save Elevator',
        content = string.format('Elevator "%s" with %d floors created!\n\nSave to config.lua?', currentShaft.name, #currentFloors),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        local saveSuccess = lib.callback.await('custom_elevator:builder:saveToFile', false)
        if saveSuccess then
            lib.notify({
                title = 'Elevator Builder',
                description = 'Saved to config.lua and reloaded!',
                type = 'success',
                duration = 5000
            })
        else
            lib.notify({
                title = 'Elevator Builder',
                description = 'Failed to save to config.lua',
                type = 'error',
                duration = 5000
            })
        end
    end

    -- Reset
    currentShaft = nil
    currentFloors = {}
    ClearPreviewMarkers()

    lib.notify({
        title = 'Elevator Builder',
        description = 'Builder reset. Press E to start new elevator.',
        type = 'info'
    })
end

-- Start new elevator shaft
local function StartNewShaft()
    local input = lib.inputDialog('New Elevator Shaft', {
        {type = 'input', label = 'Elevator Name', description = 'Name this elevator system', placeholder = 'LSPD Main Elevator', required = true}
    })

    if not input or not input[1] then return end

    currentShaft = {
        name = input[1]
    }

    currentFloors = {}
    ClearPreviewMarkers()

    lib.notify({
        title = 'Elevator Builder',
        description = string.format('Started: %s\nNow press E at each floor location', currentShaft.name),
        type = 'success',
        duration = 5000
    })
end

-- Cancel current build
local function CancelBuild()
    if not currentShaft then return end

    local alert = lib.alertDialog({
        header = 'Cancel Building',
        content = string.format('Cancel building "%s"?\nYou will lose %d unsaved floors.', currentShaft.name, #currentFloors),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        currentShaft = nil
        currentFloors = {}
        ClearPreviewMarkers()

        lib.notify({
            title = 'Elevator Builder',
            description = 'Build cancelled',
            type = 'info'
        })
    end
end

-- Teleport to floor
local function TeleportToFloor()
    if #currentFloors == 0 then
        lib.notify({
            title = 'Elevator Builder',
            description = 'No floors added yet',
            type = 'error'
        })
        return
    end

    local options = {}
    for i, floor in ipairs(currentFloors) do
        table.insert(options, {
            value = i,
            label = floor.name
        })
    end

    local input = lib.inputDialog('Teleport to Floor', {
        {type = 'select', label = 'Select Floor', options = options, required = true}
    })

    if input and input[1] then
        local floor = currentFloors[input[1]]
        local ped = PlayerPedId()
        SetEntityCoords(ped, floor.coords.x, floor.coords.y, floor.coords.z, false, false, false, false)
        SetEntityHeading(ped, floor.heading)

        lib.notify({
            title = 'Elevator Builder',
            description = 'Teleported to: ' .. floor.name,
            type = 'success'
        })
    end
end

-- Main builder thread
CreateThread(function()
    while true do
        Wait(0)

        if builderMode then
            -- Draw help text
            if currentShaft then
                lib.showTextUI(string.format(
                    '[E] Add Floor • [Z] Remove Last • [ENTER] Save (%d floors)\n' ..
                    '[X] Cancel • [T] Teleport to Floor\n' ..
                    '**%s**',
                    #currentFloors,
                    currentShaft.name
                ), {
                    position = "top-center"
                })
                helpTextVisible = true
            else
                lib.showTextUI('[E] Start New Elevator', {
                    position = "top-center"
                })
                helpTextVisible = true
            end

            -- E key - Add floor or start new shaft
            if IsControlJustReleased(0, 38) then -- E
                if currentShaft then
                    AddFloorAtCurrentPosition()
                else
                    StartNewShaft()
                end
            end

            -- Z key - Remove last floor
            if IsControlJustReleased(0, 20) and currentShaft then -- Z
                RemoveLastFloor()
            end

            -- ENTER - Save elevator
            if IsControlJustReleased(0, 191) and currentShaft then -- ENTER
                SaveElevator()
            end

            -- X key - Cancel
            if IsControlJustReleased(0, 73) and currentShaft then -- X
                CancelBuild()
            end

            -- T key - Teleport
            if IsControlJustReleased(0, 245) and currentShaft then -- T
                TeleportToFloor()
            end
        else
            if helpTextVisible then
                lib.hideTextUI()
                helpTextVisible = false
            end
            Wait(500)
        end
    end
end)

-- Toggle builder mode
local function ToggleBuilderMode()
    builderMode = not builderMode

    if builderMode then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Builder mode activated!\nPress E to start building.',
            type = 'success',
            duration = 5000
        })
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Builder mode deactivated',
            type = 'info'
        })

        -- Clean up
        currentShaft = nil
        currentFloors = {}
        ClearPreviewMarkers()

        if helpTextVisible then
            lib.hideTextUI()
            helpTextVisible = false
        end
    end
end

-- Commands
RegisterCommand('elevatorbuilder', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(PlayerId(), 'admin') and not IsPlayerAceAllowed(PlayerId(), 'god') then
        lib.notify({
            title = 'Elevator Builder',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    ToggleBuilderMode()
end, false)

RegisterCommand('eb', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(PlayerId(), 'admin') and not IsPlayerAceAllowed(PlayerId(), 'god') then
        lib.notify({
            title = 'Elevator Builder',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    ToggleBuilderMode()
end, false)

print('^2[Elevator Builder]^7 Interactive builder loaded. Use /eb to toggle.')
