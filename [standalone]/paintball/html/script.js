let currentMatch = null;
let isHost = false;
let weaponMenuSource = null; // Track where weapon menu was opened from ('gamemode' or 'practice')

// Auto-refresh lobbies interval
let lobbyRefreshInterval = null;

// Start auto-refreshing lobbies
function startLobbyAutoRefresh() {
    // Clear any existing interval
    if (lobbyRefreshInterval) {
        clearInterval(lobbyRefreshInterval);
    }
    
    // Request lobbies immediately
    fetch(`https://${GetParentResourceName()}/refreshLobbies`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    
    // Set up auto-refresh every 3 seconds
    lobbyRefreshInterval = setInterval(function() {
        fetch(`https://${GetParentResourceName()}/refreshLobbies`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }, 3000);
}

// Stop auto-refreshing lobbies
function stopLobbyAutoRefresh() {
    if (lobbyRefreshInterval) {
        clearInterval(lobbyRefreshInterval);
        lobbyRefreshInterval = null;
    }
}

// Listen for messages from Lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    // Debug: Log all messages
    if (data.action === 'showScoreboard' || data.action === 'hideScoreboard') {
        console.log('[Paintball NUI] Received action:', data.action, data);
    }
    
    switch(data.action) {
        case 'openLobby':
            openLobby(data.match, data.isHost);
            break;
        case 'updateLobby':
            updateLobby(data.match);
            break;
        case 'closeLobby':
            closeLobby();
            break;
        case 'startMatch':
            startMatch(data.match, data.gameModeName);
            break;
        case 'updateScoreboard':
            updateScoreboard(data.match);
            break;
        case 'updateMatchTime':
            updateMatchTime(data.time);
            break;
        case 'endMatch':
            endMatch(data.match, data.winner);
            break;
        case 'closeMatch':
            closeMatch();
            break;
        case 'showLeaderboard':
            showLeaderboard(data.stats);
            break;
        case 'toggleScoreboard':
            toggleScoreboard();
            break;
        case 'showScoreboard':
            console.log('[Paintball NUI] showScoreboard called with match:', data.match);
            if (data.match) {
                showScoreboard(data.match);
            } else {
                console.error('[Paintball NUI] showScoreboard called but no match data!');
            }
            break;
        case 'hideScoreboard':
            console.log('[Paintball NUI] hideScoreboard called');
            hideScoreboard();
            break;
        case 'showInteractionPrompt':
            showInteractionPrompt();
            break;
        case 'hideInteractionPrompt':
            hideInteractionPrompt();
            break;
        case 'showLobbyIndicator':
            showLobbyIndicator(data.match);
            break;
        case 'hideLobbyIndicator':
            hideLobbyIndicator();
            break;
        case 'closeUI':
            // Comprehensive instant cleanup - no delays
            closeLobby();
            closeMatch();
            closeMainMenu();
            closeGameModeMenu();
            closeWeaponMenu();
            hidePracticeHUD();
            hidePracticeSummary();
            hideInteractionPrompt();
            hideLobbyIndicator();
            hideKillFeed();
            hideHitMarker();
            // Force hide all containers instantly
            const containers = ['lobby-container', 'scoreboard-container', 'leaderboard-container', 'main-menu-container', 'gamemode-menu-container', 'weapon-menu-container', 'practice-settings-container', 'practice-hud-container', 'practice-summary-container', 'interaction-prompt', 'lobby-indicator', 'kill-feed-container', 'hit-marker', 'respawn-countdown-container'];
            containers.forEach(id => {
                const el = document.getElementById(id);
                if (el) {
                    el.classList.add('hidden');
                    el.style.display = 'none';
                    el.style.visibility = 'hidden';
                    el.style.opacity = '0';
                }
            });
            break;
        case 'openMainMenu':
            // Open instantly - no delays
            openMainMenu();
            break;
        case 'receiveActiveLobbies':
            receiveActiveLobbies(data.lobbies);
            break;
        case 'refreshLobbies':
            // Server requested a refresh, trigger it immediately if menu is open
            if (lobbyRefreshInterval !== null) {
                fetch(`https://${GetParentResourceName()}/refreshLobbies`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }
            break;
        case 'showRoundReset':
            showRoundReset(data.countdown, data.match);
            break;
        case 'updateRoundReset':
            updateRoundReset(data.countdown, data.match);
            break;
        case 'hideRoundReset':
            hideRoundReset();
            break;
        case 'updatePlayerName':
            updatePlayerName(data.playerId, data.playerName);
            break;
        case 'openGameModeMenu':
            openGameModeMenu(data.gameModes);
            break;
        case 'closeMainMenu':
            closeMainMenu();
            break;
        case 'closeGameModeMenu':
            closeGameModeMenu();
            break;
        case 'openWeaponMenu':
            weaponMenuSource = data.source || null; // Track where it was opened from
            openWeaponMenu(data.weapons);
            break;
        case 'openWeaponCategory':
            openWeaponCategory(data.category, data.weapons);
            break;
        case 'closeWeaponMenu':
            closeWeaponMenu();
            break;
        case 'openPracticeSettings':
            openPracticeSettings(data.settings);
            break;
        case 'closePracticeSettings':
            closePracticeSettings();
            break;
        case 'updatePracticeWeapon':
            updatePracticeWeapon(data.weapon, data.weaponName);
            break;
        case 'updatePracticeKills':
            updatePracticeKills(data.kills);
            break;
        case 'updatePracticeWeapon':
            updatePracticeWeapon(data.weapon, data.weaponName);
            break;
        case 'showRespawnCountdown':
            showRespawnCountdown(data.time);
            break;
        case 'updateRespawnCountdown':
            updateRespawnCountdown(data.time);
            break;
        case 'hideRespawnCountdown':
            hideRespawnCountdown();
            break;
        case 'showPracticeHUD':
            showPracticeHUD(data.match);
            break;
        case 'updatePracticeHUD':
            updatePracticeHUD(data);
            break;
        case 'hidePracticeHUD':
            hidePracticeHUD();
            break;
        case 'addKillFeed':
            addKillFeed(data);
            break;
        case 'hideKillFeed':
            hideKillFeed();
            break;
        case 'hideHitMarker':
            hideHitMarker();
            break;
        case 'updateProgression':
            updateProgressionDisplay(data);
            break;
        case 'updateConfig':
            updateConfigFlags(data);
            break;
        case 'showRankUp':
            showRankUpNotification(data);
            break;
        case 'showPrestigeUp':
            showPrestigeUpNotification(data);
            break;
        case 'showHitMarker':
            showHitMarker(data.headshot);
            break;
        case 'showKillConfirmation':
            showKillConfirmation(data.weapon, data.headshot);
            break;
        case 'showDamageIndicator':
            showDamageIndicator(data.damage);
            break;
        case 'showPaintSplatter':
            showPaintSplatter();
            break;
        case 'showPracticeSummary':
            showPracticeSummary(data.stats);
            break;
    }
});

// Lobby Functions
function openLobby(match, host) {
    // Hide lobby indicator when lobby menu is open
    hideLobbyIndicator();
    
    // Ensure all other containers are hidden first (immediate, no delay)
    const scoreboard = document.getElementById('scoreboard-container');
    const leaderboard = document.getElementById('leaderboard-container');
    const mainMenu = document.getElementById('main-menu-container');
    const gameModeMenu = document.getElementById('gamemode-menu-container');
    const weaponMenu = document.getElementById('weapon-menu-container');
    const practiceMenu = document.getElementById('practice-settings-container');
    
    if (scoreboard) {
        scoreboard.classList.add('hidden');
        scoreboard.style.display = 'none';
        scoreboard.style.visibility = 'hidden';
    }
    if (leaderboard) {
        leaderboard.classList.add('hidden');
        leaderboard.style.display = 'none';
        leaderboard.style.visibility = 'hidden';
    }
    if (mainMenu) {
        mainMenu.classList.add('hidden');
        mainMenu.style.display = 'none';
        mainMenu.style.visibility = 'hidden';
    }
    if (gameModeMenu) {
        gameModeMenu.classList.add('hidden');
        gameModeMenu.style.display = 'none';
        gameModeMenu.style.visibility = 'hidden';
    }
    if (weaponMenu) {
        weaponMenu.classList.add('hidden');
        weaponMenu.style.display = 'none';
        weaponMenu.style.visibility = 'hidden';
    }
    if (practiceMenu) {
        practiceMenu.classList.add('hidden');
        practiceMenu.style.display = 'none';
        practiceMenu.style.visibility = 'hidden';
    }
    
    currentMatch = match;
    isHost = host;
    
    // Show lobby FIRST (before updating) to prevent freeze
    const lobby = document.getElementById('lobby-container');
    if (lobby) {
        lobby.style.visibility = 'visible';
        lobby.classList.remove('hidden');
        lobby.style.display = 'block';
        // Force immediate rendering
        void lobby.offsetHeight;
    }
    
    // Update lobby content (menu is already visible, so this won't freeze)
    updateLobby(match);
    
    // Setup kills to win setting click handler
    const killCountSetting = document.getElementById('kill-count-setting');
    if (killCountSetting) {
        killCountSetting.onclick = function() {
            if (isHost) {
                openKillsMenu(match.settings.killCount || 3);
            }
        };
    }
    
    // Setup weapon setting click handler
    const weaponSetting = document.getElementById('weapon-setting');
    if (weaponSetting) {
        weaponSetting.onclick = function() {
            if (isHost) {
                fetch(`https://${GetParentResourceName()}/openWeaponMenu`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            }
        };
    }
    
    // Setup wager setting click handler
    const wagerSetting = document.getElementById('wager-setting');
    if (wagerSetting) {
        wagerSetting.onclick = function() {
            if (isHost) {
                openWagerMenu(match.settings.wager || 0);
            }
        };
    }
}

function updateLobby(match) {
    currentMatch = match;
    
    // Update game mode
    const gameModeElement = document.getElementById('lobby-gamemode');
    if (gameModeElement && match.settings && match.settings.gameModeName) {
        gameModeElement.textContent = match.settings.gameModeName;
    }
    
    // Update team counts
    const redCount = match.teams.red.length;
    const blueCount = match.teams.blue.length;
    document.getElementById('red-count').textContent = `${redCount}/12`;
    document.getElementById('blue-count').textContent = `${blueCount}/12`;
    
    // Update team players
    const redPlayersDiv = document.getElementById('red-players');
    const bluePlayersDiv = document.getElementById('blue-players');
    redPlayersDiv.innerHTML = '';
    bluePlayersDiv.innerHTML = '';
    
    match.teams.red.forEach(playerId => {
        const playerDiv = document.createElement('div');
        playerDiv.className = 'player-name';
        playerDiv.id = `player-${playerId}`;
        // Get character name from match.playerNames
        const playerIdStr = String(playerId);
        const playerIdNum = Number(playerId);
        const playerName = (match.playerNames && (match.playerNames[playerIdStr] || match.playerNames[playerIdNum])) || `Player ${playerId}`;
        playerDiv.textContent = playerName;
        redPlayersDiv.appendChild(playerDiv);
    });
    
    match.teams.blue.forEach(playerId => {
        const playerDiv = document.createElement('div');
        playerDiv.className = 'player-name';
        playerDiv.id = `player-${playerId}`;
        // Get character name from match.playerNames
        const playerIdStr = String(playerId);
        const playerIdNum = Number(playerId);
        const playerName = (match.playerNames && (match.playerNames[playerIdStr] || match.playerNames[playerIdNum])) || `Player ${playerId}`;
        playerDiv.textContent = playerName;
        bluePlayersDiv.appendChild(playerDiv);
    });
    
    // Update settings
    const killCount = match.settings.killCount || 3;
    const killCountValue = document.getElementById('kill-count-value');
    if (killCountValue) {
        killCountValue.textContent = `${killCount} kills`;
    }
    
    const wagerValue = document.getElementById('wager-value');
    if (wagerValue) {
        const wager = match.settings && match.settings.wager ? match.settings.wager : 0;
        wagerValue.textContent = wager > 0 ? `$${wager.toLocaleString()}` : '$0';
        
        // Add visual feedback when wager is updated (subtle animation)
        if (wager > 0) {
            wagerValue.style.transition = 'all 0.3s ease';
            wagerValue.style.color = '#ffd700';
            wagerValue.style.textShadow = '0 0 10px rgba(255, 215, 0, 0.5)';
            setTimeout(() => {
                wagerValue.style.color = '';
                wagerValue.style.textShadow = '';
            }, 1000);
        }
    }
    
    // Use weaponName if available, otherwise convert from weapon hash
    const weaponDisplay = match.settings.weaponName || getWeaponName(match.settings.weapon);
    const weaponValue = document.getElementById('weapon-value');
    if (weaponValue) {
        weaponValue.textContent = weaponDisplay;
    }
    
    // Show wager badge next to game mode if set (always reserve space)
    const wagerBadge = document.getElementById('lobby-wager-badge');
    if (wagerBadge) {
        if (match.settings.wager > 0) {
            wagerBadge.innerHTML = `<span class="wager-icon">💰</span><span class="wager-amount">$${match.settings.wager.toLocaleString()}</span>`;
            wagerBadge.classList.remove('hidden');
            wagerBadge.style.display = 'flex';
        } else {
            wagerBadge.classList.add('hidden');
            wagerBadge.style.display = 'flex'; // Keep display: flex to reserve space
        }
    }
    
    // Show/hide and enable/disable start button
    const startBtn = document.getElementById('start-match');
    if (!startBtn) return; // Safety check
    
    const requiresTeams = match.settings.requiresTeams !== false; // Default to true
    const totalPlayers = redCount + blueCount;
    const minPlayers = match.settings.minPlayers || 2;
    
    // Always show button for host, but disable if conditions aren't met
    if (isHost) {
        startBtn.style.display = 'flex';
        
        let canStart = false;
        let reason = '';
        
        if (requiresTeams) {
            // Team-based mode: need at least 1 player on each team
            if (redCount > 0 && blueCount > 0) {
                canStart = true;
    } else {
                reason = 'Need at least 1 player on each team';
            }
        } else {
            // Non-team mode (FFA, Gun Game): need minimum players total
            if (totalPlayers >= minPlayers) {
                canStart = true;
            } else {
                reason = `Need at least ${minPlayers} players to start`;
            }
        }
        
        // Enable/disable button
        if (canStart) {
            startBtn.disabled = false;
            startBtn.style.opacity = '1';
            startBtn.style.cursor = 'pointer';
            startBtn.title = 'Click to start the match';
        } else {
            startBtn.disabled = true;
            startBtn.style.opacity = '0.5';
            startBtn.style.cursor = 'not-allowed';
            startBtn.title = reason;
        }
    } else {
        // Not host, hide button
        startBtn.style.display = 'none';
    }
}

function closeLobby() {
    // Instant close - no delays
    const lobby = document.getElementById('lobby-container');
    if (lobby) {
        lobby.classList.add('hidden');
        lobby.style.display = 'none';
        lobby.style.visibility = 'hidden';
    }
    currentMatch = null;
    isHost = false;
}

// Team joining
document.getElementById('red-team').addEventListener('click', function() {
    if (currentMatch) {
        fetch(`https://${GetParentResourceName()}/joinTeam`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                matchId: currentMatch.id,
                team: 'red'
            })
        });
    }
});

