fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nn_lib'
author 'Sinaps'
version '2.0.0'
lua54 'yes'

client_scripts {
    'client/main.lua',
    'shared/functions.lua',
    'client/callbacks.lua',
    'client/entity.lua',
    'client/blip.lua',
}

server_scripts {
    'server/main.lua',
    'shared/functions.lua',
    'server/timezone.lua',
    'server/webhook.lua',
    'server/callbacks.lua',
    'server/identifier.lua',
    'server/entity.lua',
}

exports {
    'Framework',
    'FrameWorkCheck',
    'GetLibObject',
}
dependency '/assetpacks'