local isLoggedIn = LocalPlayer.state.isLoggedIn

-- Camera State
local cinematicCameraActive = false
local clearUIActive = false
local camera = nil
local fov = Config.Camera.fovDefault
local uiOpen = false
local savedPosition = nil -- For save/load position feature
local lastCameraPosition = nil -- Last camera position when it was closed (pos, rot, fov)
local currentMoveSpeed = Config.Camera.moveSpeed
local cameraStartPosition = nil -- Starting position when camera was activated
local cameraInitialized = false -- Track if camera has been properly initialized
local cameraStartTime = 0 -- Time when camera was activated (for grace period)
local playerStartPosition = nil -- Player's position when camera was activated (to restore on exit)
local playerStartHeading = nil -- Player's heading when camera was activated
local originalStartPosition = nil -- Original starting position (first time camera was activated, never cleared)
local originalStartHeading = nil -- Original starting heading (first time camera was activated, never cleared)

-- Camera Position and Rotation
local camPos = vector3(0.0, 0.0, 0.0)
local camRot = vector3(0.0, 0.0, 0.0)
local targetPos = vector3(0.0, 0.0, 0.0)
local targetRot = vector3(0.0, 0.0, 0.0)

-- Movement Vectors
local forwardVector = vector3(0.0, 0.0, 0.0)
local rightVector = vector3(0.0, 0.0, 0.0)
local upVector = vector3(0.0, 0.0, 0.0)

-- Helper Functions
local function HideHUDThisFrame()
    HideHelpTextThisFrame()
    HideHudAndRadarThisFrame()
    
    -- Hide all standard HUD components
    for _, component in ipairs(Config.ClearUI.hideComponents) do
        HideHudComponentThisFrame(component)
    end
    
    -- Hide custom HUD systems if enabled
    if Config.ClearUI.hideCustomHUD then
        -- Hide minimap/radar more thoroughly
        DisplayRadar(false)
        SetRadarBigmapEnabled(false, false)
        
        -- Try to hide jg-hud via export (most reliable method)
        if GetResourceState('jg-hud') == 'started' then
            if exports['jg-hud'] and exports['jg-hud'].toggleHud then
                exports['jg-hud']:toggleHud(false)
            end
            -- Also try NUI messages as backup
            SendNUIMessage({
                action = 'hideHUD',
                type = 'hideHUD',
                hide = true,
                resource = 'jg-hud'
            })
            LocalPlayer.state:set('jgHudHidden', true, false)
        end
        
        -- Try to hide qbx_hud if available
        if GetResourceState('qbx_hud') == 'started' then
            if exports.qbx_hud and exports.qbx_hud.hideHud then
                exports.qbx_hud:hideHud()
            end
            SendNUIMessage({
                action = 'hideHUD',
                resource = 'qbx_hud'
            })
        end
        
        -- Try to hide ulc HUD if available
        if GetResourceState('ulc') == 'started' then
            pcall(function()
                exports.ulc:SetDisplay(false)
            end)
            pcall(function()
                exports.ulc:SetHudDisabled(true)
            end)
        end
        
        -- Try to hide any other HUD systems via NUI
        SendNUIMessage({
            type = 'hideHUD',
            hide = true
        })
    end
end

local function CalculateCameraVectors(rotation)
    local rotX = math.rad(rotation.x)
    local rotZ = math.rad(rotation.z)
    
    -- Forward vector (based on Z rotation and X pitch)
    forwardVector = vector3(
        -math.sin(rotZ) * math.abs(math.cos(rotX)),
        math.cos(rotZ) * math.abs(math.cos(rotX)),
        math.sin(rotX)
    )
    
    -- Right vector (perpendicular to forward, horizontal)
    rightVector = vector3(
        math.cos(rotZ),
        math.sin(rotZ),
        0.0
    )
    
    -- Up vector (world up, not camera relative)
    upVector = vector3(0.0, 0.0, 1.0)
end

