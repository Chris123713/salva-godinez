fx_version 'cerulean'
game 'gta5'
name 'BDX-Bmx'
description 'BMX Stunts - Shred the streets with customizable bikes, tricks and stunts'
author 'Bodhix'
version '3.0.0'
lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/BMX.lua',              
    'client/store-preview.lua',    
}

server_scripts {
    'server/BMX-sv.lua',           
    'server/BMX-Store-sv.lua',    
    'Whitelist.lua'
}

files {
    'data/*.meta',
    'stream/anims/*.ycd',
    'server/version.json',
    'stream/models/*.yft',
    'stream/vehicles/*.yft',
}

ui_page 'https://bodh1x.github.io/bdx-sport-hub/'
nui_page 'https://bodh1x.github.io/bdx-sport-hub/'

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file "DLC_ITYP_REQUEST" 'stream/bmxs.ytyp'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'

escrow_ignore {
    'config.lua',
    'Whitelist.lua',
}

dependencies {
  'BDX-Sport-Hub'
}
dependency '/assetpacks'