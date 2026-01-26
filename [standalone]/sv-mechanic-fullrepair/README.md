# sv-mechanic-fullrepair

Full vehicle repair utility for Sierra Valley RP that resets both GTA vehicle health AND jg-mechanic internal components (servicingData).

## Problem Solved

When players use NPC mechanics or repair kits, only the base GTA vehicle health was being reset. The jg-mechanic internal components (engine oil, tyres, brakes, clutch, spark plugs, suspension, etc.) were NOT being reset, causing vehicles to still perform poorly even after "repairs".

This resource ensures ALL repairs also reset the internal servicing components.

## Features

- **Admin Commands**: `/fullrepair` to fully repair current vehicle including all internal components
- **Bulk Reset**: `/resetallservicing` to reset ALL vehicles in the database (use with caution)
- **Exports**: Other resources can call our exports to perform full repairs
- **Auto-Integration**: Works with vehiclehandler and jg-mechanic automatically

## Installation

1. Resource is already in `[standalone]` folder - it will start automatically
2. No additional configuration needed
3. Restart server or run `ensure sv-mechanic-fullrepair`

## Admin Commands

| Command | Permission | Description |
|---------|------------|-------------|
| `/fullrepair [player_id]` | `command.fullrepair` (admin) | Full repair vehicle including servicing data |
| `/resetallservicing` | `group.admin` | Reset servicing data for ALL vehicles in database |

## Exports (for other resources)

### Client-Side

```lua
-- Full repair a vehicle (GTA health + servicing data)
exports['sv-mechanic-fullrepair']:FullRepairVehicle(vehicle, skipServerSync)

-- Repair just GTA health (no servicing reset)
exports['sv-mechanic-fullrepair']:RepairGTAVehicle(vehicle)

-- Reset just servicing data
exports['sv-mechanic-fullrepair']:ResetServicingData(vehicle, skipServerSync)

-- Get full health servicing data structure
exports['sv-mechanic-fullrepair']:GetFullServicingData(vehicle)

-- Check if vehicle is electric
exports['sv-mechanic-fullrepair']:IsVehicleElectric(vehicle)
```

### Server-Side

```lua
-- Full repair by network ID
exports['sv-mechanic-fullrepair']:FullRepairVehicle(netId, isElectric)

-- Reset servicing data by plate (for offline vehicles)
exports['sv-mechanic-fullrepair']:FullRepairByPlate(plate)

-- Get full servicing data structure
exports['sv-mechanic-fullrepair']:GetFullServicingData(isElectric)
```

## How It Works

1. **jg-mechanic Integration**: Modified `Framework.Client.RepairVehicle()` in jg-mechanic to automatically call our export when any repair is performed (including self-service NPC mechanics)

2. **vehiclehandler Integration**: Modified `fixVehicle()` and `adminfix()` in vehiclehandler to reset servicing data after repairs

3. **Database Sync**: When servicing data is reset, it's also cleared from the `mechanic_vehicledata` database table so the fix persists

## Servicing Components Reset

**Combustion Vehicles:**
- Engine Oil
- Clutch
- Air Filter
- Spark Plugs
- Suspension
- Tyres
- Brake Pads

**Electric Vehicles:**
- EV Motor
- EV Battery
- EV Coolant
- Suspension
- Tyres
- Brake Pads

## Dependencies

- oxmysql
- ox_lib
- jg-mechanic (optional but recommended)

## Files Modified

- `jg-mechanic/framework/cl-functions.lua` - Added servicing reset to RepairVehicle function
- `vehiclehandler/modules/handler.lua` - Added servicing reset after repairs

## Troubleshooting

**Repairs not resetting servicing?**
1. Ensure `sv-mechanic-fullrepair` is started
2. Check server console for any errors
3. Run `/fullrepair` manually to test

**Can't use admin commands?**
1. Ensure you're in `group.admin` or have `command` permission
2. Check `permissions.cfg`
