-----------------------------------------------------------------------------------
-- WAIT! Before editing this file manually, try our new easy configuration tool! --
--            https://configurator.jgscripts.com/advanced-garages                --
-----------------------------------------------------------------------------------
Config = {}

-- Localisation
Config.Locale = "en"
Config.NumberAndDateFormat = "en-US"
Config.Currency = "USD"

-- Framework & Integrations
Config.Framework = "auto" -- or "QBCore", "Qbox", "ESX"
Config.FuelSystem = "rcore_fuel" -- or "LegacyFuel", "ps-fuel", "lj-fuel", "ox_fuel", "cdn-fuel", "hyon_gas_station", "okokGasStation", "nd_fuel", "myFuel", "ti_fuel", "Renewed-Fuel", "rcore_fuel", "none"
Config.VehicleKeys = "qb-vehiclekeys" -- or "qb-vehiclekeys", "MrNewbVehicleKeys", "jaksam-vehicles-keys", "qs-vehiclekeys", "mk_vehiclekeys", "wasabi_carlock", "cd_garage", "okokGarage", "t1ger_keys", "Renewed", "tgiann-hotwire" "none"
Config.Notifications = "auto" -- or "default", "okokNotify", "ox_lib", "ps-ui"
Config.Banking = "tgg-banking" -- or "qb-banking", "qb-management", "esx_addonaccount", "Renewed-Banking", "okokBanking", "fd_banking"
Config.Gangs = "auto" -- "qb-gangs", "rcore_gangs"

