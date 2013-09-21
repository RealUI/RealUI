local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "WatchFrame Adv."
local WatchFrameAdv = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local LoggedIn = false

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Watch Frame Adv.",
		desc = "Style and re-position the Quest Watch Frame.",
		childGroups = "tab",
		arg = MODNAME,
		args = {
			header = {
				type = "header",
				name = "Watch Frame Adv.",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Style and re-position the Quest Watch Frame.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Watch Frame Adv. module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					WatchFrameAdv:RefreshMod()				
				end,
				order = 30,
			},
			sizeposition = {
				name = "Size/Position",
				type = "group",
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 40,
				args = {
					header = {
						type = "description",
						name = "Adjust size and position.",
						order = 10,
					},
					enabled = {
						type = "toggle",
						name = "Enabled",
						get = function(info) return db.position.enabled end,
						set = function(info, value) 
							db.position.enabled = value
							WatchFrameAdv:UpdatePosition()
							nibRealUI:ReloadUIDialog()
						end,
						order = 20,
					},
					note1 = {
						type = "description",
						name = "Note: Enabling/disabling the size/position adjustments will require a UI Reload to take full effect.",
						order = 30,
					},
					gap1 = {
						name = " ",
						type = "description",
						order = 31,
					},
					offsets = {
						type = "group",
						name = "Offsets",
						disabled = function() return not(db.position.enabled) or not(nibRealUI:GetModuleEnabled(MODNAME)) end,
						inline = true,
						order = 40,
						args = {
							xoffset = {
								type = "input",
								name = "X Offset",
								width = "half",
								order = 10,
								get = function(info) return tostring(db.position.x) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.x = value
									WatchFrameAdv:UpdatePosition()
								end,
							},
							yoffset = {
								type = "input",
								name = "Y Offset",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.position.y) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.y = value
									WatchFrameAdv:UpdatePosition()
								end,
							},
							negheightoffset = {
								type = "input",
								name = "Height Offset",
								desc = "How much shorter than screen height to make the Quest Watch Frame.",
								width = "half",
								order = 30,
								get = function(info) return tostring(db.position.negheightofs) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.negheightofs = value
									WatchFrameAdv:UpdatePosition()
								end,
							},
						},
					},
					gap2 = {
						name = " ",
						type = "description",
						order = 41,
					},
					anchor = {
						type = "group",
						name = "Position",
						inline = true,
						disabled = function() return not(db.position.enabled) or not(nibRealUI:GetModuleEnabled(MODNAME)) end,
						order = 50,
						args = {
							anchorto = {
								type = "select",
								name = "Anchor To",
								get = function(info) 
									for k,v in pairs(nibRealUI.globals.anchorPoints) do
										if v == db.position.anchorto then return k end
									end
								end,
								set = function(info, value)
									db.position.anchorto = nibRealUI.globals.anchorPoints[value]
									WatchFrameAdv:UpdatePosition()
								end,
								style = "dropdown",
								width = nil,
								values = nibRealUI.globals.anchorPoints,
								order = 10,
							},
							anchorfrom = {
								type = "select",
								name = "Anchor From",
								get = function(info) 
									for k,v in pairs(nibRealUI.globals.anchorPoints) do
										if v == db.position.anchorfrom then return k end
									end
								end,
								set = function(info, value)
									db.position.anchorfrom = nibRealUI.globals.anchorPoints[value]
									WatchFrameAdv:UpdatePosition()
								end,
								style = "dropdown",
								width = nil,
								values = nibRealUI.globals.anchorPoints,
								order = 20,
							},
						},
					},
				},
			},
			hidden = {
				name = "Automatic Collapse/Hide",
				type = "group",
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 60,
				args = {
					header = {
						type = "description",
						name = "Automatically collapse the Quest Watch Frame in certain zones.",
						order = 10,
					},
					enabled = {
						type = "toggle",
						name = "Enabled",
						get = function(info) return db.hidden.enabled end,
						set = function(info, value) 
							db.hidden.enabled = value
							WatchFrameAdv:UpdateCollapseState()
						end,
						order = 20,
					},
					gap1 = {
						name = " ",
						type = "description",
						order = 21,
					},
					collapse = {
						type = "group",
						name = "Collapse the Quest Watch Frame in..",
						inline = true,
						disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME) and db.hidden.enabled) end,
						order = 30,
						args = {
							arena = {
								type = "toggle",
								name = "Arenas",
								get = function(info) return db.hidden.collapse.arena end,
								set = function(info, value) 
									db.hidden.collapse.arena = value
									WatchFrameAdv:UpdateCollapseState()
								end,
								order = 10,
							},
							pvp = {
								type = "toggle",
								name = "Battlegrounds",
								get = function(info) return db.hidden.collapse.pvp end,
								set = function(info, value)
									db.hidden.collapse.pvp = value
									WatchFrameAdv:UpdateCollapseState()
								end,
								order = 20,
							},
							party = {
								type = "toggle",
								name = "5 Man Dungeons",
								get = function(info) return db.hidden.collapse.party end,
								set = function(info, value) 
									db.hidden.collapse.party = value
									WatchFrameAdv:UpdateCollapseState()
								end,
								order = 30,
							},
							raid = {
								type = "toggle",
								name = "Raid Dungeons",
								get = function(info) return db.hidden.collapse.raid end,
								set = function(info, value) 
									db.hidden.collapse.raid = value 
									WatchFrameAdv:UpdateCollapseState()
								end,
								order = 40,
							},
						},
					},
					gap2 = {
						name = " ",
						type = "description",
						order = 31,
					},
					hide = {
						type = "group",
						name = "Hide the Quest Watch Frame completely in..",
						inline = true,
						disabled = function() return not(db.hidden.enabled) or not(nibRealUI:GetModuleEnabled(MODNAME)) end,
						order = 40,
						args = {
							arena = {
								type = "toggle",
								name = "Arenas",
								get = function(info) return db.hidden.hide.arena end,
								set = function(info, value) 
									db.hidden.hide.arena = value
									WatchFrameAdv:UpdateHideState()
								end,
								order = 10,
							},
							pvp = {
								type = "toggle",
								name = "Battlegrounds",
								get = function(info) return db.hidden.hide.pvp end,
								set = function(info, value)
									db.hidden.hide.pvp = value
									WatchFrameAdv:UpdateHideState()
								end,
								order = 20,
							},
							party = {
								type = "toggle",
								name = "5 Man Dungeons",
								get = function(info) return db.hidden.hide.party end,
								set = function(info, value) 
									db.hidden.hide.party = value
									WatchFrameAdv:UpdateHideState()
								end,
								order = 30,
							},
							raid = {
								type = "toggle",
								name = "Raid Dungeons",
								get = function(info) return db.hidden.hide.raid end,
								set = function(info, value) 
									db.hidden.hide.raid = value 
									WatchFrameAdv:UpdateHideState()
								end,
								order = 40,
							},
						},
					},
				},
			},
		},
	}
	end
	return options
