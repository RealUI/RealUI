-- Defaults.lua: AceDB default profile for RealUI_Auras

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")

AurasAddon.defaults = {
    profile = {
        cooldownViewer = {
            buffIconCountdown = false,
        },
        groups = {
            -----------------------------------------------------------------
            -- 1. Buffs — player buffs, top-right buff strip
            --    Anchor: RealUIPositionersBuffs (positioner frame)
            -----------------------------------------------------------------
            Buffs = {
                disabled          = true,
                name              = "Buffs",
                unit              = "player",
                detectBuffs       = true,
                detectDebuffs     = false,
                detectBuffsCastBy = "anyone",

                anchorFrame = "RealUIPositionersBuffs",
                anchorX     = -3,
                anchorY     = -3,

                iconSize  = 30,
                spacingX  = 3,
                spacingY  = 15,
                wrap      = 20,
                maxBars   = 40,
                iconAlign = "RIGHT",

                showNoDuration  = true,
                checkDuration   = true,
                filterDuration  = 60,
                checkTimeLeft   = true,
                filterTimeLeft  = 60,
                filterBuffTable   = "ClassBuffs",
                filterDebuffTable = "ClassBuffs",

                timeSort    = false,
                reverseSort = true,
            },

            -----------------------------------------------------------------
            -- 2. TargetBuffs — target buffs beside target frame
            --    Anchor: RealUITargetFrame
            -----------------------------------------------------------------
            TargetBuffs = {
                disabled          = true,
                name              = "TargetBuffs",
                unit              = "target",
                detectBuffs       = true,
                detectDebuffs     = false,
                detectBuffsCastBy = "anyone",
                detectBuffsMonitor = "target",

                parentFrame = "RealUITargetFrame",
                anchorX     = 0,
                anchorY     = -2,

                iconSize  = 30,
                spacingX  = 3,
                spacingY  = 15,
                wrap      = 6,
                maxBars   = 12,
                iconAlign = "RIGHT",

                showNoDuration    = true,
                filterBuffTable   = "ClassBuffs",
                filterDebuffTable = "PlayerExclusions",

                timeSort    = false,
                reverseSort = false,

                desaturate       = true,
                desaturateFriend = true,
            },

            -----------------------------------------------------------------
            -- 3. TargetDebuffs — target debuffs beside target frame
            --    Anchor: RealUITargetFrame
            -----------------------------------------------------------------
            TargetDebuffs = {
                disabled             = true,
                name                 = "TargetDebuffs",
                unit                 = "target",
                detectBuffs          = false,
                detectDebuffs        = true,
                detectOtherDebuffs   = false,
                detectDebuffsMonitor = "target",

                parentFrame = "RealUITargetFrame",
                anchorX     = 0,
                anchorY     = -4,

                iconSize  = 30,
                spacingX  = 3,
                spacingY  = 15,
                wrap      = 10,
                maxBars   = 8,
                iconAlign = "LEFT",

                showNoDuration    = true,
                filterDebuffTable = "ClassBuffs",
                filterBuffTable   = "ClassBuffs",

                timeSort    = false,
                reverseSort = false,

                desaturate = true,
            },

            -----------------------------------------------------------------
            -- 4. FocusBuffs — focus buffs beside focus frame
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

                parentFrame = "RealUIFocusFrame",
                anchorX     = 0,
                anchorY     = -2,

                iconSize  = 30,
                spacingX  = 3,
                spacingY  = 15,
                wrap      = 7,
                maxBars   = 7,
                iconAlign = "RIGHT",

                showNoDuration    = false,
                filterBuffTable   = "PlayerExclusions",
                filterDebuffTable = "PlayerExclusions",

                timeSort    = false,
                reverseSort = false,

                desaturate       = true,
                desaturateFriend = true,
            },

            -----------------------------------------------------------------
            -- 5. FocusDebuffs — focus debuffs beside focus frame
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

                parentFrame = "RealUIFocusFrame",
                anchorX     = 0,
                anchorY     = -4,

                iconSize  = 35,
                spacingX  = -8,
                spacingY  = -8,
                wrap      = 7,
                maxBars   = 7,
                iconAlign = "RIGHT",

                showNoDuration    = true,
                filterBuffTable   = "PlayerExclusions",
                filterDebuffTable = "PlayerExclusions",

                timeSort    = false,
                reverseSort = false,
            },

            -----------------------------------------------------------------
            -- 6. ToTDebuffs — target-of-target debuffs
            --    Anchor: RealUITargetTargetFrame
            -----------------------------------------------------------------
            ToTDebuffs = {
                disabled             = true,
                name                 = "ToTDebuffs",
                unit                 = "targettarget",
                detectBuffs          = false,
                detectDebuffs        = true,
                detectOtherDebuffs   = false,
                detectDebuffsMonitor = "targettarget",

                parentFrame = "RealUITargetTargetFrame",
                anchorX     = 0,
                anchorY     = -2,

                iconSize  = 35,
                spacingX  = -8,
                spacingY  = -8,
                wrap      = 7,
                maxBars   = 7,
                iconAlign = "RIGHT",

                showNoDuration    = true,
                filterBuffTable   = "PlayerExclusions",
                filterDebuffTable = "PlayerExclusions",

                timeSort    = false,
                reverseSort = false,
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
        -- Default aura type colours
        -----------------------------------------------------------------
        DefaultBuffColor     = { r = 0.5215686274509804, g = 0.796078431372549,  b = 0.2,                a = 1 },
        DefaultDebuffColor   = { r = 0.6470588235294118, g = 0,                  b = 0,                  a = 1 },
        DefaultMagicColor    = { r = 0.1450980392156863, g = 0.4392156862745098, b = 0.7176470588235294, a = 1 },
        DefaultCurseColor    = { r = 0.4196078431372549, g = 0,                  b = 0.6941176470588235, a = 1 },
        DefaultDiseaseColor  = { r = 0,                  g = 0,                  b = 0,                  a = 1 },
        DefaultPoisonColor   = { r = 0,                  g = 0.6313725490196078, b = 0,                  a = 1 },
        DefaultCooldownColor = { r = 0.8431372549019608, g = 0.7803921568627451, b = 0.2549019607843137, a = 1 },
    },
}
