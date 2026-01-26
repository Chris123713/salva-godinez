-- Resource Metadata
fx_version 'cerulean'
games {'gta5'}

name 'rahe-speakers'
description 'RAHE Speakers'
version '1.0.3'
lua54 'yes'

dependencies {
    'oxmysql',
    'ox_lib',
    'rahe-audio',
    '/server:7290',
    '/onesync',
}

client_scripts {
    'client/cl_*.lua',
    'editable_client/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'editable_shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua',
    'editable_server/*.lua',
}

ui_page 'web/build/index.html'

files {
    'locales/*.json',
    'web/build/index.html',
    'web/build/**/*',
}

escrow_ignore {
    'editable_client/*.lua',
    'editable_shared/*.lua',
    'editable_server/*.lua',
}
dependency '/assetpacks'