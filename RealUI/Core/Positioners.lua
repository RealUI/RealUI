local _, private = ...

-- Lua Globals --
local next, floor = _G.next, _G.math.floor

-- RealUI --
local RealUI = private.RealUI
local db, ndb, ndbc

local MODNAME = "Positioners"
local Positioners = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local PF = {}

local function GetHuDSizeOffset(key)
    Positioners:debug("GetHuDSizeOffset", key)
    -- Defensive: ndb.settings.hudSize can be nil or out-of-range (e.g. 3)
    -- during early init or when HuDPositioning briefly tries to switch to
    -- a HuD size that doesn't have an entry in RealUI.hudSizeOffsets.
    -- Fall back to size 2 (the default) so positioners don't fail to init.
    local offsets = RealUI.hudSizeOffsets
    if not offsets then return 0 end
    local size = ndb and ndb.settings and ndb.settings.hudSize
    local sizeOffsets = (size and offsets[size]) or offsets[2] or offsets[1]
    if not sizeOffsets then return 0 end
    return sizeOffsets[key] or 0
end

-- The positions table for a layout is populated lazily (LayoutManager fills
-- missing keys only, HuDPositioning writes the calculated ones at login), so
-- an individual key can legitimately be absent when the config sliders drive
-- an update. A missing key contributes no offset rather than erroring.
--[[ `RealUI.defaultPositions` and profile positions hold PRE-offset values
     for every key, and the HuD size offset is added exactly once, here at read
     time (and in RealUI_ActionBars Integration's topYOfs for ActionBarsY).

     Until B102 (2026-09-26) that was only true for the `runtimeOwnedKeys`
     (`UFHorizontal`, `ActionBarsBotY`). HuDPositioning:CalculatePositionValue
     also baked the offset into the calculated keys, so ActionBarsY and both
     cast bar Y keys got it twice: -40 instead of -20 at Large. Profiles
     filled before that fix may still hold a doubled ActionBarsY; the
     `abHeightB102` entry in /realui newdefaults resets it. ]]

local function GetKeyAdjust(key)
    -- Precedence MUST match the config panel's `safeLayout()`, which resolves
    -- RealUI.cLayout first. This read used to prefer the persisted
    -- db.char.layout.current instead, so whenever the two disagreed — which
    -- they do transiently around a layout switch, and cLayout is the value the
    -- profile cascade sets before modules run — the slider wrote one layout's
    -- table while the positioner read the other's, and the slider looked dead.
    local layout = RealUI.cLayout or (ndbc and ndbc.layout and ndbc.layout.current) or 1
    local positions = ndb and ndb.positions and ndb.positions[layout]
    local value = positions and positions[key]

    --[[ A missing key falls back to the shared default. Zero was the old
         behaviour and is wrong for width keys: the UnitFrames positioner is 80
         wide plus UFHorizontal, so a missing UFHorizontal collapsed it from
         380 to 80 and pulled both unit frames into the middle of the screen
         (measured 2026-08-23: profile key nil, defaultPositions holding 200). ]]
    --[[ B80/B86 (2026-08-24): fallback for EVERY key, because AceDB no longer
         supplies position defaults at all — see the note at Core.lua's
         `positions = {}`.

         This is deliberately a LIFT-AND-SHIFT of what AceDB used to do
         implicitly when it resolved an unsaved key against the shared defaults
         table: read `defaultPositions[layout][key]`, then add the size offset
         exactly as a saved value would get it. Same value in, same value out,
         for saved and unsaved keys alike. The only thing that changes is that
         AceDB no longer holds an opinion about the profile — and so no longer
         deletes saved keys for matching a default that the user's own values
         were promoted into.

         Values are pre-offset (B102, see the top of this file), so adding
         the offset here is the one place it is applied. ]]
    if not value then
        local defaults = RealUI.defaultPositions and RealUI.defaultPositions[layout]
        value = defaults and defaults[key]
        if not value then return 0 end
    end

    return value + GetHuDSizeOffset(key)
end

local function GetPositionData(pT)
    Positioners:debug("GetPositionData", pT)
    local point, parent, rPoint, x, y, width, height, xKeyTable, yKeyTable, widthKeyTable, heightKeyTable =
            pT[1], pT[2], pT[3], pT[4], pT[5], pT[6], pT[7], pT[8], pT[9], pT[10], pT[11]

    local xAdj, yAdj, widthAdj, heightAdj = 0, 0, 0, 0

    if xKeyTable then
        for k,v in next, xKeyTable do
            xAdj = xAdj + GetKeyAdjust(v)
        end
    end
    if yKeyTable then
        for k,v in next, yKeyTable do
            yAdj = yAdj + GetKeyAdjust(v)
        end
    end
    if widthKeyTable then
        for k,v in next, widthKeyTable do
            widthAdj = widthAdj + GetKeyAdjust(v)
        end
    end
    if heightKeyTable then
        for k,v in next, heightKeyTable do
            heightAdj = heightAdj + GetKeyAdjust(v)
        end
    end
    x = floor(x + xAdj)
    y = floor(y + yAdj)
    width = floor(width + widthAdj)
    height = floor(height + heightAdj)

    return point, parent, rPoint, x, y, width, height
end

function RealUI:UpdatePositioners()
    Positioners:debug("UpdatePositioners")
    -- Safety check: ensure db is initialized
    if not db or not db.positioners then
        Positioners:debug("UpdatePositioners: db not initialized yet")
        return
    end

    local positioners = {}
    for k, v in next, db.positioners do
        positioners[k] = v
    end
    for k, v in next, positioners do
        Positioners:debug("iter positioners", k, v)
        local point, parent, rPoint, x, y, width, height = GetPositionData(v)
        PF[k]:ClearAllPoints()
        PF[k]:SetPoint(point, parent, rPoint, x, y)
        PF[k]:SetSize(width, height)
    end
end

local function CreatePositionerFrame(point, parent, rpoint, x, y, w, h, name)
    Positioners:debug("CreatePositionerFrame", name)
    local frame = _G.CreateFrame("Frame", name, _G[parent])
    frame:SetPoint(point, _G[parent], rpoint, x, y)
    frame:SetHeight(h)
    frame:SetWidth(w)

    -- frame.bg = frame:CreateTexture(nil, "OVERLAY")
    -- frame.bg:SetAllPoints(frame)
    -- frame.bg:SetTexture(1, 1, 0, 0.5)

    return frame
end

local function CreatePositioners()
    Positioners:debug("CreatePositioners")
    local positioners = {}
    for k, v in next, db.positioners do
        positioners[k] = v
    end
    for k, v in next, positioners do
        local point, parent, rPoint, x, y, width, height = GetPositionData(v)
        PF[k] = CreatePositionerFrame(
            point, parent, rPoint, x, y, width, height, "RealUIPositioners"..k
        )
    end
end

function Positioners:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    RealUI:UpdatePositioners()
end

function Positioners:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            positioners = {
                --                      {point,     parent,     rpoint,     x, y, w, h,     xKeyTable,                  yKeyTable,                  widthKeyTable,                      heightKeyTable},
                ["Center"] =            {"CENTER",  "UIParent", "CENTER",   0, 0, 2, 2,     nil,                        {"HuDY"}},
                ["Buffs"] =             {"TOPRIGHT","UIParent", "TOPRIGHT", -1, -1, 2, 2},
                -- B13: static screen-center anchor — spell alerts appear around the
                -- player character, so they must NOT follow the HuD sliders
                -- (HuDX/HuDY) or the retired SpellAlertWidth key. Sizing is now
                -- owned by Modules/SpellAlerts.lua (scale setting); the 250x140
                -- rect here matches the old default footprint for reference.
                ["SpellAlerts"] =       {"CENTER",  "UIParent", "CENTER",   0, 0, 250, 140},
                ["CastBarPlayer"] =     {"TOP",     "UIParent", "CENTER",   -2, -130, 2, 2, {"HuDX", "CastBarPlayerX"}, {"HuDY", "CastBarPlayerY"}},
                ["CastBarTarget"] =     {"TOP",     "UIParent", "CENTER",   2, -130, 2, 2,  {"HuDX", "CastBarTargetX"}, {"HuDY", "CastBarTargetY"}},
                ["UnitFrames"] =        {"CENTER",  "UIParent", "CENTER",   0, 0, 80, 2,    {"HuDX"},                   {"HuDY"},                   {"UFHorizontal"}},
                ["BossFrames"] =        {"RIGHT",   "UIParent", "RIGHT",    0, 0, 2, 2,     {"BossX"},                  {"HuDY", "BossY"}},
            },
        }
    })
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    self:SetEnabledState(true)

    CreatePositioners()
end
