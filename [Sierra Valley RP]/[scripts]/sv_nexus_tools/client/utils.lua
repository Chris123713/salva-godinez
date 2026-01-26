-- Client utility functions

ClientUtils = {}

-- Debug print helper
function ClientUtils.Debug(...)
    if Config.Debug.Enabled then
        print('^3[sv_nexus_tools]^7', ...)
    end
end

-- Play sound effect
function ClientUtils.PlaySound(soundType)
    local sound = Constants.Sounds[soundType]
    if sound then
        PlaySoundFrontend(-1, sound.soundId, sound.soundSet, true)
    end
end

-- Request model with timeout
function ClientUtils.RequestModel(model, timeout)
    timeout = timeout or 5000

    if type(model) == 'string' then
        model = joaat(model)
    end

    if not IsModelValid(model) then
        return false
    end

    RequestModel(model)

    local startTime = GetGameTimer()
    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

-- Get ground Z coordinate
function ClientUtils.GetGroundZ(coords, maxAttempts)
    maxAttempts = maxAttempts or 10

    for i = 1, maxAttempts do
        local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + (i * 10.0), false)
        if found then
            return groundZ
        end
        Wait(10)
    end

    return coords.z
end

-- Check if position is clear
function ClientUtils.IsPositionClear(coords, radius, flags)
    radius = radius or 2.0
    flags = flags or 10 -- Default: vehicles and peds

    return not IsAnyEntityNearPoint(coords.x, coords.y, coords.z, radius, true, true, true)
end

-- Raycast from camera
function ClientUtils.RaycastFromCamera(distance, flags)
    distance = distance or 100.0
    flags = flags or -1

    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)

    local radX = camRot.x * math.pi / 180.0
    local radZ = camRot.z * math.pi / 180.0

    local dirX = -math.sin(radZ) * math.cos(radX)
    local dirY = math.cos(radZ) * math.cos(radX)
    local dirZ = math.sin(radX)

    local endCoords = vector3(
        camCoords.x + dirX * distance,
        camCoords.y + dirY * distance,
        camCoords.z + dirZ * distance
    )

    local ray = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        endCoords.x, endCoords.y, endCoords.z,
        flags, PlayerPedId(), 7
    )

    return GetShapeTestResult(ray)
end

-- Notify helper (uses ox_lib)
function ClientUtils.Notify(title, message, type)
    lib.notify({
        title = title,
        description = message,
        type = type or 'info'
    })
end

-- Distance to coords
function ClientUtils.DistanceTo(coords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - coords)
end

-- Is near coords
function ClientUtils.IsNear(coords, distance)
    return ClientUtils.DistanceTo(coords) <= (distance or 5.0)
end

-- Draw 3D text (for debug)
function ClientUtils.Draw3DText(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

-- Create blip
function ClientUtils.CreateBlip(coords, sprite, color, text, scale)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite or 1)
    SetBlipColour(blip, color or 1)
    SetBlipScale(blip, scale or 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text or "Mission")
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Remove blip safely
function ClientUtils.RemoveBlip(blip)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end
