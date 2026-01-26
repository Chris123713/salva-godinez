-- Advanced Paintball System - Server

-- Match State
local ActiveMatches = {}
local PlayerMatches = {} -- [source] = matchId
local MatchIdCounter = 1

-- Player Stats (for leaderboard)
local PlayerStats = {}

-- Player Progression Data (XP, Level, Rank, Prestige)
-- All previous progression data erased - starting fresh at Prestige 0, Level 1, XP 0
local PlayerProgression = {} -- [citizenid] = { xp = 0, level = 1, prestige = 0, rankedRating = 0 }

-- Clear all progression data on server start (ensures fresh start)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Erase all previous progression data
        PlayerProgression = {}
        print("[Paintball] All progression data cleared - starting fresh at Prestige 0, Level 1, XP 0")
    end
end)

-- Helper function to get player character name - defined early so it can be used throughout
local function GetPlayerDisplayName(playerId)
    local player = exports.qbx_core:GetPlayer(playerId)
    if player and player.PlayerData and player.PlayerData.charinfo then
        return player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    end
    -- If no character info, return empty string (will show as "Player [ID]" in UI)
    return ''
end

-- Helper function to add player names to match data - ensures playerNames are always included
local function AddPlayerNamesToMatch(match)
    -- Modify the match table directly to add player names
    if not match.playerNames then
        match.playerNames = {}
    end
    for playerId, _ in pairs(match.players) do
        -- Get character name directly
        local playerName = GetPlayerDisplayName(playerId)
        -- Store with playerId as key (both string and number for compatibility)
        if playerName and playerName ~= '' then
            match.playerNames[tostring(playerId)] = playerName
            match.playerNames[tonumber(playerId)] = playerName
        end
    end
    return match
end

-- Initialize player progression
local function GetPlayerProgression(citizenid)
    -- Always start fresh at Prestige 0, Level 1, XP 0 (all previous data erased)
    if not PlayerProgression[citizenid] then
        PlayerProgression[citizenid] = {
            xp = 0,
            level = 1,
            prestige = 0,
            prestigeLevel = 0,
            rankedRating = 0,
            totalXP = 0
        }
    end
    -- Return progression (will be updated as player earns XP)
    return PlayerProgression[citizenid]
end

-- Calculate XP required for a level
local function GetXPRequiredForLevel(level)
    if level <= 1 then return Config.XPPerLevel end
    return math.floor(Config.XPPerLevel * (Config.XPPerLevelMultiplier ^ (level - 1)))
end

-- Add XP to player
local function AddXP(citizenid, amount, reason)
    if not Config.EnableXPSystem then return end
    
    local prog = GetPlayerProgression(citizenid)
    local oldLevel = prog.level
    local oldPrestige = prog.prestigeLevel
    
    -- Max level is 50 per prestige
    local maxLevelPerPrestige = 50
    
    -- If already at max level, check for prestige opportunity
    if prog.level >= maxLevelPerPrestige then
        -- Player is at level 50, check if they can prestige
        if Config.PrestigeSystem.enabled and prog.prestigeLevel < Config.PrestigeSystem.maxPrestige then
            prog.prestigeLevel = prog.prestigeLevel + 1
            prog.level = 1 -- Reset to level 1 for new prestige
            prog.xp = 0
            
            -- Notify player of prestige up
            local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
            if player then
                TriggerClientEvent('paintball:client:prestigeUp', player.PlayerData.source, prog.prestigeLevel)
            end
        else
            -- Already max prestige or prestige disabled, don't add XP
            return prog
        end
    end
    
    prog.xp = prog.xp + amount
    prog.totalXP = prog.totalXP + amount
    
    -- Check for level up (cap at 50 per prestige)
    while prog.xp >= GetXPRequiredForLevel(prog.level) and prog.level < maxLevelPerPrestige do
        prog.xp = prog.xp - GetXPRequiredForLevel(prog.level)
        prog.level = prog.level + 1
        
        -- Notify player of level up
        local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
        if player then
            TriggerClientEvent('paintball:client:levelUp', player.PlayerData.source, prog.level)
        end
        
        -- If reached level 50, automatically prestige (if available)
        if prog.level >= maxLevelPerPrestige then
            -- Cap XP at 0 when reaching max level
            prog.xp = 0
            
            -- Check for prestige up (requires level 50)
            if Config.PrestigeSystem.enabled and prog.prestigeLevel < Config.PrestigeSystem.maxPrestige then
                prog.prestigeLevel = prog.prestigeLevel + 1
                prog.level = 1 -- Reset to level 1 for new prestige
                prog.xp = 0
                
                -- Notify player of prestige up
                local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
                if player then
                    TriggerClientEvent('paintball:client:prestigeUp', player.PlayerData.source, prog.prestigeLevel)
                end
            end
            break -- Stop leveling loop when at max
        end
    end
    
    -- Update progression display if player is online
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    if player then
        UpdatePlayerProgressionDisplay(player.PlayerData.source)
    end
    
    return prog
end

-- Get player's rank based on rating
local function GetPlayerRank(rating)
    if not Config.EnableRankedPvP then return nil end
    
    for i = #Config.Ranks, 1, -1 do
        local rank = Config.Ranks[i]
        if rating >= rank.minRating and rating <= rank.maxRating then
            return rank
        end
    end
    return Config.Ranks[1] -- Default to Rookie
end

-- Update ranked rating
local function UpdateRankedRating(citizenid, ratingChange)
    if not Config.EnableRankedPvP then return end
    
    local prog = GetPlayerProgression(citizenid)
    prog.rankedRating = math.max(0, prog.rankedRating + ratingChange)
    
    -- Update progression display
    local player = exports.qbx_core:GetPlayerByCitizenId(citizenid)
    if player then
        UpdatePlayerProgressionDisplay(player.PlayerData.source)
    end
end

