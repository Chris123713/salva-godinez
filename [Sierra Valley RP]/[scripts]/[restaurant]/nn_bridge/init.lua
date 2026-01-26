bridge = {}

BridgeConfig = {}

BridgeConfig.Framework = 'qbx_core' -- qb-core, qbx_core, es_extended
BridgeConfig.Inventory = 'ox_inventory' -- ox_inventory, core_inventory, codem-inventory, origen_inventory, lj-inventory, ps-inventory, jpr-inventory, tgiann-inventory, qs-inventory, qb-inventory
BridgeConfig.Notification = 'ox_lib' -- ox_lib, qb-core, esx_notify, codem-notification
BridgeConfig.Target = 'ox_target' -- ox_target, qb-target
BridgeConfig.Progressbar = 'ox_lib' -- ox_lib, progressbar
BridgeConfig.Keys = 'qb-vehiclekeys' -- qb-vehiclekeys, qs-vehiclekeys, vehicles_keys, wasabi_carlock, cd_garage, okokGarage
BridgeConfig.Fuel = 'okokGasStation' -- LegacyFuel, cdn-fuel, ps-fuel, okokGasStation, ox_fuel, lj-fuel, hyon_gas_station, ND_Fuel, myFuel


---------------------------------------------------------------------------------------------------

while GetResourceState('nn_lib') ~= 'started' do 
    Wait(1000)
    print('^2 Waiting for script ^5nn_lib^0')
end

Lib = exports["nn_lib"]:GetLibObject()

local modules = {
    {
        module = "framework",
        resources = {
            client = {
                ["qb-core"] = "qb-core.lua",
                ["qbx_core"] = "qbx_core.lua",
                ["es_extended"] = "es_extended.lua",
            },
            server = {
                ["qb-core"] = "qb-core.lua",
                ["qbx_core"] = "qbx_core.lua",
                ["es_extended"] = "es_extended.lua",
            },
        },
    },
    {
        module = "inventory",
        resources = {
            server = {
                ["core_inventory"] = "core_inventory.lua",
                ["codem-inventory"] = "codem-inventory.lua",
                ["lj-inventory"] = "mixed.lua",
                ["ps-inventory"] = "mixed.lua",
                ["jpr-inventory"] = "mixed.lua",
                ["qs-inventory"] = "qs-inventory.lua",
                ["qb-inventory"] = "qb-inventory-v2.lua",
                ['qb-inventory-old'] = "mixed.lua",
                ["ox_inventory"] = "ox_inventory.lua",
                ["tgiann-inventory"] = "tgiann-inventory.lua",
                ["origen_inventory"] = "origen_inventory.lua",
            },
        },
    },
    {
        module = "fuel",
        resources = {
            client = {
                ["LegacyFuel"] = "mixed.lua",
                ["cdn-fuel"] = "mixed.lua",
                ["ps-fuel"] = "mixed.lua",
                ["okokGasStation"] = "mixed.lua",
                ["ox_fuel"] = "ox_fuel.lua",
                ["lj-fuel"] = "mixed.lua",
                ["hyon_gas_station"] = "mixed.lua",
                ["ND_Fuel"] = "mixed.lua",
                ["myFuel"] = "mixed.lua",
            },
        },
    },
    {
        module = "keys",
        resources = {
            client = {
                ["qb-vehiclekeys"] = "qb-vehiclekeys.lua",
                ["qs-vehiclekeys"] = "qs-vehiclekeys.lua",
                ["vehicles_keys"] = "vehicles_keys.lua",
                ["wasabi_carlock"] = "wasabi_carlock.lua",
                ["cd_garage"] = "cd_garage.lua",
                ["okokGarage"] = "okokGarage.lua",
            },
            server = {
                ["qb-vehiclekeys"] = "qb-vehiclekeys.lua",
                ["qs-vehiclekeys"] = "qs-vehiclekeys.lua",
                ["vehicles_keys"] = "vehicles_keys.lua",
                ["wasabi_carlock"] = "wasabi_carlock.lua",
                ["cd_garage"] = "cd_garage.lua",
                ["okokGarage"] = "okokGarage.lua",
            },
        },
    },
    {
        module = "notification",
        resources = {
            client = {
                ["ox_lib"] = "ox_lib.lua",
                ["qb-core"] = "qb-core.lua",
                ["esx_notify"] = "esx_notify.lua",
                ["codem-notification"] = "codem-notification.lua",
            },
            server = {
                ["ox_lib"] = "ox_lib.lua",
                ["qb-core"] = "qb-core.lua",
                ["esx_notify"] = "esx_notify.lua",
                ["codem-notification"] = "codem-notification.lua",
            },
        },
    },
    {
        module = "progressbar",
        resources = {
            client = {
                ["ox_lib"] = "ox_lib.lua",
                ["progressbar"] = "qb-core.lua",
            },
        },
    },
    {
        module = "target",
        resources = {
            client = {
                ["qb-target"] = "qb-target.lua",
                ["ox_target"] = "ox_target.lua",
            },
        },
    },
}

