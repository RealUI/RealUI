-- Lua Globals --
local _G = _G
local next, random, type = _G.next, _G.math.random, _G.type
local bit_band, tinsert = _G.bit.band, _G.table.insert

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
            debug(isDebug, "Match found")
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
local function shouldTrack(spellData)
    local isDebug = spellData.debug
    if spellData.specs[playerSpec] and spellData.minLevel <= playerLevel and spellData.shouldLoad then
        local talent = spellData.talent
        debug(isDebug, "Check for talents", talent.mustHave)
        if talent.ID then
            local _, talentID = _G.GetTalentRowSelectionInfo(talent.tier)
            AuraTracking:debug("Find talent", talent.tier, talent.ID, talentID)
            if talent.mustHave then
                debug(isDebug, "Must have")
                return talent.ID == talentID
            else
                debug(isDebug, "Must not have")
                return talent.ID ~= talentID
            end
        else
            debug(isDebug, "Do Track")
            return true
        end
    else
        debug(isDebug, "Don't Track")
        return false
    end
end
local function AddToSpellList(spellData, spellList)
    local spell = spellData.spell
    if type(spell) == "table" then
        for index = 1, #spell do
            tinsert(spellList, spell[index])
        end
    else
        tinsert(spellList, spell)
    end
end

function AuraTracking:AddTracker(tracker, slotID)
    self:debug("AddTracker", tracker.id, tracker.slotID, slotID)
    local numActive = numActive[tracker.side]
    if tracker.slotID then
        if tracker.isStatic then
            tracker.icon:SetDesaturated(false)
            tracker:SetAlpha(1)
            numActive = numActive + 1
        end
    else
        numActive = numActive + 1
        local side, slot = self[tracker.side]
        if slotID then
            self:debug("Place in slot", slotID)
            slot = side["slot"..slotID]
        else
            self:debug("Find empty slot")
            for i = 1, maxSlots do
                slot = side["slot"..i]
                if not slot.isActive then
                    self:debug("Found slot", slotID)
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
        tracker:SetAlpha(db.indicators.fadeOpacity)
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
            self:debug("Shift", movedTracker.id, movedTracker.isStatic, emptySlot)
            self:RemoveTracker(movedTracker, movedTracker.isStatic)
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
        return tracker, trackingData[newTrackerID]
    end
end

function AuraTracking:UpdateVisibility()
    self:debug("UpdateVisibility")
    local visibility = db.visibility
    local targetCondition = visibility.showHostile and self.targetHostile
    local combatCondition = (visibility.showCombat and self.inCombat) or not(visibility.showCombat)
    local instType = self.inPvP and "PvP" or "PvE"
    self:debug("targetCondition", visibility.showHostile, self.targetHostile, targetCondition)
    self:debug("combatCondition", visibility.showCombat, self.inCombat, combatCondition)
    self:debug("instType", self.inPvP, self.inPvE, instType)

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
function AuraTracking:Lock()
    if not db.locked then
        db.locked = true
        for i, side in next, {"left", "right"} do
            local parent = self[side]
            parent:EnableMouse(false)
            parent.bg:Hide()
        end
    end
    if not nibRealUI.isInTestMode then
        self:ToggleConfigMode(false)
    end
end
function AuraTracking:Unlock()
    if db.locked then
        db.locked = false
        for i, side in next, {"left", "right"} do
            local parent = self[side]
            parent:EnableMouse(true)
            parent.bg:Show()
        end
    end
    if not nibRealUI.isInTestMode then
        self:ToggleConfigMode(true)
    end
end
function AuraTracking:SettingsUpdate(event)
    if event == "slotSize" then
        local size = db.style.slotSize - 2
        for _, side in next, {"left", "right"} do
            for slotID = 1, maxSlots do
                local slot = self[side]["slot"..slotID]
                slot:SetSize(size, size)
            end
        end
    elseif event == "padding" then
        local padding = db.style.padding
        for _, side in next, {"left", "right"} do
            local point = side == "left" and "RIGHT" or "LEFT"
            local xMod = side == "left" and -1 or 1
            for slotID = 1, maxSlots do
                local parent = self[side]
                local slot = parent["slot"..slotID]
                if slotID == 1 then
                    slot:SetPoint(point, parent, 0, 0)
                else
                    slot:SetPoint(point, parent["slot"..slotID - 1], _G.strupper(side), (padding + 2) * xMod, 0)
                end
            end
        end
    elseif event == "fadeOpacity" then
        local fadeOpacity = db.indicators.fadeOpacity
        for _, side in next, {"left", "right"} do
            for slotID = 1, maxSlots do
                local slot = self[side]["slot"..slotID]
                if slot.tracker then
                    slot.tracker:SetAlpha(db.indicators.fadeOpacity)
                end
            end
        end
    elseif event == "position" then
        for _, side in next, {"left", "right"} do
            local parent = self[side]
            parent:RestorePosition()
        end
    end
end


-- Events --
function AuraTracking:UNIT_AURA(event, unit)
    if not isValidUnit[unit] then return end
    AuraTracking:debug("UNIT_AURA", unit)

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
            debug(spellData.debug, "postUnitAura", tracker.postUnitAura)
            if tracker.postUnitAura then
                tracker:postUnitAura(spellData)
            end
        end
    end
end

