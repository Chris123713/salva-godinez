function HelpText(show, message)
    if show then
        -- TriggerEvent('cd_drawtextui:ShowUI', 'show', message)
        lib.showTextUI(message)
        -- exports['jg-textui']:DrawText(message)
        -- ESX.TextUI(message)
        -- exports['okokTextUI']:Open(message, 'lightblue', 'right')
        -- exports['qb-core']:DrawText(message)
        -- exports['bcs_hud']:displayHelp(message)
    else
        -- exports['ataUI']:closeText()
        -- TriggerEvent('cd_drawtextui:HideUI')
        lib.hideTextUI()
        -- exports['jg-textui']:HideText()
        -- ESX.HideUI()
        -- exports['okokTextUI']:Close()
        -- exports['qb-core']:HideText()
        -- exports['bcs_hud']:closeHelp()
    end
end

function Notify(title, message, type, duration)
    -- ===== QB uncomment below =====
    -- if type == 'info' or type == 'warning' then
    --     type = 'primary'
    -- end
    -- QBCore.Functions.Notify(message, type, duration)
    -- ===== QB uncomment above ======

    -- exports['bcs_hud']:SendAlert(title, message, type, duration)
    -- exports['okokNotify']:Alert(title, message, duration, type)
    -- ESX.ShowNotification(message)
    lib.notify({ title = title, description = message, type = type, duration = duration })
end

function debugPrint(...)
    if Config.debug then
        print(...)
    end
end

RegisterNetEvent('Housing:notify', Notify)

Config = Config or {}

Config.Lang = 'en' -- en, sl, ar, id
Config.target = true
Config.QBBanking = false
Config.debug = false

-- options are:
-- ox_inventory
-- qs-inventory
-- qb-inventory
-- origen_inventory
-- lj-inventory
-- core_inventory
-- chezza
-- tgiann
-- ak47_inventory
-- mInventory (This is codem-inventory)
Config.Inventory = 'ox_inventory'

Config.DefaultAccount = 'bank'         -- for buying house and furnitures
Config.TimeInShell = 18                -- The time when inside a shell 0-23
Config.SaveDoorsWhenSold = true        -- When MLO is sold, should the door locks persist?
Config.AutoLock = true                 -- Auto lock doors when you exit a shell or ipl (if house is empty & person haskey)
Config.EnableLastProperty = true       -- When players logout inside a shell or IPL, they will login inside it
Config.LimitHouses = 0                 -- maximum amount of players owned houses, if 0 then no limit is placed
Config.useDataStore = false            -- For ESX, saving wardrobe/outfit in esx_datastore
Config.UseStarterApartment = false
Config.sellFurniturePercentage = 50    -- Selling unused furniture for half price (50%)
Config.RevokeOwnerAfterExpiry = 2      -- Give 2 days of grace period before revoking ownership
Config.RevokeOwnerAfterInactivity = 14 -- Give 14 days after last login before revoking the ownership
Config.ShowNameOnKnock = false         -- show the player ingame name when knocking on door
Config.Preview = {
    Catalogue = true,                  -- disable catalogue preview
    Home = true,                       -- disable home for sale preview
}

Config.EnableFurnitureShop = false -- enable furniture shop, if disabled then users can buy directly from /furnish
Config.FurnitureMenu = 'default'   -- 'default' or 'ox_lib'
Config.EnableFurnish = true        -- Do you want to disable the whole furnish system? idk why though
Config.FurnitureAlpha = 120        -- from 0 to 255 for entity transparency when moving it
Config.FurnitureAsItem = false     -- Enable Furniture shop to buy furnitures as items
Config.FurnitureItem = 'furniture' -- The item that will be used to place furnitures
Config.EnableCatalogue = true      -- Enable catalogue preview for people to check list of interiors / houses
Config.RadiusShellCheck = 100      -- Check the radius of the player if they somehow managed to bug out of the shell, then it will teleport if it exceed this distance

Config.KeyAsItem = {
    Enable = false,            -- Enable key as item this will disable the default key system
    Ped = 's_m_m_movalien_01', -- ped model or false to disable ped
    ItemName = 'house_key',    -- item name for the house key
    Coords = vec4(-39.0449, -1388.5126, 30.4917, 359.0285),
    Price = 100,
    DuplicatePrice = 50,
    Account = 'bank',
    Blip = {
        label = 'Locksmith',
        sprite = 187,
        colour = 2,
        scale = 0.7,
    }
}

-- set either one of this up in your server.cfg
-- fivemanage
-- setr FIVEMANAGE_TOKEN fivemanagetoken
-- standalone
-- setr IMAGE_SERVER http://your.image.server.ip:5000
-- discord
-- setr SCREENSHOT_WEBHOOK your_webhook_link
-- offline
-- this method is for those who does not want to use image upload server
-- and put the image in the html folder instead
Config.Screenshot = 'offline'
Config.UI = {
    FurnitureShopImage = true,
    KeyAsItem = Config.KeyAsItem.Enable,
    Bill = Config.Bill.enabled
}

Config.Upgrades = {
    keys = {
        max = 10,
        price = 100,
        bgImage = './images/key-upgrades.png'
    },
    storage = {
        max = 20,
        price = 500,
        bgImage = './images/organized-storage-room-shelves.png'
    },
    wardrobes = {
        max = 10,
        price = 50,
        bgImage = './images/modern-walk-in-wardrobe.png'
    },
    garages = {
        max = 10,
        price = 200,
        bgImage = './images/luxury-car-garage.png'
    }
}

