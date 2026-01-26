fx_version "cerulean"
game "gta5"
lua54 "yes"

author "LB"
description "A radio app for LB Phone"
version "1.2.3"

shared_scripts {
    "config/config.lua",
    "config/locales/*.lua",
    "lib/shared/**.lua",
}

client_scripts {
    "lib/client/**.lua",
    "client/**/*"
}

server_scripts {
    "lib/server/**.lua",
    "server/*.lua"
}

file "ui/dist/**/*"
ui_page "ui/dist/index.html"

escrow_ignore {
    "config/*.lua",
    "config/locales/*.lua",
    "lib/**.lua",
    "client/functions.lua",
    "client/frameworks/*.lua",
    "server/server.lua"
}

dependency '/assetpacks'