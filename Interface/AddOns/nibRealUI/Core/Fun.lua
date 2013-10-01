local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")

-- Misc Functions
function FindSpellID(SpellName, unit, isDebuff)
	print("|cffffff20 SpellID tracking active. When |r|cffffffff"..SpellName.."|r|cffffff20 next activates, the SpellID will be printed in the chat window.|r")
	local f = CreateFrame("FRAME")
	f:RegisterUnitEvent("UNIT_AURA", unit)
	f:SetScript("OnEvent", function(self, event, unit)
		local spellID
		if isDebuff then
			spellID = select(11, UnitDebuff(unit, SpellName))
		else
			spellID = select(11, UnitAura(unit, SpellName))
		end
		if spellID then
			print(SpellName..": #", spellID); 
			f:UnregisterEvent("UNIT_AURA")
		end
	end)
end

-- Memory Display
local function FormatMem(memory)
	if ( memory > 999 ) then
		return format("%.1f |cff%s%s|r", memory/1024, "ff8030", "MiB")
	else
		return format("%.1f |cff%s%s|r", memory, "80ff30", "KB")
	end
end
function nibRealUI:MemoryDisplay()
	local addons, total = {}, 0
	UpdateAddOnMemoryUsage()
	local memory = gcinfo()
	
	for i = 1, GetNumAddOns() do
		if ( IsAddOnLoaded(i) ) then
			table.insert(addons, { GetAddOnInfo(i), GetAddOnMemoryUsage(i) })
			total = total + GetAddOnMemoryUsage(i)
		end
	end
	
	table.sort(addons, (function(a, b) return a[2] > b[2] end))
	
	local userMem = format("|cff00ffffMemory usage: |r%.1f |cffff8030%s|r", total/1024, "MiB")
	print(userMem)
	print("-------------------------------")
	for key, val in pairs(addons) do
		if ( key <= 20 ) then
			print(FormatMem(val[2]).."  -  "..val[1])
		end
	end
end

function nibRealUI:ReloadUIDialog()
	LibStub("AceConfigDialog-3.0"):Close("nibRealUI")

	-- Display Dialog
	StaticPopupDialogs["PUDRUIRELOADUI"] = {
		text = L["You need to Reload the UI for changes to take effect. Reload Now?"],
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		notClosableByLogout = false,
	}
	StaticPopup_Show("PUDRUIRELOADUI")
end

-- Screen Height + Width
function nibRealUI:GetResolutionVals()
	local resStr = GetCVar("gxResolution")
	local resHeight = tonumber(string.match(resStr, "%d+x(%d+)"))
	local resWidth = tonumber(string.match(resStr, "(%d+)x%d+"))

	if self.db.global.tags.retinaDisplay.checked and self.db.global.tags.retinaDisplay.set then
		resHeight = resHeight / 2
		resWidth = resWidth / 2
	end

	return resWidth, resHeight
end

-- Deep Copy table
function nibRealUI:DeepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

-- Loot Spec
function nibRealUI:GetCurrentLootSpecName()
	local lsID = GetLootSpecialization()
	local sID, specName = GetSpecializationInfo(GetSpecialization())

	if (lsID == 0) then
		return specName
	else
		local _, spName = GetSpecializationInfoByID(lsID)
		return spName
	end
end

