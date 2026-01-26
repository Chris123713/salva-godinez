fx_version 'cerulean'
game 'gta5'

name 'BDX-Xtreme-Stores'
description 'X-Treme Stores'
author 'Bodhix'
version '1.1.5'

lua54 'yes'
this_is_a_map "yes"

files {
  'stream/**/**/*.ydr',
  'stream/**/**/*.yft',
  'stream/**/**/*.ycd',
}

data_file "DLC_ITYP_REQUEST" "stream/Vinewood_Store/X-Treme.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Venice_Store/skate_store.ytyp"

dependency '/assetpacks'