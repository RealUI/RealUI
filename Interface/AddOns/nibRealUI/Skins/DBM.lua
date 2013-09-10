local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "SkinDBM"
local SkinDBM = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")
local dbc

function SkinDBM:Skin()
	local F = Aurora[1]
	if DBM and DBM.Bars and nibRealUICharacter then
		if not dbc.settingsApplied then
			nibRealUI:LoadDBMData()

			DBM.Bars:SetOption("FontSize", 1)
			DBM.Bars:SetOption("HugeScale", 1)
			DBM.Bars:SetOption("Scale", 1)
			DBM.Bars:SetOption("HugeWidth", 160)
			DBM.Bars:SetOption("Width", 160)
			DBM.Bars:SetOption("HugeBarYOffset", 9)
			DBM.Bars:SetOption("BarYOffset", 9)

			dbc.settingsApplied = true

			if (nibRealUICharacter.installStage == -1) and (nibRealUI.db.global.tags.tutorialdone) then
				print("|cFFFFFFFFDBM settings loaded.|r |cffFFFFFFReload UI (|r|cFFFF8000/rl|r|cffFFFFFF) for these settings to apply.")
				nibRealUI:Notification("DBM settings loaded.", true, "Reload UI (|cFFFF8000/rl|r) for these settings to apply.")
			end
		end
	end

	hooksecurefunc(DBT, "CreateBar", function(self)
		for bar in self:GetBarIterator() do
			if not bar.styled then
				local frame = bar.frame
				local name = frame:GetName()

				local tbar = _G[name.."Bar"]
				local texture = _G[name.."BarTexture"]
				local spark = _G[name.."BarSpark"]
				local text = _G[name.."BarName"]
				local timer = _G[name.."BarTimer"]
				local icon1 = _G[name.."BarIcon1"]

				tbar:SetHeight(7)

				F.CreateBDFrame(tbar, 0.35)

				texture:SetTexture(RealUI.media.textures.plain)
				texture.SetTexture = F.dummy

				spark:SetHeight(28)
				spark:SetWidth(16)
				spark:SetTexture([[Interface\AddOns\nibRealUI\Media\Skins\DBMSpark]])

				text:ClearAllPoints()
				text:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 18)
				text:SetFont(RealUI.font.standard, 11, "OUTLINE")
				text:SetShadowColor(0, 0, 0, 0)
				text.SetFont = F.dummy

				timer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 16)
				timer:SetFont(RealUI.font.standard, 11, "OUTLINE")
				timer:SetShadowColor(0, 0, 0, 0)
				timer.SetFont = F.dummy
				
				icon1:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				icon1:ClearAllPoints()
				icon1:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -4, 6.5)
				icon1:SetSize(24, 24)
				F.CreateBDFrame(icon1)

				bar.styled = true
			end
		end
	end)
end

function SkinDBM:ADDON_LOADED(event, addon)
	if addon == "DBM-Core" then
		self:Skin()
	end
end
----------

function SkinDBM:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
		char = {
			settingsApplied = false,
		},
	})
	dbc = self.db.char

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "DBM")
end

function SkinDBM:OnEnable()
	if not Aurora then return end
	if IsAddOnLoaded("DBM-Core") then
		self:Skin()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end