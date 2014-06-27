local _, ns = ...
local alpha
local RealUIStripeOpacity = 0.5

local mediapath = "Interface\\AddOns\\FreebTip\\media\\"
local cfg = {
	-- xRUI
	font = [[Interface\AddOns\nibRealUI\Fonts\standard.ttf]],
	pixelfont = [[Interface\AddOns\nibRealUI\Fonts\pixel_small.ttf]],
	fontsize = 11, -- I'd suggest adjusting the scale instead of the fontsize
	outline = "OUTLINE",
	monochromeoutline = "MONOCHROMEOUTLINE",
	tex = mediapath.."texture",
	scale = 1, -- Scale of the tooltip. 1 = default
	
	-- point = {"BOTTOMRIGHT", -31, 192}, -- can use /freebtip or uncomment this to override SavedVars

	backdrop = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], 
	edgeSize = 1,
	insets = {top = 1, left = 1, bottom = 1, right = 1},
	},
	
	-- Background / Border / Guild - (Colors)
	bgcolor = { r=0.05, g=0.05, b=0.05, t=0.9 }, -- background
	bdrcolor = { r=0, g=0, b=0 }, -- border
	gcolor = { r=1.00, g=1.00, b=0.70}, -- guild

	you = "<You>", -- When someone is targeting you!
	boss = "??", -- Boss, Obvious. O.o
	
	-- =============================== --
	-- Config options, (true of false) --
	-- =============================== --
	
	cursor = false, -- Attach tooltip to cursor.
	hideTitles = true, -- Hide player titles on the tooltip 
	hideRealm = false, -- Hide player realm on the tooltip 
	hideIcons = true,
	hideFaction = true, -- Hide player faction on the tooltip
	hidePvP = true, -- Hide player PvP on the tooltip 
	colorborderClass = false, -- Color the tooltip border the class color of the player you are targeting / hovering over
	colorborderItem = true, -- Color the tooltip border the color of the item quility of the item you are hovering over
	Itemicons = true, -- shows the item icon in the tooltip when hovering over an item
    Itemlevel = false, -- show avg ilvl of player.
	combathide = false,     -- world objects
	combathideALL = false,  -- everything
	multiTip = true, -- show more than one linked item tooltip
	hideHealthbar = false,
	powerbar = true, -- enable power bars
	powerManaOnly = false, -- only show mana users
	showRank = false, -- show guild rank
	showTalents = true,
	tcacheTime = 900, -- talent cache time in seconds (default 15 mins)
	spellid = false,
}
ns.cfg = cfg
local style

local GetTime = GetTime
local tonumber = tonumber
local find = string.find
local format = string.format
local select = select
local _G = _G
local GameTooltip = GameTooltip
local gtSB = GameTooltipStatusBar
local InCombatLockdown = InCombatLockdown
local PVP = PVP
local FACTION_ALLIANCE = FACTION_ALLIANCE
local FACTION_HORDE = FACTION_HORDE
local LEVEL = LEVEL
local CHAT_FLAG_AFK =CHAT_FLAG_AFK
local CHAT_FLAG_DND = CHAT_FLAG_DND
local ICON_LIST = ICON_LIST
local targettext = TARGET
local DEAD = DEAD
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR

local talentcache = {}
local talenttext = SPECIALIZATION
local talentcolor = {r=1,g=1,b=1}
local INTERACTIVE_SERVER_LABEL = INTERACTIVE_SERVER_LABEL
local FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL
local COALESCED_REALM_TOOLTIP1 = string.split(FOREIGN_SERVER_LABEL, COALESCED_REALM_TOOLTIP)
local INTERACTIVE_REALM_TOOLTIP1 = string.split(INTERACTIVE_SERVER_LABEL, INTERACTIVE_REALM_TOOLTIP)

local colors = {power = {}}
for power, color in next, PowerBarColor do
	if(type(power) == 'string') then
		colors.power[power] = {color.r, color.g, color.b}
	end
end

colors.power['MANA'] = {.31,.45,.63}
colors.power['RAGE'] = {.69,.31,.31}

local classification = {
	elite = "+",
	rare = " R",
	rareelite = " R+",
}

