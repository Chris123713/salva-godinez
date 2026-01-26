--[[
    sv-mechanic-fullrepair - Server Script

    Provides full vehicle repair including jg-mechanic internal components.
    Use this for NPC mechanics, admin commands, or any repair that should
    reset ALL vehicle components, not just GTA health.
]]

local Config = {
    -- Admin command name (set to false to disable)
    AdminCommand = 'fullrepair',

    -- ACE permission required for admin command
    AdminPermission = 'command.fullrepair',

    -- Debug mode
    Debug = false,
}

-- Full health servicing data for combustion vehicles
local FULL_SERVICING_COMBUSTION = {
    suspension = 100,
    tyres = 100,
    brakePads = 100,
    engineOil = 100,
    clutch = 100,
    airFilter = 100,
    sparkPlugs = 100,
}

-- Full health servicing data for electric vehicles
local FULL_SERVICING_ELECTRIC = {
    suspension = 100,
    tyres = 100,
    brakePads = 100,
    evMotor = 100,
    evBattery = 100,
    evCoolant = 100,
}

-- Debug print helper
local function debugPrint(...)
    if Config.Debug then
        print('^3[sv-mechanic-fullrepair]^7', ...)
    end
end

-- Get servicing data structure based on vehicle type
---@param isElectric boolean
---@return table
local function getFullServicingData(isElectric)
    if isElectric then
        return lib.table.deepclone(FULL_SERVICING_ELECTRIC)
    end
    return lib.table.deepclone(FULL_SERVICING_COMBUSTION)
end

-- Reset servicing data in database for a plate
---@param plate string
---@return boolean success
local function resetServicingDataInDB(plate)
    if not plate or plate == '' then return false end

    -- Trim whitespace from plate
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    -- Check if entry exists
    local existing = MySQL.scalar.await('SELECT plate FROM mechanic_vehicledata WHERE plate = ?', { plate })

    if existing then
        -- Get current data and update only servicingData
        local row = MySQL.single.await('SELECT data FROM mechanic_vehicledata WHERE plate = ?', { plate })
        if row and row.data then
            local data = json.decode(row.data) or {}
            -- Remove servicingData - jg-mechanic will regenerate fresh on next use
            data.servicingData = nil
            MySQL.update.await('UPDATE mechanic_vehicledata SET data = ? WHERE plate = ?', { json.encode(data), plate })
            debugPrint('Reset servicingData in DB for plate:', plate)
        end
    end

    return true
end

-- Full repair a vehicle by network ID (resets everything)
---@param netId number Network ID of the vehicle
---@param isElectric? boolean Whether vehicle is electric (auto-detected if not provided)
---@return boolean success
local function fullRepairVehicle(netId, isElectric)
    if not netId or netId == 0 then return false end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return false end

    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return false end

    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    -- Reset in database
    resetServicingDataInDB(plate)

    -- Get full health servicing data
    local servicingData = getFullServicingData(isElectric or false)

    -- Set statebag to update client-side
    local state = Entity(vehicle).state
    if state then
        state:set('servicingData', servicingData, true)
        debugPrint('Set servicingData statebag for vehicle:', netId, 'plate:', plate)
    end

    return true
end

-- Full repair by plate (for offline vehicles or database cleanup)
---@param plate string
---@return boolean success
local function fullRepairByPlate(plate)
    if not plate or plate == '' then return false end

    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    return resetServicingDataInDB(plate)
end

-- Export: Full repair a vehicle (call from other resources)
exports('FullRepairVehicle', function(netId, isElectric)
    return fullRepairVehicle(netId, isElectric)
end)

-- Export: Full repair by plate
exports('FullRepairByPlate', function(plate)
    return fullRepairByPlate(plate)
end)

-- Export: Get full servicing data structure
exports('GetFullServicingData', function(isElectric)
    return getFullServicingData(isElectric)
end)

-- Callback for client to trigger full repair
lib.callback.register('sv-mechanic-fullrepair:fullRepair', function(source, netId, isElectric)
    return fullRepairVehicle(netId, isElectric)
end)

-- Callback for client to reset servicing data by plate
lib.callback.register('sv-mechanic-fullrepair:resetByPlate', function(source, plate)
    return fullRepairByPlate(plate)
end)

