local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

if _G.IsAddOnLoaded("DBM-Core") or _G.IsAddOnLoaded("BigWigs") then return end

----------------------------------------------------------------------------------------
--  Queue timer on LFGDungeonReadyDialog
----------------------------------------------------------------------------------------
local frame = _G.CreateFrame("Frame", nil, _G.LFGDungeonReadyDialog)

_G.LFGDungeonReadyDialog.nextUpdate = 0

local function UpdateBar()
    if not frame.bar then
        frame:SetPoint("BOTTOM", _G.LFGDungeonReadyDialog, "BOTTOM", 0, 8)
        RealUI:CreateBD(frame) -- Not sure.
        frame:SetSize(244, 12)

        frame.bar = _G.CreateFrame("StatusBar", nil, frame)
        frame.bar:SetStatusBarTexture(RealUI.media.textures.plain)
        frame.bar:SetPoint("TOPLEFT", 1, -1)
        frame.bar:SetPoint("BOTTOMLEFT", -1, 1)
        frame.bar:SetFrameLevel(_G.LFGDungeonReadyDialog:GetFrameLevel() + 1)
        frame.bar:SetStatusBarColor(1, 0.7, 0)
    end

    local obj = _G.LFGDungeonReadyDialog
    local oldTime = _G.GetTime()
    local flag = 0
    local duration = 40
    local interval = 0.1
    obj:SetScript("OnUpdate", function(self, elapsed)
        obj.nextUpdate = obj.nextUpdate + elapsed
        if obj.nextUpdate > interval then
            local newTime = _G.GetTime()
            if (newTime - oldTime) < duration then
                local width = frame:GetWidth() * (newTime - oldTime) / duration
                frame.bar:SetPoint("BOTTOMRIGHT", frame, 0 - width, 0)
                flag = flag + 1
                if flag >= 10 then
                    flag = 0
                end
            else
                obj:SetScript("OnUpdate", nil)
            end
            obj.nextUpdate = 0
        end
    end)
end

frame:RegisterEvent("LFG_PROPOSAL_SHOW")
frame:SetScript("OnEvent", function(self)
    if _G.LFGDungeonReadyDialog:IsShown() then
        UpdateBar()
    end
end)
