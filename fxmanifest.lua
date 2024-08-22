fx_version 'cerulean'
game 'gta5'

author 'Jestar'
description 'Vice N Virtue Vehicle Shop'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_core/imports/server.lua',
    'server/*.lua'
}

client_scripts {
    '@ox_core/imports/client.lua',
    'client/*.lua'
}

lua54 'yes'
