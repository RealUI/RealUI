-- Lua Globals --
local _G = _G
local next = _G.next

-- WoW Globals --
local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb, trackingData
local round = nibRealUI.Round

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:GetModule(MODNAME)

local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b
local LibWin = LibStub("LibWindow-1.1")

local maxSlots, maxStaticSlots = 10, 6
local activeTrackers = {left = {}, right = {}}
local slots = {left = {}, right = {}}

function AuraTracking:Createslots()
    for sideID, side in next, slots do
        local parent = CreateFrame("Frame", nil, UIParent)
        LibWin:Embed(parent)
        parent:SetSize(db.style.slotSize * maxStaticSlots, db.style.slotSize)
        parent:RegisterConfig(db.position[sideID])
        parent:RestorePosition()
        side.parent = parent

        ---[[ debug 
        local bg = parent:CreateTexture()
        local color = sideID == "left" and 1 or 0
        bg:SetTexture(color, color, color, 0.5)
        bg:SetAllPoints(parent)
        --]]

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

            local cd = CreateFrame("Cooldown", nil, slot)
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

-- Visibility --
function AuraTracking:UpdateVisibility()
    local targetCondition = db.visibility.showHostile and self.targetHostile
    local pvpCondition = db.visibility.showPvP and self.inPvP
    local pveCondition = db.visibility.showPvE and self.inPvE
    local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

    for sideID, side in next, activeTrackers do
        self:debug("Iterate activeTrackers", sideID, #side)
        if #side > 0 then
            for slotID = 1, #side do
                local slot = side[slotID]
                slot:SetShown(self.configMode or targetCondition or pvpCondition or pveCondition or combatCondition)
            end
        end
    end
end

-- Events --
function AuraTracking:PLAYER_TARGET_CHANGED(skipUpdate)
    self.oldTargetHostile = self.targetHostile
    self.targetHostile = _G.UnitExists("target") and (_G.UnitIsEnemy("player", "target") or _G.UnitCanAttack("player", "target")) and not(UnitIsDeadOrGhost("target"))
    if not(skipUpdate) and (self.oldTargetHostile ~= self.targetHostile) then
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
    self:PLAYER_TARGET_CHANGED(true)
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
    --self:RefreshMod()
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
            tracking = self.Defaults,
        },
    })

    db = self.db.profile
    ndb = nibRealUI.db.profile
    trackingData = db.tracking[nibRealUI.class]

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

    self.configMode = false
end

function AuraTracking:OnDisable()

end
