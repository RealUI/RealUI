--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
--[[ Generic Template for a ButtonBar with state control ]]
local _, Bartender4 = ...
local ButtonBar = Bartender4.ButtonBar.prototype

local setmetatable, rawset, pairs, type, tostring = setmetatable, rawset, pairs, type, tostring
local table_insert, table_concat, fmt = table.insert, table.concat, string.format

-- GLOBALS: GetSpellInfo, InCombatLockdown, GetNumShapeshiftForms
-- GLOBALS: MainMenuBarArtFrame, OverrideActionBar, RegisterStateDriver, UnregisterStateDriver

local StateBar = setmetatable({}, {__index = ButtonBar})
local StateBar_MT = {__index = StateBar}

local defaults = Bartender4:Merge({
	autoassist = false,
	states = {
		enabled = false,
		possess = false,
		actionbar = false,
		default = 0,
		ctrl = 0,
		alt = 0,
		shift = 0,
		stance = {
			['*'] = {
			},
		},
	},
}, Bartender4.ButtonBar.defaults)

Bartender4.StateBar = {}
Bartender4.StateBar.prototype = StateBar
Bartender4.StateBar.defaults = defaults

local _, playerclass = UnitClass("player")

function Bartender4.StateBar:Create(id, config, name)
	local bar = setmetatable(Bartender4.ButtonBar:Create(id, config, name), StateBar_MT)

	if playerclass == "DRUID" or playerclass == "ROGUE" then
		bar:RegisterEvent("PLAYER_TALENT_UPDATE")
		bar:RegisterEvent("PLAYER_REGEN_ENABLED")
		bar:RegisterEvent("GLYPH_UPDATED")
		bar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		bar:SetScript("OnEvent", StateBar.OnEvent)
	end
	return bar
end

StateBar.BT4BarType = "StateBar"

function StateBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)
	-- We cannot call UpdateStates or UpdateSelfCast now, because the buttons are not yet created *sad*
end

function StateBar:OnEvent(event, ...)
	if event == "PLAYER_TALENT_UPDATE" or event == "GLYPH_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
		if InCombatLockdown() then
			self.updateStateOnCombatLeave = true
		else
			self:UpdateStates()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if self.updateStateOnCombatLeave and not InCombatLockdown() then
			self.updateStateOnCombatLeave = nil
			self:UpdateStates()
		end
	end
end

--------------------------------------------------------------
-- Stance Management

local modifiers = { "ctrl", "alt", "shift" }

-- specifiy the available stances for each class
local DefaultStanceMap = setmetatable({}, { __index = function(t,k)
	local newT = nil
	if k == "WARRIOR" then
		newT = {
			{ id = "battle", name = GetSpellInfo(2457), index = 1 },
			{ id = "def", name = GetSpellInfo(71), index = 2 },
			{ id = "gladiator", name = GetSpellInfo(156291), index = 3 },
		}
	elseif k == "DRUID" then
		newT = {
			{ id = "bear", name = GetSpellInfo(5487), index = 3 },
			{ id = "cat", name = GetSpellInfo(768), index = 1 },
				-- prowl is virtual, no real stance
			{ id = "prowl", name = ("%s (%s)"):format((GetSpellInfo(768)), (GetSpellInfo(5215))), index = false},
			{ id = "moonkin", name = GetSpellInfo(24858), index = 4 },
		}
	elseif k == "ROGUE" then
		newT = {
			-- shadowdance needs to be before stealth in the list, otherwise the condition is overwritten
			{ id = "shadowdance", name = ("%s / %s"):format((GetSpellInfo(51713)), (GetSpellInfo(1856))), index = -1, type = "form" },
			{ id = "stealth", name = GetSpellInfo(1784), index = 1 },
		}
	elseif k == "PRIEST" then
		newT = {
			{ id = "shadowform", name = GetSpellInfo(15473), index = 1 },
		}
	elseif k == "WARLOCK" then
		newT = {
			{ id = "metamorphosis", name = GetSpellInfo(103958), index = 1, type = "form"},
			--{ id = "darkapotheosis", name = GetSpellInfo(114168), index = 2, type = "form"}, -- this should work, but for some reason it doesn't.
		}
	elseif k == "MONK" then
		newT = {
			{ id = "tiger", name = GetSpellInfo(103985), index = 1, spec = 3 },
			{ id = "crane", name = GetSpellInfo(154436), index = 1, spec = 2 },
			{ id = "ox", name = GetSpellInfo(115069), index = 2, spec = 1 },
			{ id = "serpent", name = GetSpellInfo(115070), index = 3, spec = 2 },
		}
	end
	rawset(t, k, newT)

	return newT
end})
Bartender4.StanceMap = DefaultStanceMap

