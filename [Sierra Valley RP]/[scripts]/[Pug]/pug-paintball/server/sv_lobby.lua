local function switchModeKeepPlayers(lobby, newMode)
    local toFFA  = IsFreeForAllGameMode(newMode)
    local ffaCap = 24

    lobby.mode = newMode

    lobby.scores.red, lobby.scores.blue = 0, 0

    if toFFA then
        lobby.placements.red, lobby.placements.blue = 0, 0
        for pid in pairs(lobby.red)  do SetRemove(lobby.red,  pid) end
        for pid in pairs(lobby.blue) do SetRemove(lobby.blue, pid) end

        for pid in pairs(lobby.ffa) do
            SetRemove(lobby.ffa, pid)
        end
        lobby.placements.ffa = 0

        for pid in pairs(lobby.all) do
            local ok, err = joinTeam(lobby, pid, 'ffa')

            if ok then
                TriggerClientEvent('Pug:paintball:joinedTeam', pid, "ffa", lobby.placements.ffa)
            else
                SetAdd(lobby.spec, pid)
                if err == "full" then
                    TriggerClientEvent(
                        'Pug:client:PaintballNotifyEvent',
                        pid,
                        Config.Translations.menu.ffa_full_spectate,
                        'error'
                    )
                else
                    TriggerClientEvent(
                        'Pug:client:PaintballNotifyEvent',
                        pid,
                        Config.Translations.menu.ffa_move_fail_spectate,
                        'error'
                    )
                end
            end
        end

    else
        for pid in pairs(lobby.ffa) do
            SetRemove(lobby.ffa, pid)
            SetAdd(lobby.spec, pid)
        end
        lobby.placements.ffa = 0
    end
end

function LobbyManager.getOrCreate(id)
    if not Lobbies[id] then Lobbies[id] = newLobby(id) end
    return Lobbies[id]
end
function LobbyManager.ofPlayer(src)
    local id = PlayerLobby[src]
    return id and Lobbies[id] or nil, id
end

function LobbyDirty(lobby)
    if not lobby then return end
    for pid in pairs(lobby.all) do
        TriggerClientEvent('Pug:client:LobbyDirty', pid, lobby.id)
    end
end


function destroyLobby(lobbyId)
    local L = Lobbies[lobbyId]
    if not L then return end

    for pid in pairs(L.all) do
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            pid,
            string.format(Config.Translations.menu.lobby_shutdown_by_host, lobbyId),
            'error'
        )
        TriggerClientEvent('Pug:paintball:removeFromArena', pid)
        AddRadio(pid, true)
        SetPlayerRoutingBucket(pid, 0)
        PlayerLobby[pid] = nil
    end

    if L.redFlagEntity and DoesEntityExist(L.redFlagEntity) then DeleteEntity(L.redFlagEntity) end
    if L.blueFlagEntity and DoesEntityExist(L.blueFlagEntity) then DeleteEntity(L.blueFlagEntity) end

    Lobbies[lobbyId] = nil
end

RegisterNetEvent("Pug:Lobby:LeaveLobby", function()
    local src = source

    local L, lobbyId = LobbyManager.ofPlayer(src)

    if not L or not lobbyId then
        TriggerClientEvent('Pug:client:OpenPaintballHUB', src, {})
        return
    end


    SetRemove(L.red,  src)
    SetRemove(L.blue, src)
    SetRemove(L.ffa,  src)
    SetRemove(L.spec, src)
    removeFromAll(L, src)
    L.access[src] = nil

    if PlayerLobby[src] == lobbyId then
        PlayerLobby[src] = nil
    end

    TriggerClientEvent(
        'Pug:client:PaintballNotifyEvent',
        src,
        string.format(Config.Translations.menu.left_lobby_message, lobbyId)
    )
    TriggerClientEvent("Pug:client:OpenPaintballHUB", src, {})

    if L.host == src then
        if HostLobbyBySrc[src] == lobbyId then HostLobbyBySrc[src] = nil end

        local nextHost = pickAnyMember(L, src)
        if nextHost then
            L.host = nextHost
            HostLobbyBySrc[nextHost] = lobbyId
            L.access[nextHost] = true
            TriggerClientEvent(
                'Pug:client:PaintballNotifyEvent',
                nextHost,
                Config.Translations.menu.host_now
            )
            TriggerClientEvent("Pug:client:DoLobbyHostLoop", nextHost)
        else
            destroyLobby(lobbyId)
            return
        end
    end


    LobbyDirty(L)
end)


