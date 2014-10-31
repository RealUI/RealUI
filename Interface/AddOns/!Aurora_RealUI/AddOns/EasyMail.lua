local _, mods = ...

mods["EasyMail"] = function(F, C)
    --print("HELLO EasyMail!!!", F, C)
    local _, class = UnitClass("player")
    local r, g, b = C.classcolours[class].r, C.classcolours[class].g, C.classcolours[class].b

    local function SetTexture(f, name)
        f:SetNormalTexture([[Interface\AddOns\!Aurora_RealUI\Media\AddOns\EasyMail\]]..name)
        local nTex = f:GetNormalTexture()
        nTex:SetVertexColor(r, g, b)

        f:SetPushedTexture([[Interface\AddOns\!Aurora_RealUI\Media\AddOns\EasyMail\]]..name) --..[[Down]])
        local pTex = f:GetPushedTexture()
        pTex:SetVertexColor(r, g, b)

        f:SetDisabledTexture([[Interface\AddOns\!Aurora_RealUI\Media\AddOns\EasyMail\]]..name) --..[[Disabled]])
    end

    -- Inbox
    F.Reskin(EasyMail_CheckAllButton)
    SetTexture(EasyMail_CheckAllButton, "CheckAll")

    F.Reskin(EasyMail_ClearAllButton)
    SetTexture(EasyMail_ClearAllButton, "ClearAll")

    F.Reskin(EasyMail_CheckPageButton)
    SetTexture(EasyMail_CheckPageButton, "CheckPage")

    F.Reskin(EasyMail_ClearPageButton)
    SetTexture(EasyMail_ClearPageButton, "ClearPage")

    F.Reskin(EasyMail_GetAllButton)
    SetTexture(EasyMail_GetAllButton, "GetChecked")
    local bag = EasyMail_GetAllButton:CreateTexture()
    bag:SetPoint("TOPRIGHT", -14, -7)
    bag:SetSize(20, 20)
    bag:SetTexture([[Interface\Icons\INV_Misc_Bag_08]])
    bag:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    bag:Show()
    hooksecurefunc(EasyMail_GetAllButton, "Disable", function()
        --print("Disable", bag)
        bag:SetDesaturated(true)
    end)
    hooksecurefunc(EasyMail_GetAllButton, "Enable", function()
        --print("Enable", bag)
        bag:SetDesaturated(false)
    end)

    hooksecurefunc(EasyMail, "InboxUpdate", function()
        for i = 1, INBOXITEMS_TO_DISPLAY do
            local check = _G["EasyMail_CheckButton"..i]
            if check and not check.skinned then
                F.ReskinCheck(check)
            end
        end
    end)


    -- Send
    F.Reskin(EasyMail_MailButton, true)
    EasyMail_MailButton:SetSize(20, 20)
    EasyMail_MailButton:ClearAllPoints()
    EasyMail_MailButton:SetPoint("TOPLEFT", SendMailNameEditBox, "TOPRIGHT", -1, 0)

    local tex = EasyMail_MailButton:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(C.media.arrowDown)
    tex:SetSize(8, 8)
    tex:SetPoint("CENTER")
    tex:SetVertexColor(1, 1, 1)
    EasyMail_MailButton.tex = tex

    EasyMail_MailButton:HookScript("OnEnter", F.colourArrow)
    EasyMail_MailButton:HookScript("OnLeave", F.clearArrow)

    -- Dropdown pullout
    F.CreateBD(EasyMail_MailDropdownBackdrop)
    for i = 1, 15 do
        local highlight = _G["EasyMail_MailDropdownButton" .. i .. "Highlight"]
        highlight:SetTexture(r, g, b, .4)
        highlight:ClearAllPoints()
        highlight:SetPoint("TOPLEFT", -11, 0)
        highlight:SetPoint("BOTTOMRIGHT", 12, 0)
    end

    -- Open
    F.Reskin(EasyMail_AttButton)
    F.Reskin(EasyMail_ForwardButton)
end
