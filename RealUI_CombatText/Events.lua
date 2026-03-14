local _, private = ...

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- Message type to color mapping
-- Physical damage: red, Spell damage: purple, Healing: green, Miss types: white
local MESSAGE_TYPE_COLORS = {
    -- Physical damage
    DAMAGE          = Color.Create(1, 0.1, 0.1),
    DAMAGE_CRIT     = Color.Create(1, 0.1, 0.1),
    DAMAGE_SHIELD   = Color.Create(1, 0.1, 0.1),
    SPLIT_DAMAGE    = Color.Create(1, 0.1, 0.1),

    -- Spell damage
    SPELL_DAMAGE      = Color.Create(0.79, 0.3, 0.85),
    SPELL_DAMAGE_CRIT = Color.Create(0.79, 0.3, 0.85),

    -- Healing
    HEAL               = Color.green,
    HEAL_CRIT          = Color.green,
    PERIODIC_HEAL      = Color.green,
    PERIODIC_HEAL_CRIT = Color.green,
    HEAL_ABSORB           = Color.green,
    PERIODIC_HEAL_ABSORB  = Color.green,
    HEAL_CRIT_ABSORB      = Color.green,
    ABSORB_ADDED          = Color.green,

    -- Miss types
    MISS    = Color.white,  DODGE   = Color.white,  PARRY    = Color.white,
    EVADE   = Color.white,  IMMUNE  = Color.white,  DEFLECT  = Color.white,
    BLOCK   = Color.white,  ABSORB  = Color.white,  RESIST   = Color.white,
    SPELL_MISS    = Color.white,  SPELL_DODGE   = Color.white,
    SPELL_PARRY   = Color.white,  SPELL_EVADE   = Color.white,
    SPELL_IMMUNE  = Color.white,  SPELL_DEFLECT = Color.white,
    SPELL_REFLECT = Color.white,  SPELL_BLOCK   = Color.white,
    SPELL_ABSORB  = Color.white,  SPELL_RESIST  = Color.white,
}
private.MESSAGE_TYPE_COLORS = MESSAGE_TYPE_COLORS

-- Scroll area routing: damage → "outgoing", healing → "incoming", other → "notification"
local SCROLL_AREA_ROUTING = {
    -- Damage → outgoing
    DAMAGE          = "outgoing",
    DAMAGE_CRIT     = "outgoing",
    SPELL_DAMAGE      = "outgoing",
    SPELL_DAMAGE_CRIT = "outgoing",
    DAMAGE_SHIELD   = "outgoing",
    SPLIT_DAMAGE    = "outgoing",

    -- Healing → incoming
    HEAL               = "incoming",
    HEAL_CRIT          = "incoming",
    PERIODIC_HEAL      = "incoming",
    PERIODIC_HEAL_CRIT = "incoming",
    HEAL_ABSORB           = "incoming",
    PERIODIC_HEAL_ABSORB  = "incoming",
    HEAL_CRIT_ABSORB      = "incoming",
    ABSORB_ADDED          = "incoming",

    -- Miss types → notification
    MISS    = "notification",  DODGE   = "notification",  PARRY    = "notification",
    EVADE   = "notification",  IMMUNE  = "notification",  DEFLECT  = "notification",
    BLOCK   = "notification",  ABSORB  = "notification",  RESIST   = "notification",
    SPELL_MISS    = "notification",  SPELL_DODGE   = "notification",
    SPELL_PARRY   = "notification",  SPELL_EVADE   = "notification",
    SPELL_IMMUNE  = "notification",  SPELL_DEFLECT = "notification",
    SPELL_REFLECT = "notification",  SPELL_BLOCK   = "notification",
    SPELL_ABSORB  = "notification",  SPELL_RESIST  = "notification",

    -- Energize → notification
    ENERGIZE          = "notification",
    PERIODIC_ENERGIZE = "notification",
}
private.SCROLL_AREA_ROUTING = SCROLL_AREA_ROUTING

-- Crit types that use sticky display and are non-mergeable
local CRIT_TYPES = {
    DAMAGE_CRIT        = true,
    SPELL_DAMAGE_CRIT  = true,
    HEAL_CRIT          = true,
    PERIODIC_HEAL_CRIT = true,
}
private.CRIT_TYPES = CRIT_TYPES

