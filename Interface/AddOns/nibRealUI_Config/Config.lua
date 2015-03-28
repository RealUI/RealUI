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

local uiWidth, uiHieght = UIParent:GetSize()
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
    ACD:SetDefaultSize("HuD", uiWidth * 0.3, uiHieght * 0.4)
    ACR:RegisterOptionsTable("RealUI", options.RealUI)
    initialized = true

    -- The HuD Config bar
    local F, C = unpack(Aurora)
    local r, g, b = C.r, C.g, C.b
    local size = floor(uiHieght * 0.05)

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
    local tabs = {
        {
            slug = "toggle",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
        },
        {
            slug = "unitframes",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
        },
        {
            slug = "castbars",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Auras]],
        },
        {
            slug = "close",
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Close]],
            onclick = function(self, ...)
                debug("onclick", ...)
                hudToggle()
            end,
        }
    }
    local prevFrame, container
    debug("size", size)
    for i = 1, #tabs do
        local tab = tabs[i]
        debug("iter tabs", i, tab.slug)
        local btn = CreateFrame("Button", "$parentBtn"..i, hudConfig)
        btn.ID = i
        btn:SetSize(size, size)
        btn:SetScript("OnEnter", function(self, ...)
            if slideAnim:IsPlaying() then return end
            debug("OnEnter", tab.slug)
            if highlight:IsShown() then
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
            debug("OnLeave hudConfig", ...)
            if hudConfig:IsMouseOver() then return end
            if highlight.clicked then
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

            btn:SetScript("OnClick", tab.onclick or function(self, ...)
                debug("OnClick", tab.slug, ...)
                if ACD.OpenFrames["HuD"] and highlight.clicked == i then
                    highlight.clicked = nil
                    ACD:Close("HuD")
                else
                    highlight.clicked = i
                    ACD:Open("HuD", tab.slug)
                    local widget = ACD.OpenFrames["HuD"]
                    widget:ClearAllPoints()
                    widget:SetPoint("TOP", hudConfig, "BOTTOM")
                    -- the position will get reset via SetStatusTable, so we need to set our new positions there too.
                    local status = widget.status or widget.localstatus
                    status.top = widget.frame:GetTop()
                    status.left = widget.frame:GetLeft()
                end
            end)

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

local unitframes
do
    local ModKeys = {
        SHIFT_KEY_TEXT,
        CTRL_KEY_TEXT,
        ALT_KEY_TEXT,
    }
    local trinkChat = {
        "GROUP",
        "SAY",
    }
    local db = nibRealUI.db:GetNamespace("UnitFrames").profile
    unitframes = {
        name = UNITFRAME_LABEL,
        type = "group",
        childGroups = "tab",
        args = {
            enable = {
                name = "Enable Unit Frames",
                desc = "Enable/Disable Unit Frames",
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
                    focusclick = {
                        type = "toggle",
                        name = "Click Set Focus",
                        desc = "Set focus by click+modifier on the Unit Frames.",
                        get = function() return db.misc.focusclick end,
                        set = function(info, value)
                            db.misc.focusclick = value
                        end,
                        order = 10,
                    },
                    focuskey = {
                        type = "select",
                        name = "Modifier Key",
                        values = ModKeys,
                        disabled = function() return not db.misc.focusclick end,
                        get = function(info)
                            for i = 1, #ModKeys do
                                if ModKeys[i] == db.misc.focuskey then
                                    return i
                                end
                            end
                        end,
                        set = function(info, value)
                            db.misc.focuskey = ModKeys[value]
                        end,
                        order = 20,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    alwaysDisplayFullHealth = {
                        type = "toggle",
                        name = "Full Health on Target",
                        desc = "Always display the full health value on the Target frame.",
                        get = function() return db.misc.alwaysDisplayFullHealth end,
                        set = function(info, value)
                            db.misc.alwaysDisplayFullHealth = value
                        end,
                        order = 30,
                    },
                }
            },
            units = {
                name = "Units",
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
                    player = {
                        name = ARENA,
                        type = "group",
                        args = {

                        }
                    },
                    target = {
                        name = BOSS,
                        type = "group",
                        args = {

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
                name = "Anchor Width",
                desc = "The amount of space between the Player frame and the Target frame.",
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
            name = "X Offset",
            type = "input",
            order = 10,
            get = function(info) return tostring(position.x) end,
            set = function(info, value)
                value = nibRealUI:ValidateOffset(value)
                position.x = value
            end,
        }
        unit.args.y = {
            name = "Y Offset",
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
                name = "Width",
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
            hieght = {
                name = "Hieght",
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
            healthHieght = {
                name = "Health bar hieght",
                desc = "The hieght of the health bar as a percentage of the total unit hieght",
                type = "range",
                width = "double",
                min = 0,
                max = 1,
                step = .01,
                isPercent = true,
                order = 50,
                get = function(info) return unitInfo.healthHieght end,
                set = function(info, value)
                    unitInfo.healthHieght = value
                end,
            },
            x = {
                name = "X offset",
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
                name = "Y offset",
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
        castbars = {
            name = "Cast Bars",
            type = "group",
            args = {
                enable = {
                    name = "Enable Cast Bars",
                    desc = "Enables / disables Cast Bars",
                    type = "toggle",
                    set = function(info,val) end,
                    get = function(info) return end
                },
            },
        },
        close = { -- This is for button creation
            name = "Close",
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
