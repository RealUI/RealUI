local NAME, config = ...
local options = {}

-- RealUI
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb = nibRealUI.db.profile
local hudSize = ndb.settings.hudSize
local round = nibRealUI.Round

-- Ace
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local GUI = LibStub("AceGUI-3.0")

local uiWidth, uiHeight = UIParent:GetSize()
local initialized = false
local isHuDShown = false

local function debug(...)
    nibRealUI.Debug("Config", ...)
end

local hudConfig, hudToggle
local function InitializeOptions()
    debug("Init")

    nibRealUI:SetUpOptions() -- Old
    ACR:RegisterOptionsTable("HuD", options.HuD)
    ACD:SetDefaultSize("HuD", uiWidth * 0.3, uiHeight * 0.4)
    ACR:RegisterOptionsTable("RealUI", options.RealUI)
    initialized = true

    -- The HuD Config bar
    local F, C = unpack(Aurora)
    local r, g, b = C.r, C.g, C.b
    local size = floor(uiHeight * 0.05)

    local hudConfig = CreateFrame("Frame", "RealUIHuDConfig", UIParent)
    hudConfig:SetPoint("BOTTOM", UIParent, "TOP", -500, 0)
    F.CreateBD(hudConfig)

    local slideAnim = hudConfig:CreateAnimationGroup()
    slideAnim:SetScript("OnFinished", function(self)
        local x, y = self.slide:GetOffset()
        hudConfig:ClearAllPoints()
        if y < 0 then
            hudConfig:SetPoint("TOP", UIParent, "TOP", -500, 0)
        else
            hudConfig:SetPoint("BOTTOM", UIParent, "TOP", -500, 1)
        end
    end)
    local slide = slideAnim:CreateAnimation("Translation")
    slide:SetDuration(1)
    slide:SetSmoothing("OUT")
    slideAnim.slide = slide

    -- Highlight frame
    local highlight = CreateFrame("Frame", "RealUIHuDConfig", hudConfig)
    F.CreateBD(highlight, 0.0)
    highlight:SetBackdropColor(r, g, b, 0.3)
    highlight:SetBackdropBorderColor(r, g, b)
    highlight:Hide()

    local hlAnim = highlight:CreateAnimationGroup()
    local hl = hlAnim:CreateAnimation("Translation")
    hl:SetDuration(0.2)
    hl:SetSmoothing("OUT")
    hlAnim.hl = hl

    -- Buttons
    local tabs
    tabs = {
        {
            slug = "toggle",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
        },
        {
            slug = "unitframes",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
        },
        {
            slug = "auratracker",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Auras]],
            onclick = function(self, ...)
                debug("OnClick", self.slug, self.ID, ...)
                if not self.frame then
                    local widget = GUI:Create("Frame")
                    widget:SetTitle(self.text:GetText())
                    widget:SetPoint("TOP", hudConfig, "BOTTOM")
                    widget:SetWidth(uiWidth * 0.3)
                    widget:SetHeight(uiHeight * 0.2)
                    widget.frame:GetChildren():Hide()
                    widget.frame:Hide()
                    widget.titlebg:SetPoint("TOP", 0, 0)
                    self.frame = widget.frame
                    tabs[self.ID].frame = widget.frame

                    self.table = _G.LibStub("LibTextTable-1.1").New(nil, widget.frame)
                    self.table:SetAllPoints()
                end
                if self.frame:IsShown() and highlight.clicked == self.ID then
                    highlight.clicked = nil
                    self.frame:Hide()
                    ACD:Close("HuD")
                else
                    highlight.clicked = self.ID
                    self.frame:Show()
                    ACD:Close("HuD")
                end
            end,
        },
        {
            slug = "castbars",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Auras]],
        },
        {
            slug = "close",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Close]],
            onclick = function(self, ...)
                debug("OnClick", self.slug, ...)
                highlight:Hide()
                hudToggle()
            end,
        }
    }
    local function tabOnClick(self, ...)
        debug("OnClick", self.slug, ...)
        if highlight.clicked and tabs[highlight.clicked].frame then
            tabs[highlight.clicked].frame:Hide()
        end
        local widget = ACD.OpenFrames["HuD"]
        if widget and highlight.clicked == self.ID then
            highlight.clicked = nil
            widget.titlebg:SetPoint("TOP", 0, 12)
            ACD:Close("HuD")
        else
            highlight.clicked = self.ID
            ACD:Open("HuD", self.slug)
            widget = ACD.OpenFrames["HuD"]
            widget:ClearAllPoints()
            widget:SetPoint("TOP", hudConfig, "BOTTOM")
            widget:SetTitle(self.text:GetText())
            widget.titlebg:SetPoint("TOP", 0, 0)
            -- the position will get reset via SetStatusTable, so we need to set our new positions there too.
            local status = widget.status or widget.localstatus
            status.top = widget.frame:GetTop()
            status.left = widget.frame:GetLeft()
        end
    end
    local prevFrame, container
    debug("size", size)
    for i = 1, #tabs do
        local tab = tabs[i]
        debug("iter tabs", i, tab.slug)
        local btn = CreateFrame("Button", "$parentBtn"..i, hudConfig)
        btn.ID = i
        btn.slug = tab.slug
        btn:SetSize(size, size)
        btn:SetScript("OnEnter", function(self, ...)
            if slideAnim:IsPlaying() then return end
            debug("OnEnter", tab.slug)
            if highlight:IsShown() then
                debug(highlight.hover, highlight.clicked)
                if highlight.hover ~= self.ID then
                    hl:SetOffset(size * (self.ID - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(hlAnim)
                        highlight.hover = i
                        highlight:SetAllPoints(self)
                    end)
                    hlAnim:Play()
                elseif hlAnim:IsPlaying() then
                    debug("Stop Playing")
                    hlAnim:Stop()
                end
            else
                highlight.hover = i
                highlight:SetAllPoints(self)
                highlight:Show()
            end
        end)
        btn:SetScript("OnLeave", function(self, ...)
            if hudConfig:IsMouseOver() then return end
            debug("OnLeave hudConfig", ...)
            if highlight.clicked then
                debug(highlight.hover, highlight.clicked)
                if highlight.hover ~= highlight.clicked then
                    hl:SetOffset(size * (highlight.clicked - highlight.hover), 0)
                    hlAnim:SetScript("OnFinished", function(hlAnim)
                        highlight.hover = highlight.clicked
                        highlight:SetAllPoints(hudConfig[highlight.clicked])
                    end)
                    hlAnim:Play()
                elseif hlAnim:IsPlaying() then
                    debug("Stop Playing")
                    hlAnim:Stop()
                end
            else
                highlight:Hide()
            end
        end)

        if i == 1 then
            btn:SetPoint("TOPLEFT")
            local check = CreateFrame("CheckButton", nil, btn, "SecureActionButtonTemplate, UICheckButtonTemplate")
            check:SetHitRectInsets(-10, -10, -1, -21)
            check:SetPoint("CENTER", 0, 10)
            check:SetAttribute("type1", "macro")
            SecureHandlerWrapScript(check, "OnClick", check, [[
                if self:GetID() == 1 then
                    self:SetAttribute("macrotext", format("/cleartarget\n/focus\n/run RealUIHuDTestMode(false)"))
                    self:SetID(0)
                else
                    self:SetAttribute("macrotext", format("/target player\n/focus\n/run RealUIHuDTestMode(true)"))
                    self:SetID(1)
                end
            ]])
        else
            btn:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT")
            btn:SetScript("OnClick", tab.onclick or tabOnClick)

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetTexture(tab.icon)
            icon:SetSize(size * 0.5, size * 0.5)
            icon:SetPoint("TOP", 0, -(size * 0.15))
        end

        local text = btn:CreateFontString()
        text:SetFontObject(GameFontHighlightSmall)
        text:SetWidth(size * 0.9)
        text:SetPoint("BOTTOM", 0, size * 0.08)
        text:SetText(options.HuD.args[tab.slug].name)
        btn.text = text

        hudConfig[i] = btn
        prevFrame = btn
    end
    hudConfig:SetSize(#tabs * size, size)

    hudToggle = function( ... )
        if isHuDShown then
            ACD:Close("HuD")
            -- slide out
            slide:SetOffset(0, size)
            slideAnim:Play()
            isHuDShown = false
        else
            -- slide in
            slide:SetOffset(0, -size)
            slideAnim:Play()
            isHuDShown = true
        end
    end
end

function nibRealUI:ToggleConfig(mode, ...)
    debug("Toggle", mode, ...)
    if not initialized then InitializeOptions() end
    if mode == "HuD" and not ... then
        nibRealUI:ShowConfigBar() -- Old
        return hudToggle()
    end
    --if not mode:match("RealUI") then mode = "RealUI" end
    if ACD.OpenFrames[mode] then
        ACD:Close(mode)
    else
        ACD:Open(mode, ...)
    end
end

local unitframes do
    local CombatFader = nibRealUI:GetModule("CombatFader")
    local UnitFrames = nibRealUI:GetModule("UnitFrames")
    local db = UnitFrames.db.profile
    unitframes = {
        name = UNITFRAME_LABEL,
        type = "group",
        childGroups = "tab",
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format("RealUI"..UNITFRAME_LABEL),
                type = "toggle",
                get = function(info) return nibRealUI:GetModuleEnabled("UnitFrames") end,
                set = function(info, value)
                    nibRealUI:SetModuleEnabled("UnitFrames", value)
                    nibRealUI:ReloadUIDialog()
                end,
            },
            general = {
                name = GENERAL,
                type = "group",
                order = 10,
                args = {
                    classColor = {
                        name = L["Appearance_ClassColorHealth"],
                        type = "toggle",
                        get = function() return db.overlay.classColor end,
                        set = function(info, value)
                            db.overlay.classColor = value
                        end,
                        order = 10,
                    },
                    classColorNames = {
                        name = L["Appearance_ClassColorNames"],
                        type = "toggle",
                        get = function() return db.overlay.classColorNames end,
                        set = function(info, value)
                            db.overlay.classColorNames = value
                        end,
                        order = 20,
                    },
                    statusText = {
                        name = STATUS_TEXT,
                        desc = OPTION_TOOLTIP_STATUS_TEXT_DISPLAY,
                        type = "select",
                        values = function()
                            return {
                                both = STATUS_TEXT_BOTH,
                                perc = STATUS_TEXT_PERCENT,
                                value = STATUS_TEXT_VALUE,
                            }
                        end,
                        get = function(info)
                            return db.misc.statusText
                        end,
                        set = function(info, value)
                            db.misc.statusText = value
                            UnitFrames:RefreshUnits("StatusText")
                        end,
                        order = 30,
                    },
                    focusClick = {
                        name = L["UnitFrames_SetFocus"],
                        desc = L["UnitFrames_SetFocusDesc"],
                        type = "toggle",
                        get = function() return db.misc.focusclick end,
                        set = function(info, value)
                            db.misc.focusclick = value
                        end,
                        order = 40,
                    },
                    focusKey = {
                        name = L["UnitFrames_ModifierKey"],
                        type = "select",
                        values = function()
                            return {
                                shift = SHIFT_KEY_TEXT,
                                ctrl = CTRL_KEY_TEXT,
                                alt = ALT_KEY_TEXT,
                            }
                        end,
                        disabled = function() return not db.misc.focusclick end,
                        get = function(info)
                            return db.misc.focuskey
                        end,
                        set = function(info, value)
                            db.misc.focuskey = value
                        end,
                        order = 41,
                    },
                    combatFade = {
                        name = L["CombatFade"],
                        type = "group",
                        inline = true,
                        disabled = function() return not db.misc.combatfade.enabled end,
                        order = 50,
                        args = {
                            incombat = {
                                name = L["CombatFade_InCombat"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.incombat end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.incombat = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 10,
                            },
                            harmtarget = {
                                name = L["CombatFade_HarmTarget"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.harmtarget end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.harmtarget = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 20,
                            },
                            target = {
                                name = L["CombatFade_Target"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.target end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.target = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 30,
                            },
                            hurt = {
                                name = L["CombatFade_Hurt"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.hurt end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.hurt = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 40,
                            },
                            outofcombat = {
                                name = L["CombatFade_NoCombat"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.outofcombat end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.outofcombat = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 50,
                            },
                        }
                    }
                }
            },
            units = {
                name = L["UnitFrames_Units"],
                type = "group",
                childGroups = "select",
                order = 20,
                args = {
                    player = {
                        name = PLAYER,
                        type = "group",
                        order = 10,
                        args = {}
                    },
                    pet = {
                        name = PET,
                        type = "group",
                        order = 20,
                        args = {}
                    },
                    target = {
                        name = TARGET,
                        type = "group",
                        order = 30,
                        args = {}
                    },
                    targettarget = {
                        name = SHOW_TARGET_OF_TARGET_TEXT,
                        type = "group",
                        order = 40,
                        args = {}
                    },
                    focus = {
                        name = FOCUS,
                        type = "group",
                        order = 50,
                        args = {}
                    },
                    focustarget = {
                        name = BINDING_NAME_FOCUSTARGET,
                        type = "group",
                        order = 60,
                        args = {}
                    },
                }
            },
            groups = {
                name = GROUPS,
                type = "group",
                childGroups = "select",
                order = 30,
                args = {
                    gap = {
                        name = L["UnitFrames_Gap"],
                        desc = L["UnitFrames_GapDesc"],
                        type = "range",
                        min = 0, max = 10, step = 1,
                        get = function(info) return db.boss.gap end,
                        set = function(info, value) db.boss.gap = value end,
                        order = 10,
                    },
                    x = {
                        name = L["UnitFrames_XOffset"],
                        type = "input",
                        order = 20,
                        get = function(info) return tostring(db.positions[hudSize].boss.x) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            position.x = value
                        end,
                    },
                    y = {
                        name = L["UnitFrames_YOffset"],
                        type = "input",
                        order = 30,
                        get = function(info) return tostring(db.positions[hudSize].boss.y) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            position.y = value
                        end,
                    },
                    boss = {
                        name = BOSS,
                        type = "group",
                        order = 40,
                        args = {
                            showPlayerAuras = {
                                name = L["UnitFrames_PlayerAuras"],
                                desc = L["UnitFrames_PlayerAurasDesc"],
                                type = "toggle",
                                get = function() return db.boss.showPlayerAuras end,
                                set = function(info, value)
                                    db.boss.showPlayerAuras = value
                                end,
                                order = 10,
                            },
                            showNPCAuras = {
                                name = L["UnitFrames_NPCAuras"],
                                desc = L["UnitFrames_NPCAurasDesc"],
                                type = "toggle",
                                get = function() return db.boss.showNPCAuras end,
                                set = function(info, value)
                                    db.boss.showNPCAuras = value
                                end,
                                order = 20,
                            },
                            buffCount = {
                                name = L["UnitFrames_BuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.buffCount end,
                                set = function(info, value) db.boss.buffCount = value end,
                                order = 30,
                            },
                            debuffCount = {
                                name = L["UnitFrames_DebuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.debuffCount end,
                                set = function(info, value) db.boss.debuffCount = value end,
                                order = 40,
                            },

                        }
                    },
                    arena = {
                        name = ARENA,
                        type = "group",
                        order = 50,
                        args = {
                            enabled = {
                                name = L["General_Enabled"],
                                desc = L["General_EnabledDesc"]:format("RealUI"..SHOW_ARENA_ENEMY_FRAMES_TEXT),
                                type = "toggle",
                                get = function() return db.arena.enabled end,
                                set = function(info, value)
                                    db.arena.enabled = value
                                end,
                                order = 10,
                            },
                            options = {
                                name = "",
                                type = "group",
                                inline = true,
                                disabled = function() return not db.arena.enabled end,
                                order = 20,
                                args = {
                                    announceUse = {
                                        name = L["UnitFrames_AnnounceTrink"],
                                        desc = L["UnitFrames_AnnounceTrinkDesc"],
                                        type = "toggle",
                                        get = function() return db.arena.announceUse end,
                                        set = function(info, value)
                                            db.arena.announceUse = value
                                        end,
                                        order = 10,
                                    },
                                    announceChat = {
                                        name = CHAT,
                                        desc = L["UnitFrames_AnnounceChatDesc"],
                                        type = "select",
                                        values = function()
                                            return {
                                                group = INSTANCE_CHAT,
                                                say = CHAT_MSG_SAY,
                                            }
                                        end,
                                        disabled = function() return not db.arena.announceUse end,
                                        get = function(info)
                                            return strlower(db.arena.announceChat)
                                        end,
                                        set = function(info, value)
                                            db.arena.announceChat = value
                                        end,
                                        order = 20,
                                    },
                                    --[[showPets = {
                                        name = SHOW_ARENA_ENEMY_PETS_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_PETS,
                                        type = "toggle",
                                        get = function() return db.arena.showPets end,
                                        set = function(info, value)
                                            db.arena.showPets = value
                                        end,
                                        order = 30,
                                    },
                                    showCast = {
                                        name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_CASTBAR,
                                        type = "toggle",
                                        get = function() return db.arena.showCast end,
                                        set = function(info, value)
                                            db.arena.showCast = value
                                        end,
                                        order = 40,
                                    },]]
                                },
                            },
                        }
                    },
                }
            },
        },
    }
    local units = unitframes.args.units.args
    for unitSlug, unit in next, units do
        local position = db.positions[hudSize][unitSlug]
        if unitSlug == "player" or unitSlug == "target" then
            unit.args.anchorWidth = {
                name = L["UnitFrames_AnchorWidth"],
                desc = L["UnitFrames_AnchorWidthDesc"],
                type = "range",
                width = "double",
                min = round(uiWidth * 0.1),
                max = round(uiWidth * 0.5),
                step = 2,
                order = 5,
                get = function(info) return ndb.positions[nibRealUI.cLayout]["UFHorizontal"] end,
                set = function(info, value)
                    ndb.positions[nibRealUI.cLayout]["UFHorizontal"] = value
                    nibRealUI:UpdatePositioners()
                end,
            }
        end
        unit.args.x = {
            name = L["UnitFrames_XOffset"],
            type = "input",
            order = 10,
            get = function(info) return tostring(position.x) end,
            set = function(info, value)
                value = nibRealUI:ValidateOffset(value)
                position.x = value
            end,
        }
        unit.args.y = {
            name = L["UnitFrames_YOffset"],
            type = "input",
            order = 20,
            get = function(info) return tostring(position.y) end,
            set = function(info, value)
                value = nibRealUI:ValidateOffset(value)
                position.y = value
            end,
        }
        --[[ future times
        local unitInfo = db.units[unitSlug]
        unit.args = {
            width = {
                name = L["HuD_Width"],
                type = "input",
                --width = "half",
                order = 10,
                get = function(info) return tostring(unitInfo.size.x) end,
                set = function(info, value)
                    unitInfo.size.x = value
                end,
                pattern = "^(%d+)$",
                usage = "You can only use whole numbers."
            },
            height = {
                name = L["HuD_Height"],
                type = "input",
                --width = "half",
                order = 20,
                get = function(info) return tostring(unitInfo.size.y) end,
                set = function(info, value)
                    unitInfo.size.y = value
                end,
                pattern = "^(%d+)$",
                usage = "You can only use whole numbers."
            },
            healthHeight = {
                name = "Health bar height",
                desc = "The height of the health bar as a percentage of the total unit height",
                type = "range",
                width = "double",
                min = 0,
                max = 1,
                step = .01,
                isPercent = true,
                order = 50,
                get = function(info) return unitInfo.healthHeight end,
                set = function(info, value)
                    unitInfo.healthHeight = value
                end,
            },
            x = {
                name = L["UnitFrames_XOffset"],
                type = "range",
                min = -100,
                max = 50,
                step = 1,
                order = 30,
                get = function(info) return unitInfo.position.x end,
                set = function(info, value)
                    unitInfo.position.x = value
                end,
            },
            y = {
                name = "L["UnitFrames_YOffset"],
                type = "range",
                min = -100,
                max = 100,
                step = 1,
                order = 40,
                get = function(info) return unitInfo.position.y end,
                set = function(info, value)
                    unitInfo.position.y = value
                end,
            },
        --]]
    end
end
local auratracker do
    local db = nibRealUI.db:GetNamespace("AuraTracking").profile
    auratracker = {
        name = L["AuraTrack"],
        type = "group",
        childGroups = "tab",
        args = {}
    }
end
options.HuD = {
    type = "group",
    args = {
        toggle = { -- This is for button creation
            name = L["HuD_ShowElements"],
            type = "group",
            args = {
            },
        },
        unitframes = unitframes,
        auratracker = auratracker,
        castbars = {
            name = SHOW_ENEMY_CAST,
            type = "group",
            args = {
                enable = {
                    name = L["General_Enabled"],
                    desc = L["General_EnabledDesc"]:format(SHOW_ENEMY_CAST),
                    type = "toggle",
                    set = function(info,val) end,
                    get = function(info) return end
                },
            },
        },
        close = { -- This is for button creation
            name = CLOSE,
            type = "group",
            args = {
            },
        },
    }
}

options.RealUI = {
    type = "group",
    args = {
        enable = {
            name = "Enable",
            desc = "Enables / disables the addon",
            type = "toggle",
            set = function(info,val) end,
            get = function(info) end
        },
        moreoptions = {
            name = "More Options",
            type = "group",
            args = {
                -- more options go here
            }
        }
    }
}
