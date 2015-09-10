local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb, ndbc

local _
local MODNAME = "FrameMover"
local FrameMover = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local EnteredWorld
local FramesMoving

local FrameList = {
    addons = {
        grid2 = {
            name = "Grid2",
            hashealing = true,
            frames = {[1] = {name = "Grid2LayoutFrame"},},
            frameshealing = {[1] = {name = "Grid2LayoutFrame"},},
        },
        raven = {
            name = "Raven",
            frames = {
                [1] = {name = "RavenBarGroupPlayerBuffs"},
                [2] = {name = "RavenBarGroupPlayerDebuffs"},
                [3] = {name = "RavenBarGroupTargetBuffs"},
                [4] = {name = "RavenBarGroupTargetDebuffs"},
                [5] = {name = "RavenBarGroupFocusBuffs"},
                [6] = {name = "RavenBarGroupFocusDebuffs"},
                [7] = {name = "RavenBarGroupToTDebuffs"},
                -- [8] = {name = "RavenBarGroupBuffs"},
            },
        },
    },
    uiframes = {
        zonetext = {
            name = "Zoning Text",
            frames = {[1] = {name = "ZoneTextFrame"},},
        },
        raidmessages = {
            name = "Raid Alerts",
            frames = {[1] = {name = "RaidWarningFrame"},},
        },
        -- bossemote = {
        --  name = "Boss Emotes",
        --  frames = {[1] = {name = "RaidBossEmoteFrame"},},
        -- },
        ticketstatus = {
            name = "Ticket Status",
            frames = {[1] = {name = "TicketStatusFrame"},},
        },
        worldstate = {
            name = "World State",
            frames = {[1] = {name = "WorldStateAlwaysUpFrame"},},
        },
        errorframe = {
            name = "Errors",
            frames = {[1] = {name = "UIErrorsFrame"},},
        },
        vsi = {
            name = "Vehicle Seat",
            frames = {[1] = {name = "VehicleSeatIndicator"},},
        },
        playerpowerbaralt = {
            name = "Alternate Power Bar",
            frames = {[1] = {name = "PlayerPowerBarAlt"},},
        },
    },
    hide = {
        durabilityframe = {
            name = "Durability Frame",
            frames = {[1] = {name = "DurabilityFrame"},},
        },
    },
}

-- Hide a Frame 
local function HideFrame(FrameName)
    local frame = _G[FrameName]
    if not frame then return end
    
    frame:UnregisterAllEvents()
    frame:Hide()    
    frame:SetScript("OnShow", function(self) self:Hide() end)
end

local function HideFrameGroup(FramesTable)
    for _, info in next, FramesTable do
        local frame = _G[info.name]
        if not frame then return end
        
        frame:UnregisterAllEvents()
        frame:Hide()    
        frame:SetScript("OnShow", function(self) self:Hide() end)
    end
end

-- Move a single Addon/UIFrame group from saved variables
local function MoveFrameGroup(FramesTable, DBTable)
    FrameMover:debug("MoveFrameGroup")
    local FrameDB = {}
    for idx = 1, #FramesTable do
        FramesMoving = true

        local frame = _G[FramesTable[idx].name]
        if not frame then return end
        
        FrameDB = DBTable[idx]
        frame:ClearAllPoints()
        if _G[FrameDB.parent] then
            frame:SetPoint(FrameDB.point, FrameDB.parent, FrameDB.rpoint, FrameDB.x, FrameDB.y)
        else
            print(L["General_InvalidParent"]:format(FramesTable[idx].name, MODNAME, "Addons -> Raven"))
        end
        
        if FrameDB.scale then frame:SetScale(FrameDB.scale) end
        FramesMoving = false
    end
