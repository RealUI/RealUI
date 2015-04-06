local _, mods = ...

mods["Blizzard_CompactRaidFrames"] = function(F, C)
    RealUI.Debug("Blizzard_CompactRaidFrames", F, C)

    local CompactRaidFrameManager = _G.CompactRaidFrameManager
    CompactRaidFrameManager:DisableDrawLayer("ARTWORK")
    F.CreateBD(CompactRaidFrameManager)

    local toggleButton = CompactRaidFrameManager.toggleButton
    toggleButton:DisableDrawLayer("OVERLAY")
    toggleButton:SetPoint("RIGHT", -1, 0)
    toggleButton:HookScript("OnEnter", F.colourArrow)
    toggleButton:HookScript("OnLeave", F.clearArrow)

    local tex = toggleButton:CreateTexture(nil, "ARTWORK")
    tex:SetTexture([[Interface\AddOns\Aurora\media\arrow-right-active]])
    tex:SetAllPoints()
    toggleButton.tex = tex
    hooksecurefunc("CompactRaidFrameManager_Toggle", function(self)
        if self.collapsed then
            tex:SetTexture([[Interface\AddOns\Aurora\media\arrow-right-active]])
        else
            tex:SetTexture([[Interface\AddOns\Aurora\media\arrow-left-active]])
        end
    end)

    local displayFrame = CompactRaidFrameManager.displayFrame
    displayFrame:GetRegions():Hide()
    local header = _G[displayFrame:GetName().."HeaderDelineator"]
    header:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line.blp]])
    header:SetVertexColor(C.r, C.g, C.b)
    header:SetHeight(9)

    F.ReskinDropDown(displayFrame.profileSelector)

    local filterOptions = displayFrame.filterOptions
    F.ReskinFilterButton(filterOptions.filterRoleTank)
    F.ReskinFilterButton(filterOptions.filterRoleHealer)
    F.ReskinFilterButton(filterOptions.filterRoleDamager)

    for i = 1, 8 do
        F.ReskinFilterButton(filterOptions["filterGroup"..i])
    end

    local footer = _G[filterOptions:GetName().."FooterDelineator"]
    footer:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line.blp]])
    footer:SetVertexColor(C.r, C.g, C.b)
    footer:SetHeight(9)

    F.ReskinFilterButton(displayFrame.lockedModeToggle)
    F.ReskinFilterButton(displayFrame.hiddenModeToggle)
    F.ReskinFilterButton(displayFrame.convertToRaid)

    local leaderOptions = displayFrame.leaderOptions
    F.ReskinFilterButton(leaderOptions.rolePollButton)
    F.ReskinFilterButton(leaderOptions.readyCheckButton)
    F.ReskinFilterButton(leaderOptions.rolePollButton)
    F.ReskinFilterButton(leaderOptions.rolePollButton)
    local worldMarks = _G[leaderOptions:GetName().."RaidWorldMarkerButton"]
    F.ReskinFilterButton(_G[leaderOptions:GetName().."RaidWorldMarkerButton"], true)
    worldMarks:SetNormalTexture([[Interface\RaidFrame\Raid-WorldPing]])
    worldMarks.Icon:SetDrawLayer("ARTWORK")

    F.ReskinCheck(displayFrame.everyoneIsAssistButton)
end
