--[[
    Mr. X Camera-Based Intelligence
    ================================
    Mr. X can only gather certain intelligence when players are
    within range of cameras. This adds realism - secret meetings
    in hidden locations stay secret.

    Uses rcore_cam camera model locations as the intelligence network.
]]

local CameraIntel = {}

-- ============================================
-- CONFIGURATION
-- ============================================

-- Camera detection range (same as rcore_cam)
local CAMERA_RANGE = 140.0

-- Loaded camera positions from rcore_cam cameras.json
local LoadedCameras = {}
local CamerasLoaded = false

-- ============================================
-- RCORE_CAM INTEGRATION
-- Load camera positions from cameras.json
-- ============================================

---Load camera positions from rcore_cam's cameras.json
---@return boolean success
local function LoadRcoreCameras()
    if CamerasLoaded then return true end

    -- Check if rcore_cam is started
    local rcoreState = GetResourceState('rcore_cam')
    if rcoreState ~= 'started' then
        print('^3[MR_X:CAMERA]^7 rcore_cam not started, using static camera zones')
        return false
    end

    -- Try to load cameras.json from rcore_cam
    local camerasJson = LoadResourceFile('rcore_cam', 'cameras.json')
    if not camerasJson then
        print('^3[MR_X:CAMERA]^7 Could not load cameras.json from rcore_cam')
        return false
    end

    local success, cameraGroups = pcall(json.decode, camerasJson)
    if not success or not cameraGroups then
        print('^1[MR_X:CAMERA]^7 Failed to parse cameras.json: ' .. tostring(cameraGroups))
        return false
    end

    -- Parse camera positions - cameras.json is a nested array [[cameras], [cameras], ...]
    local count = 0

    -- Helper function to process a single camera
    local function processCam(cam)
        if cam and cam.pos then
            local x, y, z
            if type(cam.pos) == 'table' then
                x = cam.pos.x or cam.pos[1]
                y = cam.pos.y or cam.pos[2]
                z = cam.pos.z or cam.pos[3]
            end

            if x and y and z then
                table.insert(LoadedCameras, {
                    coords = vec3(x, y, z),
                    model = cam.model,
                    tag = cam.tag,
                    range = CAMERA_RANGE
                })
                count = count + 1
            end
        end
    end

    -- Handle nested array structure: [[cam, cam], [cam, cam], ...]
    for _, group in ipairs(cameraGroups) do
        if type(group) == 'table' then
            -- Check if this is an array of cameras or a single camera
            if group.pos then
                -- Single camera object
                processCam(group)
            else
                -- Array of cameras
                for _, cam in ipairs(group) do
                    processCam(cam)
                end
            end
        end
    end

    CamerasLoaded = true
    print('^2[MR_X:CAMERA]^7 Loaded ' .. count .. ' cameras from rcore_cam')
    return true
end

-- Load cameras on resource start
CreateThread(function()
    Wait(5000)  -- Wait for rcore_cam to be ready
    LoadRcoreCameras()
end)

---Check if coordinates are near any loaded rcore_cam camera
---@param coords vector3
---@return boolean nearCamera
---@return string|nil cameraTag
local function IsNearRcoreCamera(coords)
    if not CamerasLoaded or #LoadedCameras == 0 then
        return false, nil
    end

    for _, cam in ipairs(LoadedCameras) do
        local dist = #(coords - cam.coords)
        if dist <= cam.range then
            return true, cam.tag or 'rcore_camera'
        end
    end

    return false, nil
end

-- Known camera models from rcore_cam config
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

