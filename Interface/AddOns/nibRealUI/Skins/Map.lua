local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "Map"
local Map = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0")

local strform = string.format

local mop_530 = select(4, GetBuildInfo()) >= 50300

----------
function Map:SetMapStrata()
	WorldMapFrame:SetFrameLevel(10)
	WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
	WorldMapFrame:SetFrameStrata("HIGH")
end

function Map:Skin()
	local Aurora = Aurora
	if not Aurora then return end
	
	local F = Aurora[1]
	
	WorldMapFrameTitle:Hide()
	
	F.SetBD(WorldMapPositioningGuide)

	WorldMapPlayerUpper:EnableMouse(false)
	WorldMapPlayerLower:EnableMouse(false)
	
	F.ReskinScroll(WorldMapQuestScrollFrameScrollBar)
	F.ReskinScroll(WorldMapQuestDetailScrollFrameScrollBar)
	F.ReskinScroll(WorldMapQuestRewardScrollFrameScrollBar)
	
	if not WorldMapPositioningGuide.SizeSet then
		WorldMapPositioningGuide:SetWidth(WorldMapPositioningGuide:GetWidth() - 8)
		WorldMapPositioningGuide:SetHeight(WorldMapPositioningGuide:GetHeight() - 6)
		WorldMapPositioningGuide.SizeSet = true
	end
	
	F.ReskinClose(WorldMapFrameCloseButton)
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -3, -3)
	WorldMapFrameCloseButton:SetFrameStrata("HIGH")
	WorldMapFrameCloseButton:SetFrameLevel(12)
	
	F.ReskinDropDown(WorldMapLevelDropDown)
	F.ReskinDropDown(WorldMapZoneMinimapDropDown)
	F.ReskinDropDown(WorldMapContinentDropDown)
	F.ReskinDropDown(WorldMapZoneDropDown)
	F.ReskinDropDown(WorldMapShowDropDown)
	
	F.Reskin(WorldMapZoomOutButton)
	
	if not mop_530 then
		F.ReskinCheck(WorldMapQuestShowObjectives)
		F.ReskinCheck(WorldMapShowDigSites)
	end

	if foglightmenu then
		F.ReskinDropDown(foglightmenu)
	end

	local function FixSkin()
		-- Init Coords update
		Map:ScheduleRepeatingTimer("UpdateCoords", 0.05)
		
		-- Strip textures, set standard fonts
		for i = 1, WorldMapFrame:GetNumRegions() do
			local region = select(i, WorldMapFrame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			elseif region:GetObjectType() == "FontString" then
				region:SetFont(nibRealUI.font.standard, 13)
			end
		end
		
		-- Track Quest checkbox
		F.ReskinCheck(WorldMapTrackQuest)
		WorldMapTrackQuest:ClearAllPoints()
		WorldMapTrackQuest:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -222, 0)
		WorldMapTrackQuestText:ClearAllPoints()
		WorldMapTrackQuestText:SetPoint("BOTTOMRIGHT", WorldMapTrackQuest, "BOTTOMLEFT", -2, 6.5)
		WorldMapTrackQuestText:SetFont(unpack(nibRealUI.font.pixel1))
		WorldMapTrackQuestText:SetTextColor(1, 1, 1)
		WorldMapTrackQuestText:SetShadowColor(0, 0, 0, 0)

		if not mop_530 then
			-- Show Objectives checkbox
			WorldMapQuestShowObjectives:ClearAllPoints()
			WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -22, -1)
			WorldMapQuestShowObjectivesText:ClearAllPoints()
			WorldMapQuestShowObjectivesText:SetPoint("BOTTOMRIGHT", WorldMapQuestShowObjectives, "BOTTOMLEFT", -2, 6.5)
			WorldMapQuestShowObjectivesText:SetFont(unpack(nibRealUI.font.pixel1))
			WorldMapQuestShowObjectivesText:SetTextColor(1, 1, 1)
			WorldMapQuestShowObjectivesText:SetShadowColor(0, 0, 0, 0)

			-- Show Digsites checkbox
			WorldMapShowDigSites:ClearAllPoints()
			WorldMapShowDigSites:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -352, -1)
			WorldMapShowDigSitesText:ClearAllPoints()
			WorldMapShowDigSitesText:SetPoint("BOTTOMRIGHT", WorldMapShowDigSites, "BOTTOMLEFT", -2, 6.5)
			WorldMapShowDigSitesText:SetFont(unpack(nibRealUI.font.pixel1))
			WorldMapShowDigSitesText:SetTextColor(1, 1, 1)
			WorldMapShowDigSitesText:SetShadowColor(0, 0, 0, 0)
		else
			WorldMapShowDropDown:ClearAllPoints()
			WorldMapShowDropDown:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -22, -5)
		end
		
		-- Top Dropdown Fonts
		local function SetDropdownHeaderFont(r)
			r:SetFont(unpack(nibRealUI.font.pixel1))
			r:SetTextColor(unpack(nibRealUI.classColor))
			r:SetShadowColor(0, 0, 0, 0)
		end
		for i = 1, WorldMapZoneMinimapDropDown:GetNumRegions() do
			local region = select(i, WorldMapZoneMinimapDropDown:GetRegions())
			if region:GetObjectType() == "FontString" then
				if region:GetText() == BATTLEFIELD_MINIMAP then
					SetDropdownHeaderFont(region)
				end
			end
		end
		for i = 1, WorldMapContinentDropDown:GetNumRegions() do
			local region = select(i, WorldMapContinentDropDown:GetRegions())
			if region:GetObjectType() == "FontString" then
				if region:GetText() == CONTINENT then
					SetDropdownHeaderFont(region)
				end
			end
		end
		for i = 1, WorldMapZoneDropDown:GetNumRegions() do
			local region = select(i, WorldMapZoneDropDown:GetRegions())
			if region:GetObjectType() == "FontString" then
				if region:GetText() == ZONE then
					SetDropdownHeaderFont(region)
				end
			end
		end
		SetDropdownHeaderFont(WorldMapLevelDropDown.header)
		
		-- Frame level
		if InCombatLockdown() then return end
		self:SetMapStrata()
	end
	local function Hidden()
		Map:CancelAllTimers()
	end
	
	WorldMapFrame:HookScript("OnShow", FixSkin)
	WorldMapFrame:HookScript("OnHide", Hidden)
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)
end

