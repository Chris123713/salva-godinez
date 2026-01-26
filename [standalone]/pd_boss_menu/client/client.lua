local QBX = exports.qbx_core
local menuOpen = false
local panelId = nil           -- Currently active panel (when zoomed)
BossPanels = {}               -- All created panels { [id] = { panelId, config } } - Global for integration access
local panels = BossPanels     -- Local alias for existing code
local isFocused = false
local isZoomed = false
local zoomCam = nil
local activePanel = nil       -- Config of the panel we're currently interacting with
-- Mouse input is handled via native cursor + raycast to 3D panel

-- ========================================
-- SAFETY: Reset NUI state on resource start
-- Prevents fullscreen NUI from persisting across restarts
-- ========================================
CreateThread(function()
    -- Small delay to ensure FiveM systems are ready
    Wait(100)

    -- Reset NUI focus (close any fullscreen NUI that might be stuck)
    SetNuiFocus(false, false)

    -- Send forceClose to ensure the web UI is in closed state
    SendNUIMessage({ action = 'forceClose' })

    -- Enable all controls (in case they were disabled)
    EnableAllControlActions(0)

    print('^2[pd_boss_menu] NUI state reset on resource start^7')
end)

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

-- Convert heading to normal vector (screen faces opposite direction so players can see it)
local function HeadingToNormal(heading)
    local rad = math.rad(heading + 180)
    return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

-- Permission check - validates player has a supported job
local function HasValidJob()
    local playerData = QBX:GetPlayerData()
    if not playerData then return false end

    local jobName = playerData.job.name
    for _, supportedJob in ipairs(Config.SupportedJobs) do
        if jobName == supportedJob then
            return true
        end
    end
    return false
end

-- ========================================
-- 3D PANEL CREATION (Multi-Panel Support)
-- Panels are always visible in the world
-- Permission check only happens on interaction
-- ========================================

-- Cleanup all panels and target zones
local function CleanupAllPanels()
    if GetResourceState('cr-3dnui') == 'started' then
        for id, data in pairs(panels) do
            pcall(function()
                exports['cr-3dnui']:DestroyPanel(data.panelId)
            end)
            pcall(function()
                exports.ox_target:removeZone('pd_boss_panel_' .. id)
            end)
        end
    end
    panels = {}
    panelId = nil
    print('^3[pd_boss_menu] Cleaned up all panels^7')
end

-- Create a single panel from config
local function CreateSinglePanel(cfg, index)
    if not cfg or not cfg.enabled then return nil end

    local id = cfg.id or ('panel_' .. index)
    local normal = HeadingToNormal(cfg.heading)

    print('^3[pd_boss_menu] Creating panel:^7', id, 'at', cfg.position)

    local newPanelId = exports['cr-3dnui']:CreatePanel({
        url = 'nui://pd_boss_menu/web/index.html?res=pd_boss_menu',
        pos = cfg.position,
        normal = normal,
        width = cfg.width or 1.5,
        height = cfg.height or 1.0,
        resW = cfg.resW or 1920,
        resH = cfg.resH or 1280,
        alpha = 255,
        enabled = true,
        zOffset = 0.01
    })

    if not newPanelId then
        print('^1[pd_boss_menu] Failed to create panel:^7', id)
        return nil
    end

    -- Store panel info
    panels[id] = {
        panelId = newPanelId,
        config = cfg
    }

    -- Create ox_target zone for this panel
    local zoneName = 'pd_boss_panel_' .. id
    local panelIndex = index  -- Capture the index for runtime lookup
    exports.ox_target:addSphereZone({
        coords = cfg.position,
        radius = cfg.interactDist or 3.0,
        name = zoneName,
        options = {{
            name = zoneName,
            icon = 'fas fa-desktop',
            label = 'Access Boss Menu',
            onSelect = function()
                -- Look up current config at runtime (not the captured reference)
                local currentConfig = Config.Screen3DPanels and Config.Screen3DPanels[panelIndex]
                if currentConfig then
                    ZoomToScreen(currentConfig)
                else
                    ZoomToScreen(cfg)  -- Fallback to original
                end
            end
        }}
    })

    print('^2[pd_boss_menu] Panel created:^7', id, '^2with ID:^7', newPanelId)
    return newPanelId
end

