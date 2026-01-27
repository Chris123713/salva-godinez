--[[
    Mr. X Phone Hack System
    =======================
    Demonstrates Mr. X's power by taking control of the player's phone,
    capturing a selfie, and sending it back to them.
]]

local isHacking = false
local selfieCamera = nil

-- ============================================
-- SCREEN GLITCH EFFECT
-- ============================================

local function ApplyGlitchEffect()
    -- Screen shake
    ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)

    -- Flash effect
    AnimpostfxPlay('FocusOut', 0, false)

    -- Sound effect (phone buzz/glitch)
    PlaySoundFrontend(-1, 'HACKING_CLICK', 'HUD_FRONTEND_MP_COLLECTABLE_SOUNDS', true)
end

local function StopGlitchEffect()
    AnimpostfxStop('FocusOut')
    StopGameplayCamShaking(true)
end

-- ============================================
-- SELFIE CAMERA SYSTEM
-- Creates a camera in front of the player's face
-- ============================================

local function CreateSelfieCamera()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)

    -- Get the bone index for the head
    local headBone = GetPedBoneIndex(ped, 31086)  -- SKEL_Head bone
    local headPos = GetPedBoneCoords(ped, headBone, 0.0, 0.0, 0.0)

    -- Calculate camera position in front of and slightly above the face
    local forwardOffset = 0.7  -- Distance in front of face
    local upOffset = 0.1       -- Slightly above eye level
    local headingRad = math.rad(pedHeading)

    local camX = headPos.x + (math.sin(-headingRad) * forwardOffset)
    local camY = headPos.y + (math.cos(-headingRad) * forwardOffset)
    local camZ = headPos.z + upOffset

    -- Create the camera
    selfieCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(selfieCamera, camX, camY, camZ)

    -- Point camera at the player's head
    PointCamAtPedBone(selfieCamera, ped, headBone, 0.0, 0.0, 0.1, true)

    -- Set camera properties for a phone-like selfie look
    SetCamFov(selfieCamera, 50.0)  -- Narrower FOV like phone camera
    SetCamNearClip(selfieCamera, 0.1)

    -- Activate the camera
    RenderScriptCams(true, false, 0, true, true)

    return true
end

local function DestroySelfieCamera()
    if selfieCamera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(selfieCamera, false)
        selfieCamera = nil
    end
end

-- ============================================
-- SCREENSHOT CAPTURE
-- Requires screenshot-basic resource
-- ============================================

local function CaptureScreenshot(callback)
    -- Check if screenshot-basic is available
    if GetResourceState('screenshot-basic') ~= 'started' then
        print('^1[MR_X:PHONE_HACK]^7 screenshot-basic resource not running')
        callback(nil, 'Screenshot resource not available')
        return
    end

    -- Request screenshot upload to Discord webhook
    exports['screenshot-basic']:requestScreenshotUpload(
        Config.PhoneHack.DiscordWebhook,
        'files[]',
        {
            encoding = 'jpg',
            quality = 0.85
        },
        function(data)
            -- Parse Discord response to get image URL
            local response = json.decode(data)
            if response and response.attachments and response.attachments[1] then
                local imageUrl = response.attachments[1].url
                -- Remove query params for cleaner URL (optional)
                imageUrl = imageUrl:gsub('%?.*', '')
                callback(imageUrl, nil)
            else
                print('^1[MR_X:PHONE_HACK]^7 Failed to parse Discord response:', data)
                callback(nil, 'Failed to upload screenshot')
            end
        end
    )
end

-- ============================================
-- MAIN PHONE HACK EVENT
-- ============================================

RegisterNetEvent('mrx:client:phoneHack', function()
    if isHacking then return end
    isHacking = true

    -- Check config
    if not Config.PhoneHack or not Config.PhoneHack.Enabled then
        isHacking = false
        return
    end

    if not Config.PhoneHack.DiscordWebhook or Config.PhoneHack.DiscordWebhook == '' then
        print('^1[MR_X:PHONE_HACK]^7 Discord webhook not configured')
        isHacking = false
        return
    end

    print('^3[MR_X:PHONE_HACK]^7 Phone hack initiated')

    -- Phase 1: Glitch effect
    if Config.PhoneHack.UseGlitchEffect then
        ApplyGlitchEffect()
    end

    -- Small delay for dramatic effect
    Wait(500)

    -- Phase 2: Create selfie camera looking at player's face
    local cameraCreated = CreateSelfieCamera()
    if cameraCreated then
        Wait(300)  -- Let camera settle
    end

    -- Phase 3: Capture screenshot
    CaptureScreenshot(function(imageUrl, error)
        -- Cleanup camera
        DestroySelfieCamera()

        -- Cleanup glitch effect
        if Config.PhoneHack.UseGlitchEffect then
            StopGlitchEffect()
        end

        if imageUrl then
            print('^2[MR_X:PHONE_HACK]^7 Screenshot captured:', imageUrl)
            -- Send URL back to server
            TriggerServerEvent('mrx:server:phoneHackComplete', imageUrl)
        else
            print('^1[MR_X:PHONE_HACK]^7 Screenshot failed:', error)
            TriggerServerEvent('mrx:server:phoneHackFailed', error)
        end

        -- Additional wait before allowing another hack
        Wait(Config.PhoneHack.HackDurationMs or 3000)
        isHacking = false
    end)
end)

-- ============================================
-- PREVIEW HACK EFFECT (For admin testing)
-- ============================================

RegisterNetEvent('mrx:client:previewHackEffect', function()
    if Config.PhoneHack.UseGlitchEffect then
        ApplyGlitchEffect()
        Wait(Config.PhoneHack.HackDurationMs or 3000)
        StopGlitchEffect()
    end
end)
