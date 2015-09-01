local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "CastBars"
local CastBars = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize
local round = nibRealUI.Round

local Textures = {
    [1] = {
        player = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Bar]],
            tick = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Tick]],
        },
        target = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Bar]],
        },
        focus = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Small_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Small_Bar]],
        },
    },
    [2] = {
        player = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Bar]],
            tick = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Tick]],
        },
        target = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Bar]],
        },
        focus = {
            surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Small_Surround]],
            bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Small_Bar]],
        },
    },
}

local CastBarXOffset = {
    [1] = 5,
    [2] = 6,
}

local MaxTicks = 10
local ChannelingTicks = {
    -- Druid
    [GetSpellInfo(16914)] = 10, -- Hurricane
    [GetSpellInfo(106996)] = 10,-- Astral Storm
    [GetSpellInfo(740)] = 4,    -- Tranquility
    -- Mage
    [GetSpellInfo(5143)] = 5,   -- Arcane Missiles
    [GetSpellInfo(10)] = 8,     -- Blizzard
    [GetSpellInfo(12051)] = 3,  -- Evocation
    -- Monk
    [GetSpellInfo(117952)] = 4,  -- Crackling Jade Lightning
    [GetSpellInfo(115175)] = 8,  -- Soothing Mist
    [GetSpellInfo(115294)] = 6,  -- Mana Tea
    [GetSpellInfo(113656)] = 4,  -- Fists of Fury
    -- Priest
    [GetSpellInfo(64843)] = 4,  -- Divine Hymn
    [GetSpellInfo(15407)] = 3,  -- Mind Flay
    [GetSpellInfo(129197)] = 3, -- Mind Flay (Insanity)
    [GetSpellInfo(48045)] = 5,  -- Mind Sear
    [GetSpellInfo(47540)] = 2,  -- Penance
    -- Warlock
    [GetSpellInfo(689)] = 6,    -- Drain Life
    [GetSpellInfo(755)] = 6,    -- Health Funnel
    [GetSpellInfo(4629)] = 6,   -- Rain of Fire
    [GetSpellInfo(103103)] = 6, -- Drain Soul
    [GetSpellInfo(108371)] = 6, -- Harvest Life
}

local MaxNameLengths = {
    player = 26,
    vehicle = 26,
    target = 26,
    focus = 20,
}

local UpdateSpeed = 1/60

-- Chanelling Ticks
function CastBars:ClearTicks()
    CastBars:debug("ClearTicks")
    for i = 1, MaxTicks do
        self.tick[i]:Hide()
    end
end

function CastBars:SetBarTicks(ticks)
    CastBars:debug("SetBarTicks", ticks)
    for i = 1, ticks do
        self.tick[i]:SetPoint("TOPRIGHT", -(floor(db.size[layoutSize].width * ((i - 1) / ticks))), 0)
        self.tick[i]:Show()
    end
end

