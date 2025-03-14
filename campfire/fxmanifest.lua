fx_version 'cerulean'
game { 'gta5' }
author 'BostonGeorgeTTV'
description 'Campfire'
version '1.1.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', -- comment if dont use it
    'shared/config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

data_file 'DLC_ITYP_REQUEST' 'stream/log_campfire.ytyp'