end

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Frame Mover",
        desc = "Automatically Move/Hide certain AddOns/Frames.",
        arg = MODNAME,
        order = 618,
        args = {
            header = {
                type = "header",
                name = "Frame Mover/Hider",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Automatically Move/Hide certain AddOns/Frames.",
                fontSize = "medium",
                order = 20,
            },
        },
    }
    end
    
    -- Create Addons options table
    local addonOpts = {
        name = "Addons",
        type = "group",
        disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
        order = 50,
        args = {},
    }
    local addonOrderCnt = 10
    for addonSlug, addon in next, FrameList.addons do
        local addonInfo = db.addons[addonSlug]
        -- Create base options for Addons
        addonOpts.args[addonSlug] = {
            type = "group",
            name = addon.name,
            childGroups = "tab",
            order = addonOrderCnt,
            disabled = function() return not(IsAddOnLoaded(addon.name) and nibRealUI:GetModuleEnabled(MODNAME)) end,
            args = {
                header = {
                    type = "header",
                    name = string.format("Frame Mover - Addons - %s", addon.name),
                    order = 10,
                },
                enabled = {
                    type = "toggle",
                    name = string.format("Move %s", addon.name),
                    get = function(info)
                        if addonSlug == "grid2" then
                            return nibRealUI:DoesAddonMove("Grid2")
                        else
                            return addonInfo.move
                        end
                    end,
                    set = function(info, value) 
                        if addonSlug == "grid2" then
                            if nibRealUI:DoesAddonMove("Grid2") then
                                FrameMover:MoveAddons()
                            end
                        else
                            addonInfo.move = value
                            if addonInfo.move then
                                FrameMover:MoveAddons()
                            end
                        end
                    end,
                    order = 20,
                },
                normal = {
                    type = "group",
                    name = " ",
                    order = 50,
                    args = {},
                },
            },
        }
        
        -- Healing Enable option
        if addon.hashealing then
            addonOpts.args[addonSlug].args.healingenabled = {
                type = "toggle",
                name = "Enable Healing Layout",
                get = function(info) return addonInfo.healing end,
                set = function(info, value) 
                    addonInfo.healing = value 
                    if addonInfo.move then
                        FrameMover:MoveAddons()
                    end
                end,
                order = 30,
            }
        end
        
        -- Normal / Low Res
        -- Create options table for Frames
        local normalFrameOpts = {
            name = "Frames",
            type = "group",
            inline = true,
            disabled = function() if addonInfo.move then return false else return true end end,
            order = 10,
            args = {},
        }
        local normalFrameOrderCnt = 10
        for i = 1, #addon.frames do
            normalFrameOpts.args[tostring(i)] = {
                type = "group",
                name = addon.frames[i].name,
                inline = true,
                order = normalFrameOrderCnt,
                args = {
                    x = {
                        type = "input",
                        name = "X Offset",
                        width = "half",
                        order = 10,
                        get = function(info) return tostring(addonInfo.frames[i].x) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            addonInfo.frames[i].x = value
                            FrameMover:MoveAddons()
                        end,
                    },
                    yoffset = {
                        type = "input",
                        name = "Y Offset",
                        width = "half",
                        order = 20,
                        get = function(info) return tostring(addonInfo.frames[i].y) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            addonInfo.frames[i].y = value
                            FrameMover:MoveAddons()
                        end,
                    },
                    anchorto = {
                        type = "select",
                        name = "Anchor To",
                        get = function(info) 
                            for idx, point in next, nibRealUI.globals.anchorPoints do
                                if point == addonInfo.frames[i].rpoint then return idx end
                            end
                        end,
                        set = function(info, value)
                            addonInfo.frames[i].rpoint = nibRealUI.globals.anchorPoints[value]
                            FrameMover:MoveAddons()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = nibRealUI.globals.anchorPoints,
                        order = 30,
                    },
                    anchorfrom = {
                        type = "select",
                        name = "Anchor From",
                        get = function(info) 
                            for idx, point in next, nibRealUI.globals.anchorPoints do
                                if point == addonInfo.frames[i].point then return idx end
                            end
                        end,
                        set = function(info, value)
                            addonInfo.frames[i].point = nibRealUI.globals.anchorPoints[value]
                            FrameMover:MoveAddons()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = nibRealUI.globals.anchorPoints,
                        order = 40,
                    },
                    parent = {
                        type = "input",
                        name = "Parent",
                        desc = L["General_NoteParent"],
                        width = "double",
                        order = 50,
                        get = function(info) return addonInfo.frames[i].parent end,
                        set = function(info, value)
                            if not _G[value] then value = "UIParent" end
                            addonInfo.frames[i].parent = value
                            FrameMover:MoveAddons()
                        end,
                    },
                },
            }
            normalFrameOrderCnt = normalFrameOrderCnt + 10
        end
        
        -- Create options table for Healing Frames
        local normalHealingFrameOpts = nil
        if addon.hashealing then
            normalHealingFrameOpts = {
                name = "Healing Layout Frames",
                type = "group",
                inline = true,
                disabled = function() return not ( addonInfo.move and addonInfo.healing ) end,
                order = 50,
                args = {},
            }
            local normalHealingFrameOrderCnt = 10       
            for i = 1, #addon.frameshealing do
                normalHealingFrameOpts.args[tostring(i)] = {
                    type = "group",
                    name = addon.frameshealing[i].name,
                    inline = true,
                    order = normalHealingFrameOrderCnt,
                    args = {
                        x = {
                            type = "input",
                            name = "X Offset",
                            width = "half",
                            order = 10,
                            get = function(info) return tostring(addonInfo.frameshealing[i].x) end,
                            set = function(info, value)
                                value = nibRealUI:ValidateOffset(value)
                                addonInfo.frameshealing[i].x = value
                                FrameMover:MoveAddons()
                            end,
                        },
                        yoffset = {
                            type = "input",
                            name = "Y Offset",
                            width = "half",
                            order = 20,
                            get = function(info) return tostring(addonInfo.frameshealing[i].y) end,
                            set = function(info, value)
                                value = nibRealUI:ValidateOffset(value)
                                addonInfo.frameshealing[i].y = value
                                FrameMover:MoveAddons()
                            end,
                        },
                        anchorto = {
                            type = "select",
                            name = "Anchor To",
                            get = function(info) 
                                for idx, point in next, nibRealUI.globals.anchorPoints do
                                    if point == addonInfo.frameshealing[i].rpoint then return idx end
                                end
                            end,
                            set = function(info, value)
                                addonInfo.frameshealing[i].rpoint = nibRealUI.globals.anchorPoints[value]
                                FrameMover:MoveAddons()
                            end,
                            style = "dropdown",
                            width = nil,
                            values = nibRealUI.globals.anchorPoints,
                            order = 30,
                        },
                        anchorfrom = {
                            type = "select",
                            name = "Anchor From",
                            get = function(info) 
                                for idx, point in next, nibRealUI.globals.anchorPoints do
                                    if point == addonInfo.frameshealing[i].point then return idx end
                                end
                            end,
                            set = function(info, value)
                                addonInfo.frameshealing[i].point = nibRealUI.globals.anchorPoints[value]
                                FrameMover:MoveAddons()
                            end,
                            style = "dropdown",
                            width = nil,
                            values = nibRealUI.globals.anchorPoints,
                            order = 40,
                        },
                        parent = {
                            type = "input",
                            name = "Parent",
                            desc = L["General_NoteParent"],
                            width = "double",
                            order = 50,
                            get = function(info) return addonInfo.frameshealing[i].parent end,
                            set = function(info, value)
                                if not _G[value] then value = "UIParent" end
                                addonInfo.frameshealing[i].parent = value
                                FrameMover:MoveAddons()
                            end,
                        },
                    },
                }
                normalHealingFrameOrderCnt = normalHealingFrameOrderCnt + 10
            end
        end

        -- Add Frames to Addons options
        addonOpts.args[addonSlug].args.normal.args.frames = normalFrameOpts
        if normalHealingFrameOpts ~= nil then addonOpts.args[addonSlug].args.normal.args.healingframes = normalHealingFrameOpts end
        
        addonOrderCnt = addonOrderCnt + 10  
    end
    
    -- Create UIFrames options table
    local uiframesopts = {
        name = "UI Frames",
        type = "group",
        disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
        order = 60,
        args = {},
    }
    local uiframesordercnt = 10 
    for uiSlug, ui in next, FrameList.uiframes do
        local uiInfo = db.uiframes[uiSlug]
        -- Create base options for UIFrames
        uiframesopts.args[uiSlug] = {
            type = "group",
            name = ui.name,
            order = uiframesordercnt,
            args = {
                header = {
                    type = "header",
                    name = string.format("Frame Mover - UI Frames - %s", ui.name),
                    order = 10,
                },
                enabled = {
                    type = "toggle",
                    name = string.format("Move %s", ui.name),
                    get = function(info) return uiInfo.move end,
                    set = function(info, value) 
                        uiInfo.move = value 
                        if uiInfo.move and ui.frames then MoveFrameGroup(ui.frames, uiInfo.frames) end
                    end,
                    order = 20,
                },
            },
        }
        
        -- Create options table for Frames
        if ui.frames then
            local frameopts = {
                name = "Frames",
                type = "group",
                inline = true,
                disabled = function() if uiInfo.move then return false else return true end end,
                order = 30,
                args = {},
            }
            local FrameOrderCnt = 10
            for i = 1, #ui.frames do
                frameopts.args[tostring(i)] = {
                    type = "group",
                    name = ui.frames[i].name,
                    inline = true,
                    order = FrameOrderCnt,
                    args = {
                        x = {
                            type = "input",
                            name = "X Offset",
                            width = "half",
                            order = 10,
                            get = function(info) return tostring(uiInfo.frames[i].x) end,
                            set = function(info, value)
                                value = nibRealUI:ValidateOffset(value)
                                uiInfo.frames[i].x = value
                                MoveFrameGroup(ui.frames, uiInfo.frames)
                            end,
                        },
                        yoffset = {
                            type = "input",
                            name = "Y Offset",
                            width = "half",
                            order = 20,
                            get = function(info) return tostring(uiInfo.frames[i].y) end,
                            set = function(info, value)
                                value = nibRealUI:ValidateOffset(value)
                                uiInfo.frames[i].y = value
                                MoveFrameGroup(ui.frames, uiInfo.frames)
                            end,
                        },
                        anchorto = {
                            type = "select",
                            name = "Anchor To",
                            get = function(info) 
                                for idx, point in next, nibRealUI.globals.anchorPoints do
                                    if point == uiInfo.frames[i].rpoint then return idx end
                                end
                            end,
                            set = function(info, value)
                                uiInfo.frames[i].rpoint = nibRealUI.globals.anchorPoints[value]
                                MoveFrameGroup(ui.frames, uiInfo.frames)
                            end,
                            style = "dropdown",
                            width = nil,
                            values = nibRealUI.globals.anchorPoints,
                            order = 30,
                        },
                        anchorfrom = {
                            type = "select",
                            name = "Anchor From",
                            get = function(info) 
                                for idx, point in next, nibRealUI.globals.anchorPoints do
                                    if point == uiInfo.frames[i].point then return idx end
                                end
                            end,
                            set = function(info, value)
                                uiInfo.frames[i].point = nibRealUI.globals.anchorPoints[value]
                                MoveFrameGroup(ui.frames, uiInfo.frames)
                            end,
                            style = "dropdown",
                            width = nil,
                            values = nibRealUI.globals.anchorPoints,
                            order = 40,
                        },
                    },
                }
                FrameOrderCnt = FrameOrderCnt + 10
            end
            
            -- Add Frames to UI Frames options
            uiframesopts.args[uiSlug].args.frames = frameopts
            uiframesordercnt = uiframesordercnt + 10
        end
    end
    
    -- Create Hide options table
    local hideopts = {
        name = "Hide Frames",
        type = "group",
        disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
        order = 70,
        args = {
            header = {
                type = "header",
                name = string.format("Frame Mover - Hide Frames"),
                order = 10,
            },
            sep = {
                type = "description",
                name = " ",
                order = 20,
            },
            note = {
                type = "description",
                name = "Note: To make a frame visible again after it has been hidden, you will need to reload the UI (type: /rl).",
                order = 30,
            },
            hideframes = {
                type = "group",
                name = "Hide",
                inline = true,
                order = 40,
                args = {},
            },
        },
    }
    -- Add all frames to Hide Frames options
    local hideordercnt = 10 
    for hideSlug, hide in next, FrameList.hide do
        local hideInfo = db.hide [hideSlug]
        -- Create base options for Hide
        hideopts.args.hideframes.args[hideSlug] = {
            type = "toggle",
            name = hide.name,
            get = function(info) return hideInfo.hide end,
            set = function(info, value) 
                hideInfo.hide = value 
                if hideInfo.hide then
                    FrameMover:HideFrames()
                else
                    nibRealUI:ReloadUIDialog()
                end
            end,
            order = hideordercnt,
        }

        hideordercnt = hideordercnt + 10        
    end

    -- Add extra options to Options table
    options.args.addons = addonOpts
    options.args.uiframes = uiframesopts
    options.args.hide = hideopts
    return options
