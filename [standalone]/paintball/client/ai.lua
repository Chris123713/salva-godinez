-- AI Practice Mode Client

local AIPracticeActive = false
local AIPeds = {} -- [ped] = {id, spawn, respawnTime}
local NextBotId = 1
local CurrentDifficulty = 'medium' -- Store current difficulty setting
local KillTargetReached = false -- Flag to stop spawning when kill target is reached
local KillTarget = 0 -- Store the kill target number
local KillTargetEnabled = false -- Whether kill target is enabled
local CurrentKills = 0 -- Track current kill count
local CurrentAIMode = 'none' -- 'none' (Free Play), 'killtarget', 'wave', 'timelimit'

-- Count alive bots (TOTAL across ALL spawn points, not per spawn point)
local function CountAliveBots()
    local count = 0
    for ped, _ in pairs(AIPeds) do
        if ped and DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
            count = count + 1
        end
    end
    return count -- Returns TOTAL count of all alive bots, regardless of spawn location
end

-- Get difficulty-based stats
local function GetDifficultyStats(difficulty)
    local stats = {
        easy = {
            accuracy = 0.15,      -- 15% accuracy (poor aim)
            health = 80,          -- Lower health
            armor = 25,           -- Less armor
            combatAbility = 1,     -- Lower combat ability (1 = poor)
            combatRange = 1       -- Shorter combat range
        },
        medium = {
            accuracy = 0.3,       -- 30% accuracy (decent aim)
            health = 100,         -- Normal health
            armor = 50,           -- Normal armor
            combatAbility = 2,    -- Medium combat ability (2 = normal)
            combatRange = 2       -- Normal combat range
        },
        hard = {
            accuracy = 0.6,       -- 60% accuracy (good aim)
            health = 150,         -- Higher health
            armor = 100,          -- More armor
            combatAbility = 3,    -- High combat ability (3 = expert)
            combatRange = 3       -- Longer combat range
        }
    }
    return stats[difficulty] or stats.medium
end