RegisterNetEvent("Pug:paintball:HostTooFar", function()
    local src = source
    local lobby, lobbyId = LobbyManager.ofPlayer(src)
    if not lobby or lobby.host ~= src then return end
    if lobby.started then return end

    if HostLobbyBySrc[src] == lobbyId then HostLobbyBySrc[src] = nil end

    local nextHost = pickAnyMember(lobby, src)
    if nextHost then
        lobby.host = nextHost
        HostLobbyBySrc[nextHost] = lobbyId
        lobby.access[nextHost] = true
        leaveTeam(lobby, src)

        TriggerClientEvent("Pug:client:StopLobbyHostLoop", src)
        TriggerClientEvent("Pug:client:DoLobbyHostLoop",   nextHost)
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            nextHost,
            Config.Translations.menu.host_now
        )
        LobbyDirty(lobby)
    else
        destroyLobby(lobbyId)
    end
end)


RegisterServerEvent('Pug:paintball:JoinTeam', function(team, lobbyId)
    local src = source
    if not lobbyId then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.no_lobby_specified,
            'error'
        )
        return
    end


    local lobby = Lobbies[tonumber(lobbyId)]
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.lobby_no_longer_exists_refresh,
            'error'
        )
        TriggerClientEvent("Pug:client:OpenPaintballHUB", src, {})
        return
    end

    if lobby.locked and not (lobby.access[src] or lobby.host == src) then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.lobby_locked_passcode,
            'error'
        )
        return
    end

    local ok, err = joinTeam(lobby, src, team)
    local P = getPlayer(src)
    if not ok then
        local msg = (err == "full")
            and Config.Translations.error.team_full
            or Config.Translations.error.join_failed

        TriggerClientEvent('Pug:client:PaintballNotifyEvent', src, msg, 'error')
        return
    end


    local joinedMsg
    if IsFreeForAllGameMode(lobby.mode) then
        local pname = P and (P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname) or ("Player "..src)
        joinedMsg = string.format(Config.Translations.menu.joined_game_message, pname)
        TriggerClientEvent('Pug:paintball:joinedTeam', src, "ffa", lobby.placements.ffa)
    else
        local pname = P and (P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname) or ("Player "..src)
        if team == 'redteam' then
            joinedMsg = string.format(Config.Translations.menu.joined_red_team_message, pname)
            TriggerClientEvent('Pug:paintball:joinedTeam', src, 'redteam', lobby.placements.red)
        else
            joinedMsg = string.format(Config.Translations.menu.joined_blue_team_message, pname)
            TriggerClientEvent('Pug:paintball:joinedTeam', src, 'blueteam', lobby.placements.blue)
        end
    end

    if Config.HostOnlyCanControllWeaponSelect and lobby.weapon then
        TriggerClientEvent("Pug:client:SetAllPlayersWeapons", src, lobby.weapon)
    end


    broadcast(lobby, 'Pug:client:PaintballNotifyEvent', joinedMsg)
    LobbyDirty(lobby)
end)

RegisterServerEvent('Pug:paintball:Leave', function()
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then return end
    local P = getPlayer(src)
    local name = P and (P.PlayerData.charinfo.firstname.." "..P.PlayerData.charinfo.lastname) or ("Player "..src)
    leaveTeam(lobby, src)
    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.left_lobby_announce, name),
        'error'
    )
    LobbyDirty(lobby) 
    endIfOver(lobby, src)
end)

RegisterServerEvent('Pug:SV:SetWagerOfLobby', function(wager)
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.you_are_not_in_lobby,
            'error'
        )
        return
    end
    if lobby.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_change_wager,
            'error'
        )
        return
    end

    lobby.cashprize = tonumber(wager) or lobby.cashprize
    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.wager_set_prize_pool, lobby.cashprize)
    )
    LobbyDirty(lobby)
