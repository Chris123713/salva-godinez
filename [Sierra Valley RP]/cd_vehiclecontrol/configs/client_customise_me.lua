--███████╗██████╗  █████╗ ███╗   ███╗███████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
--██╔════╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
--█████╗  ██████╔╝███████║██╔████╔██║█████╗  ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
--██╔══╝  ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
--██║     ██║  ██║██║  ██║██║ ╚═╝ ██║███████╗╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
--╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝


ESX, QBCore = nil, nil
JobData, on_duty = {}, true

CreateThread(function()
    if Config.Framework == 'esx' then
        while ESX == nil do
            pcall(function() ESX = exports[Config.FrameworkTriggers.resource_name]:getSharedObject() end)
            if ESX == nil then
                TriggerEvent(Config.FrameworkTriggers.main, function(obj) ESX = obj end)
            end
            Wait(100)
        end
        JobData = ESX.PlayerData.job or {}
        if JobData.onDuty ~= nil and Config.UseFrameworkDutySystem then on_duty = JobData.onDuty end 

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function(xPlayer)
            JobData = xPlayer.job or {}
            if JobData.onDuty ~= nil and Config.UseFrameworkDutySystem then on_duty = JobData.onDuty end
        end)

        RegisterNetEvent(Config.FrameworkTriggers.job)
        AddEventHandler(Config.FrameworkTriggers.job, function(job)
            JobData = job or {}
            if JobData.onDuty ~= nil and Config.UseFrameworkDutySystem then on_duty = JobData.onDuty end
        end)  

    elseif Config.Framework == 'qbcore' then
        while QBCore == nil do
            TriggerEvent(Config.FrameworkTriggers.main, function(obj) QBCore = obj end)
            if QBCore == nil then
                QBCore = exports[Config.FrameworkTriggers.resource_name]:GetCoreObject()
            end
            Wait(100)
        end
        JobData = QBCore.Functions.GetPlayerData().job or {}
        if JobData.onduty ~= nil and Config.UseFrameworkDutySystem then on_duty = JobData.onduty end

        RegisterNetEvent(Config.FrameworkTriggers.load)
        AddEventHandler(Config.FrameworkTriggers.load, function()
            JobData = QBCore.Functions.GetPlayerData().job or {}
            if JobData.onduty ~= nil and Config.UseFrameworkDutySystem then on_duty = JobData.onduty end
        end)

        RegisterNetEvent(Config.FrameworkTriggers.job)
        AddEventHandler(Config.FrameworkTriggers.job, function(JobInfo)
            JobData = JobInfo or {}
        end)

        RegisterNetEvent(Config.FrameworkTriggers.duty)
        AddEventHandler(Config.FrameworkTriggers.duty, function(boolean)
            if not Config.UseFrameworkDutySystem then return end
            on_duty = boolean
        end)

    elseif Config.Framework == 'other' then
        --add your framework code here.

    end
end)

function GetJob()
    if Config.Framework == 'esx' then
        while JobData.name == nil do Wait(0) end
        return JobData.name
    
    elseif Config.Framework == 'qbcore' then
        while JobData.name == nil do Wait(0) end
        return JobData.name

    elseif Config.Framework == 'other' then
        return 'unemployed' --return a players job name (string).
    end
end

function CheckJob(job_table)
    local job = GetJob()
    for c, d in pairs(job_table) do
        if d == job and on_duty then
            return true
        end
    end
    return false
end


--██╗  ██╗███████╗██╗   ██╗███████╗     █████╗ ███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
--██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝    ██╔══██╗████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
--█████╔╝ █████╗   ╚████╔╝ ███████╗    ███████║██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
--██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║    ██╔══██║██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
--██║  ██╗███████╗   ██║   ███████║    ██║  ██║██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
--╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝


CreateThread(function()
    while not Authorised do Wait(1000) end 

    RegisterKeyMapping(Config.OpenUI.command, L('chat_description'), 'keyboard', Config.OpenUI.key)
    TriggerEvent('chat:addSuggestion', '/'..Config.OpenUI.command, L('chat_description'))
    RegisterCommand(Config.OpenUI.command, function()
        NUI_actions('open')
    end)

end)


--██╗   ██╗███████╗██╗  ██╗██╗ ██████╗██╗     ███████╗    ██████╗ ███████╗██╗      █████╗ ████████╗███████╗██████╗ 
--██║   ██║██╔════╝██║  ██║██║██╔════╝██║     ██╔════╝    ██╔══██╗██╔════╝██║     ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
--██║   ██║█████╗  ███████║██║██║     ██║     █████╗      ██████╔╝█████╗  ██║     ███████║   ██║   █████╗  ██║  ██║
--╚██╗ ██╔╝██╔══╝  ██╔══██║██║██║     ██║     ██╔══╝      ██╔══██╗██╔══╝  ██║     ██╔══██║   ██║   ██╔══╝  ██║  ██║
-- ╚████╔╝ ███████╗██║  ██║██║╚██████╗███████╗███████╗    ██║  ██║███████╗███████╗██║  ██║   ██║   ███████╗██████╔╝
--  ╚═══╝  ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═════╝ 


function DoesPlayerHaveKeys(vehicle) 
    local plate = GetVehicleNumberPlateText(vehicle)
    
    if GetResourceState('cd_garage') == 'started' then --If you use cd_garage, and its keys feature this comes pre-configured.
        if exports['cd_garage']:GetConfig().VehicleKeys.ENABLE then
            return exports['cd_garage']:DoesPlayerHaveKeys(plate)
        end
    end
    
    --If you use a different keys script, you must return a boolean (true = player has keys / false = player does not have keys).
    return false --This will return false by default if you have not configured this part yet.
