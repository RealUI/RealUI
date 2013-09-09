local addon = DXE

local SM = addon.SM
local Media = {}
addon.Media = Media

-------------------------
-- DB
-------------------------

local pfl
local function RefreshProfile(db) 
	pfl = db.profile 
	addon:NotifyAllMedia()
end
addon:AddToRefreshProfile(RefreshProfile)

-------------------------
-- Colors
-------------------------

do
	local Colors = {
		BLACK = 			{r=0,  	g=0,		b=0},
		BLUE = 			{r=0,  	g=0, 		b=1},
		BROWN = 			{r=.65,  g=.165,  b=.165},
		CYAN = 			{r=0,		g=1,		b=1},
		DCYAN = 			{r=0,  	g=.6, 	b=.6},
		GOLD = 			{r=1,		g=0.843,	b=0},
		GREEN = 			{r=0,  	g=0.5,	b=0},
		GREY = 			{r=.3, 	g=.3, 	b=.3},
		INDIGO = 		{r=0,		g=0.25,	b=0.71},
		MAGENTA =   	{r=1, 	g=0, 		b=1},
		MIDGREY = 		{r=.5, 	g=.5, 	b=.5},
		ORANGE = 		{r=1,	 	g=0.5,	b=0},
		PEACH = 			{r=1,		g=0.9,	b=0.71},
		PINK = 			{r=1,		g=0,		b=1},
		PURPLE = 		{r=0.627,g=0.125,	b=0.941},
		RED = 			{r=0.9,	g=0,		b=0},
		TAN = 			{r=0.82,	g=0.71,	b=0.55},
		TEAL = 			{r=0,		g=0.5,	b=0.5},
		TURQUOISE =  	{r=.251, g=.878,  b=.816},
		VIOLET = 		{r=0.55, g=0,     b=1},
		WHITE = 			{r=1,  	g=1,		b=1},
		YELLOW = 		{r=1,	 	g=1,		b=0},
		NEWBLUE = {r=0.22, g=0.34, b=0.46},
	}
	Media.Colors = Colors

	--[[
	Grabbed by Localizer

	L["BLACK"] 	L["BLUE"] 		L["BROWN"]	 	L["CYAN"]
	L["DCYAN"] 	L["GOLD"] 		L["GREEN"] 		L["GREY"]
	L["INDIGO"] L["MAGENTA"] 	L["MIDGREY"] 	L["ORANGE"]
	L["PEACH"] 	L["PINK"] 		L["PURPLE"] 	L["RED"]
	L["TAN"] 	L["TEAL"] 		L["TURQUOISE"] L["VIOLET"]
	L["WHITE"] 	L["YELLOW"]

	]]
end

-------------------------
-- Sounds
-------------------------

do
	local Sounds = {}

	local List = {
		["Bell Toll Alliance"] = "Sound\\Doodad\\BellTollAlliance.wav",
		["Bell Toll Horde"] = "Sound\\Doodad\\BellTollHorde.wav",
		["Bell"] = "Sound\\Doodad\\BellTollNightElf.wav",
		["Bell 2"] = "Sound\\Doodad\\BoatDockedWarning.wav",
		["Bell Toll Horde"] = "Sound\\Doodad\\BellTollHorde.wav",
		["Low Mana"] = "Interface\\AddOns\\DXE\\Sounds\\LowMana.mp3",
		["Low Health"] = "Interface\\AddOns\\DXE\\Sounds\\LowHealth.mp3",
		["Zing Alarm"] = "Interface\\AddOns\\DXE\\Sounds\\ZingAlarm.mp3",
		["Wobble"] = "Interface\\Addons\\DXE\\Sounds\\Wobble.mp3",
		["Bottle"] = "Interface\\AddOns\\DXE\\Sounds\\Bottle.mp3",
		["Lift Me"] = "Interface\\AddOns\\DXE\\Sounds\\LiftMe.mp3",
		["Neo Beep"] = "Interface\\AddOns\\DXE\\Sounds\\NeoBeep.mp3",
		["PvP Flag Taken"] = "Sound\\Spells\\PVPFlagTaken.wav",
		["Bad Press"] = "Sound\\Spells\\SimonGame_Visual_BadPress.wav",
		["Run Away"] = "Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav",
		["Come Closer"] = "Sound\\Creature\\KelidanTheBreaker\\HELL_Keli_Burn01.wav",
		["FF1 Victory"] = "Interface\\AddOns\\DXE\\Sounds\\FF1_Victory.mp3",
		["Beware"] = "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav",
		["Raid Warning"] = "Sound\\Interface\\RaidWarning.wav",
		["Instrumental Attention"] = "Interface\\AddOns\\DXE\\Sounds\\Attention04.mp3",
		["War Drums"] = "Sound\\Event Sounds\\Event_wardrum_ogre.wav",
		["Destruction"] = "Sound\\Creature\\KilJaeden\\KILJAEDEN02.wav",
		["Not Prepared"] = "Sound\\Creature\\Illidan\\BLACK_Illidan_04.wav",
		["Raid Boss Whisper"] = "Sound\\Interface\\UI_RaidBossWhisperWarning.ogg",
		["Adds Incoming"] = "Interface\\AddOns\\DXE\\Sounds\\adds.mp3",
	}
	local sound_defaults = addon.defaults.profile.Sounds

	function Sounds:GetFile(id) 
		return id == "None" and "Interface\\Quiet.mp3" or SM:Fetch("sound",sound_defaults[id] and pfl.Sounds[id] or pfl.CustomSounds[id])
	end

	Media.Sounds = Sounds
	for name,file in pairs(List) do SM:Register("sound",name,file) end
end

-------------------------
-- FONTS
-------------------------

