
local function GetPlayerTruckingData(identifier, fields)
    return exports['siberwin_trucksimulator']:GetPlayerTruckingData(identifier, fields)
end

local SpecialJobList = require 'list/specialjoblist'
local specialLoadsData = SpecialJobList.jobs or {}


local function NormalizeDestinationCoords(raw)
    if not raw then return nil end
    if type(raw) == 'string' then
        local nums = {}
        for num in string.gmatch(raw, '([^,]+)') do
            local n = tonumber(num:match('%S+'))
            if n then table.insert(nums, n) end
        end
        if #nums >= 3 then
            return { x = nums[1], y = nums[2], z = nums[3], w = nums[4] or 0.0 }
        end
        return nil
    end
    if raw.x and raw.y and raw.z then
        return { x = raw.x, y = raw.y, z = raw.z, w = raw.w or raw.h or 0.0 }
    end
    return nil
end


local function CheckDailySpecialLoadsLimit(identifier)
    local playerData = GetPlayerTruckingData(identifier, {'daily_special_loads', 'special_loads_reset_time'})
    if not playerData then
        return { canTake = true, remaining = Config.SpecialLoads.dailyLimit, resetTime = 0 }
    end
    
    local currentTime = os.time()
    local dailySpecialLoads = tonumber(playerData.daily_special_loads) or 0
    local resetTime = tonumber(playerData.special_loads_reset_time) or 0
    
    if currentTime >= resetTime then
        dailySpecialLoads = 0
        local cooldownSeconds = (Config.SpecialLoads.cooldownMinutes * 60) + Config.SpecialLoads.cooldownSeconds
        local newResetTime = currentTime + cooldownSeconds
        
        MySQL.update('UPDATE sw_player_trucking_data SET daily_special_loads = 0, special_loads_reset_time = ? WHERE player_identifier = ?', 
                    {newResetTime, identifier})
        
        return { canTake = true, remaining = Config.SpecialLoads.dailyLimit, resetTime = newResetTime }
    end
    
    local remaining = Config.SpecialLoads.dailyLimit - dailySpecialLoads
    local canTake = remaining > 0
    
    return { canTake = canTake, remaining = remaining, resetTime = resetTime }
end

lib.callback.register('trucker:getSpecialLoads', function(source)
    local player = Wrapper.GetPlayerFromId(source)
    if not player then
        return { success = false, message = "Player not found" }
    end
    
    local identifier = Wrapper.GetPlayerIdentifier(player)
    if not identifier then
        return { success = false, message = "Player identifier not found" }
    end
    
    local limitCheck = CheckDailySpecialLoadsLimit(identifier)
    
    if type(specialLoadsData) ~= 'table' or next(specialLoadsData) == nil then
        return { 
            success = true, 
            specialLoads = {},
            dailyLimit = {
                canTake = limitCheck.canTake,
                remaining = limitCheck.remaining,
                resetTime = limitCheck.resetTime,
                maxDaily = Config.SpecialLoads.dailyLimit
            }
        }
    end
    
    local trailerImageMap = {
        ["trailers"] = "trailers/trailers.webp",
        ["trailers2"] = "trailers/trailers2.webp", 
        ["trailers3"] = "trailers/trailers3.webp",
        ["trailers4"] = "trailers/trailers4.webp",
        ["tanker"] = "trailers/tanker.webp",
        ["tanker2"] = "trailers/tanker2.webp",
        ["docktrailer"] = "trailers/docktrailer.webp",
        ["armytanker"] = "trailers/armytanker.webp",
        ["freighttrailer"] = "trailers/freighttrailer.webp",
        ["tr2"] = "trailers/tr2.webp",
        ["tr3"] = "trailers/tr3.webp", 
        ["tr4"] = "trailers/tr4.webp",
        ["trailerlarge"] = "trailers/trailerlarge.webp"
    }

    local availableLoads = {}
    for _, load in ipairs(specialLoadsData) do
        local trailerImage = trailerImageMap[load.trailerModel] or "trailers/trailers.webp"
        
        table.insert(availableLoads, {
            id = load.id,
            name = load.name,
            description = load.description,
            difficulty = load.difficulty,
            reward = load.reward,
            trailerImage = trailerImage,
            trailerModel = load.trailerModel
        })
    end
    
    return { 
        success = true, 
        specialLoads = availableLoads,
        dailyLimit = {
            canTake = limitCheck.canTake,
            remaining = limitCheck.remaining,
            resetTime = limitCheck.resetTime,
            maxDaily = Config.SpecialLoads.dailyLimit
        }
    }
end)

