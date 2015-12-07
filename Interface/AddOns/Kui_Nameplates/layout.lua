--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]

local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local slowUpdateTime, critUpdateTime = 1, .1
local _

local profile
-- profile keys used often
local profile_fade, profile_fade_rules, profile_lowhealthval, profile_hp

--[===[@debug@
--KuiNameplatesDebug=true
--KuiNameplatesDrawFrames=true
--@end-debug@]===]

--------------------------------------------------------------------- globals --
local select, strfind, strsplit, pairs, ipairs, unpack, tinsert, type, floor
    = select, strfind, strsplit, pairs, ipairs, unpack, tinsert, type, floor
local UnitExists=UnitExists
-- non-laggy, pixel perfect positioning (Semlar's) #############################
local function SizerOnSizeChanged(self,x,y)
    -- because :Hide bubbles up and triggers the OnHide script of any elements
    -- that might use it, we set MOVING to let them know they should ignore
    -- that invocation
    -- Hiding frames before moving them significantly increases FPS for some
    -- reason, so I thought this was better than nothing
    self.f.MOVING=true
    self.f:Hide()
    self.f:SetPoint('CENTER',WorldFrame,'BOTTOMLEFT',
        floor(x),
        floor(y))
    self.f:Show()
    self.f.MOVING=nil
end
------------------------------------------------------------- Frame functions --
local function SetFrameCentre(f)
    -- using CENTER breaks pixel-perfectness with oddly sized frames
    -- .. so we have to align frames manually.
    local w,h = f:GetSize()

    if f.trivial then
        f.x = floor((w / 2) - (addon.sizes.frame.twidth / 2))
        f.y = floor((h / 2) - (addon.sizes.frame.theight / 2))
    else
        f.x = floor((w / 2) - (addon.sizes.frame.width / 2))
        f.y = floor((h / 2) - (addon.sizes.frame.height / 2))
    end
end
-- get default health bar colour, parse it into one of our custom colours
-- and the reaction of the unit toward the player
local function SetHealthColour(self,sticky,r,g,b)
    if sticky == false then
        -- unstick and reset
        self.health.reset = true
        self.healthColourPriority = nil
        sticky = nil
    elseif sticky == true then
        -- convert legacy stickiness
        sticky = 1
    end
    -- nil sticky = just update health colour

    if sticky then
        if  not self.healthColourPriority or
            sticky >= self.healthColourPriority
        then
            self.health:SetStatusBarColor(r,g,b)
            self.healthColourPriority = sticky
        end
        return
    end

    -- update health colour from default (r,g,b arguments are ignored)
    local r, g, b = self.oldHealth:GetStatusBarColor()
    if self.health.reset  or
       r ~= self.health.r or
       g ~= self.health.g or
       b ~= self.health.b
    then
        -- store the default colour
        self.health.r, self.health.g, self.health.b = r, g, b
        self.health.reset, self.player, self.tapped = nil, nil, nil, nil

        if g > .9 and r == 0 and b == 0 then
            -- friendly NPC
            self.friend = true
            r, g, b = unpack(profile_hp.reactioncolours.friendlycol)
        elseif b > .9 and r == 0 and g == 0 then
            -- friendly player
            self.friend = true
            self.player = true
            r, g, b = unpack(profile_hp.reactioncolours.playercol)
        elseif r > .9 and g == 0 and b == 0 then
            -- enemy NPC
            self.friend = nil
            r, g, b = unpack(profile_hp.reactioncolours.hatedcol)
        elseif (r + g) > 1.8 and b == 0 then
            -- neutral NPC
            self.friend = nil
            r, g, b = unpack(profile_hp.reactioncolours.neutralcol)
        elseif r < .6 and (r+g) == (r+b) then
            -- tapped NPC
            -- keep previous self.friend value
            self.tapped = true
            r, g, b = unpack(profile_hp.reactioncolours.tappedcol)
        else
            -- enemy player, use default UI colour
            self.friend = nil
            self.player = true
        end

        self.health:SetStatusBarColor(r, g, b)
    end
end

local function SetGlowColour(self, r, g, b, a)
    if not r then
        -- set default colour
        r, g, b = 0, 0, 0

        if profile.general.glowshadow then
            a = .8
        else
            a = 0
        end
    end

    if not a then
        a = .8
    end

    self.bg:SetVertexColor(r, g, b, a)
end

local function GetDesiredAlpha(frame)
    if profile_fade_rules.avoidhostilehp or
       profile_fade_rules.avoidfriendhp
    then
        if ((frame.friend    and profile_fade_rules.avoidfriendhp) or
           (not frame.friend and profile_fade_rules.avoidhostilehp)) and
           frame.health.percent and frame.health.percent <= profile_lowhealthval
        then
            -- avoid fading low health frames
            return 1
        end
    end

    if profile_fade_rules.avoidcast and frame.castbar and frame.castbar:IsShown() then
        -- avoid fading when castbar is visible
        return 1
    end

    if profile_fade_rules.avoidraidicon and frame.icon:IsVisible() then
        -- avoid fading frames with a raid icon
        return 1
    end

    if profile_fade.fademouse and frame.highlighted then
        -- fade in with mouse
        return 1
    end

    if UnitExists('target') then
        return frame.defaultAlpha == 1 and 1 or profile_fade.fadedalpha
    else
        -- default when there is no target
        return profile_fade.fadeall and profile_fade.fadedalpha or 1
    end
end
---------------------------------------------------- Update health bar & text --
local OnHealthValueChanged
do
    -- possible ids specified in config.lua, HealthTextSelectList
    local HealthValues = {
        function(f) return kui.num(f.health.curr) end,
        function(f) return kui.num(f.health.max) end,
        function(f) return floor(f.health.percent) end,
        function(f) return '-'..(kui.num(f.health.max - f.health.curr)) end,
        function(f) return '' end
    }

    local function SetHealthText(frame)
        if profile_hp.text.hp_text_disabled then
            frame.health.p:SetText('')
            return
        end

        if frame.health.health_max_snapshot then
            -- workaround logic
            if frame.friend then
                if frame.health.curr == frame.health.max then
                    frame.health.p:SetText(HealthValues[profile_hp.text.hp_friend_max](frame))
                else
                    frame.health.p:SetText(HealthValues[profile_hp.text.hp_friend_low](frame))
                end
            else
                if frame.health.curr == frame.health.max then
                    frame.health.p:SetText(HealthValues[profile_hp.text.hp_hostile_max](frame))
                else
                    frame.health.p:SetText(HealthValues[profile_hp.text.hp_hostile_low](frame))
                end
            end
        else
            -- fallback
            if frame.friend then
                if frame.health.curr == 1 and profile_hp.text.hp_friend_max ~= 5 then
                    frame.health.p:SetText('100')
                elseif frame.health.curr < 1 and profile_hp.text.hp_friend_low ~= 5 then
                    frame.health.p:SetText(floor(frame.health.percent))
                else
                    frame.health.p:SetText('')
                end
            else
                if frame.health.curr == 1 and profile_hp.text.hp_hostile_max ~= 5 then
                    frame.health.p:SetText('100')
                elseif frame.health.curr < 1 and profile_hp.text.hp_hostile_low ~= 5 then
                    frame.health.p:SetText(floor(frame.health.percent))
                else
                    frame.health.p:SetText('')
                end
            end
        end
    end
    OnHealthValueChanged = function(frame)
        frame.health.percent = frame.oldHealth:GetValue() * 100

        -- store values for external access
        if frame.health.health_max_snapshot then
            -- 6.2.2 workaround values
            frame.health.min = 0
            frame.health.max = frame.health.health_max_snapshot
            frame.health.curr = floor(frame.health.health_max_snapshot * frame.oldHealth:GetValue())
        else
            -- fallback values
            frame.health.min, frame.health.max = 0,1
            frame.health.curr = frame.oldHealth:GetValue()
        end

        frame.health:SetMinMaxValues(0,1)
        frame.health:SetValue(frame.oldHealth:GetValue())

        SetHealthText(frame)
    end
end
------------------------------------------------------- Frame script handlers --
local function OnFrameEnter(self)
    addon:StoreGUID(self, 'mouseover')
    self.highlighted = true

    if self.highlight then
        self.highlight:Show()
    end

    if profile_hp.text.mouseover and not self.trivial then
        self.health.p:Show()
    end
end
local function OnFrameLeave(self)
    self.highlighted = nil

    if self.highlight and
        (profile.general.highlight_target and not self.target or
        not profile.general.highlight_target)
    then
        self.highlight:Hide()
    end

    if profile_hp.text.mouseover and not self.target then
        self.health.p:Hide()
    end
end
local function OnFrameShow(self)
    local f = self.kui
    local trivial = f:IsTrivial()

    ---------------------------------------------- Trivial sizing/positioning --
    if addon.uiscale then
        -- change our parent frame size if we're using fixaa..
        -- (size is changed by SetAllPoints otherwise)
        f:SetSize(self:GetWidth()/addon.uiscale, self:GetHeight()/addon.uiscale)
    end

    if (trivial and not f.trivial) or
       (not trivial and f.trivial) or
       not f.doneFirstShow
    then
        f.trivial = trivial
        f:SetCentre()

        addon:UpdateBackground(f, trivial)
        addon:UpdateHealthBar(f, trivial)
        addon:UpdateHealthText(f, trivial)
        addon:UpdateLevel(f, trivial)
        addon:UpdateName(f, trivial)
        addon:UpdateTargetGlow(f, trivial)

        f.doneFirstShow = true
    end

    -- classifications
    if not trivial and f.level.enabled then
        if f.boss:IsVisible() then
            f.level:SetText('Boss')
            f.level:SetTextColor(1,.2,.2)

            f.boss:Hide()
        elseif f.state:IsVisible() then
            if f.state:GetTexture() == "Interface\\Tooltips\\EliteNameplateIcon" then
                f.level:SetText(f.level:GetText()..'+')
            else
                f.level:SetText(f.level:GetText()..'r')
            end

            f.state:Hide()
        end

        f.level:SetWidth(0)
        f.level:Show()
    else
        f.level:SetWidth(.1)
        f.level:Hide()
    end

    if f.state:IsVisible() then
        -- hide the elite/rare dragon
        f.state:Hide()
    end

    -- run updates immediately after the frame is shown
    f.elapsed = 0
    f.critElap = 0

    -- reset glow colour
    f:SetGlowColour()

    -- dispatch the PostShow message after the first UpdateFrame
    f.DispatchPostShow = true
    f.DoShow = true
end
local function OnFrameHide(self)
    local f = self.kui
    f:Hide()

    f:SetFrameLevel(0)

    if f.targetGlow then
        f.targetGlow:Hide()
    end

    addon:ClearGUID(f)

    -- remove name from store
    -- if there are name duplicates, this will be recreated in an onupdate
    addon:ClearName(f)

    f.active    = nil
    f.lastAlpha = nil
    f.fadingTo  = nil
    f.hasThreat = nil
    f.target    = nil
    f.targetDelay = nil
    f.healthColourPriority = nil

    -- force un-highlight
    OnFrameLeave(f)
    if f.highlight then
        f.highlight:Hide()
    end

    if addon.Castbar then
        addon.Castbar:HideCastbar(f)
        f.castbar_ignore_frame = nil
    end

    -- despite being a default element, this doesn't hide correctly if it was
    -- shown when the frame is hidden
    f.glow:Hide()

    -- unset stored health bar colours
    f.health.r, f.health.g, f.health.b, f.health.reset
        = nil, nil, nil, nil
    f.friend = nil

    addon:SendMessage('KuiNameplates_PostHide', f)
end
-- stuff that needs to be updated every frame
local function OnFrameUpdate(self, e)
    local f = self.kui
    f.elapsed   = f.elapsed - e
    f.critElap  = f.critElap - e

    -- Show during first update to prevent flashyness
    -- .DoShow is set OnFrameShow
    if f.DoShow then
        f:Show()
        f.DoShow = nil
    end
    ------------------------------------------------------------------- Alpha --
    f.defaultAlpha = self:GetAlpha()
    f.currentAlpha = GetDesiredAlpha(f)
    ------------------------------------------------------------------ Fading --
    if profile_fade.smooth then
        -- track changes in the alpha level and intercept them
        if not f.lastAlpha or f.currentAlpha ~= f.lastAlpha then
            if not f.fadingTo or f.fadingTo ~= f.currentAlpha then
                if kui.frameIsFading(f) then
                    kui.frameFadeRemoveFrame(f)
                end

                -- fade to the new value
                f.fadingTo    = f.currentAlpha
                local alphaChange = (f.fadingTo - (f.lastAlpha or 0))

                kui.frameFade(f, {
                    mode        = alphaChange < 0 and 'OUT' or 'IN',
                    timeToFade  = abs(alphaChange) * (profile_fade.fadespeed or .5),
                    startAlpha  = f.lastAlpha or 0,
                    endAlpha    = f.fadingTo,
                    finishedFunc = function()
                        f.fadingTo = nil
                    end,
                })
            end

            f.lastAlpha = f.currentAlpha
        end
    else
        f:SetAlpha(f.currentAlpha)
    end

    -- call delayed updates
    if f.elapsed <= 0 then
        f.elapsed = slowUpdateTime
        f:UpdateFrame()
    end

    if f.critElap <= 0 then
        f.critElap = critUpdateTime
        f:UpdateFrameCritical()
    end
end

-- stuff that can be updated less often
local function UpdateFrame(self)
    -- periodically update the name in order to purge Unknowns due to lag, etc
    self:SetName()

    -- ensure a frame is still stored for this name, as name conflicts cause
    -- it to be erased when another might still exist
    addon:StoreName(self)

    -- reset/update health bar colour
    self:SetHealthColour()

    if select(2,self.oldName:GetTextColor()) == 0 then
        self.active = true
    else
        self.active = nil
    end

    if self.DispatchPostShow then
        -- force initial health update, which relies on health colour
        self:OnHealthValueChanged()

        addon:SendMessage('KuiNameplates_PostShow', self)
        self.DispatchPostShow = nil

        -- return guid to an assumed unique name
        addon:GetGUID(self)
    end
end

-- stuff that needs to be updated often
local function UpdateFrameCritical(self)
    ------------------------------------------------------------------ Threat --
    if self.glow:IsVisible() then
        -- check the default glow colour every frame while it is visible
        self.glow.wasVisible = true
        self.glow.r, self.glow.g, self.glow.b = self.glow:GetVertexColor()

        if addon.TankModule then
            -- handoff to tank module
            addon.TankModule:ThreatUpdate(self)
        end
    elseif self.glow.wasVisible then
        self.glow.wasVisible = nil

        if not self.targetGlow or not self.target then
            -- restore default glow colour
            self:SetGlowColour()
        end

        if self.hasThreat then
            -- lost threat
            self.hasThreat = nil

            if addon.TankModule then
                addon.TankModule:ThreatClear(self)
            end
        end
    end
    ------------------------------------------------------------ Target stuff --
    if UnitExists('target') and self.defaultAlpha == 1 then
        if not self.target then
            if self.guid and self.guid == UnitGUID('target') then
                -- this is definitely the target
                self.targetDelay = 1
            else
                -- this -may- be the target's frame but we need to wait a moment
                -- before we can be sure.
                -- this alpha update delay is a blizzard issue.
                self.targetDelay = (self.targetDelay and self.targetDelay + 1) or 0
            end

            if self.targetDelay >= 1 then
                -- this is almost probably certainly maybe the target
                -- (the delay may not be long enough, but it already feels
                -- laggy so i'd prefer not to make it longer)
                self.target = true
                self.targetDelay = nil
                addon:StoreGUID(self, 'target')

                -- move this frame above others
                self:SetFrameLevel(3)

                if profile_hp.text.mouseover and not self.trivial then
                    self.health.p:Show()
                end

                if self.targetGlow then
                    self.targetGlow:Show()
                    self:SetGlowColour(unpack(profile.general.targetglowcolour))
                end

                if self.highlight and profile.general.highlight_target then
                    self.highlight:Show()
                end

                addon:SendMessage('KuiNameplates_PostTarget', self, true)
            end
        end
    else
        if self.targetDelay then
            -- it wasn't the target after all. phew.
            self.targetDelay = nil
        end

        if self.target then
            -- or it was, but no longer is.
            self.target = nil

            self:SetFrameLevel(0)

            if self.targetGlow then
                self.targetGlow:Hide()
                self:SetGlowColour()
            end

            if self.highlight and profile.general.highlight_target then
                self.highlight:Hide()
            end

            if not self.highlighted and profile_hp.text.mouseover then
                self.health.p:Hide()
            end

            addon:SendMessage('KuiNameplates_PostTarget', self, nil)
        end
    end

    --------------------------------------------------------------- Mouseover --
    if self.oldHighlight:IsShown() then
        if not self.highlighted then
            OnFrameEnter(self)
        end
    elseif self.highlighted then
        OnFrameLeave(self)
    end

    --[===[@debug@
    if _G['KuiNameplatesDebug'] then
        if self.guid then
            self.guidtext:SetText(self.guid)

            if addon:FrameHasGUID(self) then
                self.guidtext:SetTextColor(1,1,1)
            else
                self.guidtext:SetTextColor(1,0,0)
            end
        else
            self.guidtext:SetText(nil)
        end

        if addon:FrameHasName(self) then
            self.nametext:SetText('Has name')
        else
            self.nametext:SetText(nil)
        end

        if self.target then
            self.nametext:SetText((self.nametext:GetText() or '')..' [target]')
        end

        if self.active then
            self.nametext:SetText((self.nametext:GetText() or '')..' [active]')
        end

        if self.friend then
            self.isfriend:SetText('friendly')
        else
            self.isfriend:SetText('not friendly')
        end
    end
    --@end-debug@]===]
end
local function SetName(self)
    -- get name from default frame and update our values
    self.name.text = self.oldName:GetText()
    self.name:SetText(self.name.text)
end
local function IsTrivial(self)
    return self.firstChild:GetScale() < 1 and not addon.notrivial
end
--------------------------------------------------------------- KNP functions --
function addon:IsNameplate(frame)
    if frame:GetName() and strfind(frame:GetName(), '^NamePlate%d') then
        return frame.ArtContainer and true
    end
end
function addon:InitFrame(frame)
    -- container for kui objects!
    frame.kui = CreateFrame('Frame', nil,
        profile.general.compatibility and frame or WorldFrame)
    local f = frame.kui

    f.fontObjects = {}

    -- fetch default ui's objects
    local overlayChild = frame.ArtContainer
    local healthBar, castBar = overlayChild.HealthBar, overlayChild.CastBar
    local nameTextRegion = frame.NameContainer.NameText

    local castbarOverlay, shieldedRegion, spellIconRegion, spellNameRegion,
          spellNameShadow
        = overlayChild.CastBarBorder,
          overlayChild.CastBarFrameShield,
          overlayChild.CastBarSpellIcon,
          overlayChild.CastBarText,
          overlayChild.CastBarTextBG

    local glowRegion, overlayRegion, highlightRegion, levelTextRegion,
          bossIconRegion, raidIconRegion, stateIconRegion
        = overlayChild.AggroWarningTexture,
          overlayChild.Border,
          overlayChild.Highlight,
          overlayChild.LevelText,
          overlayChild.HighLevelIcon,
          overlayChild.RaidTargetIcon,
          overlayChild.EliteIcon

    local absorbBar, absorbBarOverlay
        = overlayChild.AbsorbBar,
          overlayChild.AbsorbBar.Overlay

    absorbBarOverlay:SetTexture(nil)
    overlayRegion:SetTexture(nil)
    highlightRegion:SetTexture(nil)
    bossIconRegion:SetTexture(nil)
    shieldedRegion:SetTexture(nil)
    castbarOverlay:SetTexture(nil)
    glowRegion:SetTexture(nil)
    spellIconRegion:SetSize(.01,.01)
    spellNameShadow:SetTexture(nil)

    overlayRegion:Hide()
    castbarOverlay:Hide()
    spellNameShadow:Hide()
    spellNameRegion:Hide()

    healthBar:Hide()
    frame.NameContainer:Hide()
    nameTextRegion:Hide()

    -- re-hidden OnFrameShow
    bossIconRegion:Hide()
    stateIconRegion:Hide()

    -- make default healthbar & castbar transparent
    castBar:SetStatusBarTexture(kui.m.t.empty)
    healthBar:SetStatusBarTexture(kui.m.t.empty)

    -- this bar doesn't work, so just get rid of it
    absorbBarOverlay:Hide()
    absorbBar:SetStatusBarTexture(nil)
    absorbBar:Hide()

    f.firstChild = overlayChild

    f.glow       = glowRegion
    f.boss       = bossIconRegion
    f.state      = stateIconRegion
    f.level      = levelTextRegion
    f.icon       = raidIconRegion
    f.spell      = spellIconRegion
    f.spellName  = spellNameRegion
    f.shield     = shieldedRegion
    f.oldHealth  = healthBar
    f.oldCastbar = castBar

    f.oldName = nameTextRegion
    f.oldName:Hide()

    f.oldHighlight = highlightRegion

    --------------------------------------------------------- Frame functions --
    f.CreateFontString     = addon.CreateFontString
    f.UpdateFrame          = UpdateFrame
    f.UpdateFrameCritical  = UpdateFrameCritical
    f.SetName              = SetName
    f.SetHealthColour      = SetHealthColour
    f.SetNameColour        = SetNameColour
    f.SetGlowColour        = SetGlowColour
    f.SetCentre            = SetFrameCentre
    f.OnHealthValueChanged = OnHealthValueChanged
    f.IsTrivial            = IsTrivial

    ------------------------------------------------------------------ Layout --
    if profile.general.fixaa and addon.uiscale then
        f:SetSize(frame:GetWidth()/addon.uiscale, frame:GetHeight()/addon.uiscale)
        f:Hide()

        --[===[@debug@
        if _G['KuiNameplatesDrawFrames'] then
            f:SetBackdrop({ bgFile = kui.m.t.solid })
            f:SetBackdropColor(0,0,0,.5)
        end
        --@end-debug@]===]

        local sizer = CreateFrame('Frame',nil,f)
        sizer:SetPoint('BOTTOMLEFT',WorldFrame)
        sizer:SetPoint('TOPRIGHT',frame,'CENTER')
        sizer:SetScript('OnSizeChanged',SizerOnSizeChanged)
        sizer.f = f
    else
        f:SetAllPoints(frame)
    end

    f:SetScale(addon.uiscale)

    f:SetFrameStrata(profile.general.strata)
    f:SetFrameLevel(0)

    f:SetCentre()

    self:CreateBackground(frame, f)
    self:CreateHealthBar(frame, f)

    -- overlay - frame level above health bar, used for text -------------------
    f.overlay = CreateFrame('Frame', nil, f)
    f.overlay:SetAllPoints(f.health)
    f.overlay:SetFrameLevel(2)

    self:CreateHighlight(frame, f)
    self:CreateHealthText(frame, f)

    self:CreateLevel(frame, f)
    self:CreateName(frame, f)

    -- castbar #################################################################
    if self.Castbar and self.Castbar.db.profile.enabled then
        self.Castbar:CreateCastbar(f)
    end

    -- target highlight --------------------------------------------------------
    if profile.general.targetglow then
        self:CreateTargetGlow(f)
    end

    -- raid icon ---------------------------------------------------------------
    self:UpdateRaidIcon(f)

    --[===[@debug@
    if _G['KuiNameplatesDrawFrames'] then
        frame:SetBackdrop({bgFile=kui.m.t.solid})
        frame:SetBackdropColor(1, 1, 1, .5)

        f.overlay:SetBackdrop({ bgFile = kui.m.t.solid })
        f.overlay:SetBackdropColor(1,1,1)
    end

    if _G['KuiNameplatesDebug'] then
        f.isfriend = f:CreateFontString(f.overlay)
        f.isfriend:SetPoint('BOTTOM', frame, 'TOP')

        f.guidtext = f:CreateFontString(f.overlay)
        f.guidtext:SetPoint('TOP', frame, 'BOTTOM')

        f.nametext = f:CreateFontString(f.overlay)
        f.nametext:SetPoint('TOP', f.guidtext, 'BOTTOM')
    end
    --@end-debug@]===]
    ----------------------------------------------------------------- Scripts --
    frame:HookScript('OnShow', OnFrameShow)
    frame:HookScript('OnHide', OnFrameHide)
    frame:HookScript('OnUpdate', OnFrameUpdate)

    f.oldHealth.kuiParent = frame
    f.oldHealth:HookScript('OnValueChanged', function()
        f:OnHealthValueChanged()
    end)
    ------------------------------------------------------------ Finishing up --
    addon:SendMessage('KuiNameplates_PostCreate', f)

    if frame:IsShown() then
        -- force OnShow
        OnFrameShow(frame)
    else
        f:Hide()
    end
end

---------------------------------------------------------------------- Events --
function addon:PLAYER_REGEN_DISABLED()
    if profile.general.combataction_hostile > 1 then
        SetCVar('nameplateShowEnemies',
            profile.general.combataction_hostile == 3 and 1 or 0)
    end
    if profile.general.combataction_friendly > 1 then
        SetCVar('nameplateShowFriends',
            profile.general.combataction_friendly == 3 and 1 or 0)
    end
end
function addon:PLAYER_REGEN_ENABLED()
    if profile.general.combataction_hostile > 1 then
        SetCVar('nameplateShowEnemies',
            profile.general.combataction_hostile == 2 and 1 or 0)
    end
    if profile.general.combataction_friendly > 1 then
        SetCVar('nameplateShowFriends',
            profile.general.combataction_friendly == 2 and 1 or 0)
    end
end
------------------------------------------------------------- Script handlers --
function addon:configChangedListener()
    -- cache values used often to reduce table lookup
    profile = addon.db.profile
    profile_hp = profile.hp
    profile_fade = profile.fade
    profile_fade_rules = profile_fade.rules
    profile_lowhealthval = profile.general.lowhealthval
end
