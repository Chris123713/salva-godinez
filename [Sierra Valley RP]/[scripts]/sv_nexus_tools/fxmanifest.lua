fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sv_nexus_tools'
description 'AI-driven procedural content generation toolbox for Sierra Valley RP'
author 'Sierra Valley Development'
version '1.0.0'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'ox_target',
    'ox_inventory'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/constants.lua',
    'shared/tools_registry.lua',
    'config.lua'
}

client_scripts {
    'client/utils.lua',
    'client/spawning.lua',
    'client/dialogs.lua',
    'client/targeting.lua',
    'client/tools_handlers.lua',
    'client/mission_creator.lua',
    'client/nui_mission_creator.lua', -- NUI callbacks for mission creator
    'client/gameplay_handlers.lua',   -- Client handlers for gameplay tools
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/tools.lua',           -- MUST load first: defines RegisterTool global
    'server/openai.lua',
    'server/phone.lua',
    'server/economy.lua',
    'server/items.lua',
    'server/spawning.lua',
    'server/element_library.lua', -- Element library for reusable assets
    'server/tools_criminal.lua',
    'server/tools_police.lua',
    'server/tools_social.lua',
    'server/tools_world.lua',
    'server/tools_elements.lua',  -- Element library tool handlers
    'server/tools_gameplay.lua',  -- Gameplay manipulation tools
    'server/tools_multiplayer.lua', -- Multi-player mission tools
    'server/missions.lua',
    'server/networking.lua',
    'server/integrations.lua',
    'server/main.lua'
}

files {
    'data/blueprints.json',
    'data/safe_zones.json',
    'data/items.lua'
}

-- NUI for mission creator
ui_page 'html/mission_creator.html'

files {
    'html/mission_creator.html',
    'html/css/mission_creator.css',
    'html/js/mission_creator.js'
}

-- Database schema: run db/nexus_schema.sql on your MySQL server