-- Update player progression display on client (always uses current data)
function UpdatePlayerProgressionDisplay(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    
    local citizenid = player.PlayerData.citizenid
    -- Get current progression (ensures it's initialized if missing)
    local prog = GetPlayerProgression(citizenid)
    
    -- Ensure progression starts at correct values if not initialized
    if not prog.prestigeLevel then prog.prestigeLevel = 0 end
    if not prog.level then prog.level = 1 end
    if not prog.xp then prog.xp = 0 end
    if not prog.rankedRating then prog.rankedRating = 0 end
    
    local rank = GetPlayerRank(prog.rankedRating)
    
    local prestigeData = nil
    if Config.PrestigeSystem.enabled and prog.prestigeLevel > 0 then
        prestigeData = Config.PrestigeSystem.prestigeRewards[prog.prestigeLevel]
    end
    
    local prestigeIcon = "🛡️"
    if prestigeData then
        prestigeIcon = prestigeData.icon or "🛡️"
    elseif prog.prestigeLevel == 0 then
        -- Default for prestige 0
        local defaultPrestige = Config.PrestigeSystem.prestigeRewards[0]
        if defaultPrestige then
            prestigeIcon = defaultPrestige.icon or "🛡️"
        end
    end
    
    -- Debug: Log progression data being sent (helps identify if old data is being sent)
    print(string.format("[Paintball] Sending progression to player %d (citizenid: %s): Prestige=%d, Level=%d, XP=%d", source, citizenid, prog.prestigeLevel or 0, prog.level or 1, prog.xp or 0))
    
    -- Always send current progression data immediately (no delays, no caching, instant)
    TriggerClientEvent('paintball:client:updateProgression', source, {
        prestige = prog.prestigeLevel or 0,
        prestigeLevel = prog.prestigeLevel or 0,
        prestigeTitle = prestigeData and prestigeData.title or nil,
        prestigeIcon = prestigeIcon,
        rank = rank and rank.name or "Unranked",
        rankInsignia = rank and rank.insignia or "🎖️",
        level = prog.level or 1,
        xp = prog.xp or 0,
        xpRequired = GetXPRequiredForLevel(prog.level or 1),
        totalXP = prog.totalXP or (prog.xp or 0), -- Include total XP for display
        rankedRating = Config.EnableRankedPvP and (prog.rankedRating or 0) or nil
    })
end

-- Create a new match
local function CreateMatch(hostId, settings)
    local matchId = MatchIdCounter
    MatchIdCounter = MatchIdCounter + 1
    
    local defaultSettings = {
        matchTime = Config.MatchSettings.maxMatchTime, -- Deprecated, kept for compatibility
        killCount = Config.MatchSettings.defaultKillCount, -- Kills needed to win
        wager = 0,
        weapon = Config.MatchSettings.defaultWeapon,
        weaponName = 'Pistol',
        gameMode = 'tdm',
        gameModeName = 'Team Deathmatch',
        maxScore = 30, -- Deprecated, using killCount instead
        minPlayers = 2,
        requiresTeams = true
    }
    
    if settings then
        for k, v in pairs(settings) do
            defaultSettings[k] = v
        end
    end
    
    local match = {
        id = matchId,
        host = hostId,
        settings = defaultSettings,
        gameMode = defaultSettings.gameMode,
        gameModeName = defaultSettings.gameModeName,
        teams = {
            red = {},
            blue = {}
        },
        scores = {
            red = 0,
            blue = 0
        },
        status = 'lobby',
        startTime = nil,
        endTime = nil,
        players = {},
        stats = {},
        gunGameLevels = {},
        wagerPaid = {},
        totalWager = 0,
        playerSpawns = {}, -- Store assigned spawn points for each player (for round resets)
        endVotes = {} -- Track votes to end match (playerId -> 'yes' or 'no')
    }
    
    ActiveMatches[matchId] = match
    return matchId
end

-- Add player to match
local function AddPlayerToMatch(source, matchId, team)
    local match = ActiveMatches[matchId]
    if not match then return false end
    if match.status ~= 'lobby' then return false end
    
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    
    local currentMatchId = PlayerMatches[source]
    if currentMatchId then
        if currentMatchId ~= matchId then
        return false
    end
    
        local currentPlayerData = match.players[source]
        if currentPlayerData then
            if currentPlayerData.team == team then
                return true
            end
            
            for i, playerId in ipairs(match.teams[currentPlayerData.team]) do
                if playerId == source then
                    table.remove(match.teams[currentPlayerData.team], i)
                    break
                end
            end
        end
    end
    
    if #match.teams[team] >= Config.MatchSettings.maxPlayersPerTeam then
        return false
    end
    
    table.insert(match.teams[team], source)
    match.players[source] = {
        team = team,
        kills = 0,
        deaths = 0,
        points = 0
    }
    match.stats[source] = {
        kills = 0,
        deaths = 0,
        kd = 0.00,
        points = 0
    }
    match.gunGameLevels[source] = 1
    
    PlayerMatches[source] = matchId
    
    -- Set routing bucket for regular matches (not practice mode)
    if Config.MatchRoutingBucket.enabled and match.gameMode ~= 'practice' then
        local bucketId = Config.MatchRoutingBucket.baseBucket + matchId
        SetPlayerRoutingBucket(source, bucketId)
    end
    
    -- Add player names to match data before sending
    local matchWithNames = AddPlayerNamesToMatch(match)
    
    for playerId, _ in pairs(match.players) do
        TriggerClientEvent('paintball:client:updateLobby', playerId, matchWithNames)
    end
    
    -- Notify all clients to refresh their lobby list when someone joins
    TriggerClientEvent('paintball:client:refreshLobbies', -1)
    
    return true
end

-- Remove player from match
local function RemovePlayerFromMatch(source)
    local matchId = PlayerMatches[source]
    if not matchId then return end
    
    local match = ActiveMatches[matchId]
    if not match then return end
    
    -- Check if player is the host
    local isHost = (match.host == source)
    
    -- Reset routing bucket
    if match.gameMode == 'practice' and Config.AIPractice.useRoutingBucket then
        SetPlayerRoutingBucket(source, 0)
    elseif Config.MatchRoutingBucket.enabled and match.gameMode ~= 'practice' then
        SetPlayerRoutingBucket(source, 0)
    end
    
    local playerData = match.players[source]
    if playerData then
    for i, playerId in ipairs(match.teams[playerData.team]) do
        if playerId == source then
            table.remove(match.teams[playerData.team], i)
            break
            end
        end
    end
    
    match.players[source] = nil
    match.stats[source] = nil
    match.gunGameLevels[source] = nil
    match.wagerPaid[source] = nil
    PlayerMatches[source] = nil
    
    -- Track if match was deleted
    local matchWasDeleted = false
    
    -- If host left, disband the lobby completely and send all players back to main UI
    if isHost then
        if match.status == 'active' then
            -- Match is active, end it properly (this will send all players back)
            EndMatch(matchId, nil, nil)
            matchWasDeleted = true -- Mark as deleted so we don't try to update lobby
        else
            -- Match is in lobby, disband completely and send all players back
            -- Get all remaining players before we delete the match
            local remainingPlayers = {}
            for playerId, _ in pairs(match.players) do
                table.insert(remainingPlayers, playerId)
            end
            
            -- Clean up all references for all remaining players
            for _, playerId in ipairs(remainingPlayers) do
                PlayerMatches[playerId] = nil
                -- Reset routing bucket for all players
                if match.gameMode == 'practice' and Config.AIPractice.useRoutingBucket then
                    SetPlayerRoutingBucket(playerId, 0)
                elseif Config.MatchRoutingBucket.enabled and match.gameMode ~= 'practice' then
                    SetPlayerRoutingBucket(playerId, 0)
                end
                -- Send all players back to main UI
                TriggerClientEvent('paintball:client:leftMatch', playerId)
                TriggerClientEvent('paintball:client:openMainMenu', playerId)
            end
            
            -- Delete the match completely
            ActiveMatches[matchId] = nil
            matchWasDeleted = true
            
            -- Notify all clients to refresh their lobby list
            TriggerClientEvent('paintball:client:refreshLobbies', -1)
        end
    end
    
    -- If match is active and player left, end match if not enough players
    if match.status == 'active' and not isHost then
        local totalPlayers = #match.teams.red + #match.teams.blue
        local minPlayers = match.settings.minPlayers or 2
        if totalPlayers < minPlayers then
            EndMatch(matchId, nil, nil)
        end
    end
    
    -- Notify client to restore state (only if match still exists)
    if not matchWasDeleted and ActiveMatches[matchId] then
        TriggerClientEvent('paintball:client:leftMatch', source)
        
        -- Update remaining players with player names
        local matchWithNames = AddPlayerNamesToMatch(match)
        
        for playerId, _ in pairs(match.players) do
            TriggerClientEvent('paintball:client:updateLobby', playerId, matchWithNames)
        end
        
        -- Notify all clients to refresh their lobby list
        TriggerClientEvent('paintball:client:refreshLobbies', -1)
    else
        -- Match was deleted (host left), notify the leaving player and open main menu
        TriggerClientEvent('paintball:client:leftMatch', source)
        TriggerClientEvent('paintball:client:openMainMenu', source)
        -- Refresh already triggered above when match was deleted
    end
end

-- Start match
local function StartMatch(matchId)
    local match = ActiveMatches[matchId]
    if not match then return false end
    
    local totalPlayers = #match.teams.red + #match.teams.blue
    local minPlayers = match.settings.minPlayers or 2
    if totalPlayers < minPlayers then
        return false
    end
    
    if match.settings.requiresTeams then
    if #match.teams.red == 0 or #match.teams.blue == 0 then
        return false
        end
    end
    
    match.status = 'active'
    match.startTime = os.time()
    
    -- Collect wagers
    local totalWager = 0
    if match.settings.wager and match.settings.wager > 0 then
    for playerId, _ in pairs(match.players) do
            local player = exports.qbx_core:GetPlayer(playerId)
            if player then
                local money = player.PlayerData.money.cash or 0
                if money >= match.settings.wager then
                    player.Functions.RemoveMoney('cash', match.settings.wager, 'paintball-wager')
                    totalWager = totalWager + match.settings.wager
                    match.wagerPaid[playerId] = true
                else
                    RemovePlayerFromMatch(playerId)
                end
            end
        end
        match.totalWager = totalWager
    end
    
    -- Initialize Gun Game levels
    if match.gameMode == 'gungame' then
        for playerId, _ in pairs(match.players) do
            match.gunGameLevels[playerId] = 1
        end
    end
    
    -- Set routing bucket for matches (isolate from other players/cops)
    if match.gameMode == 'practice' and Config.AIPractice.useRoutingBucket then
        -- Practice mode uses its own bucket system
        local bucketId = Config.AIPractice.routingBucket + matchId
        for playerId, _ in pairs(match.players) do
            SetPlayerRoutingBucket(playerId, bucketId)
        end
    elseif Config.MatchRoutingBucket.enabled then
        -- Regular matches use match routing bucket system
        local bucketId = Config.MatchRoutingBucket.baseBucket + matchId
        for playerId, _ in pairs(match.players) do
            SetPlayerRoutingBucket(playerId, bucketId)
        end
    end
    
    -- Assign spawn points for team matches (randomly assign which team gets which spawn)
    if match.settings.requiresTeams and Config.ArenaSpawns.teamSpawns and #Config.ArenaSpawns.teamSpawns >= 2 then
        -- Ensure playerSpawns table exists
        if not match.playerSpawns then
            match.playerSpawns = {}
        end
        
        -- Randomly decide which team gets which spawn (so it's different each match)
        local spawn1 = Config.ArenaSpawns.teamSpawns[1]
        local spawn2 = Config.ArenaSpawns.teamSpawns[2]
        
        -- Random assignment: 50% chance red gets spawn1, 50% chance red gets spawn2
        local redSpawn, blueSpawn
        if math.random() > 0.5 then
            redSpawn = spawn1
            blueSpawn = spawn2
        else
            redSpawn = spawn2
            blueSpawn = spawn1
        end
        
        print(string.format("[Paintball] Team spawn assignment - Red: %.2f,%.2f,%.2f | Blue: %.2f,%.2f,%.2f", 
            redSpawn.x, redSpawn.y, redSpawn.z, blueSpawn.x, blueSpawn.y, blueSpawn.z))
        
        -- Assign spawns to red team players
        for _, playerId in ipairs(match.teams.red) do
            match.playerSpawns[playerId] = redSpawn
            print(string.format("[Paintball] Assigned red spawn to player %d: %.2f,%.2f,%.2f", playerId, redSpawn.x, redSpawn.y, redSpawn.z))
        end
        
        -- Assign spawns to blue team players
        for _, playerId in ipairs(match.teams.blue) do
            match.playerSpawns[playerId] = blueSpawn
            print(string.format("[Paintball] Assigned blue spawn to player %d: %.2f,%.2f,%.2f", playerId, blueSpawn.x, blueSpawn.y, blueSpawn.z))
        end
    end
    
    -- Assign spawn points for 1v1 matches (fixed spawns, not random)
    local isOneVOne = false
    local totalPlayers = 0
    for _ in pairs(match.players) do
        totalPlayers = totalPlayers + 1
    end
    isOneVOne = (totalPlayers == 2) and (match.gameMode == 'ffa' or match.gameMode == 'gungame' or not match.settings.requiresTeams)
    
    if isOneVOne and Config.ArenaSpawns.oneVOneSpawns and #Config.ArenaSpawns.oneVOneSpawns >= 2 then
        local spawnIndex = 1
            for playerId, _ in pairs(match.players) do
            if spawnIndex <= #Config.ArenaSpawns.oneVOneSpawns then
                match.playerSpawns[playerId] = Config.ArenaSpawns.oneVOneSpawns[spawnIndex]
                spawnIndex = spawnIndex + 1
            end
        end
    end
    
    -- Send players to arena
    for playerId, _ in pairs(match.players) do
        TriggerClientEvent('paintball:client:startMatch', playerId, match)
    end
    
    -- Match timer removed - using kill count instead
    
    return true
end

-- End match
function EndMatch(matchId, winner, winnerId)
    local match = ActiveMatches[matchId]
    if not match then return end
    
    match.status = 'ended'
    match.endTime = os.time()
    
    -- Reset routing bucket for all players
    if match.gameMode == 'practice' and Config.AIPractice.useRoutingBucket then
        for playerId, _ in pairs(match.players) do
            SetPlayerRoutingBucket(playerId, 0) -- Return to default dimension
        end
    elseif Config.MatchRoutingBucket.enabled then
        for playerId, _ in pairs(match.players) do
            SetPlayerRoutingBucket(playerId, 0) -- Return to default dimension
        end
    end
    
    -- Distribute wager winnings
    if match.settings.wager and match.settings.wager > 0 and match.totalWager and match.totalWager > 0 then
        if match.gameMode == 'gungame' then
            if winnerId then
                local winner = exports.qbx_core:GetPlayer(winnerId)
                if winner and match.wagerPaid[winnerId] then
                    winner.Functions.AddMoney('cash', match.totalWager, 'paintball-wager-win')
                end
            end
        else
            local winningTeamPlayers = {}
            for pId, pData in pairs(match.players) do
                if match.wagerPaid[pId] then
                    local pTeam = pData.team
                    if winner == pTeam then
                        table.insert(winningTeamPlayers, pId)
                    end
                end
            end
            
            if #winningTeamPlayers > 0 then
                local winningsPerPlayer = math.floor(match.totalWager / #winningTeamPlayers)
                for _, pId in ipairs(winningTeamPlayers) do
                    local p = exports.qbx_core:GetPlayer(pId)
                    if p then
                        p.Functions.AddMoney('cash', winningsPerPlayer, 'paintball-wager-win')
                    end
                end
            end
        end
    end
    
    -- Update player stats
    for playerId, stats in pairs(match.stats) do
        local player = exports.qbx_core:GetPlayer(playerId)
        if player then
            local citizenid = player.PlayerData.citizenid
            if not PlayerStats[citizenid] then
                PlayerStats[citizenid] = {
                    kills = 0,
                    deaths = 0,
                    wins = 0,
                    losses = 0,
                    matches = 0
                }
            end
            
            -- Only count statistics for PvP matches (not practice/AI matches)
            local isPvPMatch = match.gameMode ~= 'practice'
            
            -- Only update leaderboard stats for PvP matches
            if isPvPMatch then
            PlayerStats[citizenid].kills = PlayerStats[citizenid].kills + stats.kills
            PlayerStats[citizenid].deaths = PlayerStats[citizenid].deaths + stats.deaths
            PlayerStats[citizenid].matches = PlayerStats[citizenid].matches + 1
            end
            
            local isWinner = false
            if match.gameMode == 'gungame' then
                isWinner = (winnerId == playerId)
            else
            local playerTeam = match.players[playerId].team
                isWinner = (winner == playerTeam)
            end
            
            if isWinner then
                -- Only count wins for PvP matches
                if isPvPMatch then
                    PlayerStats[citizenid].wins = PlayerStats[citizenid].wins + 1
                end
                if Config.Rewards.enabled then
                    player.Functions.AddMoney('cash', Config.Rewards.winReward, 'paintball-win-reward')
                end
                
                -- Give XP and ranked rating only for PvP matches
                if isPvPMatch then
                    if Config.EnableXPSystem then
                        AddXP(citizenid, Config.XPRewards.matchWin, 'matchWin')
                    end
                    if Config.EnableRankedPvP then
                        UpdateRankedRating(citizenid, 25) -- +25 rating for win
                    end
                end
            else
                -- Only count losses for PvP matches
                if isPvPMatch then
                PlayerStats[citizenid].losses = PlayerStats[citizenid].losses + 1
            end
                
                -- Give XP and ranked rating only for PvP matches
                if isPvPMatch then
                    if Config.EnableXPSystem then
                        AddXP(citizenid, Config.XPRewards.matchLoss, 'matchLoss')
                    end
                    if Config.EnableRankedPvP then
                        UpdateRankedRating(citizenid, -15) -- -15 rating for loss
                    end
                end
            end
        end
    end
    
    -- Notify all players
    for playerId, _ in pairs(match.players) do
        TriggerClientEvent('paintball:client:endMatch', playerId, match, winner, winnerId)
    end
    
    -- Clean up after delay
    SetTimeout(30000, function()
        for playerId, _ in pairs(match.players) do
            RemovePlayerFromMatch(playerId)
        end
        ActiveMatches[matchId] = nil
    end)
end

-- Events
RegisterNetEvent('paintball:server:createLobby', function(settings)
    local source = source
    -- Clean up any existing match first
    if PlayerMatches[source] then
        RemovePlayerFromMatch(source)
    end
    
    local matchId = CreateMatch(source, settings)
    local match = ActiveMatches[matchId]
    
    -- Add host to red team by default
    table.insert(match.teams.red, source)
    match.players[source] = {
        team = 'red',
        kills = 0,
        deaths = 0,
        points = 0
    }
    match.stats[source] = {
        kills = 0,
        deaths = 0,
        kd = 0.00,
        points = 0
    }
    match.gunGameLevels[source] = 1
    PlayerMatches[source] = matchId
    
    -- Set routing bucket for regular matches (not practice mode) when lobby is created
    if Config.MatchRoutingBucket.enabled and match.gameMode ~= 'practice' then
        local bucketId = Config.MatchRoutingBucket.baseBucket + matchId
        SetPlayerRoutingBucket(source, bucketId)
    end
    
    -- Notify all clients to refresh their lobby list when a new lobby is created
    TriggerClientEvent('paintball:client:refreshLobbies', -1)
    
    -- Send progression data immediately with lobby data (no delay)
    UpdatePlayerProgressionDisplay(source)
    
    TriggerClientEvent('paintball:client:joinedLobby', source, match)
end)

RegisterNetEvent('paintball:server:joinTeam', function(matchId, team)
    local source = source
    local success = AddPlayerToMatch(source, matchId, team)
    if success then
        -- Notify all clients to refresh their lobby list when someone joins
        TriggerClientEvent('paintball:client:refreshLobbies', -1)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Failed to join team'
        })
    end
end)

RegisterNetEvent('paintball:server:leaveLobby', function()
    local source = source
    RemovePlayerFromMatch(source)
    -- Notify all clients to refresh their lobby list when someone leaves
    TriggerClientEvent('paintball:client:refreshLobbies', -1)
end)

RegisterNetEvent('paintball:server:startMatch', function(matchId)
    local source = source
    local match = ActiveMatches[matchId]
    if not match then return end
    if match.host ~= source then return end
    
    local success = StartMatch(matchId)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Cannot start match. Check minimum players and teams.'
        })
    end
end)


