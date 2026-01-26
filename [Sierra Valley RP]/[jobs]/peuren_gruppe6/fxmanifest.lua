fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'

author 'PEUREN DEVELOPMENT - peuren.dev'
lua54 'yes'

client_scripts { 'client/**/**' }
shared_scripts { 'shared/sh_main.lua', 'shared/sh_contracts.lua', 'shared/sh_laptops.lua'  }
server_scripts { 'server/**/**' }

files { 'locales/*.json', "web/dist/**/*", 'data/**/*.meta' }

dependency 'peuren_lib'

data_file 'HANDLING_FILE' 'data/**/*.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/**/*.meta'
data_file 'CARCOLS_FILE' 'data/**/*.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/**/*.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/**/*.meta'
data_file 'VEHICLE_SHOP_DLC_FILE' 'data/**/*.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'data/**/*.meta' 

-- ui_page "http://localhost:5173/"
ui_page "web/dist/index.html"

escrow_ignore { 'shared/**' }
dependency '/assetpacks'
dependency '/assetpacks'