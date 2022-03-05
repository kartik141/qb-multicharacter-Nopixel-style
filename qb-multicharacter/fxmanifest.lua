fx_version 'bodacious'
game 'gta5'

author 'Mike M'
description 'Nopixel style multicharacter for QBcore'
version '1.3'


ui_page "html/index.html"

client_scripts {
    'client/main.lua',
    'client/cameras.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/script.js',
    'html/images/*.png',
}