function nibRealUI:GetLootSpecData()
	local LootSpecIDs = {}
	local LootSpecClass
	local _, _, idClass = UnitClass("player")
	if (idClass == 1) then
		LootSpecIDs[1] = 71
		LootSpecIDs[2] = 72
		LootSpecIDs[3] = 73
		LootSpecIDs[4] = 0
		LootSpecClass = 1
	elseif (idClass == 2) then
		LootSpecIDs[1] = 65
		LootSpecIDs[2] = 66
		LootSpecIDs[3] = 70
		LootSpecIDs[4] = 0
		LootSpecClass = 2
	elseif (idClass == 3) then
		LootSpecIDs[1] = 253
		LootSpecIDs[2] = 254
		LootSpecIDs[3] = 255
		LootSpecIDs[4] = 0
		LootSpecClass = 3
	elseif (idClass == 4) then
		LootSpecIDs[1] = 259
		LootSpecIDs[2] = 260
		LootSpecIDs[3] = 261
		LootSpecIDs[4] = 0
		LootSpecClass = 4
	elseif (idClass == 5) then
		LootSpecIDs[1] = 256
		LootSpecIDs[2] = 257
		LootSpecIDs[3] = 258
		LootSpecIDs[4] = 0
		LootSpecClass = 5
	elseif (idClass == 6) then
		LootSpecIDs[1] = 250
		LootSpecIDs[2] = 251
		LootSpecIDs[3] = 252
		LootSpecIDs[4] = 0
		LootSpecClass = 6
	elseif (idClass == 7) then
		LootSpecIDs[1] = 262
		LootSpecIDs[2] = 263
		LootSpecIDs[3] = 264
		LootSpecIDs[4] = 0
		LootSpecClass = 7
	elseif (idClass == 8) then
		LootSpecIDs[1] = 62
		LootSpecIDs[2] = 63
		LootSpecIDs[3] = 64
		LootSpecIDs[4] = 0
		LootSpecClass = 8
	elseif (idClass == 9) then
		LootSpecIDs[1] = 265
		LootSpecIDs[2] = 266
		LootSpecIDs[3] = 267
		LootSpecIDs[4] = 0
		LootSpecClass = 9
	elseif (idClass == 10) then
		LootSpecIDs[1] = 268
		LootSpecIDs[2] = 270
		LootSpecIDs[3] = 269
		LootSpecIDs[4] = 0
		LootSpecClass = 10
	elseif (idClass == 11) then
		LootSpecIDs[1] = 102
		LootSpecIDs[2] = 103
		LootSpecIDs[3] = 104
		LootSpecIDs[4] = 105
		LootSpecClass = 11
	end
	return LootSpecIDs, LootSpecClass
end

-- Math
function nibRealUI:Round(value, places)
	return (("%%.%df"):format(places or 0)):format(value)
end

function nibRealUI:Clamp(value, min, max)
	if value < min then
		value = min
	elseif value > max then
		value = max
	elseif value ~= value or not (value >= min and value <= max) then -- check for nan...
		value = min
	end

	return value
end

-- Seconds to Time
function nibRealUI:ConvertSecondstoTime(value, onlyOne)
	local hours, minues, seconds
	hours = floor(value / 3600)
	minutes = floor((value - (hours * 3600)) / 60)
	seconds = floor(value - ((hours * 3600) + (minutes * 60)))

	if ( hours > 0 ) then
		if onlyOne then
			return string.format("%dh", hours)
		else
			return string.format("%dh %dm", hours, minutes)
		end
	elseif ( minutes > 0 ) then
		if ( minutes >= 10 ) or onlyOne then
			return string.format("%dm", minutes)
		else
			return string.format("%dm %ds", minutes, seconds)
		end
	else
		return string.format("%ds", seconds)
	end
end

-- Draggable Window
local function MouseDownHandler(frame, button)
	if frame and button == "LeftButton" then
		frame:StartMoving()
		frame:SetUserPlaced(false)
	end
end
local function MouseUpHandler(frame, button)
	if frame and button == "LeftButton" then
		frame:StopMovingOrSizing()
	end
end
function nibRealUI:HookScript(frame, script, handler)
	if not frame.GetScript then return end
	local oldHandler = frame:GetScript(script)
	if oldHandler then
		frame:SetScript(script, function(...)
			handler(...)
			oldHandler(...)
		end)
	else
		frame:SetScript(script, handler)
	end
end
function nibRealUI:MakeFrameDraggable(frame)
	frame:SetMovable(true)
	frame:SetClampedToScreen(false)
	frame:EnableMouse(true)
	self:HookScript(frame, "OnMouseDown", MouseDownHandler)
	self:HookScript(frame, "OnMouseUp", MouseUpHandler)
end

