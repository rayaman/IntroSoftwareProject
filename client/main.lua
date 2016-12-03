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
client.OnChatRecieved(function(user,msg) -- hook to grab chat data
	mainapp.chatFrame.text=mainapp.chatFrame.text..user..": "..msg.."\n"
end)
gui.enableAutoWindowScaling(true) -- allows mobile support. Not needed for PC use
function InitEngine()
	mainapp=gui:newFrame("",0,0,0,0,0,0,1,1) -- creates a frame that takes up the enitre window
	mainapp.header=mainapp:newTextLabel("Chat Program",0,0,0,20,0,0,1) -- creates the header for the app
	mainapp.header.Tween=-3 -- moves the text up by a factor of 3 pixels
	mainapp.header.Color=Color.Lighten(Color.Blue,.25) -- Sets the Color of the header object to light blue
	mainapp.chatFrame=mainapp:newTextLabel("",0,20,0,-20,0,0,1,1) -- creates the chat frame where users can see the text that is sent
	mainapp.chatFrame.Color=Color.Lighten(Color.Brown,.15) -- Color stuff
	mainapp.chatFrame.Tween=-3 -- text positioning
	mainapp.chatFrame.TextFormat="left" -- changes the text format to left hand side of screen
	mainapp.textbox=mainapp:newTextBox("",5,-35,-10,30,0,1,1) -- creates a textbox that allows the user to be able to send messages
	mainapp.textbox.TextFormat="left" -- sets the format to left hand side of screen
	mainapp.textbox.Color=Color.tan
	mainapp.textbox:setRoundness(5,5,360)
	mainapp.textbox:OnEnter(function(self,txt) -- handles the send event
		client:sendChat("NAMENOSPACE",txt) -- sends the data to the server
		self.text=""
		self.Color=Color.tan
	end)
	mainapp.textbox:OnFocus(function(self)
		self.Color=Color.Lighten(Color.tan,.25)
	end)
	mainapp.textbox.ClearOnFocus=true
	mainapp.textbox.XTween=2
	mainapp.textbox.Tween=2 -- positions the text in the text box
	--This displays the chatting frame and allows connection to the server... Look at server.lua to see the servers code
end
