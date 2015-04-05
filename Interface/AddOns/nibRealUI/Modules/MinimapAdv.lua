local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndbc, _

local MODNAME = "MinimapAdv"
local MinimapAdv = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local Astrolabe = DongleStub("Astrolabe-1.0")

RealUIMinimap = MinimapAdv

local CRFM
local strform = _G.string.format

BINDING_HEADER_REALUIMINIMAP = "RealUI Minimap"
BINDING_NAME_REALUIMINIMAPTOGGLE = "Toggle Minimap"
BINDING_NAME_REALUIMINIMAPFARM = "Toggle Farm Mode"

-- Options
local minimapOffsets = {
    {x = 7, y = -7},
    {x = -7, y = -7},
    {x = 7, y = 28},
    {x = -7, y = 28},
}
local minimapAnchors = {
    "TOPLEFT",
    "TOPRIGHT",
    "BOTTOMLEFT",
    "BOTTOMRIGHT",
}

local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Minimap",
        desc = "Advanced, minimalistic Minimap.",
        arg = MODNAME,
        childGroups = "tab",
        -- order = 1309,
        args = {
            header = {
                type = "header",
                name = "Minimap",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Advanced, minimalistic Minimap.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Minimap module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                    nibRealUI:ReloadUIDialog()
                end,
                order = 30,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 31,
            },
            information = {
                name = "Information",
                type = "group",
                disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 40,
                args = {
                    coordDelayHide = {
                        type = "toggle",
                        name = "Fade out Coords",
                        desc = "Hide the Coordinate display when you haven't moved for 10 seconds.",
                        get = function(info) return db.information.coordDelayHide end,
                        set = function(info, value)
                            db.information.coordDelayHide = value
                            MinimapAdv.StationaryTime = 0
                            MinimapAdv.LastX = 0
                            MinimapAdv.LastY = 0
                            MinimapAdv:CoordsUpdate()
                        end,
                        order = 10,
                    },
                    minimapbuttons = {
                        type = "toggle",
                        name = "Hide Minimap Buttons",
                        desc = "Moves buttons attached to the Minimap to underneath and shows them on mouse-over.",
                        get = function(info) return db.information.minimapbuttons end,
                        set = function(info, value)
                            db.information.minimapbuttons = value
                            nibRealUI:ReloadUIDialog()
                        end,
                        order = 20,
                    },
                    location = {
                        type = "toggle",
                        name = "Location Name",
                        desc = "Show the name of your current location underneath the Minimap.",
                        get = function(info) return db.information.location end,
                        set = function(info, value)
                            db.information.location = value
                            MinimapAdv:UpdateInfoPosition()
                        end,
                        order = 30,
                    },
                    gap = {
                        type = "range",
                        name = "Gap",
                        desc = "Amount of space between each information element.",
                        min = 1, max = 28, step = 1,
                        get = function(info) return db.information.gap end,
                        set = function(info, value)
                            db.information.gap = value
                            MinimapAdv:UpdateFonts()
                            MinimapAdv:UpdateInfoPosition()
                        end,
                        order = 40,
                    },
                    hideRaidFilters = {
                        type = "toggle",
                        name = L["Tweaks_HideRaidFilter"],
                        desc = L["Tweaks_HideRaidFilterDesc"],
                        get = function(info) return db.information.hideRaidFilters end,
                        set = function(info, value)
                            db.information.hideRaidFilters = value
                        end,
                        order = 50,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 51,
                    },
                    position = {
                        name = "Position",
                        type = "group",
                        inline = true,
                        order = 60,
                        args = {
                            xoffset = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                order = 10,
                                get = function(info) return tostring(db.information.position.x) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.information.position.x = value
                                    MinimapAdv:UpdateInfoPosition()
                                end,
                            },
                            yoffset = {
                                type = "input",
                                name = "Y Offset",
                                width = "half",
                                order = 20,
                                get = function(info) return tostring(db.information.position.y) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.information.position.y = value
                                    MinimapAdv:UpdateInfoPosition()
                                end,
                            },
                        },
                    },
                },
            },
            hidden = {
                name = "Automatic Hide/Show",
                type = "group",
                disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 50,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        get = function(info) return db.hidden.enabled end,
                        set = function(info, value) db.hidden.enabled = value end,
                        order = 10,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 11,
                    },
                    zones = {
                        type = "group",
                        name = "Hide in..",
                        inline = true,
                        disabled = function()
                            return not(db.hidden.enabled and nibRealUI:GetModuleEnabled(MODNAME))
                        end,
                        order = 20,
                        args = {
                            arena = {
                                type = "toggle",
                                name = "Arenas",
                                get = function(info) return db.hidden.zones.arena end,
                                set = function(info, value) db.hidden.zones.arena = value end,
                                order = 10,
                            },
                            pvp = {
                                type = "toggle",
                                name = BATTLEGROUNDS,
                                get = function(info) return db.hidden.zones.pvp end,
                                set = function(info, value) db.hidden.zones.pvp = value end,
                                order = 200,
                            },
                            party = {
                                type = "toggle",
                                name = DUNGEONS,
                                get = function(info) return db.hidden.zones.party end,
                                set = function(info, value) db.hidden.zones.party = value end,
                                order = 30,
                            },
                            raid = {
                                type = "toggle",
                                name = RAIDS,
                                get = function(info) return db.hidden.zones.raid end,
                                set = function(info, value) db.hidden.zones.raid = value end,
                                order = 40,
                            },
                        },
                    },
                },
            },
            sizeposition = {
                name = "Position",
                type = "group",
                disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 60,
                args = {
                    size = {
                        type = "range",
                        name = "Size",
                        desc = "Note: Minimap will refresh to fit the new size upon player movement.",
                        min = 134,
                        max = 164,
                        step = 1,
                        get = function(info) return db.position.size end,
                        set = function(info, value)
                            db.position.size = value
                            MinimapAdv:UpdateMinimapPosition()
                        end,
                        order = 10,
                    },
                    position = {
                        name = "Position",
                        type = "group",
                        inline = true,
                        order = 20,
                        args = {
                            scale = {
                                type = "range",
                                name = "Scale",
                                min = 0.5,
                                max = 2,
                                step = 0.05,
                                isPercent = true,
                                get = function(info) return db.position.scale end,
                                set = function(info, value)
                                    db.position.scale = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 10,
                            },
                            xoffset = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                get = function(info) return tostring(db.position.x) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.position.x = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 20,
                            },
                            yoffset = {
                                type = "input",
                                name = "Y Offset",
                                width = "half",
                                get = function(info) return tostring(db.position.y) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.position.y = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 30,
                            },
                            anchorto = {
                                type = "select",
                                name = "Anchor To",
                                get = function(info)
                                    for k,v in pairs(minimapAnchors) do
                                        if v == db.position.anchorto then return k end
                                    end
                                end,
                                set = function(info, value)
                                    --print("Set Anchor", info.option, value)
                                    db.position.anchorto = minimapAnchors[value]
                                    db.position.x = minimapOffsets[value].x
                                    db.position.y = minimapOffsets[value].y
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = minimapAnchors,
                                order = 40,
                            },
                        },
                    },
                },
            },
            expand = {
                name = "Farm Mode",
                type = "group",
                disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 70,
                args = {
                    appearance = {
                        name = APPEARANCE_LABEL,
                        type = "group",
                        inline = true,
                        order = 10,
                        args = {
                            scale = {
                                type = "range",
                                name = "Scale",
                                min = 0.5,
                                max = 2,
                                step = 0.05,
                                isPercent = true,
                                get = function(info) return db.expand.appearance.scale end,
                                set = function(info, value)
                                    db.expand.appearance.scale = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 10,
                            },
                            opacity = {
                                type = "range",
                                name = "Opacity",
                                min = 0,
                                max = 1,
                                step = 0.05,
                                isPercent = true,
                                get = function(info) return db.expand.appearance.opacity end,
                                set = function(info, value)
                                    db.expand.appearance.opacity = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 20,
                            },
                        },
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    position = {
                        name = "Position",
                        type = "group",
                        inline = true,
                        order = 30,
                        args = {
                            xoffset = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                get = function(info) return tostring(db.expand.position.x) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.expand.position.x = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 10,
                            },
                            yoffset = {
                                type = "input",
                                name = "Y Offset",
                                width = "half",
                                get = function(info) return tostring(db.expand.position.y) end,
                                set = function(info, value)
                                    value = nibRealUI:ValidateOffset(value)
                                    db.expand.position.y = value
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                order = 20,
                            },
                            anchorto = {
                                type = "select",
                                name = "Anchor To",
                                get = function(info)
                                    for k, v in pairs(minimapAnchors) do
                                        if v == db.expand.position.anchorto then return k end
                                    end
                                end,
                                set = function(info, value)
                                    db.expand.position.anchorto = minimapAnchors[value]
                                    db.expand.position.x = minimapOffsets[value].x
                                    db.expand.position.y = minimapOffsets[value].y
                                    MinimapAdv:UpdateMinimapPosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = minimapAnchors,
                                order = 30,
                            },
                        },
                    },
                    gap2 = {
                        name = " ",
                        type = "description",
                        order = 31,
                    },
                    extras = {
                        name = "Extras",
                        type = "group",
                        inline = true,
                        order = 40,
                        args = {
                            gatherertoggle = {
                                type = "toggle",
                                name = "Gatherer toggle",
                                disabled = function() if not Gatherer then return true else return false end end,
                                desc = "If you have Gatherer installed, then MinimapAdv will automatically disable Gatherer's minimap icons and HUD while not in Farm Mode, and enable them while in Farm Mode.",
                                get = function(info) return db.expand.extras.gatherertoggle end,
                                set = function(info, value)
                                    db.expand.extras.gatherertoggle = value
                                    MinimapAdv:ToggleGatherer()
                                end,
                                order = 10,
                            },
                            clickthrough = {
                                type = "toggle",
                                name = "Clickthrough",
                                desc = "Make the Minimap clickthrough (won't respond to mouse clicks) while in Farm Mode.",
                                get = function(info) return db.expand.extras.clickthrough end,
                                set = function(info, value)
                                    db.expand.extras.clickthrough = value
                                    MinimapAdv:UpdateClickthrough()
                                end,
                                order = 20,
                            },
                            hidepoi = {
                                type = "toggle",
                                name = "Hide POI icons",
                                get = function(info) return db.expand.extras.hidepoi end,
                                set = function(info, value)
                                    db.expand.extras.hidepoi = value
                                    MinimapAdv:UpdateFarmModePOI()
                                end,
                                order = 30,
                            },
                        },
                    },
                },
            },
            poi = {
                name = "POI",
                type = "group",
                disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 80,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        desc = "Enable/Disable the displaying of POI icons on the minimap.",
                        get = function(info) return db.poi.enabled end,
                        set = function(info, value)
                            db.poi.enabled = value
                            MinimapAdv:UpdatePOIEnabled()
                        end,
                        order = 10,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 11,
                    },
                    general = {
                        type = "group",
                        name = "General Settings",
                        inline = true,
                        disabled = function()
                            return not(db.poi.enabled and nibRealUI:GetModuleEnabled(MODNAME))
                        end,
                        order = 20,
                        args = {
                            watchedOnly = {
                                type = "toggle",
                                name = "Watched Only",
                                desc = "Only show POI icons for watched quests.",
                                get = function(info) return db.poi.watchedOnly end,
                                set = function(info, value)
                                    db.poi.watchedOnly = value
                                    MinimapAdv:POIUpdate()
                                end,
                                order = 10,
                            },
                            fadeEdge = {
                                type = "toggle",
                                name = "Fade at Edge",
                                desc = "Fade icons when they go off the edge of the minimap.",
                                get = function(info) return db.poi.fadeEdge end,
                                set = function(info, value)
                                    db.poi.fadeEdge = value
                                    MinimapAdv:POIUpdate()
                                end,
                                order = 10,
                            },
                        },
                    },
                    gap2 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    icons = {
                        type = "group",
                        name = "Icon Settings",
                        inline = true,
                        disabled = function()
                            return not(db.poi.enabled and nibRealUI:GetModuleEnabled(MODNAME))
                        end,
                        order = 30,
                        args = {
                            scale = {
                                type = "range",
                                name = "Scale",
                                min = 0.1,
                                max = 1.5,
                                step = 0.05,
                                isPercent = true,
                                get = function(info) return db.poi.icons.scale end,
                                set = function(info, value)
                                    db.poi.icons.scale = value
                                    MinimapAdv:POIUpdate()
                                end,
                                order = 10,
                            },
                            opacity = {
                                type = "range",
                                name = "Opacity",
                                min = 0.1,
                                max = 1,
                                step = 0.05,
                                isPercent = true,
                                get = function(info) return db.poi.icons.opacity end,
                                set = function(info, value)
                                    db.poi.icons.opacity = value
                                    MinimapAdv:POIUpdate()
                                end,
                                order = 10,
                            },
                        },
                    },
                },
            },
        },
    }
    end

    return options