end

-- Move all Addons
function FrameMover:MoveAddons(addonName)
    FrameMover:debug("MoveAddons", addonName)
    local FrameDB = {}
    for addonSlug, addon in next, FrameList.addons do
        local addonInfo = db.addons[addonSlug]
        --print("MoveAddons", addonSlug, addon, addonName)
        if (addonName and addonSlug == addonName) or (addonName == nil) then
            if ((addonSlug ~= "grid2") and addonInfo.move) or ((addonSlug == "grid2") and nibRealUI:DoesAddonMove("Grid2")) then
                local IsHealing = ( addon.hashealing and addonInfo.healing and nibRealUI.cLayout == 2 )
                FrameMover:debug("IsHealing", IsHealing)
                
                if IsHealing then
                    -- Healing Layout
                    MoveFrameGroup(addon.frameshealing, addonInfo.frameshealing)
                else
                    -- Normal Layout
                    MoveFrameGroup(addon.frames, addonInfo.frames)
                end
            end
        end
    end
end

-- Move all UI Frames
function FrameMover:MoveUIFrames()
    local FrameDB = {}
    for uiSlug, ui in next, FrameList.uiframes do
        if db.uiframes[uiSlug].move and ui.frames then
            MoveFrameGroup(ui.frames, db.uiframes[uiSlug].frames)
        end
    end
