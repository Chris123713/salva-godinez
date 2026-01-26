fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sv-mechanic-fullrepair'
description 'Full vehicle repair utility - resets jg-mechanic servicingData and GTA health'
author 'Sierra Valley RP'
version '1.0.0'

dependencies {
    'oxmysql',
    'ox_lib',
}

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
