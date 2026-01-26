fx_version 'cerulean'
games {'gta5'}
description 'Markomods.com MI9'

files{
	'**/markomods-mi9-components.meta',
	'**/markomods-mi9-archetypes.meta',
	'**/markomods-mi9-animations.meta',
	'**/markomods-mi9-pedpersonality.meta',
	'**/markomods-mi9.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-mi9-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-mi9-archetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/markomods-mi9-animations.meta'
data_file 'PED_PERSONALITY_FILE' '**/markomods-mi9-pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/markomods-mi9.meta'

client_script 'cl_weaponNames.lua'

escrow_ignore {
	'stream/**/*.ytd',
	'data/**/*.meta',
	'cl_weaponNames.lua'
}
  
lua54 'yes'
dependency '/assetpacks'