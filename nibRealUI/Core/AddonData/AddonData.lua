local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

RealUI.AddOns = {}
function RealUI:LoadAddonData()
    for name, func in next, self.AddOns do
        func()
    end
end

RealUI.Profiles = {}
function RealUI:LoadAddonProfiles()
    for name, func in next, self.Profiles do
        func()
    end
end

function RealUI:LoadSpecificAddOnData(addon, skipReload)
    --print("RealUI:LoadSpecificAddOnData", addon, skipReload, self.AddOns[addon])
    if self.AddOns[addon] then
        self.AddOns[addon]()
    end
    if self.Profiles[addon] then
        self.Profiles[addon]()
    end

    if skipReload then return end
    self:ReloadUIDialog()
end

_G.StaticPopupDialogs["RealUI_ResetAddonProfile"] = {
    text = L["Patch_UpdateAddonSettings"],
    button1 = _G.YES,
    button2 = _G.NO,
    OnAccept = function(self)
        RealUI:LoadSpecificAddOnData(self.text.text_arg1)
    end,
    OnCancel = function() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    notClosableByLogout = false,
}