-- Draw text UI prompts (key binding control IDs here: https://docs.fivem.net/docs/game-references/controls/)
Config.DrawText = "auto" -- or "jg-textui", "qb-DrawText", "okokTextUI", "ox_lib", "ps-ui"
Config.OpenGarageKeyBind = 38
Config.OpenGaragePrompt = "[E] Open Garage"
Config.OpenImpoundKeyBind = 38
Config.OpenImpoundPrompt = "[E] Open Impound"
Config.InsertVehicleKeyBind = 38
Config.InsertVehiclePrompt = "[E] Store Vehicle"
Config.ExitInteriorKeyBind = 38
Config.ExitInteriorPrompt = "[E] Exit Garage"

-- Target
Config.UseTarget = false
Config.Target = "ox_target" -- or "qb-target"
Config.TargetPed = "s_m_y_valet_01"

-- Radial
Config.UseRadialMenu = false
Config.RadialMenu = "ox_lib"


-- Little vehicle preview images in the garage UI - learn more/add custom images: https://docs.jgscripts.com/advanced-garages/vehicle-images
Config.ShowVehicleImages = true

-- Vehicle Spawning & Storing
Config.DoNotSpawnInsideVehicle = false
Config.SaveVehicleDamage = true -- Save and apply body and engine damage when taking the vehicle out a garage
Config.AdvancedVehicleDamage = true -- use Kiminaze's VehicleDeformation
Config.SaveVehiclePropsOnInsert = true
Config.CheckVehicleModel = true -- Extra security

-- If you don't know what this means, don't touch this
-- If you know what this means, I do recommend enabling it but be aware you may experience reliability issues on more populated servers
-- Having significant issues? I beg you to just set it back to false before opening a ticket with us
-- HIGHLY recommended that you set Config.DoNotSpawnInsideVehicle = false if you decide to enable this
-- Want to read my rant about server spawned vehicles? https://docs.jgscripts.com/advanced-garages/misc/why-are-you-not-using-createvehicleserversetter-by-default
Config.SpawnVehiclesWithServerSetter = false

-- Vehicle Transfers
Config.GarageVehicleTransferCost = 2500 -- Cost to transfer between garages
Config.TransferHidePlayerNames = false
Config.EnableTransfers = {
  betweenGarages = true,
  betweenPlayers = true
}
Config.DisableTransfersToUnregisteredGarages = false -- Potential hacking protection for vigilant servers - unregistered garages are ones created via events in third-party script integrations, such as housing scripts, and therefore could be prone to script kiddie attacks.

-- Prevent vehicle duplication
-- Learn more: https://docs.jgscripts.com/advanced-garages/vehicle-duplication-prevention
Config.AllowInfiniteVehicleSpawns = false -- Public & private garages
Config.JobGaragesAllowInfiniteVehicleSpawns = false -- Job garages
Config.GangGaragesAllowInfiniteVehicleSpawns = false -- Gang garages
Config.GarageVehicleReturnCost = 2500 -- "towing" tax if not placed back in garage after server restart; or if destroyed or underwater while left out
Config.GarageVehicleReturnCostSocietyFund = false -- Job name of society fund to pay return fees into (optional)

-- Public Garages
Config.GarageShowBlips = true
Config.GarageUniqueBlips = false
Config.GarageUniqueLocations = true
Config.GarageEnableInteriors = true
Config.GarageLocations = { -- IMPORTANT - Every garage name must be unique
  ["Legion Square"] = { -- If you change the name of this garage from Legion Square, you must change the default value of `garage_id` to the same name in the SQL table `players_vehicles`
    coords = vector3(215.09, -805.17, 30.81),
    spawn = {vector4(216.84, -802.02, 30.78, 69.82), vector4(218.09, -799.42, 30.76, 66.17), vector4(219.29, -797.23, 30.75, 65.4), vector4(219.59, -794.44, 30.75, 69.35), vector4(220.63, -792.03, 30.75, 63.76), vector4(206.81, -798.35, 30.99, 248.53)}, --  you can add multiple spawn locations into a table
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Mission Row"] = {
    coords = vector3(411.2, -976.92, 28.42),
    spawn = vector4(408.38, -980.38, 27.87, 50.14),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 3, -- Light blue/cyan color
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Vespucci"] = {
    coords = vector3(-1110.178223, -802.207642, 17.792110),
    spawn = vector4(-1110.178223, -802.207642, 17.792110, 229.391708),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 3, -- Light blue/cyan color
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Islington South"] = {
    coords = vector3(273.0, -343.85, 44.91),
    spawn = vector4(270.75, -340.51, 44.92, 342.03),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Grove Street"] = {
    coords = vector3(14.66, -1728.52, 29.3),
    spawn = vector4(23.93, -1722.9, 29.3, 310.58),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Mirror Park"] = {
    coords = vector3(1032.84, -765.1, 58.18),
    spawn = vector4(1023.2, -764.27, 57.96, 319.66),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Beach"] = {
    coords = vector3(-1248.69, -1425.71, 4.32),
    spawn = vector4(-1244.27, -1422.08, 4.32, 37.12),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Great Ocean Highway"] = {
    coords = vector3(-2961.58, 375.93, 15.02),
    spawn = vector4(-2964.96, 372.07, 14.78, 86.07),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Sandy South"] = {
    coords = vector3(217.33, 2605.65, 46.04),
    spawn = vector4(216.94, 2608.44, 46.33, 14.07),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Sandy North"] = {
    coords = vector3(1878.44, 3760.1, 32.94),
    spawn = vector4(1880.14, 3757.73, 32.93, 215.54),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Sandy Shores Station"] = {
    coords = vector3(1705.099976, 3855.002686, 34.870281),
    spawn = vector4(1705.099976, 3855.002686, 34.870281, 311.539459),
    distance = 15,
    type = "car",
    hideBlip = true, --Place holder until sandy is readded
    blip = {
      id = 50, -- Garage icon
      color = 3, -- Light blue/cyan color
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["North Vinewood Blvd"] = {
    coords = vector3(365.21, 295.65, 103.46),
    spawn = vector4(364.84, 289.73, 103.42, 164.23),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Grapeseed"] = {
    coords = vector3(1713.06, 4745.32, 41.96),
    spawn = vector4(1710.64, 4746.94, 41.95, 90.11),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Paleto Bay"] = {
    coords = vector3(107.32, 6611.77, 31.98),
    spawn = vector4(110.84, 6607.82, 31.86, 265.28),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Paleto Bay Station"] = {
    coords = vector3(-439.544525, 6032.511230, 30.994230),
    spawn = vector4(-442.07, 6034.36, 29.63, 312.73),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 0, -- Light blue/cyan color
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Boats"] = {
    coords = vector3(-795.15, -1510.79, 1.6),
    spawn = vector4(-798.66, -1507.73, -0.47, 102.23),
    distance = 20,
    type = "sea",
    hideBlip = false,
    blip = {
      id = 356,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Hangar"] = {
    coords = vector3(-1243.49, -3391.88, 13.94),
    spawn = vector4(-1258.4, -3394.56, 13.94, 328.23),
    distance = 20,
    type = "air",
    hideBlip = false,
    blip = {
      id = 359,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Quarry Parking"] = {
    coords = vector3(2561.91, 2745.6, 41.57),
    spawn = vector4(2565.41, 2749.76, 41.04, 242.45),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Garbage Depot Parking"] = {
    coords = vector3(-312.1, -1514.14, 26.89),
    spawn = vector4(-319.48, -1517.04, 26.19, 178.3),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Gruppe 6 Parking"] = {
    coords = vector3(5.85, -705.01, 31.48),
    spawn = vector4(2.03, -704.7, 30.64, 341.16),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["Casino Parking"] = {
    coords = vector3(915.08, 52.04, 79.9),
    spawn = vector4(918.23, 50.6, 79.64, 327.06),
    distance = 15,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
  ["LSIA Parking"] = {
    coords = vector3(-1214.12, -3382.85, 12.51),
    spawn = vector4(-1214.12, -3382.85, 12.51, 328.92),
    distance = 20,
    type = "car",
    hideBlip = false,
    blip = {
      id = 50,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
}

-- Private Garages
Config.PrivGarageCreateCommand = "privategarages"
Config.PrivGarageCreateJobRestriction = {"realestate"}
Config.PrivGarageEnableInteriors = true
Config.PrivGarageHideBlips = false
Config.PrivGarageBlip = {
  id = 357,
  color = 0,
  scale = 0.7
}

-- Job Garages
Config.JobGarageShowBlips = true
Config.JobGarageSetVehicleCommand = "setjobvehicle" -- admin only
Config.JobGarageRemoveVehicleCommand = "removejobvehicle" -- admin only
Config.JobGarageUniqueBlips = false
Config.JobGarageUniqueLocations = true
Config.JobGarageEnableInteriors = true
Config.JobGarageLocations = { -- IMPORTANT - Every garage name must be unique
  ["Mechanic"] = {
    coords = vector3(157.86, -3005.9, 7.03),
    spawn = vector4(165.26, -3014.94, 5.9, 268.8),
    distance = 15,
    job = {"mechanic"},
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Use owned vehicles that can anyone in this society can access - more details: https://docs.jgscripts.com/advanced-garages/job-and-gang-garages
  },
  ["LSPD Garage"] = {
    coords = vector3(443.250793, -982.024719, 25.700001),
    spawn = vector4(443.250793, -982.024719, 25.700001, 87.068977),
    distance = 15,
    job = {"police"}, -- LSPD job access
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 38, -- Blue color for police
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Use owned vehicles that officers can store/retrieve (department vehicles)
  },
  ["LSPD Personal Garage"] = {
    coords = vector3(439.070923, -1026.582642, 28.778353),
    spawn = vector4(439.070923, -1026.582642, 28.778353, 354.451477),
    distance = 5,
    job = {"police"}, -- LSPD job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 1,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Officers can only access their own personal vehicles here
  },
  ["LSPD Vespucci Garage"] = {
    coords = vector3(-1094.772095, -828.309082, 4.872134),
    spawn = vector4(-1094.772095, -828.309082, 4.872134, 38.158623),
    distance = 15,
    job = {"police"}, -- LSPD job access
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 38, -- Blue color for police
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles (requires /setjobvehicle command)
  },
  ["LSPD Vespucci Personal Garage"] = {
    coords = vector3(-1048.172241, -864.637024, 4.988384),
    spawn = vector4(-1048.172241, -864.637024, 4.988384, 238.529755),
    distance = 15,
    job = {"police"}, -- LSPD job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 1,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 29, g = 100, b = 153, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Officers can only access their own personal vehicles here
  },
  ["LSCSO Sandy Shores Garage"] = {
    coords = vector3(1743.339478, 3869.820068, 34.653969),
    spawn = vector4(1743.339478, 3869.820068, 34.653969, 111.792015),
    distance = 15,
    job = {"lscso"}, -- LSCSO job access
    type = "car",
    hideBlip = true, --Place holder until sandy is readded
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 17, -- Orange color for sheriff
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles (requires /setjobvehicle command)
  },
  ["LSCSO Sandy Shores Personal Garage"] = {
    coords = vector3(1695.098755, 3864.538086, 34.802799),
    spawn = vector4(1695.098755, 3864.538086, 34.802799, 301.995972),
    distance = 15,
    job = {"lscso"}, -- LSCSO job access only
    type = "car",
    hideBlip = true, --Place holder until sandy is readded
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 1,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Deputies can only access their own personal vehicles here
  },
  ["LSCSO Paleto Bay Garage"] = {
    coords = vector3(-476.212372, 5973.812988, 30.956102),
    spawn = vector4(-476.212372, 5973.812988, 30.956102, 132.366470),
    distance = 15,
    job = {"lscso"}, -- LSCSO job access
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 17, -- Orange color for sheriff
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles (requires /setjobvehicle command)
  },
  ["LSCSO Paleto Bay Helicopter Garage"] = {
    coords = vec3(-491.58, 6005.26, 31.75),
    spawn = vector4(-476.212372, 5973.812988, 30.956102, 132.366470),
    distance = 15,
    job = {"lscso"}, -- LSCSO job access
    type = "air",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 17, -- Orange color for sheriff
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles (requires /setjobvehicle command)
  },
  ["LSCSO Paleto Bay Personal Garage"] = {
    coords = vector3(-483.283783, 6034.272949, 30.994215),
    spawn = vector4(-483.283783, 6034.272949, 30.994215, 45.004631),
    distance = 15,
    job = {"lscso"}, -- LSCSO job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 1,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Deputies can only access their own personal vehicles here
  },
  ["SAFR Garage"] = {
    coords = vector3(326.470306, -588.223816, 28.796881),
    spawn = vector4(332.164948, -578.889526, 28.796869, 334.303955),
    distance = 15,
    job = {"safr"}, -- SAFR job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50,
      color = 1,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles
  },
  ["Davis Hospital Garage"] = {
    coords = vector3(328.135712, -1471.637939, 29.774790),
    spawn = vector4(328.135712, -1471.637939, 29.774790, 49.159130),
    distance = 15,
    job = {"safr"}, -- SAFR job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50,
      color = 1,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department vehicles
  },
    ["Department Store Personal Garage"] = {
    coords = vector3(-1578.61, -889.72, 8.63),
    spawn = vector4(-1578.61, -889.72, 8.63, 52.0),
    distance = 15,
    job = {"lscso", "police", "safr"}, -- LSCSO, LSPD, SAFR job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 1,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Deputies can only access their own personal vehicles here
  },
      ["Department Store Garage"] = {
    coords = vector3(-1658.12, -822.74, 8.51),
    spawn = vector4(-1658.12, -822.74, 8.51, 138.88),
    distance = 15,
    job = {"lscso", "police", "safr"}, -- LSCSO, LSPD, SAFR job access only
    type = "car",
    hideBlip = false,
    blip = {
      id = 50, -- Garage icon (car under roof)
      color = 38,
      scale = 0.5
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 140, b = 0, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "owned", -- Department owned vehicles
  },
}

-- Gang Garages (QBCore/Qbox only by default)
Config.GangEnableCustomESXIntegration = false -- Set to true if you've added a custom system to cl/sv-functions.lua
Config.GangGarageShowBlips = true
Config.GangGarageSetVehicleCommand = "setgangvehicle" -- admin only
Config.GangGarageRemoveVehicleCommand = "removegangvehicle" -- admin only
Config.GangGarageUniqueBlips = false
Config.GangGarageUniqueLocations = true
Config.GangGarageEnableInteriors = true
Config.GangGarageLocations = { -- IMPORTANT - Every garage name must be unique
  ["The Lost MC"] = {
    coords = vector3(439.18, -1518.48, 29.28),
    spawn = vector4(439.18, -1518.48, 29.28, 139.06),
    distance = 15,
    gang = {"lostmc"},
    type = "car",
    hideBlip = false,
    blip = {
      id = 357,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
    vehiclesType = "personal", -- Use personal vehicles
  },
}

-- Impound
Config.ImpoundCommand = "iv"
Config.ImpoundFeesSocietyFund = "police" -- Job name of society fund to pay impound fees into (optional)
Config.ImpoundShowBlips = true
Config.ImpoundUniqueBlips = false
Config.ImpoundTimeOptions = {0, 1, 4, 12, 24, 72, 168} -- in hours
Config.ImpoundLocations = { -- IMPORTANT - Every impound name must be unique
  ["LSPD Davis"] = {
    coords = vector3(410.8, -1626.26, 29.29),
    spawn = vector4(408.44, -1630.88, 29.29, 136.88),
    distance = 15,
    type = "car",
    job = {"police", "lscso"},
    hideBlip = false,
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },

  ["LSCSO Sandy"] = {
    coords = vector3(1649.71, 3789.61, 34.79),
    spawn = vector4(1643.66, 3798.36, 34.49, 216.16),
    distance = 15,
    type = "car",
    job = {"bcso"}, -- place holder until Sandy is back in
    hideBlip = true, -- place holder until sandy is back in
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },

  ["MRPD"] = {
    coords = vector3(412.4, -1004.48, 28.39),
    spawn = vector4(408.03, -1005.55, 27.85, 356.52),
    distance = 5,
    type = "car",
    job = {"police", "lscso"},
    hideBlip = false,
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },

  ["LSCSO Paleto"] = {
    coords = vector3(-447.88, 5970.46, 30.3),
    spawn = vector4(-455.07, 5962.43, 29.92, 224.69),
    distance = 5,
    type = "car",
    job = {"lscso", "police"},
    hideBlip = false,
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },

  ["Sandy Air Impound"] = {
    coords = vector3(1750.19, 3293.57, 40.11),
    spawn = vector4(1739.13, 3279.76, 40.76, 194.29),
    distance = 5,
    type = "air",
    job = {"lscso", "police"},
    hideBlip = false,
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },

  ["LSIA Air Impound"] = {
    coords = vector3(-968.71, -2968.21, 12.95),
    spawn = vector4(-964.87, -2983.66, 13.59, 60.13),
    distance = 5,
    type = "air",
    job = {"lscso", "police"},
    hideBlip = false,
    blip = {
      id = 68,
      color = 0,
      scale = 0.7
    },
    hideMarkers = true,
    markers = { id = 21, size = { x = 0.3, y = 0.3, z = 0.3 }, color = { r = 255, g = 255, b = 255, a = 120 }, bobUpAndDown = 0, faceCamera = 0, rotate = 1, drawOnEnts = 0 },
  },
}

-- Garage Interior
Config.GarageInteriorEntrance = vector4(227.96, -1003.06, -99.0, 0.0)
Config.GarageInteriorCameraCutscene = {
  vector4(227.96, -977.81, -98.99, 0.0), -- from
  vector4(227.96, -1006.96, -98.99, 0.0), -- to (this should be the entrance, or slightly further back from the entrance coords for a better final player transition)
}
Config.GarageInteriorVehiclePositions = {
  vector4(233.000000, -984.000000, -99.410004, 118.000000),
  vector4(233.000000, -988.500000, -99.410004, 118.000000),
  vector4(233.000000, -993.000000, -99.410004, 118.000000),
  vector4(233.000000, -997.500000, -99.410004, 118.000000),
  vector4(233.000000, -1002.000000, -99.410004, 118.000000),
  vector4(223.600006, -979.000000, -99.410004, 235.199997),
  vector4(223.600006, -983.599976, -99.410004, 235.199997),
  vector4(223.600006, -988.200012, -99.410004, 235.199997),
  vector4(223.600006, -992.799988, -99.410004, 235.199997),
  vector4(223.600006, -997.400024, -99.410004, 235.199997),
  vector4(223.600006, -1002.000000, -99.410004, 235.199997),
}

-- Staff Commands
Config.ChangeVehiclePlate = "vplate" -- admin only
Config.DeleteVehicleFromDB = "dvdb" -- admin only
Config.ReturnVehicleToGarage = "vreturn" -- admin only

-- Add your import vehicle's spawn name and desired label here for pretty vehicle names in the garage
-- This is mainly designed for ESX - if you are using QB, do this in shared!
Config.VehicleLabels = {
  ["spawnName"] = "Pretty Vehicle Label"
}

-- Block certain vehicles from being transferred to other players
Config.PlayerTransferBlacklist = {
  "spawnName"
}

Config.AutoRunSQL = true
Config.ReturnToPreviousRoutingBucket = false
Config.HideWatermark = false
Config.__v3Config = true
Config.Debug = false