-- Get player name for client
RegisterNetEvent('paintball:server:getPlayerName', function(targetPlayerId)
    local source = source
    local playerName = GetPlayerDisplayName(targetPlayerId)
    TriggerClientEvent('paintball:client:playerName', source, targetPlayerId, playerName)
end)

RegisterNetEvent('paintball:server:updateSettings', function(matchId, settings)
    local source = source
    local match = ActiveMatches[matchId]
    if not match then return end
    if match.host ~= source then return end
    if match.status ~= 'lobby' then return end
    
    match.settings = settings
    
    -- Create match data with player names
    local matchWithNames = AddPlayerNamesToMatch(match)
    
    -- Update all players in lobby with match data including player names
    for playerId, _ in pairs(match.players) do
        -- Send progression data immediately with lobby update (no delay)
        UpdatePlayerProgressionDisplay(playerId)
        TriggerClientEvent('paintball:client:updateLobby', playerId, matchWithNames)
    end
end)

-- Give XP for kill
local function GiveKillXP(killerId, wasHeadshot, killStreak)
    if not Config.EnableXPSystem then return end
    
    local killer = exports.qbx_core:GetPlayer(killerId)
    if not killer then return end
    
    local citizenid = killer.PlayerData.citizenid
    local xpAmount = wasHeadshot and Config.XPRewards.headshot or Config.XPRewards.kill
    
    -- Add kill streak bonus
    if killStreak and Config.XPRewards.killStreak[killStreak] then
        xpAmount = xpAmount + Config.XPRewards.killStreak[killStreak]
    end
    
    AddXP(citizenid, xpAmount, wasHeadshot and 'headshot' or 'kill')
