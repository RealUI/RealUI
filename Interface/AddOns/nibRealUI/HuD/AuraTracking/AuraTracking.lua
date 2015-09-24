-- Lua Globals --
local _G = _G
local next, random, type = _G.next, _G.math.random, _G.type
local bit_band = _G.bit.band

-- WoW Globals --
local UIParent = _G.UIParent
local CreateFrame, UnitAura, GetSpellInfo = _G.CreateFrame, _G.UnitAura, _G.GetSpellInfo
local C_TimerAfter = _G.C_Timer.After
local COMBATLOG_FILTER_ME = _G.COMBATLOG_FILTER_ME

-- Libs --
local LibWin = LibStub("LibWindow-1.1")
local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local db, ndb, trackingData
local round = nibRealUI.Round

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:GetModule(MODNAME)
local debug = false

local maxSlots, maxStaticSlots = 10, 6
local numActive = {left = 0, right = 0}
local playerLevel, playerSpec, iterUnits
local isValidUnit = {
    player = true,
    target = false,
    pet = false
}

local function debug(isDebug, ...)
    if isDebug then
        -- self.debug should be a string describing what the bar is.
        -- eg. "playerHealth", "targetAbsorbs", etc
        AuraTracking:debug(isDebug, ...)
    end
end
local function FindSpellMatch(spell, unit, filter, isDebug)
    debug(isDebug, "FindSpellMatch", spell, unit, filter)
    local aura = {}
    for auraIndex = 1, 40 do
        local name, _, texture, count, _, duration, endTime, _, _, _, ID = UnitAura(unit, auraIndex, filter)
        debug(isDebug, "Aura", auraIndex, name, ID)
        if spell == name or spell == ID then
            aura.texture, aura.duration, aura.endTime, aura.index = texture, duration, endTime, auraIndex
            aura.name, aura.ID = name, ID
            aura.count = count > 0 and count or ""
            return true, aura
        end

        if name == nil then
            aura.index = auraIndex
            return false, aura
        end
    end
end
local function FindAura(spellID, unit, filter, isDebug)
    debug(isDebug, "FindSpellMatch", spellID, unit, filter)
    local aura = {}
    for auraIndex = 1, 40 do
        local name, _, texture, count, _, duration, endTime, _, _, _, ID = UnitAura(unit, auraIndex, filter)
        if name == nil then break end
        debug(isDebug, "Aura", auraIndex, name, ID)
        if spellID == ID then
            count = count > 0 and count or ""
            return auraIndex, texture, count, duration, endTime
        end

    end
end

function AuraTracking:AddTracker(tracker, slotID)
    self:debug("AddTracker", tracker.id, tracker.slotID, slotID)
    local numActive = numActive[tracker.side]
    if tracker.slotID then
        if tracker.isStatic then
            tracker.icon:SetDesaturated(false)
            numActive = numActive + 1
        end
    else
        numActive = numActive + 1
        local side, slot = self[tracker.side]
        if slotID then
            slot = side["slot"..slotID]
        else
            for i = 1, maxSlots do
                slot = side["slot"..i]
                if not slot.isActive then
                    slotID = i
                    break
                end
            end
        end
        slot.tracker = tracker
        slot.isActive = true

        tracker.slotID = slotID
        tracker:SetAllPoints(slot)
        tracker:Show()
    end
end
function AuraTracking:RemoveTracker(tracker, isStatic)
    self:debug("RemoveTracker", tracker.id, isStatic)
    local numActive = numActive[tracker.side]
    if isStatic then
        tracker.icon:SetDesaturated(true)
        numActive = numActive - 1
    else
        numActive = numActive - 1
        local side, emptySlot = self[tracker.side], tracker.slotID
        local currSlot = side["slot"..emptySlot]
        currSlot.tracker = nil
        currSlot.isActive = false

        tracker.slotID = nil
        tracker:ClearAllPoints()
        tracker:Hide()

        if iterUnits then return end
        local nextSlot = side["slot"..emptySlot+1]
        if nextSlot.isActive then
            local movedTracker = nextSlot.tracker
            self:RemoveTracker(movedTracker)
            self:AddTracker(movedTracker, emptySlot)
        end
    end