local function HandleCameraMovement()
    if not cinematicCameraActive or not camera then return end
    
    local moveSpeed = currentMoveSpeed
    
    -- Speed modifiers (use GetDisabledControlNormal to detect even when disabled)
    local fastInput = GetDisabledControlNormal(0, 21) -- Left Shift
    local slowInput = GetDisabledControlNormal(0, 36) -- Left Ctrl
    
    if fastInput > 0.0 then
        moveSpeed = Config.Camera.moveSpeedFast
    elseif slowInput > 0.0 then
        moveSpeed = Config.Camera.moveSpeedSlow
    end
    
    -- Movement input (use GetDisabledControlNormal to get input even when disabled)
    -- Control 30 (INPUT_MOVE_LR): Positive = Right (D), Negative = Left (A)
    -- Control 31 (INPUT_MOVE_UD): Positive = Forward (W), Negative = Backward (S)
    local moveX = GetDisabledControlNormal(0, 30) -- A/D (INPUT_MOVE_LR): A = negative, D = positive
    local moveY = GetDisabledControlNormal(0, 31) -- W/S (INPUT_MOVE_UD): W = positive, S = negative
    local moveZ = 0.0
    
    -- Up/Down (Q/E) - check both keys
    -- Use GetDisabledControlNormal to get input even when controls are disabled
    local qInput = GetDisabledControlNormal(0, 44) -- Q (up)
    local eInput = GetDisabledControlNormal(0, 38) -- E (down)
    
    -- Q goes up (positive), E goes down (negative)
    moveZ = qInput - eInput
    
    -- Apply movement
    -- W (moveY positive) = forward (forwardVector)
    -- S (moveY negative) = backward (-forwardVector)
    -- D (moveX positive) = right (rightVector)
    -- A (moveX negative) = left (-rightVector)
    if moveX ~= 0.0 or moveY ~= 0.0 or moveZ ~= 0.0 then
        -- Invert moveY to fix W/S inversion
        local moveDir = (forwardVector * -moveY) + (rightVector * moveX) + (upVector * moveZ)
        -- Normalize the direction vector to prevent faster diagonal movement
        local dirLength = #moveDir
        if dirLength > 0.0 then
            moveDir = moveDir / dirLength
        end
        targetPos = targetPos + (moveDir * moveSpeed)
    end
end

local function HandleCameraRotation()
    if not cinematicCameraActive or not camera then return end
    
    -- Get mouse look input - use GetDisabledControlNormal which works even when controls are enabled
    -- Controls 1 and 2 are NOT disabled, so we can read them normally
    local rightAxisX = GetDisabledControlNormal(0, 1) -- Mouse X (LookLeftRight)
    local rightAxisY = GetDisabledControlNormal(0, 2) -- Mouse Y (LookUpDown)
    
    -- Apply rotation if there's input
    if math.abs(rightAxisX) > 0.001 or math.abs(rightAxisY) > 0.001 then
        local rot = targetRot
        -- Invert Y axis for natural mouse movement (up = look up)
        rot = vector3(
            math.max(math.min(rot.x - rightAxisY * Config.Camera.rotationSpeed, 89.0), -89.0),
            rot.y,
            rot.z - rightAxisX * Config.Camera.rotationSpeed
        )
        targetRot = rot
    end
end

local function HandleCameraZoom()
    if not cinematicCameraActive or not camera then return end
    
    local ped = PlayerPedId()
    local scrollUpControl = IsPedSittingInAnyVehicle(ped) and 17 or 241
    local scrollDownControl = IsPedSittingInAnyVehicle(ped) and 16 or 242
    
    if IsControlJustPressed(0, scrollUpControl) then
        fov = math.max(fov - Config.Camera.zoomSpeed, Config.Camera.fovMin)
    end
    
    if IsControlJustPressed(0, scrollDownControl) then
        fov = math.min(fov + Config.Camera.zoomSpeed, Config.Camera.fovMax)
    end
    
    local currentFov = GetCamFov(camera)
    local fovDifference = fov - currentFov
    
    if math.abs(fovDifference) > 0.01 then
        local newFov = currentFov + (fovDifference * 0.1)
        SetCamFov(camera, newFov)
    end
end

local function CheckAreaRestriction()
    if not Config.Camera.areaRestriction.enabled then
        return true -- No restrictions, allow camera
    end
    
    -- Check camera position (where the camera is looking from)
    local checkPos = nil
    
    -- First try to get position from camPos (updated every frame, most accurate)
    if camPos and camPos.x ~= 0.0 and camPos.y ~= 0.0 and camPos.z ~= 0.0 then
        checkPos = camPos
    elseif camera and cinematicCameraActive then
        -- Fallback to actual camera position from the camera object
        local camCoord = GetCamCoord(camera)
        if camCoord and camCoord.x ~= 0.0 and camCoord.y ~= 0.0 and camCoord.z ~= 0.0 then
            checkPos = camCoord
        end
    end
    
    -- Last resort: player position
    if not checkPos or (checkPos.x == 0.0 and checkPos.y == 0.0 and checkPos.z == 0.0) then
        local ped = PlayerPedId()
        checkPos = GetEntityCoords(ped)
    end
    
    -- Check max distance from start position (check camera position, not player)
    if Config.Camera.areaRestriction.maxDistance > 0 and cameraStartPosition and checkPos then
        local distance = #(checkPos - cameraStartPosition)
        -- Check if distance exceeds limit (strict check, no buffer)
        if distance > Config.Camera.areaRestriction.maxDistance then
            return false, "Camera moved too far from the starting position (" .. math.floor(distance * 10) / 10 .. "m / " .. Config.Camera.areaRestriction.maxDistance .. "m)"
        end
    end
    
    -- Check if in restricted zone
    if #Config.Camera.areaRestriction.restrictedZones > 0 then
        for _, zone in ipairs(Config.Camera.areaRestriction.restrictedZones) do
            local distance = #(checkPos - zone.coords)
            if distance <= zone.radius then
                return false, "Camera is not allowed in this area"
            end
        end
    end
    
    -- Check if in allowed zone (if allowed zones are defined, must be in one)
    if #Config.Camera.areaRestriction.allowedZones > 0 then
        local inAllowedZone = false
        for _, zone in ipairs(Config.Camera.areaRestriction.allowedZones) do
            local distance = #(checkPos - zone.coords)
            if distance <= zone.radius then
                inAllowedZone = true
                break
            end
        end
        if not inAllowedZone then
            return false, "Camera is only allowed in specific areas"
        end
    end
    
    return true -- All checks passed
