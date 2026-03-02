-- NUI Mission Creator Client
-- Handles NUI callbacks and placement mode

local NuiCreator = {}

-- State
local nuiOpen = false
local placementMode = false
local currentPlacement = nil
local placementEntity = nil
local placementHistory = {}
local currentDraft = nil

-- Placement settings
local placementHeading = 0.0
local placementHeightOffset = 0.0
local rotationSpeed = 5.0
local heightStep = 0.1

-- ============================================
-- NUI CONTROL
-- ============================================

function NuiCreator.Open(draft)
    currentDraft = draft
    nuiOpen = true

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        draft = draft
    })
end

function NuiCreator.Close()
    nuiOpen = false
    placementMode = false
    currentPlacement = nil
    currentDraft = nil

    if placementEntity and DoesEntityExist(placementEntity) then
        DeleteEntity(placementEntity)
        placementEntity = nil
    end

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
end

function NuiCreator.LoadDraft(draft)
    currentDraft = draft
    SendNUIMessage({
        action = 'loadDraft',
        draft = draft
    })
end

-- ============================================
-- NUI CALLBACKS
-- ============================================

RegisterNUICallback('onShow', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('onHide', function(data, cb)
    NuiCreator.Close()
    cb('ok')
end)

RegisterNUICallback('teleport', function(data, cb)
    if data.coords then
        local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
        lib.notify({ title = 'Teleported', description = 'Moved to mission area', type = 'success' })
    elseif currentDraft and currentDraft.area_coords then
        local coords = currentDraft.area_coords
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
        lib.notify({ title = 'Teleported', description = 'Moved to mission area', type = 'success' })
    end
    cb('ok')
end)

RegisterNUICallback('requestPlacement', function(data, cb)
    StartPlacementMode(data)
    cb('ok')
end)

RegisterNUICallback('cancelPlacement', function(data, cb)
    EndPlacementMode()
    cb('ok')
end)

RegisterNUICallback('saveElement', function(data, cb)
    -- Save element to server
    TriggerServerEvent('nexus:server:createElementFromPlacement', data)
    cb('ok')
end)

RegisterNUICallback('previewAll', function(data, cb)
    PreviewAllPlacements(data.items)
    cb('ok')
end)

RegisterNUICallback('saveBlueprint', function(data, cb)
    SaveBlueprint(data)
    cb('ok')
end)

RegisterNUICallback('undo', function(data, cb)
    UndoLastPlacement()
    cb('ok')
end)

RegisterNUICallback('cancel', function(data, cb)
    NuiCreator.Close()
    cb('ok')
end)

-- ============================================
-- PLACEMENT MODE
-- ============================================

function StartPlacementMode(data)
    placementMode = true
    currentPlacement = data
    placementHeading = 0.0
    placementHeightOffset = 0.0

    -- Release mouse for game control
    SetNuiFocus(true, false)

    -- Send start placement to NUI
    SendNUIMessage({
        action = 'startPlacement',
        heading = placementHeading,
        heightOffset = placementHeightOffset
    })

    -- Create preview entity
    CreatePlacementPreview(data)

    -- Start placement thread
    CreateThread(function()
        while placementMode do
            Wait(0)
            UpdatePlacement()
            HandlePlacementInput()
        end
    end)
end

function EndPlacementMode()
    placementMode = false
    currentPlacement = nil

    if placementEntity and DoesEntityExist(placementEntity) then
        DeleteEntity(placementEntity)
        placementEntity = nil
    end

    -- Restore full NUI focus
    if nuiOpen then
        SetNuiFocus(true, true)
    end

    SendNUIMessage({ action = 'endPlacement' })
end

function CreatePlacementPreview(data)
    local model = data.model

    -- Default models by type
    if not model or model == '' then
        if data.type == 'npc' then
            model = 's_m_m_scientist_01'
        elseif data.type == 'vehicle' then
            model = 'sultan'
        elseif data.type == 'prop' then
            model = 'prop_box_wood02a'
        end
    end

    if not model then return end

    -- Request model
    local hash = type(model) == 'string' and joaat(model) or model
    if not IsModelValid(hash) then return end

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    -- Get position in front of player
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)
    local spawnPos = playerCoords + forward * 5.0

    -- Create entity based on type
    if data.type == 'npc' then
        placementEntity = CreatePed(4, hash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, false, false)
    elseif data.type == 'vehicle' then
        placementEntity = CreateVehicle(hash, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, false, false)
    else
        placementEntity = CreateObject(hash, spawnPos.x, spawnPos.y, spawnPos.z, false, false, false)
    end

    if placementEntity then
        SetEntityAlpha(placementEntity, 150, false)
        SetEntityCollision(placementEntity, false, false)
        FreezeEntityPosition(placementEntity, true)
        SetModelAsNoLongerNeeded(hash)
    end
end

function UpdatePlacement()
    if not placementEntity or not DoesEntityExist(placementEntity) then return end

    -- Raycast from screen center
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local direction = RotationToDirection(camRot)
    local destination = camCoords + direction * 100.0

    local ray = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, destination.x, destination.y, destination.z, 1 + 16, PlayerPedId(), 0)
    local _, hit, hitCoords, _, _ = GetShapeTestResult(ray)

    if hit == 1 then
        local finalZ = hitCoords.z + placementHeightOffset
        SetEntityCoords(placementEntity, hitCoords.x, hitCoords.y, finalZ, false, false, false, false)
        SetEntityHeading(placementEntity, placementHeading)
    end
end

