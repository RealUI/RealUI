local _, private = ...

-- Lua Globals --
-- luacheck: globals floor type pcall tonumber

local RealUI = _G.RealUI

if not private.oUF then
    private.oUF = _G.oUF
end


----====####$$$$%%%%$$$$####====----
--              Math              --
----====####$$$$%%%%$$$$####====----
function RealUI.Round(value, places)
    local mult = 10 ^ (places or 0)
    return floor(value * mult + 0.5) / mult
end
function RealUI.GetSafeVals(min, max)
    if max == 0 then
        return 0
    else
        return min / max
    end
end


----====####$$$$%%%%%$$$$####====----
--              Color              --
----====####$$$$%%%%%$$$$####====----
local hexColor = "%02x%02x%02x"
function RealUI.GetColorString(red, green, blue)
    if type(red) == "table" then
        if red.r and red.g and red.b then
            red, green, blue = red.r, red.g, red.b
        else
            red, green, blue = red[1], red[2], red[3]
        end
    end

    return hexColor:format(red * 255, green * 255, blue * 255)
end

function RealUI.GetDurabilityColor(curDura, maxDura)
    local low, mid, high = _G.Aurora.Color.red, _G.Aurora.Color.yellow, _G.Aurora.Color.green
    return private.oUF:RGBColorGradient(curDura, maxDura or 1, low.r,low.g,low.b, mid.r,mid.g,mid.b, high.r,high.g,high.b)
end


----====####$$$$%%%%%$$$$####====----
--          Miscellaneous          --
----====####$$$$%%%%%$$$$####====----
local scanningTooltip = _G.CreateFrame("GameTooltip", "RealUIScanningTooltip", _G.UIParent, "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")

local cache = {}
local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
function RealUI.GetItemLevel(itemLink)
    local iLvl = _G.GetDetailedItemLevelInfo(itemLink)
    if iLvl and iLvl > 0 then
        return iLvl
    end

    if cache[itemLink] then
        return cache[itemLink]
    end

    scanningTooltip:ClearLines()
    local success = pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
    if not success then
        return 0
    end

    for i = 1, 5 do
        local l = _G["RealUIScanningTooltipTextLeft"..i]
        if l and l:GetText() then
            iLvl = tonumber(l:GetText():match(itemLevelPattern))
            if iLvl then
                cache[itemLink] = iLvl
                break
            end
        end
    end

    return iLvl or 0
end

function RealUI.GetOptions(modName, path)
    local options = RealUI:GetModule(modName).db
    if path then
        for i = 1, #path do
            options = options[path[i]]
        end
    end
    return options
end

