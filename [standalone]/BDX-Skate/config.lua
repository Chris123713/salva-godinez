--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
--------------------------------------
-- <!>--     SKATE | CAREER     --<!>--
--------------------------------------
-- Support & Feedback: https://discord.gg/PjN7AWqkpF
-- How to:
-- Use E to Pickup the Skateboard or put it in your back
-- Use G to Ride the Skateboard or put it in your Hand
-- For Tricks, set the Keys in Settings / Key Binding / FiveM
-- You need a the Trigger Event for custom inventory?
-- Use this one:
-- TriggerClientEvent('bodhix-skating:client:start', source, item)

Config = {}

-- Debug
Config.Debug = false -- true / false

-- Framework
Config.Framework = "qb" -- "qb" | "esx" | "vrp" | "custom"
Config.FrameworkResourceName = "qbx_core"

-- Settings
Config.ItemName = "skateboard"
Config.Target = "ox" -- "qb" | "ox" | "none"
Config.TextFont = 4

Config.MaxSpeedKmh = 40
Config.maxJumpHeigh = 5.0
Config.maxFallSurvival = 45.0
Config.LoseConnectionDistance = 2.0
Config.MinimumSkateSpeed = 2.0
Config.MinGroundHeight = 1.0

-- Controls
Config.PickupKey = 38 -- E
Config.ConnectPlayer = 113 -- G

-- Position offsets
Config.ModernBack = -0.25
Config.ClassicBack = -0.32

-- Language
Config.Language = {
    Info = {
        ['controls'] = 'Press E to Pickup | Press G to Ride',
    },
}
