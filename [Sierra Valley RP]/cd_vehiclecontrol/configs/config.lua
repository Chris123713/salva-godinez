Config = {}
function L(cd) if Locales[Config.Language][cd] then return Locales[Config.Language][cd] else print('Locale is nil ('..cd..')') end end
--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


--WHAT DOES 'auto_detect' DO?
--The 'auto_detect' feature automatically identifies your framework and applies the appropriate default settings.

Config.Framework = 'auto_detect' --[ 'auto_detect' / 'other' ]   If you select 'auto_detect', only ESX, QBCore and Standalone frameworks will be detected. Use 'other' for custom frameworks.
Config.Notification = 'auto_detect' --[ 'auto_detect' / 'other' ]   If you select 'auto_detect', only ESX, QBCore, cd_notifications, okokNotify, ps-ui and ox_lib notifications will be detected. Use 'other' for custom notification resources.
Config.Language = 'EN' --[ 'EN' / 'DE' / 'NL' ]   You can add your own locales to Locales.lua, but be sure to update the Config.Language to match it.

Config.FrameworkTriggers = {
    esx = { --If you have modified the default event names in the es_extended resource, change them here.
        resource_name = 'es_extended',
        main = 'esx:getSharedObject',
        load = 'esx:playerLoaded',
        job = 'esx:setJob'
    },
    qbcore = { --If you have modified the default event names in the qb-core resource, change them here.
        resource_name = 'qb-core',
        main = 'QBCore:GetObject',
        load = 'QBCore:Client:OnPlayerLoaded',
        job = 'QBCore:Client:OnJobUpdate',
        duty = 'QBCore:Client:SetDuty'
    }
}


--██╗███╗   ███╗██████╗  ██████╗ ██████╗ ████████╗ █████╗ ███╗   ██╗████████╗
--██║████╗ ████║██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║╚══██╔══╝
--██║██╔████╔██║██████╔╝██║   ██║██████╔╝   ██║   ███████║██╔██╗ ██║   ██║   
--██║██║╚██╔╝██║██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║╚██╗██║   ██║   
--██║██║ ╚═╝ ██║██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║ ╚████║   ██║   
--╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝


Config.Debug = false --To enable debug prints.
Config.UseFrameworkDutySystem = false --Do you want to use your frameworks (esx/qbcore) built-in duty system?


--███╗   ███╗ █████╗ ██╗███╗   ██╗
--████╗ ████║██╔══██╗██║████╗  ██║
--██╔████╔██║███████║██║██╔██╗ ██║
--██║╚██╔╝██║██╔══██║██║██║╚██╗██║
--██║ ╚═╝ ██║██║  ██║██║██║ ╚████║
--╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝


Config.Liveries = {
    ENABLE = true, --Do you want the vehicle liveries feature to be enabled on the UI? (if set to false none of the options below will work).

    Job_Restricted = {
        ENABLE = false, ----Do you want the vehicle liveries feature to only be usable by certain jobs?
        job_table = {'police', 'ambulance', } --If the line above^ is set to true, choose which jobs can use this.
    },

    Location_Restricted = {
        ENABLE = false, --Do you want the vehicle liveries feature to only be usable within a radius of certain locations?
        location_table = { --If the line above^ is set to true, choose which locations can use this.
            [1] = {coords = vec3(450.19, -1021.18, 28.4), radius = 20}, --MRPD
            --[2] = {coords = vec3(0.0, 0.0, 0.0), radius = 5},
        } 
    },

    Vehicle_Restricted = {
        ENABLE = false, --Do you want the vehicle liveries feature to only be usable by certain vehicles?
        vehicle_table = {'police', 'ambulance', } --If the line above^ is set to true, choose which vehicles can use this.
    },
}

Config.Extras = {
    ENABLE = true, --Do you want the vehicle extras feature to be enabled on the UI? (if set to false none of the options below will work).
    extras_workaround_fix = true, --Sometimes extras such as lightbars will only be visible if the car is fully repaired first. So to fix this we repair the car and then re-aply the damage - READ MORE HERE https://docs.codesign.pro/paid-scripts/vehicle-control#common-issues.
    max_extras = 20, --Whats the maximum amount of extras your vehicles have?
    disable_extras_in_heli = false, --Do you want to disable the extras feature for helicopters? (this was requested due to people removing the helis blades lol).

    Job_Restricted = {
        ENABLE = false, --Do you want the vehicle extras feature to only be usable by certain jobs?
        job_table = {'police', 'ambulance', } --If the line above^ is set to true, choose which jobs can use this.
    },

    Location_Restricted = {
        ENABLE = false, ----Do you want the vehicle extras feature to only be usable within a radius of certain locations?
        location_table = { --If the line above^ is set to true, choose which locations can use this.
            [1] = {coords = vec3(450.19, -1021.18, 28.4), radius = 20}, --MRPD
            --[2] = {coords = vec3(0.0, 0.0, 0.0), radius = 5},
        } 
    },

    Vehicle_Restricted = {
        ENABLE = false, --Do you want the vehicle extras feature to only be usable by certain vehicles?
        vehicle_table = {'police', 'ambulance', }  --If the line above^ is set to true, choose which vehicles can use this.
    }
}

