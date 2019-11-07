local _, private = ...

-- Lua Globals --
-- luacheck: globals next type tinsert

-- Libs --
local ace = _G.LibStub("AceAddon-3.0")
local Aurora = _G.Aurora
local Skin = Aurora.Skin


-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db

local MODNAME = "AddonControl"
local AddonControl = RealUI:NewModule(MODNAME, "AceEvent-3.0")


local RealUIAddOns = {
    ["Raven"] =         {isAce = true, db = "RavenDB",          profKey = "profileKeys"},
    ["Skada"] =         {isAce = true, db = "SkadaDB",          profKey = "profileKeys"},

    ["DBM"] =                    {isAce = false, db = "DBT_AllPersistentOptions"},
    ["Kui_Nameplates_Core"] =    {isAce = false, db = "KuiNameplatesCoreCharacterSaved", profKey = "profile"},
    ["mikScrollingBattleText"] = {isAce = false, db = "MSBTProfiles_SavedVarsPerChar", profKey = "currentProfileName"},
}
local RealUIAddOnsOrder = {
    "DBM",
    "Masque",
    "mikScrollingBattleText",
    "Bartender4",
    "Raven",
    "Skada",
}

----------------------------
---- Profile Management ----
----------------------------

local function GetProfileInfo(addon)
    local profiles = db.addonControl[addon].profiles

    -- fix messed profile keys
    if profiles.base.key:match("Healing") then
        profiles.base.key = "RealUI"
    end

    local profileKey = profiles.base.key
    if profiles.layout.use then
        if (RealUI.cLayout == 2) then profileKey = profiles.base.key .. "-" .. profiles.layout.key end
    end

    return profileKey
end

-- Set Profile Keys of all AddOns
function RealUI:SetProfileKeys()
    -- Refresh Key
    self.key = ("%s - %s"):format(_G.UnitName("player"), _G.GetRealmName())

    for addon, data in next, RealUIAddOns do
        if db.addonControl[addon].profiles.base.use then
            -- Set Addon profiles
            local profile = GetProfileInfo(addon)
            if _G[data.db] and _G[data.db][data.profKey] then
                if data.isAce then
                    _G[data.db][data.profKey][self.key] = profile
                else
                    _G[data.db][data.profKey] = profile
                end
            end
        end
    end
end

-- Change Profile on AddOns using a Layout profile
function RealUI:SetProfileLayout()
    if _G.InCombatLockdown() then return end
    for addon, data in next, RealUIAddOns do
        if db.addonControl[addon].profiles.base.use and db.addonControl[addon].profiles.layout.use and data.isAce then
            local profile = GetProfileInfo(addon)
            local aceAddon = ace:GetAddon(addon, true)
            if aceAddon then
                aceAddon.db:SetProfile(profile)
            end
        end
    end
end

------------------------
---- Options Window ----
------------------------
local function CreateCheckbox(name, parent, label, side, size)
    local f = _G.CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate")
    Skin.ChatConfigCheckButtonTemplate(f)
    f:SetHitRectInsets(0, 0, 0, 0)
    f.type = "checkbox"

    f.text = _G[f:GetName() .. "Text"]
    f.text:SetFontObject("SystemFont_Shadow_Med1")
    f.text:SetTextColor(1, 1, 1)
    f.text:SetText(label)
    f.text:ClearAllPoints()
    if side == "LEFT" then
        f.text:SetPoint("RIGHT", f, "LEFT", -4, 0)
        f.text:SetJustifyH("RIGHT")
    else
        f.text:SetPoint("LEFT", f, "RIGHT", 4, 0)
        f.text:SetJustifyH("LEFT")
    end

    return f
end
local function CreateTextButton(text, parent, width, height)
    local f = _G.CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    Skin.UIPanelButtonTemplate(f)
    f:SetSize(width, height)
    f:SetText(text)
    return f
end
local function CreateFS(parent, justify, size)
    local font = "SystemFont_Shadow_Med1"
    if size == "large" then
        font = "Fancy16Font"
    end

    local f = parent:CreateFontString(nil, "OVERLAY", font)
    f:SetJustifyH(justify)
    return f
end
local function CreateWindow(name, width, height)
    local f = _G.CreateFrame("Frame", name, _G.UIParent)
    Aurora.Base.SetBackdrop(f)
    f:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
    f:SetSize(width, height)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(10)
    RealUI.MakeFrameDraggable(f)

    tinsert(_G.UISpecialFrames, name)
    f.close = _G.CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.close:SetPoint("TOPRIGHT", 6, 4)
    f.close:SetScript("OnClick", function(button)
        button:GetParent():Hide()
    end)
    Skin.UIPanelCloseButton(f.close)

    return f
