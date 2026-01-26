--[[
    RCORE_DOORLOCK INTEGRATION SNIPPET
    For door/lock manipulation during missions

    This enables Mr. X to:
    - Lock/unlock doors as part of heist setups
    - Create locked areas for mission objectives
    - Spawn temporary locked doors for mission barriers
    - Track lockpicking activity for criminal detection

    EXPORTS AVAILABLE FROM rcore_doorlock:
    - changeDoorState(doorId, state) - Lock/unlock a door
    - addDoor(door) - Add a new door
    - getLoadedDoors() - Get all loaded doors
    - getSqlDoors() - Get doors from database
    - getLoadedObjects() - Get loaded objects
    - getPlayerBusiness(source) - Check player's business access
    - hasPlayerBusinessPermision(source, business, permission) - Check permission
]]

-- Helper function to safely call nexus
local function ReportToNexus(eventType, data, source)
    if GetResourceState('sv_nexus_tools') ~= 'started' then return end
    exports['sv_nexus_tools']:ReportActivity(eventType, data, source)
end

local function GetCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    return player and player.PlayerData.citizenid
end

local function GetPlayerCoords(source)
    return GetEntityCoords(GetPlayerPed(source))
end

-- ============================================
-- DOOR CONTROL FUNCTIONS
-- ============================================

-- Lock or unlock a door by ID
---@param doorId string|number Door identifier
---@param locked boolean True to lock, false to unlock
---@return boolean success
local function SetDoorLockState(doorId, locked)
    if GetResourceState('rcore_doorlock') ~= 'started' then return false end

    local state = locked and 1 or 0  -- 1 = locked, 0 = unlocked
    return exports.rcore_doorlock:changeDoorState(doorId, state)
end

-- Get all doors in a specific area
---@param coords vector3 Center coordinates
---@param radius number Search radius
---@return table doors List of doors in area
local function GetDoorsInArea(coords, radius)
    if GetResourceState('rcore_doorlock') ~= 'started' then return {} end

    local loadedDoors = exports.rcore_doorlock:getLoadedDoors()
    local nearbyDoors = {}

    for doorId, door in pairs(loadedDoors) do
        if door.coords then
            local doorCoords = type(door.coords) == 'table'
                and vector3(door.coords.x, door.coords.y, door.coords.z)
                or door.coords

            local distance = #(coords - doorCoords)
            if distance <= radius then
                table.insert(nearbyDoors, {
                    id = doorId,
                    coords = doorCoords,
                    distance = distance,
                    locked = door.currentState == 1
                })
            end
        end
    end

    return nearbyDoors
end

-- Lock all doors in an area (for heist lockdown)
---@param coords vector3 Center coordinates
---@param radius number Search radius
---@return number count Number of doors locked
local function LockdownArea(coords, radius)
    local doors = GetDoorsInArea(coords, radius)
    local count = 0

    for _, door in ipairs(doors) do
        if SetDoorLockState(door.id, true) then
            count = count + 1
        end
    end

    return count
end

-- Unlock all doors in an area (for mission completion)
---@param coords vector3 Center coordinates
---@param radius number Search radius
---@return number count Number of doors unlocked
local function UnlockArea(coords, radius)
    local doors = GetDoorsInArea(coords, radius)
    local count = 0

    for _, door in ipairs(doors) do
        if SetDoorLockState(door.id, false) then
            count = count + 1
        end
    end

    return count
end

-- ============================================
-- LOCKPICKING DETECTION
-- ============================================

-- Call when player attempts to lockpick
local function OnLockpickAttempt(source, doorId, success)
    local loadedDoors = exports.rcore_doorlock:getLoadedDoors()
    local door = loadedDoors[tostring(doorId)]

    ReportToNexus('lockpick_attempt', {
        doorId = doorId,
        success = success,
        doorType = door and door.type or 'unknown',
        coords = GetPlayerCoords(source)
    }, source)

    -- If lockpick at a business, additional tracking
    if door and door.business then
        ReportToNexus('business_breach_attempt', {
            business = door.business,
            doorId = doorId,
            success = success,
            coords = GetPlayerCoords(source)
        }, source)
    end
