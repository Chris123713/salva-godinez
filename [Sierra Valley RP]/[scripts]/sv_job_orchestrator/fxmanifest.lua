fx_version 'cerulean'
game 'gta5'

name 'sv_job_orchestrator'
description 'Centralized job tracking with dynamic supply/demand pricing and DUI display'
author 'Sierra Valley RP'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/tracking.lua',
    'server/pricing.lua',
    'server/main.lua',
    'server/admin.lua',
    'server/discord.lua'
}

client_scripts {
    'client/main.lua'
}

-- NOTE: No ui_page - this is a DUI (3D panel) not fullscreen NUI
-- cr-3dnui loads the page directly via nui:// URL

files {
    'web/index.html',
    'web/styles.css',
    'web/script.js'
}

dependencies {
    'oxmysql',
    'ox_lib',
    'qbx_core',
    'sv_panel_placer'  -- Universal panel placement
}
