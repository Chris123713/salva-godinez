local config = require 'config'

-- Player state
local PlayerData = {}
local isPolice = false -- Cached police status
local targetOptionsRegistered = false

local playerState = {
    isCuffed = false,
    isHardCuffed = false,
    isEscorted = false,
    isEscorting = false,
    escortTarget = nil,
    escortedBy = nil,
    lastTackle = 0
}

-- =====================
-- PLAYER DATA MANAGEMENT
-- =====================

local function UpdatePoliceStatus()
    if not PlayerData.job then
        isPolice = false
        return
    end
    isPolice = IsPoliceJob(config.policeJobs, PlayerData.job.name)
end

local function UpdatePlayerData()
    PlayerData = exports.qbx_core:GetPlayerData() or {}
    UpdatePoliceStatus()
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    UpdatePlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    UpdatePlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isPolice = false
    playerState = {
        isCuffed = false,
        isHardCuffed = false,
        isEscorted = false,
        isEscorting = false,
        escortTarget = nil,
        escortedBy = nil,
        lastTackle = 0
    }
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    local wasPolice = isPolice
    PlayerData.job = job
    UpdatePoliceStatus()

    -- Handle target options based on job change
    if isPolice and not wasPolice then
        -- Became police - register options
        RegisterTargetOptions()
    elseif not isPolice and wasPolice then
        -- Left police - remove options
        RemoveTargetOptions()
    end
end)

-- =====================
-- HELPER FUNCTIONS
-- =====================

local function IsPolice()
    return isPolice
end

local function HasRequiredGrade(action)
    if not PlayerData.job then return false end
    local required = config.gradeRequirements[action] or 0
    return (PlayerData.job.grade or 0) >= required
end

local function PlayAnim(animConfig, ped)
    ped = ped or PlayerPedId()
    if not animConfig then return end

    lib.requestAnimDict(animConfig.dict)
    TaskPlayAnim(ped, animConfig.dict, animConfig.anim, 8.0, -8.0, animConfig.duration, 49, 0, false, false, false)
end

local function Notify(msg, type)
    lib.notify({
        title = 'Police',
        description = msg,
        type = type or 'inform'
    })
end

-- =====================
-- CUFF SYSTEM
-- =====================

local function ApplyCuffEffects(isHard)
    local ped = PlayerPedId()

    -- Set walking style
    local walkStyle = isHard and config.cuffs.hardCuffWalkStyle or config.cuffs.softCuffWalkStyle
    lib.requestAnimSet(walkStyle)
    SetPedMovementClipset(ped, walkStyle, 1.0)
end

local function RemoveCuffEffects()
    local ped = PlayerPedId()
    ResetPedMovementClipset(ped, 1.0)
end

RegisterNetEvent('sv_police_actions:client:setCuffed', function(isCuffed, isHard)
    playerState.isCuffed = isCuffed
    playerState.isHardCuffed = isHard or false

    if isCuffed then
        ApplyCuffEffects(isHard)
        Notify(isHard and config.notifications.hardcuffed or config.notifications.cuffed, 'warning')
    else
        RemoveCuffEffects()
        Notify(config.notifications.uncuffed, 'success')
    end
end)

-- Cuff control loop - only active when cuffed
CreateThread(function()
    while true do
        if playerState.isCuffed and config.cuffs.preventActions then
            -- When cuffed, run every frame to disable controls
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 47, true)  -- Weapon
            DisableControlAction(0, 58, true)  -- Weapon
            DisableControlAction(0, 263, true) -- Melee
            DisableControlAction(0, 264, true) -- Melee
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 140, true) -- Melee light
            DisableControlAction(0, 141, true) -- Melee heavy
            DisableControlAction(0, 142, true) -- Melee alternate
            DisableControlAction(0, 143, true) -- Melee block
            Wait(0)
        else
            -- Not cuffed - sleep longer
            Wait(1000)
        end
    end
end)

