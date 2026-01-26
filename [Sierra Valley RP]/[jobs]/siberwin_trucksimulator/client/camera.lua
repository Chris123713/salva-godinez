local CameraSystem = {}
local camera = nil
local currentTruck = nil
local isCameraActive = false
local cinematicInterval = nil
local fadeOverlay = nil
local cameraSwayThread = nil 
local originalWeather = nil 
local currentMode = "statistics" 
local isDiagnosticsMode = false 
local isDealershipMode = false 
local selectedTruckData = nil 
local currentCameraIndex = 1 
local previousCameraIndex = 1 
local statisticsTruckModelName = "hauler"


local statisticsCameraPositions = {
vector3(-1556.06, -880.67, 12.17),  
vector3(-1554.79, -893.16, 12.27),  
vector3(-1546.21, -893.34, 16.18),  
vector3(-1540.77, -879.48, 17.10),
vector3(-1547.60, -891.37, 12.74) 
}


local diagnosticsCameraPositions = {
{ name = "bodycamera", pos = vector3(-1598.68, -839.40, 12.91) },
{ name = "enginecamera", pos = vector3(-1595.77, -838.96, 12.43) },
{ name = "sidecamera", pos = vector3(-1597.96, -829.97, 13.39) },
{ name = "rearcamera", pos = vector3(-1590.77, -826.90, 14.75) },
{ name = "frontcamera", pos = vector3(-1596.04, -844.29, 13.67) },
{ name = "fuelcamera", pos = vector3(-1594.59, -836.29, 11.89) }
}

local cameraPositions = statisticsCameraPositions


local function getCurrentCameraPos()
    if not currentCameraIndex or currentCameraIndex < 1 then
        currentCameraIndex = 1
    end
    if isDiagnosticsMode then
        if currentCameraIndex <= #diagnosticsCameraPositions and #diagnosticsCameraPositions > 0 then
            return diagnosticsCameraPositions[currentCameraIndex].pos
        else
            currentCameraIndex = 1
            if #diagnosticsCameraPositions > 0 then
                return diagnosticsCameraPositions[1].pos
            else
                print("[CAMERA ERROR] No diagnostic camera positions available!")
                return nil
            end
        end
    else
        if currentCameraIndex <= #cameraPositions and #cameraPositions > 0 then
            return cameraPositions[currentCameraIndex]
        else
            currentCameraIndex = 1
            if #cameraPositions > 0 then
                return cameraPositions[1]
            else
                print("[CAMERA ERROR] No statistics camera positions available!")
                return nil
            end
        end
    end
end


local function getCurrentCameraName()
    if not currentCameraIndex or currentCameraIndex < 1 then
        currentCameraIndex = 1
    end
    
    if isDiagnosticsMode then
        if currentCameraIndex <= #diagnosticsCameraPositions and #diagnosticsCameraPositions > 0 then
            return diagnosticsCameraPositions[currentCameraIndex].name
        else
            return "bodycamera"
        end
    else
        return "camera" .. currentCameraIndex
    end
end

local truckPosition = vector4(-1549.63, -885.91, 10.50, 85)
local diagnosticTruckPosition = vector4(-1589.27, -836.45, 10.04, 140)
local function getCurrentTruckPosition()
    if isDiagnosticsMode then
        return diagnosticTruckPosition
    else
        return truckPosition
    end
end
local CAMERA_DURATION = 8000 
local FADE_DURATION = 300  
local DIAGNOSTIC_TRANSITION_DURATION = 1000 


