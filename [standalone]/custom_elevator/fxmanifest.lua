fx_version 'cerulean'
game 'gta5'

author 'SierraValleyRP'
description 'Advanced Custom Elevator System with Call Mechanics & State Synchronization'
version '2.0.0'

-- Required dependencies
dependencies {
    'ox_lib'
}

-- Shared scripts (loaded on both client and server)
shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/state_machine.lua'
}

-- Client scripts
client_scripts {
    'client/client.lua',
    'client/animations.lua',
    'client/sounds.lua',
    'client/interaction_target.lua',
    'client/interaction_text.lua',
    'client/builder_advanced.lua'
}

-- Server scripts
server_scripts {
    'server/state_manager.lua',
    'server/queue_system.lua',
    'server/sync.lua',
    'server/server.lua',
    'server/builder.lua'
}

-- NUI
ui_page 'html/builder_advanced.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/builder.html',
    'html/builder.js',
    'html/builder_advanced.html',
    'html/builder_advanced.css',
    'html/builder_advanced.js',
    'html/sounds/*.ogg'
}

lua54 'yes'
