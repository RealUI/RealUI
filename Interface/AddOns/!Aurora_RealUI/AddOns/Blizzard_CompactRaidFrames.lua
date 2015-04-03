local _, mods = ...

mods["Blizzard_CompactRaidFrames"] = function(F, C)
    RealUI.Debug("Blizzard_CompactRaidFrames", F, C)

    local CompactRaidFrameManager = _G.CompactRaidFrameManager
    CompactRaidFrameManager:DisableDrawLayer("ARTWORK")
    F.CreateBD(CompactRaidFrameManager)
    CompactRaidFrameManager.toggleButton:DisableDrawLayer("OVERLAY")

    local displayFrame = CompactRaidFrameManager.displayFrame
    F.ReskinDropDown(displayFrame.profileSelector)

    local filterOptions = displayFrame.filterOptions
    F.ReskinFilterButton(filterOptions.filterRoleTank)
end
