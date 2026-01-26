local config = require 'config'

-- Only run if blips are enabled
if not config.unitBlips.enabled then return end

-- Local state
local unitBlips = {}  -- [serverId] = blipHandle
local isViewer = false
local blipUpdateThread = nil

-- =====================
-- HELPER FUNCTIONS
-- =====================

local function CanViewBlips()
    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job then return false end

    local jobName = playerData.job.name
    for _, viewerJob in ipairs(config.unitBlips.viewerJobs) do
        if viewerJob == jobName then
            return true
        end
    end
    return false
end

local function RemoveAllBlips()
    for serverId, blip in pairs(unitBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    unitBlips = {}
end

local function CreateOrUpdateBlip(serverId, data)
    local myId = GetPlayerServerId(PlayerId())
    if serverId == myId then return end -- Don't show own blip

    local blipConfig = config.unitBlips.blips[data.job]
    if not blipConfig then return end

    -- Determine sprite, color, and scale based on state
    local sprite, color, scale

    if data.sirenOn and blipConfig.spriteLightsOn then
        -- Lights/siren on - use emergency blip
        sprite = blipConfig.spriteLightsOn
        color = blipConfig.colorLightsOn or blipConfig.color
        scale = blipConfig.scaleLightsOn or blipConfig.scale
    elseif data.inVehicle and blipConfig.spriteInVehicle then
        -- In vehicle but no lights
        sprite = blipConfig.spriteInVehicle
        color = blipConfig.color
        scale = blipConfig.scale
    else
        -- On foot
        sprite = blipConfig.sprite
        color = blipConfig.color
        scale = blipConfig.scale
    end

    -- Build blip name
    local blipName = blipConfig.name
    if config.unitBlips.showRank and data.rank then
        blipName = data.rank .. ' - ' .. blipName
    end
    if config.unitBlips.showCallsign and data.callsign and data.callsign ~= '' then
        blipName = blipName .. ' (' .. data.callsign .. ')'
    end
    if data.name then
        blipName = blipName .. ' - ' .. data.name
    end

    -- Add status indicator to name
    if data.sirenOn then
        blipName = blipName .. ' [CODE 3]'
    end

    -- Check if blip exists
    if unitBlips[serverId] and DoesBlipExist(unitBlips[serverId]) then
        local blip = unitBlips[serverId]

        -- Update position
        SetBlipCoords(blip, data.coords.x, data.coords.y, data.coords.z)

        -- Update sprite if changed (for siren state changes)
        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, color)
        SetBlipScale(blip, scale)

        -- Update name
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipName)
        EndTextCommandSetBlipName(blip)

        -- Flash effect when siren is on
        if data.sirenOn then
            SetBlipFlashes(blip, true)
            SetBlipFlashInterval(blip, 500)
        else
            SetBlipFlashes(blip, false)
        end
    else
        -- Create new blip
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, color)
        SetBlipScale(blip, scale)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipName)
        EndTextCommandSetBlipName(blip)

        -- Flash if siren on
        if data.sirenOn then
            SetBlipFlashes(blip, true)
            SetBlipFlashInterval(blip, 500)
        end

        unitBlips[serverId] = blip
    end
end

local function UpdateBlips()
    if not isViewer then return end

    -- Request unit positions from server
    local units = lib.callback.await('sv_police_actions:getUnitPositions', false)

    if not units then
        RemoveAllBlips()
        return
    end

    -- Track which units we received
    local receivedIds = {}

    -- Create/update blips for each unit
    for serverId, data in pairs(units) do
        receivedIds[serverId] = true
        CreateOrUpdateBlip(serverId, data)
    end

    -- Remove blips for units no longer in list
    for serverId, blip in pairs(unitBlips) do
        if not receivedIds[serverId] then
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
            unitBlips[serverId] = nil
        end
    end
end

local function StartBlipThread()
    if blipUpdateThread then return end

    blipUpdateThread = CreateThread(function()
        while isViewer do
            UpdateBlips()
            Wait(config.unitBlips.updateInterval)
        end

        -- Cleanup when no longer a viewer
        RemoveAllBlips()
        blipUpdateThread = nil
    end)
end

local function CheckViewerStatus()
    local wasViewer = isViewer
    isViewer = CanViewBlips()

    if isViewer and not wasViewer then
        -- Became a viewer - start blip updates
        StartBlipThread()
    elseif not isViewer and wasViewer then
        -- No longer a viewer - blips will be cleaned up by thread
    end
end

-- =====================
-- EVENT HANDLERS
-- =====================

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    CheckViewerStatus()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    CheckViewerStatus()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isViewer = false
    RemoveAllBlips()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    CheckViewerStatus()
end)

-- =====================
-- CLEANUP
-- =====================

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    RemoveAllBlips()
end)

-- =====================
-- DEBUG
-- =====================

if config.debug then
    RegisterCommand('blips:debug', function()
        print('^3[DEBUG]^7 isViewer:', isViewer)
        print('^3[DEBUG]^7 unitBlips count:', #unitBlips)
        for id, blip in pairs(unitBlips) do
            print(('  - Server ID %d: Blip %d (exists: %s)'):format(id, blip, tostring(DoesBlipExist(blip))))
        end
    end, false)

    RegisterCommand('blips:refresh', function()
        UpdateBlips()
        print('^2[DEBUG]^7 Blips refreshed')
    end, false)
end
