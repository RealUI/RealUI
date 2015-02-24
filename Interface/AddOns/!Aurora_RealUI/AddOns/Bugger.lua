local _, mods = ...

mods["PLAYER_LOGIN"]["Bugger"] = function(self, F, C)
    hooksecurefunc(Bugger, "SetupFrame", function(self)
        local options = ScriptErrorsFrameTitleButton:GetChildren()
        options:SetPoint("TOPRIGHT", ScriptErrorsFrameClose, "TOPLEFT", -2, -2)

        F.Reskin(self.showLocals)
        for i = 1, 3 do
            F.ReskinTab(self.tabs[i])
        end

        -- Fix Aurora edit
        local scale = 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
        ScriptErrorsFrame:SetScale(1)
    end)
end
