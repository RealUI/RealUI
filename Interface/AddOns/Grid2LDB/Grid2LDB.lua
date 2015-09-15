--[[ Simple DataBroker launcher for Grid2. Created by Michael --]]

local DataBroker = LibStub("LibDataBroker-1.1", true)
if not DataBroker then return end

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2Layout = Grid2Layout

local MenuLayoutsShow

local Grid2LDB = DataBroker:NewDataObject("Grid2", {
	type  = "launcher",
	label = GetAddOnInfo("Grid2", "Title"),
	icon  = "Interface\\AddOns\\Grid2\\media\\icon",
	OnClick = function(self, button)
		if button=="LeftButton" then
			Grid2:OnChatCommand("grid2")
		elseif button=="RightButton" then
			MenuLayoutsShow()
		end
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Grid2")
		tooltip:AddDoubleLine( L["Layout"], L[Grid2Layout.layoutName] or "", 255,255,255, 255,255,0)
		for _,func in pairs(Grid2.tooltipFunc) do
			func(tooltip)
		end
		tooltip:AddLine("|cFFff4040Left Click|r to open configuration\n|cFFff4040Right Click|r to open layouts menu", 0.2, 1, 0.2)
	end,
})

local icon = LibStub("LibDBIcon-1.0")
if icon then
	icon:Register("Grid2", Grid2LDB, Grid2Layout.db.profile.minimapIcon)
	Grid2Layout.minimapIcon = icon
end

--
-- Layouts popup menu
--
do
	local menuFrame
	local partyType
	local instType
	local layoutName
	local menuTable = {}
	local function SetLayout(self)
		if not InCombatLockdown() then
			layoutName    = self.value
			local key     = Grid2Layout.instMaxPlayers
			local layouts = Grid2Layout.db.profile.layoutBySize
			if not layouts[key] then
				layouts = Grid2Layout.db.profile.layouts
				key = partyType.."@"..instType
				if not layouts[key] then key = partyType end
			end
			layouts[key] = layoutName
			Grid2Layout:ReloadLayout()
		end
	end
	local function CreateMenuTable()
		layoutName = Grid2Layout.layoutName
		if partyType~=Grid2Layout.partyType or instType~=Grid2Layout.instType then
			local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")
			partyType = Grid2Layout.partyType
			instType = Grid2Layout.instType
			wipe(menuTable)
			menuTable[1] = { text = L["Select Layout"],  notCheckable= true, isTitle = true }
			for name, layout in pairs(Grid2Layout.layoutSettings) do
				if layout.meta[partyType] and name~="None" then
					menuTable[#menuTable+1] = { func= SetLayout, text = L[name], value = name, checked = function() return name == layoutName end }
				end
			end
			sort(menuTable, function(a,b) if a.isTitle then return true elseif b.isTitle then return false else return a.text<b.text end end )
		end
	end
	MenuLayoutsShow= function()
		menuFrame= menuFrame or CreateFrame("Frame", "Grid2LDBLayoutsMenu", UIParent, "UIDropDownMenuTemplate")
		CreateMenuTable()
		EasyMenu(menuTable, menuFrame, "cursor", 0 , 0, "MENU", 1)
	end
end