--[[
    ----
    -- Bar Updates
    ----
    function CastBars:FlashBar(unit, alpha, text)
        self[unit]:SetAlpha(alpha)

        self[unit].color = "flash"
        AngleStatusBar:SetBarColor(self[unit].cast.bar, {1, 0, 0, 1})
        self[unit].name.text:SetTextColor(1, 0, 0, 1)

        AngleStatusBar:SetValue(self[unit].cast.bar, 0.01)
        self[unit].time.text:SetText("")
        self[unit].name.text:SetText(text)
    end

    function CastBars:OnUpdate(unit, elapsed)
        if self.configMode then return end

        -- safety catch
        if (self[unit].action == "NONE") then
            self:StopBar()
            return
        end

        -- Throttle updates
        if (unit == "focus") then elapsed = elapsed * 0.75 end
        self[unit].elapsed = self[unit].elapsed + elapsed
        if self[unit].elapsed < UpdateSpeed then
            return
        else
            self[unit].elapsed = 0
        end

        -- handle casting and channeling
        if (self[unit].action == "CAST" or self[unit].action == "CHANNEL") then
            local remainingTime = self[unit].actionStartTime + self[unit].actionDuration - GetTime()

            local perCast = (self[unit].actionDuration ~= 0 and remainingTime / self[unit].actionDuration or 0)
            -- Reverse channeling
            if (self[unit].action == "CHANNEL") then
                perCast = 1 - (self[unit].actionDuration ~= 0 and remainingTime / self[unit].actionDuration or 0)
            end
            perCast = nibRealUI:Clamp(perCast, 0, 1)

            -- Set Cast Bar
            AngleStatusBar:SetValue(self[unit].cast.bar, perCast)

            -- Reposition Latency if overlapping
            if (unit == self.player.unit) and (self[unit].action == "CHANNEL") then
                if perCast + self.player.cast.latencyRight.value > 1 then
                    AngleStatusBar:SetValue(self[unit].cast.latencyRight, 1-perCast)
                end
            end

            -- Stop if time remaining <= 0
            if (remainingTime <= 0) then
                self:StopBar(unit)
            end

            -- Time text
            if remainingTime < 30 then
                self[unit].time.text:SetFormattedText("%.1f", remainingTime)
            elseif remainingTime < 300 then
                self[unit].time.text:SetFormattedText("%.0f", remainingTime)
            else
                self[unit].time.text:SetText(nibRealUI:ConvertSecondstoTime(remainingTime, true))
            end

            -- Name text
            self[unit].name.text:SetText(nibRealUI:AbbreviateName(self[unit].actionMessage, MaxNameLengths[unit]))

            return
        end

        -- stop bar if casting or channeling is done (in theory this should not be needed)
        if (self[unit].action == "CAST" or self[unit].action == "CHANNEL") then
            self:StopBar(unit)
            return
        end

        -- handle bar flashes
        if (self[unit].action == "FAILURE") then
            if not self[unit].flashStartTime then self[unit].flashStartTime = GetTime() end
            local flashTime = GetTime() - self[unit].flashStartTime

            if (flashTime > 0.5) then
                self:StopBar(unit)
                return
            end

            self:FlashBar(unit, 1-(flashTime*2), self[unit].actionMessage)
            return
        end

        -- something went wrong
        self:StopBar(unit)
    end

    function CastBars:Show(unit, shown)
        if shown or self.configMode then
            self[unit]:Show()
            self[unit]:SetAlpha(1)
        else
            self[unit]:Hide()
        end
    end

    function CastBars:StopBar(unit)
        if not(self[unit] and self[unit].unit == unit) then return end
        self[unit].action = "NONE"
        self[unit].actionStartTime = nil
        self[unit].actionDuration = nil

        self:Show(unit, false)
    end

    function CastBars:StartBar(unit, action, message)
        -- Config Mode
        if self.configMode then
            self[unit].icon.bg:SetTexture("Interface\\Icons\\Spell_Fire_Immolation")
            self[unit].name.text:SetTextColor(1, 1, 1, 1)
            self[unit].name.text:SetText(unit.." cast bar")
            self[unit].time.text:SetText("2.5")

            AngleStatusBar:SetValue(self[unit].cast.bar, 0.35)
            if (unit == "player") then
                AngleStatusBar:SetValue(self[unit].cast.latencyLeft, 0.05)
                AngleStatusBar:SetValue(self[unit].cast.latencyRight, 0)
            end

            self:Show(unit, true)
            return
        end

        local spell, rank, displayName, icon, startTime, endTime, isTradeSkill, _, notInterruptibleCast = UnitCastingInfo(self[unit].unit)
        if not spell then
            spell, rank, displayName, icon, startTime, endTime, _, _, notInterruptibleCast = UnitChannelInfo(self[unit].unit)
        end
        if not spell then return end

        self[unit].notInterruptible = notInterruptibleCast

        self:Show(unit, true)
        self[unit].action = action

        if (icon ~= nil) then
            self[unit].icon.bg:SetTexture(icon)
            self[unit].icon:Show()
        else
            self[unit].icon:Hide()
        end

        self[unit].current = spell
        self[unit].actionStartTime = GetTime()
        self[unit].actionMessage = message
        self[unit].flashStartTime = nil

        if (startTime and endTime) then
            self[unit].actionDuration = (endTime - startTime) / 1000

            -- set start time here in case we start to monitor a cast that is underway already
            self[unit].actionStartTime = startTime / 1000
        else
            self[unit].actionDuration = 1 -- instants/failures
        end

        if not message then
            self[unit].actionMessage = spell
        end

        if not(self[unit].color == "normal") then
            if unit == "vehicle" then unit = "player" end
            if (unit == "player") or not(self[unit].notInterruptible) then
                local color
                if db.colors.useGlobal then
                    if unit == "target" or unit == "focus" then
                        color = nibRealUI.media.colors.orange
                    else
                        color = nibRealUI.media.colors.blue
                    end
                else
                    color = db.colors[unit]
                end
                AngleStatusBar:SetBarColor(self[unit].cast.bar, color)
            else
                self:UpdateInterruptibleColor(unit)
            end
            self[unit].name.text:SetTextColor(1, 1, 1, 1)
            self[unit].color = "normal"
        end
    end

    ----
    -- Casting
    ----
    function CastBars:SpellCastSent(event, unit, spell, rank, target)
        if not(self[unit] and self[unit].unit == unit) then return end
        self[unit].spellCastSent = GetTime()
    end

    function CastBars:SpellCastStart(event, unit, spell, rank)
        if not(self[unit] and self[unit].unit == unit) then return end
        self[unit].current = spell
        self:StartBar(unit, "CAST")

        if not self[unit]:IsShown() or not self[unit].actionDuration then return end

        if unit == self.player.unit then self:SetBarTicks(0) end

        if ((unit == "player") or (unit == "vehicle")) then
            local lagScale
            if self[unit].unit == "vehicle" then
                lagScale = 0
            else
                local now = GetTime()
                local lag = now - (self[unit].spellCastSent or now)
                lagScale = nibRealUI:Clamp(lag / self[unit].actionDuration, 0, 1)
            end
            AngleStatusBar:SetValue(self[unit].cast.latencyLeft, lagScale)
            AngleStatusBar:SetValue(self[unit].cast.latencyRight, 0)
        end

        self[unit].spellCastSent = nil
    end

    function CastBars:SpellCastStop(event, unit, spell, rank)
        if not(self[unit] and self[unit].unit == unit) then return end

        -- ignore if not coming from current spell
        if (self[unit].current and spell and self[unit].current ~= spell) then return end

        if  self[unit].action ~= "FAILURE" and
            self[unit].action ~= "CHANNEL"
        then
            self:StopBar(unit)
            self[unit].current = nil
        end
    end

    function CastBars:SpellCastFailed(event, unit, spell, rank)
        if not(self[unit] and self[unit].unit == unit) then return end

        if (self[unit].current and spell and self[unit].current ~= spell) then return end

        -- channeled spells will call ChannelStop, not cast failed
        if self[unit].action == "CHANNEL" then return end

        self[unit].current = nil

        if (UnitPowerType("player") ~= SPELL_POWER_MANA) then
            return
        end

        self:StartBar(unit, "FAILURE", "Failed")
    end

    function CastBars:SpellCastInterrupted(event, unit, spell, rank)
        if not(self[unit] and self[unit].unit == unit) then return end

        -- ignore if not coming from current spell
        if (self[unit].current and spell and self[unit].current ~= spell) then return end

        self[unit].current = nil

        self:StartBar(unit, "FAILURE", "Interrupted")
    end

    function CastBars:SpellCastDelayed(event, unit, delay)
        if not(self[unit] and self[unit].unit == unit) then return end

        local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(self[unit].unit)

        if (endTime and self[unit].actionStartTime) then
            -- apparently this check is needed, got nils during a horrible lag spike
            self[unit].actionDuration = endTime/1000 - self[unit].actionStartTime
        end
    end


    function CastBars:SpellCastSucceeded(event, unit, spell, rank)
        if not(self[unit] and self[unit].unit == unit) then return end

        -- never show on channeled (why on earth does this event even fire when channeling starts?)
        if (self[unit].action == "CHANNEL") then return end

        -- ignore if not coming from current spell
        if (self[unit].current and self[unit].current ~= spell) then return end

        self[unit].current = nil
    end

    ----
    -- Channeling
    ----
    function CastBars:SpellCastChannelStart(event, unit)
        if not(self[unit] and self[unit].unit == unit) then return end

        self:StartBar(unit, "CHANNEL")

        if not self[unit]:IsShown() or not self[unit].actionDuration then return end

        if (unit == "player") or (unit == "vehicle") then
            local lagScale
            if self[unit].unit == "vehicle" then
                lagScale = 0
            else
                local now = GetTime()
                local lag = now - (self[unit].spellCastSent or now)
                lagScale = nibRealUI:Clamp(lag / self[unit].actionDuration, 0, 1)
            end
            AngleStatusBar:SetValue(self[unit].cast.latencyLeft, 0)
            AngleStatusBar:SetValue(self[unit].cast.latencyRight, lagScale)

            self:SetBarTicks(ChannelingTicks[UnitChannelInfo(unit)])
        end

        self[unit].spellCastSent = nil
    end

    function CastBars:SpellCastChannelUpdate(event, unit)
        if not(self[unit] and self[unit].unit == unit) or not self[unit].actionStartTime then return end

        local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
        if endTime then
            self[unit].actionDuration = endTime/1000 - self[unit].actionStartTime
        end
    end

    function CastBars:SpellCastChannelStop(event, unit)
        if not(self[unit] and self[unit].unit == unit) then return end

        self:StopBar(unit)
    end

    ----
    -- Vehicle check
    ----
    function CastBars:EnteringVehicle(event, unit, arg2)
        if (unit == "player") and (self.player.unit == "player") and arg2 then
            self.player.unit = "vehicle"
            self:StopBar(self.player.unit)
            self:UnitUpdate(self.player.unit)
        end
    end

    function CastBars:ExitingVehicle(event, unit)
        if (unit == "player") then
            self.player.unit = "player"
            self:StopBar(self.player.unit)
            self:UnitUpdate(self.player.unit)
        end
    end

    function CastBars:CheckVehicle()
        self:ToggleConfigMode(false)
        self.player.unit = "player"
        self.target.unit = "target"
        self.focus.unit = "focus"
        if UnitHasVehicleUI("player") then
            self:EnteringVehicle(nil, "player", true)
        else
            self:ExitingVehicle(nil, "player")
        end
    end


    ---- Target
    function CastBars:UpdateInterruptibleColor(unit)
        if unit == "player" or unit == "vehicle" then return end
        local color
        if self[unit].notInterruptible then
            if db.colors.useGlobal then
                color = nibRealUI.media.colors.red
            else
                color = db.colors.uninterruptible
            end
        else
            if db.colors.useGlobal then
                color = nibRealUI.media.colors.blue
            else
                color = db.colors[unit]
            end
        end
        AngleStatusBar:SetBarColor(self[unit].cast.bar, color)
    end

    function CastBars:SpellCastInterruptible(event, unit)
        if not(self[unit] and self[unit].unit == unit) then return end

        self[unit].notInterruptible = false
        self:UpdateInterruptibleColor(unit)
    end

    function CastBars:SpellCastNotInterruptible(event, unit)
        if not(self[unit] and self[unit].unit == unit) then return end
        self[unit].notInterruptible = true
        self:UpdateInterruptibleColor(unit)
    end

    function CastBars:UnitUpdate(unit)
        if not UnitExists(self[unit].unit) then
            self:StopBar(self[unit].unit)
            return
        end

        local spell, _, _, _, _, _, _, _, notInterruptibleCast = UnitCastingInfo(self[unit].unit)
        if (spell) then
            self[unit].notInterruptible = notInterruptibleCast
            self:StartBar(self[unit].unit, "CAST")
            return
        end

        local channel, _, _, _, _, _, _, notInterruptibleChannel = UnitChannelInfo(self[unit].unit)
        if (channel) then
            self[unit].notInterruptible = notInterruptibleChannel
            self:StartBar(self[unit].unit, "CHANNEL")
            return
        end

        self:StopBar(self[unit].unit)
    end

    function CastBars:PLAYER_TARGET_CHANGED()
        self.target.unit = "target"
        self:UnitUpdate("target")
    end

    function CastBars:PLAYER_FOCUS_CHANGED()
        self.focus.unit = "focus"
        self:UnitUpdate("focus")
    end

    ----
    -- Frame Creation / Updates
    ----
    local function SetTextPosition(frame, p1, p2)
        local cPos = (p1 ~= "CENTER") and p1..p2 or p1
        frame.text:ClearAllPoints()
        frame.text:SetPoint(cPos, frame, cPos, 0.5, 0.5)
        frame.text:SetJustifyH(p2)
        frame.text:SetJustifyV(p1)
    end

    function CastBars:UpdateAnchors()
        local textPointVert, textPointHoriz, textY, textX, xOfs, fontYOfs
        if db.text.textOnBottom then
            textPointVert = "TOP"
            xOfs = db.size[layoutSize].height + 1
        else
            textPointVert = "BOTTOM"
            xOfs = 0
        end

        -- Player
        if db.text.textInside then textPointHoriz = "RIGHT" else textPointHoriz = "LEFT" end

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
        textX = textPointHoriz == "LEFT" and 25 or -35
        if (ndb.settings.fontStyle ~= 1) and db.text.textOnBottom then fontYOfs = -1 else fontYOfs = 0 end
        SetTextPosition(self.player.name, textPointVert, textPointHoriz)
        self.player.name:ClearAllPoints()
        self.player.name:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY + fontYOfs)

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 21) else textY = 13 end
        textX = textPointHoriz == "LEFT" and 25 or -35
        SetTextPosition(self.player.time, "BOTTOM", textPointHoriz)
        self.player.time:ClearAllPoints()
        self.player.time:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY)

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 4) else textY = 2 end
        textX = textPointHoriz == "LEFT" and -7 or -(db.size[layoutSize].height + 1)
        self.player.icon:ClearAllPoints()
        self.player.icon:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY)

        if db.reverse.player then
            AngleStatusBar:ReverseBarDirection(self.player.cast.bar, db.reverse.player, (251 - db.size[layoutSize].width), -1)
            AngleStatusBar:ReverseBarDirection(self.player.cast.latencyLeft, db.reverse.player, -5, -1)
            AngleStatusBar:ReverseBarDirection(self.player.cast.latencyRight, db.reverse.player, (251 - db.size[layoutSize].width), -1)
        else
            AngleStatusBar:ReverseBarDirection(self.player.cast.bar, db.reverse.player)
            AngleStatusBar:ReverseBarDirection(self.player.cast.latencyLeft, db.reverse.player)
            AngleStatusBar:ReverseBarDirection(self.player.cast.latencyRight, db.reverse.player)
        end

        -- Target
        if db.text.textInside then textPointHoriz = "LEFT" else textPointHoriz = "RIGHT" end

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
        textX = textPointHoriz == "LEFT" and 37 or -23
        SetTextPosition(self.target.name, textPointVert, textPointHoriz)
        self.target.name:ClearAllPoints()
        self.target.name:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY + fontYOfs)

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 21) else textY = 13 end
        textX = textPointHoriz == "LEFT" and 37 or -23
        SetTextPosition(self.target.time, "BOTTOM", textPointHoriz)
        self.target.time:ClearAllPoints()
        self.target.time:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY)

        if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 4) else textY = 2 end
        textX = textPointHoriz == "LEFT" and 5 or (db.size[layoutSize].height + 2)
        self.target.icon:ClearAllPoints()
        self.target.icon:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY)

        if db.reverse.target then
            AngleStatusBar:ReverseBarDirection(self.target.cast.bar, db.reverse.target, 5 + db.size[layoutSize].width - 256, -1)
        else
            AngleStatusBar:ReverseBarDirection(self.target.cast.bar, db.reverse.target)
        end


        -- Focus
        self.focus:SetParent(RealUIFocusFrame)
        self.focus:ClearAllPoints()
        self.focus:SetPoint("TOPRIGHT", RealUIFocusFrame, "TOPRIGHT", db.size[layoutSize].focus.x + 3, db.size[layoutSize].focus.y)

        -- if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
        -- textX = textPointHoriz == "LEFT" and 37 or -23
        if (ndb.settings.fontStyle == 3) then fontYOfs = -1 else fontYOfs = 0 end
        SetTextPosition(self.focus.name, "BOTTOM", "RIGHT")
        self.focus.name:ClearAllPoints()
        self.focus.name:SetPoint("BOTTOMRIGHT", self.focus, "TOPRIGHT", 2, 2 + fontYOfs)

        SetTextPosition(self.focus.time, "BOTTOM", "LEFT")
        self.focus.time:ClearAllPoints()
        self.focus.time:SetPoint("TOPRIGHT", self.focus, "TOPRIGHT", 32, 6)

        self.focus.icon:ClearAllPoints()
        self.focus.icon:SetPoint("TOPRIGHT", self.focus, "TOPRIGHT", 18, 11)
    end

    function CastBars:UpdateTextures()
        self.player.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
        if db.colors.useGlobal then
            AngleStatusBar:SetBarColor(self.player.cast.bar, nibRealUI.media.colors.blue)
            AngleStatusBar:SetBarColor(self.player.cast.latencyLeft, nibRealUI.media.colors.red)
            AngleStatusBar:SetBarColor(self.player.cast.latencyRight, nibRealUI.media.colors.red)
        else
            AngleStatusBar:SetBarColor(self.player.cast.bar, db.colors.player)
            AngleStatusBar:SetBarColor(self.player.cast.latencyLeft, db.colors.latency)
            AngleStatusBar:SetBarColor(self.player.cast.latencyRight, db.colors.latency)
        end

        self.target.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
        self:UpdateInterruptibleColor("target")

        self.focus.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
        self:UpdateInterruptibleColor("focus")
    end

    function CastBars:UpdateGlobalColors()
        self:UpdateTextures()
    end

    local function CreateIconFrame(parent, size)
        local NewIconFrame = CreateFrame("Frame", nil, parent)
        NewIconFrame:SetSize(size, size)

        nibRealUI:CreateBD(NewIconFrame)
        NewIconFrame.bg = NewIconFrame:CreateTexture(nil, "ARTWORK")
        NewIconFrame.bg:SetPoint("TOPRIGHT", NewIconFrame, "TOPRIGHT", -1, -1)
        NewIconFrame.bg:SetPoint("BOTTOMLEFT", NewIconFrame, "BOTTOMLEFT", 1, 1)
        NewIconFrame.bg:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        return NewIconFrame
    end

    local function CreateTextFrame(parent, size)
        local NewTextFrame = CreateFrame("Frame", nil, parent)
        NewTextFrame:SetSize(12, 12)

        NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
        if size == "numbers" then
            NewTextFrame.text:SetFontObject(RealUIFont_PixelNumbers)
        elseif size == "small" then
            NewTextFrame.text:SetFontObject(RealUIFont_PixelSmall)
        else
            NewTextFrame.text:SetFontObject(RealUIFont_Pixel)
        end

        return NewTextFrame
    end

    local function CreateCastBar(parent, unit, side)
        local NewCB = CreateFrame("Frame", nil, parent)
        NewCB:SetParent(parent)
        NewCB:SetSize(256, 16)
        if side == "RIGHT" then NewCB:SetPoint("TOPLEFT", parent) else NewCB:SetPoint("TOPRIGHT", parent) end

        NewCB.surround = NewCB:CreateTexture(nil, "BORDER")
        NewCB.surround:SetAllPoints()
        NewCB.surround:SetTexture(Textures[layoutSize][unit].surround)
        if side == "RIGHT" then NewCB.surround:SetTexCoord(1, 0, 0, 1) end

        NewCB.bg = NewCB:CreateTexture(nil, "BACKGROUND")
        NewCB.bg:SetAllPoints()
        NewCB.bg:SetTexture(Textures[layoutSize][unit].bar)
        if side == "RIGHT" then NewCB.bg:SetTexCoord(1, 0, 0, 1) end

        return NewCB
    end

    function CastBars:CreateFrames()
        -- Player
        local cbPlayer = CreateFrame("Frame", "RealUI_CastBarsPlayer", RealUIPositionersCastBarPlayer)
        cbPlayer:Hide()
        self.player = cbPlayer
        self.vehicle = cbPlayer
            cbPlayer:SetHeight(32 + db.size[layoutSize].height)
            cbPlayer:SetWidth(db.size[layoutSize].width)
            cbPlayer:SetPoint("TOPRIGHT", RealUIPositionersCastBarPlayer, "TOPRIGHT", -1, 0)
            cbPlayer:SetScript("OnUpdate", function(self, elapsed)
                CastBars:OnUpdate("player", elapsed)
            end)

            -- Cast Bar
            cbPlayer.cast = CreateCastBar(cbPlayer, "player", "LEFT")
                cbPlayer.cast.bar = AngleStatusBar:NewBar(cbPlayer.cast, -CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "LEFT")
                    cbPlayer.cast.bar:SetFrameLevel(5)
                cbPlayer.cast.latencyLeft = AngleStatusBar:NewBar(cbPlayer.cast, (256 - CastBarXOffset[layoutSize] - db.size[layoutSize].width), -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "RIGHT")
                    cbPlayer.cast.latencyLeft:SetFrameLevel(4)
                    cbPlayer.cast.latencyLeft.reverse = true
                cbPlayer.cast.latencyRight = AngleStatusBar:NewBar(cbPlayer.cast, -CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "LEFT")
                    cbPlayer.cast.latencyRight:SetFrameLevel(6)
                    cbPlayer.cast.latencyRight.reverse = true

            -- Name / Time / Icon
            cbPlayer.name = CreateTextFrame(cbPlayer)
            cbPlayer.time = CreateTextFrame(cbPlayer, "numbers")
            cbPlayer.icon = CreateIconFrame(cbPlayer, 28)

            -- Chanelling Ticks
            cbPlayer.tick = {}
            for i = 1, MaxTicks do
                cbPlayer.tick[i] = CreateFrame("Frame", nil, cbPlayer)
                local tick = cbPlayer.tick[i]
                    tick:SetFrameLevel(7)
                    tick:SetSize(16, 16)

                tick.bg = tick:CreateTexture(nil, "OVERLAY")
                    tick.bg:SetAllPoints()
                    tick.bg:SetTexture(Textures[layoutSize].player.tick)
                    tick.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], 0.4)

                tick:Hide()
            end

        -- Target
        local cbTarget = CreateFrame("Frame", "RealUI_CastBarsTarget", RealUIPositionersCastBarTarget)
        cbTarget:Hide()
        self.target = cbTarget
            cbTarget:SetHeight(32 + db.size[layoutSize].height)
            cbTarget:SetWidth(db.size[layoutSize].width)
            cbTarget:SetPoint("TOPLEFT", RealUIPositionersCastBarTarget, "TOPLEFT", 0, 0)
            cbTarget:SetScript("OnUpdate", function(self, elapsed)
                CastBars:OnUpdate("target", elapsed)
            end)

            -- Cast Bar
            cbTarget.cast = CreateCastBar(cbTarget, "target", "RIGHT")
                cbTarget.cast.bar = AngleStatusBar:NewBar(cbTarget.cast, CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "LEFT", "LEFT", "RIGHT")

            -- Name / Time / Icon
            cbTarget.name = CreateTextFrame(cbTarget)
            cbTarget.time = CreateTextFrame(cbTarget, "numbers")
            cbTarget.icon = CreateIconFrame(cbTarget, 28)


        -- Focus
        local cbFocus = CreateFrame("Frame", "RealUI_CastBarsFocus", UIParent)
        cbFocus:Hide()
        self.focus = cbFocus
            cbFocus:SetHeight(13 + db.size[layoutSize].focus.height)
            cbFocus:SetWidth(db.size[layoutSize].focus.width)
            cbFocus:SetScript("OnUpdate", function(self, elapsed)
                CastBars:OnUpdate("focus", elapsed)
            end)

            -- Cast Bar
            cbFocus.cast = CreateCastBar(cbFocus, "focus", "LEFT")
                cbFocus.cast.bar = AngleStatusBar:NewBar(cbFocus.cast, -2, -1, db.size[layoutSize].focus.width, db.size[layoutSize].focus.height, "LEFT", "RIGHT", "LEFT")

            -- Name / Time / Icon
            cbFocus.name = CreateTextFrame(cbFocus, "small")
            cbFocus.time = CreateTextFrame(cbFocus, "numbers")
            cbFocus.icon = CreateIconFrame(cbFocus, 16)
    end
]]

