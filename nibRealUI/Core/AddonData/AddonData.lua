local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

private.AddOns = {}
function RealUI:AddRealUIProfileToAddOn(addonName)
    --local loaded, finished = _G.IsAddOnLoaded(addonName)
    if private.AddOns[addonName] and _G.IsAddOnLoaded(addonName) then
        private.AddOns[addonName]()
    end
end

function RealUI:AddRealUIProfiles()
    for addonName, func in next, private.AddOns do
        self:AddRealUIProfileToAddOn(addonName)
    end
end

private.Profiles = {}
function RealUI:SetAddOnProfileToRealUI(addonName)
    if private.Profiles[addonName] and _G.IsAddOnLoaded(addonName) then
        private.Profiles[addonName]()
    end
end
function RealUI:SetProfilesToRealUI()
    for addonName, func in next, private.Profiles do
        self:SetAddOnProfileToRealUI(addonName)
    end
end

function RealUI:SetUpAddonProfile(addonName, skipReload)
    self:AddRealUIProfileToAddOn(addonName)
    self:SetAddOnProfileToRealUI(addonName)

    if skipReload then return end
    self:ReloadUIDialog()
end

_G.StaticPopupDialogs["RealUI_ResetAddonProfile"] = {
    text = L["Patch_UpdateAddonSettings"],
    button1 = _G.YES,
    button2 = _G.NO,
    OnAccept = function(self)
        RealUI:SetUpAddonProfile(self.text.text_arg1)
    end,
    OnCancel = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    notClosableByLogout = false,
}
