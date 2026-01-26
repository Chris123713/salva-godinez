fx_version 'cerulean'
games {'gta5'}
description 'Markomods.com 2011'

files{
	'**/markomods-2011-components.meta',
	'**/markomods-2011-archetypes.meta',
	'**/markomods-2011-animations.meta',
	'**/markomods-2011-pedpersonality.meta',
	'**/markomods-2011.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-2011-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-2011-archetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/markomods-2011-animations.meta'
data_file 'PED_PERSONALITY_FILE' '**/markomods-2011-pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/markomods-2011.meta'

client_script 'cl_weaponNames.lua'

escrow_ignore {
	'stream/**/*.ytd',
	'data/**/*.meta',
	'cl_weaponNames.lua'
}
  
lua54 'yes'
dependency '/assetpacks'