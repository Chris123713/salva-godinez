fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Police Department Boss Menu with 3D Screen'
version '1.1.0'

dependencies {
    'cr-3dnui',
    'ox_lib',
    'qbx_core',
    'oxmysql'
}

-- sv_panel_placer is optional but recommended for easier panel placement
-- If not present, uses config-based panels only

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/client.lua',
    'client/placement_tool.lua',
    'client/panel_placer_integration.lua'  -- sv_panel_placer integration
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/panel_placer_integration.lua'  -- sv_panel_placer integration
}

-- UI page with frame pointer for better mouse handling
ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/animations.js',
    'web/admin_logs.js',
    'web/time_tracking.js',
    'web/transaction_display.js',
    'web/lib/chart.min.js',
    'web/lib/xlsx.min.js'
}

lua54 'yes'