local resourceName = GetCurrentResourceName()
local isBridge = GetResourceMetadata(resourceName, "name") == "nn_bridge"
local version = GetResourceMetadata("nn_bridge", "version")
local isServer = IsDuplicityVersion()

local function loadModules(path)
    local file = LoadResourceFile("nn_bridge", path)

    if not file then
        print(("Failed to load file: ^1%s^0"):format(path), "error")
        return nil
    end
    
    local func, err = load(file, path)

    if not func then
        print(("An error occurred while loading the file: ^1%s^0"):format(path), "error")
        return nil
    end

    local status, result = pcall(func)

    if not status then
        print(("An error occurred in module ^1%s^0: ^1%s^0"):format(path, result), "error")
        return nil
    end
    return result
end

local function isResourceStarted(res)
    local state = GetResourceState(res)
    local t = 0.0

    while state == "starting" and t < 0.5 do
        state = GetResourceState(res)
        Wait(10)
        t = t + 0.01
    end

    return state == "started"
end

local function getResource(mod, side, res)
    local resType = type(res)

    if resType == "string" then
        local isLoaded = isResourceStarted(res)

        if isLoaded then return res, modules[mod].resources[side][res] end
    elseif resType == "table" then
        for checkRes, file in pairs(res) do
            local isLoaded = isResourceStarted(checkRes)

            if isLoaded then return checkRes, file end
        end
    end

    return nil, nil
end

local function injectModule(mod, side, res, file)
    local result = loadModules(mod .. "/" .. side .. "/" .. file)
    if result then
        bridge[mod] = result
        bridge[mod].name = res

        if mod == "target" then
            bridge[mod].cache = {}
        end
        
        return true
    end

    return false
end

local function getModules()
    bridge.language = GetConvar("nn_bridge:language", "en")

    for modId, tbl in ipairs(modules) do
        local moduleType = tbl.module
        local configKey = string.gsub(moduleType, "^%l", string.upper)
        while not BridgeConfig do Wait(100) end
        local configRes = BridgeConfig[configKey] or "none"
        
        for side, v in pairs(tbl.resources) do
            if (side == "server" and not isServer) or (side == "client" and isServer) then goto skip end
            
            local resource, file
            if configRes ~= "none" and modules[modId].resources[side][configRes] then
                resource, file = getResource(modId, side, configRes)
                if resource and file and injectModule(moduleType, side, configRes, file) then 
                    break 
                end
            end

            -- If we reach here, either no config was set, resource not found, or injection failed
            injectModule(moduleType, side, "none", "none.lua")
            break

            ::skip::
        end
    end
end

getModules()

if isBridge then
    print(("^2 nn_bridge (^5%s^0) started"):format(version), "success")

    for _, tbl in ipairs(modules) do
        local moduleType = tbl.module
        if bridge[moduleType] and bridge[moduleType].name ~= "none" then
            print(("^2 Module ^3%s^0: ^2%s^0 (from config)"):format(moduleType, bridge[moduleType].name), "success")
        elseif bridge[moduleType] and bridge[moduleType].name == "none" then
            print(("^2 Module ^3%s^0: ^1%s^0 (not detected, make sure to edit it in init.lua)"):format(moduleType, bridge[moduleType].name), "error")
        end
    end
end

if not isServer then
    AddEventHandler("onResourceStop", function(stoppedRes)
        if not stoppedRes or type(stoppedRes) ~= "string" then return end

        for entity, tbl in pairs(bridge.target.cache) do

            for i, v in ipairs(tbl.options) do
                if v.invoker == stoppedRes then
                    bridge.target.removeEntity(entity, v.name, v.invoker)
                    print(("^2 Removing Option ^3%s^0 from Target ^3%s^0 from resource ^5[%s]^0"):format(v.name, tostring(entity), v.invoker), "info")
                end
            end
        end
    end)
end