end)

RegisterServerEvent('Pug:SV:SetlivesOfPlayers', function(livesNum)
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.you_are_not_in_lobby,
            'error'
        )
        return
    end
    if lobby.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_change_wager,
            'error'
        )
        return
    end

    lobby.lives = tonumber(livesNum) or lobby.lives
    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.lives_set_message, lobby.lives)
    )
    LobbyDirty(lobby)
end)


RegisterServerEvent('Pug:SV:SetArenaMap', function(arenaKey)
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.you_are_not_in_lobby,
            'error'
        )
        return
    end
    if lobby.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_change_wager,
            'error'
        )
        return
    end

    if tostring(arenaKey) == 'random' then
        lobby.arenaKey = randomArenaKey()
    else
        -- guard: only set if key exists in Config.Arenas
        if Config.Arenas[arenaKey] then
            lobby.arenaKey = arenaKey
        else
            TriggerClientEvent(
                'Pug:client:PaintballNotifyEvent',
                src,
                Config.Translations.error.invalid_map_key,
                'error'
            )

            return
        end
    end
    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.map_set_to, Config.Arenas[lobby.arenaKey].name)
    )
    LobbyDirty(lobby)
end)

RegisterServerEvent('Pug:server:ChoseGameMode', function(gMode)
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.you_are_not_in_lobby,
            'error'
        )
        return
    end
    if lobby.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_change_wager,
            'error'
        )
        return
    end
    if lobby.mode == gMode then return end

    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.mode_set_to, gMode)
    )
    LobbyDirty(lobby)

    switchModeKeepPlayers(lobby, gMode)

    LobbyDirty(lobby)
end)

RegisterNetEvent("Pug:Lobby:SetPasscode", function(lobbyId, pass)
    local src = source
    local L = LobbyManager.getOrCreate(tonumber(lobbyId) or 1)
    if not L then return end
    if L.host ~= src then return end

    L.passcode = (pass ~= nil and pass ~= "") and tostring(pass) or nil
    L.locked   = (L.passcode ~= nil)
    local msg = L.passcode
        and Config.Translations.menu.passcode_set_and_locked
        or Config.Translations.menu.passcode_cleared_unlocked
    broadcast(L, 'Pug:client:PaintballNotifyEvent', msg)

    LobbyDirty(L)
end)


RegisterNetEvent("Pug:Lobby:Shutdown", function()
    local src = source
    local L, lobbyId = LobbyManager.ofPlayer(src)
    if not lobbyId then return end
    if L and L.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_shutdown_lobby,
            'error'
        )
        return
    end
    LobbyDirty(L)
    destroyLobby(lobbyId)
end)

RegisterServerEvent('Pug:paintball:RemovePlayer', function(team)
    local src = source
    local lobby, _ = LobbyManager.ofPlayer(src)
    if not lobby then return end
    EliminatePlayerFromLobby(lobby, src, team)
end)

RegisterNetEvent("Pug:server:MakePlayerGameHost", function(playerId, lobbyId)
    local src = source
    local lobby = (lobbyId and LobbyManager.getOrCreate(lobbyId)) or LobbyManager.ofPlayer(src) or LobbyManager.getOrCreate(1)

    if playerId == "remove" then
        lobby.host = nil
        for pid in pairs(lobby.all) do
            TriggerClientEvent(
                'Pug:client:PaintballNotifyEvent',
                pid,
                Config.Translations.error.host_removed_far
            )
        end
        LobbyDirty(lobby)
        return
    end

    if playerId and playerId == lobby.host then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            playerId,
            Config.Translations.error.player_already_host
        )
        return
    end

    local target = getPlayer(tonumber(playerId or src))
    if target and type(playerId) == "number" then
        if #(GetEntityCoords(GetPlayerPed(playerId)) - GetEntityCoords(GetPlayerPed(src))) >= 20.0 then
            TriggerClientEvent(
                'Pug:client:PaintballNotifyEvent',
                src,
                Config.Translations.error.player_too_far_for_host
            )
            return
        end
        lobby.host = playerId
        local old = src
        if HostLobbyBySrc[old] == lobby.id then HostLobbyBySrc[old] = nil end
        lobby.access[lobby.host] = true
        HostLobbyBySrc[lobby.host] = lobby.id
        TriggerClientEvent("Pug:client:DoLobbyHostLoop", lobby.host)
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            lobby.host,
            Config.Translations.menu.host_now
        )
        LobbyDirty(lobby)
    else
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            string.format(Config.Translations.error.player_not_found_id, tostring(playerId))
        )
    end
