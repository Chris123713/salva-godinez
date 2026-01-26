-- Inspired by esx-legacy esx_property
-- https://github.com/esx-framework/esx_core/blob/1.9.0/%5Besx_addons%5D/esx_property/client/cctv.lua
-- Credits where its due!

RegisterNUICallback('viewCCTV', function(homeId, cb)
    local home = Homes[homeId]
    if home then
        ToggleNuiFrame(false)
        ViewCCTV(homeId)
    end
    cb(1)
end)

function ViewCCTV(homeId)
    local list = {}

    local home = Homes[homeId]
    if not home then
        return print('^1[HOUSING] ^0The home does not exist')
    end

    local aptId = LocalPlayer.state.CurrentApartment
    local data = lib.callback.await('Housing:server:GetData', false, home.identifier, aptId)
    -- Initialize furniture, storage and wardrobes
    home:SetData(data, aptId)

    if home.properties.furniture and type(home.properties.furniture) == 'table' and next(home.properties.furniture) then
        for i = 1, #home.properties.furniture do
            local furniture = home.properties.furniture[i]
            if not furniture then goto continue end
            if FurnitureModelList[furniture.model] and FurnitureModelList[furniture.model].type == 'cctv' then
                local modelData = FurnitureModelList[furniture.model]
                local id = #list + 1
                list[id] = furniture
                list[id].coords = ToVector3(furniture.coords)
                list[id].pitch = modelData.pitch or Config.CCTV.pitch
                list[id].yaw = modelData.yaw or Config.CCTV.yaw
            end
            ::continue::
        end
    end

    home.cctv:Enter(list)
end

exports('ViewCCTV', ViewCCTV)

function PreviewCCTV(coords, rotation)
    Notify(locale('housing'), locale('setup_cctv_heading'), 'info', 3000)
    if IsResourceStarted('bcs_hud') then
        exports['bcs_hud']:keybind({
            title = locale('cctv_setup_controls'),
            items = {
                {
                    description = locale('keybind_cctv_move'),
                    buttons = { 'W', 'A', 'S', 'D' }
                },
                {
                    description = locale('keybind_cctv_save'),
                    buttons = { 'ENTER' }
                },
                {
                    description = locale('keybind_cctv_exit'),
                    buttons = { 'BACKSPACE' }
                },
            }
        })
    else
        displayHelp(locale('prompt_cctv_preview_keybinds'), 'bottom-right')
    end
    DoScreenFadeOut(500)
    Wait(500)
    local initialCoords = GetEntityCoords(PlayerPedId())
    ClearFocus()
    local playerPed = PlayerPedId()
    local cctvcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords, 0, 0, 0, Config.CCTV.FOV)
    SetCamRot(cctvcam, rotation.x, rotation.y, rotation.z, 2)
    SetCamActive(cctvcam, true)
    SetTimecycleModifier("scanline_cam_cheap")

    DisableAllControlActions(0)
    FreezeEntityPosition(playerPed, true)
    SetEntityCollision(playerPed, false, true)
    SetEntityVisible(playerPed, false)
    SetTimecycleModifierStrength(2.0)
    SetFocusArea(coords, 0.0, 0.0, 0.0)
    PointCamAtCoord(cctvcam, coords)
    RenderScriptCams(true, false, 1, true, false)
    Wait(1000)
    DoScreenFadeIn(500)
    RequestAmbientAudioBank("Phone_Soundset_Franklin", 0, 0)
    RequestAmbientAudioBank("HintCamSounds", 0, 0)
    local initCameraRot = GetCamRot(cctvcam, 2)
    local finalCamRot = initCameraRot
    while IsCamActive(cctvcam) do
        Wait(0)
        DisableAllControlActions(0)
        EnableControlAction(0, 245, true)
        EnableControlAction(0, 246, true)
        EnableControlAction(0, 249, true)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
        -- ROTATE LEFT
        local getCameraRot = GetCamRot(cctvcam, 2)

        if IsDisabledControlPressed(0, Config.CCTV.Controls.Left) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z + Config.CCTV.RotateSpeed, 2)
        end
        -- ROTATE RIGHT
        if IsDisabledControlPressed(0, Config.CCTV.Controls.Right) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z - Config.CCTV.RotateSpeed, 2)
        end

        -- ROTATE UP
        if IsDisabledControlPressed(0, Config.CCTV.Controls.Up) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x + Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
        end

        if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
        end

        if IsDisabledControlJustPressed(1, 191) then
            finalCamRot = getCameraRot
            Notify(locale('housing'), locale('cctv_rotation_saved'), 'success', 3000)
        end

        if IsDisabledControlJustPressed(1, Config.CCTV.Controls.Exit) then
            if finalCamRot ~= initCameraRot then
                DoScreenFadeOut(1000)
                InCCTV = false
                Wait(1000)
                ClearFocus()
                ClearTimecycleModifier()
                ClearExtraTimecycleModifier()
                RenderScriptCams(false, false, 0, true, false)
                DestroyCam(cctvcam, false)
                SetFocusEntity(playerPed)
                SetNightvision(false)
                SetSeethrough(false)
                SetEntityCollision(playerPed, true, true)
                FreezeEntityPosition(playerPed, false)
                SetEntityVisible(playerPed, true)
                SetEntityCoordsNoOffset(playerPed, initialCoords)
                Wait(1500)
                DoScreenFadeIn(1000)
                break
            else
                Notify(locale('housing'), locale('cctv_rotation_same'), 'error', 3000)
            end
        end
    end
    if IsResourceStarted('bcs_hud') then
        exports.bcs_hud:closeKeybind()
    else
        closeHelp()
    end
    return finalCamRot