local stancemap
function StateBar:UpdateStates(returnOnly)
	if not self.buttons then return end
	self.statebutton = {}
	if not stancemap and DefaultStanceMap[playerclass] then
		stancemap = DefaultStanceMap[playerclass]
	end

	local statedriver
	if not self:GetStateOption("enabled") then
		statedriver = "0"
	elseif returnOnly or not self:GetStateOption("customEnabled") then
		statedriver = {}
		local stateconfig = self.config.states
		-- arguments will be parsed from left to right, so we have a priority here

		-- possessing will always be the most important change, if enabled
		if self:GetStateOption("possess") then
			table_insert(statedriver, "[overridebar][possessbar][shapeshift]possess")
		end

		-- highest priority have our temporary quick-swap keys
		for _,v in pairs(modifiers) do
			local page = self:GetStateOption(v)
			if page and page ~= 0 then
				table_insert(statedriver, fmt("[mod:%s]%s", v, page))
			end
		end

		-- second priority the manual changes using the ActionBar options
		if self:GetStateOption("actionbar") then
			for i=2,6 do
				table_insert(statedriver, fmt("[bar:%s]%s", i, i))
			end
		end

		-- third priority the stances
		if stancemap then
			if not stateconfig.stance[playerclass] then stateconfig.stance[playerclass] = {} end
			for i,v in pairs(stancemap) do
				local state = self:GetStanceState(v)
				if state and state ~= 0 and v.index and (v.spec == nil or v.spec == GetSpecialization()) then
					-- hack for druid prowl, since its no real "stance", but we want to handle it anyway
					if playerclass == "DRUID" then
						if v.id == "cat" then
							local prowl = self:GetStanceState("prowl")
							if prowl and prowl ~= 0 then
								table_insert(statedriver, fmt("[bonusbar:%s,stealth:1]%s", v.index, prowl))
							end
						end
					elseif playerclass == "ROGUE" then
						if v.id == "shadowdance" then
							v.index = GetNumShapeshiftForms() + 1
						end
					end
					table_insert(statedriver, fmt("[%s:%s]%s", v.type or "bonusbar", v.index, state))
				end
			end
		end

		table_insert(statedriver, tostring(self:GetDefaultState() or 0))
		statedriver = table_concat(statedriver, ";")
		if returnOnly then
			return statedriver
		end
	else
		statedriver = self:GetStateOption("custom")
	end

	if statedriver then
		statedriver = statedriver:gsub("%[bonusbar:5%]11", "[overridebar][possessbar]possess")
	end

	self:SetAttribute("_onstate-page", [[
		if newstate == "possess" or newstate == "11" then
			if HasVehicleActionBar() then
				newstate = GetVehicleBarIndex()
			elseif HasOverrideActionBar() then
				newstate = GetOverrideBarIndex()
			elseif HasTempShapeshiftActionBar() then
				newstate = GetTempShapeshiftBarIndex()
			else
				newstate = nil
			end
			if not newstate then
				print("Bartender4: Cannot determine possess/vehicle action bar page, please report this!")
				newstate = 12
			end
		end
		self:SetAttribute("state", newstate)
		control:ChildUpdate("state", newstate)
	]])

	UnregisterStateDriver(self, "page")
	self:SetAttribute("state-page", "0")

	RegisterStateDriver(self, "page", statedriver or "0")

	self:SetAttribute("_onstate-target-help", [[
		local state = (newstate ~= "nil") and newstate or nil
		control:ChildUpdate("target-help", state)
	]])

	self:SetAttribute("_onstate-target-harm", [[
		local state = (newstate ~= "nil") and newstate or nil
		control:ChildUpdate("target-harm", state)
	]])

	local preSelf = ""
	if Bartender4.db.profile.selfcastmodifier then
		preSelf = "[mod:SELFCAST]player;"
	end

	local preFocus = ""
	if Bartender4.db.profile.focuscastmodifier then
		preFocus = "[mod:FOCUSCAST,@focus,exists,nodead]focus;"
	end

	UnregisterStateDriver(self, "target-help")
	self:SetAttribute("state-target-help", "nil")
	UnregisterStateDriver(self, "target-harm")
	self:SetAttribute("state-target-harm", "nil")

	local helpDriver, harmDriver = "", ""
	if self.config.autoassist then
		helpDriver = "[help]nil; [@targettarget, help]targettarget;"
		harmDriver = "[harm]nil; [@targettarget, harm]targettarget;"
	end

	if self.config.mouseover then
		local moMod = ""
		if Bartender4.db.profile.mouseovermod and Bartender4.db.profile.mouseovermod ~= "NONE" then
			moMod = ",mod:" .. Bartender4.db.profile.mouseovermod
		end
		helpDriver = ("[@mouseover,help%s]mouseover;"):format(moMod) .. helpDriver
		harmDriver = ("[@mouseover,harm%s]mouseover;"):format(moMod) .. harmDriver
	end

	if helpDriver ~= "" then
		RegisterStateDriver(self, "target-help", ("%s%s%s nil"):format(preSelf, preFocus, helpDriver))
	end

	if harmDriver ~= "" then
		RegisterStateDriver(self, "target-harm", ("%s%s nil"):format(preFocus, harmDriver))
	end

	self:ForAll("UpdateState")
