local _, private = ...

-- Lua Globals --
local _G = _G
local next, random, type = _G.next, _G.math.random, _G.type
local tinsert = _G.table.insert

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")
local F = _G.Aurora[1]

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, trackingData

local MODNAME = "AuraTracking"
local AuraTracking = RealUI:GetModule(MODNAME)

local MAX_SLOTS, MAX_STATIC_SLOTS = 10, 6
local activeTrackers = {left = 0, right = 0}
local playerLevel, playerSpec, iterUnits
local isValidUnit = {
    player = true,
    target = false,
    pet = false
}

local debug = AuraTracking.trackerDebug

local function FindSpellMatch(spellNameOrID, unit, filter, isDebug)
    debug(isDebug, "FindSpellMatch", spellNameOrID, unit, filter)
    local aura = {}
    for auraIndex = 1, 40 do
        local name, _, texture, count, _, duration, endTime, _, _, _, ID = _G.UnitAura(unit, auraIndex, filter)
        debug(isDebug, "Aura", auraIndex, name, ID)
        local spell
        if type(spellNameOrID) == "table" then
            for index = 1, #spellNameOrID do
                spell = spellNameOrID[index]
                if spell == name or spell == ID then break end
            end
        else
            spell = spellNameOrID
        end


        if name == nil then
            aura.index = auraIndex
            return false, aura
        elseif (spell == name or spell == ID) then
            debug(isDebug, "Match found")
            aura.texture, aura.duration, aura.endTime, aura.index = texture, duration, endTime, auraIndex
            aura.name, aura.ID = name, ID
            aura.count = count > 0 and count or ""
            return true, aura
        end
    end
end

local function GetShouldTrack(spellData)
    local isDebug = spellData.debug
    debug(isDebug, "shouldTrack", spellData.specs[playerSpec], spellData.minLevel, spellData.shouldLoad)
    if spellData.specs[playerSpec] and spellData.minLevel <= playerLevel and spellData.shouldLoad then
        local talent = spellData.talent
        debug(isDebug, "Check for talents", talent.mustHave)
        if talent.column or talent.ID then
            local _, selectedTalent = _G.GetTalentTierInfo(talent.tier, 1)
            local trackerTalent = talent.column or talent.ID
            if type(trackerTalent) == "table" then
                trackerTalent = trackerTalent[playerSpec]
            end
            AuraTracking:debug("Find talent", talent.tier, trackerTalent, selectedTalent)
            if talent.mustHave then
                debug(isDebug, "Must have")
                return trackerTalent == selectedTalent
            else
                debug(isDebug, "Must not have")
                return (trackerTalent or selectedTalent) ~= selectedTalent
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
    if spellData.noExclude then return end
    AuraTracking:debug("AddToSpellList", spellData.spell, spellList)
    local spell = spellData.spell
    if type(spell) == "table" then
        for index = 1, #spell do
            AuraTracking:debug("Spell", index, spell[index])
            tinsert(spellList, spell[index])
        end
    else
        AuraTracking:debug("Spell", spell)
        tinsert(spellList, spell)
    end
end
local function RegisterSpellList(unitExclusions, spellList)
    if _G.Raven then
        _G.Raven:RegisterSpellList(unitExclusions, spellList, true)
    end
end