document.getElementById('blue-team').addEventListener('click', function() {
    if (currentMatch) {
        fetch(`https://${GetParentResourceName()}/joinTeam`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                matchId: currentMatch.id,
                team: 'blue'
            })
        });
    }
});

// Start match
const startMatchBtn = document.getElementById('start-match');
if (startMatchBtn) {
    startMatchBtn.addEventListener('click', function() {
        if (this.disabled) return; // Don't allow clicking if disabled
        
    if (currentMatch && isHost) {
        fetch(`https://${GetParentResourceName()}/startMatch`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                matchId: currentMatch.id
            })
        });
    }
});
}

// Leave lobby
document.getElementById('leave-lobby').addEventListener('click', function() {
    closeLobby();
    closeMatch();
    // Leave lobby and return to main menu instead of closing UI
    fetch(`https://${GetParentResourceName()}/leaveLobby`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    // Open main menu immediately (no delay)
    openMainMenu();
});

// Close lobby
document.getElementById('close-lobby').addEventListener('click', function() {
    closeLobby();
    closeMatch();
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
});

// Leave practice mode
const leavePracticeBtn = document.getElementById('leave-practice-btn');
if (leavePracticeBtn) {
    leavePracticeBtn.addEventListener('click', function() {
        // Hide all UI elements immediately
        hidePracticeHUD();
        hidePracticeSummary();
        closeMatch();
        closeLobby();
        
        fetch(`https://${GetParentResourceName()}/leaveLobby`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
        // Don't open main menu - UI should be closed completely
    });
}

// Match Functions
function startMatch(match, gameModeName) {
    currentMatch = match;
    closeLobby();
    updateScoreboard(match);
    
    // Update game mode name
    if (gameModeName) {
        document.getElementById('match-mode').textContent = gameModeName;
    }
    
    // Show leave button for practice mode
    const leaveBtn = document.getElementById('leave-practice-btn');
    if (leaveBtn && match.gameMode === 'practice') {
        leaveBtn.classList.remove('hidden');
        leaveBtn.style.display = 'flex';
    }
    
    // Hide scoreboard initially (will show when Tab is pressed)
    hideScoreboard();
}

function updateScoreboard(match) {
    if (!match) return;
    
    currentMatch = match;
    
    // Update scores with defaults if missing
    const redScore = (match.scores && match.scores.red) || 0;
    const blueScore = (match.scores && match.scores.blue) || 0;
    document.getElementById('red-score').textContent = redScore;
    document.getElementById('blue-score').textContent = blueScore;
    
    // Show/hide leave practice button based on game mode - check multiple possible values
    const leaveBtn = document.getElementById('leave-practice-btn');
    if (leaveBtn) {
        const isPractice = match.gameMode === 'practice' || 
                          (match.settings && match.settings.gameMode === 'practice') ||
                          match.gameMode === 'ai' ||
                          match.id === 'practice';
        
        if (isPractice) {
            leaveBtn.classList.remove('hidden');
            leaveBtn.style.display = 'flex';
        } else {
            leaveBtn.classList.add('hidden');
            leaveBtn.style.display = 'none';
        }
    }
    
    // Update player stats
    const tbody = document.getElementById('player-stats-body');
    tbody.innerHTML = '';
    
    // Red team players
    match.teams.red.forEach(playerId => {
        const stats = match.stats[playerId] || { kills: 0, deaths: 0, kd: 0, points: 0 };
        const row = createPlayerRow(playerId, stats, 'red');
        tbody.appendChild(row);
    });
    
    // Blue team players
    match.teams.blue.forEach(playerId => {
        const stats = match.stats[playerId] || { kills: 0, deaths: 0, kd: 0, points: 0 };
        const row = createPlayerRow(playerId, stats, 'blue');
        tbody.appendChild(row);
    });
}

function createPlayerRow(playerId, stats, team) {
    const row = document.createElement('tr');
    row.innerHTML = `
        <td>Lv. ${playerId} Player ${playerId}</td>
        <td>${stats.kills || 0}</td>
        <td>${stats.deaths || 0}</td>
        <td>${(stats.kd || 0).toFixed(2)}</td>
        <td>${stats.points || 0}</td>
    `;
    return row;
}

function updateMatchTime(remainingTime) {
    const minutes = Math.floor(remainingTime / 60);
    const seconds = remainingTime % 60;
    // Update match time display if needed
}

function endMatch(match, winner) {
    // Show end match screen
    setTimeout(() => {
        closeMatch();
    }, 10000);
}

function closeMatch() {
    // Instant close - no delays
    const scoreboard = document.getElementById('scoreboard-container');
    if (scoreboard) {
        scoreboard.classList.add('hidden');
        scoreboard.style.display = 'none';
        scoreboard.style.visibility = 'hidden';
    }
    const leaderboard = document.getElementById('leaderboard-container');
    if (leaderboard) {
        leaderboard.classList.add('hidden');
        leaderboard.style.display = 'none';
        leaderboard.style.visibility = 'hidden';
    }
    currentMatch = null;
}

function toggleScoreboard() {
    const scoreboard = document.getElementById('scoreboard-container');
    scoreboard.classList.toggle('hidden');
}

function showScoreboard(match) {
    if (!match) {
        console.log('showScoreboard: No match data provided');
        return;
    }
    
    currentMatch = match;
    const scoreboard = document.getElementById('scoreboard-container');
    if (!scoreboard) {
        console.log('showScoreboard: Scoreboard container not found');
        return;
    }
    
    // Force show the scoreboard
    scoreboard.classList.remove('hidden');
    scoreboard.style.display = 'flex';
    scoreboard.style.visibility = 'visible';
    scoreboard.style.opacity = '1';
    scoreboard.style.zIndex = '9999';
    scoreboard.style.pointerEvents = 'none'; // Container passes clicks through, only buttons are clickable
    // Ensure scoreboard stays fixed in center
    scoreboard.style.position = 'fixed';
    scoreboard.style.top = '50%';
    scoreboard.style.left = '50%';
    scoreboard.style.transform = 'translate(-50%, -50%)';
    scoreboard.style.margin = '0';
    
    // Update scoreboard with match data
    updateScoreboard(match);
    
    // Show leave button for practice mode - check multiple possible gameMode values
    const leaveBtn = document.getElementById('leave-practice-btn');
    if (leaveBtn) {
        // Check for practice mode in multiple ways
        const gameModeName = (match.gameModeName || '').toLowerCase();
        const isPractice = match.gameMode === 'practice' || 
                          (match.settings && match.settings.gameMode === 'practice') ||
                          match.gameMode === 'ai' ||
                          gameModeName.includes('practice');
        
        if (isPractice) {
            leaveBtn.classList.remove('hidden');
            leaveBtn.style.display = 'flex';
            leaveBtn.style.visibility = 'visible';
            leaveBtn.style.pointerEvents = 'auto'; // Allow button clicks
            leaveBtn.style.cursor = 'pointer';
            leaveBtn.style.position = 'relative';
            leaveBtn.style.zIndex = '10000';
            
            // Re-attach event listener to ensure it works
            leaveBtn.onclick = function(e) {
                e.stopPropagation();
                e.preventDefault();
                console.log('[Paintball NUI] Leave Practice button clicked');
                // Hide all UI elements immediately
                hidePracticeHUD();
                hidePracticeSummary();
                closeMatch();
                closeLobby();
                
                fetch(`https://${GetParentResourceName()}/leaveLobby`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
                // Don't open main menu - UI should be closed completely
            };
        } else {
            leaveBtn.classList.add('hidden');
            leaveBtn.style.display = 'none';
        }
    }
    
    // Setup vote to end buttons for regular matches (not practice)
    const voteContainer = document.getElementById('vote-end-match-container');
    const voteYesBtn = document.getElementById('vote-yes-btn');
    const voteNoBtn = document.getElementById('vote-no-btn');
    const voteStatus = document.getElementById('vote-status');
    
    if (voteContainer && voteYesBtn && voteNoBtn) {
        const gameModeName = (match.gameModeName || '').toLowerCase();
        const isPractice = match.gameMode === 'practice' || 
                          (match.settings && match.settings.gameMode === 'practice') ||
                          match.gameMode === 'ai' ||
                          gameModeName.includes('practice') ||
                          gameModeName.includes('ai');
        
        if (!isPractice && match.status === 'active') {
            // Get current player ID - try multiple sources
            // Note: Server IDs are numbers, but object keys in JS are strings
            const currentPlayerId = match.playerServerId || window.currentPlayerId;
            const playerVote = match.endVotes && (match.endVotes[currentPlayerId] || match.endVotes[String(currentPlayerId)]);
            
            // Count votes - get player count from teams or players object
            let totalPlayers = 0;
            let yesVotes = 0;
            let noVotes = 0;
            
            // Count players from teams if available
            if (match.teams) {
                if (match.teams.red && Array.isArray(match.teams.red)) {
                    totalPlayers += match.teams.red.length;
                }
                if (match.teams.blue && Array.isArray(match.teams.blue)) {
                    totalPlayers += match.teams.blue.length;
                }
            }
            
            // If no teams, try to count from players object
            if (totalPlayers === 0 && match.players) {
                for (let playerId in match.players) {
                    if (match.players.hasOwnProperty(playerId)) {
                        totalPlayers++;
                    }
                }
            }
            
            // Count votes
            if (match.endVotes) {
                for (let playerId in match.endVotes) {
                    if (match.endVotes.hasOwnProperty(playerId)) {
                        const vote = match.endVotes[playerId];
                        if (vote === 'yes') yesVotes++;
                        else if (vote === 'no') noVotes++;
                    }
                }
            }
            
            voteContainer.classList.remove('hidden');
            voteContainer.style.display = 'flex';
            voteContainer.style.visibility = 'visible';
            voteContainer.style.pointerEvents = 'auto';
            voteContainer.style.position = 'relative';
            voteContainer.style.zIndex = '10000';
            
            // Update button states
            if (playerVote === 'yes') {
                voteYesBtn.classList.add('voted');
                voteNoBtn.classList.remove('voted');
            } else if (playerVote === 'no') {
                voteYesBtn.classList.remove('voted');
                voteNoBtn.classList.add('voted');
            } else {
                voteYesBtn.classList.remove('voted');
                voteNoBtn.classList.remove('voted');
            }
            
            // Update vote status display
            if (voteStatus) {
                if (totalPlayers > 0 && (yesVotes > 0 || noVotes > 0)) {
                    voteStatus.textContent = `${yesVotes}/${totalPlayers} Yes, ${noVotes}/${totalPlayers} No`;
                    voteStatus.style.display = 'block';
                } else {
                    voteStatus.textContent = '';
                    voteStatus.style.display = 'none';
                }
            }
            
            // Attach event listeners
            voteYesBtn.onclick = function(e) {
                e.stopPropagation();
                e.preventDefault();
                if (playerVote !== 'yes') {
                    fetch(`https://${GetParentResourceName()}/voteEndMatch`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ voteType: 'yes' })
                    });
                }
            };
            
            voteNoBtn.onclick = function(e) {
                e.stopPropagation();
                e.preventDefault();
                if (playerVote !== 'no') {
                    fetch(`https://${GetParentResourceName()}/voteEndMatch`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ voteType: 'no' })
                    });
                }
            };
        } else {
            voteContainer.classList.add('hidden');
            voteContainer.style.display = 'none';
        }
    }
    
    console.log('showScoreboard: Scoreboard shown for match', match.id);
}

