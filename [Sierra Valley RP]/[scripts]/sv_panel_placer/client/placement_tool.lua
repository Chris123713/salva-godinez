-- Universal 3D Panel Placement Tool
-- Adapted for multi-resource panel support

local resourceName = GetCurrentResourceName()

local placementActive = false
local previewPanelId = nil
local editingPanelId = nil
local selectedPanelType = nil

local placementData = {
    panel_id = nil,
    panel_type = nil,
    label = nil,
    position = vector3(0, 0, 0),
    heading = 0.0,
    width = 1.5,
    height = 1.0,
    zoomDist = 1.8,
    zoomFov = 50.0,
    camHeight = 0.1,
    camOffsetX = 0.0,
    camOffsetY = 0.0,
}

local NEARBY_DISTANCE = 5.0
local cameraEditMode = false

-- Keybinds
local KEYS = {
    CONFIRM = 191,       -- ENTER
    CANCEL = 200,        -- ESC
    INCREASE_W = 96,     -- NUMPAD +
    DECREASE_W = 97,     -- NUMPAD -
    INCREASE_H = 45,     -- R
    DECREASE_H = 23,     -- F
    ROTATE_LEFT = 174,   -- LEFT ARROW
    ROTATE_RIGHT = 175,  -- RIGHT ARROW
    MOVE_UP = 27,        -- UP ARROW
    MOVE_DOWN = 173,     -- DOWN ARROW
    MOVE_FORWARD = 32,   -- W
    MOVE_BACK = 33,      -- S
    MOVE_LEFT = 34,      -- A
    MOVE_RIGHT = 35,     -- D
    ZOOM_IN = 241,       -- SCROLL UP
    ZOOM_OUT = 242,      -- SCROLL DOWN
    TOGGLE_CAM = 47,     -- G
    SNAP_TO_SURFACE = 38, -- E
    FINE_ADJUST = 21,    -- SHIFT
    CAMERA_MODE = 245,   -- T
    FOV_UP = 10,         -- PAGE UP
    FOV_DOWN = 11,       -- PAGE DOWN
    DELETE_PANEL = 73,   -- X
}

-- Generate unique panel ID
local function GeneratePanelId()
    return selectedPanelType .. '_' .. os.time() .. '_' .. math.random(1000, 9999)
end

