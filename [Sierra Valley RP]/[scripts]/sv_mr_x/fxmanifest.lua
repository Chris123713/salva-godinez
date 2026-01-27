fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sv_mr_x'
description 'Mr. X - Omniscient AI Fixer for Sierra Valley RP'
author 'Sierra Valley Development'
version '1.0.0'

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'lb-phone',
    'sv_nexus_tools'
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/constants.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/admin_menu.lua',
    'client/phone_hack.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/webhook.lua',           -- Webhook posting to web dashboard (load early)
    'server/banking.lua',           -- Mr. X's personal finances (scarcity system)
    'server/personality.lua',       -- Dynamic personality context injection
    'server/profile.lua',
    'server/reputation.lua',
    'server/fact_discovery.lua',    -- Automatic fact discovery from various sources
    'server/activity_tracking.lua', -- Session/idle tracking for proactive contact timing
    'server/camera_intel.lua',      -- Camera-aware intelligence (requires camera locations)
    'server/snitch_network.lua',    -- Player intel reporting system
    'server/comms.lua',
    'server/services.lua',
    'server/tablet.lua',
    'server/bounty.lua',
    'server/mission_gen.lua',
    'server/chaos.lua',
    'server/external_hooks.lua',    -- Death, MDT, economy hooks
    'server/admin.lua',
    'server/http_handler.lua',      -- HTTP endpoint for manual commands (load late, uses exports)
    'server/boardroom.lua',         -- AI strategic planning sessions
    'server/phone_hack.lua',        -- Phone hack selfie system
    'server/main.lua'
}

files {
    'data/MR_X_SYSTEM_PROMPT.md',
    'data/MR_X_BOARDROOM_PROMPT.md'
}

-- Database schema: run db/mr_x_schema.sql on your MySQL server