-- Frames
local function ReskinSlider(f)
	f:SetBackdrop(nil)
	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", -23, 0)
	bd:SetPoint("BOTTOMRIGHT", 23, 0)
	bd:SetFrameStrata("BACKGROUND")
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	
	nibRealUI:CreateBD(bd, 0)
	f.bg = nibRealUI:CreateInnerBG(bd)
	f.bg:SetVertexColor(1, 1, 1, 0.6)

	local slider = select(4, f:GetRegions())
	slider:SetTexture("Interface\\AddOns\\nibRealUI\\Media\\HuDConfig\\SliderPos")
	slider:SetSize(16, 16)
	slider:SetBlendMode("ADD")
	
	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:GetObjectType() == "FontString" then
			region:SetFont(unpack(nibRealUI.font.pixel1))
			if region:GetText() == LOW then
				region:ClearAllPoints()
				region:SetPoint("BOTTOMLEFT", bd, "BOTTOMLEFT", 3.5, 4.5)
				region:SetTextColor(0.75, 0.75, 0.75)
				region:SetShadowColor(0, 0, 0, 0)
			elseif region:GetText() == HIGH then
				region:ClearAllPoints()
				region:SetPoint("BOTTOMRIGHT", bd, "BOTTOMRIGHT", 1.5, 4.5)
				region:SetTextColor(0.75, 0.75, 0.75)
				region:SetShadowColor(0, 0, 0, 0)
			else
				region:SetTextColor(0.9, 0.9, 0.9)
			end
		end
	end
end

function nibRealUI:CreateSlider(name, parent, min, max, title, step)
	local f = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	f:SetFrameLevel(parent:GetFrameLevel() + 2)
	f:SetSize(180, 17)
	f:SetMinMaxValues(min, max)
	f:SetValue(0)
	f:SetValueStep(step)
	f.header = nibRealUI:CreateFS(f, "CENTER", "small")
	f.header:SetPoint("BOTTOM", f, "TOP", 0, 4)
	f.header:SetText(title)
	f.value = nibRealUI:CreateFS(f, "CENTER", "small")
	f.value:SetPoint("TOP", f, "BOTTOM", 1, -4)
	f.value:SetText(f:GetValue())

	local sbg = CreateFrame("Frame", nil, f)
	sbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, 0)
	sbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
	nibRealUI:CreateBD(sbg)
	sbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
	sbg:SetFrameLevel(f:GetFrameLevel() - 1)
	
	ReskinSlider(f)

	return f
end

function nibRealUI:CreateCheckbox(name, parent, label, side, size)
	local f = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
	f:SetSize(size, size)
	f:SetHitRectInsets(0,0,0,0) 
	f:SetFrameLevel(parent:GetFrameLevel() + 2)
	f.type = "checkbox"
	
	f.text = _G[f:GetName() .. "Text"]
	f.text:SetFont(nibRealUI.font.standard, 11)
	f.text:SetTextColor(1, 1, 1)
	f.text:SetText(label)
	f.text:ClearAllPoints()
	if side == "LEFT" then
		f.text:SetPoint("RIGHT", f, "LEFT", -4, 0)
		f.text:SetJustifyH("RIGHT")
	else
		f.text:SetPoint("LEFT", f, "RIGHT", 4, 0)
		f.text:SetJustifyH("LEFT")
	end
	
	local cbg = CreateFrame("Frame", nil, f)
	cbg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
	cbg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
	nibRealUI:CreateBD(cbg)
	cbg:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
	cbg:SetFrameLevel(f:GetFrameLevel() - 1)
	
	if Aurora then
		Aurora[1].ReskinCheck(f)
	end

	return f
end

function nibRealUI:CreateTextButton(name, parent, width, height, secure, small)
	local f
	if secure then
		f = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
	else
		f = CreateFrame("Button", nil, parent)
	end

	f:SetFrameLevel(parent:GetFrameLevel() + 2)
	if small then
		f:SetNormalFontObject(RealUIStandardFont10)
		f:SetHighlightFontObject(RealUIStandardFont10)
	else
		f:SetNormalFontObject(GameFontHighlight)
		f:SetHighlightFontObject(GameFontHighlight)
	end
	f:SetText(name)
	f:SetWidth(width)
	f:SetHeight(height)

	if Aurora then
		Aurora[1].Reskin(f)
	end
	
	return f
