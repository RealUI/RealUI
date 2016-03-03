local _, mods = ...
local _G = _G

mods["PLAYER_LOGIN"]["Bugger"] = function(self, F, C)
    _G.hooksecurefunc(_G.Bugger, "SetupFrame", function(bugFrame)
        local options = _G.ScriptErrorsFrameTitleButton:GetChildren()
        options:SetPoint("TOPRIGHT", _G.ScriptErrorsFrameClose, "TOPLEFT", -2, -2)

        F.Reskin(bugFrame.showLocals)
        for i = 1, 3 do
            F.ReskinTab(bugFrame.tabs[i])
        end

        -- Fix Aurora edit
        _G.ScriptErrorsFrame:SetScale(1)
    end)
end
