-- Server-Side Core Logic for Advanced Taxi System
local QBCore = exports['qbx_core']:GetCoreObject()

-- Initialize player data cache
local activeTaxiDrivers = {}
local activeTrips = {}

-- Debug helper
local function Debug(msg)
    if Config.EnableDebug then
        print('^3[SV_TAXI DEBUG]^7 ' .. msg)
    end
end

-- Get or create taxi driver profile
local function GetDriverProfile(citizenid)
    local result = MySQL.single.await('SELECT * FROM taxi_drivers WHERE citizenid = ?', {citizenid})

    if not result then
        MySQL.insert.await('INSERT INTO taxi_drivers (citizenid, rank, xp) VALUES (?, ?, ?)', {
            citizenid, 1, 0
        })
        return {
            citizenid = citizenid,
            rank = 1,
            xp = 0,
            total_trips = 0,
            total_distance = 0.0,
            total_earnings = 0.0,
            best_tip = 0.0
        }
    end

    return result
end

-- Calculate rank from XP
local function CalculateRank(xp)
    local rank = 1
    for r = #Config.Ranks, 1, -1 do
        if xp >= Config.Ranks[r].xpRequired then
            rank = r
            break
        end
    end
    return rank
end

-- Add XP and check for rank up
local function AddXP(citizenid, amount)
    local profile = GetDriverProfile(citizenid)
    local oldRank = profile.rank
    local newXP = profile.xp + amount
    local newRank = CalculateRank(newXP)

    MySQL.update.await('UPDATE taxi_drivers SET xp = ?, rank = ? WHERE citizenid = ?', {
        newXP, newRank, citizenid
    })

    local rankChanged = newRank > oldRank

    Debug(('Added %d XP to %s (Total: %d, Rank: %d)'):format(amount, citizenid, newXP, newRank))

    return {
        xp = newXP,
        rank = newRank,
        rankUp = rankChanged,
        oldRank = oldRank,
        newRank = newRank
    }
end

-- Get player source from citizenid
local function GetPlayerByCitizenId(citizenid)
    local players = QBCore.Functions.GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.citizenid == citizenid then
            return src
        end
    end
    return nil
end

-- Callbacks
lib.callback.register('sv_taxi:getDriverData', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        Debug('getDriverData: Player not found for source ' .. source)
        return nil
    end

    local citizenid = player.PlayerData.citizenid
    local profile = GetDriverProfile(citizenid)
    if not profile then
        Debug('getDriverData: Failed to get profile for ' .. citizenid)
        return nil
    end

    local rankData = Config.Ranks[profile.rank]
    if not rankData then
        Debug('getDriverData: Invalid rank ' .. profile.rank)
        return nil
    end

    -- Calculate XP progress to next rank
    local nextRankXP = 0
    local currentRankXP = rankData.xpRequired
    local progress = 100

    if Config.Ranks[profile.rank + 1] then
        nextRankXP = Config.Ranks[profile.rank + 1].xpRequired
        local xpIntoRank = profile.xp - currentRankXP
        local xpNeeded = nextRankXP - currentRankXP
        progress = (xpIntoRank / xpNeeded) * 100
    end

    Debug(('getDriverData: Returning data for %s (Rank %d, XP %d)'):format(citizenid, profile.rank, profile.xp))

    return {
        citizenid = citizenid,
        rank = profile.rank,
        rankName = rankData.name,
        rankColor = rankData.color,
        xp = profile.xp,
        nextRankXP = nextRankXP,
        progress = progress,
        totalTrips = profile.total_trips,
        totalDistance = profile.total_distance,
        totalEarnings = profile.total_earnings,
        bestTip = profile.best_tip,
        unlockedVehicles = rankData.unlocks
    }
end)