end

function nibRealUI:CreateWindow(name, width, height, closeOnEsc, draggable, hideCloseButton)
	local f = CreateFrame("Frame", name, UIParent)
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		f:SetSize(width, height)
		f:SetFrameStrata("DIALOG")
		if draggable then
			nibRealUI:MakeFrameDraggable(f)
			f:SetClampedToScreen(true)
			f:SetFrameLevel(10)
		else
			f:SetFrameLevel(5)
		end
	
	if closeOnEsc then
		tinsert(UISpecialFrames, name)
		if not hideCloseButton then
			f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
				f.close:SetPoint("TOPRIGHT", 6, 4)
				f.close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
		end
	end

	nibRealUI:CreateBD(f, nil, true, true)

	if Aurora then
		-- Aurora[1].SetBD(f)
		if closeOnEsc and f.close then Aurora[1].ReskinClose(f.close) end
	end

	return f
end

function nibRealUI:AddButtonHighlight(button)
	-- Button Highlight
	local highlight = CreateFrame("Frame", nil, button)
	highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
	highlight:SetWidth(button:GetWidth() - 2)
	highlight:SetHeight(button:GetHeight() - 2)
	highlight:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain, 
		edgeFile = nibRealUI.media.textures.plain, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = 1, right = 1, top = 1, bottom = 1	}
	})
	highlight:SetBackdropColor(0,0,0,0)
	highlight:SetBackdropBorderColor(unpack(self.classColor))
end

function nibRealUI:SkinButton(button, icon, border)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetPoint("TOPLEFT", 3, -3)
	icon:SetPoint("BOTTOMRIGHT", -3, 3)

	border:SetTexture(nil)

	local bd1 = CreateFrame("Frame", nil, button)
	bd1:SetPoint("TOPLEFT", button, 2, -2)
	bd1:SetPoint("BOTTOMRIGHT", button, -2, 2)
	bd1:SetFrameLevel(1)
	nibRealUI:CreateBD(bd1, 0)

	local bd2 = CreateFrame("Frame", nil, button)
	bd2:SetPoint("TOPLEFT", button, 0, 0)
	bd2:SetPoint("BOTTOMRIGHT", button, 0, 0)
	bd2:SetFrameLevel(1)
	nibRealUI:CreateBD(bd2)
end

function nibRealUI:CreateBD(frame, alpha, stripes, windowColor)
	local bdColor
	frame:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain, 
		edgeFile = nibRealUI.media.textures.plain, 
		edgeSize = 1, 
	})
	if windowColor then
		bdColor = {nibRealUI.media.window[1], nibRealUI.media.window[2], nibRealUI.media.window[3], nibRealUI.media.window[4]}
		tinsert(REALUI_WINDOW_FRAMES, frame)
	else
		bdColor = {nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], alpha or nibRealUI.media.background[4]}
	end
	frame:SetBackdropColor(unpack(bdColor))
	frame:SetBackdropBorderColor(0, 0, 0)

	if stripes then
		self:AddStripeTex(frame)
	end
end

function nibRealUI:CreateBDFrame(frame, alpha, stripes, windowColor)
	local f
	if frame:GetObjectType() == "Texture" then
		f = frame:GetParent()
	else
		f = frame
	end

	local lvl = f:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, f)
	bg:SetParent(f)
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	nibRealUI:CreateBD(bg, alpha, stripes, windowColor)

	return bg
end

function nibRealUI:CreateBG(frame, alpha)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", f, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
	bg:SetTexture(nibRealUI.media.textures.plain)
	bg:SetVertexColor(0, 0, 0, alpha)

	return bg
end

function nibRealUI:CreateBGSection(parent, f1, f2, ...)
	-- Button Backgrounds
	local x1, y1, x2, y2 = -2, 2, 2, -2
	if ... then
		x1, y1, x2, y2 = ...
	end
	local Sect1 = CreateFrame("Frame", nil, parent)
	Sect1:SetPoint("TOPLEFT", f1, "TOPLEFT", x1, y1)
	Sect1:SetPoint("BOTTOMRIGHT", f2, "BOTTOMRIGHT", x2, y2)
	nibRealUI:CreateBD(Sect1)
	Sect1:SetBackdropColor(0.8, 0.8, 0.8, 0.15)
	Sect1:SetFrameLevel(parent:GetFrameLevel() + 1)

	return Sect1
