-- Resource Metadata
fx_version 'cerulean'
games {'gta5'}

name 'rahe-audio'
description 'RAHE Audio'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/cl_*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    'shared/sh_*.lua',
}

server_scripts {
    'server/sv_*.lua',
}

-- ui_page 'web/build/index.html'

files {
    'web/build/**/*',
}
dependency '/assetpacks'