end
do -- AuraTracking:CreateNewTracker()
    local template = "yxxxxxxx"
    local function generateGUID()
        return _G.gsub(template, "[xy]", function (c)
            local v = (c == "x") and random(0, 0xf) or random(0, 7)
            return _G.format("%x", v)
        end)
    end
    function AuraTracking:CreateNewTracker()
        local newID
        repeat
            newID = generateGUID()
            local isDupe = false
            for trackerID, spellData in next, trackingData do
                local classID, id, isDefault = _G.strsplit("-", trackerID)
                if newID == id then
                    isDupe = true
                    break
                end
            end
        until not isDupe

        local newTrackerID = _G.format("%d-%s", nibRealUI.classID, newID)
        local tracker = self:CreateAuraIcon(newID, trackingData[newTrackerID])
        tracker.classID = nibRealUI.classID
        tracker.isDefault = false
        return newTrackerID
    end
end

function AuraTracking:UpdateVisibility()
    self:debug("UpdateVisibility")
    local visibility = db.visibility
    local targetCondition = visibility.showHostile and self.targetHostile
    local combatCondition = (visibility.showCombat and self.inCombat) or not(visibility.showCombat)
    local instType = self.inPvP and "PvP" or "PvE"

    if self.configMode then
        self.left:Show()
        self.right:Show()
    elseif self["in"..instType] then
        self.left:SetShown(visibility["show"..instType] and (combatCondition or targetCondition))
        self.right:SetShown(visibility["show"..instType] and targetCondition)
    else
        self.left:SetShown(targetCondition or numActive["left"] > 0)
        self.right:SetShown(targetCondition)
    end
end


-- Events --
function AuraTracking:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, subEvent, hideCaster, dstGUID, srcName, srcFlags, srcRaidFlags, dstGUID, dstName, dstFlags, dstRaidFlags, ...)
    local unit
    if dstGUID == self.playerGUID then
        unit = "player"
    elseif dstGUID == self.targetGUID then
        unit = "target"
    elseif dstGUID == self.petGUID then
        unit = "pet"
    end
    if unit then
        AuraTracking:debug("Combat Event", unit, subEvent, ...)
        if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent:find("DOSE") then
            local spellID, spellName, spellSchool, auraType, amount = ...
            AuraTracking:debug("Aura Applied", unit, ...)
            for tracker, spellData in AuraTracking:IterateTrackers() do
                if spellData.unit == unit and tracker.isEnabled then
                    local spell, spellMatch = spellData.spell, false
                    debug(spellData.debug, "IterateTrackers", tracker.id, spell)

                    if type(spell) == "table" then
                        for index = 1, #spell do
                            if spell == spellName or spell == spellID then
                                spellMatch = true
                            end
                            if spellMatch then break end
                        end
                    else
                        if spell == spellName or spell == spellID then
                            spellMatch = true
                        end
                    end

                    if spellMatch then
                        local auraIndex, texture, count, duration, endTime = FindAura(spellID, spellData.unit, tracker.filter, spellData.debug)
                        debug(spellData.debug, "Tracker", tracker.id, spell)
                        tracker.auraIndex = auraIndex
                        tracker.cd:Show()
                        tracker.cd:SetCooldown(endTime - duration, duration)
                        tracker.icon:SetTexture(texture)
                        tracker.count:SetText(count)
                        AuraTracking:AddTracker(tracker)
                    end
                    if self.postUnitAura then
                        self:postUnitAura(spellData, spellID)
                    end
                end
            end
        elseif subEvent == "SPELL_AURA_REMOVED" then
            local spellID, spellName, spellSchool, auraType, amount = ...
            AuraTracking:debug("Aura Removed", unit, spellID, spellName)
            for tracker, spellData in AuraTracking:IterateTrackers() do
                if spellData.unit == unit and tracker.isEnabled then
                    local spell, spellMatch = spellData.spell, false
                    debug(spellData.debug, "IterateTrackers", tracker.id, spell)

                    if type(spell) == "table" then
                        for index = 1, #spell do
                            if spell == spellName or spell == spellID then
                                spellMatch = true
                            end
                            if spellMatch then break end
                        end
                    else
                        if spell == spellName or spell == spellID then
                            spellMatch = true
                        end
                    end

                    if spellMatch then
                        tracker.cd:SetCooldown(0, 0)
                        tracker.cd:Hide()
                        tracker.count:SetText("")
                        AuraTracking:RemoveTracker(tracker, tracker.isStatic)
                    end
                    if self.postUnitAura then
                        self:postUnitAura(spellData, spellID)
                    end
                end
            end
        end
    end