end

-- Hide all UI Frames
function FrameMover:HideFrames()
    for hideSlug, hide in pairs(FrameList.hide) do
        if db.hide[hideSlug].hide then
            HideFrameGroup(hide.frames)
        end
    end
end

---- Hook into addons to display PopUpMessage and reposition frames
-- VSI
local function Hook_VSI()
    hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(_, _, parent)
        if nibRealUI:GetModuleEnabled(MODNAME) and db.uiframes.vsi.move then
            if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
                MoveFrameGroup(FrameList.uiframes.vsi.frames, db.uiframes.vsi.frames)
            end
        end
    end)
end

-- Raven - To stop bars repositioning themselves
local function Hook_Raven()
    if not IsAddOnLoaded("Raven") then return end
    
    local t = CreateFrame("Frame")
    t:Hide()
    t.e = 0
    t:SetScript("OnUpdate", function(s, e)
        t.e = t.e + e
        if t.e >= 0.5 then
            MoveFrameGroup(FrameList.addons.raven.frames, db.addons.raven.frames)
            t.e = 0
            t:Hide()
        end
    end) 
    
    hooksecurefunc(Raven, "Nest_SetAnchorPoint", function()
        t:Show()
    end)

    if RavenBarGroupBuffs then RavenBarGroupBuffs:SetClampedToScreen(false) end
