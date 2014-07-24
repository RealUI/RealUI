local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")

local _
local MODNAME = "GameMenu"
local GameMenu = nibRealUI:NewModule(MODNAME)

function GameMenu:Skin()
	-- Title text
	for i = 1, GameMenuFrame:GetNumRegions() do
		local region = select(i, GameMenuFrame:GetRegions())
		if region:GetObjectType() == "FontString" then
			if region:GetText() == MAINMENU_BUTTON then
				region:SetFont(unpack(nibRealUI.font.pixel1))
				region:SetTextColor(unpack(nibRealUI.classColor))
				region:SetShadowColor(0, 0, 0, 0)
				region:SetPoint("TOP", GameMenuFrame, "TOP", 0, -10.5)
			end
		end
	end

	GameMenuButtonStore:SetScale(0.00001)
	GameMenuButtonStore:SetAlpha(0)

	-- RealUI Control
	local ConfigStr = string.format("|cffffffffReal|r|cff%sUI|r Config", nibRealUI:ColorTableToStr(nibRealUI.media.colors.red))
	GameMenuFrame.realuiControl = nibRealUI:CreateTextButton(ConfigStr, GameMenuFrame, GameMenuButtonQuit:GetWidth(), GameMenuButtonQuit:GetHeight())
	GameMenuFrame.realuiControl:SetPoint("BOTTOM", GameMenuFrame, "BOTTOM", 0, 21)
	GameMenuFrame.realuiControl:SetScript("OnMouseUp", function() nibRealUI:ShowConfigBar(); HideUIPanel(GameMenuFrame) end)

	-- Button Backgrounds
	nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonHelp, GameMenuButtonHelp)
	nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonOptions, GameMenuButtonMacros)

	nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonLogout, GameMenuButtonQuit)
	nibRealUI:CreateBGSection(GameMenuFrame, GameMenuButtonContinue, GameMenuButtonContinue)
	nibRealUI:CreateBGSection(GameMenuFrame, GameMenuFrame.realuiControl, GameMenuFrame.realuiControl)
end
----------

function GameMenu:OnInitialize()
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Game Menu")
end

function GameMenu:OnEnable()
	GameMenu:Skin()
	GameMenuFrame:HookScript("OnShow", function() GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 37) end)
end
