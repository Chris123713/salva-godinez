Config = {}

-- Registered panel types from various resources
-- Other resources can add their panel types via exports
Config.PanelTypes = {
    -- Job Orchestrator panel
    job_market = {
        label = 'Job Market Display',
        resource = 'sv_job_orchestrator',
        url = 'nui://sv_job_orchestrator/web/index.html',
        defaultWidth = 1.5,
        defaultHeight = 1.125,  -- 4:3 aspect ratio
        resW = 1024,
        resH = 768,
        interactDist = 3.0,
        zoomDist = 1.8,
        zoomFov = 50.0,
        camHeight = 0.1,
        -- Optional: callback event when panel is interacted with
        onInteract = nil,
    },

    -- PD Boss Menu panels
    -- NOTE: pd_boss_menu handles its own panel rendering via panel_placer_integration.lua
    -- This entry is here for the placement tool to know about the panel type
    pd_boss_menu = {
        label = 'PD Boss Menu',
        resource = 'pd_boss_menu',
        url = 'nui://pd_boss_menu/web/index.html?res=pd_boss_menu',
        defaultWidth = 0.5,
        defaultHeight = 0.28,
        resW = 1920,
        resH = 1280,
        interactDist = 3.0,
        zoomDist = 1.8,
        zoomFov = 50.0,
        camHeight = 0.1,
        -- pd_boss_menu creates its own ox_target zones, so no onInteract needed here
        selfManaged = true,  -- Flag: pd_boss_menu handles its own panel creation
    },
}

-- Default panel settings
Config.Defaults = {
    width = 1.5,
    height = 1.0,
    resW = 1920,
    resH = 1080,
    interactDist = 3.0,
    zoomDist = 1.8,
    zoomFov = 50.0,
    camHeight = 0.1,
    camOffsetX = 0.0,
    camOffsetY = 0.0,
}

-- ACE Permissions for panel commands
-- These tie into your permissions.cfg ACE groups
Config.Permissions = {
    -- Permission to place/edit/delete panels
    place = 'group.admin',      -- /placepanel command

    -- Permission to list panels (less restrictive)
    list = 'group.mod',         -- /listpanels command
}