Config.Neons = {
    ENABLE = true, --Do you want to allow your players to toggle neon lights using the UI?
    blacklisted_colours = { --By default all cars have neons enabled and have default colours, so we will disable the default colours and only allow custom colours.
        {r = 255, g = 0, b = 255}, --purple (one of the default colours).
        {r = 255, g = 255, b = 255}, --white (one of the default colours).
        --{r = 0, g = 0, b = 0}, --You can add more here if you need.
    }
}

Config.VehicleLock = {
    ENABLE = false, --Do you want to allow players to lock/unlock vehicles and view if the vehicle is locked? (this is not a vehicle lock system, it depends on external lock scripts).
    disable_doors_when_locked = true --Do you want to disable opening the doors when the vehicle is locked?
}

Config.DisabledKeys = { --A list of keys which are disabled while you interact with the UI.
    1,2,21,24,25,47,58,75,106,140,141,142,143,245,257,263,264,
}

Config.BlacklistedVehicleClass = { --A list of vehicle classes which can't use the UI. (https://docs.fivem.net/natives/?_0x29439776AAA00A62).
    13, --bicycles
}

Config.IndicatorSync = false --Do you want indicator's to be synced server side to all players? (this will consume slightly more resources).
Config.PreventAutoSeatShuffle = true --Do you want to prevent the auto seat shuffle in the vehicle? (This will consume more resources).


--██╗  ██╗███████╗██╗   ██╗███████╗     █████╗ ███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
--██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝    ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
--█████╔╝ █████╗   ╚████╔╝ ███████╗    ███████║██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
--██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║    ██╔══██║██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
--██║  ██╗███████╗   ██║   ███████║    ██║  ██║██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
--╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝


Config.OpenUI = {
    ENABLE = true, --Do you want to allow player's open the vehicle control UI?
    command = 'vehcontrol', --The chat command.
    key = 'k' --The keypress.
}


-- ██████╗ ████████╗██╗  ██╗███████╗██████╗ 
--██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
--██║   ██║   ██║   ███████║█████╗  ██████╔╝
--██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
--╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
-- ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


function Round(cd) return math.floor(cd+0.5) end
function Trim(cd) return cd:gsub('%s+', '') end


-- █████╗ ██╗   ██╗████████╗ ██████╗     ██████╗ ███████╗████████╗███████╗ ██████╗████████╗
--██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝
--███████║██║   ██║   ██║   ██║   ██║    ██║  ██║█████╗     ██║   █████╗  ██║        ██║   
--██╔══██║██║   ██║   ██║   ██║   ██║    ██║  ██║██╔══╝     ██║   ██╔══╝  ██║        ██║   
--██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██████╔╝███████╗   ██║   ███████╗╚██████╗   ██║   
--╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝   


-----DO NOT TOUCH ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.-----
if Config.Framework == 'auto_detect' then
    if GetResourceState(Config.FrameworkTriggers.esx.resource_name) == 'started' then
        Config.Framework = 'esx'
    elseif GetResourceState(Config.FrameworkTriggers.qbcore.resource_name) == 'started' then
        Config.Framework = 'qbcore'
    else
        Config.Framework = 'standalone'
    end
    if Config.Framework == 'esx' or Config.Framework == 'qbcore' then
        for c, d in pairs(Config.FrameworkTriggers[Config.Framework]) do
            Config.FrameworkTriggers[c] = d
        end
        Config.FrameworkTriggers.esx, Config.FrameworkTriggers.qbcore = nil, nil
    end
end

if Config.Notification == 'auto_detect' then
    if GetResourceState('cd_notifications') == 'started' then
        Config.Notification = 'cd_notifications'
    elseif GetResourceState('okokNotify') == 'started' then
        Config.Notification = 'okokNotify'
    elseif GetResourceState('ps-ui') == 'started' then
        Config.Notification = 'ps-ui'
    elseif GetResourceState('ox_lib') == 'started' then
        Config.Notification = 'ox_lib'
    else
        if Config.Framework == 'esx' or Config.Framework == 'qbcore' then
            Config.Notification = Config.Framework
        else
            Config.Notification = 'chat'
        end
    end
end
-----DO NOT TOUCH ANYTHING ABOVE THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.-----