end

local initialCoords = nil

RegisterNetEvent('Housing:client:ViewCCTV', function(homeId, coords, rotation, pitch, yaw)
    DoScreenFadeOut(500)
    Wait(500)
    initialCoords = GetEntityCoords(PlayerPedId())
    local home = Homes[homeId]
    if not home then return end
    lib.callback('Housing:server:EnterCCTV', false, function(canCCTV)
        if canCCTV then
            local cctvcam = nil
            ClearFocus()
            if IsResourceStarted('bcs_hud') then
                exports['bcs_hud']:keybind({
                    title = locale('cctv_controls'),
                    items = {
                        {
                            description = locale('keybind_cctv_move'),
                            buttons = { 'W', 'A', 'S', 'D' }
                        },
                        {
                            description = locale('keybind_cctv_zoom'),
                            buttons = { 'SCROLL' }
                        },
                        {
                            description = locale('keybind_cctv_exit'),
                            buttons = { 'BACKSPACE' }
                        },
                    }
                })
            else
                displayHelp(locale('prompt_cctv_keybinds'), 'bottom-right')
            end
            local infront = ToVector3(home.properties.entry) + ToVector3(coords)
            local playerPed = PlayerPedId()
            cctvcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", infront, 0, 0, 0, Config.CCTV.FOV)
            SetCamRot(cctvcam, rotation.x, rotation.y, rotation.z, 2)
            SetCamActive(cctvcam, true)
            SetTimecycleModifier("scanline_cam_cheap")

            DisableAllControlActions(0)
            FreezeEntityPosition(playerPed, true)
            SetEntityCollision(playerPed, false, true)
            SetTimecycleModifierStrength(2.0)
            SetFocusArea(infront, 0.0, 0.0, 0.0)
            PointCamAtCoord(cctvcam, infront)
            RenderScriptCams(true, false, 1, true, false)
            Wait(1000)
            DoScreenFadeIn(500)
            RequestAmbientAudioBank("Phone_Soundset_Franklin", 0, 0)
            RequestAmbientAudioBank("HintCamSounds", 0, 0)
            local initCameraRot = GetCamRot(cctvcam, 2)
            while IsCamActive(cctvcam) do
                Wait(5)
                DisableAllControlActions(0)
                EnableControlAction(0, 245, true)
                EnableControlAction(0, 246, true)
                EnableControlAction(0, 249, true)
                HideHudComponentThisFrame(7)
                HideHudComponentThisFrame(8)
                HideHudComponentThisFrame(9)
                HideHudComponentThisFrame(6)
                HideHudComponentThisFrame(19)
                HideHudAndRadarThisFrame()
                -- ROTATE LEFT
                local getCameraRot = GetCamRot(cctvcam, 2)
                if IsDisabledControlPressed(0, Config.CCTV.Controls.Left) and getCameraRot.z < (initCameraRot.z + (pitch / 2)) then
                    PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
                    SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z + Config.CCTV.RotateSpeed, 2)
                end
                -- ROTATE RIGHT
                if IsDisabledControlPressed(0, Config.CCTV.Controls.Right) and getCameraRot.z > (initCameraRot.z - (pitch / 2)) then
                    PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
                    SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z - Config.CCTV.RotateSpeed, 2)
                end

                -- ROTATE UP
                if IsDisabledControlPressed(0, Config.CCTV.Controls.Up) and getCameraRot.x < (initCameraRot.x + (yaw / 2)) then
                    PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
                    SetCamRot(cctvcam, getCameraRot.x + Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
                end

                if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > (initCameraRot.z - (yaw / 2)) then
                    PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
                    SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
                end

                if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomIn) and GetCamFov(cctvcam) > Config.CCTV.MaxZoom then
                    SetCamFov(cctvcam, GetCamFov(cctvcam) - 1.0)
                end

                if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomOut) and GetCamFov(cctvcam) < Config.CCTV.MinZoom then
                    SetCamFov(cctvcam, GetCamFov(cctvcam) + 1.0)
                end

                if IsDisabledControlPressed(1, 190) then
                    home.cctv:NextCamera()
                    break
                end

                if IsDisabledControlPressed(1, Config.CCTV.Controls.Exit) then
                    DoScreenFadeOut(1000)
                    lib.callback("Housing:server:LeaveCCTV", false, function(CanExit)
                        if CanExit then
                            InCCTV = false
                            Wait(1000)
                            ClearFocus()
                            ClearTimecycleModifier()
                            ClearExtraTimecycleModifier()
                            RenderScriptCams(false, false, 0, true, false)
                            DestroyCam(cctvcam, false)
                            SetFocusEntity(playerPed)
                            SetNightvision(false)
                            SetSeethrough(false)
                            SetEntityCollision(playerPed, true, true)
                            FreezeEntityPosition(playerPed, false)
                            SetEntityCoordsNoOffset(playerPed, initialCoords)
                            Wait(1500)
                            DoScreenFadeIn(1000)
                        end
                    end, homeId)
                    if IsResourceStarted('bcs_hud') then
                        exports.bcs_hud:closeKeybind()
                    else
                        closeHelp()
                    end
                    break
                end
            end
        else
            Wait(1500)
            DoScreenFadeIn(1000)
        end
    end, homeId, LocalPlayer.state.isInsideHome)
