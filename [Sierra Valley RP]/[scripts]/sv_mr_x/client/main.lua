--[[
    Mr. X Client Main
    =================
    Client-side initialization and phone state tracking
]]

-- ============================================
-- PHONE STATE TRACKING
-- ============================================

-- Track phone open/closed state for message queueing
RegisterNetEvent('lb-phone:phoneToggled', function(isOpen)
    TriggerServerEvent('sv_mr_x:phoneStateChanged', isOpen)
end)

-- ============================================
-- INITIALIZATION
-- ============================================

CreateThread(function()
    -- Wait for player to be loaded
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    -- Small delay to ensure server-side is ready
    Wait(1000)

    if Config.Debug then
        print('^2[MR_X]^7 Client initialized')
    end
end)

-- ============================================
-- KEYBIND FOR ADMIN (Optional)
-- ============================================

-- Uncomment to add keybind
--[[
RegisterCommand('+mrx_admin', function()
    TriggerEvent('sv_mr_x:client:openAdminMenu')
end, false)

RegisterKeyMapping('+mrx_admin', 'Open Mr. X Admin Menu', 'keyboard', 'F10')
]]

-- ============================================
-- CAMERA PROXIMITY CHECK
-- For camera-aware intelligence gathering
-- ============================================

-- Camera models from rcore_cam config
local CAMERA_MODELS = {
    `prop_cctv_cam_05a`,
    `prop_cctv_cam_03a`,
    `prop_cctv_cam_06a`,
    `prop_cctv_cam_04c`,
    `prop_cctv_cam_01b`,
    `prop_cctv_cam_01a`,
    `prop_cctv_cam_04a`,
    `prop_cctv_cam_02a`,
    `prop_cctv_cam_04b`,
    `prop_cctv_cam_07a`,
    `prop_cctv_pole_02`,
    `prop_cctv_pole_03`,
    `prop_cctv_pole_04`,
    `v_serv_securitycam_1a`,
    `prop_cctv_pole_01a`,
    `ba_prop_battle_cctv_cam_01b`,
    `v_serv_securitycam_03`,
    `ba_prop_battle_cctv_cam_01a`,
}

local CAMERA_RANGE = 140.0

---Check if player is near any camera
---@return boolean isNear
---@return vector3|nil coords
local function IsNearCamera()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    for _, modelHash in ipairs(CAMERA_MODELS) do
        local camera = GetClosestObjectOfType(coords.x, coords.y, coords.z, CAMERA_RANGE, modelHash, false, false, false)
        if camera and camera ~= 0 then
            return true, coords
        end
    end

    return false, coords
end

-- Server requests camera proximity check
RegisterNetEvent('sv_mr_x:client:checkCameraProximity', function()
    local isNear, coords = IsNearCamera()
    TriggerServerEvent('sv_mr_x:server:cameraProximityResponse', isNear, coords)
end)

-- Periodic camera proximity update (every 60 seconds)
CreateThread(function()
    while true do
        Wait(60000)

        if LocalPlayer.state.isLoggedIn then
            local isNear, coords = IsNearCamera()
            TriggerServerEvent('sv_mr_x:server:cameraProximityResponse', isNear, coords)
        end
    end
end)

-- ============================================
-- DEBUG COMMANDS
-- ============================================

if Config.Debug then
    RegisterCommand('mrx_debug', function()
        print('^3[MR_X DEBUG]^7 Client state:')
        print('  isLoggedIn:', LocalPlayer.state.isLoggedIn)

        local isNear, coords = IsNearCamera()
        print('  nearCamera:', isNear)
        print('  coords:', coords)
    end, false)
end