function AuraTracking:PLAYER_LOGIN()
    self:debug("PLAYER_LOGIN")
    self:RefreshMod()
    local playerSpellList = {}
    for trackerID, spellData in next, trackingData do
        local classID, id, isDefault = _G.strsplit("-", trackerID)
        self:debug("|c"..id.."Init tracker|r ", id, isDefault)
        local tracker = self:CreateAuraIcon(id, spellData)
        tracker.classID = classID
        tracker.isDefault = isDefault and true or false
        tracker.shouldTrack = shouldTrack(spellData)
        if tracker.shouldTrack and spellData.unit == "player" then
            tracker:Enable()
            tracker:SetAlpha(db.indicators.fadeOpacity)
            AddToSpellList(spellData, playerSpellList)
        end
    end
    _G.Raven:RegisterSpellList("PlayerExclusions", playerSpellList, true)
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
    local targetSpellList
    if unit == "target" then
        targetSpellList = {}
        self.targetHostile = unitExists and _G.UnitCanAttack("player", "target") and not _G.UnitIsDeadOrGhost("target")
    end
    if unitExists then
        self[unit.."GUID"] = _G.UnitGUID(unit)
        if not isValidUnit[unit] then
            self:debug("EnableUnit", unit)
            isValidUnit[unit] = true
            for tracker, spellData in self:IterateTrackers() do
                if spellData.unit == unit and tracker.shouldTrack and not tracker.isEnabled then
                    tracker:Enable()
                    if targetSpellList then
                        AddToSpellList(spellData, targetSpellList)
                    end
                end
            end
            self:UNIT_AURA("FORCED_UNIT_AURA", unit)
            if targetSpellList then
                _G.Raven:RegisterSpellList("TargetExclusions", targetSpellList, true)
            end
        end
    elseif isValidUnit[unit] then
        iterUnits = true
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
function AuraTracking:CharacterUpdate(units, force)
    self:debug("CharacterUpdate", units.player, force)
    local newPlayerLevel = _G.UnitLevel("player")
    local newPlayerSpec = _G.GetSpecialization()
    if units.player and (newPlayerLevel ~= playerLevel or newPlayerSpec ~= playerSpec) or force then
        playerLevel, playerSpec = newPlayerLevel, newPlayerSpec
        self:debug("Level", playerLevel, "Spec", playerSpec)

        local playerSpellList = {}
        for tracker, spellData in self:IterateTrackers() do
            tracker:Disable() -- Reset incase there are any auras still active
            tracker.shouldTrack = shouldTrack(spellData)
            if tracker.shouldTrack then
                self:debug("Track", tracker.id)
                tracker:Enable()
                AddToSpellList(spellData, playerSpellList)
            else
                self:debug("Don't Track", tracker.id)
            end
        end
        _G.Raven:RegisterSpellList("PlayerExclusions", playerSpellList, true)
    end
end


-- Init --
function AuraTracking:Createslots()
    for i, side in next, {"left", "right"} do
        local parent = CreateFrame("Frame", "AuraTracker"..side, UIParent)
        parent:SetSize(db.style.slotSize * maxStaticSlots, db.style.slotSize)
        self[side] = parent

        LibWin:Embed(parent)
        parent:RegisterConfig(db.position[side])
        parent:RestorePosition()
        parent:SetMovable(true)
        parent:RegisterForDrag("LeftButton")
        parent:SetScript("OnDragStart", function(...)
            LibWin.OnDragStart(...)
        end)
        parent:SetScript("OnDragStop", function(...)
            LibWin.OnDragStop(...)
        end)

        local bg = parent:CreateTexture()
        local color = i - 1
        bg:SetTexture(color, color, color, 0.5)
        bg:SetAllPoints(parent)
        bg:Hide()
        parent.bg = bg

        local point = side == "left" and "RIGHT" or "LEFT"
        local xMod = side == "left" and -1 or 1
        local size = db.style.slotSize - 2
        for slotID = 1, maxSlots do
            local slot = CreateFrame("Frame", nil, parent)
            slot:SetSize(size, size)
            if slotID == 1 then
                slot:SetPoint(point, parent, 0, 0)
            else
                slot:SetPoint(point, parent["slot"..slotID - 1], _G.strupper(side), (db.style.padding + 2) * xMod, 0)
            end
            parent["slot"..slotID] = slot

            F.CreateBG(slot)

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
            if slot.tracker then
                slot.tracker:EnableMouse(not val)
            end
        end
    end
    self:UpdateVisibility()
end

function AuraTracking:RefreshMod()
    playerLevel = _G.UnitLevel("player")
    playerSpec = _G.GetSpecialization()
    self:debug("Level", playerLevel, "Spec", playerSpec)

    self:UpdateVisibility()
end
function AuraTracking:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        class = self.Defaults[nibRealUI.class],
        profile = {
            locked = true,
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
                showPvE = true,
                showPvP = true,
            },
            indicators = {
                fadeInactive = true,
                fadeOpacity = 0.75,
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

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetAndPetUpdate", "target")
    self:RegisterEvent("UNIT_PET", "TargetAndPetUpdate", "pet")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "CharacterUpdate", "talents")
    self:RegisterBucketEvent({
        "ACTIVE_TALENT_GROUP_CHANGED",
        "PLAYER_SPECIALIZATION_CHANGED",
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