function hideScoreboard() {
    const scoreboard = document.getElementById('scoreboard-container');
    if (scoreboard) {
        scoreboard.classList.add('hidden');
        scoreboard.style.display = 'none';
        scoreboard.style.visibility = 'hidden';
        scoreboard.style.opacity = '0';
        console.log('hideScoreboard: Scoreboard hidden');
    }
}

// Respawn Countdown Functions
function showRespawnCountdown(time) {
    const container = document.getElementById('respawn-countdown-container');
    const number = document.getElementById('respawn-countdown-number');
    if (container && number) {
        number.textContent = time;
        container.classList.remove('hidden');
        container.style.display = 'flex';
    }
}

function updateRespawnCountdown(time) {
    const number = document.getElementById('respawn-countdown-number');
    if (number) {
        number.textContent = time;
    }
}

function hideRespawnCountdown() {
    const container = document.getElementById('respawn-countdown-container');
    if (container) {
        container.classList.add('hidden');
        container.style.display = 'none';
    }
}

// Round Reset Functions (for 1v1 matches)
function showRoundReset(countdown, match) {
    const container = document.getElementById('round-reset-container');
    const countdownEl = document.getElementById('round-reset-countdown');
    const scoreboardEl = document.getElementById('round-reset-scoreboard');
    
    if (container && countdownEl) {
        countdownEl.textContent = countdown;
        
        // Show scoreboard in round reset
        if (scoreboardEl && match) {
            let scoreboardHTML = '<div class="round-reset-scores">';
            
            // For FFA/1v1, show individual scores
            if (match.gameMode === 'ffa' || match.gameMode === 'gungame' || !match.settings.requiresTeams) {
                const players = [];
                if (match.players) {
                    for (const playerId in match.players) {
                        const playerData = match.players[playerId];
                        const stats = match.stats[playerId] || { kills: 0, deaths: 0 };
                        players.push({
                            id: playerId,
                            kills: stats.kills || 0,
                            deaths: stats.deaths || 0
                        });
                    }
                }
                players.sort((a, b) => b.kills - a.kills);
                
                players.forEach((player, index) => {
                    scoreboardHTML += `
                        <div class="round-reset-player">
                            <span class="round-reset-rank">${index + 1}</span>
                            <span class="round-reset-kills">${player.kills}</span>
                            <span class="round-reset-separator">-</span>
                            <span class="round-reset-deaths">${player.deaths}</span>
                        </div>
                    `;
                });
            } else {
                // Team modes
                const redScore = match.scores?.red || 0;
                const blueScore = match.scores?.blue || 0;
                scoreboardHTML += `
                    <div class="round-reset-team">
                        <span class="round-reset-team-name red">RED</span>
                        <span class="round-reset-score">${redScore}</span>
                    </div>
                    <div class="round-reset-team">
                        <span class="round-reset-team-name blue">BLUE</span>
                        <span class="round-reset-score">${blueScore}</span>
                    </div>
                `;
            }
            
            scoreboardHTML += '</div>';
            scoreboardEl.innerHTML = scoreboardHTML;
        }
        
        container.classList.remove('hidden');
        container.style.display = 'flex';
    }
}

function updateRoundReset(countdown, match) {
    const countdownEl = document.getElementById('round-reset-countdown');
    if (countdownEl) {
        countdownEl.textContent = countdown;
    }
    
    // Update scoreboard if match data provided
    if (match) {
        const scoreboardEl = document.getElementById('round-reset-scoreboard');
        if (scoreboardEl) {
            let scoreboardHTML = '<div class="round-reset-scores">';
            
            if (match.gameMode === 'ffa' || match.gameMode === 'gungame' || !match.settings.requiresTeams) {
                const players = [];
                if (match.players) {
                    for (const playerId in match.players) {
                        const playerData = match.players[playerId];
                        const stats = match.stats[playerId] || { kills: 0, deaths: 0 };
                        players.push({
                            id: playerId,
                            kills: stats.kills || 0,
                            deaths: stats.deaths || 0
                        });
                    }
                }
                players.sort((a, b) => b.kills - a.kills);
                
                players.forEach((player, index) => {
                    scoreboardHTML += `
                        <div class="round-reset-player">
                            <span class="round-reset-rank">${index + 1}</span>
                            <span class="round-reset-kills">${player.kills}</span>
                            <span class="round-reset-separator">-</span>
                            <span class="round-reset-deaths">${player.deaths}</span>
                        </div>
                    `;
                });
            } else {
                const redScore = match.scores?.red || 0;
                const blueScore = match.scores?.blue || 0;
                scoreboardHTML += `
                    <div class="round-reset-team">
                        <span class="round-reset-team-name red">RED</span>
                        <span class="round-reset-score">${redScore}</span>
                    </div>
                    <div class="round-reset-team">
                        <span class="round-reset-team-name blue">BLUE</span>
                        <span class="round-reset-score">${blueScore}</span>
                    </div>
                `;
            }
            
            scoreboardHTML += '</div>';
            scoreboardEl.innerHTML = scoreboardHTML;
        }
    }
}

function hideRoundReset() {
    const container = document.getElementById('round-reset-container');
    if (container) {
        container.classList.add('hidden');
        container.style.display = 'none';
    }
}

function updatePlayerName(playerId, playerName) {
    // Update player name in lobby if it exists
    const playerElement = document.getElementById(`player-${playerId}`);
    if (playerElement) {
        playerElement.textContent = playerName;
    }
}

// Leaderboard
function showLeaderboard(stats) {
    const tbody = document.getElementById('leaderboard-body');
    const emptyState = document.getElementById('leaderboard-empty-state');
    tbody.innerHTML = '';
    
    if (!stats || stats.length === 0) {
        if (emptyState) {
            emptyState.classList.remove('hidden');
        } else {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td colspan="11" style="text-align: center; padding: 40px; color: rgba(255, 255, 255, 0.5);">
                    No statistics available yet. Play some matches to see your rank!
                </td>
            `;
            tbody.appendChild(row);
        }
    } else {
        if (emptyState) {
            emptyState.classList.add('hidden');
        }
    stats.forEach((stat, index) => {
        const row = document.createElement('tr');
            const rank = index + 1;
            const rankIcon = rank === 1 ? '🥇' : rank === 2 ? '🥈' : rank === 3 ? '🥉' : '';
            
            // Color code based on rank
            let rowClass = '';
            if (rank === 1) rowClass = 'leaderboard-gold';
            else if (rank === 2) rowClass = 'leaderboard-silver';
            else if (rank === 3) rowClass = 'leaderboard-bronze';
            
            // Format prestige display
            let prestigeDisplay = '-';
            if (stat.prestige && stat.prestige > 0) {
                if (stat.prestigeIcon) {
                    prestigeDisplay = `${stat.prestigeIcon} ${stat.prestige}`;
                } else {
                    prestigeDisplay = `⭐ ${stat.prestige}`;
                }
            }
            
            // Format rank display
            const rankDisplay = stat.rankInsignia ? `${stat.rankInsignia} ${stat.rank}` : stat.rank;
            
            row.className = rowClass;
        row.innerHTML = `
                <td>
                    <span class="leaderboard-rank">${rankIcon ? rankIcon + ' ' : ''}${rank}</span>
                </td>
                <td class="leaderboard-player-name">${stat.name || stat.citizenid || 'Unknown'}</td>
                <td class="leaderboard-prestige">${prestigeDisplay}</td>
                <td class="leaderboard-level">
                    <span class="leaderboard-rank-badge">${rankDisplay}</span>
                    <span class="leaderboard-level-number">Lv. ${stat.level || 1}</span>
                </td>
                <td>${stat.kills || 0}</td>
                <td>${stat.deaths || 0}</td>
                <td class="leaderboard-kd">${(stat.kd || 0).toFixed(2)}</td>
                <td class="leaderboard-wins">${stat.wins || 0}</td>
                <td class="leaderboard-losses">${stat.losses || 0}</td>
                <td class="leaderboard-winrate">${(stat.winRate || 0).toFixed(1)}%</td>
                <td>${stat.matches || stat.totalGames || 0}</td>
        `;
        tbody.appendChild(row);
    });
    }
    
    const leaderboard = document.getElementById('leaderboard-container');
    if (leaderboard) {
        leaderboard.classList.remove('hidden');
        leaderboard.style.display = 'flex';
    }
    
    updateMainMenuCloseButton();
    
    // Setup tab switching
    const tabs = document.querySelectorAll('.leaderboard-tab');
    const overallContent = document.getElementById('leaderboard-overall-content');
    const rankedContent = document.getElementById('leaderboard-ranked-content');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            const tabType = this.dataset.tab;
            
            // Update active tab
            tabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            
            // Show/hide content
            if (tabType === 'overall') {
                if (overallContent) {
                    overallContent.classList.remove('hidden');
                    overallContent.style.display = 'block';
                }
                if (rankedContent) {
                    rankedContent.classList.add('hidden');
                    rankedContent.style.display = 'none';
                }
            } else if (tabType === 'ranked') {
                if (overallContent) {
                    overallContent.classList.add('hidden');
                    overallContent.style.display = 'none';
                }
                if (rankedContent) {
                    rankedContent.classList.remove('hidden');
                    rankedContent.style.display = 'block';
                }
            }
        });
    });
    
    // Setup back button (goes back to main menu)
    const backBtn = document.getElementById('back-leaderboard');
    if (backBtn) {
        backBtn.onclick = function() {
            leaderboard.classList.add('hidden');
            leaderboard.style.display = 'none';
            updateMainMenuCloseButton();
            // Go back to main menu
            openMainMenu();
        };
    }
    
    // Setup close button (closes entire UI)
    const closeBtn = document.getElementById('close-leaderboard');
    if (closeBtn) {
        closeBtn.onclick = function() {
            leaderboard.classList.add('hidden');
            leaderboard.style.display = 'none';
            updateMainMenuCloseButton();
            fetch(`https://${GetParentResourceName()}/closeUI`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
}

// ESC key handler to close any open UI
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape' || event.keyCode === 27) {
        // Only prevent default if we're actually closing a menu
        // Don't prevent default on scroll events
        if (event.key === 'Escape' || event.keyCode === 27) {
            event.preventDefault();
            event.stopPropagation();
        }
        
        // Check if any menu is open
        const mainMenu = document.getElementById('main-menu-container');
        const gameModeMenu = document.getElementById('gamemode-menu-container');
        const weaponMenu = document.getElementById('weapon-menu-container');
        const practiceSettings = document.getElementById('practice-settings-container');
        const leaderboard = document.getElementById('leaderboard-container');
        const lobby = document.getElementById('lobby-container');
        const matchContainer = document.getElementById('match-container');
        
        // Check if any menu is visible (check both class and style)
        const isMainMenuOpen = mainMenu && (!mainMenu.classList.contains('hidden') && mainMenu.style.display !== 'none');
        const isGameModeOpen = gameModeMenu && (!gameModeMenu.classList.contains('hidden') && gameModeMenu.style.display !== 'none');
        const isWeaponMenuOpen = weaponMenu && (!weaponMenu.classList.contains('hidden') && weaponMenu.style.display !== 'none');
        const isPracticeOpen = practiceSettings && (!practiceSettings.classList.contains('hidden') && practiceSettings.style.display !== 'none');
        const isLeaderboardOpen = leaderboard && (!leaderboard.classList.contains('hidden') && leaderboard.style.display !== 'none');
        const isLobbyOpen = lobby && (!lobby.classList.contains('hidden') && lobby.style.display !== 'none');
        const isMatchOpen = matchContainer && (!matchContainer.classList.contains('hidden') && matchContainer.style.display !== 'none');
        
        // If any menu is open, close it instantly
        if (isMainMenuOpen || isGameModeOpen || isWeaponMenuOpen || isPracticeOpen || isLeaderboardOpen || isLobbyOpen || isMatchOpen) {
            console.log('[Paintball] ESC pressed, closing menu');
            // Close all menus instantly first, then notify server
            closeLobby();
            closeMatch();
            closeMainMenu();
            closeGameModeMenu();
            closeWeaponMenu();
            closePracticeSettings();
            hidePracticeHUD();
            hidePracticeSummary();
            hideInteractionPrompt();
            hideLobbyIndicator();
            // Then notify server
            fetch(`https://${GetParentResourceName()}/closeUI`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(err => console.error('[Paintball] Error closing UI:', err));
        }
    }
});