end

function nibRealUI:CreateInnerBG(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, 1, -1)
	bg:SetPoint("BOTTOMRIGHT", frame, -1, 1)
	bg:SetTexture(nibRealUI.media.textures.plain)
	bg:SetVertexColor(0, 0, 0, 0)

	return bg
end

function nibRealUI:AddStripeTex(parent)
	local stripeTex = parent:CreateTexture(nil, "BACKGROUND", nil, 1)
		stripeTex:SetAllPoints()
		stripeTex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
		stripeTex:SetAlpha(nibRealUI.db.profile.settings.stripeOpacity)
		stripeTex:SetHorizTile(true)
		stripeTex:SetVertTile(true)
		stripeTex:SetBlendMode("ADD")

	tinsert(REALUI_STRIPE_TEXTURES, stripeTex)

	return stripeTex
end

function nibRealUI:CreateFS(parent, justify, ...)
	local f = parent:CreateFontString(nil, "OVERLAY")

	local size = ... or "default"
	f:SetFont(unpack(nibRealUI:Font(false, size)))
	f:SetShadowColor(0, 0, 0, 0)
	if justify then f:SetJustifyH(justify) end

	if size == "small" then
		tinsert(nibRealUI.fontStringsSmall, f)
	elseif size == "large" then
		tinsert(nibRealUI.fontStringsLarge, f)
	else
		tinsert(nibRealUI.fontStringsRegular, f)
	end

	return f
end

-- Formatting
local IgnoreLocales = {
	koKR = true,
	zhCN = true,
	zhTW = true,
}
local function checkCJKlength(name, maxNameLength)
	local lastCharLen = 0

	if IgnoreLocales[nibRealUI.locale] then
		maxNameLength = maxNameLength / 2
		local count = maxNameLength

		for c in string.gmatch(name, "([%z\1-\127\194-\244][\128-\191]*)") do
			local ucLength = string.len(c)

			if (ucLength > 1) then
				maxNameLength = maxNameLength + ucLength - 1
			end

			count = count - 1

			if (count == 0) then
				lastCharLen = ucLength
				break
			end
		end
	end

	return maxNameLength, lastCharLen
end
function nibRealUI:AbbreviateName(name, maxLength)
	if not name then return "" end

	local maxNameLength, endCharLength = checkCJKlength(name, maxLength or 12)
	local newName = (strlen(name) > maxNameLength) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1.") or name
	maxNameLength, endCharLength = checkCJKlength(newName, maxLength or 12)

	if (strlen(newName) > maxNameLength) then
		newName = strsub(newName, 1, maxNameLength)
		local newNameLength = string.len(newName);
		newName = newName..".."
	end

	return newName
end

local function FormatToDecimalPlaces(num, places)
	local placeValue = ("%%.%df"):format(places)
	return placeValue:format(num)
end
function nibRealUI:ReadableNumber(num, places)
	local ret = 0
	if not num then
		return 0
	elseif num >= 100000000 then
		ret = FormatToDecimalPlaces(num / 1000000, places or 0) .. "m" -- hundred million
	elseif num >= 10000000 then
		ret = FormatToDecimalPlaces(num / 1000000, places or 1) .. "m" -- ten million
	elseif num >= 1000000 then
		ret = FormatToDecimalPlaces(num / 1000000, places or 2) .. "m" -- million
	elseif num >= 100000 then
		ret = FormatToDecimalPlaces(num / 1000, places or 0) .. "k" -- hundred thousand
	elseif num >= 10000 then
		ret = FormatToDecimalPlaces(num / 1000, places or 1) .. "k" -- ten thousand
	elseif num >= 1000 then
		ret = FormatToDecimalPlaces(num / 1000, places or 2) .. "k" -- thousand
	else
		ret = FormatToDecimalPlaces(num, places or 0) -- hundreds
	end
	return ret