function HandlePlacementInput()
    -- Rotation
    if IsControlPressed(0, 45) then -- R key
        placementHeading = (placementHeading + rotationSpeed) % 360
        UpdatePlacementHUD()
    elseif IsControlPressed(0, 44) then -- Q key
        placementHeading = (placementHeading - rotationSpeed) % 360
        if placementHeading < 0 then placementHeading = placementHeading + 360 end
        UpdatePlacementHUD()
    end

    -- Height (scroll wheel)
    if IsControlJustPressed(0, 14) then -- Scroll Up
        placementHeightOffset = placementHeightOffset + heightStep
        UpdatePlacementHUD()
    elseif IsControlJustPressed(0, 15) then -- Scroll Down
        placementHeightOffset = placementHeightOffset - heightStep
        UpdatePlacementHUD()
    end

    -- Place (Left Mouse)
    if IsControlJustPressed(0, 24) then
        ConfirmPlacement()
    end

    -- Cancel (ESC handled by NUI)
end

function UpdatePlacementHUD()
    SendNUIMessage({
        action = 'updatePlacementInfo',
        heading = placementHeading,
        heightOffset = placementHeightOffset
    })
end

function ConfirmPlacement()
    if not placementEntity or not DoesEntityExist(placementEntity) then return end

    local coords = GetEntityCoords(placementEntity)
    local heading = GetEntityHeading(placementEntity)

    -- Store in history for undo
    table.insert(placementHistory, {
        index = currentPlacement.index,
        coords = coords,
        heading = heading,
        type = currentPlacement.type,
        model = currentPlacement.model
    })

    -- Notify NUI
    SendNUIMessage({
        action = 'itemPlaced',
        index = currentPlacement.index,
        coords = { x = coords.x, y = coords.y, z = coords.z }
    })

    -- Show tag modal
    SendNUIMessage({
        action = 'showTagModal',
        coords = { x = coords.x, y = coords.y, z = coords.z },
        heading = heading,
        type = currentPlacement.type,
        model = currentPlacement.model,
        index = currentPlacement.index
    })

    -- Clean up preview
    DeleteEntity(placementEntity)
    placementEntity = nil

    EndPlacementMode()
end

function UndoLastPlacement()
    if #placementHistory == 0 then
        lib.notify({ title = 'Undo', description = 'Nothing to undo', type = 'error' })
        return
    end

    local last = table.remove(placementHistory)

    -- Update NUI to mark item as not placed
    SendNUIMessage({
        action = 'itemPlaced',
        index = last.index,
        coords = nil
    })

    lib.notify({ title = 'Undo', description = 'Last placement undone', type = 'info' })
end

-- ============================================
-- PREVIEW & SAVE
-- ============================================

function PreviewAllPlacements(items)
    if not items then return end

    for _, item in ipairs(items) do
        if item.placed and item.coords then
            -- Briefly spawn preview entities
            local model = item.model or GetDefaultModel(item.type)
            local hash = type(model) == 'string' and joaat(model) or model

            if IsModelValid(hash) then
                RequestModel(hash)
                while not HasModelLoaded(hash) do Wait(10) end

                local entity
                if item.type == 'npc' then
                    entity = CreatePed(4, hash, item.coords.x, item.coords.y, item.coords.z, item.heading or 0.0, false, false)
                elseif item.type == 'vehicle' then
                    entity = CreateVehicle(hash, item.coords.x, item.coords.y, item.coords.z, item.heading or 0.0, false, false)
                else
                    entity = CreateObject(hash, item.coords.x, item.coords.y, item.coords.z, false, false, false)
                end

                if entity then
                    SetEntityAlpha(entity, 200, false)
                    FreezeEntityPosition(entity, true)

                    -- Delete after 3 seconds
                    SetTimeout(3000, function()
                        if DoesEntityExist(entity) then
                            DeleteEntity(entity)
                        end
                    end)
                end

                SetModelAsNoLongerNeeded(hash)
            end
        end
    end

    lib.notify({ title = 'Preview', description = 'Showing all placements for 3 seconds', type = 'info' })
end

function SaveBlueprint(data)
    -- Send to server
    TriggerServerEvent('nexus:server:saveMissionBlueprint', {
        draft_id = data.draft and data.draft.id,
        items = data.items,
        history = placementHistory
    })

    lib.notify({ title = 'Saved', description = 'Blueprint saved successfully', type = 'success' })
    NuiCreator.Close()
end

-- ============================================
-- HELPERS
-- ============================================

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return vector3(direction.x, direction.y, direction.z)
end

function GetDefaultModel(elementType)
    if elementType == 'npc' then
        return 's_m_m_scientist_01'
    elseif elementType == 'vehicle' then
        return 'sultan'
    else
        return 'prop_box_wood02a'
    end
end

-- ============================================
-- COMMANDS
-- ============================================

RegisterCommand('missionDraft', function(source, args)
    -- Request draft generation from server
    TriggerServerEvent('nexus:server:requestMissionDraft', args[1] or 'criminal')
end, false)

-- Server sends draft back
RegisterNetEvent('nexus:client:openMissionCreator', function(draft)
    NuiCreator.Open(draft)
end)

RegisterNetEvent('nexus:client:draftGenerated', function(data)
    if nuiOpen then
        NuiCreator.LoadDraft({
            id = data.draftId,
            synopsis = data.synopsis,
            required_assets = data.required_assets
        })
    else
        NuiCreator.Open({
            id = data.draftId,
            synopsis = data.synopsis,
            required_assets = data.required_assets
        })
    end
end)

-- ============================================
-- EXPORTS
-- ============================================

exports('OpenMissionCreator', NuiCreator.Open)
exports('CloseMissionCreator', NuiCreator.Close)
exports('IsMissionCreatorOpen', function() return nuiOpen end)