end

local Font1, Font2 = CreateFont("MinimapFont1"), CreateFont("MinimapFont2")

local Textures = {
    SquareMask = [[Interface\AddOns\nibRealUI\Media\Minimap\SquareMinimapMask]],
    Minimize = [[Interface\Addons\nibRealUI\Media\Minimap\Minimize]],
    Maximize = [[Interface\Addons\nibRealUI\Media\Minimap\Maximize]],
    Config = [[Interface\Addons\nibRealUI\Media\Minimap\Config]],
    Tracking = [[Interface\Addons\nibRealUI\Media\Minimap\Tracking]],
    Expand = [[Interface\Addons\nibRealUI\Media\Minimap\Expand]],
    Collapse = [[Interface\Addons\nibRealUI\Media\Minimap\Collapse]],
    ZoneIndicator = [[Interface\Addons\nibRealUI\Media\Minimap\ZoneIndicator]],
    TooltipIcon = [[Interface\Addons\nibRealUI\Media\Minimap\TooltipIcon]],
}

local MMFrames = MinimapAdv.Frames
local InfoShown = {
    coords = false,
    dungeondifficulty = false,
    lootSpec = false,
}
local pois = {}
MinimapAdv.pois = pois
local POI_OnEnter, POI_OnLeave, POI_OnMouseUp, Arrow_OnUpdate

local ExpandedState = 0
local UpdateProcessing = false

----------
-- Seconds to Time
local function ConvertSecondstoTime(value)
    local minutes, seconds
    minutes = floor(value / 60)
    seconds = floor(value - (minutes * 60))
    if ( minutes > 0 ) then
        if ( seconds < 10 ) then seconds = strform("0%d", seconds) end
        return strform("%s:%s", minutes, seconds)
    else
        return strform("%ss", seconds)
    end
end

-- Zoom Out
local function ZoomMinimapOut()
    Minimap:SetZoom(0)
    MinimapZoomIn:Enable()
    MinimapZoomOut:Disable()
end

-- Timer
local RefreshMap, RefreshZoom
local RefreshTimer = CreateFrame("FRAME")
RefreshTimer.elapsed = 5
RefreshTimer:Hide()
RefreshTimer:SetScript("OnUpdate", function(s, e)
    RefreshTimer.elapsed = RefreshTimer.elapsed - e
    if (RefreshTimer.elapsed <= 0) then
        -- Map
        if RefreshMap then
            local x, y = GetPlayerMapPosition("Player")

            -- If Coords are at 0,0 then it's possible that they are stuck
            if x == 0 and y == 0 and not WorldMapFrame:IsVisible() then
                SetMapToCurrentZone()
            end
            RefreshMap = false
        end

        -- Zoom
        if RefreshZoom then
            ZoomMinimapOut()
            RefreshZoom = false
        end
        RefreshTimer.elapsed = 1
    end
end)

local function fadeIn(frame)
    --print("fadeIn")
    if InCombatLockdown() then return end
    UIFrameFadeIn(frame, 0.1, frame:GetAlpha(), 1)
end
local function fadeOut(frame)
    --print("fadeOut")
    UIFrameFadeOut(frame, 0.5, frame:GetAlpha(), 0)
end

---------------------------
-- MINIMAP FRAME UPDATES --
---------------------------
-- Clickthrough
function MinimapAdv:UpdateClickthrough()
    if ( (ExpandedState == 0) or (not db.expand.extras.clickthrough) ) then
        Minimap:EnableMouse(true)
    else
        Minimap:EnableMouse(false)
    end
end

-- Farm Mode - Hide POI option
function MinimapAdv:UpdateFarmModePOI()
    if ExpandedState == 0 then
        self:POIUpdate()
    else
        if db.expand.extras.hidepoi then
            self:RemoveAllPOIs()
        else
            self:POIUpdate()
        end
    end
end

-- Get size and position data
local function GetPositionData()
    -- Get Normal or Expanded data
    local NewMinimapPoints

    if ExpandedState == 0 then
        NewMinimapPoints = {
            xofs = db.position.x,
            yofs = db.position.y,
            anchor = db.position.anchorto,
            scale = db.position.scale,
            opacity = 1,
            isTop = db.position.anchorto:find("TOP"),
            isLeft = db.position.anchorto:find("LEFT"),
        }
    else
        NewMinimapPoints = {
            xofs = db.expand.position.x,
            yofs = db.expand.position.y,
            anchor = db.expand.position.anchorto,
            scale = db.expand.appearance.scale,
            opacity = db.expand.appearance.opacity,
            isTop = db.position.anchorto:find("TOP"),
            isLeft = db.position.anchorto:find("LEFT"),
        }
    end

    return NewMinimapPoints
end

