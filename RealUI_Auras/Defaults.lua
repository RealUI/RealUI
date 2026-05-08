-- Defaults.lua: AceDB default profile for RealUI_Auras
-- Translated from RealUI/RealUI/Core/AddonData/Raven.lua
-- Raven-internal fields (configuration, i_*, pointX/Y, bars, backdrop*, border*,
-- hideSpark, barColors, iconColors, minimumDuration, minimumTimeLeft, labelInset,
-- anchorPoint) are dropped or mapped to the new schema.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")

AurasAddon.defaults = {
    profile = {
        groups = {
            -----------------------------------------------------------------
            -- 1. Buffs — player buffs, top-right buff strip
            --    Source: profiles.RealUI.BarGroups.Buffs
            --    Anchor: RealUIPositionersBuffs (positioner frame)
            -----------------------------------------------------------------
            Buffs = {
                disabled            = true,
                name                = "Buffs",
                unit                = "player",
                detectBuffs         = true,
                detectDebuffs       = false,
                detectBuffsCastBy   = "anyone",

                anchorFrame         = "RealUIPositionersBuffs",
                anchorX             = -3,   -- small inset from right edge of positioner
                anchorY             = -3,   -- small offset down from top of positioner

                iconSize            = 30,   -- i_iconSize
                spacingX            = 3,    -- i_spacingX
                spacingY            = 15,   -- i_spacingY
                wrap                = 20,
                maxBars             = 40,
                growDirection       = false,
                iconAlign           = "RIGHT",
                iconInset           = -18,
                iconOffset          = 5,

                hideBar             = true,
                barWidth            = 20,   -- i_barWidth
                barHeight           = 5,    -- i_barHeight
                hideLabel           = true,

                timeAlign           = "LEFT",
                timeOffset          = 18,
                timeInset           = 16,
                timeFormat          = 23,

                showNoDuration      = true,
                checkDuration       = true,
                filterDuration      = 60,
                checkTimeLeft       = true,
                filterTimeLeft      = 60,
                filterBuffTable     = "ClassBuffs",
                filterDebuffTable   = "ClassBuffs",
                filterCooldownTable = "ClassBuffs",

                sor                 = "T",
                timeSort            = false,
                reverseSort         = true,
            },

            -----------------------------------------------------------------
            -- 2. TargetBuffs — target buffs beside target frame
            --    Source: profiles.RealUI.BarGroups.TargetBuffs
            --    Anchor: RealUITargetFrame
            -----------------------------------------------------------------
            TargetBuffs = {
                disabled            = true,
                name                = "TargetBuffs",
                unit                = "target",
                detectBuffs         = true,
                detectDebuffs       = false,
                detectBuffsCastBy   = "anyone",
                detectBuffsMonitor  = "target",

                parentFrame         = "RealUITargetFrame",
                anchorX             = 0,
                anchorY             = -2,

                iconSize            = 30,   -- i_iconSize
                spacingX            = 3,    -- i_spacingX
                spacingY            = 15,   -- i_spacingY
                wrap                = 6,
                maxBars             = 12,
                growDirection       = false,
                iconAlign           = "RIGHT",
                iconInset           = -18,
                iconOffset          = 5,

                hideBar             = true,
                barWidth            = 20,   -- i_barWidth
                barHeight           = 5,    -- i_barHeight
                hideLabel           = true,

                timeAlign           = "LEFT",
                timeOffset          = 18,
                timeInset           = 16,
                timeFormat          = 23,

                showNoDuration      = true,
                filterBuffSpells    = true,
                filterBuffTypes     = false,
                filterBuffTable     = "ClassBuffs",
                filterBuffList      = {},
                filterDebuffTable   = "PlayerExclusions",
                filterCooldownTable = "ClassBuffs",

                sor                 = "T",
                timeSort            = false,
                reverseSort         = false,
                playerSort          = true,

                desaturate          = true,
                desaturateFriend    = true,
            },

            -----------------------------------------------------------------
            -- 3. TargetDebuffs — target debuffs beside target frame
            --    Source: profiles.RealUI.BarGroups.TargetDebuffs
            --    Anchor: RealUITargetFrame
            -----------------------------------------------------------------
            TargetDebuffs = {
                disabled             = true,
                name                 = "TargetDebuffs",
                unit                 = "target",
                detectBuffs          = false,
                detectDebuffs        = true,
                detectDebuffsMonitor = "target",
                detectOtherDebuffs   = false,

                parentFrame          = "RealUITargetFrame",
                anchorX              = 0,
                anchorY              = -4,

                iconSize             = 30,   -- i_iconSize
                spacingX             = 3,    -- i_spacingX
                spacingY             = 15,   -- i_spacingY
                wrap                 = 10,
                maxBars              = 8,
                growDirection        = false,
                iconAlign            = "LEFT",

                hideBar              = true,
                barWidth             = 20,   -- i_barWidth
                barHeight            = 5,    -- i_barHeight
                hideLabel            = true,

                timeAlign            = "RIGHT",
                timeFormat           = 23,

                showNoDuration       = true,
                filterDebuffSpells   = true,
                filterDebuffTypes    = false,
                filterDebuffTable    = "ClassBuffs",
                filterDebuffList     = {},
                filterBuffTable      = "ClassBuffs",
                filterCooldownTable  = "ClassBuffs",

                sor                  = "T",
                timeSort             = false,
                reverseSort          = false,

                desaturate           = true,
            },

            -----------------------------------------------------------------
            -- 4. FocusBuffs — focus buffs beside focus frame
            --    Source: profiles.RealUI.BarGroups.FocusBuffs
            --    Anchor: RealUIFocusFrame
            -----------------------------------------------------------------
            FocusBuffs = {
                disabled             = true,
                name                 = "FocusBuffs",
                unit                 = "focus",
                detectBuffs          = true,
                detectDebuffs        = false,
                detectDebuffsCastBy  = "anyone",
                detectBuffsMonitor   = "focus",
                detectDebuffsMonitor = "focus",

                parentFrame          = "RealUIFocusFrame",
                anchorX              = 0,
                anchorY              = -2,

                iconSize             = 30,   -- i_iconSize
                spacingX             = 3,    -- i_spacingX
                spacingY             = 15,   -- i_spacingY
                wrap                 = 7,
                maxBars              = 7,
                growDirection        = false,
                iconAlign            = "RIGHT",
                iconInset            = -18,
                iconOffset           = 5,

                hideBar              = true,
                barWidth             = 20,   -- i_barWidth
                barHeight            = 5,    -- i_barHeight
                hideLabel            = true,

                timeAlign            = "LEFT",
                timeOffset           = 18,
                timeInset            = 16,
                timeFormat           = 23,

                showNoDuration       = false,
                filterDebuffTypes    = true,
                filterBuffTable      = "PlayerExclusions",
                filterDebuffTable    = "PlayerExclusions",
                filterCooldownTable  = "PlayerExclusions",

                sor                  = "T",
                timeSort             = false,
                reverseSort          = false,

                desaturate           = true,
                desaturateFriend     = true,

                noPlayerBuffs        = true,
                noTargetBuffs        = false,
            },

            -----------------------------------------------------------------
            -- 5. FocusDebuffs — focus debuffs beside focus frame
            --    Source: profiles.RealUI.BarGroups.FocusDebuffs
            --    Anchor: RealUIFocusFrame
            -----------------------------------------------------------------
            FocusDebuffs = {
                disabled             = true,
                name                 = "FocusDebuffs",
                unit                 = "focus",
                detectBuffs          = false,
                detectDebuffs        = true,
                detectDebuffsCastBy  = "anyone",
                detectDebuffsMonitor = "focus",

                parentFrame          = "RealUIFocusFrame",
                anchorX              = 0,
                anchorY              = -4,

                iconSize             = 35,   -- i_iconSize
                spacingX             = -8,   -- i_spacingX
                spacingY             = -8,   -- i_spacingY
                wrap                 = 7,
                maxBars              = 7,
                growDirection        = false,
                iconAlign            = "RIGHT",
                iconInset            = -18,
                iconOffset           = 5,

                hideBar              = true,
                barWidth             = 20,   -- i_barWidth
                barHeight            = 5,    -- i_barHeight
                hideLabel            = true,

                timeAlign            = "LEFT",
                timeOffset           = 18,
                timeInset            = 16,
                timeFormat           = 23,

                showNoDuration       = true,
                filterBuffTable      = "PlayerExclusions",
                filterDebuffTable    = "PlayerExclusions",

                sor                  = "T",
                timeSort             = false,
                reverseSort          = false,

                noPlayerDebuffs      = true,
                noTargetDebuffs      = true,
            },

            -----------------------------------------------------------------
            -- 6. ToTDebuffs — target-of-target debuffs
            --    Source: profiles.RealUI.BarGroups.ToTDebuffs
            --    Anchor: RealUITargetTargetFrame
            -----------------------------------------------------------------
            ToTDebuffs = {
                disabled             = true,
                name                 = "ToTDebuffs",
                unit                 = "targettarget",
                detectBuffs          = false,
                detectDebuffs        = true,
                detectDebuffsMonitor = "targettarget",
                detectOtherDebuffs   = false,

                parentFrame          = "RealUITargetTargetFrame",
                anchorX              = 0,
                anchorY              = -2,

                iconSize             = 35,   -- i_iconSize
                spacingX             = -8,   -- i_spacingX
                spacingY             = -8,   -- i_spacingY
                wrap                 = 7,
                maxBars              = 7,
                growDirection        = false,
                iconAlign            = "RIGHT",
                iconInset            = -18,
                iconOffset           = 5,

                hideBar              = true,
                barWidth             = 20,   -- i_barWidth
                barHeight            = 5,    -- i_barHeight
                hideLabel            = true,

                timeAlign            = "LEFT",
                timeOffset           = 18,
                timeInset            = 16,
                timeFormat           = 23,

                showNoDuration       = true,
                filterDebuffTypes    = false,
                filterBuffTable      = "PlayerExclusions",
                filterDebuffTable    = "PlayerExclusions",

                sor                  = "T",
                timeSort             = false,
                reverseSort          = false,

                noPlayerDebuffs      = true,
                noTargetDebuffs      = true,
                noFocusDebuffs       = false,
            },

        },
    },
    global = {
        -----------------------------------------------------------------
        -- Spell lists (all empty by default, user-populated)
        -----------------------------------------------------------------
        SpellLists = {
            PlayerInclusions       = {},
            ClassBuffs             = {},
            PlayerDebuffExclusions = {},
            PlayerExclusions       = {},
            TargetExclusions       = {},
        },

        -----------------------------------------------------------------
        -- Default aura type colours (verbatim from Raven globals)
        -----------------------------------------------------------------
        DefaultBuffColor     = { r = 0.5215686274509804, g = 0.796078431372549,  b = 0.2,                a = 1 },
        DefaultDebuffColor   = { r = 0.6470588235294118, g = 0,                  b = 0,                  a = 1 },
        DefaultMagicColor    = { r = 0.1450980392156863, g = 0.4392156862745098, b = 0.7176470588235294, a = 1 },
        DefaultCurseColor    = { r = 0.4196078431372549, g = 0,                  b = 0.6941176470588235, a = 1 },
        DefaultDiseaseColor  = { r = 0,                  g = 0,                  b = 0,                  a = 1 },
        DefaultPoisonColor   = { r = 0,                  g = 0.6313725490196078, b = 0,                  a = 1 },
        DefaultCooldownColor = { r = 0.8431372549019608, g = 0.7803921568627451, b = 0.2549019607843137, a = 1 },

        -----------------------------------------------------------------
        -- Duration overrides (spell name → known duration in seconds)
        -- Carried forward from profiles.RealUI.Durations in Raven
        -----------------------------------------------------------------
        Durations = {
            ["Cloak of Shadows"]     = 5,
            ["Deadly Poison"]        = 3600.022,
            ["Blade Twisting"]       = 8,
            ["Earthbind"]            = 5,
            ["Slice and Dice"]       = 27,
            ["Rupture"]              = 12,
            ["Combat Readiness"]     = 20,
            ["Dancing Steel"]        = 12,
            ["Vendetta"]             = 20,
            ["Drink"]                = 20,
            ["Food"]                 = 20,
            ["Anticipation"]         = 15,
            ["Windswept Pages"]      = 20,
            ["Garrote"]              = 18,
            ["Blind"]                = 60,
            ["Tricks of the Trade"]  = 6,
            ["Recuperate"]           = 24,
            ["Weakened Soul"]        = 15,
            ["Jade Spirit"]          = 12,
            ["Moderate Insight"]     = 15,
            ["Arcane Missiles!"]     = 20,
            ["Sprint"]              = 8,
            ["Honorless Target"]     = 30,
            ["Hand of Protection"]   = 10,
            ["Resurrection Sickness"] = 600,
            ["Deep Insight"]         = 15,
            ["Frostbolt"]            = 9,
            ["Revealing Strike"]     = 15,
            ["Paralytic Poison"]     = 15,
            ["Leeching Poison"]      = 3600.022,
            ["Shallow Insight"]      = 15,
            ["Grace"]                = 15,
            ["Recently Bandaged"]    = 60,
            ["Hurricane"]            = 12,
            ["Vanish"]               = 3,
            ["Eye of Vengeance"]     = 10,
            ["Arrow of Time"]        = 20,
            ["Harmony"]              = 20,
            ["River's Song"]         = 7,
            ["Blindside"]            = 10,
            ["Deserter"]             = 900,
            ["Kidney Shot"]          = 2,
            ["Enlightenment"]        = 10,
            ["First Aid"]            = 8,
            ["Plague of Ages"]       = 9,
            ["Adrenaline Rush"]      = 20,
            ["Killing Spree"]        = 2,
            ["Power Word: Shield"]   = 15,
            ["Forbearance"]          = 60,
            ["Paralysis"]            = 4,
            ["Rejuvenation"]         = 12.597,
            ["Cheap Shot"]           = 4,
            ["Evasion"]              = 15,
        },
    },
}