local info = {
    player = {
        leftAngle = [[\]],
        rightAngle = [[\]],
        smooth = false,
        debug = "playerCast"
    },
    target = {
        leftAngle = [[/]],
        rightAngle = [[/]],
        smooth = false,
        debug = "targetCast"
    },
    focus = {
        leftAngle = [[\]],
        rightAngle = [[/]],
        smooth = false,
        debug = "focusCast"
    },
}

-- From oUF castbar
local updateSafeZone = function(self)
    local sz = self.safeZone
    local width = self:GetWidth()
    local _, _, _, ms = GetNetStats()

    -- Guard against GetNetStats returning latencies of 0.
    if (ms ~= 0) then
        -- MADNESS!
        local safeZonePercent = (width / self.max) * (ms / 1e5)
        if (safeZonePercent > 1) then safeZonePercent = 1 end
        sz:SetWidth(width * safeZonePercent)
        sz:Show()
    else
        sz:Hide()
    end
end

local function PostCastStart(self, unit, ...)
    CastBars:debug("PostCastStart", unit, ...)
    local sz = self.safeZone
    sz:ClearAllPoints()
    if self:GetReverseFill() then
        sz:SetPoint("TOPLEFT", self, 2, 0)
    else
        sz:SetPoint("TOPRIGHT", self, -2, 0)
    end
    updateSafeZone(self)

    if self.ClearTicks then
        self:ClearTicks()
    end