do 
    local function AddTrackerToSlot(tracker, slot)
        AuraTracking:debug("AddTrackerToSlot", tracker.id, slot:GetID())
        slot.tracker = tracker
        slot:SetActive(true)

        tracker.slot = slot
        tracker:SetAllPoints(slot)
        tracker:Show()
    end
    local function RemoveTrackerFromSlot(tracker, slot)
        AuraTracking:debug("RemoveTrackerFromSlot", tracker.id, slot:GetID())
        slot.tracker = nil
        slot:SetActive(false)

        tracker.slot = nil
        tracker:ClearAllPoints()
        tracker:Hide()
    end

    function AuraTracking:AddTracker(tracker, enforceSlot)
        self:debug("AddTracker", tracker.id, tracker.slot and tracker.slot:GetID(), tracker.slotIDMax)
        if tracker.slot then
            if tracker.isStatic and not tracker.slot.isActive then
                tracker.icon:SetDesaturated(false)
                tracker:SetAlpha(1)
                tracker.slot:SetActive(true)
            end
        else
            local side, slot = self[tracker.side]
            local slotID = tracker.isStatic and tracker.slotIDMax
            if enforceSlot then
                self:debug("Place in slot", slotID)
                AddTrackerToSlot(tracker, side["slot"..slotID])
            else
                local maxSlots = slotID or MAX_SLOTS
                self:debug("Find first empty slot until:", maxSlots)
                for i = 1, maxSlots do
                    slot = side["slot"..i]
                    self:debug("Slot:", i, slot.tracker and slot.tracker.id)
                    if slot.tracker then
                        self:debug("Slot info:", slot.tracker.isStatic, slot.tracker.slotIDMax)
                        if (slot.tracker.slotIDMax > maxSlots) or (tracker.isStatic and not slot.tracker.isStatic) or (i == maxSlots and i < MAX_SLOTS) then
                            -- Make sure static trackers have priority placement on earlier slots
                            self:ShiftTracker(slot.tracker, i, i + 1)
                        end
                    end

                    if not slot.tracker then
                        self:debug("Found slot", i)
                        AddTrackerToSlot(tracker, slot)
                        break
                    end
                end
            end
        end
        if activeTrackers[tracker.side] > 0 then
            self:UpdateVisibility()
        end
    end
    function AuraTracking:RemoveTracker(tracker, isStatic)
        self:debug("RemoveTracker", tracker.id, isStatic)
        if isStatic then
            if tracker.slot.isActive then
                tracker.icon:SetDesaturated(true)
                tracker:SetAlpha(db.indicators.fadeOpacity)
                tracker.slot:SetActive(false)
            end
        else
            local side, emptySlot = self[tracker.side], tracker.slot:GetID()
            RemoveTrackerFromSlot(tracker, tracker.slot)

            if iterUnits then return end
            repeat
                emptySlot = emptySlot + 1
                local nextSlot = side["slot"..emptySlot]
                self:debug("Next Slot:", emptySlot, nextSlot.tracker)
                if nextSlot.tracker then
                    self:ShiftTracker(nextSlot.tracker, emptySlot, emptySlot - 1)
                end
            until not nextSlot.tracker
        end
        if activeTrackers[tracker.side] <= 0 then
            self:UpdateVisibility()
        end
    end
    function AuraTracking:ShiftTracker(tracker, fromSlotID, toSlotID)
        self:debug("Shift", tracker.id, tracker.isStatic, fromSlotID, toSlotID)
        local side = self[tracker.side]
        RemoveTrackerFromSlot(tracker, side["slot"..fromSlotID])
        if toSlotID <= MAX_SLOTS then
            local toSlot = side["slot"..toSlotID]
            if toSlot.isActive then
                self:ShiftTracker(toSlot.tracker, toSlotID, toSlotID + (toSlotID - fromSlotID))
            end
            AddTrackerToSlot(tracker, toSlot)
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
    function AuraTracking:CreateNewTracker(customSpellData)
        local newID
        repeat
            newID = generateGUID()
            local isDupe = false
            for trackerID in next, trackingData do
                local _, id = _G.strsplit("-", trackerID)
                if newID == id then
                    isDupe = true
                    break
                end
            end
        until not isDupe
        self:debug("CreateNewTracker", newID, customSpellData)

        local newTrackerID = _G.format("%d-%s", RealUI.classID, newID)
        if customSpellData then
            return self:CreateAuraIcon(newID, customSpellData)
        else
            local tracker = self:CreateAuraIcon(newID, trackingData[newTrackerID])
            tracker.classID = RealUI.classID
            tracker.isDefault = false
            return tracker, trackingData[newTrackerID]
        end
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
    self:debug("activeTrackers", activeTrackers["left"], activeTrackers["right"])

    if self.configMode or combatCondition then
        self.left:Show()
        self.right:Show()
    elseif self["in"..instType] then
        self.left:SetShown(visibility["show"..instType] and targetCondition)
        self.right:SetShown(visibility["show"..instType] and targetCondition)
    else
        self.left:SetShown(targetCondition or activeTrackers["left"] > 0)
        self.right:SetShown(targetCondition)
    end
end
function AuraTracking:Lock()
    if not db.locked then
        db.locked = true
        for _, side in next, {"left", "right"} do
            local parent = self[side]
            parent:EnableMouse(false)
            parent.bg:Hide()
            for slotID = 1, MAX_STATIC_SLOTS do
                local slot = self[side]["slot"..slotID]
                slot:SetAlpha(RealUI.isInTestMode and 1 or 0)
            end
        end
    end
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(false)
    end
