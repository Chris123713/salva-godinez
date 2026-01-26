fx_version 'bodacious'
lua54 'yes'
game 'gta5'

version '2.0.8'

author 'KAFKAS - store.siberwin.com'
description 'SiberWin Truck Simulator'

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
	'shared/framework.lua',
	'shared/fuel.lua',
	'shared/inventory.lua',
	'shared/keys.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'server/party.lua',
	'server/database.lua',
	'server/dealership.lua',
	'server/diagnostics.lua',
	'server/banking.lua',
	'server/repayment_handler.lua',
	'server/drivers.lua',
	'server/specialloads.lua',
	'list/specialjoblist.lua',
	'list/joblist.lua',
	'list/deliverylocation.lua'
}

client_scripts {
	'client/main.lua',
	'client/target.lua',
	'client/truckjobs.lua',
	'client/nui.lua',
	'client/dealership.lua',
	'client/diagnostics.lua',
	'client/party.lua',
	'client/drivers.lua',
	'client/camera.lua',
	'client/diamond_exchange.lua'
}

ui_page 'web/build/index.html'

files {
    'web/build/**/*',
	'locales/*.json'
}


escrow_ignore {
    'list/*.lua',
    'config.lua',
	'server/database.lua',
	'client/truckjobs.lua',
	'shared/fuel.lua',
	'client/target.lua',
	'client/camera.lua',
	'server/specialloads.lua',
	'list/specialjoblist.lua',
	'shared/inventory.lua',
	'shared/keys.lua'
}

dependencies {
	'ox_lib',
	'oxmysql'
}

server_exports {
    'DispatchSpecialLoadAlert'
}
dependency '/assetpacks'