-- Well-known camera locations (static list for server-side checks)
-- These are common locations with cameras (buildings, streets, etc.)
local KNOWN_CAMERA_ZONES = {
    -- Police Stations
    {name = 'MRPD', center = vec3(441.0, -982.0, 30.0), radius = 200.0},
    {name = 'Sandy Shores PD', center = vec3(1853.0, 3687.0, 34.0), radius = 150.0},
    {name = 'Paleto Bay PD', center = vec3(-448.0, 6012.0, 31.0), radius = 150.0},

    -- Banks
    {name = 'Pacific Standard Bank', center = vec3(253.0, 220.0, 106.0), radius = 100.0},
    {name = 'Fleeca Bank Downtown', center = vec3(147.0, -1044.0, 29.0), radius = 80.0},
    {name = 'Fleeca Bank Vinewood', center = vec3(-1211.0, -331.0, 37.0), radius = 80.0},
    {name = 'Fleeca Bank Burton', center = vec3(-2962.0, 482.0, 16.0), radius = 80.0},
    {name = 'Fleeca Bank Highway', center = vec3(-350.0, -50.0, 49.0), radius = 80.0},

    -- Shopping Areas (lots of security cameras)
    {name = 'Legion Square', center = vec3(196.0, -935.0, 30.0), radius = 150.0},
    {name = 'Del Perro Pier', center = vec3(-1805.0, -1218.0, 13.0), radius = 200.0},
    {name = 'Vinewood Boulevard', center = vec3(302.0, 200.0, 104.0), radius = 250.0},
    {name = 'Rockford Plaza', center = vec3(-164.0, -302.0, 39.0), radius = 180.0},

    -- Gas Stations
    {name = 'LTD Downtown', center = vec3(-47.0, -1757.0, 29.0), radius = 60.0},
    {name = '24/7 Strawberry', center = vec3(28.0, -1346.0, 29.0), radius = 60.0},
    {name = 'RON Mirror Park', center = vec3(1163.0, -330.0, 69.0), radius = 60.0},

    -- Hospitals
    {name = 'Pillbox Hospital', center = vec3(308.0, -592.0, 43.0), radius = 150.0},
    {name = 'Sandy Shores Hospital', center = vec3(1839.0, 3672.0, 34.0), radius = 100.0},

    -- Airports
    {name = 'LSIA', center = vec3(-1034.0, -2733.0, 13.0), radius = 400.0},
    {name = 'Sandy Shores Airfield', center = vec3(1703.0, 3251.0, 41.0), radius = 200.0},

    -- Car Dealerships / Mechanic Shops
    {name = 'Premium Deluxe Motorsport', center = vec3(-56.0, -1097.0, 26.0), radius = 100.0},
    {name = 'LS Customs Strawberry', center = vec3(-354.0, -133.0, 39.0), radius = 80.0},
    {name = 'LS Customs Burton', center = vec3(-1145.0, -1991.0, 13.0), radius = 80.0},

    -- Government Buildings
    {name = 'City Hall', center = vec3(-544.0, -204.0, 38.0), radius = 120.0},
    {name = 'Courthouse', center = vec3(244.0, -1084.0, 29.0), radius = 100.0},

    -- Major Streets/Intersections (traffic cameras)
    {name = 'Little Seoul', center = vec3(-696.0, -912.0, 19.0), radius = 200.0},
    {name = 'Vespucci Beach', center = vec3(-1389.0, -946.0, 10.0), radius = 200.0},
    {name = 'Downtown Los Santos', center = vec3(-263.0, -713.0, 33.0), radius = 300.0},
    {name = 'Mission Row', center = vec3(440.0, -1017.0, 28.0), radius = 200.0},

    -- Casinos/Entertainment
    {name = 'Diamond Casino', center = vec3(924.0, 47.0, 81.0), radius = 200.0},
    {name = 'Vanilla Unicorn', center = vec3(130.0, -1287.0, 29.0), radius = 80.0},

    -- Industrial/Docks
    {name = 'Terminal', center = vec3(1201.0, -3113.0, 5.0), radius = 300.0},
    {name = 'Elysian Island', center = vec3(-82.0, -2356.0, 14.0), radius = 200.0},
}

-- No-camera zones (guaranteed blind spots)
local BLIND_SPOTS = {
    {name = 'Humane Labs', center = vec3(3619.0, 3752.0, 28.0), radius = 300.0},
    {name = 'Mount Chiliad', center = vec3(450.0, 5566.0, 795.0), radius = 500.0},
    {name = 'Alamo Sea', center = vec3(1323.0, 4318.0, 38.0), radius = 400.0},
    {name = 'Paleto Forest', center = vec3(-557.0, 5326.0, 74.0), radius = 300.0},
    {name = 'Tongva Hills', center = vec3(-1896.0, 2042.0, 141.0), radius = 200.0},
    {name = 'Mount Gordo', center = vec3(2877.0, 5911.0, 369.0), radius = 300.0},
    {name = 'Raton Canyon', center = vec3(-517.0, 4425.0, 89.0), radius = 300.0},
    {name = 'Great Ocean Highway North', center = vec3(-2187.0, 4288.0, 48.0), radius = 300.0},
    {name = 'Senora Desert', center = vec3(2411.0, 2890.0, 44.0), radius = 400.0},
}