// Main Menu Functions
function openMainMenu(skipRefresh) {
    // Hide interaction prompt when menu opens (instant)
    hideInteractionPrompt();
    
    // Get menu element first
    const menu = document.getElementById('main-menu-container');
    
    // Check if menu is already visible (going back from sub-menu)
    const isAlreadyOpen = menu && !menu.classList.contains('hidden') && menu.style.display !== 'none';
    
    // Hide all other containers FIRST (immediate, synchronous - no delays)
    const containers = ['lobby-container', 'scoreboard-container', 'leaderboard-container', 'gamemode-menu-container', 'weapon-menu-container', 'practice-settings-container'];
    containers.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.classList.add('hidden');
            el.style.display = 'none';
            el.style.visibility = 'hidden';
        }
    });
    
    // Show menu instantly - all styles already set in CSS with !important
    if (menu) {
        // Remove hidden class and show - CSS handles positioning
        menu.classList.remove('hidden');
        menu.style.display = 'block';
        menu.style.visibility = 'visible';
        // Force immediate reflow (no delay)
        void menu.offsetHeight;
    }
    
    // Setup event listeners (only once to prevent duplicates)
    if (!mainMenuListenersSetup) {
        setupMainMenuListeners();
    }
    
    // Only start auto-refresh if menu wasn't already open (prevents refresh when going back)
    if (!skipRefresh && !isAlreadyOpen) {
        startLobbyAutoRefresh();
    }
}

// Check if any sub-menu is open
function isAnySubMenuOpen() {
    const subMenus = [
        'prestige-menu-container',
        'weapon-menu-container',
        'practice-settings-container',
        'gamemode-menu-container',
        'kills-menu-container',
        'wager-menu-container',
        'leaderboard-container'
    ];
    
    for (const menuId of subMenus) {
        const menu = document.getElementById(menuId);
        if (menu && !menu.classList.contains('hidden')) {
            return true; // A sub-menu is open
        }
    }
    return false; // No sub-menus are open
}

// Update main menu close button state
function updateMainMenuCloseButton() {
    const closeBtn = document.getElementById('close-main-menu');
    if (closeBtn) {
        if (isAnySubMenuOpen()) {
            // Disable close button when any sub-menu is open
            closeBtn.style.pointerEvents = 'none';
            closeBtn.style.opacity = '0.5';
        } else {
            // Enable close button when no sub-menus are open
            closeBtn.style.pointerEvents = 'auto';
            closeBtn.style.opacity = '1';
        }
    }
}

function closeMainMenu() {
    // Don't close if any sub-menu is open
    if (isAnySubMenuOpen()) {
        return; // A sub-menu is open, don't close main menu
    }
    
    // Instant close - no delays
    const menu = document.getElementById('main-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
        menu.style.visibility = 'hidden';
    }
    
    // Stop auto-refreshing lobbies when menu is closed
    stopLobbyAutoRefresh();
}

// Track if listeners are already set up to prevent duplicates
let mainMenuListenersSetup = false;

function setupMainMenuListeners() {
    // Prevent duplicate listeners
    if (mainMenuListenersSetup) {
        return;
    }
    mainMenuListenersSetup = true;
    
    // Close button - clone to remove old listeners
    const closeBtn = document.getElementById('close-main-menu');
    if (closeBtn) {
        const newCloseBtn = closeBtn.cloneNode(true);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        newCloseBtn.onclick = function() {
            // Check if any sub-menu is open
            if (isAnySubMenuOpen()) {
                return; // Don't close if any sub-menu is open
            }
            
            closeMainMenu();
            fetch(`https://${GetParentResourceName()}/closeMainMenu`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(() => {});
        };
    }
    
    // Create Match button - clone to remove old listeners
    const createMatchBtn = document.getElementById('menu-create-match');
    if (createMatchBtn) {
        const newCreateBtn = createMatchBtn.cloneNode(true);
        createMatchBtn.parentNode.replaceChild(newCreateBtn, createMatchBtn);
        
        newCreateBtn.onclick = function() {
            // Prevent multiple clicks
            if (newCreateBtn.style.pointerEvents === 'none') return;
            newCreateBtn.style.pointerEvents = 'none';
            setTimeout(() => { newCreateBtn.style.pointerEvents = 'auto'; }, 300);
            
            fetch(`https://${GetParentResourceName()}/openGameModeMenu`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(() => {});
        };
    }
    
    // Practice Mode button
    const rankedBtn = document.getElementById('menu-ranked-pvp');
    if (rankedBtn) {
        rankedBtn.onclick = function() {
            // Placeholder for ranked PvP - will be implemented later
            fetch(`https://${GetParentResourceName()}/openRankedPvP`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
    
    const practiceBtn = document.getElementById('menu-practice-mode');
    if (practiceBtn) {
        practiceBtn.onclick = function() {
            fetch(`https://${GetParentResourceName()}/startPracticeMode`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            closeMainMenu();
        };
    }
    
    // Initialize progression display (placeholder data - will be populated from server)
    updateProgressionDisplay({
        prestige: 0,
        prestigeLevel: 0,
        rank: 'Rookie',
        rankInsignia: '🎖️',
        level: 1,
        xp: 0,
        xpRequired: 1000,
        rankedRating: null
    });
    
    // Leaderboard button
    const leaderboardBtn = document.getElementById('menu-leaderboard');
    if (leaderboardBtn) {
        leaderboardBtn.onclick = function() {
            // Close main menu first
            closeMainMenu();
            // Request leaderboard data
            fetch(`https://${GetParentResourceName()}/showLeaderboard`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
}

function openGameModeMenu(gameModes) {
    // Hide main menu instantly (no delay)
    const mainMenu = document.getElementById('main-menu-container');
    if (mainMenu) {
        mainMenu.classList.add('hidden');
        mainMenu.style.display = 'none';
        mainMenu.style.visibility = 'hidden';
    }
    
    // Hide all other containers instantly
    const containers = ['lobby-container', 'scoreboard-container', 'leaderboard-container'];
    containers.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.classList.add('hidden');
            el.style.display = 'none';
            el.style.visibility = 'hidden';
        }
    });
    
    const menu = document.getElementById('gamemode-menu-container');
    const content = document.getElementById('gamemode-options');
    
    if (menu && content) {
        // Show menu FIRST (before populating content) to prevent freeze
        menu.style.position = 'fixed';
        menu.style.top = '50%';
        menu.style.left = '50%';
        menu.style.transform = 'translate(-50%, -50%)';
        menu.style.opacity = '1';
        menu.style.transition = 'none';
        menu.style.visibility = 'visible';
        menu.classList.remove('hidden');
        menu.style.display = 'block';
        
        // Force immediate render to prevent freeze
        void menu.offsetHeight;
        
        // Clear existing options to prevent duplicates
        content.innerHTML = '';
        
        // Add game mode options
        if (gameModes && gameModes.length > 0) {
            gameModes.forEach(mode => {
                const option = document.createElement('div');
                option.className = 'gamemode-option';
                option.innerHTML = `
                    <div class="gamemode-option-icon">🎮</div>
                    <div class="gamemode-option-content">
                        <div class="gamemode-option-title">${mode.name}</div>
                        <div class="gamemode-option-desc">${mode.description}</div>
                    </div>
                    <div class="gamemode-option-arrow">→</div>
                `;
                option.onclick = function() {
                    // Prevent multiple clicks
                    if (option.style.pointerEvents === 'none') return;
                    option.style.pointerEvents = 'none';
                    setTimeout(() => { option.style.pointerEvents = 'auto'; }, 300);
                    
                    // Close menu immediately for smooth transition (instant, no delay)
                    closeGameModeMenu();
                    // Then notify server (non-blocking)
                    fetch(`https://${GetParentResourceName()}/selectGameMode`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ gameMode: mode.id })
                    }).catch(() => {}); // Silently fail if needed
                };
                content.appendChild(option);
            });
        }
        
        // Menu already shown above, ensure it stays visible
        if (menu.classList.contains('hidden')) {
            menu.classList.remove('hidden');
        }
        menu.style.display = 'block';
        menu.style.visibility = 'visible';
        // Force immediate render (no delay)
        void menu.offsetHeight;
    }
    
    updateMainMenuCloseButton();
    
    // Setup close button (remove old listener first to prevent duplicates)
    const closeBtn = document.getElementById('close-gamemode-menu');
    if (closeBtn) {
        // Clone and replace to remove old event listeners
        const newCloseBtn = closeBtn.cloneNode(true);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        newCloseBtn.onclick = function() {
            // Prevent multiple clicks
            if (newCloseBtn.style.pointerEvents === 'none') return;
            newCloseBtn.style.pointerEvents = 'none';
            setTimeout(() => { newCloseBtn.style.pointerEvents = 'auto'; }, 200);
            
            // Instant close - smooth transition back to main menu (no refresh, no delay)
            const gameModeMenu = document.getElementById('gamemode-menu-container');
            if (gameModeMenu) {
                gameModeMenu.classList.add('hidden');
                gameModeMenu.style.display = 'none';
                gameModeMenu.style.visibility = 'hidden';
            }
            // Show main menu immediately without refreshing (instant)
            openMainMenu(true); // Pass true to skip refresh
            // Notify server after UI is updated (non-blocking)
            fetch(`https://${GetParentResourceName()}/closeGameModeMenu`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            }).catch(() => {}); // Silently fail if needed
        };
    }
}

function closeGameModeMenu() {
    // Instant close - no delays
    const menu = document.getElementById('gamemode-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
        menu.style.visibility = 'hidden';
    }
    updateMainMenuCloseButton();
}

// Weapon Selection Menu Functions
function openWeaponMenu(weapons) {
    // Hide main menu
    closeMainMenu();
    
    // Hide all other containers
    const containers = ['lobby-container', 'scoreboard-container', 'leaderboard-container', 'gamemode-menu-container', 'weapon-menu-container', 'practice-settings-container'];
    containers.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.classList.add('hidden');
            el.style.display = 'none';
        }
    });
    
    const menu = document.getElementById('weapon-menu-container');
    const categoriesContainer = document.getElementById('weapon-categories');
    const weaponsContainer = document.getElementById('weapon-list');
    
    if (menu && categoriesContainer) {
        // Clear existing options
        categoriesContainer.innerHTML = '';
        if (weaponsContainer) {
            weaponsContainer.innerHTML = '';
            weaponsContainer.classList.add('hidden');
        }
        
        // Show categories container
        categoriesContainer.classList.remove('hidden');
        
        // Add back button if opened from another menu
        if (weaponMenuSource) {
            const backBtn = document.createElement('div');
            backBtn.className = 'menu-option';
            backBtn.style.background = 'linear-gradient(135deg, rgba(255, 102, 0, 0.2) 0%, rgba(255, 140, 0, 0.15) 100%)';
            backBtn.style.borderColor = 'rgba(255, 102, 0, 0.4)';
            backBtn.style.marginBottom = '12px';
            backBtn.innerHTML = `
                <div class="menu-option-icon" style="background: linear-gradient(135deg, rgba(255, 102, 0, 0.4) 0%, rgba(255, 140, 0, 0.3) 100%); border-color: rgba(255, 102, 0, 0.5);">←</div>
                <div class="menu-option-content">
                    <div class="menu-option-title" style="color: #ffaa44;">Back</div>
                    <div class="menu-option-desc">Return to ${weaponMenuSource === 'practice' ? 'Practice Settings' : 'Game Mode'}</div>
                </div>
                <div class="menu-option-arrow">←</div>
            `;
            backBtn.onclick = function() {
                // Instant close - no delays
                closeWeaponMenu();
                fetch(`https://${GetParentResourceName()}/closeWeaponMenu`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
            };
            categoriesContainer.appendChild(backBtn);
        }
        
        // Add weapon category options
        if (weapons && weapons.length > 0) {
            weapons.forEach(category => {
                const option = document.createElement('div');
                option.className = 'menu-option';
                option.innerHTML = `
                    <div class="menu-option-icon">📁</div>
                    <div class="menu-option-content">
                        <div class="menu-option-title">${category.name}</div>
                        <div class="menu-option-desc">${category.description || ''}</div>
                    </div>
                    <div class="menu-option-arrow">→</div>
                `;
                option.onclick = function() {
                    // Show weapons in this category
                    openWeaponCategory(category, category.weapons);
                };
                categoriesContainer.appendChild(option);
            });
        }
        
        menu.style.opacity = '1';
        menu.style.transition = 'none';
        menu.classList.remove('hidden');
        menu.style.display = 'block';
        void menu.offsetHeight;
    }
    
    updateMainMenuCloseButton();
    
    // Setup close button
    const closeBtn = document.getElementById('close-weapon-menu');
    if (closeBtn) {
        closeBtn.onclick = function() {
            closeWeaponMenu();
            fetch(`https://${GetParentResourceName()}/closeWeaponMenu`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
}

function openWeaponCategory(category, weapons) {
    const categoriesContainer = document.getElementById('weapon-categories');
    const weaponsContainer = document.getElementById('weapon-list');
    
    if (categoriesContainer && weaponsContainer) {
        // Hide categories, show weapons
        categoriesContainer.classList.add('hidden');
        weaponsContainer.classList.remove('hidden');
        weaponsContainer.innerHTML = '';
        
        // Add back button (more prominent)
        const backBtn = document.createElement('div');
        backBtn.className = 'menu-option';
        backBtn.style.background = 'linear-gradient(135deg, rgba(255, 102, 0, 0.2) 0%, rgba(255, 140, 0, 0.15) 100%)';
        backBtn.style.borderColor = 'rgba(255, 102, 0, 0.4)';
        backBtn.style.marginBottom = '12px';
        backBtn.innerHTML = `
            <div class="menu-option-icon" style="background: linear-gradient(135deg, rgba(255, 102, 0, 0.4) 0%, rgba(255, 140, 0, 0.3) 100%); border-color: rgba(255, 102, 0, 0.5);">←</div>
            <div class="menu-option-content">
                <div class="menu-option-title" style="color: #ffaa44;">Back to Categories</div>
                <div class="menu-option-desc">Return to weapon categories</div>
            </div>
            <div class="menu-option-arrow">←</div>
        `;
        backBtn.onclick = function() {
            // Instant transition - no delays
            weaponsContainer.classList.add('hidden');
            categoriesContainer.classList.remove('hidden');
        };
        weaponsContainer.appendChild(backBtn);
        
        // Add weapons
        if (weapons && weapons.length > 0) {
            weapons.forEach(weapon => {
                const option = document.createElement('div');
                option.className = 'menu-option';
                option.innerHTML = `
                    <div class="menu-option-icon">🔫</div>
                    <div class="menu-option-content">
                        <div class="menu-option-title">${weapon.name}</div>
                    </div>
                    <div class="menu-option-arrow">→</div>
                `;
                option.onclick = function() {
                    console.log('[Paintball] Weapon clicked:', weapon.weapon, weapon.name);
                    // Don't close menu here - let the client handle it
                    fetch(`https://${GetParentResourceName()}/selectWeapon`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ 
                            weapon: weapon.weapon,
                            weaponName: weapon.name
                        })
                    }).then(response => {
                        console.log('[Paintball] selectWeapon response:', response);
                    }).catch(error => {
                        console.error('[Paintball] selectWeapon error:', error);
                    });
                    // Menu will be closed by the client-side SelectWeapon function
                };
                weaponsContainer.appendChild(option);
            });
        }
    }
}

