local addon = DXE;
local L = addon.L;
local gbl, pf1
local module = addon:NewModule("Messages","LibSink-2.0")
local SM = LibStub("LibSharedMedia-3.0")

local function RefreshProfile(db)
	gbl, pfl = db.global, db.profile
end
addon:AddToRefreshProfile(RefreshProfile)

---------------------------------------------
-- UTILS
---------------------------------------------

local function search(t,value,i)
	for k,v in pairs(t) do
		if i then
			if type(v) == "table" and v[i] == value then return k end
		elseif v == value then return k end
	end
end

---------------------------------------------
-- PANE
---------------------------------------------
local Pane

function addon:ScalePaneAndCenter()
	local x,y = Pane:GetCenter()
	local escale = Pane:GetEffectiveScale()
	x,y = x*escale,y*escale
	Pane:SetScale(pfl.Pane.Scale)
	escale = Pane:GetEffectiveScale()
	x,y = x/escale,y/escale
	Pane:ClearAllPoints()
	Pane:SetPoint("CENTER",UIParent,"BOTTOMLEFT",x,y)
	addon:SavePosition(Pane)
end

function addon:SetPaneWidth()
	Pane:SetWidth(pfl.Pane.Width)
end

function addon:UpdatePaneVisibility()
	if pfl.Pane.Show then
		local op = 0
		local instanceType = select(2,IsInInstance())
		op = op + (pfl.Pane.OnlyInRaid and (addon.GroupType == "RAID"	and 1  or 0) or 1)
		op = op + (pfl.Pane.OnlyInParty and ((addon.GroupType == "PARTY" or addon.GroupType == "RAID") and 2 or 0) or  2)
		op = op + (pfl.Pane.OnlyInRaidInstance	and (instanceType == "raid" and 4  or 0) or 4)
		op = op + (pfl.Pane.OnlyInPartyInstance and (instanceType == "party"	and 8  or 0) or 8)
		op = op + (pfl.Pane.OnlyIfRunning and (self:IsRunning() and 16 or 0) or 16)
		local show = op == 31
		Pane[show and "Show" or "Hide"](Pane)

		-- Fading
		UIFrameFadeRemoveFrame(Pane)
		local fadeTable = Pane.fadeTable
		fadeTable.fadeTimer = 0
		local a = pfl.Pane.OnlyOnMouseover and (addon.Pane.MouseIsOver and 1 or 0) or 1
		local p_a = Pane:GetAlpha()
		if not show and p_a > 0 then
			fadeTable.startAlpha = p_a
			fadeTable.endAlpha = 0
			fadeTable.finishedFunc = Pane.Hide
			UIFrameFade(Pane,fadeTable)
		elseif show and a ~= p_a then
			fadeTable.startAlpha = p_a
			fadeTable.endAlpha = a
			UIFrameFade(Pane,fadeTable)
		end
	else
		self.Pane:SetAlpha(0)
		self.Pane:Hide()
	end
end