-- Client-reported camera proximity cache {citizenid -> {isNearCamera, lastUpdate, coords}}
local ClientCameraCache = {}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

---Check if coordinates are within a camera zone (server-side check)
---@param coords vector3
---@return boolean inCameraZone
---@return string|nil zoneName
function CameraIntel.IsInCameraZone(coords)
    if not coords then return false, nil end

    -- First check blind spots (override camera zones)
    for _, blind in ipairs(BLIND_SPOTS) do
        local dist = #(coords - blind.center)
        if dist <= blind.radius then
            return false, nil  -- In a blind spot
        end
    end

    -- PRIORITY 1: Check loaded rcore_cam cameras (most accurate)
    local nearRcore, rcoreTag = IsNearRcoreCamera(coords)
    if nearRcore then
        return true, 'rcore:' .. (rcoreTag or 'camera')
    end

    -- PRIORITY 2: Check static camera zones (fallback)
    for _, zone in ipairs(KNOWN_CAMERA_ZONES) do
        local dist = #(coords - zone.center)
        if dist <= zone.radius then
            return true, zone.name
        end
    end

    -- Not in any known camera zone
    return false, nil
end

---Force reload cameras from rcore_cam
---@return number count Number of cameras loaded
function CameraIntel.ReloadCameras()
    CamerasLoaded = false
    LoadedCameras = {}
    LoadRcoreCameras()
    return #LoadedCameras
end

---Get count of loaded rcore cameras
---@return number count
function CameraIntel.GetLoadedCameraCount()
    return #LoadedCameras
end

---Ask client if player is near a camera (async)
---@param source number
---@param callback function
function CameraIntel.CheckClientCameraProximity(source, callback)
    local citizenid = nil
    local player = exports.qbx_core:GetPlayer(source)
    if player then
        citizenid = player.PlayerData.citizenid
    end

    -- Check cache first (valid for 30 seconds)
    if citizenid and ClientCameraCache[citizenid] then
        local cache = ClientCameraCache[citizenid]
        if os.time() - cache.lastUpdate < 30 then
            callback(cache.isNearCamera)
            return
        end
    end

    -- Request from client
    TriggerClientEvent('sv_mr_x:client:checkCameraProximity', source)

    -- Set a timeout for the response
    local responded = false
    SetTimeout(2000, function()
        if not responded then
            -- Fallback to server-side check
            local ped = GetPlayerPed(source)
            if ped then
                local coords = GetEntityCoords(ped)
                local inZone, zoneName = CameraIntel.IsInCameraZone(coords)
                callback(inZone)
            else
                callback(false)
            end
        end
    end)
end

---Handle client camera proximity response
---@param isNearCamera boolean
---@param coords vector3|nil
RegisterNetEvent('sv_mr_x:server:cameraProximityResponse', function(isNearCamera, coords)
    local source = source
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid

    ClientCameraCache[citizenid] = {
        isNearCamera = isNearCamera,
        coords = coords,
        lastUpdate = os.time()
    }
end)

-- ============================================
-- CAMERA-AWARE FACT RECORDING
-- ============================================

