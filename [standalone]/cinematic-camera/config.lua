Config = {}

-- Camera Settings
Config.Camera = {
    -- FOV Settings
    fovMax = 70.0,          -- Maximum FOV (wide angle)
    fovMin = 1.0,           -- Minimum FOV (maximum zoom)
    fovDefault = 50.0,      -- Default FOV
    zoomSpeed = 5.0,        -- Zoom speed (scroll wheel sensitivity)
    
    -- Movement Settings
    moveSpeed = 0.1,        -- Base movement speed
    moveSpeedFast = 0.5,    -- Fast movement speed (when holding shift)
    moveSpeedSlow = 0.05,   -- Slow movement speed (when holding ctrl)
    rotationSpeed = 2.0,   -- Mouse rotation sensitivity
    
    -- Camera Smoothing
    smoothing = true,       -- Enable smooth camera movement
    smoothingFactor = 0.1,  -- Smoothing factor (0.0 - 1.0, lower = smoother)
    
    -- Controls
    toggleKey = '',         -- Key to toggle cinematic camera (disabled - use /cameramenu command)
    exitKey = 'BACK',       -- Key to exit cinematic camera (ESC)
    
    -- Timecycle Modifier (optional visual effect)
    useTimecycle = true,    -- Enable timecycle modifier
    timecycleModifier = 'default', -- Timecycle modifier name
    timecycleStrength = 0.3, -- Timecycle strength (0.0 - 1.0)
    
    -- Area Restrictions
    areaRestriction = {
        enabled = true,    -- Enable area restriction (exit camera when leaving area)
        maxDistance = 100, -- Maximum distance from start position (in meters, 0 = unlimited)
        restrictedZones = {  -- List of zones where camera is NOT allowed (leave empty to allow everywhere)
            -- Example zones (uncomment and modify as needed):
            -- { coords = vector3(0.0, 0.0, 0.0), radius = 100.0 }, -- No camera within 100m of this point
        },
        allowedZones = {     -- List of zones where camera IS allowed (leave empty to allow everywhere)
            -- Example zones (uncomment and modify as needed):
            -- { coords = vector3(0.0, 0.0, 0.0), radius = 200.0 }, -- Camera only allowed within 200m of this point
        },
    },
}

-- UI Menu Settings
Config.UIMenu = {
    enabled = true,         -- Enable UI menu
    toggleKey = '',       -- Key to open/close UI menu
    command = 'cameramenu', -- Command to open/close UI menu
}

-- Clear UI Settings
Config.ClearUI = {
    enabled = true,         -- Enable clear UI feature
    toggleKey = '',      -- Key to toggle clear UI
    command = 'clearui',   -- Command to toggle clear UI
    
    -- What to hide when clear UI is active
    hideComponents = {
        1,  -- Wanted Stars
        2,  -- Weapon Icon
        3,  -- Cash
        4,  -- MP Cash
        5,  -- MP Message
        6,  -- Vehicle Name
        7,  -- Area Name
        8,  -- Vehicle Class
        9,  -- Street Name
        10, -- Help Text
        11, -- Floating Help Text
        12, -- Floating Help Text 2
        13, -- Cash Change
        14, -- Reticle
        15, -- Subtitle Text
        16, -- Radio Stations
        17, -- Saving Game
        18, -- Game Stream
        19, -- Weapon Wheel
        20, -- Weapon Wheel Stats
        21, -- HUD Components
        22, -- HUD Weapons
    },
    
    -- Hide custom HUD systems (if available)
    hideCustomHUD = true,  -- Try to hide custom HUD systems like qbx_hud, jg-hud, ulc, etc.
}

-- Camera Item (optional - if you want to use a camera item from inventory)
Config.CameraItem = {
    enabled = false,        -- Enable camera item usage
    itemName = 'camera',    -- Item name in inventory
}

