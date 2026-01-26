fx_version 'cerulean'
game 'gta5'

author 'Rejox | rxscripts.xyz'
description 'Loading Screen'
version '1.1.1'

lua54 'yes'

loadscreen_manual_shutdown "yes"
loadscreen 'web/dist/index.html'
loadscreen_cursor "yes"

client_script 'client.lua'

files {
  'config.js',
  'locales/*.js',
  'web/dist/index.html',
  -- 'web/dist/bg.mp4', -- Commented out - using direct URL instead
  'web/dist/audio.mp3',
  'web/dist/logo.png',
  'web/dist/team/*.png',
  'web/dist/playlist/*.mp3',
  'web/dist/slideshow/*.png',
  'web/dist/assets/*.*',
}

dependency '/assetpacks'