---Record a fact only if player is in camera range
---@param citizenid string
---@param factType string
---@param data table
---@param source? number
---@param requireCamera? boolean If true, only record if in camera range
---@return boolean recorded
function CameraIntel.RecordFactIfVisible(citizenid, factType, data, source, requireCamera)
    if requireCamera == nil then
        requireCamera = true  -- Default to requiring camera
    end

    if not source then
        source = exports['sv_mr_x']:FindPlayerSource(citizenid)
    end

    -- ============================================
    -- FINANCIAL INTEL HANDLING
    -- Bank/electronic transactions are NOT camera-based
    -- They require Mr. X to have financial network access
    -- ============================================
    local isFinancialIntel = factType:find('^BANK_INTEL_') ~= nil

    if isFinancialIntel then
        -- Check if financial intel is enabled
        if not Config.FinancialIntel or not Config.FinancialIntel.Enabled then
            if Config.Debug then
                print('^3[MR_X:CAMERA]^7 Blocked financial intel: ' .. factType .. ' (financial intel disabled)')
            end
            return false
        end

        -- Check if Mr. X has bank access
        local accessLevel = Config.FinancialIntel.BankAccessLevel or 'none'
        if accessLevel == 'none' then
            if Config.Debug then
                print('^3[MR_X:CAMERA]^7 Blocked financial intel: ' .. factType .. ' (no bank access)')
            end
            return false
        end

        -- Mr. X has bank access - record with financial intel source
        data = data or {}
        data._visibility = 'financial_intel'
        data._accessLevel = accessLevel
        data.intelSource = data.intelSource or 'bank_network'

        -- Use the existing RecordFact mechanism (via profile)
        local profile = exports['sv_mr_x']:GetProfile(citizenid)
        if profile then
            local knownFacts = profile.known_facts or {}
            knownFacts[factType] = knownFacts[factType] or {}

            table.insert(knownFacts[factType], {
                data = data,
                timestamp = os.time(),
                source = 'financial_intel:' .. accessLevel
            })

            while #knownFacts[factType] > 10 do
                table.remove(knownFacts[factType], 1)
            end

            MySQL.update.await([[
                UPDATE mr_x_profiles SET known_facts = ? WHERE citizenid = ?
            ]], {json.encode(knownFacts), citizenid})
        end

        if Config.Debug then
            print('^2[MR_X:CAMERA]^7 Recorded financial intel: ' .. factType .. ' for ' .. citizenid .. ' (access: ' .. accessLevel .. ')')
        end

        return true
    end

    -- ============================================
    -- STANDARD CAMERA-BASED RECORDING
    -- ============================================

    -- Always record these types regardless of camera
    local alwaysRecord = {
        'JOB_CHANGE', 'GANG_CHANGE', 'POLICE_REPORT', 'WARRANT', 'BOLO',
        'ARRESTED', 'JAILED', 'LOAN', 'MISSION_OUTCOME', 'CONVERSATION'
    }

    for _, ft in ipairs(alwaysRecord) do
        if factType == ft then
            requireCamera = false
            break
        end
    end

    -- Check camera visibility
    local isVisible = false
    local visibilitySource = 'unknown'

    if not requireCamera then
        isVisible = true
        visibilitySource = 'always_recorded'
    elseif source then
        local ped = GetPlayerPed(source)
        if ped then
            local coords = GetEntityCoords(ped)
            local inZone, zoneName = CameraIntel.IsInCameraZone(coords)

            if inZone then
                isVisible = true
                visibilitySource = 'camera_zone:' .. (zoneName or 'unknown')
            end
        end

        -- Also check client cache
        if not isVisible and ClientCameraCache[citizenid] then
            local cache = ClientCameraCache[citizenid]
            if os.time() - cache.lastUpdate < 60 and cache.isNearCamera then
                isVisible = true
                visibilitySource = 'client_camera'
            end
        end
    end

    -- Record if visible
    if isVisible then
        -- Augment data with visibility info
        data = data or {}
        data._visibility = visibilitySource

        -- Use the existing RecordFact mechanism (via profile)
        local profile = exports['sv_mr_x']:GetProfile(citizenid)
        if profile then
            local knownFacts = profile.known_facts or {}
            knownFacts[factType] = knownFacts[factType] or {}

            -- Add to fact history
            table.insert(knownFacts[factType], {
                data = data,
                timestamp = os.time(),
                source = visibilitySource
            })

            -- Keep only last 10 entries per type
            while #knownFacts[factType] > 10 do
                table.remove(knownFacts[factType], 1)
            end

            -- Save back to profile
            MySQL.update.await([[
                UPDATE mr_x_profiles SET known_facts = ? WHERE citizenid = ?
            ]], {json.encode(knownFacts), citizenid})
        end

        if Config.Debug then
            print('^2[MR_X:CAMERA]^7 Recorded fact: ' .. factType .. ' for ' .. citizenid .. ' (' .. visibilitySource .. ')')
        end

        return true
    else
        if Config.Debug then
            print('^3[MR_X:CAMERA]^7 Blocked fact: ' .. factType .. ' for ' .. citizenid .. ' (not in camera range)')
        end
        return false
    end
end

-- ============================================
-- LOCATION-BASED KNOWLEDGE
-- ============================================

