Config = {}

-- Framework Settings
Config.Framework = 'qb-core' -- Options: 'qb-core', 'esx', 'standalone'
Config.UseTarget = false -- Set to true if using qb-target or ox_target
Config.TargetScript = 'qb-target' -- Options: 'qb-target', 'ox_target'

-- Interaction Settings
Config.InteractionDistance = 0.0 -- Distance to show interaction text
Config.UseThirdEye = true -- If using third eye targeting
Config.InteractionKey = 38 -- Default: E key

-- Visual Settings
Config.ShowBlips = true -- Show blips on map for elevators
Config.BlipSprite = 524 -- Blip icon
Config.BlipColor = 3 -- Blip color
Config.BlipScale = 0.8 -- Blip size

Config.DrawMarkers = true -- Show 3D markers at elevator locations
Config.MarkerType = 1 -- Marker type (1 = cylinder)
Config.MarkerColor = {r = 0, g = 255, b = 0, a = 100} -- Marker color with transparency
Config.MarkerSize = {x = 1.0, y = 1.0, z = 0.5} -- Marker dimensions

-- Teleport Settings
Config.FadeScreen = true -- Fade screen during teleportation
Config.FadeTime = 1000 -- Fade duration in milliseconds
Config.TeleportDelay = 2000 -- Delay before teleporting (simulates elevator movement)

-- ==========================================
-- ADVANCED ELEVATOR SYSTEM SETTINGS
-- ==========================================

-- Elevator Call System
Config.CallSystem = {
    enabled = true,                 -- Enable call system (if false, uses old teleport system)
    showArrivalTime = true,         -- Display ETA in notification
    queueMultipleCalls = true,      -- Allow multiple calls to be queued
    autoCloseDoors = true,          -- Automatically close doors after timeout
    doorOpenTime = 5000,            -- Time (ms) doors stay open before auto-closing
    doorAnimationTime = 2000,       -- Time (ms) for door open/close animation
}

-- Movement Settings
Config.Movement = {
    speedPerFloor = 3000,           -- Time (ms) to travel one floor (3 seconds default)
    acceleration = 1000,            -- Time (ms) to reach full speed
    deceleration = 1000,            -- Time (ms) to decelerate and stop
}

-- Interaction System
Config.Interaction = {
    mode = "both",                  -- Options: "target" (ox_target only), "text" (3D text only), "both"
    targetDistance = 2.0,           -- Distance for ox_target interaction
    textDistance = 2.5,             -- Distance to show 3D text
    callButtonOffset = vector3(0.5, 0, 0),  -- Offset for call button from floor coords
    panelOffset = vector3(-0.5, 0, 0),      -- Offset for floor panel from floor coords
}

-- Visual Effects
Config.Effects = {
    screenShake = true,             -- Enable screen shake during movement
    shakeIntensity = 0.3,           -- Screen shake intensity (0.0 - 1.0)
    doorFadeEffect = true,          -- Fade effect when doors open/close
    showDirectionArrows = true,     -- Show up/down arrows during movement
    arrowPosition = {x = 0.5, y = 0.85},  -- Screen position for arrows (0.0 - 1.0)
}

-- Sound Settings
Config.Sounds = {
    enabled = true,                 -- Enable sound effects
    volume = 0.5,                   -- Master volume (0.0 - 1.0)
    ding = "elevator_ding.ogg",     -- Arrival ding sound
    doorOpen = "door_open.ogg",     -- Door opening sound
    doorClose = "door_close.ogg",   -- Door closing sound
    movement = "elevator_move.ogg", -- Movement/motor sound
    use3D = true,                   -- Use 3D positional audio
    maxDistance = 20.0,             -- Max distance to hear elevator sounds (meters)
}

--[[
    ELEVATOR SHAFTS CONFIGURATION
    
    Each shaft represents a separate elevator system with its own floors.
    Players can only travel between floors within the same shaft.
    
    Structure:
    - name: Display name for the elevator shaft
    - floors: Table of all floors in this shaft
        - id: Unique identifier for the floor
        - name: Display name shown in the menu
        - coords: Location where player will be teleported (vector3)
        - heading: Direction player will face after teleport
        - jobLock: (Optional) Restrict access to specific jobs
            - jobs: Table of job names that can access this floor
            - requireOnDuty: (Optional) If true, player must be on duty
        - markerCoords: (Optional) Custom marker position, defaults to coords if not specified
        - blip: (Optional) Show blip for this floor entrance
]]

