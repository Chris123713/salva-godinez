-- Server-side module for sv_panel_placer
-- Handles database persistence and panel registration

local resourceName = GetCurrentResourceName()

-- In-memory panel type registry (runtime additions)
local registeredPanelTypes = {}

-- Initialize database table
CreateThread(function()
    repeat Wait(100) until MySQL.ready

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `panel_placements` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `panel_id` VARCHAR(100) NOT NULL UNIQUE,
            `panel_type` VARCHAR(50) NOT NULL,
            `label` VARCHAR(100) DEFAULT NULL,
            `position_x` FLOAT NOT NULL,
            `position_y` FLOAT NOT NULL,
            `position_z` FLOAT NOT NULL,
            `heading` FLOAT NOT NULL DEFAULT 0,
            `width` FLOAT NOT NULL DEFAULT 1.5,
            `height` FLOAT NOT NULL DEFAULT 1.0,
            `zoom_dist` FLOAT NOT NULL DEFAULT 1.8,
            `zoom_fov` FLOAT NOT NULL DEFAULT 50.0,
            `cam_height` FLOAT NOT NULL DEFAULT 0.1,
            `cam_offset_x` FLOAT NOT NULL DEFAULT 0.0,
            `cam_offset_y` FLOAT NOT NULL DEFAULT 0.0,
            `enabled` BOOLEAN NOT NULL DEFAULT TRUE,
            `created_by` VARCHAR(50) DEFAULT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX `idx_panel_type` (`panel_type`),
            INDEX `idx_enabled` (`enabled`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])

    print('^2[' .. resourceName .. ']^7 Database table initialized')
end)

---Register a new panel type from another resource
---@param typeId string Unique identifier for this panel type
---@param config table Panel type configuration
function RegisterPanelType(typeId, config)
    if not typeId or not config then
        print('^1[' .. resourceName .. ']^7 RegisterPanelType: Missing typeId or config')
        return false
    end

    registeredPanelTypes[typeId] = {
        label = config.label or typeId,
        resource = config.resource or GetInvokingResource() or 'unknown',
        url = config.url,
        defaultWidth = config.defaultWidth or Config.Defaults.width,
        defaultHeight = config.defaultHeight or Config.Defaults.height,
        resW = config.resW or Config.Defaults.resW,
        resH = config.resH or Config.Defaults.resH,
        interactDist = config.interactDist or Config.Defaults.interactDist,
        zoomDist = config.zoomDist or Config.Defaults.zoomDist,
        zoomFov = config.zoomFov or Config.Defaults.zoomFov,
        camHeight = config.camHeight or Config.Defaults.camHeight,
        onInteract = config.onInteract,
        onMessage = config.onMessage,
    }

    print('^2[' .. resourceName .. ']^7 Registered panel type: ' .. typeId .. ' from ' .. registeredPanelTypes[typeId].resource)

    -- Broadcast to all clients
    TriggerClientEvent('sv_panel_placer:panelTypeRegistered', -1, typeId, registeredPanelTypes[typeId])

    return true
end

---Get all registered panel types
---@return table All panel types (merged config + runtime)
function GetPanelTypes()
    local merged = {}

    -- Start with config panel types
    for typeId, config in pairs(Config.PanelTypes) do
        merged[typeId] = config
    end

    -- Merge runtime registered types (override if same key)
    for typeId, config in pairs(registeredPanelTypes) do
        merged[typeId] = config
    end

    return merged
end

---Get all placed panels from database
---@param panelType string|nil Optional filter by panel type
---@return table Array of panel placements
function GetPlacedPanels(panelType)
    local query = 'SELECT * FROM panel_placements WHERE enabled = TRUE'
    local params = {}

    if panelType then
        query = query .. ' AND panel_type = ?'
        params = { panelType }
    end

    local rows = MySQL.query.await(query, params)
    return rows or {}
end

