-- ========================================
-- 3D PANEL PLACEMENT TOOL
-- Admin tool for positioning 3D NUI screens
-- Supports multiple panels with auto-save
-- ========================================

local placementActive = false
local previewPanelId = nil
local editingPanelIndex = nil  -- Index of panel being edited (nil = new panel)
local placementData = {
    id = nil,
    position = vector3(0, 0, 0),
    normal = vector3(0, 0, 1),
    heading = 0.0,
    width = 1.5,
    height = 1.0,
    zoomDist = 1.8,
    zoomFov = 50.0,
    camHeight = 0.1,
    camOffsetX = 0.0,  -- Camera left/right offset
    camOffsetY = 0.0   -- Camera forward/back offset (added to zoomDist)
}

local NEARBY_DISTANCE = 5.0  -- Distance to check for existing panels
local cameraEditMode = false  -- Toggle for camera adjustment mode

-- Keybinds
local KEYS = {
    CONFIRM = 191,       -- ENTER - Confirm placement
    CANCEL = 200,        -- ESC - Cancel placement
    INCREASE_W = 96,     -- NUMPAD + - Increase width
    DECREASE_W = 97,     -- NUMPAD - - Decrease width
    INCREASE_H = 45,     -- R - Increase height (Rise)
    DECREASE_H = 23,     -- F - Decrease height (Fall)
    ROTATE_LEFT = 174,   -- LEFT ARROW - Rotate left
    ROTATE_RIGHT = 175,  -- RIGHT ARROW - Rotate right
    MOVE_UP = 27,        -- UP ARROW - Move up
    MOVE_DOWN = 173,     -- DOWN ARROW - Move down
    MOVE_FORWARD = 32,   -- W - Move forward
    MOVE_BACK = 33,      -- S - Move back
    MOVE_LEFT = 34,      -- A - Move left
    MOVE_RIGHT = 35,     -- D - Move right
    ZOOM_IN = 241,       -- SCROLL UP - Zoom camera in
    ZOOM_OUT = 242,      -- SCROLL DOWN - Zoom camera out
    TOGGLE_CAM = 47,     -- G - Preview zoom camera
    SNAP_TO_SURFACE = 38, -- E - Snap to surface (raycast)
    FINE_ADJUST = 21,    -- SHIFT - Fine adjustment mode (slower)
    CAMERA_MODE = 245,   -- T - Toggle camera edit mode (INPUT_MP_TEXT_CHAT_ALL)
    FOV_UP = 10,         -- PAGE UP - Increase FOV
    FOV_DOWN = 11,       -- PAGE DOWN - Decrease FOV
}

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function HeadingToNormal(heading)
    local rad = math.rad(heading + 180)
    return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

-- Find nearby panel within NEARBY_DISTANCE
local function FindNearbyPanel(pos)
    local panelConfigs = Config.Screen3DPanels or {}
    for i, cfg in ipairs(panelConfigs) do
        if cfg.position then
            local dist = #(pos - cfg.position)
            if dist < NEARBY_DISTANCE then
                return i, cfg
            end
        end
    end
    return nil, nil
end

-- Generate unique panel ID
local function GeneratePanelId()
    local count = #(Config.Screen3DPanels or {})
    return 'panel_' .. (count + 1) .. '_' .. math.random(1000, 9999)
end

