local _, private = ...

-- Lua Globals --
-- luacheck: globals tostring

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "WorldMarker"
local WorldMarker = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local BUTTON_WIDTH = 18
local MARKER_COLORS = {
    Color.white, -- Icon 8 - Skull
    Color.red, -- Icon 7 - Cross
    Color.marine, -- Icon 6 - Square
    Color.cyan, -- Icon 5 - Moon
    Color.green, -- Icon 4 - Triangle
    Color.magenta, -- Icon 3 - Diamond
    Color.orange, -- Icon 2 - Circle
    Color.yellow, -- Icon 1 - Star
}
local MARKER_ORDER = {
    -- from WORLD_RAID_MARKER_ORDER in Blizzard_CompactRaidFrameManager.lua
    8,
    4,
    1,
    7,
    2,
    3,
    6,
    5,
}


local function UpdateUsed()
    if not WorldMarker.frame:IsShown() then return end

    for index = 1, #MARKER_COLORS do
        local button = WorldMarker.frame[index]

        if _G.IsRaidMarkerActive(button.id) then
            button:SetBackdropBorderColor(Color.gray)
        else
            button:SetBackdropBorderColor(MARKER_COLORS[index])
        end
    end
end
local function UpdateVisibility()
    if _G.IsInGroup() and _G.UnitIsGroupLeader("player") or _G.UnitIsGroupAssistant("player") then
        WorldMarker.frame:Show()
    else
        WorldMarker.frame:Hide()
    end
end
local function UpdateSize()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    local frame = WorldMarker.frame
    local maxHeight = frame:GetHeight()

    local numBtns = #frame
    local totalHeight, buttonHeight = 0, _G.ceil(maxHeight / numBtns)
    for index = 1, numBtns do
        local button = frame[index]
        if button.id then
            button:SetHeight(buttonHeight)
        else
            button:SetHeight(maxHeight - totalHeight)
        end

        totalHeight = totalHeight + buttonHeight
    end
end

-----------------
local function OnLeave(self)
    self.text:Hide()
    self:SetBackdropOption("offsets", {
        left = 0,
        right = (BUTTON_WIDTH - 2),
        top = 0,
        bottom = 0,
    })
end
local function OnEnter(self)
    self.text:Show()
    self:SetBackdropOption("offsets", {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    })
end
local function CreateButton(index, id)
    local button = _G.CreateFrame("Button", "RealUI_WorldMarker"..(id or "Clear"), WorldMarker.frame, "SecureActionButtonTemplate")
    button:SetSize(BUTTON_WIDTH, 1)
    button.id = id

    button:SetNormalFontObject("GameFontNormal")
    button:SetAttribute("type", "worldmarker")
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)

    if index then
        Base.SetBackdrop(button, MARKER_COLORS[index])
        button:SetText(_G["WORLD_MARKER"..id])
        button:SetAttribute("marker", id)
    else
        Base.SetBackdrop(button, Color.gray)
        button:SetText(_G.REMOVE_WORLD_MARKERS)
        button:SetAttribute("action", "clear")
    end

    button.text = button:GetFontString()
    button.text:SetPoint("LEFT", button, "RIGHT", 2, 0)

    OnLeave(button)
    return button
end

---------------
function WorldMarker:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    RealUI.TryInCombat(UpdateVisibility)
end

function WorldMarker:OnInitialize()
    local frame = _G.CreateFrame("Frame", "RealUI_WorldMarker", _G.Minimap)
    frame:SetPoint("TOPLEFT", _G.Minimap, "TOPRIGHT", 1, 1)
    frame:SetPoint("BOTTOMLEFT", _G.Minimap, "BOTTOMRIGHT", 1, -1)
    frame:SetWidth(BUTTON_WIDTH)
    self.frame = frame

    for index = 1, #MARKER_COLORS do
        local button = CreateButton(index, MARKER_ORDER[index])

        if index == 1 then
            button:SetPoint("TOPLEFT")
        else
            button:SetPoint("TOPLEFT", frame[index - 1], "BOTTOMLEFT", 0, 0)
        end

        frame[index] = button
    end

    local button = CreateButton()
    button:SetPoint("TOPLEFT", frame[#frame], "BOTTOMLEFT", 0, 0)
    frame[#frame + 1] = button

    _G.hooksecurefunc(_G.Minimap, "SetSize", UpdateSize)
    _G.C_Timer.NewTicker(1, UpdateUsed)

    self:SetEnabledState(RealUI:GetModuleEnabled("MinimapAdv"))
end

function WorldMarker:OnEnable()
    self.bucket = self:RegisterBucketEvent({
        "PLAYER_ENTERING_WORLD",
        "PARTY_LEADER_CHANGED",
        "GROUP_ROSTER_UPDATE",
    }, 1, "RefreshMod")

    WorldMarker:RefreshMod()
end

function WorldMarker:OnDisable()
    self:UnregisterBucket(self.bucket)

    self.frame:Hide()
end
