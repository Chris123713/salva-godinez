lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'Pug'
description 'Discord: zpug'
version '2.2.3'

client_script {
    '@ox_lib/init.lua',
    'client/open.lua',
    'client/crafting.lua',
    'client/fishing.lua',
    'client/menus.lua',
    'client/rewards.lua',
    'client/tournament.lua',
    'client/treasurechest.lua',
    'client/cooking.lua',
    'client/fishingnet.lua',
    'client/fishingtrap.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
	'server/*.lua',
}

shared_script {
    'config/config-framework.lua',
    'config/config-challenges.lua',
    'config/config-tournament.lua',
    'config/config-translation.lua',
    'config/config.lua',
    'config/config-rewards.lua',
}


ui_page 'html/index.html'

files {
    'html/*.html',
    'html/images/*',
    'html/sounds/*',
}

data_file 'DLC_ITYP_REQUEST' 'stream/prop_ham3d_fishingpackone.ytyp'

escrow_ignore {
    'config/config-framework.lua',
    'config/config-challenges.lua',
    'config/config-rewards.lua',
    'config/config-tournament.lua',
    'config/config-translation.lua',
    'config/config.lua',
    'client/crafting.lua',
    'client/open.lua',
    'client/menus.lua',
    'client/rewards.lua',
    'server/sv_open.lua',
    'server/sv_boats.lua',
    'server/sv_hotzones.lua',
    'client/treasurechest.lua',
    'client/treasurechest.lua',
    '(ESX-ONLY)/ox-items.lua',
    '(QBCORE-ONLY)/qb-items.lua',
}
dependency '/assetpacks'