end

-- Call when door is breached (thermite, explosives, etc.)
local function OnDoorBreached(source, doorId, method)
    ReportToNexus('door_breach', {
        doorId = doorId,
        method = method,  -- 'thermite', 'explosive', 'ram', etc.
        coords = GetPlayerCoords(source)
    }, source)
end

-- ============================================
-- MISSION DOOR SETUP
-- ============================================

-- Create a temporary mission door (if rcore_doorlock supports dynamic doors)
---@param doorData table {coords, model, heading, locked?}
---@return string|nil doorId
local function CreateMissionDoor(doorData)
    if GetResourceState('rcore_doorlock') ~= 'started' then return nil end

    local door = {
        coords = doorData.coords,
        model = doorData.model or 'prop_gate_airport_01',
        heading = doorData.heading or 0.0,
        locked = doorData.locked ~= false,  -- Default locked
        autoLock = false,
        missionDoor = true  -- Mark as mission door for cleanup
    }

    local success = exports.rcore_doorlock:addDoor(door)
    if success then
        return door.id or tostring(doorData.coords)
    end

    return nil
end

-- ============================================
-- EXAMPLE: Heist Door Lockdown
-- ============================================

--[[
-- For a bank heist mission, lock all doors:

RegisterNetEvent('nexus:heist:startLockdown', function(heistCoords, radius)
    local lockedCount = LockdownArea(heistCoords, radius or 50.0)
    print('^3[NEXUS]^7 Locked ' .. lockedCount .. ' doors for heist')

    -- Track for later cleanup
    ActiveHeistDoors[currentMissionId] = {
        coords = heistCoords,
        radius = radius,
        doorsLocked = lockedCount
    }
end)

RegisterNetEvent('nexus:heist:endLockdown', function(missionId)
    local heistData = ActiveHeistDoors[missionId]
    if heistData then
        local unlockedCount = UnlockArea(heistData.coords, heistData.radius)
        print('^3[NEXUS]^7 Unlocked ' .. unlockedCount .. ' doors after heist')
        ActiveHeistDoors[missionId] = nil
    end
end)
]]

-- ============================================
-- EXAMPLE: Hook into rcore_doorlock Events
-- ============================================

--[[
-- In rcore_doorlock, add nexus reporting for lockpicking:

-- In client/modules/doors/cl-lockpick.lua (or similar):
RegisterNetEvent('rcore_doorlock:client:lockpickResult', function(doorId, success)
    TriggerServerEvent('nexus:doorlock:lockpickAttempt', doorId, success)
end)

-- In server file:
RegisterNetEvent('nexus:doorlock:lockpickAttempt', function(doorId, success)
    local src = source
    OnLockpickAttempt(src, doorId, success)
end)
]]

-- ============================================
-- BUSINESS ACCESS INTEGRATION
-- ============================================

-- Check if player has access to a business's doors
---@param source number Player source
---@param businessName string Business identifier
---@return boolean hasAccess
local function CheckBusinessAccess(source, businessName)
    if GetResourceState('rcore_doorlock') ~= 'started' then return false end

    local playerBusiness = exports.rcore_doorlock:getPlayerBusiness(source)
    return playerBusiness == businessName
end

-- ============================================
-- DISPATCH INTEGRATION
-- ============================================

--[[
-- rcore_doorlock has built-in dispatch support via bridges.
-- When a door is breached, it can trigger police dispatch.
-- You can intercept these for nexus tracking:

AddEventHandler('rcore_doorlock:dispatch:breachAlert', function(data)
    ReportToNexus('dispatch_alert', {
        type = 'door_breach',
        location = data.location,
        coords = data.coords
    }, nil)
end)
]]

-- Export functions
return {
    SetDoorLockState = SetDoorLockState,
    GetDoorsInArea = GetDoorsInArea,
    LockdownArea = LockdownArea,
    UnlockArea = UnlockArea,
    OnLockpickAttempt = OnLockpickAttempt,
    OnDoorBreached = OnDoorBreached,
    CreateMissionDoor = CreateMissionDoor,
    CheckBusinessAccess = CheckBusinessAccess
}
