local _, private = ...

function private.AddOns.Masque()
    local MSQ = _G.LibStub("Masque")
    local Hidden = MSQ.__Hidden

    MSQ:AddSkin("RealUI", {
        Template = "Blizzard Modern",
        Shape = "Square",
        API_VERSION = 100002,

        Author = "Gethe",
        Version = 3,

        Backdrop = {
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        Icon = {
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        -- SlotIcon = Template.Hidden,
        -- Shadow = Template.Hidden,
        Normal = {
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Border]],
            Color = {0, 0, 0, 1},
            Width = 32,
            Height = 32,
        },
        -- Disabled = Template.Hidden,
        Pushed = {
            Texture = [[Interface\Buttons\UI-Quickslot-Depress]],
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        Flash = {
            Color = {1, 0, 0, 0.3},
            Width = 32,
            Height = 32,
            UseColor = true
        },
        HotKey = {
            JustifyH = "LEFT",
            Width = 26,
            Height = 8,
            Point = "TOPLEFT",
            RelPoint = "TOPLEFT",
            OffsetX = 11,
            OffsetY = -13,
        },
        Count = {
            JustifyH = "RIGHT",
            Width = 26,
            Height = 6,
            OffsetX = -8,
            OffsetY = 12,
        },
        Duration = {
            Width = 26,
            Height = 10,
            OffsetY = -2,
        },
        Checked = {
            Texture = [[Interface\Buttons\CheckButtonHilight]],
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        SlotHighlight = {
            Texture = [[Interface\Buttons\CheckButtonHilight]],
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        Name = {
            JustifyH = "LEFT",
            Width = 26,
            Height = 10,
            OffsetX = 1,
            OffsetY = 5,
        },
        Border = {
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Border]],
            Width = 32,
            Height = 32,
        },
        IconBorder = {
            Texture = [[Interface\AddOns\RealUI_Skins\Media\Border]],
            Width = 32,
            Height = 32,
        },
        -- Gloss = Template.Hidden,
        NewAction = {
            Atlas = "bags-newitem",
            TexCoords = {0.15, 0.85, 0.15, 0.85},
            Width = 26,
            Height = 26,
        },
        SpellHighlight = {
            Atlas = "bags-newitem",
            TexCoords = {0.15, 0.85, 0.15, 0.85},
            Width = 26,
            Height = 26,
        },
        AutoCastable = {
            Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
            TexCoords = {0.21875, 0.765625, 0.21875, 0.765625},
            Width = 26,
            Height = 26,
        },
        IconOverlay = Hidden,
        --UpgradeIcon = Template,
        --IconOverlay2 = Template,
        --QuestBorder = Template,
        NewItem = {
            Atlas = "bags-glow-white",
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        SearchOverlay = {
            Width = 26,
            Height = 26,
        },
        ContextOverlay = {
            Width = 26,
            Height = 26,
        },
        --JunkIcon = Template,
        Highlight = {
            Texture = [[Interface\Buttons\ButtonHilight-Square]],
            TexCoords = {0.08, 0.92, 0.08, 0.92},
            Width = 26,
            Height = 26,
        },
        AutoCastShine = {
            Width = 26,
            Height = 26,
            OffsetX = 1,
            OffsetY = -1,
        },
        Cooldown = {
            Width = 26,
            Height = 26,
        },
        ChargeCooldown = {
            Width = 26,
            Height = 26,
        },
    }, true)
end
