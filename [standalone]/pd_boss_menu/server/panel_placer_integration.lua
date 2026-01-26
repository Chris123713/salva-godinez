-- pd_boss_menu integration with sv_panel_placer
-- Registers panel type and syncs panels from the universal placer

local resourceName = GetCurrentResourceName()

-- Check if sv_panel_placer is available
local function IsPanelPlacerAvailable()
    return GetResourceState('sv_panel_placer') == 'started'
end

-- Register pd_boss_menu panel type with sv_panel_placer
CreateThread(function()
    Wait(2000) -- Wait for sv_panel_placer to be ready

    if not IsPanelPlacerAvailable() then
        print('^3[pd_boss_menu]^7 sv_panel_placer not found - using config-based panels only')
        return
    end

    -- Register panel type
    local success = exports['sv_panel_placer']:RegisterPanelType('pd_boss_menu', {
        label = 'PD Boss Menu',
        resource = resourceName,
        url = 'nui://pd_boss_menu/web/index.html?res=pd_boss_menu',
        defaultWidth = 1.5,
        defaultHeight = 1.0,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = 1.8,
        zoomFov = 50.0,
        camHeight = 0.1,
    })

    if success then
        print('^2[pd_boss_menu]^7 Registered with sv_panel_placer')
    else
        print('^1[pd_boss_menu]^7 Failed to register with sv_panel_placer')
    end
end)

-- Callback to get panels from sv_panel_placer
lib.callback.register('pd_boss_menu:getPanelPlacerPanels', function(source)
    if not IsPanelPlacerAvailable() then
        return {}
    end

    local panels = exports['sv_panel_placer']:GetPlacedPanels('pd_boss_menu')
    return panels or {}
end)

print('^2[pd_boss_menu]^7 Panel placer integration loaded')
