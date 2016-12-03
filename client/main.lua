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
client=net:newTCPClient("localhost",12345) -- Connects to the server
if type(client)=="boolean" then error("Please run the server file first!") end
client.OnChatRecieved(function(user,msg,isself) -- hook to grab chat data
	Chat:AddChatBubble(user,msg,isself)
end)
--gui.enableAutoWindowScaling(true) -- allows mobile support. Not needed for PC use
nameframe=gui:newFrame("",0,0,200,100)
nameframe.Color=Color.Lighten(Color.Brown,.15)
nameframe:setRoundness(15,15,360)
nameframe:centerX()
nameframe:centerY()
namer=nameframe:newTextBox("Please enter a name to use!",0,0,180,30)
namer:centerX()
namer:centerY()
namer.Color=Color.tan
namer.ClearOnFocus=true
namer:setRoundness(5,5,360)
namer:OnEnter(function(self,txt)
	MY_Name=txt:gsub("%s","_")
	InitEngine()
	nameframe:Destroy()
	gui.ff:Destroy()
end)
gui.ff.C1=45
gui.ff.C2=193
gui.ff.C3=92
gui.ff.C1m=-1
gui.ff.C2m=1
gui.ff.C3m=-1
gui.ff.Color=Color.Blue
func=multi:newFunction(function(l,self) -- not needed just adds color change when chosing a name
	l:hold(.05)
	self.C1=self.C1+(({1,2,3})[math.random(1,3)]*self.C1m)
	self.C2=self.C2+(({1,2,3})[math.random(1,3)]*self.C2m)
	self.C3=self.C3+(({1,2,3})[math.random(1,3)]*self.C3m)
	if self.C1>255 then self.C1=254 self.C1m=-1 end
	if self.C2>255 then self.C2=254 self.C2m=-1 end
	if self.C3>255 then self.C3=254 self.C3m=-1 end
	if self.C1<0 then self.C1=1 self.C1m=1 end
	if self.C2<0 then self.C2=1 self.C2m=1 end
	if self.C3<0 then self.C3=1 self.C3m=1 end
	self.Color=Color.new(self.C1,self.C2,self.C3)
end)
function love.wheelmoved(x, y) -- handle scrolling
	if mainapp then else return end
    if y > 0 then
        Chat.bubbles:SetDualDim(nil,Chat.bubbles.y+10)
    elseif y < 0 then
        Chat.bubbles:SetDualDim(nil,Chat.bubbles.y-50)
    end
	if Chat.bubbles.offset.pos.y>0 then
		Chat.bubbles.offset.pos.y=0
	end
	print(Chat.bubbles.offset.pos.y)
end
gui.ff:OnUpdate(func)
function InitEngine()
	mainapp=gui:newFrame("",0,0,0,0,0,0,1,1) -- creates a frame that takes up the enitre window
	mainapp.Color=Color.Lighten(Color.Brown,.25)
	mainapp.BorderSize=0
	mainapp.header=mainapp:newTextLabel("Now chatting as: "..MY_Name,1,-10,-2,30,0,0,1) -- creates the header for the app
	mainapp.header:setRoundness(15,15,360)
	mainapp.header.Tween=7 -- moves the text up by a factor of 3 pixels
	mainapp.header.Color=Color.Lighten(Color.Blue,.25) -- Sets the Color of the header object to light blue
	mainapp.chatFrame=mainapp:newFrame("",0,21,0,-20,0,0,1,1) -- creates the chat frame where users can see the text that is sent
	mainapp.chatFrame.Color=Color.Lighten(Color.Brown,.25) -- Color stuff
	mainapp.chatFrame.ClipDescendants=true
	mainapp.chatFrame.bubbles=mainapp.chatFrame:newFrame("",0,0,0,0,0,0,1)
	mainapp.chatFrame.bubbles.Visibility=0
	Chat=mainapp.chatFrame
	Chat.lastBubbleHeight=0
	function Chat:AddChatBubble(user,txt,isself)
		local msg=user..": "..txt
		local bubble=self.bubbles:newTextLabel(msg,0,self.lastBubbleHeight+5,math.floor(mainapp.width/2),(math.ceil(#msg/24)*12)+5)
		bubble.TextFormat="left"
		bubble.XTween=2
		bubble.Tween=-4
		bubble:setRoundness(5,5,360)
		if isself then
			bubble:anchorRight(1)
		end
		self.lastBubbleHeight=self.lastBubbleHeight+(math.ceil(#msg/24)*12)+13
		if self.lastBubbleHeight>mainapp.height-60 then
			self.bubbles.offset.pos.y=-(self.lastBubbleHeight-(mainapp.height-60))
		end
	end
	mainapp.textbox=mainapp:newTextBox("",5,-35,-10,30,0,1,1) -- creates a textbox that allows the user to be able to send messages
	mainapp.textbox.TextFormat="left" -- sets the format to left hand side of screen
	mainapp.textbox.Color=Color.tan
	mainapp.textbox:setRoundness(5,5,360)
	mainapp.textbox:OnEnter(function(self,txt) -- handles the send event
		client:sendChat(MY_Name,txt) -- sends the data to the server
		self.text=""
		self.Color=Color.tan
	end)
	mainapp.textbox:OnFocus(function(self)
		self.Color=Color.Lighten(Color.tan,.25)
	end)
	mainapp.textbox.ClearOnFocus=true
	mainapp.textbox.XTween=2
	mainapp.textbox.Tween=2 -- positions the text in the text box
end
