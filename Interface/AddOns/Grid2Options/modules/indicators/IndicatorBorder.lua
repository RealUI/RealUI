local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("border", false, function(self, indicator)
	local options, statuses = {}, {}
	self:MakeIndicatorBorderCustomOptions(indicator,options)
	self:MakeIndicatorColorOptions(indicator, options, {
		color1 = L["Border Background Color"],
		colorDesc1 = L["Adjust border background color and alpha."],
		typeKey = "indicators",
	})
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorBorderCustomOptions(indicator,options)
	options.borderSize = {
		type = "range",
		order = 10,
		name = L["Border Size"],
		desc = L["Adjust the border of each unit's frame."],
		min = 1,
		max = 20,
		step = 1,
		get = function () return Grid2Frame.db.profile.frameBorder end,
		set = function (_, frameBorder)
			Grid2Frame.db.profile.frameBorder = frameBorder
			Grid2Frame:LayoutFrames()
		end,
		disabled = InCombatLockdown,
	}
	options.borderDistance= {
		type = "range",
		name = L["Border separation"],
		desc = L["Adjust the distance between the border and the frame content."],
		min = -16,
		max = 16,
		step = 1,
		order = 15,
		get = function () return Grid2Frame.db.profile.frameBorderDistance end,
		set = function (_, v)
			Grid2Frame.db.profile.frameBorderDistance = v
			Grid2Frame:LayoutFrames()
		end,
	}		
	options.borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = 25,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return Grid2Frame.db.profile.frameBorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			Grid2Frame.db.profile.frameBorderTexture = v
			Grid2Frame:LayoutFrames()
		end, 
		values = AceGUIWidgetLSMlists.border,
	}
end