local numberize = function(val)
	if(val >= 1e6) then
		return ("%.0fm"):format(val / 1e6)
	elseif(val >= 1e3) then
		return ("%.0fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end

local hex = function(color)
	return (color.r and format('|cff%02x%02x%02x', color.r * 255, color.g * 255, color.b * 255)) or "|cffFFFFFF"
end

local nilcolor = { r=1, g=1, b=1 }
local tapped = { r=.6, g=.6, b=.6 }

local function unitColor(unit)
	if(not unit) then unit = "mouseover" end

	local color
	if(UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		color = RAID_CLASS_COLORS[class]
	elseif(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		color = tapped
	else
		local reaction = UnitReaction(unit, "player")
		if(reaction) then
			color = FACTION_BAR_COLORS[reaction]
		end
	end

	return (color or nilcolor)
end

local function GameTooltip_UnitColor(unit)
	local color = unitColor(unit)
	if(color) then return color.r, color.g, color.b end
end

local function formatLines(self)
	for i=1, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local point, relTo, relPoint, x, y = tiptext:GetPoint()
		tiptext:ClearAllPoints()

		if(i==1) then
			tiptext:SetPoint("TOPLEFT", self, "TOPLEFT", x, y)
		else
			local key = i-1

			while(true) do
				local preTiptext = _G["GameTooltipTextLeft"..key]

				if(preTiptext and not preTiptext:IsShown()) then
					key = key-1
				else
					break
				end
			end

			tiptext:SetPoint("TOPLEFT", _G["GameTooltipTextLeft"..key], "BOTTOMLEFT", x, -2)
		end
	end
end

local function hideLines(self)
	for i=3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if(linetext) then
			if(cfg.hidePvP and linetext:find(PVP)) then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif(linetext:find(COALESCED_REALM_TOOLTIP1) or linetext:find(INTERACTIVE_REALM_TOOLTIP1)) then
				tiptext:SetText(nil)
				tiptext:Hide()

				local pretiptext = _G["GameTooltipTextLeft"..i-1]
				pretiptext:SetText(nil)
				pretiptext:Hide()

				self:Show()
			elseif(linetext:find(FACTION_ALLIANCE)) then
				if(cfg.hideFaction) then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cff7788FF"..linetext.."|r")
				end
			elseif(linetext:find(FACTION_HORDE)) then
				if(cfg.hideFaction) then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cffFF4444"..linetext.."|r")
				end
			end
		end
	end
end

local function UpdatePower(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if(self.elapsed < .25) then return end

	local unit = self.unit
	if(unit) then
		local min, max = UnitPower(unit), UnitPowerMax(unit)
		if(max ~= 0) then
			self:SetValue(min)

			local pp = numberize(min).." / "..numberize(max)
			self.text:SetText(pp)
		end
	end

	self.elapsed = 0
end

local function HidePower(powerbar)
	if(powerbar) then
		powerbar:Hide()

		if(powerbar.text) then
			powerbar.text:SetText(nil)
		end
	end
end

local function ShowPowerBar(self, unit, statusbar)
	local powerbar = _G[self:GetName().."FreebTipPowerBar"]
	if(not unit) then return HidePower(powerbar) end

	local min, max = UnitPower(unit), UnitPowerMax(unit)
	local ptype, ptoken = UnitPowerType(unit)

	if(max == 0 or (cfg.powerManaOnly and ptoken ~= 'MANA')) then
		return HidePower(powerbar)
	end

	if(not powerbar) then
		powerbar = CreateFrame("StatusBar", self:GetName().."FreebTipPowerBar", statusbar)
		powerbar:SetHeight(statusbar:GetHeight())
		powerbar:SetFrameLevel(statusbar:GetFrameLevel())
		powerbar:SetWidth(0)
		powerbar:SetStatusBarTexture(cfg.tex, "OVERLAY")
		powerbar.elapsed = 0
		powerbar:SetScript("OnUpdate", UpdatePower)

		local bg = powerbar:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints(powerbar)
		bg:SetTexture(cfg.tex)
		bg:SetVertexColor(0.3, 0.3, 0.3, 0.5)
		
		local PBG = CreateFrame("Frame", "StatusBarBG", GameTooltipFreebTipPowerBar)
		PBG:SetFrameLevel(GameTooltipFreebTipPowerBar:GetFrameLevel() - 1)
		PBG:SetPoint("TOPLEFT", -1, 1)
		PBG:SetPoint("BOTTOMRIGHT", 1, -1)
		PBG:SetBackdrop({edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1})
		PBG:SetBackdropColor(0,0,0)
		PBG:SetBackdropBorderColor(0,0,0)
		
	end
	powerbar.unit = unit

	powerbar:SetMinMaxValues(0, max)
	powerbar:SetValue(min)

	local pcolor = colors.power[ptoken]
	if(pcolor) then
		powerbar:SetStatusBarColor(pcolor[1], pcolor[2], pcolor[3])
	end

	powerbar:ClearAllPoints()
	powerbar:SetPoint("LEFT", statusbar, "LEFT", 0, -(statusbar:GetHeight()) - 1)
	powerbar:SetPoint("RIGHT", self, "RIGHT", -1, 0)

	powerbar:Show()

	if(not powerbar.text) then
		-- xRUI
		powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
			tinsert(RealUI.fontStringsTiny, powerbar.text)
		powerbar.text:SetPoint("CENTER", powerbar)
		powerbar.text:SetFont(unpack(RealUI:Font(false, "tiny")))
		powerbar.text:Show()
	end

	local pp = numberize(min).." / "..numberize(max)
	powerbar.text:SetText(pp)
	
end

local talentGUID
local talentevent = CreateFrame"Frame"

local function updateTalents(spec)
	for i=3, GameTooltip:NumLines() do
		local tiptext = _G["GameTooltipTextRight"..i]
		local linetext = tiptext:GetText()

		if(linetext and (linetext == "...")) then
			tiptext:SetText(spec)

			GameTooltip.freebHeightSet = nil
			GameTooltip:Show()	
			break
		end
	end
end

local function ShowTalents(self, unit)
	local level = UnitLevel(unit) or 0
	local canInspect = CanInspect(unit)
	if(not canInspect or level < 10) then return end

	local uGUID = UnitGUID(unit)

	if((not self.freebTalentSet and talentcache[uGUID])) then
		-- look for an empty line..
		local talentSet = false
		for i=3, self:NumLines() do
			local tiptext = _G["GameTooltipTextLeft"..i]

			if(not tiptext:IsShown()) then
				tiptext:SetText(talenttext)
				tiptext:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				tiptext:Show()

				local tipRtext = _G["GameTooltipTextRight"..i]
				tipRtext:SetText("...")
				tipRtext:SetTextColor(talentcolor.r, talentcolor.g, talentcolor.b)
				tipRtext:Show()

				talentSet = true
				break
			end
		end
		if(not talentSet) then
			self:AddDoubleLine(talenttext, ("..."), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
			talentcolor.r, talentcolor.g, talentcolor.b)
		end

		self.freebTalentSet = true
	end

	if(talentcache[uGUID]) then
		-- check to see how old the talentcache is
		if((GetTime() - talentcache[uGUID].time) > cfg.tcacheTime) then
			talentcache[uGUID] = nil

			return ShowTalents(self, unit)
		end

		local talname = talentcache[uGUID].talent
		updateTalents(talname)
	else
		if(not canInspect) or (InspectFrame and InspectFrame:IsShown()) then return end
		talentGUID = uGUID
		talentevent:RegisterEvent"INSPECT_READY"

		NotifyInspect(unit)
	end
end

talentevent:SetScript("OnEvent", function(self, event, arg1)
	if(event == "INSPECT_READY") then
		local activeSpec = GetInspectSpecialization("mouseover")
		local name = activeSpec and select(2, GetSpecializationInfoByID(activeSpec))

		if(name) then
			talentcache[arg1] = {talent = name,time = GetTime()}
			ShowTalents(GameTooltip, "mouseover")

			if InspectFrame and (not InspectFrame:IsShown()) then
				ClearInspectPlayer()
			end
		end
	end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
	self.freebTalentSet = false
	self.freebHeightSet = nil
end)

-- Time to add those faction icons in, for Horde and Alliance. Just for eye-candy! -WIP
-- Thanks to Azilroka, from Tukui.org
local StatusIcon = GameTooltip:CreateTexture(nil, "ARTWORK")

local function SetStatusIcon()
	local GetMouseFocus = GetMouseFocus()
	local Unit = select(2, GameTooltip:GetUnit()) or (GetMouseFocus and GetMouseFocus:GetAttribute("unit"))
	if not Unit then Unit = "mouseover" end
	if not UnitExists(Unit) then return end
	if UnitIsPlayer(Unit) and UnitIsPVP(Unit) and UnitFactionGroup(Unit) then
		StatusIcon:SetTexture(mediapath..UnitFactionGroup(Unit))
		StatusIcon:Show()
	else
		StatusIcon:Hide()
	end
	StatusIcon:SetPoint("CENTER", GameTooltip, "LEFT", 0, 0)
	--StatusIcon:SetSize(30, 30)
end

GameTooltip:HookScript("OnTooltipSetUnit", SetStatusIcon)
GameTooltip:HookScript("OnHide", function() StatusIcon:Hide() end)

local function PlayerTitle(self, unit)
	local unitName
	if(cfg.hideTitles and cfg.hideRealm) then
		unitName = UnitName(unit)
	elseif(cfg.hideTitles) then
		unitName = GetUnitName(unit, true)
	elseif(cfg.hideRealm) then
		unitName = UnitPVPName(unit) or UnitName(unit)
	end

	if(unitName) then GameTooltipTextLeft1:SetText(unitName) end

	local relationship = UnitRealmRelationship(unit)	
	if(relationship == LE_REALM_RELATION_VIRTUAL) then
		self:AppendText(("|cffcccccc%s|r"):format(INTERACTIVE_SERVER_LABEL))
	end

	local status = UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or 
	not UnitIsConnected(unit) and "<DC>"

	if(status) then
		self:AppendText((" |cff00cc00%s|r"):format(status))
	end
end

local function PlayerGuild(self, unit)
	local unitGuild, unitRank = GetGuildInfo(unit)
	if(unitGuild) then
		local text2 = GameTooltipTextLeft2
		local str = hex(cfg.gcolor).."<%s> |cff00E6A8%s|r"
		local unitRank = cfg.showRank and unitRank or ""

		text2:SetFormattedText(str, unitGuild, unitRank)
	end
end

local function SetStatusBar(self, unit)
	if(gtSB:IsShown()) then
		if(cfg.hideHealthbar) then
			GameTooltipStatusBar:Hide()
			return
		end

		if(cfg.powerbar) then
			ShowPowerBar(self, unit, gtSB)
		end

		gtSB:ClearAllPoints()

		local gtsbHeight = gtSB:GetHeight()
		if(GameTooltipFreebTipPowerBar and GameTooltipFreebTipPowerBar:IsShown()) then
			GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, ((gtsbHeight)*2)-5)
			GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", self, -1, 0)
		else
			GameTooltipStatusBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, gtsbHeight-6)
			GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", self, -1, 0)
		end
	end

	if(unit) then
		local color = unitColor(unit)
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		GameTooltipStatusBar:SetStatusBarColor(0, .9, 0)
	end
end

GameTooltipStatusBar:SetHeight(7);

local function getTarget(unit)
	if(UnitIsUnit(unit, "player")) then
		return ("|cffff0000%s|r"):format(cfg.you)
	else
		return UnitName(unit)
	end
end

local function ShowTarget(self, unit)
	if(UnitExists(unit.."target")) then
		local tarRicon = GetRaidTargetIndex(unit.."target")
		local tar = ("%s%s"):format((tarRicon and ICON_LIST[tarRicon].."10|t") or "", getTarget(unit.."target"))

		self:AddDoubleLine(targettext, tar, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
		GameTooltip_UnitColor(unit.."target"))
	end
end

local function OnSetUnit(self)
	if(cfg.combathide and InCombatLockdown()) then
		return self:Hide()
	end

	hideLines(self)

	local _, unit = self:GetUnit()
	if(not unit) then
		unit = GetMouseFocus() and GetMouseFocus().unit or nil
	end

	if(UnitExists(unit)) then
		local isPlayer = UnitIsPlayer(unit)

		if(isPlayer) then
			PlayerTitle(self, unit)
			PlayerGuild(self, unit)
		end

		local ricon = GetRaidTargetIndex(unit)
		if(ricon) then
			local text = GameTooltipTextLeft1:GetText()
			GameTooltipTextLeft1:SetFormattedText(("%s %s"), ICON_LIST[ricon]..cfg.fontsize.."|t", text)
		end

		local color = unitColor(unit)
		local line1 = GameTooltipTextLeft1:GetText()
		GameTooltipTextLeft1:SetFormattedText(("%s"), hex(color)..line1)
		GameTooltipTextLeft1:SetTextColor(GameTooltip_UnitColor(unit))

		local alive = not UnitIsDeadOrGhost(unit)

		local level
		if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
			level = UnitBattlePetLevel(unit)
		else
			level = UnitLevel(unit)
		end

		if(level) then
			local unitClass = isPlayer and hex(color)..UnitClass(unit).."|r" or ""
			local creature = not isPlayer and UnitCreatureType(unit) or ""
			local diff = GetQuestDifficultyColor(level)

			if(level == -1) then
				level = "|cffff0000"..cfg.boss
			end

			local classify = UnitClassification(unit)
			local textLevel = ("%s%s%s|r"):format(hex(diff), tostring(level), classification[classify] or "")

			local tiptextLevel
			for i=2, self:NumLines() do
				local tiptext = _G["GameTooltipTextLeft"..i]
				if(tiptext:GetText() and tiptext:GetText():find(LEVEL)) then
					tiptextLevel = tiptext
				end
			end

			if(tiptextLevel) then
				tiptextLevel:SetFormattedText(("%s %s%s %s%s"), textLevel, creature, (UnitRace(unit) or ""),
				unitClass, (not alive and "|cffCCCCCC"..DEAD.."|r" or ""))
			end
		end

		ShowTarget(self, unit)

		if(cfg.showTalents and isPlayer) then
			ShowTalents(self, unit)
		end

		if(not alive or cfg.hideHealthbar) then
			GameTooltipStatusBar:Hide()
		end
	end

	SetStatusBar(self, unit)

	self.freebHeightSet = nil
	self.freebtipUpdate = 0
end

GameTooltip:HookScript("OnTooltipSetUnit", OnSetUnit)

gtSB:SetStatusBarTexture(cfg.tex)
local bg = gtSB:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(GameTooltipStatusBar)
bg:SetTexture(cfg.tex)
bg:SetVertexColor(0.3, 0.3, 0.3, 0.5)

local SBG = CreateFrame("Frame", "StatusBarBG", GameTooltipStatusBar)
SBG:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
SBG:SetPoint("TOPLEFT", -1, 1)
SBG:SetPoint("BOTTOMRIGHT", 1, -1)
SBG:SetBackdrop({edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1})
SBG:SetBackdropColor(0,0,0)
SBG:SetBackdropBorderColor(0,0,0)

local function gtSBValChange(self, value)
	if(not value) then
		return
	end
	local min, max = self:GetMinMaxValues()
	if(value < min) or (value > max) then
		return
	end
	local _, unit = GameTooltip:GetUnit()
	if(unit) then
		min, max = UnitHealth(unit), UnitHealthMax(unit)
		if(not self.text) then
			-- xRUI
			self.text = self:CreateFontString(nil, "OVERLAY")
				tinsert(RealUI.fontStringsTiny, self.text)
			self.text:SetPoint("CENTER", GameTooltipStatusBar)
			self.text:SetFont(unpack(RealUI:Font(false, "tiny")))
		end
		self.text:Show()
		local hp = numberize(min).." / "..numberize(max)
		self.text:SetText(hp)
	end
end

gtSB:SetScript("OnValueChanged", gtSBValChange)

function style(frame)
	if(not frame) then return end

	frame:SetScale(cfg.scale)
	if(not frame.freebtipBD) then
		frame:SetBackdrop(cfg.backdrop)
		frame.freebtipBD = true
		-- xRUI
		tinsert(REALUI_WINDOW_FRAMES, frame)
	end
	-- xRUI
	frame:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])

	-- Stripes xRUI
	if not frame.stripeTex then
		frame.stripeTex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
			frame.stripeTex:SetAllPoints()
			frame.stripeTex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
			frame.stripeTex:SetHorizTile(true)
			frame.stripeTex:SetVertTile(true)
			frame.stripeTex:SetBlendMode("ADD")
			frame.stripeTex:SetAlpha(RealUI.db.profile.settings.stripeOpacity)
		tinsert(REALUI_STRIPE_TEXTURES, frame.stripeTex)
	end

	local unit = GetMouseFocus() and GetMouseFocus().unit or "mouseover"
	if(cfg.colorborderClass and UnitIsPlayer(unit)) then
		frame:SetBackdropBorderColor(GameTooltip_UnitColor(unit))
	else
		frame:SetBackdropBorderColor(0, 0, 0)
	end

	if(cfg.colorborderItem and frame.GetItem) then
		local _, item = frame:GetItem()
		if(item) then
			--print(item)
			local quality = select(3, GetItemInfo(item))
			if(quality) then
				local r, g, b = GetItemQualityColor(quality)
				frame:SetBackdropBorderColor(r, g, b)
			end		
		end
	end

	local frameName = frame:GetName()
	if(not frameName) then return end

	if(frameName ~= "GameTooltip" and frame.NumLines) then
		for index=1, frame:NumLines() do
			if(index==1) then
				_G[frameName..'TextLeft'..index]:SetFont(RealUI.font.standard, cfg.fontsize+2, cfg.outline)
			else
				_G[frameName..'TextLeft'..index]:SetFont(RealUI.font.standard, cfg.fontsize, cfg.outline)
			end
			_G[frameName..'TextRight'..index]:SetFont(RealUI.font.standard, cfg.fontsize, cfg.outline)
		end
	end

	if(_G[frameName.."MoneyFrame1"]) then
		_G[frameName.."MoneyFrame1PrefixText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame1SuffixText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame1GoldButtonText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame1SilverButtonText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame1CopperButtonText"]:SetFontObject(GameTooltipText)
	end

	if(_G[frameName.."MoneyFrame2"]) then
		_G[frameName.."MoneyFrame2PrefixText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame2SuffixText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame2GoldButtonText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame2SilverButtonText"]:SetFontObject(GameTooltipText)
		_G[frameName.."MoneyFrame2CopperButtonText"]:SetFontObject(GameTooltipText)
	end