end
--[==[
local function PostCastFailed(self, unit, ...)
    CastBars:debug("PostCastFailed", unit, ...)
end
]==]
local function PostCastInterrupted(self, unit, ...)
    CastBars:debug("PostCastInterrupted", unit, ...)
    self.castid = nil
    if not self.flashAnim:IsPlaying() then
        CastBars:debug("PlayFlash")
        self.Time:SetText("")
        self.Text:SetText(SPELL_FAILED_INTERRUPTED)
        self.Text:SetTextColor(1, 0, 0, 1)
        self:SetStatusBarColor(1, 0, 0, 1)
        self:Show()
        self.flash:SetChange(-(self:GetAlpha()))
        self.flashAnim:Play()
    end
end
local function PostCastInterruptible(self, unit, ...)
    CastBars:debug("PostCastInterruptible", unit, ...)
    local color = db.colors[unit]
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end
local function PostCastNotInterruptible(self, unit, ...)
    CastBars:debug("PostCastNotInterruptible", unit, ...)
    local color = db.colors.uninterruptible
    self:SetStatusBarColor(color[1], color[2], color[3], color[4])
end
--[==[
local function PostCastDelayed(self, unit, ...)
    CastBars:debug("PostCastDelayed", unit, ...)
end
local function PostCastStop(self, unit, ...)
    CastBars:debug("PostCastStop", unit, ...)
end
]==]

