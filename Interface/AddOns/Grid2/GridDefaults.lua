--[[
Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors
--]]

local Grid2 = Grid2
local Location = Grid2.CreateLocation
local type, pairs = type, pairs
local defaultFont = "Friz Quadrata TT"

-- Database manipulation functions

function Grid2:DbSetStatusDefaultValue(name, value)
	self.defaults.profile.statuses[name] = value
	if self.db then -- if acedb was already created, copy by hand the defaults to the current profile
		local statuses = self.db.profile.statuses
		statuses[name] = Grid2.CopyTable( value, statuses[name] )
	end
end

function Grid2:DbSetValue(section, name, value)
  self.db.profile[section][name]= value
end

function Grid2:DbGetValue(section, name)
  return self.db.profile[section][name]
end;

function Grid2:DbGetIndicator(name)
    return self.db.profile.indicators[name]
end

function Grid2:DbSetIndicator(name, value)
	if value==nil then
		local map = Grid2.db.profile.statusMap
		if map[name] then map[name]= nil end	
	end
    self.db.profile.indicators[name]= value
end

function Grid2:DbSetMap(indicatorName, statusName, priority)
	local map = self.db.profile.statusMap
	if priority then
		if not map[indicatorName] then
			map[indicatorName] =  {}
		end
		map[indicatorName][statusName] =  priority
	else
		if map[indicatorName] and map[indicatorName][statusName] then
			map[indicatorName][statusName] = nil
		end		
	end	
end

-- Default configurations

