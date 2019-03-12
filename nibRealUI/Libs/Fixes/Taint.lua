-- Dropdown Menu taint fixes
-- https://www.townlong-yak.com/bugs/PfF9rr-UIDropDownMenu

-- UIDropDownMenu displayMode taints dropdown initialization
-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeTaint
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

-- UIDropDownMenu_SetSelectedValue/_Refresh can taint execution
-- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
if (COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then
    COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1
    local function CleanDropdowns()
        if COMMUNITY_UIDD_REFRESH_PATCH_VERSION ~= 1 then
            return
        end
        local f, f2 = FriendsFrame, FriendsTabHeader
        local s = f:IsShown()
        f:Hide()
        f:Show()
        if not f2:IsShown() then
            f2:Show()
            f2:Hide()
        end
        if not s then
            f:Hide()
        end
    end
    hooksecurefunc("Communities_LoadUI", CleanDropdowns)
    hooksecurefunc("SetCVar", function(n)
        if n == "lastSelectedClubId" then
            CleanDropdowns()
        end
    end)
end
