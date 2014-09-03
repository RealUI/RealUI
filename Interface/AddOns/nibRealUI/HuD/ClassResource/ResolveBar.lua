local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_ResolveBar"
local ResolveBar = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local Resolve = nibRealUI:GetModule("ClassResource_Resolve")

local layoutSize
local class

local Textures = {
    [1] = {
        bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar]],
        middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
    },
    [2] = {
        bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar]],
        middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
    },
}

local BarWidth = {
    [1] = 84,
    [2] = 114,
}

local FontStringsRegular = {}
local MinLevel = 10

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Resolve",
        desc = "Resolve tracker for Druids, Paladins and Warriors.",
        arg = MODNAME,
        childGroups = "tab",
        args = {
            header = {
                type = "header",
                name = "Resolve",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Resolve tracker for Druids, Paladins and Warriors.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Resolve module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
        },
    }
    end
    return options
end

---------------------------
---- Resolve Updates ----
---------------------------
function ResolveBar:UpdateAuras(units)
    --print("UpdateAuras", units)
    if units then
        for k, v in pairs(units) do
            --print(k, v)
        end
    end
    if units and not(units.player) then return end

    Resolve:UpdateCurrent()

    self.rBar.value.text:SetText(nibRealUI:ReadableNumber(Resolve.current, 0))
    if Resolve.percent < 0.5 then
        AngleStatusBar:SetValue(self.rBar.left.bar, Resolve.percent * 2)
        AngleStatusBar:SetValue(self.rBar.right.bar, 0)
    else
        AngleStatusBar:SetValue(self.rBar.right.bar, (Resolve.percent - 0.5) * 2)
        AngleStatusBar:SetValue(self.rBar.left.bar, 1)
    end

    if ((Resolve.current > floor(Resolve.base)) and not(self.rBar:IsShown())) or
        ((Resolve.current <= floor(Resolve.base)) and self.rBar:IsShown()) then
            self:UpdateShown()
    end
end

function ResolveBar:UpdateBase(event, unit)
    --print("UpdateBase", event, unit)
    if (unit and (unit ~= "player")) then
        return
    end

    Resolve:UpdateBase(event, unit)
    self:UpdateAuras()
end

function ResolveBar:UpdateShown()
    --print("UpdateShown")
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.rBar:Show()
        return
    end

    if ( (Resolve.current and (Resolve.current > floor(Resolve.base))) and not(UnitIsDeadOrGhost("player")) and (UnitLevel("player") >= MinLevel) ) then
        self.rBar:Show()
    else
        self.rBar:Hide()
    end
end

function ResolveBar:PLAYER_ENTERING_WORLD()
    self.guid = UnitGUID("player")
    self:UpdateAuras()
    self:UpdateShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function ResolveBar:UpdateFonts()
    local font = nibRealUI:Font()
    for k, fontString in pairs(FontStringsRegular) do
        fontString:SetFont(unpack(font))
    end
end

function ResolveBar:UpdateGlobalColors()
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    AngleStatusBar:SetBarColor(self.rBar.left.bar, nibRealUI.media.colors.orange)
    AngleStatusBar:SetBarColor(self.rBar.right.bar, nibRealUI.media.colors.orange)
end

local function CreateTextFrame(parent, size)
    local NewTextFrame = CreateFrame("Frame", nil, parent)
    NewTextFrame:SetSize(12, 12)

    NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
    NewTextFrame.text:SetFont(unpack(nibRealUI:Font()))
    NewTextFrame.text:SetPoint("BOTTOM", NewTextFrame, "BOTTOM", 0.5, 0.5)
    tinsert(FontStringsRegular, NewTextFrame.text)
    
    return NewTextFrame
end

function ResolveBar:CreateFrames()
    self.rBar = CreateFrame("Frame", "RealUI_Resolve", RealUIPositionersClassResource)
    local rBar = self.rBar
        rBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
        rBar:SetPoint("BOTTOM")
        -- rBar:Hide()
    
    -- Left
    rBar.left = CreateFrame("Frame", nil, rBar)
        rBar.left:SetPoint("BOTTOMRIGHT", rBar, "BOTTOM", -1, 0)
        rBar.left:SetSize(BarWidth[layoutSize], 6)

        rBar.left.bg = rBar.left:CreateTexture(nil, "BACKGROUND")
            rBar.left.bg:SetPoint("BOTTOMRIGHT")
            rBar.left.bg:SetSize(128, 16)
            rBar.left.bg:SetTexture(Textures[layoutSize].bar)
            rBar.left.bg:SetVertexColor(unpack(nibRealUI.media.background))

        rBar.left.bar = AngleStatusBar:NewBar(rBar.left, 2, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "RIGHT")
            rBar.left.bar.reverse = true
    
    -- Right
    rBar.right = CreateFrame("Frame", nil, rBar)
        rBar.right:SetPoint("BOTTOMLEFT", rBar, "BOTTOM", 0, 0)
        rBar.right:SetSize(BarWidth[layoutSize], 6)

        rBar.right.bg = rBar.right:CreateTexture(nil, "BACKGROUND")
            rBar.right.bg:SetPoint("BOTTOMLEFT")
            rBar.right.bg:SetSize(128, 16)
            rBar.right.bg:SetTexture(Textures[layoutSize].bar)
            rBar.right.bg:SetTexCoord(1, 0, 0, 1)
            rBar.right.bg:SetVertexColor(unpack(nibRealUI.media.background))

        rBar.right.bar = AngleStatusBar:NewBar(rBar.right, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
            rBar.right.bar.reverse = true

    -- Middle
    rBar.middle = rBar:CreateTexture(nil, "BACKGROUND")
        rBar.middle:SetPoint("BOTTOM")
        rBar.middle:SetSize(16, 16)
        rBar.middle:SetTexture(Textures[layoutSize].middle)
        rBar.middle:SetVertexColor(unpack(nibRealUI.classColor))

    -- Resolve text
    rBar.value = CreateTextFrame(rBar)
        rBar.value:SetPoint("BOTTOM", rBar, "TOP", 0, 3)
end

------------
function ResolveBar:ToggleConfigMode(val)
    --print("UpdateShown", val)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if Resolve.special[class] then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function ResolveBar:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile

    layoutSize = ndb.settings.hudSize
    class = nibRealUI.class
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterHuDOptions(MODNAME, GetOptions, "ClassResource")
    nibRealUI:RegisterConfigModeModule(self)
end

function ResolveBar:OnEnable()
    if Resolve.special[class] then return end
    self.configMode = false

    if not self.rBar then self:CreateFrames() end
    self:UpdateBase()
    self:UpdateFonts()
    self:UpdateGlobalColors()

    local updateSpeed
    if nibRealUI.db.profile.settings.powerMode == 1 then
        updateSpeed = 1/6
    elseif nibRealUI.db.profile.settings.powerMode == 2 then
        updateSpeed = 1/4
    else
        updateSpeed = 1/8
    end

    -- Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateShown")
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
    self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateShown")
    self:RegisterEvent("UNIT_MAXHEALTH", "UpdateBase")
    self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
end

function ResolveBar:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