-- Draw help text on screen
local function DrawHelpText()
    local modeText = editingPanelIndex and ('~y~EDITING Panel #' .. editingPanelIndex .. '~s~') or '~g~CREATING New Panel~s~'
    local cameraModeText = cameraEditMode and '~o~[CAMERA MODE ACTIVE]~s~' or ''

    local helpLines = {
        "~y~=== 3D Panel Placement Tool ===~s~",
        modeText,
        cameraModeText,
        "",
    }

    if cameraEditMode then
        -- Camera adjustment mode controls
        table.insert(helpLines, "~o~=== CAMERA ADJUSTMENT ===~s~")
        table.insert(helpLines, "  W/S - Camera Forward/Back")
        table.insert(helpLines, "  A/D - Camera Left/Right")
        table.insert(helpLines, "  UP/DOWN - Camera Height")
        table.insert(helpLines, "  PGUP/PGDN - FOV")
        table.insert(helpLines, "  SCROLL - Zoom Distance")
        table.insert(helpLines, "  ~c~G - Preview Camera (16:9 Safe Zone)~s~")
        table.insert(helpLines, "  ~y~T - Exit Camera Mode~s~")
    else
        -- Normal panel adjustment controls
        table.insert(helpLines, "~b~Position:~s~")
        table.insert(helpLines, "  W/S - Move Forward/Back")
        table.insert(helpLines, "  A/D - Move Left/Right")
        table.insert(helpLines, "  UP/DOWN - Move Up/Down")
        table.insert(helpLines, "  LEFT/RIGHT - Rotate")
        table.insert(helpLines, "  ~c~E - SNAP TO SURFACE~s~")
        table.insert(helpLines, "  SHIFT - Fine adjustment")
        table.insert(helpLines, "")
        table.insert(helpLines, "~b~Size:~s~ NUM+/- Width, R/F Height")
        table.insert(helpLines, "~o~T - Camera Edit Mode~s~")
    end

    table.insert(helpLines, "")
    table.insert(helpLines, "~g~ENTER~s~ - Save  ~r~ESC~s~ - Cancel")
    table.insert(helpLines, "")
    table.insert(helpLines, string.format("~y~Panel:~s~ %.2f, %.2f, %.2f", placementData.position.x, placementData.position.y, placementData.position.z))
    table.insert(helpLines, string.format("~y~Heading:~s~ %.1f  ~y~Size:~s~ %.2fx%.2f", placementData.heading, placementData.width, placementData.height))
    table.insert(helpLines, string.format("~o~Cam:~s~ Dist=%.2f H=%.2f FOV=%.0f", placementData.zoomDist, placementData.camHeight, placementData.zoomFov))
    if placementData.camOffsetX ~= 0 or placementData.camOffsetY ~= 0 then
        table.insert(helpLines, string.format("~o~Offset:~s~ X=%.2f Y=%.2f", placementData.camOffsetX, placementData.camOffsetY))
    end

    local y = 0.02
    for _, line in ipairs(helpLines) do
        SetTextFont(4)
        SetTextScale(0.32, 0.32)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(line)
        DrawText(0.01, y)
        y = y + 0.022
    end
end

-- Draw panel outline
local function DrawPanelOutline()
    local pos = placementData.position
    local heading = placementData.heading
    local w = placementData.width / 2
    local h = placementData.height / 2

    local rad = math.rad(heading)
    local rightX = math.cos(rad)
    local rightY = math.sin(rad)

    local corners = {
        vector3(pos.x - rightX * w, pos.y - rightY * w, pos.z - h),
        vector3(pos.x + rightX * w, pos.y + rightY * w, pos.z - h),
        vector3(pos.x + rightX * w, pos.y + rightY * w, pos.z + h),
        vector3(pos.x - rightX * w, pos.y - rightY * w, pos.z + h),
    }

    local color = editingPanelIndex and {r = 255, g = 200, b = 0, a = 200} or {r = 0, g = 255, b = 100, a = 200}
    for i = 1, 4 do
        local next = i % 4 + 1
        DrawLine(corners[i].x, corners[i].y, corners[i].z,
                 corners[next].x, corners[next].y, corners[next].z,
                 color.r, color.g, color.b, color.a)
    end

    DrawMarker(28, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 255, 0, 200, false, false, 2, false, nil, nil, false)

    -- Calculate camera position with offsets
    local normalRad = math.rad(heading + 180)
    local normalX = -math.sin(normalRad)
    local normalY = math.cos(normalRad)

    -- Right vector (perpendicular to normal)
    local rightX = math.cos(math.rad(heading))
    local rightY = math.sin(math.rad(heading))

    -- Arrow showing panel facing direction
    local arrowEnd = vector3(pos.x + normalX * 0.5, pos.y + normalY * 0.5, pos.z)
    DrawLine(pos.x, pos.y, pos.z, arrowEnd.x, arrowEnd.y, arrowEnd.z, 255, 0, 0, 255)

    -- Camera position: base position + zoom distance + offsets
    local totalDist = placementData.zoomDist + placementData.camOffsetY
    local camPos = vector3(
        pos.x + normalX * totalDist + rightX * placementData.camOffsetX,
        pos.y + normalY * totalDist + rightY * placementData.camOffsetX,
        pos.z + placementData.camHeight
    )

    -- Draw camera marker (larger and orange when in camera mode)
    local camColor = cameraEditMode and {r = 255, g = 150, b = 0, a = 255} or {r = 0, g = 150, b = 255, a = 200}
    local camSize = cameraEditMode and 0.2 or 0.15
    DrawMarker(28, camPos.x, camPos.y, camPos.z, 0, 0, 0, 0, 0, 0, camSize, camSize, camSize, camColor.r, camColor.g, camColor.b, camColor.a, false, false, 2, false, nil, nil, false)

    -- Draw line from camera to panel center (view direction)
    DrawLine(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.z, camColor.r, camColor.g, camColor.b, 150)
