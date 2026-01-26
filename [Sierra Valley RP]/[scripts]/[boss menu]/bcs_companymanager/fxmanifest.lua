fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version      '5.11.0'
version      '5.11.0'

author 'BagusCodeStudio'
description 'Fivem Company Manager (Boss Menu and Billing)'

ui_page 'html/index.html'
-- ui_page 'http://localhost:5174'

files {
    'html/index.html',
    'html/images/*.png',
    'html/assets/*.js',
    'html/assets/*.css',
    'locales/*.json'
}

shared_script {
    '@ox_lib/init.lua',
    'config/config.lua',
    'modules/utils.lua',
    'bridge/init.lua',
    'config/bossmenu.lua',
    'config/gangs.lua',
    'config/billing.lua',
    'config/duty.lua',
}

client_scripts {
    'bridge/**/client.lua',
    'client/**/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/sv_config.lua',
    'modules/core.lua',
    'modules/database.lua',
    'bridge/**/server.lua',  -- Load bridge BEFORE server files
    'server/classes/*.lua',
    'server/*.lua',
}

escrow_ignore {
    'config/*.lua',
    'bridge/**/**.lua',
    'client/functions.lua',
    'client/markers.lua',
    'client/target.lua',
    'server/functions.lua',
    'server/classes/account.lua',
    'server/init.lua',
    'locales/*.json'
}

dependency '/assetpacks'