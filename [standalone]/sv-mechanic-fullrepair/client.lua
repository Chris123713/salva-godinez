--[[
    sv-mechanic-fullrepair - Client Script

    Handles GTA-side vehicle repairs and provides exports for other resources.
    Works in conjunction with server script to reset jg-mechanic servicingData.
]]

-- Full health servicing data structures
local FULL_SERVICING_COMBUSTION = {
    suspension = 100,
    tyres = 100,
    brakePads = 100,
    engineOil = 100,
    clutch = 100,
    airFilter = 100,
    sparkPlugs = 100,
}

local FULL_SERVICING_ELECTRIC = {
    suspension = 100,
    tyres = 100,
    brakePads = 100,
    evMotor = 100,
    evBattery = 100,
    evCoolant = 100,
}

-- Check if a vehicle is electric
---@param vehicle number
---@return boolean
local function isVehicleElectric(vehicle)
    if not vehicle or vehicle == 0 then return false end

    -- Use native if available (build 3258+)
    if GetIsVehicleElectric then
        return GetIsVehicleElectric(GetEntityModel(vehicle))
    end

    -- Fallback: check jg-mechanic's list
    if GetResourceState('jg-mechanic') == 'started' then
        local archetype = GetEntityArchetypeName(vehicle)
        -- jg-mechanic stores electric vehicles in Config.ElectricVehicles
        -- We can't directly access it, but we can check the statebag
        local state = Entity(vehicle).state
        if state and state.tuningConfig then
            -- If vehicle has EV-specific tuning, it's electric
            return state.tuningConfig.evMotor ~= nil
        end
    end

    return false
end

-- Get appropriate servicing data based on vehicle type
---@param vehicle number
---@return table
local function getFullServicingData(vehicle)
    if isVehicleElectric(vehicle) then
        return lib.table.deepclone(FULL_SERVICING_ELECTRIC)
    end
    return lib.table.deepclone(FULL_SERVICING_COMBUSTION)
end

