local L = LibStub("AceLocale-3.0"):GetLocale("Skada", false)
local AceGUI = LibStub("AceGUI-3.0")

-- Configuration menu.
function Skada:OpenMenu(window)
	if not self.skadamenu then
		self.skadamenu = CreateFrame("Frame", "SkadaMenu")
	end
	local skadamenu = self.skadamenu

	skadamenu.displayMode = "MENU"
	local info = {}
	skadamenu.initialize = function(self, level)
	    if not level then return end
	    wipe(info)
	    if level == 1 then
	        -- Create the title of the menu
	        info.isTitle = 1
	        info.text = L["Skada Menu"]
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

			for i, win in ipairs(Skada:GetWindows()) do
		        wipe(info)
		        info.text = win.db.name
		        info.hasArrow = 1
		        info.value = win
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)
			end

	        -- Add a blank separator
	        wipe(info)
	        info.disabled = 1
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

			-- Can't report if we are not in a mode.
			if not window or (window or window.selectedmode) then
		        wipe(info)
		        info.text = L["Report"]
				info.func = function() Skada:OpenReportWindow(window) end
		        info.value = "report"
				info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)
		    end

	        wipe(info)
	        info.text = L["Delete segment"]
	        info.func = function() Skada:DeleteSet() end
	        info.hasArrow = 1
	        info.notCheckable = 1
	        info.value = "delete"
	        UIDropDownMenu_AddButton(info, level)

	        wipe(info)
	        info.text = L["Keep segment"]
	        info.func = function() Skada:KeepSet() end
	        info.notCheckable = 1
	        info.hasArrow = 1
	        info.value = "keep"
	        UIDropDownMenu_AddButton(info, level)

	        -- Add a blank separator
	        wipe(info)
	        info.disabled = 1
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

	        wipe(info)
	        info.text = L["Toggle window"]
	        info.func = function() Skada:ToggleWindow() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

	        wipe(info)
	        info.text = L["Reset"]
	        info.func = function() Skada:Reset() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

	        wipe(info)
	        info.text = L["Start new segment"]
	        info.func = function() Skada:NewSegment() end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)


	        wipe(info)
	        info.text = L["Configure"]
	        info.func = function() InterfaceOptionsFrame_OpenToCategory("Skada") end
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)

	        -- Close menu item
	        wipe(info)
	        info.text         = CLOSE
	        info.func         = function() CloseDropDownMenus() end
	        info.checked      = nil
	        info.notCheckable = 1
	        UIDropDownMenu_AddButton(info, level)
	    elseif level == 2 then
	    	if type(UIDROPDOWNMENU_MENU_VALUE) == "table" then
	    		local window = UIDROPDOWNMENU_MENU_VALUE
	    		-- Display list of modes with current ticked; let user switch mode by checking one.
		        wipe(info)
		        info.isTitle = 1
		        info.text = L["Mode"]
		        UIDropDownMenu_AddButton(info, level)

		        for i, module in ipairs(Skada:GetModes()) do
			        wipe(info)
		            info.text = module:GetName()
		            info.func = function() window:DisplayMode(module) end
		            info.checked = (window.selectedmode == module)
		            UIDropDownMenu_AddButton(info, level)
		        end

		        -- Separator
		        wipe(info)
		        info.disabled = 1
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)

		        -- Display list of sets with current ticked; let user switch set by checking one.
		        wipe(info)
		        info.isTitle = 1
		        info.text = L["Segment"]
		        UIDropDownMenu_AddButton(info, level)

		        wipe(info)
	            info.text = L["Total"]
	            info.func = function()
	            				window.selectedset = "total"
	            				Skada:Wipe()
	            				Skada:UpdateDisplay(true)
	            			end
	            info.checked = (window.selectedset == "total")
	            UIDropDownMenu_AddButton(info, level)
		        wipe(info)
	            info.text = L["Current"]
	            info.func = function()
	            				window.selectedset = "current"
	            				Skada:Wipe()
	            				Skada:UpdateDisplay(true)
	            			end
	            info.checked = (window.selectedset == "current")
	            UIDropDownMenu_AddButton(info, level)

		        for i, set in ipairs(Skada:GetSets()) do
			        wipe(info)
		            info.text = set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime)
		            info.func = function()
		            				window.selectedset = i
		            				Skada:Wipe()
		            				Skada:UpdateDisplay(true)
		            			end
		            info.checked = (window.selectedset == set.starttime)
		            UIDropDownMenu_AddButton(info, level)
		        end

		        -- Add a blank separator
		        wipe(info)
		        info.disabled = 1
		        info.notCheckable = 1
		        UIDropDownMenu_AddButton(info, level)

		        wipe(info)
	            info.text = L["Lock window"]
	            info.func = function()
	            				window.db.barslocked = not window.db.barslocked
	            				Skada:ApplySettings()
	            			end
	            info.checked = window.db.barslocked
		        UIDropDownMenu_AddButton(info, level)

		        wipe(info)
	            info.text = L["Hide window"]
	            info.func = function() if window:IsShown() then window.db.hidden = true; window:Hide() else window.db.hidden = false; window:Show() end end
	            info.checked = not window:IsShown()
		        UIDropDownMenu_AddButton(info, level)

		    elseif UIDROPDOWNMENU_MENU_VALUE == "delete" then
		        for i, set in ipairs(Skada:GetSets()) do
			        wipe(info)
		            info.text = set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime)
		            info.func = function() Skada:DeleteSet(set) end
			        info.notCheckable = 1
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "keep" then
		        for i, set in ipairs(Skada:GetSets()) do
			        wipe(info)
		            info.text = set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime)
		            info.func = function()
		            				set.keep = not set.keep
		            				Skada:Wipe()
		            				Skada:UpdateDisplay(true)
		            			end
		            info.checked = set.keep
		            UIDropDownMenu_AddButton(info, level)
		        end
		    end
		elseif level == 3 then
		    if UIDROPDOWNMENU_MENU_VALUE == "modes" then

		        for i, module in ipairs(Skada:GetModes()) do
			        wipe(info)
		            info.text = module:GetName()
		            info.checked = (Skada.db.profile.report.mode == module:GetName())
		            info.func = function() Skada.db.profile.report.mode = module:GetName() end
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "segment" then
		        wipe(info)
	            info.text = L["Total"]
	            info.func = function() Skada.db.profile.report.set = "total" end
	            info.checked = (Skada.db.profile.report.set == "total")
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Current"]
	            info.func = function() Skada.db.profile.report.set = "current" end
	            info.checked = (Skada.db.profile.report.set == "current")
	            UIDropDownMenu_AddButton(info, level)

		        for i, set in ipairs(sets) do
		            info.text = set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime)
		            info.func = function() Skada.db.profile.report.set = i end
		            info.checked = (Skada.db.profile.report.set == i)
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "number" then
		        for i = 1,25 do
			        wipe(info)
		            info.text = i
		            info.checked = (Skada.db.profile.report.number == i)
		            info.func = function() Skada.db.profile.report.number = i end
		            UIDropDownMenu_AddButton(info, level)
		        end
		    elseif UIDROPDOWNMENU_MENU_VALUE == "channel" then
		        wipe(info)
		        info.text = L["Whisper"]
		        info.checked = (Skada.db.profile.report.chantype == "whisper")
		        info.func = function() Skada.db.profile.report.channel = "Whisper"; Skada.db.profile.report.chantype = "whisper" end
		        UIDropDownMenu_AddButton(info, level)

		        info.text = L["Say"]
		        info.checked = (Skada.db.profile.report.channel == "Say")
		        info.func = function() Skada.db.profile.report.channel = "Say"; Skada.db.profile.report.chantype = "preset" end
		        UIDropDownMenu_AddButton(info, level)

	            info.text = L["Raid"]
	            info.checked = (Skada.db.profile.report.channel == "Raid")
	            info.func = function() Skada.db.profile.report.channel = "Raid"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Party"]
	            info.checked = (Skada.db.profile.report.channel == "Party")
	            info.func = function() Skada.db.profile.report.channel = "Party"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Instance"]
	            info.checked = (Skada.db.profile.report.channel == "INSTANCE_CHAT")
	            info.func = function() Skada.db.profile.report.channel = "INSTANCE_CHAT"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Guild"]
	            info.checked = (Skada.db.profile.report.channel == "Guild")
	            info.func = function() Skada.db.profile.report.channel = "Guild"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Officer"]
	            info.checked = (Skada.db.profile.report.channel == "Officer")
	            info.func = function() Skada.db.profile.report.channel = "Officer"; Skada.db.profile.report.chantype = "preset" end
	            UIDropDownMenu_AddButton(info, level)

	            info.text = L["Self"]
	            info.checked = (Skada.db.profile.report.chantype == "self")
	            info.func = function() Skada.db.profile.report.channel = "Self"; Skada.db.profile.report.chantype = "self" end
	            UIDropDownMenu_AddButton(info, level)

				info.text = L["RealID"]
				info.checked = (Skada.db.profile.report.chantype == "realid")
				info.func = function() Skada.db.profile.report.channel = "RealID"; Skada.db.profile.report.chantype = "realid" end
				UIDropDownMenu_AddButton(info, level)

				local list = {GetChannelList()}
				for i=1,table.getn(list)/2 do
					info.text = list[i*2]
					info.checked = (Skada.db.profile.report.channel == list[i*2])
					info.func = function() Skada.db.profile.report.channel = list[i*2]; Skada.db.profile.report.chantype = "channel" end
					UIDropDownMenu_AddButton(info, level)
				end

		    end

	    end
	end

	local x,y = GetCursorPosition(UIParent);
	ToggleDropDownMenu(1, nil, skadamenu, "UIParent", x / UIParent:GetEffectiveScale() , y / UIParent:GetEffectiveScale())