local classColorStr
function Map:UpdateCoords()
	if not classColorStr then classColorStr = nibRealUI:ColorTableToStr(nibRealUI.classColor) end
	
	-- Player
	local x, y = GetPlayerMapPosition("player")
	x = nibRealUI:Round(100 * x, 1)
	y = nibRealUI:Round(100 * y, 1)
	
	if x ~= 0 and y ~= 0 then
		self.coords.player:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, PLAYER, x, y))
	else
		self.coords.player:SetText("")
	end
	
	-- Mouse
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()
	local adjustedX = (x / scale - (centerX - (width/2))) / width
	local adjustedY = (centerY + (height/2) - y / scale) / height	

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = nibRealUI:Round(100 * adjustedX, 1)
		adjustedY = nibRealUI:Round(100 * adjustedY, 1)
		self.coords.mouse:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, MOUSE_LABEL, adjustedX, adjustedY))
	else
		self.coords.mouse:SetText("")
	end
end

function Map:SetUpCoords()
	self.coords = CreateFrame("Frame", nil, WorldMapFrame)
	
	self.coords:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
	self.coords:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
	
	self.coords.player = self.coords:CreateFontString(nil, "OVERLAY")
	self.coords.player:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 4.5, 4.5)
	self.coords.player:SetFont(unpack(nibRealUI.font.pixel1))
	self.coords.player:SetText("")
	
	self.coords.mouse = self.coords:CreateFontString(nil, "OVERLAY")
	self.coords.mouse:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 120.5, 4.5)
	self.coords.mouse:SetFont(unpack(nibRealUI.font.pixel1))
	self.coords.mouse:SetText("")