---Save a panel placement to database
---@param panelData table Panel placement data
---@param createdBy string|nil CitizenID of the creator
---@return boolean success
---@return string|nil error
function SavePanelPlacement(panelData, createdBy)
    if not panelData or not panelData.panel_id or not panelData.panel_type then
        return false, 'Missing required panel data'
    end

    -- Check if panel exists
    local existing = MySQL.scalar.await(
        'SELECT id FROM panel_placements WHERE panel_id = ?',
        { panelData.panel_id }
    )

    if existing then
        -- Update existing
        MySQL.update.await([[
            UPDATE panel_placements SET
                position_x = ?, position_y = ?, position_z = ?,
                heading = ?, width = ?, height = ?,
                zoom_dist = ?, zoom_fov = ?, cam_height = ?,
                cam_offset_x = ?, cam_offset_y = ?,
                label = ?, enabled = ?
            WHERE panel_id = ?
        ]], {
            panelData.position.x, panelData.position.y, panelData.position.z,
            panelData.heading, panelData.width, panelData.height,
            panelData.zoomDist, panelData.zoomFov, panelData.camHeight,
            panelData.camOffsetX or 0, panelData.camOffsetY or 0,
            panelData.label, panelData.enabled ~= false,
            panelData.panel_id
        })
        return true, 'Panel updated'
    else
        -- Insert new
        MySQL.insert.await([[
            INSERT INTO panel_placements
            (panel_id, panel_type, label, position_x, position_y, position_z,
             heading, width, height, zoom_dist, zoom_fov, cam_height,
             cam_offset_x, cam_offset_y, enabled, created_by)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            panelData.panel_id, panelData.panel_type, panelData.label,
            panelData.position.x, panelData.position.y, panelData.position.z,
            panelData.heading, panelData.width, panelData.height,
            panelData.zoomDist, panelData.zoomFov, panelData.camHeight,
            panelData.camOffsetX or 0, panelData.camOffsetY or 0,
            panelData.enabled ~= false, createdBy
        })
        return true, 'Panel created'
    end
end

---Delete a panel placement
---@param panelId string The panel ID to delete
---@return boolean success
function DeletePanelPlacement(panelId)
    local affected = MySQL.update.await(
        'DELETE FROM panel_placements WHERE panel_id = ?',
        { panelId }
    )
    return affected > 0
end

-- Exports
exports('RegisterPanelType', RegisterPanelType)
exports('GetPanelTypes', GetPanelTypes)
exports('GetPlacedPanels', GetPlacedPanels)
exports('SavePanelPlacement', SavePanelPlacement)
exports('DeletePanelPlacement', DeletePanelPlacement)

-- Callbacks
lib.callback.register('sv_panel_placer:getPanelTypes', function(source)
    return GetPanelTypes()
end)

lib.callback.register('sv_panel_placer:getPlacedPanels', function(source, panelType)
    return GetPlacedPanels(panelType)
end)

-- Event: Save panel from placement tool
RegisterNetEvent('sv_panel_placer:server:savePanel', function(panelData)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Check admin permission (ACE-based)
    if not IsPlayerAceAllowed(src, Config.Permissions.place) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Panel Placer',
            description = 'You do not have permission to place panels',
            type = 'error'
        })
        return
    end

    local success, message = SavePanelPlacement(panelData, player.PlayerData.citizenid)

    TriggerClientEvent('sv_panel_placer:client:saveResult', src, success, message)

    if success then
        -- Broadcast to all clients to refresh panels
        TriggerClientEvent('sv_panel_placer:client:refreshPanels', -1)
    end
end)

-- Event: Delete panel
RegisterNetEvent('sv_panel_placer:server:deletePanel', function(panelId)
    local src = source

    -- Check admin permission (ACE-based)
    if not IsPlayerAceAllowed(src, Config.Permissions.place) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Panel Placer',
            description = 'You do not have permission to delete panels',
            type = 'error'
        })
        return
    end

    local success = DeletePanelPlacement(panelId)

    if success then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Panel Placer',
            description = 'Panel deleted',
            type = 'success'
        })
        TriggerClientEvent('sv_panel_placer:client:refreshPanels', -1)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Panel Placer',
            description = 'Panel not found',
            type = 'error'
        })
    end
end)

print('^2[' .. resourceName .. ']^7 Server module loaded')