function CameraSystem.diagnosticTransition(targetIndex)
    if not isCameraActive or not isDiagnosticsMode then return end
    
    CameraSystem.stopCameraSway()
    
    if not isCameraActive then
        return
    end
    
    local currentPos = getCurrentCameraPos()
    if not currentPos then return end
    
    if targetIndex then
        currentCameraIndex = targetIndex
    end
    
    local targetPos = getCurrentCameraPos()
    if not targetPos then return end
    
    if currentPos.x == targetPos.x and currentPos.y == targetPos.y and currentPos.z == targetPos.z then
        return
    end
    
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        local transitionDuration = DIAGNOSTIC_TRANSITION_DURATION
        
        while GetGameTimer() - startTime < transitionDuration and camera and isCameraActive do
            local progress = (GetGameTimer() - startTime) / transitionDuration
            
            local easedProgress = progress * progress * (3.0 - 2.0 * progress)
            
            local newX = currentPos.x + (targetPos.x - currentPos.x) * easedProgress
            local newY = currentPos.y + (targetPos.y - currentPos.y) * easedProgress
            local newZ = currentPos.z + (targetPos.z - currentPos.z) * easedProgress
            
            if camera and isCameraActive then
                SetCamCoord(camera, newX, newY, newZ)
                local currentTruckPos = getCurrentTruckPosition()
                PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
            end
            
            Wait(16) 
        end
        
        if camera and isCameraActive then
            SetCamCoord(camera, targetPos.x, targetPos.y, targetPos.z)
            local currentTruckPos = getCurrentTruckPosition()
            PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
        end
    end)
end

function CameraSystem.createCamera()
    if camera then
        CameraSystem.destroyCamera()
    end
    
    local pos = getCurrentCameraPos()
    
    if not pos then
        print("[CAMERA ERROR] Failed to get camera position! Mode: " .. (isDiagnosticsMode and "diagnostics" or "statistics") .. ", Index: " .. currentCameraIndex)
        return
    end
    
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    SetCamActive(camera, true)
    
    SetCamCoord(camera, pos.x, pos.y, pos.z)
    
    local currentTruckPos = getCurrentTruckPosition()
    PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
    
    SetCamFov(camera, 50.0)
    
    RenderScriptCams(true, false, 0, true, false) 
    
    isCameraActive = true
    
    if not isDiagnosticsMode and not isDealershipMode then
        CameraSystem.startCameraSway()
    end
end

function CameraSystem.startCameraSway()
    if isDiagnosticsMode then
        return
    end
    
    CameraSystem.stopCameraSway()
    
    cameraSwayThread = Citizen.CreateThread(function()
        local moveSpeed = 0.1 
        local startTime = GetGameTimer() 
        local lastUpdate = startTime
        
        while isCameraActive and camera and cameraSwayThread do
            local currentTime = GetGameTimer()
            
            if currentTime - lastUpdate >= 32 then 
                local elapsedTime = (currentTime - startTime) / 1000
                
                local originalPos = getCurrentCameraPos()
                if originalPos and camera and isCameraActive then
                    local offsetX = elapsedTime * moveSpeed
                    
                    local newX = originalPos.x + offsetX
                    local newY = originalPos.y
                    local newZ = originalPos.z
                    
                    if DoesEntityExist(currentTruck) then
                        SetCamCoord(camera, newX, newY, newZ)
                        local currentTruckPos = getCurrentTruckPosition()
                        PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
                    end
                end
                
                lastUpdate = currentTime
            end
            
            Wait(16) 
        end
        
        cameraSwayThread = nil
    end)
end

function CameraSystem.stopCameraSway()
    if cameraSwayThread then
        cameraSwayThread = nil 
        Wait(10) 
    end
end


function CameraSystem.createFadeOverlay()
    if fadeOverlay then return end
    
    fadeOverlay = RequestScaleformMovie("mp_big_message_freemode")
    while not HasScaleformMovieLoaded(fadeOverlay) do
        Wait(0)
    end
end


function CameraSystem.fadeOut()
    CameraSystem.createFadeOverlay()
    DoScreenFadeOut(FADE_DURATION)
end


function CameraSystem.fadeIn()
    DoScreenFadeIn(FADE_DURATION)
end


function CameraSystem.destroyCamera()
    CameraSystem.stopCameraSway()
    
    if camera then
        DestroyCam(camera, false)
        camera = nil
    end
    
    RenderScriptCams(false, false, 0, true, false) 
    isCameraActive = false
end

