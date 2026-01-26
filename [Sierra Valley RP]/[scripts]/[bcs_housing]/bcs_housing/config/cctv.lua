Config = Config or {}

-- CREDITS TO ESX_PROPERTY V2
Config.CCTV = {
    HeightAboveDoor = 1.5, -- Height above the door to place the cctv camera
    FOV = 80.0,            -- Camera Field of View
    pitch = 40,            -- up and down max
    yaw = 100,             -- left and rigth max
    MaxLeftRotation = 80,
    MaxZoom = 30,
    MinZoom = 100,
    MaxRightRotation = -50,
    MaxUpRotation = 10,
    MaxDownRotation = -45,
    RotateSpeed = 0.3,    -- Camera Rotation Speed
    Controls = {
        Left = 34,        -- LEFT Arrow
        Right = 35,       -- RIGHT Arrow
        Screenshot = 201, -- ENTER
        NightVision = 38, -- E
        ZoomIn = 96,      -- UP Arrow
        ZoomOut = 97,     -- DOWN Arrow
        Up = 32,          -- UP Arrow
        Down = 33,        -- DOWN Arrow
        Exit = 194,       -- BACKSPACE
    }
}