end

function Skada:SegmentMenu(window)
	if not self.segmentsmenu then
		self.segmentsmenu = CreateFrame("Frame", "SkadaWindowButtonsSegments")
	end
	local segmentsmenu = self.segmentsmenu

	segmentsmenu.displayMode = "MENU"
	local info = {}
	segmentsmenu.initialize = function(self, level)
	    if not level then return end

		info.isTitle = 1
		info.text = L["Segment"]
		UIDropDownMenu_AddButton(info, level)
		info.isTitle = nil

		wipe(info)
		info.text = L["Total"]
		info.func = function()
						window.selectedset = "total"
	            				Skada:Wipe()
						Skada:UpdateDisplay(true)
					end
		info.checked = (window.selectedset == "total")
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.text = L["Current"]
		info.func = function()
						window.selectedset = "current"
	            				Skada:Wipe()
						Skada:UpdateDisplay(true)
					end
		info.checked = (window.selectedset == "current")
		UIDropDownMenu_AddButton(info, level)

		for i, set in ipairs(Skada:GetSets()) do
		    wipe(info)
			info.text = set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime)
			info.func = function()
							window.selectedset = i
	            					Skada:Wipe()
							Skada:UpdateDisplay(true)
						end
			info.checked = (window.selectedset == i)
			UIDropDownMenu_AddButton(info, level)
		end
	end
	local x,y = GetCursorPosition(UIParent);
	ToggleDropDownMenu(1, nil, segmentsmenu, "UIParent", x / UIParent:GetEffectiveScale() , y / UIParent:GetEffectiveScale())
