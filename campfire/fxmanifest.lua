fx_version 'cerulean'
game { 'gta5' }
author 'BostonGeorgeTTV'
description 'Campfire'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/log_campfire.ytyp'