end)

RegisterNetEvent("Pug:Lobby:Create", function(opts)
    local src = source

    if HostLobbyBySrc[src] and Lobbies[HostLobbyBySrc[src]] then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            string.format(Config.Translations.menu.already_hosting_lobby, HostLobbyBySrc[src]),
            'error'
        )
        return
    end

    local nextId = 1
    while Lobbies[nextId] ~= nil do nextId = nextId + 1 end

    local L = LobbyManager.getOrCreate(nextId)
    L.name = (opts and opts.name) or nil

    local hasPass = (opts and opts.passcode and tostring(opts.passcode) ~= "")
    L.passcode = hasPass and tostring(opts.passcode) or nil
    L.locked   = hasPass and true or false

    L.access = {}
    L.host   = src
	L.access[src] = true  
    HostLobbyBySrc[src] = nextId

    addToAll(L, src)
    SetAdd(L.spec, src)

    TriggerClientEvent("Pug:client:DoLobbyHostLoop", src)
    TriggerClientEvent(
        'Pug:client:PaintballNotifyEvent',
        src,
        string.format(Config.Translations.menu.lobby_created_host, nextId)
    )
end)

RegisterNetEvent("Pug:Lobby:KickPlayer", function(lobbyId, targetId)
    local src = source
    lobbyId = tonumber(lobbyId)
    targetId = tonumber(targetId)

    if not lobbyId or not targetId then
        return
    end

    local lobby = Lobbies[lobbyId]
    if not lobby then
        TriggerClientEvent('Pug:client:PaintballNotifyEvent', src, Config.Translations.error.lobby_not_found, 'error')
        return
    end

    if lobby.host ~= src then
        TriggerClientEvent('Pug:client:PaintballNotifyEvent', src, Config.Translations.error.only_host_kick_players, 'error')
        return
    end

    if targetId == src then
        TriggerClientEvent('Pug:client:PaintballNotifyEvent', src, Config.Translations.error.use_leave_lobby, 'error')
        return
    end

    if not SetContains(lobby.all, targetId) then
        TriggerClientEvent('Pug:client:PaintballNotifyEvent', src, Config.Translations.error.player_not_in_lobby_anymore, 'error')
        return
    end

    local kicked = getPlayer(targetId)
    local kickedName = kicked and kicked.PlayerData and kicked.PlayerData.charinfo
        and (kicked.PlayerData.charinfo.firstname .. " " .. kicked.PlayerData.charinfo.lastname)
        or ("Player " .. tostring(targetId))

    leaveTeam(lobby, targetId)
    lobby.access[targetId] = nil
    SetPlayerRoutingBucket(targetId, 0)
    AddRadio(targetId, true)

    TriggerClientEvent(
        'Pug:client:PaintballNotifyEvent',
        targetId,
        Config.Translations.menu.kicked_from_lobby,
        'error'
    )
    TriggerClientEvent("Pug:client:OpenPaintballHUB", targetId, {})

    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.kicked_broadcast, kickedName),
        'error'
    )

    if lobby.started then
        endIfOver(lobby, targetId)
    end

    LobbyDirty(lobby)
end)

RegisterServerEvent('Pug:SV:SetMatchTime', function(minutes)
    local src = source
    local lobby = LobbyManager.ofPlayer(src)
    if not lobby then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.you_are_not_in_lobby,
            'error'
        )
        return
    end
    if lobby.host ~= src then
        TriggerClientEvent(
            'Pug:client:PaintballNotifyEvent',
            src,
            Config.Translations.error.only_host_change_wager,
            'error'
        )
        return
    end

    local m = tonumber(minutes) or 30

    lobby.matchMinutes = m
    broadcast(
        lobby,
        'Pug:client:PaintballNotifyEvent',
        string.format(Config.Translations.menu.match_time_set, m)
    )
    LobbyDirty(lobby)