end

function Skada:ModeMenu(window)
	--Spew("window", window)
	if not self.modesmenu then
		self.modesmenu = CreateFrame("Frame", "SkadaWindowButtonsModes")
	end
	local modesmenu = self.modesmenu

	modesmenu.displayMode = "MENU"
	local info = {}
	modesmenu.initialize = function(self, level)
	    if not level then return end

		info.isTitle = 1
		info.text = L["Mode"]
		UIDropDownMenu_AddButton(info, level)

		for i, module in ipairs(Skada:GetModes()) do
			wipe(info)
			info.text = module:GetName()
			info.func = function() window:DisplayMode(module) end
			info.checked = (window.selectedmode == module)
			UIDropDownMenu_AddButton(info, level)
		end
	end
	local x,y = GetCursorPosition(UIParent);
	ToggleDropDownMenu(1, nil, modesmenu, "UIParent", x / UIParent:GetEffectiveScale() , y / UIParent:GetEffectiveScale())
end

function Skada:OpenReportWindow(window)
	if self.ReportWindow==nil then
		self:CreateReportWindow(window)
	end

	--self:UpdateReportWindow()
	self.ReportWindow:Show()
end

local function destroywindow()
	if Skada.ReportWindow then
		Skada.ReportWindow:ReleaseChildren()
		Skada.ReportWindow:Hide()
		Skada.ReportWindow:Release()
	end
	Skada.ReportWindow = nil
end

