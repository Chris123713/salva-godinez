-- Admin Mission Creator UI

local MissionCreator = {}

-- Placement state
local PlacementMode = {
    active = false,
    currentElement = nil,
    mockupEntity = nil,
    elements = {},
    profile = nil
}

-- Create transparent mockup entity
local function CreateMockup(model, coords, entityType)
    local modelHash = type(model) == 'string' and joaat(model) or model

    if not ClientUtils.RequestModel(model) then
        ClientUtils.Notify('Error', 'Failed to load model: ' .. model, 'error')
        return nil
    end

    local entity

    if entityType == 'npc' then
        entity = CreatePed(4, modelHash, coords.x, coords.y, coords.z, 0.0, false, false)
    elseif entityType == 'vehicle' then
        entity = CreateVehicle(modelHash, coords.x, coords.y, coords.z, 0.0, false, false)
    else
        entity = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    end

    SetModelAsNoLongerNeeded(modelHash)

    if DoesEntityExist(entity) then
        SetEntityAlpha(entity, Config.MissionCreator.MockupAlpha, false)
        SetEntityCollision(entity, false, false)
        FreezeEntityPosition(entity, true)
        return entity
    end

    return nil
end

-- Delete mockup entity
local function DeleteMockup()
    if PlacementMode.mockupEntity and DoesEntityExist(PlacementMode.mockupEntity) then
        DeleteEntity(PlacementMode.mockupEntity)
    end
    PlacementMode.mockupEntity = nil
end

-- Start mission creator
function MissionCreator.Start(missionType)
    if PlacementMode.active then
        ClientUtils.Notify('Warning', 'Mission creator already active', 'warning')
        return
    end

    ClientUtils.Notify('Mission Creator', 'Generating AI profile...', 'info')

    -- Request AI profile from server
    TriggerServerEvent('nexus:server:generateProfile', {
        missionType = missionType or 'criminal'
    })
end

-- Handle profile received from server
RegisterNetEvent('nexus:client:profileGenerated', function(data)
    if not data.success then
        ClientUtils.Notify('Error', data.error or 'Failed to generate profile', 'error')
        return
    end

    PlacementMode.active = true
    PlacementMode.profile = data.profile
    PlacementMode.elements = {}

    -- Show profile menu
    MissionCreator.ShowProfileMenu()
end)

