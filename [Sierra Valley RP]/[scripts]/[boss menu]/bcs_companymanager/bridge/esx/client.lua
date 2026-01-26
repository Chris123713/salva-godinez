local isESX, resourceName = Utils.CheckFramework("ESX")
if not isESX then return end

PlayerData = {}
PlayerLoaded = false

local success, obj = pcall(function(...)
    local ESX = exports[resourceName]:getSharedObject()
    if ESX.PlayerLoaded then
        PlayerData = ESX.GetPlayerData()
        PlayerLoaded = true
    end
    return ESX
end)


if not success then
    Utils.DebugWarn('Failed to get shared object from ESX')
    return
end

ESX = obj
FrameworkLoaded = true

RegisterNetEvent('esx:setJob', function(job)
    if source == '' then return end
    PlayerData.job = job
end)

RegisterNetEvent('esx:playerLoaded', function(data)
    if source == '' then return end
    PlayerLoaded = true
    PlayerData = data
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    PlayerLoaded = false
end)

if Config.Mugshot then
    AddEventHandler('esx:onPlayerSpawn', function()
        Wait(15000)
        if Utils.IsResourceStarted('mugshot') then
            exports['mugshot']:getMugshotUrl(PlayerPedId(), function(url)
                TriggerServerEvent('bcs_companymanager:saveMugShot', url)
            end)
        elseif Utils.IsResourceStarted('MugShotBase64') then
            TriggerServerEvent('bcs_companymanager:saveMugShot',
                exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false))
        end
    end)
end

function Framework.HelpText(show, message)
    if show then
        -- lib.showTextUI(message)
        ESX.TextUI(message)
        -- TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
    else
        -- lib.hideTextUI()
        ESX.HideUI()
        -- TriggerEvent('cd_drawtextui:HideUI')
    end
end

function Framework.Notify(title, message, type, duration)
    ESX.ShowNotification(message)
    -- exports['bcs_hud']:SendAlert(title, message, type, duration)

    -- For mythic notify example
    -- if type == 'info' then
    --     type = 'inform'
    -- end
    -- exports['mythic_notify']:SendAlert(type, message)
    -- lib.notify({ title = title, description = message, type = type, duration = duration })
end