function Skada:CreateReportWindow(window)
	-- ASDF = window
	self.ReportWindow = AceGUI:Create("Window")
	local frame = self.ReportWindow
	frame:EnableResize(false)
	frame:SetWidth(250)
	frame:SetLayout("Flow")
	if window then
		frame:SetHeight(220)
	else
		frame:SetHeight(310)
	end
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	if window then
		frame:SetTitle(L["Report"] .. (" - %s"):format(window.db.name))
	else
		frame:SetTitle(L["Report"])
	end
	frame:SetCallback("OnClose", function(widget, callback) destroywindow() end)

	if window then
		Skada.db.profile.report.set = window.selectedset
		Skada.db.profile.report.mode = window.db.mode
	else
		-- Mode, default last chosen or first available.
		local modebox = AceGUI:Create("Dropdown")
		modebox:SetLabel(L["Mode"])
		modebox:SetList({})
		for i, mode in ipairs(Skada:GetModes()) do
			modebox:AddItem(mode:GetName(), mode:GetName())
		end
		modebox:SetCallback("OnValueChanged", function(f, e, value) Skada.db.profile.report.mode = value end)
		modebox:SetValue(Skada.db.profile.report.mode or Skada:GetModes()[1])
		frame:AddChild(modebox)

		-- Segment, default last chosen or last set.
		local setbox = AceGUI:Create("Dropdown")
		setbox:SetLabel(L["Segment"])
		setbox:SetList({total = L["Total"], current = L["Current"]})
		for i, set in ipairs(Skada:GetSets()) do
			setbox:AddItem(i, set.name..": "..date("%H:%M",set.starttime).." - "..date("%H:%M",set.endtime))
		end
		setbox:SetCallback("OnValueChanged", function(f, e, value) Skada.db.profile.report.set = value end)
		setbox:SetValue(Skada.db.profile.report.set or Skada:GetSets()[1])
		frame:AddChild(setbox)
	end

	local channellist = {
		whisper 	= { L["Whisper"], "whisper"},
		target		= { "Whisper Target", "whisper"},
		say			= { L["Say"], "preset"},
		raid 		= { L["Raid"], "preset"},
		party 		= { L["Party"], "preset"},
		instance_chat 		= { L["Instance"], "preset"},
		guild 		= { L["Guild"], "preset"},
		officer 	= { L["Officer"], "preset"},
		self 		= { L["Self"], "self"},
		realid	 	= { L["RealID"], "RealID"},
	}
	local list = {GetChannelList()}
	for i=1,#list/2 do
		local chan = list[i*2]
		if chan ~= "Trade" and chan ~= "General" and chan ~= "LookingForGroup" then -- These should be localized.
			channellist[chan] = {chan, "channel"}
		end
	end

	-- Channel, default last chosen or Say.
	local channelbox = AceGUI:Create("Dropdown")
	channelbox:SetLabel(L["Channel"])
	channelbox:SetList( {} )
	for chan, kind in pairs(channellist) do
		channelbox:AddItem(chan, kind[1])
	end
	channelbox:SetCallback("OnValueChanged",
			function(f, e, value)
				Skada.db.profile.report.channel = value
				Skada.db.profile.report.chantype = channellist[value][2]
			end
		)
	channelbox:SetValue(Skada.db.profile.report.channel or "say")
	frame:AddChild(channelbox)

	local lines = AceGUI:Create("Slider")
	lines:SetLabel(L["Lines"])
	lines:SetValue(Skada.db.profile.report.number ~= nil and Skada.db.profile.report.number	 or 10)
	lines:SetSliderValues(1, 25, 1)
	lines:SetCallback("OnValueChanged", function(self, event, value) Skada.db.profile.report.number = value end)
	lines:SetFullWidth(true)
	frame:AddChild(lines)

	local whisperbox = AceGUI:Create("EditBox")
	whisperbox:SetLabel("Whisper Target")
	whisperbox:SetText(Skada.db.profile.report.target)
	whisperbox:SetCallback("OnEnterPressed", function(box, event, text) Skada.db.profile.report.target = text; frame.button.frame:Click() end)
	whisperbox:SetCallback("OnTextChanged", function(box, event, text) Skada.db.profile.report.target = text end)
	whisperbox:SetFullWidth(true)

	local report = AceGUI:Create("Button")
	frame.button = report
	report:SetText(L["Report"])
	report:SetCallback("OnClick", function()
		local mode, set, channel, chantype, number = Skada.db.profile.report.mode, Skada.db.profile.report.set, Skada.db.profile.report.channel, Skada.db.profile.report.chantype, Skada.db.profile.report.number

		if channel == "whisper" then
			channel = Skada.db.profile.report.target
		elseif channel == "realid" then
			channel = BNet_GetPresenceID(Skada.db.profile.report.target)
		elseif channel == "target" then
			if UnitExists("target") then
				channel = UnitName("target")
			else
				channel = nil
			end
		end
		-- print(tostring(frame.channel), tostring(frame.chantype), tostring(window.db.mode))

		if channel and chantype and mode and set and number then
			Skada:Report(channel, chantype, mode, set, number, window)
			frame:Hide()
		else
			Skada:Print("Error: No options selected")
		end

	end)
	report:SetFullWidth(true)
	frame:AddChildren(whisperbox, report)
end
