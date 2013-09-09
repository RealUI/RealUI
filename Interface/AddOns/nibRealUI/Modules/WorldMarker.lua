local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndbc

local MODNAME = "WorldMarker"
local WorldMarker = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local LoggedIn = false

local WMF = {}

local ButtonWidthExpanded = 18
local ButtonWidthCollapsed = 3

local NeedRefreshed, FramesCreated

local MarkerColors = {
	[1] = {0.2, 	0.2,		1,		0.8},
	[2] = {0.2, 	0.9,		0.2,	0.8},
	[3] = {1, 		0.2,		1,		0.8},
	[4] = {1, 		0.2,		0.2,	0.8},
	[5] = {1, 		1,			0.2,	0.8},
	[6] = {0.3,		0.3,		0.3,	0.8},
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "World Marker",
		desc = "Quick access to World Markers.",
		childGroups = "tab",
		arg = MODNAME,
		-- order = 2315,
		args = {
			header = {
				type = "header",
				name = "World Marker",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Quick access to World Markers.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the WorldMarker module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					if not InCombatLockdown() then
						nibRealUI:SetModuleEnabled(MODNAME, value)
					else
						print("|cff0099ffRealUI: |r World Marker can't be enabled or disabled during combat.")
					end
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 31,
			},
			visibility = {
				name = "Show the World Marker in..",
				type = "group",
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 40,
				args = {
					arena = {
						type = "toggle",
						name = "Arenas",
						get = function(info) return db.visibility.arena end,
						set = function(info, value) 
							db.visibility.arena = value
							WorldMarker:UpdateVisibility()
						end,
						order = 10,
					},
					pvp = {
						type = "toggle",
						name = "Battlegrounds",
						get = function(info) return db.visibility.pvp end,
						set = function(info, value)
							db.visibility.pvp = value
							WorldMarker:UpdateVisibility()
						end,
						order = 20,
					},
					party = {
						type = "toggle",
						name = "5 Man Dungeons",
						get = function(info) return db.visibility.party end,
						set = function(info, value) 
							db.visibility.party = value
							WorldMarker:UpdateVisibility()
						end,
						order = 30,
					},
					raid = {
						type = "toggle",
						name = "Raid Dungeons",
						get = function(info) return db.visibility.raid end,
						set = function(info, value) 
							db.visibility.raid = value 
							WorldMarker:UpdateVisibility()
						end,
						order = 40,
					},
				},
			},
		},
	}
	end
	return options
end



-- OnLeave
local function ButtonOnLeave(index)
	WMF.Buttons[index].mouseover = false
	WorldMarker:HighlightUpdate(WMF.Buttons[index])
end

-- OnEnter
local function ButtonOnEnter(index)
	WMF.Buttons[index].mouseover = true
	WorldMarker:HighlightUpdate(WMF.Buttons[index])
end

-- Toggle visibility of World Marker frame
function WorldMarker:UpdateVisibility()
	-- Refresh
	if ( (NeedRefreshed or not FramesCreated) and (not InCombatLockdown()) ) then
		-- Mod needs refreshing
		WorldMarker:RefreshMod()
		return
	elseif InCombatLockdown() then
		NeedRefreshed = true
		return
	end

	-- Should we hide the WM?
	local Hide = false
	if not nibRealUI:GetModuleEnabled(MODNAME) then Hide = true end
	local Inst, InstType = IsInInstance()
	if Inst and not(Hide) then
		if (InstType == "pvp" and not(db.visibility.pvp)) then			-- Battlegrounds
			Hide = true
		elseif (InstType == "arena" and not(db.visibility.arena)) then	-- Arena
			Hide = true
		elseif (InstType == "party" and not(db.visibility.party)) then	-- 5 Man Dungeons
			Hide = true
		elseif (InstType == "raid" and not(db.visibility.raid)) then	-- Raid Dungeons
			Hide = true
		end
	end
	if not(Hide) and not( (GetNumGroupMembers() > 0) and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) ) then
		Hide = true
	end

	-- Update visibility
	if not(Hide) then
		-- Viable to use World Markers
		if not WMF.Parent:IsShown() then
			WMF.Parent:Show()
		end
	else
		-- Not viable to use World Markers
		if WMF.Parent:IsShown() then
			WMF.Parent:Hide()
		end
	end
end

function WorldMarker_oocUpdate()
	if NeedRefreshed then
		WorldMarker:RefreshMod()
	else
		WorldMarker:UpdateVisibility()
	end
end
function WorldMarker:UpdateLockdown(...)
	nibRealUI:RegisterLockdownUpdate("WorldMarker_oocUpdate", function()
		WorldMarker_oocUpdate()
	end)
end

function WorldMarker:HighlightUpdate(self)
	self.bg:SetWidth(self.mouseover and ButtonWidthExpanded or ButtonWidthCollapsed)
end