---Get what Mr. X knows about a player's location
---@param citizenid string
---@param source? number
---@return table locationKnowledge
function CameraIntel.GetLocationKnowledge(citizenid, source)
    if not source then
        source = exports['sv_mr_x']:FindPlayerSource(citizenid)
    end

    local knowledge = {
        isVisible = false,
        lastKnownZone = nil,
        lastKnownTime = nil,
        certainty = 'unknown'
    }

    if not source then
        -- Player offline - check last known from cache
        if ClientCameraCache[citizenid] then
            local cache = ClientCameraCache[citizenid]
            knowledge.lastKnownTime = cache.lastUpdate
            if cache.isNearCamera then
                knowledge.certainty = 'stale'
            end
        end
        return knowledge
    end

    local ped = GetPlayerPed(source)
    if not ped then return knowledge end

    local coords = GetEntityCoords(ped)
    local inZone, zoneName = CameraIntel.IsInCameraZone(coords)

    if inZone then
        knowledge.isVisible = true
        knowledge.lastKnownZone = zoneName
        knowledge.lastKnownTime = os.time()
        knowledge.certainty = 'confirmed'
    else
        -- Check blind spots
        for _, blind in ipairs(BLIND_SPOTS) do
            if #(coords - blind.center) <= blind.radius then
                knowledge.certainty = 'dark'  -- In a known blind spot
                return knowledge
            end
        end

        knowledge.certainty = 'unknown'
    end

    return knowledge
end

---Check if Mr. X can "see" a meeting between two players
---@param source1 number
---@param source2 number
---@return boolean canSee
---@return string|nil reason
function CameraIntel.CanSeeMeeting(source1, source2)
    local ped1 = GetPlayerPed(source1)
    local ped2 = GetPlayerPed(source2)

    if not ped1 or not ped2 then
        return false, 'player_offline'
    end

    local coords1 = GetEntityCoords(ped1)
    local coords2 = GetEntityCoords(ped2)

    -- Check if they're actually near each other
    if #(coords1 - coords2) > 50.0 then
        return false, 'not_meeting'
    end

    -- Average position
    local meetingCoords = (coords1 + coords2) / 2

    -- Check if meeting is in camera zone
    local inZone, zoneName = CameraIntel.IsInCameraZone(meetingCoords)

    if inZone then
        return true, 'camera_zone:' .. zoneName
    else
        return false, 'dark_location'
    end
end

-- ============================================
-- ASSOCIATION TRACKING (Camera-Aware)
-- ============================================

-- Track player associations seen via camera
local PlayerAssociations = {}  -- {citizenid -> {associateCid -> lastSeenTogether}}

---Record an association if both players are visible
---@param cid1 string
---@param cid2 string
---@param source1? number
---@param source2? number
function CameraIntel.RecordAssociation(cid1, cid2, source1, source2)
    if not source1 then source1 = exports['sv_mr_x']:FindPlayerSource(cid1) end
    if not source2 then source2 = exports['sv_mr_x']:FindPlayerSource(cid2) end

    if not source1 or not source2 then return end

    local canSee, reason = CameraIntel.CanSeeMeeting(source1, source2)

    if canSee then
        -- Initialize tracking
        PlayerAssociations[cid1] = PlayerAssociations[cid1] or {}
        PlayerAssociations[cid2] = PlayerAssociations[cid2] or {}

        -- Record bidirectional
        PlayerAssociations[cid1][cid2] = os.time()
        PlayerAssociations[cid2][cid1] = os.time()

        -- Record as fact
        CameraIntel.RecordFactIfVisible(cid1, 'ASSOCIATION', {
            associateCid = cid2,
            location = reason,
            timestamp = os.time()
        }, source1, false)

        if Config.Debug then
            print('^2[MR_X:CAMERA]^7 Recorded association: ' .. cid1 .. ' <-> ' .. cid2 .. ' (' .. reason .. ')')
        end
    end
end

---Get known associates for a player
---@param citizenid string
---@return table associates
function CameraIntel.GetKnownAssociates(citizenid)
    return PlayerAssociations[citizenid] or {}
end

-- ============================================
-- PERIODIC ASSOCIATION SCAN
-- ============================================

