-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- WoW Globals --
local UIParent, GameTooltip = _G.UIParent, _G.GameTooltip
local CreateFrame, GetTime = _G.CreateFrame, _G.GetTime
local UnitAura, GetSpellInfo = _G.UnitAura, _G.GetSpellInfo

-- Libs --
local F, C = _G.Aurora[1], _G.Aurora[2]
local r, g, b = C.r, C.g, C.b

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local round = nibRealUI.Round

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:GetModule(MODNAME)

local icons = {}
local isValidUnit = {
    player = true,
    target = false,
    pet = false
}

local function FindSpellMatch(spell, unit, filter)
    AuraTracking:debug("FindSpellMatch", spell, unit, filter)
    local aura = {}
    for auraIndex = 1, 40 do
        local name, _, texture, count, _, duration, endTime, _, _, _, ID = UnitAura(unit, auraIndex, filter)
        AuraTracking:debug("Aura", auraIndex, name, ID)
        if spell == name or spell == ID then
            aura.texture, aura.count, aura.duration, aura.endTime, aura.index = texture, count, duration, endTime, auraIndex
            return true, aura
        end

        if name == nil then
            aura.index = auraIndex
            return false, aura
        end
    end
end

local auras = CreateFrame("Frame")
auras:RegisterUnitEvent("UNIT_AURA")
auras:SetScript("OnEvent", function(self, event, unit)
    AuraTracking:debug("UNIT_AURA", unit)
    if not isValidUnit[unit] then return end

    for tracker in AuraTracking:IterateTrackers() do
        if tracker.unit == unit and tracker.isEnabled then
            local spell = icons[tracker].spell
            local spellMatch, aura = false
            AuraTracking:debug("IterateTrackers", tracker.id, spell)

            if type(spell) == "table" then
                for index = 1, #spell do
                    spellMatch, aura = FindSpellMatch(spell[index], tracker.unit, tracker.filter)
                end
            else
                spellMatch, aura = FindSpellMatch(spell, tracker.unit, tracker.filter)
            end

            if spellMatch then
                AuraTracking:debug("Tracker", tracker.id, spell)
                tracker.auraIndex = aura.index
                tracker.cd:Show()
                tracker.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
                tracker.icon:SetTexture(aura.texture)
                AuraTracking:AddTracker(tracker)
            elseif tracker.slotID then
                tracker.auraIndex = aura.index
                tracker.cd:SetCooldown(0, 0)
                tracker.cd:Hide()
                AuraTracking:RemoveTracker(tracker, tracker.order > 0)
            end
        end
    end
end)

--[[ API Functions ]]--
local api = {}
function api:UpdateSpellData()
    local spellData = icons[self]
    self.unit = spellData.unit
    self.order = spellData.order
    self.ignoreRaven = spellData.ignoreRaven
    self.filter = (spellData.auraType == "buff" and "HELPFUL PLAYER" or "HARMFUL PLAYER")
    self.specs = spellData.specs
    self.minLevel = spellData.minLevel
end

function api:Enable()
    AuraTracking:debug("Tracker:Enable", self.id)
    self.isEnabled = true
    if self.order > 0 then
        self.icon:SetDesaturated(true)
        AuraTracking:AddTracker(self)
    end
end
function api:Disable()
    AuraTracking:debug("Tracker:Disable", self.id)
    self.isEnabled = false
end

--[[ External Functions ]]--
function AuraTracking:CreateAuraIcon(id, spellData)
    local side = spellData.unit == "target" and "right" or "left"
    local tracker = CreateFrame("Frame", nil, self[side])
    self[side][id] = tracker
    tracker.side = side
    tracker.id = id

    local _, _, texture
    if type(spellData.spell) == "table" then
        _, _, texture = GetSpellInfo(spellData.spell[1])
    else
        _, _, texture = GetSpellInfo(spellData.spell)
    end

    local cd = CreateFrame("Cooldown", nil, tracker, "CooldownFrameTemplate")
    cd:SetAllPoints(tracker)
    tracker.cd = cd

    local icon = tracker:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(tracker)
    icon:SetTexture(texture)
    tracker.icon = icon

    local bg = F.ReskinIcon(icon)
    tracker.bg = bg

    local count = tracker:CreateFontString()
    count:SetFontObject(_G.RealUIFont_PixelCooldown)
    count:SetJustifyH("RIGHT")
    count:SetJustifyV("TOP")
    count:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", 1.5, 2.5)
    tracker.count = count

    tracker:SetScript("OnEnter", function(tracker)
        if not tracker.isEnabled then return end
        if tracker.auraIndex then
            _G.GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnitAura(tracker.unit, tracker.auraIndex, self.filter)
            GameTooltip:Show()
        end
    end)
    tracker:SetScript("OnLeave", function(tracker)
        if tracker.auraIndex then
            GameTooltip:Hide()
        end
    end)

    for key, func in next, api do
        tracker[key] = func
    end

    icons[tracker] = spellData

    tracker:UpdateSpellData()
    tracker:Hide()

    return tracker
end

function AuraTracking:EnableUnit(unit)
    if isValidUnit[unit] then return end
    self:debug("EnableUnit", unit)
    isValidUnit[unit] = true
    for tracker in self:IterateTrackers() do
        if tracker.unit == unit and self.isEnabled then
            tracker:Enable()
        end
    end
end
function AuraTracking:DisableUnit(unit)
    if not isValidUnit[unit] then return end
    self:debug("DisableUnit", unit)
    isValidUnit[unit] = false
    for tracker in self:IterateTrackers() do
        if tracker.unit == unit and self.isEnabled then
            tracker:Disable()
        end
    end
end

do
    local function iter(_, id)
        -- don't expose spellData
        return (next(icons, id))
    end

    function AuraTracking:IterateTrackers()
        return iter, nil, nil
    end
end
