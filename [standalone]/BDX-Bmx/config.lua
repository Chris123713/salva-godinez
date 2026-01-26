--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
--------------------------------------
-- <!>--      BMX | CAREER     --<!>--
--------------------------------------
-- Support & Feedback: https://discord.gg/PjN7AWqkpF

Config = {}

Config.Debug = true -- Enable Prints to check if you getting an error.
Config.ItemName = 'bmx' -- Name of the Item.
Config.Framework = "qbox" -- Write your Framework: "qb" or "esx" or "vrp" or "custom".
Config.Target = "ox" -- Write your Target System: "qb" or "ox" or "none".
Config.FrameworkResourceName = nil -- Fill only in case that your Framework resource folder isnt located in the Default directory.
Config.minimumSpeed = 1.0 -- Minimum km/h to perform a Trick.
Config.ActiveWhitelist = false
Config.maxFallSurvival = 150

--TRICK KEYS
Config.BarSpin      = 24    --LEFT MOUSE BUTTON / RT
Config.BikeFlip     = 113   --G / LEFT STICK
Config.BriFlip      = 51    --E / DPAD RIGHT
Config.HDFlip       = 80    --R / B
Config.Invert       = 52    --Q / DPAD LEFT
Config.Superman     = 131   --LEFT SHIFT / X
Config.Tailwhip     = 79    --C /  RIGHT STICK
Config.TuckNoHander = 76    --Space / RB
Config.TurnDown     = 252   --X / LT
-- WHEELIE: L Ctrl / L Stick

Config.allowedVehicles = {
    [`bmx_1`] = true,
    [`bmx_2`] = true,
    [`bmx_3`] = true,
    [`bmx_4`] = true,
    [`bmx_5`] = true,
    [`bmx_6`] = true,
    [`bmx_7`] = true,
    [`bmx_8`] = true,
    [`bmx_9`] = true,
    [`bmx_10`] = true,
}

Config.Language = {
    Info = {
        ['controls'] = 'Press E to Pickup or Target',
    },
    Bmx = {
        ['target'] = 'Save BMX.',
        ['text'] = '[E] Save BMX.'
    },
}
