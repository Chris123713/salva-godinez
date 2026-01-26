local isQb, resourceName = Utils.CheckFramework("QB")
if not isQb then return end
PlayerData = {}
PlayerLoaded = false

local function ReOrderJob(job)
    return {
        label = job.label,
        grade_label = job.grade.name,
        name = job.name,
        grade = job.grade.level,
        salary = job.grade.payment
    }
end

local success, obj = pcall(function (...)
    local qb = exports[resourceName]:GetCoreObject()
    PlayerLoaded = LocalPlayer.state['isLoggedIn']

    if PlayerLoaded then
        PlayerData = qb.Functions.GetPlayerData()
        PlayerData.job = ReOrderJob(PlayerData.job)
        PlayerData.gang = ReOrderJob(PlayerData.gang)
        PlayerData.name = ('%s %s'):format(PlayerData.charinfo.firstname, PlayerData.charinfo.lastname)
    end
    return qb
end)

if not success then
    Utils.DebugWarn('Failed to get core object from QBCORE')
    return
end

QBCore = obj
FrameworkLoaded = true

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    PlayerData.job = ReOrderJob(PlayerData.job)
    PlayerData.gang = ReOrderJob(PlayerData.gang)
    PlayerData.name = ('%s %s'):format(PlayerData.charinfo.firstname, PlayerData.charinfo.lastname)
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerLoaded = false
end)

if Config.Mugshot then
    AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
        Wait(15000)
        if GetResourceState('mugshot') == 'started' then
            exports['mugshot']:getMugshotUrl(PlayerPedId(), function(url)
                TriggerServerEvent('bcs_companymanager:saveMugShot', url)
            end)
        elseif GetResourceState('MugShotBase64') == 'started' then
            TriggerServerEvent('bcs_companymanager:saveMugShot',
                exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), false))
        end
    end)
end

function Framework.HelpText(show, message)
    if show then
        -- lib.showTextUI(message)
        exports['qb-core']:DrawText(message)
        -- TriggerEvent('cd_drawtextui:ShowUI', 'show', text)
    else
        -- lib.hideTextUI()
        exports['qb-core']:HideText()
        -- TriggerEvent('cd_drawtextui:HideUI')
    end
end

function Framework.Notify(title, message, type, duration)
    -- ===== QB uncomment below =====
    if type == 'info' or type == 'warning' then
        type = 'primary'
    end
    QBCore.Functions.Notify(message, type, duration)
    -- ===== QB uncomment above ======
    -- exports['bcs_hud']:SendAlert(title, message, type, duration)

    -- For mythic notify example
    -- if type == 'info' then
    --     type = 'inform'
    -- end
    -- exports['mythic_notify']:SendAlert(type, message)
    -- lib.notify({ title = title, description = message, type = type, duration = duration })
end