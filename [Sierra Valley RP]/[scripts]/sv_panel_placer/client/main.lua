-- Client-side main module for sv_panel_placer
-- Handles panel rendering and management

local resourceName = GetCurrentResourceName()

-- Active panels: { [panelId] = { cr3dnuiId, config, ... } }
ActivePanels = {}

-- Cached panel types
local panelTypes = {}

-- Load panel types on start
CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    -- Get panel types from server
    panelTypes = lib.callback.await('sv_panel_placer:getPanelTypes', false)

    -- Load and create all placed panels
    RefreshAllPanels()

    print('^2[' .. resourceName .. ']^7 Client module loaded')
end)

---Get panel type configuration
---@param typeId string The panel type ID
---@return table|nil config
function GetPanelTypeConfig(typeId)
    return panelTypes[typeId] or Config.PanelTypes[typeId]
end

---Create a 3D panel using cr-3dnui
---@param placement table Panel placement data from database
---@return number|nil panelHandle
function CreatePanel(placement)
    if GetResourceState('cr-3dnui') ~= 'started' then
        print('^1[' .. resourceName .. ']^7 cr-3dnui is not running!')
        return nil
    end

    local typeConfig = GetPanelTypeConfig(placement.panel_type)
    if not typeConfig then
        print('^1[' .. resourceName .. ']^7 Unknown panel type: ' .. tostring(placement.panel_type))
        return nil
    end

    -- Skip if resource manages its own panels (e.g., pd_boss_menu)
    if typeConfig.selfManaged then
        print('^3[' .. resourceName .. ']^7 Skipping ' .. placement.panel_type .. ' (self-managed by ' .. (typeConfig.resource or 'unknown') .. ')')
        return nil
    end

    -- Calculate normal from heading
    local normalRad = math.rad(placement.heading + 180)
    local normal = vector3(-math.sin(normalRad), math.cos(normalRad), 0.0)

    local position = vector3(placement.position_x, placement.position_y, placement.position_z)

    local panelHandle = exports['cr-3dnui']:CreatePanel({
        url = typeConfig.url,
        pos = position,
        normal = normal,
        width = placement.width,
        height = placement.height,
        resW = typeConfig.resW or 1920,
        resH = typeConfig.resH or 1080,
        alpha = 255,
        enabled = true,
        zOffset = 0.01
    })

    if panelHandle then
        ActivePanels[placement.panel_id] = {
            handle = panelHandle,
            placement = placement,
            typeConfig = typeConfig,
            position = position,
        }

        -- Send init message if configured
        if typeConfig.onMessage then
            exports['cr-3dnui']:SendMessage(panelHandle, typeConfig.onMessage)
        end
    end

    return panelHandle
end

---Destroy a panel
---@param panelId string The panel ID
function DestroyPanel(panelId)
    local panel = ActivePanels[panelId]
    if panel and panel.handle then
        pcall(function()
            exports['cr-3dnui']:DestroyPanel(panel.handle)
        end)
        ActivePanels[panelId] = nil
    end
end

---Destroy all panels
function DestroyAllPanels()
    for panelId, _ in pairs(ActivePanels) do
        DestroyPanel(panelId)
    end
    ActivePanels = {}
end

---Refresh all panels from database
function RefreshAllPanels()
    DestroyAllPanels()

    local placements = lib.callback.await('sv_panel_placer:getPlacedPanels', false)

    for _, placement in ipairs(placements or {}) do
        CreatePanel(placement)
    end

    print('^2[' .. resourceName .. ']^7 Loaded ' .. #(placements or {}) .. ' panels')
end

---Get panel at position (for editing)
---@param pos vector3 Position to check
---@param maxDist number Maximum distance
---@return string|nil panelId
---@return table|nil panelData
function GetNearbyPanel(pos, maxDist)
    maxDist = maxDist or 5.0

    for panelId, panel in pairs(ActivePanels) do
        local dist = #(pos - panel.position)
        if dist < maxDist then
            return panelId, panel
        end
    end

    return nil, nil
end

-- Event handlers
RegisterNetEvent('sv_panel_placer:client:refreshPanels', function()
    RefreshAllPanels()
end)

RegisterNetEvent('sv_panel_placer:panelTypeRegistered', function(typeId, config)
    panelTypes[typeId] = config
end)

-- Update panels from sv_job_orchestrator
RegisterNetEvent('sv_job_orchestrator:updateDUI', function(jobData)
    -- Forward to any job_market panels
    for panelId, panel in pairs(ActivePanels) do
        if panel.placement.panel_type == 'job_market' then
            exports['cr-3dnui']:SendMessage(panel.handle, json.encode({
                type = 'update',
                jobs = jobData
            }))
        end
    end
end)

-- Exports
exports('CreatePanel', CreatePanel)
exports('DestroyPanel', DestroyPanel)
exports('RefreshAllPanels', RefreshAllPanels)
exports('GetNearbyPanel', GetNearbyPanel)
exports('GetPanelTypeConfig', GetPanelTypeConfig)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == resourceName then
        DestroyAllPanels()
    end
end)
