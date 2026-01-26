fx_version 'cerulean'
games {'gta5'}
description 'MarkoMods.com X17 Modular'

files{
	'**/markomods-x17m-components.meta',
	'**/markomods-x17m-archetypes.meta',
	'**/**/markomods-x17m-animations.meta',
	'**/**/markomods-x17m-pedpersonality.meta',
	'**/**/markomods-x17m.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-x17m-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-x17m-archetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/**/markomods-x17m-animations.meta'
data_file 'PED_PERSONALITY_FILE' '**/**/markomods-x17m-pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/**/markomods-x17m.meta'

client_script 'cl_weaponNames.lua'

escrow_ignore {
	'stream/**/*.ytd',
	'data/**/*.meta',
	'cl_weaponNames.lua'
}
  
lua54 'yes'
dependency '/assetpacks'