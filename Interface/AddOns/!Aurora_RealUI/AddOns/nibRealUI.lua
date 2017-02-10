local _, mods = ...

_G.tinsert(mods["PLAYER_LOGIN"], function(F, C)
    --print("HELLO RealUI!!!", F, C)
    --VideoOptions
    F.Reskin(_G.RealUIScaleBtn)

    -- DropDownMenu copy
    _G.hooksecurefunc("Lib_UIDropDownMenu_CreateFrames", function(level, index)
        for i = 1, _G.LIB_UIDROPDOWNMENU_MAXLEVELS do
            local menu = _G["Lib_DropDownList"..i.."MenuBackdrop"]
            local backdrop = _G["Lib_DropDownList"..i.."Backdrop"]
            if not backdrop.reskinned then
                F.CreateBD(menu)
                F.CreateBD(backdrop)
                backdrop.reskinned = true
            end
        end
    end)

    local createBackdrop = function(parent, texture)
        local bg = parent:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0, .5)
        bg:SetPoint("CENTER", texture)
        bg:SetSize(12, 12)
        parent.bg = bg

        local left = parent:CreateTexture(nil, "BACKGROUND")
        left:SetWidth(1)
        left:SetColorTexture(0, 0, 0)
        left:SetPoint("TOPLEFT", bg)
        left:SetPoint("BOTTOMLEFT", bg)
        parent.left = left

        local right = parent:CreateTexture(nil, "BACKGROUND")
        right:SetWidth(1)
        right:SetColorTexture(0, 0, 0)
        right:SetPoint("TOPRIGHT", bg)
        right:SetPoint("BOTTOMRIGHT", bg)
        parent.right = right

        local top = parent:CreateTexture(nil, "BACKGROUND")
        top:SetHeight(1)
        top:SetColorTexture(0, 0, 0)
        top:SetPoint("TOPLEFT", bg)
        top:SetPoint("TOPRIGHT", bg)
        parent.top = top

        local bottom = parent:CreateTexture(nil, "BACKGROUND")
        bottom:SetHeight(1)
        bottom:SetColorTexture(0, 0, 0)
        bottom:SetPoint("BOTTOMLEFT", bg)
        bottom:SetPoint("BOTTOMRIGHT", bg)
        parent.bottom = bottom
    end

    local toggleBackdrop = function(bu, show)
        if show then
            bu.bg:Show()
            bu.left:Show()
            bu.right:Show()
            bu.top:Show()
            bu.bottom:Show()
        else
            bu.bg:Hide()
            bu.left:Hide()
            bu.right:Hide()
            bu.top:Hide()
            bu.bottom:Hide()
        end
    end

    _G.hooksecurefunc("Lib_ToggleDropDownMenu", function(level, _, dropDownFrame, anchorName)
        if not level then level = 1 end

        local uiScale = _G.UIParent:GetScale()

        local listFrame = _G["Lib_DropDownList"..level]

        if level == 1 then
            if not anchorName then
                local xOffset = dropDownFrame.xOffset and dropDownFrame.xOffset or 16
                local yOffset = dropDownFrame.yOffset and dropDownFrame.yOffset or 9
                local point = dropDownFrame.point and dropDownFrame.point or "TOPLEFT"
                local relativeTo = dropDownFrame.relativeTo and dropDownFrame.relativeTo or dropDownFrame
                local relativePoint = dropDownFrame.relativePoint and dropDownFrame.relativePoint or "BOTTOMLEFT"

                listFrame:ClearAllPoints()
                listFrame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)

                -- make sure it doesn't go off the screen
                local offLeft = listFrame:GetLeft()/uiScale
                local offRight = (_G.GetScreenWidth() - listFrame:GetRight())/uiScale
                local offTop = (_G.GetScreenHeight() - listFrame:GetTop())/uiScale
                local offBottom = listFrame:GetBottom()/uiScale

                local xAddOffset, yAddOffset = 0, 0
                if offLeft < 0 then
                    xAddOffset = -offLeft
                elseif offRight < 0 then
                    xAddOffset = offRight
                end

                if offTop < 0 then
                    yAddOffset = offTop
                elseif offBottom < 0 then
                    yAddOffset = -offBottom
                end
                listFrame:ClearAllPoints()
                listFrame:SetPoint(point, relativeTo, relativePoint, xOffset + xAddOffset, yOffset + yAddOffset)
            elseif anchorName ~= "cursor" then
                -- this part might be a bit unreliable
                local _, _, relPoint, xOff, yOff = listFrame:GetPoint()
                if relPoint == "BOTTOMLEFT" and xOff == 0 and _G.floor(yOff) == 5 then
                    listFrame:SetPoint("TOPLEFT", anchorName, "BOTTOMLEFT", 16, 9)
                end
            end
        else
            local point, anchor, relPoint, _, y = listFrame:GetPoint()
            if point:find("RIGHT") then
                listFrame:SetPoint(point, anchor, relPoint, -14, y)
            else
                listFrame:SetPoint(point, anchor, relPoint, 9, y)
            end
        end

        for j = 1, _G.LIB_UIDROPDOWNMENU_MAXBUTTONS do
            local bu = _G["Lib_DropDownList"..level.."Button"..j]
            local _, _, _, x = bu:GetPoint()
            if bu:IsShown() and x then
                local hl = _G["Lib_DropDownList"..level.."Button"..j.."Highlight"]
                local check = _G["Lib_DropDownList"..level.."Button"..j.."Check"]

                hl:SetPoint("TOPLEFT", -x + 1, 0)
                hl:SetPoint("BOTTOMRIGHT", listFrame:GetWidth() - bu:GetWidth() - x - 1, 0)

                if not bu.bg then
                    createBackdrop(bu, check)
                    hl:SetColorTexture(C.r, C.g, C.b, .2)
                    _G["Lib_DropDownList"..level.."Button"..j.."UnCheck"]:SetTexture("")

                    local arrow = _G["Lib_DropDownList"..level.."Button"..j.."ExpandArrow"]
                    arrow:SetNormalTexture(C.media.arrowRight)
                    arrow:SetSize(8, 8)
                end

                if not bu.notCheckable then
                    toggleBackdrop(bu, true)

                    -- only reliable way to see if button is radio or or check...
                    local _, co = check:GetTexCoord()

                    if co == 0 then
                        check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        check:SetVertexColor(C.r, C.g, C.b, 1)
                        check:SetSize(20, 20)
                        check:SetDesaturated(true)
                    else
                        check:SetTexture(C.media.backdrop)
                        check:SetVertexColor(C.r, C.g, C.b, .6)
                        check:SetSize(10, 10)
                        check:SetDesaturated(false)
                    end

                    check:SetTexCoord(0, 1, 0, 1)
                else
                    toggleBackdrop(bu, false)
                end
            end
        end
    end)

    _G.hooksecurefunc("Lib_UIDropDownMenu_SetIconImage", function(icon, texture)
        if texture:find("Divider") then
            icon:SetColorTexture(1, 1, 1, .2)
            icon:SetHeight(1)
        end
    end)
end)
