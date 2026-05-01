local _, private = ...

-- Lua Globals --
-- luacheck: globals type

-- RealUI --
local RealUI = private.RealUI

function private.AddOns.Grid2()
    local namespaces = _G.Grid2DB.namespaces
    local Grid2Layout = namespaces.Grid2Layout.profiles
    Grid2Layout["RealUI-Healing"] = {
        ["BackgroundTexture"] = "None",
        ["PosY"] = -199.041577582324,
        ["layouts"] = {
            ["solo"] = "None",
        },
        ["FrameLock"] = true,
        ["clamp"] = true,
        ["PosX"] = -0.000104980466403504,
        ["anchor"] = "CENTER",
        ["BorderTexture"] = "None",
    }
    Grid2Layout["RealUI"] = {
        ["BackgroundTexture"] = "None",
        ["layouts"] = {
            ["solo"] = "None",
        },
        ["FrameLock"] = true,
        ["clamp"] = true,
        ["PosX"] = -1.525878872143950e-05,
        ["anchor"] = "BOTTOM",
        ["groupAnchor"] = "BOTTOMLEFT",
        ["PosY"] = 38.4000015830993,
        ["BorderTexture"] = "None",
    }

    local Grid2Frame = namespaces.Grid2Frame.profiles
    Grid2Frame["RealUI-Healing"] = {
        ["frameColor"] = {
            ["a"] = 0,
        },
        ["frameBorder"] = 1,
        ["frameBorderDistance"] = 0,
        ["frameHeight"] = 30,
        ["barTexture"] = "Plain",
        ["frameBorderTexture"] = "None",
        ["font"] = "Roboto",
        ["frameTexture"] = "Plain",
        ["orientation"] = "HORIZONTAL",
        ["frameContentColor"] = {
            ["a"] = 0.5,
        },
        ["frameWidth"] = 70,
    }
    Grid2Frame["RealUI"] = {
        ["frameColor"] = {
            ["a"] = 0,
        },
        ["frameBorder"] = 1,
        ["frameHeight"] = 30,
        ["barTexture"] = "Plain",
        ["frameTexture"] = "Plain",
        ["font"] = "Roboto",
        ["frameBorderTexture"] = "Plain",
        ["frameContentColor"] = {
            ["a"] = 0.5,
        },
        ["frameBorderDistance"] = 0,
        ["frameWidth"] = 70,
        ["orientation"] = "HORIZONTAL",
    }

    if not namespaces.Grid2RaidDebuffs then
        namespaces.Grid2RaidDebuffs = {}
    end
    if not namespaces.Grid2RaidDebuffs.profiles then
        namespaces.Grid2RaidDebuffs.profiles = {}
    end
    local Grid2RaidDebuffs = namespaces.Grid2RaidDebuffs.profiles
    Grid2RaidDebuffs["RealUI-Healing"] = {
        ["enabledModules"] = {
            ["Midnight"] = true,
            ["Mythic+ Dungeons"] = true,
        },
    }


    local profiles = _G.Grid2DB.profiles
    profiles["RealUI-Healing"] = {
        ["indicators"] = {
            ["corner-top-left"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
                ["type"] = "square",
                ["borderSize"] = 1,
                ["height"] = 3,
                ["location"] = {
                    ["y"] = -1,
                    ["relPoint"] = "TOPLEFT",
                    ["point"] = "TOPLEFT",
                    ["x"] = 1,
                },
                ["level"] = 9,
                ["width"] = 6,
                ["texture"] = "Plain",
            },
            ["text-down"] = {
                ["type"] = "text",
                ["location"] = {
                    ["y"] = 3,
                    ["relPoint"] = "BOTTOM",
                    ["point"] = "BOTTOM",
                    ["x"] = 0,
                },
                ["level"] = 6,
                ["textlength"] = 6,
                ["fontSize"] = 10,
            },
            ["icon-left"] = {
                ["type"] = "icon",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "LEFT",
                    ["point"] = "LEFT",
                    ["x"] = -2,
                },
                ["level"] = 8,
                ["fontSize"] = 8,
                ["size"] = 12,
            },
            ["border"] = {
                ["type"] = "border",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["text-down-color"] = {
                ["type"] = "text-color",
            },
            ["icon-center"] = {
                ["type"] = "icon",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 0,
                },
                ["level"] = 8,
                ["fontSize"] = 8,
                ["size"] = 14,
            },
            ["health-deficit-color"] = {
                ["type"] = "bar-color",
            },
            ["health-color"] = {
                ["type"] = "bar-color",
            },
            ["corner-top-right"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 0,
                },
                ["borderSize"] = 1,
                ["texture"] = "Plain",
                ["location"] = {
                    ["y"] = 1,
                    ["relPoint"] = "BOTTOMRIGHT",
                    ["point"] = "BOTTOMRIGHT",
                    ["x"] = -1,
                },
                ["height"] = 3,
                ["level"] = 9,
                ["type"] = "square",
                ["width"] = 6,
            },
            ["heals-color"] = {
                ["type"] = "bar-color",
            },
            ["tooltip"] = {
                ["type"] = "tooltip",
                ["displayUnitOOC"] = true,
                ["showDefault"] = true,
                ["showTooltip"] = 4,
            },
            ["alpha"] = {
                ["type"] = "alpha",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["icon-right"] = {
                ["type"] = "icon",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "RIGHT",
                    ["point"] = "RIGHT",
                    ["x"] = 2,
                },
                ["level"] = 8,
                ["fontSize"] = 8,
                ["size"] = 12,
            },
            ["health-deficit"] = {
                ["type"] = "bar",
                ["reverseFill"] = true,
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "RIGHT",
                    ["point"] = "RIGHT",
                    ["x"] = 0,
                },
                ["level"] = 2,
                ["orientation"] = "HORIZONTAL",
            },
            ["health"] = {
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 0,
                },
                ["type"] = "bar",
                ["level"] = 2,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["text-up"] = {
                ["type"] = "text",
                ["location"] = {
                    ["y"] = -3,
                    ["relPoint"] = "TOP",
                    ["point"] = "TOP",
                    ["x"] = 0,
                },
                ["level"] = 7,
                ["textlength"] = 6,
                ["fontSize"] = 10,
            },
            ["corner-bottom-left"] = {
                ["type"] = "square",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "BOTTOMLEFT",
                    ["point"] = "BOTTOMLEFT",
                    ["x"] = 0,
                },
                ["level"] = 5,
                ["size"] = 5,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                },
            },
            ["text-up-color"] = {
                ["type"] = "text-color",
            },
            ["heals"] = {
                ["type"] = "bar",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 0,
                },
                ["level"] = 1,
                ["opacity"] = 0.25,
                ["color1"] = {
                    ["a"] = 0,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["side-bottom"] = {
                ["width"] = 6,
                ["type"] = "square",
                ["borderSize"] = 1,
                ["height"] = 3,
                ["location"] = {
                    ["y"] = 1,
                    ["relPoint"] = "BOTTOM",
                    ["point"] = "BOTTOM",
                    ["x"] = 0,
                },
                ["level"] = 9,
                ["texture"] = "Plain",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["background"] = {
                ["type"] = "background",
            },
            ["private-auras-dispel"] = {
                ["type"] = "privateaurasdispel",
                ["level"] = 7,
            },
        },
        ["statuses"] = {
            ["health-deficit"] = {
                ["threshold"] = 0,
            },
            ["buff-Renew-mine"] = {
                ["spellName"] = 139,
                ["type"] = "buff",
                ["mine"] = true,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                },
            },
            ["buff-PowerWordShield"] = {
                ["type"] = "buff",
                ["spellName"] = 17,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 1,
                },
            },
            ["dungeon-role"] = {
                ["color2"] = {
                    ["a"] = 1,
                },
                ["hideDamagers"] = true,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0.749019607843137,
                },
            },
            ["buff-Riptide-mine"] = {
                ["spellName"] = 61295,
                ["type"] = "buff",
                ["mine"] = 1,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 0,
                },
            },
            ["raid-debuffs"] = {
                ["debuffs"] = {
                },
            },
            ["buff-SpiritOfRedemption"] = {
                ["spellName"] = 27827,
                ["type"] = "buff",
                ["blinkThreshold"] = 3,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                },
            },
            ["threat"] = {
                ["blinkThreshold"] = true,
                ["color2"] = {
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 1,
                },
                ["color3"] = {
                    ["g"] = 0,
                    ["b"] = 0,
                },
                ["color1"] = {
                    ["g"] = 0.415686274509804,
                },
            },
            ["buff-RenewingMist-mine"] = {
                ["spellName"] = 119611,
                ["type"] = "buff",
                ["mine"] = 1,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 0,
                },
            },
            ["buff-Rejuvenation-mine"] = {
                ["spellName"] = 774,
                ["type"] = "buff",
                ["mine"] = 1,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 1,
                    ["b"] = 0,
                },
            },
            ["afk"] = {
                ["color1"] = {
                    ["r"] = 0.501960784313726,
                    ["g"] = 0.501960784313726,
                    ["b"] = 0.501960784313726,
                },
            },
            ["health-current"] = {
                ["color2"] = {
                    ["a"] = 0.700000017881393,
                    ["g"] = 0,
                    ["r"] = 0,
                },
                ["color3"] = {
                    ["a"] = 0.700000017881393,
                    ["r"] = 0,
                },
                ["color1"] = {
                    ["a"] = 0.512819677591324,
                    ["g"] = 0,
                },
            },
            ["friendcolor"] = {
                ["colorHostile"] = true,
            },
            ["buff-PrayerOfMending-mine"] = {
                ["type"] = "buff",
                ["mine"] = true,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 0.2,
                    ["b"] = 0.2,
                },
                ["color2"] = {
                    ["a"] = 0.4,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 0.4,
                },
                ["color4"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 0.8,
                    ["b"] = 0.8,
                },
                ["spellName"] = 33076,
                ["color3"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 0.6,
                    ["b"] = 0.6,
                },
                ["color5"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                },
                ["colorCount"] = 5,
            },
            ["raid-icon-player"] = {
                ["color1"] = {
                    ["g"] = 0.96078431372549,
                    ["b"] = 0.164705882352941,
                },
            },
            ["buff-Lifebloom-mine"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 1,
                    ["g"] = 1,
                    ["r"] = 1,
                },
                ["type"] = "buff",
                ["mine"] = 1,
                ["spellName"] = 33763,
            },
        },
        ["versions"] = {
            ["Grid2"] = 106,
            ["Grid2RaidDebuffs"] = 4,
        },
        ["statusMap"] = {
            ["corner-top-left"] = {
                ["debuff-Disease"] = 53,
                ["debuff-Magic"] = 52,
                ["debuff-Poison"] = 51,
                ["debuff-Curse"] = 50,
            },
            ["health-deficit"] = {
            },
            ["icon-left"] = {
                ["buff-Rejuvenation-mine"] = 55,
                ["buff-Lifebloom-mine"] = 56,
                ["buff-RenewingMist-mine"] = 50,
                ["buff-Riptide-mine"] = 52,
                ["buff-Renew-mine"] = 54,
                ["raid-icon-player"] = 155,
            },
            ["border"] = {
                ["target"] = 50,
                ["afk"] = 51,
                ["threat"] = 50,
                ["health-low"] = 55,
            },
            ["text-down-color"] = {
                ["classcolor"] = 50,
            },
            ["icon-center"] = {
                ["ready-check"] = 150,
                ["raid-debuffs"] = 155,
                ["death"] = 155,
            },
            ["health-deficit-color"] = {
            },
            ["health-color"] = {
                ["classcolor"] = 99,
            },
            ["corner-top-right"] = {
                ["raid-assistant"] = 50,
                ["leader"] = 51,
            },
            ["heals-color"] = {
                ["classcolor"] = 99,
            },
            ["tooltip"] = {
            },
            ["alpha"] = {
                ["offline"] = 97,
                ["range"] = 99,
                ["death"] = 98,
            },
            ["icon-right"] = {
                ["raid-icon-player"] = 50,
            },
            ["text-down"] = {
                ["offline"] = 102,
                ["charmed"] = 101,
                ["name"] = 99,
                ["death"] = 103,
            },
            ["health"] = {
                ["health-current"] = 99,
            },
            ["corner-bottom-left"] = {
                ["ready-check"] = 50,
                ["threat"] = 99,
            },
            ["text-up"] = {
                ["charmed"] = 65,
                ["feign-death"] = 96,
                ["health-deficit"] = 50,
                ["offline"] = 93,
                ["death"] = 95,
                ["vehicle"] = 70,
            },
            ["text-up-color"] = {
                ["charmed"] = 65,
                ["feign-death"] = 96,
                ["health-deficit"] = 97,
                ["offline"] = 93,
                ["death"] = 95,
                ["vehicle"] = 70,
            },
            ["heals"] = {
                ["heals-incoming"] = 99,
            },
            ["side-bottom"] = {
                ["dungeon-role"] = 50,
            },
        },
        ["themes"] = {
            ["indicators"] = {
                [0] = {
                },
            },
        },
        ["hideBlizzard"] = {
            ["raid"] = true,
            ["party"] = true,
        },
    }
    profiles["RealUI"] = {
        ["indicators"] = {
            ["corner-top-left"] = {
                ["texture"] = "Plain",
                ["borderSize"] = 1,
                ["width"] = 6,
                ["location"] = {
                    ["y"] = -1,
                    ["relPoint"] = "TOPLEFT",
                    ["point"] = "TOPLEFT",
                    ["x"] = 1,
                },
                ["height"] = 3,
                ["level"] = 9,
                ["type"] = "square",
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 0,
                },
            },
            ["health-deficit"] = {
                ["type"] = "bar",
                ["reverseFill"] = true,
                ["orientation"] = "HORIZONTAL",
                ["level"] = 2,
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "RIGHT",
                    ["point"] = "RIGHT",
                    ["x"] = 0,
                },
            },
            ["icon-left"] = {
                ["size"] = 12,
                ["type"] = "icon",
                ["fontSize"] = 8,
                ["stackColor"] = {
                    ["a"] = 1,
                    ["r"] = 1,
                    ["g"] = 1,
                    ["b"] = 1,
                },
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "LEFT",
                    ["point"] = "LEFT",
                    ["x"] = 2,
                },
                ["level"] = 8,
                ["font"] = "Roboto Condensed",
                ["color1"] = {
                    ["a"] = 0,
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 0,
                },
            },
            ["border"] = {
                ["type"] = "border",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["text-down-color"] = {
                ["type"] = "text-color",
            },
            ["icon-center"] = {
                ["fontFlags"] = "MONOCHROME, OUTLINE",
                ["type"] = "icon",
                ["font"] = "Roboto Condensed",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 0,
                },
                ["level"] = 8,
                ["fontSize"] = 8,
                ["size"] = 14,
            },
            ["health-deficit-color"] = {
                ["type"] = "bar-color",
            },
            ["health-color"] = {
                ["type"] = "bar-color",
            },
            ["icon-right"] = {
                ["fontSize"] = 8,
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 0,
                },
                ["size"] = 16,
                ["borderSize"] = 1,
                ["width"] = 8,
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "RIGHT",
                    ["point"] = "RIGHT",
                    ["x"] = -1,
                },
                ["height"] = 8,
                ["level"] = 8,
                ["type"] = "icon",
                ["texture"] = "Plain",
            },
            ["heals-color"] = {
                ["type"] = "bar-color",
            },
            ["tooltip"] = {
                ["displayUnitOOC"] = true,
                ["type"] = "tooltip",
            },
            ["alpha"] = {
                ["type"] = "alpha",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["text-down"] = {
                ["type"] = "text",
                ["fontSize"] = 12,
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 2,
                },
                ["level"] = 3,
                ["textlength"] = 4,
                ["font"] = "Roboto",
            },
            ["heals"] = {
                ["type"] = "bar",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "CENTER",
                    ["point"] = "CENTER",
                    ["x"] = 0,
                },
                ["level"] = 1,
                ["opacity"] = 0.25,
                ["color1"] = {
                    ["a"] = 0,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["health"] = {
                ["type"] = "bar",
                ["orientation"] = "HORIZONTAL",
                ["level"] = 3,
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "LEFT",
                    ["point"] = "LEFT",
                    ["x"] = 0,
                },
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
            },
            ["corner-bottom-left"] = {
                ["type"] = "square",
                ["texture"] = "Plain",
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0,
                    ["g"] = 0,
                    ["b"] = 0,
                },
                ["width"] = 6,
                ["borderSize"] = 1,
                ["fontSize"] = 8,
                ["height"] = 6,
                ["location"] = {
                    ["y"] = 1,
                    ["relPoint"] = "BOTTOMLEFT",
                    ["point"] = "BOTTOMLEFT",
                    ["x"] = 1,
                },
                ["level"] = 5,
                ["font"] = "Roboto Condensed",
                ["size"] = 5,
            },
            ["text-up"] = {
                ["fontSize"] = 12,
                ["type"] = "text",
                ["location"] = {
                    ["y"] = -8,
                    ["relPoint"] = "TOP",
                    ["point"] = "TOP",
                    ["x"] = 0,
                },
                ["level"] = 6,
                ["textlength"] = 4,
                ["font"] = "Roboto",
            },
            ["text-up-color"] = {
                ["type"] = "text-color",
            },
            ["corner-top-right"] = {
                ["type"] = "square",
                ["location"] = {
                    ["y"] = 0,
                    ["relPoint"] = "TOPRIGHT",
                    ["point"] = "TOPRIGHT",
                    ["x"] = 0,
                },
                ["level"] = 9,
                ["texture"] = "Plain",
                ["size"] = 5,
            },
            ["side-bottom"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 0,
                },
                ["borderSize"] = 1,
                ["texture"] = "Plain",
                ["location"] = {
                    ["y"] = 1,
                    ["relPoint"] = "BOTTOM",
                    ["point"] = "BOTTOM",
                    ["x"] = 0,
                },
                ["height"] = 5,
                ["level"] = 9,
                ["type"] = "square",
                ["width"] = 5,
            },
            ["background"] = {
                ["type"] = "background",
            },
            ["private-auras-dispel"] = {
                ["type"] = "privateaurasdispel",
                ["level"] = 7,
            },
        },
        ["statusMap"] = {
            ["corner-top-left"] = {
                ["debuff-Disease"] = 53,
                ["debuff-Poison"] = 51,
                ["debuff-Curse"] = 50,
                ["debuff-Magic"] = 52,
                ["buff-Renew-mine"] = 99,
            },
            ["health-deficit"] = {
                ["health-deficit"] = 50,
            },
            ["icon-left"] = {
            },
            ["border"] = {
                ["afk"] = 51,
                ["threat"] = 50,
            },
            ["text-down-color"] = {
                ["classcolor"] = 99,
            },
            ["icon-center"] = {
                ["test"] = 156,
                ["raid-debuffs"] = 155,
            },
            ["health-deficit-color"] = {
                ["classcolor"] = 50,
            },
            ["heals"] = {
            },
            ["icon-right"] = {
                ["raid-icon-player"] = 50,
            },
            ["heals-color"] = {
            },
            ["alpha"] = {
                ["offline"] = 97,
                ["range"] = 99,
                ["death"] = 98,
            },
            ["corner-top-right"] = {
                ["raid-assistant"] = 50,
                ["leader"] = 51,
                ["buff-PowerWordShield"] = 99,
            },
            ["health-color"] = {
            },
            ["health"] = {
            },
            ["corner-bottom-left"] = {
                ["ready-check"] = 50,
            },
            ["text-up"] = {
            },
            ["text-up-color"] = {
                ["charmed"] = 65,
                ["feign-death"] = 96,
                ["health-deficit"] = 50,
                ["offline"] = 93,
                ["vehicle"] = 70,
                ["death"] = 95,
            },
            ["text-down"] = {
                ["charmed"] = 101,
                ["offline"] = 102,
                ["name"] = 99,
                ["death"] = 103,
            },
            ["side-bottom"] = {
                ["dungeon-role"] = 50,
            },
        },
        ["versions"] = {
            ["Grid2"] = 106,
            ["Grid2RaidDebuffs"] = 4,
        },
        ["statuses"] = {
            ["buff-SpiritOfRedemption"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 1,
                    ["g"] = 1,
                    ["r"] = 1,
                },
                ["type"] = "buff",
                ["blinkThreshold"] = 3,
                ["spellName"] = 27827,
            },
            ["threat"] = {
                ["blinkThreshold"] = true,
                ["color2"] = {
                    ["b"] = 0,
                    ["g"] = 0,
                    ["r"] = 1,
                },
                ["color3"] = {
                    ["g"] = 0,
                    ["b"] = 0,
                },
                ["color1"] = {
                    ["g"] = 0.388235294117647,
                },
            },
            ["health-deficit"] = {
                ["threshold"] = 0,
            },
            ["afk"] = {
                ["color1"] = {
                    ["r"] = 0.501960784313726,
                    ["g"] = 0.501960784313726,
                    ["b"] = 0.501960784313726,
                },
            },
            ["friendcolor"] = {
                ["colorHostile"] = true,
            },
            ["buff-Renew-mine"] = {
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 1,
                    ["g"] = 1,
                    ["r"] = 1,
                },
                ["type"] = "buff",
                ["mine"] = true,
                ["spellName"] = 139,
            },
            ["buff-PowerWordShield"] = {
                ["type"] = "buff",
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 1,
                    ["g"] = 1,
                    ["r"] = 0,
                },
                ["spellName"] = 17,
            },
            ["dungeon-role"] = {
                ["color2"] = {
                    ["a"] = 1,
                },
                ["hideDamagers"] = true,
                ["color1"] = {
                    ["a"] = 1,
                    ["r"] = 0.749019607843137,
                },
            },
            ["raid-icon-player"] = {
                ["color1"] = {
                    ["g"] = 0.96078431372549,
                    ["b"] = 0.164705882352941,
                },
            },
            ["health-current"] = {
                ["color2"] = {
                    ["a"] = 0.700000017881393,
                    ["g"] = 0,
                    ["r"] = 0,
                },
                ["color3"] = {
                    ["a"] = 0.700000017881393,
                    ["r"] = 0,
                },
                ["color1"] = {
                    ["a"] = 0.5,
                    ["g"] = 0,
                },
            },
            ["buff-PrayerOfMending-mine"] = {
                ["type"] = "buff",
                ["mine"] = true,
                ["color1"] = {
                    ["a"] = 1,
                    ["b"] = 0.2,
                    ["g"] = 0.2,
                    ["r"] = 1,
                },
                ["color2"] = {
                    ["a"] = 0.4,
                    ["b"] = 0.4,
                    ["g"] = 1,
                    ["r"] = 1,
                },
                ["color3"] = {
                    ["a"] = 1,
                    ["b"] = 0.6,
                    ["g"] = 0.6,
                    ["r"] = 1,
                },
                ["colorCount"] = 5,
                ["color4"] = {
                    ["a"] = 1,
                    ["b"] = 0.8,
                    ["g"] = 0.8,
                    ["r"] = 1,
                },
                ["color5"] = {
                    ["a"] = 1,
                    ["b"] = 1,
                    ["g"] = 1,
                    ["r"] = 1,
                },
                ["spellName"] = 33076,
            },
        },
        ["themes"] = {
            ["enabled"] = {
                ["solo"] = 0,
                ["raid"] = 0,
                ["default"] = 0,
                ["party"] = 0,
            },
            ["indicators"] = {
                [0] = {
                },
            },
        },
        ["hideBlizzard"] = {
            ["raid"] = true,
            ["party"] = true,
        },
    }