function closeWeaponMenu() {
    // Instant close - no delays
    const menu = document.getElementById('weapon-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
        menu.style.visibility = 'hidden';
    }
    updateMainMenuCloseButton();
    const categoriesContainer = document.getElementById('weapon-categories');
    const weaponsContainer = document.getElementById('weapon-list');
    if (categoriesContainer) {
        categoriesContainer.classList.remove('hidden');
        categoriesContainer.style.visibility = 'visible';
    }
    if (weaponsContainer) {
        weaponsContainer.classList.add('hidden');
        weaponsContainer.style.visibility = 'hidden';
    }
    
    // If we came from practice settings, ensure practice settings menu is visible (instant)
    if (weaponMenuSource === 'practice') {
        const practiceMenu = document.getElementById('practice-settings-container');
        if (practiceMenu) {
            practiceMenu.classList.remove('hidden');
            practiceMenu.style.display = 'flex';
            practiceMenu.style.visibility = 'visible';
        }
    }
    
    // Reset source tracking
    weaponMenuSource = null;
}

// Practice Mode Settings Functions
let practiceSettings = {
    weapon: 'WEAPON_PISTOL',
    weaponName: 'Pistol',
    difficulty: 'medium',
    botCount: 15,
    botCountEnabled: false,
    killTarget: 30,
    killTargetEnabled: false,
    waveMode: false,
    waveSize: 5,
    timeLimit: 10,
    timeLimitEnabled: false,
    aiMode: 'none', // 'none', 'killtarget', 'wave', 'timelimit'
    healthSystem: null, // null when disabled, 'health_per_kill' or 'armor' when enabled
    healthSystemEnabled: false,
    healthPerKill: 0,
    armorPerKill: 0
};

// Bot count ranges based on difficulty
const botCountRanges = {
    easy: { min: 10, max: 20 },
    medium: { min: 30, max: 60 },
    hard: { min: 70, max: 100 }
};

function openPracticeSettings(settings) {
    // Hide main menu visually (keep NUI focus)
    const mainMenu = document.getElementById('main-menu-container');
    if (mainMenu) {
        mainMenu.classList.add('hidden');
        mainMenu.style.display = 'none';
    }
    
    // Hide all other containers (instant, no delays)
    const containers = ['lobby-container', 'scoreboard-container', 'leaderboard-container', 'gamemode-menu-container', 'weapon-menu-container'];
    containers.forEach(id => {
        const el = document.getElementById(id);
        if (el) {
            el.classList.add('hidden');
            el.style.display = 'none';
            el.style.visibility = 'hidden';
        }
    });
    
    const menu = document.getElementById('practice-settings-container');
    if (menu) {
        // Update settings if provided
        if (settings) {
            practiceSettings = { ...practiceSettings, ...settings };
        }
        
        // Update UI with current settings
        updatePracticeSettingsUI();
        
        // Setup click handlers
        setupPracticeSettingsHandlers();
        
        // Show instantly (no animation, no delay)
        menu.style.opacity = '1';
        menu.style.transition = 'none';
        menu.style.visibility = 'visible';
        menu.classList.remove('hidden');
        menu.style.display = 'flex';
        void menu.offsetHeight; // Force immediate render
        
        updateMainMenuCloseButton();
        
        // Ensure scrollable area can scroll
        const scrollable = menu.querySelector('.practice-settings-scrollable');
        if (scrollable) {
            // Force scroll to work
            scrollable.style.overflowY = 'scroll';
            scrollable.style.overflowX = 'hidden';
            
            // Add wheel event listener to ensure scrolling works
            scrollable.addEventListener('wheel', function(e) {
                // Allow default scroll behavior - don't stop propagation
                // Just let it scroll naturally
            }, { passive: true });
            
            // Add touch event listeners for mobile
            scrollable.addEventListener('touchstart', function(e) {
                e.stopPropagation();
            }, { passive: true });
            
            scrollable.addEventListener('touchmove', function(e) {
                e.stopPropagation();
            }, { passive: true });
        }
    }
}

function updatePracticeSettingsUI() {
    const weaponValue = document.getElementById('practice-weapon-value');
    const killsValue = document.getElementById('practice-kills-value');
    
    if (weaponValue) weaponValue.textContent = practiceSettings.weaponName || 'Pistol';
    
    // Kill target value
    if (killsValue) killsValue.textContent = `${practiceSettings.killTarget || 30} Kills`;
    
    // Health system - Update UI based on current settings
    const healthToggle = document.getElementById('practice-health-toggle');
    const healthWrapper = document.getElementById('practice-health-wrapper');
    const healthTypeMenu = document.getElementById('practice-health-type-menu');
    const healthSubmenu = document.getElementById('practice-health-submenu');
    const armorSubmenu = document.getElementById('practice-armor-submenu');
    const healthPerKillValue = document.getElementById('practice-healthperkill-value');
    const armorPerKillValue = document.getElementById('practice-armorperkill-value');
    
    if (healthToggle) {
        healthToggle.checked = practiceSettings.healthSystemEnabled === true;
        if (healthWrapper) {
            healthWrapper.style.display = healthToggle.checked ? 'flex' : 'none';
        }
    }
    
    // Update health system type menu active state (only if enabled)
    if (healthTypeMenu && healthToggle && healthToggle.checked) {
        const typeOptions = healthTypeMenu.querySelectorAll('.practice-health-type-option');
        typeOptions.forEach(option => {
            option.classList.remove('active');
            const type = option.dataset.type;
            
            // Map healthSystem to type
            if (practiceSettings.healthSystem === 'health_per_kill' && type === 'health') {
                option.classList.add('active');
            } else if (practiceSettings.healthSystem === 'armor' && type === 'armor') {
                option.classList.add('active');
            }
        });
        
        // Show appropriate menu based on current health system
        if (practiceSettings.healthSystem === 'health_per_kill') {
            if (healthTypeMenu) healthTypeMenu.style.display = 'none';
            if (healthSubmenu) healthSubmenu.style.display = 'flex';
            if (armorSubmenu) armorSubmenu.style.display = 'none';
        } else if (practiceSettings.healthSystem === 'armor') {
            if (healthTypeMenu) healthTypeMenu.style.display = 'none';
            if (healthSubmenu) healthSubmenu.style.display = 'none';
            if (armorSubmenu) armorSubmenu.style.display = 'flex';
        } else {
            // No system selected - show type menu
            if (healthTypeMenu) healthTypeMenu.style.display = 'flex';
            if (healthSubmenu) healthSubmenu.style.display = 'none';
            if (armorSubmenu) armorSubmenu.style.display = 'none';
        }
    } else {
        // Health system is disabled - hide everything
        if (healthTypeMenu) healthTypeMenu.style.display = 'none';
        if (healthSubmenu) healthSubmenu.style.display = 'none';
        if (armorSubmenu) armorSubmenu.style.display = 'none';
    }
    
    if (healthPerKillValue) {
        healthPerKillValue.textContent = (practiceSettings.healthPerKill || 0).toString();
    }
    if (armorPerKillValue) {
        armorPerKillValue.textContent = (practiceSettings.armorPerKill || 0).toString();
    }
    
    // Free Play mode is always active (only mode available)
    const modeOptions = document.querySelectorAll('.practice-mode-option');
    modeOptions.forEach(opt => {
        if (opt.dataset.mode === 'none') {
            opt.classList.add('active');
        } else {
            opt.classList.remove('active');
        }
    });
}

