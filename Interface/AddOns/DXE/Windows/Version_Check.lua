local addon = DXE
local L = addon.L
local util = addon.util

local Roster = addon.Roster
local EDB = addon.EDB
local RVS = addon.RVS

local window
local dropdown, heading, scrollframe
local list,work,encounter_names,headers = {},{},{},{}
local value = "addon"
local sort_index = 2

local backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
   edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
	edgeSize = 9,             
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local NONE = -1
local GREEN = "|cff99ff33"
local BLUE  = "|cff3399ff"
local GREY  = "|cff999999"
local RED   = "|cffff3300"
local NUM_ROWS = 12
local ROW_HEIGHT = 16

local function ColorCode(text)
	if type(text) == "string" then
		return addon.CN[text]
	elseif type(text) == "number" then
		if text == NONE then
			return GREY..L["None"].."|r"
		else
			local v = value == "addon" and addon.version or EDB[value].version
			if v > text then
				return RED..text.."|r"
			elseif v < text then
				return BLUE..text.."|r"
			else
				return GREEN..text.."|r"
			end
		end
	end
end

local function UpdateScroll()
	local n = #RVS
	FauxScrollFrame_Update(scrollframe, n, NUM_ROWS, ROW_HEIGHT, nil, nil, nil, nil, nil, nil, true)
	local offset = FauxScrollFrame_GetOffset(scrollframe)
	for i = 1, NUM_ROWS do
		local j = i + offset
		if j <= n then
			for k, header in ipairs(headers) do
				local text = ColorCode(RVS[j][k])
				header.rows[i]:SetText(text)
				header.rows[i]:Show()
			end
		else
			for k, header in ipairs(headers) do
				header.rows[i]:Hide()
			end
		end
	end
end

-- stable sort if sort_index == 2
-- place NONEs at the end of the list
local function sort_asc(a,b)
	if sort_index == 2 then
		local a2,b2 = a[2],b[2]
		if a2 == NONE then a2 = 99999 end
		if b2 == NONE then b2 = 99999 end
		if a2 == b2 then return a[1] < b[1]
		else return a2 < b2 end
	else
		return a[sort_index] < b[sort_index]
	end
end

local function sort_desc(a,b)
	if sort_index == 2 then
		local a2,b2 = a[2],b[2]
		if a2 == NONE then a2 = -99999 end
		if b2 == NONE then b2 = -99999 end
		if a2 == b2 then return a[1] < b[1]
		else return a2 > b2 end
	else
		return a[sort_index] > b[sort_index]
	end
end

local function SortColumn(column)
	local header = headers[column]
	sort_index = column
	if not header.sortDir then
		table.sort(RVS, sort_asc)
	else
		table.sort(RVS, sort_desc)
	end
	UpdateScroll()
end

local function SetHeaderText(name,version)
	heading.label:SetFormattedText("%s: |cffffffff%s|r",name,version)
end

local function CreateRow(parent)
	local text = parent:CreateFontString(nil,"OVERLAY")
	text:SetHeight(ROW_HEIGHT)
	text:SetFontObject(GameFontNormalSmall)
	text:SetJustifyH("LEFT")
	text:SetTextColor(1,1,1)
	return text
end

local function CreateHeader(content,column)
	local header = CreateFrame("Button", nil, content)
	header:SetScript("OnClick",function() header.sortDir = not header.sortDir; SortColumn(column) end)
	header:SetHeight(20)
	local title = header:CreateFontString(nil,"OVERLAY")
	title:SetPoint("LEFT",header,"LEFT",10,0)
	header:SetFontString(title)
	header:SetNormalFontObject(GameFontNormalSmall)
	header:SetHighlightFontObject(GameFontNormal)

	local rows = {}
	header.rows = rows
	local text = CreateRow(header)
	text:SetPoint("TOPLEFT",header,"BOTTOMLEFT",10,-3)
	text:SetPoint("TOPRIGHT",header,"BOTTOMRIGHT",0,-3)
	rows[1] = text

	for i=2,NUM_ROWS do
		text = CreateRow(header)
		text:SetPoint("TOPLEFT", rows[i-1], "BOTTOMLEFT")
		text:SetPoint("TOPRIGHT", rows[i-1], "BOTTOMRIGHT")
		rows[i] = text
	end

	return header
end