end

local function StartCinematicCamera()
    if cinematicCameraActive then return end
    
    -- Check area restrictions before starting
    local canUse, reason = CheckAreaRestriction()
    if not canUse then
        lib.notify({
            title = 'Cinematic Camera',
            description = reason or 'Camera cannot be used in this area',
            type = 'error',
            duration = 4000
        })
        return
    end
    
    -- Get player position and use it as base for camera
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    local playerHeading = GetEntityHeading(ped)
    
    -- Store player's original position and heading to restore on exit
    playerStartPosition = vector3(playerPos.x, playerPos.y, playerPos.z)
    playerStartHeading = playerHeading
    
    -- Store original starting position (only set once, never cleared - used for reset button)
    if not originalStartPosition then
        originalStartPosition = vector3(playerPos.x, playerPos.y, playerPos.z)
        originalStartHeading = playerHeading
        print(string.format("[CAMERA DEBUG] Original start position saved: %.2f, %.2f, %.2f", originalStartPosition.x, originalStartPosition.y, originalStartPosition.z))
    end
    
    -- Freeze player in place but keep animations normal
    FreezeEntityPosition(ped, true)
    -- Don't block events - let character animate naturally
    SetBlockingOfNonTemporaryEvents(ped, false)
    -- Allow ped to use normal animations and ragdoll
    SetPedCanRagdoll(ped, true)
    -- Allow ambient animations
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanPlayAmbientBaseAnims(ped, true)
    -- Use a scenario to keep character in natural standing pose
    -- Wait a frame first to ensure ped is ready
    Wait(0)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    
    -- Get initial camera rotation from gameplay cam
    local gameplayCamRot = GetGameplayCamRot(2)
    
    -- Determine starting position: use last camera position if available, otherwise use player position
    local startPos = nil
    local startRot = nil
    local startFov = nil
    
    if lastCameraPosition then
        -- Use last camera position
        startPos = lastCameraPosition.pos
        startRot = lastCameraPosition.rot
        startFov = lastCameraPosition.fov
        print(string.format("[CAMERA DEBUG] Restoring last camera position: %.2f, %.2f, %.2f", startPos.x, startPos.y, startPos.z))
    else
        -- Start at player's position (first time or after reset)
        local currentPlayerPos = GetEntityCoords(ped)
        startPos = vector3(currentPlayerPos.x, currentPlayerPos.y, currentPlayerPos.z)
        local initialPitch = -30.0 -- Look down at the ground
        startRot = vector3(initialPitch, 0.0, playerHeading)
        startFov = GetGameplayCamFov()
        print(string.format("[CAMERA DEBUG] Starting at player position: %.2f, %.2f, %.2f", startPos.x, startPos.y, startPos.z))
    end
    
    -- Set camera position variables
    camPos = startPos
    targetPos = startPos
    camRot = startRot
    targetRot = startRot
    fov = startFov
    
    -- Clamp FOV
    fov = math.max(math.min(fov, Config.Camera.fovMax), Config.Camera.fovMin)
    
    -- Store starting camera position (use exact player position)
    cameraStartPosition = vector3(startPos.x, startPos.y, startPos.z)
    
    -- Set focus to player position FIRST (before creating camera)
    SetFocusPosAndVel(startPos.x, startPos.y, startPos.z, 0.0, 0.0, 0.0)
    
    -- Create camera with position set directly - use DEFAULT_SCRIPTED_CAMERA instead
    camera = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', startPos.x, startPos.y, startPos.z, camRot.x, camRot.y, camRot.z, fov, false, 2)
    
    -- Set camera as active
    SetCamActive(camera, true)
    SetFocusPosAndVel(startPos.x, startPos.y, startPos.z, 0.0, 0.0, 0.0)
    
    -- Force position multiple times before rendering
    for i = 1, 20 do
        SetCamCoord(camera, startPos.x, startPos.y, startPos.z)
        SetFocusPosAndVel(startPos.x, startPos.y, startPos.z, 0.0, 0.0, 0.0)
        Wait(0)
    end
    
    -- Now render camera
    RenderScriptCams(true, false, 0, true, false)
    
    -- Create a dedicated thread that forces the position ONLY during initialization (before cameraInitialized is true)
    CreateThread(function()
        local startTime = GetGameTimer()
        while camera and DoesCamExist(camera) and cinematicCameraActive and cameraStartPosition and not cameraInitialized do
            local currentPos = GetCamCoord(camera)
            local timeSinceStart = GetGameTimer() - startTime
            -- Only force position during initialization period (first 500ms), and only if Z is way off (5m+)
            if timeSinceStart < 500 and currentPos and math.abs(currentPos.z - cameraStartPosition.z) > 5.0 then
                SetCamCoord(camera, cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z)
                SetFocusPosAndVel(cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z, 0.0, 0.0, 0.0)
            end
            Wait(0)
        end
    end)
    
    -- Force it many times immediately after render
    for i = 1, 50 do
        SetCamCoord(camera, startPos.x, startPos.y, startPos.z)
        SetFocusPosAndVel(startPos.x, startPos.y, startPos.z, 0.0, 0.0, 0.0)
        Wait(0)
    end
    
    -- Always use the exact start position we set
    camPos = startPos
    targetPos = startPos
    cameraStartPosition = vector3(startPos.x, startPos.y, startPos.z)
    
    -- Set initialization flag AFTER position is locked
    cameraInitialized = true
    cameraStartTime = GetGameTimer() -- Record start time for grace period
    
    -- Final check - verify position one more time
    Wait(50)
    local actualPos = GetCamCoord(camera)
    if actualPos then
        local dist = #(actualPos - startPos)
        print(string.format("[CAMERA DEBUG] Final camera position: %.2f, %.2f, %.2f", actualPos.x, actualPos.y, actualPos.z))
        print(string.format("[CAMERA DEBUG] Final distance from start: %.2f meters", dist))
        if dist > 0.1 then
            -- Camera moved, keep forcing it in the main loop
            print("[CAMERA DEBUG] WARNING: Camera position incorrect after initialization!")
            print("[CAMERA DEBUG] Will continue forcing position in main loop...")
        end
    end
    camPos = startPos
    targetPos = startPos
    
    -- Apply timecycle modifier if enabled
    if Config.Camera.useTimecycle then
        SetTimecycleModifier(Config.Camera.timecycleModifier)
        SetTimecycleModifierStrength(Config.Camera.timecycleStrength)
    end
    
    cinematicCameraActive = true
    
    -- Close UI when camera starts (so user can see the camera view)
    if uiOpen then
        CloseUI()
    end
    
    -- Show notification with controls
    lib.notify({
        title = 'Cinematic Camera',
        description = 'WASD: Move | Mouse: Rotate | Scroll: Zoom | Shift/Ctrl: Speed | ESC: Exit',
        type = 'info',
        duration = 8000
    })
