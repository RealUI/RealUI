local _, mods = ...

mods["Blizzard_CompactRaidFrames"] = function(F, C)
    mods.debug("Blizzard_CompactRaidFrames", F, C)

    local CompactRaidFrameManager = _G.CompactRaidFrameManager
    CompactRaidFrameManager:DisableDrawLayer("ARTWORK")
    F.CreateBD(CompactRaidFrameManager)

    local toggleButton = CompactRaidFrameManager.toggleButton
    toggleButton:DisableDrawLayer("OVERLAY")
    toggleButton:SetPoint("RIGHT", -1, 0)
    toggleButton:HookScript("OnEnter", F.colorTex)
    toggleButton:HookScript("OnLeave", F.clearTex)

    toggleButton.tex = {}
    for i = 1, 2 do
        local tex = toggleButton:CreateTexture(nil, "ARTWORK")
        tex:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\triangle.blp]])
        tex:SetVertexColor(1, 1, 1)

        local height = toggleButton:GetHeight() * 0.5
        if i == 1 then
            tex:SetPoint("TOPLEFT", 3, 0)
            tex:SetPoint("BOTTOMRIGHT", -2, height)
            tex:SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)
        elseif i == 2 then
            tex:SetPoint("TOPLEFT", 3, -height)
            tex:SetPoint("BOTTOMRIGHT", -2, 0)
        end
        _G.tinsert(toggleButton.tex, tex)
    end
    _G.hooksecurefunc("CompactRaidFrameManager_Toggle", function(self)
        if self.collapsed then
            toggleButton.tex[1]:SetTexCoord(0, 1, 0, 0, 1, 1, 1, 0)
            toggleButton.tex[2]:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
        else
            toggleButton.tex[1]:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0)
            toggleButton.tex[2]:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
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
