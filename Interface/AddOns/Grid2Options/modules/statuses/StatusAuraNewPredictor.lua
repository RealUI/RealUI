-- Buffs & Debuffs predictors used by AceGUI-3.0-Search-EditBox
local ipairs = ipairs
local strlower = string.lower
local strmatch = string.match
local GetSpellInfo = GetSpellInfo

-- translated&colorized players class names table
local classNames
 
-- AuraPredictor class
local AuraPredictor = {}
AuraPredictor.__index = AuraPredictor

function AuraPredictor:new( type, spells )
	local e = setmetatable({}, self)
	e.type = type
	e.spells = spells
	return e
end

function AuraPredictor:Initialize()
	classNames = { [""] = "" }
	for class,translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local c = RAID_CLASS_COLORS[class]
		classNames[class] = string.format(", |cff%.2x%.2x%.2x%s|r ", c.r*255, c.g*255, c.b*255, translation) 
	end
	AuraPredictor.OnInitialize = nil -- Only one initialization for all instances
end

function AuraPredictor:GetValues( text, values, max )
	-- The user can optionally type a prefix, for example: "Druid>Rejuvenation", 
	-- so we have to remove the prefix if exists, valid prefix separators: "@#>"
	local _, suffix = strmatch(text, "^(.-[@#>])(.*)$")
	text = suffix or text
	local spellID = tonumber(text)
	if spellID and GetSpellInfo(spellID) then
		-- if the user has typed a number, return directly this spell info
		local spellName,_,spellIcon = GetSpellInfo(spellID)
		values[spellID] = self:GetSpellDescription(spellID, spellName, spellIcon, "")
	elseif text ~= "" then
		max = 12
		text = strlower(suffix or text)
		-- search buffs or debuffs
		for className,spells in pairs(self.spells) do
			max = self:GetTableValues(spells, values, text, max, className )
			if max == 0 then return end
		end
		-- search raid-debuffs if module is available
		if self.type=="debuff" and Grid2Options.GetRaidDebuffsTable then
			local module = (Grid2Options:GetRaidDebuffsTable())["Warlords of Draenor"]
			for _,instance in pairs(module) do
				for bossName,boss in pairs(instance) do
					bossName = string.gsub(bossName, "%[.-%]", "")
					max = self:GetTableValues(boss, values, text, max, bossName, true)
					if max==0 then return end
				end
			end
		end
	end
end

-- Validation function, its tricky:
-- key param: two posible types: number | string
--   number > Its a SpellID,  string > Prefixed spellID, ex: "Mage>10234"
-- text param: spellID or spellName and could have a prefix too, ex:
--   "Riptide" | "12304" | "Druid>Rejuvenation" | "Druid>102345"
-- returns key or text: a prefix is added if exists: text prefix has priority over key prefix.
-- If a number is provided in text param, validates the value checking if it is a valid spell
function AuraPredictor:GetValue( text, key )
	local prefix, suffix = strmatch(text, "^(.-[@#>])(.*)$")
	if key then
		if prefix then
			return prefix .. ( type(key)=="string" and strmatch(key, "^.->(.*)$") or key )
		else
			return key
		end	
	else
		key = suffix and tonumber(suffix) or tonumber(text)
		if not key or GetSpellInfo(key) then
			return text
		end	
	end	
end

function AuraPredictor:GetHyperlink( key )
	key = type(key) == "string" and strmatch(key, "^.->(.*)$") or key
	return "spell:"..key
end

function AuraPredictor:GetTableValues(spells, values, text, max, category, isBoss)
	for _, spellID in ipairs(spells) do
		local spellName,_,spellIcon = GetSpellInfo(spellID)
		if spellName and strfind(strlower(spellName), text, 1, true)==1 then
			local key = self:GetSpellKey(spellID, category, isBoss)
			values[key] = self:GetSpellDescription(spellID, spellName, spellIcon, category, isBoss)
			max = max - 1; if max == 0 then break end
		end
	end
	return max
end

function AuraPredictor:GetSpellKey(spellID, category)
	if self.type=="debuff" then
		local key = LOCALIZED_CLASS_NAMES_MALE[category] or category
		return key and key~="" and key..">"..spellID or spellID
	else
		return spellID
	end	
end

function AuraPredictor:GetSpellDescription(spellID, spellName, spellIcon, className, isBoss)
	className = isBoss and string.format( ", |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t|cFFff0000%s|r ", className) or classNames[className]
	return string.format( "|T%s:0|t%s %s, %s%d|r", spellIcon, spellName, className, GRAY_FONT_COLOR_CODE, spellID )
end

-- Registering EditBoxGrid2Buffs and EditBoxGrid2Debuffs to use with AceConfigTable dialogControl
LibStub("AceGUI-3.0-Search-EditBox"):Register( "Grid2Buffs",    AuraPredictor:new( "buff",   Grid2Options.PlayerBuffs   ) )
LibStub("AceGUI-3.0-Search-EditBox"):Register( "Grid2Debuffs",  AuraPredictor:new( "debuff", Grid2Options.PlayerDebuffs ) )
