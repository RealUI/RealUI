-- Raven is an addon to monitor auras and cooldowns, providing timer bars and icons plus helpful notifications.

-- Profile.lua contains the default profile for initializing the player's selected profile.
-- It includes routines to process preset aura and cooldown info for all classes and races.
-- Profile settings are accessed by reference to MOD.db.global or MOD.db.profile.
-- It also maintains a persistent database that caches icons, colors and labels for auras and spells.

-- Exported functions for looking up aura and spell-related info:
-- Raven:SetIcon(name, icon) save icon in cache
-- Raven:GetIcon(name) returns cached icon for spell with the specified name, nil if not found
-- Raven:SetColor(name, color) save color in cache
-- Raven:GetColor(name) returns cached color for spell with the specified name, nil if not found
-- Raven:SetLabel(name, label) save label in cache
-- Raven:GetLabel(name) returns cached label for spell with the specified name, nil if not found
-- Raven:SetSound(name, sound) save sound in cache
-- Raven:GetSound(name) returns cached sound for spell with the specified name, nil if not found
-- Raven:GetHyperlink(name) return a hyperlink for the spell with the specified name, nil if not found
-- Raven:FormatTime(time, index, spaces, upperCase) returns time in seconds converted into a text string
-- Raven:RegisterTimeFormat(func) adds a custom time format and returns its assigned index
-- Raven:ResetBarGroupFilter(barGroupName, "Buff"|"Debuff"|"Cooldown")
-- Raven:RegisterBarGroupFilter(barGroupName, "Buff"|"Debuff"|"Cooldown", spellNameOrID)

local MOD = Raven
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local LSPELL = MOD.LocalSpellNames

local dispelTypes = {} -- table of debuff types that the character can dispel
local spellColors = {} -- table of default spell colors
local maxSpellID = 300000 -- set to maximum actual spell id during initialization

-- Saved variables don't handle being set to nil properly so need to use alternate value to indicate an option has been turned off
local Off = 0 -- value used to designate an option is turned off
local function IsOff(value) return value == nil or value == Off end -- return true if option is turned off
local function IsOn(value) return value ~= nil and value ~= Off end -- return true if option is turned on

-- Convert color codes from hex number to array with r, g, b, a fields (alpha set to 1.0)
function MOD.HexColor(hex)
	local n = tonumber(hex, 16)
	local red = math.floor(n / (256 * 256))
	local green = math.floor(n / 256) % 256
	local blue = n % 256

	return { r = red/255, g = green/255, b = blue/255, a = 1.0 }
end

-- Return a copy of a color, if c is nil then return white
function MOD.CopyColor(c)
	if not c then return nil end
	return { r = c.r, g = c.g, b = c.b, a = c.a }
end

