-- Lua Globals --
local _G = _G
local next = _G.next

-- WoW Globals --
local UIParent = _G.UIParent
local CreateFrame, UnitAura, GetSpellInfo = _G.CreateFrame, _G.UnitAura, _G.GetSpellInfo

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb, trackingData
local round = nibRealUI.Round

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:GetModule(MODNAME)
local debug = true

-- Libs --
local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b
local LibWin = LibStub("LibWindow-1.1")


local maxSlots, maxStaticSlots = 10, 6
local activeSlots = {left = {}, right = {}}
local slots = {left = {}, right = {}}

local activeSpells = {left = {}, right = {}}
local playerLevel, playerSpec

-- Utils --
function AuraTracking:Createslots()
    for sideID, side in next, slots do
        local parent = CreateFrame("Frame", nil, UIParent)
        LibWin:Embed(parent)
        parent:SetSize(db.style.slotSize * maxStaticSlots, db.style.slotSize)
        parent:RegisterConfig(db.position[sideID])
        parent:RestorePosition()
        side.parent = parent

        if debug then
            local bg = parent:CreateTexture()
            local color = sideID == "left" and 1 or 0
            bg:SetTexture(color, color, color, 0.5)
            bg:SetAllPoints(parent)
        end

        local point = sideID == "left" and "RIGHT" or "LEFT"
        local xMod = sideID == "left" and -1 or 1
        for slotID = 1, maxSlots do
            local slot = CreateFrame("Frame", nil, parent)
            slot:SetSize(db.style.slotSize, db.style.slotSize)
            if slotID == 1 then
                slot:SetPoint(point, parent, 0, 0)
            else
                slot:SetPoint(point, side[slotID - 1], _G.strupper(sideID), (db.style.padding + 2) * xMod, 0)
            end
            side[slotID] = slot

            local cd = CreateFrame("Cooldown", nil, slot, "CooldownFrameTemplate")
            cd:SetAllPoints(slot)
            slot.cd = cd

            local icon = slot:CreateTexture(nil, "BACKGROUND")
            icon:SetAllPoints(slot)
            icon:SetTexture([[Interface/Icons/Inv_Misc_QuestionMark]])
            slot.icon = icon

            local bg = F.ReskinIcon(icon)
            slot.bg = bg

            local count = slot:CreateFontString()
            count:SetFontObject(_G.RealUIFont_PixelCooldown)
            count:SetJustifyH("RIGHT")
            count:SetJustifyV("TOP")
            count:SetPoint("TOPRIGHT", slot, "TOPRIGHT", 1.5, 2.5)
            slot.count = count

            slot:Hide()
        end
    end

    function AuraTracking_MoveTrackers()
        
    end

    --self:UpdateStyle()
end

