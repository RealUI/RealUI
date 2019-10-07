local _, private = ...

-- Lua Globals --
-- luacheck: globals type

-- RealUI --

function private.AddOns.Bartender4()
    local namespaces = _G.Bartender4DB.namespaces
    local ActionBars = namespaces.ActionBars.profiles
    ActionBars["RealUI"] = {
        ["actionbars"] = {
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["flyoutDirection"] = "DOWN",
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]][overridebar][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "CENTER",
                    ["x"] = -171.5,
                    ["y"] = -199.5,
                },
            }, -- [1]
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "BOTTOM",
                    ["x"] = -171.5,
                    ["y"] = 89,
                },
            }, -- [2]
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "BOTTOM",
                    ["x"] = -171.5,
                    ["y"] = 62,
                },
            }, -- [3]
            {
                ["version"] = 3,
                ["rows"] = 12,
                ["padding"] = -9,
                ["flyoutDirection"] = "LEFT",
                ["fadeoutalpha"] = 0,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
                },
                ["position"] = {
                    ["point"] = "RIGHT",
                    ["x"] = -36,
                    ["y"] = 334.5,
                },
            }, -- [4]
            {
                ["version"] = 3,
                ["rows"] = 12,
                ["padding"] = -9,
                ["flyoutDirection"] = "LEFT",
                ["fadeoutalpha"] = 0,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
                },
                ["position"] = {
                    ["point"] = "RIGHT",
                    ["x"] = -36,
                    ["y"] = 10.5,
                },
            }, -- [5]
            {
                ["enabled"] = false,
            }, -- [6]
        },
    }
    ActionBars["RealUI-Healing"] = {
        ["actionbars"] = {
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["flyoutDirection"] = "DOWN",
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]][overridebar][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "CENTER",
                    ["x"] = -171.5,
                    ["y"] = -199.5,
                },
            }, -- [1]
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "BOTTOM",
                    ["x"] = -171.5,
                    ["y"] = 89,
                },
            }, -- [2]
            {
                ["version"] = 3,
                ["padding"] = -9,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
                },
                ["position"] = {
                    ["point"] = "BOTTOM",
                    ["x"] = -171.5,
                    ["y"] = 62,
                },
            }, -- [3]
            {
                ["version"] = 3,
                ["rows"] = 12,
                ["padding"] = -9,
                ["flyoutDirection"] = "LEFT",
                ["fadeoutalpha"] = 0,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
                },
                ["position"] = {
                    ["point"] = "RIGHT",
                    ["x"] = -36,
                    ["y"] = 334.5,
                },
            }, -- [4]
            {
                ["version"] = 3,
                ["rows"] = 12,
                ["padding"] = -9,
                ["flyoutDirection"] = "LEFT",
                ["fadeoutalpha"] = 0,
                ["hidemacrotext"] = true,
                ["visibility"] = {
                    ["custom"] = true,
                    ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
                },
                ["position"] = {
                    ["point"] = "RIGHT",
                    ["x"] = -36,
                    ["y"] = 10.5,
                },
            }, -- [5]
            {
                ["enabled"] = false,
            }, -- [6]
        },
    }

    if namespaces.ExtraActionBar then
        local ExtraActionBar = namespaces.ExtraActionBar.profiles
        ExtraActionBar["RealUI"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "BOTTOM",
                ["x"] = 157.5,
                ["y"] = 86,
                ["scale"] = 0.985,
            },
        }
        ExtraActionBar["RealUI-Healing"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "BOTTOM",
                ["x"] = 157.5,
                ["y"] = 86,
                ["scale"] = 0.985,
            },
        }
    end

    local MicroMenu = namespaces.MicroMenu.profiles
    MicroMenu["RealUI"] = {
        ["enabled"] = false,
    }
    MicroMenu["RealUI-Healing"] = {
        ["enabled"] = false,
    }

    if namespaces.ZoneAbilityBar then
        local ZoneAbilityBar = namespaces.ZoneAbilityBar.profiles
        ZoneAbilityBar["RealUI"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "BOTTOM",
                ["x"] = -157.5,
                ["y"] = 86,
                ["scale"] = 0.985,
            },
        }
        ZoneAbilityBar["RealUI-Healing"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "BOTTOM",
                ["x"] = -157.5,
                ["y"] = 86,
                ["scale"] = 0.985,
            },
        }
    end

    local BagBar = namespaces.BagBar.profiles
    BagBar["RealUI"] = {
        ["enabled"] = false,
    }
    BagBar["RealUI-Healing"] = {
        ["enabled"] = false,
    }

    local StanceBar = namespaces.StanceBar.profiles
    StanceBar["RealUI"] = {
        ["version"] = 3,
        ["padding"] = -7,
        ["fadeoutalpha"] = 0,
        ["visibility"] = {
            ["custom"] = true,
            ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
        },
        ["position"] = {
            ["point"] = "BOTTOM",
            ["x"] = -157.5,
            ["y"] = 49,
            ["scale"] = 1,
            ["growHorizontal"] = "LEFT",
        },
    }
    StanceBar["RealUI-Healing"] = {
        ["version"] = 3,
        ["padding"] = -7,
        ["fadeoutalpha"] = 0,
        ["visibility"] = {
            ["custom"] = true,
            ["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
        },
        ["position"] = {
            ["point"] = "BOTTOM",
            ["x"] = -157.5,
            ["y"] = 49,
            ["scale"] = 1,
            ["growHorizontal"] = "LEFT",
        },
    }

    if namespaces.Vehicle then
        local Vehicle = namespaces.Vehicle.profiles
        Vehicle["RealUI"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "TOPRIGHT",
                ["x"] = -36,
                ["y"] = -59.5,
                ["scale"] = 0.84,
            },
        }
        Vehicle["RealUI-Healing"] = {
            ["version"] = 3,
            ["position"] = {
                ["point"] = "TOPRIGHT",
                ["x"] = -36,
                ["y"] = -59.5,
                ["scale"] = 0.84,
            },
        }
    end

    local PetBar = namespaces.PetBar.profiles
    PetBar["RealUI"] = {
        ["version"] = 3,
        ["rows"] = 10,
        ["padding"] = -7,
        ["fadeoutalpha"] = 0,
        ["visibility"] = {
            ["custom"] = true,
            ["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
        },
        ["position"] = {
            ["point"] = "LEFT",
            ["x"] = -8,
            ["y"] = 124.5,
        },
    }
    PetBar["RealUI-Healing"] = {
        ["version"] = 3,
        ["rows"] = 10,
        ["padding"] = -7,
        ["fadeoutalpha"] = 0,
        ["visibility"] = {
            ["custom"] = true,
            ["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
        },
        ["position"] = {
            ["point"] = "LEFT",
            ["x"] = -8,
            ["y"] = 124.5,
        },
    }


    local profiles = _G.Bartender4DB.profiles
    profiles["RealUI"] = {
        ["minimapIcon"] = {
            ["hide"] = true,
        },
    }
    profiles["RealUI-Healing"] = {
        ["minimapIcon"] = {
            ["hide"] = true,
        },
    }
end

function private.Profiles.Bartender4()
    _G.Grid2.db:SetProfile("RealUI")
end