-- Copy a table, including its metatable
function MOD.CopyTable(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- Global color palette containing the standard colors for this addon
MOD.ColorPalette = {
	Yellow1=MOD.HexColor("fce94f"), Yellow2=MOD.HexColor("edd400"), Yellow3=MOD.HexColor("c4a000"),
	Orange1=MOD.HexColor("fcaf3e"), Orange2=MOD.HexColor("f57900"), Orange3=MOD.HexColor("ce5c00"),
	Brown1=MOD.HexColor("e9b96e"), Brown2=MOD.HexColor("c17d11"), Brown3=MOD.HexColor("8f5902"),
	Green1=MOD.HexColor("8ae234"), Green2=MOD.HexColor("73d216"), Green3=MOD.HexColor("4e9a06"),
	Blue1=MOD.HexColor("729fcf"), Blue2=MOD.HexColor("3465a4"), Blue3=MOD.HexColor("204a87"),
	Purple1=MOD.HexColor("ad7fa8"), Purple2=MOD.HexColor("75507b"), Purple3=MOD.HexColor("5c3566"),
	Red1=MOD.HexColor("ef2929"), Red2=MOD.HexColor("cc0000"), Red3=MOD.HexColor("a40000"),
	Pink=MOD.HexColor("ff6eb4"), Cyan=MOD.HexColor("7adbf2"), Gray=MOD.HexColor("888a85"),
}

-- Remove unneeded variables from the profile before logout
local function OnProfileShutDown()
	for n, k in pairs(MOD.db.global.SpellIDs) do if k == 0 then MOD.db.global.SpellIDs[n] = nil end end
	MOD:FinalizeBars() -- strip out all default values to significantly reduce profile file size
	MOD:FinalizeConditions() -- strip out temporary values from conditions
	MOD:FinalizeSettings() -- strip default values from layouts
	MOD:FinalizeInCombatBar() -- save linked settings
end
	
-- Initialize profile used to customize the addon
function MOD:InitializeProfile()
	MOD:SetSpellDefaults()
	MOD:SetCooldownDefaults()
	MOD:SetInternalCooldownDefaults()
	MOD:SetSpellEffectDefaults()
	MOD:SetConditionDefaults()
	MOD:SetIconDefaults()
	MOD:SetSpellNameDefaults()
	MOD:SetDimensionDefaults(MOD.DefaultProfile.global.Defaults)
	MOD:SetFontTextureDefaults(MOD.DefaultProfile.global.Defaults)
	MOD:SetInCombatBarDefaults()
	
	-- Get profile from database, providing default profile for initialization
	MOD.db = LibStub("AceDB-3.0"):New("RavenDB", MOD.DefaultProfile)
	MOD.db.RegisterCallback(MOD, "OnDatabaseShutdown", OnProfileShutDown)

	MOD:InitializeSettings() -- Initialize bar group settings with default values
end

-- Initialize spells for class auras and cooldowns, also scan other classes for group buffs and cooldowns
-- Buffs, debuffs and cooldowns are tracked in tables containing name, color, class, race
function MOD:SetSpellDefaults()
	local id = maxSpellID
	while id > 1 do -- find the highest actual spell id by scanning down from a really big number
		id = id - 1
		local n = GetSpellInfo(id)
		if n then break end
	end
	maxSpellID = id + 1

	for id, hex in pairs(MOD.defaultColors) do -- add spell colors with localized names to the profile
		local c = MOD.HexColor(hex) -- convert from hex coded string
		local name = GetSpellInfo(id) -- get localized name from the spell id
		if name and c then MOD.DefaultProfile.global.SpellColors[name] = c end-- sets default color in the shared color table
	end

	for name, hex in pairs(MOD.generalSpells) do -- add some general purpose localized colors
		local c = MOD.HexColor(hex) -- convert from hex coded string
		local ln = L[name] -- get localized name
		if ln and c then MOD.DefaultProfile.global.SpellColors[ln] = c end -- add to the shared color table
	end
	
	MOD.defaultColors = nil -- not used again after initialization so okay to delete
	MOD.generalSpells = nil
	
	spellColors = MOD.DefaultProfile.global.SpellColors -- save for restoring defaults later
	
	if MOD.myClass == "DEATHKNIGHT" then -- localize rune spell names
		local t = {}
		for k, p in pairs(MOD.runeSpells) do if p.id then local name = GetSpellInfo(p.id); if name and name ~= "" then t[name] = p end end end
		MOD.runeSpells = t
	end
end

-- Initialize cooldown info from spellbook, should be called whenever spell book changes
-- This is currently only used to initialize some info related to spell school lockouts
function MOD:SetCooldownDefaults()
	table.wipe(MOD.lockoutSpells) -- erase any previous entries in the spell lockout table
	for _, p in pairs(MOD.lockSpells) do -- then add in all known spells from the table of spells used to test for lockouts
		local name = GetSpellInfo(p.id)
		if name and name ~= "" then MOD.lockoutSpells[name] = { school = p.school, id = p.id } end
	end
	
	local numSpells = 0
	for i = 1, 2 do local _, _, _, n = GetSpellTabInfo(i); numSpells = numSpells + n end
	
	for i = 1, numSpells do
		local name = GetSpellInfo(i, "spell") -- doesn't account for "FLYOUT" spellbook entries, but not an issue currently
		if name and name ~= "" then
			local ls = MOD.lockoutSpells[name]
			if ls then
				ls.index = i -- add fields for the spell book index plus localized text
				if ls.school == "Frost" then ls.label = L["Frost School"]; ls.text = L["Locked out of Frost school of magic."]
				elseif ls.school == "Fire" then ls.label = L["Fire School"]; ls.text = L["Locked out of Fire school of magic."]
				elseif ls.school == "Nature" then ls.label = L["Nature School"]; ls.text = L["Locked out of Nature school of magic."]
				elseif ls.school == "Shadow" then ls.label = L["Shadow School"]; ls.text = L["Locked out of Shadow school of magic."]
				elseif ls.school == "Arcane" then ls.label = L["Arcane School"]; ls.text = L["Locked out of Arcane school of magic."]
				elseif ls.school == "Holy" then ls.label = L["Holy School"]; ls.text = L["Locked out of Holy school of magic."]
				elseif ls.school == "Physical" then ls.label = L["Physical School"]; ls.text = L["Locked out of Physical school of magic."]
				end
			end
		end
	end
end

-- Initialize internal cooldown info from presets, table fields include id, duration, cancel, item
-- This function translates ids into spell names and looks up the icon
function MOD:SetInternalCooldownDefaults()
	local ict = MOD.DefaultProfile.global.InternalCooldowns
	for _, cd in pairs(MOD.internalCooldowns) do
		local name = GetSpellInfo(cd.id)
		if name and (name ~= "") and (not ict[name] or not cd.item or IsUsableItem(cd.item)) then 
			local t = { id = cd.id, duration = cd.duration, icon = GetSpellTexture(cd.id), item = cd.item, class = cd.class }
			if cd.cancel then
				t.cancel = {}
				for k, c in pairs(cd.cancel) do local n = GetSpellInfo(c); if n and n ~= "" then t.cancel[k] = n end end
			end
			ict[name] = t
		end
	end
	MOD.internalCooldowns = nil -- release the preset table memory
end

-- Initialize spell effect info from presets, table fields include id, duration, associated spell, talent
-- This function translates ids into spell names and looks up the icon
function MOD:SetSpellEffectDefaults()
	local ect = MOD.DefaultProfile.global.SpellEffects
	for _, ec in pairs(MOD.spellEffects) do
		local name = GetSpellInfo(ec.id)
		if name and name ~= "" then
			local id, spell, talent = ec.id, nil, nil
			if ec.spell then spell = GetSpellInfo(ec.spell); id = ec.spell end -- must be valid
			if ec.talent then talent = GetSpellInfo(ec.talent) end -- must be valid
			local t = { duration = ec.duration, icon = GetSpellTexture(id), spell = spell, id = id, renew = ec.renew, talent = talent }
			ect[name] = t
		end
	end
	MOD.spellEffects = nil -- release the preset table memory
end

-- Reset a particular spell color to its default value
function MOD:ResetColorDefault(name)
	if name then
		local dct = spellColors
		local sct = MOD.db.global.SpellColors
		local c = dct[name]
		if not c then
			sct[name] = nil -- if not default value then just clear the spell color
		else
			local t = sct[name]
			if t then
				t.r, t.g, t.b, t.a = c.r, c.g, c.b, c.a
			else
				sct[name] = MOD.CopyColor(c)
			end
		end	
	end
end

-- Reset all colors to default values
function MOD:ResetColorDefaults()
	local dct = spellColors
	local sct = MOD.db.global.SpellColors
	for n, c in pairs(dct) do -- copy all original values from the default color table
		local t = sct[n]
		if t then
			t.r, t.g, t.b, t.a = c.r, c.g, c.b, c.a
		else
			sct[n] = MOD.CopyColor(c)
		end
	end 
	for n in pairs(sct) do if not dct[n] then sct[n] = nil end end -- remove any extras
end

-- Initialize cache of icons
local iconCache = {}
function MOD:SetIconDefaults()
	for tab = 1, 2 do -- scan first two tabs of player spell book and create caches of known spells and icons
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		for i = 1, numSpells do
			local index = i + offset
			local stype, id = GetSpellBookItemInfo(index, "spell")
			if stype == "SPELL" then -- use spellbook index to check for cooldown
				local name = GetSpellInfo(index, "spell")
				if name and name ~= "" then iconCache[name] = GetSpellTexture(id) end
			elseif stype == "FLYOUT" then -- use spell id to check for cooldown
				local _, _, numSlots = GetFlyoutInfo(id)
				for slot = 1, numSlots do
					local spellID = GetFlyoutSlotInfo(id, slot)
					if spellID then
						local name = GetSpellInfo(spellID)
						if name and name ~= "" then iconCache[name] = GetSpellTexture(spellID) end
					end
				end
			end
		end
	end

	iconCache[L["GCD"]] = GetSpellTexture(28730) -- cached for global cooldown (using same icon as Arcane Torrent, must be valid)
end

-- Initialize dimension defaults
function MOD:SetDimensionDefaults(p)
	p.barWidth = 150; p.barHeight = 15; p.iconSize = 15; p.scale = 1; p.spacingX = 0; p.spacingY = 0; p.iconOffsetX = 0; p.iconOffsetY = 0
	p.hideIcon = false; p.hideClock = false; p.hideBar = false; p.hideSpark = false
	p.hideLabel = false; p.hideCount = true; p.hideValue = false; p.showTooltips = true
	p.i_barWidth = 20; p.i_barHeight = 5; p.i_iconSize = 25; p.i_scale = 1; p.i_spacingX = 2; p.i_spacingY = 15; p.i_iconOffsetX = 0; p.i_iconOffsetY = 0
	p.i_hideIcon = false; p.i_hideClock = false; p.i_hideBar = true; p.i_hideSpark = false
	p.i_hideLabel = true; p.i_hideCount = true; p.i_hideValue = false; p.i_showTooltips = true
end

-- Copy dimensions, destination is always a bar group, check which configuration type and copy either bar or icon defaults
function MOD:CopyDimensions(s, d)
	local iconOnly = d.configuration and MOD.Nest_SupportedConfigurations[d.configuration].iconOnly or false
	if iconOnly then
		d.barWidth = s.i_barWidth; d.barHeight = s.i_barHeight; d.iconSize = s.i_iconSize; d.scale = s.i_scale				
		d.spacingX = s.i_spacingX; d.spacingY = s.i_spacingY; d.iconOffsetX = s.i_iconOffsetX; d.iconOffsetY = s.i_iconOffsetY
		d.hideIcon = s.i_hideIcon; d.hideClock = s.i_hideClock; d.hideBar = s.i_hideBar; d.hideSpark = s.i_hideSpark
		d.hideLabel = s.i_hideLabel; d.hideCount = s.i_hideCount; d.hideValue = s.i_hideValue; d.showTooltips = s.i_showTooltips
	else
		d.barWidth = s.barWidth; d.barHeight = s.barHeight; d.iconSize = s.iconSize; d.scale = s.scale				
		d.spacingX = s.spacingX; d.spacingY = s.spacingY; d.iconOffsetX = s.iconOffsetX; d.iconOffsetY = s.iconOffsetY
		d.hideIcon = s.hideIcon; d.hideClock = s.hideClock; d.hideBar = s.hideBar; d.hideSpark = s.hideSpark
		d.hideLabel = s.hideLabel; d.hideCount = s.hideCount; d.hideValue = s.hideValue; d.showTooltips = s.showTooltips
	end
end

-- Initialize default fonts and textures
function MOD:SetFontTextureDefaults(p)
	p.labelFont = "Arial Narrow"; p.labelFSize = 10; p.labelAlpha = 1; p.labelColor = { r = 1, g = 1, b = 1, a = 1 }
	p.labelOutline = false; p.labelShadow = true; p.labelThick = false; p.labelMono = false
	p.timeFont = "Arial Narrow"; p.timeFSize = 10; p.timeAlpha = 1; p.timeColor = { r = 1, g = 1, b = 1, a = 1 }
	p.timeOutline = false; p.timeShadow = true; p.timeThick = false; p.timeMono = false
	p.iconFont = "Arial Narrow"; p.iconFSize = 10; p.iconAlpha = 1; p.iconColor = { r = 1, g = 1, b = 1, a = 1 }
	p.iconOutline = true; p.iconShadow = true; p.iconThick = false; p.iconMono = false
	p.texture = "Blizzard"; p.bgtexture = "Blizzard"; p.alpha = 1; p.combatAlpha = 1; p.fgAlpha = 1; p.bgAlpha = 0.65
	p.backdropEnable = false; p.backdropTexture = "None"; p.backdropWidth = 16; p.backdropInset = 4; p.backdropPadding = 16; p.backdropPanel = "None"
	p.backdropColor = { r = 1, g = 1, b = 1, a = 1 }; p.backdropFill = { r = 1, g = 1, b = 1, a = 1 }
	p.backdropOffsetX = 0; p.backdropOffsetY = 0; p.backdropPadW = 0; p.backdropPadH = 0
	p.borderTexture = "None"; p.borderWidth = 8; p.borderOffset = 2; p.borderColor = { r = 1, g = 1, b = 1, a = 1 }
	p.fgSaturation = 0; p.fgBrightness = 0; p.bgSaturation = 0; p.bgBrightness = 0; p.borderSaturation = 0; p.borderBrightness = 0
end

-- Copy fonts and textures between tables
function MOD:CopyFontsAndTextures(s, d)
	if s and d and (s ~= d) then
		d.labelFont = s.labelFont; d.labelFSize = s.labelFSize; d.labelAlpha = s.labelAlpha; d.labelColor = MOD.CopyColor(s.labelColor)
		d.labelOutline = s.labelOutline; d.labelShadow = s.labelShadow; d.labelThick = s.labelThick; d.labelMono = s.labelMono
		d.timeFont = s.timeFont; d.timeFSize = s.timeFSize; d.timeAlpha = s.timeAlpha; d.timeColor = MOD.CopyColor(s.timeColor)
		d.timeOutline = s.timeOutline; d.timeShadow = s.timeShadow; d.timeThick = s.timeThick; d.timeMono = s.timeMono
		d.iconFont = s.iconFont; d.iconFSize = s.iconFSize; d.iconAlpha = s.iconAlpha; d.iconColor = MOD.CopyColor(s.iconColor)
		d.iconOutline = s.iconOutline; d.iconShadow = s.iconShadow; d.iconThick = s.iconThick; d.iconMono = s.iconMono
		d.texture = s.texture; d.bgtexture = s.bgtexture; d.alpha = s.alpha; d.combatAlpha = s.combatAlpha; d.fgAlpha = s.fgAlpha; d.bgAlpha = s.bgAlpha
		d.fgSaturation = s.fgSaturation; d.fgBrightness = s.fgBrightness; d.bgSaturation = s.bgSaturation; d.bgBrightness = s.bgBrightness;
		d.backdropTexture = s.backdropTexture; d.backdropWidth = s.backdropWidth; d.backdropInset = s.backdropInset
		d.backdropPadding = s.backdropPadding; d.backdropPanel = s.backdropPanel; d.backdropEnable = s.backdropEnable
		d.backdropColor = MOD.CopyColor(s.backdropColor); d.backdropFill = MOD.CopyColor(s.backdropFill)
		d.backdropOffsetX = s.backdropOffsetX; d.backdropOffsetY = s.backdropOffsetY; d.backdropPadW = s.backdropPadW; d.backdropPadH = s.backdropPadH
		d.borderTexture = s.borderTexture; d.borderWidth = s.borderWidth; d.borderOffset = s.borderOffset
		d.borderColor = MOD.CopyColor(s.borderColor); d.borderFill = MOD.CopyColor(s.borderFill)
		d.borderSaturation = s.borderSaturation; d.borderBrightness = s.borderBrightness
	end
end

-- Copy standard colors between tables
function MOD:CopyStandardColors(s, d)
	if s and d and (s ~= d) then
		d.buffColor = MOD.CopyColor(s.buffColor); d.debuffColor = MOD.CopyColor(s.debuffColor)
		d.cooldownColor = MOD.CopyColor(s.cooldownColor); d.notificationColor = MOD.CopyColor(s.notificationColor)
		d.poisonColor = MOD.CopyColor(s.poisonColor); d.curseColor = MOD.CopyColor(s.curseColor)
		d.magicColor = MOD.CopyColor(s.magicColor); d.diseaseColor = MOD.CopyColor(s.diseaseColor)
	end
end

-- Find and cache spell ids (this should be used rarely, primarily when entering spell names manually
function MOD:GetSpellID(name)
	if not name then return nil end -- prevent parameter error
	if string.find(name, "^#%d+") then return tonumber(string.sub(name, 2)) end -- check if name is in special format for specific spell id (i.e., #12345)
	
	local id = MOD.db.global.SpellIDs[name]
	if id == 0 then return nil end -- only scan invalid ones once in a session
	if id and (name ~= GetSpellInfo(id)) then id = nil end -- verify it is still valid

	if not id and not InCombatLockdown() then -- disallow the search when in combat due to script time limit (MoP)
		id = 0
		while id < maxSpellID do -- determined during initialization
			id = id + 1
			local n = GetSpellInfo(id)
			if n == name then
				MOD.db.global.SpellIDs[n] = id
				return id
			end
		end
		MOD.db.global.SpellIDs[name] = 0 -- this marks an invalid spell name
		id = nil
	end
	return id
end

-- Add a texture to the icons cache
function MOD:SetIcon(name, texture)
	if name and texture then iconCache[name] = texture end -- add to the in-memory icon cache
end

-- Get a texture from the icons cache, if not there try to get by spell name and cache if found.
-- If not found then look up spell identifier and use it to locate a texture.
function MOD:GetIcon(name, spellID)
	if not name or (name == "none") or (name == "") then return nil end -- make sure valid name string
	
	local override = MOD.db.global.SpellIcons[name] -- check the spell icon override cache for an overriding spell name or numeric id
	if override and (override ~= "none") and (override ~= "") then name = override end -- make sure it is valid too
	
	local id = nil -- next check if the name is a numeric spell id (with or without preceding # sign)
	if string.find(name, "^#%d+") then id = tonumber(string.sub(name, 2)) else id = tonumber(name) end
	if id then -- found what is supposed to be a spell id number
		local n = GetSpellInfo(id)
		if n and n ~= "" then return GetSpellTexture(id) else return nil end -- return icon looked up by spell id (note: no valid name so return nil if not found)
	end
	
	local tex = iconCache[name] -- check the in-memory icon cache which is initialized from player's spell book
	if not tex then -- if not found then try to look it up through spell API
		tex = GetSpellTexture(name)
		if tex and tex ~= "" then
			iconCache[name] = tex -- only cache textures found by looking up the name
		else
			id = spellID or MOD:GetSpellID(name)
			if id then tex = GetSpellTexture(id); if tex == "" then tex = nil end end -- then try based on id
		end
	end
	return tex
end

-- Get a hyperlink for a spell, looking up as a spell identifier if name is unknown
function MOD:GetHyperlink(name)
	if not name or (name == "") then return nil end
	local link = GetSpellLink(name) -- first try to find it based on the name
	if not link then
		local id = MOD:GetSpellID(name)
		if id then link = GetSpellLink(id) end -- then try based on id
	end
	return link
end

-- Add a color to the cache, update values in case they have changed
function MOD:SetColor(name, c)
	if name and c then
		local t = MOD.db.global.SpellColors[name]
		if t then
			t.r, t.g, t.b, t.a = c.r, c.g, c.b, c.a
		else
			MOD.db.global.SpellColors[name] = MOD.CopyColor(c)
		end
	end
end

-- Get a color from the cache of given name, but if not in cache then return nil
function MOD:GetColor(name, spellID)
	local c = nil
	if spellID then c = MOD.db.global.SpellColors["#" .. tostring(spellID)] end -- allow names stored as #spellid
	if not c then c = MOD.db.global.SpellColors[name] end
	return c
end

-- Add a label to the cache but only if different from name
function MOD:SetLabel(name, label)
	if name and label then
		if name == label then MOD.db.global.Labels[name] = nil else MOD.db.global.Labels[name] = label end
	end
end

-- Get a label from the cache, but if not in the cache then return the name
function MOD:GetLabel(name, spellID)
	local label = nil
	if spellID then label = MOD.db.global.Labels["#" .. tostring(spellID)] end -- allow names stored as #spellid
	if not label then label = MOD.db.global.Labels[name] end
	if not label and name and string.find(name, "^#%d+") then
		local id = tonumber(string.sub(name, 2))
		if id then
			local t = GetSpellInfo(id)
			if t then label = t .. " (" .. name .. ")" end -- special case format: spellname (#spellid)
		end
	end
	if not label then label = name end
	return label
end

-- Reset all labels to default values
function MOD:ResetLabelDefaults() table.wipe(MOD.db.global.Labels) end

-- Reset all icons to default values
function MOD:ResetIconDefaults() table.wipe(MOD.db.global.SpellIcons) end

-- Add a sound to the cache
function MOD:SetSound(name, sound) if name then MOD.db.global.Sounds[name] = sound end end

-- Get a sound from the cache, return nil if none specified
function MOD:GetSound(name, spellID)
	local sound = nil
	if spellID then sound = MOD.db.global.Sounds["#" .. tostring(spellID)] end -- allow names stored as #spellid
	if name and not sound then sound = MOD.db.global.Sounds[name] end
	return sound
end

-- Reset all sounds to default values
function MOD:ResetSoundDefaults() table.wipe(MOD.db.global.Sounds) end

-- Add a spell duration to the per-profile cache, always save latest value since could change with haste
-- When the spell id is known, save duration indexed by spell id; otherwise save indexed by name
function MOD:SetDuration(name, spellID, duration)
	if duration == 0 then duration = nil end -- remove cache entry if duration is 0
	if spellID then MOD.db.profile.Durations[spellID] = duration else MOD.db.profile.Durations[name] = duration end
end

-- Get a duration from the cache, but if not in the cache then return 0
function MOD:GetDuration(name, spellID)
	local duration = 0
	if spellID then duration = MOD.db.profile.Durations[spellID] end -- first look for durations indexed by spell id
	if not duration then duration = MOD.db.profile.Durations[name] end -- second look at durations indexed by just name
	if not duration then duration = 0 end
	return duration
end

-- Get localized names for all spells used internally or in built-in conditions, spell ids must be valid
function MOD:SetSpellNameDefaults()
	LSPELL["Freezing Trap"] = GetSpellInfo(1499)
	LSPELL["Ice Trap"] = GetSpellInfo(13809)
	LSPELL["Immolation Trap"] = GetSpellInfo(13795)
	LSPELL["Explosive Trap"] = GetSpellInfo(13813)
	LSPELL["Black Arrow"] = GetSpellInfo(3674)
	LSPELL["Frost Shock"] = GetSpellInfo(8056)
	LSPELL["Flame Shock"] = GetSpellInfo(8050)
	LSPELL["Earth Shock"] = GetSpellInfo(8042)
	LSPELL["Defensive Stance"] = GetSpellInfo(71)
	LSPELL["Berserker Stance"] = GetSpellInfo(2458)
	LSPELL["Battle Stance"] = GetSpellInfo(2457)
	LSPELL["Battle Shout"] = GetSpellInfo(6673)
	LSPELL["Commanding Shout"] = GetSpellInfo(469)
	LSPELL["Flight Form"] = GetSpellInfo(33943)
	LSPELL["Swift Flight Form"] = GetSpellInfo(40120)
	LSPELL["Earthliving Weapon"] = GetSpellInfo(51730)
	LSPELL["Flametongue Weapon"] = GetSpellInfo(8024)
	LSPELL["Frostbrand Weapon"] = GetSpellInfo(8033)
	LSPELL["Rockbiter Weapon"] = GetSpellInfo(8017)
	LSPELL["Windfury Weapon"] = GetSpellInfo(8232)
	LSPELL["Crusader Strike"] = GetSpellInfo(35395)
	LSPELL["Hammer of the Righteous"] = GetSpellInfo(53595)
	LSPELL["Combustion"] = GetSpellInfo(83853)
	LSPELL["Pyroblast"] = GetSpellInfo(11366)
	LSPELL["Living Bomb"] = GetSpellInfo(44457)
	LSPELL["Ignite"] = GetSpellInfo(12654)
end

-- Check if a spell id is known and usable by the player
local function RavenCheckSpellKnown(spellID)
	local name = GetSpellInfo(spellID)
	if not name or name == "" then return false end
	return IsUsableSpell(name)
end

-- Initialize the dispel table which lists what types of debuffs the player can dispel
-- This needs to be updated when the player changes talent specs or learns new spells
function MOD:SetDispelDefaults()
	dispelTypes.Poison = false; dispelTypes.Curse = false; dispelTypes.Magic = false; dispelTypes.Disease = false
	if MOD.myClass == "DRUID" then
		if RavenCheckSpellKnown(88423) then -- Nature's Cure
			dispelTypes.Poison = true; dispelTypes.Curse = true; dispelTypes.Magic = true
		elseif RavenCheckSpellKnown(2782) then -- Remove Corruption
			dispelTypes.Poison = true; dispelTypes.Curse = true
		end
	elseif MOD.myClass == "MONK" then
		if RavenCheckSpellKnown(115451) then -- Internal Medicine
			dispelTypes.Poison = true; dispelTypes.Disease = true; dispelTypes.Magic = true
		elseif RavenCheckSpellKnown(115450) then -- Detox
			dispelTypes.Poison = true; dispelTypes.Disease = true
		end
	elseif MOD.myClass == "PRIEST" then
		if RavenCheckSpellKnown(527) then
			dispelTypes.Magic = true; dispelTypes.Disease = true -- Purify
		elseif RavenCheckSpellKnown(32375) then
			dispelTypes.Magic = true -- Mass Dispel
		end
	elseif MOD.myClass == "MAGE" then
		if RavenCheckSpellKnown(475) then dispelTypes.Curse = true end -- Remove Curse
	elseif MOD.myClass == "PALADIN" then
		if RavenCheckSpellKnown(4987) then -- Cleanse
			dispelTypes.Poison = true; dispelTypes.Disease = true
			if RavenCheckSpellKnown(53551) then dispelTypes.Magic = true end -- Sacred Cleansing
		end
	elseif MOD.myClass == "SHAMAN" then
		if RavenCheckSpellKnown(77130) then
			dispelTypes.Curse = true; dispelTypes.Magic = true -- Purify Spirit
		elseif RavenCheckSpellKnown(51886) then
			dispelTypes.Curse = true -- Cleanse Spirit
		end
	end
	MOD.updateDispels = false
end

-- Return true if the player can dispel the type of debuff on the unit
function MOD:IsDebuffDispellable(n, unit, debuffType)
	if not debuffType then return false end
	if MOD.updateDispels == true then MOD:SetDispelDefaults() end
	local t = dispelTypes[debuffType]
	if not t then return false end
	if (t == "player") and (unit ~= "player") then return false end -- special case for self-only dispels
	if unit == "player" then return true end -- always can dispel debuffs on self
	if UnitIsFriend("player", unit) then return true end -- only can dispel on friendly units
	return false
end

-- Format a time value in seconds, return converted string or nil if invalid index
function MOD:FormatTime(t, index, spaces, upperCase)
	if (index > 0) and (index <= #MOD.Nest_TimeFormatOptions) then
		return MOD.Nest_FormatTime(t, index, spaces, upperCase)
	end
	return nil
end

-- Register a new time format option and return its assigned index
function MOD:RegisterTimeFormat(func) return MOD.Nest_RegisterTimeFormat(func) end

-- Reset the spells in a bar group list filter (should be called during OnEnable, not during OnInitialize)
-- Particularly useful if you are changing localization and need to register spells in a new language
function Raven:ResetBarGroupFilter(bgName, list)
	local listName = nil
	if list == "Buff" then listName = "filterBuffList"
	elseif list == "Debuff" then listName = "filterDebuffList"
	elseif list == "Cooldown" then listName = "filterCooldownList" end
	
	if bgName and listName then
		local bg = MOD.db.profile.BarGroups[bgName]
		if bg then bg[listName] = nil end
	end
end

-- Register a spell in a bar group filter (must be called during OnEnable, not OnInitialize)
-- Raven:RegisterBarGroupFilter(barGroupName, "Buff"|"Debuff"|"Cooldown", spellNameOrID)
-- Note that if the bar group's filter list is linked then the entries will also be added to the associated shared filter list.
function MOD:RegisterBarGroupFilter(bgName, list, spell)
	local listName = nil
	if list == "Buff" then listName = "filterBuffList"
	elseif list == "Debuff" then listName = "filterDebuffList"
	elseif list == "Cooldown" then listName = "filterCooldownList" end
	
	local id = tonumber(spell) -- convert to spell name if provided a number
	if id then spell = GetSpellInfo(id); if spell == "" then spell = nil end end
	
	if bgName and listName and spell then
		local bg = MOD.db.profile.BarGroups[bgName]
		if bg then
			local filterList = bg[listName]
			if not filterList then filterList = {}; bg[listName] = filterList end
			filterList[spell] = spell
		end
	end
end

-- Register a spell table (must be called during OnEnable, not OnInitialize)
-- Table should contain a list of spell names or numeric identifiers (prefered for localization)
-- Return number of unique spells successfully registered.
function MOD:RegisterSpellList(name, spellList, reset)
	local slt, count = MOD.db.global.SpellLists[name], 0
	if not slt then slt = {}; MOD.db.global.SpellLists[name] = slt end
	if reset then table.wipe(slt) end
	for _, spell in pairs(spellList) do
		local n, id = spell, tonumber(spell) -- convert to spell name if provided a number
		if string.find(n, "^#%d+") then
			id = tonumber(string.sub(n, 2)); if id and GetSpellInfo(id) == "" then id = nil end -- support #12345 format for spell ids
		else
			if id then -- otherwise look up the id
				n = GetSpellInfo(id)
				if n == "" then n = nil end -- make sure valid return
			else
				id = MOD:GetSpellID(n)
			end
		end
		if n and id then if not slt[n] then count = count + 1 end slt[n] = id else print(L["Not valid string"](spell)) end -- only spells with valid name and id
	end
	return count
end

-- Register Raven's media entries to LibSharedMedia
function MOD:InitializeMedia(media)
	local mt = media.MediaType.SOUND
	media:Register(mt, "Raven Alert", [[Interface\Addons\Raven\Sounds\alert.ogg]])
	media:Register(mt, "Raven Bell", [[Interface\Addons\Raven\Sounds\bell.ogg]])
	media:Register(mt, "Raven Boom", [[Interface\Addons\Raven\Sounds\boom.ogg]])
	media:Register(mt, "Raven Buzzer", [[Interface\Addons\Raven\Sounds\buzzer.ogg]])
	media:Register(mt, "Raven Chimes", [[Interface\Addons\Raven\Sounds\chime.ogg]])
	media:Register(mt, "Raven Clong", [[Interface\Addons\Raven\Sounds\clong.ogg]])
	media:Register(mt, "Raven Coin", [[Interface\Addons\Raven\Sounds\coin.ogg]])
	media:Register(mt, "Raven Coocoo", [[Interface\Addons\Raven\Sounds\coocoo.ogg]])
	media:Register(mt, "Raven Creak", [[Interface\Addons\Raven\Sounds\creak.ogg]])
	media:Register(mt, "Raven Drill", [[Interface\Addons\Raven\Sounds\drill.ogg]])
	media:Register(mt, "Raven Elephant", [[Interface\Addons\Raven\Sounds\elephant.ogg]])
	media:Register(mt, "Raven Flute", [[Interface\Addons\Raven\Sounds\flute.ogg]])
	media:Register(mt, "Raven Honk", [[Interface\Addons\Raven\Sounds\honk.ogg]])
	media:Register(mt, "Raven Knock", [[Interface\Addons\Raven\Sounds\knock.ogg]])
	media:Register(mt, "Raven Laser", [[Interface\Addons\Raven\Sounds\laser.ogg]])
	media:Register(mt, "Raven Rub", [[Interface\Addons\Raven\Sounds\rubbing.ogg]])
	media:Register(mt, "Raven Slide", [[Interface\Addons\Raven\Sounds\slide.ogg]])
	media:Register(mt, "Raven Squeaky", [[Interface\Addons\Raven\Sounds\squeaky.ogg]])
	media:Register(mt, "Raven Whistle", [[Interface\Addons\Raven\Sounds\whistle.ogg]])
	media:Register(mt, "Raven Zoing", [[Interface\Addons\Raven\Sounds\zoing.ogg]])

	mt = media.MediaType.STATUSBAR
	media:Register(mt, "Raven Black", [[Interface\Addons\Raven\Statusbars\Black.tga]]) 
	media:Register(mt, "Raven CrossHatch", [[Interface\Addons\Raven\Statusbars\CrossHatch.tga]]) 
	media:Register(mt, "Raven DarkAbove", [[Interface\Addons\Raven\Statusbars\DarkAbove.tga]]) 
	media:Register(mt, "Raven DarkBelow", [[Interface\Addons\Raven\Statusbars\DarkBelow.tga]]) 
	media:Register(mt, "Raven Deco", [[Interface\Addons\Raven\Statusbars\Deco.tga]]) 
	media:Register(mt, "Raven Foggy", [[Interface\Addons\Raven\Statusbars\Foggy.tga]]) 
	media:Register(mt, "Raven Glassy", [[Interface\Addons\Raven\Statusbars\Glassy.tga]]) 
	media:Register(mt, "Raven Glossy", [[Interface\Addons\Raven\Statusbars\Glossy.tga]]) 
	media:Register(mt, "Raven Gray", [[Interface\Addons\Raven\Statusbars\Gray.tga]]) 
	media:Register(mt, "Raven Linear", [[Interface\Addons\Raven\Statusbars\Linear.tga]]) 
	media:Register(mt, "Raven Mesh", [[Interface\Addons\Raven\Statusbars\Mesh.tga]]) 
	media:Register(mt, "Raven Minimal", [[Interface\Addons\Raven\Statusbars\Minimal.tga]]) 
	media:Register(mt, "Raven Paper", [[Interface\Addons\Raven\Statusbars\Paper.tga]]) 
	media:Register(mt, "Raven Reticulate", [[Interface\Addons\Raven\Statusbars\Reticulate.tga]]) 
	media:Register(mt, "Raven Reverso", [[Interface\Addons\Raven\Statusbars\Reverso.tga]]) 
	media:Register(mt, "Raven Sleet", [[Interface\Addons\Raven\Statusbars\Sleet.tga]]) 
	media:Register(mt, "Raven Smoke", [[Interface\Addons\Raven\Statusbars\Smoke.tga]]) 
	media:Register(mt, "Raven Smudge", [[Interface\Addons\Raven\Statusbars\Smudge.tga]]) 
	media:Register(mt, "Raven StepIn", [[Interface\Addons\Raven\Statusbars\StepIn.tga]]) 
	media:Register(mt, "Raven StepOut", [[Interface\Addons\Raven\Statusbars\StepOut.tga]]) 
	media:Register(mt, "Raven Strip", [[Interface\Addons\Raven\Statusbars\Strip.tga]]) 
	media:Register(mt, "Raven Stripes", [[Interface\Addons\Raven\Statusbars\Stripes.tga]]) 
	media:Register(mt, "Raven Sunrise", [[Interface\Addons\Raven\Statusbars\Sunrise.tga]]) 
	media:Register(mt, "Raven White", [[Interface\Addons\Raven\Statusbars\White.tga]]) 

	mt = media.MediaType.BORDER
	media:Register(mt, "Raven SingleWhite", [[Interface\Addons\Raven\Borders\SingleWhite.tga]]) 
	media:Register(mt, "Raven SingleGray", [[Interface\Addons\Raven\Borders\SingleGray.tga]]) 
	media:Register(mt, "Raven DoubleWhite", [[Interface\Addons\Raven\Borders\DoubleWhite.tga]]) 
	media:Register(mt, "Raven DoubleGray", [[Interface\Addons\Raven\Borders\DoubleGray.tga]]) 
	media:Register(mt, "Raven Rounded", [[Interface\Addons\Raven\Borders\Rounded.tga]]) 
end

-- Default profile description used to initialize the SavedVariables persistent database
MOD.DefaultProfile = {
	global = {
		Labels = {},					-- cache of labels for actions and spells
		Sounds = {},					-- cache of sounds for actions and spells
		SpellColors = {},				-- cache of colors for actions and spells
		SpellIcons = {},				-- cache of spell icons that override default icons
		SpellIDs = {},					-- cache of spell ids that had to be looked up
		Settings = {},					-- settings table indexed by bar group names
		Defaults = {},					-- default settings for bar group layout, fonts and textures
		FilterBuff = {},				-- shared table of buff filters
		FilterDebuff = {},				-- shared table of debuff filters
		FilterCooldown = {},			-- shared table of cooldown filters
		SharedConditions = {},			-- shared condition settings
		BuffDurations = {},				-- cache of buff durations used for weapon buffs
		DetectInternalCooldowns = true,	-- enable detecting internal cooldowns
		InternalCooldowns = {},			-- descriptors for internal cooldowns
		DetectSpellEffects = true,		-- enable detecting spell effects
		SpellEffects = {},				-- descriptors for spell effects
		SpellLists = {},				-- spell lists
		DefaultBuffColor = MOD.HexColor("8ae234"), -- Green1
		DefaultDebuffColor = MOD.HexColor("fcaf3e"), -- Orange1
		DefaultCooldownColor = MOD.HexColor("fce94f"), -- Yellow1
		DefaultNotificationColor = MOD.HexColor("729fcf"), -- Blue1
		DefaultPoisonColor = MOD.CopyColor(DebuffTypeColor["Poison"]),
		DefaultCurseColor = MOD.CopyColor(DebuffTypeColor["Curse"]),
		DefaultMagicColor = MOD.CopyColor(DebuffTypeColor["Magic"]),
		DefaultDiseaseColor = MOD.CopyColor(DebuffTypeColor["Disease"]),
		ButtonFacadeIcons = true,		-- enable use of ButtonFacade for icons
		ButtonFacadeNormal = true,		-- enable color of normal texture in ButtonFacade
		ButtonFacadeBorder = false,		-- enable color of border texture in ButtonFacade
		SoundChannel = "Master",		-- by default, use the Master sound channel
		HideOmniCC = false,				-- hide OmniCC counts on all bar group icons
		HideBorder = true,				-- hide custom border in all bar groups
		TukuiSkin = true,				-- skin with Tukui borders
		TukuiFont = true,				-- skin with Tukui fonts
		TukuiScale = true,				-- skin Tukui with pixel perfect size and position
		PixelPerfect = false,			-- enable pixel perfect size and position
		RectIcons = false,				-- enable rectangular icons
		DefaultBorderColor = MOD.HexColor("ffffff"), -- icon border color when "None" is selected
		Minimap = { hide = false, minimapPos = 180, radius = 80, }, -- saved DBIcon minimap settings
		InCombatBar = {},				-- shared settings for the in-combat bar
	},
	profile = {
		enabled = true,					-- enable Raven
		hideBlizz = true,				-- enable hiding the Blizzard buff and temp enchant frames
		hideRunes = true,				-- enable hiding the Blizzard runes frame
		muteSFX = false,				-- enable muting of Raven's sound effects
		Durations = {},					-- spell durations (use profile instead of global for better per-character info)
		BarGroups = {},					-- bar group options to be filled in and saved between sessions
		Conditions = {}, 				-- conditions for the player's class
		ButtonFacadeSkin = {},			-- skin settings from ButtonFacade
		InCombatBar = {},				-- settings for the in-combat bar used to cancel buffs in combat
		InCombatBuffs = {},				-- list of buffs that can be cancelled in-combat
		WeaponBuffDurations = {},		-- cache of buff durations used for weapon buffs
	},
}
