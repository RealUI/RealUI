if not REALUI_STRIPE_TEXTURES then REALUI_STRIPE_TEXTURES = {} end
if not REALUI_WINDOW_FRAMES then REALUI_WINDOW_FRAMES = {} end

local style = {}
style.apiVersion = "5.0.7"

local F, C

style.functions = {
    ["CreateBD"] = function(f, a)
        --print("Override CreateBD")
        f:SetBackdrop({
            bgFile = C.media.backdrop,
            edgeFile = C.media.backdrop,
            edgeSize = 1,
        })
        f:SetBackdropColor(0.03, 0.03, 0.03, a or AuroraConfig.alpha)
        f:SetBackdropBorderColor(0, 0, 0)
        if not a then tinsert(C.frames, f) end
    end,
    ["CreateBG"] = function(frame)
        --print("Override CreateBG")
        local f = frame
        if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", frame, -1, 1)
        bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
        bg:SetTexture(C.media.backdrop)
        bg:SetVertexColor(0.03, 0.03, 0.03)

        return bg
    end,
    ["CreateSD"] = function(parent, size, r, g, b, alpha, offset)
        --print("New CreateSD")
        local sd = CreateFrame("Frame", nil, parent)
        sd.size = size or 5
        sd.offset = offset or 0
        sd:SetBackdrop({
            edgeFile = nil,
            edgeSize = sd.size,
        })
        sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
        sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
        sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
        sd:SetAlpha(alpha or 1)
        tinsert(REALUI_WINDOW_FRAMES, parent)

        sd.tex = parent:CreateTexture(nil, "BACKGROUND", nil, 1)
        sd.tex:SetAllPoints()
        sd.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
        sd.tex:SetHorizTile(true)
        sd.tex:SetVertTile(true)
        sd.tex:SetBlendMode("ADD")
        tinsert(REALUI_STRIPE_TEXTURES, sd.tex)
    end,
    ["SetBD"] = function(f, x, y, x2, y2)
        --print("Override SetBD")
        local bg = CreateFrame("Frame", nil, f)
        if not x then
            bg:SetPoint("TOPLEFT")
            bg:SetPoint("BOTTOMRIGHT")
        else
            bg:SetPoint("TOPLEFT", x, y)
            bg:SetPoint("BOTTOMRIGHT", x2, y2)
        end
        bg:SetFrameLevel(0)
        F.CreateBD(bg)
        F.CreateSD(bg)
    end,
    ["ReskinPortraitFrame"] = function(f, isButtonFrame)
        --print("Override ReskinPortraitFrame")
        local name = f:GetName()

        _G[name.."Bg"]:Hide()
        _G[name.."TitleBg"]:Hide()
        _G[name.."Portrait"]:Hide()
        _G[name.."PortraitFrame"]:Hide()
        _G[name.."TopRightCorner"]:Hide()
        _G[name.."TopLeftCorner"]:Hide()
        _G[name.."TopBorder"]:Hide()
        _G[name.."TopTileStreaks"]:SetTexture("")
        _G[name.."BotLeftCorner"]:Hide()
        _G[name.."BotRightCorner"]:Hide()
        _G[name.."BottomBorder"]:Hide()
        _G[name.."LeftBorder"]:Hide()
        _G[name.."RightBorder"]:Hide()

        if isButtonFrame then
            _G[name.."BtnCornerLeft"]:SetTexture("")
            _G[name.."BtnCornerRight"]:SetTexture("")
            _G[name.."ButtonBottomBorder"]:SetTexture("")

            f.Inset.Bg:Hide()
            f.Inset:DisableDrawLayer("BORDER")
        end

        F.CreateBD(f)
        F.CreateSD(f)
        F.ReskinClose(_G[name.."CloseButton"])
    end,
}

style.classcolors = {
    ["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23 },
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 },
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 },
    ["MONK"]        = { r = 0.00, g = 1.00, b = 0.59 },
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["PRIEST"]      = { r = 0.80, g = 0.80, b = 0.80 },
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 },
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 };
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 },
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 },
}

--style.highlightColor = {r = 0, g = 1, b = 0}


AURORA_CUSTOM_STYLE = style

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
    if addon == "Aurora" then
        F, C = unpack(Aurora)

        --New functions
        F.CreateSD = style.functions["CreateSD"]

        --Misc
        F.CreateSD(PVPReadyDialog)
        F.CreateSD(PetBattleQueueReadyFrame)
        F.CreateSD(MovieFrame.CloseDialog)
        F.CreateSD(CinematicFrameCloseDialog)
        F.CreateSD(TutorialFrame)
        F.CreateSD(BattleTagInviteFrame)

        local FrameBDs = {"GameMenuFrame", "InterfaceOptionsFrame", "VideoOptionsFrame", "AudioOptionsFrame", "ChatConfigFrame", "StackSplitFrame", "AddFriendFrame", "FriendsFriendsFrame", "ColorPickerFrame", "ReadyCheckFrame", "GuildInviteFrame", "ChannelFrameDaughterFrame"}
        for i = 1, #FrameBDs do
            local FrameBD = _G[FrameBDs[i]]
            F.CreateSD(FrameBD)
        end

        -- Dropdown lists
        hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
            for i = 1, UIDROPDOWNMENU_MAXLEVELS do
                local menu = _G["DropDownList"..i.."MenuBackdrop"]
                local backdrop = _G["DropDownList"..i.."Backdrop"]
                if not backdrop.reskinned then
                    F.CreateBD(menu)
                    F.CreateBD(backdrop)

                    backdrop.tex = backdrop:CreateTexture(nil, "BACKGROUND", nil, 1)
                    backdrop.tex:SetAllPoints()
                    backdrop.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
                    backdrop.tex:SetHorizTile(true)
                    backdrop.tex:SetVertTile(true)
                    backdrop.tex:SetBlendMode("ADD")
                    tinsert(REALUI_STRIPE_TEXTURES, backdrop.tex)

                    menu.tex = menu:CreateTexture(nil, "BACKGROUND", nil, 1)
                    menu.tex:SetAllPoints()
                    menu.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
                    menu.tex:SetHorizTile(true)
                    menu.tex:SetVertTile(true)
                    menu.tex:SetBlendMode("ADD")
                    tinsert(REALUI_STRIPE_TEXTURES, menu.tex)
    
                    backdrop.reskinned = true
                end
            end
        end)

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