end

-- Optional migration for existing users: additively applies Grid2 3.x
-- profile additions and removes obsolete spell references that no longer
-- exist in the game. Returns true if any changes were made, false otherwise.
function private.Grid2ProfileMigration()
    local Grid2DB = _G.Grid2DB
    if not Grid2DB or not Grid2DB.profiles then return false end

    -- Spells removed from the game — safe to clean up unconditionally
    local OBSOLETE_STATUSES = {
        "buff-Grace-mine",
        "buff-DivineAegis",
        "buff-InnerFire",
        "buff-SpiritShell-mine",
        "buff-EternalFlame-mine",
        "debuff-WeakenedSoul",
    }

    local changed = false
    for _, profileName in _G.ipairs({"RealUI", "RealUI-Healing"}) do
        local profile = Grid2DB.profiles[profileName]
        if profile then
            -- hideBlizzard (migration v14)
            if not profile.hideBlizzard then
                profile.hideBlizzard = { raid = true, party = true }
                changed = true
            end

            -- Ensure indicators table exists
            profile.indicators = profile.indicators or {}

            -- background indicator (migration v7)
            if not profile.indicators["background"] then
                profile.indicators["background"] = { type = "background" }
                changed = true
            end

            -- private-auras-dispel indicator (migration v105)
            if not profile.indicators["private-auras-dispel"] then
                profile.indicators["private-auras-dispel"] = { type = "privateaurasdispel", level = 7 }
                changed = true
            end

            -- tooltip displayUnitOOC (migration v6)
            if profile.indicators["tooltip"] and profile.indicators["tooltip"].displayUnitOOC == nil then
                profile.indicators["tooltip"].displayUnitOOC = true
                changed = true
            end

            -- threat blinkThreshold (migration v11)
            if profile.statuses and profile.statuses["threat"]
               and not profile.statuses["threat"].blinkThreshold then
                profile.statuses["threat"].blinkThreshold = true
                changed = true
            end

            -- Remove obsolete statuses (spells no longer in the game)
            if profile.statuses then
                for _, obsolete in _G.ipairs(OBSOLETE_STATUSES) do
                    if profile.statuses[obsolete] then
                        profile.statuses[obsolete] = nil
                        changed = true
                    end
                end
            end

            -- Remove obsolete statusMap references
            if profile.statusMap then
                for _, mappings in _G.pairs(profile.statusMap) do
                    for _, obsolete in _G.ipairs(OBSOLETE_STATUSES) do
                        if mappings[obsolete] then
                            mappings[obsolete] = nil
                            changed = true
                        end
                    end
                end
            end

            -- Clear stale BfA-era raid debuffs (RealUI-Healing only)
            if profileName == "RealUI-Healing" and profile.statuses
               and profile.statuses["raid-debuffs"]
               and profile.statuses["raid-debuffs"].debuffs then
                local debuffs = profile.statuses["raid-debuffs"].debuffs
                if _G.next(debuffs) then
                    -- Wipe all entries — Grid2RaidDebuffs repopulates at runtime
                    _G.table.wipe(debuffs)
                    changed = true
                end
            end

            -- versions.RealUIGrid2 for future migration tracking
            profile.versions = profile.versions or {}
            if not profile.versions.RealUIGrid2 then
                profile.versions.RealUIGrid2 = 1
                changed = true
            end
        end
    end

    -- Grid2RaidDebuffs enabledModules
    local namespaces = Grid2DB.namespaces
    local rdProfiles = namespaces and namespaces.Grid2RaidDebuffs
        and namespaces.Grid2RaidDebuffs.profiles
    if rdProfiles and rdProfiles["RealUI-Healing"] then
        local em = rdProfiles["RealUI-Healing"].enabledModules
        if em then
            if not em["Midnight"] then
                em["Midnight"] = true
                changed = true
            end
            if em["The War Within"] then
                em["The War Within"] = nil
                changed = true
            end
        end
    end

    return changed
