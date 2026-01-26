-----------------------------------------------------------------------------------
-- WAIT! Before editing this file manually, try our new easy configuration tool! --
--               https://configurator.jgscripts.com/dealerships                  --
-----------------------------------------------------------------------------------
Config = {}

-- Localisation
Config.Locale = "en"
Config.NumberAndDateFormat = "en-US"
Config.Currency = "USD"
Config.SpeedUnit = "mph" -- or "kph"

-- Framework & Integrations
Config.Framework = "auto" -- or "QBCore", "Qbox", "ESX"
Config.FuelSystem = "none" -- or "LegacyFuel", "ps-fuel", "lj-fuel", "ox_fuel", "cdn-fuel", "hyon_gas_station", "okokGasStation", "nd_fuel", "myFuel", "ti_fuel", "Renewed-Fuel", "rcore_fuel", "qs-fuelstations", "none"
Config.VehicleKeys = "none" -- or "qb-vehiclekeys", "MrNewbVehicleKeys", "jaksam-vehicles-keys", "qs-vehiclekeys", "mk_vehiclekeys", "wasabi_carlock", "cd_garage", "okokGarage", "t1ger_keys", "Renewed", "tgiann-hotwire", "none"
Config.Notifications = "auto" -- or "default", "okokNotify", "ox_lib", "ps-ui"
Config.DrawText = "ox_lib" -- or "jg-textui", "qb-DrawText", "okokTextUI", "ox_lib", "ps-ui" (set to ox_lib for ox_target)

-- Text UI prompts
Config.OpenShowroomPrompt = "[E] Open Showroom"
Config.OpenShowroomKeyBind = 38
Config.ViewInShowroomPrompt = "[E] View in Showroom"
Config.ViewInShowroomKeyBind = 38
Config.OpenManagementPrompt = "[E] Dealership Management"
Config.OpenManagementKeyBind = 38
Config.SellVehiclePrompt = "[E] Sell Vehicle"
Config.SellVehicleKeyBind = 38

-- If you don't know what this means, don't touch this
-- If you know what this means, I do recommend enabling it but be aware you may experience reliability issues on more populated servers
-- Having significant issues? I beg you to just set it back to false before opening a ticket with us
-- Want to read my rant about server spawned vehicles? https://docs.jgscripts.com/advanced-garages/misc/why-are-you-not-using-createvehicleserversetter-by-default
Config.SpawnVehiclesWithServerSetter = false

-- Finance (to disable finance, you have to do it on a per-location basis with Config.DealershipLocations below)
Config.FinancePayments = 12
Config.FinanceDownPayment = 0.1 -- 0.1 means 10%
Config.FinanceInterest = 0.1 -- 0.1 means 10%
Config.FinancePaymentInterval = 12 -- in hours
Config.FinancePaymentFailedHoursUntilRepo = 1 -- in hours
Config.MaxFinancedVehiclesPerPlayer = 5

-- Little vehicle preview images in the garage UI - learn more/add custom images: https://docs.jgscripts.com/advanced-garages/vehicle-images
Config.ShowVehicleImages = true

-- Vehicle purchases
Config.PlateFormat = "1AA111AA" -- https://docs.jgscripts.com/dealerships/plate-format
Config.HideVehicleStats = false

-- Test drives
Config.TestDrivePlate = "TEST1111" -- This is a plate seed so it'll be random every time (read: https://docs.jgscripts.com/dealerships/plate-format)
Config.TestDriveTimeSeconds = 120
Config.TestDriveNotInBucket = false -- Set to true for everyone to see the test driven vehicle (player is instanced by default)

-- Display vehicles (showroom)
Config.DisplayVehiclesPlate = "DEALER"
Config.DisplayVehiclesHidePurchasePrompt = false

-- Dealership stock purchases
Config.DealerPurchasePrice = 0.6 -- 0.8 = Dealers pay 80% of vehicle price
Config.VehicleOrderTime = 1 -- in mins
Config.ManagerCanChangePriceOfVehicles = true -- Managers can change the price of vehicles in the dealership