function setupPracticeSettingsHandlers() {
    // Weapon setting
    const weaponSetting = document.getElementById('practice-weapon-setting');
    if (weaponSetting) {
        weaponSetting.onclick = function() {
            fetch(`https://${GetParentResourceName()}/openWeaponMenu`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ forPractice: true })
            });
        };
    }
    
    // AI Mode Selector - replaces individual toggles
    // Set Free Play as default mode (only mode available)
    practiceSettings.aiMode = 'none';
    practiceSettings.killTargetEnabled = false;
    practiceSettings.waveMode = false;
    practiceSettings.timeLimitEnabled = false;
    
    // Kill Target value (click to change) - for killtarget mode (disabled for now)
    const killsValue = document.getElementById('practice-kills-value');
    
    // Health System - Hierarchical Menu System
    const healthSetting = document.getElementById('practice-health-setting');
    const healthToggle = document.getElementById('practice-health-toggle');
    const healthWrapper = document.getElementById('practice-health-wrapper');
    const healthTypeMenu = document.getElementById('practice-health-type-menu');
    const healthSubmenu = document.getElementById('practice-health-submenu');
    const armorSubmenu = document.getElementById('practice-armor-submenu');
    const healthBackBtn = document.getElementById('practice-health-back-btn');
    const armorBackBtn = document.getElementById('practice-armor-back-btn');
    const healthMainArrow = document.getElementById('practice-health-main-arrow');
    
    // Toggle health system on/off
    if (healthToggle && healthWrapper) {
        healthToggle.addEventListener('change', function() {
            practiceSettings.healthSystemEnabled = healthToggle.checked;
            healthWrapper.style.display = healthToggle.checked ? 'flex' : 'none';
            
            if (healthToggle.checked) {
                // When enabled, show type menu (no system selected yet)
                showHealthTypeMenu();
                // Reset health system to null so nothing is active until user selects
                practiceSettings.healthSystem = null;
            } else {
                // When disabled, reset everything
                practiceSettings.healthSystem = null;
                practiceSettings.healthPerKill = 0;
                practiceSettings.armorPerKill = 0;
                hideAllHealthMenus();
            }
            
            // Update UI to reflect changes
            updatePracticeSettingsUI();
            
            fetch(`https://${GetParentResourceName()}/updatePracticeHealthEnabled`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ enabled: healthToggle.checked })
            });
        });
    }
    
    // Click on Health System item to open type menu
    if (healthSetting && healthMainArrow) {
        healthSetting.onclick = function(e) {
            // Don't trigger if clicking on toggle or wrapper
            if (e.target.closest('.practice-toggle') || e.target.closest('.practice-health-wrapper')) {
                return;
            }
            
            if (healthToggle && healthToggle.checked) {
                // Toggle type menu visibility
                if (healthTypeMenu) {
                    const isVisible = healthTypeMenu.style.display !== 'none' && healthTypeMenu.offsetParent !== null;
                    if (isVisible) {
                        hideAllHealthMenus();
                    } else {
                        showHealthTypeMenu();
                    }
                }
            }
        };
    }
    
    // Show health type selection menu
    function showHealthTypeMenu() {
        if (healthTypeMenu) healthTypeMenu.style.display = 'flex';
        if (healthSubmenu) healthSubmenu.style.display = 'none';
        if (armorSubmenu) armorSubmenu.style.display = 'none';
    }
    
    // Hide all health menus
    function hideAllHealthMenus() {
        if (healthTypeMenu) healthTypeMenu.style.display = 'none';
        if (healthSubmenu) healthSubmenu.style.display = 'none';
        if (armorSubmenu) armorSubmenu.style.display = 'none';
    }
    
    // Health type selection (Standard, Health, Armor)
    if (healthTypeMenu) {
        const typeOptions = healthTypeMenu.querySelectorAll('.practice-health-type-option');
        typeOptions.forEach(option => {
            option.addEventListener('click', function(e) {
                e.stopPropagation();
                const type = this.dataset.type;
                
                // Update active state
                typeOptions.forEach(opt => opt.classList.remove('active'));
                this.classList.add('active');
                
                // Map type to healthSystem value
                const healthSystemMap = {
                    'health': 'health_per_kill',
                    'armor': 'armor'
                };
                
                practiceSettings.healthSystem = healthSystemMap[type] || 'health_per_kill';
                
                // Show appropriate submenu
                if (type === 'health') {
                    if (healthSubmenu) healthSubmenu.style.display = 'flex';
                    if (healthTypeMenu) healthTypeMenu.style.display = 'none';
                } else if (type === 'armor') {
                    if (armorSubmenu) armorSubmenu.style.display = 'flex';
                    if (healthTypeMenu) healthTypeMenu.style.display = 'none';
                }
                
                updatePracticeSettingsUI();
                
                fetch(`https://${GetParentResourceName()}/updatePracticeHealthSystem`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ healthSystem: practiceSettings.healthSystem })
                });
            });
        });
    }
    
    // Back buttons
    if (healthBackBtn) {
        healthBackBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            showHealthTypeMenu();
        });
    }
    
    if (armorBackBtn) {
        armorBackBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            showHealthTypeMenu();
        });
    }
    
    // Health per kill setting (in health submenu)
    const healthPerKillSetting = document.getElementById('practice-healthperkill-setting');
    const healthPerKillValue = document.getElementById('practice-healthperkill-value');
    if (healthPerKillSetting && healthPerKillValue) {
        healthPerKillSetting.addEventListener('click', function(e) {
            e.stopPropagation();
            
            // Only 0, 25, and 50
            const amounts = [0, 25, 50];
            // Get current value from displayed value first (most accurate), then fallback to stored
            let current = 0;
            if (healthPerKillValue && healthPerKillValue.textContent) {
                const displayedValue = Number(healthPerKillValue.textContent.trim());
                if (!isNaN(displayedValue) && amounts.includes(displayedValue)) {
                    current = displayedValue;
                }
            }
            // Fallback to stored value if displayed value wasn't valid
            if (current === 0 && practiceSettings.healthPerKill !== undefined) {
                const storedValue = Number(practiceSettings.healthPerKill);
                if (!isNaN(storedValue) && amounts.includes(storedValue)) {
                    current = storedValue;
                }
            }
            
            // Find current index (must be exact match)
            let currentIndex = amounts.indexOf(current);
            if (currentIndex === -1) {
                // If not found, default to 0
                currentIndex = 0;
                current = 0;
            }
            
            // Move to next value (forward: 0 → 25 → 50 → 0)
            const nextIndex = (currentIndex + 1) % amounts.length;
            const nextAmount = amounts[nextIndex];
            
            console.log('[Paintball] Health per kill - current:', current, 'index:', currentIndex, 'next:', nextAmount);
            
            practiceSettings.healthPerKill = nextAmount;
            healthPerKillValue.textContent = nextAmount.toString();
            
            fetch(`https://${GetParentResourceName()}/updatePracticeHealthPerKill`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount: nextAmount })
            });
        });
    }
    
    // Armor per kill setting (in armor submenu)
    const armorPerKillSetting = document.getElementById('practice-armorperkill-setting');
    const armorPerKillValue = document.getElementById('practice-armorperkill-value');
    if (armorPerKillSetting && armorPerKillValue) {
        armorPerKillSetting.addEventListener('click', function(e) {
            e.stopPropagation();
            
            // Only 0, 25, and 50
            const amounts = [0, 25, 50];
            // Get current value from displayed value first (most accurate), then fallback to stored
            let current = 0;
            if (armorPerKillValue && armorPerKillValue.textContent) {
                const displayedValue = Number(armorPerKillValue.textContent.trim());
                if (!isNaN(displayedValue) && amounts.includes(displayedValue)) {
                    current = displayedValue;
                }
            }
            // Fallback to stored value if displayed value wasn't valid
            if (current === 0 && practiceSettings.armorPerKill !== undefined) {
                const storedValue = Number(practiceSettings.armorPerKill);
                if (!isNaN(storedValue) && amounts.includes(storedValue)) {
                    current = storedValue;
                }
            }
            
            // Find current index (must be exact match)
            let currentIndex = amounts.indexOf(current);
            if (currentIndex === -1) {
                // If not found, default to 0
                currentIndex = 0;
                current = 0;
            }
            
            // Move to next value (forward: 0 → 25 → 50 → 0)
            const nextIndex = (currentIndex + 1) % amounts.length;
            const nextAmount = amounts[nextIndex];
            
            console.log('[Paintball] Armor per kill - current:', current, 'index:', currentIndex, 'next:', nextAmount);
            
            practiceSettings.armorPerKill = nextAmount;
            armorPerKillValue.textContent = nextAmount.toString();
            
            fetch(`https://${GetParentResourceName()}/updatePracticeArmorPerKill`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ amount: nextAmount })
            });
        });
    }
    
    // Mode-specific settings removed (only Free Play available)
    
    // Start button
    const startBtn = document.getElementById('start-practice-btn');
    if (startBtn) {
        startBtn.onclick = function() {
            fetch(`https://${GetParentResourceName()}/startPracticeWithSettings`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(practiceSettings)
            });
            closePracticeSettings();
        };
    }
    
    // Back button (closes UI completely) - instant close
    const backBtn = document.getElementById('back-practice-settings');
    if (backBtn) {
        backBtn.onclick = function() {
            // Instant close - no delays
            closePracticeSettings();
            // Close UI completely instead of opening main menu
            fetch(`https://${GetParentResourceName()}/closeUI`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
    
    // Close button (closes entire UI)
    const closeBtn = document.getElementById('close-practice-settings');
    if (closeBtn) {
        closeBtn.onclick = function() {
            closePracticeSettings();
            fetch(`https://${GetParentResourceName()}/closePracticeSettings`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
    }
    
    // Prestige menu close button
    const closePrestigeBtn = document.getElementById('close-prestige-menu');
    if (closePrestigeBtn) {
        closePrestigeBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            closePrestigeMenu();
        });
        closePrestigeBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            closePrestigeMenu();
        };
    }
    
    // Kills menu close button
    const closeKillsBtn = document.getElementById('close-kills-menu');
    if (closeKillsBtn) {
        closeKillsBtn.onclick = function() {
            closeKillsMenu();
        };
    }
    
    // Wager menu close button
    const closeWagerBtn = document.getElementById('close-wager-menu');
    if (closeWagerBtn) {
        closeWagerBtn.onclick = function() {
            closeWagerMenu();
        };
    }
}

function closePracticeSettings() {
    // Instant close - no delays
    const menu = document.getElementById('practice-settings-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
        menu.style.visibility = 'hidden';
    }
    updateMainMenuCloseButton();
}

function updatePracticeWeapon(weapon, weaponName) {
    practiceSettings.weapon = weapon;
    practiceSettings.weaponName = weaponName;
    // Only update the weapon value, don't call full UI update to preserve health settings
    const weaponValue = document.getElementById('practice-weapon-value');
    if (weaponValue) {
        weaponValue.textContent = weaponName || 'Pistol';
    }
}

// Handle weapon update from NUI message
window.addEventListener('message', function(event) {
    if (event.data.action === 'updatePracticeWeapon') {
        updatePracticeWeapon(event.data.weapon, event.data.weaponName);
    }
});


function updatePracticeKills(kills) {
    practiceSettings.killTarget = kills;
    updatePracticeSettingsUI();
}

// Practice HUD Functions
function showPracticeHUD(match) {
    const hud = document.getElementById('practice-hud-container');
    if (hud) {
        hud.classList.remove('hidden');
        hud.style.display = 'block';
    }
}

function updatePracticeHUD(data) {
    const killsEl = document.getElementById('practice-hud-kills');
    const remainingEl = document.getElementById('practice-hud-remaining');
    const timeEl = document.getElementById('practice-hud-time');
    const accuracyEl = document.getElementById('practice-hud-accuracy');
    const streakEl = document.getElementById('practice-hud-streak');
    
    if (killsEl) killsEl.textContent = data.kills || 0;
    if (remainingEl) remainingEl.textContent = data.remaining || 0;
    if (timeEl) timeEl.textContent = data.time || '00:00';
    if (accuracyEl) accuracyEl.textContent = (data.accuracy || 0) + '%';
    if (streakEl) streakEl.textContent = data.streak || 0;
}

function hidePracticeHUD() {
    // Comprehensive cleanup of all practice UI elements - instant, no delays
    const hud = document.getElementById('practice-hud-container');
    if (hud) {
        hud.classList.add('hidden');
        hud.style.display = 'none';
    }
    
    // Hide all other practice-related UI elements
    const killFeed = document.getElementById('kill-feed-container');
    if (killFeed) {
        killFeed.classList.add('hidden');
        killFeed.style.display = 'none';
    }
    
    const hitMarker = document.getElementById('hit-marker');
    if (hitMarker) {
        hitMarker.classList.add('hidden');
    }
    
    const practiceSummary = document.getElementById('practice-summary-container');
    if (practiceSummary) {
        practiceSummary.classList.add('hidden');
        practiceSummary.style.display = 'none';
    }
    
    const respawnCountdown = document.getElementById('respawn-countdown-container');
    if (respawnCountdown) {
        respawnCountdown.classList.add('hidden');
        respawnCountdown.style.display = 'none';
    }
    
    // Hide scoreboard if it's open
    const scoreboard = document.getElementById('scoreboard-container');
    if (scoreboard) {
        scoreboard.classList.add('hidden');
        scoreboard.style.display = 'none';
    }
    
    // Hide match container
    const matchContainer = document.getElementById('match-container');
    if (matchContainer) {
        matchContainer.classList.add('hidden');
        matchContainer.style.display = 'none';
    }
    
    // Hide lobby container
    const lobbyContainer = document.getElementById('lobby-container');
    if (lobbyContainer) {
        lobbyContainer.classList.add('hidden');
        lobbyContainer.style.display = 'none';
    }
    
    // Hide practice settings
    const practiceSettings = document.getElementById('practice-settings-container');
    if (practiceSettings) {
        practiceSettings.classList.add('hidden');
        practiceSettings.style.display = 'none';
    }
}

// Kill Feed Functions
// Advanced Visual Effects Functions
function showHitMarker(isHeadshot) {
    const hitMarker = document.getElementById('hit-marker');
    if (hitMarker) {
        hitMarker.classList.remove('hidden');
        
        // Add headshot effect
        if (isHeadshot) {
            hitMarker.classList.add('headshot');
        } else {
            hitMarker.classList.remove('headshot');
        }
        
        // Hide after animation
        setTimeout(() => {
            hitMarker.classList.add('hidden');
        }, 200);
    }
}

function showKillConfirmation(weapon, isHeadshot) {
    const killConfirm = document.getElementById('kill-confirmation');
    const weaponText = document.getElementById('kill-confirmation-weapon');
    
    if (killConfirm && weaponText) {
        weaponText.textContent = weapon || 'Paintball';
        if (isHeadshot) {
            weaponText.textContent += ' • HEADSHOT';
        }
        
        killConfirm.classList.remove('hidden');
        
        // Hide after animation
        setTimeout(() => {
            killConfirm.classList.add('hidden');
        }, 2000);
    }
}

function showDamageIndicator(damage) {
    const damageIndicator = document.getElementById('damage-indicator');
    const damageAmount = document.getElementById('damage-amount');
    
    if (damageIndicator && damageAmount) {
        damageAmount.textContent = '-' + (damage || 0);
        damageIndicator.classList.remove('hidden');
        
        // Hide after animation
        setTimeout(() => {
            damageIndicator.classList.add('hidden');
        }, 1000);
    }
}

function showPaintSplatter() {
    const splatter = document.getElementById('paint-splatter');
    if (splatter) {
        splatter.classList.add('show');
        
        // Randomize splatter positions
        const splatters = splatter.querySelectorAll('.splatter-1, .splatter-2, .splatter-3');
        splatters.forEach(s => {
            const x = 40 + Math.random() * 20; // 40-60%
            const y = 30 + Math.random() * 20; // 30-50%
            s.style.left = x + '%';
            s.style.top = y + '%';
        });
        
        setTimeout(() => {
            splatter.classList.remove('show');
        }, 500);
    }
}

// Progression System Functions (for future features)
function updateProgressionDisplay(data) {
    // Store current prestige level for menu
    window.currentPrestigeLevel = data.prestigeLevel || 0;
    
    // Enhanced prestige icons with better symbols
    const prestigeIcons = {
        0: '🛡️', // Recruit - Bronze Shield
        1: '⚔️', // Veteran - Silver Crossed Swords
        2: '⚡', // Elite - Gold Lightning
        3: '🔥', // Legend - Platinum Flame
        4: '👑', // Master - Diamond Crown
        5: '🐉'  // Grandmaster - Legendary Dragon
    };
    
    const prestigeLevelNum = Math.min(data.prestigeLevel || 0, 5);
    const prestigeIconSymbol = prestigeIcons[prestigeLevelNum] || prestigeIcons[0];
    const level = data.level || 1;
    const xp = data.xp || 0;
    const xpRequired = data.xpRequired || 1000;
    const totalXP = data.totalXP || xp; // Use totalXP if available, otherwise use current xp
    
    // Update main menu prestige badge
    const prestigeLevel = document.getElementById('prestige-level');
    const prestigeIcon = document.getElementById('prestige-icon');
    const prestigeBadge = document.getElementById('prestige-badge');
    
    if (prestigeLevel && data.prestigeLevel !== undefined) {
        prestigeLevel.textContent = `Prestige ${data.prestigeLevel}`;
    }
    if (prestigeIcon && data.prestigeLevel !== undefined) {
        if (prestigeIcon.tagName === 'SPAN' || prestigeIcon.tagName === 'DIV') {
            prestigeIcon.textContent = prestigeIconSymbol;
            // Add data attribute for CSS styling
            prestigeIcon.setAttribute('data-prestige', prestigeLevelNum.toString());
        }
    }
    
    // Update lobby progression display (CRITICAL - this is what shows in lobby)
    const lobbyPrestigeIcon = document.getElementById('lobby-prestige-icon');
    const lobbyPrestigeLevel = document.getElementById('lobby-prestige-level');
    const lobbyXpText = document.getElementById('lobby-xp-text');
    const lobbyXpProgress = document.getElementById('lobby-xp-progress');
    
    if (lobbyPrestigeIcon) {
        lobbyPrestigeIcon.textContent = prestigeIconSymbol;
        lobbyPrestigeIcon.setAttribute('data-prestige', prestigeLevelNum.toString());
    }
    
    if (lobbyPrestigeLevel) {
        lobbyPrestigeLevel.textContent = `Prestige ${data.prestigeLevel || 0} • Lv. ${level}`;
    }
    
    if (lobbyXpText) {
        lobbyXpText.textContent = `XP this level: ${xp} / ${xpRequired} (Total: ${totalXP})`;
    }
    
    if (lobbyXpProgress) {
        const percentage = Math.min((xp / xpRequired) * 100, 100);
        lobbyXpProgress.style.width = percentage + '%';
    }
    
    // Make prestige badge clickable to open prestige menu
    if (prestigeBadge && !prestigeBadge.hasAttribute('data-listener')) {
        prestigeBadge.style.cursor = 'pointer';
        prestigeBadge.addEventListener('click', function() {
            openPrestigeMenu(data.prestigeLevel || 0);
        });
        prestigeBadge.setAttribute('data-listener', 'true');
    }
    
    // Update rank display
    const rankName = document.getElementById('rank-name');
    const rankInsignia = document.getElementById('rank-insignia');
    if (rankName && data.rank) {
        rankName.textContent = data.rank;
        // Add data attribute for special styling (e.g., Rookie)
        rankName.setAttribute('data-rank', data.rank);
    }
    if (rankInsignia && data.rankInsignia) {
        rankInsignia.textContent = data.rankInsignia;
    }
    
    // Update stats
    const playerLevel = document.getElementById('player-level');
    const playerXp = document.getElementById('player-xp');
    const rankedRating = document.getElementById('ranked-rating');
    
    if (playerLevel && data.level !== undefined) {
        playerLevel.textContent = data.level;
    }
    if (playerXp && data.xp !== undefined && data.xpRequired !== undefined) {
        playerXp.textContent = `${data.xp} / ${data.xpRequired}`;
    }
    if (rankedRating) {
        if (data.rankedRating !== null && data.rankedRating !== undefined) {
            rankedRating.textContent = data.rankedRating;
        } else {
            rankedRating.textContent = 'Unranked';
        }
    }
    
    // Update XP progress bar
    const xpProgressFill = document.getElementById('xp-progress-fill');
    if (xpProgressFill && data.xp !== undefined && data.xpRequired !== undefined) {
        const percentage = Math.min((data.xp / data.xpRequired) * 100, 100);
        xpProgressFill.style.width = percentage + '%';
    }
}

function showRankUpNotification(data) {
    // Future: Show rank up animation with insignia
    // This will be implemented when rank system is added
    console.log('Rank up!', data);
}

function showPrestigeUpNotification(data) {
    // Show prestige up animation with special effects
    console.log('Prestige up!', data);
    // Future: Add visual notification/celebration
}

// Open prestige menu showing all prestige levels
function openPrestigeMenu(currentPrestige) {
    const menu = document.getElementById('prestige-menu-container');
    const grid = document.getElementById('prestige-menu-grid');
    
    if (!menu || !grid) return;
    
    // Clear existing content
    grid.innerHTML = '';
    
    // Prestige data from config (matching server config)
    const prestigeData = {
        0: { title: "Recruit", icon: "🛡️", symbol: "shield" },
        1: { title: "Veteran", icon: "⚔️", symbol: "sword" },
        2: { title: "Elite", icon: "⚡", symbol: "lightning" },
        3: { title: "Legend", icon: "🔥", symbol: "flame" },
        4: { title: "Master", icon: "👑", symbol: "crown" },
        5: { title: "Grandmaster", icon: "🐉", symbol: "dragon" }
    };
    
    // Create prestige items
    for (let i = 0; i <= 5; i++) {
        const isUnlocked = i <= currentPrestige;
        const prestige = prestigeData[i];
        
        const item = document.createElement('div');
        item.className = `prestige-menu-item ${isUnlocked ? 'unlocked' : 'locked'}`;
        item.setAttribute('data-prestige', i.toString());
        
        item.innerHTML = `
            <div class="prestige-menu-icon-wrapper">
                <span class="prestige-menu-icon" data-prestige="${i}">${prestige.icon}</span>
                ${!isUnlocked ? '<div class="prestige-lock-overlay">🔒</div>' : ''}
            </div>
            <div class="prestige-menu-info">
                <div class="prestige-menu-title">${prestige.title}</div>
                <div class="prestige-menu-level">Prestige ${i}</div>
                ${!isUnlocked ? '<div class="prestige-menu-locked">Locked</div>' : '<div class="prestige-menu-unlocked">✓ Unlocked</div>'}
            </div>
        `;
        
        grid.appendChild(item);
    }
    
    // Setup close button handler (ensure it's always attached)
    const closeBtn = document.getElementById('close-prestige-menu');
    if (closeBtn) {
        // Remove existing event listeners by cloning
        const newCloseBtn = closeBtn.cloneNode(true);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        // Add click event listener
        newCloseBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            closePrestigeMenu();
        });
        
        // Also set onclick as backup
        newCloseBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            closePrestigeMenu();
        };
    }
    
    // Show menu
    menu.classList.remove('hidden');
    menu.style.display = 'flex';
    
    // Update main menu close button state (disable if sub-menu is open)
    updateMainMenuCloseButton();
    
    // Focus is handled by client-side Lua when menu opens
}