-- =====================
-- ESCORT SYSTEM
-- =====================

RegisterNetEvent('sv_police_actions:client:setEscorted', function(isEscorted, escorterId)
    playerState.isEscorted = isEscorted
    playerState.escortedBy = escorterId

    if isEscorted then
        Notify(config.notifications.escorted, 'warning')
    else
        Notify(config.notifications.unescorted, 'inform')
    end
end)

RegisterNetEvent('sv_police_actions:client:setEscorting', function(isEscorting, targetId)
    playerState.isEscorting = isEscorting
    playerState.escortTarget = targetId
end)

-- Escort follow loop - only active when being escorted
CreateThread(function()
    while true do
        if playerState.isEscorted and playerState.escortedBy then
            local escorterPed = GetPlayerPed(GetPlayerFromServerId(playerState.escortedBy))
            if DoesEntityExist(escorterPed) then
                local heading = GetEntityHeading(escorterPed)

                -- Calculate position behind escorter
                local offset = GetOffsetFromEntityInWorldCoords(escorterPed, 0.0, -0.5, 0.0)

                local ped = PlayerPedId()
                if #(GetEntityCoords(ped) - offset) > config.distances.escort then
                    TaskGoToEntity(ped, escorterPed, -1, 1.0, 2.0, 0, 0)
                end

                SetEntityHeading(ped, heading)
            end
            Wait(100)
        else
            -- Not being escorted - sleep longer
            Wait(1000)
        end
    end
end)

-- =====================
-- TACKLE SYSTEM
-- =====================

local function CanTackle()
    if not config.tackle.enabled then return false end
    if not isPolice then return false end
    if not HasRequiredGrade('tackle') then return false end

    local now = GetGameTimer()
    if (now - playerState.lastTackle) < config.tackle.cooldown then
        return false
    end

    local ped = PlayerPedId()
    local speed = GetEntitySpeed(ped)
    return speed <= config.tackle.maxSpeed and IsPedOnFoot(ped) and not IsPedRagdoll(ped)
end

RegisterNetEvent('sv_police_actions:client:tackled', function()
    local ped = PlayerPedId()
    SetPedToRagdoll(ped, config.tackle.stunDuration, config.tackle.stunDuration, 0, true, true, false)
    Notify(config.notifications.tackled, 'error')
end)

-- =====================
-- VEHICLE INTERACTIONS
-- =====================

RegisterNetEvent('sv_police_actions:client:putInVehicle', function(vehicleNet)
    local vehicle = NetToVeh(vehicleNet)
    if not DoesEntityExist(vehicle) then return end

    -- Try back seats first (2, 1), then any free seat
    local seat = nil
    if IsVehicleSeatFree(vehicle, 2) then
        seat = 2
    elseif IsVehicleSeatFree(vehicle, 1) then
        seat = 1
    else
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        for i = 0, maxSeats - 1 do
            if IsVehicleSeatFree(vehicle, i) then
                seat = i
                break
            end
        end
    end

    if seat then
        local ped = PlayerPedId()
        TaskWarpPedIntoVehicle(ped, vehicle, seat)
        Notify(config.notifications.putInVehicle, 'warning')
    end
end)

RegisterNetEvent('sv_police_actions:client:removeFromVehicle', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped, false), 16)
        Notify(config.notifications.removedFromVehicle, 'inform')
    end
end)

-- =====================
-- FRISK/SEARCH/ID RESULTS
-- =====================

-- Target receives frisk - play animation
RegisterNetEvent('sv_police_actions:client:beingFrisked', function(officerId)
    local ped = PlayerPedId()
    local animConfig = config.animations.friskTarget

    -- Play hands up animation
    lib.requestAnimDict(animConfig.dict)
    TaskPlayAnim(ped, animConfig.dict, animConfig.anim, 8.0, -8.0, animConfig.duration, 49, 0, false, false, false)

    -- Show notification
    Notify('Stay still - you are being frisked', 'warning')
end)

