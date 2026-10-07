local _, private = ...

-- Lua Globals --
local ipairs = _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "AlertFrameMove"
local AlertFrameMove = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceHook-3.0")

local AlertFrameHolder = _G.CreateFrame("Frame", "AlertFrameHolder", _G.UIParent)
AlertFrameHolder:SetWidth(180)
AlertFrameHolder:SetHeight(20)
AlertFrameHolder:SetPoint("TOP", _G.UIParent, "TOP", 0, -18)

--[[ Alerts drop down from AlertFrameHolder (top centre) instead of rising
     from Blizzard's AlertFrame.

     This used to replace `AdjustAnchors` on every alert subsystem and
     table.remove the talking head / group loot subsystems from
     AlertFrame.alertFrameSubSystems: replaced methods and rewritten array
     slots that every Blizzard UpdateAnchors read, so every alert
     (ShowAlert -> AddAlertFrame -> UpdateAnchors) ran under RealUI taint
     (tracker taint doctrine R1). Now one post-hook on AlertFrame:UpdateAnchors
     re-anchors the active alert frames after Blizzard has placed them. Nothing
     is written onto Blizzard objects, and Blizzard's execution continues
     secure after the hook returns. Externally anchored subsystems (talking
     head, group loot) are simply not chained, as the old blacklist did. ]]
local alertPoint, alertRelPoint, alertYofs = "TOP", "BOTTOM", -10
local function UpdateAnchors(container)
    AlertFrameMove:debug("UpdateAnchors")
    local relativeAlert = AlertFrameHolder
    for _, alertFrameSubSystem in ipairs(container.alertFrameSubSystems) do
        local pool = alertFrameSubSystem.alertFramePool
        if pool then
            for alertFrame in pool:EnumerateActive() do
                alertFrame:ClearAllPoints()
                alertFrame:SetPoint(alertPoint, relativeAlert, alertRelPoint, 0, alertYofs)
                relativeAlert = alertFrame
            end
        end
    end
end

local function SetUpAlert()
    AlertFrameMove:debug("SetUpAlert")
    _G.hooksecurefunc(_G.AlertFrame, "UpdateAnchors", UpdateAnchors)
end
----------
function AlertFrameMove:OnInitialize()
    self:SetEnabledState(true)

end

function AlertFrameMove:OnEnable()
    SetUpAlert()
end