local function OnRefreshVersionList(self)
	if self:IsShown() then
		for k,v in ipairs(RVS) do
			v[2] = v.versions[value] or NONE
		end

		for name in pairs(Roster.name_to_unit) do
			if not util.search(RVS,name,1) and name ~= addon.PNAME then
				RVS[#RVS+1] = {name,NONE,versions = {}}
			end
		end

		SortColumn(sort_index)
	end
end

local function OnShow(self)
	local v = addon:GetActiveEncounter()
	if v ~= "default" then
		-- When showing switch to the active encounter even if we already have
		-- a dropdown value
		UIDropDownMenu_SetSelectedValue(dropdown,v)
		UIDropDownMenu_SetText(dropdown,EDB[v].name)
	elseif not dropdown.selectedValue then
		-- if there was no value and no active encounter, grab the first one we can find
		v = next(EDB)
		if v == "default" then
			v = next(EDB,v)
		end
		if v then
			UIDropDownMenu_SetSelectedValue(dropdown,v)
			UIDropDownMenu_SetText(dropdown,EDB[v].name)
		end
	else
		v = nil
	end
	if v and value ~= "addon" then
		value = v
		local data = EDB[v]
		SetHeaderText(data.name,data.version)
	end
	addon:RequestVersions(value)
	addon:RefreshVersionList()
end

local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local loaded = ...
		if window and window:IsVisible() and loaded:match("^DXE_") then
			if not dropdown.selectedValue then
				local v = addon:GetActiveEncounter()
				if v ~= "default" then
					UIDropDownMenu_SetSelectedValue(dropdown,v)
					UIDropDownMenu_SetText(dropdown,EDB[v].name)
				else
					local _
					v = next(EDB)
					if v == "default" then
						v = next(EDB,v)
					end
					if v then
						UIDropDownMenu_SetSelectedValue(dropdown,v)
						UIDropDownMenu_SetText(dropdown,EDB[v].name)
					end
				end
			end
		end
	end
end

local function CreateWindow()
	window = addon:CreateWindow(L["Version Check"],220,295)
	window:SetScript("OnShow",OnShow)
	window:SetScript("OnEvent",OnEvent)
	window:RegisterEvent("ADDON_LOADED")
	window:SetContentInset(7)
	--[===[@debug@
	window:AddTitleButton("Interface\\Addons\\DXE\\Textures\\Window\\Sync.tga",
									function() addon:RequestAllVersions() end,L["Sync"])
	--@end-debug@]===]
	local content = window.content
	local addonbutton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
	addonbutton:SetWidth(content:GetWidth()/3)
	addonbutton:SetHeight(25)
	addonbutton:SetNormalFontObject(GameFontNormalSmall)
	addonbutton:SetHighlightFontObject(GameFontHighlightSmall)
	addonbutton:SetDisabledFontObject(GameFontDisableSmall)
	addonbutton:SetText("AddOn")
	addonbutton:SetPoint("TOPLEFT",content,"TOPLEFT",0,-1)
	addonbutton:RegisterForClicks("LeftButtonUp","RightButtonUp")
	addonbutton:SetScript("OnClick",function(_,button) 
		if button == "LeftButton" then
			SetHeaderText(L["AddOn"],addon.version)
			value = "addon"
			addon:RequestVersions("addon")
		elseif button == "RightButton" then
			if not dropdown.selectedValue then return end
			value = dropdown.selectedValue 
			local data = EDB[value]
			SetHeaderText(data.name,data.version)
			addon:RequestVersions(value)
		end
		addon:RefreshVersionList() 
	end)
	addon:AddTooltipText(addonbutton,L["Usage"],L["|cffffff00Left Click|r to display AddOn versions. Repeated clicks will refresh them"]
	.."\n"..L["|cffffff00Right Click|r to display the selected versions. Repeated clicks will refresh them"])

	do
		local parent = CreateFrame("Frame",nil,content)
		parent:SetHeight(44)
		parent:SetWidth(content:GetWidth()*2/3)
		parent:SetPoint("TOPRIGHT")

		dropdown = CreateFrame("Frame", "DXEVersionCheckDropDown", parent, "UIDropDownMenuTemplate")
		dropdown:SetPoint("TOPLEFT",parent,"TOPLEFT",-15,0)
		dropdown:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",17,0)

		local left = _G[dropdown:GetName().."Left"]
		local right = _G[dropdown:GetName().."Right"]
		local text = _G[dropdown:GetName().."Text"]

		text:ClearAllPoints()
		text:SetPoint("RIGHT", right, "RIGHT" ,-43, 2)
		text:SetPoint("LEFT", left, "LEFT", 25, 2)

		local function OnClick(self)
			UIDropDownMenu_SetSelectedValue(dropdown,self.value)
			-- No need to set the dropdown menu text since SetSelectedValue can do
			-- it for us here, since the 2nd level menu with the proper value is
			-- guaranteed to exist here.
			value = self.value
			local data = EDB[value]
			SetHeaderText(data.name,data.version)
			addon:RefreshVersionList()
			addon:RequestVersions(value)
			CloseDropDownMenus()
		end

		local function dropdown_initialize(self, level)
			local info

			wipe(work)
			wipe(list)

			level = level or 1

			if level == 1 then
				for key,data in addon:IterateEDB() do
					work[data.category or data.zone] = true
				end
				for cat in pairs(work) do
					list[#list+1] = cat
				end

				sort(list)

				for _,cat in ipairs(list) do
					info = UIDropDownMenu_CreateInfo()
					info.text = cat
					info.value = cat
					info.hasArrow = true
					info.notCheckable = true
					info.owner = self
					UIDropDownMenu_AddButton(info,1)
				end
			elseif level == 2 then
				local cat = UIDROPDOWNMENU_MENU_VALUE

				for key,data in addon:IterateEDB() do
					if (data.category or data.zone) == cat then
						list[#list+1] = data.name
						work[data.name] = key
					end
				end

				sort(list)

				for _,name in ipairs(list) do
					info = UIDropDownMenu_CreateInfo()
					info.hasArrow = false
					info.text = name
					info.owner = self
					info.value = work[name]
					info.func = OnClick
					UIDropDownMenu_AddButton(info,2)
				end
			end

			-- Workaround for blizzard bug that causes top level frames
			-- to not properly set frame levels. See this forum post for details:
			-- http://forums.worldofwarcraft.com/thread.html?topicId=23425769491 
			for l=1,UIDROPDOWNMENU_MAXLEVELS do
				for b=1,UIDROPDOWNMENU_MAXBUTTONS do
					local button = _G["DropDownList"..l.."Button"..b]
					if button then 
						local button_parent = button:GetParent()
						if button_parent then 
							local button_level = button:GetFrameLevel()
							local parent_level = button_parent:GetFrameLevel()
							if button_level <= parent_level then 
								button:SetFrameLevel(parent_level + 2) 
							end  
						end  
					end  
				end  
			end  
		end
		UIDropDownMenu_Initialize(dropdown, dropdown_initialize)
		OnShow(window)
	end

	heading = CreateFrame("Frame",nil,content)
	heading:SetWidth(content:GetWidth())
	heading:SetHeight(18)
	heading:SetPoint("TOPLEFT",addonbutton,"BOTTOMLEFT",0,-2)
	local label = heading:CreateFontString(nil,"ARTWORK")
	label:SetFont(GameFontNormalSmall:GetFont())
	label:SetPoint("CENTER")
	label:SetTextColor(1,1,0)
	heading.label = label
	SetHeaderText(L["AddOn"],addon.version)

	local left = heading:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT",heading,"LEFT",3,0)
	left:SetPoint("RIGHT",label,"LEFT",-5,0)
	left:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = heading:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT",heading,"RIGHT",-3,0)
	right:SetPoint("LEFT",label,"RIGHT",5,0)
	right:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
	right:SetTexCoord(0.81, 0.94, 0.5, 1)

	for i=1,2 do headers[i] = CreateHeader(content,i) end
	headers[1]:SetPoint("TOPLEFT",heading,"BOTTOMLEFT")
	headers[1]:SetText(L["Name"])
	headers[1]:SetWidth(120)

	headers[2]:SetPoint("LEFT",headers[1],"LEFT",content:GetWidth()/2,0)
	headers[2]:SetText(L["Version"])
	headers[2]:SetWidth(80)

	scrollframe = CreateFrame("ScrollFrame", "DXEVCScrollFrame", content, "FauxScrollFrameTemplate")
	scrollframe:SetPoint("TOPLEFT", headers[1], "BOTTOMLEFT")
	scrollframe:SetPoint("BOTTOMRIGHT",-21,0)
	scrollframe:SetBackdrop(backdrop)
	scrollframe:SetBackdropBorderColor(0.33,0.33,0.33)

	local scrollbar = _G[scrollframe:GetName() .. "ScrollBar"]
	local scrollbarbg = CreateFrame("Frame",nil,scrollbar)
	scrollbarbg:SetBackdrop(backdrop)
	scrollbarbg:SetPoint("TOPLEFT",-3,19)
	scrollbarbg:SetPoint("BOTTOMRIGHT",3,-18)
	scrollbarbg:SetBackdropBorderColor(0.33,0.33,0.33)
	scrollbarbg:SetFrameLevel(scrollbar:GetFrameLevel()-2)

	scrollframe:SetScript("OnVerticalScroll", function(addon, offset) 
		FauxScrollFrame_OnVerticalScroll(addon, offset, ROW_HEIGHT, UpdateScroll) 
	end)

	window.OnRefreshVersionList = OnRefreshVersionList
	window:DisableResizing()
	addon.RegisterCallback(window,"OnRefreshVersionList")
	addon:RefreshVersionList()
	UpdateScroll()
	CreateWindow = nil
end
	
function addon:VersionCheck()
	if window then
		window:Show()
	else
		CreateWindow()
	end
end
addon:RegisterWindow(L["Version Check"],function() addon:VersionCheck() end)
