-- Lua Globals --
local _G = _G
local next = _G.next

-- WoW Globals --
local UIParent = _G.UIParent
local CreateFrame, UnitAura, GetSpellInfo = _G.CreateFrame, _G.UnitAura, _G.GetSpellInfo

-- Libs --
local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local round = nibRealUI.Round

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:GetModule(MODNAME)

local icons = {}

-- Custom Cooldown
local function CustomCooldownUpdate(self, elapsed)
    if not(self.startTime and self.auraDuration) then
        self.elapsed = 1
        self.customCDTime:SetText()
        return
    end

    self.elapsed = self.elapsed + elapsed
    if self.elapsed > 0.1 then
        local now = GetTime()
        local maxHeight = 30
        local curHeight = nibRealUI:Clamp(((now - self.startTime) / self.auraDuration) * maxHeight, 0, maxHeight)
        local remaining = self.auraDuration - (now - self.startTime)

        self.customCD:SetHeight(curHeight)

        local time, suffix = AuraTracking:GetTimeText(remaining)
        self.customCDTime:SetFormattedText("%d%s", time, suffix or "")

        local color
        if remaining >= 59.5 then
            color = nibRealUI.CooldownCount.db.profile.colors.minutes
        elseif remaining >= 5.5 then
            color = nibRealUI.CooldownCount.db.profile.colors.seconds
        else
            color = nibRealUI.CooldownCount.db.profile.colors.expiring
        end
        self.customCDTime:SetTextColor(color[1], color[2], color[3])

        self.elapsed = 0
    end
end

-- Aura update
local function GetAuraInfo(self, index)
    local spellName = index and self.spellNames[index] or self.spellName
    local spellID = index and tonumber(self.spellIDs[index]) or tonumber(self.spellID)
    AuraTracking:debug("GetAuraInfo", spellID, spellName)
    local buffFilter = (self.isBuff and "HELPFUL" or "HARMFUL") .. (self.anyone and "" or "|PLAYER")

    local _, name, duration, remaining, count, texture, endTime, curSpellID
    local i = 1 repeat
        name, _, texture, count, _, duration, endTime, _, _, _, curSpellID = UnitAura(self.unit, i, buffFilter)
        --AuraTracking:debug("UnitAura", curSpellID, name)
        if not spellID and (spellName == name) then
            spellID = curSpellID
        end
        i = i + 1
    until (spellID == curSpellID) or (not name)

    if (spellID == curSpellID) then
        if endTime then
            remaining = endTime - GetTime()
        end
        return name, duration, remaining, count, texture, endTime
    end
end

local function AuraUpdate(self, event, unit)
    local spellData = icons[self]
    AuraTracking:debug("AuraUpdate", spellData.spell, self.inactive)
    if self.inactive and not self.isStatic then
        self:Hide()
        AuraTracking:FreeIndicatorUpdate(self, false)
        return
    end
    if self.inactive then return end

    local name, duration, remaining, count, texture, endTime
    if self.trackMultiple then
        for k,v in ipairs(self.spellIDs) do
            name, duration, remaining, count, texture, endTime = GetAuraInfo(self, k)
            if name then break end
        end
    else
        name, duration, remaining, count, texture, endTime = GetAuraInfo(self)
    end

    -- Set Icon Texture / Desaturated
    if not(self.isStatic) then
        -- Update Free aura icon
        if texture then self.icon:SetTexture(texture) end
    else
        self.isActive = false
        -- Update Static aura icon and active status
        if name and texture then
            self.texture = texture
            self.icon:SetTexture(texture)
        end
        if not name then
            self.icon:SetDesaturated(true)
            self.isActive = false
        else
            self.icon:SetDesaturated(false)
            if not self.hideOOC then
                self.isActive = true
            end
        end
    end

    -- Active Spell Name
    if name then
        self.activeSpellName = name
    else
        self.activeSpellName = nil
    end
    self.auraIndex = nil

    -- Calculate Aura info
    if name then
        if endTime == 0 then
            self.bIsAura = true
            self.auraDuration = 1
            self.auraEndTime = 0
            self.startTime = 0
            remaining = 1
        elseif not remaining then
            self.bIsAura = false
            self.auraEndTime = -1
            self.auraDuration = duration
            self.startTime = GetTime() - duration
        else
            self.bIsAura = false
            self.auraEndTime = remaining + GetTime()
            self.auraDuration = duration
            self.startTime = self.auraEndTime - duration
        end
    else
        self.auraEndTime = nil
        self.count:SetText()
    end

    -- Update Frame
    if self.auraEndTime ~= nil and (self.auraEndTime == 0 or self.auraEndTime >= GetTime()) then
        -- Cooldown
        if not(self.bIsAura) and (self.auraEndTime > 0) and not(self.hideTime) then
            if self.useCustomCD then
                self.customCD:Show()
                self.customCDTime:Show()
                self.count:SetParent(self)
            else
                self.cd:SetCooldown(self.startTime, self.auraDuration)
                self.cd:Show()
                self.count:SetParent(self.cd)
            end
        else
            self.cd:Hide()
            self.customCD:Hide()
            self.customCDTime:Hide()
            self.count:SetParent(self)
        end

        -- Count
        if count and (count > 0) and not(self.hideStacks) then
            self.count:SetText(count)
        else
            self.count:SetText()
        end

        -- Show frame
        self:Show()
        if not self.isStatic then
            AuraTracking:FreeIndicatorUpdate(self, true)
        end
    else
        -- Hide frame
        if not(self.isStatic) and self:IsShown() then
            self:Hide()
            AuraTracking:FreeIndicatorUpdate(self, false)
        else
            self.cd:Hide()
            self.customCD:Hide()
            self.customCDTime:Hide()
        end
    end

    if self.isStatic then
        AuraTracking:StaticIndicatorUpdate(self)
    end
