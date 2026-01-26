fx_version 'cerulean'
game 'gta5'

name 'sv_panel_placer'
description 'Universal 3D Panel Placement Tool - Register and place panels from any resource'
author 'Sierra Valley RP'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua',
    'client/placement_tool.lua'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'cr-3dnui'
}
