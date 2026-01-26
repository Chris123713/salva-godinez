fx_version 'cerulean'
game 'gta5'

name 'Cinematic Camera'
description 'Cinematic camera system with freecam movement, zoom, and clear UI toggle for better footage'
author 'Auto'
version '1.0.0'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'

