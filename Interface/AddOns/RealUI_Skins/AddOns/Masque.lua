local _, private = ...

function private.AddOns.Masque()
    print("Masque loaded")
    local EAB = _G.ExtraActionButton1
    EAB:SetNormalTexture("")

    local MSQ = _G.LibStub("Masque")
    MSQ:AddSkin("RealUI", {
        Author = "Nibelheim",
        Version = "8.1 r20",
        Shape = "Square",
        Masque_Version = 70200,
        Backdrop = {
            Width = 32,
            Height = 32,
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Backdrop]],
        },
        Icon = {
            Width = 26,
            Height = 26,
            TexCoords = {0.08, 0.92, 0.08, 0.92},
        },
        Flash = {
            Width = 32,
            Height = 32,
            Color = {1, 0, 0, 0.3},
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Overlay]],
        },
        Cooldown = {
            Width = 26,
            Height = 26,
        },
        ChargeCooldown = {
            Width = 26,
            Height = 26,
        },
        Pushed = {
            Width = 32,
            Height = 32,
            Color = {0, 0, 0, 0.5},
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Overlay]],
        },
        Normal = {
            Width = 32,
            Height = 32,
            Color = {0, 0, 0, 1},
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Normal]],
        },
        Disabled = {
            Hide = true,
        },
        Checked = {
            Width = 32,
            Height = 32,
            BlendMode = "ADD",
            Color = {0, 0.8, 1, 0.5},
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Border]],
        },
        Border = {
            Width = 32,
            Height = 32,
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Border]],
        },
        Gloss = {
            Width = 32,
            Height = 32,
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Gloss]],
        },
        AutoCastable = {
            Width = 48,
            Height = 48,
            OffsetX = 0.5,
            OffsetY = -0.5,
            Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
        },
        Highlight = {
            Width = 32,
            Height = 32,
            BlendMode = "ADD",
            Color = {1, 1, 1, 0.75},
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Highlight]],
        },
        Name = {
            Width = 26,
            Height = 10,
            OffsetX = 1,
            OffsetY = 5,
            JustifyH = "LEFT",
        },
        Count = {
            Width = 26,
            Height = 10,
            OffsetX = -3,
            OffsetY = 5,
            JustifyH = "RIGHT",
        },
        HotKey = {
            Width = 26,
            Height = 10,
            OffsetX = 6,
            OffsetY = -6,
            JustifyH = "LEFT",
        },
        Duration = {
            Width = 26,
            Height = 10,
            OffsetY = -2,
        },
        Shine = {
            Width = 26,
            Height = 26,
            OffsetX = 1,
            OffsetY = -1,
        },
    }, true)
end