-- Set Info text/button positions
function MinimapAdv:UpdateInfoPosition()
    local NewMinimapPoints = GetPositionData()

    local mm_xofs = NewMinimapPoints.xofs
    local mm_yofs = NewMinimapPoints.yofs
    local mm_anchor = NewMinimapPoints.anchor
    local scale = NewMinimapPoints.scale
    local isTop = NewMinimapPoints.isTop
    local isLeft = NewMinimapPoints.isLeft

    local xofs
    local yofs
    local yadj
    local ymulti

    local font1 = {RealUIFont_PixelSmall:GetFont()}
    local font2 = {RealUIFont_Pixel:GetFont()}
    local fontSize
    Font1:SetFont(font1[1], font1[2] / db.position.scale, font1[3])
    Font2:SetFont(font2[1], font2[2] / db.position.scale, font2[3])
    fontSize = font2[2]

    local iHeight = (fontSize + db.information.gap) / scale

    self.numText = 0
    local numText = self.numText

    if Minimap:IsVisible() and (ExpandedState == 0) then
        -- Set Offsets, Positions, Gaps
        ymulti = isTop and -1 or 1
        xofs = isLeft and db.information.position.x or -db.information.position.x
        yofs = (db.information.position.y + 11) * ymulti - (5 * scale * ymulti)
        yadj = iHeight * ymulti

        local rpoint, point, Cpoint
        if isTop then
            point = "TOP"
            rpoint = "BOTTOM"
            Cpoint = "BOTTOM"
        else
            point = "BOTTOM"
            rpoint = "TOP"
            Cpoint = "TOP"
        end
        if isLeft then
            point = point .. "LEFT"
            rpoint = rpoint .. "LEFT"
            Cpoint = Cpoint .. "LEFT"
        else
            point = point .. "RIGHT"
            rpoint = rpoint .. "RIGHT"
            Cpoint = Cpoint .. "RIGHT"
        end

        -- Zone Indicator
        if MMFrames.info.zoneIndicator.isHostile then
            MMFrames.info.zoneIndicator:Show()
        else
            MMFrames.info.zoneIndicator:Hide()
        end

        -- Coordinates
        if InfoShown.coords then
            MMFrames.info.coords:ClearAllPoints()
            MMFrames.info.coords:SetPoint(Cpoint, "Minimap", Cpoint, 0, 0)
            MMFrames.info.coords.text:SetFontObject("MinimapFont1")
            MMFrames.info.coords.text:SetJustifyH("LEFT")

            MMFrames.info.coords:Show()
        else
            MMFrames.info.coords:Hide()
        end

        ---- Info List
        -- Location
        if db.information.location then
            MMFrames.info.location:ClearAllPoints()
            MMFrames.info.location:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.location.text:SetFontObject("MinimapFont2")
            MMFrames.info.location:Show()
            yofs = yofs + yadj
        else
            MMFrames.info.location:Hide()
        end

        -- Dungeon Difficulty
        if InfoShown.dungeondifficulty and not(InfoShown.coords) then
            MMFrames.info.dungeondifficulty:ClearAllPoints()
            MMFrames.info.dungeondifficulty:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.dungeondifficulty.text:SetFontObject("MinimapFont2")
            MMFrames.info.dungeondifficulty:Show()
            yofs = yofs + yadj
            numText = numText + 1
        else
            MMFrames.info.dungeondifficulty:Hide()
        end

        -- Loot Spec
        if InfoShown.lootSpec then
            MMFrames.info.lootSpec:ClearAllPoints()
            MMFrames.info.lootSpec:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.lootSpec.text:SetFontObject("MinimapFont2")
            MMFrames.info.lootSpec:Show()
            yofs = yofs + yadj
            numText = numText + 1
        else
            MMFrames.info.lootSpec:Hide()
        end

        -- Dungeon Finder Queue
        if InfoShown.queue then
            MMFrames.info.queue:ClearAllPoints()
            MMFrames.info.queue:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.queue.text:SetFontObject("MinimapFont2")
            MMFrames.info.queue:Show()
            yofs = yofs + yadj
            numText = numText + 1
        else
            MMFrames.info.queue:Hide()
        end

        -- Raid Finder Queue
        if InfoShown.RFqueue then
            MMFrames.info.RFqueue:ClearAllPoints()
            MMFrames.info.RFqueue:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.RFqueue.text:SetFontObject("MinimapFont2")
            MMFrames.info.RFqueue:Show()
            yofs = yofs + yadj
            numText = numText + 1
        else
            MMFrames.info.RFqueue:Hide()
        end

        -- Scenarios Queue
        if InfoShown.Squeue then
            MMFrames.info.Squeue:ClearAllPoints()
            MMFrames.info.Squeue:SetPoint(point, "Minimap", rpoint, xofs, yofs)
            MMFrames.info.Squeue.text:SetFontObject("MinimapFont2")
            MMFrames.info.Squeue:Show()
            yofs = yofs + yadj
            numText = numText + 1
        else
            MMFrames.info.Squeue:Hide()
        end

        if (IsAddOnLoaded("Blizzard_CompactRaidFrames")) and (mm_anchor == "TOPLEFT") then
            numText = numText + 1
            self:debug("InfoText", yofs, self.numText)
            self:AdjustCRFManager(_G["CompactRaidFrameManager"], Minimap:GetHeight(), NewMinimapPoints)
            if not self.hookedCRFM then
                hooksecurefunc("CompactRaidFrameManager_Toggle", function(CRFM)
                    self:AdjustCRFManager(CRFM, Minimap:GetHeight())
                end)
                if db.information.hideRaidFilters then
                    hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", function(self)
                        local container = self.displayFrame.optionsFlowContainer
                        FlowContainer_PauseUpdates(container)

                        FlowContainer_RemoveObject(container, self.displayFrame.profileSelector)
                        self.displayFrame.profileSelector:Hide()
                        FlowContainer_RemoveObject(container, self.displayFrame.filterOptions)
                        self.displayFrame.filterOptions:Hide()
                        FlowContainer_RemoveObject(container, self.displayFrame.lockedModeToggle)
                        self.displayFrame.lockedModeToggle:Hide()
                        FlowContainer_RemoveObject(container, self.displayFrame.hiddenModeToggle)
                        self.displayFrame.hiddenModeToggle:Hide()

                        FlowContainer_ResumeUpdates(container);
                        
                        local usedX, usedY = FlowContainer_GetUsedBounds(container);
                        self:SetHeight(usedY + 40);
                    end)
                end
                self.hookedCRFM = true
            end
        end
    else
        MMFrames.info.location:Hide()
        MMFrames.info.coords:Hide()
        MMFrames.info.dungeondifficulty:Hide()
        MMFrames.info.lootSpec:Hide()
        MMFrames.info.queue:Hide()
        MMFrames.info.RFqueue:Hide()
        MMFrames.info.Squeue:Hide()
        MMFrames.info.zoneIndicator:Hide()
        numText = 1
    end
end

function MinimapAdv:AdjustCRFManager(CRFM, height, mapPoints)
    if (InCombatLockdown()) then
        return;
    end
    if not mapPoints then
        mapPoints = GetPositionData()
    end
    local yofs = (-height * mapPoints.scale) + (-self.numText * 13)
    local show = UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or not db.information.hideRaidFilters
    if CRFM.collapsed and mapPoints.anchor == "TOPLEFT" then
        CRFM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", show and -182 or -182, yofs)
    else
        CRFM:SetPoint("TOPLEFT", UIParent, "TOPLEFT", show and -7 or -7, yofs)
    end
end


-- Set Button positions
function MinimapAdv:UpdateButtonsPosition()
    local NewMinimapPoints = GetPositionData()

    local anchor = NewMinimapPoints.anchor
    local scale = NewMinimapPoints.scale
    local isTop = NewMinimapPoints.isTop
    local isLeft = NewMinimapPoints.isLeft
    local frameOrder = {
        "toggle",
    }

    -- Set visibility for Normal or Farm Mode
    local bfWidth = 21

    -- Config
    if Minimap:IsVisible() then
        MMFrames.config:Show()
        tinsert(frameOrder, "config")
        bfWidth = bfWidth + 15
    else
        MMFrames.config:Hide()
        MMFrames.config.mouseover = false
    end

    -- Tracking
    if Minimap:IsVisible() and ExpandedState == 0 then
        MMFrames.tracking:Show()
        tinsert(frameOrder, "tracking")
        bfWidth = bfWidth + 15
    else
        MMFrames.tracking:Hide()
        MMFrames.tracking.mouseover = false
    end

    -- Farm mode
    if ( Minimap:IsVisible() and (not IsInInstance()) ) then
        MMFrames.farm:Show()
        tinsert(frameOrder, "farm")
        bfWidth = bfWidth + 15
    else
        MMFrames.farm:Hide()
        MMFrames.farm.mouseover = false
    end

    -- Set button positions
    MMFrames.buttonframe:ClearAllPoints()
    MMFrames.buttonframe:SetPoint(anchor, "Minimap", isLeft and 1 or -1, isTop and -1 or 1)
    MMFrames.buttonframe:SetScale(1)
    MMFrames.buttonframe:Show()

    if isLeft then
        local prevFrame = MMFrames.buttonframe.edge
        prevFrame:ClearAllPoints()
        prevFrame:SetPoint("LEFT", MMFrames.buttonframe, 1, 0)
        for i = 1, #frameOrder do
            --print("Left", frameOrder[i])
            local frame = MMFrames[frameOrder[i]]
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", 0, 0)
            prevFrame = frame
        end
        MMFrames.buttonframe.tooltip:ClearAllPoints()
        MMFrames.buttonframe.tooltip:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", 9, -3)
    else
        local prevFrame = MMFrames.buttonframe.edge
        prevFrame:ClearAllPoints()
        prevFrame:SetPoint("RIGHT", MMFrames.buttonframe, -1, 0)
        for i = 1, #frameOrder do
            --print("Right", frameOrder[i])
            local frame = MMFrames[frameOrder[i]]
            frame:ClearAllPoints()
            frame:SetPoint("TOPRIGHT", prevFrame, "TOPLEFT", 0, 0)
            prevFrame = frame
        end
        MMFrames.buttonframe.tooltip:ClearAllPoints()
        MMFrames.buttonframe.tooltip:SetPoint("TOPRIGHT", prevFrame, "TOPLEFT", 0, -3)
    end

    if MMFrames.buttonframe.tooltip:IsShown() then
        MMFrames.buttonframe:SetWidth(Minimap:GetWidth() * scale + 2)
    else
        MMFrames.buttonframe:SetWidth(bfWidth)
    end

    self:FadeButtons()
end

