# Elevator Builder Guide

The Elevator Builder allows admins to create and manage elevators in-game without editing config files.

## Features

- **In-game elevator creation** - Build elevators directly in the city
- **Real-time coordinate capture** - Stand at a location and capture coordinates
- **Visual editor** - Manage all elevators and floors through a clean UI
- **Live reload** - Changes take effect immediately without server restart
- **Persistent storage** - Custom elevators saved to `elevator_data.json`

## Getting Started

### Opening the Builder

Admins can open the builder using either command:
- `/elevatorbuilder`
- `/elevatorcreate`

**Requirements:** Admin or God ACE permissions

### Helper Commands

- `/getcoords` - Print your current coordinates to console (F8)
- `/markspot [seconds]` - Place a visual marker at your location (default: 30 seconds)

## Creating an Elevator

### Step 1: Open the Builder
Use `/elevatorbuilder` to open the builder interface.

### Step 2: Name Your Elevator
In the "Create New" tab, enter a descriptive name for your elevator system:
- Example: "LSPD Main Elevator"
- Example: "Pillbox Hospital Elevator"

### Step 3: Add Floors

You have two options:

#### Option A: Add Floor at Current Position (Recommended)
1. Stand at the exact location where you want the elevator entrance
2. Face the direction players should face when they teleport here
3. Click "Add Floor at Current Position"
4. The floor will be created with your current coordinates and heading

#### Option B: Add Floor Manually
1. Click "+ Add Floor"
2. Click "Edit" on the floor
3. Enter coordinates and heading manually

### Step 4: Edit Floor Details
For each floor, click "Edit" to customize:
- **Floor Name** - Display name (e.g., "Ground Floor", "Rooftop")
- **Coordinates** - X, Y, Z position
- **Heading** - Direction player faces (0-360)

### Step 5: Save
Click "💾 Save Elevator" to save your elevator. It will be immediately active on all clients.

## Managing Existing Elevators

### Viewing Elevators
1. Switch to the "Manage Existing" tab
2. Click "🔄 Refresh List" to see all custom elevators

### Editing an Elevator
1. Find the elevator in the list
2. Click "Edit" on the elevator card
3. Make your changes in the Create tab
4. Click "💾 Save Elevator" to update

### Deleting an Elevator
1. Find the elevator in the list
2. Click "Delete" on the elevator card
3. Confirm the deletion

### Viewing Floor Details
Click "View Floors" on any elevator card to see all floors and their coordinates.

## Best Practices

### Capturing Coordinates
1. **Stand exactly where you want the player to spawn**
2. **Face the direction** you want them to face
3. Use `/markspot 60` to mark the location visually
4. Walk around to verify it looks good from all angles
5. Return to the marked spot and capture coordinates

### Naming Convention
- Use descriptive names that include the building/location
- Example: "LSPD Main Elevator" (not just "Elevator 1")
- Example: "Hospital Surgery Wing" (not just "Hospital")

### Floor Ordering
- Add floors in a logical order (ground floor first)
- Use clear floor names:
  - ✅ "Lobby", "Second Floor - Offices", "Rooftop Helipad"
  - ❌ "Floor1", "Floor2", "Floor3"

### Testing
After creating an elevator:
1. Go to each floor location in-game
2. Verify the elevator appears correctly
3. Test traveling between all floors
4. Check that coordinates are accurate

## Technical Details

### Data Storage
Custom elevators are saved to `elevator_data.json` in the resource folder. This file is automatically created and managed by the system.

### How It Works
1. Custom elevators are loaded on resource start
2. They are merged with elevators defined in `config.lua`
3. When you save changes, all clients reload their elevator lists
4. The system uses the same mechanics as config-based elevators

### Permissions
The builder uses ACE permissions:
```lua
IsPlayerAceAllowed(source, 'admin')
IsPlayerAceAllowed(source, 'god')
```

To grant access, add to your `server.cfg`:
```
add_ace group.admin command.elevatorbuilder allow
```

## Troubleshooting

### Builder won't open
- Verify you have admin/god ACE permissions
- Check server console for errors
- Try restarting the resource: `restart custom_elevator`

### Coordinates are wrong
- Use `/getcoords` to verify your position
- Make sure you're standing exactly where you want the player to spawn
- Remember Z coordinate should be at ground level (not player head height)

### Elevator doesn't appear
- Check that you have at least 2 floors
- Verify coordinates are correct (not 0, 0, 0)
- Restart the resource if needed
- Check for errors in server console (F8)

### Changes not saving
- Check server console for save errors
- Verify the resource has write permissions
- Make sure `elevator_data.json` is not read-only

## Examples

### Basic Office Building
```
Name: "Legion Square Office"
Floors:
1. "Ground Floor Lobby" - Entrance
2. "First Floor - Offices"
3. "Second Floor - Conference"
4. "Rooftop Access"
```

### Police Department with Job Locks
(Job locks need to be added manually in config.lua for now)
```
Name: "LSPD Main Elevator"
Floors:
1. "Lobby" - Public access
2. "Second Floor - Offices" - Police only
3. "Rooftop Helipad" - Police on duty only
```

## Workflow Example

1. **Plan your elevator**
   - Decide which building needs an elevator
   - Identify all floor locations

2. **Mark ground floor**
   - Go to ground floor entrance
   - Stand in position, face correct direction
   - Use `/markspot 300` (5 minutes)

3. **Mark other floors**
   - Go to each floor
   - Mark each position with `/markspot`

4. **Build in the tool**
   - Open `/elevatorbuilder`
   - Name the elevator
   - Visit each marked spot
   - Click "Add Floor at Current Position"
   - Edit floor names

5. **Save and test**
   - Save the elevator
   - Test all floor transitions
   - Adjust if needed

## Advanced Features (Coming Soon)

- Job lock configuration in the UI
- Blip configuration per floor
- Custom marker settings
- Elevator shaft cloning/duplication
- Import/export elevator configurations