end

-- Grid2 - Top stop LayoutFrame re-anchoring itself to UIParent
local function Hook_Grid2()
    if not Grid2LayoutFrame then return end
    hooksecurefunc(Grid2LayoutFrame, "SetPoint", function(...)
        FrameMover:debug("Grid2LayoutFrame:SetPoint")
        if FramesMoving then return end
        FrameMover:debug("SetPoint", ...)
        FrameMover:MoveAddons("grid2")
    end)
end

function FrameMover:RefreshMod()
    db = self.db.profile
    self:MoveUIFrames()
    self:MoveAddons()
end

function FrameMover:PLAYER_ENTERING_WORLD()
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    
    if not EnteredWorld then
        Hook_Grid2()
        Hook_Raven()
        Hook_VSI()
        
        self:MoveUIFrames()
        self:MoveAddons()
        self:HideFrames()
    end
    EnteredWorld = true
end

----
function FrameMover:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            addons = {
                ["**"] = {
                    move = true,
                    healing = false,
                },
                grid2 = {
                    healing = true,
                    frames = {
                        [1] = {name = "Grid2LayoutFrame", parent = "RealUIPositionersGridBottom", point = "BOTTOM", rpoint = "BOTTOM", x = -0.5, y = 0},
                    },
                    frameshealing = {
                        [1] = {name = "Grid2LayoutFrame", parent = "RealUIPositionersGridTop", point = "TOP", rpoint = "TOP", x = -0.5, y = 0},
                    },
                },
                raven = {
                    frames = {
                        [1] = {name = "RavenBarGroupPlayerBuffs",   parent = "RealUIPlayerFrame",       point = "TOPRIGHT",    rpoint = "TOPLEFT",  x = -2, y = 3},
                        [2] = {name = "RavenBarGroupPlayerDebuffs", parent = "RealUIPlayerShields",     point = "BOTTOMRIGHT", rpoint = "TOPRIGHT", x = 6,   y = -3},
                        [3] = {name = "RavenBarGroupTargetBuffs",   parent = "RealUITargetFrame",       point = "TOPLEFT",     rpoint = "TOPRIGHT", x = 2,  y = 3},
                        [4] = {name = "RavenBarGroupTargetDebuffs", parent = "RealUITargetFrame",       point = "BOTTOMLEFT",  rpoint = "TOPRIGHT", x = 3,   y = 3},
                        [5] = {name = "RavenBarGroupFocusBuffs",    parent = "RealUIFocusFrame",        point = "TOPRIGHT",    rpoint = "TOPLEFT",  x = -6, y = 5},
                        [6] = {name = "RavenBarGroupFocusDebuffs",  parent = "RealUIFocusFrame",        point = "TOPRIGHT",    rpoint = "TOPLEFT",  x = -6, y = -21},
                        [7] = {name = "RavenBarGroupToTDebuffs",    parent = "RealUITargetTargetFrame", point = "TOPLEFT",     rpoint = "TOPRIGHT", x = 6,  y = -5},
                    },
                },
            },
            uiframes = {
                ["**"] = {
                    move = true,
                },
                zonetext = {
                    frames = {
                        [1] = {name = "ZoneTextFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = 0, y = -85},
                    },
                },
                raidmessages = {
                    frames = {
                        [1] = {name = "RaidWarningFrame", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 0, y = 214},
                    },
                },
                -- bossemote = {
                --  frames = {
                --      [1] = {name = "RaidBossEmoteFrame", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 0, y = 128},
                --  },
                -- },
                errorframe = {
                    frames = {
                        [1] = {name = "UIErrorsFrame", parent = "RealUIPositionersCenter", point = "BOTTOM", rpoint = "CENTER", x = 0, y = 138},
                    },
                },
                ticketstatus = {
                    frames = {
                        [1] = {name = "TicketStatusFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = -220, y = -8},
                    },
                },
                worldstate = {
                    frames = {
                        [1] = {name = "WorldStateAlwaysUpFrame", parent = "UIParent", point = "TOP", rpoint = "TOP", x = -5, y = -20},
                    },
                },
                vsi = {
                    frames = {
                        [1] = {name = "VehicleSeatIndicator", parent = "UIParent", point = "TOPRIGHT", rpoint = "TOPRIGHT", x = -10, y = -72},
                    },
                },
                playerpowerbaralt = {
                    frames = {
                        [1] = {name = "PlayerPowerBarAlt", parent = "UIParent", point = "CENTER", rpoint = "CENTER", x = 295, y = -275},
                    },
                },
            },
            hide = {
                ["**"] = {
                    hide = true,
                },
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)
end

function FrameMover:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function FrameMover:OnDisable()
    self:UnregisterAllEvents()
end