end

function StateBar:GetStanceState(stance)
	local stanceconfig = self.config.states.stance[playerclass]
	local state
	if type(stance) == "table" then
		state = stanceconfig[stance.id]
	else
		state = stanceconfig[stance]
	end
	return state or 0
end

function StateBar:GetStanceStateOption(stance)
	local state = self:GetStanceState(stance)
	return state
end

function StateBar:SetStanceStateOption(stance, state)
	local stanceconfig = self.config.states.stance[playerclass]
	stanceconfig[stance] = state
	self:UpdateStates()
end

function StateBar:GetStateOption(key)
	return self.config.states[key]
end

function StateBar:SetStateOption(key, value)
	self.config.states[key] = value
	self:UpdateStates()
end

function StateBar:GetDefaultState()
	return self.config.states.default
end

function StateBar:SetDefaultState(_, value)
	self.config.states.default = value
	self:UpdateStates()
end

function StateBar:GetConfigAutoAssist()
	return self.config.autoassist
end

function StateBar:SetConfigAutoAssist(_, value)
	if value ~= nil then
		self.config.autoassist = value
	end
	self:UpdateStates()
end

function StateBar:GetConfigMouseOver()
	return self.config.mouseover
end

function StateBar:SetConfigMouseOver(_, value)
	if value ~= nil then
		self.config.mouseover = value
	end
	self:UpdateStates()
end

function StateBar:SetCopyCustomConditionals()
	self.config.states.custom = self:UpdateStates(true)
	self:UpdateStates()
end

function StateBar:UpdateSelfCast()
	self:ForAll("UpdateSelfCast")
	self:UpdateStates()
end
