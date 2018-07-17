local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns = {}
function RealUI:LoadAddonData()
    for name, func in next, self.AddOns do
        func()
    end
end

function RealUI:LoadSpecificAddOnData(addon, skipReload)
    --print("RealUI:LoadSpecificAddOnData", addon, skipReload, self.AddOns[addon])
    if self.AddOns[addon] then
        self.AddOns[addon]()
        --setProfile
        if skipReload then return end
        self:ReloadUIDialog()
    end
end
