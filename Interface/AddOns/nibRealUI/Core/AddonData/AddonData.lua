local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns = {
    "Aurora",
    "BugGrabber",
    "BugSack",
    "Bartender4",
    "DBM-StatusBarTimers",
    "FreebTip",
    "Grid2",
    "Kui_Nameplates",
    "mikScrollingBattleText",
    "Masque",
    "Raven",
    "Skada",
}

function RealUI:LoadAddonData()
    for k, a in next, self.AddOns do
        if self["LoadAddOnData_"..a] then
            self["LoadAddOnData_"..a]()
        end
    end
end

function RealUI:LoadSpecificAddOnData(addon, skipReload)
    --print("RealUI:LoadSpecificAddOnData", addon, skipReload, self["LoadAddOnData_"..addon])
    if self["LoadAddOnData_"..addon] then
        self["LoadAddOnData_"..addon]()
        --setProfile
        if skipReload then return end
        self:ReloadUIDialog()
    end
end