end
function AuraTracking:UNIT_AURA(event, unit)
    AuraTracking:debug("UNIT_AURA", unit)
    if not isValidUnit[unit] then return end

    for tracker, spellData in AuraTracking:IterateTrackers() do
        if spellData.unit == unit and tracker.isEnabled then
            local spell, spellMatch, aura = spellData.spell, false, {}
            debug(spellData.debug, "IterateTrackers", tracker.id, spell)

            if type(spell) == "table" then
                for index = 1, #spell do
                    spellMatch, aura = FindSpellMatch(spell[index], spellData.unit, tracker.filter, spellData.debug)
                    if spellMatch then break end
                end
            else
                spellMatch, aura = FindSpellMatch(spell, spellData.unit, tracker.filter, spellData.debug)
            end

            if spellMatch then
                debug(spellData.debug, "Tracker", tracker.id, spell)
                tracker.auraIndex = aura.index
                tracker.cd:Show()
                tracker.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
                tracker.icon:SetTexture(aura.texture)
                tracker.count:SetText(aura.count)
                AuraTracking:AddTracker(tracker)
            elseif tracker.slotID then
                tracker.auraIndex = aura.index
                tracker.cd:SetCooldown(0, 0)
                tracker.cd:Hide()
                tracker.count:SetText("")
                AuraTracking:RemoveTracker(tracker, tracker.isStatic)
            end
            if self.postUnitAura then
                self:postUnitAura(spellData, aura.ID)
            end
        end
    end
end

function AuraTracking:PLAYER_LOGIN()
    self:debug("PLAYER_LOGIN")
    self:RefreshMod()
    for trackerID, spellData in next, trackingData do
        local classID, id, isDefault = _G.strsplit("-", trackerID)
        self:debug("Init tracker", classID, id, isDefault)
        local tracker = self:CreateAuraIcon(id, spellData)
        tracker.classID = classID
        tracker.isDefault = isDefault and true or false
        if spellData.specs[playerSpec] and spellData.minLevel <= playerLevel then
            tracker.shouldTrack = true
            if spellData.unit == "player" then
                tracker:Enable()
            end
        end
    end
    self.loggedIn = true
end
function AuraTracking:PLAYER_ENTERING_WORLD()
    self:debug("PLAYER_ENTERING_WORLD")
    self.playerGUID = _G.UnitGUID("player")
    self.petGUID = _G.UnitGUID("pet")
    if _G.UnitAffectingCombat("player") then
        self.inCombat = true
    else
        self.inCombat = false
    end

    self.targetHostile = false

    C_TimerAfter(1, function()
        local instanceName, instanceType = _G.GetInstanceInfo()
        self:debug("UpdateLocation", instanceName, instanceType)
        if instanceType == "none" or instanceName:find("Garrison") then
            self.inPvP = false
            self.inPvE = false
        elseif (instanceType == "pvp") or (instanceType == "arena") then
            self.inPvP = true
            self.inPvE = false
        elseif (instanceType == "party") or (instanceType == "raid") or (instanceType == "scenario") then
            self.inPvP = false
            self.inPvE = true
        end
        self:UpdateVisibility()
    end)
end

function AuraTracking:PLAYER_REGEN_ENABLED()
    self:debug("PLAYER_REGEN_ENABLED")
    self.inCombat = false
end
function AuraTracking:PLAYER_REGEN_DISABLED()
    self:debug("PLAYER_REGEN_DISABLED")
    self.inCombat = true
end

function AuraTracking:TargetAndPetUpdate(unit, event, ...)
    self:debug("TargetAndPetUpdate", unit, event, ...)
    local unitExists = _G.UnitExists(unit)
    if unit == "target" then
        self.targetHostile = unitExists and _G.UnitCanAttack("player", "target") and not _G.UnitIsDeadOrGhost("target")
    end
    if unitExists then
        self[unit.."GUID"] = _G.UnitGUID(unit)
        if isValidUnit[unit] then return end
        self:debug("EnableUnit", unit)
        isValidUnit[unit] = true
        for tracker, spellData in self:IterateTrackers() do
            if spellData.unit == unit and tracker.shouldTrack and not tracker.isEnabled then
                tracker:Enable()
            end
        end
        self:UNIT_AURA("FORCED_UNIT_AURA", unit)
    else
        iterUnits = true
        if not isValidUnit[unit] then return end
        self:debug("DisableUnit", unit)
        isValidUnit[unit] = false
        for tracker, spellData in self:IterateTrackers() do
            if spellData.unit == unit and tracker.isEnabled then
                tracker:Disable()
            end
        end
        iterUnits = false
    end
    self:UpdateVisibility()