end

-- Retrieve Spell Info
local function UpdateSpellInfo(self)
    local spellData = icons[self]
    if tonumber(spellData.spell) then
        self.spellID = spellData.spell
        self.spellName = (GetSpellInfo(spellData.spell))
    elseif type(spellData.spell) == "table" then
        self.trackMultiple = true
        self.spellIDs = {}
        self.spellNames = {}
        for k,v in ipairs(spellData.spell) do
            self.spellIDs[k] = v
            self.spellNames[k] = (GetSpellInfo(v))
        end
    else
        spellData.spell = spellData.spell
        self.spellName = spellData.spell
    end
end

-- Spell validity check
local function CheckSpellValidity(self)
    if self.isDisabled then return end
    local isValid
    if self.isStatic and (self.minLevel == 0) then
        -- No Min Level specified, check if spell exists
        if self.isTrinket then
            isValid = true
        elseif self.trackMultiple then
            for k,spellID in pairs(self.spellIDs) do
                if GetSpellInfo(spellID) then
                    if self.checkKnown then
                        isValid = IsPlayerSpell(spellID)
                    else
                        isValid = true
                    end
                else
                    print("|cffff0000Spell |cffffffff["..spellID.."]|r|cffff0000 not valid.|r")
                end
                if isValid then break end
            end
        else
            isValid = self.spellName or GetSpellInfo(self.spellID)
            if not isValid and self.spellID then
                print("|cffff0000Spell |cffffffff["..self.spellID.."]|r|cffff0000 not valid.|r")
            end
            if self.checkKnown and isValid and self.spellID then
                isValid = IsPlayerSpell(self.spellID)
            end
        end

    elseif (self.minLevel > 0) then
        -- Min Level specified, are we high enough level?
        if UnitLevel("player") >= self.minLevel then
            isValid = true
        end

    else
        -- Fallback
        isValid = true
    end
    return isValid
end

