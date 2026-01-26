# Sierra Valley Taxi - Advanced Taxi Job System

A comprehensive, feature-rich taxi job system for QBX/QB-Core FiveM servers with ranking progression, realistic fare meter, NPC AI jobs, and a modern UI.

## Features

### 🎯 Core Features
- **Rank System** - 7 progressive ranks with XP-based leveling
- **Vehicle Progression** - Unlock better vehicles as you rank up (7 different taxi vehicles)
- **Realistic Meter** - Live fare calculation based on distance, time, and vehicle multiplier
- **NPC Jobs** - AI passengers with dynamic pickup/dropoff locations
- **Modern UI** - Clean, responsive interface with real-time stats
- **ox_target Integration** - Easy interaction with taxi stands
- **Leaderboard** - Track top drivers on the server
- **Statistics Tracking** - Total trips, earnings, distance, best tips

### 📊 Rank System
1. **Rookie Driver** (0 XP) - Unlocks: Standard Taxi
2. **Junior Driver** (500 XP) - Unlocks: Modern Taxi
3. **Professional Driver** (1,500 XP) - Unlocks: Luxury Limousine
4. **Senior Driver** (3,500 XP) - Unlocks: Executive Sedan
5. **Elite Driver** (7,500 XP) - Unlocks: Premium Sedan
6. **Master Driver** (15,000 XP) - Unlocks: Elite Limousine
7. **Legendary Driver** (30,000 XP) - Unlocks: Super Diamond

### 🚖 Available Vehicles
- `taxi` - Standard Taxi (1.0x multiplier)
- `taxi2` - Modern Taxi (1.1x multiplier)
- `stretch` - Luxury Limousine (1.5x multiplier)
- `washington` - Executive Sedan (1.3x multiplier)
- `schafter3` - Premium Sedan (1.4x multiplier)
- `cognoscenti` - Elite Limousine (1.6x multiplier)
- `superd` - Super Diamond (2.0x multiplier)

## Installation

### 1. Database Setup
Run the SQL file to create required tables:
```sql
-- Execute: db/taxi_system.sql
```

This creates three tables:
- `taxi_drivers` - Driver profiles with stats
- `taxi_trips` - Trip history
- `taxi_leaderboard` - Leaderboard cache

### 2. Add Taxi Job to QBX Core
Edit `resources/[Sierra Valley RP]/[qbx]/qbx_core/shared/jobs.lua`:

```lua
['taxi'] = {
    label = 'Taxi',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        [0] = { name = 'Driver', payment = 50 },
        [1] = { name = 'Senior Driver', payment = 75 },
        [2] = { name = 'Dispatcher', payment = 100 },
        [3] = { name = 'Manager', payment = 150 }
    }
}
```

### 3. Install Resource
1. Place `sv_taxi` folder in `resources/[Sierra Valley RP]/[jobs]/`
2. Add to your `server.cfg`:
```cfg
ensure sv_taxi
```

### 4. Configure (Optional)
Edit `shared/config.lua` to customize:
- Taxi stand locations
- Fare rates
- XP progression
- Vehicle unlocks
- NPC spawn settings

## Configuration

### Taxi Stands
Default locations in `shared/config.lua`:
- **Downtown Cab Co.** - Main city taxi depot
- **Airport Taxi Service** - Los Santos Airport
- **Sandy Shores Taxi** - Sandy Shores
- **Paleto Bay Taxi** - Paleto Bay

### Fare Calculation
```lua
Config.Fare = {
    baseRate = 15,        -- Base fare when entering
    perMeter = 0.50,      -- Per meter traveled
    perSecond = 0.10,     -- Per second of trip
    minimumFare = 20,     -- Minimum charge
    maximumFare = 5000,   -- Maximum charge
    tipChance = 70,       -- % chance NPC tips
    tipMin = 5,           -- Min tip %
    tipMax = 25           -- Max tip %
}
```

### XP System
```lua
Config.XP = {
    perTrip = 10,         -- Base XP per trip
    perMeter = 0.05,      -- XP per meter
    bonusShortTrip = 5,   -- Bonus < 500m
    bonusMediumTrip = 15, -- Bonus 500-2000m
    bonusLongTrip = 30,   -- Bonus > 2000m
    tipBonus = 20,        -- Bonus if tipped
    perfectDelivery = 50  -- Perfect delivery bonus
}
```

