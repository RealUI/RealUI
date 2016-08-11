local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db

local MODNAME = "FrameMover"
local FrameMover = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

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
FrameMover.FrameList = FrameList

local isAddonControl = {
    raven = "Raven",
    grid2 = "Grid2"
}
FrameMover.isAddonControl = isAddonControl

-- Hide a Frame 
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
    local FrameDB
    for idx = 1, #FramesTable do
        FramesMoving = true

        local frame = _G[FramesTable[idx].name]
        if not frame then return end
        
        FrameDB = DBTable[idx]
        frame:ClearAllPoints()
        if _G[FrameDB.parent] then
            frame:SetPoint(FrameDB.point, FrameDB.parent, FrameDB.rpoint, FrameDB.x, FrameDB.y)
        else
            _G.print(L["General_InvalidParent"]:format(FramesTable[idx].name, MODNAME, "Addons -> Raven"))
        end
        
        if FrameDB.scale then frame:SetScale(FrameDB.scale) end
        FramesMoving = false
    end
end
FrameMover.MoveFrameGroup = MoveFrameGroup

-- Move all Addons
function FrameMover:MoveAddons(addonName)
    FrameMover:debug("MoveAddons", addonName)
    for addonSlug, addon in next, FrameList.addons do
        local addonInfo = db.addons[addonSlug]
        FrameMover:debug("Move Addon", addonSlug, addon, addonName)
        if (addonName and addonSlug == addonName) or (addonName == nil) then
            if (not isAddonControl[addonSlug] and addonInfo.move) or
              (isAddonControl[addonSlug] and RealUI:DoesAddonMove(isAddonControl[addonSlug])) then
                local IsHealing = ( addon.hashealing and addonInfo.healing and RealUI.cLayout == 2 )
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
    for uiSlug, ui in next, FrameList.uiframes do
        if db.uiframes[uiSlug].move and ui.frames then
            MoveFrameGroup(ui.frames, db.uiframes[uiSlug].frames)
        end
    end
end

-- Hide all UI Frames
function FrameMover:HideFrames()
    for hideSlug, hide in next, FrameList.hide do
        if db.hide[hideSlug].hide then
            HideFrameGroup(hide.frames)
        end
    end
end

---- Hook into addons to display PopUpMessage and reposition frames
-- VSI
local function Hook_VSI()
    _G.hooksecurefunc(_G.VehicleSeatIndicator, "SetPoint", function(_, _, parent)
        if RealUI:GetModuleEnabled(MODNAME) and db.uiframes.vsi.move then
            if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
                MoveFrameGroup(FrameList.uiframes.vsi.frames, db.uiframes.vsi.frames)
            end
        end
    end)
end

-- Raven - To stop bars repositioning themselves
local function Hook_Raven()
    if not _G.IsAddOnLoaded("Raven") then return end
    
    local t = _G.CreateFrame("Frame")
    t:Hide()
    t.e = 0
    t:SetScript("OnUpdate", function(s, e)
        FrameMover:debug("Move Raven")
        t.e = t.e + e
        if t.e >= 0.5 then
            MoveFrameGroup(FrameList.addons.raven.frames, db.addons.raven.frames)
            t.e = 0
            t:Hide()
        end
    end) 
    
    _G.hooksecurefunc(_G.Raven, "Nest_SetAnchorPoint", function()
        FrameMover:debug("Nest_SetAnchorPoint")
        t:SetShown(RealUI:DoesAddonMove("Raven"))
    end)

    if _G.RavenBarGroupBuffs then _G.RavenBarGroupBuffs:SetClampedToScreen(false) end
end

-- Grid2 - Top stop LayoutFrame re-anchoring itself to UIParent
local function Hook_Grid2()
    if not _G.Grid2LayoutFrame then return end
    _G.hooksecurefunc(_G.Grid2LayoutFrame, "SetPoint", function(...)
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
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    
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
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function FrameMover:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function FrameMover:OnDisable()
    self:UnregisterAllEvents()
end