-- Set Minimap position
function MinimapAdv:UpdateMinimapPosition()
    local NewMinimapPoints = GetPositionData()

    local xofs = NewMinimapPoints.xofs
    local yofs = NewMinimapPoints.yofs
    local anchor = NewMinimapPoints.anchor
    local scale = NewMinimapPoints.scale
    local opacity = NewMinimapPoints.opacity
    local isTop = NewMinimapPoints.isTop
    local isLeft = NewMinimapPoints.isLeft

    -- Set new size and position
    Minimap:SetFrameStrata("LOW")
    Minimap:SetFrameLevel(1)

    Minimap:SetSize(db.position.size, db.position.size)
    Minimap:SetScale(scale)
    Minimap:SetAlpha(opacity)

    Minimap:SetMovable(true)
    Minimap:ClearAllPoints()
    Minimap:SetPoint(anchor, "UIParent", anchor, xofs, yofs)
    Minimap:SetUserPlaced(true)

    -- Kinda dirty, but it works
    local LFDrpoint, LFDpoint, Qpoint, Gpoint
    if isTop then
        LFDpoint = "TOP"
        LFDrpoint = "TOP"
        Qpoint = "BOTTOM"
        Gpoint = "TOP"
    else
        LFDpoint = "BOTTOM"
        LFDrpoint = "BOTTOM"
        Qpoint = "TOP"
        Gpoint = "BOTTOM"
    end
    if isLeft then
        LFDpoint = LFDpoint .. "LEFT"
        LFDrpoint = LFDrpoint .. "RIGHT"
        Qpoint = Qpoint .. "RIGHT"
        Gpoint = Gpoint .. "RIGHT"
    else
        LFDpoint = LFDpoint .. "RIGHT"
        LFDrpoint = LFDrpoint .. "LEFT"
        Qpoint = Qpoint .. "LEFT"
        Gpoint = Gpoint .. "LEFT"
    end

    -- Queue Status
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetPoint(Qpoint, isLeft and 2 or -2, isTop and -2 or 2)

    -- LFD Button Tooltip
    QueueStatusFrame:ClearAllPoints()
    QueueStatusFrame:SetPoint(LFDpoint, "QueueStatusMinimapButton", LFDrpoint)
    QueueStatusFrame:SetClampedToScreen(true)

    -- Garrisons
    GarrisonLandingPageMinimapButton:ClearAllPoints()
    GarrisonLandingPageMinimapButton:SetPoint(Gpoint, isLeft and 2 or -2, isTop and 2 or -2)

    GarrisonLandingPageTutorialBox:ClearAllPoints()
    GarrisonLandingPageTutorialBox.Arrow:ClearAllPoints()
    if isTop then
        GarrisonLandingPageTutorialBox:SetPoint("TOP", GarrisonLandingPageMinimapButton, "BOTTOM", 0, -20)
        GarrisonLandingPageTutorialBox.Arrow:SetPoint("BOTTOM", GarrisonLandingPageTutorialBox, "TOP", 0, -3)
        SetClampedTextureRotation(GarrisonLandingPageTutorialBox.Arrow, 180)
    else
        GarrisonLandingPageTutorialBox:SetPoint("BOTTOM", GarrisonLandingPageMinimapButton, "TOP", 0, 20)
        GarrisonLandingPageTutorialBox.Arrow:SetPoint("TOP", GarrisonLandingPageTutorialBox, "BOTTOM", 0, 3)
        SetClampedTextureRotation(GarrisonLandingPageTutorialBox.Arrow, 0)
    end

    ButtonCollectFrame:ClearAllPoints()
    if isTop then
        ButtonCollectFrame:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -5)
    else
        ButtonCollectFrame:SetPoint("BOTTOMLEFT", Minimap, "TOPLEFT", -1, 5)
    end

    -- Update the rest of the Minimap
    self:UpdateButtonsPosition()
    self:UpdateInfoPosition()
    self:UpdateClickthrough()
end

---------------------
-- MINIMAP BUTTONS --
---------------------
local BlackList = {
    ["QueueStatusMinimapButton"] = true,
    ["GarrisonLandingPageMinimapButton"] = true,
    ["MiniMapTracking"] = true,
    ["MiniMapMailFrame"] = true,
    ["HelpOpenTicketButton"] = true,
    ["GameTimeFrame"] = true,
}
local OddList = {
    ["BagSync_MinimapButton"] = true,
    ["OutfitterMinimapButton"] = true,
}

local buttons = {}
local button = CreateFrame("Frame", "ButtonCollectFrame", UIParent)
button:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
})
button:SetBackdropBorderColor(0, 0, 0)
button:SetBackdropColor(0, 0, 0, .5)
button:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -5)
button:SetSize(136, 32)
button:EnableMouse(true)
button:SetAlpha(0)
button:Show()
button:HookScript("OnEnter", fadeIn)
button:HookScript("OnLeave", fadeOut)
local line = math.floor(button:GetWidth() / 32)

local function PositionAndStyle()
    local row = 0
    for i = 1, #buttons do
        if not buttons[i].styled then
            buttons[i]:SetParent(button)
            buttons[i]:ClearAllPoints()
            --print("Eval", i, i + line - 1, math.floor(row+1) * line, row)
            if i + line - 1 == math.floor(row + 1) * line then
                --print("Row start", i)
                buttons[i]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -(row * 32))
            else
                --print("Row cont.", i)
                buttons[i]:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 2, 0)
            end
            row = i / line
            buttons[i].ClearAllPoints = function() return end
            buttons[i].SetPoint = function() return end
            buttons[i]:HookScript("OnEnter", function() fadeIn(button) end)
            buttons[i]:HookScript("OnLeave", function() fadeOut(button) end)
            buttons[i].styled = true
        end
    end
    button:SetHeight(math.ceil(row) * 32)
end

local function MoveMMButton(mmb)
    if not mmb then return end
    if mmb.mmStyled then return end

    mmb:SetParent(button)
    tinsert(buttons, mmb)
    mmb.mmStyled = true
end

local function UpdateMMButtonsTable()
    for i, child in next, {Minimap:GetChildren()} do
        if not(BlackList[child:GetName()]) then
            if (child:GetObjectType() == "Button") and child:GetNumRegions() >= 3 and child:IsShown() then
                MoveMMButton(child)
            end
        end
    end
    for f, _ in pairs(OddList) do
        MoveMMButton(_G[f])
    end

    if #buttons == 0 then
        button:Hide()
    else
        button:Show()
    end
end

local collect = CreateFrame("Frame")
collect:RegisterEvent("PLAYER_ENTERING_WORLD")
collect:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event)
    if db.information.minimapbuttons then
        UpdateMMButtonsTable()
        PositionAndStyle()
    end
end)

-------------------------
-- INFORMATION UPDATES --
-------------------------
---- POI ----
-- POI Frame events
-- Show Tooltip
local POITooltip = CreateFrame("GameTooltip", "QuestPointerTooltip", UIParent, "GameTooltipTemplate")
local function POI_OnEnter(self)
    -- Set Tooltip's parent
    if UIParent:IsVisible() then
        POITooltip:SetParent(UIParent)
    else
        POITooltip:SetParent(self)
    end

    -- Set Tooltip position
    local NewMinimapPoints = GetPositionData()
    local mm_anchor = NewMinimapPoints.anchor
    if mm_anchor == "TOPLEFT" then
        POITooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10)
    elseif mm_anchor == "BOTTOMLEFT" then
        POITooltip:SetOwner(self, "ANCHOR_TOPMRIGHT", 5, 5)
    end

    -- Add Hyperlink
    local link = GetQuestLink(self.questLogIndex)
    if link then
        POITooltip:SetHyperlink(link)
    end

    if Aurora then
        Aurora[1].SetBD(POITooltip)
    end
end

-- Hide Tooltip
local function POI_OnLeave(self)
    POITooltip:Hide()
end

-- Open World Map at appropriate quest
local function POI_OnMouseUp(self)
    WorldMapFrame:Show()
    local frame = _G["WorldMapQuestFrame"..self.index]
    if not frame then
        return
    end
    WorldMapFrame_SelectQuestFrame(frame)
    MinimapAdv:SelectSpecificPOI(self)
end

-- Find closest POI
function MinimapAdv:ClosestPOI(all)
    local closest, closest_distance, poi_distance
    for k, poi in pairs(self.pois) do
        if poi.active then
            poi_distance = Astrolabe:GetDistanceToIcon(poi)

            if closest then
                if ( poi_distance and closest_distance and (poi_distance < closest_distance) ) then
                    closest = poi
                    closest_distance = poi_distance
                end
            else
                closest = poi
                closest_distance = poi_distance
            end
        end
    end
    return closest
end

function MinimapAdv:SelectSpecificPOI(self)
    QuestPOI_SelectButton(self.poiButton)
    SetSuperTrackedQuestID(self.questId)
    MinimapAdv:UpdatePOIGlow()
end

-- Select Closest POI
function MinimapAdv:SelectClosestPOI()
    if not db.poi.enabled then return end
    if IsAddOnLoaded("Carbonite") or IsAddOnLoaded("DugisGuideViewerZ") then return end

    local closest = self:ClosestPOI()
    if closest then
        self:SelectSpecificPOI(self)
    end
end

-- Update POI at edge of Minimap
function MinimapAdv:UpdatePOIEdges()
    for id, poi in pairs(pois) do
        if poi.active then
            if Astrolabe:IsIconOnEdge(poi) then
                poi.poiButton:Show()
                poi.poiButton:SetAlpha(db.poi.icons.opacity * (db.poi.fadeEdge and 0.6 or 1))
            else
                -- Hide completed POIs when close enough to see the ?
                if poi.complete then
                    poi.poiButton:Hide()
                else
                    poi.poiButton:Show()
                end
                poi.poiButton:SetAlpha(db.poi.icons.opacity)
            end
        end
    end
end

-- Update POI highlight
function MinimapAdv:UpdatePOIGlow()
    for i, poi in pairs(pois) do
        if GetSuperTrackedQuestID() == poi.questId then
            QuestPOI_SelectButton(poi.poiButton)
            poi:SetFrameLevel(Minimap:GetFrameLevel() + 3)
        else
            QuestPOI_ClearSelection(Minimap)
            poi:SetFrameLevel(Minimap:GetFrameLevel() + 2)
        end
    end
end

function MinimapAdv:RemoveAllPOIs()
    for i, poi in pairs(pois) do
        Astrolabe:RemoveIconFromMinimap(poi)
        if poi.poiButton then
            poi.poiButton:Hide()
            poi.poiButton:SetParent(Minimap)
            poi.poiButton = nil
        end
        poi.active = false
    end
end

