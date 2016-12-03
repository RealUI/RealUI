local _, mods = ...

_G.tinsert(mods["nibRealUI"], function(F, C)
    mods.debug("WorldMapFrame", F, C)
    local function skin()
        --print("Map:Skin")
        if not _G.WorldMapFrame.skinned then
            _G.WorldMapFrame:SetUserPlaced(true)
            local trackingBtn = _G.WorldMapFrame.UIElementsFrame.TrackingOptionsButton

            --Buttons
            trackingBtn:ClearAllPoints()
            trackingBtn:SetPoint("TOPRIGHT", _G.WorldMapFrame.UIElementsFrame, 3, 3)

            --Foglight
            if _G.foglightmenu and _G.Aurora then
                _G.foglightmenu:ClearAllPoints()
                _G.foglightmenu:SetPoint("TOPRIGHT", trackingBtn, "TOPLEFT", 20, 0)
                F.ReskinDropDown(_G.foglightmenu)
            end
            _G.WorldMapFrame.skinned = true
        end
    end

    -- Coordinate Display --
    local coords = _G.CreateFrame("Frame", nil, _G.WorldMapFrame)
    _G.WorldMapFrame.coords = coords

    coords:SetFrameLevel(_G.WorldMapDetailFrame:GetFrameLevel() + 1)
    coords:SetFrameStrata(_G.WorldMapDetailFrame:GetFrameStrata())

    coords.player = coords:CreateFontString(nil, "OVERLAY")
    coords.player:SetPoint("TOPLEFT", _G.WorldMapFrame, 40.5, -10.5)
    coords.player:SetFontObject(_G.RealUIFont_PixelSmall)
    coords.player:SetJustifyH("LEFT")
    coords.player:SetText("")

    coords.mouse = coords:CreateFontString(nil, "OVERLAY")
    coords.mouse:SetPoint("TOPLEFT", _G.WorldMapFrame, 160.5, -10.5)
    coords.mouse:SetFontObject(_G.RealUIFont_PixelSmall)
    coords.mouse:SetJustifyH("LEFT")
    coords.mouse:SetText("")

    local round, classColorStr = _G.RealUI.Round, _G.RealUI:ColorTableToStr({C.r, C.g, C.b})
    local function updateCoords(self, elapsed)
        --print("UpdateCoords")

        -- Player
        local playerX, playerY = _G.GetPlayerMapPosition("player")
        if (playerX and playerX > 0) and (playerY and playerY > 0) then
            playerX = round(100 * playerX, 1)
            playerY = round(100 * playerY, 1)

            coords.player:SetText(("|cff%s%s: |cffffffff%s, %s|r"):format(classColorStr, _G.PLAYER, playerX, playerY))
        else
            coords.player:SetText(("|cff%s%s: |cffffffff%s|r"):format(classColorStr, _G.PLAYER, _G.UNAVAILABLE))
        end

        -- Mouse
        local scale = _G.WorldMapDetailFrame:GetEffectiveScale()
        local width = _G.WorldMapDetailFrame:GetWidth()
        local height = _G.WorldMapDetailFrame:GetHeight()
        local centerX, centerY = _G.WorldMapDetailFrame:GetCenter()
        local cursorX, cursorY = _G.GetCursorPosition()
        local adjustedX = (cursorX / scale - (centerX - (width/2))) / width
        local adjustedY = (centerY + (height/2) - cursorY / scale) / height

        if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
            adjustedX = round(100 * adjustedX, 1)
            adjustedY = round(100 * adjustedY, 1)
            coords.mouse:SetText(("|cff%s%s: |cffffffff%s, %s|r"):format(classColorStr, _G.MOUSE_LABEL, adjustedX, adjustedY))
        else
            coords.mouse:SetText("")
        end
    end

    -- Size Adjust --
    local function SetLargeWorldMap()
        --print("SetLargeWorldMap")
        if _G.InCombatLockdown() then return end

        -- reparent
        _G.WorldMapFrame:SetParent(_G.UIParent)
        _G.WorldMapFrame:SetFrameStrata("HIGH")
        _G.WorldMapTooltip:SetFrameStrata("TOOLTIP");
        _G.WorldMapCompareTooltip1:SetFrameStrata("TOOLTIP");
        _G.WorldMapCompareTooltip2:SetFrameStrata("TOOLTIP");

        --reposition
        _G.WorldMapFrame:ClearAllPoints()
        _G.WorldMapFrame:SetPoint("CENTER", 0, 0)
        _G.SetUIPanelAttribute(_G.WorldMapFrame, "area", "center")
        _G.SetUIPanelAttribute(_G.WorldMapFrame, "allowOtherPanels", true)
        _G.WorldMapFrame:SetSize(1022, 766)
    end

    local function SetQuestWorldMap()
        if _G.InCombatLockdown() or not _G.IsAddOnLoaded("Aurora") then return end

        _G.WorldMapFrameNavBar:SetPoint("TOPLEFT", _G.WorldMapFrame.BorderFrame, 3, -33)
        _G.WorldMapFrameNavBar:SetWidth(700)
    end

    if _G.InCombatLockdown() then return end

    _G.BlackoutWorld:SetTexture(nil)

    _G.QuestMapFrame_Hide()
    if _G.GetCVar("questLogOpen") == 1 then
        _G.QuestMapFrame_Show()
    end

    _G.hooksecurefunc("WorldMap_ToggleSizeUp", SetLargeWorldMap)
    _G.hooksecurefunc("WorldMap_ToggleSizeDown", SetQuestWorldMap)

    if _G.WORLDMAP_SETTINGS.size == _G.WORLDMAP_FULLMAP_SIZE then
        _G.WorldMap_ToggleSizeUp()
    elseif _G.WORLDMAP_SETTINGS.size == _G.WORLDMAP_WINDOWED_SIZE then
        _G.WorldMap_ToggleSizeDown()
    end

    local ticker
    _G.WorldMapFrame:HookScript("OnShow", function()
        --print("WMF:OnShow", WORLDMAP_SETTINGS.size, GetCVarBool("miniWorldMap"))
        ticker = _G.C_Timer.NewTicker(0.1, updateCoords)
        skin(_G.WORLDMAP_SETTINGS.size)
    end)
    _G.WorldMapFrame:HookScript("OnHide", function()
        --print("WMF:OnHide")
        ticker:Cancel()
    end)

    _G.DropDownList1:HookScript("OnShow", function(self)
        if _G.DropDownList1:GetScale() ~= _G.UIParent:GetScale() then
            _G.DropDownList1:SetScale(_G.UIParent:GetScale())
        end
    end)
end)