end

-- Calculate full camera position (shared function)
local function GetCameraPosition()
    local pos = placementData.position
    local normalRad = math.rad(placementData.heading + 180)
    local normalX = -math.sin(normalRad)
    local normalY = math.cos(normalRad)
    local rightX = math.cos(math.rad(placementData.heading))
    local rightY = math.sin(math.rad(placementData.heading))

    local totalDist = placementData.zoomDist + placementData.camOffsetY
    return vector3(
        pos.x + normalX * totalDist + rightX * placementData.camOffsetX,
        pos.y + normalY * totalDist + rightY * placementData.camOffsetX,
        pos.z + placementData.camHeight
    )
end

-- Update preview panel
local function UpdatePreviewPanel()
    if previewPanelId and GetResourceState('cr-3dnui') == 'started' then
        local normalRad = math.rad(placementData.heading + 180)
        local normal = vector3(-math.sin(normalRad), math.cos(normalRad), 0.0)
        pcall(function()
            exports['cr-3dnui']:SetPanelTransform(previewPanelId, placementData.position, normal)
            exports['cr-3dnui']:SetPanelSize(previewPanelId, placementData.width, placementData.height)
        end)
    end
end

-- Create preview panel
local function CreatePreviewPanel()
    if GetResourceState('cr-3dnui') ~= 'started' then return end

    local normalRad = math.rad(placementData.heading + 180)
    local normal = vector3(-math.sin(normalRad), math.cos(normalRad), 0.0)

    previewPanelId = exports['cr-3dnui']:CreatePanel({
        url = 'nui://pd_boss_menu/web/index.html?res=pd_boss_menu',
        pos = placementData.position,
        normal = normal,
        width = placementData.width,
        height = placementData.height,
        resW = 1920,
        resH = 1280,
        alpha = 255,
        enabled = true,
        zOffset = 0.01
    })

    if previewPanelId then
        exports['cr-3dnui']:SendMessage(previewPanelId, { action = 'openMenu' })
    end
end

local function DestroyPreviewPanel()
    if previewPanelId and GetResourceState('cr-3dnui') == 'started' then
        pcall(function()
            exports['cr-3dnui']:DestroyPanel(previewPanelId)
        end)
        previewPanelId = nil
    end
end

-- ========================================
-- RAYCAST SNAP TO SURFACE
-- Works on any geometry including MLO static meshes
-- ========================================

local function GetCameraDirection()
    local camRot = GetGameplayCamRot(2)
    local radX = math.rad(camRot.x)
    local radZ = math.rad(camRot.z)

    local direction = vector3(
        -math.sin(radZ) * math.cos(radX),
        math.cos(radZ) * math.cos(radX),
        math.sin(radX)
    )
    return direction