-- Show profile overview menu
function MissionCreator.ShowProfileMenu()
    local profile = PlacementMode.profile

    lib.registerContext({
        id = 'mission_creator_main',
        title = 'Mission Creator',
        description = profile.brief,
        options = {
            {
                title = 'Teleport to Area',
                description = 'Go to mission location',
                icon = 'fas fa-location-arrow',
                onSelect = function()
                    local coords = profile.area
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                    ClientUtils.Notify('Teleported', 'Arrived at mission area', 'success')
                end
            },
            {
                title = 'Place Elements',
                description = 'Add NPCs, vehicles, and props',
                icon = 'fas fa-plus-circle',
                onSelect = function()
                    MissionCreator.ShowElementMenu()
                end
            },
            {
                title = 'View Placed Elements',
                description = ('%d elements placed'):format(#PlacementMode.elements),
                icon = 'fas fa-list',
                onSelect = function()
                    MissionCreator.ShowPlacedElements()
                end
            },
            {
                title = 'Configure Objectives',
                description = 'Set mission objectives',
                icon = 'fas fa-bullseye',
                onSelect = function()
                    MissionCreator.ShowObjectivesMenu()
                end
            },
            {
                title = 'Save Blueprint',
                description = 'Save to blueprints.json',
                icon = 'fas fa-save',
                onSelect = function()
                    MissionCreator.SaveBlueprint()
                end
            },
            {
                title = 'Cancel',
                description = 'Discard and exit',
                icon = 'fas fa-times',
                onSelect = function()
                    MissionCreator.Cancel()
                end
            }
        }
    })

    lib.showContext('mission_creator_main')
end

-- Show element placement menu
function MissionCreator.ShowElementMenu()
    lib.registerContext({
        id = 'mission_creator_elements',
        title = 'Place Element',
        menu = 'mission_creator_main',
        options = {
            {
                title = 'Place NPC',
                description = 'Add a mission NPC',
                icon = 'fas fa-user',
                onSelect = function()
                    MissionCreator.StartPlacement('npc', 's_m_m_scientist_01')
                end
            },
            {
                title = 'Place Vehicle',
                description = 'Add a mission vehicle',
                icon = 'fas fa-car',
                onSelect = function()
                    MissionCreator.StartPlacement('vehicle', 'sultan')
                end
            },
            {
                title = 'Place Prop',
                description = 'Add a mission prop',
                icon = 'fas fa-cube',
                onSelect = function()
                    MissionCreator.StartPlacement('prop', 'prop_box_wood02a')
                end
            },
            {
                title = 'Custom Model',
                description = 'Enter model name',
                icon = 'fas fa-edit',
                onSelect = function()
                    MissionCreator.PromptCustomModel()
                end
            }
        }
    })

    lib.showContext('mission_creator_elements')
end

-- Prompt for custom model
function MissionCreator.PromptCustomModel()
    local input = lib.inputDialog('Custom Model', {
        {type = 'select', label = 'Element Type', options = {
            {value = 'npc', label = 'NPC'},
            {value = 'vehicle', label = 'Vehicle'},
            {value = 'prop', label = 'Prop'}
        }},
        {type = 'input', label = 'Model Name', placeholder = 's_m_m_scientist_01'}
    })

    if input then
        MissionCreator.StartPlacement(input[1], input[2])
    end
end

-- Start element placement mode
function MissionCreator.StartPlacement(elementType, model)
    PlacementMode.currentElement = {
        type = elementType,
        model = model
    }

    local playerCoords = GetEntityCoords(PlayerPedId())
    PlacementMode.mockupEntity = CreateMockup(model, playerCoords, elementType)

    if not PlacementMode.mockupEntity then
        ClientUtils.Notify('Error', 'Failed to create mockup', 'error')
        return
    end

    ClientUtils.Notify('Placement Mode', 'LMB: Place | R: Rotate | ESC: Cancel', 'info')
    ClientUtils.PlaySound('SUCCESS')

    -- Start placement thread
    CreateThread(function()
        while PlacementMode.mockupEntity do
            Wait(0)

            -- Get raycast from camera
            local hit, endCoords, _, _, _ = ClientUtils.RaycastFromCamera(50.0, 1)

            if hit then
                -- Move mockup to hit location
                local groundZ = ClientUtils.GetGroundZ(endCoords)
                SetEntityCoords(PlacementMode.mockupEntity, endCoords.x, endCoords.y, groundZ + 0.5)
            end

            -- Rotation with R
            if IsControlJustPressed(0, 45) then -- R key
                local currentHeading = GetEntityHeading(PlacementMode.mockupEntity)
                SetEntityHeading(PlacementMode.mockupEntity, currentHeading + Config.MissionCreator.RotationStep)
                ClientUtils.PlaySound('ROTATE')
            end

            -- Place with left click
            if IsControlJustPressed(0, 24) then -- LMB
                MissionCreator.ConfirmPlacement()
                break
            end

            -- Cancel with ESC
            if IsControlJustPressed(0, 200) then -- ESC
                DeleteMockup()
                PlacementMode.currentElement = nil
                ClientUtils.Notify('Cancelled', 'Placement cancelled', 'info')
                MissionCreator.ShowProfileMenu()
                break
            end

            -- Draw instructions
            ClientUtils.Draw3DText(GetEntityCoords(PlacementMode.mockupEntity), 'LMB: Place | R: Rotate')
        end
    end)
end

-- Confirm element placement
function MissionCreator.ConfirmPlacement()
    local coords = GetEntityCoords(PlacementMode.mockupEntity)
    local heading = GetEntityHeading(PlacementMode.mockupEntity)

    local element = {
        type = PlacementMode.currentElement.type,
        model = PlacementMode.currentElement.model,
        coords = {coords.x, coords.y, coords.z, heading}
    }

    -- Check limit
    if #PlacementMode.elements >= Config.MissionCreator.MaxElements then
        ClientUtils.Notify('Limit Reached', 'Maximum elements reached', 'warning')
        DeleteMockup()
        PlacementMode.currentElement = nil
        MissionCreator.ShowProfileMenu()
        return
    end

    table.insert(PlacementMode.elements, element)
    ClientUtils.PlaySound('PLACE')
    ClientUtils.Notify('Placed', ('%s placed (%d total)'):format(element.type, #PlacementMode.elements), 'success')

    -- Ask about dialog for NPCs
    if element.type == 'npc' then
        MissionCreator.ConfigureNpcDialog(#PlacementMode.elements)
    else
        -- Convert mockup to permanent
        SetEntityAlpha(PlacementMode.mockupEntity, 255, false)
        PlacementMode.mockupEntity = nil
        PlacementMode.currentElement = nil
        MissionCreator.ShowProfileMenu()
    end
end

-- Configure NPC dialog
function MissionCreator.ConfigureNpcDialog(elementIndex)
    local input = lib.inputDialog('NPC Configuration', {
        {type = 'input', label = 'NPC Name', placeholder = 'Informant'},
        {type = 'input', label = 'Dialog Tree ID', placeholder = 'informant_talk'},
        {type = 'checkbox', label = 'Requires Mission', checked = true}
    })

    if input then
        PlacementMode.elements[elementIndex].npcName = input[1]
        PlacementMode.elements[elementIndex].dialog = input[2]
        PlacementMode.elements[elementIndex].requireMission = input[3]
    end

    -- Convert mockup to permanent
    SetEntityAlpha(PlacementMode.mockupEntity, 255, false)
    PlacementMode.mockupEntity = nil
    PlacementMode.currentElement = nil

    MissionCreator.ShowProfileMenu()
end

-- Show placed elements list
function MissionCreator.ShowPlacedElements()
    local options = {}

    for i, element in ipairs(PlacementMode.elements) do
        options[#options + 1] = {
            title = ('%d. %s - %s'):format(i, element.type:upper(), element.model),
            description = ('Coords: %.1f, %.1f, %.1f'):format(
                element.coords[1], element.coords[2], element.coords[3]
            ),
            icon = element.type == 'npc' and 'fas fa-user' or
                   element.type == 'vehicle' and 'fas fa-car' or 'fas fa-cube',
            onSelect = function()
                -- Teleport to element
                SetEntityCoords(PlayerPedId(), element.coords[1], element.coords[2], element.coords[3])
            end,
            metadata = {
                {label = 'Heading', value = element.coords[4]},
                {label = 'Dialog', value = element.dialog or 'None'}
            }
        }
    end

    if #options == 0 then
        options[#options + 1] = {
            title = 'No elements placed',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'mission_creator_placed',
        title = 'Placed Elements',
        menu = 'mission_creator_main',
        options = options
    })

    lib.showContext('mission_creator_placed')
end

-- Show objectives configuration
function MissionCreator.ShowObjectivesMenu()
    local input = lib.inputDialog('Configure Objectives', {
        {type = 'textarea', label = 'Criminal Objectives', placeholder = 'steal_vehicle\nescape_area', default = 'steal_vehicle\nescape_area'},
        {type = 'textarea', label = 'Police Objectives', placeholder = 'prevent_theft\narrest_suspect', default = 'prevent_theft\narrest_suspect'}
    })

    if input then
        -- Parse objectives
        PlacementMode.profile.objectives = {
            criminal = {},
            police = {}
        }

        for line in input[1]:gmatch('[^\n]+') do
            table.insert(PlacementMode.profile.objectives.criminal, line:match('^%s*(.-)%s*$'))
        end

        for line in input[2]:gmatch('[^\n]+') do
            table.insert(PlacementMode.profile.objectives.police, line:match('^%s*(.-)%s*$'))
        end

        ClientUtils.Notify('Saved', 'Objectives configured', 'success')
    end

    MissionCreator.ShowProfileMenu()
end

-- Save blueprint to server
function MissionCreator.SaveBlueprint()
    if #PlacementMode.elements == 0 then
        ClientUtils.Notify('Error', 'No elements placed', 'error')
        MissionCreator.ShowProfileMenu()
        return
    end

    local blueprint = {
        type = PlacementMode.profile.type or 'criminal',
        brief = PlacementMode.profile.brief,
        area = PlacementMode.profile.area,
        elements = {
            npcs = {},
            vehicles = {},
            props = {}
        },
        objectives = PlacementMode.profile.objectives or {}
    }

    -- Sort elements by type
    for _, element in ipairs(PlacementMode.elements) do
        local container = blueprint.elements[element.type .. 's']
        if container then
            table.insert(container, {
                model = element.model,
                coords = element.coords,
                dialog = element.dialog,
                npcName = element.npcName
            })
        end
    end

    TriggerServerEvent('nexus:server:saveBlueprint', blueprint)

    MissionCreator.Cancel()
end

-- Cancel and cleanup
function MissionCreator.Cancel()
    DeleteMockup()

    -- Delete placed mockup entities
    -- In a real implementation, we'd track these

    PlacementMode.active = false
    PlacementMode.currentElement = nil
    PlacementMode.elements = {}
    PlacementMode.profile = nil

    ClientUtils.Notify('Exited', 'Mission creator closed', 'info')
end

-- Command to start mission creator
RegisterCommand('missionCreator', function(source, args)
    local missionType = args[1] or 'criminal'
    MissionCreator.Start(missionType)
end, false)

-- Server event to trigger profile generation
RegisterNetEvent('nexus:server:generateProfile', function(data)
    -- This is actually handled server-side, client just triggers it
end)

return MissionCreator