end

local function StopCinematicCamera(reason)
    if not cinematicCameraActive then return end
    
    cinematicCameraActive = false
    cameraInitialized = false -- Reset initialization flag
    cameraStartTime = 0 -- Reset start time
    
    -- Update UI state
    if uiOpen then
        SendNUIMessage({
            action = 'updateCameraState',
            active = false
        })
    end
    
    -- Clear timecycle modifier
    if Config.Camera.useTimecycle then
        ClearTimecycleModifier()
    end
    
    -- Save current camera position before destroying camera (use camPos which is updated every frame)
    if camera and camPos and camPos.x ~= 0.0 and camPos.y ~= 0.0 and camPos.z ~= 0.0 then
        lastCameraPosition = {
            pos = vector3(camPos.x, camPos.y, camPos.z),
            rot = vector3(camRot.x, camRot.y, camRot.z),
            fov = fov
        }
        print(string.format("[CAMERA DEBUG] Saved camera position for next session: %.2f, %.2f, %.2f", lastCameraPosition.pos.x, lastCameraPosition.pos.y, lastCameraPosition.pos.z))
    end
    
    -- Destroy camera
    if camera then
        RenderScriptCams(false, false, 500, true, false)
        DestroyCam(camera, false)
        camera = nil
    end
    
    -- Restore player to original position and unfreeze
    if playerStartPosition then
        local ped = PlayerPedId()
        -- Clear any standing tasks
        ClearPedTasksImmediately(ped)
        -- Unfreeze player
        FreezeEntityPosition(ped, false)
        -- Restore blocking of events
        SetBlockingOfNonTemporaryEvents(ped, false)
        -- Restore player to exact position they were at when camera started
        SetEntityCoordsNoOffset(ped, playerStartPosition.x, playerStartPosition.y, playerStartPosition.z, false, false, false, true)
        if playerStartHeading then
            SetEntityHeading(ped, playerStartHeading)
        end
        playerStartPosition = nil
        playerStartHeading = nil
    end
    
    -- Reset camera start position
    cameraStartPosition = nil
    
    -- Reset FOV
    fov = Config.Camera.fovDefault
    
    -- Show notification
    lib.notify({
        title = 'Cinematic Camera',
        description = reason or 'Cinematic camera deactivated.',
        type = reason and 'error' or 'info',
        duration = 4000
    })
end