end

function Map:SetMapSize()
	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:EnableMouse(false)
	WorldMapFrame:EnableKeyboard(false)
	
	if WorldMapFrame:GetAttribute("UIPanelLayout-area") ~= "center" then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end
	
	if WorldMapFrame:GetAttribute("UIPanelLayout-allowOtherPanels") ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end
	
	WorldMapFrameSizeDownButton:Hide()
	WorldMapFrameSizeDownButton.Show = function() return end
	WorldMapFrameSizeUpButton:Hide()
	WorldMapFrameSizeUpButton.Show = function() return end
end

function Map:SetLargeWorldMap()
	if InCombatLockdown() then return end
	
	self:SetMapSize()
	WorldMapFrame:SetScale(1)
end

function Map:SetQuestWorldMap()
	if InCombatLockdown() then return end
	
	self:SetMapSize()
end

function Map:AdjustMapSize()
	if InCombatLockdown() then return end
	
	if WORLDMAP_SETTINGS.size ~= WORLDMAP_QUESTLIST_SIZE then
		WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE
	end
	self:SetQuestWorldMap()
	
	WorldMapFrame:SetFrameStrata("HIGH")
	WorldMapFrame:SetFrameLevel(3)
	WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
end

function Map:ToggleTinyWorldMapSetting()
	if InCombatLockdown() then return end
	
	BlackoutWorld:SetTexture(nil)
	
	self:SecureHook("WorldMap_ToggleSizeUp", "AdjustMapSize")
	self:SecureHook("WorldMapFrame_SetFullMapView", "SetLargeWorldMap")
	self:SecureHook("WorldMapFrame_SetQuestMapView", "SetQuestWorldMap")
	
	if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
		self:SetLargeWorldMap()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		self:SetQuestWorldMap()
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		self:SetQuestWorldMap()
	end
end

function Map:ResetDropDownListPosition(frame)
	DropDownList1:ClearAllPoints()
	DropDownList1:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -17, -4)
end

function Map:WorldMapFrame_OnShow()
	if InCombatLockdown() then return; end
	self:SetMapStrata()
end

----------

function Map:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "World Map")
end

function Map:OnEnable()
	if IsAddOnLoaded("Mapster") or IsAddOnLoaded("m_Map") or IsAddOnLoaded("MetaMap") then return end

	-- 5.4.1 Taint fix
	setfenv(WorldMapFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G }))
	
	-- Make sure we're not in Windowed mode
	if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) then
		SetCVar("miniWorldMap", 0)
		WorldMap_ToggleSizeUp()
	end

	self:SetMapStrata()	
	
	WorldMapShowDropDown:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -2, -4)
	WorldMapZoomOutButton:SetPoint("LEFT", WorldMapZoneDropDown, "RIGHT", 0, 2)
	WorldMapLevelUpButton:SetPoint("TOPLEFT", WorldMapLevelDropDown, "TOPRIGHT", -2, 6)
	WorldMapLevelDownButton:SetPoint("BOTTOMLEFT", WorldMapLevelDropDown, "BOTTOMRIGHT", -2, 2)
	
	self:HookScript(WorldMapFrame, "OnShow", "WorldMapFrame_OnShow")
	self:HookScript(WorldMapZoneDropDownButton, "OnClick", "ResetDropDownListPosition")
	
	self:SetUpCoords()
	self:ToggleTinyWorldMapSetting()
	
	DropDownList1:HookScript("OnShow", function(self)
		if DropDownList1:GetScale() ~= UIParent:GetScale() then
			DropDownList1:SetScale(UIParent:GetScale())
		end		
	end)
	
	self:Skin()
end