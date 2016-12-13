gui.LoadAll("Interface")
if not client then
	-- handle client not being created!
else
	client.OnUserLoggedIn:connect(function(self,data)
		lMenu.bar.text="Logged In!"
		lMenu.anim.Visible=false
	end)
	client.OnBadLogin:connect(function(self)
		lMenu.bar.text="Pass/User incorrect!"
		lMenu.anim.Visible=false
	end)
	client.OnUserAlreadyRegistered:connect(function(self,nick)
		lMenu.bar.text="Username Taken!"
		lMenu.anim.Visible=false
	end)
	client.OnUserAlreadyLoggedIn:connect(function(self)
		lMenu.bar.text="Already logged in!"
		lMenu.anim.Visible=false
	end)
	client.OnUserRegistered:connect(function(self,nick)
		lMenu.bar.text="Register Success!"
		lMenu.anim.Visible=false
	end)
	client.OnNoUserWithName:connect(function(self,nick)
		lMenu.bar.text="No User with that name!"
		lMenu.anim.Visible=false
	end)
	client.OnPasswordRequest:connect(function(self)
		lMenu.bar.text="Password request sent!"
		lMenu.anim.Visible=false
	end)
end
--gui.setBG("fire.jpg")
--Login Windows
lMenu=gui:newFrame(0,0,200,100)
lMenu.ClipDescendants=true
lMenu:ApplyGradient{Color.Lighten(Color.Blue,.40),Color.Lighten(Color.Blue,.25),direction="vertical"}
lMenu.bar=lMenu:newTextLabel("","",0,0,0,20,0,0,1)
lMenu.bar:ApplyGradient{Color.Blue,Color.Darken(Color.Blue,.25)}
lMenu.bar.TextColor=Color.Lighten(Color.Red,.25)
lMenu.user=lMenu:newTextBox("username","username",5,25,190,20)
lMenu.pass=lMenu:newTextBox("password","password",5,50,190,20)
lMenu.email=lMenu:newTextBox("email","email",5,100,190,20)
lMenu.nick=lMenu:newTextBox("nick","nick",5,75,190,20)
lMenu.user.TextFormat="left"
lMenu.pass.TextFormat="left"
lMenu.email.TextFormat="left"
lMenu.nick.TextFormat="left"
lMenu.bar.TextFormat="left"
lMenu.bar.Tween=-3
lMenu.user.Tween=-3
lMenu.pass.Tween=-3
lMenu.email.Tween=-3
lMenu.nick.Tween=-3
lMenu.user.ClearOnFocus=true
lMenu.pass.ClearOnFocus=true
lMenu.email.ClearOnFocus=true
lMenu.nick.ClearOnFocus=true
lMenu.user:ApplyGradient{Color.Darken(Color.Blue,.20),Color.Blue,direction="vertical"}
lMenu.pass:ApplyGradient{Color.Darken(Color.Blue,.20),Color.Blue,direction="vertical"}
lMenu.pass.hidden=true
lMenu.email:ApplyGradient{Color.Darken(Color.Blue,.20),Color.Blue,direction="vertical"}
lMenu.nick:ApplyGradient{Color.Darken(Color.Blue,.20),Color.Blue,direction="vertical"}
lMenu.hider=lMenu:newFrame("",1,-29,-2,28,0,1,1)
lMenu.hider.BorderSize=0
lMenu.hider:ApplyGradient{Color.Lighten(Color.Blue,.40),Color.Lighten(Color.Blue,.25),direction="vertical"}
lMenu.Login=lMenu:newTextButton("Login","Login",5,-25,90,20,0,1)
lMenu.Register=lMenu:newTextButton("Register","Register",105,-25,90,20,0,1)
lMenu.Login.Tween=-3
lMenu.Register.Tween=-3
lMenu.Login.Color=Color.Green
lMenu.Register.Color=Color.Red
lMenu.step=multi:newTStep(1,80,1,.01)
lMenu.step:Pause()
lMenu.step.link=lMenu
lMenu.step:OnStep(function(pos,self)
	if self.link.height<=150 then
		self.link:SetDualDim(nil,nil,nil,self.link.height+1)
		lMenu:centerY()
	end
	print(self.link.height)
end)
lMenu.step2=multi:newTStep(1,80,1,.01)
lMenu.step2:Pause()
lMenu.step2.link=lMenu
lMenu.step2:OnStep(function(pos,self)
	if self.link.height>=101 then
		self.link:SetDualDim(nil,nil,nil,self.link.height-1)
		lMenu:centerY()
	end
	print(self.link.height)
end)
lMenu.Register:OnReleased(function(b,self)
	if self.Parent.Login.text=="Back" then
		print(lMenu.pass.ttext)
		client:register(lMenu.user.text,lMenu.pass.ttext,lMenu.nick.text,{email=lMenu.email.text})
		lMenu.anim.Visible=true
	else
		self.Parent.Login.text="Back"
		self.Parent.Login.Color=Color.saddle_brown
		self.Parent.nick.text="nick"
		self.Parent.step:Update()
	end
end)
lMenu.Login:OnReleased(function(b,self)
	if self.text=="Back" then
		self.text="Login"
		self.Color=Color.Green
		self.Parent.step2:Update()
	else
		print(lMenu.pass.ttext)
		client:logIn(lMenu.user.text,lMenu.pass.ttext)
		lMenu.anim.Visible=true
	end
end)
lMenu:centerX()
lMenu:centerY()
lMenu.anim=lMenu:newAnim("loading",.01, 0, 0, 41, 39)
lMenu.anim:OnAnimEnd(function(self)
	self:Reset()
	self:Resume()
end)
lMenu.anim:OnUpdate(function(self)
	self:centerX()
	self:centerY()
end)
lMenu.anim.Visible=false