-- Create all panels from config
local function CreateAllPanels()
    CleanupAllPanels()

    -- Wait for Config to be loaded
    if not Config then
        print('^1[pd_boss_menu] ERROR: Config not loaded yet!^7')
        return false
    end

    if GetResourceState('cr-3dnui') ~= 'started' then
        print('^1[pd_boss_menu] ERROR: cr-3dnui not started!^7')
        return false
    end

    local panelConfigs = Config.Screen3DPanels or {}

    -- Fallback to legacy single panel config
    if #panelConfigs == 0 and Config.Screen3D then
        panelConfigs = { Config.Screen3D }
    end

    print('^2[pd_boss_menu] ====================================^7')
    print('^2[pd_boss_menu] Creating', #panelConfigs, '3D Panel(s)^7')
    print('^2[pd_boss_menu] ====================================^7')

    local created = 0
    for i, cfg in ipairs(panelConfigs) do
        if CreateSinglePanel(cfg, i) then
            created = created + 1
        end
    end

    print('^2[pd_boss_menu] Created', created, 'panel(s) successfully^7')
    print('^2[pd_boss_menu] ====================================^7')
    return created > 0
end

-- Hide a specific panel by its config ID (for placement tool)
local function HidePanelById(panelConfigId)
    if not panelConfigId then return false end

    for id, data in pairs(panels) do
        if id == panelConfigId or (data.config and data.config.id == panelConfigId) then
            if GetResourceState('cr-3dnui') == 'started' then
                pcall(function()
                    exports['cr-3dnui']:DestroyPanel(data.panelId)
                end)
                pcall(function()
                    exports.ox_target:removeZone('pd_boss_panel_' .. id)
                end)
            end
            panels[id] = nil
            print('^3[pd_boss_menu] Hidden panel:^7', panelConfigId)
            return true
        end
    end
    return false
end

-- Event handler for placement tool to hide panels during editing
RegisterNetEvent('pd_boss_menu:hidePanel', function(panelConfigId)
    HidePanelById(panelConfigId)
end)

-- Initialize on resource start
CreateThread(function()
    -- Wait for Config to be loaded (with timeout)
    local timeout = 10000  -- 10 seconds max
    local waited = 0
    while not Config and waited < timeout do
        Wait(100)
        waited = waited + 100
    end

    if not Config then
        print('^1[pd_boss_menu] ERROR: Config failed to load after 10 seconds!^7')
        return
    end

    -- Additional wait for cr-3dnui to start
    Wait(2000)
    CreateAllPanels()
end)

-- Command to recreate all panels
RegisterCommand('refreshpanel', function()
    print('^3[pd_boss_menu] Refreshing all 3D panels...^7')
    CreateAllPanels()
    lib.notify({
        title = 'Panels Refreshed',
        description = 'All panels recreated from config',
        type = 'success'
    })
end, false)

-- Debug command to show all panels
RegisterCommand('debugpanel', function()
    local panelConfigs = Config.Screen3DPanels or {}
    if #panelConfigs == 0 and Config.Screen3D then
        panelConfigs = { Config.Screen3D }
    end

    print('^2[pd_boss_menu] Panel Debug Info:^7')
    print('  Total configs:', #panelConfigs)
    print('  Active panels:', 0)
    for id, data in pairs(panels) do
        print('    -', id, '| PanelID:', data.panelId)
    end
    print('  cr-3dnui state:', GetResourceState('cr-3dnui'))

    -- Draw markers at all panel positions for 10 seconds
    lib.notify({
        title = 'Panel Debug',
        description = 'Markers drawn at all panel positions for 10 seconds',
        type = 'inform'
    })

    CreateThread(function()
        local endTime = GetGameTimer() + 10000
        while GetGameTimer() < endTime do
            for _, cfg in ipairs(panelConfigs) do
                if cfg.position then
                    local normal = HeadingToNormal(cfg.heading or 0)
                    DrawMarker(28, cfg.position.x, cfg.position.y, cfg.position.z,
                        0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 0, 255, 0, 200,
                        false, false, 2, false, nil, nil, false)
                    local normalEnd = cfg.position + normal * 1.0
                    DrawLine(cfg.position.x, cfg.position.y, cfg.position.z,
                        normalEnd.x, normalEnd.y, normalEnd.z, 255, 0, 0, 255)
                end
            end
            Wait(0)
        end
    end)
end, false)

-- ========================================
-- ZOOM AND FOCUS SYSTEM
-- ========================================

-- Zoom camera to screen and enable focus
-- cfg parameter: the panel config to zoom to
function ZoomToScreen(cfg)
    if isZoomed then return end

    -- Use provided config or fall back to first panel
    cfg = cfg or Config.Screen3D
    if not cfg then
        print('^1[pd_boss_menu] No panel config provided to ZoomToScreen^7')
        return
    end

    -- Find the panel ID for this config
    local targetPanelId = nil
    for id, data in pairs(panels) do
        if data.config == cfg or (data.config.id and data.config.id == cfg.id) then
            targetPanelId = data.panelId
            break
        end
    end

    if not targetPanelId then
        print('^1[pd_boss_menu] Could not find panel for config^7')
        return
    end

    -- Permission check BEFORE allowing zoom
    if not HasValidJob() then
        lib.notify({
            title = 'Access Denied',
            description = 'You are not authorized to use this system',
            type = 'error'
        })
        return
    end

    -- Store active panel info
    activePanel = cfg
    panelId = targetPanelId

    -- Calculate camera position (in front of screen, facing it)
    -- Must match placement_tool.lua GetCameraPosition() calculation exactly
    local camHeight = cfg.camHeight or 0.1
    local camOffsetX = cfg.camOffsetX or 0.0
    local camOffsetY = cfg.camOffsetY or 0.0
    local totalDist = cfg.zoomDist + camOffsetY

    -- Normal vector (direction camera faces toward panel)
    local normalRad = math.rad(cfg.heading + 180)
    local normalX = -math.sin(normalRad)
    local normalY = math.cos(normalRad)

    -- Right vector (perpendicular to normal, for left/right offset)
    local rightX = math.cos(math.rad(cfg.heading))
    local rightY = math.sin(math.rad(cfg.heading))

    -- Calculate camera position with all offsets (PLUS not minus!)
    local camPos = vector3(
        cfg.position.x + (normalX * totalDist) + (rightX * camOffsetX),
        cfg.position.y + (normalY * totalDist) + (rightY * camOffsetX),
        cfg.position.z + camHeight
    )

    -- Create and activate camera
    zoomCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(zoomCam, camPos.x, camPos.y, camPos.z)
    PointCamAtCoord(zoomCam, cfg.position.x, cfg.position.y, cfg.position.z)
    SetCamFov(zoomCam, cfg.zoomFov)
    SetCamActive(zoomCam, true)
    RenderScriptCams(true, true, 500, true, false) -- Smooth transition over 500ms

    isZoomed = true

    -- Wait for camera transition to complete, then enable focus
    Citizen.SetTimeout(600, function()
        BeginScreenFocus()
    end)
end

-- Enable focus mode on the 3D screen
function BeginScreenFocus()
    if isFocused or not panelId then return end

    isFocused = true
    menuOpen = true

    -- Enable NUI focus with cursor for keyboard capture
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(true)  -- Allows mouse detection, but keyboard leaks to game

    -- Tell NUI to enter keyboard proxy mode
    SendNUIMessage({ action = 'enterKeyboardProxy' })

    -- Open the menu in DUI (the 3D panel - this is what user sees)
    exports['cr-3dnui']:SendMessage(panelId, { action = 'openMenu' })

    -- Register with server for live updates
    TriggerServerEvent('pd_boss:server:menuOpened')

    Citizen.SetTimeout(100, function()
        TriggerServerEvent('pd_boss:server:directGetData')
    end)

    lib.notify({
        title = 'Boss Menu',
        description = 'Click to interact, type for search. ESC to exit.',
        type = 'inform',
        duration = 3000
    })
end

-- Text input dialog for typing into search fields
local textInputOpen = false
function OpenTextInputDialog()
    if textInputOpen or not panelId then return end
    textInputOpen = true

    -- Use lib.inputDialog for text entry
    local input = lib.inputDialog('Search / Text Input', {
        { type = 'input', label = 'Type here', placeholder = 'Enter text...' }
    })

    textInputOpen = false

    if input and input[1] and input[1] ~= '' and panelId then
        -- Send the typed text to DUI
        exports['cr-3dnui']:SendMessage(panelId, {
            action = 'textInput',
            text = input[1]
        })
    end
end

-- Exit focus and restore camera
function ExitScreenMode()
    if not isZoomed then return end

    -- End focus mode
    if isFocused then
        -- Disable NUI focus
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'exitKeyboardProxy' })

        -- Close DUI panel
        pcall(function()
            exports['cr-3dnui']:SendMessage(panelId, { action = 'forceClose' })
        end)

        isFocused = false
        menuOpen = false
        TriggerServerEvent('pd_boss:server:menuClosed')
    end

    -- Restore camera smoothly
    RenderScriptCams(false, true, 500, true, false)
    if zoomCam then
        DestroyCam(zoomCam, false)
        zoomCam = nil
    end

    isZoomed = false
    activePanel = nil
