fx_version 'cerulean'
game 'gta5'

author 'Advanced MultiJob Menu'
description 'An advanced multi-job menu system for QBX Core and QB-Core'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

lua54 'yes'

escrow_ignore {
    'html/**',
    'README.md',
    'fxmanifest.lua',
    'config.lua',
}

dependency '/assetpacks'