local function ToggleClearUI()
    clearUIActive = not clearUIActive
    
    -- Restore HUD when disabling clear UI
    if not clearUIActive and Config.ClearUI.hideCustomHUD then
        DisplayRadar(true)
        
        -- Restore jg-hud
        if GetResourceState('jg-hud') == 'started' then
            if exports['jg-hud'] and exports['jg-hud'].toggleHud then
                exports['jg-hud']:toggleHud(true)
            end
            SendNUIMessage({
                action = 'showHUD',
                type = 'showHUD',
                hide = false,
                resource = 'jg-hud'
            })
            LocalPlayer.state:set('jgHudHidden', false, false)
        end
        
        -- Restore qbx_hud
        if GetResourceState('qbx_hud') == 'started' then
            if exports.qbx_hud and exports.qbx_hud.showHud then
                exports.qbx_hud:showHud()
            end
            SendNUIMessage({
                action = 'showHUD',
                resource = 'qbx_hud'
            })
        end
        
        -- Restore ulc HUD
        if GetResourceState('ulc') == 'started' then
            pcall(function()
                exports.ulc:SetDisplay(true)
            end)
            pcall(function()
                exports.ulc:SetHudDisabled(false)
            end)
        end
        
        -- Restore any other HUD systems
        SendNUIMessage({
            type = 'showHUD',
            hide = false
        })
    end
    
    -- Update UI state
    if uiOpen then
        SendNUIMessage({
            action = 'updateUIState',
            active = clearUIActive
        })
    end
    
    lib.notify({
        title = 'Clear UI',
        description = clearUIActive and 'UI hidden for better footage' or 'UI restored',
        type = clearUIActive and 'success' or 'info',
        duration = 3000
    })
end

local function OpenUI()
    if uiOpen then return end
    uiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openUI'
    })
    SendNUIMessage({
        action = 'updateCameraState',
        active = cinematicCameraActive
    })
    SendNUIMessage({
        action = 'updateUIState',
        active = clearUIActive
    })
    SendNUIMessage({
        action = 'updateZoom',
        zoom = math.floor(fov)
    })
end

local function CloseUI()
    if not uiOpen then return end
    uiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeUI'
    })
end