-- Update all POIs
function MinimapAdv:POIUpdate(...)
    if ( (not db.poi.enabled) or (ExpandedState == 1 and db.expand.extras.hidepoi) ) then return end
    if IsAddOnLoaded("Carbonite") or IsAddOnLoaded("DugisGuideViewerZ") then return end

    self:RemoveAllPOIs()

    local c,z,x,y = Astrolabe:GetCurrentPlayerPosition()

    -- Update was probably triggered by World Map browsing. Don't update any POIs.
    if not (c and z and x and y) then return end

    QuestPOIUpdateIcons()

    local numNumericQuests = 0
    local numCompletedQuests = 0
    local numEntries = QuestMapUpdateAllQuests()
    -- Iterate through all available quests, retrieving POI info
    for i = 1, numEntries do
        local questID, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(i)
        if questID then
            local _, posX, posY, objective = QuestPOIGetIconInfo(questID)
            if ( posX and posY and (IsQuestWatched(questLogIndex) or not db.poi.watchedOnly) ) then
                local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, _, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isStory = GetQuestLogTitle(questLogIndex)
                local numObjectives = GetNumQuestLeaderBoards(questLogIndex)
                if isComplete and isComplete < 0 then
                    isComplete = false
                elseif numObjectives == 0 then
                    isComplete = true
                end

                -- Create POI arrow
                local poi = pois[i]
                if not poi then
                    poi = CreateFrame("Frame", "QuestPointerPOI"..i, Minimap)
                    poi:SetFrameLevel(Minimap:GetFrameLevel() + 2)
                    poi:SetWidth(10)
                    poi:SetHeight(10)
                    poi:SetScript("OnEnter", POI_OnEnter)
                    poi:SetScript("OnLeave", POI_OnLeave)
                    poi:SetScript("OnMouseUp", POI_OnMouseUp)
                    poi:EnableMouse()
                end

                -- Create POI button
                local poiButton
                if isComplete then
                    -- Using QUEST_POI_COMPLETE_SWAP gets the ? without any circle
                    -- Using QUEST_POI_COMPLETE_IN gets the ? in a brownish circle
                    numCompletedQuests = numCompletedQuests + 1
                    poiButton = QuestPOI_GetButton(Minimap, questID)--, "completed", numCompletedQuests)
                else
                    numNumericQuests = numNumericQuests + 1
                    poiButton = QuestPOI_GetButton(Minimap, questID, "numeric", numNumericQuests, isStory)
                end
                poiButton:SetPoint("CENTER", poi)
                poiButton:SetScale(db.poi.icons.scale)
                poiButton:SetParent(poi)
                poiButton:EnableMouse(false)
                poi.poiButton = poiButton

                poi.index = i
                poi.questID = questID
                poi.questLogIndex = questLogIndex
                poi.c = c
                poi.z = z
                poi.x = posX
                poi.y = posY
                poi.title = title
                poi.active = true
                poi.complete = isComplete

                Astrolabe:PlaceIconOnMinimap(poi, c, z, posX, posY)

                pois[i] = poi
            else
                -- Skipped
            end
        end
    end
    self:UpdatePOIEdges()
    self:UpdatePOIGlow()
end

function MinimapAdv:InitializePOI()
    -- This would be needed for switching to a different look when icons are on the edge of the minimap.
    Astrolabe:Register_OnEdgeChanged_Callback(function(...)
        self:UpdatePOIEdges()
    end, "MinimapAdv")

    -- Update POI timer
    local GlowTimer = CreateFrame("Frame")
    GlowTimer.elapsed = 0
    GlowTimer:SetScript("OnUpdate", function(self, elapsed)
        GlowTimer.elapsed = GlowTimer.elapsed + elapsed
        if ( (GlowTimer.elapsed > 2) and (not WorldMapFrame:IsShown()) and db.poi.enabled ) then
            GlowTimer.elapsed = 0
            MinimapAdv:UpdatePOIGlow()
        end
    end)
end

function MinimapAdv:UpdatePOIEnabled()
    if db.poi.enabled and not(IsAddOnLoaded("Carbonite") or IsAddOnLoaded("DugisGuideViewerZ")) then
        QuestPOI_Initialize(Minimap, function(self) end)
        self:POIUpdate()
        self:InitializePOI()
    else
        self:RemoveAllPOIs()
    end
end

function MinimapAdv:GetLFGQueue()
    for i=1, NUM_LE_LFG_CATEGORYS do
        local mode, submode = GetLFGMode(i)
        if ( mode ) then
            self:QueueTimeUpdate(i)
        end
    end
end

---- Queue Time ----
function MinimapAdv:QueueTimeUpdate(category)
    local mode, submode = GetLFGMode(category)
    if mode == "queued" then
        local queueStr = ""
        local hasData, _, _, _, _, _, _, _, _, _, _, _, _, _, _, myWait, queuedTime = GetLFGQueueStats(category)

        if not hasData then
            queueStr = LESS_THAN_ONE_MINUTE
        else
            local elapsedTime = GetTime() - queuedTime
            local tiqStr = strform("%s", ConvertSecondstoTime(elapsedTime))
            local awtStr = strform("%s", myWait == -1 and TIME_UNKNOWN or SecondsToTime(myWait, false, false, 1))
            queueStr = strform("%s |cffc0c0c0(%s)|r", tiqStr, awtStr)
        end

        local colorOrange = nibRealUI:ColorTableToStr(nibRealUI.media.colors.orange)
        if category == 1 then -- Dungeon Finder
            MMFrames.info.queue.text:SetText("|cff"..colorOrange.."DF:|r "..queueStr)
            MMFrames.info.queue:SetWidth(MMFrames.info.queue.text:GetStringWidth() + 12)
            InfoShown.queue = true
        elseif category == 3 then -- Raid Finder
            MMFrames.info.RFqueue.text:SetText("|cff"..colorOrange.."RF:|r "..queueStr)
            MMFrames.info.RFqueue:SetWidth(MMFrames.info.RFqueue.text:GetStringWidth() + 12)
            InfoShown.RFqueue = true
        elseif category == 4 then -- Scenarios
            MMFrames.info.Squeue.text:SetText("|cff"..colorOrange.."S:|r "..queueStr)
            MMFrames.info.Squeue:SetWidth(MMFrames.info.Squeue.text:GetStringWidth() + 12)
            InfoShown.Squeue = true
        end
    else
        -- Set to hide Queue time
        InfoShown.queue = false
        InfoShown.RFqueue = false
        InfoShown.Squeue = false
    end
    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end

function MinimapAdv:QueueTimeFrequentCheck()
    if InfoShown.queue or InfoShown.RFqueue or InfoShown.Squeue then
        self:GetLFGQueue()
    end
end

--[[ Dungeon Difficulty ----
    ID - "Name"
    1  - "Normal"
    2  - "Heroic"
    3  - "10 Player"
    4  - "25 Player"
    5  - "10 Player (Heroic)"
    6  - "25 Player (Heroic)"
    7  - "Looking For Raid"
    8  - "Challenge Mode"
    9  - "40 Player"
    10 - nil
    11 - "Heroic Scenario"
    12 - "Normal Scenario"
    13 - nil
    14 - "Normal"  10-30 Player
    15 - "Heroic"  10-30 Player
    16 - "Mythic"  20 Player
    17 - "Looking For Raid" 10-25 Player
]]--
function MinimapAdv:DungeonDifficultyUpdate()
    self:debug("DungeonDifficultyUpdate")
    -- If in a Party/Raid then show Dungeon Difficulty text
    MMFrames.info.dungeondifficulty.text:SetText("")
    local instanceName, instanceType, difficulty, _, maxPlayers, _, _, _, currPlayers = GetInstanceInfo()
    local name, groupType, isHeroic, isChallengeMode = GetDifficultyInfo(difficulty)
    self:debug("instanceType", instanceType)
    local isInGarrison = instanceName:find("Garrison")
    if instanceType ~= "none" and not instanceName:find("Garrison") then
        if (instanceType == "party" or instanceType == "scenario") and (maxPlayers <= 5) then
            self.DifficultyText = "D: "..maxPlayers
            if isChallengeMode then self.DifficultyText = self.DifficultyText.."+" end
        elseif (instanceType == "raid") then
            self.DifficultyText = "R: "

            --Set raid size
            if (difficulty <= 9) or (difficulty == 16) then
                --Legacy raids and Mythic are fixed size
                self.DifficultyText = self.DifficultyText..maxPlayers
            else
                --Current Normal, Heroic, and LFR are flexible
                self.DifficultyText = self.DifficultyText..currPlayers
            end

            --Give Mythic double "+" because it's #Hardcore
            if (difficulty == 16) then
                --Mythic gets the isHeroic flag
                self.DifficultyText = self.DifficultyText.."+"
            elseif (difficulty == 15) then
                --Heroic does not
                self.DifficultyText = self.DifficultyText.."+"
            end
        else
            self.DifficultyText = "PvP: "
            if (instanceType == "arena") then
                self.DifficultyText = self.DifficultyText..currPlayers
            else
                self.DifficultyText = self.DifficultyText..maxPlayers
            end
        end

        if isHeroic then self.DifficultyText = self.DifficultyText.."+" end

        -- Update Frames
        MMFrames.info.dungeondifficulty.text:SetText(self.DifficultyText.." ")
        MMFrames.info.dungeondifficulty:EnableMouse(true)
        MMFrames.info.dungeondifficulty:SetWidth(MMFrames.info.dungeondifficulty.text:GetStringWidth() + 12)

        -- Set to show DungeonDifficulty
        InfoShown.dungeondifficulty = true
    else
        self.DifficultyText = ""
        -- Set to hide DungeonDifficulty
        InfoShown.dungeondifficulty = false
    end
    if self.IsGuildGroup then
        self.DifficultyText = self.DifficultyText.."("..GUILD..")"
        MMFrames.info.dungeondifficulty:SetScript("OnEnter", function(self)
            local guildName = GetGuildInfo("player")
            local _, instanceType, _, _, maxPlayers = GetInstanceInfo()
            local _, numGuildPresent, numGuildRequired = InGuildParty()
            if instanceType == "arena" then
                maxPlayers = numGuildRequired
            end
            GameTooltip:SetOwner(MMFrames.info.dungeondifficulty, "ANCHOR_RIGHT", 18)
            GameTooltip:SetText(GUILD_GROUP, 1, 1, 1)
            GameTooltip:AddLine(strform(GUILD_ACHIEVEMENTS_ELIGIBLE, numGuildRequired, maxPlayers, guildName), nil, nil, nil, 1)
            GameTooltip:Show()
        end)
        MMFrames.info.dungeondifficulty:SetScript("OnLeave", function()
            if GameTooltip:IsShown() then GameTooltip:Hide() end
        end)
    else
        MMFrames.info.dungeondifficulty:SetScript("OnEnter", nil)
    end
    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end

    -- Loot Spec
    self:LootSpecUpdate()
