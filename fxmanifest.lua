fx_version 'cerulean'
game 'gta5'

name 'sync-hud'
author 'kxirby'
description 'fivem hud for all popular frameworks :)'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/assets/logo.png',
    'html/assets/*.png',
    'html/assets/*.jpg',
    'html/assets/*.gif',
}
