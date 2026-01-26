--[[
    Advanced MultiJob - Server Clock-In Wrapper
    Handles time tracking, database logging, and clock-in validation
]]

local QBX = exports.qbx_core

-- Store active shift data (in-memory for performance)
local activeShifts = {}

-- Log clock-in event to database
local function LogClockinEvent(citizenid, jobName, eventType, location)
    if not Config.EnableTimeTracking then return end

    local timestamp = os.time()

    if eventType == 'clockin' then
        -- Record clock-in
        MySQL.insert('INSERT INTO job_clockin_logs (citizenid, job, clockin_time, location) VALUES (?, ?, FROM_UNIXTIME(?), ?)',
            {citizenid, jobName, timestamp, location or 'Unknown'})

        -- Store in memory for duration calculation
        activeShifts[citizenid] = {
            job = jobName,
            clockinTime = timestamp,
            location = location
        }

        if Config.Debug then
            print('^2[MultiJob]^7 Clock-in logged for ' .. citizenid .. ' at ' .. jobName)
        end

    elseif eventType == 'clockout' then
        -- Calculate duration and update record
        local shift = activeShifts[citizenid]

        if shift then
            local duration = timestamp - shift.clockinTime

            -- Update the most recent clock-in record with clock-out time and duration
            MySQL.update([[
                UPDATE job_clockin_logs
                SET clockout_time = FROM_UNIXTIME(?), duration = ?
                WHERE citizenid = ? AND job = ? AND clockout_time IS NULL
                ORDER BY clockin_time DESC LIMIT 1
            ]], {timestamp, duration, citizenid, shift.job})

            -- Clear from memory
            activeShifts[citizenid] = nil

            if Config.Debug then
                print('^2[MultiJob]^7 Clock-out logged for ' .. citizenid .. ' - Duration: ' .. duration .. 's')
            end
        end
    end
end

-- Get shift start time for a player
local function GetShiftStartTime(source)
    local player = QBX:GetPlayer(source)
    if not player then return nil end

    local shift = activeShifts[player.PlayerData.citizenid]
    if shift then
        return shift.clockinTime * 1000 -- Convert to milliseconds for JavaScript
    end

    return nil
end

-- Validate clock-in location (called before allowing duty toggle)
local function ValidateClockinLocation(source)
    if not Config.RequirePhysicalClockin then
        return true, 'Any Location'
    end

    -- Request location check from client
    local atLocation = lib.callback.await('multijob:client:checkLocation', source)

    return atLocation
end

-- Hook into QBCore duty toggle event
AddEventHandler('QBCore:Server:SetDuty', function(source, onDuty)
    local player = QBX:GetPlayer(source)
    if not player then return end

    local citizenid = player.PlayerData.citizenid
    local jobName = player.PlayerData.job.name

    if onDuty then
        -- Player clocked in
        local location = 'Unknown'

        -- Try to get location from client
        local locationData = lib.callback.await('multijob:client:getLocationName', source)
        if locationData then
            location = locationData
        end

        LogClockinEvent(citizenid, jobName, 'clockin', location)
    else
        -- Player clocked out
        LogClockinEvent(citizenid, jobName, 'clockout')
    end
end)

-- Callback to get player's work hours (30-day rolling)
lib.callback.register('multijob:server:getWorkHours', function(source)
    local player = QBX:GetPlayer(source)
    if not player then return 0 end

    local result = MySQL.single.await([[
        SELECT COALESCE(SUM(duration), 0) as total_seconds
        FROM job_clockin_logs
        WHERE citizenid = ?
        AND clockin_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        AND duration IS NOT NULL
    ]], {player.PlayerData.citizenid})

    if result and result.total_seconds then
        local hours = math.floor(result.total_seconds / 3600)
        return hours
    end

    return 0
end)

-- Callback to get shift start time
lib.callback.register('multijob:server:getShiftStartTime', function(source)
    return GetShiftStartTime(source)
end)

-- Clean up active shifts on player drop
AddEventHandler('playerDropped', function()
    local src = source
    local player = QBX:GetPlayer(src)

    if player then
        local citizenid = player.PlayerData.citizenid

        -- If player was on duty, log clock-out
        if activeShifts[citizenid] then
            LogClockinEvent(citizenid, activeShifts[citizenid].job, 'clockout')
        end
    end
end)

-- Restore active shifts on resource start (in case of restart)
CreateThread(function()
    Wait(2000) -- Wait for database to be ready

    -- Find all players currently on duty without a clock-out time
    local results = MySQL.query.await([[
        SELECT DISTINCT citizenid, job, UNIX_TIMESTAMP(clockin_time) as clockin_time, location
        FROM job_clockin_logs
        WHERE clockout_time IS NULL
        AND clockin_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
    ]])

    if results then
        for _, row in ipairs(results) do
            activeShifts[row.citizenid] = {
                job = row.job,
                clockinTime = row.clockin_time,
                location = row.location
            }
        end

        if Config.Debug then
            print('^2[MultiJob]^7 Restored ' .. #results .. ' active shifts from database')
        end
    end
end)

-- Admin command to view player work hours
lib.addCommand('viewhours', {
    help = 'View work hours for a player (30 days)',
    params = {
        {name = 'id', help = 'Player ID'},
    },
    restricted = 'admin'
}, function(source, args)
    local targetId = tonumber(args.id)
    local targetPlayer = QBX:GetPlayer(targetId)

    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Player not found',
            type = 'error'
        })
        return
    end

    local results = MySQL.query.await([[
        SELECT job,
               COALESCE(SUM(duration), 0) as total_seconds,
               COUNT(*) as shift_count
        FROM job_clockin_logs
        WHERE citizenid = ?
        AND clockin_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        AND duration IS NOT NULL
        GROUP BY job
        ORDER BY total_seconds DESC
    ]], {targetPlayer.PlayerData.citizenid})

    if results and #results > 0 then
        local message = 'Work Hours (30 days):\n'
        for _, row in ipairs(results) do
            local hours = math.floor(row.total_seconds / 3600)
            message = message .. string.format('%s: %d hours (%d shifts)\n', row.job, hours, row.shift_count)
        end

        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Work Hours - ' .. targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname,
            description = message,
            type = 'info',
            duration = 10000
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Work Hours',
            description = 'No work hours found for this player in the last 30 days',
            type = 'info'
        })
    end
end)

if Config.Debug then
    print('^2[MultiJob]^7 Clock-in wrapper loaded successfully')
end
