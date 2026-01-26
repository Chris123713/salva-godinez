Config = Config or {}

Config.DebugPrint = false -- Print debug messages to console

Config.Framework = 'auto' --auto | --qbox | --qb | --esx | --standalone
--[[
    Supported frameworks:
        * esx: es_extended, https://github.com/esx-framework/esx-legacy
        * qbox: qbx_core, https://github.com/qbox-project/qbx_core
        * qb: qb-core, https://github.com/qbcore-framework/qb-core
        * standalone: no framework, note that framework specific apps will not work unless you implement the functions in `standalone.lua`. - vMenu basic support included.
--]]

Config.InteractOption = 'auto' -- ox_target, qb-target, interact, sleepless_interact, drawtext

Config.BankLocations = {
    [1] = { -- Pacific Standard
        model = 'u_m_m_bankman',
        coords = vector4(241.44, 227.19, 106.29, 170.43),
        bankName = 'pacific'
    },
    [2] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(313.84, -280.58, 54.16, 338.31),
        bankName = 'fleeca'
    },
    [3] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(149.46, -1042.09, 29.37, 335.43),
        bankName = 'fleeca'
    },
    [4] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(-351.23, -51.28, 49.04, 341.73),
        bankName = 'fleeca'
    },
    [5] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(-1211.9, -331.9, 37.78, 20.07),
        bankName = 'fleeca'
    },
    [6] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(-2961.14, 483.09, 15.7, 83.84),
        bankName = 'fleeca'
    },
    [7] = { -- Fleeca Bank
        model = 'ig_barry',
        coords = vector4(1174.8, 2708.2, 38.09, 178.52),
        bankName = 'fleeca'
    },
    [8] = { -- Blaine County Savings(Paleto)
        model = 'u_m_m_bankman',
        coords = vector4(-112.22, 6471.01, 31.63, 134.18),
        bankName = 'blaine'
    }
}

Config.Atms = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`
}

-- example: 100$;
-- Choose the formatting of the currency.
-- {amount}$ - *default - !!! DO NOT CHANGE THE LABEL INSIDE THE BRAKETS !!!
Config.CurrencyFormat = "${amount}"
Config.CurrencySymbol = "$"

-- Used to send notifications & emails.
Config.Phone = 'yseries'

-- ============================= --
--- RECOMENDED TO LEAVE AS TRUE ---
-- ============================= --
Config.CheckForUpdates = true
Config.AutoImportSQL = true -- Automatically import/migrate database on server start