-- Draw help text
local function DrawHelpText()
    local modeText = editingPanelId and ('~y~EDITING: ' .. editingPanelId .. '~s~') or ('~g~CREATING: ' .. (selectedPanelType or 'unknown') .. '~s~')
    local cameraModeText = cameraEditMode and '~o~[CAMERA MODE]~s~' or ''

    local helpLines = {
        "~y~=== Universal Panel Placer ===~s~",
        modeText,
        cameraModeText,
        "",
    }

    if cameraEditMode then
        table.insert(helpLines, "~o~=== CAMERA ADJUSTMENT ===~s~")
        table.insert(helpLines, "  W/S - Camera Forward/Back")
        table.insert(helpLines, "  A/D - Camera Left/Right")
        table.insert(helpLines, "  UP/DOWN - Camera Height")
        table.insert(helpLines, "  PGUP/PGDN - FOV")
        table.insert(helpLines, "  SCROLL - Zoom Distance")
        table.insert(helpLines, "  ~c~G - Preview Camera~s~")
        table.insert(helpLines, "  ~y~T - Exit Camera Mode~s~")
    else
        table.insert(helpLines, "~b~Position:~s~")
        table.insert(helpLines, "  W/S/A/D - Move Panel")
        table.insert(helpLines, "  UP/DOWN - Move Up/Down")
        table.insert(helpLines, "  LEFT/RIGHT - Rotate")
        table.insert(helpLines, "  ~c~E - SNAP TO SURFACE~s~")
        table.insert(helpLines, "  SHIFT - Fine adjustment")
        table.insert(helpLines, "")
        table.insert(helpLines, "~b~Size:~s~ NUM+/- Width, R/F Height")
        table.insert(helpLines, "~o~T - Camera Edit Mode~s~")
    end

    table.insert(helpLines, "")
    if editingPanelId then
        table.insert(helpLines, "~r~X - DELETE PANEL~s~")
    end
    table.insert(helpLines, "~g~ENTER~s~ - Save  ~r~ESC~s~ - Cancel")
    table.insert(helpLines, "")
    table.insert(helpLines, string.format("~y~Pos:~s~ %.2f, %.2f, %.2f", placementData.position.x, placementData.position.y, placementData.position.z))
    table.insert(helpLines, string.format("~y~Heading:~s~ %.1f  ~y~Size:~s~ %.2fx%.2f", placementData.heading, placementData.width, placementData.height))

    local y = 0.02
    for _, line in ipairs(helpLines) do
        SetTextFont(4)
        SetTextScale(0.32, 0.32)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
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

    local color = editingPanelId and {r = 255, g = 200, b = 0, a = 200} or {r = 0, g = 255, b = 100, a = 200}
    for i = 1, 4 do
        local next = i % 4 + 1
        DrawLine(corners[i].x, corners[i].y, corners[i].z,
                 corners[next].x, corners[next].y, corners[next].z,
                 color.r, color.g, color.b, color.a)
    end

    -- Center marker
    DrawMarker(28, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 255, 0, 200, false, false, 2, false, nil, nil, false)

    -- Direction arrow
    local normalRad = math.rad(heading + 180)
    local normalX = -math.sin(normalRad)
    local normalY = math.cos(normalRad)
    local arrowEnd = vector3(pos.x + normalX * 0.5, pos.y + normalY * 0.5, pos.z)
    DrawLine(pos.x, pos.y, pos.z, arrowEnd.x, arrowEnd.y, arrowEnd.z, 255, 0, 0, 255)

    -- Camera position marker
    local totalDist = placementData.zoomDist + placementData.camOffsetY
    local camRightX = math.cos(math.rad(heading))
    local camRightY = math.sin(math.rad(heading))
    local camPos = vector3(
        pos.x + normalX * totalDist + camRightX * placementData.camOffsetX,
        pos.y + normalY * totalDist + camRightY * placementData.camOffsetX,
        pos.z + placementData.camHeight
    )

    local camColor = cameraEditMode and {r = 255, g = 150, b = 0, a = 255} or {r = 0, g = 150, b = 255, a = 200}
    DrawMarker(28, camPos.x, camPos.y, camPos.z, 0, 0, 0, 0, 0, 0, 0.15, 0.15, 0.15, camColor.r, camColor.g, camColor.b, camColor.a, false, false, 2, false, nil, nil, false)
    DrawLine(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.z, camColor.r, camColor.g, camColor.b, 150)
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

    local typeConfig = GetPanelTypeConfig(selectedPanelType)
    if not typeConfig then return end

    local normalRad = math.rad(placementData.heading + 180)
    local normal = vector3(-math.sin(normalRad), math.cos(normalRad), 0.0)

    previewPanelId = exports['cr-3dnui']:CreatePanel({
        url = typeConfig.url,
        pos = placementData.position,
        normal = normal,
        width = placementData.width,
        height = placementData.height,
        resW = typeConfig.resW or 1920,
        resH = typeConfig.resH or 1080,
        alpha = 255,
        enabled = true,
        zOffset = 0.01
    })
end

local function DestroyPreviewPanel()
    if previewPanelId and GetResourceState('cr-3dnui') == 'started' then
        pcall(function()
            exports['cr-3dnui']:DestroyPanel(previewPanelId)
        end)
        previewPanelId = nil
    end
end

-- Raycast snap to surface
local function GetCameraDirection()
    local camRot = GetGameplayCamRot(2)
    local radX = math.rad(camRot.x)
    local radZ = math.rad(camRot.z)
    return vector3(
        -math.sin(radZ) * math.cos(radX),
        math.cos(radZ) * math.cos(radX),
        math.sin(radX)
    )
end

