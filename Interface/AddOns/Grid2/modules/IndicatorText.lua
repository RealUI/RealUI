--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local GetTime = GetTime
local string_cut = Grid2.strcututf8
local min = math.min
local next = next

local justifyH = { CENTER = "CENTER", TOP = "CENTER", BOTTOM = "CENTER", LEFT = "LEFT",   RIGHT = "RIGHT",  TOPLEFT = "LEFT", TOPRIGHT = "RIGHT", BOTTOMLEFT = "LEFT",   BOTTOMRIGHT = "RIGHT"  }
local justifyV = { CENTER = "CENTER", TOP = "TOP",    BOTTOM = "BOTTOM", LEFT = "CENTER", RIGHT = "CENTER", TOPLEFT = "TOP",  TOPRIGHT = "TOP",   BOTTOMLEFT = "BOTTOM", BOTTOMRIGHT = "BOTTOM" }

Grid2.defaults.profile.formatting = {
	longDecimalFormat        = "%.1f",
	shortDecimalFormat       = "%.0f",
	longDurationStackFormat  = "%.1f:%d",
	shortDurationStackFormat = "%.0f:%d", 
	invertDurationStack      = false,
}

local timers = {}
local stacks = {}
local expirations = {}

local curTime -- Here goes current time to minimize GetTime() calls

-- {{ Timer management
local TimerStart, TimerStop
do 
	local timer
	function TimerStart(text, func)
		timer = CreateFrame("Frame", nil, Grid2LayoutFrame):CreateAnimationGroup()
		local anim = timer:CreateAnimation()
		timer:SetScript("OnFinished", function (self)
			self:Play()
			curTime = GetTime()
			for text, func in next, timers do
				func(text)
			end
		end)
		anim:SetOrder(1)
		anim:SetDuration(0.10)
		timer:Play()
		timers[text] = func 
		TimerStart = function(text, func) 
			if not next(timers) then timer:Play() end
			timers[text] = func
		end
	end
	function TimerStop(text)
		timers[text], expirations[text], stacks[text] = nil, nil, nil
		if not next(timers) then timer:Stop() end
	end
end	
--}}

-- {{ Update functions
local FmtDE  = {} -- masks for duration|elapsed
local FmtDES = {} -- masks for duration|elapsed & stacks
-- elapsed + stacks
local function _UpdateES(text)
	text:SetFormattedText( FmtDES[false], curTime - expirations[text] , stacks[text] or 1  )
end
-- stacks + elapsed
local function _UpdateSE(text)
	text:SetFormattedText( FmtDES[false], stacks[text] or 1, curTime - expirations[text] )
end
-- duration + stacks
local function _UpdateDS(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDES[timeLeft<1], timeLeft, stacks[text] or 1 )
	else
		text:SetText("")
	end	
end
-- stacks + duration
local function _UpdateSD(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDES[timeLeft<1], stacks[text] or 1, timeLeft )
	else
		text:SetText("")
	end	
end
-- elapsed
local function UpdateE(text)
	text:SetFormattedText( "%.0f", curTime - expirations[text]  )
end
-- duration
local function UpdateD(text)
	local timeLeft = expirations[text] - curTime
	if timeLeft>0 then
		text:SetFormattedText( FmtDE[timeLeft<1], timeLeft )
	else
		text:SetText("")
	end
end
-- elapsed+stacks | stacks+elapsed
local UpdateES = _UpdateES
-- duration+stacks | stacks+duration
local UpdateDS = _UpdateDS
-- }}