do
	SM:Register("font", "Bastardus Sans", "Interface\\AddOns\\DXE\\Fonts\\BS.ttf")
	SM:Register("font", "Courier New", "Interface\\AddOns\\DXE\\Fonts\\CN.ttf")
	SM:Register("font", "Franklin Gothic Medium", "Interface\\AddOns\\DXE\\Fonts\\FGM.ttf")
	SM:Register("font", "Prototype", "Interface\\AddOns\\DXE\\Fonts\\Prototype.ttf")
	SM:Register("font", "accid", "Interface\\AddOns\\DXE\\Fonts\\accid.ttf")
	
	SM:Register("statusbar", "HalD", [[Interface\AddOns\DXE\Textures\HalD.tga]])
	SM:Register("statusbar", "Minimalist", [[Interface\AddOns\DXE\Textures\Minimalist.tga]])
	SM:Register("border", "IshBorder", [[Interface\AddOns\DXE\Textures\IshBorder.tga]])
end



-------------------------
-- GLOBALS
-------------------------
local bgBackdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", insets = {}}
local borderBackdrop = {}

function addon:NotifyAllMedia()
	addon:NotifyBarTextureChanged()
	addon:NotifyFontChanged()
	addon:NotifyBorderChanged()
	addon:NotifyBorderColorChanged()
	addon:NotifyBorderEdgeSizeChanged()
	addon:NotifyBackgroundColorChanged()
	addon:NotifyBackgroundInsetChanged()
	addon:NotifyBackgroundTextureChanged()
end

do
	local reg = {}
	function addon:RegisterFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.Font),size,flags)
	end

	function addon:NotifyFontChanged(fontFile)
		local font = SM:Fetch("font",pfl.Globals.Font)
		for _,fontstring in ipairs(reg) do
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterTimerFontString(fontstring,size,flags)
		reg[#reg+1] = fontstring
		fontstring:SetFont(SM:Fetch("font",pfl.Globals.TimerFont),size,flags)
	end

	function addon:NotifyTimerFontChanged(fontFile)
		local font = SM:Fetch("font",fontFile)
		for _,fontstring in ipairs(reg) do 
			local _,size,flags = fontstring:GetFont()
			fontstring:SetFont(font,size,flags)
		end
	end
end

do
	local reg = {}
	function addon:RegisterStatusBar(statusbar)
		reg[#reg+1] = statusbar
		statusbar:SetStatusBarTexture(SM:Fetch("statusbar",pfl.Globals.BarTexture))
		statusbar:GetStatusBarTexture():SetHorizTile(false)
	end

	function addon:NotifyBarTextureChanged(name)
		local texture = SM:Fetch("statusbar",pfl.Globals.BarTexture)
		for _,statusbar in ipairs(reg) do statusbar:SetStatusBarTexture(texture) end
	end
end

do
	local reg = {}
	function addon:RegisterBorder(frame)
		reg[#reg+1] = frame
		local r,g,b,a = unpack(pfl.Globals.BorderColor)
		borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)
		borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
		frame:SetBackdrop(borderBackdrop)
		frame:SetBackdropBorderColor(r,g,b,a)
	end

	function addon:NotifyBorderChanged()
		borderBackdrop.edgeFile = SM:Fetch("border",pfl.Globals.Border)
		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderEdgeSizeChanged()
		borderBackdrop.edgeSize = pfl.Globals.BorderEdgeSize
		for _,frame in ipairs(reg) do 
			frame:SetBackdrop(borderBackdrop)
		end
		-- setting backdrop resets color
		addon:NotifyBorderColorChanged()
	end

	function addon:NotifyBorderColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BorderColor)
		for _,frame in ipairs(reg) do 
			frame:SetBackdropBorderColor(r,g,b,a)
		end
	end
end

do
	local reg = {}

	function addon:RegisterBackground(widget,pane)
--	print("teste",widget:GetName(),pane)
	--	if widget:GetName() ~= "DXEPane" then
			reg[#reg+1] = widget
			local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
			bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
			local inset = pfl.Globals.BackgroundInset
			bgBackdrop.insets.left = inset
			bgBackdrop.insets.right = inset
			bgBackdrop.insets.top = inset
			bgBackdrop.insets.bottom = inset
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
				widget:SetBackdropColor(r,g,b,a)
			elseif widget:IsObjectType("Texture") then
				widget:SetTexture(bgBackdrop.bgFile)
				widget:SetVertexColor(r,g,b,a)
			end
	end


	function addon:NotifyBackgroundTextureChanged()
		bgBackdrop.bgFile = SM:Fetch("background",pfl.Globals.BackgroundTexture)
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			elseif widget:IsObjectType("Texture") then
				widget:SetTexture(bgBackdrop.bgFile)
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundInsetChanged()
		local inset = pfl.Globals.BackgroundInset
		bgBackdrop.insets.left = inset
		bgBackdrop.insets.right = inset
		bgBackdrop.insets.top = inset
		bgBackdrop.insets.bottom = inset
		for _,widget in ipairs(reg) do
			if widget:IsObjectType("Frame") then
				widget:SetBackdrop(bgBackdrop)
			--elseif widget:IsObjectType("Texture") then
			end
		end
		-- setting backdrop resets color
		self:NotifyBackgroundColorChanged()
	end

	function addon:NotifyBackgroundColorChanged()
		local r,g,b,a = unpack(pfl.Globals.BackgroundColor)
		for _,widget in ipairs(reg) do 
			if widget:IsObjectType("Frame") then
				widget:SetBackdropColor(r,g,b,a)
			elseif widget:IsObjectType("Texture") then
				widget:SetVertexColor(r,g,b,a)
			end
		end
	end
end
