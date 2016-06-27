local _, private = ...

-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- Libs --
local F = _G.Aurora[1]

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AuraTracking"
local AuraTracking = RealUI:GetModule(MODNAME)

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
    local eventUpdate = spellData.eventUpdate
    if eventUpdate then
        if eventUpdate.event == "UNIT_AURA" then
            eventUpdate.func(self, spellData)
        else
            self:RegisterEvent(eventUpdate.event)
            self[eventUpdate.event] = eventUpdate.func
        end
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
    if self.timer then
        AuraTracking:CancelTimer(self.timer)
    end
    if self.slotID then
        AuraTracking:RemoveTracker(self)
    end
end

--[[ External Functions ]]--
function AuraTracking:CreateAuraIcon(id, spellData)
    AuraTracking:debug("CreateAuraIcon", id, spellData.unit)
    local side = spellData.unit == "target" and "right" or "left"
    local tracker = _G.CreateFrame("Frame", nil, self[side])
    self[side][id] = tracker
    tracker.side = side
    tracker.id = id

    local cd = _G.CreateFrame("Cooldown", nil, tracker, "CooldownFrameTemplate")
    cd:SetAllPoints(tracker)
    cd:SetDrawEdge(false)
    cd:SetReverse(true)
    tracker.cd = cd

    local _, texture
    if spellData.customIcon then
        texture = spellData.customIcon
    elseif type(spellData.spell) == "table" then
        _, _, texture = _G.GetSpellInfo(spellData.spell[1])
    else
        _, _, texture = _G.GetSpellInfo(spellData.spell)
    end

    local icon = tracker:CreateTexture(nil, "BACKGROUND", nil, -7)
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

    tracker:SetScript("OnEnter", function(trakr)
        if not trakr.isEnabled then return end
        if trakr.auraIndex then
            _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.UIParent)
            _G.GameTooltip:SetUnitAura(spellData.unit, trakr.auraIndex, trakr.filter)
            _G.GameTooltip:Show()
        else
            local spell = spellData.spell
            if type(spell) == "table" then
                spell = spell[1]
            end

            spell = _G.tonumber(spell)
            _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.UIParent)
            _G.GameTooltip:SetSpellByID(spell)
            _G.GameTooltip:Show()
        end
    end)
    tracker:SetScript("OnLeave", function(trakr)
        if trakr.auraIndex then
            _G.GameTooltip:Hide()
        end
    end)
    tracker:SetScript("OnEvent", function(trakr, event, ...)
        trakr[event](trakr, spellData, ...)
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
