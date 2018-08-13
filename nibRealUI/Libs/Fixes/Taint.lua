-- HonorFrame.type can be tainted through UIDropDownMenu
-- https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
if (UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 2 then
    UIDROPDOWNMENU_VALUE_PATCH_VERSION = 2
    hooksecurefunc("UIDropDownMenu_InitializeHelper", function()
        if UIDROPDOWNMENU_VALUE_PATCH_VERSION ~= 2 then
            return
        end
        for i=1, UIDROPDOWNMENU_MAXLEVELS do
            for j=1, UIDROPDOWNMENU_MAXBUTTONS do
                local b = _G["DropDownList" .. i .. "Button" .. j]
                if not (issecurevariable(b, "value") or b:IsShown()) then
                    b.value = nil
                    repeat
                        j, b["fx" .. j] = j+1
                    until issecurevariable(b, "value")
                end
            end
        end
    end)
end


-- UIDropDown displayMode taints Communities UI
-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
if (UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
    UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
    hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
        if UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then
            return
        end
        if UIDROPDOWNMENU_OPEN_MENU and UIDROPDOWNMENU_OPEN_MENU ~= frame
           and not issecurevariable(UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
            UIDROPDOWNMENU_OPEN_MENU = nil
            local t, f, prefix, i = _G, issecurevariable, " \0", 1
            repeat
                i, t[prefix .. i] = i + 1
            until f("UIDROPDOWNMENU_OPEN_MENU")
        end
    end)
end