do
	local size = 17
	local buttons = {}
	--- Adds a button to the encounter pane
	-- @param normal The normal texture for the button
	-- @param highlight The highlight texture for the button
	-- @param onclick The function of the OnClick script
	-- @param anchor SetPoints the control LEFT, anchor, RIGHT
	function addon:AddPaneButton(normal,highlight,OnClick,name,text)
		local control = CreateFrame("Button",nil,self.Pane)
		control:SetWidth(size)
		control:SetHeight(size)
		control:SetPoint("LEFT",buttons[#buttons] or self.Pane.timer,"RIGHT")
		control:SetScript("OnClick",OnClick)
		control:RegisterForClicks("AnyUp")
		control:SetNormalTexture(normal)
		control:SetHighlightTexture(highlight)
		self:AddTooltipText(control,name,text)
		control:HookScript("OnEnter",function(self) addon.Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		control:HookScript("OnLeave",function(self) addon.Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)

		buttons[#buttons+1] = control
		return control
	end
end
-- Idea based off RDX's Pane
function addon:CreatePane()
	Pane = CreateFrame("Frame","DXEPane",UIParent)
	Pane:SetAlpha(0)
	Pane:Hide()
	Pane:SetClampedToScreen(true)
	addon:RegisterBackground(Pane)
	Pane.border = CreateFrame("Frame",nil,Pane)
	Pane.border:SetAllPoints(true)
	addon:RegisterBorder(Pane.border)
	Pane:SetWidth(pfl.Pane.Width)
	Pane:SetHeight(25)
	Pane:EnableMouse(true)
	Pane:SetMovable(true)
	Pane:SetPoint("CENTER")
	Pane:SetScale(pfl.Pane.Scale)
	self:RegisterMoveSaving(Pane,"LEFT","UIParent","LEFT",179.0000387755648,-158.9998021557163,true)
	self:LoadPosition("DXEPane")
	Pane:SetUserPlaced(false)
	self:AddTooltipText(Pane,"Pane",L["|cffffff00Shift + Click|r to move"])
	local function OnUpdate() addon:LayoutHealthWatchers() end
	Pane:HookScript("OnMouseDown",function(self) self:SetScript("OnUpdate",OnUpdate) end)
	Pane:HookScript("OnMouseUp",function(self) self:SetScript("OnUpdate",nil) end)
	Pane:HookScript("OnEnter",function(self) self.MouseIsOver = true; addon:UpdatePaneVisibility() end)
	Pane:HookScript("OnLeave",function(self) self.MouseIsOver = false; addon:UpdatePaneVisibility() end)

	Pane.fadeTable = {timeToFade = 0.5, finishedArg1 = Pane}
  	self.Pane = Pane

	Pane.timer = addon.Timer:New(Pane,19,11)
	Pane.timer:SetPoint("BOTTOMLEFT",5,2)
	
	local PaneTextures = "Interface\\AddOns\\DXE\\Textures\\Pane\\"

	-- Add StartStop control
	Pane.startStop = self:AddPaneButton(
		PaneTextures.."Stop",
		PaneTextures.."Stop",
		function(self,button)
			if button == "LeftButton" then
				addon:StopEncounter()
			elseif button == "RightButton" then
				addon.Alerts:QuashByPattern("^custom")
			end
		end,
		L["Stop"],
		L["|cffffff00Click|r stops the current encounter"].."\n"..L["|cffffff00Right-Click|r stops all custom bars"]
	)

	-- Add Config control
	Pane.config = self:AddPaneButton(
		PaneTextures.."Menu",
		PaneTextures.."Menu",
		function() self:ToggleConfig() end,
		L["Configuration"],
		L["Toggles the settings window"]
	)

	-- Create dropdown menu for folder
	local selector = self:CreateSelectorDropDown()
	Pane.SetFolderValue = function(key)
		UIDropDownMenu_SetSelectedValue(selector,key)
	end
	-- Add Folder control
	Pane.folder = self:AddPaneButton(
		PaneTextures.."Folder",
		PaneTextures.."Folder",
		function() ToggleDropDownMenu(1,nil,selector,Pane.folder,0,0) end,
		L["Selector"],
		L["Activates an encounter"]
	)

	Pane.lock = self:AddPaneButton(
		PaneTextures.."Locked",
		PaneTextures.."Locked",
		function() self:ToggleLock() end,
		L["Locking"],
		L["Toggle frame anchors"]
	)

	local windows = self:CreateWindowsDropDown()
	Pane.windows = self:AddPaneButton(
		PaneTextures.."Windows",
		PaneTextures.."Windows",
		function() ToggleDropDownMenu(1,nil,windows,Pane.windows,0,0) end,
		L["Windows"],
		L["Make windows visible"]
	)

	self:CreateHealthWatchers(Pane)

	self.CreatePane = nil

end

function addon:SkinPane()
	local db = pfl.Pane

	-- Health watchers
	for i,hw in ipairs(addon.HW) do
		hw:SetNeutralColor(db.NeutralColor)
		hw:SetLostColor(db.LostColor)
		hw:ApplyNeutralColor()

		hw.title:SetFont(hw.title:GetFont(),db.TitleFontSize)
		hw.title:SetVertexColor(unpack(db.FontColor))
		hw.health:SetFont(hw.health:GetFont(),db.HealthFontSize)
		hw.health:SetVertexColor(unpack(db.FontColor))
	end
end

---------------------------------------------
-- HEALTH WATCHERS
---------------------------------------------
local HW = {}
addon.HW = HW
local DEAD = DEAD:upper()

-- Holds a list of tables
-- Each table t has three values
-- t[1] = npcid
-- t[2] = last known perc
local SortedCache = {}
local SeenNIDS = {}
--[===[@debug@
addon.SortedCache = SortedCache
addon.SeenNIDS = SeenNIDS
--@end-debug@]===]

local UNKNOWN = _G.UNKNOWN
function addon:CreateHealthWatchers(Pane)
	local function OnMouseDown() if IsShiftKeyDown() then Pane:StartMoving() end end
	local function OnMouseUp() Pane:StopMovingOrSizing(); addon:SavePosition(Pane) end

	local function OnAcquired(self,event,unit)
		local goal = self:GetGoal()
		--print("OnAcquired",unit,UnitName(unit),goal,self:IsTitleSet())

		if not self:IsTitleSet() then
			if type(goal) == "number" then
				-- Should only enter once per name
				local name = UnitName(unit)
				if name ~= UNKNOWN then
					gbl.L_NPC[goal] = name
					self:SetTitle(name)
				end
			elseif type(goal) == "string" then
				local name = UnitName(goal)
				if name ~= UNKNOWN then
					self:SetTitle(name)
				end
			end
			-- Another Check
			if not self:IsTitleSet() then
				local name = UnitName(unit)
				if name ~= UNKNOWN then
					gbl.L_NPC[goal] = name
					self:SetTitle(name)
				end
			end
		else
				local name = UnitName(unit)
				if name ~= UNKNOWN then
					gbl.L_NPC[goal] = name
					self:SetTitle(name)
				end
		--	print("OnAcquired Something went wrong",unit,UnitName(unit),goal,self:IsTitleSet(),self.title:GetText())
		end
		addon.callbacks:Fire("HW_TRACER_ACQUIRED",unit,goal)
	end
	--[[local function OnTargetUnit(self, arg1, arg2)
		if arg1 == "LeftButton" then
			-- unitname
			print("ASD",self.title:GetText(),arg2)
			TargetUnit("boss1")
			if UnitExists(self.title:GetText()) then
				print("ASD2 - it exists",self.title:GetText())
				TargetUnit(arg2)
			end
		end
	end--]]
	for i=1,5 do
		local hw = addon.HealthWatcher:New(Pane)
		self:AddTooltipText(hw,"Pane",L["|cffffff00Shift + Click|r to move"])
		hw:HookScript("OnEnter",function(self) Pane.MouseIsOver = true; addon:UpdatePaneVisibility() end)
		hw:HookScript("OnLeave",function(self) Pane.MouseIsOver = false; addon:UpdatePaneVisibility()end)
		hw:SetScript("OnMouseDown",OnMouseDown)
		hw:SetScript("OnMouseUp",OnMouseUp)
		--hw:SetScript("OnClick",OnTargetUnit)
		hw:SetParent(Pane)
		hw:SetCallback("HW_TRACER_ACQUIRED",OnAcquired)
		HW[i] = hw
	end

	for i=1,5 do
		HW[i]:SetCallback("HW_TRACER_UPDATE",function(self,event,unit) addon:TRACER_UPDATE(unit) end)
		HW[i]:EnableUpdates()
	end

	self.CreateHealthWatchers = nil
end

function addon:CloseAllHW()
	for i=1,5 do 
		HW[i]:Close()
		HW[i]:Hide()
	end
end

function addon:ShowFirstHW()
	--	local heroic
	--[[	if self:IsHeroic() == true then
			--print("heroic")
			heroic = "Heroic"
		else
			--print("not heroic")
			heroic = "Normal"
		end--]]
	if not HW[1]:IsShown() then
		--local TestMarker1 = {70, 25}
		--HW[1]:ShowMarker(HW[1],TestMarker1)
		HW[1]:SetInfoBundle("",1)
		HW[1]:ApplyNeutralColor()
--		local israidparty = self:GetRaidDifficulty()
--		print("Raid ssdfdf",self:InstanceSize().." - ")
	--	if self:InstanceSize() > 0 then
--			HW[1]:SetTitle(addon.CE.title.. " - "..self:InstanceSize().." "..heroic)
--		else
			HW[1]:SetTitle(addon.CE.title)
--		end
		HW[1]:Show()
	--else
		--HW[1]:SetTitle(addon.CE.title)
	end
	
end

do
	local n = 0
	local handle
	local e = 1e-10
	local UNACQUIRED = 1

	--[[
	Convert percentages to negatives so we can achieve something like
		HW[4] => Neutral color
		HW[3] => DEAD
		HW[2] => DEAD
		HW[1] => 56%
	]]

	-- Stable sort by comparing npc ids
	-- When comparing two percentages we convert back to positives
	local function sortFunc(a,b)
		local v1,v2 = a[2],b[2] -- health perc
		if v1 == v2 then
			return a[1] < b[1] -- npc ids
		elseif v1 < 0 and v2 < 0 then
			return -v1 < -v2
		else
			return v1 < v2
		end
	end

	local function Execute()
		for _,unit in pairs(Roster.unit_to_unittarget) do
		--print("execute",unit)
			-- unit could not exist and still return a valid guid
			if UnitExists(unit) then
				local npcid = NID[UnitGUID(unit)]
				if npcid then
					SeenNIDS[npcid] = true
					local k = search(SortedCache,npcid,1)
					if k then
						local h,hm = UnitHealth(unit),UnitHealthMax(unit)
						if hm == 0 then hm = 1 end
						SortedCache[k][2] = -(h / hm)
					end
				end
			end
		end

		sort(SortedCache,sortFunc)

		local flag -- Whether or not we should layout health watchers
		for i=1,n do
			if i <= 5 then
				local hw,info = HW[i],SortedCache[i]
				local npcid,perc = info[1],info[2]
--print("asdasd",info,npcid,perc)
				-- Conditional is entered sparsely during a fight
				if perc ~= UNACQUIRED and hw:GetGoal() ~= npcid and SeenNIDS[npcid] then
					hw:SetTitle(gbl.L_NPC[npcid] or "...")
					-- Has been acquired
					if perc then
						if perc < 0 then
							hw:SetInfoBundle(format("%0.0f%%", -perc*100), -perc)
							hw:ApplyLostColor()
						else
							hw:SetInfoBundle(DEAD,0)
						end
					-- Hasn't been acquired
					else
						hw:SetInfoBundle("",1)
						hw:ApplyNeutralColor()
					end
					hw:Track("npcid",npcid)
					hw:Open()
					if not hw:IsShown() then
						hw:Show()
						flag = true
					end
				end
			else break end
		end
		if flag then addon:LayoutHealthWatchers() end
	end

	function addon:StartSortedTracing()
		if n == 0 or handle then return end
		handle = self:ScheduleRepeatingTimer(Execute,0.5)
	end

	function addon:StopSortedTracing()
		if not handle then return end
		self:CancelTimer(handle,true)
		handle = nil
	end

	function addon:ClearSortedTracing()
		wipe(SeenNIDS)
		for i in ipairs(SortedCache) do
			SortedCache[i][2] = UNACQUIRED
		end
	end

	function addon:ResetSortedTracing()
		wipe(SeenNIDS)
		self:StopSortedTracing()
		for i in ipairs(SortedCache) do
			SortedCache[i][1] = nil
			SortedCache[i][2] = UNACQUIRED
		end
		n = 0
	end

	function addon:SetSortedTracing(npcids)
		if not npcids then return end
		n = #npcids
		for i,npcid in ipairs(npcids) do
			SortedCache[i] = SortedCache[i] or {}
			SortedCache[i][1] = npcid
			SortedCache[i][2] = UNACQUIRED
		end
		for i=n+1,#SortedCache do SortedCache[i] = nil end
	end
end

-- Units dead
function addon:HWDead(npcid)
	-- Health watchers
	for i,hw in ipairs(HW) do
		if hw:IsOpen() and hw:GetGoal() == npcid then
			hw:SetInfoBundle(DEAD,0,0)
			local k = search(SortedCache,npcid,1)
			if k then SortedCache[k][2] = 0 end
			break
		end
	end
end

do
	local registered = nil
	local units = {} -- unit => hw
	function addon:SetTracing(targets)
		if not targets then return end
		self:ResetSortedTracing()
		wipe(units)
		if registered then
			self:UnregisterEvent("UNIT_NAME_UPDATE")
			registered = nil
		end
		local n = 0
		for i,tgt in ipairs(targets) do
			-- Prevents overwriting
			local hw = HW[i]

			if hw:GetGoal() ~= tgt then
				if targets.powers and targets.powers[i] then
					hw:ShowPower()
				end
				if i == 1 and targets.markers1 then
					hw:ShowMarker(hw,targets.markers1)
				elseif i == 2 and targets.markers2 then
					hw:ShowMarker(hw,targets.markers2)
				elseif i == 3 and targets.markers3 then
					hw:ShowMarker(hw,targets.markers3)
				elseif i == 4 and targets.markers4 then
					hw:ShowMarker(hw,targets.markers4)
				elseif i == 5 and targets.markers5 then
					hw:ShowMarker(hw,targets.markers5)
				end
				hw:SetTitle(gbl.L_NPC[tgt] or "...")
				--hw:SetTitle("Debug "..tgt)
				hw:SetInfoBundle("",1,1)
				hw:ApplyNeutralColor()
				if type(tgt) == "number" then
					hw:Track("npcid",tgt)
				elseif type(tgt) == "string" then
					if not registered then
						self:RegisterEvent("UNIT_NAME_UPDATE")
						registered = true
					end
					hw:Track("unit",tgt)
					units[tgt] = hw
				end
				hw:Open()
				hw:Show()
			end
			n = n + 1
		end
		for i=n+1,5 do
			HW[i]:Close()
			HW[i]:Hide()
		end
		self:LayoutHealthWatchers()
	end

	-- Occasionally UnitName("boss1") == UnitName("boss2")
	function addon:UNIT_NAME_UPDATE(unit)
		if units[unit] then
			--[===[@debug@
			debug("UNIT_NAME_UPDATE","unit: %s",unit)
			--@end-debug@]===]
			units[unit]:SetTitle(UnitName(unit))
		end
	end
end

function addon:LayoutHealthWatchers()
	local anchor = Pane
	local point, point2
	local relpoint, relpoint2
	local growth = pfl.Pane.BarGrowth
	local mult = 1 -- set to -1 when growing down
	if growth == "AUTOMATIC" then
		local midY = (GetScreenHeight()/2)*UIParent:GetEffectiveScale()
		local x,y = Pane:GetCenter()
		local s = Pane:GetEffectiveScale()
		x,y = x*s,y*s
		if y > midY then
			mult = -1
			point,relpoint = "TOPLEFT","BOTTOMLEFT"
			point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
		else
			point,relpoint = "BOTTOMLEFT","TOPLEFT"
			point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
		end
	elseif growth == "UP" then
		point,relpoint = "BOTTOMLEFT","TOPLEFT"
		point2,relpoint2 = "BOTTOMRIGHT","TOPRIGHT"
	elseif growth == "DOWN" then
		mult = -1
		point,relpoint = "TOPLEFT","BOTTOMLEFT"
		point2,relpoint2 = "TOPRIGHT","BOTTOMRIGHT"
	end
	for i,hw in ipairs(HW) do --self.HW
		if hw:IsShown() then
			hw:ClearAllPoints()
			hw:SetPoint(point,anchor,relpoint,0,mult*pfl.Pane.BarSpacing)
			hw:SetPoint(point2,anchor,relpoint2,0,mult*pfl.Pane.BarSpacing)
			anchor = hw
		end
	end
end

do
	-- Throttling is needed because sometimes bosses pulsate in and out of combat at the start.
	-- UnitAffectingCombat can return false at the start even if the boss is moving towards a player.

	-- The time to wait (seconds) before it auto stops the encounter after auto starting
	local throttle = 5
	-- The last time the encounter was auto started + throttle time
	local last = 0
	function addon:TRACER_UPDATE(unit)
		local time,running = GetTime(),self:IsRunning()
		if self:IsTracerStart() and not running and UnitIsFriend(addon.targetof[unit],"player") then
			self:StartEncounter()
			last = time + throttle
		elseif (UnitIsDead(unit) or not UnitAffectingCombat(unit)) and self:IsTracerStop() and running and last < time then -- or not IsEncounterInProgress()
			self:StopEncounter()
		end
	end
end

do
	local AutoStart,AutoStop
	function addon:SetTracerStart(val)
		AutoStart = not not val
	end

	function addon:SetTracerStop(val)
		AutoStop = not not val
	end

	function addon:IsTracerStart()
		return AutoStart
	end

	function addon:IsTracerStop()
		return AutoStop
	end
end

---------------------------------------------
-- LOCK
---------------------------------------------

do
	local LockableFrames = {}
	function addon:RegisterForLocking(frame)
		--[===[@debug@
		assert(type(frame) == "table","expected 'frame' to be a table")
		assert(frame.IsObjectType and frame:IsObjectType("Region"),"'frame' is not a blizzard frame")
		--@end-debug@]===]
		LockableFrames[frame] = true
		self:UpdateLockedFrames()
	end
	
local NewWarningFrame
local function onUpdate(self, elapsed)
	local showing = false
	for i, s in next, module.slots do
		if s:IsShown() then
			showing = true
			if s.ScaleTime == nil then return true end
			s.ScaleTime = s.ScaleTime + elapsed
			-- Scale the text up untill ScaleUpTime is reached
			if s.ScaleTime < 0.3 then
				s:SetScale(s:GetScale() + elapsed * 3)
			-- Scale down untill ScaleDownTime is reached
			elseif s.ScaleTime <= 0.6 then
				local newScale = s:GetScale() - elapsed * 3
				s:SetScale(newScale > 0 and newScale or 0.01)
			-- Else reset the scale and text size
			else
				s:SetScale(pfl.MessageAnchor.messagescale)
			end
			FadingFrame_OnUpdate(s)
		else
		end
	end
	if not showing then self:SetScript("OnUpdate", nil) end
end	
function addon:GetMessageFrame(DXEframe)
	local slots = module.slots
	local old = slots[#slots]
	for i = #slots, 1, -1 do
		if i > 1 then
			slots[i] = slots[i-1]
		else
			slots[i] = old
		end
	end
	for i, t in pairs(module.slots) do
		t:ClearAllPoints()
		if i == 1 then
			t:SetPoint("BOTTOM","DXEAlertsMessageStackAnchor",0,-6) --
		else
			t:SetPoint("BOTTOM", module.slots[i-1], "TOP" , 0, 6 or -6)
		end
		FadingFrame_SetHoldTime(t, pfl.MessageAnchor.messageholdtime) -- Delay of the message
	end
			
	-- Return the "oldest" slot to be re-used
	return module.slots[1]
end
	
	function addon:CreateLockableFrame(name,width,height,text)
		--[===[@debug@
		assert(type(name) == "string","expected 'name' to be a string")
		assert(type(width) == "number" and width > 0,"expected 'width' to be a number > 0")
		assert(type(height) == "number" and height > 0,"expected 'height' to be a number > 0")
		assert(type(text) == "string","expected 'text' to be a string")
		--@end-debug@]===]
		local frame =  CreateFrame("Frame","DXE"..name,UIParent)
		--if name ~= "AlertsWarningStackAnchor" then
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetUserPlaced(false)
		addon:RegisterBackground(frame)
		frame.border = CreateFrame("Frame",nil,frame)
		frame.border:SetAllPoints(true)
		addon:RegisterBorder(frame.border)
		frame:SetWidth(width)
		frame:SetHeight(height)
		LockableFrames[frame] = true
		self:UpdateLockedFrames()

		local desc = frame:CreateFontString(nil,"ARTWORK")
		desc:SetShadowOffset(1,-1)
		desc:SetPoint("BOTTOM",frame,"TOP")
		desc:SetFont(GameFontNormal:GetFont(),12,"THICKOUTLINE")
		self:RegisterFontString(desc,9)
		desc:SetText(text)

		if name == "AlertsWarningStackAnchor" then
			NewWarningFrame = CreateFrame("MessageFrame", "DXE"..name, UIParent)
			NewWarningFrame:SetPoint("BOTTOM",frame,0,-40) --"DXEAlertsWarningStackAnchor"
			NewWarningFrame:SetSize(712, 100)
			NewWarningFrame:SetFont(pfl.TopMessageAnchor.TopMessageFont, pfl.TopMessageAnchor.TopMessageSize, "THICKOUTLINE")
			NewWarningFrame:SetJustifyH("CENTER")
			NewWarningFrame:SetFadeDuration(1)
		end
		if name == "AlertsInformStackAnchor" then
			--------------- Create a lower one
			InformWarningFrame = CreateFrame("MessageFrame", "DXE"..name, UIParent)
			InformWarningFrame:SetPoint("BOTTOM",frame,0,-20)
			InformWarningFrame:SetSize(812, 60)
			InformWarningFrame:SetFont(pfl.InformMessageAnchor.InformMessageFont, pfl.InformMessageAnchor.InformMessageSize, "THICKOUTLINE")
			InformWarningFrame:SetJustifyH("CENTER")
			InformWarningFrame:SetFadeDuration(1)
			--NewWarningFrame:SetWidth(1200)
		end
		if name == "AlertsMessageStackAnchor" then
			if not module.slots then
				module.slots = {}
				for i = 1, 5 do
					--addon:GetMessageFrame(frame)
					local NewMessageFrame = CreateFrame("Frame", "SlotFrame_"..i, self.eventFrame)
					NewMessageFrame:SetPoint("BOTTOM",frame,0,-60) --"DXEAlertsWarningStackAnchor"
					NewMessageFrame:SetSize(512, 16)
					NewMessageFrame:SetWidth(1200)
						
				local str = NewMessageFrame:CreateFontString("DXEMessageSlot_"..i, "ARTWORK")
				str:SetPoint("CENTER")		
				
				local icon = NewMessageFrame:CreateTexture(nil, "OVERLAY")
				icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				icon:SetPoint("RIGHT", str, "LEFT", -4, 0)
				icon:SetWidth(18)
				icon:SetHeight(18)
				
				local iconback = NewMessageFrame:CreateTexture(nil, "ARTWORK")
				iconback:SetTexture(0, 0, 0, 0.3)
				iconback:SetPoint("TOPLEFT", icon, -1, 1)
				iconback:SetPoint("BOTTOMRIGHT", icon, 1, -1)

				local icon2 = NewMessageFrame:CreateTexture(nil, "OVERLAY")
				icon2:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				icon2:SetPoint("LEFT", str, "RIGHT", 4, 0)
				icon2:SetWidth(18)
				icon2:SetHeight(18)
				
				local iconback2 = NewMessageFrame:CreateTexture(nil, "ARTWORK")
				iconback2:SetTexture(0, 0, 0, 0.3)
				iconback2:SetPoint("TOPRIGHT", icon2, -1, 1)
				iconback2:SetPoint("BOTTOMLEFT", icon2, 1, -1)
				
				NewMessageFrame.text = str
				NewMessageFrame.icon = icon
				NewMessageFrame.icon2 = icon2
				NewMessageFrame.iconback = iconback
				NewMessageFrame.iconback2 = iconback2
				iconback:Hide()
				iconback2:Hide()
				NewMessageFrame:Hide()		
						
				module.slots[i] = NewMessageFrame
			end
			
			local updateFrame = CreateFrame("Frame", nil, UIParent)	
			self.eventFrame = updateFrame
			end

			-- Re-arrange slot, so that slot 1 is always the next one to be used (n:th slot becomes slot nr 1)
			local slots = module.slots
			local old = slots[#slots]
			for i = #slots, 1, -1 do
				if i > 1 then
					slots[i] = slots[i-1]
				else
					slots[i] = old
				end
			end
		end
	
		return frame
	end
	local function GetMedia(sound,c1,c2)
		return Sounds:GetFile(sound),Colors[c1],Colors[c2]
	end
	function addon:NewWarning(text,color,totaltime,icon,textsize)
		if not textsize then textsize = 0 end 
		NewWarningFrame:Clear()
		if icon then text = "|T"..icon..":20:20:-5|t"..text end
		NewWarningFrame:SetTimeVisible(totaltime);
		--if textsize then NewWarningFrame:SetFont("Interface\\AddOns\\DXE\\Fonts\\Prototype.ttf", textsize, "THICKOUTLINE") end
		if textsize > 0 then
			NewWarningFrame:SetFont(SM:Fetch("font",pfl.TopMessageAnchor.TopMessageFont), textsize, "THICKOUTLINE")
		else
			NewWarningFrame:SetFont(SM:Fetch("font",pfl.TopMessageAnchor.TopMessageFont), pfl.TopMessageAnchor.TopMessageSize, "THICKOUTLINE")
		end
		NewWarningFrame:AddMessage(text, color.r,color.g,color.b,ChatTypeInfo["RAID_WARNING"])
		--PlaySound("Levelup");
	end	
	
	function addon:InformWarning(text,color,totaltime,icon,textsize)
		if not textsize then textsize = 0 end
		InformWarningFrame:Clear()
		if icon then text = "|T"..icon..":20:20:-5|t"..text end
		InformWarningFrame:SetTimeVisible(totaltime);
		--if textsize then InformWarningFrame:SetFont("Interface\\AddOns\\DXE\\Fonts\\Prototype.ttf", textsize, "THICKOUTLINE") end
		if textsize > 0 then
			InformWarningFrame:SetFont(SM:Fetch("font",pfl.InformMessageAnchor.InformMessageFont), textsize, "THICKOUTLINE")
		else
			InformWarningFrame:SetFont(SM:Fetch("font",pfl.InformMessageAnchor.InformMessageFont), pfl.InformMessageAnchor.InformMessageSize, "THICKOUTLINE")
		end
		InformWarningFrame:AddMessage(text, color.r,color.g,color.b,ChatTypeInfo["RAID_WARNING"])
	end	
	
	function addon:NewTMessage(text,color,icon,sound)
		--if icon then text = "|T"..icon..":20:20:-5|t"..text end
		local slot = self:GetMessageFrame()

		local soundFile,c1Data = addon.Alerts:GetMediaT(sound,color)
		if soundFile and not pfl.DisableSounds then addon.Alerts:SoundT(soundFile) end

		slot.text:SetTextColor(c1Data.r,c1Data.g,c1Data.b)
		slot.text:SetFont(SM:Fetch("font",pfl.MessageAnchor.MessageFont), pfl.MessageAnchor.MessageSize, "THICKOUTLINE")
		slot.text:SetText(text)
		if pfl.MessageAnchor.messageShowLeftIcon then 
			slot.iconback:Show()
			slot.icon:SetTexture(icon) 
		else
			slot.iconback:Hide()
			slot.icon:SetTexture(nil)
		end
		if pfl.MessageAnchor.messageShowRightIcon then
			slot.iconback2:Show()
			slot.icon2:SetTexture(icon)
		else
			slot.iconback2:Hide()
			slot.icon2:SetTexture(nil)
		end
		slot.ScaleTime = 0

		FadingFrame_SetFadeInTime(slot, pfl.MessageAnchor.messagefadeintime)
		FadingFrame_SetFadeOutTime(slot, pfl.MessageAnchor.messagefadeouttime)
		FadingFrame_Show(slot)
		
		if not self.eventFrame:GetScript("OnUpdate") then self.eventFrame:SetScript("OnUpdate", onUpdate) end
		
		if pfl.WarningMessages then
			addon.Alerts:Pour(text,icon,c1Data)
		end
	end	
	
	function addon:UpdateLock()
		self:UpdateLockedFrames()
		if gbl.Locked then
			self:SetLocked()
		else
			self:SetUnlocked()
		end
	end

	function addon:ToggleLock()
		gbl.Locked = not gbl.Locked
		self:UpdateLock()
	end

	function addon:UpdateLockedFrames(func)
		func = func or (gbl.Locked and "Hide" or "Show")
		for frame in pairs(LockableFrames) do frame[func](frame) end
	end

	function addon:SetLocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Locked")
	end

	function addon:SetUnlocked()
		self.Pane.lock:SetNormalTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
		self.Pane.lock:SetHighlightTexture("Interface\\Addons\\DXE\\Textures\\Pane\\Unlocked")
	end
end

---------------------------------------------
-- SELECTOR
---------------------------------------------

do
	local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
	local function closeall() CloseDropDownMenus(1) end

	local function OnClick(self)
		addon:SetActiveEncounter(self.value)
		CloseDropDownMenus()
	end

	local YELLOW = "|cffffff00"

	local work,list = {},{}
	local info

	local function Initialize(self,level)
		wipe(work)
		wipe(list)

		level = level or 1

		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.isTitle = true
			info.text = L["Encounter Selector"]
			info.notCheckable = true
			info.justifyH = "LEFT"
			UIDropDownMenu_AddButton(info,1)

			info = UIDropDownMenu_CreateInfo()
			info.text = L["Default"]
			info.value = "default"
			info.func = OnClick
			info.colorCode = YELLOW
			info.owner = self
			UIDropDownMenu_AddButton(info,1)

			for key,data in addon:IterateEDB() do
				work[data.category or data.zone] = true
			end
			for cat in pairs(work) do
				list[#list+1] = cat
			end

			sort(list)

			for _,cat in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.text = cat
				info.value = cat
				info.hasArrow = true
				info.notCheckable = true
				info.owner = self
				UIDropDownMenu_AddButton(info,1)
			end

			info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true
			info.justifyH = "LEFT"
			info.text = L["Cancel"]
			info.func = closeall
			UIDropDownMenu_AddButton(info,1)
		elseif level == 2 then
			local cat = UIDROPDOWNMENU_MENU_VALUE

			for key,data in addon:IterateEDB() do
				if (data.category or data.zone) == cat then
					list[#list+1] = data.name
					work[data.name] = key
				end
			end

			sort(list)

			for _,name in ipairs(list) do
				info = UIDropDownMenu_CreateInfo()
				info.hasArrow = false
				info.text = name
				info.owner = self
				info.value = work[name]
				info.func = OnClick
				UIDropDownMenu_AddButton(info,2)
			end
		end
	end

	function addon:CreateSelectorDropDown()
		local selector = CreateFrame("Frame", "DXEPaneSelector", UIParent, "UIDropDownMenuTemplate")
		UIDropDownMenu_Initialize(selector, Initialize, "MENU")
		UIDropDownMenu_SetSelectedValue(selector,"default")
		return selector
	end
end

---------------------------------------------
-- PANE FUNCTIONS
---------------------------------------------
do
	local isRunning,elapsedTime

	-- @return number >= 0
	function addon:GetElapsedTime()
		return elapsedTime
	end

	--- Returns whether or not the timer is running
	-- @return A boolean
	function addon:IsRunning()
		return isRunning
	end

	local function OnUpdate(self,elapsed)
		elapsedTime = elapsedTime + elapsed
		self:SetTime(elapsedTime)
	end

	--- Starts the Pane timer
	function addon:StartTimer()
		elapsedTime = 0
		self.Pane.timer:SetScript("OnUpdate",OnUpdate)
		isRunning = true
	end

	--- Stops the Pane timer
	function addon:StopTimer()
		self.Pane.timer:SetScript("OnUpdate",nil)
		isRunning = false
	end

	--- Resets the Pane timer
	function addon:ResetTimer()
		elapsedTime = 0
		self.Pane.timer:SetTime(0)
	end
end