function HelpText(show, message)
    if show then
        -- TriggerEvent('cd_drawtextui:ShowUI', 'show', message)
        lib.showTextUI(message)
        -- ESX.TextUI(message)
        -- exports['okokTextUI']:Open(message, 'lightblue', 'right')
        -- exports['qb-core']:DrawText(message)
        -- exports['bcs_hud']:displayHelp(message)
    else
        -- TriggerEvent('cd_drawtextui:HideUI')
        lib.hideTextUI()
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

RegisterNetEvent('LicenseManager:notify', Notify)

Config = {
    debug = false,
    target = true,
    enablePed = false,
    ManagerBased = true,
    Database = {
        badge = 'badges',
        license = 'licenses',
        license_history = 'license_history',
    },
    -- set either one of this up in your server.cfg
    -- fivemanage or fivemerr or GKSMEDIA
    -- setr SCREENSHOT_TOKEN yourtoken
    -- standalone
    -- setr IMAGE_SERVER http://your.image.server.ip
    -- discord
    -- setr SCREENSHOT_WEBHOOK your_webhook_link
    Screenshot = 'fivemanage',
    ScreenshotAnim = {
        dict = 'rcmnigel1a',
        clip = 'base'
    },
    ScreenshotGreenScreen = true,
    ScreenshotLocationBased = {
        enable = false, -- If you want green screen to be set in fixed coordinate
        location = vec3(0.0, 0.0, 1000.0)
    },
    GreenScreenProp = 'km_greenscreen_01',
    DistanceCheck = 8, -- Maximum distance to create a player license
    society = false,   -- If you want the payment for licenses to be sent to company account, set it to true
    -- Available options
    -- 'ox_inventory',
    -- 'qs-inventory',
    -- 'core_inventory',
    -- 'codem-inventory',
    -- 'tgiann',
    -- 'qb-inventory',
    -- true (using default framework inventory)
    -- false (if you dont want to use the license as items)
    inventory = 'ox_inventory',
    Expiry = {
        RemoveOnExpired = false,
        CheckInterval = 3 * 60 * 60 * 1000 -- Checks every three hour of server lifetime
    },
    ConvertMode = {
        enable = false,
        -- put the old licenses ['your old license type name'] = 'the new name in Config.Licenses'
        old_licenses = {
            ['drive'] = 'driver_car',
            ['drive_bike'] = 'driver_bike',
            ['drive_truck'] = 'driver_truck'
        }
    },
    maleGender = 'm', -- match your database gender column
}

-- Renew Mugshot
Config.Mugshot = {
    coord = {
        vec4(437.2527, -978.1722, 30.6896, 181.4593),
    },
    ped = "s_f_y_cop_01",
    price = 0
}

-- convert from esx_license old licenses, Compatible for oxmysql
Config.UI = {
    ['currency'] = 'USD',         -- if you want usd change it to USD, list can be found here https://www.iban.com/currency-codes
    ['custom_currency'] = false,  -- either false or a custom string like maybe 'MyCurrency'. If its enabled then the currency code above will not matter
    ['expiry'] = true,            -- enable or disable expiry system
    ['shop_view'] = 'horizontal', -- either horizontal or vertical
    ['m'] = 'Male',
    ['f'] = 'Female',
    ['unknown'] = 'Unknown',
    ['useHeight'] = Shared.framework == 'esx',
    ['license_position'] = 'right_center', -- 'top_left', 'top_right', 'bottom_left', 'bottom_right', 'right_center', 'left_center'
    ['badge_position'] = 'left_center',    -- 'top_left', 'top_right', 'bottom_left', 'bottom_right', 'right_center', 'left_center'
}