--{{ Indicator methods
local function Text_Create(self, parent)
	local f = self:CreateFrame("Frame", parent)
	f:SetAllPoints()
	f:SetBackdrop(nil)
	f:Show()
	local Text = f.Text or f:CreateFontString(nil, "OVERLAY")
	f.Text = Text
	Text:SetFontObject(GameFontHighlightSmall)
	Text:SetFont(self.textfont, self.dbx.fontSize, self.dbx.fontFlags)
	Text:Show()	
end

local function Text_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Text_Layout(self, parent)
	local Text = parent[self.name].Text
	Text:ClearAllPoints()
	Text:GetParent():SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Text:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	Text:SetJustifyH(justifyH[self.anchorRel])
	Text:SetJustifyV(justifyV[self.anchorRel])
	Text:SetWidth(parent:GetWidth())
	Text:SetShadowColor(0,0,0, self.shadowAlpha)
end

local function Text_OnUpdateDE(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		Text:Show()
		local expiration = status:GetExpirationTime(unit)
		if expiration then
			curTime = GetTime() -- not local because is used later by self.updateFunc
			if expiration > curTime then
				if self.stack then
					stacks[Text] = status:GetCount(unit)				
				end
				if self.elapsed then
					expirations[Text] = min( expiration - (status:GetDuration(unit) or 0), curTime )
				else
					expirations[Text] = expiration
				end
				if not timers[Text] then 
					TimerStart(Text, self.updateFunc) 
				end
				self.updateFunc(Text)
				return
			end
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
			if timers[Text] then TimerStop(Text) end
			return
		end
	end
	Text:Hide()	
	if timers[Text] then TimerStop(Text) end
end

local function Text_OnUpdateS(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local count = status:GetCount(unit)
		if count then
			Text:SetFormattedText( "%d", count )
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		end
		Text:Show()
	else
		Text:Hide()
	end
end

local function Text_OnUpdateP(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		local percent, text
		if status.GetPercentText then
			text = status:GetPercentText(unit)
		else
			percent, text = status:GetPercent(unit)
		end	
		if text then
			Text:SetText( text )
		elseif percent then
			Text:SetFormattedText( "%.0f%%", percent*100 )
		else
			Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		end
		Text:Show()
	else
		Text:Hide()
	end
end

local function Text_OnUpdate(self, parent, unit, status)
	local Text = parent[self.name].Text
	if status then
		Text:SetText( string_cut(status:GetText(unit) or "", self.textlength) )
		Text:Show()
	else
		Text:Hide()
	end	
end

local function Text_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f.Text:Hide()
	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = Grid2.Dummy
end

local function Text_UpdateDB(self, dbx)
	-- text fmt
	local fmt = Grid2.db.profile.formatting
	FmtDE[true] = fmt.longDecimalFormat
	FmtDE[false] = fmt.shortDecimalFormat
	FmtDES[true] = fmt.longDurationStackFormat
	FmtDES[false] = fmt.shortDurationStackFormat
	UpdateES = fmt.invertDurationStack and _UpdateSE or _UpdateES
	UpdateDS = fmt.invertDurationStack and _UpdateSD or _UpdateDS
	-- indicator dbx
	dbx = dbx or self.dbx
	local l = dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.textlength = dbx.textlength or 16
	self.shadowAlpha = dbx.shadowDisabled and 0 or 1
	self.textfont  = Grid2:MediaFetch("font", dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT
	self.Create = Text_Create
	self.GetBlinkFrame = Text_GetBlinkFrame
	self.Layout = Text_Layout
	self.Disable = Text_Disable
	self.UpdateDB = Text_UpdateDB
	if dbx.duration or dbx.elapsed then
		self.stack = dbx.stack
		self.elapsed = dbx.elapsed
		if dbx.stack then
			self.updateFunc = dbx.elapsed and UpdateES or UpdateDS
		else
			self.updateFunc = dbx.elapsed and UpdateE or UpdateD
		end
		self.OnUpdate = Text_OnUpdateDE		
	elseif dbx.stack then
		self.OnUpdate = Text_OnUpdateS
	elseif dbx.percent then
		self.OnUpdate = Text_OnUpdateP
	else
		self.OnUpdate = Text_OnUpdate
	end
	self.dbx = dbx
end

local function TextColor_OnUpdate(self, parent, unit, status)
	local Text = parent[self.textname].Text
	if status then
		Text:SetTextColor(status:GetColor(unit))
	else
		Text:SetTextColor(1, 1, 1, 1)
	end
end

local function TextColor_UpdateDB(self, dbx)
	self.dbx = dbx
	self.Create = Grid2.Dummy
	self.Layout = Grid2.Dummy
	self.OnUpdate = TextColor_OnUpdate
end

local function Create(indicatorKey, dbx)
	local indicator = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	Text_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "text" })

	local colorKey = indicatorKey .. "-color"
	local TextColor = Grid2.indicators[colorKey] or Grid2.indicatorPrototype:new(colorKey)
	TextColor_UpdateDB(TextColor, dbx)
	TextColor.textname = indicatorKey
	Grid2:RegisterIndicator(TextColor, { "color" })

	indicator.sideKick = TextColor

	return indicator, TextColor
end

Grid2.setupFunc["text"] = Create
Grid2.setupFunc["text-color"] = Grid2.Dummy
-- }}