function CameraSystem.cinematicTransition()
    if not isCameraActive then 
        return 
    end
    
    if isDiagnosticsMode then
        return
    end
    
    CameraSystem.stopCameraSway()
    
    CameraSystem.fadeOut()
    
    Wait(FADE_DURATION)
    
    if not isCameraActive then
        DoScreenFadeIn(FADE_DURATION)
        return
    end
    
    if camera then
        DestroyCam(camera, false)
        camera = nil
    end
    
    currentCameraIndex = currentCameraIndex + 1
    if currentCameraIndex > #cameraPositions then
        currentCameraIndex = 1
    end
    
    local pos = getCurrentCameraPos()
    if not pos then
        currentCameraIndex = 1
        pos = getCurrentCameraPos()
    end
    
    camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(camera, true)
    SetCamCoord(camera, pos.x, pos.y, pos.z)
    local currentTruckPos = getCurrentTruckPosition()
    PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
    SetCamFov(camera, 50.0)
    RenderScriptCams(true, false, 0, true, false)
    
    Wait(100)
    if camera and isCameraActive then
        SetCamCoord(camera, pos.x, pos.y, pos.z)
        local currentTruckPos = getCurrentTruckPosition()
        PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
    end
    
    if isCameraActive and not isDiagnosticsMode then
        CameraSystem.startCameraSway()
    end
    
    CameraSystem.fadeIn()
end

function CameraSystem.startCinematicLoop()
    if cinematicInterval then
        cinematicInterval = nil 
    end
    
    cinematicInterval = Citizen.CreateThread(function()
        while isCameraActive do
            Wait(CAMERA_DURATION)
            
            if isCameraActive then 
                CameraSystem.cinematicTransition()
            else
                break 
            end
        end
        cinematicInterval = nil
    end)
end


function CameraSystem.stopCinematicLoop()
    if cinematicInterval then
        cinematicInterval = nil
    end
end

function CameraSystem.spawnTruck()
    if currentTruck and DoesEntityExist(currentTruck) then
        DeleteEntity(currentTruck)
    end
    
    local truckModel
    local truckPlate = nil
    local truckColors = {}
    
    if isDiagnosticsMode and selectedTruckData then
        truckModel = GetHashKey(selectedTruckData.vehicle_spawn_name)
        truckPlate = selectedTruckData.plate
        
        if selectedTruckData.primary_color_r then
            truckColors.primary = { r = selectedTruckData.primary_color_r, g = selectedTruckData.primary_color_g, b = selectedTruckData.primary_color_b }
        end
        if selectedTruckData.secondary_color_r then
            truckColors.secondary = { r = selectedTruckData.secondary_color_r, g = selectedTruckData.secondary_color_g, b = selectedTruckData.secondary_color_b }
        end
    else
        truckModel = GetHashKey(statisticsTruckModelName)
    end
    
    RequestModel(truckModel)
    
    local timeout = 5000
    local waited = 0
    while not HasModelLoaded(truckModel) do
        Wait(10)
        waited = waited + 10
        if waited >= timeout then
            print("[CAMERA ERROR] Model load timeout: " .. tostring(truckModel))
            return false
        end
    end
    
    local currentTruckPos = getCurrentTruckPosition()
    currentTruck = CreateVehicle(truckModel, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z, currentTruckPos.w, false, false)
    
    if DoesEntityExist(currentTruck) then
        SetEntityAsMissionEntity(currentTruck, true, true)
        SetEntityVisible(currentTruck, true, false)
        SetEntityCollision(currentTruck, false, false)
        SetEntityInvincible(currentTruck, true)
        SetVehicleOnGroundProperly(currentTruck)
        
        if truckPlate then
            SetVehicleNumberPlateText(currentTruck, truckPlate)
        end
        
        if truckColors.primary then
            SetVehicleCustomPrimaryColour(currentTruck, truckColors.primary.r, truckColors.primary.g, truckColors.primary.b)
        end
        if truckColors.secondary then
            SetVehicleCustomSecondaryColour(currentTruck, truckColors.secondary.r, truckColors.secondary.g, truckColors.secondary.b)
        end
        
        SetVehicleEngineHealth(currentTruck, 1000.0)
        SetVehicleBodyHealth(currentTruck, 1000.0)
        SetVehicleFuelLevel(currentTruck, 100.0)
        SetVehicleDirtLevel(currentTruck, 0.0)
        SetVehicleDeformationFixed(currentTruck)
        SetVehicleEngineOn(currentTruck, false, false, false)
        SetVehicleLights(currentTruck, 2) 
        SetVehicleFullbeam(currentTruck, true) 
        FreezeEntityPosition(currentTruck, true)
        SetVehicleDoorsLocked(currentTruck, 2)
    end
    
    return true