-- Admin command to full repair current vehicle
if Config.AdminCommand then
    lib.addCommand(Config.AdminCommand, {
        help = 'Full repair vehicle including all internal components (jg-mechanic servicing)',
        params = {
            {
                name = 'target',
                type = 'playerId',
                help = 'Target player ID (optional, defaults to self)',
                optional = true,
            },
        },
        restricted = Config.AdminPermission,
    }, function(source, args)
        local targetId = args.target or source
        local targetPed = GetPlayerPed(targetId)

        if not targetPed or targetPed == 0 then
            return TriggerClientEvent('ox_lib:notify', source, {
                title = 'Full Repair',
                description = 'Invalid target player',
                type = 'error'
            })
        end

        local vehicle = GetVehiclePedIsIn(targetPed, false)
        if not vehicle or vehicle == 0 then
            return TriggerClientEvent('ox_lib:notify', source, {
                title = 'Full Repair',
                description = 'Target must be in a vehicle',
                type = 'error'
            })
        end

        local netId = NetworkGetNetworkIdFromEntity(vehicle)

        -- Trigger client-side repair for GTA health
        TriggerClientEvent('sv-mechanic-fullrepair:doRepair', targetId, netId)

        -- Reset servicing data server-side
        fullRepairVehicle(netId, false)

        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Full Repair',
            description = 'Vehicle fully repaired including all internal components',
            type = 'success'
        })

        if targetId ~= source then
            TriggerClientEvent('ox_lib:notify', targetId, {
                title = 'Full Repair',
                description = 'Your vehicle has been fully repaired by an admin',
                type = 'success'
            })
        end
    end)
end

-- Bulk reset command for all vehicles (works from console and in-game)
RegisterCommand('resetallservicing', function(source, args, rawCommand)
    -- Check permission (skip for console)
    if source > 0 and not IsPlayerAceAllowed(source, 'command') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Servicing Reset',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    local affected = MySQL.update.await('UPDATE mechanic_vehicledata SET data = JSON_REMOVE(data, "$.servicingData")')

    if source > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Servicing Reset',
            description = ('Reset servicing data for %d vehicles'):format(affected or 0),
            type = 'success'
        })
    end

    local adminName = source > 0 and GetPlayerName(source) or 'Console'
    print('^2[sv-mechanic-fullrepair]^7', adminName, 'reset servicing data for', affected or 0, 'vehicles')
end, true) -- true = restricted to admins (ACE)

-- Reset servicing for a specific plate (console-friendly)
RegisterCommand('resetservicing', function(source, args, rawCommand)
    -- Check permission (skip for console)
    if source > 0 and not IsPlayerAceAllowed(source, 'command') then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Servicing Reset',
            description = 'You do not have permission to use this command',
            type = 'error'
        })
        return
    end

    local plate = args[1]
    if not plate or plate == '' then
        print('^1[sv-mechanic-fullrepair]^7 Usage: resetservicing <plate>')
        if source > 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Servicing Reset',
                description = 'Usage: /resetservicing <plate>',
                type = 'error'
            })
        end
        return
    end

    -- Trim and normalize plate
    plate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

    local success = fullRepairByPlate(plate)

    if source > 0 then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Servicing Reset',
            description = success and ('Reset servicing for plate: %s'):format(plate) or 'Failed to reset servicing',
            type = success and 'success' or 'error'
        })
    end

    local adminName = source > 0 and GetPlayerName(source) or 'Console'
    print('^2[sv-mechanic-fullrepair]^7', adminName, success and 'reset servicing for plate:' or 'failed to reset plate:', plate)
end, true)

-- Diagnostic command to check servicing data status
RegisterCommand('checkservicing', function(source, args, rawCommand)
    -- Check permission (skip for console)
    if source > 0 and not IsPlayerAceAllowed(source, 'command') then
        return
    end

    print('^3[sv-mechanic-fullrepair]^7 Checking mechanic_vehicledata table...')

    -- Total vehicles
    local total = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_vehicledata')
    print('^2[sv-mechanic-fullrepair]^7 Total vehicles in database:', total or 0)

    -- Vehicles with servicingData still present
    local withServicing = MySQL.scalar.await([[
        SELECT COUNT(*) FROM mechanic_vehicledata
        WHERE data IS NOT NULL
        AND data LIKE '%servicingData%'
    ]])
    print('^2[sv-mechanic-fullrepair]^7 Vehicles with servicingData:', withServicing or 0)

    -- Vehicles without servicingData (fixed)
    local fixed = (total or 0) - (withServicing or 0)
    print('^2[sv-mechanic-fullrepair]^7 Vehicles without servicingData (fixed):', fixed)

    -- Sample a few plates
    local samples = MySQL.query.await('SELECT plate FROM mechanic_vehicledata LIMIT 5')
    if samples and #samples > 0 then
        print('^2[sv-mechanic-fullrepair]^7 Sample plates:')
        for _, row in ipairs(samples) do
            print('  -', row.plate)
        end
    end
end, true)

print('^2[sv-mechanic-fullrepair]^7 Loaded - Full vehicle repair utility')
print('^2[sv-mechanic-fullrepair]^7 Commands: resetallservicing, resetservicing <plate>, checkservicing')