end

---------------------
-- Collapse / Hide --
---------------------
-- Hide Quest Tracker based on zone
function WatchFrameAdv:UpdateHideState()
	local Hide = false
	local _, instanceType = GetInstanceInfo()

	if db.hidden.enabled and (instanceType ~= "none") and nibRealUI:GetModuleEnabled(MODNAME) then
		if (instanceType == "pvp" and db.hidden.hide.pvp) then			-- Battlegrounds
			Hide = true
		elseif (instanceType == "arena" and db.hidden.hide.arena) then	-- Arena
			Hide = true
		elseif (((instanceType == "party") or (instanceType == "scenario")) and db.hidden.hide.party) then	-- 5 Man Dungeons
			Hide = true
		elseif (instanceType == "raid" and db.hidden.hide.raid) then	-- Raid Dungeons
			Hide = true
		end
	end
	if Hide then
		self.hidden = true
		WatchFrame.realUIHidden = true
		WatchFrame:Hide() 
	else
		local oldHidden = self.hidden
		self.hidden = false
		WatchFrame.realUIHidden = false
		WatchFrame:Show()

		-- Refresh fade, since fade won't update while hidden
		local CF = nibRealUI:GetModule("CombatFader", 1)
		if oldHidden and nibRealUI:GetModuleEnabled("CombatFader") and CF then
			CF:UpdateStatus(true)
		end
	end
