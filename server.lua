package.path="?/init.lua;"..package.path
require("Libs/MultiManager") -- allows for multitasking
require("net") -- Loads the networking library
require("net.chatting") -- loads the networking chatting module
server=net:newTCPServer(12345) -- starts a server with the port 12345 on local host
multi:mainloop() -- starts the mainloop to keep the server going