local function RaycastFromCamera(maxDistance)
    local camCoords = GetGameplayCamCoord()
    local camDir = GetCameraDirection()
    local endCoords = camCoords + (camDir * maxDistance)

    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endCoords.x, endCoords.y, endCoords.z, -1, PlayerPedId(), 0)
    local _, hit, hitCoords, surfaceNormal, _ = GetShapeTestResult(rayHandle)

    if hit then
        return true, hitCoords, surfaceNormal
    end
    return false, nil, nil
end

local function NormalToHeading(normal)
    return math.deg(math.atan2(-normal.x, normal.y))
end

local function SnapToSurface()
    local hit, hitCoords, surfaceNormal = RaycastFromCamera(20.0)

    if hit and hitCoords then
        local offset = surfaceNormal * 0.02
        placementData.position = hitCoords + offset
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

-- Draw raycast indicator
local function DrawRaycastIndicator()
    local hit, hitCoords, surfaceNormal = RaycastFromCamera(20.0)

    if hit and hitCoords then
        DrawMarker(28, hitCoords.x, hitCoords.y, hitCoords.z, 0, 0, 0, 0, 0, 0, 0.08, 0.08, 0.08, 0, 255, 255, 200, false, false, 2, false, nil, nil, false)

        local normalEnd = hitCoords + surfaceNormal * 0.3
        DrawLine(hitCoords.x, hitCoords.y, hitCoords.z, normalEnd.x, normalEnd.y, normalEnd.z, 0, 255, 255, 200)
    end
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
        local pos = placementData.position
        local normalRad = math.rad(placementData.heading + 180)
        local normalX = -math.sin(normalRad)
        local normalY = math.cos(normalRad)
        local rightX = math.cos(math.rad(placementData.heading))
        local rightY = math.sin(math.rad(placementData.heading))

        local totalDist = placementData.zoomDist + placementData.camOffsetY
        local camPos = vector3(
            pos.x + normalX * totalDist + rightX * placementData.camOffsetX,
            pos.y + normalY * totalDist + rightY * placementData.camOffsetX,
            pos.z + placementData.camHeight
        )

        previewCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        SetCamCoord(previewCam, camPos.x, camPos.y, camPos.z)
        PointCamAtCoord(previewCam, pos.x, pos.y, pos.z)
        SetCamFov(previewCam, placementData.zoomFov)
        SetCamActive(previewCam, true)
        RenderScriptCams(true, true, 500, true, false)
        lib.notify({ title = 'Preview Camera', description = 'Press G to exit', type = 'inform' })
    end
end

-- Save configuration
local function SaveConfiguration()
    local panelData = {
        panel_id = placementData.panel_id,
        panel_type = selectedPanelType,
        label = placementData.label,
        position = placementData.position,
        heading = placementData.heading,
        width = placementData.width,
        height = placementData.height,
        zoomDist = placementData.zoomDist,
        zoomFov = placementData.zoomFov,
        camHeight = placementData.camHeight,
        camOffsetX = placementData.camOffsetX,
        camOffsetY = placementData.camOffsetY,
        enabled = true,
    }

    TriggerServerEvent('sv_panel_placer:server:savePanel', panelData)
end

