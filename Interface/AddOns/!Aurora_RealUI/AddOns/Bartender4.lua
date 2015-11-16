local _, mods = ...
local _G = _G

mods["PLAYER_LOGIN"]["Bartender4"] = function(self, F, C)
    --print("Bartender4", F, C)
    local RealUIFont_PixelSmall, RealUIFont_PixelCooldown = _G.RealUIFont_PixelSmall, _G.RealUIFont_PixelCooldown

    local textures = {
        vehicle = {
            normal = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_up]],
            pushed = [[Interface\AddOns\nibRealUI\Media\Icons\vehicle_leave_down]],
        },
    }

    local MainMenuBarVehicleLeaveButton = _G.MainMenuBarVehicleLeaveButton
    MainMenuBarVehicleLeaveButton:SetNormalTexture(textures.vehicle.normal)
    MainMenuBarVehicleLeaveButton:SetPushedTexture(textures.vehicle.pushed)
    F.CreateBD(MainMenuBarVehicleLeaveButton)

    for i = 1, 120 do
        local button = _G["BT4Button"..i];
        if button then
            local name = button:GetName();
            local count = _G[name.."Count"];
            local hotkey = _G[name.."HotKey"];
            local macro = _G[name.."Name"];

            if count then
                count:SetFont(RealUIFont_PixelSmall:GetFont())
            end
            hotkey:SetFont(RealUIFont_PixelSmall:GetFont())
            macro:SetFont(RealUIFont_PixelSmall:GetFont())
            macro:SetShadowColor(0, 0, 0, 0)
        end
    end

    -- Extra Action Button
    local ExtraActionBarFrame = _G.ExtraActionBarFrame
    if ExtraActionBarFrame then
        ExtraActionBarFrame.button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        ExtraActionBarFrame.button.style:SetAlpha(0)
        F.CreateBDFrame(ExtraActionBarFrame.button)
        ExtraActionBarFrame:HookScript("OnShow", function()
            ExtraActionBarFrame.button.style:SetAlpha(0)
        end)
    end
    local ExtraActionButton1 = _G.ExtraActionButton1
    if ExtraActionButton1 then
        _G.ExtraActionButton1HotKey:SetFont(RealUIFont_PixelSmall:GetFont())
        _G.ExtraActionButton1HotKey:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", 1.5, -1.5)
        _G.ExtraActionButton1Count:SetFont(RealUIFont_PixelCooldown:GetFont())
        _G.ExtraActionButton1Count:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", -2.5, 1.5)
    end
end