CreateThread(function()
    Wait(60000)  -- Wait 1 minute after start

    while true do
        Wait(120000)  -- Every 2 minutes

        local players = GetPlayers()

        -- Check for players near each other in camera zones
        for i = 1, #players do
            for j = i + 1, #players do
                local source1 = tonumber(players[i])
                local source2 = tonumber(players[j])

                local player1 = exports.qbx_core:GetPlayer(source1)
                local player2 = exports.qbx_core:GetPlayer(source2)

                if player1 and player2 then
                    local ped1 = GetPlayerPed(source1)
                    local ped2 = GetPlayerPed(source2)

                    if ped1 and ped2 then
                        local coords1 = GetEntityCoords(ped1)
                        local coords2 = GetEntityCoords(ped2)

                        -- If within 20 units, check if we can see them
                        if #(coords1 - coords2) < 20.0 then
                            local cid1 = player1.PlayerData.citizenid
                            local cid2 = player2.PlayerData.citizenid

                            CameraIntel.RecordAssociation(cid1, cid2, source1, source2)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('IsInCameraZone', CameraIntel.IsInCameraZone)
exports('RecordFact', CameraIntel.RecordFactIfVisible)  -- This replaces external_hooks RecordFact calls
exports('GetLocationKnowledge', CameraIntel.GetLocationKnowledge)
exports('CanSeeMeeting', CameraIntel.CanSeeMeeting)
exports('RecordAssociation', CameraIntel.RecordAssociation)
exports('GetKnownAssociates', CameraIntel.GetKnownAssociates)
exports('ReloadCameras', CameraIntel.ReloadCameras)
exports('GetLoadedCameraCount', CameraIntel.GetLoadedCameraCount)

-- ============================================
-- ADMIN COMMANDS
-- ============================================

RegisterCommand('mrx_camera', function(source, args)
    if source ~= 0 and not IsPlayerAceAllowed(source, 'admin') then
        print('^1[MR_X]^7 No permission')
        return
    end

    local target = args[1]
    if not target then
        print('^3[MR_X:CAMERA]^7 Usage: mrx_camera [player_id]')
        print('^3[MR_X:CAMERA]^7 Loaded cameras: ' .. #LoadedCameras)
        return
    end

    local targetId = tonumber(target)
    if not targetId then
        print('^1[MR_X:CAMERA]^7 Invalid player ID')
        return
    end

    local ped = GetPlayerPed(targetId)
    if not ped then
        print('^1[MR_X:CAMERA]^7 Player not found')
        return
    end

    local coords = GetEntityCoords(ped)
    local inZone, zoneName = CameraIntel.IsInCameraZone(coords)
    local knowledge = CameraIntel.GetLocationKnowledge(nil, targetId)

    print('^3[MR_X:CAMERA]^7 Player ' .. targetId .. ' camera status:')
    print('  - Position: ' .. string.format('%.1f, %.1f, %.1f', coords.x, coords.y, coords.z))
    print('  - In camera zone: ' .. (inZone and '^2YES^7' or '^1NO^7'))
    if inZone then
        print('  - Zone/Camera: ' .. (zoneName or 'unknown'))
    end
    print('  - Visibility certainty: ' .. (knowledge.certainty or 'unknown'))

    -- Find nearest camera
    local nearestDist = 999999
    local nearestCam = nil
    for _, cam in ipairs(LoadedCameras) do
        local dist = #(coords - cam.coords)
        if dist < nearestDist then
            nearestDist = dist
            nearestCam = cam
        end
    end

    if nearestCam then
        print('  - Nearest rcore camera: ' .. string.format('%.1f', nearestDist) .. 'm away')
        if nearestDist <= CAMERA_RANGE then
            print('    ^2(IN RANGE - camera range is ' .. CAMERA_RANGE .. 'm)^7')
        else
            print('    ^3(OUT OF RANGE - need to be within ' .. CAMERA_RANGE .. 'm)^7')
        end
    end
end, false)

if Config and Config.Debug then
    print('^2[MR_X]^7 Camera Intel module loaded')
    print('^2[MR_X]^7 Static camera zones: ' .. #KNOWN_CAMERA_ZONES .. ', Blind spots: ' .. #BLIND_SPOTS)
    print('^2[MR_X]^7 rcore_cam cameras will be loaded after 5 seconds...')
end

-- Return module
return CameraIntel
