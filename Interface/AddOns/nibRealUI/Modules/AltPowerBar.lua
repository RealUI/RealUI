local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "AltPowerBar"
local AltPowerBar = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

local APBFrames = {}

local UpdateInterval = 0

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Alt Power Bar",
        arg = MODNAME,
        childGroups = "tab",
        -- order = 112,
        args = {
            header = {
                type = "header",
                name = "Alt Power Bar",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Replacement of the default Alternate Power Bar.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Alt Power Bar module.",
                get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    RealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 31,
            },
            size = {
                name = "Size",
                type = "group",
                disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                inline = true,
                order = 50,
                args = {
                    width = {
                        type = "input",
                        name = "Width",
                        width = "half",
                        order = 10,
                        get = function(info) return _G.tostring(db.size.width) end,
                        set = function(info, value)
                            value = RealUI:ValidateOffset(value)
                            db.size.width = value
                            AltPowerBar:UpdatePosition()
                        end,
                    },
                    height = {
                        type = "input",
                        name = "Height",
                        width = "half",
                        order = 20,
                        get = function(info) return _G.tostring(db.size.height) end,
                        set = function(info, value)
                            value = RealUI:ValidateOffset(value)
                            db.size.height = value
                            AltPowerBar:UpdatePosition()
                        end,
                    },
                },
            },
            gap2 = {
                name = " ",
                type = "description",
                order = 51,
            },
            position = {
                name = "Position",
                type = "group",
                disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                inline = true,
                order = 60,
                args = {
                    position = {
                        name = "Position",
                        type = "group",
                        inline = true,
                        order = 10,
                        args = {
                            xoffset = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                order = 10,
                                get = function(info) return _G.tostring(db.position.x) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    db.position.x = value
                                    AltPowerBar:UpdatePosition()
                                end,
                            },
                            yoffset = {
                                type = "input",
                                name = "Y Offset",
                                width = "half",
                                order = 20,
                                get = function(info) return _G.tostring(db.position.y) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    db.position.y = value
                                    AltPowerBar:UpdatePosition()
                                end,
                            },
                            anchorto = {
                                type = "select",
                                name = "Anchor To",
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == db.position.anchorto then return k end
                                    end
                                end,
                                set = function(info, value)
                                    db.position.anchorto = RealUI.globals.anchorPoints[value]
                                    AltPowerBar:UpdatePosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = RealUI.globals.anchorPoints,
                                order = 30,
                            },
                            anchorfrom = {
                                type = "select",
                                name = "Anchor From",
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == db.position.anchorfrom then return k end
                                    end
                                end,
                                set = function(info, value)
                                    db.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                    AltPowerBar:UpdatePosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = RealUI.globals.anchorPoints,
                                order = 40,
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

-- Events
function AltPowerBar:PowerUpdate()
    if _G.UnitAlternatePowerInfo("player") then
        APBFrames.bg:Show()
        APBFrames.bar:Show()
    else
        APBFrames.bg:Hide()
        APBFrames.bar:Hide()
    end
end

-- Colors
function AltPowerBar:UpdateColors()
    -- BG + Border
    local color = RealUI.media.background
    APBFrames.bg:SetBackdropColor(color[1], color[2], color[3], color[4])
    APBFrames.bg:SetBackdropBorderColor(0, 0, 0, 1)

    -- Bar
    color = RealUI.media.colors.green
    APBFrames.bar:SetStatusBarColor(color[1], color[2], color[3], 0.85)
end

-- Position
function AltPowerBar:UpdatePosition()
    -- BG + Border
    APBFrames.bg:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)

    APBFrames.bg:SetFrameStrata("MEDIUM")
    APBFrames.bg:SetFrameLevel(1)

    APBFrames.bg:SetHeight(db.size.height)
    APBFrames.bg:SetWidth(db.size.width)
end

-- Refresh
function AltPowerBar:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    db = self.db.profile

    AltPowerBar:UpdatePosition()
    AltPowerBar:UpdateColors()
end

function AltPowerBar:PLAYER_LOGIN()
    LoggedIn = true
    AltPowerBar:RefreshMod()
    AltPowerBar:PowerUpdate()
end

-- Create Frames
function AltPowerBar:CreateFrames()
    APBFrames = {
        bg = nil,
        bar = nil,
        text = nil,
    }

    -- BG + Border
    APBFrames.bg = _G.CreateFrame("Frame", "RealUI_AltPowerBarBG", _G.UIParent)
    APBFrames.bg:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)

    APBFrames.bg:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
    })

    -- Bar + Text
    APBFrames.bar = _G.CreateFrame("StatusBar", "RealUI_AltPowerBar", APBFrames.bg)
    APBFrames.bar:SetStatusBarTexture(RealUI.media.textures.plain)
    APBFrames.bar:SetMinMaxValues(0, 100)
    APBFrames.bar:SetPoint("TOPLEFT", APBFrames.bg, "TOPLEFT", 1, -1)
    APBFrames.bar:SetPoint("BOTTOMRIGHT", APBFrames.bg, "BOTTOMRIGHT", -1, 1)

    APBFrames.text = APBFrames.bar:CreateFontString(nil, "OVERLAY")
    APBFrames.text:SetPoint("CENTER", APBFrames.bar, "CENTER", 1.5, -0.5)
    APBFrames.text:SetFontObject(_G.RealUIFont_Pixel)
    APBFrames.text:SetTextColor(1, 1, 1, 1)

    -- Update Power
    UpdateInterval = 0
    APBFrames.bar:SetScript("OnUpdate", function(bar, elapsed)
        UpdateInterval = UpdateInterval + elapsed

        if UpdateInterval > 0.1 then
            bar:SetMinMaxValues(0, _G.UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX))
            local CurPower = _G.UnitPower("player", _G.ALTERNATE_POWER_INDEX)
            local MaxPower = _G.UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX)
            bar:SetValue(CurPower)
            if MaxPower > 0 then
                APBFrames.text:SetText(CurPower.."/"..MaxPower)
            else
                APBFrames.text:SetText("0")
            end
            UpdateInterval = 0
        end
    end)

    APBFrames.bg:Hide()
end

-- Initialize
function AltPowerBar:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            size = {width = 160, height = 16},
            position = {
                anchorto = "TOP",
                anchorfrom = "TOP",
                x = 0,
                y = -200,
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterModuleOptions(MODNAME, GetOptions)

    AltPowerBar:CreateFrames()
end

function AltPowerBar:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("UNIT_POWER", "PowerUpdate")
    self:RegisterEvent("UNIT_POWER_BAR_SHOW", "PowerUpdate")
    self:RegisterEvent("UNIT_POWER_BAR_HIDE", "PowerUpdate")

    -- Hide Default
    _G.PlayerPowerBarAlt:SetAlpha(0)

    if LoggedIn then
        AltPowerBar:RefreshMod()
        AltPowerBar:PowerUpdate()
    end
end

function AltPowerBar:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("UNIT_POWER")
    self:UnregisterEvent("UNIT_POWER_BAR_SHOW")
    self:UnregisterEvent("UNIT_POWER_BAR_HIDE")

    APBFrames.bg:Hide()
    _G.PlayerPowerBarAlt:SetAlpha(1)
end