end

function CameraSystem.deleteTruck()
    if currentTruck and DoesEntityExist(currentTruck) then
        DeleteEntity(currentTruck)
        currentTruck = nil
    end
end

function CameraSystem.setStatisticsPreviewModel(modelName)
    if modelName and type(modelName) == 'string' and #modelName > 0 then
        if currentTruck and DoesEntityExist(currentTruck) then
            DeleteEntity(currentTruck)
            currentTruck = nil
        end
        statisticsTruckModelName = modelName
        return true
    end
    return false
end

function CameraSystem.respawnStatisticsTruck()
    if not isCameraActive or isDiagnosticsMode then 
        return false 
    end
    return CameraSystem.spawnTruck()
end

function CameraSystem.updateTruckColor(colorData)
    if not currentTruck or not DoesEntityExist(currentTruck) or not colorData then
        return false
    end
    
    if colorData.type == 'metallic' then
        SetVehicleColours(currentTruck, 0, 0) 
        SetVehicleCustomPrimaryColour(currentTruck, colorData.r, colorData.g, colorData.b)
        SetVehicleExtraColours(currentTruck, 0, 0) 
        SetVehicleModColor_2(currentTruck, 3, 0) 
    else
        SetVehicleCustomPrimaryColour(currentTruck, colorData.r, colorData.g, colorData.b)
    end
    
    return true
end

function CameraSystem.getSelectedTruckData(callback)
    lib.callback('trucker:getSelectedTruck', false, function(result)
        if result and result.success and result.vehicle then
            selectedTruckData = result.vehicle
        else
            selectedTruckData = nil
        end
        callback()
    end)
end

function CameraSystem.respawnDiagnosticsTruck()
    print("[DEBUG] respawnDiagnosticsTruck CALLED.")
    if not isDiagnosticsMode or not isCameraActive then
        print("[DEBUG-ERROR] respawnDiagnosticsTruck: Not in diagnostics mode or camera not active.")
        return
    end

    CameraSystem.getSelectedTruckData(function()
        print(('[DEBUG] respawnDiagnosticsTruck: getSelectedTruckData callback. Data: %s'):format(json.encode(selectedTruckData)))
        CameraSystem.spawnTruck()
    end)
end

function CameraSystem.startCamera()
    DoScreenFadeOut(100)
    Wait(100)
    RenderScriptCams(false, false, 0, true, false)
    CameraSystem.createCamera()
    DoScreenFadeIn(FADE_DURATION)
    DisplayRadar(false) 
    SetMinimapHideFow(true) 
    
    local pos = getCurrentCameraPos()
    if pos then
        SetCamCoord(camera, pos.x, pos.y, pos.z)
        local currentTruckPos = getCurrentTruckPosition()
        PointCamAtCoord(camera, currentTruckPos.x, currentTruckPos.y, currentTruckPos.z)
    end
end

function CameraSystem.nextCamera()
    if not isCameraActive or not isDiagnosticsMode then return end
    
    local nextIndex = currentCameraIndex + 1
    if nextIndex > #diagnosticsCameraPositions then
        nextIndex = 1
    end
    
    CameraSystem.diagnosticTransition(nextIndex)
end