lib.callback.register('trucker:startSpecialLoadJob', function(source, jobId, selectedTruckPurchaseId)
    local player = Wrapper.GetPlayerFromId(source)
    if not player then
        return { success = false, message = "Player not found" }
    end
    
    local identifier = Wrapper.GetPlayerIdentifier(player)
    if not identifier then
        return { success = false, message = "Player identifier not found" }
    end
    
    if not jobId or not selectedTruckPurchaseId then
        return { success = false, message = "Missing parameter (jobId, selectedTruckPurchaseId)" }
    end
    
    local limitCheck = CheckDailySpecialLoadsLimit(identifier)
    if not limitCheck.canTake then
        return { 
            success = false, 
            message = "Daily special load limit reached. Remaining time: " .. math.ceil((limitCheck.resetTime - os.time()) / 60) .. " minutes",
            dailyLimitReached = true,
            resetTime = limitCheck.resetTime
        }
    end
    
    local selectedLoad = nil

    if type(specialLoadsData) ~= 'table' or next(specialLoadsData) == nil then
        return { success = false, message = "Special loads configuration is missing or empty" }
    end

    for _, load in ipairs(specialLoadsData) do
        if load.id == jobId then
            selectedLoad = load
            break
        end
    end
    
    if not selectedLoad then
        return { success = false, message = "Invalid special load ID: " .. tostring(jobId) }
    end
    
    local truckResult = MySQL.query.await('SELECT id, vehicle_spawn_name, plate, engine_health, body_health, fuel_level, primary_color_r, primary_color_g, primary_color_b, secondary_color_r, secondary_color_g, secondary_color_b FROM sw_player_vehicles WHERE id = ? AND player_identifier = ?', {selectedTruckPurchaseId, identifier})
    
    if not truckResult or #truckResult == 0 then
        return { success = false, message = "Truck information not found. ID: " .. selectedTruckPurchaseId }
    end
    
    local truckDetails = truckResult[1]
    
    local destCoordsTbl = NormalizeDestinationCoords(selectedLoad.destination_coords)
    local deliveryLocation = {
        name = selectedLoad.destination or "Special Destination",
        coords = destCoordsTbl or { x = 1201.85, y = -3253.16, z = 7.10, w = 0.0 }
    }
    local trailerSpawnCoordsNormalized = NormalizeDestinationCoords(selectedLoad.trailer_spawn_coords)
    
    local cashReward = math.random(selectedLoad.reward.cash.min, selectedLoad.reward.cash.max)
    local xpReward = math.random(selectedLoad.reward.xp.min, selectedLoad.reward.xp.max)
    
    if Config.DifficultyMultipliers and Config.DifficultyMultipliers[selectedLoad.difficulty] then
        local multiplier = Config.DifficultyMultipliers[selectedLoad.difficulty]
        cashReward = math.floor(cashReward * multiplier.cash)
        xpReward = math.floor(xpReward * multiplier.xp)
    end
    
    local truckPlate = truckDetails.plate
    if not truckPlate or truckPlate == "" then
        truckPlate = "TRUCK" .. math.random(1000, 9999)
        MySQL.query.await('UPDATE sw_player_vehicles SET plate = ? WHERE id = ?', {truckPlate, selectedTruckPurchaseId})
    end
    
    local currentTime = os.time()
    local playerData = GetPlayerTruckingData(identifier, {'daily_special_loads', 'special_loads_reset_time'})
    local currentCount = tonumber(playerData and playerData.daily_special_loads or 0)
    local newCount = currentCount + 1
    
    MySQL.update('UPDATE sw_player_trucking_data SET daily_special_loads = ? WHERE player_identifier = ?', 
                {newCount, identifier})
    
    local jobDataForClient = {
        id = selectedLoad.id,
        name = selectedLoad.name,
        description = selectedLoad.description,
        difficulty = selectedLoad.difficulty,
        truckSpawnName = truckDetails.vehicle_spawn_name,
        trailerModel = selectedLoad.trailerModel,
        destination = deliveryLocation.name,
        destination_coords = deliveryLocation.coords,
        trailer_spawn_coords = trailerSpawnCoordsNormalized,
        reward = {
            cash = cashReward,
            xp = xpReward
        },
        truckHealth = {
            engine = truckDetails.engine_health or 1000,
            body = truckDetails.body_health or 1000,
            fuel = truckDetails.fuel_level or 100
        },
        truckColors = {
            primary = {
                r = truckDetails.primary_color_r or 0,
                g = truckDetails.primary_color_g or 0,
                b = truckDetails.primary_color_b or 0
            },
            secondary = {
                r = truckDetails.secondary_color_r or 0,
                g = truckDetails.secondary_color_g or 0,
                b = truckDetails.secondary_color_b or 0
            }
        },
        calculatedDistance = math.random(5000, 15000)
    }
    
    return {
        success = true,
        message = "Special load job started successfully",
        jobDataForClient = jobDataForClient
    }
end)

local function IsJobInList(jobName, list)
    if not jobName or not list then return false end
    for _, n in ipairs(list) do
        if n == jobName then return true end
    end
    return false
end