end


function AddonControl:CreateOptionsFrame()
    if self.options then return end

    local color = _G.Aurora.Color.highlight
    self.options = CreateWindow("RealUIAddonControlOptions", 290, 240)
    local acO = self.options
        acO:SetPoint("CENTER", _G.UIParent, "CENTER", 0, 0)
        acO:Hide()

    acO.okay = CreateTextButton(_G.OKAY, acO, 100, 24)
        acO.okay:SetPoint("BOTTOM", acO, "BOTTOM", -51, 5)
        acO.okay:SetScript("OnClick", function() self.options:Hide() end)

    acO.reloadui = CreateTextButton("Reload UI", acO, 100, 24)
        acO.reloadui:SetPoint("BOTTOM", acO, "BOTTOM", 50, 5)
        acO.reloadui:SetScript("OnClick", _G.ReloadUI)

    -- Header
    local header = CreateFS(acO, "CENTER", "large")
        header:SetText(L["Control_AddonControl"])
        header:SetPoint("TOP", acO, "TOP", 0, -9)

    -- Label AddOn
    local lAddon = CreateFS(acO, "LEFT", "small")
        lAddon:SetPoint("TOPLEFT", acO, "TOPLEFT", 12, -30)
        lAddon:SetText("AddOn")
        lAddon:SetWidth(130)
        lAddon:SetTextColor(color:GetRGB())

    -- Label Base
    local lBase = CreateFS(acO, "CENTER", "small")
        lBase:SetPoint("LEFT", lAddon, "RIGHT", 0, 0)
        lBase:SetText("Base")
        lBase:SetWidth(40)
        lBase:SetTextColor(color:GetRGB())

    -- Label Position
    local lPosition = CreateFS(acO, "CENTER", "small")
        lPosition:SetPoint("LEFT", lBase, "RIGHT", 0, 0)
        lPosition:SetText("Pos")
        lPosition:SetWidth(40)
        lPosition:SetTextColor(color:GetRGB())

    local acAddonSect = _G.CreateFrame("Frame", nil, acO)
    acAddonSect:SetPoint("TOPLEFT", acO, "TOPLEFT", 6, -42)
    acAddonSect:SetPoint("BOTTOMRIGHT", acO, "BOTTOMRIGHT", -6, 36)

    local PositionAddOns = {
        ["DBM"] = true,
        ["Bartender4"] = true,
        ["Raven"] = true,
        ["mikScrollingBattleText"] = true,
    }
    local altAddOnTable = {
        ["DBM"] = "DBM-StatusBarTimers",
    }
    local prevLabel, prevCBBase, prevCBPosition, prevReset
    local cbBase, cbPosition, bReset = {}, {}, {}
    local cnt = 0
    for k, addon in next, RealUIAddOnsOrder do
        if _G.IsAddOnLoaded(addon) or (altAddOnTable[addon] and _G.IsAddOnLoaded(altAddOnTable[addon])) then
            cnt = cnt + 1

            -- AddOn name
            local fs = acAddonSect:CreateFontString(nil, "OVERLAY")
            fs:SetFontObject("SystemFont_Shadow_Med1")
            fs:SetText(addon)
            if not prevLabel then
                fs:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 6, -6)
            else
                fs:SetPoint("TOPLEFT", prevLabel, "BOTTOMLEFT", 0, -7)
            end
            prevLabel = fs

            -- Base Checkboxes
            cbBase[cnt] = CreateCheckbox("RealUIAddonControlBase"..cnt, acAddonSect, "", "LEFT", 21)
            cbBase[cnt].addon = addon
            cbBase[cnt].id = cnt
            if not prevCBBase then
                cbBase[cnt]:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 143, 0)
            else
                cbBase[cnt]:SetPoint("TOPLEFT", prevCBBase, "BOTTOMLEFT", 0, 5)
            end
            cbBase[cnt]:SetChecked(db.addonControl[addon].profiles.base.use)
            cbBase[cnt]:SetScript("OnClick", function(checkBtn)
                db.addonControl[checkBtn.addon].profiles.base.use = checkBtn:GetChecked() and true or false
                cbPosition[checkBtn.id]:SetShown(PositionAddOns[checkBtn.addon] and checkBtn:GetChecked())
            end)
            cbBase[cnt].tooltip = "Allow |cff0099ffRealUI|r to change |cffffffff"..addon.."'s|r profile."
            prevCBBase = cbBase[cnt]

            -- Position Checkboxes
            cbPosition[cnt] = CreateCheckbox("RealUIAddonControlPosition"..cnt, acAddonSect, "", "LEFT", 21)
            cbPosition[cnt].addon = addon
            cbPosition[cnt].id = cnt
            if not prevCBPosition then
                cbPosition[cnt]:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 183, 0)
            else
                cbPosition[cnt]:SetPoint("TOPLEFT", prevCBPosition, "BOTTOMLEFT", 0, 5)
            end
            if not(PositionAddOns[addon]) or not(db.addonControl[addon].profiles.base.use) then cbPosition[cnt]:Hide() end
            cbPosition[cnt]:SetChecked(db.addonControl[addon].control.position)
            cbPosition[cnt]:SetScript("OnClick", function(checkBtn)
                db.addonControl[checkBtn.addon].control.position = checkBtn:GetChecked() and true or false
            end)
            cbPosition[cnt].tooltip = "Allow |cff0099ffRealUI|r to dynamically control |cffffffff"..addon.."'s|r position."
            prevCBPosition = cbPosition[cnt]

            -- Reset
            bReset[cnt] = CreateTextButton("Reset", acAddonSect, 60, 18)
            bReset[cnt].addon = altAddOnTable[addon] or addon
            bReset[cnt].id = cnt
            if not prevReset then
                bReset[cnt]:SetPoint("TOPRIGHT", acAddonSect, "TOPRIGHT", -4, -4)
                acAddonSect.firstReset = bReset[cnt]
            else
                bReset[cnt]:SetPoint("TOPRIGHT", prevReset, "BOTTOMRIGHT", 0, -1)
                acAddonSect.lastReset = bReset[cnt]
            end
            bReset[cnt]:SetScript("OnClick", function(button)
                RealUI:SetUpAddonProfile(button.addon)
            end)
            bReset[cnt]:SetScript("OnEnter", function(button)
                --print("OnEnter", button.addon)
                _G.GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT", 64, 4)
                _G.GameTooltip:AddLine("Reset |cffffffff"..addon.."'s|r data to defaults.\nThis will erase any changes you've\nmade to this AddOn's settings.")
                _G.GameTooltip:Show()
            end)
            bReset[cnt]:SetScript("OnLeave", function(button)
                if _G.GameTooltip:IsShown() then _G.GameTooltip:Hide() end
            end)
            prevReset = bReset[cnt]
        end
    end
    acO:SetHeight(84 + (cnt * 19.25))
    acO:Show()
