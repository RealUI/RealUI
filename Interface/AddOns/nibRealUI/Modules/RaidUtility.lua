local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "RaidUtility"
local RaidUtility = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Raid Utility",
		desc = "Provides raid functions for raid leaders.",
		arg = MODNAME,
		-- order = 1916,
		args = {
			header = {
				type = "header",
				name = "Raid Utility",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Provides raid functions for raid leaders.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Raid Utility module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

local function DisbandRaidGroup()
	if InCombatLockdown() then return end

	if UnitInRaid("player") then
		SendChatMessage(ERR_GROUP_DISBANDED, "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= nibRealUI.name then UninviteUnit(name) end
		end
	else
		SendChatMessage(ERR_GROUP_DISBANDED, "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetNumGroupMembers(i) then UninviteUnit(UnitName("party"..i)) end
		end
	end
	LeaveParty()
end

StaticPopupDialogs["PUDRUIDISBANDRAID"] = {
    text = "Disband the raid group?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        DisbandRaidGroup()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    notClosableByLogout = false,
}

local function CheckRaidStatus()
	local _, instanceType = IsInInstance()
	if ((GetNumGroupMembers() > 0 and UnitIsGroupLeader("player") and not UnitInRaid("player")) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and (instanceType ~= "pvp" or instanceType ~= "arena") then
		return true
	else
		return false
	end
end

local function CreateButton(name, parent, template, width, height, SetPoint, relativeto, SetPoint2, xOfs, yOfs, text)
	local b = CreateFrame("Button", name, parent, template)
	b:SetWidth(width)
	b:SetHeight(height)
	b:SetPoint(SetPoint, relativeto, SetPoint2, xOfs, yOfs)
	b:EnableMouse(true)
	if Aurora then
        Aurora[1].Reskin(b)
    end
	if text then
		b.t = b:CreateFontString(nil, "OVERLAY")
		b.t:SetFontObject(SystemFont_Small)
		b.t:SetPoint("CENTER", 0, -1)
		b.t:SetJustifyH("CENTER")
		b.t:SetText(text)
	end
end

function RaidUtility:SetUpFrame()
	--[[Raid Utility(by Elv22)]]--
	local anchor = CreateFrame("Frame", "RealUIRaidUtilityAnchor", UIParent)
	anchor:SetSize(170, 21)
	anchor:SetPoint("TOP", UIParent, "TOP", -350, 0)
	anchor:Hide()

	--[[Raid Utility(by Elv22)]]--
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
	RaidUtilityPanel:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
	nibRealUI:CreateBD(RaidUtilityPanel, nil, true, true)
	RaidUtilityPanel:SetSize(170, 116)


	CreateButton("RaidUtilityShowButton", UIParent, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth(), 18, "TOP", RaidUtilityPanel, "TOP", 0, 0, RAID_CONTROL)
	RaidUtilityShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
	RaidUtilityShowButton:SetAttribute("_onclick", [=[self:Hide(); self:GetFrameRef("RaidUtilityPanel"):Show();]=])
	RaidUtilityShowButton:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			if CheckRaidStatus() then DoReadyCheck() end
		elseif button == "MiddleButton" then
			if CheckRaidStatus() then InitiateRolePoll() end
		elseif button == "LeftButton" then
			RaidUtilityPanel.toggled = true
		end
	end)

	CreateButton("RaidUtilityCloseButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth(), 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE)
	RaidUtilityCloseButton:SetFrameRef("RaidUtilityShowButton", RaidUtilityShowButton)
	RaidUtilityCloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtilityShowButton"):Show();]=])
	RaidUtilityCloseButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = false end)

	CreateButton("RaidUtilityDisbandButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -4, "Disband")
	RaidUtilityDisbandButton:SetScript("OnMouseUp", function(self) StaticPopup_Show("PUDRUIDISBANDRAID") end)

	CreateButton("RaidUtilityConvertButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityDisbandButton, "BOTTOM", 0, -4, UnitInRaid("player") and CONVERT_TO_PARTY or CONVERT_TO_RAID)
	RaidUtilityConvertButton:SetScript("OnMouseUp", function(self)
		if UnitInRaid("player") then
			ConvertToParty()
			RaidUtilityConvertButton.t:SetText(CONVERT_TO_RAID)
		elseif UnitInParty("player") then
			ConvertToRaid()
			RaidUtilityConvertButton.t:SetText(CONVERT_TO_PARTY)
		end
	end)

	CreateButton("RaidUtilityRoleButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityConvertButton, "BOTTOM", 0, -4, ROLE_POLL)
	RaidUtilityRoleButton:SetScript("OnMouseUp", function(self) InitiateRolePoll() end)

	CreateButton("RaidUtilityMainTankButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 2, 18, "TOPLEFT", RaidUtilityRoleButton, "BOTTOMLEFT", 0, -4, TANK)
	RaidUtilityMainTankButton:SetAttribute("type", "maintank")
	RaidUtilityMainTankButton:SetAttribute("unit", "target")
	RaidUtilityMainTankButton:SetAttribute("action", "toggle")

	CreateButton("RaidUtilityMainAssistButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", RaidUtilityRoleButton, "BOTTOMRIGHT", 0, -4, MAINASSIST)
	RaidUtilityMainAssistButton:SetAttribute("type", "mainassist")
	RaidUtilityMainAssistButton:SetAttribute("unit", "target")
	RaidUtilityMainAssistButton:SetAttribute("action", "toggle")

	CreateButton("RaidUtilityReadyCheckButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityRoleButton:GetWidth() * 0.75, 18, "TOPLEFT", RaidUtilityMainTankButton, "BOTTOMLEFT", 0, -4, READY_CHECK)
	RaidUtilityReadyCheckButton:SetScript("OnMouseUp", function(self) DoReadyCheck() end)

	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", RaidUtilityMainAssistButton, "BOTTOMRIGHT", 0, -4)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHeight(18)
	CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetWidth(RaidUtilityRoleButton:GetWidth() * 0.22)
	if Aurora then
        Aurora[1].Reskin(CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton)
    end

	local MarkTexture = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:CreateTexture(nil, "OVERLAY")
	MarkTexture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
	MarkTexture:SetPoint("CENTER", 0, -1)
end

-------
local function ToggleRaidUtil(self, event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtilityShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtilityShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtilityShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == "PLAYER_REGEN_ENABLED" then self:UnregisterEvent("PLAYER_REGEN_ENABLED") end
end

-------
function RaidUtility:GROUP_ROSTER_UPDATE()
	ToggleRaidUtil()
end

function RaidUtility:PLAYER_ENTERING_WORLD()
	ToggleRaidUtil()
end

-------
function RaidUtility:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function RaidUtility:OnEnable()
	self:SetUpFrame()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function RaidUtility:OnDisable()
	self:UnregisterAllEvents()
	
	if RaidUtilityPanel and RaidUtilityShowButton then
		RaidUtilityShowButton:Hide()
		RaidUtilityPanel:Hide()
	end
end