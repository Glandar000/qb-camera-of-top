fx_version 'cerulean'
game 'gta5'

description 'ZomerX#6153  Benz#0579  Discord  - https://discord.gg/5xHA3RY3Fq'
version '1.0.2'

client_script 'client/client.lua'

server_script 'server/server.lua'

lua54 'yes'

escrow_ignore {
    'client/client.lua',
    'server/server.lua',
    'README.md',
    'LICENSE',
}
dependency '/assetpacks'server_scripts { '@mysql-async/lib/MySQL.lua' }