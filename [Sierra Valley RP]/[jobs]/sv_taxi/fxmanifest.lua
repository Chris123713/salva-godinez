fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sv_taxi'
author 'Sierra Valley RP'
version '1.0.0'
description 'Advanced Taxi Job System with Ranking, NPC Jobs, and Realistic Meter'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/images/*.png',
    'html/images/*.jpg',
    'html/images/*.svg'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'oxmysql'
}
