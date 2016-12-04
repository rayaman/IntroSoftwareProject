package.path="?/init.lua;"..package.path
require("Libs/MultiManager") -- allows for multitasking
require("Libs/bin") -- allows for binary minipulation
require("net") -- Loads the networking library
require("net.chatting") -- loads the networking chatting module
require("net.settings") -- loads the networking settings module
require("net.identity") -- loads the networking identity module
require("net.logging") -- loads the networking logging module
server=net:newTCPServer(12345) -- starts a server with the port 12345 on local host
server.OnChatRecieved(function(struct) -- where we handle users and messages
	print(struct.user..": "..struct.msg)
end)
multi:mainloop() -- starts the mainloop to keep the server going
--:regSetting(namespace,settings)
