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
    'server/tools_criminal.lua',
    'server/tools_police.lua',
    'server/tools_social.lua',
    'server/tools_world.lua',
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

-- Database schema: run db/nexus_schema.sql on your MySQL server