end

-- Centralized menu close function (for NUI callbacks)
function CloseMenu()
    ExitScreenMode()
end

-- ========================================
-- INPUT HANDLING WHILE FOCUSED
-- Custom mouse handling for 3D panel, keyboard via NUI proxy
-- ========================================

-- Convert screen coordinates to ray direction using camera FOV
local function ScreenToWorldDir(screenX, screenY, camRot, fov)
    local nx = (screenX - 0.5) * 2.0
    local ny = (screenY - 0.5) * 2.0
    local aspectRatio = 16.0 / 9.0
    nx = nx * aspectRatio
    local fovRad = math.rad(fov or 50.0)
    local tanFov = math.tan(fovRad / 2.0)
    nx = nx * tanFov
    ny = -ny * tanFov

    local localDir = vector3(nx, ny, -1.0)
    local len = math.sqrt(localDir.x^2 + localDir.y^2 + localDir.z^2)
    localDir = vector3(localDir.x/len, localDir.y/len, localDir.z/len)

    local pitch = math.rad(camRot.x)
    local yaw = math.rad(camRot.z)
    local cosYaw, sinYaw = math.cos(yaw), math.sin(yaw)
    local cosPitch, sinPitch = math.cos(pitch), math.sin(pitch)

    local forward = vector3(-sinYaw * cosPitch, cosYaw * cosPitch, sinPitch)
    local right = vector3(cosYaw, sinYaw, 0)
    local up = vector3(sinYaw * sinPitch, -cosYaw * sinPitch, cosPitch)

    return vector3(
        right.x * localDir.x + up.x * localDir.y + forward.x * (-localDir.z),
        right.y * localDir.x + up.y * localDir.y + forward.y * (-localDir.z),
        right.z * localDir.x + up.z * localDir.y + forward.z * (-localDir.z)
    )