-- Repair GTA vehicle health (visual + mechanical)
---@param vehicle number
local function repairGTAVehicle(vehicle)
    if not vehicle or vehicle == 0 then return end

    SetVehicleUndriveable(vehicle, false)
    WashDecalsFromVehicle(vehicle, 1.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleFixed(vehicle)
    ResetVehicleWheels(vehicle, true)
    SetVehicleEngineOn(vehicle, true, true, true)

    -- Third-party deformation scripts
    if GetResourceState('VehicleDeformation') == 'started' then
        pcall(function()
            exports['VehicleDeformation']:FixVehicleDeformation(vehicle)
        end)
    end
end

-- Reset jg-mechanic servicingData statebag locally
---@param vehicle number
local function resetServicingStatebag(vehicle)
    if not vehicle or vehicle == 0 then return end

    local state = Entity(vehicle).state
    if not state then return end

    local servicingData = getFullServicingData(vehicle)
    state:set('servicingData', servicingData, true)
end

-- Full repair a vehicle (GTA health + jg-mechanic servicing)
---@param vehicle number
---@param skipServerSync? boolean If true, don't sync to server (use if server already handled it)
local function fullRepairVehicle(vehicle, skipServerSync)
    if not vehicle or vehicle == 0 then return false end

    -- Repair GTA health
    repairGTAVehicle(vehicle)

    -- Reset servicing statebag
    resetServicingStatebag(vehicle)

    -- Sync to server/database in background thread to avoid blocking
    if not skipServerSync and NetworkGetEntityIsNetworked(vehicle) then
        CreateThread(function()
            local netId = VehToNet(vehicle)
            local isElectric = isVehicleElectric(vehicle)
            lib.callback.await('sv-mechanic-fullrepair:fullRepair', false, netId, isElectric)
        end)
    end

    return true
end

-- Export: Full repair any vehicle
exports('FullRepairVehicle', function(vehicle, skipServerSync)
    return fullRepairVehicle(vehicle, skipServerSync)
end)

-- Export: Repair just GTA health (no servicing reset)
exports('RepairGTAVehicle', function(vehicle)
    repairGTAVehicle(vehicle)
    return true
end)

-- Export: Reset just servicing data (non-blocking)
exports('ResetServicingData', function(vehicle, skipServerSync)
    if not vehicle or vehicle == 0 then return false end

    resetServicingStatebag(vehicle)

    -- Server sync in background thread to avoid blocking
    if not skipServerSync and NetworkGetEntityIsNetworked(vehicle) then
        local plate = GetVehicleNumberPlateText(vehicle)
        if plate then
            CreateThread(function()
                lib.callback.await('sv-mechanic-fullrepair:resetByPlate', false, plate)
            end)
        end
    end

    return true
end)

-- Export: Get full servicing data structure
exports('GetFullServicingData', function(vehicle)
    return getFullServicingData(vehicle)
end)

-- Export: Check if vehicle is electric
exports('IsVehicleElectric', function(vehicle)
    return isVehicleElectric(vehicle)
end)

-- Event handler for server-triggered repairs
RegisterNetEvent('sv-mechanic-fullrepair:doRepair', function(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle and vehicle ~= 0 then
        -- Only repair GTA health, server handles servicing data
        repairGTAVehicle(vehicle)
        resetServicingStatebag(vehicle)
    end
end)

--[[
    APPROACH 1: Hook jg-mechanic repair event

    This listens for the jg-mechanic:client:repair-vehicle event
    and resets servicingData AFTER the repair completes.
    No modification to jg-mechanic files required!
]]

-- Listen for jg-mechanic repair events (repair kits, NPC mechanics)
AddEventHandler('jg-mechanic:client:repair-vehicle', function()
    -- Wait for jg-mechanic to complete its repair sequence
    SetTimeout(500, function()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        -- Also check nearby vehicle if not in one
        if vehicle == 0 then
            local coords = GetEntityCoords(ped)
            vehicle = lib.getClosestVehicle(coords, 5.0, false)
        end

        if vehicle and vehicle ~= 0 then
            resetServicingStatebag(vehicle)

            -- Sync to server in background
            CreateThread(function()
                local plate = GetVehicleNumberPlateText(vehicle)
                if plate then
                    lib.callback.await('sv-mechanic-fullrepair:resetByPlate', false, plate)
                end
            end)

            print('^2[sv-mechanic-fullrepair]^7 Reset servicingData after jg-mechanic repair')
        end
    end)
end)

--[[
    APPROACH 2: Health monitor (catches ALL repairs from any source)

    Monitors vehicle health - when it jumps to 1000 (full repair),
    automatically resets servicingData if components are worn.
]]

local recentResets = {}

CreateThread(function()
    -- Wait for resources to initialize
    Wait(5000)

    -- Only run if jg-mechanic is present
    if GetResourceState('jg-mechanic') ~= 'started' then
        print('^3[sv-mechanic-fullrepair]^7 jg-mechanic not detected - health monitor disabled')
        return
    end

    print('^2[sv-mechanic-fullrepair]^7 Health monitor active - will auto-reset servicingData on repairs')

    local lastHealth = {}

    while true do
        Wait(2000) -- Check every 2 seconds

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle and vehicle ~= 0 then
            local plate = GetVehicleNumberPlateText(vehicle)
            local health = GetVehicleEngineHealth(vehicle)

            if plate and plate ~= '' then
                local prevHealth = lastHealth[plate] or health

                -- Detect repair: health jumped significantly (at least 200 points) and now at or near full
                if health >= 990.0 and (health - prevHealth) >= 200 then
                    -- Prevent duplicate resets within 30 seconds
                    local now = GetGameTimer()
                    if not recentResets[plate] or (now - recentResets[plate]) > 30000 then

                        local state = Entity(vehicle).state
                        if state then
                            -- Check if servicingData exists and has worn components
                            local servicingData = state.servicingData
                            local needsReset = false

                            if servicingData then
                                for part, value in pairs(servicingData) do
                                    if type(value) == 'number' and value < 80 then
                                        needsReset = true
                                        break
                                    end
                                end
                            end

                            if needsReset then
                                resetServicingStatebag(vehicle)
                                recentResets[plate] = now

                                -- Sync to server in background
                                CreateThread(function()
                                    lib.callback.await('sv-mechanic-fullrepair:resetByPlate', false, plate)
                                end)

                                print('^2[sv-mechanic-fullrepair]^7 Auto-reset servicingData for plate:', plate)
                            end
                        end
                    end
                end

                lastHealth[plate] = health
            end
        end

        -- Cleanup old entries every cycle
        local now = GetGameTimer()
        for p, time in pairs(recentResets) do
            if (now - time) > 60000 then
                recentResets[p] = nil
            end
        end
    end
end)

print('^2[sv-mechanic-fullrepair]^7 Client loaded - event hooks and health monitor active')