end
function AuraTracking:CharacterUpdate(units)
    self:debug("CharacterUpdate", units.player)
    if units.player then
        playerLevel = _G.UnitLevel("player")
        playerSpec = _G.GetSpecialization()

        for tracker, spellData in self:IterateTrackers() do
            tracker:Disable()
            for i = 1, #spellData.specs do
                if spellData.specs[playerSpec] and spellData.minLevel <= playerLevel then
                    tracker.shouldTrack = true
                    tracker:Enable()
                    break
                else
                    tracker.shouldTrack = false
                end
            end
        end
    end
end


-- Init --
function AuraTracking:Createslots()
    for i, side in next, {"left", "right"} do
        local parent = CreateFrame("Frame", "AuraTracker"..side, UIParent)
        LibWin:Embed(parent)
        parent:SetSize(db.style.slotSize * maxStaticSlots, db.style.slotSize)
        parent:RegisterConfig(db.position[side])
        parent:RestorePosition()
        self[side] = parent

        if debug then
            local bg = parent:CreateTexture()
            local color = side == "left" and 1 or 0
            bg:SetTexture(color, color, color, 0.5)
            bg:SetAllPoints(parent)
        end

        local point = side == "left" and "RIGHT" or "LEFT"
        local xMod = side == "left" and -1 or 1
        for slotID = 1, maxSlots do
            local slot = CreateFrame("Frame", nil, parent)
            slot:SetSize(db.style.slotSize, db.style.slotSize)
            if slotID == 1 then
                slot:SetPoint(point, parent, 0, 0)
            else
                slot:SetPoint(point, parent["slot"..slotID - 1], _G.strupper(side), (db.style.padding + 2) * xMod, 0)
            end
            parent["slot"..slotID] = slot

            F.CreateBD(slot)

            local count = slot:CreateFontString()
            count:SetFontObject(_G.RealUIFont_PixelCooldown)
            count:SetJustifyH("RIGHT")
            count:SetJustifyV("TOP")
            count:SetPoint("TOPRIGHT", slot, "TOPRIGHT", 1.5, 2.5)
            count:SetText(slotID)
            slot.count = count

            slot:SetAlpha(0)
        end
    end
end

function AuraTracking:ToggleConfigMode(val)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end
    self.configMode = val

    for _, side in next, {"left", "right"} do
        for slotID = 1, maxStaticSlots do
            local slot = self[side]["slot"..slotID]
            slot:SetAlpha(val and 1 or 0)
        end
    end
end

function AuraTracking:RefreshMod()
    playerLevel = _G.UnitLevel("player")
    playerSpec = _G.GetSpecialization()

    self:UpdateVisibility()
end
function AuraTracking:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        class = self.Defaults[nibRealUI.class],
        profile = {
            position = {
                left = {
                    x = -98, -- ((db.style.slotSize * maxStaticSlots) / 2) + 2
                    y = -128,
                    point = "CENTER",
                },
                right = {
                    x = 98,
                    y = -128,
                    point = "CENTER",
                },
            },
            style = {
                slotSize = 32,
                padding = 1,
            },
            visibility = {
                showCombat = true,
                showHostile = true,
                showPvE = false,
                showPvP = false,
            },
            indicators = {
                fadeInactive = true,
                fadeOpacity = 0.75,
                useCustomCD = true,
            },
        },
    })

    db = self.db.profile
    ndb = nibRealUI.db.profile
    trackingData = self.db.class
    self.Defaults = nil

    if db.tracking then
        db.tracking = nil
    end

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterConfigModeModule(self)
end

function AuraTracking:OnEnable()
    self:debug("OnEnable")
    self:RegisterEvent("UNIT_AURA")
    --self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetAndPetUpdate", "target")
    self:RegisterEvent("UNIT_PET", "TargetAndPetUpdate", "pet")
    self:RegisterBucketEvent({
        "ACTIVE_TALENT_GROUP_CHANGED",
        "PLAYER_SPECIALIZATION_CHANGED",
        "PLAYER_TALENT_UPDATE",
        "PLAYER_LEVEL_UP",
    }, 0.1, "CharacterUpdate")

    if not self.left then
        self:Createslots()
    end

    if self.loggedIn then self:RefreshMod() end
    self.configMode = false
end

function AuraTracking:OnDisable()

end
