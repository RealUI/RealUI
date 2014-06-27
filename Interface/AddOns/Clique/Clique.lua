--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2010 - James N. Whitehead II
--
--  This is an updated version of the original 'Clique' addon
--  designed to work better with multi-button mice, and those players
--  who want to be able to bind keyboard combinations to enable
--  hover-casting on unit frames.  It's a bit of a paradigm shift from
--  the original addon, but should make a much simpler and more
--  powerful addon.
--
--    * Any keyboard combination can be set as a binding.
--    * Any mouse combination can be set as a binding.
--    * The only types that are allowed are spells and macros.
--
--  The concept of 'click-sets' has been simplified and extended
--  so that the user can specify their own binding-sets, allowing
--  for different bindings for different sets of frames. By default
--  the following binding-sets are available:
--
--    * default - These bindings are active on all frames, unless
--      overridden by another binding in a more specific binding-set.
--    * ooc - These bindings will ONLY be active when the player is
--      out of combat.
--    * enemy - These bindings are ONLY active when the unit you are
--      clicking on is an enemy, i.e. a unit that you can attack.
--    * friendly - These bindings are ONLY active when the unit you are
--      clicking on is a friendly unit, i.e. one that you can assist
--    * hovercast - These bindings will be available whenever you are over
--      a unit frame, or a unit in the 3D world.
--    * global - These bindings will be always available. They
--      do not specify a target for the action, so if the action requires
--      a target, you must specify it after performing the binding.
--
--  The binding-sets layer on each other, with the 'default' binding-set
--  being at the bottom, and any other binding-set being layered on top.
--  Clique will detect any conflicts that you have other than with
--  default bindings, and will warn you of the situation.
-------------------------------------------------------------------]]--

local addonName, addon = ...
local L = addon.L