end
function AuraTracking:Unlock()
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(true)
    end
    if db.locked then
        db.locked = false
        for _, side in next, {"left", "right"} do
            local parent = self[side]
            parent:EnableMouse(true)
            parent.bg:Show()
            for slotID = 1, MAX_STATIC_SLOTS do
                local slot = self[side]["slot"..slotID]
                slot:SetAlpha(0.2)
            end
        end
    end
end
function AuraTracking:SettingsUpdate(event)
    if event == "slotSize" then
        local size = db.style.slotSize - 2
        for _, side in next, {"left", "right"} do
            for slotID = 1, MAX_SLOTS do
                local slot = self[side]["slot"..slotID]
                slot:SetSize(size, size)
            end
        end
    elseif event == "padding" then
        local padding = db.style.padding
        for _, side in next, {"left", "right"} do
            local point = side == "left" and "RIGHT" or "LEFT"
            local xMod = side == "left" and -1 or 1
            for slotID = 1, MAX_SLOTS do
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
        for _, side in next, {"left", "right"} do
            for slotID = 1, MAX_SLOTS do
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
    self:debug("UNIT_AURA", event, unit)

    for tracker, spellData in self:IterateTrackers() do
        if spellData.unit == unit and tracker.isEnabled then
            local spell, hasAura, aura = spellData.spell
            debug(spellData.debug, "IterateTrackers", tracker.id, spell)

            hasAura, aura = FindSpellMatch(spell, spellData.unit, tracker.filter, spellData.debug)

            debug(spellData.debug, "do postUnitAura", tracker.postUnitAura)
            if tracker.postUnitAura then
                tracker:postUnitAura(spellData, aura, hasAura)
            elseif hasAura then
                debug(spellData.debug, "Tracker", tracker.id, spell)
                tracker.auraIndex = aura.index
                tracker.cd:Show()
                tracker.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
                tracker.icon:SetTexture(spellData.customIcon or aura.texture)
                if not spellData.hideStacks then
                    tracker.count:SetText(aura.count)
                end
                self:AddTracker(tracker)
            elseif tracker.slot then
                tracker.auraIndex = nil
                tracker.cd:SetCooldown(0, 0)
                tracker.cd:Hide()
                tracker.count:SetText("")
                self:RemoveTracker(tracker, tracker.isStatic)
            end
        end
    end
end