-- Start AI Practice Mode
function StartAIPractice(match)
    if not Config.AIPractice.enabled then 
        print("[Paintball AI] AI Practice is disabled in config")
        return 
    end
    
    print("[Paintball AI] Starting AI Practice Mode")
    AIPracticeActive = true
    AIPeds = {}
    NextBotId = 1
    KillTargetReached = false -- Reset kill target flag
    CurrentKills = 0 -- Reset kill count
    
    -- Get difficulty and settings from match
    CurrentDifficulty = (match.settings and match.settings.difficulty) or 'medium'
    CurrentAIMode = (match.settings and match.settings.aiMode) or 'none'
    KillTargetEnabled = (match.settings and match.settings.killTargetEnabled) or false
    KillTarget = (match.settings and match.settings.killTarget) or 0
    WaveMode = (match.settings and match.settings.waveMode) or false
    WaveSize = (match.settings and match.settings.waveSize) or 5
    CurrentWave = 0
    BotsInCurrentWave = 0
    
    print(string.format("[Paintball AI] Starting practice mode - AI Mode: %s", CurrentAIMode))
    
    -- Determine how many bots to spawn initially
    local maxBotCount = 0
    local maxConcurrent = Config.AIPractice.maxConcurrentBots or 20
    
    -- For Free Play mode (aiMode == 'none'), spawn up to maxConcurrent bots
    if CurrentAIMode == 'none' then
        maxBotCount = maxConcurrent
        print(string.format("[Paintball AI] Free Play mode - will maintain up to %d bots continuously", maxConcurrent))
    -- Priority: If killTarget is enabled, use killTarget as the bot count
    elseif match.settings.killTargetEnabled == true then
        maxBotCount = match.settings.killTarget or 10
        print(string.format("[Paintball AI] Kill target enabled: %d kills required", maxBotCount))
    -- Otherwise, use botCount if enabled
    elseif match.settings.botCountEnabled ~= false then
        maxBotCount = match.settings.botCount or 15
        if not match.settings.botCount then
            -- Fallback to default ranges if not specified
            if CurrentDifficulty == 'easy' then
                maxBotCount = 15
            elseif CurrentDifficulty == 'medium' then
                maxBotCount = 45
            elseif CurrentDifficulty == 'hard' then
                maxBotCount = 85
            end
        end
    end
    
    -- Ensure we have a valid bot count
    if maxBotCount <= 0 then
        print("[Paintball AI] ERROR: maxBotCount is 0 or invalid, defaulting to 10")
        maxBotCount = 10
    end
    
    -- For Free Play, limit initial spawn to maxConcurrent
    if CurrentAIMode == 'none' then
        maxBotCount = math.min(maxBotCount, maxConcurrent)
    end
    
    print(string.format("[Paintball AI] Will spawn %d bots (killTargetEnabled: %s, botCountEnabled: %s)", 
        maxBotCount, 
        tostring(match.settings.killTargetEnabled), 
        tostring(match.settings.botCountEnabled)))
    print(string.format("[Paintball AI] useSpawnPoints: %s, spawnPoints count: %d", 
        tostring(Config.AIPractice.useSpawnPoints), 
        Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints or 0))
    
    -- Debug: Print all spawn points
    if Config.AIPractice.spawnPoints then
        print("[Paintball AI] ===== SPAWN POINTS CONFIGURATION =====")
        for i, point in ipairs(Config.AIPractice.spawnPoints) do
            print(string.format("[Paintball AI] Spawn point %d: %.6f, %.6f, %.6f, heading: %.6f", i, point.x, point.y, point.z, point.w or 0.0))
        end
        print("[Paintball AI] ======================================")
    else
        print("[Paintball AI] ERROR: spawnPoints is nil!")
    end
    
    -- CRITICAL CHECK: If useSpawnPoints is true but no spawn points, error out
    if Config.AIPractice.useSpawnPoints and (not Config.AIPractice.spawnPoints or #Config.AIPractice.spawnPoints == 0) then
        print("[Paintball AI] ERROR: useSpawnPoints is true but no spawn points defined!")
        return
    end
    
    -- Debug: Print all spawn points
    if Config.AIPractice.spawnPoints then
        for i, point in ipairs(Config.AIPractice.spawnPoints) do
            print(string.format("[Paintball AI] Spawn point %d: %.2f, %.2f, %.2f, %.2f", i, point.x, point.y, point.z, point.w or 0.0))
        end
    end
    
    -- If both are disabled, don't spawn any bots
    if maxBotCount == 0 then
        print("[Paintball AI] ERROR: maxBotCount is 0, cannot spawn bots")
        return
    end
    
    local spawnLocation = Config.AIPractice.spawnLocation
    local spawnRadius = Config.AIPractice.spawnRadius or 50.0
    local minDistanceFromPlayer = Config.AIPractice.minDistanceFromPlayer or 15.0
    local playerPed = cache.ped
    local playerCoords = GetEntityCoords(playerPed)
    
    print(string.format("[Paintball AI] Player at: %.2f, %.2f, %.2f", playerCoords.x, playerCoords.y, playerCoords.z))
    
    -- Preload all bot models instantly (so spawning is instant)
    print("[Paintball AI] Preloading bot models...")
    for _, model in ipairs(Config.AIPractice.botModels) do
        local modelHash = GetHashKey(model)
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 100 do
            Wait(0)
            timeout = timeout + 1
        end
        if HasModelLoaded(modelHash) then
            print(string.format("[Paintball AI] Model %s loaded", model))
        else
            print(string.format("[Paintball AI] WARNING: Model %s failed to load", model))
        end
    end
    print("[Paintball AI] All models preloaded - spawning bots instantly...")
    
    -- NO DELAY - spawn immediately
    
    -- Spawn initial bots (or first wave if wave mode)
    if not WaveMode then
        -- Spawn all bots at once
        -- Limit initial spawn to max concurrent bots (TOTAL across all spawn points)
        local maxConcurrent = Config.AIPractice.maxConcurrentBots or 20
        local initialSpawnCount = math.min(maxBotCount, maxConcurrent)
        
        print(string.format("[Paintball AI] Initial spawn: %d bots (max concurrent: %d TOTAL)", initialSpawnCount, maxConcurrent))
        
        -- Set NextBotId to start after initial spawns
        NextBotId = initialSpawnCount + 1
        
        for i = 1, initialSpawnCount do
        local attempts = 0
        local spawn = nil
        
        -- Check if using specific spawn points
        if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
            -- For spawn points, just randomly select one (don't check distance - spawn points are fixed locations)
            local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
            spawn = Config.AIPractice.spawnPoints[spawnIndex]
            
            -- Debug: Print spawn point being used
            if spawn then
                print(string.format("[Paintball AI] Bot %d will spawn at spawn point %d: %.2f, %.2f, %.2f (heading: %.2f)", i, spawnIndex, spawn.x, spawn.y, spawn.z, spawn.w or 0.0))
            else
                print(string.format("[Paintball AI] ERROR: Spawn point %d is nil for bot %d", spawnIndex, i))
                -- Fallback: use first spawn point if selected one is nil
                if Config.AIPractice.spawnPoints[1] then
                    spawn = Config.AIPractice.spawnPoints[1]
                    print(string.format("[Paintball AI] Using fallback spawn point 1: %.2f, %.2f, %.2f", spawn.x, spawn.y, spawn.z))
                end
            end
        else
            print(string.format("[Paintball AI] WARNING: Not using spawn points! useSpawnPoints=%s, spawnPoints exists=%s, count=%d", 
                tostring(Config.AIPractice.useSpawnPoints), 
                tostring(Config.AIPractice.spawnPoints ~= nil),
                Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints or 0))
            -- Try to find a spawn location that's far enough from the player and within boundaries
            while attempts < 20 do -- Increased attempts for better boundary checking
                local spawnX, spawnY, spawnZ, heading
                
                -- Check if using rectangular spawn area or circular radius
                if Config.AIPractice.useSpawnArea and Config.AIPractice.spawnArea then
                    local area = Config.AIPractice.spawnArea
                    -- Spawn within rectangular area
                    local offsetX = area.minX + (math.random() * (area.maxX - area.minX))
                    local offsetY = area.minY + (math.random() * (area.maxY - area.minY))
                    local offsetZ = area.minZ + (math.random() * (area.maxZ - area.minZ))
                    
                    spawnX = spawnLocation.x + offsetX
                    spawnY = spawnLocation.y + offsetY
                    spawnZ = spawnLocation.z + offsetZ
                    heading = spawnLocation.w + (math.random() - 0.5) * 60.0
                else
                    -- Use circular radius (original method)
                    local angle = (360.0 / maxBotCount) * i + (math.random() * 20.0 - 10.0)
                    local distance = (spawnRadius * 0.6) + (math.random() * spawnRadius * 0.4)
                    local randomZ = (math.random() - 0.5) * 2.0
                    
                    spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                    spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                    spawnZ = spawnLocation.z + randomZ
                    heading = spawnLocation.w + (math.random() - 0.5) * 60.0
                end
                
                local testSpawn = vector3(spawnX, spawnY, spawnZ)
                local distanceToPlayer = #(testSpawn - playerCoords)
                
                -- Verify spawn is within boundaries (if using spawn area)
                local withinBounds = true
                if Config.AIPractice.useSpawnArea and Config.AIPractice.spawnArea then
                    local area = Config.AIPractice.spawnArea
                    local distFromCenter = #(testSpawn - vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z))
                    -- Also check if within max radius as a safety measure
                    if distFromCenter > spawnRadius then
                        withinBounds = false
                    end
                end
                
                -- If spawn is far enough from player and within bounds, use it
                if distanceToPlayer >= minDistanceFromPlayer and withinBounds then
                    spawn = vector4(spawnX, spawnY, spawnZ, heading)
                    break
                end
                
                attempts = attempts + 1
            end
            
            -- If we couldn't find a good spawn, use the calculated one anyway (but at least at min distance)
            if not spawn then
                local angle = (360.0 / maxBotCount) * i
                local distance = math.max(minDistanceFromPlayer + 5.0, spawnRadius * 0.7) -- At least minDistance + 5
                local randomZ = (math.random() - 0.5) * 2.0
                local spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                local spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                local spawnZ = spawnLocation.z + randomZ
                local heading = spawnLocation.w + (math.random() - 0.5) * 60.0
                spawn = vector4(spawnX, spawnY, spawnZ, heading)
            end
        end
        
        -- CRITICAL: If useSpawnPoints is true, ONLY use spawn points - never fall back
        if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
            if not spawn or (spawn.x ~= Config.AIPractice.spawnPoints[1].x and 
                            spawn.x ~= Config.AIPractice.spawnPoints[2].x and 
                            spawn.x ~= Config.AIPractice.spawnPoints[3].x and 
                            spawn.x ~= Config.AIPractice.spawnPoints[4].x) then
                -- Force use of spawn points
                local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                spawn = Config.AIPractice.spawnPoints[spawnIndex]
                print(string.format("[Paintball AI] FORCED: Bot %d using spawn point %d: %.2f, %.2f, %.2f", i, spawnIndex, spawn.x, spawn.y, spawn.z))
            end
        end
        
        if spawn then
            -- Spawn immediately (no delay)
            SpawnAIBot(spawn, i)
        else
            print(string.format("[Paintball AI] ERROR: No valid spawn found for bot %d", i))
        end
        end
        
        -- Immediate verification (no delay)
        local immediateAlive = 0
        for ped, data in pairs(AIPeds) do
            if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
                immediateAlive = immediateAlive + 1
            end
        end
        print(string.format("[Paintball AI] Immediate check: %d bots spawned and alive", immediateAlive))
        
        -- Verify bots spawned (in a thread so it doesn't block main spawn)
        CreateThread(function()
            Wait(300) -- Small delay just to let spawns complete
            
            -- Verify bots actually spawned and are alive
            local actualAlive = 0
            for ped, data in pairs(AIPeds) do
                if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
                    actualAlive = actualAlive + 1
                end
            end
            
            print(string.format("[Paintball AI] Verification: %d/%d bots are alive and tracked", actualAlive, initialSpawnCount))
            
            -- If Free Play mode or kill target enabled, spawn additional bots if needed
            local maxConcurrent = Config.AIPractice.maxConcurrentBots or 20
            local shouldSpawnMore = false
            
            if CurrentAIMode == 'none' then
                -- Free Play: Always maintain up to maxConcurrent bots
                shouldSpawnMore = actualAlive < maxConcurrent
            elseif KillTargetEnabled and actualAlive < maxBotCount and actualAlive < maxConcurrent then
                -- Kill Target: Spawn more if needed for kill target
                shouldSpawnMore = true
            end
            
            if shouldSpawnMore then
                local needed = 0
                if CurrentAIMode == 'none' then
                    needed = maxConcurrent - actualAlive
                    print(string.format("[Paintball AI] Free Play - Spawning %d additional bots to reach %d total", needed, maxConcurrent))
                else
                    needed = math.min(maxBotCount - actualAlive, maxConcurrent - actualAlive)
                    print(string.format("[Paintball AI] Spawning %d additional bots to reach kill target of %d", needed, maxBotCount))
                end
                
                for j = 1, needed do
                    local spawn = nil
                    if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
                        local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                        spawn = Config.AIPractice.spawnPoints[spawnIndex]
                    else
                        local angle = math.random() * 360.0
                        local distance = spawnRadius * 0.5 + (math.random() * spawnRadius * 0.5)
                        local randomZ = (math.random() - 0.5) * 2.0
                        local spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                        local spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                        local spawnZ = spawnLocation.z + randomZ
                        spawn = vector4(spawnX, spawnY, spawnZ, spawnLocation.w or 0.0)
                    end
                    
                    if spawn then
                        SpawnAIBot(spawn, NextBotId)
                        NextBotId = NextBotId + 1
                        Wait(0) -- Minimal delay, just frame skip
                    end
                end
                
                -- Final verification
                Wait(500)
                actualAlive = 0
                for ped, data in pairs(AIPeds) do
                    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
                        actualAlive = actualAlive + 1
                    end
                end
                print(string.format("[Paintball AI] Final verification: %d bots are alive (target: %d)", actualAlive, maxBotCount))
            end
        end)
    else
        -- Wave mode: spawn first wave immediately (NO DELAY)
        CurrentWave = 1
        SpawnWave(WaveSize, spawnLocation, spawnRadius, minDistanceFromPlayer, playerPed, playerCoords)
        
        lib.notify({
            title = 'Wave 1',
            description = string.format('Wave 1 incoming!', CurrentWave),
            type = 'inform',
            duration = 3000
        })
    end
    
    -- Thread to keep bots within spawn area (ONLY if NOT using specific spawn points)
    if not Config.AIPractice.useSpawnPoints then
        CreateThread(function()
            while AIPracticeActive do
                Wait(2000) -- Check every 2 seconds
                local playerPed = cache.ped
                local playerCoords = GetEntityCoords(playerPed)
                
                for ped, data in pairs(AIPeds) do
                    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) then
                        local botCoords = GetEntityCoords(ped)
                        local distanceFromSpawn = #(botCoords - vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z))
                        
                        -- Check if bot is too far from spawn area
                        local maxDistance = spawnRadius * 1.5 -- Allow 50% buffer beyond spawn radius
                        
                        if distanceFromSpawn > maxDistance then
                            -- Bot wandered too far, teleport back to spawn area
                            local attempts = 0
                            local newSpawn = nil
                            
                            while attempts < 10 do
                                local angle = math.random() * 360.0
                                local distance = spawnRadius * 0.5 + (math.random() * spawnRadius * 0.5)
                                local randomZ = (math.random() - 0.5) * 2.0
                                
                                local spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                                local spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                                local spawnZ = spawnLocation.z + randomZ
                                
                                local testSpawn = vector3(spawnX, spawnY, spawnZ)
                                local distanceToPlayer = #(testSpawn - playerCoords)
                                
                                if distanceToPlayer >= minDistanceFromPlayer then
                                    newSpawn = vector3(spawnX, spawnY, spawnZ)
                                    break
                                end
                                
                                attempts = attempts + 1
                            end
                            
                            if newSpawn then
                                SetEntityCoords(ped, newSpawn.x, newSpawn.y, newSpawn.z, false, false, false, true)
                                -- Re-engage player
                                TaskCombatPed(ped, playerPed, 0, 16)
                            else
                                -- Fallback: teleport to original spawn
                                SetEntityCoords(ped, data.spawn.x, data.spawn.y, data.spawn.z, false, false, false, true)
                                TaskCombatPed(ped, playerPed, 0, 16)
                            end
                        end
                    end
                end
            end
        end)
    else
        -- When using spawn points, bots spawn at those points but can move freely to engage player
        print("[Paintball AI] Spawn points enabled - bots will spawn at specified coordinates and move to engage player")
    end
    
    CreateThread(function()
        while AIPracticeActive do
            Wait(1000)
            UpdateAIBots()
            
            -- Wave mode: spawn next wave when current wave is cleared
            if WaveMode then
                local aliveCount = 0
                for ped, _ in pairs(AIPeds) do
                    if DoesEntityExist(ped) and not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
                        aliveCount = aliveCount + 1
                    end
                end
                
                if aliveCount == 0 and BotsInCurrentWave == 0 then
                    -- All bots dead, spawn next wave
                    Wait(2000) -- 2 second delay between waves
                    if AIPracticeActive and not KillTargetReached then
                        CurrentWave = CurrentWave + 1
                        local playerPed = cache.ped
                        local playerCoords = GetEntityCoords(playerPed)
                        local spawnLocation = Config.AIPractice.spawnLocation
                        local spawnRadius = Config.AIPractice.spawnRadius or 50.0
                        local minDistanceFromPlayer = Config.AIPractice.minDistanceFromPlayer or 15.0
                        SpawnWave(WaveSize, spawnLocation, spawnRadius, minDistanceFromPlayer, playerPed, playerCoords)
                        
                        lib.notify({
                            title = 'Wave ' .. CurrentWave,
                            description = string.format('Wave %d incoming!', CurrentWave),
                            type = 'inform',
                            duration = 3000
                        })
                    end
                end
            end
        end
    end)
end

-- Spawn a wave of bots
function SpawnWave(waveSize, spawnLocation, spawnRadius, minDistanceFromPlayer, playerPed, playerCoords)
    BotsInCurrentWave = waveSize
    for i = 1, waveSize do
        local attempts = 0
        local spawn = nil
        
        -- Check if using specific spawn points
        if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
            -- For spawn points, just randomly select one (spawn points are fixed locations, don't check distance)
            local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
            spawn = Config.AIPractice.spawnPoints[spawnIndex]
            if spawn then
                print(string.format("[Paintball AI] Wave bot %d using spawn point %d: %.2f, %.2f, %.2f (heading: %.2f)", i, spawnIndex, spawn.x, spawn.y, spawn.z, spawn.w or 0.0))
            else
                print(string.format("[Paintball AI] ERROR: Wave spawn point %d is nil for bot %d", spawnIndex, i))
                -- Fallback: use first spawn point
                if Config.AIPractice.spawnPoints[1] then
                    spawn = Config.AIPractice.spawnPoints[1]
                    print(string.format("[Paintball AI] Using fallback spawn point 1: %.2f, %.2f, %.2f", spawn.x, spawn.y, spawn.z))
                end
            end
        else
            print(string.format("[Paintball AI] WARNING: Wave mode not using spawn points! useSpawnPoints=%s", tostring(Config.AIPractice.useSpawnPoints)))
            -- Try to find a spawn location that's far enough from the player and within boundaries
            while attempts < 20 do -- Increased attempts for better boundary checking
                local spawnX, spawnY, spawnZ, heading
                
                -- Check if using rectangular spawn area or circular radius
                if Config.AIPractice.useSpawnArea and Config.AIPractice.spawnArea then
                    local area = Config.AIPractice.spawnArea
                    -- Spawn within rectangular area
                    local offsetX = area.minX + (math.random() * (area.maxX - area.minX))
                    local offsetY = area.minY + (math.random() * (area.maxY - area.minY))
                    local offsetZ = area.minZ + (math.random() * (area.maxZ - area.minZ))
                    
                    spawnX = spawnLocation.x + offsetX
                    spawnY = spawnLocation.y + offsetY
                    spawnZ = spawnLocation.z + offsetZ
                    heading = spawnLocation.w + (math.random() - 0.5) * 60.0
                else
                    -- Use circular radius (original method)
                    local angle = (360.0 / waveSize) * i + (math.random() * 20.0 - 10.0)
                    local distance = (spawnRadius * 0.6) + (math.random() * spawnRadius * 0.4)
                    local randomZ = (math.random() - 0.5) * 2.0
                    
                    spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                    spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                    spawnZ = spawnLocation.z + randomZ
                    heading = spawnLocation.w + (math.random() - 0.5) * 60.0
                end
                
                local testSpawn = vector3(spawnX, spawnY, spawnZ)
                local distanceToPlayer = #(testSpawn - playerCoords)
                
                -- Verify spawn is within boundaries (if using spawn area)
                local withinBounds = true
                if Config.AIPractice.useSpawnArea and Config.AIPractice.spawnArea then
                    local area = Config.AIPractice.spawnArea
                    local distFromCenter = #(testSpawn - vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z))
                    -- Also check if within max radius as a safety measure
                    if distFromCenter > spawnRadius then
                        withinBounds = false
                    end
                end
                
                -- If spawn is far enough from player and within bounds, use it
                if distanceToPlayer >= minDistanceFromPlayer and withinBounds then
                    spawn = vector4(spawnX, spawnY, spawnZ, heading)
                    break
                end
                
                attempts = attempts + 1
            end
            
            if not spawn then
                local angle = (360.0 / waveSize) * i
                local distance = math.max(minDistanceFromPlayer + 5.0, spawnRadius * 0.7)
                local randomZ = (math.random() - 0.5) * 2.0
                spawn = vector4(
                    spawnLocation.x + (math.cos(math.rad(angle)) * distance),
                    spawnLocation.y + (math.sin(math.rad(angle)) * distance),
                    spawnLocation.z + randomZ,
                    spawnLocation.w + (math.random() - 0.5) * 60.0
                )
            end
        end
        
        -- CRITICAL: If useSpawnPoints is true, ONLY use spawn points - never fall back
        if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
            if not spawn then
                -- Force use of spawn points
                local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                spawn = Config.AIPractice.spawnPoints[spawnIndex]
                print(string.format("[Paintball AI] WAVE FORCED: Bot %d using spawn point %d: %.2f, %.2f, %.2f", NextBotId, spawnIndex, spawn.x, spawn.y, spawn.z))
            else
                -- Verify spawn is one of the configured points
                local isValidSpawnPoint = false
                for _, point in ipairs(Config.AIPractice.spawnPoints) do
                    if math.abs(spawn.x - point.x) < 0.1 and math.abs(spawn.y - point.y) < 0.1 and math.abs(spawn.z - point.z) < 0.1 then
                        isValidSpawnPoint = true
                        break
                    end
                end
                if not isValidSpawnPoint then
                    -- Force use of spawn points
                    local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                    spawn = Config.AIPractice.spawnPoints[spawnIndex]
                    print(string.format("[Paintball AI] WAVE CORRECTED: Bot %d forced to spawn point %d: %.2f, %.2f, %.2f", NextBotId, spawnIndex, spawn.x, spawn.y, spawn.z))
                end
            end
        end
        
        SpawnAIBot(spawn, NextBotId)
        NextBotId = NextBotId + 1
    end
end

-- Spawn a single AI bot
function SpawnAIBot(spawn, botIndex)
    local model = Config.AIPractice.botModels[math.random(#Config.AIPractice.botModels)]
    local modelHash = GetHashKey(model)
    
    -- Model should already be preloaded, but verify
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 10 do
            Wait(0) -- Quick check, should be instant if preloaded
            timeout = timeout + 1
        end
    end
    
    if not HasModelLoaded(modelHash) then
        print(string.format("[Paintball AI] ERROR: Failed to load model %s for bot %d (model not preloaded?)", model, botIndex))
        return false
    end
    
    -- Get difficulty-based stats BEFORE spawning
    local difficultyStats = GetDifficultyStats(CurrentDifficulty)
    
    -- Use ped type 4 (civilian) with network sync disabled (false, true) - this prevents dead spawning
    -- Use spawn.w for heading, or 0.0 if not provided
    local heading = spawn.w or 0.0
    
    -- Debug: Verify spawn coordinates before creating ped
    print(string.format("[Paintball AI] Creating bot %d at EXACT coordinates: %.6f, %.6f, %.6f, heading: %.6f", botIndex, spawn.x, spawn.y, spawn.z, heading))
    
    local ped = CreatePed(4, modelHash, spawn.x, spawn.y, spawn.z, heading, false, true)
    
    -- Verify ped was created at correct location
    if DoesEntityExist(ped) then
        Wait(0) -- No delay - instant verification
        local actualCoords = GetEntityCoords(ped)
        local distance = #(vector3(spawn.x, spawn.y, spawn.z) - actualCoords)
        if distance > 1.0 then
            print(string.format("[Paintball AI] WARNING: Bot %d spawned %.2f units away from target! Target: %.2f, %.2f, %.2f | Actual: %.2f, %.2f, %.2f", 
                botIndex, distance, spawn.x, spawn.y, spawn.z, actualCoords.x, actualCoords.y, actualCoords.z))
            -- Force teleport to exact location
            SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
            SetEntityHeading(ped, heading)
            Wait(0) -- No delay - instant verification
            -- Verify again
            actualCoords = GetEntityCoords(ped)
            distance = #(vector3(spawn.x, spawn.y, spawn.z) - actualCoords)
            print(string.format("[Paintball AI] After correction: Bot %d is now %.2f units from target", botIndex, distance))
        else
            print(string.format("[Paintball AI] Bot %d spawned correctly at target location (distance: %.2f)", botIndex, distance))
        end
    end
    
    if not DoesEntityExist(ped) then
        print(string.format("[Paintball AI] ERROR: Failed to create ped for bot %d", botIndex))
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    -- Set as mission entity FIRST (before anything else)
    SetEntityAsMissionEntity(ped, true, true)
    
    -- CRITICAL: Set health IMMEDIATELY after creation - this prevents dead spawning
    SetEntityHealth(ped, difficultyStats.health)
    SetPedArmour(ped, difficultyStats.armor)
    
    -- Clear any damage/death state immediately
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    SetEntityInvincible(ped, false)
    SetPedCanRagdoll(ped, true)
    
    -- Set health AGAIN to ensure it sticks (sometimes first set doesn't work)
    SetEntityHealth(ped, difficultyStats.health)
    SetPedArmour(ped, difficultyStats.armor)
    
    -- Verify health was set correctly
    local currentHealth = GetEntityHealth(ped)
    if currentHealth <= 0 or IsEntityDead(ped) then
        print(string.format("[Paintball AI] Bot %d spawned with %d health - forcing health again...", botIndex, currentHealth))
        
        -- Try multiple times to set health
        for i = 1, 5 do
            SetEntityHealth(ped, difficultyStats.health)
            SetPedArmour(ped, difficultyStats.armor)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            SetEntityInvincible(ped, false)
            Wait(0) -- No delay, just frame skip
        end
        
        currentHealth = GetEntityHealth(ped)
        if currentHealth <= 0 then
            print(string.format("[Paintball AI] ERROR: Bot %d still dead after all attempts - deleting", botIndex))
            DeleteEntity(ped)
            SetModelAsNoLongerNeeded(modelHash)
            return
        end
    end
    
    print(string.format("[Paintball AI] Bot %d spawned at %.2f, %.2f, %.2f with %d health", botIndex, spawn.x, spawn.y, spawn.z, GetEntityHealth(ped)))
    
    -- Set combat attributes
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAbility(ped, difficultyStats.combatAbility)
    SetPedCombatRange(ped, difficultyStats.combatRange)
    SetPedAccuracy(ped, math.floor(difficultyStats.accuracy * 100))
    
    -- Keep bot within area (prevent wandering)
    SetPedKeepTask(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    -- Give weapon
    local weaponHash = GetHashKey(Config.AIPractice.botWeapon)
    GiveWeaponToPed(ped, weaponHash, 999, false, true)
    SetCurrentPedWeapon(ped, weaponHash, true)
    
    -- Set relationships
    SetPedRelationshipGroupHash(ped, GetHashKey('HATES_PLAYER'))
    SetRelationshipBetweenGroups(5, GetHashKey('HATES_PLAYER'), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(5, GetHashKey('PLAYER'), GetHashKey('HATES_PLAYER'))
    
    -- Final check - if still dead after all attempts, try one more time with a fresh spawn
    if IsEntityDead(ped) or GetEntityHealth(ped) <= 0 then
        print(string.format("[Paintball AI] Bot %d still dead, attempting final revival...", botIndex))
        -- Delete and recreate at slightly elevated position
        DeleteEntity(ped)
        Wait(50)
        
        -- Try spawning again at slightly elevated position
        local elevatedSpawn = vector4(spawn.x, spawn.y, spawn.z + 0.5, spawn.w or 0.0)
        ped = CreatePed(4, modelHash, elevatedSpawn.x, elevatedSpawn.y, elevatedSpawn.z, elevatedSpawn.w or 0.0, false, true)
        
        if DoesEntityExist(ped) then
            Wait(0) -- No delay - instant setup
            SetEntityAsMissionEntity(ped, true, true)
            SetEntityHealth(ped, difficultyStats.health)
            SetPedArmour(ped, difficultyStats.armor)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            SetEntityInvincible(ped, false)
            
            if IsEntityDead(ped) or GetEntityHealth(ped) <= 0 then
                print(string.format("[Paintball AI] ERROR: Bot %d still dead after recreation - skipping", botIndex))
                DeleteEntity(ped)
                SetModelAsNoLongerNeeded(modelHash)
                return false
            end
        else
            print(string.format("[Paintball AI] ERROR: Failed to recreate bot %d", botIndex))
            SetModelAsNoLongerNeeded(modelHash)
            return false
        end
    end
    
    -- Final check - if still dead, delete it (this should rarely happen now)
    if IsEntityDead(ped) or GetEntityHealth(ped) <= 0 then
        print(string.format("[Paintball AI] ERROR: Bot %d is DEAD after setup - Deleting", botIndex))
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    -- Set combat task - bot is alive
    TaskCombatPed(ped, cache.ped, 0, 16)
    
    -- Final verification before adding to tracking
    local finalHealth = GetEntityHealth(ped)
    local finalArmor = GetPedArmour(ped)
    
    if IsEntityDead(ped) or finalHealth <= 0 then
        print(string.format("[Paintball AI] ERROR: Bot %d is DEAD after all setup - Deleting", botIndex))
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    -- Add to tracked bots (ONLY if bot is alive)
    AIPeds[ped] = {
        id = botIndex,
        spawn = spawn,
        respawnTime = 0
    }
    
    print(string.format("[Paintball AI] Bot %d is ALIVE with %d health, %d armor - Ready! (Tracked in AIPeds)", botIndex, finalHealth, finalArmor))
    
    SetModelAsNoLongerNeeded(modelHash)
    return ped -- Return the ped entity so we can verify it spawned
end

-- Continuous check for AI bot deaths (more reliable than gameEventTriggered)
CreateThread(function()
    local processedDeaths = {} -- Track which bots we've already processed as dead
    
    while true do
        Wait(100) -- Check every 100ms
        
        if AIPracticeActive and not KillTargetReached then
            local playerPed = cache.ped
            local playerCoords = GetEntityCoords(playerPed)
            
                    -- Create a copy of AIPeds keys to avoid modification during iteration
                    local pedsToCheck = {}
                    local pedsToRemove = {}
                    for ped, data in pairs(AIPeds) do
                        if ped and data then
                            table.insert(pedsToCheck, {ped = ped, data = data})
                        end
                    end
                    
                    for _, entry in ipairs(pedsToCheck) do
                        local ped = entry.ped
                        local data = entry.data
                        if ped and DoesEntityExist(ped) then
                            -- Check if bot is dead
                            if IsPedDeadOrDying(ped, true) or GetEntityHealth(ped) <= 0 then
                                -- Only process if we haven't already processed this death
                                if not processedDeaths[ped] then
                                    processedDeaths[ped] = true
                                    
                                    -- Check if player is close (likely killed it)
                                    local pedCoords = GetEntityCoords(ped)
                                    local distance = #(playerCoords - pedCoords)
                                    
                                    -- If player is close and bot is dead, assume player killed it
                                    if distance < 200.0 then
                                        -- Check for headshot (check last damage bone)
                                        local wasHeadshot = false
                                        local lastDamageBone = GetPedLastDamageBone(ped)
                                        if lastDamageBone == 31086 then -- Head bone
                                            wasHeadshot = true
                                        end
                                        
                                        print(string.format("[Paintball AI] Bot %d killed by player (headshot: %s, distance: %.2f)", data.id, tostring(wasHeadshot), distance))
                                        
                                        -- Update practice stats
                                        TriggerEvent('paintball:practice:kill', wasHeadshot)
                                        
                                        -- Show kill feed
                                        SendNUIMessage({
                                            action = 'addKillFeed',
                                            weapon = 'Paintball',
                                            headshot = wasHeadshot
                                        })
                                        
                                        -- Show kill confirmation
                                        SendNUIMessage({
                                            action = 'showKillConfirmation',
                                            weapon = 'Paintball',
                                            headshot = wasHeadshot
                                        })
                                        
                                        -- Show paint splatter effect
                                        SendNUIMessage({
                                            action = 'showPaintSplatter'
                                        })
                                        
                                        -- Play kill sound
                                        if wasHeadshot then
                                            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", true)
                                        else
                                            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                                        end
                                        
                                        -- Notify server
                                        TriggerServerEvent('paintball:server:aiKilled', ped)
                                        
                                        -- Increment kill count
                                        CurrentKills = CurrentKills + 1
                                        
                                        -- Decrease wave counter if in wave mode
                                        if WaveMode and BotsInCurrentWave > 0 then
                                            BotsInCurrentWave = BotsInCurrentWave - 1
                                        end
                                        
                                        -- Mark for removal (don't remove during iteration)
                                        table.insert(pedsToRemove, ped)
                                
                                -- Check if we should respawn a bot
                                local shouldRespawn = false
                                
                                -- Free Play mode: Always respawn if under max concurrent
                                if CurrentAIMode == 'none' then
                                    shouldRespawn = true
                                -- Kill Target mode: Respawn if kill target not reached
                                elseif KillTargetEnabled and KillTarget > 0 and CurrentKills < KillTarget and not KillTargetReached then
                                    shouldRespawn = true
                                end
                                
                                if shouldRespawn then
                                    -- Check if we're under the max concurrent bot cap
                                    local aliveCount = CountAliveBots()
                                    local maxConcurrent = Config.AIPractice.maxConcurrentBots or 20
                                    
                                    if CurrentAIMode == 'none' then
                                        print(string.format("[Paintball AI] Free Play - Alive bots: %d/%d - Will respawn: %s", aliveCount, maxConcurrent, tostring(aliveCount < maxConcurrent)))
                                    else
                                        print(string.format("[Paintball AI] Kill %d/%d - Alive bots: %d/%d - Will respawn: %s", CurrentKills, KillTarget, aliveCount, maxConcurrent, tostring(aliveCount < maxConcurrent)))
                                    end
                                    
                                    if aliveCount < maxConcurrent then
                                        -- Spawn a new bot at one of the spawn points (INSTANT, no delay)
                                        local spawnLocation = Config.AIPractice.spawnLocation
                                        local spawnRadius = Config.AIPractice.spawnRadius or 50.0
                                        local minDistanceFromPlayer = Config.AIPractice.minDistanceFromPlayer or 15.0
                                        local playerPed = cache.ped
                                        local playerCoords = GetEntityCoords(playerPed)
                                        
                                        -- Get spawn point
                                        local spawn = nil
                                        
                                        if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
                                            -- Use one of the specified spawn points
                                            local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                                            spawn = Config.AIPractice.spawnPoints[spawnIndex]
                                            print(string.format("[Paintball AI] INSTANT respawn: Bot %d at spawn point %d (Kill %d/%d, Alive: %d/%d)", NextBotId, spawnIndex, CurrentKills, KillTarget, aliveCount, maxConcurrent))
                                        else
                                            -- Use radius-based spawning
                                            local attempts = 0
                                            while attempts < 20 and not spawn do
                                                local angle = math.random() * 360.0
                                                local distance = spawnRadius * 0.5 + (math.random() * spawnRadius * 0.5)
                                                local randomZ = (math.random() - 0.5) * 2.0
                                                
                                                local spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                                                local spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                                                local spawnZ = spawnLocation.z + randomZ
                                                
                                                local testSpawn = vector3(spawnX, spawnY, spawnZ)
                                                local distanceToPlayer = #(testSpawn - playerCoords)
                                                
                                                if distanceToPlayer >= minDistanceFromPlayer then
                                                    spawn = vector4(spawnX, spawnY, spawnZ, spawnLocation.w or 0.0)
                                                    break
                                                end
                                                
                                                attempts = attempts + 1
                                            end
                                            
                                            if not spawn then
                                                -- Fallback to spawn location
                                                spawn = vector4(spawnLocation.x, spawnLocation.y, spawnLocation.z, spawnLocation.w or 0.0)
                                            end
                                            if CurrentAIMode == 'none' then
                                                print(string.format("[Paintball AI] INSTANT respawn: Bot %d at radius-based location (Free Play, Alive: %d/%d)", NextBotId, aliveCount, maxConcurrent))
                                            else
                                                print(string.format("[Paintball AI] INSTANT respawn: Bot %d at radius-based location (Kill %d/%d, Alive: %d/%d)", NextBotId, CurrentKills, KillTarget, aliveCount, maxConcurrent))
                                            end
                                        end
                                        
                                        if spawn then
                                            -- Spawn new bot INSTANTLY (no delay, no thread)
                                            local spawnedPed = SpawnAIBot(spawn, NextBotId)
                                            if spawnedPed then
                                                NextBotId = NextBotId + 1
                                                if CurrentAIMode == 'none' then
                                                    print(string.format("[Paintball AI] Bot %d respawned successfully (Free Play)", NextBotId - 1))
                                                else
                                                    print(string.format("[Paintball AI] Bot %d respawned successfully (Kill %d/%d)", NextBotId - 1, CurrentKills, KillTarget))
                                                end
                                            else
                                                print(string.format("[Paintball AI] ERROR: Failed to respawn bot %d", NextBotId))
                                            end
                                        end
                                    else
                                        print(string.format("[Paintball AI] Max concurrent bots reached (%d/%d), waiting for bot to die before respawning", aliveCount, maxConcurrent))
                                    end
                                end
                            end
                        end
                            else
                                -- Bot is alive, remove from processed deaths if it was there
                                processedDeaths[ped] = nil
                            end
                        else
                            -- Bot doesn't exist anymore, mark for removal
                            table.insert(pedsToRemove, ped)
                        end
                    end
                    
                    -- Clean up removed peds after iteration
                    for _, pedToRemove in ipairs(pedsToRemove) do
                        AIPeds[pedToRemove] = nil
                        processedDeaths[pedToRemove] = nil
                    end
        else
            -- Reset processed deaths when not in practice mode
            processedDeaths = {}
        end
    end
end)

-- Update AI bots (simplified - no respawning, just maintain engagement)
function UpdateAIBots()
    if not AIPracticeActive then return end
    if KillTargetReached then return end -- Don't do anything if kill target is reached
    
    -- Count alive bots and update wave counter
    for ped, data in pairs(AIPeds) do
        if DoesEntityExist(ped) then
            if not IsPedDeadOrDying(ped, true) and GetEntityHealth(ped) > 0 then
                -- Keep AI engaged
                if not IsPedInCombat(ped, cache.ped) then
                    TaskCombatPed(ped, cache.ped, 0, 16)
                end
            end
        end
    end
end

-- Stop AI Practice Mode
function StopAIPractice()
    AIPracticeActive = false
    KillTargetReached = false
    
    -- Aggressively delete all tracked bots immediately
    for ped, _ in pairs(AIPeds) do
        if DoesEntityExist(ped) then
            SetEntityAsMissionEntity(ped, true, true)
            DeleteEntity(ped)
            -- Force delete multiple times to ensure cleanup
            Wait(0)
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
    
    -- Clear the table
    AIPeds = {}
    NextBotId = 1
    
    -- Aggressive cleanup - delete ALL AI bots in a large area
    local spawnLocation = Config.AIPractice.spawnLocation
    local cleanupRadius = 500.0 -- Very large radius to catch all bots
    
    -- Immediate cleanup pass
    local nearbyPeds = GetGamePool('CPed')
    for _, ped in ipairs(nearbyPeds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z) - pedCoords)
            if distance < cleanupRadius then
                -- Check if it's one of our AI bots (has the relationship group)
                local relGroup = GetPedRelationshipGroupHash(ped)
                if relGroup == GetHashKey('HATES_PLAYER') then
                    SetEntityAsMissionEntity(ped, true, true)
                    DeleteEntity(ped)
                    Wait(0)
                    if DoesEntityExist(ped) then
                        DeleteEntity(ped)
                    end
                end
            end
        end
    end
    
    -- Multiple cleanup passes to ensure everything is deleted
    CreateThread(function()
        for i = 1, 5 do -- Run cleanup 5 times
            Wait(200 * i) -- Stagger the cleanup passes
            if not AIPracticeActive then -- Only cleanup if still not active
                local nearbyPeds = GetGamePool('CPed')
                for _, ped in ipairs(nearbyPeds) do
                    if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
                        local pedCoords = GetEntityCoords(ped)
                        local distance = #(vector3(spawnLocation.x, spawnLocation.y, spawnLocation.z) - pedCoords)
                        if distance < cleanupRadius then
                            local relGroup = GetPedRelationshipGroupHash(ped)
                            if relGroup == GetHashKey('HATES_PLAYER') then
                                SetEntityAsMissionEntity(ped, true, true)
                                DeleteEntity(ped)
                                Wait(0)
                                if DoesEntityExist(ped) then
                                    DeleteEntity(ped)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end


-- Handle AI kills and player deaths (backup method)
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' and AIPracticeActive then
        local victim = args[1]
        local attacker = args[2]
        
        -- Player killed an AI bot
        if attacker == cache.ped and victim ~= cache.ped then
            for ped, data in pairs(AIPeds) do
                if ped == victim then
                    if IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) <= 0 then
                        -- Check for headshot
                        local wasHeadshot = false
                        local boneIndex = GetPedBoneIndex(victim, 31086) -- Head bone
                        if boneIndex ~= -1 then
                            local boneCoords = GetWorldPositionOfEntityBone(victim, boneIndex)
                            local playerCoords = GetEntityCoords(cache.ped)
                            local distance = #(boneCoords - playerCoords)
                            -- If kill was very close to head, consider it a headshot
                            if distance < 0.3 then
                                wasHeadshot = true
                            end
                        end
                        
                        -- Update practice stats via event (PracticeStats is in main.lua)
                        TriggerEvent('paintball:practice:kill', wasHeadshot)
                        
                        -- Show kill feed (streak will be updated by the event handler)
                        SendNUIMessage({
                            action = 'addKillFeed',
                            weapon = 'Paintball',
                            headshot = wasHeadshot
                        })
                        
                        -- Show kill confirmation
                        SendNUIMessage({
                            action = 'showKillConfirmation',
                            weapon = 'Paintball',
                            headshot = wasHeadshot
                        })
                        
                        -- Show paint splatter effect
                        SendNUIMessage({
                            action = 'showPaintSplatter'
                        })
                        
                        -- Play kill sound
                        if wasHeadshot then
                            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", true)
                        else
                            PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                        end
                        
                        TriggerServerEvent('paintball:server:aiKilled', ped)
                        
                        -- Increment kill count
                        CurrentKills = CurrentKills + 1
                        
                        -- Check if we should respawn a bot
                        local shouldRespawn = false
                        
                        -- Free Play mode: Always respawn if under max concurrent
                        if CurrentAIMode == 'none' then
                            shouldRespawn = true
                        -- Kill Target mode: Respawn if kill target not reached
                        elseif KillTargetEnabled and KillTarget > 0 and CurrentKills < KillTarget and not KillTargetReached then
                            shouldRespawn = true
                        end
                        
                        if shouldRespawn then
                            -- Check if we're under the max concurrent bot cap
                            local aliveCount = CountAliveBots()
                            local maxConcurrent = Config.AIPractice.maxConcurrentBots or 20
                            
                            if CurrentAIMode == 'none' then
                                print(string.format("[Paintball AI] Free Play - Alive bots: %d/%d - Will respawn: %s", aliveCount, maxConcurrent, tostring(aliveCount < maxConcurrent)))
                            else
                                print(string.format("[Paintball AI] Kill %d/%d - Alive bots: %d/%d - Will respawn: %s", CurrentKills, KillTarget, aliveCount, maxConcurrent, tostring(aliveCount < maxConcurrent)))
                            end
                            
                            if aliveCount < maxConcurrent then
                                -- Spawn a new bot at one of the spawn points (INSTANT, no delay)
                                local spawnLocation = Config.AIPractice.spawnLocation
                                local spawnRadius = Config.AIPractice.spawnRadius or 50.0
                                local minDistanceFromPlayer = Config.AIPractice.minDistanceFromPlayer or 15.0
                                local playerPed = cache.ped
                                local playerCoords = GetEntityCoords(playerPed)
                                
                                -- Get spawn point
                                local spawn = nil
                                
                                if Config.AIPractice.useSpawnPoints and Config.AIPractice.spawnPoints and #Config.AIPractice.spawnPoints > 0 then
                                    -- Use one of the specified spawn points
                                    local spawnIndex = math.random(#Config.AIPractice.spawnPoints)
                                    spawn = Config.AIPractice.spawnPoints[spawnIndex]
                                    if CurrentAIMode == 'none' then
                                        print(string.format("[Paintball AI] INSTANT respawn: Bot %d at spawn point %d (Free Play, Alive: %d/%d)", NextBotId, spawnIndex, aliveCount, maxConcurrent))
                                    else
                                        print(string.format("[Paintball AI] INSTANT respawn: Bot %d at spawn point %d (Kill %d/%d, Alive: %d/%d)", NextBotId, spawnIndex, CurrentKills, KillTarget, aliveCount, maxConcurrent))
                                    end
                                else
                                    -- Use radius-based spawning
                                    local attempts = 0
                                    while attempts < 20 and not spawn do
                                        local angle = math.random() * 360.0
                                        local distance = spawnRadius * 0.5 + (math.random() * spawnRadius * 0.5)
                                        local randomZ = (math.random() - 0.5) * 2.0
                                        
                                        local spawnX = spawnLocation.x + (math.cos(math.rad(angle)) * distance)
                                        local spawnY = spawnLocation.y + (math.sin(math.rad(angle)) * distance)
                                        local spawnZ = spawnLocation.z + randomZ
                                        
                                        local testSpawn = vector3(spawnX, spawnY, spawnZ)
                                        local distanceToPlayer = #(testSpawn - playerCoords)
                                        
                                        if distanceToPlayer >= minDistanceFromPlayer then
                                            spawn = vector4(spawnX, spawnY, spawnZ, spawnLocation.w or 0.0)
                                            break
                                        end
                                        
                                        attempts = attempts + 1
                                    end
                                    
                                    if not spawn then
                                        -- Fallback to spawn location
                                        spawn = vector4(spawnLocation.x, spawnLocation.y, spawnLocation.z, spawnLocation.w or 0.0)
                                    end
                                    if CurrentAIMode == 'none' then
                                        print(string.format("[Paintball AI] INSTANT respawn: Bot %d at radius-based location (Free Play, Alive: %d/%d)", NextBotId, aliveCount, maxConcurrent))
                                    else
                                        print(string.format("[Paintball AI] INSTANT respawn: Bot %d at radius-based location (Kill %d/%d, Alive: %d/%d)", NextBotId, CurrentKills, KillTarget, aliveCount, maxConcurrent))
                                    end
                                end
                                
                                if spawn then
                                    -- Spawn new bot INSTANTLY (no delay, no thread)
                                    local spawnedPed = SpawnAIBot(spawn, NextBotId)
                                    if spawnedPed then
                                        NextBotId = NextBotId + 1
                                        if CurrentAIMode == 'none' then
                                            print(string.format("[Paintball AI] Bot %d respawned successfully (Free Play)", NextBotId - 1))
                                        else
                                            print(string.format("[Paintball AI] Bot %d respawned successfully (Kill %d/%d)", NextBotId - 1, CurrentKills, KillTarget))
                                        end
                                    else
                                        print(string.format("[Paintball AI] ERROR: Failed to respawn bot %d", NextBotId))
                                    end
                                end
                            else
                                print(string.format("[Paintball AI] Max concurrent bots reached (%d/%d), waiting for bot to die before respawning", aliveCount, maxConcurrent))
                            end
                        end
                    end
                    break
                end
            end
        end
        
        -- Player was killed (by AI or other)
        if victim == cache.ped then
            if IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) <= 0 then
                -- When player dies in practice mode, teleport back to arena and clear bots
                HandlePlayerDeathInPractice()
            end
        end
    end
end)

-- Handle player death in practice mode
function HandlePlayerDeathInPractice()
    if not AIPracticeActive then return end
    
    CreateThread(function()
        local ped = cache.ped
        local arenaCoords = Config.ArenaLocation.coords
        
        -- INSTANT smooth revival with quick screen fade (no delays, no clunky animations)
        DoScreenFadeOut(150) -- Very quick fade out
        Wait(150)
        
        -- Stop AI practice to clear all bots
        exports.paintball:StopAIPractice()
        
        -- Clear death status from any death system (wasabi_ambulance, etc.)
        TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
        TriggerEvent('wasabi_ambulance:customInjuryClear')
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
        
        -- INSTANT revival and teleport in one go (no multiple attempts, no delays)
        ped = cache.ped
        NetworkResurrectLocalPlayer(arenaCoords.x, arenaCoords.y, arenaCoords.z, arenaCoords.w or 0.0, true, false)
        ClearPedTasksImmediately(ped)
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 0)
        
        -- Trigger framework spawn events to clear death state
        TriggerServerEvent('esx:onPlayerSpawn')
        TriggerEvent('esx:onPlayerSpawn')
        TriggerServerEvent('hospital:server:resetHungerThirst')
        TriggerServerEvent('hud:server:RelieveStress', 100)
        TriggerEvent('wasabi_bridge:onPlayerSpawn')
        
        -- Ensure player is alive (one quick check)
        Wait(50)
        ped = cache.ped
        if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) or GetEntityHealth(ped) <= 0 then
            NetworkResurrectLocalPlayer(arenaCoords.x, arenaCoords.y, arenaCoords.z, arenaCoords.w or 0.0, true, false)
            ClearPedTasksImmediately(ped)
            ClearPedBloodDamage(ped)
            ResetPedVisibleDamage(ped)
            SetEntityInvincible(ped, false)
            FreezeEntityPosition(ped, false)
            SetEntityHealth(ped, 200)
            SetPedArmour(ped, 0)
        end
        
        -- Fade back in smoothly
        DoScreenFadeIn(150)
        Wait(50)
        
        -- Re-enable inventory
        if exports.ox_inventory then
            exports.ox_inventory:closeInventory()
            LocalPlayer.state:set('invBusy', false, false)
            LocalPlayer.state:set('invHotkeys', true, false)
        end
        
        -- Remove all weapons
        RemoveAllPedWeapons(ped, true)
        SetPedInfiniteAmmo(ped, false)
        SetPedInfiniteAmmoClip(ped, false)
        
        -- Leave the match (this will trigger the proper cleanup on client side)
        TriggerServerEvent('paintball:server:leaveLobby')
        
        -- Show notification
        lib.notify({
            title = 'Practice Mode Ended',
            description = 'You died! Returning to arena entrance...',
            type = 'inform',
            duration = 3000
        })
    end)
end

-- Continuous death check for practice mode
CreateThread(function()
    while true do
        Wait(500) -- Check every 500ms
        
        if AIPracticeActive then
            local ped = cache.ped
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) or GetEntityHealth(ped) <= 0 then
                print("[Paintball AI] Death detected via continuous check")
                HandlePlayerDeathInPractice()
                break -- Exit thread after handling death
            end
        end
    end
end)

-- Set kill target reached flag
function SetKillTargetReached(reached)
    KillTargetReached = reached
end

-- Export
exports('StartAIPractice', StartAIPractice)
exports('StopAIPractice', StopAIPractice)
exports('SetKillTargetReached', SetKillTargetReached)