-- Target feels something during frisk
RegisterNetEvent('sv_police_actions:client:friskFeeling', function(data)
    -- Notify target what they felt the officer discover
    if data.feltWeapon then
        Notify('The officer felt something on your person...', 'warning')
    else
        Notify('The officer patted you down', 'inform')
    end
end)

-- Officer receives frisk results
RegisterNetEvent('sv_police_actions:client:showFriskResults', function(data)
    local content = ''

    -- Status
    if data.isCuffed then
        content = content .. 'Subject is **restrained**\n\n'
    else
        content = content .. 'Subject is **not restrained**\n\n'
    end

    -- What the officer felt
    content = content .. '**Pat-down Results:**\n'

    if data.hasWeaponEquipped then
        content = content .. '- 🔫 **WEAPON IN HAND** - Armed and dangerous!\n'
    end

    if data.concealedWeapons and #data.concealedWeapons > 0 then
        content = content .. '- 🔪 Felt **hard objects** consistent with weapons:\n'
        for _, weapon in ipairs(data.concealedWeapons) do
            content = content .. ('  - %s\n'):format(weapon)
        end
    end

    if data.suspiciousItems and #data.suspiciousItems > 0 then
        content = content .. '- 📦 Felt **unusual bulges** (possible contraband):\n'
        for _, item in ipairs(data.suspiciousItems) do
            content = content .. ('  - %s\n'):format(item)
        end
    end

    if (not data.concealedWeapons or #data.concealedWeapons == 0) and
       (not data.suspiciousItems or #data.suspiciousItems == 0) and
       not data.hasWeaponEquipped then
        content = content .. '- Nothing suspicious felt\n'
    end

    content = content .. '\n*A frisk only reveals what can be felt through clothing. Use Search for a full inventory check.*'

    lib.alertDialog({
        header = 'Frisk Results',
        content = content,
        centered = true
    })
end)

RegisterNetEvent('sv_police_actions:client:showSearchResults', function(data)
    if not data.items or #data.items == 0 then
        lib.alertDialog({
            header = 'Search Results',
            content = 'No items found on person.',
            centered = true
        })
        return
    end

    local content = ''
    for _, item in ipairs(data.items) do
        content = content .. ('- %s x%d\n'):format(item.label or item.name, item.count or 1)
    end

    lib.alertDialog({
        header = 'Search Results - ' .. (data.name or 'Unknown'),
        content = content,
        centered = true
    })
end)

RegisterNetEvent('sv_police_actions:client:showIdResults', function(data)
    local content = ''

    content = content .. ('**Name:** %s %s\n'):format(data.firstname or 'Unknown', data.lastname or '')
    content = content .. ('**DOB:** %s\n'):format(data.dob or 'Unknown')
    content = content .. ('**Gender:** %s\n'):format(data.gender == 0 and 'Male' or 'Female')
    content = content .. ('**Citizen ID:** %s\n'):format(data.citizenid or 'Unknown')

    if data.licenses then
        content = content .. '\n**Licenses:**\n'
        for license, hasIt in pairs(data.licenses) do
            content = content .. ('- %s: %s\n'):format(license, hasIt and 'Valid' or 'None')
        end
    end

    if data.warrants and #data.warrants > 0 then
        content = content .. '\n**ACTIVE WARRANTS:**\n'
        for _, warrant in ipairs(data.warrants) do
            content = content .. ('- %s\n'):format(warrant)
        end
    end

    lib.alertDialog({
        header = 'ID Check Results',
        content = content,
        centered = true
    })
end)

-- =====================
-- OX_TARGET REGISTRATION
-- =====================

-- Target option names for cleanup
local targetOptionNames = {
    'sv_police:frisk',
    'sv_police:softcuff',
    'sv_police:hardcuff',
    'sv_police:uncuff',
    'sv_police:escort',
    'sv_police:unescort',
    'sv_police:search',
    'sv_police:checkid',
    'sv_police:checkwarrants',
    'sv_police:putinvehicle',
    'sv_police:removefromvehicle',
    'sv_police:tackle'
}

function RemoveTargetOptions()
    if not targetOptionsRegistered then return end

    for _, name in ipairs(targetOptionNames) do
        exports.ox_target:removeGlobalPlayer(name)
    end

    targetOptionsRegistered = false

    if config.debug then
        print('^3[sv_police_actions]^7 ox_target options removed (no longer police)')
    end
end

function RegisterTargetOptions()
    if targetOptionsRegistered then return end

    exports.ox_target:addGlobalPlayer({
        {
            name = 'sv_police:frisk',
            label = 'Frisk',
            icon = 'fas fa-hand-paper',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.frisk)

                if lib.progressBar({
                    duration = config.animations.frisk.duration,
                    label = 'Frisking suspect...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:frisk', targetId)
                end
            end,
            canInteract = function(entity)
                -- Fast checks first (no network calls)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                return HasRequiredGrade('frisk')
            end
        },
        {
            name = 'sv_police:softcuff',
            label = 'Handcuff',
            icon = 'fas fa-link',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.cuff)

                if lib.progressBar({
                    duration = config.animations.cuff.duration,
                    label = 'Applying handcuffs...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:cuff', targetId, false)
                end
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('softcuff') then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return not isCuffed
            end
        },
        {
            name = 'sv_police:hardcuff',
            label = 'Hard Cuff',
            icon = 'fas fa-lock',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.cuff)

                if lib.progressBar({
                    duration = config.animations.cuff.duration,
                    label = 'Applying hard cuffs...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:cuff', targetId, true)
                end
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('hardcuff') then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return not isCuffed
            end
        },
        {
            name = 'sv_police:uncuff',
            label = 'Remove Cuffs',
            icon = 'fas fa-unlock',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.cuff)

                if lib.progressBar({
                    duration = config.animations.cuff.duration,
                    label = 'Removing cuffs...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:uncuff', targetId)
                end
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('uncuff') then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return isCuffed
            end
        },
        {
            name = 'sv_police:escort',
            label = 'Escort',
            icon = 'fas fa-walking',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                TriggerServerEvent('sv_police_actions:server:escort', targetId)
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('escort') then return false end
                if playerState.isEscorting then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return isCuffed
            end
        },
        {
            name = 'sv_police:unescort',
            label = 'Stop Escorting',
            icon = 'fas fa-hand-paper',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                TriggerServerEvent('sv_police_actions:server:unescort', targetId)
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not playerState.isEscorting then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                return playerState.escortTarget == targetId
            end
        },
        {
            name = 'sv_police:search',
            label = 'Search',
            icon = 'fas fa-search',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.search)

                if lib.progressBar({
                    duration = config.animations.search.duration,
                    label = 'Searching suspect...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:search', targetId)
                end
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('search') then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return isCuffed
            end
        },
        {
            name = 'sv_police:checkid',
            label = 'Check ID',
            icon = 'fas fa-id-card',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                PlayAnim(config.animations.checkId)

                if lib.progressBar({
                    duration = config.animations.checkId.duration,
                    label = 'Checking identification...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, combat = true }
                }) then
                    TriggerServerEvent('sv_police_actions:server:checkId', targetId)
                end
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                return HasRequiredGrade('checkId')
            end
        },
        {
            name = 'sv_police:checkwarrants',
            label = 'Check Warrants (MDT)',
            icon = 'fas fa-gavel',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                TriggerServerEvent('sv_police_actions:server:checkWarrants', targetId)
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not config.integrations.lbTablet.enabled then return false end
                if not IsPedAPlayer(entity) then return false end
                return HasRequiredGrade('checkWarrants')
            end
        },
        {
            name = 'sv_police:putinvehicle',
            label = 'Put In Vehicle',
            icon = 'fas fa-car-side',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                local playerPed = PlayerPedId()
                local coords = GetEntityCoords(playerPed)
                local vehicle = lib.getClosestVehicle(coords, 5.0, false)

                if not vehicle then
                    Notify('No vehicle nearby', 'error')
                    return
                end

                TriggerServerEvent('sv_police_actions:server:putInVehicle', targetId, NetworkGetNetworkIdFromEntity(vehicle))
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('putInVehicle') then return false end
                if IsPedInAnyVehicle(entity, false) then return false end

                local targetId = GetPlayerServerIdFromEntity(entity)
                if not targetId then return false end

                local isCuffed = lib.callback.await('sv_police_actions:isPlayerCuffed', false, targetId)
                return isCuffed
            end
        },
        {
            name = 'sv_police:removefromvehicle',
            label = 'Remove From Vehicle',
            icon = 'fas fa-door-open',
            distance = config.distances.target + 2.0,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                TriggerServerEvent('sv_police_actions:server:removeFromVehicle', targetId)
            end,
            canInteract = function(entity)
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not HasRequiredGrade('removeFromVehicle') then return false end
                return IsPedInAnyVehicle(entity, false)
            end
        },
        {
            name = 'sv_police:tackle',
            label = 'Tackle',
            icon = 'fas fa-fist-raised',
            distance = config.distances.target,
            onSelect = function(data)
                local targetId = GetPlayerServerIdFromEntity(data.entity)
                if not targetId then return end

                if not CanTackle() then
                    Notify('Cannot tackle right now', 'error')
                    return
                end

                playerState.lastTackle = GetGameTimer()
                PlayAnim(config.animations.tackle)
                TriggerServerEvent('sv_police_actions:server:tackle', targetId)
            end,
            canInteract = function(entity)
                if not config.tackle.enabled then return false end
                if not isPolice then return false end
                if not IsPedAPlayer(entity) then return false end
                if not IsPedOnFoot(entity) then return false end
                return CanTackle()
            end
        }
    })

    targetOptionsRegistered = true

    if config.debug then
        print('^2[sv_police_actions]^7 ox_target options registered')
    end
end

-- =====================
-- INITIALIZATION
-- =====================

-- Job check loop - only registers target options when police
CreateThread(function()
    -- Initial wait for player data
    while not PlayerData.job do
        Wait(500)
        UpdatePlayerData()
    end

    -- Initial registration if police
    if isPolice then
        Wait(1000) -- Wait for ox_target
        RegisterTargetOptions()
    end

    -- Periodic check for non-police (in case job events are missed)
    while true do
        if not isPolice then
            -- Not police - sleep 30 seconds then recheck
            Wait(30000)
            UpdatePlayerData()

            -- If became police, register options
            if isPolice and not targetOptionsRegistered then
                RegisterTargetOptions()
            end
        else
            -- Is police - sleep shorter for responsiveness
            Wait(5000)
        end
    end
end)

-- =====================
-- KEYBINDS
-- =====================

if config.keybinds.escort then
    lib.addKeybind({
        name = 'sv_police_escort_toggle',
        description = 'Toggle escort (police)',
        defaultKey = config.keybinds.escort,
        onPressed = function()
            if not isPolice then return end

            if playerState.isEscorting and playerState.escortTarget then
                TriggerServerEvent('sv_police_actions:server:unescort', playerState.escortTarget)
            end
        end
    })
end

-- =====================
-- DEBUG COMMANDS
-- =====================

if config.debug then
    RegisterCommand('policeactions:debug', function()
        print('^3[DEBUG]^7 PlayerData:', json.encode(PlayerData))
        print('^3[DEBUG]^7 playerState:', json.encode(playerState))
        print('^3[DEBUG]^7 isPolice:', isPolice)
        print('^3[DEBUG]^7 targetOptionsRegistered:', targetOptionsRegistered)
    end, false)
end