end

-- Collapse Quest Tracker based on zone
function WatchFrameAdv:UpdateCollapseState()
	local Collapsed = false
	local _, instanceType = GetInstanceInfo()

	if db.hidden.enabled and (instanceType ~= "none") and nibRealUI:GetModuleEnabled(MODNAME) then
		if (instanceType == "pvp" and db.hidden.collapse.pvp) then			-- Battlegrounds
			Collapsed = true
		elseif (instanceType == "arena" and db.hidden.collapse.arena) then	-- Arena
			Collapsed = true
		elseif (((instanceType == "party") or (instanceType == "scenario")) and db.hidden.collapse.party) then	-- 5 Man Dungeons
			Collapsed = true
		elseif (instanceType == "raid" and db.hidden.collapse.raid) then	-- Raid Dungeons
			Collapsed = true
		end
	end
	
	if Collapsed then
		self.collapsed = true
		WatchFrame.userCollapsed = true
		WatchFrame_Collapse(WatchFrame)
	else
		self.collapsed = false
		WatchFrame.userCollapsed = false
		WatchFrame_Expand(WatchFrame)
	end	
end

function WatchFrameAdv:UpdatePlayerLocation()
	self:UpdateCollapseState()
	self:UpdateHideState()
end

---------------
---- Style ----
---------------
-- Styling code from Mythology (adapted from nibWatchFrameAdv) by p3lim
local function SkinButton(button, texture)
	if(string.match(button:GetName(), 'WatchFrameItem%d+') and not button.skinned) then
		button:SetSize(26, 26)
		button:SetBackdrop(backdrop)
		button:SetBackdropColor(0, 0, 0)
		button:SetBackdropBorderColor(0, 0, 0)

		local icon = _G[button:GetName() .. 'IconTexture']
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetPoint('TOPLEFT', 1, -1)
		icon:SetPoint('BOTTOMRIGHT', -1, 1)

		_G[button:GetName() .. 'NormalTexture']:SetTexture()

		button.skinned = true
	end
end

local function SetLine(...)
	local line, _, _, isHeader, _, hasDash = ...
	line.hasDash = hasDash == 1

	if(line.hasDash and line.square) then
		line.square:Show()
	elseif(line.square) then
		line.square:Hide()
	end
end

local function GetQuestData(self)
	if(self.type == 'QUEST') then
		local questIndex = GetQuestIndexForWatch(self.index)
		if(questIndex) then
			local _, level, _, _, _, _, _, daily = GetQuestLogTitle(questIndex)
			if(daily) then
				return 1/4, 6/9, 1, 'D'
			else
				local color = GetQuestDifficultyColor(level)
				return color.r, color.g, color.b, level
			end
		end
	end

	return 1, 1, 1
end

local function IsSuperTracked(self)
	if(self.type ~= 'QUEST') then return end

	local questIndex = GetQuestIndexForWatch(self.index)
	if(questIndex) then
		local _, _, _, _, _, _, _, _, id = GetQuestLogTitle(questIndex)
		if(id and GetSuperTrackedQuestID() == id) then
			return true
		end
	end
end

local function HighlightLine(self, highlight)
	for index = self.startLine, self.lastLine do
		local line = self.lines[index]
		if(line) then
			if(index == self.startLine) then
				local r, g, b, prefix = GetQuestData(self)
				local text = line.text:GetText()
				if(text and string.sub(text, -1) ~= '\032') then
					if prefix then
						line.text:SetFormattedText('[%s] %s\032', prefix, text)
					else
						line.text:SetFormattedText('%s\032', text)
					end
				end

				if(highlight) then
					line.text:SetTextColor(r, g, b)
				else
					line.text:SetTextColor(r * 6/7, g * 6/7, b * 6/7)
				end
			else
				if(highlight) then
					line.text:SetTextColor(6/7, 6/7, 6/7)

					if(line.square) then
						line.square:SetBackdropColor(1/5, 1/2, 4/5)
					end
				else
					line.text:SetTextColor(5/7, 5/7, 5/7)

					if(line.square) then
						if(IsSuperTracked(self)) then
							line.square:SetBackdropColor(5/7, 1/5, 1/5)
						else
							line.square:SetBackdropColor(4/5, 4/5, 1/5)
						end
					end
				end
			end
		end
	end
