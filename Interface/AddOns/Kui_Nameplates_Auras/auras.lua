--[[
-- Kui_Nameplates_Auras
-- By Kesava at curse.com
-- All rights reserved

   Auras module for Kui_Nameplates core layout.
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local spelllist = LibStub('KuiSpellList-1.0')
local kui = LibStub('Kui-1.0')
local mod = addon:NewModule('Auras', 'AceEvent-3.0')
local whitelist, _

local GetTime, floor, ceil, format = GetTime, floor, ceil, format
local UnitExists,UnitGUID=UnitExists,UnitGUID

local PLAYER_GUID

local sizes = {}

-- store profiles to reduce lookup in OnAuraUpdate
local db_display,db_behav

-- auras pulsate when they have less than this many seconds remaining
local FADE_THRESHOLD = 5

-- combat log events to listen to for fading auras
local REMOVAL_EVENTS = {
    ['SPELL_AURA_REMOVED'] = true,
    ['SPELL_AURA_BROKEN'] = true,
    ['SPELL_AURA_BROKEN_SPELL'] = true,
}
local ADDITION_EVENTS = {
    ['SPELL_AURA_APPLIED'] = true,
    ['SPELL_AURA_REFRESH'] = true,
    ['SPELL_AURA_REMOVED_DOSE'] = true,
    ['SPELL_AURA_APPLIED_DOSE'] = true,
}

-- stored spell id durations
-- used for giving timers to aura icons when they're added by the combat log
local stored_spells = {}

local function debug_print(msg)
    print(GetTime()..': '..msg)
end

local function ArrangeButtons(self)
    local pv, pc
    self.visible = 0

    for k,b in ipairs(self.buttons) do
        if b:IsShown() then
            self.visible = self.visible + 1

            b:ClearAllPoints()

            if pv then
                if (self.visible-1) % (self.frame.trivial and 3 or 5) == 0 then
                    -- start of row
                    b:SetPoint('BOTTOMLEFT', pc, 'TOPLEFT', 0, 1)
                    pc = b
                else
                    -- subsequent button in a row
                    b:SetPoint('LEFT', pv, 'RIGHT', 1, 0)
                end
            else
                -- first button
                b:SetPoint('BOTTOMLEFT')
                pc = b
            end

            pv = b
        end
    end

    if self.visible == 0 then
        self:Hide()
    else
        self:Show()
    end
end
-- aura pulsating functions ----------------------------------------------------
local DoPulsateAura
do
    local function OnFadeOutFinished(button)
        button.fading = nil
        button.faded = true
        DoPulsateAura(button)
    end
    local function OnFadeInFinished(button)
        button.fading = nil
        button.faded = nil
        DoPulsateAura(button)
    end

    DoPulsateAura = function(button)
        if button.fading or not button.doPulsate then return end
        button.fading = true

        if button.faded then
            kui.frameFade(button, {
                startAlpha = .5,
                timeToFade = .5,
                finishedFunc = OnFadeInFinished
            })
        else
            kui.frameFade(button, {
                mode = 'OUT',
                endAlpha = .5,
                timeToFade = .5,
                finishedFunc = OnFadeOutFinished
            })
        end
    end
end
local function StopPulsatingAura(button)
    kui.frameFadeRemoveFrame(button)
    button.doPulsate = nil
    button.fading = nil
    button.faded = nil
    button:SetAlpha(1)
end
--------------------------------------------------------------------------------
local function OnAuraUpdate(self, elapsed)
    self.elapsed = self.elapsed - elapsed

    if self.elapsed <= 0 then
        local timeLeft = (self.expirationTime or 0) - GetTime()

        if db_display.pulsate then
            if self.doPulsate and timeLeft > FADE_THRESHOLD then
                -- reset pulsating status if the time is extended
                StopPulsatingAura(self)
            elseif not self.doPulsate and timeLeft <= FADE_THRESHOLD then
                -- make the aura pulsate
                self.doPulsate = true
                DoPulsateAura(self)
            end
        end

        if db_display.timerThreshold > -1 and
            timeLeft > db_display.timerThreshold
        then
            self.time:Hide()
        else
            local timeLeftS

            if db_display.decimal and
                timeLeft <= 1 and timeLeft > 0
            then
                -- decimal places for the last second
                timeLeftS = format("%.1f", timeLeft)
            else
                timeLeftS = (timeLeft > 60 and ceil(timeLeft/60)..'m' or floor(timeLeft))
            end

            if timeLeft <= 5 then
                -- red text
                self.time:SetTextColor(1,0,0)
            elseif timeLeft <= 20 then
                -- yellow text
                self.time:SetTextColor(1,1,0)
            else
                -- white text
                self.time:SetTextColor(1,1,1)
            end

            self.time:SetText(timeLeftS)
            self.time:Show()
        end

        if timeLeft < 0 then
            -- used when a non-targeted mob's auras timer gets below 0
            -- but the combat log hasn't reported that it has faded yet.
            self.time:Hide()
            self:SetScript('OnUpdate', nil)
            StopPulsatingAura(self)
            return
        end

        if db_display.decimal and
            timeLeft <= 2 and timeLeft > 0
        then
            -- faster updates in the last two seconds
            self.elapsed = .05
        else
            self.elapsed = .5
        end
    end
end
local function OnAuraShow(self)
    local parent = self:GetParent()
    parent:ArrangeButtons()

    addon:SendMessage('KuiNameplates_PostAuraShow', parent.frame, self.spellId)
end
local function OnAuraHide(self)
    local parent = self:GetParent()

    if parent.spellIds[self.spellId] == self then
        -- remove spell id from parent list
        parent.spellIds[self.spellId] = nil
    end

    self.time:Hide()

    -- reset button pulsating
    StopPulsatingAura(self)

    parent:ArrangeButtons()

    addon:SendMessage('KuiNameplates_PostAuraHide', parent.frame, self.spellId)
    self.spellId = nil
end
local function UpdateButtonDuration(button, duration)
    if duration then
        -- set duration & expire time to given value
        button.duration = duration
        button.expirationTime = GetTime() + duration
    end

    if not button.expirationTime or not button.duration or button.duration == 0 then
        -- hide time on timeless auras
        button:SetScript('OnUpdate', nil)
        button.time:Hide()
    else
        button:SetScript('OnUpdate', OnAuraUpdate)
    end

    if db_display.sort then
        -- sort by expiration time
        table.sort(button:GetParent().buttons, function(a,b)
            if a.expirationTime and b.expirationTime then
                return a.expirationTime > b.expirationTime
            else
                return a.expirationTime and not b.expirationTime
            end
        end)

        button:GetParent():ArrangeButtons()
    end
end
local function GetAuraButton(self, spellId, icon, count, duration, expirationTime)
    local button

    if self.spellIds[spellId] then
        -- use this spell's current button...
        button = self.spellIds[spellId]
    elseif self.visible ~= #self.buttons then
        -- .. or reuse a hidden button...
        for k,b in pairs(self.buttons) do
            if not b:IsShown() then
                button = b
                break
            end
        end
    end

    if not button then
        -- ... or create a new button
        button = CreateFrame('Frame', nil, self)
        button:Hide()

        button.icon = button:CreateTexture(nil, 'ARTWORK')

        button.time = self.frame:CreateFontString(button,{
            size = 'large' })
        button.time:SetJustifyH('LEFT')
        button.time:SetPoint('TOPLEFT', -2, 4)
        button.time:Hide()

        button.count = self.frame:CreateFontString(button, {
            outline = 'OUTLINE'})
        button.count:SetJustifyH('RIGHT')
        button.count:SetPoint('BOTTOMRIGHT', 2, -2)
        button.count:Hide()

        button:SetBackdrop({ bgFile = kui.m.t.solid })
        button:SetBackdropColor(0,0,0)

        button.icon:SetPoint('TOPLEFT', 1, -1)
        button.icon:SetPoint('BOTTOMRIGHT', -1, 1)

        button.icon:SetTexCoord(.1, .9, .2, .8)

        tinsert(self.buttons, button)

        button:SetScript('OnHide', OnAuraHide)
        button:SetScript('OnShow', OnAuraShow)
    end

    if self.frame.trivial then
        -- shrink icons for trivial frames!
        button:SetHeight(sizes.tauraHeight)
        button:SetWidth(sizes.tauraWidth)
        button.time = self.frame:CreateFontString(button.time, {
            reset = true, size = 'small' })
    else
        -- normal size!
        button:SetHeight(sizes.auraHeight)
        button:SetWidth(sizes.auraWidth)
        button.time = self.frame:CreateFontString(button.time, {
            reset = true, size = 'large' })
    end

    button.icon:SetTexture(icon)

    if count > 1 and not self.frame.trivial then
        button.count:SetText(count)
        button.count:Show()
    else
        button.count:Hide()
    end

    button.duration = duration
    button.expirationTime = expirationTime
    button.spellId = spellId
    button.elapsed = 0

    UpdateButtonDuration(button)

    -- store this spell's original duration
    stored_spells[spellId] = duration or 0

    self.spellIds[spellId] = button

    return button
end
local function DisplayAura(self,spellid,name,icon,count,duration,expirationTime)
    --debug_print('aura application of '..name)
    name = strlower(name) or nil
    if not name then return end

    if  db_behav.useWhitelist and
        not (whitelist[spellid] or whitelist[name])
    then
        -- not in whitelist
        return
    end

    -- apply duration from spell store
    if not duration then
        duration = stored_spells[spellid]

        if duration then
            expirationTime = GetTime() + duration
        end
        -- otherwise, this is a timeless aura
    end

    if duration and duration > 0 and duration < db_display.lengthMin then
        -- duration below minimum
        return
    end

    if  db_display.lengthMax > -1 and
        (not duration or duration <= 0 or duration > db_display.lengthMax)
    then
        -- duration above maximum or timeless and a maximum duration is set
        return
    end

    local button = self:GetAuraButton(spellid, icon, count, duration, expirationTime)
    self:Show()

    button:Show()
    button.used = true
end
----------------------------------------------------------------------- hooks --
function mod:Create(msg, frame)
    frame.auras = CreateFrame('Frame', nil, frame)
    frame.auras.frame = frame

    -- BOTTOMLEFT is set OnShow
    frame.auras:SetPoint('BOTTOMRIGHT', frame.health, 'TOPRIGHT', -3, 0)
    frame.auras:SetHeight(50)
    frame.auras:Hide()

    frame.auras.visible = 0
    frame.auras.buttons = {}
    frame.auras.spellIds = {}
    frame.auras.GetAuraButton  = GetAuraButton
    frame.auras.ArrangeButtons = ArrangeButtons
    frame.auras.DisplayAura    = DisplayAura

    frame.auras:SetScript('OnHide', function(self)
        for k,b in pairs(self.buttons) do
            b:Hide()
        end

        self.visible = 0
    end)
end
function mod:Show(msg, frame)
    -- set vertical position of the container frame
    if frame.trivial then
        frame.auras:SetPoint('BOTTOMLEFT', frame.health, 'BOTTOMLEFT',
            3, sizes.taurasOffset)
    else
        frame.auras:SetPoint('BOTTOMLEFT', frame.health, 'BOTTOMLEFT',
            3, sizes.aurasOffset)
    end

    -- TODO calculate size of auras & num per column here
end
function mod:Hide(msg, frame)
    if frame.auras then
        frame.auras:Hide()
    end
end
-------------------------------------------------------------- event handlers --
function mod:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    -- used to hide expired auras on previously known frames
    -- to detect aura updates on the mouseover, if it exists
    -- (since UNIT_AURA doesn't fire for mouseover)
    -- and place auras on frames for which GUIDs are known, if possible
    local guid = select(4,...)
    if not guid then return end
    if guid ~= PLAYER_GUID then return end

    local event = select(2,...)

    if  REMOVAL_EVENTS[event] or
        (db_behav.showSecondary and ADDITION_EVENTS[event])
    then
        local destGUID = select(8,...)

        -- events on the current target will be caught by UNIT_AURA
        -- some other units will fire twice too, but this catches the majority
        if destGUID == UnitGUID('target') then return end

        if destGUID == UnitGUID('mouseover') then
            -- event on the mouseover unit - update directly
            self:UNIT_AURA('UNIT_AURA','mouseover')
            return
        end

        local castTime,_,_,_,name,_,_,_,destName = ...

        -- only listen for simple removals/additions from now
        -- fetch the subject's nameplate
        local f = addon:GetNameplate(destGUID, destName)
        if not f or not f.auras then return end
        if f.trivial and not self.db.profile.showtrivial then return end

        --debug_print('COMBAT_LOG_EVENT fired on '..f.name.text)

        local spId = select(12, ...)
        if not spId then return end

        if REMOVAL_EVENTS[event] then
            -- hide an aura button when the combat log reports it has expired
            if f.auras.spellIds[spId] then
                f.auras.spellIds[spId]:Hide()
            end
        elseif ADDITION_EVENTS[event] then
            if f.auras.spellIds[spId] then
                -- reset timer to original duration
                UpdateButtonDuration(f.auras.spellIds[spId], stored_spells[spId])
            else
                -- show a placeholder button with no timer when possible
                local spellName,_,icon = GetSpellInfo(spId)
                f.auras:DisplayAura(spId, spellName, icon, 1)
            end
        end
    end
end
function mod:PLAYER_TARGET_CHANGED()
    self:UNIT_AURA('UNIT_AURA', 'target')
end
function mod:UPDATE_MOUSEOVER_UNIT()
    self:UNIT_AURA('UNIT_AURA', 'mouseover')
end
function mod:GUIDStored(msg, f, unit)
    self:UNIT_AURA('UNIT_AURA', unit, f)
end
function mod:UNIT_AURA(event, unit, frame)
    -- select the unit's nameplate
    --unit = 'target' -- DEBUG
    frame = frame or addon:GetNameplate(UnitGUID(unit))
    if not frame or not frame.auras then return end
    if frame.trivial and not self.db.profile.showtrivial then return end
    --unit = 'player' -- DEBUG

    --debug_print('UNIT_AURA fired on '..frame.name.text)

    local filter = 'PLAYER '
    if UnitIsFriend(unit, 'player') then
        filter = filter..'HELPFUL'
    else
        filter = filter..'HARMFUL'
    end

    for i = 0,40 do
        local name, _, icon, count, _, duration, expirationTime, _, _, _, spellid = UnitAura(unit, i, filter)

        if spellid then
            frame.auras:DisplayAura(spellid,name,icon,count,duration,expirationTime)
        end
    end

    for _,button in pairs(frame.auras.buttons) do
        -- hide buttons that weren't used this update
        if not button.used then
            button:Hide()
        end

        button.used = nil
    end
end
function mod:PLAYER_ENTERING_WORLD(event)
    PLAYER_GUID = UnitGUID('player')
end
function mod:WhitelistChanged()
    -- update spell whitelist
    whitelist = spelllist.GetImportantSpells(select(2, UnitClass("player")))
end
---------------------------------------------------- Post db change functions --
mod.configChangedListener = function(self)
    db_display = self.db.profile.display
    db_behav   = self.db.profile.behav

    if not db_display.lengthMax then
        db_display.lengthMax = -1
    end

    if not db_display.lengthMin then
        db_display.lengthMin = 0
    end
end

mod.configChangedFuncs = { runOnce = {} }
mod.configChangedFuncs.runOnce.enabled = function(val)
    if val then
        mod:Enable()
    else
        mod:Disable()
    end
end
---------------------------------------------------- initialisation functions --
function mod:GetOptions()
    return {
        enabled = {
            name = 'Show my auras',
            desc = 'Display auras cast by you on the current target\'s nameplate',
            type = 'toggle',
            order = 1,
            disabled = false
        },
        showtrivial = {
            name = 'Show on trivial units',
            desc = 'Show auras on trivial (half-size, lower maximum health) nameplates.',
            type = 'toggle',
            order = 3,
            disabled = function()
                return not self.db.profile.enabled
            end,
        },
        display = {
            name = 'Display',
            type = 'group',
            inline = true,
            disabled = function()
                return not self.db.profile.enabled
            end,
            order = 10,
            args = {
                pulsate = {
                    name = 'Pulsate auras',
                    desc = 'Pulsate aura icons when they have less than 5 seconds remaining.\nSlightly increases memory usage.',
                    type = 'toggle',
                    order = 5,
                },
                decimal = {
                    name = 'Show decimal places',
                    desc = 'Show decimal places (.9 to .0) when an aura has less than one second remaining, rather than just showing 0.',
                    type = 'toggle',
                    order = 8,
                },
                sort = {
                    name = 'Sort auras by time remaining',
                    desc = 'Increases memory usage.',
                    type = 'toggle',
                    order = 10,
                    width = 'double',
                },
                timerThreshold = {
                    name = 'Timer threshold (s)',
                    desc = 'Timer text will be displayed on auras when their remaining length is less than or equal to this value. -1 to always display timer.',
                    type = 'range',
                    order = 15,
                    min = -1,
                    softMax = 180,
                    step = 1
                },
                lengthMin = {
                    name = 'Effect length minimum (s)',
                    desc = 'Auras with a total duration of less than this value will never be displayed. 0 to disable.',
                    type = 'range',
                    order = 20,
                    min = 0,
                    softMax = 60,
                    step = 1
                },
                lengthMax = {
                    name = 'Effect length maximum (s)',
                    desc = 'Auras with a total duration greater than this value will never be displayed. -1 to disable.',
                    type = 'range',
                    order = 30,
                    min = -1,
                    softMax= 1800,
                    step = 1
                },

            }
        },
        behav = {
            name = 'Behaviour',
            type = 'group',
            inline = true,
            disabled = function()
                return not self.db.profile.enabled
            end,
            order = 5,
            args = {
                useWhitelist = {
                    name = 'Use whitelist',
                    desc = 'Only display spells which your class needs to keep track of for PVP or an effective DPS rotation. Most passive effects are excluded.\n\n|cff00ff00You can use KuiSpellListConfig from Curse.com to customise this list.',
                    type = 'toggle',
                    order = 0,
                },
                showSecondary = {
                    name = 'Show on secondary targets',
                    desc = 'Attempt to show and refresh auras on secondary targets - i.e. nameplates which do not have a visible unit frame on the default UI. Particularly useful when tanking.',
                    type = 'toggle',
                    order = 10
                }
            }
        }
    }
end
function mod:OnInitialize()
    self.db = addon.db:RegisterNamespace(self.moduleName, {
        profile = {
            enabled = true,
            showtrivial = false,
            display = {
                pulsate = true,
                decimal = true,
                sort = false,
                timerThreshold = 60,
                lengthMin = 0,
                lengthMax = -1,
            },
            behav = {
                useWhitelist = true,
                showSecondary = true,
            }
        }
    })

    sizes.auraHeight = 18
    sizes.auraWidth = 26
    sizes.tauraHeight = 12
    sizes.tauraWidth = 20

    sizes.aurasOffset = 26
    sizes.taurasOffset = 17

    addon:InitModuleOptions(self)
    mod:SetEnabledState(self.db.profile.enabled)

    self:WhitelistChanged()
    spelllist.RegisterChanged(self, 'WhitelistChanged')
end
function mod:OnEnable()
    self:RegisterMessage('KuiNameplates_PostCreate', 'Create')
    self:RegisterMessage('KuiNameplates_PostShow', 'Show')
    self:RegisterMessage('KuiNameplates_PostHide', 'Hide')
    self:RegisterMessage('KuiNameplates_GUIDStored', 'GUIDStored')
    self:RegisterMessage('KuiNameplates_PostTarget', 'PLAYER_TARGET_CHANGED')

    self:RegisterEvent('UNIT_AURA')
    self:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self:RegisterEvent('PLAYER_ENTERING_WORLD')

    -- get guid immediately if enabled while in game
    self:PLAYER_ENTERING_WORLD()

    local _, frame
    for _, frame in pairs(addon.frameList) do
        if not frame.auras then
            self:Create(nil, frame.kui)
        end
    end
end
function mod:OnDisable()
    self:UnregisterMessage('KuiNameplates_PostShow', 'Show')
    self:UnregisterMessage('KuiNameplates_GUIDStored', 'GUIDStored')
    self:UnregisterMessage('KuiNameplates_PostTarget', 'PLAYER_TARGET_CHANGED')

    self:UnregisterEvent('UNIT_AURA')
    self:UnregisterEvent('UPDATE_MOUSEOVER_UNIT')
    self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')

    local _, frame
    for _, frame in pairs(addon.frameList) do
        self:Hide(nil, frame.kui)
    end
end
