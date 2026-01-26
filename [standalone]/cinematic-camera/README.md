# Cinematic Camera

A comprehensive cinematic camera system for FiveM servers with freecam movement, zoom functionality, and clear UI toggle for better footage and screenshots.

## Features

- **Cinematic Freecam**: Smooth freecam movement with full 360° rotation
- **Zoom Control**: Long zoom range (1.0 to 70.0 FOV) for close-up shots
- **Clear UI Toggle**: Hide all HUD elements for clean footage
- **Smooth Controls**: Configurable movement speeds and smoothing
- **Keybind Support**: Easy-to-use keybinds and commands

## Installation

1. Place the `cinematic-camera` folder in your `resources/[standalone]` directory
2. Add `ensure cinematic-camera` to your `server.cfg`
3. Restart your server or start the resource manually

## Configuration

Edit `config.lua` to customize:

- **Camera Settings**: FOV range, movement speeds, rotation sensitivity
- **Clear UI Settings**: Which HUD components to hide
- **Keybinds**: Default keys for toggling camera and UI
- **Camera Item**: Optional inventory item integration

## Usage

### Camera Menu (UI Interface)

**Open Menu:**
- Press `F6` (default) or use command `/cameramenu`
- Interactive UI with clickable buttons and controls

**Menu Features:**
- **Start/Exit Camera**: Toggle cinematic camera on/off
- **Clear UI Toggle**: Hide/show all HUD elements
- **Zoom Slider**: Adjust FOV from 1° to 70°
- **Speed Presets**: Choose Slow, Normal, or Fast movement speed
- **Quick Actions**: Reset view, save position
- **Control Guide**: Built-in reference for all controls

### Cinematic Camera

**Toggle Camera:**
- Press `F7` (default) or use command `/cinematic`
- Or use the UI menu button
- Press `ESC` (BACK) to exit (when menu is closed)

**Controls:**
- **W/S**: Move forward/backward
- **A/D**: Move left/right
- **Q/E**: Move up/down
- **Mouse**: Rotate camera
- **Scroll Wheel**: Zoom in/out
- **Left Shift**: Fast movement
- **Left Ctrl**: Slow movement

### Clear UI

**Toggle UI:**
- Press `F8` (default) or use command `/clearui`
- Or use the UI menu button
- Toggles all HUD elements on/off

## Commands

- `/cameramenu` - Open/Close Camera Menu (UI)
- `/cinematic` - Toggle cinematic camera
- `/clearui` - Toggle clear UI (hide HUD)

## Keybinds

- `F6` - Open/Close Camera Menu (UI)
- `F7` - Toggle Cinematic Camera
- `F8` - Toggle Clear UI
- `ESC` - Exit Cinematic Camera (when active and menu closed)

## Customization

### Movement Speed
Adjust in `config.lua`:
```lua
moveSpeed = 0.1,        -- Base speed
moveSpeedFast = 0.5,    -- With Shift
moveSpeedSlow = 0.05,   -- With Ctrl
```

### Zoom Range
```lua
fovMax = 70.0,  -- Wide angle
fovMin = 1.0,   -- Maximum zoom
```

### Smoothing
```lua
smoothing = true,
smoothingFactor = 0.1,  -- Lower = smoother
```

### Area Restrictions
Control where the camera can be used:
```lua
areaRestriction = {
    enabled = true,         -- Enable area restrictions
    maxDistance = 500.0,    -- Max distance from start (0 = unlimited)
    restrictedZones = {     -- Zones where camera is NOT allowed
        { coords = vector3(0.0, 0.0, 0.0), radius = 100.0 },
    },
    allowedZones = {        -- Zones where camera IS allowed (empty = everywhere)
        { coords = vector3(0.0, 0.0, 0.0), radius = 200.0 },
    },
}
```

**Note:** When area restrictions are enabled, the camera will automatically exit if:
- The player moves too far from the starting position (if `maxDistance` > 0)
- The player enters a restricted zone
- The player leaves an allowed zone (if `allowedZones` are defined)

## Tips for Better Footage

1. **Use Clear UI**: Toggle off UI before recording for clean footage
2. **Adjust Zoom**: Use scroll wheel to get the perfect framing
3. **Slow Movement**: Hold Ctrl for precise camera positioning
4. **Fast Movement**: Hold Shift to quickly reposition
5. **Combine Both**: Use cinematic camera + clear UI for best results

## Requirements

- `ox_lib` - For keybinds and notifications
- `qbx_core` - For framework integration (optional for camera item)

## Support

For issues or feature requests, please check the configuration file first as most settings can be customized there.