-- Vehicle colour options (for purchases & display vehicles)
Config.UseRGBColors = true -- this will use the index instead of hex, see https://pastebin.com/pwHci0xK (hex will still be used in the ui)
Config.VehicleColourOptions = {
  {label = "Red", hex = "#e81416", index = 27},
  {label = "Orange", hex = "#ff7518", index = 38},
  {label = "Yellow", hex = "#ffbf00", index = 88},
  {label = "Green", hex = "#79c314", index = 92},
  {label = "Blue", hex = "#487de7", index = 64},
  {label = "Purple", hex = "#70369d", index = 145},
  {label = "Black", hex = "#000000", index = 0},
  {label = "White", hex = "#ffffff", index = 111},
}

Config.Categories = {
  planes = "Planes",
  sportsclassics = "Sports Classics",
  sedans = "Sedans",
  compacts = "Compacts",
  motorcycles = "Motorcycles",
  super = "Super",
  offroad = "Offroad",
  helicopters = "Helicopters",
  coupes = "Coupes",
  muscle = "Muscle",
  boats = "Boats",
  vans = "Vans",
  sports = "Sports",
  suvs = "SUVs",
  commercial = "Commercial",
  cycles = "Cycles",
  industrial = "Industrial",
  teu = "TEU (Tactical Enforcement Unit)",
  trucks = "trucks",
  EMS = "EMS",
  police = "Police",
  esair = "Emergency Services Air",
  esboat = "Emergecy Services Boat"
}

