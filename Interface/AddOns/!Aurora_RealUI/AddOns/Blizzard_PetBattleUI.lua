-- Code from FreeUI by the awesome Haleth
-- http://www.wowinterface.com/downloads/info17892-FreeUI.html
local _, mods = ...

-- Lua Globals --
local _G = _G
local next = _G.next

_G.tinsert(mods["PLAYER_LOGIN"], function(F, C)
    mods.debug("Blizzard_PetBattleUI", F, C)
    local RealUI = _G.RealUI
    local r, g, b = C.r, C.g, C.b

    local frame = _G.PetBattleFrame
    local bf = frame.BottomFrame
    local turnTimer = bf.TurnTimer

    frame.TopArtLeft:Hide()
    frame.TopArtRight:Hide()
    frame.TopVersus:Hide()
    frame.TopVersusText:Hide()

    -- Tooltips
    local tooltips = {_G.PetBattlePrimaryAbilityTooltip, _G.PetBattlePrimaryUnitTooltip, _G.FloatingBattlePetTooltip, _G.BattlePetTooltip, _G.FloatingPetBattleAbilityTooltip}
    for _, f in next, tooltips do
        f:DisableDrawLayer("BACKGROUND")
        local bg = _G.CreateFrame("Frame", nil, f)
        bg:SetAllPoints()
        bg:SetFrameLevel(0)
        F.CreateBD(bg)
        f.bg = bg
    end

    _G.PetBattlePrimaryUnitTooltip.Delimiter:SetColorTexture(0, 0, 0)
    _G.PetBattlePrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
    _G.PetBattlePrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
    _G.FloatingPetBattleAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
    _G.FloatingPetBattleAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
    _G.FloatingBattlePetTooltip.Delimiter:SetColorTexture(0, 0, 0)
    _G.PetBattlePrimaryUnitTooltip.Delimiter:SetHeight(1)
    _G.PetBattlePrimaryAbilityTooltip.Delimiter1:SetHeight(1)
    _G.PetBattlePrimaryAbilityTooltip.Delimiter2:SetHeight(1)
    _G.FloatingPetBattleAbilityTooltip.Delimiter1:SetHeight(1)
    _G.FloatingPetBattleAbilityTooltip.Delimiter2:SetHeight(1)
    _G.FloatingBattlePetTooltip.Delimiter:SetHeight(1)
    F.ReskinClose(_G.FloatingBattlePetTooltip.CloseButton)
    F.ReskinClose(_G.FloatingPetBattleAbilityTooltip.CloseButton)

    _G.PetBattlePrimaryUnitTooltip.Icon:SetTexCoord(.08, .92, .08, .92)
    _G.PetBattlePrimaryUnitTooltip.Icon.bg = F.CreateBG(_G.PetBattlePrimaryUnitTooltip.Icon)
    _G.PetBattlePrimaryUnitTooltip.Icon.bg:SetDrawLayer("BORDER")

    _G.PetBattlePrimaryUnitTooltip.HealthBG:SetTexture("")
    _G.PetBattlePrimaryUnitTooltip.XPBG:SetTexture("")
    _G.PetBattlePrimaryUnitTooltip.Border:Hide()

    for _, f in next, {_G.PetBattlePrimaryUnitTooltip.ActualHealthBar, _G.PetBattlePrimaryUnitTooltip.XPBar} do
        local bg = _G.CreateFrame("Frame", nil, f:GetParent())
        bg:SetPoint("TOPLEFT", f, -1, 1)
        bg:SetPoint("BOTTOMLEFT", f, -1, -1)
        bg:SetWidth(232)
        bg:SetFrameLevel(0)
        F.CreateBD(bg, .25)

        f.bg = bg

        f:SetTexture(RealUI.media.textures.plain)
    end

    _G.PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
        _G.PetBattlePrimaryUnitTooltip.Icon.bg:SetVertexColor(self.Border:GetVertexColor())
        self.bg:SetBackdropColor(0, 0, 0, .5)
        self.ActualHealthBar.bg:SetBackdropColor(0, 0, 0, .25)
        self.XPBar.bg:SetBackdropColor(0, 0, 0, .25)
    end)

    _G.hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
        self.XPBar.bg:SetShown(self.XPBar:IsShown())
    end)

    -- Weather etc

    frame.WeatherFrame.Icon:Hide()
    frame.WeatherFrame.Name:Hide()
    frame.WeatherFrame.DurationShadow:Hide()
    frame.WeatherFrame.Label:Hide()
    frame.WeatherFrame.Duration:SetPoint("CENTER", frame.WeatherFrame, 0, 8)
    frame.WeatherFrame:ClearAllPoints()
    frame.WeatherFrame:SetPoint("TOP", _G.UIParent, 0, -15)

    -- Units

    local units = {frame.ActiveAlly, frame.ActiveEnemy}

    for index, unit in next, units do
        unit.healthBarWidth = 300

        unit.Border:SetDrawLayer("ARTWORK", 0)
        unit.Border2:SetDrawLayer("ARTWORK", 1)
        unit.HealthBarBG:Hide()
        unit.HealthBarFrame:Hide()
        unit.LevelUnderlay:Hide()
        unit.SpeedUnderlay:SetAlpha(0)
        unit.PetType:Hide()

        unit.ActualHealthBar:SetTexture(RealUI.media.textures.plain80)

        unit.Border:SetTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
        unit.Border:SetTexCoord(0, 1, 0, 1)
        unit.Border:SetPoint("TOPLEFT", unit.Icon, -1, 1)
        unit.Border:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
        unit.Border2:SetTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
        unit.Border2:SetVertexColor(.89, .88, .06)
        unit.Border2:SetTexCoord(0, 1, 0, 1)
        unit.Border2:SetPoint("TOPLEFT", unit.Icon, -1, 1)
        unit.Border2:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)

        unit.Level:SetFont(_G.RealUIFont_Normal:GetFont(), 16)
        unit.Level:SetTextColor(1, 1, 1)

        local bg = _G.CreateFrame("Frame", nil, unit)
        bg:SetWidth(unit.healthBarWidth + 2)
        bg:SetFrameLevel(unit:GetFrameLevel()-1)
        F.CreateBD(bg)

        unit.HealthText:SetPoint("CENTER", bg, "CENTER")

        unit.PetTypeString = unit:CreateFontString(nil, "ARTWORK")
        unit.PetTypeString:SetFontObject(_G.GameFontNormalLarge)

        unit.Name:ClearAllPoints()
        unit.ActualHealthBar:ClearAllPoints()

        if index == 1 then
            bg:SetPoint("TOPLEFT", unit.ActualHealthBar, "TOPLEFT", -1, 1)
            bg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, "BOTTOMLEFT", -1, -1)
            --unit.ActualHealthBar:SetGradient("VERTICAL", .26, 1, .22, .13, .5, .11)
            unit.ActualHealthBar:SetPoint("BOTTOMLEFT", unit.Icon, "BOTTOMRIGHT", 10, 0)
            unit.ActualHealthBar:SetVertexColor(.26, 1, .22)
            unit.Name:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 0, 4)
            unit.PetTypeString:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT", 0, 4)
            unit.PetTypeString:SetJustifyH("RIGHT")
        else
            bg:SetPoint("TOPRIGHT", unit.ActualHealthBar, "TOPRIGHT", 1, 1)
            bg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "BOTTOMRIGHT", 1, -1)
            --unit.ActualHealthBar:SetGradient("VERTICAL", 1, .12, .24, .5, .06, .12)
            unit.ActualHealthBar:SetPoint("BOTTOMRIGHT", unit.Icon, "BOTTOMLEFT", -10, 0)
            unit.ActualHealthBar:SetVertexColor(1, .12, .24)
            unit.Name:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT", 0, 4)
            unit.PetTypeString:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 0, 4)
            unit.PetTypeString:SetJustifyH("LEFT")
        end

        unit.Icon:SetDrawLayer("ARTWORK", 2)
        F.CreateBG(unit.Icon)
    end

    local extraUnits = {
        frame.Ally2,
        frame.Ally3,
        frame.Enemy2,
        frame.Enemy3
    }

    for index, unit in next, extraUnits do
        unit.healthBarWidth = 36

        unit:SetSize(36, 36)

        unit.HealthBarBG:SetAlpha(0)
        unit.HealthDivider:SetAlpha(0)

        unit.ActualHealthBar:ClearAllPoints()
        unit.ActualHealthBar:SetPoint("BOTTOM")
        unit.ActualHealthBar:SetTexture(RealUI.media.textures.plain)

        unit.BorderAlive:SetTexture(RealUI.media.textures.plain80)
        unit.BorderAlive:SetPoint("TOPLEFT", unit.Icon, -1, 1)
        unit.BorderAlive:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
        unit.BorderAlive:SetDrawLayer("BACKGROUND")
        unit.BorderDead:SetTexture(RealUI.media.textures.plain80)
        unit.BorderDead:SetPoint("TOPLEFT", unit.Icon, -1, 1)
        unit.BorderDead:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
        unit.BorderDead:SetDrawLayer("BACKGROUND")
        unit.BorderDead:SetVertexColor(1, 0, 0)

        unit.HealthBorder = unit:CreateTexture()
        unit.HealthBorder:SetColorTexture(0, 0, 0)
        unit.HealthBorder:SetSize(36, 1)
        unit.HealthBorder:SetPoint("TOP", unit.ActualHealthBar, 0, 1)

        unit.Icon:SetDrawLayer("BACKGROUND", 2)

        if index < 3 then
            unit.ActualHealthBar:SetVertexColor(.26, 1, .22)
        else
            unit.ActualHealthBar:SetVertexColor(1, .12, .24)
        end
    end

    local function petSelectOnEnter(self)
        if self.MouseoverHighlight:IsShown() then
            self.bg:SetBackdropBorderColor(r, g, b)
        end
    end

    local function petSelectOnLeave(self)
        self.bg:SetBackdropBorderColor(0, 0, 0)
    end

    for i = 1, _G.NUM_BATTLE_PETS_IN_BATTLE  do
        local unit = bf.PetSelectionFrame["Pet"..i]
        local icon = unit.Icon

        unit.HealthBarBG:Hide()
        unit.Framing:Hide()
        unit.HealthDivider:Hide()
        unit.SelectedTexture:SetTexture("")
        unit.MouseoverHighlight:SetTexture("")

        unit.Name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -3)
        unit.ActualHealthBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 3, 0)

        -- Begin frame level and draw layer nightmare

        unit.bg = _G.CreateFrame("Frame", nil, unit)
        unit.bg:SetSize(168, 37)
        unit.bg:SetPoint("BOTTOM", 3, 9)
        F.CreateBD(unit.bg, 0)

        unit.bd = unit:CreateTexture()
        unit.bd:SetDrawLayer("BACKGROUND", 1)
        unit.bd:SetColorTexture(0, 0, 0, .5)
        unit.bd:SetAllPoints(unit.bg)

        unit.bg.SelectedTexture = unit:CreateTexture()
        unit.bg.SelectedTexture:SetDrawLayer("BACKGROUND", 2)
        unit.bg.SelectedTexture:SetTexture(RealUI.media.textures.plain)
        unit.bg.SelectedTexture:SetVertexColor(r, g, b, .2)
        unit.bg.SelectedTexture:SetPoint("TOPLEFT", unit.bg, 1, -1)
        unit.bg.SelectedTexture:SetPoint("BOTTOMRIGHT", unit.bg, -1, 1)

        icon:SetTexCoord(.08, .92, .08, .92)
        icon.bg = F.CreateBG(icon)
        icon.bg:SetDrawLayer("BACKGROUND", 3)

        unit.ActualHealthBar:SetTexture(RealUI.media.textures.plain)
        unit.ActualHealthBar.bg = _G.CreateFrame("Frame", nil, unit)
        unit.ActualHealthBar.bg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
        unit.ActualHealthBar.bg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, -1, -1)
        unit.ActualHealthBar.bg:SetWidth(130)
        F.CreateBD(unit.ActualHealthBar.bg, 0)

        unit.ActualHealthBar.bd = unit:CreateTexture()
        unit.ActualHealthBar.bd:SetDrawLayer("BACKGROUND", 3)
        unit.ActualHealthBar.bd:SetColorTexture(0, 0, 0, .25)
        unit.ActualHealthBar.bd:SetAllPoints(unit.ActualHealthBar.bg)

        unit:HookScript("OnEnter", petSelectOnEnter)
        unit:HookScript("OnLeave", petSelectOnLeave)
    end


    _G.hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
        local petOwner = self.petOwner

        if (not petOwner) or self.petIndex > _G.C_PetBattles.GetNumPets(petOwner) then return end

        if self.Icon then
            if petOwner == _G.LE_BATTLE_PET_ALLY then
                self.Icon:SetTexCoord(.92, .08, .08, .92)
            else
                self.Icon:SetTexCoord(.08, .92, .08, .92)
            end
        end

        if self.SelectedTexture then
            self.bg.SelectedTexture:SetShown(self.SelectedTexture:IsShown())
        end
    end)

    _G.hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
        if self.PetType and self.PetTypeString then
            local petType = _G.C_PetBattles.GetPetType(self.petOwner, self.petIndex)
            self.PetTypeString:SetText(_G.PET_TYPE_SUFFIX[petType])
        end
    end)

    _G.hooksecurefunc("PetBattleAuraHolder_Update", function(self)
        if not self.petOwner or not self.petIndex then return end

        local nextFrame = 1
        for i = 1, _G.C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
            local _, _, turnsRemaining, isBuff = _G.C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
            if (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) then
                local petAura = self.frames[nextFrame]

                petAura.DebuffBorder:Hide()

                if not petAura.reskinned then
                    petAura.Icon:SetTexCoord(.08, .92, .08, .92)
                    petAura.bg = F.CreateBG(petAura.Icon)
                end

                petAura.Duration:SetFontObject(_G.RealUIFont_PixelSmall)
                petAura.Duration:SetShadowOffset(0, 0)
                petAura.Duration:ClearAllPoints()
                petAura.Duration:SetPoint("BOTTOM", petAura.Icon, 1, -1)

                if turnsRemaining > 0 then
                    petAura.Duration:SetText(turnsRemaining)
                end

                if isBuff then
                    petAura.bg:SetVertexColor(0, 1, 0)
                else
                    petAura.bg:SetVertexColor(1, 0, 0)
                end

                nextFrame = nextFrame + 1
            end
        end
    end)

    -- [[ Action bar ]]


    local bar = _G.CreateFrame("Frame", "FreeUIPetBattleActionBar", _G.UIParent, "SecureHandlerStateTemplate")
    bar:SetPoint("BOTTOM", _G.UIParent, "BOTTOM", 0, 100)
    bar:SetSize(6 * 33, 32)
    _G.RegisterStateDriver(bar, "visibility", "[petbattle] show; hide")

    bf.RightEndCap:Hide()
    bf.LeftEndCap:Hide()
    bf.Background:Hide()
    bf.Delimiter:Hide()
    turnTimer.TimerBG:SetTexture("")
    turnTimer.ArtFrame:SetTexture("")
    turnTimer.ArtFrame2:SetTexture("")
    bf.FlowFrame.LeftEndCap:Hide()
    bf.FlowFrame.RightEndCap:Hide()
    _G.select(3, bf.FlowFrame:GetRegions()):Hide()
    bf.MicroButtonFrame:Hide()
    _G.PetBattleFrameXPBarLeft:Hide()
    _G.PetBattleFrameXPBarRight:Hide()
    _G.PetBattleFrameXPBarMiddle:Hide()

    turnTimer.SkipButton:SetParent(bar)
    turnTimer.SkipButton:SetWidth(bar:GetWidth() - 1)
    turnTimer.SkipButton:ClearAllPoints()
    turnTimer.SkipButton:SetPoint("BOTTOM", bar, "TOP", 0, 2)
    turnTimer.SkipButton.ClearAllPoints = F.dummy
    turnTimer.SkipButton.SetPoint = F.dummy
    F.Reskin(turnTimer.SkipButton)

    turnTimer.Bar:ClearAllPoints()
    turnTimer.Bar:SetPoint("LEFT")

    turnTimer:SetParent(bar)
    turnTimer:SetSize(turnTimer.SkipButton:GetWidth() - 2, turnTimer.SkipButton:GetHeight())
    turnTimer:ClearAllPoints()
    turnTimer:SetPoint("BOTTOM", turnTimer.SkipButton, "TOP", 0, -1)
    turnTimer.TimerText:ClearAllPoints()
    turnTimer.TimerText:SetPoint("BOTTOM", turnTimer.SkipButton, "TOP", 0, 5)

    turnTimer.bg = F.CreateBDFrame(turnTimer.Bar)
    turnTimer.bg:ClearAllPoints()
    turnTimer.bg:SetPoint("TOPLEFT", -1, -1)
    turnTimer.bg:SetPoint("BOTTOMLEFT", -1, 2)
    turnTimer.bg:SetWidth(turnTimer.SkipButton:GetWidth())

    bf.xpBar:SetParent(bar)
    bf.xpBar:SetWidth(bar:GetWidth() - 3)
    bf.xpBar:ClearAllPoints()
    bf.xpBar:SetPoint("BOTTOM", turnTimer, "TOP", 0, 1)
    bf.xpBar:SetStatusBarTexture(RealUI.media.textures.plain80)
    F.CreateBDFrame(bf.xpBar, 0)

    for i = 7, 12 do
        _G.select(i, bf.xpBar:GetRegions()):Hide()
    end

    _G.hooksecurefunc("PetBattlePetSelectionFrame_Show", function()
        bf.PetSelectionFrame:ClearAllPoints()
        bf.PetSelectionFrame:SetPoint("BOTTOM", bf.xpBar, "TOP", 0, 8)
    end)

    _G.hooksecurefunc("PetBattleFrame_UpdatePassButtonAndTimer", function()
        local pveBattle = _G.C_PetBattles.IsPlayerNPC(_G.LE_BATTLE_PET_ENEMY)

        turnTimer.bg:SetShown(not pveBattle)

        bf.xpBar:ClearAllPoints()

        if pveBattle then
            bf.xpBar:SetPoint("BOTTOM", turnTimer.SkipButton, "TOP", 0, 2)
        else
            bf.xpBar:SetPoint("BOTTOM", turnTimer, "TOP", 0, 1)
        end
    end)

    -- Just to resize it, really. Whatever happened to StatusBar that could actually be resized properly?
    local TIMER_BAR_TEXCOORD_LEFT = 0.56347656
    local TIMER_BAR_TEXCOORD_RIGHT = 0.89453125
    local TIMER_BAR_TEXCOORD_TOP = 0.00195313
    local TIMER_BAR_TEXCOORD_BOTTOM = 0.03515625

    turnTimer:SetScript("OnUpdate", function(self)
        if ( ( _G.C_PetBattles.GetBattleState() ~= _G.LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) and
             ( _G.C_PetBattles.GetBattleState() ~= _G.LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS ) and
             ( _G.C_PetBattles.GetBattleState() ~= _G.LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS ) ) then
            self.Bar:SetAlpha(0);
            self.TimerText:SetText("");
        elseif ( self.turnExpires ) then
            local timeRemaining = self.turnExpires - _G.GetTime();

            --Deal with variable lag from the server without looking weird
            if ( timeRemaining <= 0.01 ) then
                timeRemaining = 0.01;
            end

            local timeRatio = 1.0;
            if ( self.turnTime > 0.0 ) then
                timeRatio = timeRemaining / self.turnTime;
            end
            local usableSpace = 160;

            self.Bar:SetWidth(timeRatio * usableSpace);
            self.Bar:SetTexCoord(TIMER_BAR_TEXCOORD_LEFT, TIMER_BAR_TEXCOORD_LEFT + (TIMER_BAR_TEXCOORD_RIGHT - TIMER_BAR_TEXCOORD_LEFT) * timeRatio, TIMER_BAR_TEXCOORD_TOP, TIMER_BAR_TEXCOORD_BOTTOM);

            if ( _G.C_PetBattles.IsWaitingOnOpponent() ) then
                self.Bar:SetAlpha(0.5);
                self.TimerText:SetText(_G.PET_BATTLE_WAITING_FOR_OPPONENT);
            else
                self.Bar:SetAlpha(1);
                if ( self.turnTime > 0.0 ) then
                    self.TimerText:SetText(_G.ceil(timeRemaining));
                else
                    self.TimerText:SetText("")
                end
            end
        else
            self.Bar:SetAlpha(0);
            if ( _G.C_PetBattles.IsWaitingOnOpponent() ) then
                self.TimerText:SetText(_G.PET_BATTLE_WAITING_FOR_OPPONENT);
            else
                self.TimerText:SetText(_G.PET_BATTLE_SELECT_AN_ACTION);
            end
        end
    end)

    -- [[ Buttons ]]

    local function stylePetBattleButton(bu)
        if bu.reskinned then return end

        local pushed = bu:GetPushedTexture()
        local icon = bu.Icon
        local ho = bu.HotKey
        local cd = bu.Cooldown
        local bi = bu.BetterIcon
        local se = bu.SelectedHighlight

        bu:SetNormalTexture("")
        bu:SetHighlightTexture("")

        bu.bg = _G.CreateFrame("Frame", nil, bu)
        bu.bg:SetAllPoints(bu)
        bu.bg:SetFrameLevel(0)
        bu.bg:SetBackdrop({
            edgeFile = RealUI.media.textures.plain,
            edgeSize = 1,
        })
        bu.bg:SetBackdropBorderColor(0, 0, 0)

        icon:SetDrawLayer("BACKGROUND", 2)
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:SetPoint("TOPLEFT", bu, 1, -1)
        icon:SetPoint("BOTTOMRIGHT", bu, -1, 1)

        bu.CooldownShadow:SetAllPoints()
        bu.CooldownFlash:SetAllPoints()

        pushed:SetColorTexture(r, g, b)
        pushed:SetDrawLayer("BACKGROUND")
        pushed:SetAllPoints()

        se:SetColorTexture(r, g, b, .2)
        se:SetAllPoints()

        ho:SetFontObject(_G.RealUIFont_PixelSmall)

        cd:SetFontObject(_G.RealUIFont_PixelCooldown)
        cd:SetTextColor(1, 1, 1)
        cd:SetShadowOffset(0, 0)

        bi:SetSize(30, 30)
        bi:ClearAllPoints()
        bi:SetPoint("BOTTOM", 6, -9)

        bu.reskinned = true
    end

    -- hooksecurefunc("PetBattleAbilityButton_UpdateHotKey", function(self)
    --  self.HotKey:SetShown(self.HotKey:IsShown())
    -- end)

    local first = true
    _G.hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
        for i = 1, _G.NUM_BATTLE_PET_ABILITIES do
            local bu = bf.abilityButtons[i]
            stylePetBattleButton(bu)
            bu:SetParent(bar)
            bu:SetSize(32, 32)
            bu:ClearAllPoints()
            if i == 1 then
                bu:SetPoint("BOTTOMLEFT", bar)
            else
                local previous = bf.abilityButtons[i-1]
                bu:SetPoint("LEFT", previous, "RIGHT", 1, 0)
            end
        end

        local utilBtns = {bf.SwitchPetButton, bf.CatchButton, bf.ForfeitButton}
        for index, btn in next, utilBtns do
            stylePetBattleButton(btn)
            btn:SetParent(bar)
            btn:SetSize(32, 32)
            btn:ClearAllPoints()
            if index == 1 then
                btn:SetPoint("LEFT", bf.abilityButtons[_G.NUM_BATTLE_PET_ABILITIES], "RIGHT", 1, 0)
                btn:SetCheckedTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
            else
                btn:SetPoint("LEFT", utilBtns[index - 1], "RIGHT", 1, 0)
            end
        end

        if first then
            first = false
            bf.SwitchPetButton:SetScript("OnClick", function()
                if bf.PetSelectionFrame:IsShown() then
                    _G.PetBattlePetSelectionFrame_Hide(bf.PetSelectionFrame)
                else
                    _G.PetBattlePetSelectionFrame_Show(bf.PetSelectionFrame)
                end
            end)
        end
    end)
end)