-- Main Camera Thread
CreateThread(function()
    while true do
        if not isLoggedIn then
            Wait(1000)
        elseif cinematicCameraActive then
            -- Check area restrictions (only after camera is initialized and grace period has passed)
            if Config.Camera.areaRestriction.enabled and cameraStartPosition and cameraInitialized and cameraStartTime > 0 then
                -- Give 500ms grace period after activation to prevent false positives
                local timeSinceStart = GetGameTimer() - cameraStartTime
                if timeSinceStart > 500 then -- 500ms grace period
                    local canUse, reason = CheckAreaRestriction()
                    if not canUse then
                        StopCinematicCamera(reason)
                        Wait(100)
                        goto continue
                    end
                end
            end
            
            -- Keep player frozen in place during camera use
            if playerStartPosition then
                local ped = PlayerPedId()
                FreezeEntityPosition(ped, true)
                -- Don't block events - let character animate naturally
                SetBlockingOfNonTemporaryEvents(ped, false)
                -- Allow ambient animations
                SetPedCanPlayAmbientAnims(ped, true)
                SetPedCanPlayAmbientBaseAnims(ped, true)
                
                -- Check if player has moved from start position
                local currentPos = GetEntityCoords(ped)
                local distance = #(currentPos - playerStartPosition)
                
                -- Only force position if player has moved significantly (more than 0.1m)
                if distance > 0.1 then
                    -- Use SetEntityCoords instead of SetEntityCoordsNoOffset to allow animations
                    SetEntityCoords(ped, playerStartPosition.x, playerStartPosition.y, playerStartPosition.z, false, false, false, false)
                end
                
                if playerStartHeading then
                    SetEntityHeading(ped, playerStartHeading)
                end
                
                -- Keep character in natural standing pose
                if not IsPedInAnyVehicle(ped, false) then
                    -- Only clear ragdoll if it happens
                    if IsPedRagdoll(ped) then
                        SetPedToRagdoll(ped, 0, 0, 0, false, false, false)
                    end
                    -- Keep scenario active (restart if it stops)
                    if not IsPedUsingScenario(ped, "WORLD_HUMAN_STAND_IMPATIENT") then
                        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
                    end
                end
            end
            
            -- IMPORTANT: Do NOT disable controls 1 and 2 (mouse look) - they must remain enabled
            -- Disable player movement controls (but keep mouse look enabled)
            DisableControlAction(0, 0, true)   -- Next Camera
            DisableControlAction(0, 30, true)  -- A/D (player movement)
            DisableControlAction(0, 31, true)  -- W/S (player movement)
            DisableControlAction(0, 32, true)  -- W (forward)
            DisableControlAction(0, 33, true)  -- S (backward)
            DisableControlAction(0, 34, true)  -- A (left)
            DisableControlAction(0, 35, true)  -- D (right)
            DisableControlAction(0, 22, true)  -- Jump
            DisableControlAction(0, 23, true)  -- Enter vehicle
            DisableControlAction(0, 37, true)  -- Weapon wheel
            DisableControlAction(0, 140, true) -- Melee attack alt
            DisableControlAction(0, 141, true) -- Melee attack heavy
            DisableControlAction(0, 142, true) -- Melee attack light
            DisableControlAction(0, 21, true)  -- Sprint
            DisableControlAction(0, 36, true)  -- Ctrl (crouch)
            DisableControlAction(0, 44, false)  -- Keep Q enabled (for up movement)
            DisableControlAction(0, 38, false)  -- Keep E enabled (for down movement)
            DisableControlAction(0, 45, true)  -- R (reload)
            DisableControlAction(0, 75, true)  -- F (enter vehicle)
            DisableControlAction(0, 85, true)  -- Q (radio wheel)
            
            -- Disable ALL pause menu controls to prevent map/menu from opening
            DisableControlAction(0, 177, true) -- ESC/BACK
            DisableControlAction(0, 200, true) -- Pause Menu
            DisableControlAction(0, 199, true) -- Pause Menu alternative
            DisableControlAction(0, 202, true) -- Pause Menu alternative
            DisableControlAction(0, 322, true) -- Pause Menu alternative (PC)
            DisableControlAction(0, 27, true)  -- Phone (can also open map)
            DisableControlAction(0, 172, true) -- Arrow Up (can navigate pause menu)
            DisableControlAction(0, 173, true) -- Arrow Down
            DisableControlAction(0, 174, true) -- Arrow Left
            DisableControlAction(0, 175, true) -- Arrow Right
            DisableControlAction(0, 176, true) -- Enter (can select in pause menu)
            DisableControlAction(0, 244, true) -- M (map key)
            DisablePlayerFiring(PlayerId(), true)
            
            -- Aggressively prevent pause menu from opening
            if IsPauseMenuActive() then
                SetPauseMenuActive(false)
            end
            
            -- Update camera vectors
            CalculateCameraVectors(targetRot)
            
            -- Only handle input and update camera if fully initialized
            if cameraInitialized then
                -- Handle input
                HandleCameraMovement()
                HandleCameraRotation()
                HandleCameraZoom()
                
                -- Smooth camera position and rotation
                if Config.Camera.smoothing then
                    local posDiff = targetPos - camPos
                    local rotDiff = targetRot - camRot
                    
                    camPos = camPos + (posDiff * Config.Camera.smoothingFactor)
                    camRot = camRot + (rotDiff * Config.Camera.smoothingFactor)
                else
                    camPos = targetPos
                    camRot = targetRot
                end
                
                -- Update camera
                if camera then
                    SetCamCoord(camera, camPos.x, camPos.y, camPos.z)
                    SetCamRot(camera, camRot.x, camRot.y, camRot.z, 2)
                end
            else
                -- During initialization, keep camera locked at start position
                if camera and cameraStartPosition then
                    SetCamCoord(camera, cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z)
                    SetFocusPosAndVel(cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z, 0.0, 0.0, 0.0)
                    camPos = cameraStartPosition
                    targetPos = cameraStartPosition
                end
            end
            
            -- Only force position during very early initialization period (first 500ms) and only if Z is way off
            -- After initialization is complete, allow normal camera movement
            if cameraInitialized and camera and cameraStartPosition and cameraStartTime > 0 then
                local timeSinceStart = GetGameTimer() - cameraStartTime
                -- Only check during the first 500ms after initialization, and only if Z is way off (10m+)
                -- This prevents normal movement from being blocked
                if timeSinceStart < 500 then
                    local currentCamPos = GetCamCoord(camera)
                    if currentCamPos then
                        local zDiff = math.abs(currentCamPos.z - cameraStartPosition.z)
                        -- Only correct if Z is way off (more than 10m) - this prevents normal movement from being blocked
                        if zDiff > 10.0 then
                            -- Camera Z position is way off, force it back (but don't reset camPos/targetPos to allow movement)
                            SetCamCoord(camera, cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z)
                            SetFocusPosAndVel(cameraStartPosition.x, cameraStartPosition.y, cameraStartPosition.z, 0.0, 0.0, 0.0)
                            -- Update camPos and targetPos to match, but only if they haven't been moved by user input
                            if #(camPos - cameraStartPosition) < 0.5 then
                                camPos = cameraStartPosition
                                targetPos = cameraStartPosition
                            end
                        end
                    end
                end
            end
            
            -- Hide HUD
            HideHUDThisFrame()
            
            -- Check for ESC press to exit camera (use IsDisabledControlJustPressed which works even when disabled)
            if IsDisabledControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 199) or IsDisabledControlJustPressed(0, 202) or IsDisabledControlJustPressed(0, 322) then
                -- Aggressively close pause menu multiple times to ensure it doesn't open
                for i = 1, 10 do
                    SetPauseMenuActive(false)
                end
                
                -- Stop camera and open UI
                StopCinematicCamera()
                if not uiOpen then
                    OpenUI()
                end
                
                -- Continue blocking pause menu for a moment after exit
                Wait(100)
                for i = 1, 10 do
                    SetPauseMenuActive(false)
                end
            end
            
            Wait(0)
        else
            Wait(100)
        end
        
        ::continue::
    end
end)