local function DispatchSpecialLoadAlert(src, clientCoords)
    local cfg = Config.SpecialLoads and Config.SpecialLoads.policeAlertOnCheckFail
    if not cfg or not cfg.enabled then return end

    local coords
    if cfg.coordsSource == 'client' and clientCoords and clientCoords.x and clientCoords.y and clientCoords.z then
        coords = vector3(clientCoords.x, clientCoords.y, clientCoords.z)
    else
        local ped = GetPlayerPed(src)
        coords = GetEntityCoords(ped)
    end

    local message = cfg.notifyMessage or 'Special loads trailer check failed! Suspicious activity reported.'
    local policeJobs = cfg.policeJobs or {'police'}

    local ServerFramework, FrameworkName = exports.siberwin_trucksimulator:GetFramework()

    if FrameworkName == 'qbcore' then
        local players = GetPlayers()
        for _, pid in ipairs(players) do
            local Player = ServerFramework.Functions.GetPlayer(pid)
            if Player and Player.PlayerData and Player.PlayerData.job then
                local job = Player.PlayerData.job
                local isLeo = (cfg.useJobTypeLeo == true and job.type == 'leo' and job.onduty == true)
                local isNamedPolice = IsJobInList(job.name, policeJobs)
                if isLeo or isNamedPolice then
                    local ev = cfg.qb and cfg.qb.eventName or nil
                    local t = cfg.qb and (cfg.qb.eventType or 'client') or 'client'
                    if ev == 'police:client:policeAlert' then
                        TriggerClientEvent('police:client:policeAlert', pid, coords, message)
                        TriggerClientEvent('qb-phone:client:addPoliceAlert', pid, { title = 'New Call', coords = { x = coords.x, y = coords.y, z = coords.z }, description = message })
                    elseif ev == 'qb-phone:client:addPoliceAlert' then
                        TriggerClientEvent('qb-phone:client:addPoliceAlert', pid, { title = 'New Call', coords = { x = coords.x, y = coords.y, z = coords.z }, description = message })
                    elseif ev == 'police:server:policeAlert' then
                        TriggerClientEvent('police:client:policeAlert', pid, coords, message)
                        TriggerClientEvent('qb-phone:client:addPoliceAlert', pid, { title = 'New Call', coords = { x = coords.x, y = coords.y, z = coords.z }, description = message })
                    elseif ev and ev ~= '' then
                        local payload = { coords = { x = coords.x, y = coords.y, z = coords.z }, source = src, type = 'special_load_check_fail', message = message }
                        if t == 'client' then
                            TriggerClientEvent(ev, pid, payload)
                        else
                            TriggerEvent(ev, pid, payload)
                        end
                    else
                        Wrapper.Notify(pid, message, 'error', 8000)
                    end
                end
            end
        end
    elseif FrameworkName == 'esx' then
        local ev = cfg.esx and cfg.esx.eventName or ''
        local t = cfg.esx and (cfg.esx.eventType or 'client') or 'client'
        if ev == 'esx_addons_gcphone:startCall' then
            local targetJob = (policeJobs and policeJobs[1]) or 'police'
            TriggerEvent('esx_addons_gcphone:startCall', targetJob, message, true, { x = coords.x, y = coords.y, z = coords.z })
        elseif ev == 'wf-alerts:svNotify' then
            local data = {
                displayCode = '911',
                description = message,
                isImportant = 0,
                recipientList = policeJobs,
                length = '10000',
                infoM = 'fa-exclamation-triangle',
                info = 'Special Loads - Trailer check failed'
            }
            local dispatchData = { dispatchData = data, caller = 'Trucker Simulator', coords = vector3(coords.x, coords.y, coords.z) }
            TriggerEvent('wf-alerts:svNotify', dispatchData)
        else
            local players = ServerFramework.GetPlayers()
            for i=1, #players do
                local Player = ServerFramework.GetPlayerFromId(players[i])
                if Player and Player.job and IsJobInList(Player.job.name, policeJobs) then
                    if ev ~= '' then
                        if ev == 'esx_outlawalert:alert' then
                            TriggerClientEvent('esx_outlawalert:alert', players[i], { x = coords.x, y = coords.y, z = coords.z }, message)
                        elseif ev == 'linden_outlawalert:alert' then
                            TriggerClientEvent('linden_outlawalert:alert', players[i], { x = coords.x, y = coords.y, z = coords.z }, message)
                        elseif ev == 'esx_policejob:alert' then
                            TriggerClientEvent('esx_policejob:alert', players[i], { x = coords.x, y = coords.y, z = coords.z }, message)
                        else
                            local payload = { coords = { x = coords.x, y = coords.y, z = coords.z }, source = src, type = 'special_load_check_fail', message = message }
                            if t == 'client' then
                                TriggerClientEvent(ev, players[i], payload)
                            else
                                TriggerEvent(ev, players[i], payload)
                            end
                        end
                    else
                        Wrapper.Notify(players[i], message, 'error', 8000)
                    end
                end
            end
        end
    end
end

exports('DispatchSpecialLoadAlert', DispatchSpecialLoadAlert)