end

function AddonControl:ShowOptionsWindow()
    if not AddonControl.options then self:CreateOptionsFrame() end
    AddonControl.options:Show()
end
_G.SlashCmdList.AC = function()
    AddonControl:ShowOptionsWindow()
end
_G.SLASH_AC1 = "/ac"

function RealUI:ToggleAddonPositionControl(addon, val)
    db.addonControl[addon].control.position = val
    if val then
        db.addonControl[addon].profiles.base.use = val
    end
end

function RealUI:GetAddonControlSettings(addon)
    return {
        position = db.addonControl[addon].control.position,
        base = db.addonControl[addon].profiles.base.use,
    }
end

function RealUI:DoesAddonMove(addon)
    local addonControl = AddonControl.db.profile.addonControl
    return addonControl[addon] and (addonControl[addon].control.position and addonControl[addon].profiles.base.use)
end

function RealUI:DoesAddonStyle(addon)
    local addonControl = AddonControl.db.profile.addonControl
    return addonControl[addon] and (addonControl[addon].control.style and addonControl[addon].profiles.base.use)
end

-------------
function AddonControl:RefreshMod()
    db = self.db.profile

    RealUI:SetProfileLayout()
end

function AddonControl:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            addonControl = {
                ["DBM"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = true,
                        style = false,
                    },
                },
                ["Masque"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = false,
                        style = false,
                    },
                },
                ["Raven"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = true,
                        style = false,
                    },
                },
                ["mikScrollingBattleText"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = true,
                        style = false,
                    },
                },
                ["Kui_Nameplates_Core"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = false,
                        style = true,
                    },
                },
                ["Bartender4"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = true,    key = "Healing"},
                    },
                    control = {
                        position = true,
                        style = false,
                    },
                },
                ["Skada"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = false,   key = "Healing"},
                    },
                    control = {
                        position = false,
                        style = false,
                    },
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(true)
end