lib.callback.register('sv_taxi:getVehicles', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        Debug('getVehicles: Player not found for source ' .. source)
        return {}
    end

    local profile = GetDriverProfile(player.PlayerData.citizenid)
    if not profile then
        Debug('getVehicles: Profile not found for ' .. player.PlayerData.citizenid)
        return {}
    end

    local rankData = Config.Ranks[profile.rank]
    if not rankData then
        Debug('getVehicles: Invalid rank ' .. profile.rank)
        return {}
    end

    local vehicles = {}

    -- Add unlocked vehicles
    if rankData.unlocks then
        for _, vehicleKey in ipairs(rankData.unlocks) do
            local vehData = Config.Vehicles[vehicleKey]
            if vehData then
                table.insert(vehicles, {
                    key = vehicleKey,
                    label = vehData.label,
                    model = vehData.model,
                    rank = vehData.rank,
                    multiplier = vehData.multiplier,
                    unlocked = true
                })
            end
        end
    end

    -- Add locked vehicles for display
    for key, vehData in pairs(Config.Vehicles) do
        if vehData.rank > profile.rank then
            table.insert(vehicles, {
                key = key,
                label = vehData.label,
                model = vehData.model,
                rank = vehData.rank,
                multiplier = vehData.multiplier,
                unlocked = false
            })
        end
    end

    table.sort(vehicles, function(a, b) return a.rank < b.rank end)

    Debug(('getVehicles: Returning %d vehicles for rank %d'):format(#vehicles, profile.rank))

    return vehicles
end)

lib.callback.register('sv_taxi:spawnVehicle', function(source, vehicleModel, coords)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    -- Check if player has taxi job
    if player.PlayerData.job.name ~= Config.JobName then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You must be employed as a taxi driver!'
        })
        return false
    end

    -- Verify player has unlocked this vehicle
    local profile = GetDriverProfile(player.PlayerData.citizenid)
    local rankData = Config.Ranks[profile.rank]
    local hasAccess = false

    for _, vehKey in ipairs(rankData.unlocks) do
        if Config.Vehicles[vehKey] and Config.Vehicles[vehKey].model == vehicleModel then
            hasAccess = true
            break
        end
    end

    if not hasAccess then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You have not unlocked this vehicle yet!'
        })
        return false
    end

    return true
end)

lib.callback.register('sv_taxi:startTrip', function(source, tripData)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local citizenid = player.PlayerData.citizenid
    activeTrips[citizenid] = {
        startTime = os.time(),
        startCoords = tripData.startCoords,
        passengerType = tripData.passengerType or 'npc',
        vehicle = tripData.vehicle
    }

    Debug(('Trip started for %s (%s)'):format(citizenid, tripData.passengerType))
    return true
end)