----====####$$$$%%%%%$$$$####====----
--    Spec compatibility layer     --
----====####$$$$%%%%%$$$$####====----
-- Taken from LIVE: /run for classID = 1, 12 do for specIndex = 1, _G.GetNumSpecializationsForClassID(classID) do print(_G.GetSpecializationInfoForClassID(classID, specIndex)) end end
local classicSpecs = {
    [71] = {71, "Arms", "A battle-hardened master of weapons, using mobility and overpowering attacks to strike her opponents down.\n\nPreferred Weapon: Two-Handed Axe, Mace, Sword", 132355, "DAMAGER", true, false},
    [72] = {72, "Fury", "A furious berserker unleashing a flurry of attacks to carve her opponents to pieces.\n\nPreferred Weapons: Dual Two-Handed Axes, Maces, Swords", 132347, "DAMAGER", false, false},
    [73] = {73, "Protection", "A stalwart protector who uses a shield to safeguard herself and her allies.\n\nPreferred Weapon: Axe, Mace, Sword, and Shield", 132341, "TANK", false, false},
    [65] = {65, "Holy", "Invokes the power of the Light to heal and protect allies and vanquish evil from the darkest corners of the world.\n\nPreferred Weapon: Sword, Mace, and Shield", 135920, "HEALER", false, false},
    [66] = {66, "Protection", "Uses Holy magic to shield herself and defend allies from attackers.\n\nPreferred Weapon: Sword, Mace, Axe, and Shield", 236264, "TANK", false, false},
    [70] = {70, "Retribution", "A righteous crusader who judges and punishes opponents with weapons and Holy magic.\n\nPreferred Weapon: Two-Handed Sword, Mace, Axe", 135873, "DAMAGER", true, false},
    [253] = {253, "Beast Mastery", "A master of the wild who can tame a wide variety of beasts to assist her in combat.\n\nPreferred Weapon: Bow, Crossbow, Gun", 461112, "DAMAGER", true, false},
    [254] = {254, "Marksmanship", "A master sharpshooter who excels in bringing down enemies from afar.\n\nPreferred Weapon: Bow, Crossbow, Gun", 236179, "DAMAGER", false, false},
    [255] = {255, "Survival", "An adaptive ranger who favors using explosives, animal venom, and coordinated attacks with their bonded beast.\n\nPreferred Weapon: Polearm, Staff", 461113, "DAMAGER", false, true},
    [259] = {259, "Assassination", "A deadly master of poisons who dispatches victims with vicious dagger strikes.\n\nPreferred Weapons: Daggers", 236270, "DAMAGER", true, false},
    [260] = {260, "Outlaw", "A ruthless fugitive who uses agility and guile to stand toe-to-toe with enemies.\n\nPreferred Weapons: Axes, Maces, Swords, Fist Weapons", 236286, "DAMAGER", false, false},
    [261] = {261, "Subtlety", "A dark stalker who leaps from the shadows to ambush her unsuspecting prey.\n\nPreferred Weapons: Daggers", 132320, "DAMAGER", false, false},
    [256] = {256, "Discipline", "Uses magic to shield allies from taking damage as well as heal their wounds.\n\nPreferred Weapon: Staff, Wand, Dagger, Mace", 135940, "HEALER", true, false},
    [257] = {257, "Holy", "A versatile healer who can reverse damage on individuals or groups and even heal from beyond the grave.\n\nPreferred Weapon: Staff, Wand, Dagger, Mace", 237542, "HEALER", false, false},
    [258] = {258, "Shadow", "Uses sinister Shadow magic and terrifying Void magic to eradicate enemies.\n\nPreferred Weapon: Staff, Wand, Dagger, Mace", 136207, "DAMAGER", false, false},
    [250] = {250, "Blood", "A dark guardian who manipulates and corrupts life energy to sustain herself in the face of an enemy onslaught.\n\nPreferred Weapon: Two-Handed Axe, Mace, Sword", 135770, "TANK", false, false},
    [251] = {251, "Frost", "An icy harbinger of doom, channeling runic power and delivering vicious weapon strikes.\n\nPreferred Weapons: Dual Axes, Maces, Swords", 135773, "DAMAGER", false, false},
    [252] = {252, "Unholy", "A master of death and decay, spreading infection and controlling undead minions to do her bidding.\n\nPreferred Weapon: Two-Handed Axe, Mace, Sword", 135775, "DAMAGER", true, false},
    [262] = {262, "Elemental", "A spellcaster who harnesses the destructive forces of nature and the elements.\n\nPreferred Weapon: Mace, Dagger, and Shield", 136048, "DAMAGER", true, false},
    [263] = {263, "Enhancement", "A totemic warrior who strikes foes with weapons imbued with elemental power.\n\nPreferred Weapons: Dual Axes, Maces, Fist Weapons", 237581, "DAMAGER", false, true},
    [264] = {264, "Restoration", "A healer who calls upon ancestral spirits and the cleansing power of water to mend allies' wounds.\n\nPreferred Weapon: Mace, Dagger, and Shield", 136052, "HEALER", false, false},
    [62] = {62, "Arcane", "Manipulates raw Arcane magic, destroying enemies with overwhelming power.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 135932, "DAMAGER", false, false},
    [63] = {63, "Fire", "Focuses the pure essence of Fire magic, assaulting enemies with combustive flames.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 135810, "DAMAGER", false, false},
    [64] = {64, "Frost", "Freezes enemies in their tracks and shatters them with Frost magic.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 135846, "DAMAGER", true, false},
    [265] = {265, "Affliction", "A master of shadow magic who specializes in drains and damage-over-time spells.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 136145, "DAMAGER", true, false},
    [266] = {266, "Demonology", "A commander of demons who twists the souls of her army into devastating power.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 136172, "DAMAGER", false, false},
    [267] = {267, "Destruction", "A master of chaos who calls down fire to burn and demolish enemies.\n\nPreferred Weapon: Staff, Wand, Dagger, Sword", 136186, "DAMAGER", false, false},
    [268] = {268, "Brewmaster", "A sturdy brawler who uses unpredictable movement and mystical brews to avoid damage and protect allies.\n\nPreferred Weapon: Staff, Polearm", 608951, "TANK", false, false},
    [270] = {270, "Mistweaver", "A healer who masters the mysterious art of manipulating life energies aided by the wisdom of the Jade Serpent.\n\nPreferred Weapon: Staff, Mace, Sword", 608952, "HEALER", false, false},
    [269] = {269, "Windwalker", "A martial artist without peer who pummels foes with hands and fists.\n\nPreferred Weapons: Fist Weapons, Axes, Maces, Swords", 608953, "DAMAGER", true, false},
    [102] = {102, "Balance", "Can shapeshift into a powerful Moonkin, balancing the power of Arcane and Nature magic to destroy enemies.\n\nPreferred Weapon: Staff, Dagger, Mace", 136096, "DAMAGER", true, true},
    [103] = {103, "Feral", "Takes on the form of a great cat to deal damage with bleeds and bites.\n\nPreferred Weapon: Staff, Polearm", 132115, "DAMAGER", false, true},
    [104] = {104, "Guardian", "Takes on the form of a mighty bear to absorb damage and protect allies.\n\nPreferred Weapon: Staff, Polearm", 132276, "TANK", false, false},
    [105] = {105, "Restoration", "Channels powerful Nature magic to regenerate and revitalize allies.\n\nPreferred Weapon: Staff, Dagger, Mace", 136041, "HEALER", false, false},
    [577] = {577, "Havoc", "A brooding master of warglaives and the destructive power of Fel magic.\n\nPreferred Weapons: Warglaives, Swords, Axes, Fist Weapons", 1247264, "DAMAGER", true, false},
    [581] = {581, "Vengeance", "Embraces the demon within to incinerate enemies and protect their allies.\n\nPreferred Weapons: Warglaives, Swords, Axes, Fist Weapons", 1247265, "TANK", false, false}
}

local classicSpecToClass = {
    [71] = "WARRIOR",
    [72] = "WARRIOR",
    [73] = "WARRIOR",
    [65] = "PALADIN",
    [66] = "PALADIN",
    [70] = "PALADIN",
    [253] = "HUNTER",
    [254] = "HUNTER",
    [255] = "HUNTER",
    [259] = "ROGUE",
    [260] = "ROGUE",
    [261] = "ROGUE",
    [256] = "PRIEST",
    [257] = "PRIEST",
    [258] = "PRIEST",
    [250] = "DEATHKNIGHT",
    [251] = "DEATHKNIGHT",
    [252] = "DEATHKNIGHT",
    [262] = "SHAMAN",
    [263] = "SHAMAN",
    [264] = "SHAMAN",
    [62] = "MAGE",
    [63] = "MAGE",
    [64] = "MAGE",
    [265] = "WARLOCK",
    [266] = "WARLOCK",
    [267] = "WARLOCK",
    [268] = "MONK",
    [270] = "MONK",
    [269] = "MONK",
    [102] = "DRUID",
    [103] = "DRUID",
    [104] = "DRUID",
    [105] = "DRUID",
    [577] = "DEMONHUNTER",
    [581] = "DEMONHUNTER"
}

local classicClassSpecs = {
    [1] = {classicSpecs[71], classicSpecs[72], classicSpecs[73]}, -- Warrior
    [2] = {classicSpecs[65], classicSpecs[66], classicSpecs[70]}, -- Paladin
    [3] = {classicSpecs[253], classicSpecs[254], classicSpecs[255]}, -- Hunter
    [4] = {classicSpecs[259], classicSpecs[260], classicSpecs[261]}, -- Rogue
    [5] = {classicSpecs[256], classicSpecs[257], classicSpecs[258]}, -- Priest
    [6] = {classicSpecs[250], classicSpecs[251], classicSpecs[252]}, -- Death Knight
    [7] = {classicSpecs[262], classicSpecs[263], classicSpecs[264]}, -- Shaman
    [8] = {classicSpecs[62], classicSpecs[63], classicSpecs[64]}, -- Mage
    [9] = {classicSpecs[265], classicSpecs[266], classicSpecs[267]}, -- Warlock
    [10] = {classicSpecs[268], classicSpecs[270], classicSpecs[269]}, -- Monk
    [11] = {classicSpecs[102], classicSpecs[103], classicSpecs[104], classicSpecs[105]}, -- Druid
    [12] = {classicSpecs[577], classicSpecs[581]} -- Demon Hunter
}

function RealUI.GetSpecialization()
    return RealUI.compatRelease and _G.GetSpecialization() or RealUI.charInfo.specs.current.index
end
function RealUI.GetLootSpecialization()
    return RealUI.compatRelease and _G.GetLootSpecialization() or RealUI.charInfo.specs.current.id
end
function RealUI.GetNumSpecializations(isInspect, isPet)
    if RealUI.compatRelease then return _G.GetNumSpecializations(isInspect, isPet) end
    local _, _, classID = _G.UnitClass("player")
    return RealUI.GetNumSpecializationsForClassID(classID)
end
function RealUI.GetNumSpecializationsForClassID(classID)
    if RealUI.compatRelease then return _G.GetNumSpecializationsForClassID(classID) end
    return classicClassSpecs[classID] and #classicClassSpecs[classID] or 0
end
function RealUI.GetSpecializationInfoForClassID(classID, specIndex)
    if RealUI.compatRelease then return _G.GetSpecializationInfoForClassID(classID, specIndex) end
    return _G.unpack(classicClassSpecs[classID][specIndex])
end
function RealUI.GetSpecializationInfo(specIndex, isInspect, isPet, inspectTarget, sex)
    if RealUI.compatRelease then return _G.GetSpecializationInfo(specIndex, isInspect, isPet, inspectTarget, sex) end
    local _, _, classID = _G.UnitClass("player")
    return RealUI.GetSpecializationInfoForClassID(classID, specIndex)
end
function RealUI.GetSpecializationInfoByID(id)
    if RealUI.compatRelease then return _G.GetSpecializationInfoByID(id) end
    local _, name, description, icon, role = _G.unpack(classicSpecs[id])
    return id, name, description, icon, role, classicSpecToClass[id]
end
function RealUI.GetInspectSpecialization(unit)
    if RealUI.compatRelease then return _G.GetInspectSpecialization(unit) end
    if "player" == unit then
        return RealUI.charInfo.specs.current
    end
    local _, _, classID = _G.UnitClass(unit)
    -- Simply return the first spec ID
    local id = _G.unpack(classicClassSpecs[classID][1])
    return id
end
