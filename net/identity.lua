require("net")
--General Stuff
--[[ What this module does!
Adds
net.identity:init()

]]
net:registerModule("identity",{1,0,0})
function net.hash(text,n)
	n=n or 16
	return bin.new(text.."jgmhktyf"):getHash(n)
end
function net.identity:init() -- calling this initilizes the library and binds it to the servers and clients created
	--Server Stuff
	net.OnServerCreated:connect(function(s)
		s.userFolder="./"
		print("The identity Module has been loaded onto the server!")
		function s:_isRegistered(user)
			return io.fileExists(self.userFolder..net.hash(user)..".dat")
		end
		function s:getUserData(user)
			local userdata=bin.load(self.userFolder..net.hash(user)..".dat")
			local nick,dTable=userdata:match("%S-|%S-|(%S-)|(.+)")
			return nick,loadstring("return "..(dTable or "{}"))()
		end
		function s:getUserCred(user)
			local userdata=bin.load(self.userFolder..net.hash(user)..".dat")
			return userdata:match("%S-|(%S-)|")
		end
		function s:userLoggedIn(cid)
			for i,v in pairs(self.loggedIn) do
				if v.cid==cid then
					return i
				end
			end
			return false
		end
		function s:setDataLocation(loc)
			self.userFolder=loc
		end
		function s:loginUserOut(user)
			self.loggedIn[user]=nil
		end
		function s:loginUserIn(user,cid)
			local nick,dTable=self:getUserData(user)
			self.loggedIn[user]={}
			table.merge(self.loggedIn[user],dTable or {})
			self.loggedIn[user].cid=cid
			self.loggedIn[user].nick=nick
			return self:getUserDataHandle(user)
		end
		function s:getUserDataHandle(user)
			return self.loggedIn[user]
		end
		function s:syncUserData(user,ip,port)
			local handle=self:getUserDataHandle(user)
			self:send(ip,"!identity! SYNC <-|"..bin.ToStr(handle).."|->",port)
		end
		s.loggedIn={}
		s.OnUserRegistered=multi:newConnection()
		s.OnUserLoggedIn=multi:newConnection()
		s.OnUserLoggerOut=multi:newConnection()
		s.OnAlreadyLoggedIn=multi:newConnection()
		s.OnPasswordForgotten=multi:newConnection()
		s.OnDataRecieved:connect(function(self,data,cid,ip,port) -- when the server recieves data this method is triggered
			local cmd,arg1,arg2,arg3,arg4 = data:match("!identity! (%S-) '(.-)' '(.-)' '(.-)' <%-|(.+)|%->")
			if cmd=="register" then
				local user,pass,nick,dTable = arg1,arg2,arg3,arg4
				if self:_isRegistered(user) then
					self:send(ip,"!identity! REGISTERED <-|"..user.."|->",port)
				else
					if not(self.userFolder:sub(-1,-1)=="/" or self.userFolder:sub(-1,-1)=="\\") then
						self.userFolder=self.userFolder.."/"
					end
					local rets=self.OnUserRegistered:Fire(user,pass,nick,loadstring("return "..(dTable or "{}"))())
					for i=1,#rets do
						if rets[i][1]==false then
							print("Server refused to accept registration request!")
							self:send(ip,"!identity! REGISTERREFUSED <-|NIL|->",port)
							return
						end
					end
					bin.new(string.format("%s|%s|%s|%s\n",user,pass,nick,dTable)):tofile(self.userFolder..net.hash(user)..".dat")
					self:send(ip,"!identity! REGISTEREDGOOD <-|"..user.."|->",port)
				end
				return
			elseif cmd=="login" then
				local user,pass = arg1,arg2
				local _pass=s:getUserCred(user)
				if not(self:_isRegistered(user)) then
					self:send(ip,"!identity! LOGINBAD <-|nil|->",port)
					return
				end
				print(pass,_pass)
				if pass==_pass then
					if self:userLoggedIn(cid) then
						self.OnAlreadyLoggedIn:Fire(self,user,cid,ip,port)
						self:send(ip,"!identity! ALREADYLOGGEDIN <-|nil|->",port)
						return
					end
					local handle=self:loginUserIn(user,cid) -- binds the cid to username
					self:send(ip,"!identity! LOGINGOOD <-|"..bin.ToStr(handle).."|->",port)
					self.OnUserLoggedIn:Fire(user,cid,ip,port)
					return
				else
					self:send(ip,"!identity! LOGINBAD <-|nil|->",port)
					return
				end
			elseif cmd=="logout" then
				self:loginUserOut(user)
				self.OnClientClosed:Fire(self,"User logged out!",cid,ip,port)
			elseif cmd=="sync" then
				local dTable = loadstring("return "..(arg4 or "{}"))()
				local handle = self:getUserDataHandle(self:userLoggedIn(cid))
				table.merge(handle,dTable)
			elseif cmd=="pass" then
				local user=arg1
				if self:_isRegistered(user) then
					self.OnPasswordForgotten:Fire(arg1,cid)
					self:send(ip,"!identity! PASSREQUESTHANDLED <-|NONE|->",port)
				else
					self:send(ip,"!identity! NOUSER <-|"..user.."|->",port)
				end
			end
		end)
		s.OnClientClosed:connect(function(self,reason,cid,ip,port)
			self.OnUserLoggerOut:Fire(self,self:userLoggedIn(cid),cid,reason)
		end)
	end)
	--Client Stuff
	net.OnClientCreated:connect(function(c)
		c.userdata={}
		c.OnUserLoggedIn=multi:newConnection()
		c.OnBadLogin=multi:newConnection()
		c.OnUserAlreadyRegistered=multi:newConnection()
		c.OnUserAlreadyLoggedIn=multi:newConnection()
		c.OnUserRegistered=multi:newConnection()
		c.OnNoUserWithName=multi:newConnection()
		c.OnPasswordRequest=multi:newConnection()
		c.OnUserRegisterRefused=multi:newConnection()
		function c:logout()
			self:send("!identity! logout 'NONE' 'NONE' 'NONE' <-|nil|->")
		end
		c.OnDataRecieved:connect(function(self,data) -- when the client recieves data this method is triggered
			local cmd,arg1 = data:match("!identity! (%S-) <%-|(.+)|%->")
			if cmd=="REGISTERED" then
				self.OnUserAlreadyRegistered:Fire(self,arg1)
			elseif cmd=="REGISTEREDGOOD" then
				self.OnUserRegistered:Fire(self,arg1)
			elseif cmd=="REGISTERREFUSED" then
				self.OnUserRegisterRefused:Fire(self,arg1)
			elseif cmd=="ALREADYLOGGEDIN" then
				self.OnUserAlreadyLoggedIn:Fire(self,arg1)
			elseif cmd=="LOGINBAD" then
				self.OnBadLogin:Fire(self)
			elseif cmd=="LOGINGOOD" then
				local dTable=loadstring("return "..(arg1 or "{}"))()
				table.merge(self.userdata,dTable)
				self.OnUserLoggedIn:Fire(self,self.userdata)
			elseif cmd=="SYNC" then
				local dTable=loadstring("return "..(arg1 or "{}"))()
				table.merge(self.userdata,dTable)
			elseif cmd=="NOUSER" then
				self.OnNoUserWithName:Fire(self,arg1)
			elseif cmd=="PASSREQUESTHANDLED" then
				self.OnPasswordRequest:Fire(self)
			end
		end)
		function c:syncUserData()
			self:send(string.format("!identity! sync 'NONE' 'NONE' 'NONE' <-|%s|->",bin.ToStr(dTable)))
		end
		function c:forgotPass(user)
			self:send(string.format("!identity! pass '%s' 'NONE' 'NONE' <-|nil|->",user))
		end
		function c:getUserDataHandle()
			return self.userdata
		end
		function c:logIn(user,pass)
			self:send(string.format("!identity! login '%s' '%s' 'NONE' <-|nil|->",user,net.hash(pass)))
		end
		function c:register(user,pass,nick,dTable)
			if dTable then
				self:send(string.format("!identity! register '%s' '%s' '%s' <-|%s|->",user,net.hash(pass),nick,bin.ToStr(dTable)))
			else
				self:send(string.format("!identity! register '%s' '%s' '%s' <-|nil|->",user,net.hash(pass),nick))
			end
		end
	end)
end
if net.autoInit then
	net.identity:init()
end
