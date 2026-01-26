-- pd_boss_menu client integration with sv_panel_placer
-- Loads panels from both config and sv_panel_placer database

local resourceName = GetCurrentResourceName()

-- Track panels created from sv_panel_placer (for cleanup purposes)
-- Actual panels are stored in global BossPanels table from client.lua
local placerPanelIds = {}

-- Check if sv_panel_placer is available
local function IsPanelPlacerAvailable()
    return GetResourceState('sv_panel_placer') == 'started'
end

-- Convert database row to config format
local function DbRowToConfig(row)
    return {
        id = row.panel_id,
        enabled = row.enabled,
        position = vector3(row.position_x, row.position_y, row.position_z),
        heading = row.heading,
        width = row.width,
        height = row.height,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = row.zoom_dist,
        zoomFov = row.zoom_fov,
        camHeight = row.cam_height,
        camOffsetX = row.cam_offset_x,
        camOffsetY = row.cam_offset_y,
        fromPlacer = true  -- Mark as coming from sv_panel_placer
    }
end

-- Convert heading to normal vector
local function HeadingToNormal(heading)
    local rad = math.rad(heading + 180)
    return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

-- Create a single panel from placer config
local function CreatePlacerPanel(cfg)
    if not cfg or not cfg.enabled then return nil end

    local id = cfg.id
    local normal = HeadingToNormal(cfg.heading)

    print('^3[pd_boss_menu]^7 Creating placer panel:', id, 'at', cfg.position)

    local newPanelId = exports['cr-3dnui']:CreatePanel({
        url = 'nui://pd_boss_menu/web/index.html?res=pd_boss_menu',
        pos = cfg.position,
        normal = normal,
        width = cfg.width or 1.5,
        height = cfg.height or 1.0,
        resW = cfg.resW or 1920,
        resH = cfg.resH or 1280,
        alpha = 255,
        enabled = true,
        zOffset = 0.01
    })

    if not newPanelId then
        print('^1[pd_boss_menu]^7 Failed to create placer panel:', id)
        return nil
    end

    -- Store panel info in global BossPanels table (shared with client.lua)
    -- This allows ZoomToScreen() to find our panels
    if BossPanels then
        BossPanels[id] = {
            panelId = newPanelId,
            config = cfg
        }
    end

    -- Track this panel ID for cleanup
    placerPanelIds[id] = true

    -- Create ox_target zone
    local zoneName = 'pd_boss_placer_panel_' .. id
    exports.ox_target:addSphereZone({
        coords = cfg.position,
        radius = cfg.interactDist or 3.0,
        name = zoneName,
        options = {{
            name = zoneName,
            icon = 'fas fa-desktop',
            label = 'Access Boss Menu',
            onSelect = function()
                -- Call the global ZoomToScreen function from client.lua
                if ZoomToScreen then
                    ZoomToScreen(cfg)
                end
            end
        }}
    })

    print('^2[pd_boss_menu]^7 Placer panel created:', id)
    return newPanelId
end

-- Cleanup placer panels
local function CleanupPlacerPanels()
    if GetResourceState('cr-3dnui') == 'started' and BossPanels then
        for id, _ in pairs(placerPanelIds) do
            local data = BossPanels[id]
            if data then
                pcall(function()
                    exports['cr-3dnui']:DestroyPanel(data.panelId)
                end)
                pcall(function()
                    exports.ox_target:removeZone('pd_boss_placer_panel_' .. id)
                end)
                BossPanels[id] = nil
            end
        end
    end
    placerPanelIds = {}
end

-- Load and create panels from sv_panel_placer
local function LoadPlacerPanels()
    if not IsPanelPlacerAvailable() then
        return 0
    end

    CleanupPlacerPanels()

    local dbPanels = lib.callback.await('pd_boss_menu:getPanelPlacerPanels', false)
    if not dbPanels or #dbPanels == 0 then
        return 0
    end

    print('^2[pd_boss_menu]^7 Loading', #dbPanels, 'panels from sv_panel_placer')

    local created = 0
    for _, row in ipairs(dbPanels) do
        local cfg = DbRowToConfig(row)
        if CreatePlacerPanel(cfg) then
            created = created + 1
        end
    end

    return created
end

-- Hook into panel refresh
RegisterNetEvent('pd_boss_menu:refreshPanels', function()
    -- Wait for main refresh then load placer panels
    Wait(600)
    LoadPlacerPanels()
end)

-- Hook into sv_panel_placer refresh events
RegisterNetEvent('sv_panel_placer:client:refreshPanels', function()
    Wait(500)
    LoadPlacerPanels()
end)

-- Initial load after player is ready
CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(500)
    end

    Wait(3000) -- Wait for main panels to load first

    local count = LoadPlacerPanels()
    if count > 0 then
        print('^2[pd_boss_menu]^7 Loaded', count, 'panels from sv_panel_placer')
    end
end)

-- Exports for debugging
exports('GetPlacerPanels', function()
    local result = {}
    for id, _ in pairs(placerPanelIds) do
        if BossPanels and BossPanels[id] then
            result[id] = BossPanels[id]
        end
    end
    return result
end)
exports('RefreshPlacerPanels', LoadPlacerPanels)

print('^2[pd_boss_menu]^7 Panel placer client integration loaded')
print('^3[pd_boss_menu]^7 Use /placepanel pd_boss_menu to place new panels via sv_panel_placer')
