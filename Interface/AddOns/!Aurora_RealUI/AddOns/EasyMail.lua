local _, mods = ...

-- Lua Globals --
local _G = _G

mods["PLAYER_LOGIN"]["EasyMail"] = function(self, F, C)
    --print("HELLO EasyMail!!!", F, C)
    local r, g, b = C.r, C.g, C.b
    
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
    F.Reskin(_G.EasyMail_CheckAllButton)
    SetTexture(_G.EasyMail_CheckAllButton, "CheckAll")

    F.Reskin(_G.EasyMail_ClearAllButton)
    SetTexture(_G.EasyMail_ClearAllButton, "ClearAll")

    F.Reskin(_G.EasyMail_CheckPageButton)
    SetTexture(_G.EasyMail_CheckPageButton, "CheckPage")

    F.Reskin(_G.EasyMail_ClearPageButton)
    SetTexture(_G.EasyMail_ClearPageButton, "ClearPage")

    F.Reskin(_G.EasyMail_GetAllButton)
    SetTexture(_G.EasyMail_GetAllButton, "GetChecked")
    local bag = _G.EasyMail_GetAllButton:CreateTexture()
    bag:SetPoint("TOPRIGHT", -14, -7)
    bag:SetSize(20, 20)
    bag:SetTexture([[Interface\Icons\INV_Misc_Bag_08]])
    bag:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    bag:Show()
    _G.hooksecurefunc(_G.EasyMail_GetAllButton, "Disable", function()
        --print("Disable", bag)
        bag:SetDesaturated(true)
    end)
    _G.hooksecurefunc(_G.EasyMail_GetAllButton, "Enable", function()
        --print("Enable", bag)
        bag:SetDesaturated(false)
    end)

    _G.hooksecurefunc(_G.EasyMail, "InboxUpdate", function()
        for i = 1, _G.INBOXITEMS_TO_DISPLAY do
            local check = _G["EasyMail_CheckButton"..i]
            if check and not check.skinned then
                F.ReskinCheck(check)
            end
        end
    end)


    -- Send
    F.Reskin(_G.EasyMail_MailButton, true)
    _G.EasyMail_MailButton:SetSize(20, 20)
    _G.EasyMail_MailButton:ClearAllPoints()
    _G.EasyMail_MailButton:SetPoint("TOPLEFT", _G.SendMailNameEditBox, "TOPRIGHT", -1, 0)

    local tex = _G.EasyMail_MailButton:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(C.media.arrowDown)
    tex:SetSize(8, 8)
    tex:SetPoint("CENTER")
    tex:SetVertexColor(1, 1, 1)
    _G.EasyMail_MailButton.tex = tex

    _G.EasyMail_MailButton:HookScript("OnEnter", F.colourArrow)
    _G.EasyMail_MailButton:HookScript("OnLeave", F.clearArrow)

    -- Dropdown pullout
    F.CreateBD(_G.EasyMail_MailDropdownBackdrop)
    for i = 1, 15 do
        local highlight = _G["EasyMail_MailDropdownButton" .. i .. "Highlight"]
        if _G.RealUI.isBeta then
            highlight:SetColorTexture(r, g, b, .4)
        else
            highlight:SetTexture(r, g, b, .4)
        end
        highlight:ClearAllPoints()
        highlight:SetPoint("TOPLEFT", -11, 0)
        highlight:SetPoint("BOTTOMRIGHT", 12, 0)
    end

    -- Open
    F.Reskin(_G.EasyMail_AttButton)
    F.Reskin(_G.EasyMail_ForwardButton)
end
