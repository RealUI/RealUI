local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- [[ Core ]]
local Aurora = private.Aurora
local Base = Aurora.Base
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

do --[[ AddOns\Clique.lua ]]
    function Hook.CliqueConfig_SetupGUI(self)
        for _, row in next, self.rows do
            Skin.CliqueRowTemplate(row)
        end
    end
    function Hook.GENERAL_CreateOptions(self)
        Skin.UICheckButtonTemplate(self.updown)
        Skin.UICheckButtonTemplate(self.fastooc)

        Skin.UICheckButtonTemplate(self.specswap)
        for i, dropdown in next, self.talentProfiles do
            Skin.UIDropDownMenuTemplate(dropdown)
        end

        Skin.UIDropDownMenuTemplate(self.profiledd)
        Skin.UICheckButtonTemplate(self.stopcastingfix)
    end
    function Hook.BLACKLIST_CreateOptions(self)
        Skin.FauxScrollFrameTemplate(self.scrollframe)

        for i, checkbox in next, self.rows do
            Skin.UICheckButtonTemplate(checkbox)
        end

        Skin.UIPanelButtonTemplate(self.selectall)
        Skin.UIPanelButtonTemplate(self.selectnone)
    end
    function Hook.BLIZZFRAMES_CreateOptions(self)
        Skin.UICheckButtonTemplate(self.PlayerFrame)
        Skin.UICheckButtonTemplate(self.PetFrame)
        Skin.UICheckButtonTemplate(self.TargetFrame)
        Skin.UICheckButtonTemplate(self.TargetFrameToT)
        Skin.UICheckButtonTemplate(self.party)
        Skin.UICheckButtonTemplate(self.compactraid)
        Skin.UICheckButtonTemplate(self.boss)
        Skin.UICheckButtonTemplate(self.FocusFrame)
        Skin.UICheckButtonTemplate(self.FocusFrameToT)
        Skin.UICheckButtonTemplate(self.arena)
    end
end

do --[[ AddOns\Clique.xml ]]
    function Skin.CliqueRowTemplate(Button)
        Base.CropIcon(Button.icon)

        local color = Color.highlight
        Button:GetHighlightTexture():SetColorTexture(color.r, color.g, color.b, Color.frame.a)
    end
    function Skin.CliqueColumnTemplate(Button)
        Skin.WhoFrameColumnHeaderTemplate(Button)
    end
end

function private.AddOns.Clique()
    Skin.SpellBookSkillLineTabTemplate(_G.CliqueSpellTab)

    local CliqueTabAlert = _G.CliqueTabAlert
    CliqueTabAlert.Arrow = CliqueTabAlert.arrow
    CliqueTabAlert.CloseButton = CliqueTabAlert.close
    Skin.GlowBoxFrame(CliqueTabAlert, "Left")


    local CliqueDialog = _G.CliqueDialog
    Skin.BasicFrameTemplate(CliqueDialog)
    Skin.UIPanelButtonTemplate(CliqueDialog.button_binding)
    Skin.UIPanelButtonTemplate(CliqueDialog.button_accept)


    local CliqueConfig = _G.CliqueConfig
    _G.hooksecurefunc(CliqueConfig, "SetupGUI", Hook.CliqueConfig_SetupGUI)
    Skin.ButtonFrameTemplate(CliqueConfig)
    Skin.UIDropDownMenuTemplate(CliqueConfig.dropdown)

    local page1 = CliqueConfig.page1
    Skin.CliqueColumnTemplate(page1.column1)
    Skin.CliqueColumnTemplate(page1.column2)
    do -- page1.slider
        page1.slider:SetBackdrop(nil)
        Skin.ScrollBarThumb(_G.CliqueConfigPage1_VSliderThumbTexture)
    end
    Skin.MagicButtonTemplate(page1.button_spell)
    Skin.MagicButtonTemplate(page1.button_other)
    Skin.MagicButtonTemplate(page1.button_options)

    local page2 = CliqueConfig.page2
    Skin.UIPanelButtonTemplate(page2.button_binding)
    Skin.MagicButtonTemplate(page2.button_save)
    Skin.MagicButtonTemplate(page2.button_cancel)

    Skin.GlowBoxTemplate(_G.CliqueConfigBindAlert)
    Skin.GlowBoxArrowTemplate(_G.CliqueConfigBindAlert.arrow)



    local optpanels = _G.Clique.optpanels
    _G.hooksecurefunc(optpanels.GENERAL, "CreateOptions", Hook.GENERAL_CreateOptions)
    _G.hooksecurefunc(optpanels.BLACKLIST, "CreateOptions", Hook.BLACKLIST_CreateOptions)
    _G.hooksecurefunc(optpanels.BLIZZFRAMES, "CreateOptions", Hook.BLIZZFRAMES_CreateOptions)
end