end)

RegisterNetEvent('Housing:client:NextCam', function(homeId, coords, rotation, pitch, yaw)
    local home = Homes[homeId]
    if not home then return end
    DoScreenFadeOut(1000)
    Wait(1000)
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cctvcam, false)
    coords = ToVector3(coords)
    local infront = ToVector3(home.properties.entry) + coords
    cctvcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", infront, 0, 0, 0, Config.CCTV.FOV)
    SetCamRot(cctvcam, rotation.x, rotation.y, rotation.z, 2)
    SetCamActive(cctvcam, true)
    RenderScriptCams(true, false, 1, true, false)
    Wait(1000)
    DoScreenFadeIn(500)
    local initCameraRot = GetCamRot(cctvcam, 2)
    while IsCamActive(cctvcam) do
        Wait(5)
        DisableAllControlActions(0)
        EnableControlAction(0, 245, true)
        EnableControlAction(0, 246, true)
        EnableControlAction(0, 249, true)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
        -- ROTATE LEFT
        local getCameraRot = GetCamRot(cctvcam, 2)
        if IsDisabledControlPressed(0, Config.CCTV.Controls.Left) and getCameraRot.z < (initCameraRot.z + (pitch / 2)) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z + Config.CCTV.RotateSpeed, 2)
        end
        -- ROTATE RIGHT
        if IsDisabledControlPressed(0, Config.CCTV.Controls.Right) and getCameraRot.z > (initCameraRot.z - (pitch / 2)) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x, 0.0, getCameraRot.z - Config.CCTV.RotateSpeed, 2)
        end

        -- ROTATE UP
        if IsDisabledControlPressed(0, Config.CCTV.Controls.Up) and getCameraRot.x < (initCameraRot.x + (yaw / 2)) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x + Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
        end

        if IsDisabledControlPressed(0, Config.CCTV.Controls.Down) and getCameraRot.x > (initCameraRot.z - (yaw / 2)) then
            PlaySoundFrontend(-1, "	FocusIn", "HintCamSounds", false)
            SetCamRot(cctvcam, getCameraRot.x - Config.CCTV.RotateSpeed, 0.0, getCameraRot.z, 2)
        end

        if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomIn) and GetCamFov(cctvcam) > Config.CCTV.MaxZoom then
            SetCamFov(cctvcam, GetCamFov(cctvcam) - 1.0)
        end

        if IsDisabledControlPressed(0, Config.CCTV.Controls.ZoomOut) and GetCamFov(cctvcam) < Config.CCTV.MinZoom then
            SetCamFov(cctvcam, GetCamFov(cctvcam) + 1.0)
        end

        if IsDisabledControlPressed(1, 190) then
            home.cctv:NextCamera()
            break
        end

        if IsDisabledControlPressed(1, Config.CCTV.Controls.Exit) then
            DoScreenFadeOut(1000)
            lib.callback("Housing:server:LeaveCCTV", false, function(CanExit)
                if CanExit then
                    InCCTV = false
                    Wait(1000)
                    ClearFocus()
                    ClearTimecycleModifier()
                    ClearExtraTimecycleModifier()
                    RenderScriptCams(false, false, 0, true, false)
                    DestroyCam(cctvcam, false)
                    SetFocusEntity(cache.ped)
                    SetNightvision(false)
                    SetSeethrough(false)
                    SetEntityCollision(cache.ped, true, true)
                    FreezeEntityPosition(cache.ped, false)
                    SetEntityVisible(cache.ped, true)
                    SetEntityCoordsNoOffset(cache.ped, initialCoords)
                    Wait(1500)
                    DoScreenFadeIn(1000)
                end
            end, homeId, LocalPlayer.state.isInsideHome)
            if IsResourceStarted('bcs_hud') then
                exports.bcs_hud:closeKeybind()
            else
                closeHelp()
            end
            break
        end
    end
end)
