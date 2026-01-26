--[[
    CLIENT-SIDE ELEVATOR BUILDER
    In-game tool for creating and managing elevators without editing config files
]]

local builderActive = false
local previewMarkers = {}

-- Open builder UI
RegisterNetEvent('custom_elevator:builder:open', function()
    builderActive = true

    -- Load current elevator data
    local shafts = lib.callback.await('custom_elevator:builder:getShafts', false)

    SendNUIMessage({
        type = "openBuilder",
        shafts = shafts or {}
    })
    SetNuiFocus(true, true)
end)

-- Close builder UI
local function CloseBuilder()
    builderActive = false
    SendNUIMessage({
        type = "closeBuilder"
    })
    SetNuiFocus(false, false)

    -- Clear preview markers
    for _, marker in ipairs(previewMarkers) do
        if marker.thread then
            marker.active = false
        end
    end
    previewMarkers = {}
end

-- Get current player position
local function GetCurrentPosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    return {
        x = tonumber(string.format("%.2f", coords.x)),
        y = tonumber(string.format("%.2f", coords.y)),
        z = tonumber(string.format("%.2f", coords.z)),
        heading = tonumber(string.format("%.2f", heading))
    }
end

-- Show preview marker for a floor
local function ShowPreviewMarker(coords, color)
    local markerData = {
        active = true,
        coords = coords,
        color = color or {r = 0, g = 255, b = 0}
    }

    table.insert(previewMarkers, markerData)

    CreateThread(function()
        while markerData.active do
            DrawMarker(
                1, -- Cylinder
                markerData.coords.x, markerData.coords.y, markerData.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.5, 1.5, 1.0,
                markerData.color.r, markerData.color.g, markerData.color.b, 150,
                false, true, 2, nil, nil, false
            )
            Wait(0)
        end
    end)
end

-- NUI Callbacks

RegisterNUICallback('close', function(data, cb)
    CloseBuilder()
    cb('ok')
end)

RegisterNUICallback('getCurrentPosition', function(data, cb)
    local position = GetCurrentPosition()
    cb(position)
end)

RegisterNUICallback('loadShafts', function(data, cb)
    local shafts = lib.callback.await('custom_elevator:builder:getShafts', false)
    cb(shafts or {})
end)

RegisterNUICallback('createShaft', function(data, cb)
    local success, shaftIndex = lib.callback.await('custom_elevator:builder:createShaft', false, data.name)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Created new elevator shaft: ' .. data.name,
            type = 'success'
        })
        cb({success = true, shaftIndex = shaftIndex})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to create elevator shaft',
            type = 'error'
        })
        cb({success = false})
    end
end)

RegisterNUICallback('deleteShaft', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:deleteShaft', false, data.shaftIndex)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Deleted elevator shaft',
            type = 'success'
        })
        cb({success = true})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to delete elevator shaft',
            type = 'error'
        })
        cb({success = false})
    end
end)

RegisterNUICallback('addFloor', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:addFloor', false, data.shaftIndex, data.floor)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Added floor: ' .. data.floor.name,
            type = 'success'
        })
        cb({success = true})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to add floor',
            type = 'error'
        })
        cb({success = false})
    end
end)

RegisterNUICallback('updateFloor', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:updateFloor', false, data.shaftIndex, data.floorIndex, data.floor)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Updated floor: ' .. data.floor.name,
            type = 'success'
        })
        cb({success = true})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to update floor',
            type = 'error'
        })
        cb({success = false})
    end
end)

RegisterNUICallback('deleteFloor', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:deleteFloor', false, data.shaftIndex, data.floorIndex)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Deleted floor',
            type = 'success'
        })
        cb({success = true})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to delete floor',
            type = 'error'
        })
        cb({success = false})
    end
end)

RegisterNUICallback('saveToFile', function(data, cb)
    lib.notify({
        title = 'Elevator Builder',
        description = 'Saving to config file...',
        type = 'info'
    })

    local success = lib.callback.await('custom_elevator:builder:saveToFile', false)

    if success then
        lib.notify({
            title = 'Elevator Builder',
            description = 'Successfully saved to config.lua! Elevators reloaded.',
            type = 'success',
            duration = 5000
        })
        cb({success = true})
    else
        lib.notify({
            title = 'Elevator Builder',
            description = 'Failed to save to config file. Check server console.',
            type = 'error',
            duration = 5000
        })
        cb({success = false})
    end
end)

RegisterNUICallback('teleportToFloor', function(data, cb)
    if data.coords and data.heading then
        local ped = PlayerPedId()
        SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
        SetEntityHeading(ped, data.heading)

        lib.notify({
            title = 'Elevator Builder',
            description = 'Teleported to floor position',
            type = 'info'
        })
    end
    cb('ok')
end)

RegisterNUICallback('previewFloor', function(data, cb)
    if data.coords then
        ShowPreviewMarker(data.coords, data.color)
    end
    cb('ok')
end)

RegisterNUICallback('clearPreviews', function(data, cb)
    for _, marker in ipairs(previewMarkers) do
        marker.active = false
    end
    previewMarkers = {}
    cb('ok')
end)

-- Update elevators when data changes
RegisterNetEvent('custom_elevator:builder:shaftsUpdated', function(shafts)
    if builderActive then
        SendNUIMessage({
            type = "updateShafts",
            shafts = shafts
        })
    end
end)

-- Reload elevators after saving
RegisterNetEvent('custom_elevator:reloadElevators', function()
    -- The main client will handle this
    lib.notify({
        title = 'Elevator System',
        description = 'Elevators have been reloaded',
        type = 'success'
    })
end)

-- Helper command to get current coordinates
RegisterCommand('getcoords', function()
    local position = GetCurrentPosition()
    local coordsText = string.format("vector3(%.2f, %.2f, %.2f), heading: %.2f",
        position.x, position.y, position.z, position.heading)

    print("^2Current Coordinates:^7 " .. coordsText)

    lib.notify({
        title = 'Coordinates',
        description = 'Coordinates printed to console (F8)',
        type = 'info'
    })
end, false)

-- Helper command to place a visual marker
local activeMarker = nil
RegisterCommand('markspot', function(args)
    local duration = tonumber(args[1]) or 30

    if activeMarker then
        activeMarker = false
        lib.notify({
            title = 'Marker',
            description = 'Marker cleared',
            type = 'info'
        })
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    lib.notify({
        title = 'Marker',
        description = 'Marking this spot for ' .. duration .. ' seconds',
        type = 'success'
    })

    local endTime = GetGameTimer() + (duration * 1000)
    activeMarker = true

    CreateThread(function()
        while activeMarker and GetGameTimer() < endTime do
            DrawMarker(
                1, -- Cylinder
                coords.x, coords.y, coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.5, 1.5, 0.8,
                0, 255, 255, 150,
                false, true, 2, nil, nil, false
            )
            Wait(0)
        end
        activeMarker = nil
    end)
end, false)