end

local function RaycastFromCamera(maxDistance)
    local camCoords = GetGameplayCamCoord()
    local camDir = GetCameraDirection()
    local endCoords = camCoords + (camDir * maxDistance)

    -- Raycast flags: 1 = world, 2 = vehicles, 4 = peds, 8 = objects, 16 = water, 256 = vegetation
    -- Using 1 + 16 = 17 to hit world geometry (including MLO)
    -- Or use -1 for everything
    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endCoords.x, endCoords.y, endCoords.z, -1, PlayerPedId(), 0)
    local _, hit, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    if hit then
        return true, hitCoords, surfaceNormal, entityHit
    end
    return false, nil, nil, nil
end

-- Convert surface normal to heading (for panel orientation)
local function NormalToHeading(normal)
    -- Calculate heading from the surface normal
    -- The panel should face outward from the surface
    local heading = math.deg(math.atan2(-normal.x, normal.y))
    return heading
end

-- Snap panel to the surface the player is looking at
local function SnapToSurface()
    local hit, hitCoords, surfaceNormal, entityHit = RaycastFromCamera(20.0)

    if hit and hitCoords then
        -- Offset slightly from the surface to prevent z-fighting
        local offset = surfaceNormal * 0.02
        placementData.position = hitCoords + offset

        -- Calculate heading from surface normal (panel faces outward)
        placementData.heading = NormalToHeading(surfaceNormal)

        UpdatePreviewPanel()

        lib.notify({
            title = 'Snapped to Surface',
            description = string.format('Pos: %.2f, %.2f, %.2f', hitCoords.x, hitCoords.y, hitCoords.z),
            type = 'success',
            duration = 2000
        })
        return true
    else
        lib.notify({
            title = 'No Surface Found',
            description = 'Look at a surface and try again',
            type = 'error',
            duration = 2000
        })
        return false
    end
end

-- Draw raycast target indicator (shows where E will snap to)
local function DrawRaycastIndicator()
    local hit, hitCoords, surfaceNormal, _ = RaycastFromCamera(20.0)

    if hit and hitCoords then
        -- Draw crosshair marker at hit point
        DrawMarker(28, hitCoords.x, hitCoords.y, hitCoords.z, 0, 0, 0, 0, 0, 0, 0.08, 0.08, 0.08, 0, 255, 255, 200, false, false, 2, false, nil, nil, false)

        -- Draw line showing surface normal direction
        local normalEnd = hitCoords + surfaceNormal * 0.3
        DrawLine(hitCoords.x, hitCoords.y, hitCoords.z, normalEnd.x, normalEnd.y, normalEnd.z, 0, 255, 255, 200)

        -- Draw text hint near crosshair
        SetTextFont(4)
        SetTextScale(0.28, 0.28)
        SetTextColour(0, 255, 255, 200)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString("~c~[E] Snap Here~s~")
        SetDrawOrigin(hitCoords.x, hitCoords.y, hitCoords.z + 0.15, 0)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end
end

-- ========================================
-- SAVE TO CONFIG FILE (via Server)
-- ========================================

local function SaveToConfigFile()
    -- Get original ID if editing
    local originalId = nil
    if editingPanelIndex and Config.Screen3DPanels and Config.Screen3DPanels[editingPanelIndex] then
        originalId = Config.Screen3DPanels[editingPanelIndex].id
    end

    -- Send to server for file save
    TriggerServerEvent('pd_boss:server:savePanelConfig', {
        id = placementData.id,
        originalId = originalId,
        position = placementData.position,
        heading = placementData.heading,
        width = placementData.width,
        height = placementData.height,
        zoomDist = placementData.zoomDist,
        zoomFov = placementData.zoomFov,
        camHeight = placementData.camHeight,
        camOffsetX = placementData.camOffsetX,
        camOffsetY = placementData.camOffsetY
    }, editingPanelIndex ~= nil, editingPanelIndex)

    return true  -- Async, result will come via event
end

