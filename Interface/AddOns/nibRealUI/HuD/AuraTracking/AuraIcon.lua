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

--[[ API Functions ]]--
local api = {}
function api:UpdateSpellData()
    local spellData = icons[self]
    self.isStatic = spellData.order > 0
    self.filter = (spellData.auraType == "buff" and "HELPFUL PLAYER" or "HARMFUL PLAYER")
end

function api:Enable()
    AuraTracking:debug("Tracker:Enable", self.id, self.isStatic)
    local spellData = icons[self]
    self.isEnabled = true
    if spellData.eventUpdate then
        local eventUpdate = spellData.eventUpdate
        self:RegisterEvent(eventUpdate.event)
        self[eventUpdate.event] = eventUpdate.func
    end
    if self.isStatic then
        self.icon:SetDesaturated(true)
        AuraTracking:AddTracker(self, spellData.order)
    end
end
function api:Disable()
    AuraTracking:debug("Tracker:Disable", self.id, self.isStatic)
    self.isEnabled = false
    self:UnregisterAllEvents()
    if self.slotID then
        AuraTracking:RemoveTracker(self)
    end
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
            GameTooltip:SetUnitAura(spellData.unit, tracker.auraIndex, self.filter)
            GameTooltip:Show()
        else
            local spell = spellData.spell
            if type(spell) == "table" then
                spell = spell[1]
            end

            if type(spell) == "number" then
                _G.GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
                GameTooltip:SetSpellByID(spell)
                GameTooltip:Show()
            end
        end
    end)
    tracker:SetScript("OnLeave", function(tracker)
        if tracker.auraIndex then
            GameTooltip:Hide()
        end
    end)
    tracker:SetScript("OnEvent", function(tracker, event, ...)
        tracker[event](tracker, spellData, ...)
    end)

    for key, func in next, api do
        tracker[key] = func
    end

    icons[tracker] = spellData

    tracker:UpdateSpellData()
    tracker:Hide()

    return tracker
end

do
    local function iter(_, id)
        return next(icons, id)
    end

    function AuraTracking:IterateTrackers()
        return iter, nil, nil
    end
end
