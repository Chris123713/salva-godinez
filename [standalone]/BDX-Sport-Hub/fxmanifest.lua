fx_version 'cerulean'
game 'gta5'

name 'BDX-Sport-Hub'
description 'Unified Sports Hub - Supports implemented Sports from Bodhix Studio.'
author 'Bodhix'
version '1.0.1'

lua54 'yes'

shared_scripts {
  'config/config_protected.lua',  -- Protected/escrowed config (technical settings)
  'config.lua',            -- Public config (customer configurable)
  'config/config_merge.lua',      -- Merges both configs together
}

client_scripts {
  'client/gear-manager.lua',              -- Shared gear management system
  'client/gear-wheel.lua',                -- Sport gear wheel menu
  'client/equipment.lua',                 -- Equipment system UI and logic
  'client/equipment-attachment.lua',      -- Equipment attachment to player bones
  'client/equipment-preview-render.lua',  -- Equipment YDR preview rendering (DUI)
  'client/xtreme-shops-cl.lua',
  'client/store-ui.lua',
  'client/camera-preview.lua',
  'client/store-hours.lua',               -- Time-based NPC arrival/departure system
  'client/store-ownership-cl.lua',        -- Store ownership system
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/kvp-storage.lua',        -- KVP storage system (fallback for SQL)
  'server/framework-bridge.lua',
  'server/equipment.lua',         -- Equipment system server-side handlers
  'server/xtreme-shops-sv.lua',
  'server/sv.lua',
  'server/store-purchase.lua',
  'server/store-ownership.lua',   -- Store ownership system
}

files {
  -- Fonts
  'nui/fonts/*.ttf',

  -- HTML/CSS/JS
  'nui/index.html',
  'nui/*.css',
  'nui/*.js',

  -- Images - Root
  'nui/images/*.png',

  -- Images - Subfolders
  'nui/images/Logos/*.png',
  'nui/images/icons/*.png',
  'nui/images/wheel/*.png',
  'nui/images/features/*.jpg',
  'nui/images/discover/*.jpg',
  'nui/images/Equipment/fr/*.png',
  'nui/images/Equipment/ht/*.png',
  'nui/images/Equipment/sh/*.png',

  -- Customs - Sport designs
  'nui/customs/bmx/*.png',
  'nui/customs/iceskates/*.png',
  'nui/customs/skateboard/modern/*.png',
  'nui/customs/skateboard/classic/*.png',
  'nui/customs/ski/*.png',
  'nui/customs/snowboard/*.png',
  'nui/customs/hoverboard/retro/*.png',
  'nui/customs/hoverboard/ultra/*.png',
  'nui/customs/scooter/*.png',
  'nui/customs/rollers/retro/*.png',
  'nui/customs/rollers/modern/*.png',

  -- Audio
  'nui/sounds/*.MP3',
  'nui/sounds/*.m4a',

  -- Other
  'server/version.json',
}

ui_page 'nui/index.html'
nui_page 'nui/index.html'

-- Stream model files
files {
    'stream/**/*.ydr',
    'stream/*.ytyp',
}

-- Load archetype files for model definitions
data_file "DLC_ITYP_REQUEST" 'stream/helmets.ytyp'
data_file "DLC_ITYP_REQUEST" 'stream/forearms.ytyp'
data_file "DLC_ITYP_REQUEST" 'stream/shingear.ytyp'

escrow_ignore {
  'config.lua',                   -- Public configuration file (customer editable)
  'server/framework-bridge.lua',  -- Framework abstraction (users need to customize for custom frameworks)
  -- NOTE: config_protected.lua and config_merge.lua are escrowed (not in this list)
}


dependency '/assetpacks'