end)

RegisterServerEvent('Pug:server:SetAllPlayersWeapons', function(weapon, lobbyId)
    local lobby = (lobbyId and LobbyManager.getOrCreate(lobbyId)) or LobbyManager.ofPlayer(source)
    if not lobby then return end

    if type(weapon) ~= "string" or weapon == "" then return end
    if not (Config.WeaponItems and Config.WeaponItems[weapon]) then return end

    lobby.weapon = weapon

    for pid in pairs(lobby.all) do
        TriggerClientEvent("Pug:client:SetAllPlayersWeapons", pid, weapon)
    end

    LobbyDirty(lobby)
end)




Config.FrameworkFunctions.CreateCallback('Pug:SVCB:GetLobbyDetails', function(source, cb, SpectateOrOptions)
    local spectateId, lobbyId
    if type(SpectateOrOptions) == "number" then
        spectateId = SpectateOrOptions
    elseif type(SpectateOrOptions) == "table" then
        spectateId = SpectateOrOptions.spectate
        lobbyId = SpectateOrOptions.lobbyId
    end

    if spectateId then
        local pos = GetEntityCoords(GetPlayerPed(spectateId))
        local l = lobbyId and LobbyManager.getOrCreate(lobbyId)
            or (LobbyManager.ofPlayer(source) or LobbyManager.getOrCreate(1))
        cb({ map = Config.Arenas[l.arenaKey].name, location = pos })
        return
    end

    local lobby
    if LobbyManager.ofPlayer then
        lobby = LobbyManager.ofPlayer(source)
    end
    if not lobby and lobbyId then
        lobby = Lobbies[tonumber(lobbyId)]
    end
    if not lobby and not lobbyId then
        lobby = LobbyManager.getOrCreate(1)
    end
    if not lobby then
        cb(nil)
        return
    end

    local isFFA    = IsFreeForAllGameMode(lobby.mode)
    local redNames  = buildNamesArray(lobby.red)
    local blueNames = buildNamesArray(lobby.blue)
    local ffaNames  = buildNamesArray(lobby.ffa)
    local myTeam
    if SetContains(lobby.red, source) then
        myTeam = 'redteam'
    elseif SetContains(lobby.blue, source) then
        myTeam = 'blueteam'
    elseif SetContains(lobby.ffa, source) then
        myTeam = 'ffa'
    end

    local function sendPayload(progress)
        local myXP, myRank, myLevel, myPrestige, myXPInto, myXPNext =
            0, 0, 1, 0, 0, 0

        if progress then
            myXP       = progress.xp       or 0
            myRank     = progress.rank     or 0
            myLevel    = progress.level    or 1
            myPrestige = progress.prestige or 0
            myXPInto   = progress.xpIntoLevel or 0
            myXPNext   = progress.xpForNext   or 0
        end

        cb({
            life   = lobby.lives,
            redT   = (isFFA and 0) or (#redNames),
            blueT  = (isFFA and 0) or (#blueNames),
            playersffa     = (isFFA and (#ffaNames)) or nil,
            PlayersDisplay = (isFFA and ffaNames) or nil,
            playsred       = (not isFFA and redNames) or nil,
            playsblue      = (not isFFA and blueNames) or nil,
            amount = lobby.cashprize,
            all    = setToArray(lobby.all),
            map    = Config.Arenas[lobby.arenaKey].name,
            host   = lobby.host,
            started= lobby.started,
            mode   = lobby.mode,
            weapon = lobby.weapon,
            id     = lobby.id,
            name   = lobby.name or Config.Arenas[lobby.arenaKey].name,
            locked = (lobby.locked == true),
            myTeam = myTeam,
            time   = lobby.matchMinutes or 30,

            myXP           = myXP,
            myRank         = myRank,
            myLevel        = myLevel,
            myPrestige     = myPrestige,
            myXPIntoLevel  = myXPInto,
            myXPForNext    = myXPNext,
        })
    end

    local ply = Config.FrameworkFunctions.GetPlayer(source)
    local citizenid = ply and ply.PlayerData and ply.PlayerData.citizenid
    if not citizenid then
        sendPayload(nil)
        return
    end

    MySQL.query([[
        SELECT citizenid, COALESCE(SUM(xp), 0) AS total_xp
        FROM pug_paintball_stats
        GROUP BY citizenid
        ORDER BY total_xp DESC
    ]], {}, function(rows)
        local myXP  = 0
        local myRank = 0

        if rows then
            for idx, row in ipairs(rows) do
                local xp = tonumber(row.total_xp) or 0
                if row.citizenid == citizenid then
                    myXP  = xp
                    myRank = idx
                    break
                end
            end
        end

        local level, prestige, xpIntoLevel, _ = GetLevelAndPrestigeFromXP(myXP)
        local xpForNext = LevelXP[level] or 0

        sendPayload({
            xp          = myXP,
            rank        = myRank,
            level       = level,
            prestige    = prestige,
            xpIntoLevel = xpIntoLevel,
            xpForNext   = xpForNext,
        })
    end)
end)

Config.FrameworkFunctions.CreateCallback("Pug:Lobby:Gate", function(source, cb, lobbyId, passAttempt)
    local L = LobbyManager.getOrCreate(tonumber(lobbyId) or 1)
    if not L then return cb(false, Config.Translations.menu.lobby_not_found_msg) end
    if not L.locked then
        L.access[source] = true
        return cb(true)
    end
    if (L.passcode or "") ~= "" and tostring(passAttempt or "") == tostring(L.passcode) then
        L.access[source] = true
        cb(true)
    else
        cb(false, Config.Translations.menu.incorrect_passcode_msg)
    end
end)

Config.FrameworkFunctions.CreateCallback('Pug:Lobby:GetMembers', function(source, cb, lobbyId)
    local lobby
    if lobbyId then
        lobby = Lobbies[tonumber(lobbyId)]
    end
    if not lobby then
        lobby = LobbyManager.ofPlayer(source)
    end
    if not lobby then
        cb({})
        return
    end

    local out = {}
    for pid in pairs(lobby.all) do
        local P = getPlayer(pid)
        local name = (Config.Translations.menu.default_player_name):format(pid)

        if P and P.PlayerData and P.PlayerData.charinfo then
            name = (P.PlayerData.charinfo.firstname or "") ..
                   " " ..
                   (P.PlayerData.charinfo.lastname or "")
        elseif lobby.nameBySrc and lobby.nameBySrc[pid] then
            name = lobby.nameBySrc[pid]
        end

        local team
        if SetContains(lobby.red, pid) then
            team = "Red"
        elseif SetContains(lobby.blue, pid) then
            team = "Blue"
        elseif SetContains(lobby.ffa, pid) then
            team = "FFA"
        elseif SetContains(lobby.spec, pid) then
            team = "Spectator"
        else
            team = "Unknown"
        end

        out[#out+1] = {
            id     = pid,
            name   = name,
            team   = team,
            isHost = (lobby.host == pid),
        }
    end

    table.sort(out, function(a, b)
        return a.id < b.id
    end)

    cb(out)
end)

Config.FrameworkFunctions.CreateCallback('Pug:Lobby:List', function(source, cb)
    local out = {}
    for id, L in pairs(Lobbies) do
        local mapName = Config.Arenas[L.arenaKey].name
        local players = SetCount(L.all)
        local red = SetCount(L.red)
        local blue = SetCount(L.blue)
        table.insert(out, {
            id = id, name = L.name or mapName, map = mapName, mode = L.mode,
            players = players, red = red, blue = blue, locked = (L.locked == true)
        })
    end
    table.sort(out, function(a,b) return a.id < b.id end)
    cb(out)
end)

Config.FrameworkFunctions.CreateCallback('Pug:Lobby:GetMyHosted', function(source, cb)
    local id = HostLobbyBySrc[source]
    if id and Lobbies[id] then cb(id) else cb(false) end
end)

Config.FrameworkFunctions.CreateCallback('Pug:Lobby:GetMine', function(source, cb)
    local id = PlayerLobby[source] or HostLobbyBySrc[source]
    if id and Lobbies[id] then
        cb(id)
    else
        cb(false)
    end
end)