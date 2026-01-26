fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'sv_police_actions'
description 'Police player interactions via ox_target - frisk, cuff, escort, search, ID check'
author 'Sierra Valley RP'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
    'qbx_core'
}
