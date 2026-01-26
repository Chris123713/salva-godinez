-- Advanced Paintball System - Client

-- State
local InLobby = false
local InMatch = false
local CurrentMatch = nil
local SavedWeapons = {}
local SavedCoords = nil
local SavedHealth = nil
local SavedArmor = nil
local LastSpawnIndex = nil -- Track last spawn index to avoid consecutive same spawns

-- Practice Mode Statistics
local PracticeStats = {
    kills = 0,
    deaths = 0,
    headshots = 0,
    shotsFired = 0,
    shotsHit = 0,
    killStreak = 0,
    bestStreak = 0,
    startTime = 0,
    lastKillTime = 0
}

-- Handle practice kill event
RegisterNetEvent('paintball:practice:kill', function(wasHeadshot)
    if PracticeStats then
        PracticeStats.kills = PracticeStats.kills + 1
        PracticeStats.shotsHit = PracticeStats.shotsHit + 1
        PracticeStats.killStreak = PracticeStats.killStreak + 1
        if PracticeStats.killStreak > PracticeStats.bestStreak then
            PracticeStats.bestStreak = PracticeStats.killStreak
        end
        if wasHeadshot then
            PracticeStats.headshots = PracticeStats.headshots + 1
        end
        PracticeStats.lastKillTime = GetGameTimer()
        
        -- Update kill feed with streak
        SendNUIMessage({
            action = 'addKillFeed',
            weapon = 'Paintball',
            headshot = wasHeadshot,
            streak = PracticeStats.killStreak
        })
        
        -- Apply health system rewards (if enabled and in practice mode)
        if InMatch and CurrentMatch and CurrentMatch.gameMode == 'practice' and CurrentMatch.settings then
            local healthSystem = CurrentMatch.settings.healthSystem or 'standard'
            local healthSystemEnabled = CurrentMatch.settings.healthSystemEnabled or false
            
            print(string.format("[Paintball] Kill event - healthSystem: %s, healthSystemEnabled: %s, InMatch: %s, CurrentMatch exists: %s", 
                tostring(healthSystem), tostring(healthSystemEnabled), tostring(InMatch), tostring(CurrentMatch ~= nil)))
            
            if healthSystemEnabled then
                local ped = cache.ped
                local currentHealth = GetEntityHealth(ped)
                local currentArmor = GetPedArmour(ped)
                local maxHealth = GetEntityMaxHealth(ped)
                
                -- Health per kill system - works independently like armor
                if healthSystem == 'health_per_kill' then
                    local healthPerKill = CurrentMatch.settings.healthPerKill or 0
                    print(string.format("[Paintball] Health per kill check - healthSystem: %s, healthPerKill: %d, enabled: %s, currentHealth: %d", 
                        tostring(healthSystem), healthPerKill, tostring(healthSystemEnabled), currentHealth))
                    if healthPerKill > 0 then
                        local newHealth = math.min(currentHealth + healthPerKill, maxHealth)
                        SetEntityHealth(ped, newHealth)
                        
                        print(string.format("[Paintball] Health restored - old: %d, added: %d, new: %d", currentHealth, healthPerKill, newHealth))
                        
                        -- Clear damage effects so player doesn't sway when aiming
                        ClearPedBloodDamage(ped)
                        ResetPedVisibleDamage(ped)
                        -- Don't clear tasks as it interferes with weapon handling
                        
                        -- Clear injury sync from wasabi_ambulance (server-side)
                        if GetResourceState('wasabi_ambulance') == 'started' then
                            -- Clear injury sync on server
                            TriggerServerEvent('wasabi_ambulance:injurySync', false)
                            -- Clear any injury effects from wasabi_ambulance
                            TriggerEvent('wasabi_ambulance:customInjuryClear')
                            -- Clear death status if set
                            if LocalPlayer.state.isDead ~= nil then
                                LocalPlayer.state:set('isDead', false, false)
        end
    end
                        if GetResourceState('mythic_hospital') == 'started' then
                            -- Clear bleed effects from mythic_hospital
                            TriggerEvent('mythic_hospital:client:RemoveBleed')
                            -- Reset limbs to clear injury effects
                            TriggerEvent('mythic_hospital:client:ResetLimbs')
                        end
                        
                        -- Stop any post-processing effects (red screen, camera shake, etc.)
                        AnimpostfxStopAll()
                        
                        -- Clear camera shake/effects (this is what causes swaying)
                        StopGameplayCamShaking(true)
                        
                        -- Verify health was set (re-apply if needed immediately)
                        local verifyHealth = GetEntityHealth(ped)
                        if verifyHealth ~= newHealth then
                            print(string.format("[Paintball] WARNING: Health was immediately changed! Expected: %d, Got: %d. Re-applying...", newHealth, verifyHealth))
                            SetEntityHealth(ped, newHealth)
                            -- Try one more time after a frame
CreateThread(function()
                                Wait(0) -- Next frame
                                if GetEntityHealth(ped) ~= newHealth then
                                    SetEntityHealth(ped, newHealth)
                                    print(string.format("[Paintball] Re-applied health to %d", newHealth))
                                end
                            end)
                        end
                        
                        lib.notify({
                            title = 'Health Restored',
                            description = string.format('+%d HP', healthPerKill),
                            type = 'success',
                            duration = 2000
                        })
                    else
                        print("[Paintball] Health per kill is 0 or not set")
                    end
                else
                    print(string.format("[Paintball] Health system is not 'health_per_kill' - current: %s", tostring(healthSystem)))
                end
                
                -- Armor system (restore armor on kill) - works independently like health
                if healthSystem == 'armor' then
                    local armorPerKill = CurrentMatch.settings.armorPerKill or 0
                    print(string.format("[Paintball] Armor per kill check - healthSystem: %s, armorPerKill: %d, enabled: %s, currentArmor: %d", 
                        tostring(healthSystem), armorPerKill, tostring(healthSystemEnabled), currentArmor))
                    if armorPerKill > 0 then
                        local maxArmor = 100
                        local newArmor = math.min(currentArmor + armorPerKill, maxArmor)
                        SetPedArmour(ped, newArmor)
                        
                        print(string.format("[Paintball] Armor restored - old: %d, added: %d, new: %d", currentArmor, armorPerKill, newArmor))
                        
                        -- Show notification immediately
                        lib.notify({
                            title = 'Armor Restored',
                            description = string.format('+%d Armor', armorPerKill),
                            type = 'success',
                            duration = 2000
                        })
                        
                        -- Verify armor was set (re-apply if needed immediately)
                        local verifyArmor = GetPedArmour(ped)
                        if verifyArmor ~= newArmor then
                            print(string.format("[Paintball] WARNING: Armor was immediately cleared! Expected: %d, Got: %d. Re-applying...", newArmor, verifyArmor))
                            SetPedArmour(ped, newArmor)
                            -- Try one more time after a frame
                            CreateThread(function()
                                Wait(0) -- Next frame
                                if GetPedArmour(ped) ~= newArmor then
                                    SetPedArmour(ped, newArmor)
                                    print(string.format("[Paintball] Re-applied armor to %d", newArmor))
                                end
                            end)
                        end
                    else
                        print("[Paintball] Armor per kill is 0 or not set")
                    end
                else
                    print(string.format("[Paintball] Health system is not 'armor' - current: %s", tostring(healthSystem)))
                end
            else
                print("[Paintball] Health system is not enabled")
            end
        else
            print(string.format("[Paintball] Kill event - Not in practice match. InMatch: %s, CurrentMatch exists: %s, gameMode: %s", 
                tostring(InMatch), tostring(CurrentMatch ~= nil), CurrentMatch and CurrentMatch.gameMode or 'nil'))
        end
    end
end)

-- Restore player state function (ensures everything is back to normal)
-- Comprehensive UI cleanup function for practice mode
local function CleanupPracticeUI()
    SendNUIMessage({ action = 'hidePracticeHUD' })
    SendNUIMessage({ action = 'hideScoreboard' })
    SendNUIMessage({ action = 'hideKillFeed' })
    SendNUIMessage({ action = 'hideHitMarker' })
    SendNUIMessage({ action = 'hideRoundReset' })
    SendNUIMessage({ action = 'hideRespawnCountdown' })
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end

local function RestorePlayerState()
    local ped = cache.ped
    
    -- ALWAYS heal and revive player when restoring state (returning to arena after paintball)
    if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
        local currentCoords = GetEntityCoords(ped)
        NetworkResurrectLocalPlayer(currentCoords.x, currentCoords.y, currentCoords.z, GetEntityHeading(ped), false, false)
        ClearPedBloodDamage(ped)
        SetEntityInvincible(ped, false)
    end
    
    -- Disable infinite ammo (always disable when not in match)
    SetPedInfiniteAmmo(ped, false)
    SetPedInfiniteAmmoClip(ped, false)
    
    -- Re-enable weapon autoswap FIRST (ox_inventory needs this)
    SetWeaponsNoAutoswap(false)
    
    -- Remove all paintball weapons first
    RemoveAllPedWeapons(ped, true)
    
    -- Re-enable ox_inventory weapon management
    if exports.ox_inventory then
        -- Close inventory first
        exports.ox_inventory:closeInventory()
        
        -- Reset all inventory states to allow full access
        LocalPlayer.state:set('invBusy', false, false)
        LocalPlayer.state:set('invHotkeys', true, false)
        LocalPlayer.state:set('canUseWeapons', true, false)
        
        -- Let ox_inventory restore weapons from inventory
        Wait(200)
        
        -- Force ox_inventory to refresh weapon state and re-equip weapons
        TriggerEvent('ox_inventory:refreshWeapon')
        
        -- Additional wait to ensure ox_inventory has time to process
        Wait(100)
    end
    
    -- Only restore if we have saved state (match was active)
    if SavedCoords or SavedHealth or SavedArmor or #SavedWeapons > 0 then
        -- Restore coordinates
        if SavedCoords then
            SetEntityCoords(ped, SavedCoords.x, SavedCoords.y, SavedCoords.z, false, false, false, true)
        end
        
        -- Always restore to full health after paintball (heal any injuries)
        SetEntityHealth(ped, 200) -- Full health
        ClearPedBloodDamage(ped)
        
        -- Restore armor
        if SavedArmor then
            SetPedArmour(ped, SavedArmor)
        end
        
        -- Restore weapons (only if ox_inventory is not available)
        if not exports.ox_inventory then
            Wait(200)
            for _, weapon in ipairs(SavedWeapons) do
                GiveWeaponToPed(ped, weapon.hash, weapon.ammo, false, true)
        end
    end
    
        -- Clear saved state
        SavedWeapons = {}
        SavedCoords = nil
        SavedHealth = nil
        SavedArmor = nil
    else
        -- No saved state, but ensure player is fully healed when at arena
        SetEntityHealth(ped, 200) -- Full health
        ClearPedBloodDamage(ped)
        SetEntityInvincible(ped, false)
    end
end

-- Cooldown after leaving practice mode to prevent UI from showing (must be declared before zone)
local PracticeExitCooldown = 0

-- Create interaction zone
lib.zones.sphere({
        coords = Config.ArenaLocation.coords,
        radius = Config.ArenaLocation.interactionRadius,
    debug = false,
    onEnter = function()
        -- CRITICAL: Don't show UI if we just left practice mode (cooldown period)
        local currentTime = GetGameTimer()
        if PracticeExitCooldown and PracticeExitCooldown > currentTime then
            -- Force hide any UI that might have shown
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            return
        end
        
        if InMatch then
            -- Don't show anything if in active match
            return
        elseif InLobby then
            -- Show lobby indicator if in lobby
            SendNUIMessage({
                action = 'showLobbyIndicator',
                match = CurrentMatch
            })
        else
            -- Show normal interaction prompt
            SendNUIMessage({
                action = 'showInteractionPrompt'
                })
            end
    end,
    inside = function()
        -- CRITICAL: Don't allow interaction if we just left practice mode (cooldown period)
        local currentTime = GetGameTimer()
        if PracticeExitCooldown and PracticeExitCooldown > currentTime then
            -- Force hide any UI that might have shown
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            return
        end
        
        if InMatch then
            -- Don't allow interaction during match
            return
        elseif InLobby then
            -- Allow returning to lobby
        if IsControlJustPressed(0, 38) then -- E key
                -- Return to lobby
                if CurrentMatch then
                    SendNUIMessage({
                        action = 'openLobby',
                        match = {
                            id = CurrentMatch.id,
                            host = CurrentMatch.host,
                            settings = CurrentMatch.settings,
                            teams = CurrentMatch.teams,
                            scores = CurrentMatch.scores,
                            status = CurrentMatch.status
                        },
                        isHost = CurrentMatch.host == cache.serverId,
                        playerServerId = cache.serverId
                    })
                    SetNuiFocus(true, true)
                    PaintballMenuOpen = true
                end
            end
        else
            -- Normal menu opening
        if IsControlJustPressed(0, 38) then -- E key
                -- Hide prompt and open menu instantly (no delays)
                SendNUIMessage({
                    action = 'hideInteractionPrompt'
                })
                -- Open menu immediately
                OpenLobbyMenu()
            end
        end
    end,
    onExit = function()
        -- Don't hide UI if we just left practice mode (cooldown period)
        local currentTime = GetGameTimer()
        if PracticeExitCooldown and PracticeExitCooldown > currentTime then
            return
        end
        
        SendNUIMessage({
            action = 'hideInteractionPrompt'
        })
        SendNUIMessage({
            action = 'hideLobbyIndicator'
        })
        
        -- If player is in a lobby (not in active match), automatically disband when they leave the interaction zone
        if InLobby and not InMatch and CurrentMatch then
            -- Notify player
            lib.notify({
                title = 'Lobby Disbanded',
                description = 'You left the arena area. Your lobby has been disbanded.',
                type = 'inform',
                duration = 3000
            })
            
            -- Leave the lobby
            InLobby = false
            InMatch = false
            CurrentMatch = nil
            
            -- Hide UI elements
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            PaintballMenuOpen = false
            
            -- Re-enable inventory
            if exports.ox_inventory then
                exports.ox_inventory:closeInventory()
                LocalPlayer.state:set('invBusy', false, false)
                LocalPlayer.state:set('invHotkeys', true, false)
                LocalPlayer.state:set('canUseWeapons', true, false)
                SetWeaponsNoAutoswap(false)
            end
            
            -- Notify server
            TriggerServerEvent('paintball:server:leaveLobby')
        end
    end
})
    


-- Open lobby menu
-- Send progression data and config to UI (no delays, immediate)
local function SendProgressionToUI()
    -- Request progression immediately (no waits, server sends instantly)
    if Config.EnableXPSystem or Config.EnableRankedPvP then
        TriggerServerEvent('paintball:server:getProgression')
    else
        -- Send empty data if systems disabled (immediate, no delay)
        SendNUIMessage({
            action = 'updateProgression',
            prestige = 0,
            prestigeLevel = 0,
            rank = 'Unranked',
            rankInsignia = '🎖️',
            level = 1,
            xp = 0,
            xpRequired = 1000,
            rankedRating = nil
        })
    end
    
    -- Send config flags immediately
    SendNUIMessage({
        action = 'updateConfig',
        enableRankedPvP = Config.EnableRankedPvP,
        enableXPSystem = Config.EnableXPSystem
    })
end

-- Track if any paintball menu is open
local PaintballMenuOpen = false
local MenuCooldown = 0 -- Cooldown to prevent rapid open/close