local function PostChannelStart(self, unit, spellName)
    CastBars:debug("PostChannelStart", unit, spellName)
    local sz = self.safeZone
    sz:ClearAllPoints()
    local point, x
    if self:GetReverseFill() then
        point, x = "TOPRIGHT", -1
    else
        point, x = "TOPLEFT", 1
    end
    sz:SetPoint(point, self, x, 0)
    updateSafeZone(self)

    if self.SetBarTicks then
        self:SetBarTicks(ChannelingTicks[spellName])
    end
end
--[==[
local function PostChannelUpdate(self, unit, ...)
    CastBars:debug("PostChannelUpdate", unit, ...)
end
local function PostChannelStop(self, unit, ...)
    CastBars:debug("PostChannelStop", unit, ...)
end
]==]

local function CustomDelayText(self, duration, ...)
    CastBars:debug("CustomDelayText", duration, ...)
    self.Time:SetFormattedText("%.1f", duration)
end
local function CustomTimeText(self, duration, ...)
    CastBars:debug("CustomTimeText", duration, ...)
    self.Time:SetFormattedText("%.1f", duration)
end

function CastBars:CreateCastBars(self, unit)
    CastBars:debug("CreateCastBars", unit)
    local info, unitDB = info[unit], db[unit]
    local size, color = db.size[layoutSize], db.colors[unit]
    local width, height = size[unit] and size[unit].width or size.width, size[unit] and size[unit].height or size.height
    if not unitDB.debug then info.debug = nil end
    local Castbar = self:CreateAngleFrame("Status", width, height, self.overlay, info)
    Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
    if db.reverse[unit] then
        Castbar:SetReverseFill(true)
    end

    local Icon = Castbar:CreateTexture(nil, "OVERLAY")
    Castbar.Icon = Icon
    Icon:SetSize(unitDB.icon, unitDB.icon)
    Aurora[1].ReskinIcon(Icon)

    local Text = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Text = Text
    Text:SetFontObject(RealUIFont_Pixel)

    local Time = Castbar:CreateFontString(nil, "OVERLAY")
    Castbar.Time = Time
    Time:SetFontObject(RealUIFont_PixelNumbers)

    local safeZone, color = self:CreateAngleFrame("Bar", width, height, Castbar, info), db.colors.latency
    Castbar.safeZone = safeZone
    safeZone:SetValue(1, true)
    safeZone:SetStatusBarColor(color[1], color[2], color[3], color[4])

    if unit == "player" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPRIGHT", RealUIPositionersCastBarPlayer, "TOPRIGHT", 0, 0)
        Icon:SetPoint("TOPRIGHT", Castbar, "BOTTOMRIGHT", -1, -2)
        Text:SetPoint("TOPRIGHT", Icon, "TOPLEFT")
        Time:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMLEFT")

        Castbar.tick = {}
        for i = 1, MaxTicks do
            local tick = self:CreateAngleFrame("Bar", width, height, Castbar, info)
            tick:SetStatusBarColor(0, 0, 0, 0.5)
            tick:SetWidth(round(width * 0.08))
            tick:ClearAllPoints()
            Castbar.tick[i] = tick
        end
        Castbar.ClearTicks = CastBars.ClearTicks
        Castbar.SetBarTicks = CastBars.SetBarTicks
    elseif unit == "target" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("TOPLEFT", RealUIPositionersCastBarTarget, "TOPLEFT", 0, 0)
        Icon:SetPoint("TOPLEFT", Castbar, "BOTTOMLEFT", 1, -2)
        Text:SetPoint("TOPLEFT", Icon, "TOPRIGHT", 2, 0)
        Time:SetPoint("BOTTOMLEFT", Icon, "BOTTOMRIGHT", 2, 0)
    elseif unit == "focus" then
        CastBars:debug("Set positions", unit)
        Castbar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 5, 1)
        Icon:SetPoint("BOTTOMLEFT", Castbar, "BOTTOMRIGHT", 2, 1)
        Text:SetPoint("BOTTOMRIGHT", Castbar, "TOPRIGHT", 0, 2)
        Time:SetPoint("BOTTOMLEFT", Icon, "BOTTOMRIGHT", 2, 0)
    end

    local flashAnim = Castbar:CreateAnimationGroup()
    Castbar.flashAnim = flashAnim
    flashAnim:SetScript("OnFinished", function(self, ...)
        CastBars:debug("flashAnim:OnFinished", ...)
        Castbar:SetAlpha(-(Castbar.flash:GetChange()))
        Castbar.Text:SetTextColor(1, 1, 1, 1)
        Castbar:SetStatusBarColor(color[1], color[2], color[3], color[4])
        Castbar:Hide()
    end)
    local flash = flashAnim:CreateAnimation("Alpha")
    Castbar.flash = flash
    flash:SetDuration(1)
    flash:SetSmoothing("OUT")

    Castbar:SetScript("OnHide", function(self, ...)
        if flashAnim:IsPlaying() then
            self:Show()
        end
    end)

    Castbar.PostCastStart = PostCastStart
    Castbar.PostCastFailed = PostCastFailed
    Castbar.PostCastInterrupted = PostCastInterrupted
    Castbar.PostCastInterruptible = PostCastInterruptible
    Castbar.PostCastNotInterruptible = PostCastNotInterruptible
    Castbar.PostCastDelayed = PostCastDelayed
    Castbar.PostCastStop = PostCastStop

    Castbar.PostChannelStart = PostChannelStart
    --Castbar.PostChannelUpdate = PostChannelUpdate
    --Castbar.PostChannelStop = PostChannelStop

    Castbar.CustomDelayText = CustomDelayText
    Castbar.CustomTimeText = CustomTimeText

    self.Castbar = Castbar
    CastBars[unit] = Castbar
