local _, private = ...

-- Lua Globals --
-- luacheck: globals tostring

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "WorldMarker"
local WorldMarker = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local BUTTON_WIDTH = 18
local markers = {
    {   -- Icon 8 - Skull
        color = Color.white,
        text = _G.WORLD_MARKER8,
        id = "8"
    },
    {   -- Icon 7 - Cross
        color = Color.red,
        text = _G.WORLD_MARKER4,
        id = "4"
    },
    {   -- Icon 6 - Square
        color = Color.marine,
        text = _G.WORLD_MARKER1,
        id = "1"
    },
    {   -- Icon 5 - Moon
        color = Color.cyan,
        text = _G.WORLD_MARKER7,
        id = "7"
    },
    {   -- Icon 4 - Triangle
        color = Color.green,
        text = _G.WORLD_MARKER2,
        id = "2"
    },
    {   -- Icon 3 - Diamond
        color = Color.magenta,
        text = _G.WORLD_MARKER3,
        id = "3"
    },
    {   -- Icon 2 - Circle
        color = Color.orange,
        text = _G.WORLD_MARKER6,
        id = "6"
    },
    {   -- Icon 1 - Star
        color = Color.yellow,
        text = _G.WORLD_MARKER5,
        id = "5"
    },
    {   -- Clear all
        color = Color.gray,
        text = _G.REMOVE_WORLD_MARKERS
    },
}

function WorldMarker:UpdateUsed()
    local frame = self.frame
    for index = 1, #markers do
        local button = frame[index]

        if markers[index].id then
            if _G.IsRaidMarkerActive(markers[index].id) then
                button:SetBackdropBorderColor(Color.gray)
            else
                button:SetBackdropBorderColor(markers[index].color)
            end
        end
    end
end
function WorldMarker:UpdateVisibility()
    local shouldShow = false
    if _G.GetNumGroupMembers() > 0 and _G.UnitIsGroupLeader("player") or _G.UnitIsGroupAssistant("player") then
        local _, instanceType = _G.IsInInstance()
        if db.visibility[instanceType] ~= nil then
            shouldShow = db.visibility[instanceType]
        end
    end

    if shouldShow then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end
function WorldMarker:UpdateSize()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    local frame = self.frame
    local maxHeight = frame:GetHeight()

    local numBtns = #markers
    local totalHeight, buttonHeight = 0, _G.ceil(maxHeight / numBtns)
    for index = 1, numBtns do
        if markers[index].id then
            frame[index]:SetHeight(buttonHeight)
        else
            frame[index]:SetHeight(maxHeight - totalHeight)
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
local function CreateButton(id)
    local button = _G.CreateFrame("Button", "RealUI_WorldMarker"..id, WorldMarker.frame, "SecureActionButtonTemplate")
    button:SetSize(BUTTON_WIDTH, 1)
    Base.SetBackdrop(button, markers[id].color)

    button:SetNormalFontObject("GameFontNormal")
    button:SetText(markers[id].text)
    button.text = button:GetFontString()
    button.text:SetPoint("LEFT", button, "RIGHT", 2, 0)

    button:SetAttribute("type", "worldmarker")
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)
    OnLeave(button)

    return button
end

---------------
local function Refresh()
    WorldMarker:UpdateUsed()
    WorldMarker:UpdateSize()
    WorldMarker:UpdateVisibility()
end
function WorldMarker:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    RealUI.TryInCombat(Refresh)
end

function WorldMarker:GLOBAL_MOUSE_UP()
    _G.C_Timer.After(1, function()
        self:UpdateUsed()
    end)
end

function WorldMarker:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            visibility = {
                pvp = false,
                arena = false,
                party = true,
                raid = true,
                none = true,
            },
        },
    })
    db = self.db.profile


    local frame = _G.CreateFrame("Frame", "RealUI_WorldMarker", _G.Minimap)
    frame:SetPoint("TOPLEFT", _G.Minimap, "TOPRIGHT", 1, 1)
    frame:SetPoint("BOTTOMLEFT", _G.Minimap, "BOTTOMRIGHT", 1, -1)
    frame:SetWidth(BUTTON_WIDTH)
    self.frame = frame

    for index = 1, #markers do
        local button = CreateButton(index)

        if index == 1 then
            button:SetPoint("TOPLEFT")
        else
            button:SetPoint("TOPLEFT", frame[index - 1], "BOTTOMLEFT", 0, 0)
        end

        if markers[index].id then
            button:SetAttribute("action", "set")
            button:SetAttribute("marker", markers[index].id)
        else
            button:SetAttribute("action", "clear")
        end

        frame[index] = button
    end

    _G.hooksecurefunc(_G.Minimap, "SetSize", function()
        WorldMarker:UpdateSize()
    end)

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function WorldMarker:OnEnable()
    self:RegisterEvent("GLOBAL_MOUSE_UP")
    self.bucket = self:RegisterBucketEvent({
        "PLAYER_ENTERING_WORLD",
        "PARTY_LEADER_CHANGED",
        "GROUP_ROSTER_UPDATE",
    }, 1, "RefreshMod")

    WorldMarker:RefreshMod()
end

function WorldMarker:OnDisable()
    self:UnregisterEvent("GLOBAL_MOUSE_UP")
    self:UnregisterBucket(self.bucket)

    self.frame:Hide()
end