## Usage

### For Players

#### Starting Work
1. Go to any taxi stand (marked with a taxi blip)
2. Use ox_target to interact with the stand
3. Select "Open Taxi Menu" to view your stats and options
4. Spawn a vehicle from the vehicles tab
5. Start accepting NPC jobs

#### NPC Jobs
1. While in a taxi, use ox_target at a stand and select "Request NPC Passenger"
2. Drive to the pickup location (marked on GPS)
3. Press `E` to pick up the passenger
4. Drive to the dropoff location
5. Press `E` to drop off and complete the trip
6. Earn money, tips, and XP!

#### Taxi Meter
- Automatically activates when you pick up a passenger
- Displays in real-time:
  - Current fare
  - Distance traveled
  - Trip duration
  - Current speed

#### Progression
- Complete trips to earn XP
- Rank up to unlock better vehicles
- Higher-tier vehicles have better fare multipliers
- Check the leaderboard to compete with other drivers

### For Admins

#### Giving Taxi Job
```lua
-- In-game command or admin panel
/job [player_id] taxi 0
```

#### Resetting Player Stats (SQL)
```sql
DELETE FROM taxi_drivers WHERE citizenid = 'ABC12345';
DELETE FROM taxi_trips WHERE citizenid = 'ABC12345';
```

#### Adjusting Player XP/Rank (SQL)
```sql
UPDATE taxi_drivers
SET xp = 5000, rank = 3
WHERE citizenid = 'ABC12345';
```

## Exports

### Client Exports
```lua
-- Open taxi UI
exports['sv_taxi']:OpenTaxiUI()

-- Start NPC job
exports['sv_taxi']:StartNPCJob()

-- Cancel current job
exports['sv_taxi']:CancelJob()
```

### Server Exports
None currently exposed. Use callbacks for data retrieval.

## Dependencies

- **qbx_core** - Main framework
- **ox_lib** - Core utilities
- **ox_target** - Interaction system
- **oxmysql** - Database queries

## Troubleshooting

### Meter Not Showing
- Ensure you picked up a passenger
- Check console for errors
- Verify NUI is not blocked

### Vehicle Not Spawning
- Check if you have the taxi job
- Verify vehicle model exists in your server
- Check if spawn point is clear
- Review server console for errors

### NPC Not Spawning
- Ensure `Config.NPC.enabled = true`
- Check spawn distance settings
- Verify you're in a taxi vehicle
- Check for script errors in F8 console

### XP/Rank Not Updating
- Verify database connection
- Check `taxi_drivers` table exists
- Review server console for SQL errors
- Ensure trip was completed successfully

## Customization

### Adding Custom Vehicles
Edit `shared/config.lua`:

```lua
Config.Vehicles['mycar'] = {
    label = 'My Custom Taxi',
    model = 'mycar',
    rank = 4,
    multiplier = 1.5
}

-- Add to rank unlocks
Config.Ranks[4].unlocks = {'taxi', 'taxi2', 'stretch', 'mycar'}
```

### Adding Taxi Stands
Edit `shared/config.lua`:

```lua
table.insert(Config.TaxiStands, {
    name = 'My Custom Stand',
    coords = vec3(x, y, z),
    heading = 0.0,
    blip = true,
    vehicleSpawn = vec4(x, y, z, heading)
})
```

### Changing UI Colors
Edit `html/css/main.css` and search for color codes:
- Primary: `#f39c12` (Orange)
- Secondary: `#e67e22` (Dark Orange)
- Background: `#1a1a2e` (Dark Blue)

## Support

For issues, feature requests, or questions:
1. Check this README thoroughly
2. Review server console for errors
3. Check F8 client console for errors
4. Verify all dependencies are running

## Credits

- **Framework:** QBX/QB-Core
- **UI Libraries:** Font Awesome, jQuery
- **Database:** oxmysql

---

**Version:** 1.0.0
**Author:** Sierra Valley RP
**License:** Custom (Server Use Only)