Config.DealershipLocations = {
  ["pdm"] = {
    type = "self-service", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(-32.1491, -1096.5920, 27.3218),
      size = 2.5
    },
    openManagement = {
      coords = vector3(-30.43, -1106.84, 26.42),
      size = 2.5
    },
    sellVehicle = {
      coords = vector3(-27.89, -1082.1, 26.64),
      size = 2.5
    },
    purchaseSpawn = vector4(-49.85, -1073.86, 25.71, 68.72),
    testDriveSpawn = vector4(-49.85, -1073.86, 25.71, 68.72),
    camera = {
      name = "Car",
      coords = vector4(-36.98, -1093.37, 25.8, 13.74),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"sedans", "compacts", "offroad", "coupes", "muscle", "suvs", "sportsclassics", "trucks"},
    enableTestDrive = true,
    hideBlip = false,
    blip = {
      id = 326,
      color = 2,
      scale = 0.6
    },
    enableSellVehicle = true, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableFinance = true,
    hideMarkers = true,  -- Hide markers when using ox_target
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
    disableShowroomPurchase = false,
    job = "cardealer", -- Owned dealerships only
    directSaleDistance = 50,
  },
  ["route68motorcycles"] = {
    type = "owned", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(1224.354980, 2738.348633, 38.108730),
      size = 1.5
    },
    openManagement = {
      coords = vector3(1228.795898, 2741.257080, 38.104671),
      size = 1.5
    },
    sellVehicle = {
      coords = vector3(-27.89, -1082.1, 26.64),
      size = 5
    },
    purchaseSpawn = vector4(1231.347656, 2711.709961, 38.008083, 186.101181),
    testDriveSpawn = vector4(1227.871338, 2710.918213, 38.008190, 173.173950),
    camera = {
      name = "Car",
      coords = vector4(1224.59, 2718.45, 36.5, 181.36),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"motorcycles", "offroad",},
    enableTestDrive = true,
    hideBlip = false,
    blip = {
      id = 661,
      color = 47,
      scale = 0.6
    },
    enableSellVehicle = false, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableFinance = true,
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
    disableShowroomPurchase = false,
    job = "cardealer", -- Owned dealerships only
    directSaleDistance = 50,
  },
  ["luxpdm"] = {
    type = "self-service", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(-1039.64, -1374.29, 4.55),
      size = 2
    },
    openManagement = {
      coords = vector3(-1029.0488, -1359.6447, 10.2595),
      size = 2
    },
    sellVehicle = {
      coords = vector3(-1057.0914, -1418.7561, 5.4258),
      size = 5
    },
    purchaseSpawn = vector4(-1048.96, -1396.4, 4.02, 76.91),
    testDriveSpawn = vector4(-1048.96, -1396.4, 4.02, 76.91),
    camera = {
      name = "Car",
      coords = vector4(-1030.1912, -1367.7556, 5.5541, 68.5279),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"super", "sports", "suvs"},
    enableSellVehicle = true, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableTestDrive = true,
    enableFinance = true,
    hideBlip = false,
    blip = {
      id = 523,
      color = 2,
      scale = 0.6
    },
    hideMarkers = false,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
  },
  ["boats"] = {
    type = "self-service", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(-739.55, -1333.75, 1.6),
      size = 5
    },
    openManagement = {
      coords = vector3(-731.37, -1310.35, 5.0),
      size = 5
    },
    sellVehicle = {
      coords = vector3(-714.42, -1340.01, -0.18),
      size = 5
    },
    purchaseSpawn = vector4(-714.42, -1340.01, -0.18, 139.38),
    testDriveSpawn = vector4(-714.42, -1340.01, -0.18, 139.38),
    camera = {
      name = "Sea",
      coords = vector4(-808.28, -1491.19, -0.47, 113.53),
      positions = {7.5, 12.0, 15.0, 12.0}
    },
    categories = {"boats"},
    enableSellVehicle = true, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableTestDrive = false,
    hideBlip = false,
    blip = {
      id = 410,
      color = 2,
      scale = 0.6
    },
    hideMarkers = false,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
  },
  ["air"] = {
    type = "self-service", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(-1623.0, -3151.56, 13.99),
      size = 5
    },
    openManagement = {
      coords = vector3(-1637.78, -3177.94, 13.99),
      size = 5
    },
    sellVehicle = {
      coords = vector3(-1649.32, -3161.47, 12.99),
      size = 5
    },
    purchaseSpawn = vector4(-1662.88, -3143.22, 13.59, 330.72),
    testDriveSpawn = vector4(-1662.88, -3143.22, 13.59, 330.72),
    camera = {
      name = "Air",
      coords = vector4(-1649.98, -3138.93, 13.63, 329.92),
      positions = {12.0, 15.0, 20.0, 15.0}
    },
    categories = {"planes", "helicopters"},
    enableSellVehicle = true, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableTestDrive = false,
    hideBlip = false,
    blip = {
      id = 423,
      color = 2,
      scale = 0.6
    },
    hideMarkers = false,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
  }, 
  ["truck"] = {
    type = "self-service", -- or "owned", "self-service"
    openShowroom = {
      coords = vector3(1214.37, -3204.53, 6.03),
      size = 5
    },
    openManagement = {
      coords = vector3(1184.45, -3179.27, 7.1),
      size = 5
    },
    sellVehicle = {
      coords = vector3(1201.57, -3187.82, 5.01),
      size = 5
    },
    purchaseSpawn = vector4(1205.75, -3203.29, 4.6, 180.85),
    testDriveSpawn = vector4(1205.75, -3203.29, 4.6, 180.85),
    camera = {
      name = "Truck",
      coords = vector4(1205.75, -3203.29, 4.6, 180.85),
      positions = {7.5, 12.0, 15.0, 12.0}
    },
    categories = {"vans", "commercial", "industrial"},
    enableSellVehicle = true, -- Allow players to sell vehicles back to dealer
    sellVehiclePercent = 0.6,  -- 60% of current sale price
    enableTestDrive = true,
    enableFinance = true,
    hideBlip = false,
    blip = {
      id = 477,
      color = 2,
      scale = 0.6
    },
    hideMarkers = false,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {},
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {},
    societyPurchaseGangWhitelist = {},
  },
   ["Emergency Services Vehicle"] = {
    name = "Department Store",
    type = "self-service", -- Police department vehicle store
    openShowroom = {
      coords = vector3(-1606.17, -820.48, 9.24),
      size = 2.0
    },
    --[[openManagement = {
      coords = vector3(-1604.7994, -823.4353, 13.5468),
      size = 5.0
    },
    sellVehicle = {
      coords = vector3(-1608.4771, -825.9324, 10.0794),
      size = 5.0
    },
    ]]--
    purchaseSpawn = vector4(-1635.68, -811.66, 8.65, 137.23),
    testDriveSpawn = vector4(-1635.68, -811.66, 8.65, 137.23),
    camera = {
      name = "Car",
      coords = vector4(-1603.06, -835.91, 8.75, 48.25),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"teu", "suvs", "sedans", "vans", "motorcycles", "helicopters", "boats", "offroad", "police", "EMS"}, -- Police vehicle types (TEU, SUVs, Sedans, Vans, Motorcycles, Helicopters, Boats, Offroad)
    enableSellVehicle = false, -- Police cannot sell vehicles back
    sellVehiclePercent = 0.0,
    enableTestDrive = true, -- No test drives for police vehicles
    enableFinance = false, -- No finance for police vehicles
    hideBlip = false,
    blip = {
      id = 56, -- Police badge icon
      color = 38, -- Blue color for police
      scale = 0.7,
      name = "PD Dept Store"
    },
    hideMarkers = false, -- Show markers for easier finding
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- LSPD and LSCSO can access
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- Allows purchasing vehicles for the department
    paymentOptions = {"societyFund", "cash", "bank"}, -- Society fund pulls from tgg-banking society account
    societyPurchaseGangWhitelist = {},
  },
   ["Emergency Services Air"] = {
    name = "Department Air Store",
    type = "self-service", -- Police department aircraft store
    openShowroom = {
      coords = vector3(-1777.07, 2973.96, 31.81),
      size = 2.0
    },
    --[[openManagement = {
      coords = vector3(-1770.21, 2993.16, 36.67),
      size = 5.0
    },
    sellVehicle = {
      coords = vector3(-1805.93, 2995.39, 31.81),
      size = 5.0
    },
    ]]--
    purchaseSpawn = vector4(-1838.42, 2980.97, 32.45, 59.64),
    testDriveSpawn = vector4(-1838.42, 2980.97, 32.45, 59.64),
    camera = {
      name = "Air",
      coords = vector4(-1838.42, 2980.97, 32.45, 59.64),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"esair"}, -- Police vehicle types (aircraft)
    enableSellVehicle = false, -- Police cannot sell vehicles back
    sellVehiclePercent = 0.0,
    enableTestDrive = true, -- No test drives for police vehicles
    enableFinance = false, -- No finance for police vehicles
    hideBlip = true,
    blip = {
      id = 56, -- Police badge icon
      color = 38, -- Blue color for police
      scale = 0.7,
      name = "ES Air Dept Store"
    },
    hideMarkers = true, -- Show markers for easier finding
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- LSPD and LSCSO can access
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- Allows purchasing vehicles for the department
    paymentOptions = {"societyFund", "cash", "bank"}, -- Society fund pulls from tgg-banking society account
    societyPurchaseGangWhitelist = {},
  },
   ["Emergency Services Boat"] = {
    name = "Department Boat Store",
    type = "self-service", -- Police department aircraft store
    openShowroom = {
      coords = vector3(-918.15, -1366.15, 0.6),
      size = 2.0
    },
    --[[openManagement = {
      coords = vector3(-918.15, -1366.15, 0.6),
      size = 5.0
    },
    sellVehicle = {
      coords = vector3(-918.15, -1366.15, 0.6),
      size = 5.0
    },
    ]]--
    purchaseSpawn = vector4(-920.52, -1360.44, -0.6, 297.57),
    testDriveSpawn = vector4(-920.52, -1360.44, -0.6, 297.57),
    camera = {
      name = "Sea",
      coords = vector4(-901.29, -1355.8, -0.61, 240.11),
      positions = {5.0, 8.0, 12.0, 8.0}
    },
    categories = {"esboat"}, -- Police vehicle types (Boats)
    enableSellVehicle = false, -- Police cannot sell vehicles back
    sellVehiclePercent = 0.0,
    enableTestDrive = true, -- No test drives for police vehicles
    enableFinance = false, -- No finance for police vehicles
    hideBlip = true,
    blip = {
      id = 56, -- Police badge icon
      color = 38, -- Blue color for police
      scale = 0.7,
      name = "ES Boat Dept Store"
    },
    hideMarkers = true, -- Show markers for easier finding
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    showroomJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- LSPD and LSCSO can access
    showroomGangWhitelist = {},
    societyPurchaseJobWhitelist = {
	police = {12, 13,14},
	lscso = {13, 14, 15},
	safr = {6, 7, 8},
    }, -- Allows purchasing vehicles for the department
    paymentOptions = {"societyFund", "cash", "bank"}, -- Society fund pulls from tgg-banking society account
    societyPurchaseGangWhitelist = {},
  },
}
-- Commands
Config.MyFinanceCommand = "myfinance"
Config.DirectSaleCommand = "directsale"
Config.DealerAdminCommand = "dealeradmin"

-- Nerd options
Config.RemoveGeneratorsAroundDealership = 60.0
Config.AutoRunSQL = true
Config.ReturnToPreviousRoutingBucket = false
Config.HideWatermark = false
Config.Debug = false