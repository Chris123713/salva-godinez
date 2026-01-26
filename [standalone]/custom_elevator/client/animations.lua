--[[
    CLIENT-SIDE ANIMATION SYSTEM

    Handles all visual effects for the elevator system including:
    - Door open/close animations
    - Movement effects (screen shake, arrows)
    - Screen fades and transitions
]]

-- Play door opening animation
function PlayDoorOpenAnimation()
    if not Config.Effects.doorFadeEffect then return end

    -- Quick fade out and back in to simulate doors opening
    DoScreenFadeOut(200)
    Wait(200)
    DoScreenFadeIn(800)

    -- Subtle camera shake
    if Config.Effects.screenShake then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
    end
end

-- Play door closing animation
function PlayDoorCloseAnimation()
    if not Config.Effects.doorFadeEffect then return end

    -- Slightly longer fade for door closing
    DoScreenFadeOut(300)
    Wait(300)
    DoScreenFadeIn(500)
end

-- Play movement animation during elevator travel
function PlayMovementAnimation(direction, duration)
    local ped = PlayerPedId()

    -- Continuous screen shake during movement
    if Config.Effects.screenShake then
        CreateThread(function()
            local startTime = GetGameTimer()
            local endTime = startTime + duration

            while GetGameTimer() < endTime do
                Wait(100)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', Config.Effects.shakeIntensity)
            end
        end)
    end

    -- Show direction arrow
    if Config.Effects.showDirectionArrows then
        ShowDirectionArrow(direction, duration)
    end
end

-- Show directional arrow (up/down) during movement
function ShowDirectionArrow(direction, duration)
    local arrow = direction == "up" and "⬆" or "⬇"
    local color = direction == "up" and {0, 255, 0, 200} or {255, 165, 0, 200}

    CreateThread(function()
        local startTime = GetGameTimer()
        local endTime = startTime + duration

        while GetGameTimer() < endTime do
            Wait(0)

            -- Animate arrow with pulsing effect
            local progress = (GetGameTimer() - startTime) / duration
            local pulse = math.sin(progress * 10) * 0.1 + 0.9

            SetTextFont(4)
            SetTextScale(1.5 * pulse, 1.5 * pulse)
            SetTextColour(color[1], color[2], color[3], color[4])
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(true)
            AddTextComponentString(arrow)
            DrawText(Config.Effects.arrowPosition.x, Config.Effects.arrowPosition.y)
        end
    end)
end

-- Full elevator arrival animation sequence
function PlayArrivalAnimation()
    -- Play ding sound (handled by sounds.lua)
    -- Play door opening animation
    PlayDoorOpenAnimation()
end

-- Teleport player with animation (used for actual position change)
function TeleportPlayerWithAnimation(coords, heading)
    local playerPed = PlayerPedId()

    -- Fade out
    if Config.FadeScreen then
        DoScreenFadeOut(Config.FadeTime)
        Wait(Config.FadeTime)
    end

    -- Teleport player
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(playerPed, heading)

    -- Small wait before fading back in
    Wait(500)

    -- Fade in
    if Config.FadeScreen then
        DoScreenFadeIn(Config.FadeTime)
    end
end

-- Emergency stop animation (for future use)
function PlayEmergencyStopAnimation()
    local playerPed = PlayerPedId()

    -- Heavy screen shake
    ShakeGameplayCam('LARGE_EXPLOSION_SHAKE', 1.0)

    -- Flash red
    StartScreenEffect('MP_corona_switch', 0, false)
    Wait(500)
    StopScreenEffect('MP_corona_switch')
end

-- Draw 3D text helper (used by interaction system)
function Draw3DText(coords, text, scale)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

print("^2[Custom Elevator]^7 Animation system loaded")