Config.ElevatorShafts = {
    
    -- Example 1: Police Department - Main Elevator
    {
        name = "LSPD Main Elevator",
        floors = {
            {
                id = "pd_lobby",
                name = "Lobby",
                coords = vector3(440.84, -981.97, 30.69),
                heading = 180.0,
                blip = true
            },
            {
                id = "pd_floor2",
                name = "Second Floor - Offices",
                coords = vector3(440.84, -981.97, 35.69),
                heading = 180.0,
                jobLock = {
                    jobs = {"police", "sheriff", "lscso", "safr"},
                    requireOnDuty = false
                }
            },
            {
                id = "pd_roof",
                name = "Rooftop Helipad",
                coords = vector3(440.84, -981.97, 43.69),
                heading = 180.0,
                jobLock = {
                    jobs = {"police", "sheriff", "lscso", "safr"},
                    requireOnDuty = true
                }
            }
        }
    },

    -- Example 2: Police Department - Basement Elevator (Separate Shaft)
    {
        name = "LSPD Basement Access",
        floors = {
            {
                id = "pd_lobby_basement",
                name = "Lobby",
                coords = vector3(435.84, -981.97, 30.69),
                heading = 90.0,
                blip = true
            },
            {
                id = "pd_basement",
                name = "Basement - Evidence",
                coords = vector3(435.84, -981.97, 25.69),
                heading = 90.0,
                jobLock = {
                    jobs = {"police", "sheriff", "lscso", "safr"},
                    requireOnDuty = false
                }
            },
            {
                id = "pd_garage",
                name = "Underground Garage",
                coords = vector3(435.84, -990.97, 25.69),
                heading = 90.0,
                jobLock = {
                    jobs = {"police", "sheriff", "lscso", "safr"},
                    requireOnDuty = false
                }
            }
        }
    },

    -- Example 3: Hospital Elevator
    {
        name = "Pillbox Hill Medical Elevator",
        floors = {
            {
                id = "hospital_ground",
                name = "Ground Floor - Reception",
                coords = vector3(332.46, -595.59, 43.28),
                heading = 340.0,
                blip = true
            },
            {
                id = "hospital_surgery",
                name = "Surgery & ICU",
                coords = vector3(339.03, -584.13, 74.16),
                heading = 340.0,
                jobLock = {
                    jobs = {"ambulance", "doctor", "police", "lscso"},
                    requireOnDuty = false
                }
            },
            {
                id = "hospital_roof",
                name = "Rooftop - Helipad",
                coords = vector3(339.03, -583.93, 83.5),
                heading = 340.0,
                jobLock = {
                    jobs = {"ambulance", "doctor", "police", "lscso"},
                    requireOnDuty = false
                }
            }
        }
    },

    -- Example 4: Office Building (No Job Lock)
    {
        name = "Legion Square Office",
        floors = {
            {
                id = "office_ground",
                name = "Ground Floor",
                coords = vector3(120.0, -750.0, 45.75),
                heading = 0.0,
                blip = true
            },
            {
                id = "office_floor1",
                name = "1st Floor - Offices",
                coords = vector3(120.0, -750.0, 50.75),
                heading = 0.0
            },
            {
                id = "office_floor2",
                name = "2nd Floor - Conference",
                coords = vector3(120.0, -750.0, 55.75),
                heading = 0.0
            },
            {
                id = "office_floor3",
                name = "3rd Floor - Executive",
                coords = vector3(120.0, -750.0, 60.75),
                heading = 0.0
            },
            {
                id = "office_roof",
                name = "Rooftop Access",
                coords = vector3(120.0, -750.0, 65.75),
                heading = 0.0
            }
        }
    },

    -- Example 5: Luxury Apartment Complex
    {
        name = "Eclipse Towers Elevator",
        floors = {
            {
                id = "eclipse_ground",
                name = "Lobby",
                coords = vector3(-773.55, 312.18, 85.70),
                heading = 180.0,
                blip = true
            },
            {
                id = "eclipse_penthouse",
                name = "Penthouse",
                coords = vector3(-774.29, 342.23, 196.69),
                heading = 180.0
            }
        }
    }
}

-- Notification function (customize based on your framework)
Config.Notify = function(message, type)
    -- QBCore
    if Config.Framework == 'qb-core' then
        QBCore.Functions.Notify(message, type)
    
    -- ESX
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    
    -- Standalone fallback
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        DrawNotification(false, false)
    end
end
