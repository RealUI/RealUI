local _, mods = ...

mods["PLAYER_LOGIN"]["Bartender4"] = function(self, F, C)
    --print("Bartender4", F, C)
    local textures = {
        vehicle = {
            normal = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_up]],
            pushed = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_down]],
        },
    }

    MainMenuBarVehicleLeaveButton:SetNormalTexture(textures.vehicle.normal)
    MainMenuBarVehicleLeaveButton:SetPushedTexture(textures.vehicle.pushed)
    F.CreateBD(MainMenuBarVehicleLeaveButton)

    -- Extra Action Button
    if ExtraActionBarFrame then
        ExtraActionBarFrame.button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        ExtraActionBarFrame.button.style:SetAlpha(0)
        F.CreateBDFrame(ExtraActionBarFrame.button)
        ExtraActionBarFrame:HookScript("OnShow", function()
            ExtraActionBarFrame.button.style:SetAlpha(0)
        end)
    end
end
