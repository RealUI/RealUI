local _, private = ...

-- Lua Globals --
local next, ipairs = _G.next, _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AlertFrameMove"
local AlertFrameMove = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local AlertFrameHolder = _G.CreateFrame("Frame", "AlertFrameHolder", _G.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", _G.UIParent, "TOP", 0, -18)

local alertBlacklist
local ReplaceAnchors do
    local alertPoint, alertRelPoint, alertYofs = "TOP", "BOTTOM", -10
    local function QueueAdjustAnchors(self, relativeAlert)
        for alertFrame in self.alertFramePool:EnumerateActive() do
            AlertFrameMove:debug("Queue", alertFrame, alertPoint, relativeAlert:GetName() or relativeAlert, alertRelPoint, alertYofs)
            alertFrame:ClearAllPoints()
            alertFrame:SetPoint(alertPoint, relativeAlert, alertRelPoint, 0, alertYofs)
            relativeAlert = alertFrame
        end
        return relativeAlert
    end
    local function SimpleAdjustAnchors(self, relativeAlert)
        if self.alertFrame:IsShown() then
            AlertFrameMove:debug("Simple", self.alertFrame:GetName(), alertPoint, relativeAlert:GetName(), alertRelPoint, alertYofs)
            self.alertFrame:ClearAllPoints()
            self.alertFrame:SetPoint(alertPoint, relativeAlert, alertRelPoint, 0, alertYofs)
            return self.alertFrame
        end
        return relativeAlert
    end
    local function AnchorAdjustAnchors(self, relativeAlert)
        if self.anchorFrame:IsShown() then
            AlertFrameMove:debug("Anchor:AdjustAnchors", relativeAlert:GetName())
            return self.anchorFrame;
        end
        return relativeAlert
    end

    function ReplaceAnchors(alertFrameSubSystem)
        if alertFrameSubSystem.alertFramePool then
            local frame = alertFrameSubSystem.alertFramePool:GetNextActive()
            AlertFrameMove:debug("Queue system", frame and frame:GetName())
            if alertBlacklist[alertFrameSubSystem.alertFramePool.frameTemplate] then
                return alertFrameSubSystem.alertFramePool.frameTemplate, true
            else
                alertFrameSubSystem.AdjustAnchors = QueueAdjustAnchors
            end
        elseif alertFrameSubSystem.alertFrame then
            local frame = alertFrameSubSystem.alertFrame
            AlertFrameMove:debug("Simple system", frame:GetName())
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = SimpleAdjustAnchors
            end
        elseif alertFrameSubSystem.anchorFrame then
            local frame = alertFrameSubSystem.anchorFrame
            AlertFrameMove:debug("Anchor system", frame:GetName())
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = AnchorAdjustAnchors
            end
        end
    end
end

local function SetUpAlert()
    AlertFrameMove:debug("SetUpAlert")
    _G.hooksecurefunc(_G.AlertFrame, "UpdateAnchors", function(self)
        AlertFrameMove:debug("UpdateAnchors")
        self:ClearAllPoints()
        self:SetAllPoints(AlertFrameHolder)
    end)
    _G.hooksecurefunc(_G.AlertFrame, "AddAlertFrameSubSystem", function(self, alertFrameSubSystem)
        AlertFrameMove:debug("AddAlertFrameSubSystem")
        local _, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)

        if isBlacklisted then
            for i, alertSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
                AlertFrameMove:debug("iterate SubSystems", i)
                if alertFrameSubSystem == alertSubSystem then
                    return _G.table.remove(_G.AlertFrame.alertFrameSubSystems, i)
                end
            end
        end
    end)

    local remove = {}
    for i, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        AlertFrameMove:debug("iterate SubSystems", i)
        local name, isBlacklisted = ReplaceAnchors(alertFrameSubSystem)

        if isBlacklisted then
            remove[i] = name
        end
    end

    for i, name in next, remove do
        AlertFrameMove:debug("iterate remove", i, name)
        _G.table.remove(_G.AlertFrame.alertFrameSubSystems, i)
    end
end
----------
function AlertFrameMove:OnInitialize()
    self:SetEnabledState(true)

end

function AlertFrameMove:OnEnable()
    alertBlacklist = {
        GroupLootContainer = RealUI:GetModuleEnabled("Loot"),
        TalkingHeadFrame = true,
    }

    SetUpAlert()
end
