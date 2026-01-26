# Advanced Elevator Builder

## Features

✨ **Modern UI** - Sleek dark theme with real-time updates
🚶 **Free Movement** - Walk around while UI is open (no cursor lock!)
📍 **Visual Markers** - See green markers where floors are placed
⌨️ **Keyboard Shortcuts** - Quick actions without clicking
🎯 **Click to Teleport** - Click any floor in the list to teleport there
📊 **Live Stats** - See floor count and elevator info in real-time
💾 **Easy Management** - View, edit, and delete elevators

## How to Use

### Step 1: Activate Builder
Type `/eb` or `/elevatorbuilder` in chat

A modern UI appears on the right side of your screen.
**You can still move around freely!**

### Step 2: Start New Elevator
Click "Start New Elevator" button or press `E`
Enter a name for your elevator (e.g., "LSPD Main Elevator")

### Step 3: Add Floors
1. Walk/run to the first floor location
2. Press `E` or click "Add Floor Here"
3. Enter a floor name (e.g., "Ground Floor")
4. A green marker appears showing the location
5. Repeat for each floor

### Step 4: Save Elevator
Once you have 2+ floors:
- Click "Save Elevator" button
- Confirm the save
- Choose whether to save to config.lua

## Controls

| Key/Action | Function |
|------------|----------|
| `/eb` | Toggle builder on/off |
| `F5` | Toggle UI visibility |
| `E` | Add floor at current position |
| `Z` | Remove last floor (undo) |
| Click floor | Teleport to that floor |
| ✏️ icon | Edit floor name |
| 🗑️ icon | Remove specific floor |

## UI Features

### Side Panel (Right)
- **Current Elevator Info** - Name, floor count, last added floor
- **Floors List** - All floors with coordinates
  - Click to teleport
  - Icons to edit/remove
- **Quick Actions**
  - Get Coordinates (logs to F8 console)
  - Manage Elevators (view/delete existing)
  - Help

### Minimap Controls (Bottom Right)
Shows all keyboard shortcuts at a glance

### Notifications (Bottom Left)
Real-time feedback for all actions

## Advanced Features

### Manage Elevators
1. Click "⚙️ Manage Elevators"
2. See all existing elevators
3. Click "Delete" to remove any elevator
4. Refresh list anytime

### Teleport Between Floors
- Click any floor in the list
- Instantly teleport there
- Perfect for checking positions

### Get Coordinates
- Click "📐 Get Coordinates"
- Current coords logged to console (F8)
- Useful for manual config editing

## Tips

💡 **No Cursor Needed** - Use keyboard shortcuts for everything
💡 **UI Stays Open** - Keep it open while building, toggle with F5
💡 **Visual Feedback** - Green markers show exactly where floors are
💡 **Undo Mistakes** - Press Z to remove the last floor added
💡 **Click to Teleport** - Quickly check floor positions
💡 **Save Often** - Each elevator is saved separately

## Example Workflow

```
1. /eb                              → Open builder
2. Walk to ground floor entrance
3. E                                → Start "Police HQ"
4. E                                → Add "Lobby"
5. Run upstairs
6. E                                → Add "Offices"
7. Click "Lobby" in list           → Teleport back down
8. Run to basement
9. E                                → Add "Parking"
10. Click "Save Elevator"          → Save with 3 floors
11. F5                             → Hide UI (still active)
12. /eb                            → Close builder
```

## Troubleshooting

**UI doesn't appear**
- Check you have admin/god permissions
- Try `/eb` again

**Can't move**
- You should be able to move freely
- If stuck, press F5 to hide UI, then /eb to restart

**Markers not showing**
- Make sure builder is active (/eb)
- Markers appear after adding floors

**Save fails**
- Need at least 2 floors
- Check server console for errors

## Keyboard Reference

```
F5    → Toggle UI visibility
E     → Add floor at position
Z     → Remove last floor
ESC   → Close modal dialogs
```

All controls work even when UI is hidden!