-- Set World Marker Position
function WorldMarker:UpdatePosition()
	if not FramesCreated then return end

	local MMHeight = Minimap:GetHeight()
	
	-- Parent
	WMF.Parent:ClearAllPoints()
	WMF.Parent:SetPoint("TOPLEFT", _G["Minimap"], "TOPRIGHT", 0, 0)
	WMF.Parent:SetFrameStrata("BACKGROUND")
	WMF.Parent:SetFrameLevel(5)
	
	WMF.Parent:SetWidth(ButtonWidthExpanded)
	WMF.Parent:SetHeight(MMHeight)
	
	local totHeight, btnHeight = 0
	for i = 1, 6 do
		btnHeight = floor(MMHeight / 6) + 1
		WMF.Buttons[i]:ClearAllPoints()
		if i == 6 then
			WMF.Buttons[i]:SetPoint("TOPLEFT", WMF.Parent, "TOPLEFT", 0, -totHeight + 1)
			WMF.Buttons[i]:SetHeight(MMHeight - totHeight + 2)
			WMF.Buttons[i].bg:SetHeight(MMHeight - totHeight + 2)
		else
			WMF.Buttons[i]:SetPoint("TOPLEFT", WMF.Parent, "TOPLEFT", 0, -totHeight + 1)
			WMF.Buttons[i]:SetHeight(btnHeight)
			WMF.Buttons[i].bg:SetHeight(btnHeight)
		end
		WMF.Buttons[i]:SetWidth(ButtonWidthExpanded)
		totHeight = totHeight + btnHeight - 1
	end
end

-----------------
local function CreateButton(id)
	local frame = CreateFrame("Button", "RealUI_WorldMarker_Button"..tostring(id), WMF.Parent, "SecureActionButtonTemplate")
	
	frame:SetAttribute("type", "macro")
	frame:SetScript("OnEnter", function(self) ButtonOnEnter(id) end)
	frame:SetScript("OnLeave", function(self) ButtonOnLeave(id) end)
	
	frame.bg = CreateFrame("Frame", nil, frame)
	frame.bg:SetPoint("LEFT", frame, "LEFT", 0, 0)
	frame.bg:SetWidth(ButtonWidthCollapsed)
	nibRealUI:CreateBD(frame.bg, 0.8)
	frame.bg:SetBackdropColor(unpack(MarkerColors[id]))

	return frame
end

local function CreateFrames()
	if InCombatLockdown() or FramesCreated then return end
	
	-- Parent Frame
	WMF.Parent = CreateFrame("Frame", "RealUI_WorldMarker", _G["Minimap"])
	
	-- Buttons
	WMF.Buttons = {}
	-- Blue
	WMF.Buttons[1] = CreateButton(1)
	WMF.Buttons[1]:SetAttribute("macrotext", "/wm 1")
	
	-- Green
	WMF.Buttons[2] = CreateButton(2)
	WMF.Buttons[2]:SetAttribute("macrotext", "/wm 2")
	
	-- Purple
	WMF.Buttons[3] = CreateButton(3)
	WMF.Buttons[3]:SetAttribute("macrotext", "/wm 3")
	
	-- Red
	WMF.Buttons[4] = CreateButton(4)
	WMF.Buttons[4]:SetAttribute("macrotext", "/wm 4")
	
	-- Yellow
	WMF.Buttons[5] = CreateButton(5)
	WMF.Buttons[5]:SetAttribute("macrotext", "/wm 5")
	
	-- Clear All
	WMF.Buttons[6] = CreateButton(6)
	WMF.Buttons[6]:SetAttribute("macrotext", "/cwm all")
	
	FramesCreated = true
end

---------------
function WorldMarker:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	db = self.db.profile
	
	-- Create Frames if it has been delayed
	if not InCombatLockdown() and not FramesCreated then
		CreateFrames()
	end
	
	-- Refresh Mod
	if InCombatLockdown() or not FramesCreated then
		-- In combat or have no frames, set flag so we can refresh once combat ends
		NeedRefreshed = true
	else
		-- Ready to refresh
		NeedRefreshed = false
		
		WorldMarker:UpdatePosition()
		WorldMarker:UpdateVisibility()
	end
end

function WorldMarker:PLAYER_LOGIN()
	LoggedIn = true
	
	WorldMarker:RefreshMod()
	hooksecurefunc(Minimap, "SetSize", function() 
		if not(InCombatLockdown()) then
			WorldMarker:UpdatePosition()
		end
	end)
end

function WorldMarker:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			visibility = {
				pvp = false,
				arena = false,
				party = true,
				raid = true,
			},
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function WorldMarker:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
	self:RegisterBucketEvent({"PLAYER_ENTERING_WORLD", "UNIT_FLAGS", "PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE"}, 1, "UpdateVisibility")
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateVisibility")
	-- self:RegisterEvent("UNIT_FLAGS", "UpdateVisibility")
	-- self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateVisibility")
	-- self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateVisibility")

	if LoggedIn then WorldMarker:RefreshMod() end
end

function WorldMarker:OnDisable()
	self:UnregisterEvent("PLAYER_LOGIN")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")

	NeedRefreshed = false
	
	if InCombatLockdown() then
		-- Trying to disable while in combat. Display message and block mouse input to World Markers.
		print("|cff00ffffRealUI: |r World Marker can't fully disable during combat. Please wait until you leave combat, then reload the UI (type: /rl)")
	else	
		WorldMarker:UpdateVisibility()
	end
end