local function MakeDefaultsCommon()
	Grid2:DbSetValue( "indicators",  "alpha", {type = "alpha", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "alpha", "range", 99)
	Grid2:DbSetMap( "alpha", "death", 98)
	Grid2:DbSetMap( "alpha", "offline", 97)

	Grid2:DbSetValue( "indicators",  "border", {type = "border", color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "border", "health-low", 55)
	Grid2:DbSetMap( "border", "target", 50)

	Grid2:DbSetValue( "indicators",  "health", {type = "bar", level = 2, location= Location("CENTER"), texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "health", "health-current", 99)

	Grid2:DbSetValue( "indicators",  "health-color", {type = "bar-color"})
	Grid2:DbSetMap( "health-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "heals", {type = "bar", anchorTo = "health", level = 1, location = Location("CENTER"), texture = "Gradient", opacity=0.25, color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "heals", "heals-incoming", 99)

	Grid2:DbSetValue( "indicators",  "heals-color", {type = "bar-color"})
	Grid2:DbSetMap( "heals-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
	Grid2:DbSetMap( "corner-bottom-left", "threat", 99)

	Grid2:DbSetValue( "indicators",  "icon-center", {type = "icon", level = 8, location = Location("CENTER"), size = 14, fontSize = 8,})
	Grid2:DbSetMap( "icon-center", "death", 155)
	Grid2:DbSetMap( "icon-center", "ready-check", 150)

	Grid2:DbSetValue( "indicators",  "icon-right", {type = "icon", level = 8, location = Location("RIGHT",2), size = 12, fontSize = 8,})
	Grid2:DbSetValue( "indicators",  "icon-left", {type = "icon", level = 8, location = Location("LEFT",-2), size = 12, fontSize = 8,})
	Grid2:DbSetMap( "icon-left", "raid-icon-player", 155)
	
	Grid2:DbSetValue( "indicators",  "text-up", {type = "text", level = 7, location = Location("TOP",0,-8) , textlength = 6, fontSize = 8 })
	Grid2:DbSetMap( "text-up", "health-deficit", 50)
	Grid2:DbSetMap( "text-up", "feign-death", 96)
	Grid2:DbSetMap( "text-up", "death", 95)
	Grid2:DbSetMap( "text-up", "offline", 93)
	Grid2:DbSetMap( "text-up", "vehicle", 70)
	Grid2:DbSetMap( "text-up", "charmed", 65)
	Grid2:DbSetValue( "indicators",  "text-up-color", {type = "text-color"})
	Grid2:DbSetMap( "text-up-color", "health-deficit", 50)
	Grid2:DbSetMap( "text-up-color", "feign-death", 96)
	Grid2:DbSetMap( "text-up-color", "death", 95)
	Grid2:DbSetMap( "text-up-color", "offline", 93)
	Grid2:DbSetMap( "text-up-color", "vehicle", 70)
	Grid2:DbSetMap( "text-up-color", "charmed", 65)

	Grid2:DbSetValue( "indicators",  "text-down", {type = "text", level = 6, location = Location("BOTTOM",0,4) , textlength = 6, fontSize = 8 })
	Grid2:DbSetMap( "text-down", "name", 99)
	Grid2:DbSetValue( "indicators",  "text-down-color", {type = "text-color"})
	Grid2:DbSetMap( "text-down-color", "classcolor", 99)	
end

local MakeDefaultsClass
do 
	local class= select(2, UnitClass("player"))
	if class=="SHAMAN" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Riptide-mine", {type = "buff", spellName = 61295, mine = true, color1 = {r=.8,g=.6,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Earthliving", {type = "buff", spellName = 51945, mine= true, color1 = {r=.8,g=1,b=.5,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-EarthShield", {type = "buff", spellName = 974, color1 = {r=.8,g=.8,b=.2,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-EarthShield-mine", {type = "buff", spellName = 974, mine = true, colorCount = 2, color1 = {r=.9,g=.9,b=.4,a=1}, color2 = {r=.9,g=.9,b=.4,a=1} })
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
		Grid2:DbSetMap( "corner-top-left", "buff-Riptide-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "square", level = 9, location= Location("TOP"), size = 5,})
		Grid2:DbSetMap( "side-top", "buff-Earthliving", 89)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "square", level = 9, location= Location("TOPRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-top-right", "buff-EarthShield-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-EarthShield", 89)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="DRUID" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Lifebloom-mine", {type = "buff", spellName = 33763, mine = true, colorCount = 3, color1 = {r=.2,g=.7,b=.2,a=1}, color2 = {r=.6,g=.9,b=.6,a=1}, color3 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Rejuvenation-mine", {type = "buff", spellName = 774, mine = true, color1 = {r=1,g=0,b=.6,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Regrowth-mine", {type = "buff", spellName = 8936, mine = true, color1 = {r=.5,g=1,b=0,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-WildGrowth-mine", {type = "buff", spellName = 48438, mine = true, color1 = {r=0.2,g=.9,b=.2,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "text", level = 9, location = Location("TOPLEFT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-left", "buff-Lifebloom-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-left-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-left-color", "buff-Lifebloom-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "text", level = 9, location = Location("TOP"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "side-top", "buff-Regrowth-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top-color", {type = "text-color"})
		Grid2:DbSetMap( "side-top-color", "buff-Regrowth-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "text", level = 9, location = Location("TOPRIGHT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-right", "buff-Rejuvenation-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-right-color", "buff-Rejuvenation-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 9, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-WildGrowth-mine", 99)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="PALADIN" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-BeaconOfLight", {type = "buff", spellName = 53563, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BeaconOfLight-mine", {type = "buff", spellName = 53563, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-DivineShield-mine", {type = "buff", spellName = 642, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-DivineProtection-mine", {type = "buff", spellName = 498, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfProtection-mine", {type = "buff", spellName = 1022, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfSalvation", {type = "buff", spellName = 1038, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfSalvation-mine", {type = "buff", spellName = 1038, mine = true, color1 = {r=.8,g=.8,b=.7,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-Forbearance", {type = "debuff", spellName = 25771, color1 = {r=1,g=0,b=0,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "text", level = 9, location = Location("TOPLEFT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-left", "buff-BeaconOfLight", 99)
		Grid2:DbSetMap( "corner-top-left", "buff-BeaconOfLight-mine", 89)
		Grid2:DbSetValue( "indicators",  "corner-top-left-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-left-color", "buff-BeaconOfLight", 99)
		Grid2:DbSetMap( "corner-top-left-color", "buff-BeaconOfLight-mine", 89)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "text", level = 9, location = Location("TOP"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "side-top", "buff-FlashOfLight-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top-color", {type = "text-color"})
		Grid2:DbSetMap( "side-top-color", "buff-FlashOfLight-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "text", level = 9, location = Location("TOPRIGHT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-right", "buff-DivineShield-mine", 97)
		Grid2:DbSetMap( "corner-top-right", "buff-DivineProtection-mine", 95)
		Grid2:DbSetMap( "corner-top-right", "buff-HandOfProtection-mine", 93)
		Grid2:DbSetValue( "indicators",  "corner-top-right-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-right-color", "buff-DivineShield-mine", 97)
		Grid2:DbSetMap( "corner-top-right-color", "buff-DivineProtection-mine", 95)
		Grid2:DbSetMap( "corner-top-right-color", "buff-HandOfProtection-mine", 93)
		Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
		Grid2:DbSetMap( "corner-bottom-left", "buff-HandOfSalvation", 101)
		Grid2:DbSetMap( "corner-bottom-left", "buff-HandOfSalvation-mine", 100)
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "icon", level = 8, location = Location("BOTTOMRIGHT"), size = 12, fontSize = 8,})
		Grid2:DbSetMap( "corner-bottom-right", "debuff-Forbearance", 99)
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="PRIEST" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-DivineAegis", {type = "buff", spellName = 47509, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-InnerFire", {type = "buff", spellName = 588, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-PowerWordShield", {type = "buff", spellName = 17, color1 = {r=0,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Renew-mine", {type = "buff", spellName = 139, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-SpiritOfRedemption", {type = "buff", spellName = 27827, blinkThreshold = 3, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Grace-mine", {type = "buff", spellName = 77613, mine = true,
						colorCount = 3, color1 = {r=.6,g=.6,b=.6,a=1}, color2 = {r=.8,g=.8,b=.8,a=1}, color3 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-PrayerOfMending-mine", {type = "buff", spellName = 33076, mine = true,
						colorCount = 5, color1 = {r=1,g=.2,b=.2,a=1}, color2 = {r=1,g=1,b=.4,a=.4}, 
						color3 = {r=1,g=.6,b=.6,a=1}, color4 = {r=1,g=.8,b=.8,a=1}, color5 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-WeakenedSoul", {type = "debuff", spellName = 6788, color1 = {r=0,g=.2,b=.9,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
		Grid2:DbSetMap( "corner-top-left", "buff-Renew-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "square", level = 9, location = Location("TOPRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-top-right", "buff-PowerWordShield", 99)
		Grid2:DbSetMap( "corner-top-right", "debuff-WeakenedSoul", 89)
		Grid2:DbSetValue( "indicators",  "side-bottom", {type = "square", level = 9, location = Location("BOTTOM"), size = 5,})
		Grid2:DbSetMap( "side-bottom", "buff-DivineAegis", 79)
		Grid2:DbSetMap( "side-bottom", "buff-InnerFire", 79)
		Grid2:DbSetMap( "icon-right", "buff-PrayerOfMending-mine", 99)
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="MONK" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "indicators", "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
		Grid2:DbSetValue( "indicators", "side-top", {type = "square", level = 9, location= Location("TOP"), size = 5,})
		Grid2:DbSetValue( "indicators", "corner-top-right", {type = "square", level = 9, location= Location("TOPRIGHT"), size = 5,})
		Grid2:DbSetValue( "statuses", "buff-EnvelopingMist-mine", {type = "buff", spellName = 124682, mine = true, color1 = {r=0.2,g=1,b=0.2,a=1}})
		Grid2:DbSetValue( "statuses", "buff-RenewingMist-mine", {type = "buff", spellName = 119611, mine = true, useSpellId = true, color1 = {r=0.5,g=1,b=0,a=1}})
		Grid2:DbSetValue( "statuses", "buff-LifeCocoon", {type = "buff", spellName = 116849, color1 = {r=0.4,g=0,b=0.8,a=1}})
		Grid2:DbSetMap( "corner-top-left", "buff-EnvelopingMist-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-RenewingMist-mine", 99)
		Grid2:DbSetMap( "side-top", "buff-LifeCocoon", 99)
		Grid2:DbSetMap( "border", "debuff-Poison" , 90)
		Grid2:DbSetMap( "border", "debuff-Disease", 80)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="MAGE" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses", "buff-FocusMagic", {type = "buff", spellName = 54646, color1 = {r=.11,g=.22,b=.33,a=1}})
		Grid2:DbSetValue( "statuses", "buff-IceArmor-mine", {type = "buff", spellName = 7302, mine = true, missing = true, color1 = {r=.2,g=.4,b=.4,a=1}})
		Grid2:DbSetValue( "statuses", "buff-IceBarrier-mine", {type = "buff", spellName = 11426, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "indicators", "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-FocusMagic", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
		Grid2:DbSetMap( "border", "debuff-Curse", 30)
	end elseif class=="ROGUE" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Evasion-mine", {type = "buff", spellName = 5277, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetMap( "side-bottom", "buff-Evasion-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARLOCK" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "indicators", "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetValue( "statuses", "buff-ShadowWard-mine", {type = "buff", spellName = 6229, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses", "buff-SoulLink-mine", {type = "buff", spellName = 19028, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses", "buff-DemonArmor-mine", {type = "buff", spellName = 687, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses", "buff-FelArmor-mine", {type = "buff", spellName = 28176, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetMap( "corner-bottom-right", "buff-ShadowWard-mine", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-SoulLink-mine", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-FelArmor-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARRIOR" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Vigilance", {type = "buff", spellName = 50720, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BattleShout", {type = "buff", spellName = 6673, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-ShieldWall", {type = "buff", spellName = 871, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-LastStand", {type = "buff", spellName = 12975, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-CommandingShout", {type = "buff", spellName = 469, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-Vigilance", 99)
		Grid2:DbSetValue( "indicators",  "side-bottom", {type = "square", level = 9, location = Location("BOTTOM"), size = 5,})
		Grid2:DbSetMap( "side-bottom", "buff-BattleShout", 89)
		Grid2:DbSetMap( "side-bottom", "buff-CommandingShout", 79)
		Grid2:DbSetMap( "corner-bottom-right", "buff-LastStand", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-ShieldWall", 89)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end else MakeDefaultsClass= function() end end
end

-- Plugins can hook this function to initialize or update values in database
function Grid2:UpdateDefaults()

	local version= Grid2:DbGetValue("versions","Grid2") or 0
	if version>=5 then return end
	if version==0 then
		MakeDefaultsCommon()
		MakeDefaultsClass()
	else
		local health = Grid2:DbGetValue("indicators", "health")
		local heals  = Grid2:DbGetValue("indicators", "heals")
		if version<2 then
			-- Upgrade health&heals indicator to version 2
			if health and heals then heals.parentBar = "health"	end
		end
		if version<4 then
			-- Upgrade health&heals indicator to version 4
			if heals and heals.parentBar then
				heals.anchorTo = heals.parentBar
				heals.parentBar = nil
			end
			if health and health.childBar then
				health.childBar = nil
			end
		end
		if version<5 then
			-- Upgrade buffs and debuffs groups statuses
			for _, status in pairs(self.db.profile.statuses) do
				if status.auras and (status.type == "buff" or status.type=="debuff") then
					status.type = status.type .. "s"  -- Convert type: buff -> buffs , debuff -> debuffs
					if status.type == "debuffs" then
						status.useWhiteList = true
					end	
				end
			end
		end
	end
	-- Set database version
	Grid2:DbSetValue("versions","Grid2",5)

end
