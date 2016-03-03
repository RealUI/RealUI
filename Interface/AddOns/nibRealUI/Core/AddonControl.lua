local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local db, ndb, ndbc

local MODNAME = "AddonControl"
local AddonControl = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")


local RealUIAddOns = {
    ["Bartender4"] =    {isAce = true, db = "Bartender4DB",     profKey = "profileKeys"},
    ["Grid2"] =         {isAce = true, db = "Grid2DB",          profKey = "profileKeys"},
    ["KuiNameplates"] = {isAce = true, db = "KuiNameplatesGDB", profKey = "profileKeys"},
    ["Masque"] =        {isAce = true, db = "MasqueDB",         profKey = "profileKeys"},
    ["Raven"] =         {isAce = true, db = "RavenDB",          profKey = "profileKeys"},
    ["Skada"] =         {isAce = true, db = "SkadaDB",          profKey = "profileKeys"},

    ["DBM"] =                    {isAce = false, db = "DBT_AllPersistentOptions"},
    ["mikScrollingBattleText"] = {isAce = false, db = "MSBTProfiles_SavedVarsPerChar", profKey = "currentProfileName"},
}
local RealUIAddOnsOrder = {
    "DBM",
    "Masque",
    "mikScrollingBattleText",
    "Bartender4",
    "Grid2",
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
        if (nibRealUI.cLayout == 2) then profileKey = profiles.base.key .. "-" .. profiles.layout.key end
    end

    return profileKey
end

-- Set Profile Keys of all AddOns
function nibRealUI:SetProfileKeys()
    -- Refresh Key
    self.key = string.format("%s - %s", UnitName("player"), GetRealmName())

    for addon, data in pairs(RealUIAddOns) do
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
function nibRealUI:SetProfileLayout()
    if InCombatLockdown() then return end
    for addon, data in pairs(RealUIAddOns) do
        if db.addonControl[addon].profiles.base.use and db.addonControl[addon].profiles.layout.use and data.isAce then
            local profile = GetProfileInfo(addon)
            local aceAddon = LibStub("AceAddon-3.0"):GetAddon(addon, true)
            if aceAddon then
                aceAddon.db:SetProfile(profile)
            end
        end
    end
end

------------------------
---- Options Window ----
------------------------

function AddonControl:CreateOptionsFrame()
    if self.options then return end

    local F
    if Aurora then F = Aurora[1] end

    self.options = nibRealUI:CreateWindow("RealUIAddonControlOptions", 330, 240, true, true)
    local acO = self.options
        acO:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        acO:Hide()

    acO.okay = nibRealUI:CreateTextButton(OKAY, acO, 100, 24, true)
        acO.okay:SetPoint("BOTTOM", acO, "BOTTOM", -51, 5)
        acO.okay:SetScript("OnClick", function() RealUIAddonControlOptions:Hide() end)

    acO.reloadui = nibRealUI:CreateTextButton("Reload UI", acO, 100, 24, true)
        acO.reloadui:SetPoint("BOTTOM", acO, "BOTTOM", 50, 5)
        acO.reloadui:SetScript("OnClick", function() ReloadUI() end)

    nibRealUI:CreateBGSection(acO, acO.okay, acO.reloadui)

    -- Header
    local header = nibRealUI:CreateFS(acO, "CENTER", "small")
        header:SetText(L["Control_AddonControl"])
        header:SetPoint("TOP", acO, "TOP", 0, -9)

    -- Label AddOn
    local lAddon = nibRealUI:CreateFS(acO, "LEFT", "small")
        lAddon:SetPoint("TOPLEFT", acO, "TOPLEFT", 12, -30)
        lAddon:SetText("AddOn")
        lAddon:SetWidth(130)
        lAddon:SetTextColor(unpack(nibRealUI.classColor))

    -- Label Base
    local lBase = nibRealUI:CreateFS(acO, "CENTER", "small")
        lBase:SetPoint("LEFT", lAddon, "RIGHT", 0, 0)
        lBase:SetText("Base")
        lBase:SetWidth(40)
        lBase:SetTextColor(unpack(nibRealUI.classColor))

    -- Label Layout
    local lLayout = nibRealUI:CreateFS(acO, "CENTER", "small")
        lLayout:SetPoint("LEFT", lBase, "RIGHT", 0, 0)
        lLayout:SetText("Layout")
        lLayout:SetWidth(40)
        lLayout:SetTextColor(unpack(nibRealUI.classColor))

    -- Label Position
    local lPosition = nibRealUI:CreateFS(acO, "CENTER", "small")
        lPosition:SetPoint("LEFT", lLayout, "RIGHT", 0, 0)
        lPosition:SetText("Pos")
        lPosition:SetWidth(40)
        lPosition:SetTextColor(unpack(nibRealUI.classColor))

    local acAddonSect = nibRealUI:CreateBDFrame(acO)
    acAddonSect:SetBackdropColor(unpack(nibRealUI.media.background))
    acAddonSect:SetPoint("TOPLEFT", acO, "TOPLEFT", 6, -42)
    acAddonSect:SetPoint("BOTTOMRIGHT", acO, "BOTTOMRIGHT", -6, 36)

    local LayoutAddOns = {
        ["Bartender4"] = true,
        ["Grid2"] = true,
    }
    local PositionAddOns = {
        ["DBM"] = true,
        ["Bartender4"] = true,
        ["Grid2"] = true,
        ["mikScrollingBattleText"] = true,
    }
    local altAddOnTable = {
        ["DBM"] = "DBM-StatusBarTimers",
    }
    local prevLabel, prevCBBase, prevCBLayout, prevCBPosition, prevReset
    local cbBase, cbLayout, cbPosition, bReset = {}, {}, {}, {}, {}
    local cnt = 0
    for k, addon in pairs(RealUIAddOnsOrder) do
        if IsAddOnLoaded(addon) or (altAddOnTable[addon] and IsAddOnLoaded(altAddOnTable[addon])) then
            cnt = cnt + 1

            -- AddOn name
            local fs = acO:CreateFontString(nil, "OVERLAY")
            fs:SetFontObject(RealUIFont_Normal)
            fs:SetText(addon)
            if not prevLabel then
                fs:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 6, -9.5)
            else
                fs:SetPoint("TOPLEFT", prevLabel, "BOTTOMLEFT", 0, -8.5)
            end
            prevLabel = fs

            -- Base Checkboxes
            cbBase[cnt] = nibRealUI:CreateCheckbox("RealUIAddonControlBase"..cnt, acAddonSect, "", "LEFT", 21)
            cbBase[cnt].addon = addon
            cbBase[cnt].id = cnt
            if not prevCBBase then
                cbBase[cnt]:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 143, -3)
            else
                cbBase[cnt]:SetPoint("TOPLEFT", prevCBBase, "BOTTOMLEFT", 0, 2)
            end
            cbBase[cnt]:SetChecked(db.addonControl[addon].profiles.base.use)
            cbBase[cnt]:SetScript("OnClick", function(self)
                db.addonControl[self.addon].profiles.base.use = self:GetChecked() and true or false
                cbLayout[self.id]:SetShown(LayoutAddOns[self.addon] and self:GetChecked())
                cbPosition[self.id]:SetShown(PositionAddOns[self.addon] and self:GetChecked())
            end)
            cbBase[cnt].tooltip = "Allow |cff0099ffRealUI|r to change |cffffffff"..addon.."'s|r profile."
            prevCBBase = cbBase[cnt]

            -- Layout Checkboxes
            cbLayout[cnt] = nibRealUI:CreateCheckbox("RealUIAddonControlLayout"..cnt, acAddonSect, "", "LEFT", 21)
            cbLayout[cnt].addon = addon
            cbLayout[cnt].id = cnt
            if not prevCBLayout then
                cbLayout[cnt]:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 183, -3)
            else
                cbLayout[cnt]:SetPoint("TOPLEFT", prevCBLayout, "BOTTOMLEFT", 0, 2)
            end
            if not(LayoutAddOns[addon]) or not(db.addonControl[addon].profiles.base.use) then cbLayout[cnt]:Hide() end
            cbLayout[cnt]:SetChecked(db.addonControl[addon].profiles.layout.use)
            cbLayout[cnt]:SetScript("OnClick", function(self)
                db.addonControl[self.addon].profiles.layout.use = self:GetChecked() and true or false
            end)
            cbLayout[cnt].tooltip = "Allow |cff0099ffRealUI|r to change |cffffffff"..addon.."'s|r profile based on current |cff0099ffLayout|r |cff999999(DPS/Tank or Healing)|r."
            prevCBLayout = cbLayout[cnt]

            -- Position Checkboxes
            cbPosition[cnt] = nibRealUI:CreateCheckbox("RealUIAddonControlPosition"..cnt, acAddonSect, "", "LEFT", 21)
            cbPosition[cnt].addon = addon
            cbPosition[cnt].id = cnt
            if not prevCBPosition then
                cbPosition[cnt]:SetPoint("TOPLEFT", acAddonSect, "TOPLEFT", 223, -3)
            else
                cbPosition[cnt]:SetPoint("TOPLEFT", prevCBPosition, "BOTTOMLEFT", 0, 2)
            end
            if not(PositionAddOns[addon]) or not(db.addonControl[addon].profiles.base.use) then cbPosition[cnt]:Hide() end
            cbPosition[cnt]:SetChecked(db.addonControl[addon].control.position)
            cbPosition[cnt]:SetScript("OnClick", function(self)
                db.addonControl[self.addon].control.position = self:GetChecked() and true or false
            end)
            cbPosition[cnt].tooltip = "Allow |cff0099ffRealUI|r to dynamically control |cffffffff"..addon.."'s|r position."
            prevCBPosition = cbPosition[cnt]

            -- Reset
            bReset[cnt] = nibRealUI:CreateTextButton("Reset", acAddonSect, 60, 18, true)
            bReset[cnt].addon = altAddOnTable[addon] or addon
            bReset[cnt].id = cnt
            if not prevReset then
                bReset[cnt]:SetPoint("TOPRIGHT", acAddonSect, "TOPRIGHT", -4, -4)
                acAddonSect.firstReset = bReset[cnt]
            else
                bReset[cnt]:SetPoint("TOPRIGHT", prevReset, "BOTTOMRIGHT", 0, -1)
                acAddonSect.lastReset = bReset[cnt]
            end
            bReset[cnt]:SetScript("OnClick", function(self)
                nibRealUI:LoadSpecificAddOnData(self.addon)
            end)
            bReset[cnt]:SetScript("OnEnter", function(self)
                --print("OnEnter", self.addon)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 64, 4)
                GameTooltip:AddLine("Reset |cffffffff"..addon.."'s|r data to defaults.\nThis will erase any changes you've\nmade to this AddOn's settings.")
                GameTooltip:Show()
            end)
            bReset[cnt]:SetScript("OnLeave", function(self)
                if GameTooltip:IsShown() then GameTooltip:Hide() end
            end)
            prevReset = bReset[cnt]
        end
    end
    acO:SetHeight(84 + (cnt * 19.25))
    nibRealUI:CreateBGSection(acAddonSect, acAddonSect.firstReset, acAddonSect.lastReset)

    acO:Show()
