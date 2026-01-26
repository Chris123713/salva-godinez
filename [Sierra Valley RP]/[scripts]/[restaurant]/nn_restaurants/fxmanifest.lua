fx_version "cerulean"

description "Restaurant System"
author "NANO Scripts"
version '1.1.2'

lua54 'yes'

games { "gta5" }

ui_page 'web/build/index.html'

server_script "@oxmysql/lib/MySQL.lua"

shared_script {
  '@ox_lib/init.lua',
  '@nn_bridge/init.lua',
  "shared/config.lua",
  "shared/translations.lua",
  "shared/config_cookingitems.lua",
  "shared/config_shopitems.lua",
  "shared/config_usables.lua",
}
client_script "client/**/*"
server_scripts {
  "lib/lib.lua",
  "server/**/*",
}

data_file 'DLC_ITYP_REQUEST' 'stream/sn_fryer.ytyp'

files {
	'web/build/index.html',
	'web/build/**/*',
  'stream/sn_fryer.ytyp'
}

escrow_ignore {
  'shared/**/*',
  -- 'client/**/*',
  -- 'server/**/*',
  -- 'stream/**/*',
}

exports {
  'getPlayerRestaurantId',
  'removeMoney',
  'addMoney'
}
dependency '/assetpacks'