-- Clear UI Thread
CreateThread(function()
    while true do
        if not isLoggedIn then
            Wait(1000)
        elseif clearUIActive then
            HideHUDThisFrame()
            
            -- Continuously hide jg-hud UI (in case it re-renders)
            if Config.ClearUI.hideCustomHUD and GetResourceState('jg-hud') == 'started' then
                if exports['jg-hud'] and exports['jg-hud'].toggleHud then
                    exports['jg-hud']:toggleHud(false)
                end
            end
            
            Wait(0)
        else
            Wait(100)
        end
    end
end)

-- Pause Menu Prevention Thread (runs continuously when camera is active)
CreateThread(function()
    while true do
        if not isLoggedIn then
            Wait(1000)
        elseif cinematicCameraActive then
            -- Aggressively prevent pause menu from opening
            if IsPauseMenuActive() then
                SetPauseMenuActive(false)
            end
            
            -- Disable pause menu controls multiple times per frame
            DisableControlAction(0, 177, true) -- ESC/BACK
            DisableControlAction(0, 200, true) -- Pause Menu
            DisableControlAction(0, 199, true) -- Pause Menu alternative
            DisableControlAction(0, 202, true) -- Pause Menu alternative
            DisableControlAction(0, 322, true) -- Pause Menu alternative (PC)
            DisableControlAction(0, 244, true) -- M (map key)
            
            Wait(0)
        else
            Wait(100)
        end
    end
end)

-- Keybinds
lib.addKeybind({
    name = 'cinematicCamera',
    description = 'Toggle Cinematic Camera',
    defaultKey = Config.Camera.toggleKey,
    onPressed = function()
        if cinematicCameraActive then
            StopCinematicCamera()
        else
            StartCinematicCamera()
        end
    end,
})

lib.addKeybind({
    name = 'cameraMenu',
    description = 'Open Camera Menu',
    defaultKey = 'F6',
    onPressed = function()
        if uiOpen then
            CloseUI()
        else
            OpenUI()
        end
    end,
})

if Config.ClearUI.enabled then
    lib.addKeybind({
        name = 'clearUI',
        description = 'Toggle Clear UI (Hide HUD)',
        defaultKey = Config.ClearUI.toggleKey,
        onPressed = function()
            ToggleClearUI()
        end,
    })
end

-- Commands
RegisterCommand('cinematic', function()
    if cinematicCameraActive then
        StopCinematicCamera()
    else
        StartCinematicCamera()
    end
end, false)

RegisterCommand('cameramenu', function()
    if uiOpen then
        CloseUI()
    else
        OpenUI()
    end
end, false)

if Config.ClearUI.enabled then
    RegisterCommand(Config.ClearUI.command, function()
        ToggleClearUI()
    end, false)
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('toggleCamera', function(data, cb)
    if cinematicCameraActive then
        StopCinematicCamera()
    else
        -- Close UI before starting camera
        if uiOpen then
            CloseUI()
        end
        StartCinematicCamera()
    end
    cb('ok')
end)

RegisterNUICallback('exitCamera', function(data, cb)
    StopCinematicCamera()
    cb('ok')
end)

RegisterNUICallback('toggleUI', function(data, cb)
    if Config.ClearUI.enabled then
        ToggleClearUI()
    end
    cb('ok')
end)

RegisterNUICallback('setZoom', function(data, cb)
    if data.zoom then
        fov = math.max(Config.Camera.fovMin, math.min(Config.Camera.fovMax, tonumber(data.zoom)))
        if camera then
            SetCamFov(camera, fov)
        end
    end
    cb('ok')
end)

RegisterNUICallback('setSpeed', function(data, cb)
    if data.speed then
        if data.speed == 'slow' then
            currentMoveSpeed = Config.Camera.moveSpeedSlow
        elseif data.speed == 'fast' then
            currentMoveSpeed = Config.Camera.moveSpeedFast
        else
            currentMoveSpeed = 0.1 -- normal
        end
    end
    cb('ok')
end)

