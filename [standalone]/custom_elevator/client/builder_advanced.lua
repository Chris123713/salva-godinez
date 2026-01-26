--[[
    ADVANCED ELEVATOR BUILDER - CLIENT
    Modern UI with free movement - no cursor lock!
]]

local builderActive = false
local floorMarkers = {}

-- Toggle builder UI
local function ToggleBuilder()
    builderActive = not builderActive

    if builderActive then
        SendNUIMessage({
            action = 'openBuilder'
        })
        -- DO NOT set NUI focus - player can move freely!

        lib.notify({
            title = 'Elevator Builder',
            description = 'Builder activated! Press F5 to toggle UI.',
            type = 'success',
            duration = 5000
        })
    else
        SendNUIMessage({
            action = 'closeBuilder'
        })

        ClearAllMarkers()

        lib.notify({
            title = 'Elevator Builder',
            description = 'Builder deactivated',
            type = 'info'
        })
    end
end

-- Add floor marker
local function AddFloorMarker(floor)
    local marker = {
        active = true,
        coords = floor.coords,
        name = floor.name
    }

    table.insert(floorMarkers, marker)

    CreateThread(function()
        while marker.active and builderActive do
            -- Draw cylinder
            DrawMarker(
                1, -- Cylinder
                marker.coords.x, marker.coords.y, marker.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.5, 1.5, 1.0,
                0, 255, 0, 150,
                false, true, 2, nil, nil, false
            )

            -- Draw text label
            local onScreen, _x, _y = World3dToScreen2d(marker.coords.x, marker.coords.y, marker.coords.z + 1.0)
            if onScreen then
                SetTextScale(0.35, 0.35)
                SetTextFont(4)
                SetTextProportional(1)
                SetTextColour(255, 255, 255, 215)
                SetTextEntry("STRING")
                SetTextCentre(true)
                AddTextComponentString(marker.name)
                DrawText(_x, _y)
            end

            Wait(0)
        end
    end)
end

-- Remove floor marker
local function RemoveFloorMarker(index)
    if floorMarkers[index + 1] then
        floorMarkers[index + 1].active = false
        table.remove(floorMarkers, index + 1)
    end
end

-- Clear all markers
function ClearAllMarkers()
    for _, marker in ipairs(floorMarkers) do
        marker.active = false
    end
    floorMarkers = {}
end

-- NUI Callbacks
RegisterNUICallback('closeBuilder', function(data, cb)
    ToggleBuilder()
    cb('ok')
end)

RegisterNUICallback('getCurrentPosition', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    cb({
        x = tonumber(string.format("%.2f", coords.x)),
        y = tonumber(string.format("%.2f", coords.y)),
        z = tonumber(string.format("%.2f", coords.z)),
        heading = tonumber(string.format("%.2f", heading))
    })
end)

RegisterNUICallback('addFloorMarker', function(data, cb)
    if data.floor then
        AddFloorMarker(data.floor)
    end
    cb('ok')
end)

RegisterNUICallback('removeFloorMarker', function(data, cb)
    if data.index then
        RemoveFloorMarker(data.index)
    end
    cb('ok')
end)

RegisterNUICallback('clearMarkers', function(data, cb)
    ClearAllMarkers()
    cb('ok')
end)

RegisterNUICallback('teleportToFloor', function(data, cb)
    if data.coords and data.heading then
        local ped = PlayerPedId()
        SetEntityCoords(ped, data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
        SetEntityHeading(ped, data.heading)
    end
    cb('ok')
end)

RegisterNUICallback('logCoords', function(data, cb)
    print('^2[Elevator Builder]^7 ' .. data.coords)
    cb('ok')
end)

-- Server callbacks
RegisterNUICallback('loadShafts', function(data, cb)
    local shafts = lib.callback.await('custom_elevator:builder:getShafts', false)
    cb(shafts or {})
end)

RegisterNUICallback('createShaft', function(data, cb)
    local success, shaftIndex = lib.callback.await('custom_elevator:builder:createShaft', false, data.name)
    cb({ success = success, shaftIndex = shaftIndex })
end)

RegisterNUICallback('deleteShaft', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:deleteShaft', false, data.shaftIndex)
    cb({ success = success })
end)

RegisterNUICallback('addFloor', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:addFloor', false, data.shaftIndex, data.floor)
    cb({ success = success })
end)

RegisterNUICallback('saveToFile', function(data, cb)
    local success = lib.callback.await('custom_elevator:builder:saveToFile', false)
    cb({ success = success })
end)

-- Keyboard controls (works even without NUI focus!)
CreateThread(function()
    while true do
        Wait(0)

        if builderActive then
            -- F5 - Toggle UI
            if IsControlJustReleased(0, 166) then -- F5
                SendNUIMessage({ action = 'closeBuilder' })
                builderActive = false
            end

            -- E - Add floor (when not in vehicle)
            if IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), false) then -- E
                SendNUIMessage({ action = 'addFloorShortcut' })
            end

            -- Z - Remove last floor
            if IsControlJustReleased(0, 20) then -- Z
                SendNUIMessage({ action = 'removeLastFloor' })
            end
        else
            Wait(500)
        end
    end
end)

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

    ToggleBuilder()
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

    ToggleBuilder()
end, false)

-- Server event trigger
RegisterNetEvent('custom_elevator:builder:open', function()
    ToggleBuilder()
end)

print('^2[Elevator Builder]^7 Advanced builder loaded. Commands: /eb, /elevatorbuilder')