-- Show/Hide based on Talent spec
local function TalentUpdate(self, event, unit, initializing)
    local oldInactive = self.inactive
    local spellData = icons[self]

    -- Check specs
    if spellData.useSpec then
        local spec = GetSpecialization()
        self.inactive = not(self.specs[spec])
    end

    -- Check talents
    if self.talent then
        local specGroup, _, selected = GetActiveSpecGroup()
        AuraTracking:debug("Check talents", specGroup)
        for tier, talentIDs in next, self.talent do
            AuraTracking:debug("tier", tier, #talentIDs)
            if tier <= GetMaxTalentTier() then
                for i = 1, #talentIDs do
                    _, _, _, selected = GetTalentInfoByID(talentIDs[i], specGroup)
                    AuraTracking:debug("talent", talentIDs[i], selected)
                    if selected then 
                        break
                    end
                end
                self.inactive = not selected
            end
        end
    end

    -- Check Spell validity
    if not(self.inactive) and self.isStatic then
        local isValid = CheckSpellValidity(self)
        self.inactive = not(isValid)
    end

    -- Update
    if not(initializing) then
        UpdateSpellInfo(self)
        if self.inactive ~= oldInactive then
            if self.isStatic then
                if not self.inactive then
                    AuraUpdate(self, nil, self.unit)
                end
                AuraTracking:RefreshIndicatorAssignments()
            else
                AuraUpdate(self, nil, self.unit)
            end
        end
    end

    -- Raven Spell Lists
    if self.trackMultiple then
        for k,spellID in pairs(self.spellIDs) do
            AuraTracking:ToggleRavenAura(self.ignoreRaven, self.auraType, "#"..spellID, not(self.inactive))
        end
    else
        AuraTracking:ToggleRavenAura(self.ignoreRaven, self.auraType, self.spellID and "#"..self.spellID or self.spellName, not(self.inactive))
    end
end

-- Target Change
local function TargetChanged(self)
    if self.unit == "target" then
        AuraUpdate(self, nil, self.unit)
    end
end

-- Pet Update
local function PetUpdate(self)
    if self.unit == "pet" then
        AuraUpdate(self, nil, self.unit)
    end
end

--[[ Event Functions]]--
local events = {}

function events.UNIT_AURA(self, ...)
end

function events.PLAYER_TARGET_CHANGED(self, ...)
end

function events.UNIT_PET(self, ...)
end

--[[ API Functions ]]--
local api = {}
-- Refresh Functions
function api:TalentRefresh()
    TalentUpdate(self.frame, nil, nil, true)
end

function api:AuraRefresh()
    AuraUpdate(self.frame, nil, self.unit)

    if self.frame.isStatic then
        if self.frame.inactive then
            self.frame:Hide()
        else
            self.frame:Show()
        end
    end
end

-- Register updates
function api:SetUpdates()
    local f = self.frame
    f:UnregisterAllEvents()
    AuraTracking:debug("SetUpdates", f.info.spell, f.inactive)

    local isValid = CheckSpellValidity(f)
    if not isValid then
        if f.isStatic then f.inactive = true end
        return
    end


end

-- Set Indicator info
function api:SetIndicatorInfo(info)
    self.auraType = info.auraType or "buff"
    self.isBuff = (self.auraType == "buff")
    self.isTrinket = info.unit and info.unit == "trinket"

    if self.isBuff then
        self.unit = info.unit or "player"
    else
        self.unit = info.unit or "target"
    end
    if self.unit == "trinket" then self.unit = "player" end

    self.side = info.side
    if not self.side then
        if self.unit == "player" or self.unit == "pet" or self.unit == "trinket" then
            self.side = "LEFT"
        else
            self.side = "RIGHT"
        end
    end

    self.specs = info.specs or {true, true, true, true}
    self.talent = info.talent
    self.minLevel = tonumber(info.minLevel or 0)

    self.anyone = info.anyone
    if self.isTrinket then self.anyone = true end

    UpdateSpellInfo(self)

    if not info.order then
        self.isStatic = false
    elseif info.order < 1 then
        self.isStatic = false
    else
        self.isStatic = true
    end

    self.texture = ""
    if self.isStatic then
        if self.trackMultiple then
            self.texture = select(3, GetSpellInfo(self.spellIDs[1]))
        else
            self.texture = select(3, GetSpellInfo(self.spellID or self.spellName))
        end
        self.icon:SetTexture(self.texture)
        self.icon:SetDesaturated(1)
    else
        self:Hide()
    end

    if info.checkKnown then
        self.checkKnown = info.checkKnown
    else
        self.checkKnown = (self.isStatic and not(self.isTrinket)) and true or false
    end

    self.hideOOC = info.hideOOC
    self.hideStacks = info.hideStacks
    self.hideTime = info.hideTime

    self.ignoreRaven = info.ignoreRaven

    -- TalentUpdate(f)
    -- AuraUpdate(f, nil, self.unit)
end

function api:Enable()
    self:RegisterUnitEvent("UNIT_AURA", self.unit)
    if self.unit == "target" then
        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif self.unit == "pet" then
        self:RegisterEvent("UNIT_PET")
    end
    self.isEnabled = true
end

function api:Disable()
    self:UnregisterAllEvents()
    self.isEnabled = false
end

-- Tooltips
local function OnLeave(self)
    if self.auraIndex then
        GameTooltip:Hide()
    end
end
local function OnEnter(self)
    if not self.activeSpellName then return end
    local buffFilter = (self.isBuff and "HELPFUL" or "HARMFUL") .. (self.anyone and "" or "|PLAYER")

    for i = 1, 40 do
        local name = UnitAura(self.unit, i, buffFilter)
        if name == self.activeSpellName then
            self.auraIndex = i
            break
        end
    end

    if self.auraIndex then
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnitAura(self.unit, self.auraIndex, buffFilter)
        GameTooltip:Show()
    end
end

-- Create Indicator frame
function AuraTracking:CreateAuraIcon(id, spellData)
    local side = spellData.unit == "target" and "left" or "right"
    local tracker = CreateFrame("Frame", nil, AuraTracking[side])
    tracker.side = side
    tracker.id = id

    local cd = CreateFrame("Cooldown", nil, tracker, "CooldownFrameTemplate")
    cd:SetAllPoints(tracker)
    tracker.cd = cd

    local icon = tracker:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(tracker)
    icon:SetTexture([[Interface/Icons/Inv_Misc_QuestionMark]])
    tracker.icon = icon

    local bg = F.ReskinIcon(icon)
    tracker.bg = bg

    local count = tracker:CreateFontString()
    count:SetFontObject(_G.RealUIFont_PixelCooldown)
    count:SetJustifyH("RIGHT")
    count:SetJustifyV("TOP")
    count:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", 1.5, 2.5)
    tracker.count = count

    tracker:SetScript("OnEnter", OnEnter)
    tracker:SetScript("OnLeave", OnLeave)
    tracker:SetScript("OnEvent", function(self, event, ...)
        events[event](self, ...)
    end)

    for key, func in next, api do
        tracker[key] = func
    end

    icons[tracker] = spellData

    tracker:SetIndicatorInfo(spellData)
    tracker:Hide()

    return tracker
end