end

function MinimapAdv:UpdateGuildPartyState(event, ...)
    -- Update Guild info and then update Dungeon Difficulty
    if event == "GUILD_PARTY_STATE_UPDATED" then
        local isGuildGroup = ...
        if isGuildGroup ~= self.IsGuildGroup then
            self.IsGuildGroup = isGuildGroup
            self:DungeonDifficultyUpdate()
        end
    else
        if IsInGuild() then
            RequestGuildPartyState()
        else
            self.IsGuildGroup = nil
        end
    end
end

function MinimapAdv:InstanceDifficultyOnEvent(event, ...)
    self:debug("InstanceDifficultyOnEvent", event, ...)
    self:DungeonDifficultyUpdate()
end

---- Loot Specialization ----
function MinimapAdv:LootSpecUpdate()
    -- If in a Dungeon, Raid or Garrison show Loot Spec
    local _, instanceType = GetInstanceInfo()
    if (instanceType == "party" or instanceType == "raid") then
        MMFrames.info.lootSpec.text:SetText("|cff"..nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue)..LOOT..":|r "..nibRealUI:GetCurrentLootSpecName())
        MMFrames.info.lootSpec:SetWidth(MMFrames.info.lootSpec.text:GetStringWidth() + 12)
        InfoShown.lootSpec = true
    else
        MMFrames.info.lootSpec.text:SetText("")
        InfoShown.lootSpec = false
    end

    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end


---- Coordinates ----
local coords_int = 0.5
function MinimapAdv:CoordsUpdate()
    if (IsInInstance() or not(Minimap:IsVisible()) or self.StationaryTime >= 10) then   -- Hide Coords
        MMFrames.info.coords:SetScript("OnUpdate", nil)
        InfoShown.coords = false
    else    -- Show Coords
        MMFrames.info.coords:SetScript("OnUpdate", function(self, elapsed)
            coords_int = coords_int - elapsed
            if (coords_int <= 0) then
                local X, Y = GetPlayerMapPosition("player")
                MMFrames.info.coords.text:SetText(strform("%.1f  %.1f", X*100, Y*100))
                MMFrames.info.coords:SetWidth(MMFrames.info.coords.text:GetStringWidth())
                coords_int = 0.5
            end
        end)
        InfoShown.coords = true
    end
    if not UpdateProcessing then self:UpdateInfoPosition() end
end

---------------------
-- MINIMAP UPDATES --
---------------------
function MinimapAdv:MovementUpdate()
    if not(db.information.coordDelayHide) or IsInInstance() or not(Minimap:IsVisible()) then return end

    local X, Y = GetPlayerMapPosition("player")
    if X == self.LastX and Y == self.LastY then
        self.StationaryTime = self.StationaryTime + 0.5
    else
        self.StationaryTime = 0
    end
    self.LastX = X
    self.LastY = Y

    if ((self.StationaryTime >= 10) and (InfoShown.coords)) or ((self.StationaryTime < 10) and not(InfoShown.coords)) then
        self:CoordsUpdate()
    end
end

function MinimapAdv:Update()
    UpdateProcessing = true     -- Stops individual update functions from calling UpdateInfoPosition
    self:CoordsUpdate()
    self:DungeonDifficultyUpdate()
    self:UpdateButtonsPosition()
    UpdateProcessing = false
end

-- Set Minimap visibility
function MinimapAdv:Toggle(shown)
    if shown then
        Minimap:Show()
        MMFrames.toggle.icon:SetTexture(Textures.Minimize)
    else
        Minimap:Hide()
        MMFrames.toggle.icon:SetTexture(Textures.Maximize)
    end
    self:Update()
end

-- Determine what visibility state the Minimap should be in
function MinimapAdv:UpdateShownState()
    local Inst, InstType = IsInInstance()
    local MinimapShown = true
    if Inst then
        if db.hidden.enabled then
            if (InstType == "pvp" and db.hidden.zones.pvp) then         -- Battlegrounds
                MinimapShown = false
            elseif (InstType == "arena" and db.hidden.zones.arena) then -- Arena
                MinimapShown = false
            elseif (InstType == "party" and db.hidden.zones.party) then -- 5 Man Dungeons
                MinimapShown = false
            elseif (InstType == "raid" and db.hidden.zones.raid) then   -- Raid Dungeons
                MinimapShown = false
            end
        end

        -- Disable Farm Mode while in dungeon
        if ExpandedState ~= 0 then
            ExpandedState = 0
            self:ToggleGatherer()
            self:UpdateMinimapPosition()
        end
    end
    self:Toggle(MinimapShown)
end


-------------
-- BUTTONS --
-------------
---- Fade
function MinimapAdv:FadeButtons()
    local NewMinimapPoints = GetPositionData()
    local scale = NewMinimapPoints.scale

    if Minimap:IsVisible() then
        if Minimap.mouseover or MMFrames.toggle.mouseover or MMFrames.config.mouseover or MMFrames.tracking.mouseover or MMFrames.farm.mouseover then
            local numButtons = 2

            if ExpandedState == 0 then
                MMFrames.tracking:Show()
                numButtons = numButtons + 1
            end
            if not IsInInstance() then
                MMFrames.farm:Show()
                numButtons = numButtons + 1
            end

            if MMFrames.buttonframe.tooltip:IsShown() and (ExpandedState == 0) then
                MMFrames.buttonframe:SetWidth(Minimap:GetWidth() * scale + 2)
            else
                MMFrames.buttonframe.tooltip:Hide()
                MMFrames.buttonframe.tooltipIcon:Hide()
                MMFrames.buttonframe:SetWidth(6 + numButtons * 15)
            end

            MMFrames.buttonframe:Show()
        else
            MMFrames.buttonframe:Hide()
            MMFrames.tracking:Hide()
            MMFrames.farm:Hide()
        end
    else

    end
end

---- Toggle Button ----
local function Toggle_OnMouseDown()
    local MinimapShown = Minimap:IsVisible()
    if MinimapShown then
        PlaySound("igMiniMapClose")
        MinimapAdv:Toggle(false)
    else
        PlaySound("igMiniMapOpen")
        MinimapAdv:Toggle(true)
    end
    if DropDownList1 then DropDownList1:Hide() end
    if DropDownList2 then DropDownList2:Hide() end
end

function MinimapAdv:ToggleBind()
    Toggle_OnMouseDown()
end

local function Toggle_OnEnter()
    MMFrames.toggle.mouseover = true

    MMFrames.toggle.icon:SetVertexColor(unpack(nibRealUI.classColor))
    MMFrames.toggle:SetFrameLevel(6)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

local function Toggle_OnLeave()
    MMFrames.toggle.mouseover = false

    MMFrames.toggle.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.toggle:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

---- Config Button ----
local function Config_OnMouseDown()
    nibRealUI:LoadConfig("nibRealUI", "modules", "MinimapAdv")

    if DropDownList1 then DropDownList1:Hide() end
    if DropDownList2 then DropDownList2:Hide() end
end

local function Config_OnEnter()
    MMFrames.config.mouseover = true

    MMFrames.config.icon:SetVertexColor(unpack(nibRealUI.classColor))
    MMFrames.config:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Options")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Config_OnLeave()
    MMFrames.config.mouseover = false

    MMFrames.config.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.config:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()

    if GameTooltip:IsShown() then GameTooltip:Hide() end
end

---- Tracking Button ----
local function Tracking_OnMouseDown()
    ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "MinimapAdv_Tracking", 0, 0)
end

local function Tracking_OnEnter()
    MMFrames.tracking.mouseover = true

    MMFrames.tracking.icon:SetVertexColor(unpack(nibRealUI.classColor))
    MMFrames.tracking:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Tracking")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Tracking_OnLeave()
    MMFrames.tracking.mouseover = false

    MMFrames.tracking.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.tracking:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()

    if GameTooltip:IsShown() then GameTooltip:Hide() end
end

---- Farm Button ----
function MinimapAdv:ToggleGatherer()
    if ( (not db.expand.extras.gatherertoggle) or (not Gatherer) ) then return end

    if ExpandedState == 1 then
        Gatherer.Config.SetSetting("minimap.enable", true)
    else
        Gatherer.Config.SetSetting("minimap.enable", false)
    end
end

local function Farm_OnMouseDown()
    if ExpandedState == 0 then
        ExpandedState = 1
        MMFrames.farm.icon:SetTexture(Textures.Collapse)
        PlaySound("igMiniMapOpen")
        button:Hide()
    else
        ExpandedState = 0
        MMFrames.farm.icon:SetTexture(Textures.Expand)
        PlaySound("igMiniMapClose")
        button:Show()
    end
    if DropDownList1 then DropDownList1:Hide() end
    if DropDownList2 then DropDownList2:Hide() end

    MinimapAdv:ToggleGatherer()
    MinimapAdv:UpdateMinimapPosition()
    MinimapAdv:UpdateFarmModePOI()
end

function MinimapAdv:FarmBind()
    if IsInInstance() then return end
    Farm_OnMouseDown()
end

local function Farm_OnEnter()
    MMFrames.farm.mouseover = true

    MMFrames.farm.icon:SetVertexColor(unpack(nibRealUI.classColor))
    MMFrames.farm:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Farm Mode")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Farm_OnLeave()
    MMFrames.farm.mouseover = false

    MMFrames.farm.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.farm:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