function AuraTracking:UpdateVisibility()
    local targetCondition = db.visibility.showHostile and self.targetHostile
    local pvpCondition = db.visibility.showPvP and self.inPvP
    local pveCondition = db.visibility.showPvE and self.inPvE
    local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

    for sideID, side in next, activeSlots do
        self:debug("Iterate activeSlots", sideID, #side)
        if #side > 0 then
            for slotID = 1, #side do
                local slot = side[slotID]
                if slot.hasAura then
                    slot:SetShown(self.configMode or targetCondition or pvpCondition or pveCondition or combatCondition)
                else
                    slot:Hide()
                end
            end
        end
    end
end

local function UpdateSpellStatus(spellData, id)
    local isActive = true
    -- Check level
    AuraTracking:debug("level", spellData.minLevel, playerLevel)
    if spellData.minLevel and spellData.minLevel > playerLevel then
        isActive = false
    end

    -- Check spec
    AuraTracking:debug("spec", spellData.specs[playerSpec], playerSpec)
    if not spellData.specs[playerSpec] then
        isActive = false
    end

    local side = spellData.unit == "target" and "right" or "left"
    AuraTracking:debug("UpdateSpellStatus", isActive, side, id)
    if isActive then
        activeSpells[side][id] = spellData
    else
        activeSpells[side][id] = nil
    end
end

function AuraTracking:SetupSpellData()
    if not trackingData then return end
    for i = 1, #trackingData do
        local spellData = trackingData[i]

        if not spellData.unit then
            if spellData.auraType == "debuff" then
                spellData.unit = "target"
            else
                spellData.unit = "player"
            end
        end

        if spellData.specs then
            local numSpecs = 0
            for i = 1, #spellData.specs do
                if spellData.specs[i] then
                    numSpecs = numSpecs + 1
                end
            end
            if numSpecs == #spellData.specs then
                spellData.useSpec = false
            elseif numSpecs == 1 then
                spellData.useSpec = true
            else
                spellData.useSpec = nil
            end
        else
            spellData.specs = {}
            spellData.useSpec = false
        end

        UpdateSpellStatus(spellData, i)
    end
end

local function GetAuraInfo(spellData, index)
    local spell = index and spellData.spell[index] or spellData.spell
    AuraTracking:debug("GetAuraInfo", spellData.unit, spell)
    local buffFilter = (spellData.auraType == "debuff" and "HARMFUL" or "HELPFUL") .. "|PLAYER"

    local _, spellName, duration, remaining, count, texture, endTime, spellID
    if spellData.deepScan then
        local i = 1 repeat
            spellName, _, texture, count, _, duration, endTime, _, _, _, spellID = UnitAura(spellData.unit, i, buffFilter)
            i = i + 1
        until (spell == spellID)
    else
        if tonumber(spell) then
            spell = GetSpellInfo(spell)
        end-- UnitAura("player", "Windwalking", nil, "HELPFUL")
        spellName, _, texture, count, _, duration, endTime, _, _, _, spellID = UnitAura(spellData.unit, spell, nil, buffFilter)
    end

    AuraTracking:debug("spell", spell, spellID, spellName)
    if (spell == spellID) or (spell == spellName) then
        if endTime then
            remaining = endTime - GetTime()
        end
        AuraTracking:debug("AuraInfo", spellName, duration, remaining, count, texture, endTime)
        return spellName, duration, remaining, count, texture, endTime
    end
end

local function ApplySpellToSlot(slot, spellData)
    local icon, _
    if type(spellData.spell) == "table" then
        _, _, icon = GetSpellInfo(spellData.spell[1])
    else
        _, _, icon = GetSpellInfo(spellData.spell)
    end

    slot.hasAura = true
    slot.icon:SetTexture(icon)
    slot.icon:SetDesaturated(true)

    slot:RegisterUnitEvent("UNIT_AURA", spellData.unit)
    if slot.unit == "target" then
        slot:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif slot.unit == "pet" then
        slot:RegisterEvent("UNIT_PET")
    end

    slot:SetScript("OnEvent", function(self, event, ...)
        AuraTracking:debug("Slot OnEvent", event, ...)
        local name, duration, remaining, count, texture, endTime
        if type(spellData.spell) == "table" then
            for index = 1, #spellData.spell do
                name, duration, remaining, count, texture, endTime = GetAuraInfo(spellData, index)
                if name then break end
            end
        else
            name, duration, remaining, count, texture, endTime = GetAuraInfo(spellData)
        end
        if endTime and duration > 0 then
            AuraTracking:debug("cooldown", GetTime(), endTime - duration, endTime, duration)
            self.cd:Show()
            self.cd:SetCooldown(endTime - duration, duration)
            self.icon:SetTexture(texture)
            self.icon:SetDesaturated(false)
        else
            self.cd:SetCooldown(0, 0)
            self.cd:Hide()
            self.icon:SetTexture(icon)
            self.icon:SetDesaturated(true)
        end
    end)
end

local function RemoveSpellFromSlot(slot, spellData)
    --
end

function AuraTracking:UpdateSlotAssignments()
    for sideID, side in next, activeSpells do
        self:debug("Iterate activeSpells", sideID, side)
        for ID, spellData in next, side do
            self:debug("Spell", spellData.spell)
            local _, _, icon = GetSpellInfo(spellData.spell)
            if spellData.order > 0 then
                local slot = slots[sideID][spellData.order]
                activeSlots[sideID][spellData.order] = slot
                ApplySpellToSlot(slot, spellData)
            end
        end
    end
end

function AuraTracking:RefreshMod()
    playerLevel = UnitLevel("player")
    playerSpec = GetSpecialization()

    self:SetupSpellData()
    self:UpdateSlotAssignments()
    self:UpdateVisibility()
end

-- Events --
function AuraTracking:PLAYER_TARGET_CHANGED(event)
    self:debug("PLAYER_TARGET_CHANGED", event)
    local oldTargetHostile = self.targetHostile
    self.targetHostile = _G.UnitExists("target") and (_G.UnitIsEnemy("player", "target") or _G.UnitCanAttack("player", "target")) and not(UnitIsDeadOrGhost("target"))
    if event and (oldTargetHostile ~= self.targetHostile) then
        self:UpdateVisibility()
    end
end

function AuraTracking:PLAYER_REGEN_DISABLED()
    self.inCombat = true
    self:UpdateVisibility()
end

function AuraTracking:PLAYER_REGEN_ENABLED()
    self.inCombat = false
    self:UpdateVisibility()
end

function AuraTracking:PLAYER_ENTERING_WORLD()
    self.playerGUID = _G.UnitGUID("player")
    --self:RefreshIndicatorStatus()
    self:PLAYER_TARGET_CHANGED()
    if _G.UnitAffectingCombat("player") then
        self.inCombat = true
    else
        self.inCombat = false
    end
    self:ScheduleTimer(function()
        local _, instanceType = GetInstanceInfo()
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
        self:UpdateVisibility()
    end, 1)
end

function AuraTracking:PLAYER_LOGIN()
    self:RefreshMod()
    self.loggedIn = true
end

-- Init --
function AuraTracking:ToggleConfigMode(val)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end
    self.configMode = val

    for sideID, side in next, slots do
        for slotID = 1, maxStaticSlots do
            local slot = side[slotID]
            slot.count:SetText(val and slotID or "")
            slot:SetShown(val)
        end
    end
end
function AuraTracking_ToggleConfigMode(val)
    AuraTracking:ToggleConfigMode(val)
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

    if db.tracking then
        db.tracking = nil
    end

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterConfigModeModule(self)
end

function AuraTracking:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    local CharUpdateEvents = {
        "ACTIVE_TALENT_GROUP_CHANGED",
        "PLAYER_SPECIALIZATION_CHANGED",
        "PLAYER_TALENT_UPDATE",
        "PLAYER_LEVEL_UP",
    }

    --self:RegisterBucketEvent(CharUpdateEvents, 0.1, "CharacterUpdate")

    if not slots.left.parent then
        self:Createslots()
    end

    if self.loggedIn then self:RefreshMod() end
    self.configMode = false
end

function AuraTracking:OnDisable()

end
