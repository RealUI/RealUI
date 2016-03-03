local _, mods = ...

mods["PLAYER_LOGIN"]["Grid2"] = function(self, F, C)
    --print("Grid2", F, C)
    _G.hooksecurefunc(_G.Grid2Layout, "UpdateSize", function()
        for k, frame in pairs(_G.Grid2Frame.registeredFrames) do
            if not frame.realUISkinned then
                -- Border
                if not frame.newBorder then
                    frame.newBorder = F.CreateBDFrame(frame, 0)
                        frame.newBorder:SetPoint("TOPLEFT", frame, 1, -1)
                        frame.newBorder:SetPoint("BOTTOMRIGHT", frame, -1, 1)
                end

                --[[ Health Deficit
                if frame["health-deficit"] then
                    frame["health-deficit"]:SetReverseFill(true)
                end]]

                frame.realUISkinned = true
            end
        end
    end)
end