end

-- Raycast from cursor to panel and get UV coordinates
local function CursorToUV(cursorX, cursorY, cfg)
    if not cfg or not zoomCam then return nil, nil end

    local camPos = GetCamCoord(zoomCam)
    local camRot = GetCamRot(zoomCam, 2)
    local camFov = GetCamFov(zoomCam)
    local rayDir = ScreenToWorldDir(cursorX, cursorY, camRot, camFov)

    local panelPos = cfg.position
    local panelHeading = cfg.heading or 0
    local normalRad = math.rad(panelHeading + 180)
    local panelNormal = vector3(-math.sin(normalRad), math.cos(normalRad), 0)

    local denom = rayDir.x * panelNormal.x + rayDir.y * panelNormal.y + rayDir.z * panelNormal.z
    if math.abs(denom) < 0.0001 then return nil, nil end

    local diff = vector3(panelPos.x - camPos.x, panelPos.y - camPos.y, panelPos.z - camPos.z)
    local t = (diff.x * panelNormal.x + diff.y * panelNormal.y + diff.z * panelNormal.z) / denom
    if t < 0 then return nil, nil end

    local hitPos = vector3(camPos.x + rayDir.x * t, camPos.y + rayDir.y * t, camPos.z + rayDir.z * t)
    local rel = vector3(hitPos.x - panelPos.x, hitPos.y - panelPos.y, hitPos.z - panelPos.z)

    local rightX = math.cos(math.rad(panelHeading))
    local rightY = math.sin(math.rad(panelHeading))
    local localX = rel.x * rightX + rel.y * rightY
    local localY = rel.z

    local halfW = (cfg.width or 1.0) / 2.0
    local halfH = (cfg.height or 1.0) / 2.0

    local u = (localX / halfW + 1.0) * 0.5
    local v = (localY / halfH + 1.0) * 0.5

    if u < 0 or u > 1 or v < 0 or v > 1 then return nil, nil end

    u = 1.0 - u  -- Flip horizontal (panel faces camera)
    v = 1.0 - v  -- Flip vertical (screen Y inverted)

    return u, v