function CameraSystem.previousCamera()
    if not isCameraActive or not isDiagnosticsMode then return end
    
    local prevIndex = currentCameraIndex - 1
    if prevIndex < 1 then
        prevIndex = #diagnosticsCameraPositions
    end
    
    CameraSystem.diagnosticTransition(prevIndex)
end
function CameraSystem.setCameraByName(cameraName)
    if not isCameraActive or not isDiagnosticsMode then return end
    
    local targetIndex = nil
    for i, camData in ipairs(diagnosticsCameraPositions) do
        if camData.name == cameraName then
            targetIndex = i
            break
        end
    end
    
    if not targetIndex then return end
    
    previousCameraIndex = currentCameraIndex
    
    CameraSystem.diagnosticTransition(targetIndex)
end

function CameraSystem.returnToPreviousCamera()
    if not isCameraActive or not isDiagnosticsMode then return end
    
    CameraSystem.diagnosticTransition(previousCameraIndex)
end

function CameraSystem.switchToCamera(cameraName)
    if not isCameraActive or not isDiagnosticsMode then return end
    
    previousCameraIndex = currentCameraIndex
    
    CameraSystem.setCameraByName(cameraName)
end

function CameraSystem.setMode(mode)
    currentMode = mode or "statistics"
    cameraPositions = statisticsCameraPositions
end


function CameraSystem.activate(mode)
    CameraSystem.setMode(mode)
    
    isDiagnosticsMode = (mode == "diagnostics")
    isDealershipMode = (mode == "dealership")
    
    if not isCameraActive then
        currentCameraIndex = 1
        
        if not currentCameraIndex then
            currentCameraIndex = 1
        end
        
        if isDiagnosticsMode then
            if #diagnosticsCameraPositions == 0 then
                print("[CAMERA ERROR] No diagnostic camera positions defined!")
                return
            end
        else
            if #cameraPositions == 0 then
                print("[CAMERA ERROR] No statistics camera positions defined!")
                return
            end
        end
        
        if isDiagnosticsMode then
            CameraSystem.getSelectedTruckData(function()
                CameraSystem.spawnTruck()
                CameraSystem.startCamera()
            end)
        else
            CameraSystem.spawnTruck()
            CameraSystem.startCamera()
        end
    end
end

function CameraSystem.deactivate()
    if isCameraActive then
        
        CameraSystem.stopCinematicLoop()
        CameraSystem.destroyCamera()
        CameraSystem.deleteTruck()
        isDiagnosticsMode = false
        isDealershipMode = false
        selectedTruckData = nil
        DoScreenFadeIn(500) 
        DisplayRadar(true) 
        SetMinimapHideFow(false) 
        
        if fadeOverlay then
            SetScaleformMovieAsNoLongerNeeded(fadeOverlay)
            fadeOverlay = nil
        end
        
        isCameraActive = false
    end
end

-- Export functions (LOCAL PLAYER ONLY SYSTEM)
exports('activateCameraSystem', CameraSystem.activate)
exports('deactivateCameraSystem', CameraSystem.deactivate)
exports('activateStatisticsCamera', function() CameraSystem.activate("statistics") end)
exports('activateDealershipCamera', function() CameraSystem.activate("dealership") end)
exports('activateDiagnosticsCamera', function() CameraSystem.activate("diagnostics") end)
exports('nextDiagnosticsCamera', CameraSystem.nextCamera)
exports('previousDiagnosticsCamera', CameraSystem.previousCamera)
exports('setCameraByName', CameraSystem.setCameraByName)
exports('switchToCamera', CameraSystem.switchToCamera)
exports('returnToPreviousCamera', CameraSystem.returnToPreviousCamera)
exports('getCurrentCameraName', getCurrentCameraName)
exports('updateCameraTruckColor', CameraSystem.updateTruckColor) 
exports('respawnDiagnosticsTruck', CameraSystem.respawnDiagnosticsTruck) 
exports('setStatisticsPreviewModel', CameraSystem.setStatisticsPreviewModel)
exports('respawnStatisticsTruck', CameraSystem.respawnStatisticsTruck)

return CameraSystem