--[[ Garrison
--The pulse anim that these function call will reset the alpha of the whole button each time it repeats.
--This was the only reliable way I could find to get this button back to full opacity.
local oldGarrisonMinimapBuilding_ShowPulse = GarrisonMinimapBuilding_ShowPulse
GarrisonMinimapBuilding_ShowPulse = function(self)
    print("Pre-hook: Building")
    self:SetAlpha(1)
    return oldGarrisonMinimapBuilding_ShowPulse(self)
end
local oldGarrisonMinimapMission_ShowPulse = GarrisonMinimapMission_ShowPulse
GarrisonMinimapMission_ShowPulse = function(self)
    print("Pre-hook: Mission")
    self:SetAlpha(1)
    return oldGarrisonMinimapMission_ShowPulse(self)
end
local oldGarrisonMinimapInvasion_ShowPulse = GarrisonMinimapInvasion_ShowPulse
GarrisonMinimapInvasion_ShowPulse = function(self)
    print("Pre-hook: Invasion")
    self:SetAlpha(1)
    return oldGarrisonMinimapInvasion_ShowPulse(self)
end
local oldGarrisonMinimapShipmentCreated_ShowPulse = GarrisonMinimapShipmentCreated_ShowPulse
GarrisonMinimapShipmentCreated_ShowPulse = function(self)
    print("Pre-hook: Shipment")
    self:SetAlpha(1)
    return oldGarrisonMinimapShipmentCreated_ShowPulse(self)
end

--GarrisonLandingPageTutorialBox:Show()
--GarrisonMinimapMission_ShowPulse(GarrisonLandingPageMinimapButton)

local function hookfunc(self, lock, enabled)
    print("hookfunc", self, lock, enabled)
    if enabled then
        self:SetAlpha(1)
    else
        self:SetAlpha(0)
    end
end
]]--

local function Garrison_OnEnter(self)
    local isLeft = db.position.anchorto:find("LEFT")
    --print("Garrison_OnEnter")
    GameTooltip:SetOwner(GarrisonLandingPageMinimapButton, "ANCHOR_" .. (isLeft and "RIGHT" or "LEFT"));
    GameTooltip:SetText(GARRISON_LANDING_PAGE_TITLE, 1, 1, 1);
    GameTooltip:AddLine(MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP, nil, nil, nil, true);
    GameTooltip:Show();
    --fadeIn(self)
end

local function Garrison_OnLeave(self)
    fadeOut(self)
end

---- Minimap
local function Minimap_OnEnter()
    Minimap.mouseover = true
    MinimapAdv:FadeButtons()
end

local function Minimap_OnLeave()
    Minimap.mouseover = false
    MinimapAdv:FadeButtons()
end

------------
-- EVENTS --
------------
local hostilePvPTypes = {
    arena = true,
    hostile = true,
    contested = true,
    combat = true,
}
function MinimapAdv:ZoneChange()
    local r, g, b = 0.5, 0.5, 0.5
    local pvpType = GetZonePVPInfo()
    if pvpType == "sanctuary" then
        r, g, b = 0.41, 0.8, 0.94
    elseif pvpType == "arena" then
        r, g, b = 1, 0.1, 0.1
    elseif pvpType == "friendly" then
        r, g, b = 0.2, 0.9, 0.2
    elseif pvpType == "hostile" then
        r, g, b = 1, 0.15, 0.15
    elseif pvpType == "contested" then
        r, g, b = 1, 0.7, 0
    elseif pvpType == "combat" then
        r, g, b = 1, 0, 0
    end

    MMFrames.info.zoneIndicator.bg:SetVertexColor(r, g, b)
    MMFrames.info.zoneIndicator.isHostile = hostilePvPTypes[pvpType]
    if MMFrames.info.zoneIndicator.isHostile then
        MMFrames.info.zoneIndicator:Show()
    else
        MMFrames.info.zoneIndicator:Hide()
    end

    local oldName = GetMinimapZoneText()
    local zName = (strlen(oldName) > 22) and gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1.") or oldName
    if strlen(zName) > 22 then
        zName = strsub(zName, 1, 20)..".."
    end

    MMFrames.info.location.text:SetText(zName)
    MMFrames.info.location.text:SetTextColor(r, g, b)
    MMFrames.info.location:SetWidth(MMFrames.info.location.text:GetWidth() + 4)

    RefreshMap = true
end

function MinimapAdv:ZONE_CHANGED_NEW_AREA()
    SetMapToCurrentZone()
    self:ZoneChange()

    -- Update POIs
    self:POIUpdate()
end

function MinimapAdv:MINIMAP_UPDATE_ZOOM()
    ZoomMinimapOut()
    self:UnregisterEvent("MINIMAP_UPDATE_ZOOM")
end

function MinimapAdv:PLAYER_ENTERING_WORLD()
    -- Hide persistent Minimap elements
    GameTimeFrame:Hide()
    GameTimeFrame.Show = function() end

    -- Update specific information
    self:DungeonDifficultyUpdate()

    -- Update Minimap position and visible state
    self:UpdateMinimapPosition()
    self:UpdateShownState() -- Will also call MinimapAdv:Update

    -- Update POIs
    self:UpdatePOIEnabled()

    -- Timer
    RefreshMap = true
    RefreshZoom = true
    RefreshTimer:Show()
end

-- Hide default Clock Button
function MinimapAdv:ADDON_LOADED(event, ...)
    --print("MinimapAdv:", event, ...)
    local addon = ...
    if addon == "Blizzard_TimeManager" then
        TimeManagerClockButton:HookScript("OnShow", function()
            TimeManagerClockButton:Hide()
        end)
        TimeManagerClockButton:Hide()
    end
end

function MinimapAdv:PLAYER_LOGIN()
    MMFrames.buttonframe.edge:SetTexture(unpack(nibRealUI.classColor))
end

-- Register events
function MinimapAdv:RegEvents()
    -- Hook into Blizzard addons
    self:RegisterEvent("ADDON_LOADED")

    -- Basic settings
    self:RegisterEvent("PLAYER_LOGIN")

    -- Initialise settings on UI load
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- Set Minimap Zoom
    self:RegisterEvent("MINIMAP_UPDATE_ZOOM")

    -- Location
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterBucketEvent({
        "ZONE_CHANGED",
        "ZONE_CHANGED_INDOORS",
        "WORLD_MAP_UPDATE",
    }, 0.2, "ZoneChange")

    -- Dungeon Difficulty
    self:RegisterEvent("GUILD_PARTY_STATE_UPDATED", "UpdateGuildPartyState")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuildPartyState")
    self:RegisterBucketEvent({
        "PLAYER_DIFFICULTY_CHANGED",
        "UPDATE_INSTANCE_INFO",
        "PARTY_MEMBERS_CHANGED",
        "PARTY_MEMBER_ENABLE",
        "PARTY_MEMBER_DISABLE",
    }, 1, "InstanceDifficultyOnEvent")

    -- Queue
    self:RegisterEvent("LFG_UPDATE", "GetLFGQueue")
    self:RegisterEvent("LFG_PROPOSAL_SHOW", "GetLFGQueue")
    self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", "GetLFGQueue")

    -- POI
    self:RegisterEvent("QUEST_POI_UPDATE", "POIUpdate")
    self:RegisterEvent("QUEST_LOG_UPDATE", "POIUpdate")

    local UpdatePOICall = function() self:POIUpdate() end
    hooksecurefunc("AddQuestWatch", UpdatePOICall)
    hooksecurefunc("RemoveQuestWatch", UpdatePOICall)

    -- Player Coords
    self.LastX = 0
    self.LastY = 0
    self.StationaryTime = 0
    -- self:RegisterEvent("PLAYER_STARTED_MOVING", function(...)
    local function MovementTimerUpdate()
        MinimapAdv:MovementUpdate()
    end
    self.coordsTicker = C_Timer.NewTicker(0.5, MovementTimerUpdate)
    -- end)
    -- self:RegisterEvent("PLAYER_STOPPED_MOVING", function(...)
        -- self.coordsTicker:Cancel()
    -- end)
end

--------------------------
-- FRAME INITIALIZATION --
--------------------------
-- Update Frame fonts
function MinimapAdv:UpdateFonts()
    -- Retrieve Font variables
    local font1 = {RealUIFont_PixelSmall:GetFont()}
    local font2 = {RealUIFont_Pixel:GetFont()}
    local fontSize
    Font1:SetFont(font1[1], font1[2] / db.position.scale, font1[3])
    Font2:SetFont(font2[1], font2[2] / db.position.scale, font2[3])
    fontSize = font2[2]

    -- Set Info font
    local fs
    for k,v in pairs(MMFrames.info) do
        fs = MMFrames.info[k].text
        if fs then
            fs:SetPoint("LEFT", MMFrames.info[k], "LEFT", 0.5, 0.5)
            if fs.style == 1 then
                fs:SetFontObject("MinimapFont1")
            else
                fs:SetFontObject("MinimapFont2")
            end
            fs:SetJustifyH("LEFT")
            MMFrames.info[k]:SetHeight(fontSize)
        end
    end
end

-- Frame Template
local function NewInfoFrame(name, parent, size2)
    local NewFrame

    NewFrame = CreateFrame("Frame", name, parent)
    NewFrame:SetHeight(12)
    NewFrame:SetWidth(12)
    NewFrame:SetFrameStrata("LOW")
    NewFrame:SetFrameLevel(5)

    NewFrame.text = NewFrame:CreateFontString(nil, "ARTWORK")
    if size2 then
        NewFrame.text.style = 2
    else
        NewFrame.text.style = 1
    end

    return NewFrame
end

-- Create Information/Toggle frames
local function CreateButton(Name, Texture, index)
    local NewButton

    NewButton = CreateFrame("Frame", Name, MMFrames.buttonframe)
    NewButton:SetPoint("BOTTOMLEFT", MMFrames.buttonframe, "BOTTOMLEFT", 5 + ((index -1) * 15), 1)
    NewButton:SetHeight(15)
    NewButton:SetWidth(15)
    NewButton:EnableMouse(true)
    NewButton:Show()

    NewButton.icon = NewButton:CreateTexture(nil, "ARTWORK")
    NewButton.icon:SetTexture(Texture)
    NewButton.icon:SetVertexColor(0.8, 0.8, 0.8)
    NewButton.icon:SetPoint("BOTTOMLEFT", NewButton, "BOTTOMLEFT", 0, 0)
    NewButton.icon:SetHeight(16)
    NewButton.icon:SetWidth(16)

    return NewButton
