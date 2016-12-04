require("net")
--General Stuff
--[[ What this module does!
Adds
net.chatting:init()
server:OnChatRecieved(function({user,msg}) end)
client:OnChatRecieved(function(user,msg) end)
client:sendChat(user,msg)
]]
net:registerModule("chatting",{2,1,0})
function net.chatting:init() -- calling this initilizes the library and binds it to the servers and clients created
	--Server Stuff
	net.OnServerCreated:connect(function(s)
		print("The Chatting Module has been loaded onto the server!")
		s.OnDataRecieved:connect(function(self,data,cid,ip,port) -- when the server recieves data this method is triggered
			--First Lets make sure we are getting chatting data
			local user,msg = data:match("!chatting! (%S-) '(.+)'")
			if user and msg then
				local struct={ -- pack the info up as a table so the server can do filtering and whatnot to the chat
					user=user,
					msg=msg
				}
				self.OnChatRecieved:Fire(struct) -- trigger the chat event
				for i,v in pairs(self.ips) do
					if ip==v then
						print("Self: "..struct.user)
						self:send(v,"!chatting! 1 "..struct.user.." '"..struct.msg.."'")
					else
						self:send(v,"!chatting! 0 "..struct.user.." '"..struct.msg.."'")
					end
				end
			end
		end)
		s.rooms={}
		function s:regesterRoom(roomname)
			self.rooms[roomname]={}
		end
		s.OnChatRecieved=multi:newConnection() -- create a chat event
	end)
	--Client Stuff
	net.OnClientCreated:connect(function(c)
		c.OnDataRecieved:connect(function(self,data) -- when the client recieves data this method is triggered
			--First Lets make sure we are getting chatting data
			local isself, user,msg = data:match("!chatting! (%d) (%S-) '(.+)'")
			if user and msg then
				--This is the client so our job here is done
				print(isself)
				self.OnChatRecieved:Fire(user,msg,({["1"]=true, ["0"]=false})[isself]) -- trigger the chat event
			end
		end)
		function c:sendChat(user,msg)
			self:send("!chatting! "..user.." '"..msg.."'")
		end
		c.OnChatRecieved=multi:newConnection() -- create a chat event
	end)
end
if net.autoInit then
	net.chatting:init()
end
