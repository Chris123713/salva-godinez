fx_version 'cerulean'
author 'NANO Scripts'
description 'Interaction System'
version '1.0.7'

game 'gta5'

lua54 'yes'

files { 
    'html/index.html', 
    'html/second.html', 
    'html/css/*.css',
    'html/css/fonts/*.ttf',
    'html/js/jquery/*.js',
    'html/js/*.js',
}
    
client_scripts {
    'config.lua',
    'client/main.lua',
    'client/exports.lua',
}

escrow_ignore {
    'config.lua',
    -- 'client/main.lua',
    -- 'client/exports.lua',
}
dependency '/assetpacks'
dependency '/assetpacks'