end

ns.style = style
FreebTipStyle = style

local tooltips = {
	GameTooltip,
	ItemRefTooltip,
	ShoppingTooltip1,
	ShoppingTooltip2,
	ShoppingTooltip3,
	AutoCompleteBox,
	FriendsTooltip,
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3,
	ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2,
	ItemRefShoppingTooltip3,
	FloatingBattlePetTooltip,
	BattlePetTooltip,
	DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop,
	DropDownList3MenuBackdrop,
}

for i, frame in ipairs(tooltips) do
	if(frame) then
		frame:HookScript("OnShow", function(self)
			if(cfg.combathideALL and InCombatLockdown()) then
				return self:Hide()
			end

			style(self)
		end)
	end
end

local function GT_OnUpdate(self, elapsed)
	self:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])

	if(self:GetHeight() == self.freebHeightSet) then return end	

	local unit = GetMouseFocus() and GetMouseFocus().unit or "mouseover"
	if(UnitExists(unit)) then
		hideLines(self)
	end

	if(gtSB:IsShown()) then
		local height = gtSB:GetHeight()+6

		local powbar = GameTooltipFreebTipPowerBar
		if(powbar and powbar:IsShown()) then
			height = (gtSB:GetHeight()*2)+9
		end

		self:SetHeight((self:GetHeight()+height))
	end

	self.freebHeightSet = self:GetHeight()
	formatLines(self)
end

-- xRUI
-- Because if you're not hacking, you're doing it wrong
local function OverrideGetBackdropColor()
	return RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4]
end

GameTooltip.GetBackdropColor = OverrideGetBackdropColor
GameTooltip:SetBackdropColor(cfg.bgcolor.r, cfg.bgcolor.g, cfg.bgcolor.b, cfg.bgcolor.t)

local function OverrideGetBackdropBorderColor()
	return 0, 0, 0
end

GameTooltip.GetBackdropBorderColor = OverrideGetBackdropBorderColor
GameTooltip:SetBackdropBorderColor(cfg.bdrcolor.r, cfg.bdrcolor.g, cfg.bdrcolor.b)
GameTooltip:HookScript("OnUpdate", GT_OnUpdate)

GameTooltipHeaderText:SetFont(cfg.font, cfg.fontsize+2, cfg.outline)
GameTooltipText:SetFont(cfg.font, cfg.fontsize, cfg.outline)
GameTooltipTextSmall:SetFont(cfg.font, cfg.fontsize-2, cfg.outline)

