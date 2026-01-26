fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

name 'tgg-banking'
description 'An advanced banking system.'
author 'TeamsGG Development'
version '1.3.2'

ui_page 'ui/build/index.html'

files {
    'ui/build/**/*',
    'locales/*.json',
}

ox_libs {
    'locale',
    'table',
}

client_script 'client/**/*.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/custom/*.lua',
    'shared/enums/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**/*.lua',
}

escrow_ignore {
    'config/**/*',

    'client/custom/**/*.lua',

    'server/custom/**/*.lua',

    'shared/custom/*.lua',
}

dependencies {
    '/server:6116',
    '/onesync',
    'oxmysql',
    'ox_lib',
}

provide 'qb-banking'
provide 'Renewed-Banking'
provide 'esx_society'

dependency '/assetpacks'