end

function ToggleVehiclelock(vehicle, state)
    if GetResourceState('cd_garage') == 'started' then --If you use cd_garage, and its keys feature this comes pre-configured.
        if exports['cd_garage']:GetConfig().VehicleKeys.ENABLE then
            TriggerEvent('cd_garage:ToggleVehicleLock')
        end
    end
    
    if state == 'lock' then --Lock the vehicle.
        --Trigger an event/export in your keys script to lock your vehicle.

    elseif state == 'unlock' then --Unlock the vehicle.
        --Trigger an event/export in your keys script to unlock your vehicle.
        
    end
end

function GetVehicleLockState(vehicle)
    local lock = GetVehicleDoorLockStatus(vehicle) --0 and 1 usually mean unlocked (https://docs.fivem.net/natives/?_0xD72CEF2).
    if lock == 0 or lock == 1 then
        return 'unlocked' --You must return 'unlocked' (string) if the vehicle is unlocked.
    else
        return 'locked' --You must return 'locked' (string) if the vehicle is locked.
    end
end

function EngineToggled(vehicle, state) --This is triggered when the engine is toggled on/off.
    if state == true then --Engine turned on.
        --Trigger any event/export you need to when the engine is turned on.

    elseif state == false then --Engine turned off.
        --Trigger any event/export you need to when the engine is turned off.
        
    end
end


--███╗   ██╗ ██████╗ ████████╗██╗███████╗██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--██╔██╗ ██║██║   ██║   ██║   ██║█████╗  ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--██║╚██╗██║██║   ██║   ██║   ██║██╔══╝  ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--██║ ╚████║╚██████╔╝   ██║   ██║██║     ██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝


function Notification(notif_type, message)
    if notif_type and message then
        if Config.Notification == 'esx' then
            ESX.ShowNotification(message)
        
        elseif Config.Notification == 'qbcore' then
            if notif_type == 1 then
                QBCore.Functions.Notify(message, 'success')
            elseif notif_type == 2 then
                QBCore.Functions.Notify(message, 'primary')
            elseif notif_type == 3 then
                QBCore.Functions.Notify(message, 'error')
            end
        
        elseif Config.Notification == 'cd_notifications' then
            if notif_type == 1 then
                TriggerEvent('cd_notifications:Add', {title =  L('vehicle_control'), message = message, type = 'success', options = {duration = 5}})
            elseif notif_type == 2 then
                TriggerEvent('cd_notifications:Add', {title =  L('vehicle_control'), message = message, type = 'inform', options = {duration = 5}})
            elseif notif_type == 3 then
                TriggerEvent('cd_notifications:Add', {title =  L('vehicle_control'), message = message, type = 'error', options = {duration = 5}})
            end

        elseif Config.Notification == 'okokNotify' then
            if notif_type == 1 then
                exports['okokNotify']:Alert(L('vehicle_control'), message, 5000, 'success')
            elseif notif_type == 2 then
                exports['okokNotify']:Alert(L('vehicle_control'), message, 5000, 'info')
            elseif notif_type == 3 then
                exports['okokNotify']:Alert(L('vehicle_control'), message, 5000, 'error')
            end
        
        elseif Config.Notification == 'ps-ui' then
            if notif_type == 1 then
                exports['ps-ui']:Notify(message, 'success', 5000)
            elseif notif_type == 2 then
                exports['ps-ui']:Notify(message, 'primary', 5000)
            elseif notif_type == 3 then
                exports['ps-ui']:Notify(message, 'error', 5000)
            end
        
        elseif Config.Notification == 'ox_lib' then
            if notif_type == 1 then
                lib.notify({title = L('vehicle_control'), description = message, type = 'success'})
            elseif notif_type == 2 then
                lib.notify({title = L('vehicle_control'), description = message, type = 'inform'})
            elseif notif_type == 3 then
                lib.notify({title = L('vehicle_control'), description = message, type = 'error'})
            end

        elseif Config.Notification == 'chat' then
            TriggerEvent('chatMessage', message)
            
        elseif Config.Notification == 'other' then
            --add your own notification.
            
        end
    end
end


--██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


if Config.Debug then
    local function Debug()
        while not Authorised do Wait(1000) end
        print('^6-----------------------^0')
        print('^1CODESIGN DEBUG^0')
        print(string.format('^6Resource Name:^0 %s', GetCurrentResourceName()))
        print(string.format('^6Framework:^0 %s', Config.Framework))
        print(string.format('^6Notification:^0 %s', Config.Notification))
        print(string.format('^6Language:^0 %s', Config.Language))
        if Config.Framework == 'esx' or Config.Framework == 'qbcore' or Config.Framework == 'other' then
            while JobData.name == nil do Wait(0) end
            print(string.format('^6Job Name:^0 %s', GetJob()))
        end
        print(string.format('^6Use Framework Duty System:^0 %s', Config.UseFrameworkDutySystem))
        print(string.format('^6On Duty:^0 %s', on_duty))
        print('^6-----------------------^0')
    end

    CreateThread(function()
        Wait(3000)
        Debug()
    end)

    RegisterCommand('debug_vehcontrol', function()
        Debug()
    end)
end