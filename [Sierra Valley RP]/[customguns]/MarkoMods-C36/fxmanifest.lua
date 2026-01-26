fx_version 'cerulean'
games {'gta5'}
description 'Markomods.com c36'

files{
	'**/markomods-c36-components.meta',
	'**/markomods-c36-archetypes.meta',
	'**/markomods-c36-animations.meta',
	'**/markomods-c36-pedpersonality.meta',
	'**/markomods-c36.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-c36-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-c36-archetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/markomods-c36-animations.meta'
data_file 'PED_PERSONALITY_FILE' '**/markomods-c36-pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/markomods-c36.meta'

client_script 'cl_weaponNames.lua'
escrow_ignore {
	'stream/*.ytd',
	'meta/*.meta',
	'cl_weaponNames.lua'
}

lua54 'yes'
dependency '/assetpacks'