end

-- Font Retrieval
function nibRealUI:RetrieveFont(font)
	local font = LSM:Fetch("font", font)
	if font == nil then font = GameFontNormalSmall:GetFont() end
	return font
end

function nibRealUI:GetFont(fontID)
	local font = {}
	if (fontID == "small") or (fontID == "large") or (fontID == "numbers") or (fontID == "cooldown") then
		font = {self:RetrieveFont(self.media.font.pixel[fontID][1]), self.media.font.pixel[fontID][2], self.media.font.pixel[fontID][3]}
	else
		font = self:RetrieveFont(self.media.font.standard[1])
	end
	return font
end

-- Opposite Faction
function nibRealUI:OtherFaction(f)
	if (f == "Horde") then
		return "Alliance"
	else
		return "Horde"
	end
end

-- Validate Offset
function nibRealUI:ValidateOffset(value, ...)
	local val = tonumber(value)
	local vmin, vmax = -5000, 5000
	if ... then vmin, vmax = ... end	
	if val == nil then val = 0 end
	val = max(val, vmin)
	val = min(val, vmax)
	return val
end

-- Colors
function nibRealUI:ColorTableToStr(vals)
	return string.format("%02x%02x%02x", vals[1] * 255, vals[2] * 255, vals[3] * 255)
end

function nibRealUI:GetDurabilityColor(percent)
	if percent < 0 then
		return 1, 0, 0
	elseif percent <= 0.5 then
		return 1, percent * 2, 0
	elseif percent >= 1 then
		return 0, 1, 0
	else
		return 2 - percent * 2, 1, 0
	end
end

local ilvlLimits = {
	normal = 385,
	uncommon = 437,
	rare = 463,
}
function nibRealUI:GetILVLColor(ilvl)
	if ilvl >= ilvlLimits.rare then
		return {GetItemQualityColor(4)}
	elseif ilvl >= ilvlLimits.uncommon then
		return {GetItemQualityColor(3)}
	elseif ilvl >= ilvlLimits.normal then
		return {GetItemQualityColor(2)}
	else
		return {0.8, 0.8, 0.8, "ffd0d0d0"}
	end
end

function nibRealUI:GetClassColor(class, ...)
	if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
	local classColors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
	if ... then
		return {r = classColors.r, g = classColors.g, b = classColors.b}
	else
		return {classColors.r, classColors.g, classColors.b}
	end
end

function nibRealUI:ColorToRgb(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h*6, s, l
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

function nibRealUI:ColorToHsl(color)
	local r, g, b = color[1], color[2], color[3]
	local min, max = math.min(r, g, b), math.max(r, g, b)
	local h, s, l = 0, 0, (max + min) / 2
	if max ~= min then
		local d = max - min
		s = l > 0.5 and d / (2 - max - min) or d / (max + min)
		if max == r then
			local mod = 6
			if g > b then mod = 0 end
			h = (g - b) / d + mod
		elseif max == g then
			h = (b - r) / d + 2
		else
			h = (r - g) / d + 4
		end
	end
	h = h / 6
	return h, s, l
end

function nibRealUI:ColorShift(color, delta)
	local h, s, l = nibRealUI:ColorToHsl(color)
	return {nibRealUI:ColorToRgb((((h + delta) * 255) % 255), s, l)}
end

function nibRealUI:ColorLighten(color, delta)
	local h, s, l = nibRealUI:ColorToHsl(color)
	return {nibRealUI:ColorToRgb(h, s, nibRealUI:Clamp(l + delta, 0, 1))}
end

function nibRealUI:ColorSaturate(color, delta)
	local h, s, l = nibRealUI:ColorToHsl(color)
	return {nibRealUI:ColorToRgb(h, nibRealUI:Clamp(s + delta, 0, 1), l)}
end

function nibRealUI:ColorDarken(color, delta)
	return nibRealUI:ColorLighten(color, -delta)
end

function nibRealUI:ColorDesaturate(color, delta)
	return nibRealUI:ColorSaturate(color, -delta)
end