-- Handle save result from server
RegisterNetEvent('pd_boss:client:panelSaveResult', function(success, message)
    if success then
        lib.notify({
            title = 'Panel Saved',
            description = message,
            type = 'success',
            duration = 5000
        })
    else
        lib.notify({
            title = 'Save Error',
            description = message,
            type = 'error',
            duration = 5000
        })
    end
end)

-- Update runtime config
local function UpdateRuntimeConfig()
    if not Config.Screen3DPanels then
        Config.Screen3DPanels = {}
    end

    local newConfig = {
        id = placementData.id,
        enabled = true,
        position = placementData.position,
        heading = placementData.heading,
        width = placementData.width,
        height = placementData.height,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = placementData.zoomDist,
        zoomFov = placementData.zoomFov,
        camHeight = placementData.camHeight,
        camOffsetX = placementData.camOffsetX,
        camOffsetY = placementData.camOffsetY
    }

    if editingPanelIndex then
        Config.Screen3DPanels[editingPanelIndex] = newConfig
    else
        table.insert(Config.Screen3DPanels, newConfig)
    end

    -- Update legacy single panel reference
    Config.Screen3D = Config.Screen3DPanels[1]
end

-- Save and apply configuration
local function SaveConfiguration()
    -- Update runtime config first
    UpdateRuntimeConfig()

    -- Save to file
    local saved = SaveToConfigFile()

    if saved then
        lib.notify({
            title = 'Panel Saved',
            description = editingPanelIndex and 'Panel updated successfully' or 'New panel added',
            type = 'success',
            duration = 5000
        })

        -- Refresh all panels to apply changes
        TriggerEvent('pd_boss_menu:refreshPanels')
    else
        lib.notify({
            title = 'Save Error',
            description = 'Could not save to config file. Check console.',
            type = 'error',
            duration = 5000
        })
    end

    -- Also print to console for manual backup
    print('^2[Placement] Panel Configuration:^7')
    print(string.format('  ID: %s', placementData.id))
    print(string.format('  Position: vector3(%.4f, %.4f, %.4f)', placementData.position.x, placementData.position.y, placementData.position.z))
    print(string.format('  Heading: %.2f', placementData.heading))
    print(string.format('  Size: %.2f x %.2f', placementData.width, placementData.height))
    print(string.format('  Camera: zoomDist=%.2f, camHeight=%.2f, FOV=%.1f', placementData.zoomDist, placementData.camHeight, placementData.zoomFov))
    print(string.format('  Camera Offsets: X=%.2f, Y=%.2f', placementData.camOffsetX, placementData.camOffsetY))
end

-- ========================================
-- 16:9 SAFE ZONE INDICATOR
-- Helps ultrawide users ensure camera works for standard monitors
-- ========================================