end

local nextLine = 1
local function SkinLine()
	local font = nibRealUI:Font(false, "small")
	for index = nextLine, 50 do
		local line = _G['WatchFrameLine' .. index]
		if(line) then
			line.text:SetFont(font[1], font[2], font[3])
			tinsert(nibRealUI.fontStringsSmall, line.text)
			line.text:SetShadowColor(0, 0, 0, 0)
			line.text:SetSpacing(5)
			line.dash:SetAlpha(0)

			local square = CreateFrame('Frame', nil, line)
			square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 7, -6)
			square:SetSize(5, 5)
			nibRealUI:CreateBD(square)
			square:SetBackdropColor(4/5, 4/5, 1/5)
			line.square = square

			if(line.hasDash) then
				square:Show()
			else
				square:Hide()
			end
		else
			nextLine = index
			break
		end
	end

	for index = 1, #WATCHFRAME_LINKBUTTONS do
		HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
	end
end

local nextScenarioLine = 1
local function SkinScenarioLine()
	local font = nibRealUI:Font(false, "small")
	for index = nextScenarioLine, 50 do
		local line = _G['WatchFrameScenarioLine' .. index]
		if(line) then
			line.text:SetFont(font[1], font[2], font[3])
			tinsert(nibRealUI.fontStringsSmall, line.text)
			line.text:SetShadowColor(0, 0, 0, 0)
			line.text:SetSpacing(5)

			local square = CreateFrame('Frame', nil, line)
			square:SetPoint('TOPRIGHT', line, 'TOPLEFT', 7, -6)
			square:SetSize(5, 5)
			square:SetBackdrop(backdrop)
			square:SetBackdropColor(4/5, 4/5, 1/5)
			square:SetBackdropBorderColor(0, 0, 0)
			line.square = square

			line.icon:Hide()
		else
			nextScenarioLine = index
			break
		end
	end

	local _, _, numCriteria = C_Scenario.GetStepInfo()
	for index = 1, numCriteria do
		local text, _, completed = C_Scenario.GetCriteriaInfo(index)
		for lineIndex = 1, nextScenarioLine do
			local line = _G['WatchFrameScenarioLine' .. lineIndex]
			if(line and string.find(line.text:GetText(), text)) then
				if(completed) then
					line.square:SetBackdropColor(0, 1, 0)
				else
					line.square:SetBackdropColor(4/5, 4/5, 4/5)
				end
			end
		end
	end
end

local origClick
local function ClickLine(self, button, ...)
	if(button == 'RightButton' and not IsShiftKeyDown() and self.type == 'QUEST') then
		local _, _, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestIndexForWatch(self.index))
		QuestPOI_SelectButtonByQuestId('WatchFrameLines', questID, true)

		if(WorldMapFrame:IsShown()) then
			WorldMapFrame_SelectQuestById(questID)
		end

		SetSuperTrackedQuestID(questID)

		for index = 1, #WATCHFRAME_LINKBUTTONS do
			if(index ~= self.index) then
				HighlightLine(WATCHFRAME_LINKBUTTONS[index], false)
			end
		end
	else
		origClick(self, button, ...)
	end
end

local function QuestPOI(name, type, index)
	if(name == 'WatchFrameLines') then
		_G['poi' .. name .. type .. '_' .. index]:Hide()
	end
end