end

local function CreateFrames()
    -- Set up Frame table
    MinimapAdv.Frames = {
        toggle = nil,
        config = nil,
        tracking = nil,
        farm = nil,
        info = {},
    }
    MMFrames = MinimapAdv.Frames

    ---- Buttons
    MMFrames.buttonframe = CreateFrame("Frame", nil, UIParent)
    MMFrames.buttonframe:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 1, -1)
    MMFrames.buttonframe:SetSize(66, 17)
    MMFrames.buttonframe:SetFrameStrata("MEDIUM")
    MMFrames.buttonframe:SetFrameLevel(5)
    nibRealUI:CreateBD(MMFrames.buttonframe, nil, true, true)
    MMFrames.buttonframe.edge = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.edge:SetTexture(1, 1, 1, 1)
    MMFrames.buttonframe.edge:SetPoint("LEFT", MMFrames.buttonframe, "LEFT", 1, 0)
    MMFrames.buttonframe.edge:SetSize(4, 15)

    MMFrames.buttonframe.tooltip = MMFrames.buttonframe:CreateFontString()
    MMFrames.buttonframe.tooltip:SetPoint("BOTTOMLEFT", MMFrames.buttonframe, "BOTTOMLEFT", 78.5, 4.5)
    MMFrames.buttonframe.tooltip:SetFontObject("MinimapFont1")
    MMFrames.buttonframe.tooltip:SetTextColor(0.8, 0.8, 0.8)
    MMFrames.buttonframe.tooltip:Hide()

    MMFrames.buttonframe.tooltipIcon = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.tooltipIcon:SetPoint("BOTTOMRIGHT", MMFrames.buttonframe.tooltip, "BOTTOMLEFT", -1.5, -0.5)
    MMFrames.buttonframe.tooltipIcon:SetWidth(16)
    MMFrames.buttonframe.tooltipIcon:SetHeight(16)
    MMFrames.buttonframe.tooltipIcon:SetTexture(Textures.TooltipIcon)
    MMFrames.buttonframe.tooltipIcon:SetVertexColor(unpack(nibRealUI.classColor))
    MMFrames.buttonframe.tooltipIcon:Hide()

    -- Toggle Button
    MMFrames.toggle = CreateButton("MinimapAdv_Toggle", Textures.Minimize, 1)
    MMFrames.toggle:SetScript("OnEnter", Toggle_OnEnter)
    MMFrames.toggle:SetScript("OnLeave", Toggle_OnLeave)
    MMFrames.toggle:SetScript("OnMouseDown", Toggle_OnMouseDown)

    -- Config Button
    MMFrames.config = CreateButton("MinimapAdv_Config", Textures.Config, 2)
    MMFrames.config:SetScript("OnEnter", Config_OnEnter)
    MMFrames.config:SetScript("OnLeave", Config_OnLeave)
    MMFrames.config:SetScript("OnMouseDown", Config_OnMouseDown)

    -- Tracking Button
    MMFrames.tracking = CreateButton("MinimapAdv_Tracking", Textures.Tracking, 3)
    MMFrames.tracking:SetScript("OnEnter", Tracking_OnEnter)
    MMFrames.tracking:SetScript("OnLeave", Tracking_OnLeave)
    MMFrames.tracking:SetScript("OnMouseDown", Tracking_OnMouseDown)

    -- Farm Button
    MMFrames.farm = CreateButton("MinimapAdv_Farm", Textures.Expand, 4)
    MMFrames.farm:SetScript("OnEnter", Farm_OnEnter)
    MMFrames.farm:SetScript("OnLeave", Farm_OnLeave)
    MMFrames.farm:SetScript("OnMouseDown", Farm_OnMouseDown)

    -- Info
    MMFrames.info.location = NewInfoFrame("MinimapAdv_Location", Minimap, true)
    MMFrames.info.coords = NewInfoFrame("MinimapAdv_Coords", Minimap)
    MMFrames.info.coords:SetAlpha(0.75)
    MMFrames.info.dungeondifficulty = NewInfoFrame("MinimapAdv_DungeonDifficulty", Minimap, true)
    MMFrames.info.lootSpec = NewInfoFrame("MinimapAdv_LootSpec", Minimap, true)
    MMFrames.info.queue = NewInfoFrame("MinimapAdv_Queue", Minimap, true)
    MMFrames.info.RFqueue = NewInfoFrame("MinimapAdv_RFQueue", Minimap, true)
    MMFrames.info.Squeue = NewInfoFrame("MinimapAdv_SQueue", Minimap, true)

    -- Zone Indicator
    MMFrames.info.zoneIndicator = CreateFrame("Frame", "MinimapAdv_Zone", Minimap)
    MMFrames.info.zoneIndicator:SetHeight(16)
    MMFrames.info.zoneIndicator:SetWidth(16)
    MMFrames.info.zoneIndicator:SetFrameStrata("MEDIUM")
    MMFrames.info.zoneIndicator:SetFrameLevel(5)
    MMFrames.info.zoneIndicator:ClearAllPoints()
    MMFrames.info.zoneIndicator:SetPoint("BOTTOMRIGHT", "Minimap", "BOTTOMRIGHT", 1, -1)

    MMFrames.info.zoneIndicator.bg = MMFrames.info.zoneIndicator:CreateTexture(nil, "BACKGROUND")
    MMFrames.info.zoneIndicator.bg:SetTexture(Textures.ZoneIndicator)
    MMFrames.info.zoneIndicator.bg:SetVertexColor(0.5, 0.5, 0.5)
    MMFrames.info.zoneIndicator.bg:SetAllPoints(MMFrames.info.zoneIndicator)

    -- Update Fonts
    MinimapAdv:UpdateFonts()
end

-------------------
-- MINIMAP FRAME --
-------------------
local function SetUpMinimapFrame()
    -- Establish Scroll Wheel zoom
    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()
    Minimap:EnableMouseWheel()
    Minimap:SetScript("OnMouseWheel", function(self, direction)
        if direction > 0 then
            MinimapZoomIn:Click()
        else
            MinimapZoomOut:Click()
        end
    end)
    Minimap:SetScript("OnEnter", Minimap_OnEnter)
    Minimap:SetScript("OnLeave", Minimap_OnLeave)

    -- Hide/Move Minimap elements
    MiniMapTracking:Hide()

    MiniMapMailFrame:Hide()
    MiniMapMailFrame.Show = function() end

    MinimapZoneText:Hide()
    MinimapZoneTextButton:Hide()

    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetParent(Minimap)
    QueueStatusMinimapButton:SetPoint('BOTTOMRIGHT', 2, -2)
    QueueStatusMinimapButtonBorder:Hide()

    GarrisonLandingPageTutorialBox:SetParent(Minimap)
    --GarrisonLandingPageMinimapButton:SetAlpha(0)
    GarrisonLandingPageMinimapButton:SetParent(Minimap)
    GarrisonLandingPageMinimapButton:ClearAllPoints()
    GarrisonLandingPageMinimapButton:SetPoint("TOPRIGHT", 2, 2)
    GarrisonLandingPageMinimapButton:SetSize(32, 32)
    --GarrisonLandingPageMinimapButton:HookScript("OnEvent", Garrison_OnEvent)
    --GarrisonLandingPageMinimapButton:HookScript("OnLeave", Garrison_OnLeave)
    GarrisonLandingPageMinimapButton:SetScript("OnEnter", Garrison_OnEnter)
    --hooksecurefunc("GarrisonMinimap_SetPulseLock", hookfunc)


    MinimapNorthTag:SetAlpha(0)

    MiniMapInstanceDifficulty:Hide()
    MiniMapInstanceDifficulty.Show = function() end
    GuildInstanceDifficulty:Hide()
    GuildInstanceDifficulty.Show = function() end
    MiniMapChallengeMode:Hide()
    MiniMapChallengeMode.Show = function() end

    MiniMapWorldMapButton:Hide()

    GameTimeFrame:Hide()

    MinimapBorderTop:Hide()

    -- Make it square
    MinimapBorder:SetTexture(nil)
    Minimap:SetMaskTexture(Textures.SquareMask)

    -- Create New Border
    nibRealUI:CreateBG(Minimap)

    -- Disable MinimapCluster area
    MinimapCluster:EnableMouse(false)
end

----------
function MinimapAdv:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            hidden = {
                enabled = true,
                zones = {
                    pvp = false,
                    arena = true,
                    party = false,
                    raid = false,
                },
            },
            position = {
                size = 134,
                scale = 1,
                anchorto = "TOPLEFT",
                x = 7,
                y = -7,
            },
            expand = {
                appearance = {
                    scale = 1.4,
                    opacity = 0.5,
                },
                position = {
                    anchorto = "TOPLEFT",
                    x = 7,
                    y = -7,
                },
                extras = {
                    gatherertoggle = false,
                    clickthrough = false,
                    hidepoi = true,
                },
            },
            information = {
                position = {x = -1, y = 0},
                location = false,
                minimapbuttons = true,
                coordDelayHide = true,
                gap = 4,
                hideRaidFilters = true,
            },
            poi = {
                enabled = true,
                watchedOnly = true,
                fadeEdge = true,
                icons = {
                    scale = 0.7,
                    opacity = 1,
                },
            },
        },
    })
    db = self.db.profile
    ndbc = nibRealUI.db.char

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function MinimapAdv:OnEnable()
    -- Create frames, register events, begin the Minimap
    SetUpMinimapFrame()
    CreateFrames()
    self:RegEvents()
end
