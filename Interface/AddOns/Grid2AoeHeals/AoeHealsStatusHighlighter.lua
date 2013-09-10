-- Status: MouseOver Highlight status

local AOEM  = Grid2:GetModule("Grid2AoeHeals")
local Grid2 = Grid2

local bxor  = bit.bxor
local band  = bit.band
local rshift= bit.rshift

local roster
local status
local hlStatus
local hlStatusName
local curUnit
local curMask = 0
local delayEnter
local delayLeave

local TimerStart, TimerStop, TimerEnabled
do
	local timerFrame
	local timerFunc
	local timerDelay = 0
	TimerStart = function(delay, func)
		timerFrame = CreateFrame("Frame", nil, Grid2LayoutFrame)
		timerFrame:SetScript("OnUpdate", function(_, elapsed)
			timerDelay = timerDelay - elapsed
			if timerDelay<=0 then
				timerFrame:Hide()
				TimerEnabled = false
				if timerFunc then
					timerFunc(status)
				end
			end
		end )
		TimerStart = function(delay, func)	
			timerDelay, timerFunc = delay, func
			timerFrame:Show() 
			TimerEnabled = true
		end
	end
	TimerStop = function() 
		if timerFrame then 
			timerFrame:Hide() 
			TimerEnabled = false
		end
	end
end

local function GetHighlightMask(unit)
	if not unit then 
		return 0 
	end
	if hlStatusName then 
		return hlStatus:GetHighlightMask(unit) or 0 
	end
	local statuses = AOEM.statuses
	for i=1,#statuses do
		local status = statuses[i]
		if status.HighlightField then
			local mask = status:GetHighlightMask(unit)
			if mask then 
				hlStatus = status
				return mask
			end	
		end	
	end
	return 0
end

local function Refresh(self)
	local newMask = GetHighlightMask(curUnit)
    local difMask = bxor(curMask,newMask)
	curMask = newMask
	if difMask~=0 then
		local i= 1
		while difMask~=0 do
			if band(difMask,1)~=0 then
				self:UpdateIndicators( roster[i].unit )
			end
			difMask = rshift(difMask,1)
			i = i + 1
		end
	end
end

local function ClearIndicators(self)
	curUnit = nil
	Refresh(self)
end

local prev_OnEnter
local function OnMouseEnter(self, frame)
	prev_OnEnter(self, frame)
	curUnit = frame.unit
	TimerStart(delayEnter, Refresh)
end

local prev_OnLeave
local function OnMouseLeave(self, frame)
	prev_OnLeave(self, frame)
	curUnit = nil
	TimerStart(delayLeave, ClearIndicators)
end

local function Enabled(self)
	prev_OnEnter = Grid2Frame.OnFrameEnter
	prev_OnLeave = Grid2Frame.OnFrameLeave
	Grid2Frame.OnFrameEnter = OnMouseEnter
	Grid2Frame.OnFrameLeave = OnMouseLeave
	self:UpdateDB()
end

local function Disabled(self)
	Grid2Frame.OnFrameEnter = prev_OnEnter
	Grid2Frame.OnFrameLeave = prev_OnLeave
	TimerStop()
	self:ClearIndicators()
end

local function UpdateDB(self)
	local dbx    = self.dbx
	hlStatusName = dbx.highlightStatus 
	hlStatus     = hlStatusName and AOEM.hlStatuses[hlStatusName]
	delayEnter   = dbx.delayEnter or 0.1
	delayLeave   = dbx.delayLeave or 0.25
end

local function Update(self)
	if hlStatus and (not hlStatus.enabled) and hlStatus.Refresh then		
		hlStatus:Refresh()
	end	
	if (not TimerEnabled) and curUnit then
		Refresh(self)
	end
end

local function IsActive(self,unit)
	local p= roster[unit]
	if p then
		return band( curMask, p.curMask ) ~= 0 
	end	
end

local function GetIcon(self, unit)
	return hlStatus and hlStatus.texture or "Interface\\Icons\\Inv_misc_map04"
end

local function GetCount(self,unit)
	return 1
end

AOEM.setupFunc["aoe-highlighter"] = function(self,dbx)
	self.order           = 1
	self.StatusEnabled   = Enabled
	self.StatusDisabled  = Disabled
	self.ClearIndicators = ClearIndicators
	self.UpdateDB        = UpdateDB
	self.Update          = Update
	self.IsActive        = IsActive
	self.GetIcon         = GetIcon
	self.GetCount        = GetCount
	self.texture         = "Interface\\Icons\\Inv_misc_idol_05"
	status 				 = self
	roster               = self:GetRoster()
	return { "color" , "icon" }
end

Grid2:DbSetStatusDefaultValue( "aoe-highlighter", { type = "aoe-highlighter", 
	highlightStatus = "aoe-neighbors", color1 = {r=0,g=0.5,b=1,a=1},
})
