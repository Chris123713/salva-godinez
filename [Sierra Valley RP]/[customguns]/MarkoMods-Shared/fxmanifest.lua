fx_version 'cerulean'
games {'gta5'}
description 'markomods.com'

files{
	'**/markomods-components.meta',
	'**/markomods-archetypes.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-archetypes.meta'

escrow_ignore {
  'stream/**/*.ytd',
  'data/**/*.meta',
  'cl_weaponNames.lua'
}

lua54 'yes'
dependency '/assetpacks'