end

-- Check if Grid2 migration is needed and show opt-in popup for existing users.
-- Called from Core.lua OnEnable with a short delay.
function private.CheckGrid2Migration()
    local dbg = RealUI.db and RealUI.db.global
    if not dbg then return end

    -- Skip if already applied or declined
    if dbg.grid2MigrationState then return end

    -- Skip if Grid2DB doesn't exist or profiles are missing
    local Grid2DB = _G.Grid2DB
    if not Grid2DB or not Grid2DB.profiles then return end

    -- Detect if migration is needed: check sentinel (hideBlizzard absent)
    local needsMigration = false
    for _, profileName in _G.ipairs({"RealUI", "RealUI-Healing"}) do
        local profile = Grid2DB.profiles[profileName]
        if profile and not profile.hideBlizzard then
            needsMigration = true
            break
        end
    end

    if not needsMigration then
        dbg.grid2MigrationState = "applied"
        return
    end

    -- Show two-button popup: Apply / Skip
    _G.StaticPopupDialogs["REALUI_GRID2_MIGRATION"] = {
        text = "|cff85e0ffRealUI Grid2 Update|r\n\nNew Grid2 3.x settings are available "
            .. "(Blizzard frame hiding, private aura dispel indicator, background indicator, "
            .. "Midnight raid debuffs).\n\nApply these additions to your Grid2 profiles? "
            .. "Your existing customizations will not be changed.",
        button1 = _G.APPLY or "Apply",
        button2 = _G.CANCEL or "Skip",
        OnAccept = function()
            private.Grid2ProfileMigration()
            dbg.grid2MigrationState = "applied"
            _G.print("|cff0099ffRealUI|r: Grid2 profiles updated with new 3.x additions.")
        end,
        OnCancel = function()
            dbg.grid2MigrationState = "declined"
            _G.print("|cff0099ffRealUI|r: Grid2 update skipped. Use |cFFFF8000/realui grid2update|r to apply later.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        notClosableByLogout = false,
    }
    _G.StaticPopup_Show("REALUI_GRID2_MIGRATION")
end

function private.Profiles.Grid2()
    local db = _G.Grid2.profiles.char
    db.enabled = true
    for specIndex = 1, #RealUI.charInfo.specs do
        local profile = private.layoutToProfile[1]
        if RealUI.charInfo.specs[specIndex].role == "HEALER" then
            profile = private.layoutToProfile[2]
        end

        db[specIndex] = profile
    end

    local pro = db[RealUI.charInfo.specs.current.index] or db
    if type(pro) == "string" then
        if _G.Grid2ProfileAPI then
            -- Use public API (Grid2 3.x) - no pcall needed since the API
            -- is only available after Grid2 has fully initialized.
            if pro ~= _G.Grid2ProfileAPI:GetCurrentProfileKey() then
                _G.Grid2ProfileAPI:SetProfile(pro)
            end
        elseif pro ~= _G.Grid2.db:GetCurrentProfile() then
            -- Fallback to AceDB (pre-3.x). pcall protects against Grid2
            -- errors during early init (e.g. GridLayout:UpdateFrame calling
            -- SetClampedToScreen with a bad value before Grid2 is fully
            -- bootstrapped on a fresh install).
            local ok, _err = pcall(_G.Grid2.db.SetProfile, _G.Grid2.db, pro)
            if not ok then
                -- Defer the profile switch until Grid2 is ready
                RealUI:ScheduleTimer(function()
                    if _G.Grid2 and _G.Grid2.db then
                        pcall(_G.Grid2.db.SetProfile, _G.Grid2.db, pro)
                    end
                end, 2)
            end
        end
    end
end
