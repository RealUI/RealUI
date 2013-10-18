-- Code from FreeUI by the awesome Haleth
-- http://www.wowinterface.com/downloads/info17892-FreeUI.html

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndbc

local MODNAME = "PetBattles"
local PetBattles = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

function PetBattles:Skin()
	if not Aurora then return end
	
	local F, C = unpack(Aurora)
	local r, g, b = unpack(nibRealUI.classColor)

	local frame = PetBattleFrame
	local bf = frame.BottomFrame
	local turnTimer = bf.TurnTimer

	frame.TopArtLeft:Hide()
	frame.TopArtRight:Hide()
	frame.TopVersus:Hide()
	frame.TopVersusText:Hide()

	-- Tooltips
	local tooltips = {PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip, FloatingBattlePetTooltip, BattlePetTooltip, FloatingPetBattleAbilityTooltip}
	for _, f in pairs(tooltips) do
		f:DisableDrawLayer("BACKGROUND")
		local bg = CreateFrame("Frame", nil, f)
		bg:SetAllPoints()
		bg:SetFrameLevel(0)
		F.CreateBD(bg)
		f.bg = bg
	end

	PetBattlePrimaryUnitTooltip.Delimiter:SetTexture(0, 0, 0)
	PetBattlePrimaryUnitTooltip.Delimiter:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter1:SetTexture(0, 0, 0)
	PetBattlePrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	PetBattlePrimaryAbilityTooltip.Delimiter2:SetTexture(0, 0, 0)
	FloatingPetBattleAbilityTooltip.Delimiter1:SetHeight(1)
	FloatingPetBattleAbilityTooltip.Delimiter1:SetTexture(0, 0, 0)
	FloatingPetBattleAbilityTooltip.Delimiter2:SetHeight(1)
	FloatingPetBattleAbilityTooltip.Delimiter2:SetTexture(0, 0, 0)
	FloatingBattlePetTooltip.Delimiter:SetTexture(0, 0, 0)
	FloatingBattlePetTooltip.Delimiter:SetHeight(1)
	F.ReskinClose(FloatingBattlePetTooltip.CloseButton)
	F.ReskinClose(FloatingPetBattleAbilityTooltip.CloseButton)

	PetBattlePrimaryUnitTooltip.Icon:SetTexCoord(.08, .92, .08, .92)
	PetBattlePrimaryUnitTooltip.Icon.bg = F.CreateBG(PetBattlePrimaryUnitTooltip.Icon)
	PetBattlePrimaryUnitTooltip.Icon.bg:SetDrawLayer("BORDER")

	PetBattlePrimaryUnitTooltip.HealthBG:SetTexture("")
	PetBattlePrimaryUnitTooltip.XPBG:SetTexture("")
	PetBattlePrimaryUnitTooltip.Border:Hide()

	for _, frame in pairs({PetBattlePrimaryUnitTooltip.ActualHealthBar, PetBattlePrimaryUnitTooltip.XPBar}) do
		local bg = CreateFrame("Frame", nil, frame:GetParent())
		bg:SetPoint("TOPLEFT", frame, -1, 1)
		bg:SetPoint("BOTTOMLEFT", frame, -1, -1)
		bg:SetWidth(232)
		bg:SetFrameLevel(0)
		F.CreateBD(bg, .25)

		frame.bg = bg

		frame:SetTexture(nibRealUI.media.textures.plain)
	end

	PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		PetBattlePrimaryUnitTooltip.Icon.bg:SetVertexColor(self.Border:GetVertexColor())
		self.bg:SetBackdropColor(0, 0, 0, .5)
		self.ActualHealthBar.bg:SetBackdropColor(0, 0, 0, .25)
		self.XPBar.bg:SetBackdropColor(0, 0, 0, .25)
	end)

	hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
		self.XPBar.bg:SetShown(self.XPBar:IsShown())
	end)

	-- Weather etc

	frame.WeatherFrame.Icon:Hide()
	frame.WeatherFrame.Name:Hide()
	frame.WeatherFrame.DurationShadow:Hide()
	frame.WeatherFrame.Label:Hide()
	frame.WeatherFrame.Duration:SetPoint("CENTER", frame.WeatherFrame, 0, 8)
	frame.WeatherFrame:ClearAllPoints()
	frame.WeatherFrame:SetPoint("TOP", UIParent, 0, -15)

	-- Units

	local units = {frame.ActiveAlly, frame.ActiveEnemy}

	for index, unit in pairs(units) do
		unit.healthBarWidth = 300

		unit.Border:SetDrawLayer("ARTWORK", 0)
		unit.Border2:SetDrawLayer("ARTWORK", 1)
		unit.HealthBarBG:Hide()
		unit.HealthBarFrame:Hide()
		unit.LevelUnderlay:Hide()
		unit.SpeedUnderlay:SetAlpha(0)
		unit.PetType:Hide()

		unit.ActualHealthBar:SetTexture(nibRealUI.media.textures.plain80)

		unit.Border:SetTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
		unit.Border:SetTexCoord(0, 1, 0, 1)
		unit.Border:SetPoint("TOPLEFT", unit.Icon, -1, 1)
		unit.Border:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
		unit.Border2:SetTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
		unit.Border2:SetVertexColor(.89, .88, .06)
		unit.Border2:SetTexCoord(0, 1, 0, 1)
		unit.Border2:SetPoint("TOPLEFT", unit.Icon, -1, 1)
		unit.Border2:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)

		unit.Level:SetFont(nibRealUI.font.standard, 16)
		unit.Level:SetTextColor(1, 1, 1)

		local bg = CreateFrame("Frame", nil, unit)
		bg:SetWidth(unit.healthBarWidth + 2)
		bg:SetFrameLevel(unit:GetFrameLevel()-1)
		F.CreateBD(bg)

		unit.HealthText:SetPoint("CENTER", bg, "CENTER")

		unit.PetTypeString = unit:CreateFontString(nil, "ARTWORK")
		unit.PetTypeString:SetFontObject(GameFontNormalLarge)

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

	for index, unit in pairs(extraUnits) do
		unit.healthBarWidth = 36

		unit:SetSize(36, 36)

		unit.HealthBarBG:SetAlpha(0)
		unit.HealthDivider:SetAlpha(0)

		unit.ActualHealthBar:ClearAllPoints()
		unit.ActualHealthBar:SetPoint("BOTTOM")
		unit.ActualHealthBar:SetTexture(nibRealUI.media.textures.plain)

		unit.BorderAlive:SetTexture(nibRealUI.media.textures.plain80)
		unit.BorderAlive:SetPoint("TOPLEFT", unit.Icon, -1, 1)
		unit.BorderAlive:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
		unit.BorderAlive:SetDrawLayer("BACKGROUND")
		unit.BorderDead:SetTexture(nibRealUI.media.textures.plain80)
		unit.BorderDead:SetPoint("TOPLEFT", unit.Icon, -1, 1)
		unit.BorderDead:SetPoint("BOTTOMRIGHT", unit.Icon, 1, -1)
		unit.BorderDead:SetDrawLayer("BACKGROUND")
		unit.BorderDead:SetVertexColor(1, 0, 0)

		unit.HealthBorder = unit:CreateTexture()
		unit.HealthBorder:SetTexture(0, 0, 0)
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

	for i = 1, NUM_BATTLE_PETS_IN_BATTLE  do
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

		unit.bg = CreateFrame("Frame", nil, unit)
		unit.bg:SetSize(168, 37)
		unit.bg:SetPoint("BOTTOM", 3, 9)
		F.CreateBD(unit.bg, 0)

		unit.bd = unit:CreateTexture()
		unit.bd:SetDrawLayer("BACKGROUND", 1)
		unit.bd:SetTexture(0, 0, 0, .5)
		unit.bd:SetAllPoints(unit.bg)

		unit.bg.SelectedTexture = unit:CreateTexture()
		unit.bg.SelectedTexture:SetDrawLayer("BACKGROUND", 2)
		unit.bg.SelectedTexture:SetTexture(nibRealUI.media.textures.plain)
		unit.bg.SelectedTexture:SetVertexColor(r, g, b, .2)
		unit.bg.SelectedTexture:SetPoint("TOPLEFT", unit.bg, 1, -1)
		unit.bg.SelectedTexture:SetPoint("BOTTOMRIGHT", unit.bg, -1, 1)

		icon:SetTexCoord(.08, .92, .08, .92)
		icon.bg = F.CreateBG(icon)
		icon.bg:SetDrawLayer("BACKGROUND", 3)

		unit.ActualHealthBar:SetTexture(nibRealUI.media.textures.plain)
		unit.ActualHealthBar.bg = CreateFrame("Frame", nil, unit)
		unit.ActualHealthBar.bg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
		unit.ActualHealthBar.bg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, -1, -1)
		unit.ActualHealthBar.bg:SetWidth(130)
		F.CreateBD(unit.ActualHealthBar.bg, 0)

		unit.ActualHealthBar.bd = unit:CreateTexture()
		unit.ActualHealthBar.bd:SetDrawLayer("BACKGROUND", 3)
		unit.ActualHealthBar.bd:SetTexture(0, 0, 0, .25)
		unit.ActualHealthBar.bd:SetAllPoints(unit.ActualHealthBar.bg)

		unit:HookScript("OnEnter", petSelectOnEnter)
		unit:HookScript("OnLeave", petSelectOnLeave)
	end


	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
		local petOwner = self.petOwner

		if (not petOwner) or self.petIndex > C_PetBattles.GetNumPets(petOwner) then return end

		if self.Icon then
			if petOwner == LE_BATTLE_PET_ALLY then
				self.Icon:SetTexCoord(.92, .08, .08, .92)
			else
				self.Icon:SetTexCoord(.08, .92, .08, .92)
			end
		end

		if self.SelectedTexture then
			self.bg.SelectedTexture:SetShown(self.SelectedTexture:IsShown())
		end
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
		if self.PetType and self.PetTypeString then
			local petType = C_PetBattles.GetPetType(self.petOwner, self.petIndex)
			self.PetTypeString:SetText(PET_TYPE_SUFFIX[petType])
		end
	end)

	hooksecurefunc("PetBattleAuraHolder_Update", function(self)
		if not self.petOwner or not self.petIndex then return end

		local nextFrame = 1
		for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
			if (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) then
				local frame = self.frames[nextFrame]

				frame.DebuffBorder:Hide()

				if not frame.reskinned then
					frame.Icon:SetTexCoord(.08, .92, .08, .92)
					frame.bg = F.CreateBG(frame.Icon)
				end

				frame.Duration:SetFont(unpack(nibRealUI.font.pixel1))
				frame.Duration:SetShadowOffset(0, 0)
				frame.Duration:ClearAllPoints()
				frame.Duration:SetPoint("BOTTOM", frame.Icon, 1, -1)

				if turnsRemaining > 0 then
					frame.Duration:SetText(turnsRemaining)
				end

				if isBuff then
					frame.bg:SetVertexColor(0, 1, 0)
				else
					frame.bg:SetVertexColor(1, 0, 0)
				end

				nextFrame = nextFrame + 1
			end
		end
	end)

	-- [[ Action bar ]]


	local bar = CreateFrame("Frame", "FreeUIPetBattleActionBar", UIParent, "SecureHandlerStateTemplate")
	bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 50)
	bar:SetSize(6 * 27, 26)
	RegisterStateDriver(bar, "visibility", "[petbattle] show; hide")

	bf.RightEndCap:Hide()
	bf.LeftEndCap:Hide()
	bf.Background:Hide()
	bf.Delimiter:Hide()
	turnTimer.TimerBG:SetTexture("")
	turnTimer.ArtFrame:SetTexture("")
	turnTimer.ArtFrame2:SetTexture("")
	bf.FlowFrame.LeftEndCap:Hide()
	bf.FlowFrame.RightEndCap:Hide()
	select(3, bf.FlowFrame:GetRegions()):Hide()
	bf.MicroButtonFrame:Hide()
	PetBattleFrameXPBarLeft:Hide()
	PetBattleFrameXPBarRight:Hide()
	PetBattleFrameXPBarMiddle:Hide()

	turnTimer.SkipButton:SetParent(bar)
	turnTimer.SkipButton:SetWidth(bar:GetWidth())
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
	bf.xpBar:SetWidth(bar:GetWidth() - 2)
	bf.xpBar:ClearAllPoints()
	bf.xpBar:SetPoint("BOTTOM", turnTimer, "TOP", 0, 1)
	bf.xpBar:SetStatusBarTexture(nibRealUI.media.textures.plain80)
	F.CreateBDFrame(bf.xpBar, 0)

	for i = 7, 12 do
		select(i, bf.xpBar:GetRegions()):Hide()
	end

	hooksecurefunc("PetBattlePetSelectionFrame_Show", function()
		bf.PetSelectionFrame:ClearAllPoints()
		bf.PetSelectionFrame:SetPoint("BOTTOM", bf.xpBar, "TOP", 0, 8)
	end)

	hooksecurefunc("PetBattleFrame_UpdatePassButtonAndTimer", function()
		local pveBattle = C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY)

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
		if ( ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_WAITING_PRE_BATTLE ) and
			 ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_ROUND_IN_PROGRESS ) and
			 ( C_PetBattles.GetBattleState() ~= LE_PET_BATTLE_STATE_WAITING_FOR_FRONT_PETS ) ) then
			self.Bar:SetAlpha(0);
			self.TimerText:SetText("");
		elseif ( self.turnExpires ) then
			local timeRemaining = self.turnExpires - GetTime();

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

			if ( C_PetBattles.IsWaitingOnOpponent() ) then
				self.Bar:SetAlpha(0.5);
				self.TimerText:SetText(PET_BATTLE_WAITING_FOR_OPPONENT);
			else
				self.Bar:SetAlpha(1);
				if ( self.turnTime > 0.0 ) then
					self.TimerText:SetText(ceil(timeRemaining));
				else
					self.TimerText:SetText("")
				end
			end
		else
			self.Bar:SetAlpha(0);
			if ( C_PetBattles.IsWaitingOnOpponent() ) then
				self.TimerText:SetText(PET_BATTLE_WAITING_FOR_OPPONENT);
			else
				self.TimerText:SetText(PET_BATTLE_SELECT_AN_ACTION);
			end
		end
	end)

	-- [[ Buttons ]]

	local r, g, b = unpack(nibRealUI.classColor)

	local function stylePetBattleButton(bu)
		if bu.reskinned then return end

		local pushed = bu:GetPushedTexture()
		local icon = bu.Icon
		local ho = bu.HotKey
		local cd = bu.Cooldown
		local bi = bu.BetterIcon

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetAllPoints(bu)
		bu.bg:SetFrameLevel(0)
		bu.bg:SetBackdrop({
			edgeFile = nibRealUI.media.textures.plain,
			edgeSize = 1,
		})
		bu.bg:SetBackdropBorderColor(0, 0, 0)

		icon:SetDrawLayer("BACKGROUND", 2)
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("TOPLEFT", bu, 1, -1)
		icon:SetPoint("BOTTOMRIGHT", bu, -1, 1)

		bu.CooldownShadow:SetDrawLayer("BACKGROUND")
		bu.CooldownShadow:SetPoint("TOPLEFT", bu, -7, 7)
		bu.CooldownShadow:SetPoint("BOTTOMRIGHT", bu, 7, -7)

		bu.CooldownFlash:SetDrawLayer("BACKGROUND")
		bu.CooldownFlash:SetPoint("TOPLEFT", bu, -7, 7)
		bu.CooldownFlash:SetPoint("BOTTOMRIGHT", bu, 7, -7)

		bu.SelectedHighlight:SetDrawLayer("BACKGROUND") -- Drathal fix
		bu.SelectedHighlight:SetPoint("TOPLEFT", bu, -7, 7)
		bu.SelectedHighlight:SetPoint("BOTTOMRIGHT", bu, 7, -7)

		pushed:SetTexture(r, g, b)
		pushed:SetDrawLayer("BACKGROUND")
		pushed:SetAllPoints()

		ho:SetFont(unpack(nibRealUI.font.pixel1))
		ho:SetJustifyH("CENTER")
		ho:ClearAllPoints()
		ho:SetPoint("TOP", 1, -1)

		cd:SetFont(unpack(nibRealUI.font.pixel1))
		cd:SetJustifyH("CENTER")
		cd:SetDrawLayer("OVERLAY", 5)
		cd:SetTextColor(1, 1, 1)
		cd:SetShadowOffset(0, 0)
		cd:ClearAllPoints()
		cd:SetPoint("BOTTOM", 1, -1)

		bi:SetSize(24, 24)
		bi:ClearAllPoints()
		bi:SetPoint("BOTTOM", 6, -9)

		bu.reskinned = true
	end

	-- hooksecurefunc("PetBattleAbilityButton_UpdateHotKey", function(self)
	-- 	self.HotKey:SetShown(self.HotKey:IsShown())
	-- end)

	local first = true
	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
		for i = 1, NUM_BATTLE_PET_ABILITIES do
			local bu = bf.abilityButtons[i]
			stylePetBattleButton(bu)
			bu:SetParent(bar)
			bu:SetSize(26, 26)
			bu:ClearAllPoints()
			if i == 1 then
				bu:SetPoint("BOTTOMLEFT", bar)
			else
				local previous = bf.abilityButtons[i-1]
				bu:SetPoint("LEFT", previous, "RIGHT", 1, 0)
			end
		end

		stylePetBattleButton(bf.SwitchPetButton)
		stylePetBattleButton(bf.CatchButton)
		stylePetBattleButton(bf.ForfeitButton)

		if first then
			first = false
			bf.SwitchPetButton:SetScript("OnClick", function()
				if bf.PetSelectionFrame:IsShown() then
					PetBattlePetSelectionFrame_Hide(bf.PetSelectionFrame)
				else
					PetBattlePetSelectionFrame_Show(bf.PetSelectionFrame)
				end
			end)
		end

		bf.SwitchPetButton:SetParent(bar)
		bf.SwitchPetButton:SetSize(26, 26)
		bf.SwitchPetButton:ClearAllPoints()
		bf.SwitchPetButton:SetPoint("LEFT", bf.abilityButtons[NUM_BATTLE_PET_ABILITIES], "RIGHT", 1, 0)
		bf.SwitchPetButton:SetCheckedTexture("Interface\\AddOns\\Aurora\\media\\CheckButtonHilight")
		bf.CatchButton:SetParent(bar)
		bf.CatchButton:SetSize(26, 26)
		bf.CatchButton:ClearAllPoints()
		bf.CatchButton:SetPoint("LEFT", bf.SwitchPetButton, "RIGHT", 1, 0)
		bf.ForfeitButton:SetParent(bar)
		bf.ForfeitButton:SetSize(26, 26)
		bf.ForfeitButton:ClearAllPoints()
		bf.ForfeitButton:SetPoint("LEFT", bf.CatchButton, "RIGHT", 1, 0)
	end)
end

function PetBattles:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {}
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Pet Battles")
end

function PetBattles:OnEnable()
	self:Skin()
end
