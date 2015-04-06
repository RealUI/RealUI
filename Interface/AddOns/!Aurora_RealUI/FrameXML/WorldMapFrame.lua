local _, mods = ...

tinsert(mods["nibRealUI"], function(F, C)
    mods.debug("WorldMapFrame", F, C)
    local function skin()
        --print("Map:Skin")
        WorldMapPlayerUpper:EnableMouse(false)
        WorldMapPlayerLower:EnableMouse(false)

        if not WorldMapFrame.skinned then
            WorldMapFrame:SetUserPlaced(true)
            local trackingBtn = WorldMapFrame.UIElementsFrame.TrackingOptionsButton

            --Buttons
            WorldMapLevelDropDown:ClearAllPoints()
            WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapFrame.UIElementsFrame, -15, 3)
            trackingBtn:ClearAllPoints()
            trackingBtn:SetPoint("TOPRIGHT", WorldMapFrame.UIElementsFrame, 3, 3)

            --Foglight
            if foglightmenu and Aurora then
                local F = Aurora[1]
                foglightmenu:ClearAllPoints()
                foglightmenu:SetPoint("TOPRIGHT", trackingBtn, "TOPLEFT", 20, 0)
                F.ReskinDropDown(foglightmenu)
            end
            WorldMapFrame.skinned = true
        end
    end

    -- Coordinate Display --
    local coords = CreateFrame("Frame", nil, WorldMapFrame)
    WorldMapFrame.coords = coords

    coords:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
    coords:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())

    coords.player = coords:CreateFontString(nil, "OVERLAY")
    coords.player:SetPoint("BOTTOMLEFT", WorldMapFrame.UIElementsFrame, "BOTTOMLEFT", 4.5, 4.5)
    coords.player:SetFontObject(RealUIFont_PixelSmall)
    coords.player:SetText("")

    coords.mouse = coords:CreateFontString(nil, "OVERLAY")
    coords.mouse:SetPoint("BOTTOMLEFT", WorldMapFrame.UIElementsFrame, "BOTTOMLEFT", 120.5, 4.5)
    coords.mouse:SetFontObject(RealUIFont_PixelSmall)
    coords.mouse:SetText("")

    local round, classColorStr = RealUI.Round, RealUI:ColorTableToStr({C.r, C.g, C.b})
    local function updateCoords(self, elapsed)
        --print("UpdateCoords")

        -- Player
        local x, y = GetPlayerMapPosition("player")
        x = round(100 * x, 1)
        y = round(100 * y, 1)

        if x ~= 0 and y ~= 0 then
            coords.player:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, PLAYER, x, y))
        else
            coords.player:SetText("")
        end

        -- Mouse
        local scale = WorldMapDetailFrame:GetEffectiveScale()
        local width = WorldMapDetailFrame:GetWidth()
        local height = WorldMapDetailFrame:GetHeight()
        local centerX, centerY = WorldMapDetailFrame:GetCenter()
        local x, y = GetCursorPosition()
        local adjustedX = (x / scale - (centerX - (width/2))) / width
        local adjustedY = (centerY + (height/2) - y / scale) / height

        if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
            adjustedX = round(100 * adjustedX, 1)
            adjustedY = round(100 * adjustedY, 1)
            coords.mouse:SetText(string.format("|cff%s%s: |cffffffff%s, %s|r", classColorStr, MOUSE_LABEL, adjustedX, adjustedY))
        else
            coords.mouse:SetText("")
        end
    end

    -- Size Adjust --
    local function SetLargeWorldMap()
        --print("SetLargeWorldMap")
        if InCombatLockdown() then return end

        -- reparent
        WorldMapFrame:SetParent(UIParent)
        WorldMapFrame:SetFrameStrata("HIGH")
        WorldMapFrame:EnableKeyboard(true)

        --reposition
        WorldMapFrame:ClearAllPoints()
        WorldMapFrame:SetPoint("CENTER", 0, 0)
        SetUIPanelAttribute(WorldMapFrame, "area", "center")
        SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
        WorldMapFrame:SetSize(1022, 766)
    end

    local function SetQuestWorldMap()
        if InCombatLockdown() or not IsAddOnLoaded("Aurora") then return end

        WorldMapFrameNavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 3, -33)
        WorldMapFrameNavBar:SetWidth(700)
    end

    if InCombatLockdown() then return end

    BlackoutWorld:SetTexture(nil)

    QuestMapFrame_Hide()
    if GetCVar("questLogOpen") == 1 then
        QuestMapFrame_Show()
    end

    hooksecurefunc("WorldMap_ToggleSizeUp", SetLargeWorldMap)
    hooksecurefunc("WorldMap_ToggleSizeDown", SetQuestWorldMap)

    if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
        WorldMap_ToggleSizeUp()
    elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
        WorldMap_ToggleSizeDown()
    end

    local ticker
    WorldMapFrame:HookScript("OnShow", function()
        --print("WMF:OnShow", WORLDMAP_SETTINGS.size, GetCVarBool("miniWorldMap"))
        ticker = C_Timer.NewTicker(0.1, updateCoords)
        skin(WORLDMAP_SETTINGS.size)
    end)
    WorldMapFrame:HookScript("OnHide", function()
        --print("WMF:OnHide")
        ticker:Cancel()
    end)

    DropDownList1:HookScript("OnShow", function(self)
        if DropDownList1:GetScale() ~= UIParent:GetScale() then
            DropDownList1:SetScale(UIParent:GetScale())
        end
    end)
end)