local function Draw16x9SafeZone()
    local screenW, screenH = GetActiveScreenResolution()
    local currentAspect = screenW / screenH
    local targetAspect = 16 / 9  -- 1.777...

    -- Only draw if the current aspect is wider than 16:9
    if currentAspect <= targetAspect then
        return  -- Already 16:9 or narrower, no safe zone needed
    end

    -- Calculate the horizontal bounds of the 16:9 safe zone
    -- In normalized coordinates (0-1)
    local safeWidth = targetAspect / currentAspect
    local leftBorder = (1 - safeWidth) / 2
    local rightBorder = 1 - leftBorder

    -- Draw semi-transparent dark overlay on the "unsafe" side areas
    -- Left side (center X = leftBorder/2, width = leftBorder)
    DrawRect(leftBorder / 2, 0.5, leftBorder, 1.0, 0, 0, 0, 120)
    -- Right side
    DrawRect((1 + rightBorder) / 2, 0.5, leftBorder, 1.0, 0, 0, 0, 120)

    -- Draw bright yellow border lines at the edges of the safe zone
    -- Vertical line on left
    DrawRect(leftBorder, 0.5, 0.003, 1.0, 255, 255, 0, 255)
    -- Vertical line on right
    DrawRect(rightBorder, 0.5, 0.003, 1.0, 255, 255, 0, 255)

    -- Draw corner markers for visibility
    local markerSize = 0.02
    -- Top-left corner
    DrawRect(leftBorder + markerSize/2, 0.02, markerSize, 0.003, 255, 255, 0, 255)
    -- Top-right corner
    DrawRect(rightBorder - markerSize/2, 0.02, markerSize, 0.003, 255, 255, 0, 255)
    -- Bottom-left corner
    DrawRect(leftBorder + markerSize/2, 0.98, markerSize, 0.003, 255, 255, 0, 255)
    -- Bottom-right corner
    DrawRect(rightBorder - markerSize/2, 0.98, markerSize, 0.003, 255, 255, 0, 255)

    -- Draw label at top center
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 0, 230)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("~y~16:9 Safe Zone~s~ - Standard monitors see this area")
    DrawText(0.5, 0.04)

    -- Show current screen info
    SetTextFont(4)
    SetTextScale(0.3, 0.3)
    SetTextColour(200, 200, 200, 200)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Your screen: %dx%d (%.2f:1) | Safe area: %.0f%%", screenW, screenH, currentAspect, safeWidth * 100))
    DrawText(0.5, 0.08)
end

