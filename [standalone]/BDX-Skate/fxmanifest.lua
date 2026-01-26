fx_version 'cerulean'
game 'gta5'

name 'BDX-Skate'
description 'Skateboard - Classic street skating with fully customizable boards'
author 'Bodhix'
version '3.0.1'

lua54 'yes'

shared_scripts {
  'config.lua',
}

client_scripts {
  'client/item-callback.lua',
  'client/*.lua',
}

server_scripts {
  'server/*.lua',
}

files {
  'nui/sounds/*.MP3',
  'stream/Add-ons/*.ydr',
  'stream/Skateboards/**/*.yft',
  'stream/Anims/**.ycd',
  'server/version.json',
}

ui_page 'https://bodh1x.github.io/bdx-sport-hub/'
nui_page 'https://bodh1x.github.io/bdx-sport-hub/'

data_file "DLC_ITYP_REQUEST" "stream/Add-ons/*.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/decks.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/trucks.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/wheels.ytyp"

escrow_ignore {
  'config.lua',
}

dependencies {
  'BDX-Sport-Hub'
}
dependency '/assetpacks'