// Close prestige menu
function closePrestigeMenu() {
    const menu = document.getElementById('prestige-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
        
        // Update main menu close button state
        updateMainMenuCloseButton();
        
        // Focus is handled by client-side Lua when menu closes
    }
}

// Open kills to win menu
function openKillsMenu(currentKills) {
    const menu = document.getElementById('kills-menu-container');
    const grid = document.getElementById('kills-options-grid');
    
    if (!menu || !grid) return;
    
    grid.innerHTML = '';
    
    // Kills options: 5, 10, 15, 20
    const killsOptions = [5, 10, 15, 20];
    
    killsOptions.forEach(kills => {
        const option = document.createElement('div');
        option.className = `setting-option ${kills === currentKills ? 'active' : ''}`;
        option.setAttribute('data-kills', kills.toString());
        
        option.innerHTML = `
            <div class="setting-option-icon">🎯</div>
            <div class="setting-option-content">
                <div class="setting-option-label">${kills} Kills</div>
                <div class="setting-option-desc">First to ${kills} kills wins</div>
            </div>
            ${kills === currentKills ? '<div class="setting-option-check">✓</div>' : ''}
        `;
        
        // Store kills value in closure
        const killsValue = kills;
        
        // Use onclick for better compatibility
        const clickHandler = function(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            // Update kills setting
            fetch(`https://${GetParentResourceName()}/updateLobbyKills`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ kills: killsValue })
            }).then(response => {
                closeKillsMenu();
            }).catch(error => {
                closeKillsMenu();
            });
            return false;
        };
        
        option.onclick = clickHandler;
        option.addEventListener('click', clickHandler, false);
        
        // Add mousedown as additional backup
        option.addEventListener('mousedown', function(e) {
            e.preventDefault();
        });
        
        grid.appendChild(option);
    });
    
    // Setup close button handler (ensure it's always attached)
    const closeBtn = document.getElementById('close-kills-menu');
    if (closeBtn) {
        // Remove existing event listeners by cloning
        const newCloseBtn = closeBtn.cloneNode(true);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        // Add click event listener
        newCloseBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            closeKillsMenu();
        });
        
        // Also set onclick as backup
        newCloseBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            closeKillsMenu();
        };
    }
    
    menu.classList.remove('hidden');
    menu.style.display = 'flex';
    updateMainMenuCloseButton();
}

// Close kills menu
function closeKillsMenu() {
    const menu = document.getElementById('kills-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
    }
    updateMainMenuCloseButton();
}