-- Power type string → {color, name} mapping
-- Keyed by string instead of Enum.PowerType for WoW 12 compatibility
local POWER_TYPE_MAP = {
    MANA          = {Color.Create(0, 0, 1),          _G.MANA},
    RAGE          = {Color.Create(1, 0, 0),          _G.RAGE},
    FOCUS         = {Color.Create(1, 0.5, 0.25),     _G.FOCUS},
    ENERGY        = {Color.Create(1, 1, 0),          _G.ENERGY},
    COMBO_POINTS  = {Color.Create(1, 0.96, 0.41),    _G.COMBO_POINTS},
    RUNES         = {Color.Create(0.5, 0.5, 0.5),    _G.RUNES},
    RUNIC_POWER   = {Color.Create(0, 0.82, 1),       _G.RUNIC_POWER},
    SOUL_SHARDS   = {Color.Create(0.5, 0.32, 0.55),  _G.SOUL_SHARDS},
    LUNAR_POWER   = {Color.Create(0.3, 0.52, 0.9),   _G.LUNAR_POWER},
    HOLY_POWER    = {Color.Create(0.95, 0.9, 0.6),   _G.HOLY_POWER},
    MAELSTROM     = {Color.Create(0, 0.5, 1),        _G.MAELSTROM_POWER},
    CHI           = {Color.Create(0.71, 1, 0.92),    _G.CHI_POWER},
    INSANITY      = {Color.Create(0.4, 0, 0.8),      _G.INSANITY_POWER},
    ARCANE_CHARGES = {Color.Create(0.1, 0.1, 0.98),  _G.ARCANE_CHARGES_POWER},
    FURY          = {Color.Create(0.788, 0.259, 0.992), _G.FURY},
    PAIN          = {Color.Create(1, 0.612, 0),      _G.PAIN},
}
private.POWER_TYPE_MAP = POWER_TYPE_MAP


-- Sets for categorizing message types
local DAMAGE_TYPES = {
    DAMAGE = true, DAMAGE_CRIT = true,
    SPELL_DAMAGE = true, SPELL_DAMAGE_CRIT = true,
    DAMAGE_SHIELD = true, SPLIT_DAMAGE = true,
}

local HEAL_TYPES = {
    HEAL = true, HEAL_CRIT = true,
    PERIODIC_HEAL = true, PERIODIC_HEAL_CRIT = true,
    HEAL_ABSORB = true, PERIODIC_HEAL_ABSORB = true,
    HEAL_CRIT_ABSORB = true, ABSORB_ADDED = true,
}

local MISS_TYPES = {
    MISS = true, DODGE = true, PARRY = true, EVADE = true,
    IMMUNE = true, DEFLECT = true, BLOCK = true, ABSORB = true, RESIST = true,
    SPELL_MISS = true, SPELL_DODGE = true, SPELL_PARRY = true,
    SPELL_EVADE = true, SPELL_IMMUNE = true, SPELL_DEFLECT = true,
    SPELL_REFLECT = true, SPELL_BLOCK = true, SPELL_ABSORB = true,
    SPELL_RESIST = true,
}

local ENERGIZE_TYPES = {
    ENERGIZE = true,
    PERIODIC_ENERGIZE = true,
}

-- WoW 12 secret value helpers: GetCurrentCombatTextEventInfo() returns
-- tainted/secret values. We can pass them to string.format and FontString:SetText
-- but cannot do arithmetic, comparisons, or use them as table keys.
-- We store them as-is and let the display layer handle them via SetFormattedText.

-- Dispatch function for WoW 12 COMBAT_TEXT_UPDATE
-- messageType: event payload arg from COMBAT_TEXT_UPDATE (untainted)
-- desc1, desc2: from GetCurrentCombatTextEventInfo() (secret/tainted)
--   Damage:   desc1=amount, desc2=nil
--   Heals:    desc1=source_name, desc2=amount
--   Miss:     desc1=nil, desc2=nil
--   Energize: desc1=amount, desc2=power_type
--   Block/Absorb: desc1=damage_taken, desc2=damage_blocked/absorbed
function private.HandleMessageType(messageType, desc1, desc2)
    if not messageType then
        return
    end

    local scrollType = SCROLL_AREA_ROUTING[messageType]
    if not scrollType then
        return
    end

    local color = MESSAGE_TYPE_COLORS[messageType]
    local isSticky = CRIT_TYPES[messageType] or false

    if DAMAGE_TYPES[messageType] then
        -- desc1 = secret amount
        local eventInfo = {
            messageType = messageType,
            scrollType = scrollType,
            secretAmount = desc1,
            color = color,
            isSticky = isSticky,
            canMerge = false, -- can't merge secret values (no arithmetic)
        }
        private.AddEvent(eventInfo)

    elseif HEAL_TYPES[messageType] then
        -- desc2 = secret amount
        local eventInfo = {
            messageType = messageType,
            scrollType = scrollType,
            secretAmount = desc2,
            color = color,
            isSticky = isSticky,
            canMerge = false,
        }
        private.AddEvent(eventInfo)

    elseif MISS_TYPES[messageType] then
        local resultStr = _G[messageType] or _G[messageType:gsub("SPELL_", "")]
        local eventInfo = {
            messageType = messageType,
            scrollType = scrollType,
            string = resultStr,
            color = color,
            isSticky = false,
            canMerge = false,
        }
        private.AddEvent(eventInfo)

    elseif ENERGIZE_TYPES[messageType] then
        -- desc1 = secret amount, desc2 = secret power type string
        -- Can't use desc2 as table key, just show the amount
        local eventInfo = {
            messageType = messageType,
            scrollType = scrollType,
            secretAmount = desc1,
            color = color,
            isSticky = false,
            canMerge = false,
        }
        private.AddEvent(eventInfo)
    end
end
