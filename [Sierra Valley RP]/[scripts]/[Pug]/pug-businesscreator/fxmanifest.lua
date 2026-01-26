lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'zPug'
description 'Pug Business Creator'
version '2.5.3'

shared_scripts {
    'config.lua'
}
server_scripts {    
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/registers.lua',
}
client_scripts { 
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/client.lua',
    'client/open.lua',
    'client/targets.lua',
    'client/registers.lua',
    '@ox_lib/init.lua', -- This can be hashed out if you are not using ox_lib
}

ui_page 'html/index.html'
files {
    'html/index.html',
}

escrow_ignore {
    'config.lua',
    'client/open.lua',
    'client/targets.lua',
    'client/registers.lua',

    'server/server.lua',
    'server/registers.lua',
    
    'html/index.html',
}
dependency '/assetpacks'