end

function AddonControl:ShowOptionsWindow()
    if not AddonControl.options then self:CreateOptionsFrame() end
    AddonControl.options:Show()
end
SlashCmdList.AC = function()
    AddonControl:ShowOptionsWindow()
end
SLASH_AC1 = "/ac"

function nibRealUI:ToggleAddonPositionControl(addon, val)
    db.addonControl[addon].control.position = val
    if val then
        db.addonControl[addon].profiles.base.use = val
    end
end

function nibRealUI:ToggleAddonLayoutControl(addon, val)
    db.addonControl[addon].profiles.layout.use = val
    if val then
        db.addonControl[addon].profiles.base.use = val
    end
end

function nibRealUI:GetAddonControlSettings(addon)
    return {
        position = db.addonControl[addon].control.position,
        base = db.addonControl[addon].profiles.base.use,
    }
end

function nibRealUI:DoesAddonMove(addon)
    return db.addonControl[addon].control.position and db.addonControl[addon].profiles.base.use
end

function nibRealUI:DoesAddonLayout(addon)
    return db.addonControl[addon].profiles.layout.use and db.addonControl[addon].profiles.base.use
end

function nibRealUI:DoesAddonStyle(addon)
    return db.addonControl[addon].control.style and db.addonControl[addon].profiles.base.use
end

-------------
function AddonControl:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
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
                        position = false,
                        style = true,
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
                ["KuiNameplates"] = {
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
                ["Grid2"] = {
                    profiles = {
                        base =          {use = true,    key = "RealUI"},
                        layout =        {use = true,    key = "Healing"},
                    },
                    control = {
                        position = true,
                        style = true,
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
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    self:SetEnabledState(true)
end
