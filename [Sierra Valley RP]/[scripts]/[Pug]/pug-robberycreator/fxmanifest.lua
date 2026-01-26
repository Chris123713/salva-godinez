lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'zPug'
description 'Robbery Creator'
version '1.2.3'

shared_scripts {
    'config/config-framework.lua',
    'config/config.lua',
    'config/config-minigames.lua',
    'config/config-translation.lua',
}
server_scripts {    
    '@oxmysql/lib/MySQL.lua',
    'server/secret.lua',
    'server/sv_banktruck.lua',
    'server/sv_sellitems.lua',
    'server/sv_atm.lua',
    'server/server.lua',
    'server/sv_open.lua',
}
client_scripts { 
    'client/*.lua',
    -- '@ox_lib/init.lua', -- This can be hashed out if you are not using ox_lib
}

ui_page 'html/index.html'
files {
    'html/*.html',
    'html/*.js',
    'preset-info/presets.json',
    'preset-info/ox_doorlocks.json',
}

escrow_ignore {
    'config/config-translation.lua',
    'config/config-framework.lua',
    'config/config-minigames.lua',
    'config/config.lua',
    'server/sv_sellitems.lua',
    'server/sv_banktruck.lua',
    'server/sv_open.lua',
    'client/open.lua',
    'client/atm.lua',
    'client/sellitems.lua',
    'html/index.html',
}
dependency '/assetpacks'