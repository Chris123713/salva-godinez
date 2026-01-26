fx_version 'cerulean'
games {'gta5'}
description 'MarkoMods.com PM4'

files{
	'**/markomods-pm4-components.meta',
	'**/markomods-pm4-archetypes.meta',
	'**/markomods-pm4-animations.meta',
	'**/markomods-pm4-pedpersonality.meta',
	'**/markomods-pm4.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/markomods-pm4-components.meta'
data_file 'WEAPON_METADATA_FILE' '**/markomods-pm4-archetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/markomods-pm4-animations.meta'
data_file 'PED_PERSONALITY_FILE' '**/markomods-pm4-pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/markomods-pm4.meta'

client_script 'cl_weaponNames.lua'

escrow_ignore {
	'stream/**/*.ytd',
	'data/**/*.meta',
	'cl_weaponNames.lua'
  }
  
  lua54 'yes'
dependency '/assetpacks'