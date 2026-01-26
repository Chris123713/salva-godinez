Config = Config or {}

Config.SQLQueries = {}
Config.Framework = 'QB' -- AUTO | ESX | QB (Set to QB for QBX)
Config.FrameworkNames = {
    ESX = 'es_extended',
    QB = 'qbx_core',  -- Changed to qbx_core for QBX Framework
}
Config.Debug = false
Config.Mugshot = false
Config.Target = true     -- Use targer or if false use marker
Config.Lang = 'en'        -- en, sl, ar, id
Config.Multijob = 'qbox'  -- QBX multijob support (wasabi_multijob / ps-multijob / cs_multijob / core_multijob / qbox)
Config.UI = {
    ['currency'] = 'USD', -- if you want usd change it to USD, list can be found here https://www.iban.com/currency-codes
    ['currencysymbol'] = '$',
    ['disablebossbilling'] = false,
    ['position'] = 'top',       -- Top, Center, or Bottom
    ['permissions'] = {
        ['MaxEmployeeCut'] = 20 -- in percentage in the ui
    }
}
Config.OffJobPrefix = 'off'
Config.LowestGrade = 0                 -- the default grade for hire and fire
Config.BossMenuDepositAccount = "bank" -- can be changed to money / cash or bank

Config.BillCommand = 'billing'         -- open bill menu
Config.ShowNameBillReceiver = true     -- disable if you want to show player id
Config.DeletePaid = false              -- This will delete paid bills if set to true
Config.AutoPay = true                  -- Pay bills pass deadline
Config.AutoPayCheckTimer = "0 * * * *" -- Check Unpaid Bills for every one hour
Config.AutoPayAllowNegative = true     -- Allow paying bills with negative balance
Config.DaysUntilExpiry = 30
Config.PayAccountWith =
'bank'                     -- can be a string or array examples 'bank' or {'bank', 'money'} and checks accounts in order
Config.RequestBill = false -- enable this if you want to use request bill

Config.SocietyIntegration = {
    -- OPTIONAL - Set to FALSE to use built-in management_funds table
    -- Supported scripts: esx_addonaccount, qb-management, qb-banking, fd_banking, Renewed-Banking, LGMods_Banking
    -- qb-management only support the old version of qb-management
    -- Set to the resource/script name to integrate with external banking systems.
    -- For TGG Banking, set both fields to your TGG banking resource name below.
    ScriptName = 'tgg-banking', -- replace with your TGG banking export name if different
    ResourceName = 'tgg-banking',  -- Resource Name / Script Name in case you renamed it
}

Config.PayCheck = {
    Enabled = true,
    Account = 'bank',
    PerHour = true -- false for per minutes
    -- example
    -- job grade salary per hour: $1200
    -- duty total duration 30 minutes
    -- if Config.PayCheck.PerHour is true
    -- salary = (1200 / 60) * 30 = $600
    -- If Config.PayCheck.PerHour is false
    -- salary = 1200 * 30 = $36,000
}

Config.Tax = {
    Enabled = true,
    Percent = 5,       -- percentage of invoice generated
    Job = 'government' -- who the tax will be sent to?
}

Config.Database = {
    Autodetect = true,        -- Enabling this will auto detect the database type
    Gang = 'gangs',
    Bill = "billings",        -- database name for billing
    Company = "management_funds",         -- Using management_funds table for QBX
    CompanyColumns = {
        Job = 'job_name',     -- Binary modules use hardcoded 'job_name'
        Amount = 'money',     -- Column name for money
        Type = 'account_type' -- Column name for account type
    }
}

Config.EnableBlackMoney = {
    mechanic = true, -- enable or disable company to keep black money
    ambulance = false,
    police = false,
    lscso = false,
}

Config.Points = {
    police = {
        vec3(461.4418, -986.1797, 30.6604),  -- LSPD Mission Row - Chief's Office
        vec3(-1072.5798, -807.0468, 22.9849) -- LSPD Vespucci Station
    },
    lscso = {
        vec3(1736.1730, 3897.3916, 39.5724),  -- LSCSO Sandy Shores Sheriff's Office
        vec3(-462.2089, 6017.7886, 35.0720)   -- LSCSO Paleto Bay Sheriff's Office
    },
    -- sasp = {
    --     vec3(0.0, 0.0, 0.0),  -- Add SASP boss menu location here when ready
    -- },
    ambulance = {
        vec3(263.6728, -1357.9293, 23.5378)
    },
    ['safr'] = {
        vec3(335.3573, -594.2171, 43.1890)
    },
    lostmc = {
        vec3(-474.2486, 272.5231, 83.2463)
    }
    ,
    mechanic = {
        vec3(-347.8255, -130.6322, 41.8588), -- LS Customs mechanic shop (boss menu)
        vec3(95.8736, 6528.2046, 31.7529) -- Paleto mechanic shop (boss menu)
    }
    ,
    tm_mechanic = {
        vec3(95.8736, 6528.2046, 31.7529) -- TM mechanic (Paleto) — adjust coords if needed
    }
}

Config.MaxRanks = {
    ['police'] = 14,  -- LSPD has 14 ranks (Cadet to Chief)
    ['lscso'] = 15,   -- LSCSO has 15 ranks (Cadet to Sheriff)
    ['sasp'] = 15,    -- SASP has 15 ranks (Cadet to Commissioner)
    ['ambulance'] = 8,
    ['mechanic'] = 6,
    ['mafia'] = 10
}

-- Optional: map incoming billing/company identifiers (aliases) to actual company identifiers
-- Example: map job 'safr' to society/company identifier 'tff' so billing deposits go to TFF banking
Config.CompanyAliases = {
    ['safr'] = 'safr',
    ['police'] = 'police',
    ['lscso'] = 'lscso',
}

Config.DisableRankDeletion = {
    ['police'] = { 3, 4 },
    ['ambulance'] = { 4 },
}
