# Paintball System

Advanced paintball script for FiveM with lobby system, team-based matches, and scoring.

## Features

- **Lobby System**: Create and join paintball lobbies
- **Team Selection**: Join Red or Blue team
- **Match Management**: First team to 30 kills wins
- **Nukedown Map**: Spawns players in the nukedown arena
- **Weapon Selection**: Choose from various weapons
- **Scoreboard**: Real-time match statistics
- **Leaderboard**: Track player statistics across matches
- **Kill/Death Tracking**: Full K/D ratio tracking

## Installation

1. Place the `paintball` folder in your `resources` directory
2. Add `ensure paintball` to your `server.cfg`
3. Configure the arena coordinates in `config.lua`

## Configuration

### Arena Location
The entrance/interaction point is set to:
- Coordinates: `-282.7254, -1936.5331, 30.2012`

### Nukedown Map Spawn Points
You need to configure the spawn points for both teams in `config.lua`:

```lua
Config.NukedownArena = {
    redSpawns = {
        vector4(x, y, z, heading), -- Add your red team spawns
    },
    blueSpawns = {
        vector4(x, y, z, heading), -- Add your blue team spawns
    }
}
```

### Match Settings
- `maxScore`: First team to reach this score wins (default: 30)
- `maxMatchTime`: Maximum match duration in minutes (default: 30)
- `minPlayers`: Minimum players required to start (default: 2)
- `maxPlayersPerTeam`: Maximum players per team (default: 12)
- `respawnTime`: Respawn delay in seconds (default: 5)

## Usage

1. Go to the paintball arena entrance at the configured coordinates
2. Press `E` to interact and open the lobby menu
3. Create a new lobby or join an existing one
4. Select your team (Red or Blue)
5. Host can start the match when both teams have at least one player
6. Players will be teleported to the nukedown arena
7. First team to reach 30 kills wins!

## Commands

- Press `TAB` during a match to toggle the scoreboard
- Press `E` at the arena entrance to open the lobby

## Requirements

- `qbx_core` (QBX Framework)
- `ox_lib`
- `ox_target` (optional, for target system)

## Notes

- Players' weapons and location are saved when entering a match
- Players are restored to their previous state after the match ends
- Match rewards can be enabled in the config (disabled by default)

