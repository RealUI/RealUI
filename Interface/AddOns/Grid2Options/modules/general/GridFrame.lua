--[[
	Grid2 frames/cells options
--]]

local L = Grid2Options.L

Grid2Options:AddGeneralOptions("General", "Frames", { orientation = {
		type = "select",
		order = 10,
		name = L["Orientation of Frame"],
		desc = L["Set frame orientation."],
		get = function ()
			return Grid2Frame.db.profile.orientation
		end,
		set = function (_, v)
			Grid2Frame.db.profile.orientation = v
			for _, indicator in Grid2:IterateIndicators() do
				if indicator.SetOrientation and indicator.orientation==nil then
					Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
				end
			end
		end,
		values={["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
}, texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 20,
		name = L["Background Texture"],
		desc = L["Select the frame background texture."],
		get = function (info) return Grid2Frame.db.profile.frameTexture or "Gradient" end,
		set = function (info, v)
			Grid2Frame.db.profile.frameTexture = v
			Grid2Frame:LayoutFrames()
		end,
		values = AceGUIWidgetLSMlists.statusbar,			
}, font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 30,
		name = L["Default Font"],
		desc = L["Adjust the font settings"],
		get = function(info) return Grid2Frame.db.profile.font end,
		set = function(info,v)
			Grid2Frame.db.profile.font = v
			for _, indicator in Grid2:IterateIndicators() do
				if indicator.textfont and indicator.dbx.font==nil then
					Grid2Options:RefreshIndicator( indicator, "Create" )
				end
			end

		end,
		values = AceGUIWidgetLSMlists.font,
}, tooltip = {
		type = "select",
		order = 40,
		name = L["Show Tooltip"],
		desc = L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."],
		get = function ()
			return Grid2Frame.db.profile.showTooltip
		end,
		set = function (_, v)
			Grid2Frame.db.profile.showTooltip = v
		end,
		values={["Always"] = L["Always"], ["Never"] = L["Never"], ["OOC"] = L["OOC"]},
}, framewidth = {
		type = "range",
		order = 50,
		name = L["Frame Width"],
		desc = L["Adjust the width of each unit's frame."],
		min = 10,
		softMax = 100,
		step = 1,
		get = function ()
			return Grid2Frame.db.profile.frameWidth
		end,
		set = function (_, v)
			Grid2Frame.db.profile.frameWidth = v
			Grid2Layout:UpdateDisplay()
			if Grid2Options.LayoutTestRefresh then Grid2Options:LayoutTestRefresh() end
		end,
		disabled = InCombatLockdown,
}, frameheight = {
		type = "range",
		order = 60,
		name = L["Frame Height"],
		desc = L["Adjust the height of each unit's frame."],
		min = 10,
		softMax = 100,		
		step = 1,
		get = function ()
			return Grid2Frame.db.profile.frameHeight
		end,
		set = function (_, v)
			Grid2Frame.db.profile.frameHeight = v
			Grid2Layout:UpdateDisplay()
			if Grid2Options.LayoutTestRefresh then Grid2Options:LayoutTestRefresh() end
		end,
		disabled = InCombatLockdown,
}, borderDistance= {
		type = "range",
		name = L["Inner Border Size"],
		desc = L["Sets the size of the inner border of each unit frame"],
		min = -16,
		max = 16,
		step = 1,
		order = 70,
		get = function ()
			return Grid2Frame.db.profile.frameBorderDistance
		end,
		set = function (_, v)
			Grid2Frame.db.profile.frameBorderDistance = v
			Grid2Frame:LayoutFrames()
		end,
}, colorFrame = {
		type = "color",
		order = 80,
		name = L["Inner Border Color"],
		desc = L["Sets the color of the inner border of each unit frame"],
		get = function()
			local c= Grid2Frame.db.profile.frameColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= Grid2Frame.db.profile.frameColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:LayoutFrames()
		 end, 
		hasAlpha = true,
}, colorContent = {
		type = "color",
		order = 90,
		name = L["Background Color"],
		desc = L["Sets the background color of each unit frame"],
		get = function()
			local c= Grid2Frame.db.profile.frameContentColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= Grid2Frame.db.profile.frameContentColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:LayoutFrames()
			Grid2Frame:UpdateIndicators()
		 end, 
		hasAlpha = true,
}, mouseoverHighlight = {
		type = "toggle",
		name = L["Mouseover Highlight"],
		desc = L["Toggle mouseover highlight."],
		order = 100,
		get = function ()
			return Grid2Frame.db.profile.mouseoverHighlight
		end,
		set = function (_, v)
			Grid2Frame.db.profile.mouseoverHighlight = v
			Grid2Frame:LayoutFrames()
		end,
},} )