-- Handle save result
RegisterNetEvent('sv_panel_placer:client:saveResult', function(success, message)
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

-- Main placement loop
local function PlacementLoop()
    placementActive = true

    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    -- Check if near an existing panel
    local nearbyPanelId, nearbyPanel = GetNearbyPanel(playerPos, NEARBY_DISTANCE)

    if nearbyPanelId and nearbyPanel then
        -- Edit existing panel
        editingPanelId = nearbyPanelId
        selectedPanelType = nearbyPanel.placement.panel_type
        placementData.panel_id = nearbyPanelId
        placementData.position = nearbyPanel.position
        placementData.heading = nearbyPanel.placement.heading or 0
        placementData.width = nearbyPanel.placement.width or 1.5
        placementData.height = nearbyPanel.placement.height or 1.0
        placementData.zoomDist = nearbyPanel.placement.zoom_dist or 1.8
        placementData.zoomFov = nearbyPanel.placement.zoom_fov or 50.0
        placementData.camHeight = nearbyPanel.placement.cam_height or 0.1
        placementData.camOffsetX = nearbyPanel.placement.cam_offset_x or 0.0
        placementData.camOffsetY = nearbyPanel.placement.cam_offset_y or 0.0
        placementData.label = nearbyPanel.placement.label

        -- Hide original panel
        DestroyPanel(nearbyPanelId)

        lib.notify({
            title = 'Editing Panel',
            description = nearbyPanelId,
            type = 'inform',
            duration = 5000
        })
    else
        -- Must select panel type for new panel
        if not selectedPanelType then
            lib.notify({
                title = 'No Panel Type Selected',
                description = 'Use /placepanel [type] to specify panel type',
                type = 'error'
            })
            placementActive = false
            return
        end

        local typeConfig = GetPanelTypeConfig(selectedPanelType)
        if not typeConfig then
            lib.notify({
                title = 'Invalid Panel Type',
                description = selectedPanelType .. ' is not registered',
                type = 'error'
            })
            placementActive = false
            return
        end

        editingPanelId = nil
        placementData.panel_id = GeneratePanelId()
        placementData.position = playerPos + vector3(0, 2, 0)
        placementData.heading = GetEntityHeading(playerPed)
        placementData.width = typeConfig.defaultWidth or 1.5
        placementData.height = typeConfig.defaultHeight or 1.0
        placementData.zoomDist = typeConfig.zoomDist or 1.8
        placementData.zoomFov = typeConfig.zoomFov or 50.0
        placementData.camHeight = typeConfig.camHeight or 0.1
        placementData.camOffsetX = 0.0
        placementData.camOffsetY = 0.0
        placementData.label = typeConfig.label

        lib.notify({
            title = 'Creating Panel',
            description = typeConfig.label,
            type = 'inform',
            duration = 5000
        })
    end

    FreezeEntityPosition(playerPed, true)
    SetEntityInvincible(playerPed, true)

    CreatePreviewPanel()

    local baseMoveSpeed = 0.005
    local baseRotateSpeed = 0.25
    local baseSizeSpeed = 0.02
    local baseZoomSpeed = 0.02

    while placementActive do
        Wait(0)

        local fineMode = IsDisabledControlPressed(0, KEYS.FINE_ADJUST)
        local speedMultiplier = fineMode and 0.2 or 1.0

        local moveSpeed = baseMoveSpeed * speedMultiplier
        local rotateSpeed = baseRotateSpeed * speedMultiplier
        local sizeSpeed = baseSizeSpeed * speedMultiplier
        local zoomSpeed = baseZoomSpeed * speedMultiplier

        DrawHelpText()
        if not previewCam then
            DrawPanelOutline()
            DrawRaycastIndicator()
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
            RefreshAllPanels()
        end

        -- Delete (only when editing)
        if editingPanelId and IsDisabledControlJustPressed(0, KEYS.DELETE_PANEL) then
            TriggerServerEvent('sv_panel_placer:server:deletePanel', editingPanelId)
            placementActive = false
        end

        -- Toggle camera edit mode
        if IsDisabledControlJustPressed(0, KEYS.CAMERA_MODE) then
            cameraEditMode = not cameraEditMode
            lib.notify({
                title = cameraEditMode and 'Camera Mode' or 'Panel Mode',
                type = 'inform',
                duration = 2000
            })
        end

        if cameraEditMode then
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
            if IsDisabledControlJustPressed(0, KEYS.FOV_UP) then
                placementData.zoomFov = math.min(90, placementData.zoomFov + 5)
            end
            if IsDisabledControlJustPressed(0, KEYS.FOV_DOWN) then
                placementData.zoomFov = math.max(20, placementData.zoomFov - 5)
            end
        else
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
            if IsDisabledControlPressed(0, KEYS.ROTATE_LEFT) then
                placementData.heading = placementData.heading - rotateSpeed
                UpdatePreviewPanel()
            end
            if IsDisabledControlPressed(0, KEYS.ROTATE_RIGHT) then
                placementData.heading = placementData.heading + rotateSpeed
                UpdatePreviewPanel()
            end
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

        -- Zoom (both modes)
        if IsDisabledControlJustPressed(0, KEYS.ZOOM_IN) then
            placementData.zoomDist = math.max(0.5, placementData.zoomDist - zoomSpeed)
        end
        if IsDisabledControlJustPressed(0, KEYS.ZOOM_OUT) then
            placementData.zoomDist = placementData.zoomDist + zoomSpeed
        end

        -- Preview camera
        if IsDisabledControlJustPressed(0, KEYS.TOGGLE_CAM) then
            TogglePreviewCamera()
        end

        -- Snap to surface
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

    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
    cameraEditMode = false
    editingPanelId = nil
end

-- Commands with ACE permission restrictions
-- /placepanel - Place, edit, or delete panels (admin only)
lib.addCommand('placepanel', {
    help = 'Place or edit 3D panels (admin only)',
    params = {
        { name = 'type', help = 'Panel type (e.g., job_market, pd_boss_menu)', type = 'string', optional = true }
    },
    restricted = Config.Permissions.place  -- 'group.admin'
}, function(source, args)
    if placementActive then
        lib.notify({ title = 'Placement tool already active', type = 'error' })
        return
    end

    -- If argument provided, use as panel type
    if args.type then
        selectedPanelType = args.type
    end

    -- If no panel type and not near existing panel, show selection menu
    local playerPos = GetEntityCoords(PlayerPedId())
    local nearbyPanelId = GetNearbyPanel(playerPos, NEARBY_DISTANCE)

    if not nearbyPanelId and not selectedPanelType then
        -- Show panel type selection
        local panelTypes = lib.callback.await('sv_panel_placer:getPanelTypes', false)
        local options = {}

        for typeId, config in pairs(panelTypes) do
            table.insert(options, {
                title = config.label,
                description = 'Resource: ' .. (config.resource or 'unknown'),
                icon = 'fa-solid fa-tv',
                onSelect = function()
                    selectedPanelType = typeId
                    PlacementLoop()
                end
            })
        end

        if #options == 0 then
            lib.notify({ title = 'No panel types registered', type = 'error' })
            return
        end

        lib.registerContext({
            id = 'panel_type_select',
            title = 'Select Panel Type',
            options = options
        })
        lib.showContext('panel_type_select')
        return
    end

    PlacementLoop()
end)

-- /listpanels - List all panel types and placements (mod+)
lib.addCommand('listpanels', {
    help = 'List all panel types and placed panels',
    restricted = Config.Permissions.list  -- 'group.mod'
}, function(source, args)
    local panelTypes = lib.callback.await('sv_panel_placer:getPanelTypes', false)

    print('^3=== Registered Panel Types ===^7')
    for typeId, config in pairs(panelTypes) do
        print(string.format('  %s - %s (from %s)', typeId, config.label, config.resource or 'unknown'))
    end

    local placements = lib.callback.await('sv_panel_placer:getPlacedPanels', false)
    print('^3=== Placed Panels ===^7')
    for _, p in ipairs(placements or {}) do
        print(string.format('  %s (%s) at %.1f, %.1f, %.1f', p.panel_id, p.panel_type, p.position_x, p.position_y, p.position_z))
    end

    -- Count panel types
    local typeCount = 0
    for _ in pairs(panelTypes or {}) do typeCount = typeCount + 1 end

    lib.notify({
        title = 'Panel List',
        description = string.format('%d types, %d placed panels (see F8 console)',
            typeCount, placements and #placements or 0),
        type = 'inform'
    })
end)

-- /unfreezeme - Emergency unfreeze (no restriction - safety command)
lib.addCommand('unfreezeme', {
    help = 'Emergency unfreeze if stuck in placement mode',
}, function(source, args)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, false)
    SetEntityInvincible(playerPed, false)
    placementActive = false
    lib.notify({ title = 'Unfrozen', type = 'success' })
end)

print('^2[' .. resourceName .. ']^7 Placement tool loaded')
print('^3[' .. resourceName .. ']^7 /placepanel [type] - Place or edit panels (admin)')
print('^3[' .. resourceName .. ']^7 /listpanels - List panels (mod+)')
print('^3[' .. resourceName .. ']^7 /unfreezeme - Emergency unfreeze')
