local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "SkinDXE"
local SkinDXE = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")
local dbc

local function kill(frame)
	if frame.isKilled then return end

	frame:Hide()
	frame:HookScript("OnShow", frame.Hide)

	frame.isKilled = true
end

function SkinDXE:SkinBar(bar)
	-- Text
	bar.text:SetFont(unpack(nibRealUI:Font()))
	bar.text:SetShadowColor(0, 0, 0, 0)
	bar.timer.left:SetFont(unpack(nibRealUI.font.pixelNumbers))
	bar.timer.left:SetShadowColor(0, 0, 0, 0)
	bar.timer.right:SetFont(unpack(nibRealUI.font.pixel1))
	bar.timer.right:SetShadowColor(0, 0, 0, 0)

	-- The main bar
	nibRealUI:CreateBD(bar)
	bar.bg:SetTexture(nil)
	kill(bar.border)

	bar.statusbar:SetStatusBarTexture(nibRealUI.media.textures.plain)
	bar.statusbar:ClearAllPoints()
	bar.statusbar:SetPoint("TOPLEFT", 1, -1)
	bar.statusbar:SetPoint("BOTTOMRIGHT", -1, 1)

	-- Right Icon
	nibRealUI:CreateBD(bar.righticon)
	kill(bar.righticon.border)
	bar.righticon.t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	bar.righticon.t:ClearAllPoints()
	bar.righticon.t:SetPoint("TOPLEFT", 1, -1)
	bar.righticon.t:SetPoint("BOTTOMRIGHT", -1, 1)
	bar.righticon.t:SetDrawLayer("ARTWORK")

	-- Left Icon
	nibRealUI:CreateBD(bar.lefticon)
	kill(bar.lefticon.border)
	bar.lefticon.t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	bar.lefticon.t:ClearAllPoints()
	bar.lefticon.t:SetPoint("TOPLEFT", 1, -1)
	bar.lefticon.t:SetPoint("BOTTOMRIGHT", -1, 1)
	bar.lefticon.t:SetDrawLayer("ARTWORK")

	bar.skinned = true
end

function SkinDXE:Skin()
	-- Stop DXE from skinning it's own frames
	DXE.NotifyBarTextureChanged = 			function() end
	DXE.NotifyBorderChanged = 				function() end
	DXE.NotifyBorderColorChanged = 			function() end
	DXE.NotifyBorderEdgeSizeChanged = 		function() end
	DXE.NotifyBackgroundTextureChanged =	function() end
	DXE.NotifyBackgroundInsetChanged = 		function() end
	DXE.NotifyBackgroundColorChanged = 		function() end

	-- Skin Window
	DXE.CreateWindow_ = DXE.CreateWindow
	DXE.CreateWindow = function(self, name, width, height)
		local win = self:CreateWindow_(name, width, height)
		win.faux_window:SetBackdrop(nil)
		nibRealUI:CreateBD(win, nil, true, true)
		win.gradient:SetTexture(0, 0, 0, 0)
		win.gradient:SetGradient("HORIZONTAL", 0, 0, 0, 0, 0, 0, 0, 0)

		win.titletext:SetFont(nibRealUI.font.pixel1[1], nibRealUI.font.pixel1[2] / win.faux_window:GetScale(), nibRealUI.font.pixel1[3])
		return win
	end

	-- Bar Refresh
	DXE.Alerts.RefreshBars_ = DXE.Alerts.RefreshBars
	DXE.Alerts.RefreshBars = function(self)
		if self.refreshing then return end
		self.refreshing = true

		self:RefreshBars_()

		local cnt = 1
		while _G["DXEAlertBar"..cnt] do
			local bar = _G["DXEAlertBar"..cnt]

			bar:SetScale(1)
			bar.SetScale = function() end
			SkinDXE:SkinBar(bar)

			cnt = cnt + 1
		end

		self.refreshing = false
	end

	DXE.Alerts.Dropdown_ = DXE.Alerts.Dropdown
	DXE.Alerts.Dropdown = function(self,...)
		self:Dropdown_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.CenterPopup_ = DXE.Alerts.CenterPopup
	DXE.Alerts.CenterPopup = function(self,...)
		self:CenterPopup_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.Simple_ = DXE.Alerts.Simple
	DXE.Alerts.Simple = function(self,...)
		self:Simple_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.Absorb_ = DXE.Alerts.Absorb
	DXE.Alerts.Absorb = function(self,...)
		self:Absorb_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts.DebuffPopup_ = DXE.Alerts.DebuffPopup
	DXE.Alerts.DebuffPopup = function(self,...)
		self:DebuffPopup_(...)
		self:RefreshBars()
	end
	
	DXE.Alerts:RefreshBars()
end

function SkinDXE:ADDON_LOADED(event, addon)
	if addon == "DXE" then
		self:Skin()
	end
end
----------

function SkinDXE:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
		char = {
			settingsApplied = false,
		},
	})
	dbc = self.db.char

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "DXE")
end

function SkinDXE:OnEnable()
	if not Aurora then return end
	if IsAddOnLoaded("DXE") then
		self:Skin()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end
