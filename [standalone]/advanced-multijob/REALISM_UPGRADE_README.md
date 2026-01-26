# Advanced MultiJob - Realism Upgrade

## Overview
This upgrade transforms the Advanced MultiJob system into a realistic, professional employment management system with physical clock-in requirements, job-specific theming, and comprehensive time tracking.

## What's New

### 🎨 Professional UI Redesign
- **Rebranded Labels**: "Clock In/Out" instead of "On/Off Duty"
- **Professional Terminology**: "Employment Records", "Active Position", "Resign"
- **FontAwesome Icons**: Replaced emojis with professional icons
- **Job-Specific Theming**: Each job gets its own color scheme and branding
  - Police: Blue theme
  - Medical: Red theme
  - Sheriff: Brown theme
  - Mechanic: Gray theme
  - And more...

### 📍 Physical Clock-In Locations
- Players must visit their job site to clock in/out
- Configurable ox_target zones at each location
- Real-time distance display when away from location
- Multiple locations per job (e.g., MRPD, Sandy PD, Paleto PD for police)

### ⏱️ Time Tracking System
- **Shift Duration**: Live counter showing how long you've been on duty
- **Clock-In Time**: Display of when you started your shift
- **Work History**: Database logging of all shifts
- **30-Day Rolling Hours**: Track total hours worked per job

### 🔒 Location-Based Access Control
- Clock In button disabled when away from job site
- Shows distance to nearest clock-in location
- Visual indicators (green = at location, red = away)
- Can still view menu remotely, just can't toggle duty

### 💾 Database Integration
- New `job_clockin_logs` table for permanent records
- Automatic shift duration calculation
- Admin command `/viewhours [id]` to check player work hours
- Database views for easy querying

## Installation

### 1. Database Setup
Run the SQL file to create the required tables:
```bash
Execute: db/advanced_multijob_tracking.sql
```

### 2. Configuration
Edit `config.lua` to customize:

```lua
-- Enable/disable physical clock-in requirement
Config.RequirePhysicalClockin = true

-- Maximum distance to clock in (meters)
Config.MaxClockinDistance = 10.0

-- Enable time tracking features
Config.EnableTimeTracking = true
```

### 3. Add Clock-In Locations
Configure job-specific locations in `config.lua`:

```lua
Config.ClockinLocations = {
    ['police'] = {
        {name = 'Mission Row PD', coords = vector3(441.7989, -982.0529, 30.6896)},
        {name = 'Sandy Shores PD', coords = vector3(1853.24, 3686.61, 34.27)},
    },
    -- Add more jobs...
}
```

### 4. Customize Job Themes
Adjust colors and branding in `config.lua`:

```lua
Config.JobThemes = {
    ['police'] = {
        color = '#1e40af',
        icon = 'fa-shield-alt',
        name = 'Los Santos Police Department',
        gradient = 'linear-gradient(...)'
    },
    -- Add more jobs...
}
```

### 5. Restart Resource
```bash
restart advanced-multijob
```

## Features in Detail

### Clock-In Locations
- **ox_target Integration**: Interact with zones to open job menu
- **Proximity Detection**: Continuous checking of player location
- **Multi-Location Support**: Jobs can have multiple valid clock-in points
- **Field Work Jobs**: Jobs without configured locations can clock in anywhere

### Time Tracking
- **Automatic Logging**: Every clock-in/out is recorded
- **Duration Calculation**: Automatic shift duration tracking
- **Persistent Data**: Survives server restarts
- **Historical Records**: 30-day rolling window for statistics

### Professional UI
- **Dynamic Theming**: UI colors change based on active job
- **Clear Labels**: Professional terminology throughout
- **Status Indicators**: Visual feedback for location and duty status
- **Real-Time Updates**: Shift timer updates every second

### Admin Tools
```lua
/viewhours [player_id]  -- View player's work hours (30 days)
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `RequirePhysicalClockin` | `true` | Require players to be at job site |
| `ShowDistanceWhenTooFar` | `true` | Show distance to clock-in point |
| `MaxClockinDistance` | `10.0` | Maximum meters from zone to clock in |
| `EnableTimeTracking` | `true` | Log shifts to database |
| `ShowShiftDuration` | `true` | Display shift timer in menu |
| `Debug` | `false` | Enable debug prints |

## Job Theme Template

Add new jobs to `Config.JobThemes`:

```lua
['jobname'] = {
    color = '#hexcolor',           -- Main theme color
    icon = 'fa-icon-name',          -- FontAwesome icon
    name = 'Department Name',       -- Display name
    gradient = 'linear-gradient(...)' -- CSS gradient
}
```

## Database Schema

### `job_clockin_logs` Table
- `id` - Auto-increment primary key
- `citizenid` - Player identifier
- `job` - Job name
- `clockin_time` - When shift started
- `clockout_time` - When shift ended (NULL if active)
- `duration` - Shift length in seconds
- `location` - Clock-in location name

### Useful Queries

**View all active shifts:**
```sql
SELECT * FROM view_active_shifts;
```

**Get player's total hours (30 days):**
```sql
SELECT SUM(duration)/3600 as hours
FROM job_clockin_logs
WHERE citizenid = 'ABC123'
AND clockin_time >= DATE_SUB(NOW(), INTERVAL 30 DAY);
```

## Compatibility

- **Framework**: QBox/QB-Core
- **Dependencies**:
  - ox_lib (callbacks, commands)
  - ox_target (clock-in zones)
  - oxmysql (database)
  - qbx_core (player data)

## Troubleshooting

### Clock-in zones not appearing
1. Ensure ox_target is started before this resource
2. Check `Config.Debug = true` to see console output
3. Verify coordinates in `Config.ClockinLocations`

### Theme not applying
1. Make sure job name in `Config.JobThemes` matches exactly
2. Clear browser cache (F5 in NUI)
3. Check browser console (F8) for JavaScript errors

### Time tracking not working
1. Verify database table exists: `SHOW TABLES LIKE 'job_clockin_logs'`
2. Check `Config.EnableTimeTracking = true`
3. Review server console for MySQL errors

### Players can't clock in
1. Check if they're within `Config.MaxClockinDistance` meters
2. Verify job name exists in `Config.ClockinLocations`
3. Ensure they're not unemployed (unemployed can't clock in)

## Default Clock-In Locations

The following locations are pre-configured:

**Police:**
- Mission Row PD: `441.80, -982.05, 30.69`
- Sandy Shores PD: `1853.24, 3686.61, 34.27`
- Paleto Bay PD: `-448.56, 6008.33, 31.72`

**Medical:**
- Pillbox Medical: `304.45, -600.35, 43.28`
- Sandy Shores Medical: `1839.69, 3672.93, 34.28`

**Mechanic:**
- Hayes Auto Body: `-1418.55, -446.58, 35.91`
- Harmony Repairs: `1175.03, 2640.08, 37.75`

*Adjust coordinates for your server's MLOs as needed.*

## Credits

- Original Advanced MultiJob System
- Enhanced with Realism Features
- Powered by QBox Framework

## Support

For issues or questions:
1. Check this README
2. Review Config.lua comments
3. Enable debug mode for diagnostic information
4. Check server console for errors

---

**Version:** 2.0.0 (Realism Upgrade)
**Date:** January 2026
**Compatible With:** QBox Framework