-- Preview camera
local previewCam = nil
local function TogglePreviewCamera()
    if previewCam then
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(previewCam, false)
        previewCam = nil
        lib.notify({ title = 'Preview Camera', description = 'Disabled', type = 'inform' })
    else
        -- Use shared function to get camera position (includes offsets)
        local camPos = GetCameraPosition()

        previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamCoord(previewCam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(previewCam, placementData.position.x, placementData.position.y, placementData.position.z)
        SetCamFov(previewCam, placementData.zoomFov)
        SetCamActive(previewCam, true)
        RenderScriptCams(true, true, 500, true, false)
        lib.notify({ title = 'Preview Camera', description = '16:9 safe zone shown - Press G to exit', type = 'inform' })
    end
end

-- ========================================
-- MAIN PLACEMENT LOOP
-- ========================================

local function PlacementLoop()
    placementActive = true

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    -- Check if near an existing panel
    editingPanelIndex, existingConfig = FindNearbyPanel(playerPos)

    if editingPanelIndex and existingConfig then
        -- Edit existing panel
        placementData.id = existingConfig.id
        placementData.position = existingConfig.position
        placementData.heading = existingConfig.heading or 0
        placementData.width = existingConfig.width or 1.5
        placementData.height = existingConfig.height or 1.0
        placementData.zoomDist = existingConfig.zoomDist or 1.8
        placementData.zoomFov = existingConfig.zoomFov or 50.0
        placementData.camHeight = existingConfig.camHeight or 0.1
        placementData.camOffsetX = existingConfig.camOffsetX or 0.0
        placementData.camOffsetY = existingConfig.camOffsetY or 0.0

        -- Hide the original panel so we only see the preview
        TriggerEvent('pd_boss_menu:hidePanel', placementData.id)

        lib.notify({
            title = 'Editing Existing Panel',
            description = 'Panel #' .. editingPanelIndex .. ' (' .. placementData.id .. ')',
            type = 'inform',
            duration = 5000
        })
    else
        -- Create new panel - start at player position
        placementData.id = GeneratePanelId()
        placementData.position = playerPos + vector3(0, 2, 0)
        placementData.heading = GetEntityHeading(playerPed)
        placementData.width = 1.5
        placementData.height = 1.0
        placementData.zoomDist = 1.8
        placementData.zoomFov = 50.0
        placementData.camHeight = 0.1
        placementData.camOffsetX = 0.0
        placementData.camOffsetY = 0.0

        lib.notify({
            title = 'Creating New Panel',
            description = 'Position the panel and press ENTER to save',
            type = 'inform',
            duration = 5000
        })
    end

    -- Freeze player
    FreezeEntityPosition(playerPed, true)
    SetEntityInvincible(playerPed, true)

    -- Create preview
    CreatePreviewPanel()

    -- Base speeds
    local baseMoveSpeed = 0.005
    local baseRotateSpeed = 0.25
    local baseSizeSpeed = 0.02
    local baseZoomSpeed = 0.02

    while placementActive do
        Wait(0)

        -- Fine adjustment mode (SHIFT held)
        local fineMode = IsDisabledControlPressed(0, KEYS.FINE_ADJUST)
        local speedMultiplier = fineMode and 0.2 or 1.0  -- 5x slower when SHIFT held

        local moveSpeed = baseMoveSpeed * speedMultiplier
        local rotateSpeed = baseRotateSpeed * speedMultiplier
        local sizeSpeed = baseSizeSpeed * speedMultiplier
        local zoomSpeed = baseZoomSpeed * speedMultiplier

        DrawHelpText()
        if previewCam then
            -- Draw 16:9 safe zone when previewing camera view
            Draw16x9SafeZone()
        else
            DrawPanelOutline()
            DrawRaycastIndicator()  -- Show snap target crosshair
        end

        DisableAllControlActions(0)
        EnableControlAction(0, 1, true)
        EnableControlAction(0, 2, true)
        EnableControlAction(0, 106, true)

        -- Confirm
        if IsDisabledControlJustPressed(0, KEYS.CONFIRM) then
            SaveConfiguration()
            placementActive = false
        end

        -- Cancel
        if IsDisabledControlJustPressed(0, KEYS.CANCEL) then
            lib.notify({ title = 'Placement Cancelled', type = 'error' })
            placementActive = false
            -- Restore original panels if we were editing
            if editingPanelIndex then
                TriggerEvent('pd_boss_menu:refreshPanels')
            end
        end

        -- Toggle camera edit mode
        if IsDisabledControlJustPressed(0, KEYS.CAMERA_MODE) then
            cameraEditMode = not cameraEditMode
            lib.notify({
                title = cameraEditMode and 'Camera Mode' or 'Panel Mode',
                description = cameraEditMode and 'Adjust camera position' or 'Adjust panel position',
                type = 'inform',
                duration = 2000
            })
        end

        if cameraEditMode then
            -- CAMERA MODE: WASD moves camera offset, arrows adjust height
            if IsDisabledControlPressed(0, KEYS.MOVE_FORWARD) then
                placementData.camOffsetY = placementData.camOffsetY - moveSpeed * 10
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_BACK) then
                placementData.camOffsetY = placementData.camOffsetY + moveSpeed * 10
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_LEFT) then
                placementData.camOffsetX = placementData.camOffsetX - moveSpeed * 10
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_RIGHT) then
                placementData.camOffsetX = placementData.camOffsetX + moveSpeed * 10
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_UP) then
                placementData.camHeight = placementData.camHeight + moveSpeed
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_DOWN) then
                placementData.camHeight = placementData.camHeight - moveSpeed
            end

            -- FOV adjustment in camera mode
            if IsDisabledControlJustPressed(0, KEYS.FOV_UP) then
                placementData.zoomFov = math.min(90, placementData.zoomFov + 5)
            end
            if IsDisabledControlJustPressed(0, KEYS.FOV_DOWN) then
                placementData.zoomFov = math.max(20, placementData.zoomFov - 5)
            end
        else
            -- PANEL MODE: Normal movement controls
            if IsDisabledControlPressed(0, KEYS.MOVE_FORWARD) then
                local normalRad = math.rad(placementData.heading + 180)
                placementData.position = placementData.position + vector3(-math.sin(normalRad) * moveSpeed, math.cos(normalRad) * moveSpeed, 0)
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_BACK) then
                local normalRad = math.rad(placementData.heading + 180)
                placementData.position = placementData.position - vector3(-math.sin(normalRad) * moveSpeed, math.cos(normalRad) * moveSpeed, 0)
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_LEFT) then
                local rightRad = math.rad(placementData.heading + 90)
                placementData.position = placementData.position + vector3(-math.sin(rightRad) * moveSpeed, math.cos(rightRad) * moveSpeed, 0)
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_RIGHT) then
                local rightRad = math.rad(placementData.heading + 90)
                placementData.position = placementData.position - vector3(-math.sin(rightRad) * moveSpeed, math.cos(rightRad) * moveSpeed, 0)
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_UP) then
                placementData.position = placementData.position + vector3(0, 0, moveSpeed)
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.MOVE_DOWN) then
                placementData.position = placementData.position - vector3(0, 0, moveSpeed)
                UpdatePreviewPanel()
            end

            -- Rotation (only in panel mode)
            if IsDisabledControlPressed(0, KEYS.ROTATE_LEFT) then
                placementData.heading = placementData.heading - rotateSpeed
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.ROTATE_RIGHT) then
                placementData.heading = placementData.heading + rotateSpeed
                UpdatePreviewPanel()
            end

            -- Size (only in panel mode)
            if IsDisabledControlJustPressed(0, KEYS.INCREASE_W) then
                placementData.width = placementData.width + sizeSpeed
                UpdatePreviewPanel()
            end
            if IsDisabledControlJustPressed(0, KEYS.DECREASE_W) then
                placementData.width = math.max(0.1, placementData.width - sizeSpeed)
                UpdatePreviewPanel()
            end
            if IsDisabledControlJustPressed(0, KEYS.INCREASE_H) then
                placementData.height = placementData.height + sizeSpeed
                UpdatePreviewPanel()
            end
            if IsDisabledControlJustPressed(0, KEYS.DECREASE_H) then
                placementData.height = math.max(0.1, placementData.height - sizeSpeed)
                UpdatePreviewPanel()
            end
        end

        -- Zoom distance (works in both modes)
        if IsDisabledControlJustPressed(0, KEYS.ZOOM_IN) then
            placementData.zoomDist = math.max(0.5, placementData.zoomDist - zoomSpeed)
        end
        if IsDisabledControlJustPressed(0, KEYS.ZOOM_OUT) then
            placementData.zoomDist = placementData.zoomDist + zoomSpeed
        end

        -- Camera height with shift (legacy, works in panel mode)
        if IsDisabledControlPressed(0, 21) then
            if IsDisabledControlJustPressed(0, KEYS.ZOOM_IN) then
                placementData.camHeight = placementData.camHeight + 0.02
            end
            if IsDisabledControlJustPressed(0, KEYS.ZOOM_OUT) then
                placementData.camHeight = placementData.camHeight - 0.02
            end
        end

        -- Preview camera
        if IsDisabledControlJustPressed(0, KEYS.TOGGLE_CAM) then
            TogglePreviewCamera()
        end

        -- Snap to surface (E key)
        if IsDisabledControlJustPressed(0, KEYS.SNAP_TO_SURFACE) then
            SnapToSurface()
        end
    end

    -- Cleanup
    if previewCam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(previewCam, false)
        previewCam = nil
    end
    DestroyPreviewPanel()

    -- Unfreeze
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
end

-- ========================================
-- COMMANDS
-- ========================================

RegisterCommand('placepanel', function()
    if placementActive then
        lib.notify({ title = 'Placement tool already active', type = 'error' })
        return
    end
    PlacementLoop()
end, false)

RegisterCommand('unfreezeme', function()
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
    placementActive = false
    lib.notify({ title = 'Unfrozen', description = 'Character released', type = 'success' })
end, false)

-- Event to refresh panels after save
RegisterNetEvent('pd_boss_menu:refreshPanels', function()
    -- Wait a moment then refresh
    Citizen.SetTimeout(500, function()
        ExecuteCommand('refreshpanel')
    end)
end)

print('^2[pd_boss_menu] Placement tool loaded^7')
print('^3[pd_boss_menu] /placepanel - Position/create panels (auto-detects nearby panels to edit)^7')
print('^3[pd_boss_menu] /unfreezeme - Emergency unfreeze^7')