end

----------
function CastBars:SetUpdateSpeed()
    if ndb.settings.powerMode == 2 then -- Economy
        UpdateSpeed = 1/40
    else
        UpdateSpeed = 1/60
    end
end

function CastBars:ToggleConfigMode(val)
    if self.configMode == val then return end
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    self.configMode = val

    if val then
        for _, unit in next, {"player", "target", "focus"} do
            local castbar = CastBars[unit]
            castbar.casting = true
            castbar.duration, castbar.max = castbar:GetMinMaxValues()
            CastBars:debug("Fake minmax", castbar.duration, castbar.max)
            castbar:Show()
        end
    else
    end
end

--[==[function CastBars:PLAYER_LOGIN()
    self:UpdateAnchors()
end

-- Color Retrieval for Config Bar
function CastBars:GetColors()
    return db.colors
end

function CastBars:SetOption(key1, key2, value)
    db[key1][key2] = value
    self:UpdateAnchors()
    self:UpdateTextures()
end

function CastBars:GetOption(key1, key2)
    return db[key1][key2]
end
]==]
function CastBars:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            reverse = {
                player = true,
                target = false,
            },
            player = {
                size = {x = 230, y = 28},
                position = {x = 0, y = 0},
                icon = 28,
                debug = true
            },
            target = {
                size = {x = 230, y = 28},
                position = {x = 0, y = 0},
                icon = 28,
                debug = false
            },
            focus = {
                size = {x = 146, y = 28},
                position = {x = 0, y = 0},
                icon = 16,
                debug = true
            },
            size = {
                [1] = {
                    width = 200,
                    height = 6,
                    focus = {
                        width = 126,
                        height = 4,
                        x = 3,
                        y = 6,
                    },
                },
                [2] = {
                    width = 230,
                    height = 8,
                    focus = {
                        width = 146,
                        height = 5,
                        x = 4,
                        y = 7,
                    },
                },
            },
            colors = {
                useGlobal = true,
                player =            {0.15, 0.61, 1.00, 1},
                focus =             {1.00, 0.38, 0.08, 1},
                target =            {0.15, 0.61, 1.00, 1},
                uninterruptible =   {0.85, 0.14, 0.14, 1},
                latency =           {0.80, 0.13, 0.13, 1},
            },
            text = {
                textOnBottom = true,
                textInside = true,
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile

    layoutSize = ndb.settings.hudSize

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterConfigModeModule(self)
end

function CastBars:OnEnable()
    self.configMode = false
    --[[
    self:SetUpdateSpeed()

    if not self.player then self:CreateFrames() end
    self:UpdateAnchors()
    self:UpdateTextures()

    self.player.unit = "player"
    self.player.action = "NONE"
    self.player.targetInRange = true
    self.player.elapsed = 0

    self.target.unit = "target"
    self.target.action = "NONE"
    self.target.elapsed = 0

    self.focus.unit = "focus"
    self.focus.action = "NONE"
    self.focus.elapsed = 0

    -- Events
    self:RegisterEvent("PLAYER_LOGIN")

    -- Vehicle check
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", "EnteringVehicle")
    self:RegisterEvent("UNIT_EXITED_VEHICLE", "ExitingVehicle")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckVehicle")

    -- Cast
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")

    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "SpellCastInterruptible")
    self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "SpellCastNotInterruptible")

    self:RegisterEvent("UNIT_SPELLCAST_SENT", "SpellCastSent") -- "player", spell, rank, target
    self:RegisterEvent("UNIT_SPELLCAST_START", "SpellCastStart") -- unit, spell, rank
    self:RegisterEvent("UNIT_SPELLCAST_STOP", "SpellCastStop") -- unit, spell, rank

    self:RegisterEvent("UNIT_SPELLCAST_FAILED", "SpellCastFailed") -- unit, spell, rank
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "SpellCastInterrupted") -- unit, spell, rank

    self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "SpellCastDelayed") -- unit, spell, rank
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "SpellCastSucceeded") -- "player", spell, rank

    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "SpellCastChannelStart") -- unit, spell, rank
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "SpellCastChannelUpdate") -- unit, spell, rank
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "SpellCastChannelStop") -- unit, spell, rank

    -- Disable default Cast Bars
    CastingBarFrame:UnregisterAllEvents()
    PetCastingBarFrame:UnregisterAllEvents()
    ---]]
end

function CastBars:OnDisable()
    self:UnregisterAllEvents()

    -- Enable default Cast Bars
    CastingBarFrame:GetScript("OnLoad")(CastingBarFrame)
    PetCastingBarFrame:GetScript("OnLoad")(PetCastingBarFrame)
end