function AuraTracking:PLAYER_LOGIN()
    self:debug("PLAYER_LOGIN")
    self:RefreshMod()
    local playerSpellList = {}
    for trackerID, spellData in next, trackingData do
        if spellData.spell ~= L["AuraTrack_SpellNameID"] then
            local classID, id, isDefault = _G.strsplit("-", trackerID)
            self:debug("|c"..id.."Init tracker|r ", id, isDefault)
            local tracker = self:CreateAuraIcon(id, spellData)
            tracker.classID = classID
            tracker.isDefault = isDefault and true or false
            tracker.shouldTrack = GetShouldTrack(spellData)

            if tracker.shouldTrack and spellData.unit == "player" then
                tracker:Enable()
                tracker:SetAlpha(db.indicators.fadeOpacity)
                AddToSpellList(spellData, playerSpellList)
            end
        else
            self:debug("Empty tracker", trackerID)
            trackingData[trackerID] = nil
        end
    end
    RegisterSpellList("PlayerExclusions", playerSpellList)
    RegisterSpellList("PlayerDebuffExclusions", playerSpellList)
    self:UNIT_AURA("FORCED_UNIT_AURA", "player")
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

    _G.C_Timer.After(1, function()
        local instanceName, instanceType = _G.GetInstanceInfo()
        self:debug("UpdateLocation", instanceName, instanceType)
        self.inPvP, self.inPvE = false, false
        if not instanceName:find("Garrison") then
            if (instanceType == "pvp") or (instanceType == "arena") then
                self.inPvP = true
            elseif (instanceType == "party") or (instanceType == "raid") or (instanceType == "scenario") then
                self.inPvE = true
            end
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
    local unitExists, unitGUIDKey = _G.UnitExists(unit), unit.."GUID"
    local targetSpellList
    if unit == "target" then
        targetSpellList = {}
        self.targetHostile = unitExists and _G.UnitCanAttack("player", "target") and not _G.UnitIsDeadOrGhost("target")
    end
    if unitExists then
        local newGUID = _G.UnitGUID(unit)
        if self[unitGUIDKey] then
            if self[unitGUIDKey] ~= newGUID then
                self:debug("Unit Changed", unit, isValidUnit[unit])
            end
        else
            self:debug("Unit Added", unit, isValidUnit[unit])
        end
        self[unitGUIDKey] = newGUID
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
            if targetSpellList then
                RegisterSpellList("TargetExclusions", targetSpellList)
            end
        end
        self:UNIT_AURA("FORCED_UNIT_AURA", unit)
    else
        self:debug("Unit Removed", unit, isValidUnit[unit])
        if isValidUnit[unit] then
            self:debug("DisableUnit", unit)
            iterUnits = true
            for tracker, spellData in self:IterateTrackers() do
                if spellData.unit == unit and tracker.isEnabled then
                    tracker:Disable()
                end
            end
            iterUnits = false
            self[unitGUIDKey] = nil
            isValidUnit[unit] = false
        end
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

        iterUnits = true
        self:debug("Disable all trackers")
        for tracker in self:IterateTrackers() do
            tracker:Disable()
        end
        iterUnits = false

        self:debug("Enable needed trackers")
        local playerSpellList = {}
        for tracker, spellData in self:IterateTrackers() do
            tracker.shouldTrack = GetShouldTrack(spellData)
            if tracker.shouldTrack then
                self:debug("Track", tracker.id)
                tracker:Enable()
                AddToSpellList(spellData, playerSpellList)
            else
                self:debug("Don't Track", tracker.id)
            end
        end
        RegisterSpellList("PlayerExclusions", playerSpellList)
        RegisterSpellList("PlayerDebuffExclusions", playerSpellList)
    end
end


-- Init --
function AuraTracking:Createslots()
    for i, side in next, {"left", "right"} do
        local parent = _G.CreateFrame("Frame", "AuraTracker"..side, _G.UIParent)
        parent:SetSize(db.style.slotSize * MAX_STATIC_SLOTS, db.style.slotSize)
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
        local color = i / 2
        bg:SetTexture(color, color, color, 0.5)
        bg:SetAllPoints(parent)
        bg:Hide()
        parent.bg = bg

        local point = side == "left" and "RIGHT" or "LEFT"
        local xMod = side == "left" and -1 or 1
        local size = db.style.slotSize - 2
        for slotID = 1, MAX_SLOTS do
            local slot = _G.CreateFrame("Frame", nil, parent)
            slot:SetSize(size, size)
            slot:SetID(slotID)
            if slotID == 1 then
                slot:SetPoint(point, parent, 0, 0)
            else
                slot:SetPoint(point, parent["slot"..slotID - 1], _G.strupper(side), (db.style.padding + 2) * xMod, 0)
            end
            parent["slot"..slotID] = slot

            F.CreateBG(slot)
            slot:SetAlpha(0)

            local count = slot:CreateFontString()
            count:SetFontObject(_G.RealUIFont_PixelCooldown)
            count:SetJustifyH("RIGHT")
            count:SetJustifyV("TOP")
            count:SetPoint("TOPRIGHT", slot, "TOPRIGHT", 1.5, 2.5)
            count:SetText(slotID)
            slot.count = count

            function slot.SetActive(s, isActive)
                if s.isActive ~= isActive then
                    s.isActive = isActive
                    if isActive then
                        activeTrackers[side] = activeTrackers[side] + 1
                    else
                        activeTrackers[side] = activeTrackers[side] - 1
                    end
                end
                self:debug("activeTrackers", side, activeTrackers[side])
            end
        end
    end
end

function AuraTracking:ToggleConfigMode(val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end
    self.configMode = val

    for _, side in next, {"left", "right"} do
        for slotID = 1, MAX_STATIC_SLOTS do
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
    self:debug("OnInitialize")
    local classTrackers = AuraTracking:SetupDefaultTracker()

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        class = classTrackers,
        profile = {
            locked = true,
            position = {
                left = {
                    x = -98, -- ((db.style.slotSize * MAX_STATIC_SLOTS) / 2) + 2
                    y = -150,
                    point = "CENTER",
                },
                right = {
                    x = 98,
                    y = -150,
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
    trackingData = self.db.class

    if db.tracking then
        db.tracking = nil
    end

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterConfigModeModule(self)
end

function AuraTracking:OnEnable()
    self:debug("OnEnable")
    self:RegisterEvent("UNIT_AURA")

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

    if self.loggedIn then
        self:RefreshMod()
    else
        self:RegisterEvent("PLAYER_LOGIN")
    end
    self.configMode = false
end

function AuraTracking:OnDisable()
    self:debug("OnDisable")

    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()

    for _, side in next, {"left", "right"} do
        self[side]:Hide()
    end
end