RegisterNUICallback('resetView', function(data, cb)
    if cinematicCameraActive and camera then
        -- Camera is active: reset camera to original starting position
        local resetPos = nil
        local resetHeading = nil
        
        if originalStartPosition and originalStartHeading then
            resetPos = vector3(originalStartPosition.x, originalStartPosition.y, originalStartPosition.z)
            resetHeading = originalStartHeading
        elseif playerStartPosition and playerStartHeading then
            resetPos = vector3(playerStartPosition.x, playerStartPosition.y, playerStartPosition.z)
            resetHeading = playerStartHeading
        else
            -- Last resort: use current player position
            local ped = PlayerPedId()
            local playerPos = GetEntityCoords(ped)
            local playerHeading = GetEntityHeading(ped)
            resetPos = vector3(playerPos.x, playerPos.y, playerPos.z)
            resetHeading = playerHeading
        end
        
        if resetPos then
            local initialPitch = -30.0 -- Look down at the ground
            local resetRot = vector3(initialPitch, 0.0, resetHeading)
            
            -- Immediately update both target and current position for instant reset
            targetPos = resetPos
            camPos = resetPos
            targetRot = resetRot
            camRot = resetRot
            
            -- Update camera immediately
            SetCamCoord(camera, resetPos.x, resetPos.y, resetPos.z)
            SetCamRot(camera, resetRot.x, resetRot.y, resetRot.z, 2)
            SetFocusPosAndVel(resetPos.x, resetPos.y, resetPos.z, 0.0, 0.0, 0.0)
            
            -- Clear last camera position so next time it starts at original position
            lastCameraPosition = nil
            
            lib.notify({
                title = 'Cinematic Camera',
                description = 'View reset to starting position',
                type = 'info',
                duration = 2000
            })
        else
            lib.notify({
                title = 'Cinematic Camera',
                description = 'Unable to determine reset position',
                type = 'error',
                duration = 2000
            })
        end
    else
        -- Camera is not active: clear saved position so next start will be at current player position
        lastCameraPosition = nil
        originalStartPosition = nil
        originalStartHeading = nil
        
        lib.notify({
            title = 'Cinematic Camera',
            description = 'Saved position cleared. Next camera start will be at your current position.',
            type = 'info',
            duration = 3000
        })
    end
    cb('ok')
end)

RegisterNUICallback('savePosition', function(data, cb)
    if cinematicCameraActive and camera then
        savedPosition = {
            pos = vector3(camPos.x, camPos.y, camPos.z),
            rot = vector3(camRot.x, camRot.y, camRot.z),
            fov = fov
        }
        lib.notify({
            title = 'Cinematic Camera',
            description = 'Position saved',
            type = 'success',
            duration = 2000
        })
    end
    cb('ok')
end)

-- Event Handlers
RegisterNetEvent('cinematic-camera:client:toggle', function()
    -- Check if player is a police officer - if so, let rcore_police handle the camera
    local playerData = nil
    if exports.qbx_core and exports.qbx_core.GetPlayerData then
        playerData = exports.qbx_core:GetPlayerData()
    elseif QBX and QBX.PlayerData then
        playerData = QBX.PlayerData
    end
    
    -- Always check job before opening cinematic camera
    if playerData and playerData.job and playerData.job.name then
        local jobName = string.lower(playerData.job.name or '')
        -- Check for common police job names - block cinematic camera for all police jobs
        if jobName == 'police' or jobName == 'sheriff' or jobName == 'fib' or jobName == 'state' then
            -- Don't start cinematic camera for police - let rcore_police handle it instead
            print("[Cinematic Camera] Blocked for police job: " .. jobName)
            return
        end
    end
    
    if cinematicCameraActive then
        StopCinematicCamera()
    else
        StartCinematicCamera()
    end
end)

RegisterNetEvent('cinematic-camera:client:toggleUI', function()
    if Config.ClearUI.enabled then
        ToggleClearUI()
    end
end)

RegisterNetEvent('cinematic-camera:client:openMenu', function()
    OpenUI()
end)

-- Function to restore UI (used on resource start/stop)
local function RestoreUI()
    -- Always restore HUD when resource starts/stops
    DisplayRadar(true)
    
    -- Restore jg-hud
    if GetResourceState('jg-hud') == 'started' then
        if exports['jg-hud'] and exports['jg-hud'].toggleHud then
            exports['jg-hud']:toggleHud(true)
        end
        SendNUIMessage({
            action = 'showHUD',
            type = 'showHUD',
            hide = false,
            resource = 'jg-hud'
        })
        LocalPlayer.state:set('jgHudHidden', false, false)
    end
    
    -- Restore qbx_hud
    if GetResourceState('qbx_hud') == 'started' then
        if exports.qbx_hud and exports.qbx_hud.showHud then
            exports.qbx_hud:showHud()
        end
        SendNUIMessage({
            action = 'showHUD',
            resource = 'qbx_hud'
        })
    end
    
    -- Restore ulc HUD
    if GetResourceState('ulc') == 'started' then
        pcall(function()
            exports.ulc:SetDisplay(true)
        end)
        pcall(function()
            exports.ulc:SetHudDisabled(false)
        end)
    end
    
    -- Restore any other HUD systems
    SendNUIMessage({
        type = 'showHUD',
        hide = false
    })
    
    -- Reset clear UI state
    clearUIActive = false
end

-- Restore UI on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Wait a moment for resources to be ready
        Wait(500)
        RestoreUI()
        
        -- Update NUI state if UI is open
        if uiOpen then
            SendNUIMessage({
                action = 'updateUIState',
                active = false
            })
        end
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if cinematicCameraActive then
            StopCinematicCamera()
        end
        if uiOpen then
            CloseUI()
        end
        -- Always restore UI when resource stops
        RestoreUI()
    end
end)