lib.callback.register('sv_taxi:completeTrip', function(source, tripData)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local citizenid = player.PlayerData.citizenid
    local trip = activeTrips[citizenid]

    if not trip then
        Debug('No active trip found for ' .. citizenid)
        return false
    end

    -- Calculate trip duration
    local duration = os.time() - trip.startTime

    -- Calculate fare
    local fare = Config.Fare.baseRate
    fare = fare + (tripData.distance * Config.Fare.perMeter)
    fare = fare + (duration * Config.Fare.perSecond)

    -- Apply vehicle multiplier
    if tripData.vehicle and Config.Vehicles[tripData.vehicle] then
        fare = fare * Config.Vehicles[tripData.vehicle].multiplier
    end

    fare = math.max(Config.Fare.minimumFare, math.min(fare, Config.Fare.maximumFare))

    -- Calculate tip (for NPC only)
    local tip = 0
    if tripData.passengerType == 'npc' and math.random(100) <= Config.Fare.tipChance then
        local tipPercent = math.random(Config.Fare.tipMin, Config.Fare.tipMax)
        tip = fare * (tipPercent / 100)
    end

    local totalPayout = fare + tip

    -- Calculate XP
    local xpEarned = Config.XP.perTrip
    xpEarned = xpEarned + (tripData.distance * Config.XP.perMeter)

    if tripData.distance < 500 then
        xpEarned = xpEarned + Config.XP.bonusShortTrip
    elseif tripData.distance < 2000 then
        xpEarned = xpEarned + Config.XP.bonusMediumTrip
    else
        xpEarned = xpEarned + Config.XP.bonusLongTrip
    end

    if tip > 0 then
        xpEarned = xpEarned + Config.XP.tipBonus
    end

    xpEarned = math.floor(xpEarned)

    -- Pay the driver
    exports.qbx_core:AddMoney(source, 'cash', math.floor(totalPayout), 'taxi-fare')

    -- Add XP
    local xpResult = AddXP(citizenid, xpEarned)

    -- Update stats
    MySQL.update.await([[
        UPDATE taxi_drivers
        SET total_trips = total_trips + 1,
            total_distance = total_distance + ?,
            total_earnings = total_earnings + ?,
            best_tip = GREATEST(best_tip, ?)
        WHERE citizenid = ?
    ]], {
        tripData.distance,
        totalPayout,
        tip,
        citizenid
    })

    -- Log trip
    MySQL.insert.await([[
        INSERT INTO taxi_trips
        (citizenid, passenger_type, pickup_coords, dropoff_coords, distance, duration, fare, tip, xp_earned, vehicle)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid,
        tripData.passengerType,
        json.encode(tripData.pickupCoords),
        json.encode(tripData.dropoffCoords),
        tripData.distance,
        duration,
        fare,
        tip,
        xpEarned,
        tripData.vehicle
    })

    -- Clear active trip
    activeTrips[citizenid] = nil

    Debug(('Trip completed: Fare=$%.2f, Tip=$%.2f, XP=%d'):format(fare, tip, xpEarned))

    return {
        fare = fare,
        tip = tip,
        total = totalPayout,
        xp = xpEarned,
        rankUp = xpResult.rankUp,
        newRank = xpResult.newRank,
        newRankName = Config.Ranks[xpResult.newRank] and Config.Ranks[xpResult.newRank].name or 'Unknown'
    }
end)

lib.callback.register('sv_taxi:cancelTrip', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local citizenid = player.PlayerData.citizenid
    if activeTrips[citizenid] then
        activeTrips[citizenid] = nil
        Debug('Trip cancelled for ' .. citizenid)
        return true
    end

    return false
end)

-- Passenger name generator
local firstNames = {'Misty', 'Lance', 'Packie', 'Wade', 'Phil', 'Gabe', 'Trevor', 'Michael', 'Franklin', 'Lamar', 'Jimmy', 'Amanda', 'Tracey', 'Denise', 'Tanisha', 'Lester', 'Ron', 'Dave', 'Steve', 'Martin'}
local lastNames = {'Mendez', 'Vance', 'McReary', 'Hebert', 'Bell', 'Turner', 'Santos', 'Johnson', 'Williams', 'Davis', 'Brown', 'Martinez', 'Garcia', 'Rodriguez', 'Wilson', 'Anderson', 'Taylor', 'Thomas', 'Moore', 'Jackson'}

local function GeneratePassengerName()
    local first = firstNames[math.random(#firstNames)]
    local last = lastNames[math.random(#lastNames)]
    return first .. ' ' .. last
end

lib.callback.register('sv_taxi:getDispatchCalls', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return {} end

    local profile = GetDriverProfile(player.PlayerData.citizenid)
    if not profile then return {} end

    local playerRank = profile.rank
    local availableCalls = {}

    -- Generate calls based on call types
    for _, callType in ipairs(Config.CallTypes) do
        local isLocked = playerRank < callType.minRank

        table.insert(availableCalls, {
            id = callType.id,
            label = callType.label,
            description = callType.description,
            icon = callType.icon,
            minRank = callType.minRank,
            baseReward = callType.baseReward,
            xpReward = callType.xpReward,
            color = callType.color,
            locked = isLocked,
            passengerName = GeneratePassengerName()
        })
    end

    Debug(('Generated %d dispatch calls for rank %d'):format(#availableCalls, playerRank))

    return availableCalls
end)

lib.callback.register('sv_taxi:getLeaderboard', function(source)
    local results = MySQL.query.await([[
        SELECT
            td.citizenid,
            td.rank,
            td.total_trips,
            td.total_earnings,
            p.charinfo
        FROM taxi_drivers td
        LEFT JOIN players p ON p.citizenid = td.citizenid
        ORDER BY td.total_earnings DESC
        LIMIT 10
    ]])

    local leaderboard = {}
    for i, row in ipairs(results) do
        local charinfo = json.decode(row.charinfo) or {}
        table.insert(leaderboard, {
            position = i,
            name = ('%s %s'):format(charinfo.firstname or 'Unknown', charinfo.lastname or 'Driver'),
            rank = row.rank,
            rankName = Config.Ranks[row.rank] and Config.Ranks[row.rank].name or 'Unknown',
            trips = row.total_trips,
            earnings = row.total_earnings
        })
    end

    return leaderboard
end)

-- Player quit handler
AddEventHandler('playerDropped', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if player then
        activeTrips[player.PlayerData.citizenid] = nil
    end
end)

Debug('^2Taxi Job System Loaded^7')
