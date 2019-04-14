local _, private = ...

-- [[ Lua Globals ]]
-- luacheck: globals

-- [[ Core ]]
local Aurora = private.Aurora
local Skin = Aurora.Skin
local Color = Aurora.Color

-- do --[[ FrameXML\LFGFrame.lua ]]
-- end

-- do --[[ FrameXML\LFGFrame.xml ]]
-- end

_G.hooksecurefunc(private.FrameXML, "LFGFrame", function()
    if _G.IsAddOnLoaded("DBM-Core") or _G.IsAddOnLoaded("BigWigs") then return end

    local LFGDungeonReadyDialog = _G.LFGDungeonReadyDialog

    local timerBar = _G.CreateFrame("StatusBar", nil, LFGDungeonReadyDialog)
    Skin.FrameTypeStatusBar(timerBar)
    timerBar:SetPoint("BOTTOM", 0, 8)
    timerBar:SetSize(242, 12)
    timerBar:SetStatusBarColor(Color.yellow:GetRGB())
    LFGDungeonReadyDialog.timerBar = timerBar

    local duration, remaining = 40
    timerBar:SetMinMaxValues(0, duration)
    timerBar:SetScript("OnUpdate", function(self, elapsed)
        if not remaining then
            remaining = duration
        end
        remaining = remaining - elapsed

        if remaining > 0 then
            self:SetValue(remaining)
        else
            remaining = nil
        end
    end)
end)
