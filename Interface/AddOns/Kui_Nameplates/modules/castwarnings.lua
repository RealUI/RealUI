--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = addon:NewModule('CastWarnings', 'AceEvent-3.0')
    
mod.uiName = 'Cast warnings'

-- combat log events to listen to for cast warnings/healing
local warningEvents = {
	['SPELL_CAST_START']    = true,
	['SPELL_CAST_SUCCESS']  = true,
	['SPELL_INTERRUPT']     = true,
	['SPELL_HEAL']          = true,
	['SPELL_PERIODIC_HEAL'] = true
}

------------------------------------------------------------- Frame functions --
local function SetCastWarning(self, spellName, spellSchool)
	self.castWarning.ag:Stop()

	if spellName == nil then
		-- hide the warning instantly
		self.castWarning.ag:Stop()
		self.castWarning:SetText()
		self.castWarning:Hide()
	else
		local col = COMBATLOG_DEFAULT_COLORS.schoolColoring[spellSchool] or
			{r = 1, g = 1, b = 1}

		self.castWarning:SetText(spellName)
		self.castWarning:SetTextColor(col.r, col.g, col.b)
		self.castWarning:SetAlpha(1)

		self.castWarning.ag:Play()
	end
end

local function SetIncomingWarning(self, amount)
	if amount == 0 then return end
	self.incWarning.ag:Stop()

	if amount > 0 then
		-- healing
		amount = '+'..amount
		self.incWarning:SetTextColor(0, 1, 0)
	else
		-- damage (nyi)
		self.incWarning:SetTextColor(1, 0, 0)
	end

	self.incWarning:SetText(amount)

	self.incWarning:SetAlpha(1)
	self.incWarning.ag.fade:SetEndDelay(.5)

	self.incWarning.ag:Play()
end

-------------------------------------------------------------- Event handlers --
function mod:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local castTime, event, _, guid, name, _, _, targetGUID, targetName = ...
	if not guid then return end

	if warningEvents[event] then
		if	event == 'SPELL_HEAL' or
			event == 'SPELL_PERIODIC_HEAL'
		then
			-- fetch the spell's target's nameplate
			guid, name = targetGUID, targetName
		end
		
		--guid, name = UnitGUID('target'), GetUnitName('target') -- [DEBUG]

		if self.db.profile.useNames and name then
			name = name and name:gsub('%-.+$', '') -- remove realm names
		else
			name = nil
		end

		local f = addon:GetNameplate(guid, name)
		if f then
			if not f.castWarning or f.trivial then return end
			local spName, spSch = select(13, ...)
			
			if event == 'SPELL_HEAL' or
			   event == 'SPELL_PERIODIC_HEAL'
			then
				-- display heal warning
				local amount = select(15, ...)
				f:SetIncomingWarning(amount)
			elseif event == 'SPELL_INTERRUPT' then
				-- hide the warning
				f:SetCastWarning(nil)
			else
				-- or display it for this spell
				f:SetCastWarning(spName, spSch)
			end
		end
	end
end

---------------------------------------------------------------------- Create --
function mod:CreateCastWarnings(msg, frame)
    -- casting spell name
    frame.castWarning = frame:CreateFontString(frame.overlay, {
        size = 'name', outline = 'OUTLINE' })
    frame.castWarning:Hide()

    if addon.db.profile.general.leftie then
        frame.castWarning:SetPoint('BOTTOMLEFT', frame.name, 'TOPLEFT', 0, 1)
        frame.castWarning:SetJustifyH('LEFT')
    else
        frame.castWarning:SetPoint('BOTTOM', frame.name, 'TOP', 0, 1)
    end

    frame.castWarning.ag 	= frame.castWarning:CreateAnimationGroup()
    frame.castWarning.fade	= frame.castWarning.ag:CreateAnimation('Alpha')
    frame.castWarning.fade:SetSmoothing('IN')
    frame.castWarning.fade:SetDuration(3)
    frame.castWarning.fade:SetChange(-1)

    frame.castWarning.ag:SetScript('OnPlay', function(self)
        self:GetParent():Show()
    end)

    frame.castWarning.ag:SetScript('OnFinished', function(self)
        self:GetParent():Hide()
    end)

    -- incoming healing
    frame.incWarning = frame:CreateFontString(frame.overlay, {
        size = 'small', outline = 'OUTLINE' })
    frame.incWarning:Hide()

    if addon.db.profile.general.leftie then
        frame.incWarning:SetPoint('BOTTOMRIGHT', frame.health.p, 'TOPRIGHT', 0, 1)
        frame.incWarning:SetJustifyH('RIGHT')
    else
        frame.incWarning:SetPoint('TOP', frame.name, 'BOTTOM', 0, -3)
    end

    frame.incWarning.ag 	 = frame.incWarning:CreateAnimationGroup()
    frame.incWarning.ag.fade = frame.incWarning.ag:CreateAnimation('Alpha')
    frame.incWarning.ag.fade:SetSmoothing('IN')
    frame.incWarning.ag.fade:SetDuration(.5)
    frame.incWarning.ag.fade:SetChange(-.5)

    frame.incWarning.ag:SetScript('OnPlay', function(self)
        self:GetParent():Show()
    end)

    frame.incWarning.ag:SetScript('OnFinished', function(self)
        if self.fade:GetEndDelay() > 0 then
            -- fade out fully
            self:GetParent():SetAlpha(.5)
            self.fade:SetEndDelay(0)
            self:Play()
        else
            self:GetParent():Hide()
        end
    end)

    -- handlers
    frame.SetCastWarning = SetCastWarning
    frame.SetIncomingWarning = SetIncomingWarning
end

function mod:Hide(msg, frame)
	if frame.castWarning then
		frame.castWarning.ag:Stop()
		frame.castWarning:SetText()
		frame.castWarning:Hide()
		
		frame.incWarning.ag:Stop()
		frame.incWarning:SetText()
		frame.incWarning:Hide()
	end
end

---------------------------------------------------- Post db change functions --
mod.configChangedFuncs = { runOnce = {} }
mod.configChangedFuncs.runOnce.warnings = function(val)
	if val then
		mod:Enable()
	else
		mod:Disable()
	end
end

-------------------------------------------------------------------- Register --
function mod:GetOptions()
	return {
		warnings = {
			name = 'Show cast warnings',
			desc = 'Display cast and healing warnings on plates',
			type = 'toggle',
			order = 1,
			disabled = false
		},
		useNames = {
			name = "Use names for warnings",
			desc = 'Use character names to decide which frame to display warnings on. May increase memory usage and may cause warnings to be displayed on incorrect frames when there are many units with the same name. Reccommended on for PvP, off for PvE.',
			type = 'toggle',
			order = 2
		}
	}
end

function mod:OnInitialize()
	self.db = addon.db:RegisterNamespace(self.moduleName, {
		profile = {
			warnings = false,
			useNames = false
		}
	})

	addon:InitModuleOptions(self)
	mod:SetEnabledState(self.db.profile.warnings)
end

function mod:OnEnable()
    self:RegisterMessage('KuiNameplates_PostCreate', 'CreateCastWarnings')
    self:RegisterMessage('KuiNameplates_PostHide', 'Hide')
    
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

    local _,frame
    for _, frame in pairs(addon.frameList) do
    	if not frame.castWarning then
    		self:CreateCastWarnings(nil, frame.kui)
    	end
	end
end

function mod:OnDisable()
	self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

	local _,frame
	for _, frame in pairs(addon.frameList) do
		self:Hide(nil, frame.kui)
	end
end
