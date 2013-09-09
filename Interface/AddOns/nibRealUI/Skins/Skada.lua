local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "SkadaSkin"
local SkadaSkin = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

function SkadaSkin:Skin()
	-- Short Numbers
	local SkadaFormatValueText = Skada.FormatValueText

	local function FormatValues(value, enabled, ...)
		if value == nil then
			return
		elseif ( type(value) == "number" or ( type(value) == "string" and value:match("^[-+]?[%d.,]+$") )) and tonumber(value) > 1000 then
			value = Skada:FormatNumber(tonumber(value))
		end
		return value, enabled, FormatValues(...)
	end

	function Skada:FormatValueText(...)
		return SkadaFormatValueText(self, FormatValues(...))
	end

	-- Background + Textures
	local skadaBar = Skada.displays["bar"]
	skadaBar._ApplySettings = skadaBar.ApplySettings
	skadaBar.ApplySettings = function(self, win)
		skadaBar._ApplySettings(self, win)
		
		local skada = win.bargroup
		
		if win.db.enabletitle and not skada.button.skinned then
			skada.button.skinned = true
			nibRealUI:CreateBDFrame(skada.button, nil, true, true)
		end

		-- skada:SetFont(unpack(nibRealUI:Font(false, "small")))
		skada:SetTexture(nibRealUI.media.textures.plain80)
		skada:SetSpacing(0)
		skada:SetFrameLevel(5)
		
		skada:SetBackdrop(nil)
		if not skada.backdrop then
			skada.backdrop = nibRealUI:CreateBDFrame(skada, nil, true, true)
		end
	end

	for _, window in ipairs(Skada:GetWindows()) do
		window:UpdateDisplay()
	end
end

function SkadaSkin:ADDON_LOADED(event, addon)
	if addon == "Skada" then
		self:Skin()
	end
end
----------

function SkadaSkin:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Skada")
end

function SkadaSkin:OnEnable()
	if IsAddOnLoaded("Skada") then
		self:Skin()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end