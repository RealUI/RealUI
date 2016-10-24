--[[
	General > General Tab > Layout Section
--]]

local L = Grid2Options.L

local order_layout  = 20
local order_display = 30
local order_anchor  = 40

Grid2Options:AddGeneralOptions( "General" , "Layout Settings", { horizontal = {
		type = "toggle",
		name = L["Horizontal groups"],
		desc = L["Switch between horzontal/vertical groups."],
		order = order_layout + 4,
		get = function ()
				  return Grid2Layout.db.profile.horizontal
			  end,
		set = function ()
			Grid2Layout.db.profile.horizontal = not Grid2Layout.db.profile.horizontal
			Grid2Layout:ReloadLayout(true)
			if Grid2Options.LayoutTestRefresh then Grid2Options:LayoutTestRefresh()	end	
		 end,
}, lock = {
		type = "toggle",
		name = L["Frame lock"],
		desc = L["Locks/unlocks the grid for movement."],
		order = order_layout + 6,
		get = function() return Grid2Layout.db.profile.FrameLock end,
		set = function()
			Grid2Layout:FrameLock()
		end,
}, clickthrough = {
		type = "toggle",
		name = L["Click through the Grid Frame"],
		desc = L["Allows mouse click through the Grid Frame."],
		order = order_layout + 7,
		get = function() return Grid2Layout.db.profile.ClickThrough end,
		set = function()
			local v = not Grid2Layout.db.profile.ClickThrough
			Grid2Layout.db.profile.ClickThrough = v
			Grid2Layout.frame:EnableMouse(not v)
		end,
		disabled = function () return not Grid2Layout.db.profile.FrameLock end,
}, rightClickMenu = {
		type = "toggle",
		name = L["Right Click Menu"],
		desc = L["Display the standard unit menu when right clicking on a frame."],
		order = order_layout + 8,
		get = function () return not Grid2Frame.db.profile.menuDisabled	end,
		set = function (_, v)
			Grid2Frame.db.profile.menuDisabled = (not v) or nil
			Grid2Frame:UpdateMenu()
			Grid2Frame:WithAllFrames( function(f) f.menu = Grid2Frame.RightClickUnitMenu end )
		end,
}, displayheader = {
		type = "header",
		order = order_display,
		name = L["Display"],
}, display = {
		type = "select",
		name = L["Show Frame"],
		desc = L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."],
		order = order_display + 1,
		get = function() return Grid2Layout.db.profile.FrameDisplay end,
		set = function(_, v)
			Grid2Layout.db.profile.FrameDisplay = v
			Grid2Layout:CheckVisibility()
		end,
		values={["Always"] = L["Always"], ["Grouped"] = L["Grouped"], ["Raid"] = L["Raid"]},
}, frameStrata = {
		type = "select",
		name = L["Frame Strata"],
		desc = L["Sets the strata in which the layout frame should be layered."],
		order = order_display + 2,
		get = function() return Grid2Layout.db.profile.FrameStrata or "MEDIUM" end,
		set = function(_, v)
			Grid2LayoutFrame:SetFrameStrata( v )
			Grid2Layout.db.profile.FrameStrata = (v~="MEDIUM") and v or nil
		end,
		values ={ BACKGROUND = L["BACKGROUND"], LOW = L["LOW"], MEDIUM = L["MEDIUM"], HIGH = L["HIGH"] },		
}, borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = order_display + 3,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return Grid2Layout.db.profile.BorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			Grid2Layout.db.profile.BorderTexture = v
			Grid2Layout:UpdateTextures()
			Grid2Layout:UpdateColor()
		end,
		values = AceGUIWidgetLSMlists.border,
}, spacing = {
		type = "range",
		name = L["Spacing"],
		desc = L["Adjust frame spacing."],
		order = order_display + 4,
		max = 25,
		min = 0,
		step = 1,
		get = function ()
				  return Grid2Layout.db.profile.Spacing
			  end,
		set = function (_, v)
				  Grid2Layout.db.profile.Spacing = v
				  Grid2Layout:ReloadLayout(true)
			  end,
}, padding = {
		type = "range",
		name = L["Padding"],
		desc = L["Adjust frame padding."],
		order = order_display + 5,
		max = 20,
		min = 0,
		step = 1,
		get = function ()
				  return Grid2Layout.db.profile.Padding
			  end,
		set = function (_, v)
				  Grid2Layout.db.profile.Padding = v
				  Grid2Layout:ReloadLayout(true)
			  end,
}, scale = {
		type = "range",
		name = L["Scale"],
		desc = L["Adjust Grid scale."],
		order = order_display + 6,
		min = 0.5,
		max = 2.0,
		step = 0.05,
		isPercent = true,
		get = function ()
				  return Grid2Layout.db.profile.ScaleSize
			  end,
		set = function (_, v)
				  Grid2Layout.db.profile.ScaleSize = v
				  Grid2Layout:Scale()
			  end,
}, border = {
		type = "color",
		name = L["Border Color"],
		desc = L["Adjust border color and alpha."],
		order = order_display + 7,
		get = function ()
				  local settings = Grid2Layout.db.profile
				  return settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA
			  end,
		set = function (_, r, g, b, a)
				  local settings = Grid2Layout.db.profile
				  settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA = r, g, b, a
				  Grid2Layout:UpdateColor()
			  end,
		hasAlpha = true
}, background = {
		type = "color",
		name = L["Background Color"],
		desc = L["Adjust background color and alpha."],
		order = order_display + 8,
		get = function ()
				  local settings = Grid2Layout.db.profile
				  return settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA
			  end,
		set = function (_, r, g, b, a)
				  local settings = Grid2Layout.db.profile
				  settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA = r, g, b, a
				  Grid2Layout:UpdateColor()
			  end,
		hasAlpha = true
}, anchorheader = {
		type = "header",
		order = order_anchor,
		name = L["Position and Anchor"],
}, layoutanchor = {
		type = "select",
		name = L["Layout Anchor"],
		desc = L["Sets where Grid is anchored relative to the screen."],
		order = order_anchor + 1,
		get = function () return Grid2Layout.db.profile.anchor end,
		set = function (_, v)
				  Grid2Layout.db.profile.anchor = v
				  Grid2Layout:SavePosition()
				  Grid2Layout:RestorePosition()
			  end,
		values={["CENTER"] = L["CENTER"], ["TOP"] = L["TOP"], ["BOTTOM"] = L["BOTTOM"], ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"], ["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
}, groupanchor = {
		type = "select",
		name = L["Group Anchor"],
		desc = L["Sets where groups are anchored relative to the layout frame."],
		order = order_anchor + 2,
		get = function () return Grid2Layout.db.profile.groupAnchor end,
		set = function (_, v)
			Grid2Layout.db.profile.groupAnchor = v
			Grid2Layout:ReloadLayout(true)
			if Grid2Options.LayoutTestRefresh then Grid2Options:LayoutTestRefresh() end	
		end,
		values={["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
}, clamp = {
		type = "toggle",
		name = L["Clamped to screen"],
		desc = L["Toggle whether to permit movement out of screen."],
		order = order_anchor + 3,
		get = function ()
				  return Grid2Layout.db.profile.clamp
			  end,
		set = function ()
				  Grid2Layout.db.profile.clamp = not Grid2Layout.db.profile.clamp
				  Grid2Layout:SetClamp()
			  end,
}, reset = {
		type = "execute",
		width = "half",
		name = L["Reset"],
		desc = L["Resets the layout frame's position and anchor."],
		order = order_anchor + 4,
		func = function () Grid2Layout:ResetPosition() end,
}, } )