end

CreateThread(function()
    while true do
        local sleep = 200

        if isFocused and panelId and activePanel then
            sleep = 0

            -- Disable game controls
            DisableAllControlActions(0)

            -- NUI cursor is active via SetNuiFocus(true, true)
            -- Get cursor position for raycast to 3D panel
            local cursorX = GetDisabledControlNormal(0, 239)
            local cursorY = GetDisabledControlNormal(0, 240)

            -- Convert cursor to panel UV and send mouse events
            local u, v = CursorToUV(cursorX, cursorY, activePanel)
            if u and v then
                exports['cr-3dnui']:SendMouseMove(panelId, u, v)

                -- Left click
                if IsDisabledControlJustPressed(0, 24) then
                    exports['cr-3dnui']:SendMouseDown(panelId, 'left')
                end
                if IsDisabledControlJustReleased(0, 24) then
                    exports['cr-3dnui']:SendMouseUp(panelId, 'left')
                end

                -- Scroll
                if IsDisabledControlJustPressed(0, 14) then
                    exports['cr-3dnui']:SendMouseWheel(panelId, 120)
                end
                if IsDisabledControlJustPressed(0, 15) then
                    exports['cr-3dnui']:SendMouseWheel(panelId, -120)
                end
            end

            -- ESC handled by keyboard proxy, but backup here
            if IsDisabledControlJustPressed(0, 200) then
                ExitScreenMode()
            end
        end

        Wait(sleep)
    end
end)

-- Auto-exit if player moves too far from screen
CreateThread(function()
    while true do
        if isZoomed and Config.Screen3D then
            local playerPos = GetEntityCoords(PlayerPedId())
            local dist = #(playerPos - Config.Screen3D.position)

            if dist > Config.Screen3D.interactDist + 2.0 then
                ExitScreenMode()
            end
        end
        Wait(500)
    end
end)

-- ========================================
-- RESOURCE CLEANUP
-- ========================================

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ExitScreenMode()
        CleanupAllPanels()
    end
end)

-- ========================================
-- NUI CALLBACKS (for DUI communication)
-- ========================================

RegisterNUICallback('closeMenu', function(_, cb)
    CloseMenu()
    if cb then cb('ok') end
end)

-- Forward keyboard events from NUI to DUI panel
RegisterNUICallback('keyboardInput', function(data, cb)
    print('^3[pd_boss_menu] Keyboard callback received:^7', data.key or 'nil', 'char:', data.char or 'nil')
    if panelId and data then
        print('^2[pd_boss_menu] Forwarding to DUI panel:^7', panelId)
        exports['cr-3dnui']:SendMessage(panelId, {
            action = 'keyboardInput',
            key = data.key,
            char = data.char,
            keyCode = data.keyCode,
            type = data.type  -- 'keydown', 'keyup', 'keypress'
        })
    else
        print('^1[pd_boss_menu] Cannot forward - panelId:^7', panelId, '^1data:^7', data)
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('pd_boss:server:deposit', data)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    TriggerServerEvent('pd_boss:server:withdraw', data)
    cb('ok')
end)

RegisterNUICallback('hire', function(data, cb)
    if data.action == 'fire' then
        TriggerServerEvent('pd_boss:server:fire', data.playerId)
    else
        TriggerServerEvent('pd_boss:server:hire', data.playerId, data.rank)
    end
    cb('ok')
end)

RegisterNUICallback('setRank', function(data, cb)
    TriggerServerEvent('pd_boss:server:setRank', data)
    cb('ok')
end)

RegisterNUICallback('refreshData', function(data, cb)
    if data and data.action == 'fire' then
        TriggerServerEvent('pd_boss:server:fire', data.playerId)
    else
        TriggerServerEvent('pd_boss:server:directGetData')
    end
    if cb then cb('ok') end
end)

RegisterNUICallback('getNearbyPlayers', function(_, cb)
    TriggerServerEvent('pd_boss:server:getNearbyPlayers')
    if cb then cb('ok') end
end)

RegisterNUICallback('getRankPermissions', function(_, cb)
    TriggerServerEvent('pd_boss:server:getRankPermissions')
    if cb then cb('ok') end
end)

RegisterNUICallback('saveRankPermissions', function(data, cb)
    TriggerServerEvent('pd_boss:server:saveRankPermissions', data)
    if cb then cb('ok') end
end)