function addon:Initialize()
    -- Create an AceDB, but it needs to be cleared first
    self.db = LibStub("AceDB-3.0"):New("CliqueDB3", self.defaults)
    self.db.RegisterCallback(self, "OnNewProfile", "OnNewProfile")
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")

    self.settings = self.db.char
    self.bindings = self.db.profile.bindings

    self.ccframes = {}
    self.hccframes = {}

    -- Registration for group headers (in-combat safe)
    self.header = CreateFrame("Frame", addonName .. "HeaderFrame", UIParent, "SecureHandlerBaseTemplate,SecureHandlerAttributeTemplate")
    ClickCastHeader = addon.header

	-- This snippet will clear any dangling bindings that might have occurred
	-- as a result of frames being shown/hidden.
    self.header:SetAttribute("_onattributechanged", [[
        if name == "hasunit" then
            if value == "false" and danglingButton then
                self:RunFor(danglingButton, self:GetAttribute("setup_onleave"))
                danglingButton = nil
            end
        end
    ]])
    RegisterAttributeDriver(self.header, "hasunit", "[@mouseover, exists] true; false")

	-- Create a secure action button that's sole purpose is to cancel a
	-- pending spellcast (the targeting hand)
	self.stopbutton = CreateFrame("Button", addonName .. "StopButton", nil, "SecureActionButtonTemplate")
	self.stopbutton.name = self.stopbutton:GetName()
	self.stopbutton:SetAttribute("type", "stop")

    -- Create a secure action button that can be used for 'hovercast' and 'global'
    self.globutton = CreateFrame("Button", addonName .. "SABButton", UIParent, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")

    -- Create a table within the addon header to store the frames
    -- that are registered for click-casting
    self.header:Execute([[
        ccframes = table.new()
    ]])

    -- Create a table within the addon header to store the frame bakcklist
    self.header:Execute([[
        blacklist = table.new()
    ]])

    -- This snippet is executed from the SecureHandlerEnterLeaveTemplate
    -- _onenter and _onleave attributes. The 'self' attribute will contain
    -- the unit frame itself.
    self.header:SetAttribute("clickcast_onenter", [===[
        local header = self:GetParent():GetFrameRef("clickcast_header")
        header:RunFor(self, header:GetAttribute("setup_onenter"))
    ]===])

    -- This snippet is executed from the SecureHandlerEnterLeaveTemplate
    -- _onenter and _onleave attributes. The 'self' attribute will contain
    -- the unit frame itself.
    self.header:SetAttribute("clickcast_onleave", [===[
        local header = self:GetParent():GetFrameRef("clickcast_header")
        header:RunFor(self, header:GetAttribute("setup_onleave"))
    ]===])

    local setup, remove = self:GetClickAttributes()
    self.header:SetAttribute("setup_clicks", setup)
    self.header:SetAttribute("remove_clicks", remove)

    -- This snippet is executed from within the initialConfigFunction secure
    -- snippet. The unit frame button is passed in the 'clickcast_button'
    -- attribute, which can only be accomplished in a restricted environment.
    self.header:SetAttribute("clickcast_register", [===[
        local button = self:GetAttribute("clickcast_button")

        -- Export this frame so we can display it in the insecure environment
        self:SetAttribute("export_register", button)

        button:SetAttribute("clickcast_onenter", self:GetAttribute("clickcast_onenter"))
        button:SetAttribute("clickcast_onleave", self:GetAttribute("clickcast_onleave"))
        ccframes[button] = true

        self:RunFor(button, self:GetAttribute("setup_clicks"))
    ]===])

    -- This snippet is executed from the Clique:UnregisterFrame() function, or
    -- possibly from some other restricted environment. The unit frame is passed
    -- in the 'clickcast_button' attribute, which can only be accomplished
    -- in a restricted environment.
    self.header:SetAttribute("clickcast_unregister", [===[
        local button = self:GetAttribute("clickcast_button")

        -- Export this frame so it can be removed from the blacklist editor
        self:SetAttribute("export_unregister", button)

        -- Remove any click and binding attributes that have already been set
        self:RunFor(button, self:GetAttribute("clickcast_onleave"))
        self:RunFor(button, self:GetAttribute("remove_clicks"))

        button:SetAttribute("clickcast_onenter", nil)
        button:SetAttribute("clickcast_onleave", nil)
        ccframes[button] = nil
    ]===])

    -- We need to track frame registrations so we can display secure frames in
    -- the frame blacklist editor. This is done via the 'export_register' and
    -- 'export_unregister' attributes.
    self.header:HookScript("OnAttributeChanged", function(frame, name, value)
        if name == "export_register" and type(value) ~= nil then
            -- Convert the userdata object to the global object so we have access
            -- to all of the correct methods, such as 'RegisterForClicks''
            local name = value.GetName and value:GetName()
            if name then
                local button = _G[name]
                self.hccframes[name] = button
                self:UpdateRegisteredClicks(button)
            end
        elseif name == "export_unregister" and type(value) ~= nil then
            local name = value.GetName and value:GetName()
            if name then
                self.hccframes[name] = nil
            end
        end
    end)

    local set, clr = self:GetBindingAttributes()
    self.header:SetAttribute("setup_onenter", set)
    self.header:SetAttribute("setup_onleave", clr)

    -- Get the override binding attributes for the global click frame
    self.globutton.setup, self.globutton.remove = self:GetClickAttributes(true)
    self.globutton.setbinds, self.globutton.clearbinds = self:GetBindingAttributes(true)

    -- Compatability with old Clique 1.x registrations
    local oldClickCastFrames = ClickCastFrames

    ClickCastFrames = setmetatable({}, {__newindex = function(t, k, v)
        if v == nil or v == false then
            self:UnregisterFrame(k)
        else
            self:RegisterFrame(k, v)
        end
    end})

    -- Iterate over the frames that were set before we arrived
    if oldClickCastFrames then
        for frame, options in pairs(oldClickCastFrames) do
            self:RegisterFrame(frame, options)
        end
    end
    self:EnableBlizzardFrames()

    -- Register for combat events to ensure we can swap between the two states
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnteringCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeavingCombat")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "TalentGroupChanged")

    -- Register for Clique-based messages for settings updates, etc.
    self:RegisterMessage("BINDINGS_CHANGED")
    self:RegisterMessage("BLACKLIST_CHANGED")

    -- Handle combat watching so we can change ooc based on party combat status
    addon:UpdateCombatWatch()

    -- Trigger a 'TalentGroupChanged' so we end up on the right profile
    addon:TalentGroupChanged()

    self:FireMessage("BLACKLIST_CHANGED")
    self:FireMessage("BINDINGS_CHANGED")
end

-- These tables are a queue for frame registration/unregistration
addon.regqueue = {}
addon.unregqueue = {}
addon.regclickqueue = {}

-- These function may be called during combat. When that is the case, the
-- request must be queued until combat ends, and then we can attempt to
-- register those frames. This is mainly due to integration with the
-- Blizzard raid frames, which we cannot 'register' while in combat.
function addon:RegisterFrame(button)
    if InCombatLockdown() then
        table.insert(self.regqueue, button)
        return
    end

    self.ccframes[button] = true

    self:UpdateRegisteredClicks(button)

    -- Wrap the OnEnter/OnLeave scripts in order to handle keybindings
    addon.header:WrapScript(button, "OnEnter", addon.header:GetAttribute("setup_onenter"))
    addon.header:WrapScript(button, "OnLeave", addon.header:GetAttribute("setup_onleave"))

    -- Set the attributes on the frame
    self.header:SetFrameRef("cliquesetup_button", button)
    self.header:Execute(self.header:GetAttribute("setup_clicks"), button)
end

function addon:UnregisterFrame(button)
    if InCombatLockdown() then
        table.insert(self.unregqueue, button)
        return
    end

    -- Clear any click/bind attributes
    self.header:SetFrameRef("cliquesetup_button", button)
    self.header:Execute([[
        local button = self:GetFrameRef("cliquesetup_button")
        self:RunFor(button, self:GetAttribute("setup_onleave"))
        self:RunAttribute("remove_clicks")
    ]])

    self.ccframes[button] = nil

    -- Unwrap the OnEnter/OnLeave scripts, if they were set
    addon.header:UnwrapScript(button, "OnEnter")
    addon.header:UnwrapScript(button, "OnLeave")
end

function addon:Enable()
    -- Make the options window a pushable panel window
    UIPanelWindows["CliqueConfig"] = {
        area = "left",
        pushable = 1,
        whileDead = 1,
    }

    -- Set the tooltip for the spellbook tab
    CliqueSpellTab.tooltip = L["Clique binding configuration"]
end

-- A new profile is being created in the db, called 'profile'
function addon:OnNewProfile(event, db, profile)
    table.insert(db.profile.bindings, {
        key = "BUTTON1",
        type = "target",
        unit = "mouseover",
        sets = {
            default = true
        },
    })

    table.insert(db.profile.bindings, {
        key = "BUTTON2",
        type = "menu",
        sets = {
            default = true
        },
    })
    self.bindings = db.profile.bindings
end

function addon:OnProfileChanged(event, db, newProfile)
    self.bindings = db.profile.bindings
    self:FireMessage("BINDINGS_CHANGED")
end

local function ATTR(indent, prefix, attr, suffix, value)
    local fmt = [[%sbutton:SetAttribute("%s%s%s%s%s", %q)]]
    return fmt:format(indent, prefix, #prefix > 0 and "-" or "", attr, tonumber(suffix) and "" or "-", suffix, value)
end

local function REMATTR(prefix, attr, suffix, value)
    local fmt = [[button:SetAttribute("%s%s%s%s%s", nil)]]
    return fmt:format(prefix, #prefix > 0 and "-" or "", attr, tonumber(suffix) and "" or "-", suffix)
end

-- A sort function that determines in what order bindings should be applied.
-- This function should be treated with care, it can drastically change behavior
local function ApplicationOrder(a, b)
    local acnt, bcnt = 0, 0
    for k,v in pairs(a.sets) do acnt = acnt + 1 end
    for k,v in pairs(b.sets) do bcnt = bcnt + 1 end

    -- Force out-of-combat clicks to take the HIGHEST priority
    if a.sets.ooc and not b.sets.ooc then
        return true
	elseif b.sets.ooc and not a.sets.ooc then
		return false
    elseif a.sets.ooc and b.sets.ooc then
        return acnt < bcnt
    end

    -- Try to give any 'default' clicks LOWEST priority
    if a.sets.default and not b.sets.default then
        return true
    elseif a.sets.default and b.sets.default then
        return acnt < bcnt
    end
end

local function shouldApply(global, entry)
    -- If this is the global button and this is a 'global' binding
    if global and (entry.sets.hovercast or entry.sets.global) then
        return true
    elseif not global then
        -- Check to see if there's a non-global binding to be set
        for k, v in pairs(entry.sets) do
            if k ~= "global" and k ~= "hovercast" then
                return true
            end
        end
        return false
    end
end

local function correctSpec(entry, currentSpec)
	if entry.sets.pritalent and currentSpec ~= 1 then
		return false
	elseif entry.sets.sectalent and currentSpec ~= 2 then
		return false
	end
	return true
end

local function getEntryString(entry)
	local bits = {}
	bits[#bits+1] = "type"
	bits[#bits+1] = tostring(entry.type)

	if entry.type == "spell" then
		bits[#bits+1] = tostring(entry.spell)
	elseif entry.type == "macro" and entry.macrotext then
		bits[#bits+1] = tostring(entry.macrotext)
	end

	return table.concat(bits, ":")
end

-- This function takes a single argument indicating if the attributes being
-- computed are for the special 'global' button used by Clique.  It then
-- computes the set of attributes necessary for the player's bindings to be
-- active on all the appropriate frames. The logic here is quite delicate but
-- also rather well commented.

function addon:GetClickAttributes(global)
    -- In these scripts, 'self' should always be the header
    local bits = {
		"local inCombat = control:GetAttribute('inCombat')",
        "local setupbutton = self:GetFrameRef('cliquesetup_button')",
        "local button = setupbutton or self",
    }

    local rembits = {
		"local inCombat = control:GetAttribute('inCombat')",
        "local setupbutton = self:GetFrameRef('cliquesetup_button')",
        "local button = setupbutton or self",
    }

    -- Check to see if the frame being setup is blacklisted. Do not perform
    -- this check on the global frame.
    if not global then
        bits[#bits + 1] = "local name = button:GetName()"
        bits[#bits + 1] = "if blacklist[name] then return end"

        rembits[#rembits + 1] = "local name = button:GetName()"
        rembits[#rembits + 1] = "if blacklist[name] then return end"
    end

    -- Sort the bindings so they are applied in order. This sort ensures that
	-- any 'ooc' bindings are applied first.
    table.sort(self.bindings, ApplicationOrder)

    -- Build a small table of ooc keys that are 'taken' so we can check for
    -- masking conflicts with the friend/enemy sets.
    local oocKeys = {}
    for idx, entry in ipairs(self.bindings) do
        if shouldApply(global, entry) and entry.sets.ooc and entry.key then
            oocKeys[entry.key] = true
        end
    end

    for idx, entry in ipairs(self.bindings) do
        -- Global (i.e. 'hovercast' and 'global') bindings are only applied
        -- on the global frame, and not on any others. Additionally, any
        -- non-global bindings are only applied on non-global frames. handle
        -- this logic here.

        if shouldApply(global, entry) and correctSpec(entry, GetActiveSpecGroup()) and entry.key then
            -- Check to see if this is a 'friend' or an 'enemy' binding, and
            -- check if it would mask an 'ooc' binding with the same key. If
            -- so, we need to add code that prevents this from happening, by
            -- stopping the friend/enemy binding from being applied when the
            -- player is out of combat.

            local indent = ""
            local oocmask = oocKeys[entry.key]

			-- This code needs to set/clear a binding depending on combat
			-- state. We do both in this function to ensure that we don't have
			-- to run remove_clicks every single time the combat status
			-- changes.

			local startbits
            if oocmask and not entry.sets.ooc then
				-- This means that the binding will mask the 'ooc' binding
				-- with the same key, so we must ensure this is only set when
				-- we are in combat.
                bits[#bits + 1] = "if inCombat then      -- non-ooc that is masking"
                indent = indent .. "  "
			elseif entry.sets.ooc then
				-- This is a standard 'ooc' binding, so we want to ensure its
				-- only applied when out of combat, and cleared otherwise.
				bits[#bits + 1] = "if not inCombat then  -- ooc binding"
				indent = indent .. "  "
				startbits = #rembits + 1
            end

            local prefix, suffix = addon:GetBindingPrefixSuffix(entry, global)

            -- Set up help/harm bindings. The button value will be either a number,
            -- in the case of mouse buttons, otherwise it will be a string of
            -- characters. Harmbuttons work alongside modifiers, so we need to include
            -- then in the remapping.
            if entry.sets.friend then
                if global then
                    -- A modified binding that uses friend/enemy must have the unmodified
                    -- 'unit' attribute set, in order to do the friend/enemy lookup. Add
                    -- that here.
                    --
                    -- NOTE: This will not work with useOwnerUnit and usesuffix frames
                    -- such as pet frames that use the owner's parent. This is a problem
                    -- with the way the 'mouseover' unit resolves in these cases.
                    bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                    rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
                end
                local newbutton = "friend" .. suffix
                bits[#bits + 1] = ATTR(indent, prefix, "helpbutton", suffix, newbutton)
                rembits[#rembits + 1] = REMATTR(prefix, "helpbutton", suffix)
                suffix = newbutton
            elseif entry.sets.enemy then
                if global then
                    -- A modified binding that uses friend/enemy must have the unmodified
                    -- 'unit' attribute set, in order to do the friend/enemy lookup. Add
                    -- that here.
                    --
                    -- NOTE: This will not work with useOwnerUnit and usesuffix frames
                    -- such as pet frames that use the owner's parent. This is a problem
                    -- with the way the 'mouseover' unit resolves in these cases.
                    bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                    rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
                end
                local newbutton = "enemy" .. suffix
                bits[#bits + 1] = ATTR(indent, prefix, "harmbutton", suffix, newbutton)
                rembits[#rembits + 1] = REMATTR(prefix, "harmbutton", suffix)
                suffix = newbutton
            end

            -- When we're setting up the 'global' button, and the binding is in the
            -- 'hovercast' binding set, we need to specify the unit on which to take
            -- the action. In this case, that's just mouseover.
            if global and entry.sets.hovercast then
                bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
            end

            -- Build any needed SetAttribute() calls
            if entry.type == "target" then
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
            elseif entry.type == "menu" then
                set_text = ATTR(indent, prefix, "type", suffix, "togglemenu")
                bits[#bits + 1] = string.gsub(set_text, '"togglemenu"', 'button:GetAttribute("*type2") == "menu" and "menu" or "togglemenu"')
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
			elseif entry.type == "spell" and self.settings.stopcastingfix then
				-- Implement the 'stop casting'f ix
				local macrotext
				if entry.sets.global then
					-- Do not include @mouseover
					macrotext = string.format("/click %s\n/cast %s", self.stopbutton.name, entry.spell)
				else
					macrotext = string.format("/click %s\n/cast [@mouseover] %s", self.stopbutton.name, entry.spell)
				end
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, "macro")
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
           elseif entry.type == "spell" then
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "spell", suffix, entry.spell)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "spell", suffix)
			elseif entry.type == "macro" and self.settings.stopcastingfix then
				local macrotext = string.format("/click %s\n%s", self.stopbutton.name, entry.macrotext)
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
            elseif entry.type == "macro" then
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, entry.macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
            else
                error(string.format("Invalid action type: '%s'", entry.type))
            end

            -- Finish the conditional statements started above
            if oocmask and not entry.sets.ooc then
				-- This means that the binding will mask the 'ooc' binding
				-- with the same key, so we must ensure this is only set when
				-- we are in combat.
				bits[#bits + 1] = "end"
                indent = indent:sub(1, -3)
			elseif entry.sets.ooc then
				-- This is a standard 'ooc' binding, so we want to ensure its
				-- only applied when out of combat, and cleared otherwise.
				local endbits = #rembits
				bits[#bits + 1] = "else                  -- clear ooc binding"
				for i = startbits, endbits, 1 do
					bits[#bits + 1] = indent .. rembits[i]
				end
				bits[#bits + 1] = "end"
				indent = indent:sub(1, -3)
            end
        end
    end

    return table.concat(bits, "\n"), table.concat(rembits, "\n")
end

local B_SET = [[self:SetBindingClick(true, %q, self, %q);]]
local B_CLR = [[self:ClearBinding(%q);]]

-- This function takes a single argument, indicating whether the attributes
-- should be built for the special global button or not, and returns an
-- attribute that can set the appropriate attributes, and one that can clear
function addon:GetBindingAttributes(global)
    local set, clr

    -- If this is not the global button, include some logic that solves issues
    -- when the frame disappears or the frame loses focus without the OnLeave
    -- event firing.
    --
    -- TODO: In the future, this should be done via OnHide or other ways as well

    if global then
        set = {}
        clr = {}
    else
        set = {
            "local button = self",
            "local name = button:GetName()",
            "if danglingButton then control:RunFor(danglingButton, control:GetAttribute('setup_onleave')) end",
            "if blacklist[name] then return end",
            "danglingButton = button",
        }
        clr = {
            "local button = self",
            "local name = button:GetName()",
            "if blacklist[name] then return end",
            "danglingButton = nil",
        }
    end

    -- This function is greatly simplified in that regardless of whether or
    -- not bindings mask one another, they still need to be set as binding
    -- clicks on the frame. Simply make a list of the keys that need to be
    -- bound, and bind them.

    local unique = {}

    for idx, entry in ipairs(self.bindings) do
		if entry.key then
			if shouldApply(global, entry) and correctSpec(entry, GetActiveSpecGroup()) then
				if global then
					-- Allow for the re-binding of clicks and keys, except for
					-- unmodified left/right-click
					if entry.key ~= "BUTTON1" and entry.key ~= "BUTTON2" then
						local prefix, suffix = addon:GetBindingPrefixSuffix(entry, global)
						local key = self:ConvertSpecialKeys(entry)

						local attr = B_SET:format(key, suffix)
						if not unique[attr] then
							set[#set + 1] = attr
							clr[#clr + 1] = B_CLR:format(key)
							unique[attr] = true
						end
					end
				else
					local buttonNum = entry.key:match("BUTTON(%d+)$")
					if not buttonNum then
						-- Only apply key-based binding clicks, let the raw
						-- attributes handle the others
						local prefix, suffix = addon:GetBindingPrefixSuffix(entry, global)
						local key = self:ConvertSpecialKeys(entry)

						local attr = B_SET:format(key, suffix)
						if not unique[attr] then
							set[#set + 1] = attr
							clr[#clr + 1] = B_CLR:format(key)
							unique[attr] = true
						end
					end
				end
			end
		end
    end

    return table.concat(set, "\n"), table.concat(clr, "\n")
end

-- This function adds a binding to the player's current profile. The
-- following options can be included in the click-cast entry:
--
-- entry = {
--     -- The full prefix and suffix of the key being bound
--     key = "ALT-CTRL-SHIFT-BUTTON1",
--     -- The icon to be used for displaying this entry
--     icon = "Interface\\Icons\\Spell_Nature_HealingTouch",
--
--     -- Any restricted sets that this click should be applied to
--     sets = {"ooc", "harm", "help", "frames_blizzard"},
--
--     -- The type of the click-binding
--     type = "spell",
--     type = "macro",
--     type = "target",
--     type = "menu",
--
--     -- Any arguments for given click type
--     spell = "Healing Touch",
--     macrotext = "/run Nature's Swiftness\n/cast [target=mouseover] Healing Touch",
--     unit = "mouseover",
-- }

function addon:AddBinding(entry)
    if InCombatLockdown() then
        return false
    end

    -- TODO: Check to see if the new binding conflicts with an existing binding
    -- TODO: Validate the entry to ensure it has the correct arguments, etc.

    if not entry.sets then
        entry.sets = {default = true}
    end

    table.insert(self.bindings, entry)
    self:FireMessage("BINDINGS_CHANGED")
    return true
end

local function bindingeq(a, b)
    assert(type(a) == "table", "Error during deletion comparison")
    assert(type(b) == "table", "Error during deletion comparison")

    if a.type ~= b.type then
        return false
    elseif a.type == "target" then
        return a.key == b.key
    elseif a.type == "menu" then
        return a.key == b.key
    elseif a.type == "spell" then
        return a.spell == b.spell and a.key == b.key
    elseif a.type == "macro" then
        return a.macrotext == b.macrotext and a.key == b.key
    end

    return false
end

function addon:DeleteBinding(entry)
    if InCombatLockdown() then
        return false
    end

    -- Look for an entry that matches the given binding and remove it
    for idx, bind in ipairs(self.bindings) do
        if bindingeq(entry, bind) then
            -- Found the entry that matches, so remove it
            table.remove(self.bindings, idx)
            break
        end
    end

    self:FireMessage("BINDINGS_CHANGED")
end

function addon:ClearAttributes()
    self.header:Execute([[
        for button, enabled in pairs(ccframes) do
            self:RunFor(button, self:GetAttribute("remove_clicks"))
        end
    ]])

    for button, enabled in pairs(self.ccframes) do
        -- Perform the setup of click bindings
        self.header:SetFrameRef("cliquesetup_button", button)
        self.header:Execute(self.header:GetAttribute("remove_clicks"), button)
    end

    -- Clear global attributes
    local globutton = self.globutton
    globutton:Execute(globutton.remove)
    globutton:Execute(globutton.clearbinds)
end

-- Recompute all attributes, so they can later be applied.
function addon:UpdateAttributes()
    local setup, remove = self:GetClickAttributes()
    self.header:SetAttribute("setup_clicks", setup)
    self.header:SetAttribute("remove_clicks", remove)

    local set, clr = self:GetBindingAttributes()
    self.header:SetAttribute("setup_onenter", set)
    self.header:SetAttribute("setup_onleave", clr)

    local globutton = self.globutton
    globutton.setup, globutton.remove = self:GetClickAttributes(true)
    globutton.setbinds, globutton.clearbinds = self:GetBindingAttributes(true)
end

function addon:ApplyAttributes()
    -- Handle all of the securely registered frames
    self.header:Execute([[
        for button, enabled in pairs(ccframes) do
            self:RunFor(button, self:GetAttribute("setup_clicks"))
        end
    ]])

    -- Now any compat frames that used the old method
    for button, enabled in pairs(self.ccframes) do
        -- Unwrap any existing enter/leave scripts
        self.header:UnwrapScript(button, "OnEnter")
        self.header:UnwrapScript(button, "OnLeave")
        self.header:WrapScript(button, "OnEnter", addon.header:GetAttribute("setup_onenter"))
        self.header:WrapScript(button, "OnLeave", addon.header:GetAttribute("setup_onleave"))

        -- Perform the setup of click bindings
        self.header:SetFrameRef("cliquesetup_button", button)
        self.header:Execute(self.header:GetAttribute("setup_clicks"), button)
    end

    -- Update the global button attributes
    self.globutton:Execute(self.globutton.setup)
    self.globutton:Execute(self.globutton.setbinds)
end

function addon:TalentGroupChanged()
    local currentProfile = self.db:GetCurrentProfile()
    local newProfile

	if self.settings.specswap then
		self.talentGroup = GetActiveSpecGroup()
        -- Determine which profile to set, based on talent group
        if self.talentGroup == 1 and self.settings.pri_profileKey then
            newProfile = self.settings.pri_profileKey
        elseif self.talentGroup == 2 and self.settings.sec_profileKey then
            newProfile = self.settings.sec_profileKey
        end

        if newProfile ~= currentProfile and type(newProfile) == "string" then
            self.db:SetProfile(newProfile)
        end
    end

    self:FireMessage("BINDINGS_CHANGED")
end

function addon:UpdateCombatWatch()
    if self.settings.fastooc then
        self:RegisterEvent("UNIT_FLAGS", "CheckPartyCombat")
    else
        self:UnregisterEvent("UNIT_FLAGS")
    end
end

function addon:UpdateBlacklist()
    local bits = {
        "blacklist = table.wipe(blacklist)",
    }

    for frame, value in pairs(self.settings.blacklist) do
        if not not value then
            bits[#bits + 1] = string.format("blacklist[%q] = true", frame)
        end
    end

    addon.header:Execute(table.concat(bits, ";\n"))
    addon:UpdateRegisteredClicks()
end

function addon:EnteringCombat()
    -- If there are no 'ooc' bindings, then no need to re-apply
    if not self.has_ooc then
        return
    end

    -- Check to see if we're already in combat, so we don't re-apply
    if not self.header:GetAttribute("inCombat") then
        -- Apply attributes, indicating we need the 'combat' set
        self.header:SetAttribute("inCombat", true)
        self.globutton:SetAttribute("inCombat", true)
        addon:ApplyAttributes()
    end
end

function addon:LeavingCombat()
    -- Process any frames in the registration queue
    for idx, button in ipairs(self.regqueue) do
        self:RegisterFrame(button)
    end
    if next(self.regqueue) then table.wipe(self.regqueue) end

    -- Process any frames in the unregistration queue
    for idx, button in ipairs(self.unregqueue) do
        self:UnregisterFrame(button)
    end
    if next(self.regqueue) then table.wipe(self.regqueue) end

    -- Process any frames in the clickregister queue
    for idx, button in ipairs(self.regclickqueue) do
        self:UpdateRegisteredClicks(button)
    end
    if next(self.regclickqueue) then table.wipe(self.regclickqueue) end

    -- Only apply attributes if we have an 'ooc' binding set
    if self.has_ooc then
        if self.partyincombat then
            self.partyincombat = false
        end

        -- Clear previously set attributes
        self:ClearAttributes()

        -- Apply attributes, indicating we want the 'ooc' set
        self.header:SetAttribute("inCombat", false)
        self.globutton:SetAttribute("inCombat", false)
        self:ApplyAttributes()
    end
end

function addon:CheckPartyCombat(event, unit)
    if InCombatLockdown() or not unit then return end
    if not self.has_ooc then
        -- No change required if no ooc bindings
        return
    end

    if self.settings.fastooc then
        if UnitInParty(unit) or UnitInRaid(unit) then
            if UnitAffectingCombat(unit) == 1 then
                -- Trigger pre-combat switch for fastooc
                self.partyincombat = true
                self.combattrigger = UnitGUID(unit)
                self.header:SetAttribute("inCombat", true)
                self.globutton:SetAttribute("inCombat", true)
                addon:ApplyAttributes()
            elseif self.partyincombat then
                -- The unit is out of combat, so try to clear our flag
                if self.combattrigger == UnitGUID(unit) then
                    self.partyincombat = false
                    self.header:SetAttribute("inCombat", false)
                    self.globutton:SetAttribute("inCombat", false)
                    addon:ApplyAttributes()
                end
            end
        end
    end
end

-- This function returns whether or not a frame is blacklisted in the current
-- users settings

function addon:IsFrameBlacklisted(frame)
    local name = frame
    if type(frame) == "table" then
        name = frame.GetName and frame:GetName()
    end
    return self.settings.blacklist[name]
end

-- Update both registered clicks, and ensure that mousewheel events are enabled
-- on the frame.
function addon:UpdateRegisteredClicks(button)
    if InCombatLockdown() then
        table.insert(self.regclickqueue, button)
        return
    end

    local direction = self.settings.downclick and "AnyDown" or "AnyUp"

    -- Short version that only updates clicks for one frame
    if button and not self:IsFrameBlacklisted(button) then
        button:RegisterForClicks(direction)
        button:EnableMouseWheel(true)
        return
    end

    for button in pairs(self.ccframes) do
        if not self:IsFrameBlacklisted(button) then
            button:RegisterForClicks(direction)
            button:EnableMouseWheel(true)
        end
    end

    for name, button in pairs(self.hccframes) do
       if not self:IsFrameBlacklisted(button) then
           button:RegisterForClicks(direction)
           button:EnableMouseWheel(true)
       end
    end
end

-- Handler function for message indicating that a change as occurred
-- with the configured bindings. This is the only place that the
-- bindings should be re-computed. If this handler is called during
-- combat than execution should be deferred until the user exits
-- combat.
function addon:BINDINGS_CHANGED()
    if InCombatLockdown() then
        self:Defer("BINDINGS_CHANGED")
        return
    end

    -- Clear any existing attributes
    self:ClearAttributes()

    -- Very simple optimisation. If the player has no 'ooc' bindings
    -- set, then attributes can be applied once and then only updated
    -- when the bindings list is changed.
    local has_ooc = false
    for idx, entry in ipairs(self.bindings) do
        if entry.sets.ooc then
             has_ooc = true
            break
        end
    end

    self.has_ooc = has_ooc

    -- Update all click/binding attributes
    self:UpdateAttributes()

    -- Update the bindings list, if open
    CliqueConfig:UpdateList()

    -- Update the actual attributes on all frames
    self:ApplyAttributes()
end

function addon:BLACKLIST_CHANGED()
    if InCombatLockdown() then
        self:Defer("BLACKLIST_CHANGED")
        return
    end

    -- Clear attributes on all frames
    self:ClearAttributes()

    -- Actually update the blacklist accordingly
    local bits = {
        "blacklist = table.wipe(blacklist)",
    }

    for frame, value in pairs(self.settings.blacklist) do
        if not not value then
            bits[#bits + 1] = string.format("blacklist[%q] = true", frame)
        end
    end

    addon.header:Execute(table.concat(bits, ";\n"))

    -- Update the registered clicks, to catch any unblacklisted frames
    self:UpdateRegisteredClicks()
    -- Update the options panel
    self:UpdateOptionsPanel()

    -- Update the actual attributes on all frames
    self:ApplyAttributes()
end

SLASH_CLIQUE1 = "/clique"
SlashCmdList["CLIQUE"] = function(msg, editbox)
    if SpellBookFrame:IsVisible() then
        CliqueConfig:ShowWithSpellBook()
    else
        ShowUIPanel(CliqueConfig)
    end
end