-- Helper function to get random spawn avoiding last spawn
local function GetRandomSpawn(spawnPoints, lastIndex)
    if not spawnPoints or #spawnPoints == 0 then
        return nil, nil
    end
    
    if #spawnPoints == 1 then
        return spawnPoints[1], 1
    end
    
    -- If we have multiple spawn points, avoid the last one
    local availableIndices = {}
    for i = 1, #spawnPoints do
        if i ~= lastIndex then
            table.insert(availableIndices, i)
        end
    end
    
    -- If all spawns were the same (shouldn't happen with 2+ spawns), just pick any
    if #availableIndices == 0 then
        availableIndices = {}
        for i = 1, #spawnPoints do
            table.insert(availableIndices, i)
        end
    end
    
    local randomIndex = availableIndices[math.random(#availableIndices)]
    return spawnPoints[randomIndex], randomIndex
end

function OpenLobbyMenu()
    -- Always update progression data when opening any menu
    SendProgressionToUI()
    
    -- Check cooldown to prevent rapid open/close
    local currentTime = GetGameTimer()
    if MenuCooldown > currentTime then
        return
    end
    
    -- Prevent opening if in match or lobby
    if InLobby or InMatch then
        return
    end
    
    -- Set cooldown (100ms - reduced for faster response)
    MenuCooldown = currentTime + 100
    
    -- If menu is already open, just ensure focus is set (don't reset)
    if PaintballMenuOpen then
        SetNuiFocus(true, true)
        return
    end
    
    -- Set NUI focus FIRST (before sending message for instant response)
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    -- Request active lobbies from server
    TriggerServerEvent('paintball:server:getActiveLobbies')
    
    -- Send progression data
    SendProgressionToUI()
    
    -- Open custom NUI menu immediately
    SendNUIMessage({
        action = 'openMainMenu'
        })
    end
    
-- Show game mode selection
function ShowGameModeSelection()
    -- Always update progression data when showing game mode selection
    SendProgressionToUI()
    
    -- Always ensure NUI focus is set (critical for menu interaction)
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    -- Prepare game modes data
    local gameModes = {}
    for _, mode in ipairs(Config.GameModes) do
        table.insert(gameModes, {
            id = mode.id,
            name = mode.name,
            description = mode.description
        })
    end
    
    -- Send to NUI
    SendNUIMessage({
        action = 'openGameModeMenu',
        gameModes = gameModes
    })
end

-- Show leaderboard
function ShowLeaderboard()
    TriggerServerEvent('paintball:server:getLeaderboard')
end

-- Events
RegisterNetEvent('paintball:client:joinedLobby', function(match)
    -- Reset state immediately
    InLobby = true
    InMatch = false
    CurrentMatch = match
    
    local matchData = {
        id = match.id,
        host = match.host,
        settings = match.settings,
        teams = {
            red = match.teams.red,
            blue = match.teams.blue
        },
        scores = match.scores,
        status = match.status,
        players = match.players,
        playerNames = match.playerNames or {} -- Use playerNames from server if available
    }
    
    -- If playerNames not in match, request them from server
    if not match.playerNames or not next(match.playerNames) then
        if match.players then
            for playerId, _ in pairs(match.players) do
                TriggerServerEvent('paintball:server:getPlayerName', playerId)
            end
        end
    end
    
    -- Send progression data when opening lobby (ensures correct prestige/XP display)
    SendProgressionToUI()
    
    -- Open lobby UI (this will show team selection)
    SendNUIMessage({
        action = 'openLobby',
        match = matchData,
        isHost = (match.host == cache.serverId)
    })
    
    -- Set NUI focus for lobby interaction
    SetNuiFocus(true, true)
    
    -- Send UI update immediately
    SendNUIMessage({
        action = 'openLobby',
        match = matchData,
        isHost = match.host == cache.serverId,
        playerServerId = cache.serverId
    })
    
    -- Set focus immediately
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
end)

-- Receive active lobbies for browser
RegisterNetEvent('paintball:client:receiveActiveLobbies', function(lobbies)
    SendNUIMessage({
        action = 'receiveActiveLobbies',
        lobbies = lobbies
    })
end)

-- Refresh lobbies when a new one is created
RegisterNetEvent('paintball:client:refreshLobbies', function()
    -- Refresh if menu is open (regardless of lobby/match status - they might want to see other lobbies)
    if PaintballMenuOpen then
        -- Send message to NUI to trigger immediate refresh
        SendNUIMessage({ action = 'refreshLobbies' })
        -- Also trigger server request
        TriggerServerEvent('paintball:server:getActiveLobbies')
    end
end)

-- Handle progression data updates from server
RegisterNetEvent('paintball:client:updateProgression', function(progressionData)
    -- Send progression data to NUI immediately (no waits, instant update)
    SendNUIMessage({
        action = 'updateProgression',
        prestige = progressionData.prestige or 0,
        prestigeLevel = progressionData.prestigeLevel or 0,
        prestigeTitle = progressionData.prestigeTitle,
        prestigeIcon = progressionData.prestigeIcon or "🛡️",
        rank = progressionData.rank or 'Unranked',
        rankInsignia = progressionData.rankInsignia or '🎖️',
        level = progressionData.level or 1,
        xp = progressionData.xp or 0,
        xpRequired = progressionData.xpRequired or 1000,
        totalXP = progressionData.totalXP or (progressionData.xp or 0), -- Include total XP
        rankedRating = progressionData.rankedRating
    })
end)

RegisterNetEvent('paintball:client:updateLobby', function(match)
    CurrentMatch = match
    
    -- Debug: Check if wager is in settings
    if match.settings then
        print(string.format("[Paintball] Client: Received lobby update, wager = %d", match.settings.wager or 0))
    else
        print("[Paintball] Client: WARNING - match.settings is nil!")
    end
    
    -- Send progression data when lobby updates (ensures correct prestige/XP display)
    SendProgressionToUI()
    
    local matchData = {
        id = match.id,
        host = match.host,
        settings = match.settings or {}, -- Ensure settings exists
        teams = {
            red = match.teams.red or {},
            blue = match.teams.blue or {}
        },
        scores = match.scores or {},
        status = match.status,
        players = match.players or {}, -- Include player data
        playerNames = match.playerNames or {} -- Include player names
    }
    
    -- Debug: Verify wager in matchData
    print(string.format("[Paintball] Client: Sending to NUI, wager = %d", matchData.settings.wager or 0))
    
    SendNUIMessage({
        action = 'updateLobby',
        match = matchData
    })
end)

-- Receive player name from server
RegisterNetEvent('paintball:client:playerName', function(playerId, playerName)
    if CurrentMatch and CurrentMatch.players then
        -- Update the match data with the player name
    SendNUIMessage({
            action = 'updatePlayerName',
            playerId = playerId,
            playerName = playerName
    })
    end
end)

RegisterNetEvent('paintball:client:startMatch', function(match)
    InLobby = false
    InMatch = true
    CurrentMatch = match
    
    -- Ensure gameMode is set correctly
    if not CurrentMatch.gameMode and CurrentMatch.settings then
        CurrentMatch.gameMode = CurrentMatch.settings.gameMode
    end
    
    -- Ensure player can roll, jump, and perform all movement actions
    local ped = cache.ped
    SetPedCanRagdoll(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    SetPedConfigFlag(ped, 281, false) -- Allow ragdoll
    SetPedResetFlag(ped, 240, false) -- Allow movement
    
    -- Debug: Print health system settings
    if CurrentMatch.settings then
        print(string.format("[Paintball] Match started - healthSystem: %s, healthSystemEnabled: %s, armorPerKill: %s, healthPerKill: %s",
            tostring(CurrentMatch.settings.healthSystem),
            tostring(CurrentMatch.settings.healthSystemEnabled),
            tostring(CurrentMatch.settings.armorPerKill),
            tostring(CurrentMatch.settings.healthPerKill)
        ))
    end
    
    -- Disable inventory opening during match using ox_inventory state system
    if exports.ox_inventory then
        exports.ox_inventory:closeInventory()
        -- Set player state to prevent inventory from opening
        LocalPlayer.state:set('invBusy', true, false)
        LocalPlayer.state:set('invHotkeys', false, false)
        -- Disable ox_inventory weapon management during match
        LocalPlayer.state:set('canUseWeapons', true, false)
        -- Clear any current weapon from ox_inventory immediately (no delay)
        TriggerEvent('ox_inventory:disarm', true)
        TriggerEvent('ox_inventory:clearWeapons')
        TriggerEvent('ox_inventory:disarm', true)
    end
    
    -- Disable inventory key (F2 or similar) and all inventory-related controls
    CreateThread(function()
        while InMatch and CurrentMatch and CurrentMatch.id == match.id do
            Wait(100) -- Reduced from 0 to 100ms - inventory checks don't need every frame
            -- Disable common inventory keys (but NOT Tab - that's for scoreboard)
            DisableControlAction(0, 289, true) -- F2 (common inventory key)
            DisableControlAction(0, 157, true) -- 1 key
            DisableControlAction(0, 158, true) -- 2 key
            DisableControlAction(0, 160, true) -- 3 key
            DisableControlAction(0, 164, true) -- 4 key
            DisableControlAction(0, 165, true) -- 5 key
            DisableControlAction(0, 11, true) -- K key (sometimes used for inventory)
            DisableControlAction(0, 172, true) -- Arrow up
            DisableControlAction(0, 173, true) -- Arrow down
            DisableControlAction(0, 174, true) -- Arrow left
            DisableControlAction(0, 175, true) -- Arrow right
            
            -- Block inventory opening attempts
            if exports.ox_inventory then
                if IsControlJustPressed(0, 289) or IsControlJustPressed(0, 11) then
                    exports.ox_inventory:closeInventory()
                end
                -- Try to close inventory (no need to check if open, just try to close)
                -- ox_inventory doesn't have isInventoryOpen export, so we just call closeInventory
                exports.ox_inventory:closeInventory()
            end
        end
    end)
    
    -- Reset last spawn index when match starts
    LastSpawnIndex = nil
    
    -- Teleport player to their assigned spawn point (for team matches and 1v1)
    -- NO DELAYS - instant spawn for smooth experience
    if match.playerSpawns and match.playerSpawns[cache.serverId] then
        local spawn = match.playerSpawns[cache.serverId]
        -- Instant teleport (no screen fade for smooth spawn)
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        SetEntityHeading(ped, spawn.w or 0.0)
        print(string.format("[Paintball] Teleported player to assigned spawn: %.2f, %.2f, %.2f", spawn.x, spawn.y, spawn.z))
    elseif match.settings.requiresTeams and match.players[cache.serverId] then
        -- Fallback: use team spawns if no assigned spawn (shouldn't happen but safety check)
        local team = match.players[cache.serverId].team
        if team and Config.ArenaSpawns.teamSpawns and #Config.ArenaSpawns.teamSpawns >= 2 then
            -- Randomly pick a spawn for this team (temporary fallback)
            local spawn = Config.ArenaSpawns.teamSpawns[team == 'red' and 1 or 2]
            -- Instant teleport (no screen fade for smooth spawn)
            SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
            SetEntityHeading(ped, spawn.w or 0.0)
            print(string.format("[Paintball] Fallback: Teleported %s team to spawn: %.2f, %.2f, %.2f", team, spawn.x, spawn.y, spawn.z))
        end
    end
    
    -- Setup team indicators and friendly fire prevention
    if match.settings.requiresTeams and match.players[cache.serverId] then
        local myTeam = match.players[cache.serverId].team
        local teamColor = myTeam == 'red' and 6 or 3 -- Cache team color
        CreateThread(function()
            while InMatch and CurrentMatch and CurrentMatch.id == match.id do
                Wait(250) -- Reduced from 0 to 250ms - team indicators don't need every frame
                -- Cache match players to avoid repeated table access
                local players = match.players
                if not players then break end
                
                -- Update team indicators for all players
                for playerId, playerData in pairs(players) do
                    if playerId ~= cache.serverId then
                        local playerIdx = GetPlayerFromServerId(playerId)
                        if playerIdx ~= -1 then
                            local targetPed = GetPlayerPed(playerIdx)
                        if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                            -- Set team color on name tag
                            if playerData.team == myTeam then
                                -- Same team - show in team color (red or blue)
                                    SetMpGamerTagVisibility(playerIdx, 0, true) -- Show name
                                    SetMpGamerTagColour(playerIdx, 0, teamColor)
                            else
                                -- Enemy team - show in default color
                                    SetMpGamerTagVisibility(playerIdx, 0, true)
                                    SetMpGamerTagColour(playerIdx, 0, 0) -- Default color
                end
                
                -- Disable friendly fire (prevent damage to same team)
                                if playerData.team == myTeam then
                                SetEntityCanBeDamaged(targetPed, false)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Re-enable damage for all players when match ends
            if match.players then
            for playerId, _ in pairs(match.players) do
                if playerId ~= cache.serverId then
                        local playerIdx = GetPlayerFromServerId(playerId)
                        if playerIdx ~= -1 then
                            local targetPed = GetPlayerPed(playerIdx)
                    if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                        SetEntityCanBeDamaged(targetPed, true)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Start AI Practice Mode if applicable
    if match.gameMode == 'practice' then
        -- Reset practice statistics
        PracticeStats = {
            kills = 0,
            deaths = 0,
            headshots = 0,
            shotsFired = 0,
            shotsHit = 0,
            killStreak = 0,
            bestStreak = 0,
            startTime = GetGameTimer(), -- GetGameTimer() returns milliseconds
            lastKillTime = 0
        }
        
        -- Teleport player to exact spawn location for practice mode
        local practiceSpawn = Config.AIPractice.spawnLocation
        
        -- Preload collision at spawn location to prevent freeze
        RequestCollisionAtCoord(practiceSpawn.x, practiceSpawn.y, practiceSpawn.z)
        
        -- Ensure player is not frozen
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        
        -- Instant teleport (no delays)
        SetEntityCoords(ped, practiceSpawn.x, practiceSpawn.y, practiceSpawn.z, false, false, false, true)
        SetEntityHeading(ped, practiceSpawn.w)
        
        -- Ensure player can move immediately
        SetPlayerControl(PlayerId(), true, 0)
        
        -- Start AI practice in a thread so it doesn't block
        CreateThread(function()
            -- Routing bucket is handled server-side in StartMatch
            exports.paintball:StartAIPractice(match)
        end)
        
        -- Show practice HUD
    SendNUIMessage({
            action = 'showPracticeHUD',
            match = match
        })
        
        -- Start HUD update thread
        CreateThread(function()
            while InMatch and CurrentMatch and CurrentMatch.gameMode == 'practice' do
                Wait(1000)
                -- GetGameTimer() returns milliseconds, convert to seconds
                local elapsed = math.floor((GetGameTimer() - PracticeStats.startTime) / 1000)
                local minutes = math.floor(elapsed / 60)
                local seconds = elapsed % 60
                local timeStr = string.format('%02d:%02d', minutes, seconds)
                
                local accuracy = 0
                if PracticeStats.shotsFired > 0 then
                    accuracy = math.floor((PracticeStats.shotsHit / PracticeStats.shotsFired) * 100)
                end
                
                local remainingBots = 0
                if match.settings.botCountEnabled ~= false and match.settings.botCount then
                    remainingBots = math.max(0, match.settings.botCount - PracticeStats.kills)
                end
                
    SendNUIMessage({
                    action = 'updatePracticeHUD',
                    kills = PracticeStats.kills,
                    remaining = remainingBots,
                    time = timeStr,
                    accuracy = accuracy,
                    streak = PracticeStats.killStreak
                })
            end
        end)
        
        -- Show practice mode info
        lib.notify({
            title = 'Practice Mode Started',
            description = 'Good luck! Check the HUD for your stats.',
            type = 'success',
            duration = 5000
        })
    end
    
    -- Save player state
    SavedCoords = GetEntityCoords(cache.ped)
    SavedHealth = GetEntityHealth(cache.ped)
    SavedArmor = GetPedArmour(cache.ped)
    
    -- Apply health system settings (for practice mode)
    if match.gameMode == 'practice' and match.settings then
        local healthSystem = match.settings.healthSystem or 'standard'
        local healthSystemEnabled = match.settings.healthSystemEnabled or false
        
        if healthSystemEnabled then
            -- Armor system: give initial armor if enabled
            if healthSystem == 'armor' then
                -- Start with 0 armor, it will be given per kill
                SetPedArmour(cache.ped, 0)
            else
                -- No armor for other systems
                SetPedArmour(cache.ped, 0)
            end
            -- Health system: start with full health (will be restored per kill if enabled)
            if healthSystem == 'health_per_kill' then
                -- Start with full health, it will be restored per kill
                SetEntityHealth(cache.ped, 200)
            end
        else
            -- Default: no armor for paintball
            SetPedArmour(cache.ped, 0)
        end
    else
        -- Remove armor for regular paintball matches (health only, no armor)
        SetPedArmour(cache.ped, 0)
    end
    
    -- Save weapons
    SavedWeapons = {}
    local ped = cache.ped
    for i = 0, 2 do
        local weaponHash = GetSelectedPedWeapon(ped)
        if weaponHash ~= `WEAPON_UNARMED` then
            local ammo = GetAmmoInPedWeapon(ped, weaponHash)
            table.insert(SavedWeapons, {
                hash = weaponHash,
                ammo = ammo
            })
        end
    end
    
    -- Determine which weapon to give BEFORE removing weapons
    local weaponHash = nil
    if match.gameMode == 'gungame' then
        local gunGameLevel = match.gunGameLevels[cache.serverId] or 1
        weaponHash = GetHashKey(Config.GunGameWeapons[gunGameLevel])
    else
        -- Get weapon from match settings (for both practice and regular matches)
        local weaponName = match.settings.weapon or Config.MatchSettings.defaultWeapon
        weaponHash = GetHashKey(weaponName)
    end
    
    -- Disable ox_inventory weapon management and give weapon immediately
    if exports.ox_inventory then
        -- Disarm ox_inventory first (no delay)
        TriggerEvent('ox_inventory:disarm', true)
    end
    
    -- Remove all weapons and attachments immediately (no waits)
    RemoveAllPedWeapons(ped, true)
    RemoveAllPedWeapons(ped, true)
    
    -- Give weapon immediately (not in a thread so it happens right away)
    if weaponHash and weaponHash ~= 0 then
        -- Give the weapon - let game use weapon's natural clip size
    GiveWeaponToPed(ped, weaponHash, 999, false, true)
        
        -- Set total ammo (reserves) - infinite stock
        SetPedAmmo(ped, weaponHash, 999)
        
        -- Set as current weapon immediately (multiple times to ensure it works)
        SetCurrentPedWeapon(ped, weaponHash, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
    SetCurrentPedWeapon(ped, weaponHash, true)
    
        -- Disable infinite ammo so clip depletes naturally (but keep reserves high)
        SetPedInfiniteAmmo(ped, false)
        SetWeaponsNoAutoswap(true)
        
        -- Ensure clip is full (do this in a thread so it doesn't block)
        CreateThread(function()
            Wait(0) -- No delay - instant
            if InMatch and CurrentMatch and CurrentMatch.id == match.id then
                local maxClipSize = 30 -- Default fallback
                if DoesEntityExist(ped) and weaponHash and weaponHash ~= 0 then
                    local success, result = pcall(function()
                        return GetMaxAmmoInClip(ped, weaponHash, true)
                    end)
                    if success then
                        maxClipSize = result
                    end
                    if maxClipSize == 0 then
                        local success2, result2 = pcall(function()
                            local _, maxAmmo = GetMaxAmmo(ped, weaponHash)
                            return maxAmmo
                        end)
                        if success2 and result2 then
                            maxClipSize = result2 > 0 and result2 or 30
                        end
                    end
                end
                local currentClipAmmo = GetAmmoInClip(ped, weaponHash)
                if currentClipAmmo and type(currentClipAmmo) == 'number' and currentClipAmmo < maxClipSize then
                    local missingAmmo = maxClipSize - currentClipAmmo
                    AddAmmoToPed(ped, weaponHash, missingAmmo)
                end
            end
        end)
        
        -- Verify weapon is equipped (in a thread so it doesn't block)
        CreateThread(function()
            Wait(0) -- No delay - instant verification
            if InMatch and CurrentMatch and CurrentMatch.id == match.id then
                local currentWeapon = GetSelectedPedWeapon(ped)
                if currentWeapon ~= weaponHash then
                    -- Force equip the correct weapon
                    RemoveAllPedWeapons(ped, true)
                    GiveWeaponToPed(ped, weaponHash, 999, false, true)
                    SetPedAmmo(ped, weaponHash, 999) -- Infinite reserves
                    SetCurrentPedWeapon(ped, weaponHash, true)
                    SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes
                    SetWeaponsNoAutoswap(true)
                    SetCurrentPedWeapon(ped, weaponHash, true)
                end
            end
        end)
    else
        -- Fallback to default weapon if weapon hash is invalid
        lib.notify({
            title = 'Paintball',
            description = 'Invalid weapon selected, using default',
            type = 'error'
        })
        weaponHash = GetHashKey(Config.MatchSettings.defaultWeapon)
        local maxClipSize = 30 -- Default fallback
        if DoesEntityExist(ped) and weaponHash and weaponHash ~= 0 then
            local success, result = pcall(function()
                return GetMaxAmmoInClip(ped, weaponHash, true)
            end)
            if success then
                maxClipSize = result
            end
            if maxClipSize == 0 then
                local success2, result2 = pcall(function()
                    local _, maxAmmo = GetMaxAmmo(ped, weaponHash)
                    return maxAmmo
                end)
                if success2 and result2 then
                    maxClipSize = result2 > 0 and result2 or 30
                end
            end
        end
        RemoveAllPedWeapons(ped, true)
        Wait(50)
        GiveWeaponToPed(ped, weaponHash, 999, false, true)
        SetPedAmmo(ped, weaponHash, 999)
        SetAmmoInClip(ped, weaponHash, maxClipSize)
        SetCurrentPedWeapon(ped, weaponHash, true)
        SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes
    end
    
    -- Don't use SetPedInfiniteAmmoClip - this allows reloading while still having infinite ammo
    -- Infinite ammo is already set above when giving weapon
    
    -- Create thread to maintain ammo, weapon, and prevent ox_inventory interference
    CreateThread(function()
        -- Determine correct weapon hash once
        local correctWeaponHash = nil
        if match.gameMode == 'gungame' then
            local gunGameLevel = match.gunGameLevels[cache.serverId] or 1
            correctWeaponHash = GetHashKey(Config.GunGameWeapons[gunGameLevel])
        else
            local weaponName = match.settings.weapon or Config.MatchSettings.defaultWeapon
            correctWeaponHash = GetHashKey(weaponName)
        end
        
        -- Disable weapon autoswap to prevent ox_inventory from switching weapons
        SetWeaponsNoAutoswap(true)
        
        -- Get weapon's natural max clip size first (with safety checks to prevent native errors)
        local maxClipSize = 30 -- Default fallback
        if DoesEntityExist(ped) and correctWeaponHash and correctWeaponHash ~= 0 then
            local success, result = pcall(function()
                return GetMaxAmmoInClip(ped, correctWeaponHash, true)
            end)
            if success then
                maxClipSize = result
            end
            if maxClipSize == 0 then
                -- Some weapons (like melee) don't have clips, use total ammo instead
                local success2, result2 = pcall(function()
                    local _, maxAmmo = GetMaxAmmo(ped, correctWeaponHash)
                    return maxAmmo
                end)
                if success2 and result2 then
                    maxClipSize = result2 > 0 and result2 or 30
                else
                    maxClipSize = 30 -- Default fallback
                end
            end
        end
        
        -- Check if weapon is already given (from startMatch function)
        -- No wait - check immediately
        local currentWeapon = GetSelectedPedWeapon(ped)
        if currentWeapon ~= correctWeaponHash then
            -- Weapon not given yet or wrong weapon, give it now
            RemoveAllPedWeapons(ped, true)
            Wait(50)
            GiveWeaponToPed(ped, correctWeaponHash, 999, false, true)
            SetPedAmmo(ped, correctWeaponHash, 999) -- Set total ammo (reserves) - infinite stock
            SetCurrentPedWeapon(ped, correctWeaponHash, true)
            SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes naturally
            SetWeaponsNoAutoswap(true)
            
            -- Ensure clip starts at full capacity
            Wait(100)
            local currentClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
            if currentClipAmmo < maxClipSize then
                local missingAmmo = maxClipSize - currentClipAmmo
                AddAmmoToPed(ped, correctWeaponHash, missingAmmo)
            end
        else
            -- Weapon already given, just ensure settings are correct
            SetPedAmmo(ped, correctWeaponHash, 999) -- Ensure infinite reserves
            SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes naturally
            SetWeaponsNoAutoswap(true)
            
            -- Ensure clip is full
            Wait(100)
            local currentClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
            if currentClipAmmo and type(currentClipAmmo) == 'number' and currentClipAmmo < maxClipSize then
                local missingAmmo = maxClipSize - currentClipAmmo
                AddAmmoToPed(ped, correctWeaponHash, missingAmmo)
            end
        end
        
        local isReloading = false
        local lastClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
        if not lastClipAmmo or type(lastClipAmmo) ~= 'number' then
            lastClipAmmo = 0
        end
        
        -- Track shots fired for accuracy
        local lastAmmo = GetAmmoInClip(ped, correctWeaponHash)
        if not lastAmmo or type(lastAmmo) ~= 'number' then
            lastAmmo = 0
        end
        
        -- Hit detection thread for visual feedback
        CreateThread(function()
            local lastHitTime = 0
            local cachedAIPeds = {} -- Cache AI peds to avoid repeated table access
            while InMatch and CurrentMatch and CurrentMatch.id == match.id do
                Wait(50) -- Reduced from 0 to 50ms - hit detection doesn't need every frame
                
                -- Check if player is shooting
                if IsPedShooting(ped) then
                    -- Check for hits on nearby entities (AI bots or players)
                    local playerCoords = GetEntityCoords(ped)
                    local hit, endCoords = GetPedLastWeaponImpactCoord(ped)
                    
                    if hit then
                        -- Only check nearby peds when we actually have a hit
                    local nearbyPeds = GetGamePool('CPed')
                        local currentTime = GetGameTimer()
                        
                        -- Only process if enough time has passed since last hit marker
                        if currentTime - lastHitTime > 100 then
                            -- Cache AI peds if in practice mode
                            if match.gameMode == 'practice' and AIPeds then
                                cachedAIPeds = {}
                                for aiPed, _ in pairs(AIPeds) do
                                    cachedAIPeds[aiPed] = true
                                end
                            end
                            
                            -- Check only nearby peds (within reasonable distance)
                    for _, targetPed in ipairs(nearbyPeds) do
                        if targetPed ~= ped and DoesEntityExist(targetPed) then
                                    local targetCoords = GetEntityCoords(targetPed)
                                    local distance = #(playerCoords - targetCoords)
                                    
                                    -- Only check if target is close enough
                                    if distance < 100.0 then
                                        local hitDistance = #(endCoords - targetCoords)
                                        if hitDistance < 2.0 then -- Hit within 2 units
                                            -- Check if this is a valid target
                            local isTarget = false
                            if match.gameMode == 'practice' then
                                                -- Check if it's one of our AI bots (use cached lookup)
                                                isTarget = cachedAIPeds[targetPed] == true
                            else
                                -- Check if it's an enemy player
                                local targetPlayer = NetworkGetPlayerIndexFromPed(targetPed)
                                if targetPlayer ~= -1 then
                                    local targetServerId = GetPlayerServerId(targetPlayer)
                                    if targetServerId and CurrentMatch.players[targetServerId] then
                                        local targetTeam = CurrentMatch.players[targetServerId].team
                                        local playerTeam = CurrentMatch.players[cache.serverId] and CurrentMatch.players[cache.serverId].team
                                        if targetTeam and playerTeam and targetTeam ~= playerTeam then
                                            isTarget = true
                                        end
                                    end
                                end
                            end
                            
                            if isTarget then
                                                -- Check for headshot
                                                local boneIndex = GetPedBoneIndex(targetPed, 31086) -- Head bone
                                                local isHeadshot = false
                                                if boneIndex ~= -1 then
                                                    local boneCoords = GetWorldPositionOfEntityBone(targetPed, boneIndex)
                                                    local headDistance = #(endCoords - boneCoords)
                                                    if headDistance < 0.3 then
                                                        isHeadshot = true
                                                    end
                                                end
                                                
                                                -- Show hit marker
                                                SendNUIMessage({
                                                    action = 'showHitMarker',
                                                    headshot = isHeadshot
                                                })
                                                
                                                -- Play hit sound
                                                if isHeadshot then
                                                    PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", true)
                                                else
                                                    PlaySoundFrontend(-1, "HACKING_SUCCESS", "HACKING_SOUNDSET", true)
                                                end
                                                
                                                lastHitTime = currentTime
                                                break -- Found a hit, no need to check more peds
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        -- Cache ox_inventory state to avoid repeated checks
        local hasOxInventory = exports.ox_inventory ~= nil
        local lastAmmoCheck = 0
        while InMatch and CurrentMatch and CurrentMatch.id == match.id do
            Wait(0) -- Check every frame for zero glitching - weapon stability is critical
            
            local currentWeapon = GetSelectedPedWeapon(ped)
            
            -- CRITICAL: Maintain ox_inventory states FIRST (before weapon check) to prevent interference
            if hasOxInventory then
                LocalPlayer.state:set('invBusy', true, false)
                LocalPlayer.state:set('invHotkeys', false, false)
                LocalPlayer.state:set('canUseWeapons', false, false)
                
                -- Aggressively block ox_inventory from managing weapons
                local oxWeapon = exports.ox_inventory:getCurrentWeapon()
                if oxWeapon then
                    TriggerEvent('ox_inventory:disarm', true)
                    TriggerEvent('ox_inventory:clearWeapons')
                end
            end
            
            -- Always ensure the correct weapon is equipped - CRITICAL: Check every frame
            if currentWeapon ~= correctWeaponHash then
                -- Aggressively disable ox_inventory interference when re-equipping
                if exports.ox_inventory then
                    TriggerEvent('ox_inventory:disarm', true)
                    TriggerEvent('ox_inventory:clearWeapons')
                end
                
                -- Weapon is wrong or missing, force equip immediately (every frame until correct)
                RemoveAllPedWeapons(ped, true)
                GiveWeaponToPed(ped, correctWeaponHash, 999, false, true)
                SetPedAmmo(ped, correctWeaponHash, 999) -- Infinite reserves
                SetCurrentPedWeapon(ped, correctWeaponHash, true)
                SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes naturally
                SetWeaponsNoAutoswap(true)
                
                -- Verify weapon was actually equipped (double-check to prevent glitching)
                local verifyWeapon = GetSelectedPedWeapon(ped)
                if verifyWeapon ~= correctWeaponHash then
                    -- Still wrong, force again more aggressively
                    RemoveAllPedWeapons(ped, true)
                    GiveWeaponToPed(ped, correctWeaponHash, 999, false, true)
                    SetCurrentPedWeapon(ped, correctWeaponHash, true)
                end
                -- Don't use SetPedCanSwitchWeapon as it might block manual reload
                -- Update max clip size (with safety checks to prevent native errors)
                if DoesEntityExist(ped) and correctWeaponHash and correctWeaponHash ~= 0 then
                    local success, result = pcall(function()
                        return GetMaxAmmoInClip(ped, correctWeaponHash, true)
                    end)
                    if success then
                        maxClipSize = result
                    else
                        maxClipSize = 0
                    end
                    if maxClipSize == 0 then
                        local success2, result2 = pcall(function()
                            local _, maxAmmo = GetMaxAmmo(ped, correctWeaponHash)
                            return maxAmmo
                        end)
                        if success2 and result2 then
                            maxClipSize = result2 > 0 and result2 or 30
                        else
                            maxClipSize = 30 -- Default fallback
                        end
                    end
                else
                    maxClipSize = 30 -- Default fallback if ped or weapon invalid
                end
                isReloading = false
                lastClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
                if not lastClipAmmo or type(lastClipAmmo) ~= 'number' then
                    lastClipAmmo = 0
                end
            else
                -- Weapon is correct - but still check every frame to prevent any glitching
                -- Only do expensive operations (ammo tracking) less frequently to save performance
                local currentTime = GetGameTimer()
                if currentTime - lastAmmoCheck > 50 then
                    lastAmmoCheck = currentTime
                    
                    -- Track shots fired (ammo decreased = shot fired) - only check every 50ms
                    local currentAmmo = GetAmmoInClip(ped, correctWeaponHash)
                    if currentAmmo and type(currentAmmo) == 'number' and lastAmmo and type(lastAmmo) == 'number' then
                        if currentAmmo < lastAmmo then
                            -- Ammo decreased, shot was fired
                            if PracticeStats then
                                PracticeStats.shotsFired = PracticeStats.shotsFired + 1
                            end
                        end
                        lastAmmo = currentAmmo
                    end
                end
                
                -- Weapon is correct, manage realistic ammo system
                local currentClipAmmo = GetAmmoInClip(ped, currentWeapon)
                if not currentClipAmmo or type(currentClipAmmo) ~= 'number' then
                    currentClipAmmo = 0
                end
                
                -- Update max clip size if weapon changed (for gun game)
                if match.gameMode == 'gungame' then
                    local gunGameLevel = match.gunGameLevels[cache.serverId] or 1
                    local newWeaponHash = GetHashKey(Config.GunGameWeapons[gunGameLevel])
                    if newWeaponHash ~= correctWeaponHash then
                        correctWeaponHash = newWeaponHash
                        -- Update max clip size (with safety checks to prevent native errors)
                        if DoesEntityExist(ped) and correctWeaponHash and correctWeaponHash ~= 0 then
                            local success, result = pcall(function()
                                return GetMaxAmmoInClip(ped, correctWeaponHash, true)
                            end)
                            if success then
                                maxClipSize = result
                            else
                                maxClipSize = 0
                            end
                            if maxClipSize == 0 then
                                local success2, result2 = pcall(function()
                                    local _, maxAmmo = GetMaxAmmo(ped, correctWeaponHash)
                                    return maxAmmo
                                end)
                                if success2 and result2 then
                                    maxClipSize = result2 > 0 and result2 or 30
                                else
                                    maxClipSize = 30 -- Default fallback
                                end
                            end
                        else
                            maxClipSize = 30 -- Default fallback if ped or weapon invalid
                        end
                        lastClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
                        if not lastClipAmmo or type(lastClipAmmo) ~= 'number' then
                            lastClipAmmo = 0
                        end
                    end
                end
                
                -- Prevent auto-reload: if clip is empty and player tries to shoot, prevent it
                -- But allow manual reload (R key) to work
                local clipAmmo = GetAmmoInClip(ped, currentWeapon)
                if not clipAmmo or type(clipAmmo) ~= 'number' then
                    clipAmmo = 0
                end
                local isTryingToShoot = IsControlPressed(0, 24) -- Left mouse / shoot
                
                -- If clip is empty and trying to shoot, prevent shooting to force manual reload
                if clipAmmo == 0 and isTryingToShoot and not IsPedReloading(ped) then
                    -- Clip is empty and player is trying to shoot (which would trigger auto-reload)
                    -- Prevent shooting to force manual reload
                    DisablePlayerFiring(PlayerId(), true)
                end
                
                -- Track ammo changes and handle manual reloads
                if currentClipAmmo > 0 and currentClipAmmo < lastClipAmmo then
                    -- Ammo decreased (player shot), update tracking
                    lastClipAmmo = currentClipAmmo
                    isReloading = false
                    -- Shot tracking is handled above in the main loop
                elseif IsPedReloading(ped) and not isReloading then
                    -- Player started reloading manually (R key pressed)
                    isReloading = true
                elseif isReloading and not IsPedReloading(ped) then
                    -- Reload animation completed - refill clip to full capacity
                    CreateThread(function()
                        Wait(300) -- Wait for reload animation to fully complete
                        if InMatch and CurrentMatch and CurrentMatch.id == match.id and GetSelectedPedWeapon(ped) == correctWeaponHash then
                            -- Ensure infinite reserves
                            SetPedAmmo(ped, correctWeaponHash, 999)
                            
                            -- Get current clip ammo and refill to max
                            local clipAmmo = GetAmmoInClip(ped, correctWeaponHash)
                            if not clipAmmo or type(clipAmmo) ~= 'number' then
                                clipAmmo = 0
                            end
                            local missingAmmo = maxClipSize - clipAmmo
                            
                            if missingAmmo > 0 then
                                -- Use AddAmmoToPed to refill clip (respects clip size)
                                AddAmmoToPed(ped, correctWeaponHash, missingAmmo)
                                
                                -- Verify it worked
                                Wait(100)
                                local finalClip = GetAmmoInClip(ped, correctWeaponHash)
                                if not finalClip or type(finalClip) ~= 'number' then
                                    finalClip = 0
                                end
                                if finalClip < maxClipSize then
                                    -- Force refill if still not full
                                    local stillMissing = maxClipSize - finalClip
                                    AddAmmoToPed(ped, correctWeaponHash, stillMissing)
                                end
                            end
                        end
                    end)
                    lastClipAmmo = GetAmmoInClip(ped, correctWeaponHash)
                    if not lastClipAmmo or type(lastClipAmmo) ~= 'number' then
                        lastClipAmmo = 0
                    end
                    isReloading = false
                elseif currentClipAmmo == maxClipSize and lastClipAmmo < maxClipSize and not IsPedReloading(ped) then
                    -- Clip was just refilled (reload completed), update tracking
                    lastClipAmmo = maxClipSize
                    isReloading = false
                end
                
                -- Keep reserves infinite for reloading (only update if reserves are low to avoid interfering with clip)
                local currentReserves = GetAmmoInPedWeapon(ped, currentWeapon)
                if currentReserves and currentReserves < 500 then
                    SetPedAmmo(ped, currentWeapon, 999) -- Infinite stock (999 reserves)
                end
                SetPedInfiniteAmmo(ped, false) -- Disable infinite ammo so clip depletes naturally
                
                -- Only clear armor if health system is not enabled or not set to armor
                if CurrentMatch and CurrentMatch.gameMode == 'practice' and CurrentMatch.settings then
                    local healthSystem = CurrentMatch.settings.healthSystem
                    local healthSystemEnabled = CurrentMatch.settings.healthSystemEnabled or false
                    
                    -- Only clear armor if health system is not enabled or not set to armor
                    if not healthSystemEnabled or healthSystem ~= 'armor' then
                        if GetPedArmour(ped) > 0 then
                            SetPedArmour(ped, 0)
                        end
                    end
                    -- If armor system is enabled, don't clear it - let it persist
                else
                    -- For non-practice matches, clear armor
                    if GetPedArmour(ped) > 0 then
                        SetPedArmour(ped, 0)
                    end
                end
            end
            
            -- Continuously disable ox_inventory weapon management (moved to main loop above for better performance)
        end
        
        -- Re-enable weapon autoswap when leaving match
        SetWeaponsNoAutoswap(false)
    end)
    
    -- Teleport to arena spawn
    local spawn = nil
    local spawnIndex = nil
    
    -- Count total players to detect 1v1
    local totalPlayers = 0
    if match.players then
        for _ in pairs(match.players) do
            totalPlayers = totalPlayers + 1
        end
    end
    
    -- Check if it's a 1v1 match (FFA with 2 players or any mode with 2 players)
    local isOneVOne = (totalPlayers == 2) and (match.gameMode == 'ffa' or match.gameMode == 'gungame' or not match.settings.requiresTeams)
    
    -- For practice mode, spawn at AI location (exact coordinates, no offset)
    if match.gameMode == 'practice' then
        local baseSpawn = Config.AIPractice.spawnLocation
        -- Spawn player at the exact spawn location (no random offset)
        spawn = vector4(
            baseSpawn.x,
            baseSpawn.y,
            baseSpawn.z,
            baseSpawn.w
        )
        spawnIndex = nil -- Don't track for practice mode
        print(string.format("[Paintball] Player spawning at practice location: %.2f, %.2f, %.2f", spawn.x, spawn.y, spawn.z))
    elseif match.playerSpawns and match.playerSpawns[cache.serverId] then
        -- Use assigned spawn point for this player (from match start) - works for both team matches and 1v1
        spawn = match.playerSpawns[cache.serverId]
        spawnIndex = nil -- Don't track for fixed spawns
        print(string.format("[Paintball] Player spawning at assigned spawn: %.2f, %.2f, %.2f", spawn.x, spawn.y, spawn.z))
    elseif match.gameMode == 'gungame' or not match.players[cache.serverId].team then
        local allSpawns = {}
        for _, sp in ipairs(Config.Teams.red.spawnPoints) do
            table.insert(allSpawns, sp)
        end
        for _, sp in ipairs(Config.Teams.blue.spawnPoints) do
            table.insert(allSpawns, sp)
        end
        if #allSpawns > 0 then
            spawn, spawnIndex = GetRandomSpawn(allSpawns, LastSpawnIndex)
            LastSpawnIndex = spawnIndex
        end
    else
    local team = match.players[cache.serverId].team
    local spawnPoints = Config.Teams[team].spawnPoints
    if spawnPoints and #spawnPoints > 0 then
            spawn, spawnIndex = GetRandomSpawn(spawnPoints, LastSpawnIndex)
            LastSpawnIndex = spawnIndex
        end
    end
    
    if spawn then
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        SetEntityHeading(ped, spawn.w)
    end
    
    -- Set health (no armor in paintball)
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    
    -- Close lobby UI (scoreboard will be shown with Tab key)
    SendNUIMessage({
        action = 'startMatch',
        match = match
    })
    SetNuiFocus(false, false)
    
    -- Hide scoreboard initially (will show when Tab is pressed)
    SendNUIMessage({
        action = 'hideScoreboard'
    })
end)

RegisterNetEvent('paintball:client:updateScoreboard', function(match)
    CurrentMatch = match
    
    -- Check if kill target is reached in practice mode
    if match.gameMode == 'practice' and match.settings then
        local killTarget = match.settings.killTarget or match.settings.maxScore
        local killTargetEnabled = match.settings.killTargetEnabled
        
        -- Only check kill target if it's enabled
        if killTargetEnabled and match.scores and match.scores.red and killTarget then
            if match.scores.red >= killTarget then
                -- Kill target reached - clear all bots and teleport back to lobby
                if exports.paintball then
                    exports.paintball:SetKillTargetReached(true)
                    -- Stop AI practice to clear all bots
                    exports.paintball:StopAIPractice()
                    
                    -- Teleport player back to arena entrance
                    CreateThread(function()
                        Wait(500) -- Small delay to ensure bots are cleared
                        local ped = cache.ped
                        local arenaCoords = Config.ArenaLocation.coords
                        SetEntityCoords(ped, arenaCoords.x, arenaCoords.y, arenaCoords.z, false, false, false, true)
                        
                        -- Revive player if dead
                        if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                            NetworkResurrectLocalPlayer(arenaCoords.x, arenaCoords.y, arenaCoords.z, GetEntityHeading(ped), false, false)
                            ClearPedBloodDamage(ped)
                            SetEntityInvincible(ped, false)
                            SetEntityHealth(ped, 200)
                        end
                        
                        -- Restore player state
                        RestorePlayerState()
                        
                        -- Re-enable inventory
                        if exports.ox_inventory then
                            exports.ox_inventory:closeInventory()
                            LocalPlayer.state:set('invBusy', false, false)
                            LocalPlayer.state:set('invHotkeys', true, false)
                            LocalPlayer.state:set('canUseWeapons', true, false)
                            
                            -- Re-enable weapon autoswap
                            SetWeaponsNoAutoswap(false)
                            
                            -- Force ox_inventory to refresh weapon state
                            Wait(100)
                            TriggerEvent('ox_inventory:refreshWeapon')
                        end
                        
                        -- Show win notification
                        lib.notify({
                            title = 'Practice Mode Complete!',
                            description = string.format('You reached %d kills! Returning to lobby...', killTarget),
                            type = 'success',
                            duration = 5000
                        })
                        
                        -- Reset match state
                        InMatch = false
                        InLobby = false
                        CurrentMatch = nil
                        
                        -- Trigger server to end match
                        TriggerServerEvent('paintball:server:leaveLobby')
                    end)
                end
            end
        end
    end
    
    -- Include vote status and player ID in match data
    local matchData = {
        id = match.id,
        host = match.host,
        settings = match.settings,
        gameMode = match.gameMode,
        gameModeName = match.gameModeName,
        teams = match.teams,
        scores = match.scores,
        status = match.status,
        players = match.players,
        stats = match.stats,
        endVotes = match.endVotes or {},
        playerServerId = cache.serverId
    }
    
    SendNUIMessage({
        action = 'updateScoreboard',
        match = matchData
    })
end)

RegisterNetEvent('paintball:client:giveWeapon', function(weapon, level)
    local ped = cache.ped
    local weaponHash = GetHashKey(weapon)
    RemoveAllPedWeapons(ped, true)
    GiveWeaponToPed(ped, weaponHash, 999, false, true)
    SetCurrentPedWeapon(ped, weaponHash, true)
    SetPedAmmo(ped, weaponHash, 999) -- Ensure ammo is set
    -- Infinite ammo should already be enabled from startMatch
    
    lib.notify({
        title = 'Gun Game',
        description = ('Weapon upgraded to level %d!'):format(level),
        type = 'success'
    })
end)

RegisterNetEvent('paintball:client:respawn', function(match)
    local ped = cache.ped
    
    local spawn = nil
    local spawnIndex = nil
    
    -- Count total players to detect 1v1
    local totalPlayers = 0
    if match.players then
        for _ in pairs(match.players) do
            totalPlayers = totalPlayers + 1
        end
    end
    
    -- Check if it's a 1v1 match (FFA with 2 players or any mode with 2 players)
    local isOneVOne = (totalPlayers == 2) and (match.gameMode == 'ffa' or match.gameMode == 'gungame' or not match.settings.requiresTeams)
    
    -- For practice mode, spawn at exact AI location (no random offset)
    if match.gameMode == 'practice' then
        spawn = Config.AIPractice.spawnLocation
        spawnIndex = nil -- Don't track for practice mode
    elseif match.playerSpawns and match.playerSpawns[cache.serverId] then
        -- Use assigned spawn point for this player (from match start) - works for both team matches and 1v1
        spawn = match.playerSpawns[cache.serverId]
        spawnIndex = nil -- Don't track for fixed spawns
    elseif match.gameMode == 'gungame' or not match.players[cache.serverId].team then
        local allSpawns = {}
        for _, sp in ipairs(Config.Teams.red.spawnPoints) do
            table.insert(allSpawns, sp)
        end
        for _, sp in ipairs(Config.Teams.blue.spawnPoints) do
            table.insert(allSpawns, sp)
        end
        if #allSpawns > 0 then
            spawn, spawnIndex = GetRandomSpawn(allSpawns, LastSpawnIndex)
            LastSpawnIndex = spawnIndex
        end
    else
    local team = match.players[cache.serverId].team
    local spawnPoints = Config.Teams[team].spawnPoints
    if spawnPoints and #spawnPoints > 0 then
            spawn, spawnIndex = GetRandomSpawn(spawnPoints, LastSpawnIndex)
            LastSpawnIndex = spawnIndex
        end
    end
    
    if spawn then
        SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
        SetEntityHeading(ped, spawn.w)
    end
    
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    
    -- Remove all weapons and give match weapon (no attachments, default equipment only)
    RemoveAllPedWeapons(ped, true)
    
    -- Give match weapon based on game mode
    local weaponHash = nil
    if match.gameMode == 'gungame' then
        local gunGameLevel = match.gunGameLevels[cache.serverId] or 1
        weaponHash = GetHashKey(Config.GunGameWeapons[gunGameLevel])
    else
        weaponHash = GetHashKey(match.settings.weapon)
    end
    
    -- Give weapon - let game use weapon's natural clip size
    GiveWeaponToPed(ped, weaponHash, 999, false, true)
    SetPedAmmo(ped, weaponHash, 999) -- Set total ammo (reserves) - infinite stock
    SetCurrentPedWeapon(ped, weaponHash, true)
    
    -- Disable infinite ammo so clip depletes naturally (but keep reserves high for reloading)
    SetPedInfiniteAmmo(ped, false)
    SetWeaponsNoAutoswap(true)
    
    -- Ensure clip is full on respawn
    Wait(100)
    local maxClipSize = 30 -- Default fallback
    if DoesEntityExist(ped) and weaponHash and weaponHash ~= 0 then
        local success, result = pcall(function()
            return GetMaxAmmoInClip(ped, weaponHash, true)
        end)
        if success then
            maxClipSize = result
        end
        if maxClipSize == 0 then
            local success2, result2 = pcall(function()
                local _, maxAmmo = GetMaxAmmo(ped, weaponHash)
                return maxAmmo
            end)
            if success2 and result2 then
                maxClipSize = result2 > 0 and result2 or 30
            end
        end
    end
    local currentClipAmmo = GetAmmoInClip(ped, weaponHash)
    if not currentClipAmmo or type(currentClipAmmo) ~= 'number' then
        currentClipAmmo = 0
    end
    if currentClipAmmo < maxClipSize then
        local missingAmmo = maxClipSize - currentClipAmmo
        AddAmmoToPed(ped, weaponHash, missingAmmo)
    end
end)

-- Handle leaving match (before it ends)
RegisterNetEvent('paintball:client:leftMatch', function()
    local wasPractice = false
    if InMatch and CurrentMatch then
        wasPractice = CurrentMatch.gameMode == 'practice'
        
        -- Hide all UI elements when leaving practice
        if wasPractice then
            -- CRITICAL: Set cooldown FIRST before anything else
            PracticeExitCooldown = GetGameTimer() + 8000 -- 8 second cooldown
            
            CleanupPracticeUI()
            -- Release NUI focus completely
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            PaintballMenuOpen = false
            -- Send closeUI to ensure all UI elements are hidden
            SendNUIMessage({ action = 'closeUI' })
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
        end
        
        -- Stop AI Practice Mode if active (do this FIRST)
        if wasPractice then
            -- Force stop AI practice immediately
            exports.paintball:StopAIPractice()
            
            -- Additional cleanup pass after a short delay to catch any stragglers
            CreateThread(function()
                Wait(500)
                exports.paintball:StopAIPractice() -- Call again to be sure
            end)
            
            -- IMMEDIATELY revive player if dead (AI practice mode only)
            local ped = cache.ped
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                NetworkResurrectLocalPlayer(GetEntityCoords(ped).x, GetEntityCoords(ped).y, GetEntityCoords(ped).z, GetEntityHeading(ped), false, false)
                ClearPedBloodDamage(ped)
                SetEntityInvincible(ped, false)
                SetEntityHealth(ped, 200) -- Full health
            end
        end
        
        -- Re-enable inventory
        if exports.ox_inventory then
            exports.ox_inventory:closeInventory()
            LocalPlayer.state:set('invBusy', false, false)
            LocalPlayer.state:set('invHotkeys', true, false)
            LocalPlayer.state:set('canUseWeapons', true, false)
            
            -- Re-enable weapon autoswap
            SetWeaponsNoAutoswap(false)
            
            -- Force ox_inventory to refresh weapon state
            Wait(100)
            TriggerEvent('ox_inventory:refreshWeapon')
        end
        
        -- Restore everything back to normal
        RestorePlayerState()
        
        -- Teleport back to paintball entrance if in practice mode
        if wasPractice then
            local ped = cache.ped
            local arenaCoords = Config.ArenaLocation.coords
            
            -- Revive player BEFORE teleporting (if dead)
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                local currentCoords = GetEntityCoords(ped)
                NetworkResurrectLocalPlayer(currentCoords.x, currentCoords.y, currentCoords.z, GetEntityHeading(ped), false, false)
                ClearPedBloodDamage(ped)
                SetEntityInvincible(ped, false)
                SetEntityHealth(ped, 200)
            end
            
            -- Teleport to arena entrance
            SetEntityCoords(ped, arenaCoords.x, arenaCoords.y, arenaCoords.z, false, false, false, true)
            
            -- Immediately hide UI again after teleport (zone might trigger)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            Wait(100) -- Small delay after teleport
            
            -- Ensure player is still alive after teleport (AI practice mode only)
            if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
                NetworkResurrectLocalPlayer(arenaCoords.x, arenaCoords.y, arenaCoords.z, GetEntityHeading(ped), false, false)
                ClearPedBloodDamage(ped)
                SetEntityInvincible(ped, false)
                SetEntityHealth(ped, 200) -- Full health
            end
            
            -- Ensure player is fully alive and healthy
            SetEntityHealth(ped, 200)
            SetPedArmour(ped, 0)
            ClearPedBloodDamage(ped)
            SetEntityInvincible(ped, false)
        end
    end
    
    InMatch = false
    InLobby = false
    CurrentMatch = nil
    
    -- If was practice mode, ensure UI is completely closed
    if wasPractice then
        -- Cooldown should already be set, but ensure it's active
        if PracticeExitCooldown <= GetGameTimer() then
            PracticeExitCooldown = GetGameTimer() + 8000 -- 8 second cooldown
        end
        
        -- Final cleanup pass
        CleanupPracticeUI()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        PaintballMenuOpen = false
        
        -- Hide all UI elements
        SendNUIMessage({ action = 'hideInteractionPrompt' })
        SendNUIMessage({ action = 'hideLobbyIndicator' })
        SendNUIMessage({ action = 'closeUI' })
        
        -- Force hide UI elements multiple times to catch any that might show
        CreateThread(function()
            Wait(100)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            Wait(500)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            Wait(1000)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end)
    end
end)

-- Event to open main menu (used when lobby is disbanded by host)
RegisterNetEvent('paintball:client:openMainMenu', function()
    -- CRITICAL: Don't open main menu if player is in practice mode match
    if InMatch and CurrentMatch and CurrentMatch.gameMode == 'practice' then
        print("[Paintball] Blocked main menu open - player is in practice mode")
        return
    end
    
    -- Always update progression data when opening main menu
    SendProgressionToUI()
    
    -- Close any open UI first (instant, no delay)
    SendNUIMessage({ action = 'closeUI' })
    SetNuiFocus(false, false)
    PaintballMenuOpen = false
    
    -- Open main menu immediately (no wait, instant)
    SendNUIMessage({ action = 'openMainMenu' })
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    -- Hide interaction prompt
    SendNUIMessage({ action = 'hideInteractionPrompt' })
end)

RegisterNetEvent('paintball:client:endMatch', function(match, winner, winnerId)
    InMatch = false
    CurrentMatch = nil
    
    -- Always update progression data after match ends (XP may have changed)
    SendProgressionToUI()
    
    -- Stop AI Practice Mode if active
    if match.gameMode == 'practice' then
        exports.paintball:StopAIPractice()
        -- Hide all practice UI elements
        CleanupPracticeUI()
        -- Routing bucket reset is handled server-side in EndMatch
    end
    
    -- Comprehensive revival and teleport (like AI matches)
    CreateThread(function()
        local ped = cache.ped
        local arenaCoords = Config.ArenaLocation.coords
        
        -- Quick screen fade for smooth transition
        DoScreenFadeOut(150)
        Wait(150)
        
        -- Clear death status from any death system (wasabi_ambulance, etc.)
        TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
        TriggerEvent('wasabi_ambulance:customInjuryClear')
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
        
        -- INSTANT revival and teleport in one go (like AI mode)
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
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
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
        
        -- Teleport to arena entrance
        SetEntityCoords(ped, arenaCoords.x, arenaCoords.y, arenaCoords.z, false, false, false, true)
        
        -- Fade back in
        Wait(100)
        DoScreenFadeIn(500)
    end)
    
    -- Re-enable inventory using ox_inventory state system
    if exports.ox_inventory then
        exports.ox_inventory:closeInventory()
        -- Reset player state to allow inventory again
        LocalPlayer.state:set('invBusy', false, false)
        LocalPlayer.state:set('invHotkeys', true, false)
        LocalPlayer.state:set('canUseWeapons', true, false)
        
        -- Re-enable weapon autoswap
        SetWeaponsNoAutoswap(false)
        
        -- Force ox_inventory to refresh weapon state
        Wait(100)
        TriggerEvent('ox_inventory:refreshWeapon')
    end
    
    -- Restore everything back to normal
    RestorePlayerState()
    
    -- Hide any open UI (comprehensive cleanup)
    if match.gameMode == 'practice' then
        CleanupPracticeUI()
    else
        SendNUIMessage({ action = 'hideScoreboard' })
        SendNUIMessage({ action = 'hideRoundReset' })
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
    
    SendNUIMessage({
        action = 'endMatch',
        match = match,
        winner = winner,
        winnerId = winnerId
    })
end)

    -- Death handler (for non-practice modes)
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' and InMatch then
        local victim = args[1]
        local attacker = args[2]
        
        -- Skip if in practice mode (handled by AI script)
        if CurrentMatch and CurrentMatch.gameMode == 'practice' then
            return
        end
        
        if victim == cache.ped and attacker ~= cache.ped and attacker ~= 0 then
            if IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) <= 0 then
                local attackerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
                if attackerId and attackerId > 0 then
                    TriggerServerEvent('paintball:server:playerKilled', attackerId)
                end
                
                -- Show respawn countdown and respawn after 5 seconds
                CreateThread(function()
                    local respawnTime = 5
                    
                    -- Show countdown UI
                    SendNUIMessage({
                        action = 'showRespawnCountdown',
                        time = respawnTime
                    })
                    
                    -- Countdown loop
                    while respawnTime > 0 do
                        Wait(1000)
                        if not InMatch or not CurrentMatch then
                            -- Match ended, hide countdown
                            SendNUIMessage({ action = 'hideRespawnCountdown' })
                            return
                        end
                        respawnTime = respawnTime - 1
                        SendNUIMessage({
                            action = 'updateRespawnCountdown',
                            time = respawnTime
                        })
                    end
                    
                    -- Respawn after countdown
                    if InMatch and CurrentMatch then
                        SendNUIMessage({ action = 'hideRespawnCountdown' })
                                TriggerServerEvent('paintball:server:requestRespawn')
                            end
                        end)
                    end
                end
            end
end)

-- NUI Callbacks
-- Vote to end match (voteType: 'yes' or 'no')
RegisterNUICallback('voteEndMatch', function(data, cb)
    if not CurrentMatch or not InMatch then
        cb('error')
        return
    end
    
    local voteType = data.voteType
    if voteType ~= 'yes' and voteType ~= 'no' then
        cb('error')
        return
    end
    
    TriggerServerEvent('paintball:server:voteEndMatch', CurrentMatch.id, voteType)
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    local wasInLobby = InLobby
    local wasInMatch = InMatch
    
    -- CRITICAL: Release NUI focus MULTIPLE TIMES to ensure it's released
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false) -- Double call to ensure release
    SetNuiFocusKeepInput(false) -- Double call to ensure release
    PaintballMenuOpen = false
    
    -- DON'T reset InLobby or CurrentMatch - keep lobby state active
    -- Only reset InMatch (menu closed, but still in lobby)
    InMatch = false
    -- InLobby stays true, CurrentMatch stays set (lobby persists)
    
    -- Set cooldown to prevent immediate reopening
    MenuCooldown = GetGameTimer() + 200
    
    -- Re-enable inventory if was in match
    if wasInMatch and exports.ox_inventory then
        exports.ox_inventory:closeInventory()
        LocalPlayer.state:set('invBusy', false, false)
        LocalPlayer.state:set('invHotkeys', true, false)
        LocalPlayer.state:set('canUseWeapons', true, false)
        
        -- Re-enable weapon autoswap
        SetWeaponsNoAutoswap(false)
    end
    
    -- Send close message to UI
    SendNUIMessage({ action = 'closeUI' })
    
    -- If player was in a match, restore their state (safety check)
    if wasInMatch then
        RestorePlayerState()
    end
    
    -- DON'T leave lobby when just closing menu - lobby persists
    -- Only leave lobby when explicitly calling leaveLobby callback
    
    -- Show lobby indicator or interaction prompt if player is still in the zone (instant, no delay)
    if not InMatch and not PaintballMenuOpen then
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - Config.ArenaLocation.coords)
        if distance <= Config.ArenaLocation.interactionRadius then
            if InLobby and CurrentMatch then
                -- Show lobby indicator
                SendNUIMessage({
                    action = 'showLobbyIndicator',
                    match = CurrentMatch
                })
            else
                -- Show normal interaction prompt
                SendNUIMessage({
                    action = 'showInteractionPrompt'
                })
            end
        end
    end
    
    cb('ok')
end)

-- Safety thread to prevent stuck NUI focus (prevents freezing)
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        
        -- If NUI focus is active but no menu should be open, release it
        if not PaintballMenuOpen and not InLobby and not InMatch then
            -- Double-check and release NUI focus if stuck
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end
    end
end)

RegisterNUICallback('joinTeam', function(data, cb)
    TriggerServerEvent('paintball:server:joinTeam', data.matchId, data.team)
    cb('ok')
end)

RegisterNUICallback('refreshLobbies', function(data, cb)
    TriggerServerEvent('paintball:server:getActiveLobbies')
    cb('ok')
end)

RegisterNUICallback('joinLobby', function(data, cb)
    -- Respond immediately to prevent UI freeze
    cb('ok')
    
    -- Then trigger server event (non-blocking)
    if data.matchId then
        TriggerServerEvent('paintball:server:joinLobby', data.matchId)
    end
end)

RegisterNUICallback('leaveLobby', function(data, cb)
    local wasInMatch = InMatch
    local wasPractice = CurrentMatch and CurrentMatch.gameMode == 'practice'
    
    -- CRITICAL: Release NUI focus FIRST
    SetNuiFocus(false, false)
    
    -- If leaving practice mode, stop AI and teleport back immediately
    if wasPractice and exports.paintball then
        -- CRITICAL: Set cooldown FIRST before anything else to prevent UI from showing
        PracticeExitCooldown = GetGameTimer() + 8000 -- 8 second cooldown (longer to be safe)
        
        -- Clean up all UI immediately BEFORE teleport
        CleanupPracticeUI()
        SendNUIMessage({ action = 'hideInteractionPrompt' })
        SendNUIMessage({ action = 'hideLobbyIndicator' })
        SendNUIMessage({ action = 'closeUI' })
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        PaintballMenuOpen = false
        
        -- Stop AI practice immediately
        exports.paintball:StopAIPractice()
        
        -- Screen fade out
        DoScreenFadeOut(300)
        Wait(300)
        
        -- Teleport to arena entrance
        local ped = cache.ped
        local arenaCoords = Config.ArenaLocation.coords
        SetEntityCoords(ped, arenaCoords.x, arenaCoords.y, arenaCoords.z, false, false, false, true)
        SetEntityHeading(ped, arenaCoords.w or 0.0)
        
        -- Revive and heal player immediately
        if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
            NetworkResurrectLocalPlayer(arenaCoords.x, arenaCoords.y, arenaCoords.z, arenaCoords.w or 0.0, false, false)
        end
        
        -- Clear death status from various death systems
        -- CRITICAL: Only clear death status, don't let wasabi_ambulance trigger main menu
        if GetResourceState('wasabi_ambulance') == 'started' then
            -- Clear death status server-side first to prevent wasabi_ambulance from opening main menu
            TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
            -- Then trigger revive event (but we've already blocked main menu opening in openMainMenu handler)
            TriggerEvent('wasabi_ambulance:client:revive')
        end
        if GetResourceState('mythic_hospital') == 'started' then
            TriggerEvent('mythic_hospital:client:RemoveBleed')
            TriggerEvent('mythic_hospital:client:ResetLimbs')
        end
        
        -- Full heal and clear damage
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
        SetEntityInvincible(ped, false)
        FreezeEntityPosition(ped, false)
        SetEntityHealth(ped, 200)
        SetPedArmour(ped, 0)
        
        -- Trigger framework spawn events
        TriggerEvent('esx:onPlayerSpawn')
        TriggerEvent('wasabi_bridge:onPlayerSpawn')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        
        -- Screen fade in
        Wait(100)
        DoScreenFadeIn(500)
    end
    
    -- Actually leave the lobby (reset state)
    InLobby = false
    InMatch = false
    CurrentMatch = nil
    
    -- If leaving practice mode, close UI completely instead of opening main menu
    if wasPractice then
        -- Cooldown already set above before teleport, but ensure it's still active
        if PracticeExitCooldown <= GetGameTimer() then
            PracticeExitCooldown = GetGameTimer() + 8000 -- 8 second cooldown
        end
        
        -- Hide all UI elements immediately (redundant but ensures cleanup)
        SendNUIMessage({ action = 'hideInteractionPrompt' })
        SendNUIMessage({ action = 'hideLobbyIndicator' })
        SendNUIMessage({ action = 'closeUI' })
        -- Release NUI focus completely
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        PaintballMenuOpen = false
        
        -- Force hide UI elements multiple times to catch any that might show
        CreateThread(function()
            Wait(100)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            Wait(500)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
            
            Wait(1000)
            SendNUIMessage({ action = 'hideInteractionPrompt' })
            SendNUIMessage({ action = 'hideLobbyIndicator' })
            SendNUIMessage({ action = 'closeUI' })
            SetNuiFocus(false, false)
            SetNuiFocusKeepInput(false)
        end)
    else
        -- For regular matches, open main menu
        SendNUIMessage({ action = 'hideInteractionPrompt' })
        SendNUIMessage({ action = 'hideLobbyIndicator' })
        SendNUIMessage({ action = 'openMainMenu' })
        -- Keep NUI focus open so main menu is interactive
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
    end
    
    -- Re-enable inventory if was in match
    if wasInMatch and exports.ox_inventory then
        exports.ox_inventory:closeInventory()
        LocalPlayer.state:set('invBusy', false, false)
        LocalPlayer.state:set('invHotkeys', true, false)
        LocalPlayer.state:set('canUseWeapons', true, false)
        
        -- Re-enable weapon autoswap
        SetWeaponsNoAutoswap(false)
        
        -- Force ox_inventory to refresh weapon state
        Wait(100)
        TriggerEvent('ox_inventory:refreshWeapon')
    end
    
    -- If player was in a match (and not practice, since practice is handled above), restore their state
    if wasInMatch and not wasPractice then
        RestorePlayerState()
    end
    
    CreateThread(function()
        Wait(100)
    TriggerServerEvent('paintball:server:leaveLobby')
    end)
    
    -- Don't show interaction prompt after leaving practice mode (cooldown prevents it)
    -- For regular matches, show prompt if still in zone
    if not wasPractice and not InMatch and not InLobby and not PaintballMenuOpen then
        local currentTime = GetGameTimer()
        if not PracticeExitCooldown or PracticeExitCooldown <= currentTime then -- Only show if cooldown expired or not set
            local playerCoords = GetEntityCoords(cache.ped)
            local distance = #(playerCoords - Config.ArenaLocation.coords)
            if distance <= Config.ArenaLocation.interactionRadius then
                SendNUIMessage({
                    action = 'showInteractionPrompt'
                })
            end
        end
    end
    
    cb('ok')
end)

RegisterNUICallback('startMatch', function(data, cb)
    TriggerServerEvent('paintball:server:startMatch', data.matchId)
    cb('ok')
end)

RegisterNUICallback('openWeaponMenu', function(data, cb)
    -- Track where weapon menu is opened from
    -- Check for forPractice flag first (from practice settings UI)
    local source = nil
    if data.forPractice then
        source = 'practice'
        -- Initialize PendingPracticeSettings if it doesn't exist
        if not PendingPracticeSettings then
            PendingPracticeSettings = {
                weapon = Config.MatchSettings.defaultWeapon,
                weaponName = 'Pistol',
                difficulty = 'medium',
                botCount = 45, -- Middle of medium range (30-60)
                botCountEnabled = true,
                killTarget = 30,
                killTargetEnabled = false,
                healthSystem = 'standard',
                healthSystemEnabled = false,
                armorAmount = 50,
                healthPerKill = 25
            }
        end
    else
        source = data.source or (PendingPracticeSettings and 'practice' or (CurrentMatch and 'lobby' or 'gamemode'))
    end
    
    WeaponMenuSource = source
    
    if source == 'practice' and PendingPracticeSettings then
        ShowWeaponCategories('practice') -- Pass 'practice' as source
    else
        ShowWeaponCategories(source) -- Pass source (gamemode or lobby)
    end
    cb('ok')
end)

RegisterNUICallback('closeWeaponMenu', function(data, cb)
    -- Only close the weapon menu UI, don't release NUI focus if we're going back to practice settings
    SendNUIMessage({ action = 'closeWeaponMenu' })
    
    -- If we have pending practice settings, keep NUI focus open (practice menu should be visible)
    if PendingPracticeSettings and WeaponMenuSource == 'practice' then
        -- Keep NUI focus - practice settings menu should still be open
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
    elseif WeaponMenuSource == 'gamemode' then
        -- Return to game mode menu
        SendNUIMessage({ action = 'openGameModeMenu' })
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
    else
        -- For other cases, release NUI focus
    SetNuiFocus(false, false)
        PaintballMenuOpen = false
    end
    
    WeaponMenuSource = nil
    cb('ok')
end)

RegisterNUICallback('selectWeapon', function(data, cb)
    if not data or not data.weapon then
        print('[Paintball] Error: selectWeapon called without weapon data')
        cb('error')
        return
    end
    
    print('[Paintball] selectWeapon called - weapon:', data.weapon, 'weaponName:', data.weaponName, 'WeaponMenuSource:', WeaponMenuSource, 'CurrentMatch:', CurrentMatch ~= nil)
    SelectWeapon(data.weapon, data.weaponName)
    cb('ok')
end)

RegisterNUICallback('updatePracticeDifficulty', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.difficulty = data.difficulty
        -- Reset bot count to middle of new range
        local ranges = {
            easy = { min = 10, max = 20 },
            medium = { min = 30, max = 60 },
            hard = { min = 70, max = 100 }
        }
        local range = ranges[data.difficulty] or ranges.medium
        PendingPracticeSettings.botCount = math.floor((range.min + range.max) / 2)
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeBotCount', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.botCount = data.botCount
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeBotCountEnabled', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.botCountEnabled = data.enabled
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeKills', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.killTarget = data.kills
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeKillsEnabled', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.killTargetEnabled = data.enabled
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeWaveMode', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.waveMode = data.enabled
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeWaveSize', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.waveSize = data.waveSize
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeTimeLimitEnabled', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.timeLimitEnabled = data.enabled
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeTimeLimit', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.timeLimit = data.timeLimit
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeHealthEnabled', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.healthSystemEnabled = data.enabled
    end
    cb('ok')
end)

RegisterNUICallback('updatePracticeHealthSystem', function(data, cb)
    if PendingPracticeSettings then
        PendingPracticeSettings.healthSystem = data.healthSystem
    end
    cb('ok')
end)

RegisterNUICallback('restartPractice', function(data, cb)
    -- Restart with same settings
    if PendingPracticeSettings then
        TriggerServerEvent('paintball:server:createPracticeMatch', PendingPracticeSettings)
    end
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closePracticeSummary', function(data, cb)
    -- Comprehensive cleanup when closing practice summary
    CleanupPracticeUI()
    
    -- Release NUI focus completely
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    PaintballMenuOpen = false
    
    -- Send close message to ensure all UI elements are hidden
    SendNUIMessage({ action = 'closeUI' })
    
    cb('ok')
end)

RegisterNUICallback('startPracticeWithSettings', function(data, cb)
    if not Config.AIPractice.enabled then
        lib.notify({
            title = 'Practice Mode',
            description = 'AI Practice mode is currently disabled',
            type = 'error'
        })
        cb('ok')
        return
    end
    
    -- Use settings from data (sent from UI) or pending settings
    local settings = data or PendingPracticeSettings or {
        weapon = Config.MatchSettings.defaultWeapon,
        weaponName = 'Pistol',
        difficulty = 'medium',
        botCount = 45,
        botCountEnabled = true,
        killTarget = 30,
        killTargetEnabled = false,
        waveMode = false,
        healthSystem = 'standard',
        healthSystemEnabled = false,
        armorAmount = 50,
        healthPerKill = 25,
        waveSize = 5,
        timeLimit = 10,
        timeLimitEnabled = false
    }
    
    -- Ensure all settings are properly set
    if not settings.weapon then
        settings.weapon = Config.MatchSettings.defaultWeapon
        settings.weaponName = 'Pistol'
    end
    if not settings.difficulty then
        settings.difficulty = 'medium'
    end
    if not settings.botCount then
        settings.botCount = 45
    end
    if settings.botCountEnabled == nil then
        settings.botCountEnabled = true
    end
    if not settings.killTarget then
        settings.killTarget = 30
    end
    if settings.killTargetEnabled == nil then
        settings.killTargetEnabled = false
    end
    if settings.waveMode == nil then
        settings.waveMode = false
    end
    if not settings.waveSize then
        settings.waveSize = 5
    end
    if not settings.timeLimit then
        settings.timeLimit = 10
    end
    if settings.timeLimitEnabled == nil then
        settings.timeLimitEnabled = false
    end
    if not settings.healthSystem then
        settings.healthSystem = 'standard'
    end
    if settings.healthSystemEnabled == nil then
        settings.healthSystemEnabled = false
    end
    if not settings.armorPerKill then
        settings.armorPerKill = 0
    end
    if not settings.healthPerKill then
        settings.healthPerKill = 0
    end
    if not settings.healthSystem then
        settings.healthSystem = nil
    end
    
    -- Create practice match with all settings
    TriggerServerEvent('paintball:server:createPracticeMatch', settings)
    
    -- Clear pending settings
    PendingPracticeSettings = nil
    
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closePracticeSettings', function(data, cb)
    SetNuiFocus(false, false)
    SetNuiFocus(false, false) -- Double call to ensure release
    PaintballMenuOpen = false
    MenuCooldown = GetGameTimer() + 200
    SendNUIMessage({ action = 'closePracticeSettings' })
    PendingPracticeSettings = nil
    cb('ok')
end)

RegisterNUICallback('openWagerInput', function(data, cb)
    OpenWagerInput()
    cb('ok')
end)

-- Update lobby kills to win
RegisterNUICallback('updateLobbyKills', function(data, cb)
    if not InLobby or not CurrentMatch then
        cb('error')
        return
    end
    
    local kills = data.kills or 5
    -- Validate kills (must be 5, 10, 15, or 20)
    local validKills = {5, 10, 15, 20}
    local isValid = false
    for _, v in ipairs(validKills) do
        if kills == v then
            isValid = true
            break
        end
    end
    if not isValid then
        kills = 5 -- Default to 5 if invalid
    end
    
    TriggerServerEvent('paintball:server:updateLobbyKills', CurrentMatch.id, kills)
    
    -- Show notification
    lib.notify({
        title = 'Kills to Win',
        description = string.format('Kills to win set to %d', kills),
        type = 'success',
        duration = 3000
    })
    
    cb('ok')
end)

-- Track last wager notification to prevent duplicates
local lastWagerNotification = 0
local lastWagerNotificationTime = 0

-- Update lobby wager amount
RegisterNUICallback('updateLobbyWager', function(data, cb)
    if not InLobby or not CurrentMatch then
        cb('error')
        return
    end
    
    local wager = data.wager or 0
    if wager < 0 then
        wager = 0
    end
    
    -- Prevent duplicate notifications (only show if wager changed and not within last 500ms)
    local currentTime = GetGameTimer()
    local wagerChanged = (wager ~= lastWagerNotification)
    local timeSinceLastNotification = (currentTime - lastWagerNotificationTime)
    
    TriggerServerEvent('paintball:server:updateLobbyWager', CurrentMatch.id, wager)
    
    -- Show notification only if wager actually changed and not a duplicate
    if wagerChanged and timeSinceLastNotification > 500 then
        lastWagerNotification = wager
        lastWagerNotificationTime = currentTime
        
        if wager > 0 then
            lib.notify({
                title = 'Match Settings',
                description = string.format('💰 Wager: $%s', wager),
                type = 'success',
                duration = 2000,
                position = 'top'
            })
        else
            lib.notify({
                title = 'Match Settings',
                description = 'Wager removed',
                type = 'info',
                duration = 2000,
                position = 'top'
            })
        end
    end
    
    cb('ok')
end)

-- Main Menu Callbacks
RegisterNUICallback('closeMainMenu', function(data, cb)
    -- Release NUI focus MULTIPLE TIMES to ensure it's released
    SetNuiFocus(false, false)
    SetNuiFocus(false, false) -- Double call to ensure release
    PaintballMenuOpen = false
    
    -- Set cooldown to prevent immediate reopening
    MenuCooldown = GetGameTimer() + 200
    
    SendNUIMessage({ action = 'closeMainMenu' })
    
    -- Show interaction prompt instantly if player is still in the zone (no delay)
    if not InMatch and not InLobby and not PaintballMenuOpen then
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(playerCoords - Config.ArenaLocation.coords)
        if distance <= Config.ArenaLocation.interactionRadius then
            SendNUIMessage({
                action = 'showInteractionPrompt'
            })
        end
    end
    
    cb('ok')
end)

RegisterNUICallback('openGameModeMenu', function(data, cb)
    -- Respond immediately to prevent UI freeze
    cb('ok')
    
    -- Check cooldown to prevent rapid open/close
    local currentTime = GetGameTimer()
    if MenuCooldown > currentTime then
        return
    end
    
    -- Set cooldown (100ms - reduced for faster response)
    MenuCooldown = currentTime + 100
    
    -- Always ensure NUI focus is set (even if already set, ensure it's active)
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    ShowGameModeSelection()
end)

RegisterNUICallback('closeGameModeMenu', function(data, cb)
    -- Check cooldown to prevent rapid open/close
    local currentTime = GetGameTimer()
    if MenuCooldown > currentTime then
        cb('ok')
        return
    end
    
    -- Set cooldown (100ms - reduced for faster response)
    MenuCooldown = currentTime + 100
    
    -- Close game mode menu UI
    SendNUIMessage({ action = 'closeGameModeMenu' })
    
    -- Always maintain NUI focus for main menu (ensure it's active)
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    cb('ok')
end)

-- Store selected weapon for practice mode creation only
local PendingPracticeSettings = nil

RegisterNUICallback('selectGameMode', function(data, cb)
    local gameModeId = data.gameMode
    local selectedMode = nil
    
    -- Clear any pending practice settings when selecting a gamemode (creating a regular match)
    PendingPracticeSettings = nil
    
    for _, mode in ipairs(Config.GameModes) do
        if mode.id == gameModeId then
            selectedMode = mode
            break
        end
    end
    
    if selectedMode then
        -- Create match directly with default weapon (user can change it in lobby)
        TriggerServerEvent('paintball:server:createLobby', {
            matchTime = Config.MatchSettings.maxMatchTime, -- Deprecated
            killCount = Config.MatchSettings.defaultKillCount, -- Kills needed to win
            wager = 0,
            weapon = Config.MatchSettings.defaultWeapon,
            weaponName = 'Pistol',
            gameMode = selectedMode.id,
            gameModeName = selectedMode.name,
            maxScore = selectedMode.maxScore, -- Deprecated
            minPlayers = selectedMode.minPlayers,
            requiresTeams = selectedMode.requiresTeams
        })
    end
    
    -- Keep NUI focus - lobby will open shortly and needs focus
    -- Don't release focus here, the joinedLobby event will handle it
    -- Always ensure focus is set (lobby needs it)
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    cb('ok')
end)

-- Store selected weapon for practice mode creation
local PendingPracticeSettings = nil

RegisterNUICallback('startPracticeMode', function(data, cb)
    if not Config.AIPractice.enabled then
        lib.notify({
            title = 'Practice Mode',
            description = 'AI Practice mode is currently disabled',
            type = 'error'
        })
        cb('ok')
        return
    end
    
    -- Initialize practice settings with defaults
    PendingPracticeSettings = {
        weapon = Config.MatchSettings.defaultWeapon,
        weaponName = 'Pistol',
        difficulty = 'medium',
        killTarget = 30,
        healthSystem = 'standard',
        healthSystemEnabled = false,
        armorAmount = 50,
        healthPerKill = 25
    }
    
    -- Show practice mode settings menu
    SendNUIMessage({
        action = 'openPracticeSettings',
        settings = PendingPracticeSettings
    })
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    
    cb('ok')
end)

RegisterNUICallback('showLeaderboard', function(data, cb)
    ShowLeaderboard()
    -- Keep NUI focus open so leaderboard is interactive
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
    cb('ok')
end)

-- Receive leaderboard data from server and display it
RegisterNetEvent('paintball:client:showLeaderboard', function(leaderboardData)
    SendNUIMessage({
        action = 'showLeaderboard',
        stats = leaderboardData
    })
    -- Ensure NUI focus is open for leaderboard interaction
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
end)

-- Show weapon categories (NUI-based, similar to game mode menu)
function ShowWeaponCategories(source)
    source = source or 'gamemode' -- Default to 'gamemode' if not specified
    -- Prepare weapon categories data
    local weaponCategories = {}
    for _, category in ipairs(Config.AvailableWeapons) do
        table.insert(weaponCategories, {
            name = category.name,
            description = category.description,
            weapons = category.weapons
        })
    end
    
    -- Send to NUI
    SendNUIMessage({
        action = 'openWeaponMenu',
        weapons = weaponCategories,
        source = source -- Track where it was opened from
    })
    
    -- Enable NUI focus
    SetNuiFocus(true, true)
    PaintballMenuOpen = true
end

-- Select weapon
-- Track weapon menu source
local WeaponMenuSource = nil

function SelectWeapon(weapon, weaponName)
    -- If weapon menu was opened from gamemode selection (before lobby is created)
    -- This takes priority over practice settings - if selecting from gamemode, handle it first
    if WeaponMenuSource == 'gamemode' then
        -- Clear any pending practice settings since we're creating a regular match
        PendingPracticeSettings = nil
        
        -- Store weapon selection for when lobby is created
        -- This will be handled in the selectGameMode callback
        WeaponMenuSource = nil
        SendNUIMessage({ action = 'closeWeaponMenu' })
        Wait(100)
        -- Return to game mode menu (weapon will be set when lobby is created)
        SendNUIMessage({ action = 'openGameModeMenu' })
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
        return
    end
    
    -- If we have pending practice settings, just update the weapon (don't start match)
    -- Check if WeaponMenuSource is 'practice' OR if PendingPracticeSettings exists (fallback)
    if PendingPracticeSettings and (WeaponMenuSource == 'practice' or not CurrentMatch) then
        PendingPracticeSettings.weapon = weapon
        PendingPracticeSettings.weaponName = weaponName
        
        print('[Paintball] Practice weapon selected:', weapon, weaponName)
        
        -- Update the practice settings UI with the selected weapon (without reopening the menu)
        -- This preserves all existing settings including health system state
        SendNUIMessage({
            action = 'updatePracticeWeapon',
            weapon = weapon,
            weaponName = weaponName
        })
        
        -- Close weapon menu - practice settings menu should already be visible behind it
        SendNUIMessage({ action = 'closeWeaponMenu' })
        
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
        WeaponMenuSource = nil
        
        lib.notify({
            title = 'Weapon Selected',
            description = weaponName,
            type = 'success'
        })
        return
    end
    
    -- If weapon menu was opened from lobby (CurrentMatch exists and not practice/gamemode)
    if CurrentMatch and WeaponMenuSource ~= 'practice' and WeaponMenuSource ~= 'gamemode' then
        -- Update match settings on server
        TriggerServerEvent('paintball:server:updateSettings', CurrentMatch.id, {
            matchTime = CurrentMatch.settings.matchTime,
            wager = CurrentMatch.settings.wager,
            weapon = weapon,
            weaponName = weaponName,
            gameMode = CurrentMatch.settings.gameMode,
            gameModeName = CurrentMatch.settings.gameModeName,
            maxScore = CurrentMatch.settings.maxScore,
            minPlayers = CurrentMatch.settings.minPlayers,
            requiresTeams = CurrentMatch.settings.requiresTeams
        })

        -- Update CurrentMatch with new weapon (client-side update for immediate UI feedback)
        if CurrentMatch.settings then
            CurrentMatch.settings.weapon = weapon
            CurrentMatch.settings.weaponName = weaponName
        end
        
        -- Close weapon menu first
        SendNUIMessage({ action = 'closeWeaponMenu' })
        Wait(50)
        
        -- Re-open lobby menu to show updated settings
        SendNUIMessage({ 
            action = 'openLobby', 
            match = CurrentMatch,
            isHost = (CurrentMatch.host == cache.serverId)
        })
        SetNuiFocus(true, true)
        PaintballMenuOpen = true
        WeaponMenuSource = nil

        lib.notify({
            title = 'Weapon Selected',
            description = weaponName,
            type = 'success'
        })
        return
    end
    
    -- Fallback: if no match and not from gamemode/practice, just close
    if not CurrentMatch and WeaponMenuSource ~= 'gamemode' and WeaponMenuSource ~= 'practice' then 
        print('[Paintball] Warning: SelectWeapon called but no match found and not from gamemode/practice')
        SendNUIMessage({ action = 'closeWeaponMenu' })
        SetNuiFocus(false, false)
        PaintballMenuOpen = false
        WeaponMenuSource = nil
        return 
    end
    
    -- Final fallback: if we get here and nothing matched, just close the menu
    print('[Paintball] Warning: SelectWeapon reached end without handling - closing menu')
    SendNUIMessage({ action = 'closeWeaponMenu' })
    SetNuiFocus(false, false)
    PaintballMenuOpen = false
    WeaponMenuSource = nil
end

-- Open wager input
function OpenWagerInput()
    if not CurrentMatch then return end

    lib.input.number('Set Wager Amount', 'Enter the amount to wager (0 for no wager)', {
        required = true,
        min = 0,
        default = CurrentMatch.settings.wager or 0
    }, function(amount)
        if amount ~= nil and amount >= 0 then
            TriggerServerEvent('paintball:server:updateSettings', CurrentMatch.id, {
                matchTime = CurrentMatch.settings.matchTime,
                wager = amount,
                weapon = CurrentMatch.settings.weapon,
                weaponName = CurrentMatch.settings.weaponName,
                gameMode = CurrentMatch.settings.gameMode,
                gameModeName = CurrentMatch.settings.gameModeName,
                maxScore = CurrentMatch.settings.maxScore,
                minPlayers = CurrentMatch.settings.minPlayers,
                requiresTeams = CurrentMatch.settings.requiresTeams
            })
            lib.notify({
                title = 'Wager Updated',
                description = ('Wager set to $%s'):format(amount),
                type = 'success'
            })
        end
    end)
end

-- ESC key to close UI (works for all menus)
-- Note: When NUI focus is active, control detection may not work, so we rely on JavaScript ESC handler
-- This is a backup for when NUI focus is not active
CreateThread(function()
    local lastEscState = false
    while true do
        -- Only check ESC if NUI focus is not active (backup handler)
        -- When NUI focus IS active, JavaScript handles ESC
        if not PaintballMenuOpen and not InLobby and not InMatch then
            Wait(500) -- Don't check as frequently when menus aren't open
        else
            Wait(100) -- Reduced from 0 to 100ms - ESC check doesn't need every frame
            local escPressed = IsControlJustPressed(0, 194) -- ESC key
            
            -- Check if any paintball menu is open
            if escPressed and not lastEscState then
                lastEscState = true
                
                -- Close menu if any paintball menu is open (InLobby, InMatch, or PaintballMenuOpen flag)
                if InLobby or InMatch or PaintballMenuOpen then
                    -- Trigger closeUI callback (same as clicking X button)
                    SendNUIMessage({ action = 'closeUI' })
                end
            elseif not escPressed then
                lastEscState = false
            end
        end
    end
end)

-- Tab key to toggle scoreboard (during match, including practice mode)
local scoreboardVisible = false
local lastTabState = false
local lastEscState = false

-- Disable camera/player look controls when scoreboard is visible
CreateThread(function()
    while true do
        if scoreboardVisible and InMatch and CurrentMatch then
            Wait(0) -- Only check every frame when scoreboard is visible
            -- Disable camera look controls
            DisableControlAction(0, 1, true)  -- INPUT_LOOK_LR (mouse left/right)
            DisableControlAction(0, 2, true)  -- INPUT_LOOK_UD (mouse up/down)
            DisableControlAction(0, 3, true)  -- INPUT_LOOK_UP_ONLY
            DisableControlAction(0, 4, true)  -- INPUT_LOOK_DOWN_ONLY
            DisableControlAction(0, 5, true)  -- INPUT_LOOK_LEFT_ONLY
            DisableControlAction(0, 6, true)  -- INPUT_LOOK_RIGHT_ONLY
        else
            Wait(500) -- Check less frequently when scoreboard is not visible
        end
    end
end)

-- Function to toggle scoreboard
local function ToggleScoreboard()
    if not InMatch or not CurrentMatch then return end
    
    scoreboardVisible = not scoreboardVisible
    
    if scoreboardVisible then
        -- Prepare complete match data for scoreboard
        local matchData = {
            id = CurrentMatch.id,
            gameMode = CurrentMatch.gameMode or (CurrentMatch.settings and CurrentMatch.settings.gameMode) or 'practice',
            settings = CurrentMatch.settings or {},
            teams = CurrentMatch.teams or { red = {}, blue = {} },
            scores = CurrentMatch.scores or { red = 0, blue = 0 },
            stats = CurrentMatch.stats or {},
            status = CurrentMatch.status or 'active'
        }
        
        -- Ensure gameMode is set correctly
        if not matchData.gameMode or matchData.gameMode == '' then
            matchData.gameMode = (matchData.settings and matchData.settings.gameMode) or 'practice'
        end
        
        -- Show scoreboard with NUI focus and cursor, but keep input enabled
        SetNuiFocus(true, true) -- Enable NUI focus and show cursor
        SetNuiFocusKeepInput(true) -- Keep game input enabled so player can still move/shoot
        SendNUIMessage({
            action = 'showScoreboard',
            match = matchData
        })
        
        print('[Paintball] Scoreboard shown with cursor')
    else
        -- Hide scoreboard and disable NUI focus
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({
            action = 'hideScoreboard'
        })
        
        print('[Paintball] Scoreboard hidden')
    end
end

-- Register a command for Tab key to ensure it works
RegisterCommand('+paintball_scoreboard', function()
    ToggleScoreboard()
end, false)

RegisterCommand('-paintball_scoreboard', function()
    -- On release, do nothing (toggle on press only)
end, false)

-- Register key mapping for Tab
RegisterKeyMapping('+paintball_scoreboard', 'Toggle Paintball Scoreboard', 'keyboard', 'TAB')

-- Handle Tab and ESC keys directly in a thread as backup
CreateThread(function()
    while true do
        if InMatch and CurrentMatch then
            Wait(50) -- Reduced from 0 to 50ms - key checks don't need every frame
            -- Check Tab key BEFORE disabling it (only control 19 is Tab)
            local tabPressed = IsControlJustPressed(0, 19)
            local escPressed = IsControlJustPressed(0, 194) -- ESC key
            
            -- Disable default Tab key behavior (inventory/player list) - ONLY Tab (19), NOT jump (22)!
            DisableControlAction(0, 19, true) -- Tab key (inventory/player list)
            -- NOTE: Control 22 is INPUT_JUMP, NOT Tab! Do NOT disable it!
            
            -- Handle Tab key toggle
            if tabPressed and not lastTabState then
                lastTabState = true
                ToggleScoreboard()
            elseif not tabPressed then
                lastTabState = false
            end
            
            -- Handle ESC key to close scoreboard
            if escPressed and not lastEscState then
                lastEscState = true
                if scoreboardVisible then
                    scoreboardVisible = false
                    SetNuiFocus(false, false)
                    SetNuiFocusKeepInput(false)
                    SendNUIMessage({
                        action = 'hideScoreboard'
                    })
                    
                    print('[Paintball] Scoreboard hidden (ESC)')
                end
            elseif not escPressed then
                lastEscState = false
            end
        else
            Wait(500) -- Check less frequently when not in match
            -- Hide scoreboard when not in match and reset toggle state
            if scoreboardVisible then
                scoreboardVisible = false
                SetNuiFocus(false, false)
                SetNuiFocusKeepInput(false)
                SendNUIMessage({
                    action = 'hideScoreboard'
                })
            end
            lastTabState = false
            lastEscState = false
        end
    end
end)

-- Round reset countdown (for 1v1 matches)
RegisterNetEvent('paintball:client:roundReset', function(match, countdown)
    if not InMatch or not CurrentMatch then return end
    
    -- Ensure match data is complete
    if not match.stats then match.stats = {} end
    if not match.scores then match.scores = { red = 0, blue = 0 } end
    if not match.players then match.players = {} end
    
    -- Show countdown UI with scoreboard
    SendNUIMessage({
        action = 'showRoundReset',
        countdown = countdown,
        match = match
    })
    
    -- Countdown loop
    CreateThread(function()
        local timeLeft = countdown
        while timeLeft > 0 and InMatch and CurrentMatch and CurrentMatch.id == match.id do
            Wait(1000)
            timeLeft = timeLeft - 1
            if timeLeft > 0 then
                SendNUIMessage({
                    action = 'updateRoundReset',
                    countdown = timeLeft,
                    match = match
                })
            else
                -- Countdown reached 0, hide the UI (respawn will be triggered by server)
                SendNUIMessage({
                    action = 'hideRoundReset'
                })
            end
        end
    end)
end)

-- Round respawn (respawn at original spawn point) - SAME AS PRACTICE MODE REVIVAL
print("[Paintball DEBUG] Registering roundRespawn event handler...")
RegisterNetEvent('paintball:client:roundRespawn', function(match, spawn)
    print("[Paintball DEBUG] roundRespawn: EVENT HANDLER CALLED - Event received!")
    print(string.format("[Paintball DEBUG] roundRespawn: Event received. InMatch=%s, CurrentMatch=%s, match=%s, spawn=%s", 
        tostring(InMatch), tostring(CurrentMatch ~= nil), tostring(match ~= nil), tostring(spawn ~= nil)))
    
    if not InMatch or not CurrentMatch then 
        print("[Paintball DEBUG] roundRespawn: ERROR - Not in match or no current match, aborting")
        return 
    end
    
    local ped = cache.ped
    local healthBefore = GetEntityHealth(ped)
    local isDeadBefore = IsPedDeadOrDying(ped, true)
    
    print(string.format("[Paintball DEBUG] roundRespawn: Player state - Health: %d, IsDead: %s, Spawn: %.2f, %.2f, %.2f", 
        healthBefore, tostring(isDeadBefore), spawn.x, spawn.y, spawn.z))
    
    -- Hide round reset UI immediately
    SendNUIMessage({ action = 'hideRoundReset' })
    
    -- Ensure NUI focus is released
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    
    -- Determine which weapon to give BEFORE doing anything else
    local weaponHash = nil
    if match.gameMode == 'gungame' then
        local gunGameLevel = match.gunGameLevels[cache.serverId] or 1
        weaponHash = GetHashKey(Config.GunGameWeapons[gunGameLevel])
    else
        local weaponName = match.settings.weapon or Config.MatchSettings.defaultWeapon
        weaponHash = GetHashKey(weaponName)
    end
    
    -- Validate weapon hash
    if not weaponHash or weaponHash == 0 then
        weaponHash = GetHashKey(Config.MatchSettings.defaultWeapon)
    end
    
    -- CRITICAL: Disable ox_inventory weapon management FIRST (before anything else)
    if exports.ox_inventory then
        TriggerEvent('ox_inventory:disarm', true)
        LocalPlayer.state:set('invBusy', true, false)
        LocalPlayer.state:set('invHotkeys', false, false)
        LocalPlayer.state:set('canUseWeapons', false, false)
    end
    
    -- EXACT SAME REVIVAL LOGIC AS INITIAL SPAWN (startMatch) - EXACT ORDER
    -- Ensure player can move (same as startMatch)
    SetPedCanRagdoll(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    SetPedConfigFlag(ped, 281, false) -- Allow ragdoll
    SetPedResetFlag(ped, 240, false) -- Allow movement
    
    -- 1. Teleport FIRST (same as initial spawn)
    print("[Paintball DEBUG] roundRespawn: Step 1 - Teleporting")
    SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
    SetEntityHeading(ped, spawn.w or 0.0)
    local healthAfterTeleport = GetEntityHealth(ped)
    print(string.format("[Paintball DEBUG] roundRespawn: After teleport - Health: %d", healthAfterTeleport))
    
    -- 2. Revive and heal player immediately (ALWAYS do this - EXACTLY like initial spawn)
    print("[Paintball DEBUG] roundRespawn: Step 2 - Reviving (always, to clear death UI)")
    -- ALWAYS call NetworkResurrectLocalPlayer (same as initial spawn logic)
    NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.w or 0.0, false, false)
    local healthAfterRevive = GetEntityHealth(ped)
    print(string.format("[Paintball DEBUG] roundRespawn: After NetworkResurrectLocalPlayer - Health: %d", healthAfterRevive))
    
    -- 3. Clear death status from various death systems (EXACTLY same as practice mode - ONLY client:revive)
    print("[Paintball DEBUG] roundRespawn: Step 3 - Clearing death status (CRITICAL - clears death UI)")
    if GetResourceState('wasabi_ambulance') == 'started' then
        print("[Paintball DEBUG] roundRespawn: Triggering wasabi_ambulance:client:revive (clears death UI)")
        -- Try multiple revive methods to ensure death UI is cleared
        TriggerEvent('wasabi_ambulance:client:revive')
        TriggerEvent('wasabi_ambulance:revive', true) -- Alternative revive event
        TriggerEvent('wasabi_ambulance:customInjuryClear') -- Clear custom injuries
        -- Also clear server-side death status
        TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
        TriggerServerEvent('wasabi_ambulance:injurySync', false)
        print("[Paintball DEBUG] roundRespawn: Also sent server-side setDeathStatus(false) and injurySync(false)")
        -- Clear LocalPlayer.state variables (critical for wasabi_ambulance)
        if LocalPlayer.state.isDead ~= nil then
            LocalPlayer.state:set('isDead', false, false)
            print("[Paintball DEBUG] roundRespawn: Cleared LocalPlayer.state.isDead")
        end
        if LocalPlayer.state.dead ~= nil then
            LocalPlayer.state:set('dead', false, false)
            print("[Paintball DEBUG] roundRespawn: Cleared LocalPlayer.state.dead")
        end
        -- Try to hide death UI directly via NUI message (wasabi_ambulance uses this)
        SendNUIMessage({
            action = 'hideDeathScreen'
        })
        print("[Paintball DEBUG] roundRespawn: Sent NUI message to hide death screen")
    else
        print("[Paintball DEBUG] roundRespawn: wasabi_ambulance not started")
    end
    if GetResourceState('mythic_hospital') == 'started' then
        print("[Paintball DEBUG] roundRespawn: Triggering mythic_hospital events")
        TriggerEvent('mythic_hospital:client:RemoveBleed')
        TriggerEvent('mythic_hospital:client:ResetLimbs')
    end
    
    -- 4. Full heal and clear damage (EXACTLY like initial spawn)
    print("[Paintball DEBUG] roundRespawn: Step 4 - Full heal and clear damage")
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityHealth(ped, 200)
    SetPedArmour(ped, 0)
    ClearPedTasksImmediately(ped) -- Clear any death animations
    local healthAfterHeal = GetEntityHealth(ped)
    print(string.format("[Paintball DEBUG] roundRespawn: After SetEntityHealth(200) - Health: %d", healthAfterHeal))
    
    -- 5. Trigger framework spawn events (EXACTLY like initial spawn)
    print("[Paintball DEBUG] roundRespawn: Step 5 - Triggering framework spawn events")
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('wasabi_bridge:onPlayerSpawn')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    local healthAfterEvents = GetEntityHealth(ped)
    print(string.format("[Paintball DEBUG] roundRespawn: After framework events - Health: %d", healthAfterEvents))
    
    -- 6. Re-clear death status AFTER all events (ensure death UI is gone)
    print("[Paintball DEBUG] roundRespawn: Step 6 - Re-clearing death status to ensure UI is gone")
    if GetResourceState('wasabi_ambulance') == 'started' then
        TriggerEvent('wasabi_ambulance:client:revive')
        TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
        if LocalPlayer.state.isDead ~= nil then
            LocalPlayer.state:set('isDead', false, false)
        end
        if LocalPlayer.state.dead ~= nil then
            LocalPlayer.state:set('dead', false, false)
        end
        print("[Paintball DEBUG] roundRespawn: Re-cleared death status and state variables")
    end
    
    -- GIVE WEAPON IMMEDIATELY (no thread delay) - AGGRESSIVE
    if DoesEntityExist(ped) and weaponHash and weaponHash ~= 0 then
        -- CRITICAL: Maintain ox_inventory states BEFORE giving weapon
        if exports.ox_inventory then
            TriggerEvent('ox_inventory:disarm', true)
            LocalPlayer.state:set('invBusy', true, false)
            LocalPlayer.state:set('invHotkeys', false, false)
            LocalPlayer.state:set('canUseWeapons', false, false)
        end
        
        -- Remove all weapons first
        RemoveAllPedWeapons(ped, true)
        
        -- Give weapon immediately
        GiveWeaponToPed(ped, weaponHash, 999, false, true)
        SetPedAmmo(ped, weaponHash, 999)
        SetCurrentPedWeapon(ped, weaponHash, true)
        SetPedInfiniteAmmo(ped, false)
        SetWeaponsNoAutoswap(true)
        
        -- Double-check weapon is equipped
        Wait(50)
        local currentWeapon = GetSelectedPedWeapon(ped)
        if currentWeapon ~= weaponHash then
            RemoveAllPedWeapons(ped, true)
            GiveWeaponToPed(ped, weaponHash, 999, false, true)
            SetPedAmmo(ped, weaponHash, 999)
            SetCurrentPedWeapon(ped, weaponHash, true)
            SetPedInfiniteAmmo(ped, false)
            SetWeaponsNoAutoswap(true)
        end
        
        -- Try to fill clip (with safety check)
        local maxClipSize = 30
        local success, result = pcall(function()
            return GetMaxAmmoInClip(ped, weaponHash, true)
        end)
        if success and result and result > 0 then
            maxClipSize = result
        end
        
        local currentClipAmmo = GetAmmoInClip(ped, weaponHash)
        if currentClipAmmo and type(currentClipAmmo) == 'number' and currentClipAmmo < maxClipSize then
            AddAmmoToPed(ped, weaponHash, maxClipSize - currentClipAmmo)
        end
    end
    
    -- Continuous verification thread (runs in background, ensures weapon stays and player stays alive)
    CreateThread(function()
        local checkCount = 0
        local maxChecks = 100 -- Check for 10 seconds (very aggressive - ensures player stays alive)
        
        while checkCount < maxChecks and InMatch and CurrentMatch and CurrentMatch.id == match.id do
            Wait(50) -- Check every 50ms (very frequent)
            checkCount = checkCount + 1
            
            local ped = cache.ped
            if not DoesEntityExist(ped) then break end
            
            -- CRITICAL: Maintain ox_inventory states continuously (prevent weapon removal)
            if exports.ox_inventory then
                LocalPlayer.state:set('invBusy', true, false)
                LocalPlayer.state:set('invHotkeys', false, false)
                LocalPlayer.state:set('canUseWeapons', false, false)
            end
            
            -- Ensure player is alive and healthy (EXACTLY like initial spawn - keep alive)
            local currentHealth = GetEntityHealth(ped)
            local isDead = IsPedDeadOrDying(ped, true)
            if isDead or currentHealth < 200 then
                print(string.format("[Paintball DEBUG] roundRespawn verification: Player health issue - Health: %d, IsDead: %s, Check: %d", currentHealth, tostring(isDead), checkCount))
                -- Re-revive using EXACT same logic as initial spawn
                NetworkResurrectLocalPlayer(spawn.x, spawn.y, spawn.z, spawn.w or 0.0, false, false)
                ClearPedTasksImmediately(ped) -- Clear death animations
                if GetResourceState('wasabi_ambulance') == 'started' then
                    TriggerEvent('wasabi_ambulance:client:revive')
                    TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
                    if LocalPlayer.state.isDead ~= nil then
                        LocalPlayer.state:set('isDead', false, false)
                    end
                    if LocalPlayer.state.dead ~= nil then
                        LocalPlayer.state:set('dead', false, false)
                    end
                end
                ClearPedBloodDamage(ped)
                ResetPedVisibleDamage(ped)
                SetEntityInvincible(ped, false)
                FreezeEntityPosition(ped, false)
                SetEntityHealth(ped, 200)
                SetPedArmour(ped, 0)
                local healthAfterFix = GetEntityHealth(ped)
                print(string.format("[Paintball DEBUG] roundRespawn verification: After fix - Health: %d", healthAfterFix))
            end
            
            -- Continuously clear death status to prevent death UI from appearing
            if GetResourceState('wasabi_ambulance') == 'started' then
                if LocalPlayer.state.isDead == true or (LocalPlayer.state.dead ~= nil and LocalPlayer.state.dead == true) then
                    print(string.format("[Paintball DEBUG] roundRespawn verification: Death state detected, clearing - Check: %d", checkCount))
                    TriggerEvent('wasabi_ambulance:client:revive')
                    TriggerServerEvent('wasabi_ambulance:setDeathStatus', false, true)
                    LocalPlayer.state:set('isDead', false, false)
                    if LocalPlayer.state.dead ~= nil then
                        LocalPlayer.state:set('dead', false, false)
                    end
                end
            end
            
            -- CRITICAL: Ensure weapon is equipped EVERY CHECK (prevent weapon disappearing)
            local currentWeapon = GetSelectedPedWeapon(ped)
            if currentWeapon ~= weaponHash and weaponHash and weaponHash ~= 0 then
                -- Disable ox_inventory interference again
                if exports.ox_inventory then
                    TriggerEvent('ox_inventory:disarm', true)
                    LocalPlayer.state:set('invBusy', true, false)
                    LocalPlayer.state:set('invHotkeys', false, false)
                    LocalPlayer.state:set('canUseWeapons', false, false)
                end
                
                -- Force equip the correct weapon
                RemoveAllPedWeapons(ped, true)
                GiveWeaponToPed(ped, weaponHash, 999, false, true)
                SetPedAmmo(ped, weaponHash, 999)
                SetCurrentPedWeapon(ped, weaponHash, true)
                SetPedInfiniteAmmo(ped, false)
                SetWeaponsNoAutoswap(true)
                
                -- Ensure clip is full
                Wait(10) -- Small delay before checking clip
                local maxClipSize = 30
                local success, result = pcall(function()
                    return GetMaxAmmoInClip(ped, weaponHash, true)
                end)
                if success and result and result > 0 then
                    maxClipSize = result
                end
                local currentClipAmmo = GetAmmoInClip(ped, weaponHash)
                if currentClipAmmo and type(currentClipAmmo) == 'number' and currentClipAmmo < maxClipSize then
                    AddAmmoToPed(ped, weaponHash, maxClipSize - currentClipAmmo)
                end
            end
            
        end
    end)
end)