RegisterNUICallback('getUserPermissions', function(_, cb)
    TriggerServerEvent('pd_boss:server:getUserPermissions')
    if cb then cb('ok') end
end)

RegisterNUICallback('forceClose', function(_, cb)
    CloseMenu()
    if cb then cb('ok') end
end)

RegisterNUICallback('getTransactions', function(_, cb)
    print("Client: getTransactions callback received, forwarding to server")
    TriggerServerEvent('pd_boss:server:getTransactions')
    if cb then cb('ok') end
end)

RegisterNUICallback('showNotification', function(data, cb)
    TriggerServerEvent('pd_boss:server:showNotification', data)
    cb('ok')
end)

RegisterNUICallback('payBonus', function(data, cb)
    TriggerServerEvent('pd_boss:server:payBonus', data)
    cb('ok')
end)

RegisterNUICallback('searchCharacters', function(data, cb)
    TriggerServerEvent('pd_boss:server:searchCharacters', data.query)
    cb('ok')
end)

RegisterNUICallback('hireCharacter', function(data, cb)
    TriggerServerEvent('pd_boss:server:hireCharacter', data)
    cb('ok')
end)

RegisterNUICallback('getRealTimeDutyData', function(_, cb)
    if cb then cb('ok') end
end)

-- Disciplinary Actions Callbacks
RegisterNUICallback('getDisciplinaryActions', function(_, cb)
    TriggerServerEvent('pd_boss:server:getDisciplinaryActions')
    if cb then cb('ok') end
end)

RegisterNUICallback('addDisciplinaryAction', function(data, cb)
    TriggerServerEvent('pd_boss:server:addDisciplinaryAction', data)
    if cb then cb('ok') end
end)

RegisterNUICallback('removeDisciplinaryAction', function(data, cb)
    TriggerServerEvent('pd_boss:server:removeDisciplinaryAction', data.actionId)
    if cb then cb('ok') end
end)

-- Duty Tracking Callbacks
RegisterNUICallback('getDutyAnalytics', function(_, cb)
    TriggerServerEvent('pd_boss:server:getDutyAnalytics')
    if cb then cb('ok') end
end)

RegisterNUICallback('getOfficerDutyHistory', function(data, cb)
    TriggerServerEvent('pd_boss:server:getOfficerDutyHistory', data.citizenid)
    if cb then cb('ok') end
end)

-- Export Transactions Callback
RegisterNUICallback('getExportTransactions', function(data, cb)
    print("^3Client: getExportTransactions callback received^7")
    TriggerServerEvent('pd_boss:server:getExportTransactions', data)
    cb('ok')
end)

-- ========================================
-- SERVER EVENT HANDLERS
-- ========================================

-- Helper function to send messages to NUI (works for both traditional and 3D modes)
local function SendToNui(message)
    if traditionalNuiOpen then
        SendNUIMessage(message)
    elseif menuOpen and panelId then
        exports['cr-3dnui']:SendMessage(panelId, message)
    end
end

-- Disciplinary Actions Event Handler
RegisterNetEvent('pd_boss:client:receiveDisciplinaryActions', function(actions)
    if menuOpen then
        SendToNui({ action = 'receiveDisciplinaryActions', actions = actions })
    end
end)

-- Receive export transactions from server
RegisterNetEvent('pd_boss:client:receiveExportTransactions', function(response)
    print("^2Client: Received export transactions from server^7")
    if menuOpen then
        SendToNui({
            action = 'receiveExportTransactions',
            data = response
        })
    end
end)

-- Duty Analytics Event Handlers
RegisterNetEvent('pd_boss:client:receiveDutyAnalytics', function(data)
    if menuOpen then
        SendToNui({ action = 'receiveDutyAnalytics', data = data })
    end
end)

RegisterNetEvent('pd_boss:client:receiveOfficerDutyHistory', function(data)
    if menuOpen then
        SendToNui({ action = 'receiveOfficerDutyHistory', data = data })
    end
end)

RegisterNetEvent('pd_boss:client:updateData', function(data)
    if menuOpen then
        SendToNui({
            action = 'updateData',
            funds = data.funds,
            employees = data.employees,
            players = data.players,
            ranks = data.ranks,
            department = data.department,
            currentUser = data.currentUser
        })
    end
end)

RegisterNetEvent('pd_boss:client:getBossPosition', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    if coords and coords.x and coords.y and coords.z then
        TriggerServerEvent('pd_boss:server:findNearbyPlayers', coords)
    end
end)

