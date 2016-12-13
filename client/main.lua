MY_Name="" -- Will be set at a later time
-- This is a comment
--This is the test client code!
require("Libs/Library") -- One of the defualt libraies that i load... Not needed for this project
require("Libs/Utils") -- One of the defualt libraies that i load... Not needed for this project
require("Libs/bin") -- One of the defualt libraies that i load... Not needed for this project
require("Libs/MultiManager") -- allows for multitasking
require("Libs/lovebind") -- binds my libraies to the love2d engine that i am using
require("GuiManager") -- allows the use of graphics in the program.
require("net") -- Loads the networking library
require("net.chatting")
require("net.settings") -- loads the networking settings module
require("net.identity") -- loads the networking identity module
client=net:newTCPClient("69.113.201.7",12345)
if type(client)=="boolean" then error("Please run the server file first!") end
client.OnUserLoggedIn:connect(function(self,data)
	anim.Visible=false
	login:Destroy()
	MY_Name=data.nick
	INIT()
end)
client.OnBadLogin:connect(function(self)
	header.text="Login/Register (Pass/User incorrect!)"
	anim.Visible=false
end)
client.OnUserAlreadyRegistered:connect(function(self,nick)
	header.text="Login/Register (Username Taken!)"
	anim.Visible=false
end)
client.OnUserRegistered:connect(function(self,nick)
	header.text="Login/Register (Register Success!)"
	anim.Visible=false
end)
client.OnNoUserWithName:connect(function(self,nick)
	header.text="Login/Register (No User with that name!)"
	anim.Visible=false
end)
client.OnPasswordRequest:connect(function(self)
	header.text="Login/Register (Password request sent!)"
	anim.Visible=false
end)
gui.ff.BorderSize=0
login=gui:newFrame("Login",0,0,0,0,0,0,1,1)
login.Color=Color.Black
header=login:newTextLabel("Login/Register",0,10,0,20,0,0,1)
header.TextColor=Color.White
header:setNewFont(20)
header.Visibility=0
username=login:newTextBox("","Username",11,52,-22,35,0,0,1)
t1=username:newTextLabel("Username",0,10,0,30,0,-1,1)
password=login:newTextBox("","Password",11,117,-22,35,0,0,1)
password.hidden=true
t2=password:newTextLabel("Password",0,10,0,30,0,-1,1)
Login=password:newTextButton("Login",0,10,100,30,0,1)
Login.Color=Color.Green
Register=Login:newTextButton("Register",10,0,100,30,1)
Register.Color=Color.Blue
nickname=login:newTextBox("","Nick",11,182,-22,35,0,0,1)
nickname.Visible=false
t3=nickname:newTextLabel("Nickname",0,10,0,30,0,-1,1)
email=login:newTextBox("","Email",11,247,-22,35,0,0,1)
email.Visible=false
t4=email:newTextLabel("Email",0,10,0,30,0,-1,1)
Back=email:newTextButton("Back",0,10,100,30,0,1)
Back.Color=Color.Red
DoRegister=Back:newTextButton("Register",10,0,100,30,1)
DoRegister.Color=Color.Blue
Login:OnReleased(function(b,self)
	client:logIn(username.text,password.ttext)
	anim.Visible=true
end)
Register:OnReleased(function(b,self)
	Login.Visible=false
	email.Visible=true
	nickname.Visible=true
end)
Back:OnReleased(function(b,self)
	Login.Visible=true
	nickname.Visible=false
	email.Visible=false
end)
DoRegister:OnReleased(function(b,self)
	client:register(username.text,password.ttext,nickname.text,{email=email.text})
	Login.Visible=true
	nickname.Visible=false
	email.Visible=false
	Register.Visible=false
end)
gui.massMutate({
	"setRoundness(10,10,360)",
	Tween=1,
	XTween=-3,
},Login,Register,Back,DoRegister)
gui.massMutate({
	Visibility=0,
	TextFormat="left",
	TextColor=Color.White,
},t1,t2,t3,t4)
gui.massMutate({
	"setRoundness(5,5,360)",
	Visibility=1,
	TextFormat="left",
	Tween=4,
	Color=Color.White,
	XTween=4,
},username,password,nickname,email)
client.OnChatRecieved(function(user,msg,isself) -- hook to grab chat data
	AG.holder:AddChatBubble(user,msg,isself)
end)
client.OnPrivateChatRecieved(function(user,msg,USERID) -- hook to grab chat data
	print("Matching: ",app[USERID],USERID)
	local lastCFrame=CFrame
	if app[USERID] then
		CFrame=app[USERID]
		--local c=AC.holder:getChildren()
		--for i=1,#c do
		--	c[i].Visible=false
		--end
		--CFrame.Visible=true
		--local c=Chatting:getChildren()
		--for i=1,#c do
		--	c[i].Color=Color.Yellow
		--end
		--CFrame.button.Color=Color.Green
	end
	AC:PopulateChat(user,msg)
	CFrame=lastCFrame -- reset cframe after stuff has been done
end)
function love.wheelmoved(x, y) -- handle scrolling
	if CFrame==nil then return end
	local c=CFrame.holder:getChildren()
	if y > 0 then
		CFrame.holder.offset.pos.y=CFrame.holder.offset.pos.y+10
	elseif y < 0 then
		CFrame.holder.offset.pos.y=CFrame.holder.offset.pos.y-10
	end
	if CFrame.holder.offset.pos.y>0 then
		CFrame.holder.offset.pos.y=0
	elseif CFrame.holder.offset.pos.y<-(#c*35) then
		CFrame.holder.offset.pos.y=-(#c*35)
	end
end
function INIT()
	love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
	app=gui:newImageLabel("bg.jpg",0,0,0,0,0,0,1,1)
	app.PrivateChats={}
	app.PrivateChatsRef={}
	app.ServerUpdate=multi:newAlarm(30)-- every 30 seconds
	app.ServerUpdate:OnRing(function(alarm)
		client:getUserList()
		alarm:Reset()
	end)
	header=app:newFrame("Header",0,0,0,60,0,0,1)
	header:ApplyGradient{Color.Black,Color.Lighten(Color.Black,.10)}
	header.BorderSize=0
	loggedInAs=header:newTextLabel("Logged in as: "..MY_Name,-250,0,250,20,1)
	loggedInAs.TextColor=Color.White
	loggedInAs.Tween=2
	loggedInAs.Visibility=0
	Options=header:newFrame("OptionHolder",0,0,0,30,0,1,1)
	Options.Color=Color.Lighten(Color.Black,.10)
	Options.BorderSize=0
	Online=Options:newTextLabel("Online",0,0,0,0,2/3,0,1/3,1)
	CChat=Options:newTextLabel("Private Chats",0,0,0,0,0,0,1/3,1)
	Global=Options:newTextLabel("Global Chat",0,0,0,0,1/3,0,1/3,1)
	app["Online"]=app:newFrame(0,90,0,-150,0,0,1,1)
	AO=app["Online"]
	--Online.Visible=false
	AO.holder=AO:newFrame("Holder",0,0,0,0,0,0,1,1)
	AO.holder.Visibility=0
	app["Private Chats"]=app:newFrame(0,90,0,-90,0,0,1,1)
	AC=app["Private Chats"]
	AC.holder=AC:newFrame("Holder",0,0,0,0,.4,0,.6,1)
	AC.holder.Visibility=0
	AC.CurrentUSERID=""
	AC.CurrentNick=""
	Chatting=AC:newFrame("Chatting",0, 0, 0, 0, 0 ,0 ,.4 ,1)
	Chatting.Color=Color.Lighten(Color.Black,.10)
	app["Global Chat"]=app:newFrame(0,90,0,-150,0,0,1,1)
	AG=app["Global Chat"]
	AG.holder=AG:newFrame("Holder",0,0,0,0,0,0,1,1)
	AG.holder.Visibility=0
	AC.lastBubbleHeight=0
	AG.holder.lastBubbleHeight=0
	function AC:sendChat(msg)
		--
	end
	function AG.holder:AddChatBubble(user,txt,USERID)
		local msg=user..": "..txt
		local width, wrappedtext = _defaultfont:getWrap(msg, math.floor(app.width/2)-10)
		local height = _defaultfont:getHeight()
		local bubble=self:newTextLabel("",0,self.lastBubbleHeight+5,math.floor(app.width/2),#wrappedtext*height+6)
		bubble.TFrame=bubble:newTextLabel(msg,8,0,-16,0,0,0,1,1)
		bubble.TFrame.Visibility=0
		bubble.TFrame.TextFormat="left"
		bubble.TFrame.Tween=-4
		bubble.TFrame.TextColor=Color.White
		bubble.Color=Color.White
		bubble:setRoundness(5,5,360)
		bubble.Visibility=.5
		bubble.Color=Color.Black
		if user==MY_Name then
			bubble.TFrame.text=bubble.TFrame.text:gsub("("..user.."):","You:")
			bubble:anchorRight(1)
		end
		self.lastBubbleHeight=self.lastBubbleHeight+#wrappedtext*height+11
		if self.lastBubbleHeight>self.height-20 then
			self.offset.pos.y=-(self.lastBubbleHeight-(self.height-20))
		end
	end
	function AG:sendChat(msg)
		client:sendChat(MY_Name,msg)
	end
	function AC:PopulateChat(user,msg,isself)
		if CFrame.IsPChat then
			local width, wrappedtext = _defaultfont:getWrap(msg, math.floor((CFrame.width)/2))
			local height = _defaultfont:getHeight()
			local bubble;
			if #wrappedtext>1 then
				bubble=CFrame:newTextLabel("",0,CFrame.lastBubbleHeight+5,0,(#wrappedtext+1)*height+6,0,0,.5)
			else
				bubble=CFrame:newTextLabel("",0,CFrame.lastBubbleHeight+5,0,(#wrappedtext)*height+6,0,0,.5)
			end
			bubble.TFrame=bubble:newTextLabel(msg,8,0,-16,0,0,0,1,1)
			bubble.TFrame.Visibility=0
			bubble.TFrame.TextFormat="left"
			bubble.TFrame.Tween=-4
			bubble.TFrame.TextColor=Color.White
			bubble.Color=Color.White
			bubble:setRoundness(5,5,360)
			bubble.Visibility=.5
			bubble.Color=Color.Black
			if isself then
				bubble.TFrame.text="You: "..msg
				bubble:anchorRight(1)
			else
				bubble.TFrame.text=CFrame.Nick..": "..msg
			end
			print(#wrappedtext)
			if #wrappedtext>1 then
				CFrame.lastBubbleHeight=CFrame.lastBubbleHeight+(#wrappedtext+1)*height+11
			else
				CFrame.lastBubbleHeight=CFrame.lastBubbleHeight+(#wrappedtext)*height+11
			end
			if CFrame.lastBubbleHeight>CFrame.height-20 then
				CFrame.offset.pos.y=-(CFrame.lastBubbleHeight-(self.height-20))
			end
		end
	end
	CFrame=nil
	client.OnUserList(function(list)
		if input.Visible then
			c=0
			local collections={}
			local childs=AC.holder:getChildren()
			for i=1,#childs do
				collections[childs[i].Name]=childs[i]
			end
			for i,v in pairs(list) do
				collections[v]=nil
				if i~=MY_Name and not(AC.holder.Children[v]) then
					local temp=Chatting:newTextLabel(i,0,20*(c+#Chatting:getChildren()),0,20,0,0,1)
					c=c+1
					temp:setRoundness(7,7,360)
					temp.Color=Color.Yellow
					temp.Tween=-4
					temp.USERID=v
					temp.link=AC.holder:newFrame(v,0,0,0,0,0,0,1,1)
					temp.link.Visibility=0
					app[v]=temp.link
					temp.link.Visible=false
					temp.link.USERID=v
					temp.link.Nick=i
					temp.link.holder=temp.link
					temp.link.button=temp
					function temp.link:sendChat(txt)
						AC:PopulateChat("",txt,true)
						client:sendChatTo(MY_Name,self.USERID,txt)
					end
					temp.link.IsPChat=true
					temp.link.lastBubbleHeight=0
					temp:OnReleased(function(b,self)
						CFrame=self.link
						local c=Chatting:getChildren()
						for i=1,#c do
							c[i].Color=Color.Yellow
						end
						temp.Color=Color.Green
						local c=AC.holder:getChildren()
						for i=1,#c do
							c[i].Visible=false
						end
						self.link.Visible=true
					end)
				end
			end
			for i,v in pairs(collections) do
				collections[i].button:Destroy()
				collections[i]:Destroy()
				AC.holder.Children[i]=nil
			end
			local c=Chatting:getChildren()
			for i=1,#c do
				c[i]:SetDualDim(0,20*(i-1),0,20,0,0,1)
			end
		else
			anim.Visible=false
			local c=AO.holder:getChildren()
			for i=1,#c do
				c[i]:Destroy()
			end
			c=0
			for i,v in pairs(list) do
				if i~=MY_Name then
					local temp=AO.holder:newTextLabel(i,0,(c)*35,0,30,0,0,.5)
					c=c+1
					temp.USERID=v
					temp:setRoundness(5,5,360)
					temp.Color=Color.dark_gray
					temp.Tween=2
					temp:OnReleased(function(b,self)
						table.insert(app.PrivateChats,{i,self.USERID})
					end)
				end
			end
		end
	end)
	function AO:Act()
		CFrame=self
		anim.Visible=true
		input.Visible=false
		client:getUserList()
	end
	function AC:Act()
		input.Visible=true
		CFrame=self
		input:setDualDim(0,-60,0,60,.4,1,.6)
		input:setRoundness(nil,nil,nil)
		client:getUserList()
	end
	function AG:Act()
		input.Visible=true
		CFrame=self
		input:setDualDim(0,-60,0,60,0,1,1)
		input:setRoundness(10,10,360)
	end
	function app:hideOptions()
		gui.massMutate({
			Visible=false,
		},app["Online"],app["Private Chats"],app["Global Chat"])
	end
	gui.massMutate({
		Visibility=0,
		ClipDescendants=true,
		Visible=false,
	},app["Online"],app["Private Chats"],app["Global Chat"])
	gui.massMutate({
		Tween=2,
		Visibility=0,
		TextColor=Color.Darken(Color.White,.3),
		"setNewFont(18)",
		[[OnEnter(function(self)
			self.TextColor=Color.White
		end)]],
		[[OnExit(function(self)
			self.TextColor=Color.Darken(Color.White,.3)
		end)]],
		[[OnReleased(function(b,self)
			app:hideOptions()
			app[self.text].Visible=true
			app[self.text]:Act()
		end)]],
	},Online,CChat,Global)
	textDisp=header:newTextLabel("Chats",10,15,100,30)
	textDisp.TextFormat="left"
	textDisp:setNewFont(28)
	textDisp.TextColor=Color.White
	textDisp.Visibility=0
	input=app:newFrame("InputHolder",0,-60,0,60,0,1,1)
	input:anchorRight(1)
	input.Visibility=1
	input.BorderSize=0
	input:setRoundness(10,10,360)
	input:ApplyGradient{Color.Black,Color.Lighten(Color.Black,.10)}
	input.Visible=false
	textbox=input:newTextBox("",11,14,-22,-25,0,0,1,1)
	textbox:setRoundness(5,5,360)
	textbox.Visibility=1
	textbox.TextFormat="left"
	textbox.Tween=4
	textbox.Color=Color.White
	textbox.XTween=4
	textbox.ClipDescendants=true
	input:OnUpdate(function(self)
		local width, wrappedtext = _defaultfont:getWrap(textbox.text, textbox.width)
		local height = _defaultfont:getHeight()
		if #wrappedtext==0 then
			input:SetDualDim(0,-60,0,60,0,1,1)
		else
			input:SetDualDim(0,-60-((#wrappedtext-1)*(height)),0,60+((height)*(#wrappedtext-1)),0,1,1)
		end
	end)
	textbox:OnEnter(function(self,txt)
		CFrame:sendChat(txt)
		self.text=""
		self.ttext=""
	end)
	AG.Visible=true
	AG:Act()
end
--must be last object created!
anim=gui:newAnim("loading",.01, 0, 0, 41, 39)
anim.Visible=false
anim:OnAnimEnd(function(self)
	self:Reset()
	self:Resume()
end)
anim:OnUpdate(function(self)
	self:centerX()
	self:centerY()
end)
--~ bubble=gui:newFrame("Test",100,100,100,100)