Config.exportname = {
    es_extended = "es_extended",
    qb_core = 'qb-core',
    qbx_core = 'qbx_core',
    qtarget = 'qtarget',
    qbtarget = 'qb-target',
    ox_target = 'ox_target',
    bob74_ipl = 'bob74_ipl',
}

Config.MaxDistance = {
    Garage = 50,
    Furniture = 100,
    Freecam = 100,
    FrontyardDistance = 100 -- Maximum distance of the area point from the entry point of the house
}

Config.FurnitureStorage = { -- Default values
    slots = 10,
    weight = 100000
}

Config.keybinds = {
    lockdoor = 38, -- 'E'
    furnish = {
        LeftRight = { key = { 189, 190 }, help = '~←~ ~→~' },
        ForwardBackward = { key = { 188, 187 }, help = '~↑~ ~↓~' },
        PitchYawRoll = { key = { 189, 190, 187, 188 }, hold = 21, help = '~Shift~ ~Arrows~' },
        ChangeHeight = { key = { 96, 97 }, help = 'Scroll' },
        Rotate = { key = { 85, 86 }, help = '~Q~ ~E~' },
        ChangeSpeed = { key = { 171, 37 }, help = '~CAPSLOCK~ ~TAB~' },
    },
    area = {
        shift = { key = 21, help = 'LShift' },
        alt = { key = 19, help = 'LAlt' },
        ChangeStep = { key = { 96, 97 }, help = 'Scroll' },
        IncreaseDecreaseHeight = { key = { 45, 23 }, help = 'R~ ~F' },
        scroll = { key = { 17, 16 }, help = 'Scroll' },
        PrecisionMode = { key = 45, help = 'R' },
        AddPoint = { key = 47, help = 'G' },
        Confirm = { key = 201, help = 'ENTER' },
        Cancel = { key = 73, help = 'X' },
        PrecisionMovement = { key = { 187, 188, 189, 190 }, help = '~←~ ~→~ ~↑~ ~↓~' },
    }
}

Config.Admin = {
    Groups = { -- admins can make houses
        'superadmin',
        'admin',
        'moderator',
        'command'
    },
    Permission = {
        furnish = true,
    }
}

Config.EnableMarkers = {
    enable = false, -- enable marker (small decrease in performance)
    type = 20,      -- the marker type
    color = { r = 237, g = 170, b = 26 },
    size = { x = 1.0, y = 1.0, z = 1.0 },
}

-- These are Placeholders in the UI. You still have to change the house configs in game
-- Since each house can have different configurations
Config.configuration = {
    DefaultMaxStorage = 3,
    DefaultMaxGarages = 2,
    LimitWardrobes = 2, -- maximum amount of wardrobe marker placement
    LimitKeys = 4,      -- maximum amount of keys per house that can be duplicated
    Upgrades = false,   -- by default should upgrades be enabled when creating house?
    Garage = false,     -- by default should garage be enabled when creating house?
    CCTV = false,       -- by default should cctv be enabled when creating house?
    Rename = false,     -- by default should renaming house name be enabled when creating house?
    -- Rents
    RentTimer = 1,      -- default rent timer
    AutoRemove = 4,     -- default amount of days before house is automatically removed
    Bill = true,        -- by default should bill be enabled when creating house?

    DefaultOwnerPermission = {
        sell = true,
        transfer = true,
        doorlock = false,
        moveGarage = true
    },

    DefaultRentOptions = { -- Tenant rent options
        price = 50,
        duration = 7,
        durationType = 'day' -- either 'day' or 'week'
    }
}

Config.robbery = {
    disableVisit = false,
    enable = false,
    lockpickItem = 'lockpick_house',
    ApartmentRobbery = true,      -- Allow apartment to be lockpickable
    alertAfterFailed = 5,         -- Alert police after certain amount of times
    alertLockpick = true,         -- Alert owner and key owners when house is lockpicked
    alertNonOwnerEntering = true, -- Alert owner and key owners when non-owner enters the house
    alertOwnerDuration = 8000,    -- Alert owner duration for the notification
    storageLockpick = true,       -- Requires non owner to lockpick storage before accessing it
    storageRobbery = false,       -- Disable stash robbery or non owner to access it
    alertPolice = true,           -- Alert police if lockpick succeed
    minPolice = 0,                -- Minimum police to do a lockpick
    enableRaid = true,            -- Police raid
    offlineRobbery = false,       -- Enable robbery even if the owner of the house is offline
    policeName = {
        ['police'] = 2,
        ['bcso'] = 2
    }, -- Police job name and minimum grade
}

Config.rent = {
    rentCheckTimer = "*/10 * * * *", -- Check Rent every 10 minute
    paymentAccount = 'bank',         -- account for manual payment
    autoPayment = false,             -- auto pay rent when the player joins
    autoPaymentAccount = 'bank',
    deleteAfterAutoRemove = false    -- Deletes the home after being revoked from the player
}

Config.mortgage = {
    checkTimer = "0 * * * *", -- Check Rent every hour
    weeks = 7,                -- Days,
    months = 30,              -- Days,
    paymentAccount = 'bank',  -- account for manual payment
    autoPayment = false,
    autoPaymentAccount = 'bank',
    removeAfter = 7, -- Days
    returnMoneyAfterRemoval = false,
    deleteAfterAutoRemove = false
}

Config.tax = {
    enable = false,
    account = 'bank', -- cash or money or bank
    society = 'government',
    percentage = 0.1,
}

Config.Catalogue = {
    coords = vec3(-197.8194, -575.3558, 40.6823),
    size = vec3(1.5, 1.5, 1.5),
    rotation = 248.1143,
    -- Blip
    label = 'House Catalogues',
    sprite = 826,
    colour = 54,
    scale = 0.8,
}

Config.SQLQueries = {}
