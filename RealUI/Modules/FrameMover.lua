local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "FrameMover"
local FrameMover = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local EnteredWorld
local FrameList = {
    uiframes = {
        zonetext = {
            name = "Zoning Text",
            frames = {[1] = {name = "ZoneTextFrame"},},
        },
        raidmessages = {
            name = "Raid Alerts",
            frames = {[1] = {name = "RaidWarningFrame"},},
        },
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
    },
}
FrameMover.FrameList = FrameList

-- Move a single UIFrame group from saved variables
local function MoveFrameGroup(FramesTable, DBTable)
    FrameMover:debug("MoveFrameGroup")
    local FrameDB
    for idx = 1, #FramesTable do
        local frame = _G[FramesTable[idx].name]
        if not frame then return end

        FrameDB = DBTable[idx]
        frame:ClearAllPoints()
        if _G[FrameDB.parent] then
            frame:SetPoint(FrameDB.point, FrameDB.parent, FrameDB.rpoint, FrameDB.x, FrameDB.y)
        else
            _G.print(("FrameMover: invalid parent %q for %s"):format(FrameDB.parent, FramesTable[idx].name))
        end

        if FrameDB.scale then frame:SetScale(FrameDB.scale) end
    end
end
FrameMover.MoveFrameGroup = MoveFrameGroup

-- Move all UI Frames
function FrameMover:MoveUIFrames()
    for uiSlug, ui in next, FrameList.uiframes do
        local uiConfig = db.uiframes[uiSlug]
        if uiConfig and uiConfig.move and ui.frames then
            MoveFrameGroup(ui.frames, uiConfig.frames)
        end
    end
end

function FrameMover:PLAYER_ENTERING_WORLD()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    if not EnteredWorld then
        self:MoveUIFrames()
    end
    EnteredWorld = true
end

----
function FrameMover:RefreshMod()
    db = self.db.profile
    self:MoveUIFrames()
end

function FrameMover:OnInitialize()
    -- Register with ModuleFramework
    if RealUI.ModuleFramework then
        RealUI:RegisterRealUIModule(MODNAME, "utility", {}, {
            description = "Frame positioning and movement system",
            version = "1.0.0"
        })
    end

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
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
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function FrameMover:OnEnable()
    db = self.db.profile
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function FrameMover:OnDisable()
    self:UnregisterAllEvents()
end