local function null() end
function WatchFrameAdv:Skin()
	hooksecurefunc('WatchFrame_SetLine', SetLine)
	hooksecurefunc('WatchFrame_Update', SkinLine)
	hooksecurefunc('WatchFrameScenario_UpdateScenario', SkinScenarioLine)
	hooksecurefunc('QuestPOI_DisplayButton', QuestPOI)
	hooksecurefunc('SetItemButtonTexture', SkinButton)

	origClick = WatchFrameLinkButtonTemplate_OnClick
	WatchFrameLinkButtonTemplate_OnClick = ClickLine
	WatchFrameLinkButtonTemplate_Highlight = HighlightLine

	local ScenarioTextHeader = WatchFrameScenarioFrame.ScrollChild.TextHeader.text
	ScenarioTextHeader:SetFont(unpack(nibRealUI:Font()))
	tinsert(nibRealUI.fontStringsSmall, ScenarioTextHeader)
	ScenarioTextHeader:SetShadowColor(0, 0, 0, 0)
	ScenarioTextHeader:SetTextColor(0.85, 0.85, 0)

	SkinScenarioLine()

	WatchFrameTitle:Hide()
	WatchFrameTitle.Show = null

	WatchFrame_SetSorting(nil, 1)

	WorldMapPlayerUpper:EnableMouse(false)
	WorldMapPlayerLower:EnableMouse(false)
end


-------------------------
---- Position / Size ----
-------------------------
-- Set Width
function WatchFrameAdv:UpdateWidth()
	if not (db.position.enabled and nibRealUI:GetModuleEnabled(MODNAME)) then return end

	if not self.WFWidthReplaced then
		self.WFWidthReplaced = true
	
		_WatchFrame_SetWidth = WatchFrame_SetWidth
		WatchFrame_SetWidth = function(width)
			 if ( width == "0" ) then
				WATCHFRAME_EXPANDEDWIDTH = db.position.width
				WATCHFRAME_MAXLINEWIDTH = db.position.width - 10
			else
				WATCHFRAME_EXPANDEDWIDTH = (db.position.width * 1.5)
				WATCHFRAME_MAXLINEWIDTH = (db.position.width * 1.5) - 10
			end
			if WatchFrameScenarioPopUpFrame then
				WatchFrameScenarioPopUpFrame:SetWidth(WATCHFRAME_EXPANDEDWIDTH)
			end
			if ( WatchFrame:IsShown() and not WatchFrame.collapsed ) then
				WatchFrame:SetWidth(WATCHFRAME_EXPANDEDWIDTH)
				WatchFrame_Update()
			end
		end
	end

	WatchFrame_SetWidth(GetCVar("watchFrameWidth"))
end

-- Position
function WatchFrameAdv:UpdatePosition()
	if not (db.position.enabled and nibRealUI:GetModuleEnabled(MODNAME)) then return end

	if not self.origSet then
		self.origSet = WatchFrame.SetPoint
		self.origClear = WatchFrame.ClearAllPoints

		WatchFrame.SetPoint = function() end
		WatchFrame.ClearAllPoints = function() end
	end

	self.origClear(WatchFrame)
	self.origSet(WatchFrame, db.position.anchorfrom, "UIParent", db.position.anchorto, db.position.x, db.position.y)

	WatchFrame:SetHeight(UIParent:GetHeight() - db.position.negheightofs)
	
	WatchFrameCollapseExpandButton:SetPoint("TOPRIGHT", WatchFrame, "TOPRIGHT", -12, -1)
end


-----------------------
function WatchFrameAdv:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	self:UpdatePosition()
	self:UpdateWidth()
end

function WatchFrameAdv:UI_SCALE_CHANGED()
	self:UpdatePosition()
end

function WatchFrameAdv:PLAYER_ENTERING_WORLD()
	self:ScheduleTimer("UpdatePlayerLocation", 1)
end

function WatchFrameAdv:PLAYER_LOGIN()
	LoggedIn = true
	self:RefreshMod()
	self:Skin()
end

function WatchFrameAdv:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			position = {
				enabled = true,
				anchorto = "TOPRIGHT",
				anchorfrom = "TOPRIGHT",
				x = -32,
				y = -200,
				negheightofs = 300,
				width = 210,
			},
			hidden = {
				enabled = true,
				collapse = {
					pvp = true,
					arena = false,
					party = true,
					raid = false,
				},
				hide = {
					pvp = false,
					arena = true,
					party = false,
					raid = true,
				},
			},
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
	
	self:RegisterEvent("PLAYER_LOGIN")
end

function WatchFrameAdv:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UI_SCALE_CHANGED")
	
	if LoggedIn then self:RefreshMod() end
end

function WatchFrameAdv:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UI_SCALE_CHANGED")
end