end

RegisterNetEvent('paintball:server:playerKilled', function(killerId)
    local source = source
    local matchId = PlayerMatches[source]
    if not matchId then return end
    
    local match = ActiveMatches[matchId]
    if not match or match.status ~= 'active' then return end
    
    local victimData = match.players[source]
    local killerData = match.players[killerId]
    if not victimData or not killerData then return end
    
    -- Prevent friendly fire (same team kills) for team-based game modes
    if match.gameMode ~= 'ffa' and match.gameMode ~= 'gungame' and match.gameMode ~= 'practice' then
        if victimData.team == killerData.team then
            -- Friendly fire attempted - notify killer but don't process kill
            TriggerClientEvent('ox_lib:notify', killerId, {
                title = 'Friendly Fire',
                description = 'You cannot damage your teammates!',
                type = 'error',
                duration = 3000
            })
            return
        end
    end
    
    match.stats[killerId].kills = match.stats[killerId].kills + 1
    match.stats[source].deaths = match.stats[source].deaths + 1
    
    -- Only give XP for kills in PvP matches (not practice/AI matches)
    local isPvPMatch = match.gameMode ~= 'practice'
    if isPvPMatch and Config.EnableXPSystem and match.stats[killerId] then
        local killStreak = match.stats[killerId].killStreak or 0
        GiveKillXP(killerId, false, killStreak) -- TODO: Pass headshot info from client
    end
    
    if match.stats[killerId].deaths > 0 then
        match.stats[killerId].kd = match.stats[killerId].kills / match.stats[killerId].deaths
    else
        match.stats[killerId].kd = match.stats[killerId].kills
    end
    
    if match.stats[source].deaths > 0 then
        match.stats[source].kd = match.stats[source].kills / match.stats[source].deaths
    else
        match.stats[source].kd = match.stats[source].kills
    end
    
    if match.gameMode ~= 'ffa' and match.gameMode ~= 'practice' then
    match.scores[killerData.team] = match.scores[killerData.team] + 1
    end
    match.stats[killerId].points = match.stats[killerId].points + 100
    
    if Config.Rewards.enabled then
        local killer = exports.qbx_core:GetPlayer(killerId)
        if killer then
            killer.Functions.AddMoney('cash', Config.Rewards.killReward, 'paintball-kill-reward')
        end
    end
    
    -- Gun Game logic
    if match.gameMode == 'gungame' then
        local currentLevel = match.gunGameLevels[killerId] or 1
        if currentLevel < #Config.GunGameWeapons then
            match.gunGameLevels[killerId] = currentLevel + 1
            TriggerClientEvent('paintball:client:giveWeapon', killerId, Config.GunGameWeapons[match.gunGameLevels[killerId]], match.gunGameLevels[killerId])
        else
            EndMatch(matchId, 'gungame', killerId)
            return
        end
    end
    
    -- AI Practice Mode
    if match.gameMode == 'practice' then
        match.scores.red = match.stats[killerId].kills
        if match.scores.red >= match.settings.maxScore then
            EndMatch(matchId, 'practice', killerId)
            return
        end
    end
    
    -- Check win condition based on kill count (not timer)
    local killCount = match.settings.killCount or Config.MatchSettings.defaultKillCount
    
    if match.gameMode == 'ffa' or match.gameMode == 'gungame' then
        -- FFA/Gun Game: Check individual player kills
        if match.stats[killerId].kills >= killCount then
            EndMatch(matchId, match.gameMode == 'gungame' and 'gungame' or 'ffa', killerId)
            return
        end
    elseif match.gameMode ~= 'practice' then
        -- Team modes: Check team score
        if match.scores[killerData.team] >= killCount then
            EndMatch(matchId, killerData.team, nil)
            return
        end
    end
    
    for playerId, _ in pairs(match.players) do
        TriggerClientEvent('paintball:client:updateScoreboard', playerId, match)
    end
    
    -- Check if all players on a team are dead (for team matches)
    if match.settings.requiresTeams and match.gameMode ~= 'practice' then
        local victimTeam = victimData.team
        local allTeamDead = true
        
        -- Check if all players on the victim's team are dead (have at least 1 death)
        for _, playerId in ipairs(match.teams[victimTeam]) do
            if match.stats[playerId] and match.stats[playerId].deaths == 0 then
                -- This player hasn't died yet, so team is not all dead
                allTeamDead = false
                break
            end
        end
        
        -- If all players on the victim's team are now dead, trigger round reset
        if allTeamDead then
            -- Show round reset countdown for all players
            for playerId, _ in pairs(match.players) do
                TriggerClientEvent('paintball:client:roundReset', playerId, match, Config.MatchSettings.respawnTime)
            end
            
            -- Wait for respawn time then reset round
            SetTimeout(Config.MatchSettings.respawnTime * 1000, function()
                local match = ActiveMatches[matchId]
                if not match or match.status ~= 'active' then 
                    print(string.format("[Paintball DEBUG] Round reset timeout: Match %s not found or not active", matchId))
                    return 
                end
                
                print(string.format("[Paintball DEBUG] Round reset: Resetting round for match %s, %d players", matchId, #match.teams.red + #match.teams.blue))
                
                -- Clear death status for ALL players on server-side FIRST (before respawning)
                -- This ensures all players (red and blue) are revived, not just dead ones
                for playerId, _ in pairs(match.players) do
                    print(string.format("[Paintball DEBUG] Round reset: Clearing death status for player %d", playerId))
                    -- Clear death status in wasabi_ambulance if available (CRITICAL - must be done first)
                    if GetResourceState('wasabi_ambulance') == 'started' then
                        -- Trigger client event to clear death status on each player's client
                        TriggerClientEvent('wasabi_ambulance:setDeathStatus', playerId, false, true)
                        print(string.format("[Paintball DEBUG] Round reset: Sent wasabi_ambulance:setDeathStatus to player %d", playerId))
                    end
                    
                    -- Reset deaths for all players (they're respawning - both red and blue teams)
                    if match.stats[playerId] then
                        local oldDeaths = match.stats[playerId].deaths
                        match.stats[playerId].deaths = 0
                        print(string.format("[Paintball DEBUG] Round reset: Reset deaths for player %d (was %d, now 0)", playerId, oldDeaths))
                    end
                end
                
                -- Respawn ALL players at their original spawn points (both red and blue teams)
                local respawnCount = 0
                -- First, ensure all players have spawns assigned (fallback to team spawns if missing)
                for playerId, playerData in pairs(match.players) do
                    if not match.playerSpawns[playerId] then
                        -- Player doesn't have a spawn assigned, assign one from their team
                        local team = playerData.team
                        if team and Config.ArenaSpawns.teamSpawns and #Config.ArenaSpawns.teamSpawns >= 2 then
                            local teamSpawns = Config.ArenaSpawns.teamSpawns[team == 'red' and 1 or 2]
                            if teamSpawns and #teamSpawns > 0 then
                                -- Pick a random spawn from team spawns
                                local randomSpawn = teamSpawns[math.random(#teamSpawns)]
                                match.playerSpawns[playerId] = randomSpawn
                                print(string.format("[Paintball DEBUG] Round reset: Assigned spawn to player %d (team: %s)", playerId, team))
                            end
                        end
                    end
                end
                
                -- Now respawn ALL players (both red and blue teams)
                for playerId, spawn in pairs(match.playerSpawns) do
                    if match.players[playerId] then
                        print(string.format("[Paintball DEBUG] Round reset: Sending roundRespawn to player %d at spawn %.2f, %.2f, %.2f", playerId, spawn.x, spawn.y, spawn.z))
                        print(string.format("[Paintball DEBUG] Round reset: Player %d - match.id=%s, match.status=%s", playerId, tostring(match.id), tostring(match.status)))
                        -- Send minimal match data to avoid serialization issues
                        local matchData = {
                            id = match.id,
                            gameMode = match.gameMode,
                            settings = match.settings,
                            gunGameLevels = match.gunGameLevels,
                            players = match.players
                        }
                        TriggerClientEvent('paintball:client:roundRespawn', playerId, matchData, spawn)
                        print(string.format("[Paintball DEBUG] Round reset: roundRespawn event sent to player %d", playerId))
                        respawnCount = respawnCount + 1
                    else
                        print(string.format("[Paintball DEBUG] Round reset: WARNING - Player %d has spawn but not in match.players", playerId))
                    end
                end
                
                -- Also respawn any players who don't have spawns in playerSpawns (safety fallback)
                for playerId, playerData in pairs(match.players) do
                    if not match.playerSpawns[playerId] then
                        -- Fallback: use team spawn
                        local team = playerData.team
                        if team and Config.ArenaSpawns.teamSpawns and #Config.ArenaSpawns.teamSpawns >= 2 then
                            local teamSpawns = Config.ArenaSpawns.teamSpawns[team == 'red' and 1 or 2]
                            if teamSpawns and #teamSpawns > 0 then
                                local randomSpawn = teamSpawns[math.random(#teamSpawns)]
                                local matchData = {
                                    id = match.id,
                                    gameMode = match.gameMode,
                                    settings = match.settings,
                                    gunGameLevels = match.gunGameLevels,
                                    players = match.players
                                }
                                TriggerClientEvent('paintball:client:roundRespawn', playerId, matchData, randomSpawn)
                                print(string.format("[Paintball DEBUG] Round reset: Sent roundRespawn to player %d (fallback spawn)", playerId))
                                respawnCount = respawnCount + 1
                            end
                        end
                    end
                end
                
                print(string.format("[Paintball DEBUG] Round reset: Sent roundRespawn to %d players", respawnCount))
                
                -- Update scoreboard after respawn
                for playerId, _ in pairs(match.players) do
                    TriggerClientEvent('paintball:client:updateScoreboard', playerId, match)
    end
end)

            return -- Don't do 1v1 round reset if we already did team round reset
        end
    end
    
    -- For 1v1 matches (2 players total), trigger round reset after 5 seconds
    local totalPlayers = 0
    for _ in pairs(match.players) do
        totalPlayers = totalPlayers + 1
    end
    -- Check if it's a 1v1 match (2 players total, regardless of game mode)
    local isOneVOne = (totalPlayers == 2) and match.gameMode ~= 'practice'
    
    if isOneVOne then
        -- Ensure match data includes player names for UI display
        AddPlayerNamesToMatch(match)
        
        -- Show round reset countdown for all players
        for playerId, _ in pairs(match.players) do
            TriggerClientEvent('paintball:client:roundReset', playerId, match, Config.MatchSettings.respawnTime)
        end
        
        -- Wait for respawn time then reset round
        SetTimeout(Config.MatchSettings.respawnTime * 1000, function()
            local match = ActiveMatches[matchId]
            if not match or match.status ~= 'active' then return end
            
            -- Clear death status for ALL players on server-side (for external death systems)
            for playerId, _ in pairs(match.players) do
                -- Clear death status in wasabi_ambulance if available
                if GetResourceState('wasabi_ambulance') == 'started' then
                    TriggerClientEvent('wasabi_ambulance:setDeathStatus', playerId, false, true)
                end
                
                -- Reset deaths for all players (they're respawning)
                if match.stats[playerId] then
                    match.stats[playerId].deaths = 0
                end
            end
            
            -- For 1v1 matches, randomly reassign spawn points each round
            if Config.ArenaSpawns.oneVOneSpawns and #Config.ArenaSpawns.oneVOneSpawns >= 2 then
                -- Shuffle spawn points randomly
                local shuffledSpawns = {}
                for i = 1, #Config.ArenaSpawns.oneVOneSpawns do
                    table.insert(shuffledSpawns, Config.ArenaSpawns.oneVOneSpawns[i])
                end
                -- Simple shuffle: swap each element with a random one
                for i = #shuffledSpawns, 2, -1 do
                    local j = math.random(i)
                    shuffledSpawns[i], shuffledSpawns[j] = shuffledSpawns[j], shuffledSpawns[i]
                end
                
                -- Assign random spawns to players
                local spawnIndex = 1
                for playerId, _ in pairs(match.players) do
                    if spawnIndex <= #shuffledSpawns then
                        match.playerSpawns[playerId] = shuffledSpawns[spawnIndex]
                        spawnIndex = spawnIndex + 1
                    end
                end
            end
            
            -- Respawn ALL players at their (newly assigned) spawn points
            for playerId, spawn in pairs(match.playerSpawns) do
                if match.players[playerId] then
                    print(string.format("[Paintball DEBUG] Round reset (1v1): Sending roundRespawn to player %d at spawn %.2f, %.2f, %.2f", playerId, spawn.x, spawn.y, spawn.z))
                    -- Send minimal match data to avoid serialization issues
                    local matchData = {
                        id = match.id,
                        gameMode = match.gameMode,
                        settings = match.settings,
                        gunGameLevels = match.gunGameLevels,
                        players = match.players
                    }
                    TriggerClientEvent('paintball:client:roundRespawn', playerId, matchData, spawn)
                    print(string.format("[Paintball DEBUG] Round reset (1v1): roundRespawn event sent to player %d", playerId))
                end
            end
            
            -- Update scoreboard after respawn (with player names)
            AddPlayerNamesToMatch(match)
            for playerId, _ in pairs(match.players) do
                TriggerClientEvent('paintball:client:updateScoreboard', playerId, match)
            end
        end)
    end
end)

RegisterNetEvent('paintball:server:requestRespawn', function()
    local source = source
    local matchId = PlayerMatches[source]
    if not matchId then return end
    
    local match = ActiveMatches[matchId]
    if not match or match.status ~= 'active' then return end
    
    TriggerClientEvent('paintball:client:respawn', source, match)
end)

-- Vote to end match (voteType: 'yes' or 'no')
RegisterNetEvent('paintball:server:voteEndMatch', function(matchId, voteType)
    local source = source
    local match = ActiveMatches[matchId]
    if not match then return end
    if match.status ~= 'active' then return end
    if not match.players[source] then return end
    if voteType ~= 'yes' and voteType ~= 'no' then return end
    
    -- Record vote
    match.endVotes[source] = voteType
    
    -- Count total players and votes
    local totalPlayers = 0
    local yesVotes = 0
    local noVotes = 0
    local totalVotes = 0
    for playerId, _ in pairs(match.players) do
        totalPlayers = totalPlayers + 1
        if match.endVotes[playerId] then
            totalVotes = totalVotes + 1
            if match.endVotes[playerId] == 'yes' then
                yesVotes = yesVotes + 1
            elseif match.endVotes[playerId] == 'no' then
                noVotes = noVotes + 1
            end
        end
    end
    
    -- Update all players with vote status
    for playerId, _ in pairs(match.players) do
        TriggerClientEvent('paintball:client:updateScoreboard', playerId, match)
    end
    
    -- If all players voted YES, end the match
    if totalVotes >= totalPlayers and totalPlayers > 0 and yesVotes == totalPlayers then
        -- End match with no winner (mutual agreement to end)
        EndMatch(matchId, nil, nil)
    elseif totalVotes >= totalPlayers and noVotes > 0 then
        -- All players voted, but at least one voted NO - match continues
        for playerId, _ in pairs(match.players) do
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = 'Match Vote',
                description = string.format('Vote failed: %d voted yes, %d voted no. Match continues.', yesVotes, noVotes),
                type = 'error'
            })
        end
        -- Clear votes so players can vote again if needed
        match.endVotes = {}
        -- Update scoreboard to clear vote status
        for playerId, _ in pairs(match.players) do
            TriggerClientEvent('paintball:client:updateScoreboard', playerId, match)
        end
    else
        -- Notify players of vote status
        for playerId, _ in pairs(match.players) do
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = 'Match Vote',
                description = string.format('%d/%d players voted (%d yes, %d no)', totalVotes, totalPlayers, yesVotes, noVotes),
                type = 'inform'
            })
        end
    end
end)

RegisterNetEvent('paintball:server:createPracticeMatch', function(settings)
    local source = source
    
    -- Clean up any existing match first
    if PlayerMatches[source] then
    RemovePlayerFromMatch(source)
    end
    
    -- Set routing bucket for practice mode (separate dimension)
    if Config.AIPractice.useRoutingBucket then
        SetPlayerRoutingBucket(source, Config.AIPractice.routingBucket)
    end
    
    -- Use weapon from settings if provided, otherwise use default
    local weapon = Config.MatchSettings.defaultWeapon
    local weaponName = 'Pistol'
    local killTarget = 30
    local difficulty = 'medium'
    local botCount = 45 -- Default middle of medium range
    local botCountEnabled = true
    local killTargetEnabled = false
    local waveMode = false
    local waveSize = 5
    local timeLimit = 10
    local timeLimitEnabled = false
    local aiMode = 'none' -- Default to Free Play
    
    if settings and settings.aiMode then
        aiMode = settings.aiMode
    end
    
    if settings and settings.weapon then
        weapon = settings.weapon
        weaponName = settings.weaponName or 'Pistol'
    end
    if settings and settings.killTarget then
        killTarget = settings.killTarget
    end
    if settings and settings.difficulty then
        difficulty = settings.difficulty
    end
    if settings and settings.botCount then
        botCount = settings.botCount
    end
    if settings and settings.botCountEnabled ~= nil then
        botCountEnabled = settings.botCountEnabled
    end
    if settings and settings.killTargetEnabled ~= nil then
        killTargetEnabled = settings.killTargetEnabled
    end
    if settings and settings.waveMode ~= nil then
        waveMode = settings.waveMode
    end
    if settings and settings.waveSize then
        waveSize = settings.waveSize
    end
    if settings and settings.timeLimit then
        timeLimit = settings.timeLimit
    end
    if settings and settings.timeLimitEnabled ~= nil then
        timeLimitEnabled = settings.timeLimitEnabled
    end
    
    -- Get health system settings
    local healthSystem = nil
    local healthSystemEnabled = false
    local healthPerKill = 0
    local armorPerKill = 0
    
    if settings and settings.healthSystem then
        healthSystem = settings.healthSystem
    end
    if settings and settings.healthSystemEnabled ~= nil then
        healthSystemEnabled = settings.healthSystemEnabled
    end
    if settings and settings.healthPerKill then
        healthPerKill = settings.healthPerKill
    end
    if settings and settings.armorPerKill then
        armorPerKill = settings.armorPerKill
    end
    
    local matchId = CreateMatch(source, {
        gameMode = 'practice',
        gameModeName = 'Practice Mode (AI)',
        matchTime = 30,
        wager = 0,
        weapon = weapon,
        weaponName = weaponName,
        maxScore = killTargetEnabled and killTarget or 999999, -- Use killTarget if enabled, otherwise very high number
        difficulty = difficulty, -- Store difficulty
        botCount = botCount, -- Store bot count
        botCountEnabled = botCountEnabled, -- Store bot count enabled flag
        killTargetEnabled = killTargetEnabled, -- Store kill target enabled flag
        waveMode = waveMode, -- Store wave mode
        waveSize = waveSize, -- Store wave size
        timeLimit = timeLimit, -- Store time limit
        timeLimitEnabled = timeLimitEnabled, -- Store time limit enabled flag
        aiMode = aiMode, -- Store AI mode ('none', 'killtarget', 'wave', 'timelimit')
        healthSystem = healthSystem, -- Store health system type
        healthSystemEnabled = healthSystemEnabled, -- Store health system enabled flag
        healthPerKill = healthPerKill, -- Store health per kill amount
        armorPerKill = armorPerKill, -- Store armor per kill amount
        minPlayers = 1,
        requiresTeams = false
    })
    
    local match = ActiveMatches[matchId]
    table.insert(match.teams.red, source)
    match.players[source] = {
        team = 'red',
        kills = 0,
        deaths = 0,
        points = 0
    }
    match.stats[source] = {
        kills = 0,
        deaths = 0,
        kd = 0.00,
        points = 0
    }
    PlayerMatches[source] = matchId
    
    match.status = 'active'
    match.startTime = os.time()
    
    TriggerClientEvent('paintball:client:startMatch', source, match)
end)

RegisterNetEvent('paintball:server:aiKilled', function(aiPed)
    local source = source
    local matchId = PlayerMatches[source]
    if not matchId then return end
    
    local match = ActiveMatches[matchId]
    if not match or match.status ~= 'active' then return end
    if match.gameMode ~= 'practice' then return end
    
    if not match.stats[source] then
        match.stats[source] = {
            kills = 0,
            deaths = 0,
            kd = 0.00,
            points = 0
        }
    end
    
    match.stats[source].kills = match.stats[source].kills + 1
    match.stats[source].points = match.stats[source].points + 100
    
    -- NO XP for practice/AI matches - XP is only given in PvP matches (1v1, team matches, etc.)
    match.scores.red = match.stats[source].kills
    
    TriggerClientEvent('paintball:client:updateScoreboard', source, match)
    
    -- Check if kill target is reached (only if killTargetEnabled is true)
    local killTarget = match.settings.killTarget or match.settings.maxScore
    local killTargetEnabled = match.settings.killTargetEnabled
    
    if killTargetEnabled and match.scores.red >= killTarget then
        EndMatch(matchId, 'practice', source)
    end
end)

-- Get player progression (always returns current data instantly, no caching, no delays)
RegisterNetEvent('paintball:server:getProgression', function()
    local src = source
    -- Update progression display immediately with current data (instant, no waits)
    UpdatePlayerProgressionDisplay(src)
end)

-- Update lobby kills to win
RegisterNetEvent('paintball:server:updateLobbyKills', function(matchId, kills)
    local source = source
    local match = ActiveMatches[matchId]
    
    if not match or match.status ~= 'lobby' then return end
    if match.host ~= source then return end -- Only host can change settings
    
    -- Validate kills (5, 10, 15, 20)
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
    
    match.settings.killCount = kills
    
    -- Create match data with player names
    local matchWithNames = AddPlayerNamesToMatch(match)
    
    -- Update all players in lobby with match data including player names
    for playerId, _ in pairs(match.players) do
        -- Send progression data immediately with lobby update (no delay)
        UpdatePlayerProgressionDisplay(playerId)
        TriggerClientEvent('paintball:client:updateLobby', playerId, matchWithNames)
    end
end)

-- Update lobby wager amount
RegisterNetEvent('paintball:server:updateLobbyWager', function(matchId, wager)
    local source = source
    local match = ActiveMatches[matchId]
    
    if not match or match.status ~= 'lobby' then return end
    if match.host ~= source then return end -- Only host can change settings
    
    if wager < 0 then
        wager = 0
    end
    
    match.settings.wager = wager
    
    -- Create match data with player names
    local matchWithNames = AddPlayerNamesToMatch(match)
    
    -- Update all players in lobby with match data including player names
    for playerId, _ in pairs(match.players) do
        -- Send progression data immediately with lobby update (no delay)
        UpdatePlayerProgressionDisplay(playerId)
        TriggerClientEvent('paintball:client:updateLobby', playerId, matchWithNames)
    end
end)

RegisterNetEvent('paintball:server:getLeaderboard', function()
    local source = source
    
    -- Convert PlayerStats to sorted array with calculated stats
    local leaderboardData = {}
    for citizenid, stats in pairs(PlayerStats) do
        -- Calculate K/D ratio
        local kd = 0.00
        if stats.deaths > 0 then
            kd = stats.kills / stats.deaths
        elseif stats.kills > 0 then
            kd = stats.kills
        end
        
        -- Calculate W/L ratio
        local wl = 0.00
        if stats.losses > 0 then
            wl = stats.wins / stats.losses
        elseif stats.wins > 0 then
            wl = stats.wins
        end
        
        -- Calculate win rate
        local winRate = 0.00
        local totalGames = stats.wins + stats.losses
        if totalGames > 0 then
            winRate = (stats.wins / totalGames) * 100
        end
        
        -- Get player name if online
        local playerName = nil
        for _, player in pairs(exports.qbx_core:GetQBPlayers()) do
            if player and player.PlayerData and player.PlayerData.citizenid == citizenid then
                if player.PlayerData.charinfo then
                    playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
                else
                    playerName = player.PlayerData.name
                end
                break
            end
        end
        
        -- Get player progression data (prestige, level, rank)
        local prog = GetPlayerProgression(citizenid)
        local rank = GetPlayerRank(prog.rankedRating)
        local prestigeData = nil
        if Config.PrestigeSystem.enabled and prog.prestigeLevel > 0 then
            prestigeData = Config.PrestigeSystem.prestigeRewards[prog.prestigeLevel]
        end
        
        table.insert(leaderboardData, {
            citizenid = citizenid,
            name = playerName or 'Unknown',
            kills = stats.kills or 0,
            deaths = stats.deaths or 0,
            kd = kd,
            wins = stats.wins or 0,
            losses = stats.losses or 0,
            wl = wl,
            winRate = winRate,
            matches = stats.matches or 0,
            totalGames = totalGames,
            -- Progression data
            level = prog.level or 1,
            prestige = prog.prestigeLevel or 0,
            prestigeTitle = prestigeData and prestigeData.title or nil,
            prestigeIcon = prestigeData and prestigeData.icon or nil,
            rank = rank and rank.name or "Unranked",
            rankInsignia = rank and rank.insignia or "🎖️",
            rankedRating = Config.EnableRankedPvP and prog.rankedRating or nil
        })
    end
    
    -- Sort by K/D ratio (descending), then by kills (descending)
    table.sort(leaderboardData, function(a, b)
        if a.kd ~= b.kd then
            return a.kd > b.kd
        end
        return a.kills > b.kills
    end)
    
    TriggerClientEvent('paintball:client:showLeaderboard', source, leaderboardData)
end)

-- Get active lobbies for browser
RegisterNetEvent('paintball:server:getActiveLobbies', function()
    local source = source
    local lobbies = {}
    local playerCurrentMatch = PlayerMatches[source] -- Get player's current match (if any)
    
    for matchId, match in pairs(ActiveMatches) do
        -- Only show lobbies (not active matches) and exclude the player's own lobby
        if match.status == 'lobby' and matchId ~= playerCurrentMatch then
            -- Check if host still exists (player might have disconnected)
            local hostPlayer = exports.qbx_core:GetPlayer(match.host)
            if not hostPlayer then
                -- Host disconnected, skip this lobby (it should be cleaned up)
                goto continue
            end
            local hostName = GetPlayerDisplayName(match.host)
            
            local totalPlayers = 0
            local redCount = 0
            local blueCount = 0
            local playerList = {}
            
            -- Count players in each team
            for _, playerId in ipairs(match.teams.red) do
                totalPlayers = totalPlayers + 1
                redCount = redCount + 1
                local player = exports.qbx_core:GetPlayer(playerId)
                if player then
                    table.insert(playerList, {
                        id = playerId,
                        name = GetPlayerDisplayName(playerId),
                        team = 'red'
                    })
                end
            end
            
            for _, playerId in ipairs(match.teams.blue) do
                totalPlayers = totalPlayers + 1
                blueCount = blueCount + 1
                local player = exports.qbx_core:GetPlayer(playerId)
                if player then
                    table.insert(playerList, {
                        id = playerId,
                        name = GetPlayerDisplayName(playerId),
                        team = 'blue'
                    })
                end
            end
            
            table.insert(lobbies, {
                id = matchId,
                host = match.host,
                hostName = hostName,
                gameMode = match.gameModeName or match.settings.gameModeName or 'Unknown',
                weapon = match.settings.weaponName or 'Unknown',
                wager = match.settings.wager or 0,
                killCount = match.settings.killCount or 3,
                maxScore = match.settings.maxScore or 30,
                matchTime = match.settings.matchTime or 30,
                totalPlayers = totalPlayers,
                maxPlayers = match.settings.minPlayers and (match.settings.minPlayers * 2) or 24,
                redCount = redCount,
                blueCount = blueCount,
                players = playerList,
                requiresTeams = match.settings.requiresTeams or false
            })
        end
        ::continue::
    end
    
    TriggerClientEvent('paintball:client:receiveActiveLobbies', source, lobbies)
end)

-- Join an existing lobby
RegisterNetEvent('paintball:server:joinLobby', function(matchId)
    local source = source
    local match = ActiveMatches[matchId]
    
    if not match then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Lobby not found',
            type = 'error'
        })
        return
    end
    
    if match.status ~= 'lobby' then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Match has already started',
            type = 'error'
        })
        return
    end
    
    -- Check if player is already in a match
    if PlayerMatches[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'You are already in a match',
            type = 'error'
        })
        return
    end
    
    -- Auto-assign to team with fewer players
    local team = 'red'
    if #match.teams.blue < #match.teams.red then
        team = 'blue'
    end
    
        if AddPlayerToMatch(source, matchId, team) then
        -- Set routing bucket for regular matches (not practice mode) when joining lobby
        if Config.MatchRoutingBucket.enabled and match.gameMode ~= 'practice' then
            local bucketId = Config.MatchRoutingBucket.baseBucket + matchId
            SetPlayerRoutingBucket(source, bucketId)
        end
        
        -- Add player names to match data before sending
        local matchWithNames = {}
        -- Create match data with player names
        local matchWithNames = AddPlayerNamesToMatch(match)
        
        -- Send progression data immediately with lobby join (no delay)
        UpdatePlayerProgressionDisplay(source)
        
        TriggerClientEvent('paintball:client:joinedLobby', source, matchWithNames)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Error',
            description = 'Failed to join lobby',
            type = 'error'
        })
    end
end)

-- Cleanup on player disconnect
AddEventHandler('playerDropped', function()
    local source = source
    -- Reset routing bucket
    SetPlayerRoutingBucket(source, 0)
    RemovePlayerFromMatch(source)
end)
