-- Lua Globals --
local _G = _G
local next = _G.next

-- WoW Globals --
local UIParent = _G.UIParent
local CreateFrame, UnitAura, GetSpellInfo = _G.CreateFrame, _G.UnitAura, _G.GetSpellInfo
local C_TimerAfter = _G.C_Timer.After

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
local debug = true

local maxSlots, maxStaticSlots = 10, 6
local numActive = {left = 0, right = 0}
local playerLevel, playerSpec

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

function AuraTracking:AddTracker(tracker, slotID)
    self:debug("AddTracker", tracker.id, tracker.slotID)
    local numActive = numActive[tracker.side]
    if tracker.slotID then
        if tracker.order > 0 then
            tracker.icon:SetDesaturated(false)
            numActive = numActive + 1
        end
    else
        numActive = numActive + 1
        local side, slot = self[tracker.side]
        if slotID then
            slot = side["slot"..slotID]
        elseif tracker.order > 0 then
            slot = side["slot"..tracker.order]
            tracker.slotID = tracker.order
        else
            for slotID = 1, maxSlots do
                slot = side["slot"..slotID]
                if not slot.isActive then
                    tracker.slotID = slotID
                    break
                end
            end
        end
        slot.tracker = tracker
        slot.isActive = true
        tracker:SetAllPoints(slot)
        tracker:Show()
    end
end
function AuraTracking:RemoveTracker(tracker, isStatic)
    self:debug("RemoveTracker", tracker.id)
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

        local nextSlot = side["slot"..emptySlot+1]
        if nextSlot.isActive then
            local movedTracker = nextSlot.tracker
            self:RemoveTracker(movedTracker)
            self:AddTracker(movedTracker, emptySlot)
        end

        --[[ 
        for slotID = emptySlot, maxSlots do
            local nextSlot = side["slot"..slotID+1]
            if nextSlot.isActive then
                currSlot.tracker = nextSlot.tracker
                currSlot.isActive = true

                nextSlot.tracker:ClearAllPoints()
                nextSlot.tracker:SetAllPoints(currSlot)
                nextSlot.tracker.slotID = slotID

                nextSlot.tracker = nil
                nextSlot.isActive = false
            end
        end
        --]]
    end
end

function AuraTracking:UpdateVisibility()
    local targetCondition = db.visibility.showHostile and self.targetHostile
    local pvpCondition = db.visibility.showPvP and self.inPvP
    local pveCondition = db.visibility.showPvE and self.inPvE
    local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

    if self.configMode or targetCondition or pvpCondition or pveCondition or combatCondition then
        self.left:Show()
        self.right:Show()
    else
        self.left:SetShown(numActive["left"] > 0)
        self.right:Hide()
    end
end
function AuraTracking:RefreshMod()
    playerLevel = _G.UnitLevel("player")
    playerSpec = _G.GetSpecialization()

    self:UpdateVisibility()
end

-- Events --
function AuraTracking:PLAYER_LOGIN()
    self:debug("PLAYER_LOGIN")
    self:RefreshMod()
    self.loggedIn = true
end
function AuraTracking:PLAYER_ENTERING_WORLD()
    self:debug("PLAYER_ENTERING_WORLD")
    self.playerGUID = _G.UnitGUID("player")
    if _G.UnitAffectingCombat("player") then
        self.inCombat = true
    else
        self.inCombat = false
    end

    self.targetHostile = false

    C_TimerAfter(1, function()
        local _, instanceType = _G.GetInstanceInfo()
        if instanceType ~= "none" then
            self.inPvP = false
            self.inPvE = false
        elseif (instanceType == "pvp") or (instanceType == "arena") then
            self.inPvP = true
            self.inPvE = false
        elseif (instanceType == "party") or (instanceType == "raid") or (instanceType == "scenario") then
            self.inPvE = true
            self.inPvP = false
        end
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
        AuraTracking:EnableUnit(unit)
    else
        AuraTracking:DisableUnit(unit)
    end
    self:UpdateVisibility()
end
function AuraTracking:CharacterUpdate(units)
    self:debug("CharacterUpdate", units.player)
    if units.player then
        playerLevel = _G.UnitLevel("player")
        playerSpec = _G.GetSpecialization()

        for tracker in self:IterateTrackers() do
            for i = 1, #tracker.specs do
                if tracker.specs[playerSpec] and tracker.minLevel <= playerLevel then
                    if not tracker.isEnabled then
                        tracker:Enable()
                    end
                elseif tracker.isEnabled then
                    tracker:Disable()
                end
            end
        end
    end
end


-- Init --
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
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetAndPetUpdate", "target")
    self:RegisterEvent("UNIT_PET", "TargetAndPetUpdate", "pet")

    local CharUpdateEvents = {
        "ACTIVE_TALENT_GROUP_CHANGED",
        "PLAYER_SPECIALIZATION_CHANGED",
        "PLAYER_TALENT_UPDATE",
        "PLAYER_LEVEL_UP",
    }

    self:RegisterBucketEvent(CharUpdateEvents, 0.1, "CharacterUpdate")

    if not self.left then
        self:Createslots()
    end

    for trackerID, spellData in next, trackingData do
        local classID, id, isDefault = _G.strsplit("-", trackerID)
        local tracker = self:CreateAuraIcon(id, spellData)
        tracker.classID = classID
        tracker.isDefault = isDefault and true or false
        if tracker.unit == "player" then
            tracker:Enable()
        end
    end

    if self.loggedIn then self:RefreshMod() end
    self.configMode = false
end

function AuraTracking:OnDisable()

end