// Open wager menu
function openWagerMenu(currentWager) {
    const menu = document.getElementById('wager-menu-container');
    const presetGrid = document.getElementById('wager-preset-grid');
    const customInput = document.getElementById('wager-custom-input');
    
    if (!menu || !presetGrid) return;
    
    presetGrid.innerHTML = '';
    if (customInput) {
        customInput.value = currentWager > 0 && ![100, 500, 1000, 5000].includes(currentWager) ? currentWager : '';
    }
    
    // Preset wager amounts
    const wagerPresets = [100, 500, 1000, 5000];
    
    wagerPresets.forEach(amount => {
        const preset = document.createElement('div');
        preset.className = `wager-preset-option ${amount === currentWager ? 'active' : ''}`;
        preset.setAttribute('data-amount', amount.toString());
        preset.style.cursor = 'pointer';
        preset.style.pointerEvents = 'auto';
        preset.style.userSelect = 'none';
        
        preset.innerHTML = `
            <div class="wager-preset-icon">💰</div>
            <div class="wager-preset-amount">$${amount.toLocaleString()}</div>
        `;
        
        // Store amount in a closure-safe way
        const wagerAmount = amount;
        
        // Primary click handler
        const clickHandler = function(e) {
            if (e) {
                e.preventDefault();
                e.stopPropagation();
            }
            applyWager(wagerAmount);
            return false;
        };
        
        // Use onclick (most reliable)
        preset.onclick = clickHandler;
        
        // Also add event listener as backup
        preset.addEventListener('click', clickHandler, false);
        
        // Add mousedown as additional backup
        preset.addEventListener('mousedown', function(e) {
            e.preventDefault();
        });
        
        presetGrid.appendChild(preset);
    });
    
    // Apply button for custom amount - setup handler every time menu opens
    const applyBtn = document.getElementById('wager-apply-btn');
    if (applyBtn) {
        // Remove existing event listeners by cloning
        const newApplyBtn = applyBtn.cloneNode(true);
        applyBtn.parentNode.replaceChild(newApplyBtn, applyBtn);
        
        // Add click event listener
        newApplyBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            const customAmount = customInput ? parseInt(customInput.value) || 0 : 0;
            if (customAmount >= 0) {
                applyWager(customAmount);
            }
        });
        
        // Also set onclick as backup
        newApplyBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            const customAmount = customInput ? parseInt(customInput.value) || 0 : 0;
            if (customAmount >= 0) {
                applyWager(customAmount);
            }
        };
    }
    
    // Also allow Enter key on input
    if (customInput) {
        customInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const customAmount = parseInt(customInput.value) || 0;
                if (customAmount >= 0) {
                    applyWager(customAmount);
                }
            }
        });
    }
    
    // Setup close button handler (ensure it's always attached)
    const closeBtn = document.getElementById('close-wager-menu');
    if (closeBtn) {
        // Remove existing event listeners by cloning
        const newCloseBtn = closeBtn.cloneNode(true);
        closeBtn.parentNode.replaceChild(newCloseBtn, closeBtn);
        
        // Add click event listener
        newCloseBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            closeWagerMenu();
        });
        
        // Also set onclick as backup
        newCloseBtn.onclick = function(e) {
            e.preventDefault();
            e.stopPropagation();
            closeWagerMenu();
        };
    }
    
    menu.classList.remove('hidden');
    menu.style.display = 'flex';
    updateMainMenuCloseButton();
}

// Apply wager amount
function applyWager(amount) {
    // Validate amount
    if (amount < 0) {
        amount = 0;
    }
    
    fetch(`https://${GetParentResourceName()}/updateLobbyWager`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ wager: amount })
    }).then(response => {
        // Don't close menu immediately - let server update first
        // The server will send updateLobby which will refresh the UI
        setTimeout(() => {
            closeWagerMenu();
        }, 100);
    }).catch(error => {
        closeWagerMenu();
    });
}

// Close wager menu
function closeWagerMenu() {
    const menu = document.getElementById('wager-menu-container');
    if (menu) {
        menu.classList.add('hidden');
        menu.style.display = 'none';
    }
    updateMainMenuCloseButton();
}

// Update config flags to show/hide features
function updateConfigFlags(data) {
    // Hide/show ranked PvP option
    const rankedOption = document.getElementById('menu-ranked-pvp');
    if (rankedOption) {
        if (data.enableRankedPvP) {
            rankedOption.style.display = 'flex';
        } else {
            rankedOption.style.display = 'none';
        }
    }
    
    // Hide/show progression card
    const progressionCard = document.querySelector('.player-progression-card');
    if (progressionCard) {
        if (data.enableXPSystem || data.enableRankedPvP) {
            progressionCard.style.display = 'block';
        } else {
            progressionCard.style.display = 'none';
        }
    }
    
    // Hide ranked rating if ranked is disabled
    const rankedRating = document.getElementById('ranked-rating');
    if (rankedRating) {
        if (data.enableRankedPvP) {
            rankedRating.parentElement.style.display = 'flex';
        } else {
            rankedRating.parentElement.style.display = 'none';
        }
    }
}

function addKillFeed(data) {
    const feed = document.getElementById('kill-feed-list');
    if (!feed) return;
    
    const feedContainer = document.getElementById('kill-feed-container');
    if (feedContainer) {
        feedContainer.classList.remove('hidden');
        feedContainer.style.display = 'block';
    }
    
    const killEntry = document.createElement('div');
    killEntry.className = 'kill-feed-entry';
    killEntry.innerHTML = `
        <span class="kill-feed-weapon">${data.weapon || 'Paintball'}</span>
        ${data.headshot ? '<span class="kill-feed-headshot">💀</span>' : ''}
        ${data.streak && data.streak > 1 ? `<span class="kill-feed-streak">${data.streak}x KILLSTREAK!</span>` : ''}
    `;
    
    feed.insertBefore(killEntry, feed.firstChild);
    
    // Remove old entries (keep last 5)
    while (feed.children.length > 5) {
        feed.removeChild(feed.lastChild);
    }
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        if (killEntry.parentNode) {
            killEntry.style.opacity = '0';
            killEntry.style.transform = 'translateX(-100%)';
            setTimeout(() => {
                if (killEntry.parentNode) {
                    killEntry.parentNode.removeChild(killEntry);
                }
                if (feed.children.length === 0) {
                    const feedContainer = document.getElementById('kill-feed-container');
                    if (feedContainer) {
                        feedContainer.classList.add('hidden');
                        feedContainer.style.display = 'none';
                    }
                }
            }, 300);
        }
    }, 5000);
}

function hideKillFeed() {
    // Instant hide - no delays
    const feedContainer = document.getElementById('kill-feed-container');
    if (feedContainer) {
        feedContainer.classList.add('hidden');
        feedContainer.style.display = 'none';
    }
    const feed = document.getElementById('kill-feed-list');
    if (feed) {
        feed.innerHTML = '';
    }
}

function hideHitMarker() {
    // Instant hide - no delays
    const hitMarker = document.getElementById('hit-marker');
    if (hitMarker) {
        hitMarker.classList.add('hidden');
    }
}

// Practice Summary Functions
function showPracticeSummary(stats) {
    const summary = document.getElementById('practice-summary-container');
    if (!summary) return;
    
    // Update stats
    const killsEl = document.getElementById('summary-kills');
    const timeEl = document.getElementById('summary-time');
    const accuracyEl = document.getElementById('summary-accuracy');
    const streakEl = document.getElementById('summary-streak');
    const headshotsEl = document.getElementById('summary-headshots');
    const kpmEl = document.getElementById('summary-kpm');
    
    if (killsEl) killsEl.textContent = stats.kills || 0;
    if (timeEl) timeEl.textContent = stats.time || '0:00';
    if (accuracyEl) accuracyEl.textContent = (stats.accuracy || 0) + '%';
    if (streakEl) streakEl.textContent = stats.streak || 0;
    if (headshotsEl) headshotsEl.textContent = stats.headshots || 0;
    if (kpmEl) kpmEl.textContent = stats.kpm || 0;
    
    summary.classList.remove('hidden');
    summary.style.display = 'block';
    
    // Setup button handlers
    const restartBtn = document.getElementById('practice-summary-restart');
    const exitBtn = document.getElementById('practice-summary-exit');
    const closeBtn = document.getElementById('close-practice-summary');
    
    if (restartBtn) {
        restartBtn.onclick = function() {
            fetch(`https://${GetParentResourceName()}/restartPractice`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            hidePracticeSummary();
        };
    }
    
    if (exitBtn || closeBtn) {
        const hideSummary = function() {
            // Hide all practice UI elements
            hidePracticeSummary();
            hidePracticeHUD();
            closeMatch();
            closeLobby();
            
            // Close UI completely
            fetch(`https://${GetParentResourceName()}/closePracticeSummary`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        };
        
        if (exitBtn) exitBtn.onclick = hideSummary;
        if (closeBtn) closeBtn.onclick = hideSummary;
    }
}

function hidePracticeSummary() {
    const summary = document.getElementById('practice-summary-container');
    if (summary) {
        summary.classList.add('hidden');
        summary.style.display = 'none';
    }
}

// Helper functions
function getWeaponName(weapon) {
    // If weapon is already a name (no WEAPON_ prefix), return it
    if (!weapon || !weapon.startsWith('WEAPON_')) {
        return weapon || 'Unknown';
    }
    
    // Remove WEAPON_ prefix and format nicely
    let weaponName = weapon.replace('WEAPON_', '');
    
    // Convert to readable format (e.g., CARBINERIFLE -> Carbine Rifle)
    weaponName = weaponName
        .replace(/([A-Z])([A-Z]+)/g, '$1$2') // Handle consecutive capitals
        .replace(/([a-z])([A-Z])/g, '$1 $2') // Add space before capital
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1).toLowerCase())
        .join(' ');
    
    return weaponName;
}

function GetParentResourceName() {
    return 'paintball';
}

// Interaction Prompt Functions
function showInteractionPrompt() {
    // Instant show - no delays
    const prompt = document.getElementById('interaction-prompt');
    if (prompt) {
        // Remove hidden class and force visibility
        prompt.classList.remove('hidden');
        prompt.style.display = 'flex';
        prompt.style.visibility = 'visible';
        prompt.style.opacity = '1';
        prompt.style.pointerEvents = 'none'; // Keep pointer-events none (prompt is not clickable)
        prompt.style.zIndex = '1003';
    }
}

function hideInteractionPrompt() {
    // Instant hide - no delays
    const prompt = document.getElementById('interaction-prompt');
    if (prompt) {
        prompt.classList.add('hidden');
        prompt.style.display = 'none';
        prompt.style.visibility = 'hidden';
        prompt.style.opacity = '0';
        prompt.style.pointerEvents = 'none';
    }
}

function showLobbyIndicator(match) {
    // Hide normal interaction prompt
    hideInteractionPrompt();
    
    // Show lobby indicator
    const indicator = document.getElementById('active-lobby-indicator');
    if (indicator) {
        indicator.classList.remove('hidden');
        indicator.style.display = 'block';
    }
}

function hideLobbyIndicator() {
    const indicator = document.getElementById('active-lobby-indicator');
    if (indicator) {
        indicator.classList.add('hidden');
        indicator.style.display = 'none';
    }
}

// Receive and display active lobbies
function receiveActiveLobbies(lobbies) {
    const lobbiesList = document.getElementById('lobbies-list');
    if (!lobbiesList) return;
    
    // Clear existing lobbies
    lobbiesList.innerHTML = '';
    
    if (!lobbies || lobbies.length === 0) {
        lobbiesList.innerHTML = '<div class="no-lobbies-message">No active lobbies. Create a match to get started!</div>';
        return;
    }
    
    // Create lobby items
    lobbies.forEach(lobby => {
        const lobbyItem = document.createElement('div');
        lobbyItem.className = 'lobby-item';
        lobbyItem.onclick = function() {
            // Prevent multiple clicks
            if (lobbyItem.style.pointerEvents === 'none') return;
            lobbyItem.style.pointerEvents = 'none';
            setTimeout(() => { lobbyItem.style.pointerEvents = 'auto'; }, 500);
            
            // Join lobby (non-blocking)
            joinLobby(lobby.id);
        };
        
        const playerCount = lobby.totalPlayers || 0;
        const maxPlayers = lobby.maxPlayers || 24;
        const wagerText = lobby.wager > 0 ? `💰 $${lobby.wager}` : '';
        
        lobbyItem.innerHTML = `
            <div class="lobby-item-info">
                <div class="lobby-item-header">
                    <span class="lobby-item-title">${lobby.hostName}'s Lobby</span>
                    <span class="lobby-item-gamemode">${lobby.gameMode}</span>
                </div>
                <div class="lobby-item-details">
                    <div class="lobby-item-detail">🔫 ${lobby.weapon}</div>
                    <div class="lobby-item-detail">🎯 ${lobby.killCount || lobby.maxScore || 3} kills</div>
                    <div class="lobby-item-detail">⏳ ${lobby.matchTime} min</div>
                    ${wagerText ? `<div class="lobby-item-detail">${wagerText}</div>` : ''}
                </div>
            </div>
            <div class="lobby-item-players">
                ${playerCount}/${maxPlayers}
            </div>
            <div class="lobby-item-arrow">→</div>
        `;
        
        lobbiesList.appendChild(lobbyItem);
    });
}

// Join a lobby
function joinLobby(matchId) {
    fetch(`https://${GetParentResourceName()}/joinLobby`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ matchId: matchId })
    });
}