RegisterNetEvent('pd_boss:client:updateNearbyPlayers', function(nearbyPlayers)
    if menuOpen then
        SendToNui({ action = 'updateNearbyPlayers', players = nearbyPlayers })
    end
end)

RegisterNetEvent('pd_boss:client:updateRankPermissions', function(permissions)
    if menuOpen then
        SendToNui({ action = 'updateRankPermissions', permissions = permissions })
    end
end)

RegisterNetEvent('pd_boss:client:updateUserPermissions', function(permissions)
    if menuOpen then
        SendToNui({ action = 'updateUserPermissions', permissions = permissions })
    end
end)

RegisterNetEvent('pd_boss:client:receiveTransactions', function(transactions)
    print("=== RECEIVED TRANSACTIONS FROM SERVER ===")
    print("Number of transactions:", #transactions)
    if menuOpen then
        SendToNui({ type = 'receiveTransactions', transactions = transactions })
    end
end)

RegisterNetEvent('pd_boss:client:searchResults', function(characters)
    if menuOpen then
        SendToNui({ action = 'updateSearchResults', characters = characters })
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    if menuOpen then
        TriggerServerEvent('pd_boss:server:directGetData')
    end
end)

-- ========================================
-- LIVE UPDATE HANDLERS (Event-Driven)
-- ========================================

-- Live employee status update (online/offline/duty change)
RegisterNetEvent('pd_boss:client:liveEmployeeUpdate', function(data)
    if menuOpen then
        print("[LiveUpdate] Received employee update:", data.type, data.employee.name)
        SendToNui({
            action = 'liveEmployeeUpdate',
            updateType = data.type,
            employee = data.employee
        })
    end
end)

-- Live analytics update (officer count/active sessions changed)
RegisterNetEvent('pd_boss:client:liveAnalyticsUpdate', function(data)
    if menuOpen then
        print("[LiveUpdate] Received analytics update - Online:", data.onlineCount)
        SendToNui({
            action = 'liveAnalyticsUpdate',
            onlineCount = data.onlineCount,
            activeSessions = data.activeSessions
        })
    end
end)

-- ========================================
-- FALLBACK: TRADITIONAL NUI MODE
-- Opens fullscreen NUI without 3D screen (command fallback)
-- ========================================

local traditionalNuiOpen = false

function DirectOpenMenu()
    if menuOpen or traditionalNuiOpen then return end

    -- Permission check
    if not HasValidJob() then
        lib.notify({
            title = 'Access Denied',
            description = 'You are not authorized to use this system',
            type = 'error'
        })
        return
    end

    traditionalNuiOpen = true
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openMenu' })

    -- Register with server for live updates
    TriggerServerEvent('pd_boss:server:menuOpened')

    Citizen.SetTimeout(100, function()
        TriggerServerEvent('pd_boss:server:directGetData')
    end)
end

function CloseTraditionalNui()
    if not traditionalNuiOpen then return end
    traditionalNuiOpen = false
    menuOpen = false
    SetNuiFocus(false, false)
    EnableAllControlActions(0)
    SendNUIMessage({ action = 'forceClose' })
    TriggerServerEvent('pd_boss:server:menuClosed')
end

-- ESC key handler for traditional NUI mode
CreateThread(function()
    while true do
        if traditionalNuiOpen then
            Wait(0)
            if IsControlJustReleased(0, 177) then -- ESC/Backspace
                CloseTraditionalNui()
            end
            if IsPauseMenuActive() then
                CloseTraditionalNui()
            end
        else
            Wait(500)
        end
    end
end)

-- Override CloseMenu to handle both modes
function CloseMenu()
    if traditionalNuiOpen then
        CloseTraditionalNui()
    elseif isZoomed then
        ExitScreenMode()
    end
end

-- ========================================
-- DEBUG/FALLBACK COMMANDS
-- ========================================

RegisterCommand('fixmenu', function()
    CloseMenu()
end)

RegisterCommand('closeboss', function()
    CloseMenu()
end)

-- /pdboss - Opens traditional fullscreen NUI (fallback mode)
RegisterCommand('pdboss', function()
    DirectOpenMenu()
end)

-- /pdboss3d - Opens 3D screen mode
RegisterCommand('pdboss3d', function()
    ZoomToScreen()
end)
