--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local category = 'Kui |cff9966ffNameplates|r'
------------------------------------------------------------------ Ace config --
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local RELOAD_HINT = '\n\n|cffff0000UI reload required to take effect.'
--------------------------------------------------------------- Options table --
do
    local StrataSelectList = {
        ['BACKGROUND'] = '1. BACKGROUND',
        ['LOW'] = '2. LOW',
        ['MEDIUM'] = '3. MEDIUM',
        ['HIGH'] = '4. HIGH',
        ['DIALOG'] = '5. DIALOG',
        ['TOOLTIP'] = '6. TOOLTIP',
    }

    local HealthTextSelectList = {
        'Current |cff888888(145k)',
        'Maximum |cff888888(156k)',
        'Percent |cff888888(93)',
        'Deficit |cff888888(-10.9k)',
        'Blank |cff888888(  )'
    }

    local HealthAnimationSelectList = {
        'None',
        'Smooth',
        'Cutaway'
    }

    local globalConfigChangedListeners = {}

    local handlers = {}
    local handlerProto = {}
    local handlerMeta = { __index = handlerProto }

    -- called by handler:Set when configuration is changed
    local function ConfigChangedSkeleton(mod, info, profile)
        if mod.configChangedListener then
            -- notify that any option has changed
            mod:configChangedListener()
        end

        if mod.configChangedFuncs then
            -- legacy support
            local key = info[#info]

            if mod.configChangedFuncs.NEW then
                -- new ConfigChanged support (TODO: voyeurs)
                local cc_table,gcc_table,k
                for i=1,#info do
                    k = info[i]

                    if not cc_table then
                        cc_table = mod.configChangedFuncs
                    end

                    if not gcc_table then
                        gcc_table = globalConfigChangedListeners[mod:GetName()]
                    end

                    -- call the modules functions..
                    if cc_table and cc_table[k] then
                        cc_table = cc_table[k]

                        if type(cc_table.ro) == 'function' then
                            cc_table.ro(profile[key])
                        end

                        if type(cc_table.pf) == 'function' then
                            for _,frame in pairs(addon.frameList) do
                                cc_table.pf(frame.kui,profile[key])
                            end
                        end
                    end

                    -- call any voyeur's functions..
                    if gcc_table and gcc_table[k] then
                        gcc_table = gcc_table[k]

                        if gcc_table.ro then
                            for _,voyeur in ipairs(gcc_table.ro) do
                                voyeur(profile[key])
                            end
                        end

                        if gcc_table.pf then
                            for _,voyeur in ipairs(gcc_table.pf) do
                                for _,frame in pairs(addon.frameList) do
                                    voyeur(frame.kui,profile[key])
                                end
                            end
                        end
                    end
                end

                return
            end

            -- call option specific callbacks
            if mod.configChangedFuncs.runOnce and
               mod.configChangedFuncs.runOnce[key]
            then
                -- call runOnce function
                mod.configChangedFuncs.runOnce[key](profile[key])
            end
        end

        -- find and call global config changed listeners
        local voyeurs = {}
        if  globalConfigChangedListeners[mod:GetName()] and
            globalConfigChangedListeners[mod:GetName()][key]
        then
            for _,voyeur in ipairs(globalConfigChangedListeners[mod:GetName()][key]) do
                voyeur = addon:GetModule(voyeur)

                if voyeur.configChangedFuncs.global.runOnce[key] then
                    voyeur.configChangedFuncs.global.runOnce[key](profile[key])
                end

                if voyeur.configChangedFuncs.global[key] then
                    -- also call when iterating frames
                    tinsert(voyeurs, voyeur)
                end
            end
        end

        -- iterate frames and call
        for _, frame in pairs(addon.frameList) do
            if mod.configChangedFuncs and mod.configChangedFuncs[key] then
                mod.configChangedFuncs[key](frame.kui, profile[key])
            end

            for _,voyeur in ipairs(voyeurs) do
                voyeur.configChangedFuncs.global[key](frame.kui, profile[key])
            end
        end
    end

    local function ResolveKeys(mod,keys,ro,pf,g,global)
        if not g then
            g = mod.configChangedFuncs
        end

        if type(keys) == 'table' then
            for _,key in ipairs(keys) do
                if not g[key] then
                    g[key] = {}
                end

                g = g[key]
            end
        elseif type(keys) == 'string' then
            if not g[keys] then
                g[keys] = {}
            end

            g = g[keys]
        else
            return
        end

        if not global then
            if g.ro or g.pf then
                kui.print('ConfigChanged callback overwritten in '..(mod:GetName() or 'nil'))
            end

            g.ro = ro
            g.pf = pf
        else
            if ro then
                if not g.ro then g.ro = {} end
                tinsert(g.ro, ro)
            end
            if pf then
                if not g.pf then g.pf = {} end
                tinsert(g.pf, pf)
            end
        end
    end

    local function AddConfigChanged(mod,key_groups,ro,pf)
        if not mod.configChangedFuncs then
            mod.configChangedFuncs = {}
        end
        mod.configChangedFuncs.NEW = true

        if type(key_groups) == 'table' and type(key_groups[1]) == 'table' then
            -- multiple key groups
            for _,keys in ipairs(key_groups) do
                ResolveKeys(mod,keys,ro,pf)
            end
        else
            -- one key group, or a string
            ResolveKeys(mod,key_groups,ro,pf)
        end
    end

    local function AddGlobalConfigChanged(mod,target_module,key_groups,ro,pf)
        if not globalConfigChangedListeners then
            globalConfigChangedListeners = {}
        end

        if not target_module or target_module == 'addon' then
            target_module = 'KuiNameplates'
        end

        if not globalConfigChangedListeners[target_module] then
            globalConfigChangedListeners[target_module] = {}
        end

        local target_table = globalConfigChangedListeners[target_module]

        if type(key_groups) == 'table' and type(key_groups[1]) == 'table' then
            for _,keys in ipairs(key_groups) do
                ResolveKeys(mod,keys,ro,pf,target_table,true)
            end
        else
            ResolveKeys(mod,key_groups,ro,pf,target_table,true)
        end
    end

    function handlerProto:ResolveInfo(info)
        local profile = self.dbPath.db.profile
        local child, k

        for i = 1, #info do
            k = info[i]

            if i < #info then
                if not child then
                    child = profile[k]
                else
                    child = child[k]
                end
            end
        end

        return child or profile, k
    end

    function handlerProto:Get(info, ...)
        local p, k = self:ResolveInfo(info)
        if not p[k] then return end

        if info.type == 'color' then
            return unpack(p[k])
        else
            return p[k]
        end
    end

    function handlerProto:Set(info, val, ...)
        local p, k = self:ResolveInfo(info)

        if info.type == 'color' then
            p[k] = { val, ... }
        else
            p[k] = val
        end

        if self.dbPath.ConfigChanged then
            -- inform module of configuration change
            self.dbPath:ConfigChanged(info,p)
        end
    end

    function addon:GetOptionHandler(mod)
        if not handlers[mod] then
            handlers[mod] = setmetatable({ dbPath = mod }, handlerMeta)
        end

        return handlers[mod]
    end

    local options = {
        name = 'Kui Nameplates',
        handler = addon:GetOptionHandler(addon),
        type = 'group',
        get = 'Get',
        set = 'Set',
        args = {
            header = {
                type = 'header',
                name = '|cffff6666Many options currently require a UI reload to take effect',
                order = 0
            },
            reload = {
                name = 'Reload UI',
                type = 'execute',
                order = 1,
                func = ReloadUI
            },
            general = {
                name = 'General display',
                type = 'group',
                order = 10,
                args = {
                    combataction_hostile = {
                        name = 'Combat action: hostile',
                        desc = 'Automatically toggle hostile nameplates when entering/leaving combat. Setting will be inverted upon leaving combat.',
                        type = 'select',
                        values = {
                            'Do nothing', 'Hide enemies', 'Show enemies'
                        },
                        order = 0
                    },
                    combataction_friendly = {
                        name = 'Combat action: friendly',
                        desc = 'Automatically toggle friendly nameplates when entering/leaving combat. Setting will be inverted upon leaving combat.',
                        type = 'select',
                        values = {
                            'Do nothing', 'Hide friendlies', 'Show friendlies'
                        },
                        order = 1
                    },
                    bartexture = {
                        name = 'Status bar texture',
                        desc = 'The texture used for both the health and cast bars.',
                        type = 'select',
                        dialogControl = 'LSM30_Statusbar',
                        values = AceGUIWidgetLSMlists.statusbar,
                        order = 5
                    },
                    strata = {
                        name = 'Frame strata',
                        desc = 'The frame strata used by all frames, which determines what "layer" of the UI the frame is on. Untargeted frames are displayed at frame level 0 of this strata. Targeted frames are bumped to frame level 3.\n\nThis does not and can not affect the click-box of the frames, only their visibility.',
                        type = 'select',
                        values = StrataSelectList,
                        order = 6
                    },
                    raidicon_size = {
                        name = 'Raid icon size',
                        desc = 'Size of the raid marker texture on nameplates (skull, cross, etc)',
                        order = 7,
                        type = 'range',
                        bigStep = 1,
                        min = 1,
                        softMin = 10,
                        softMax = 100
                    },
                    raidicon_side = {
                        name = 'Raid icon position',
                        desc = 'Which side of the nameplate the raid icon should be displayed on',
                        type = 'select',
                        values = { 'LEFT', 'TOP', 'RIGHT', 'BOTTOM' },
                        order = 8
                    },
                    fixaa = {
                        name = 'Fix aliasing',
                        desc = 'Attempt to make plates appear sharper.\nWorks best when WoW\'s UI Scale system option is disabled and at larger resolutions.\n\n|cff88ff88This has a positive effect on performance.|r'..RELOAD_HINT,
                        type = 'toggle',
                        order = 10
                    },
                    compatibility = {
                        name = 'Stereo compatibility',
                        desc = 'Fix compatibility with stereo video. This has a negative effect on performance when many nameplates are visible.'..RELOAD_HINT,
                        type = 'toggle',
                        order = 20
                    },
                    highlight = {
                        name = 'Highlight',
                        desc = 'Highlight plates on mouse over.',
                        type = 'toggle',
                        order = 40
                    },
                    highlight_target = {
                        name = 'Highlight target',
                        desc = 'Also highlight the current target.',
                        type = 'toggle',
                        order = 50,
                        disabled = function(info)
                            return not addon.db.profile.general.highlight
                        end
                    },
                    glowshadow = {
                        name = 'Use glow as shadow',
                        desc = 'The frame glow is used to indicate threat. It becomes black when a unit has no threat status. Disabling this option will make it transparent instead.',
                        type = 'toggle',
                        order = 70,
                        width = 'full'
                    },
                    targetglow = {
                        name = 'Show target glow',
                        desc = 'Make your target\'s nameplate glow',
                        type = 'toggle',
                        order = 80
                    },
                    targetglowcolour = {
                        name = 'Target glow colour',
                        type = 'color',
                        order = 90,
                        hasAlpha = true,
                        disabled = function(info)
                            return not addon.db.profile.general.targetglow and not addon.db.profile.general.targetarrows
                        end
                    },
                    targetarrows = {
                        name = 'Show target arrows',
                        desc = 'Show arrows around your target\'s nameplate. They will inherit the colour of the target glow, set above.',
                        type = 'toggle',
                        order = 100,
                        width = 'full'
                    },
                    hheight = {
                        name = 'Health bar height',
                        desc = 'Note that these values do not affect the size or shape of the click-box, which cannot be changed.',
                        order = 110,
                        type = 'range',
                        step = 1,
                        min = 1,
                        softMin = 3,
                        softMax = 30
                    },
                    thheight = {
                        name = 'Trivial health bar height',
                        desc = 'Height of the health bar of trivial (small, low maximum health) units.',
                        order = 120,
                        type = 'range',
                        step = 1,
                        min = 1,
                        softMin = 3,
                        softMax = 30
                    },
                    width = {
                        name = 'Frame width',
                        order = 130,
                        type = 'range',
                        step = 1,
                        min = 1,
                        softMin = 25,
                        softMax = 220
                    },
                    twidth = {
                        name = 'Trivial frame width',
                        order = 140,
                        type = 'range',
                        step = 1,
                        min = 1,
                        softMin = 25,
                        softMax = 220
                    },
                    lowhealthval = {
                        name = 'Low health value',
                        desc = 'Low health value used by some modules, such as frame fading.',
                        type = 'range',
                        min = 1,
                        max = 100,
                        bigStep = 1,
                        order = 170
                    },
                }
            },
            fade = {
                name = 'Frame fading',
                type = 'group',
                order = 20,
                args = {
                    smooth = {
                        name = 'Smoothly fade',
                        desc = 'Smoothly fade plates in/out (fading is instant when disabled)',
                        type = 'toggle',
                        order = 0
                    },
                    fademouse = {
                        name = 'Fade in with mouse',
                        desc = 'Fade plates in on mouse-over',
                        type = 'toggle',
                        order = 5
                    },
                    fadeall = {
                        name = 'Fade all frames',
                        desc = 'Fade out all frames by default (rather than in)',
                        type = 'toggle',
                        order = 10
                    },
                    rules = {
                        name = 'Fading rules',
                        type = 'group',
                        inline = true,
                        order = 20,
                        args = {
                            avoidhostilehp = {
                                name = 'Don\'t fade hostile units at low health',
                                desc = 'Avoid fading hostile units which are at or below a health value, determined by low health value under general display options.',
                                type = 'toggle',
                                order = 1
                            },
                            avoidfriendhp = {
                                name = 'Don\'t fade friendly units at low health',
                                desc = 'Avoid fading friendly units which are at or below a health value, determined by low health value under general display options.',
                                type = 'toggle',
                                order = 2
                            },
                            avoidcast = {
                                name = 'Don\'t fade casting units',
                                desc = 'Avoid fading units which are casting.',
                                type = 'toggle',
                                order = 5
                            },
                            avoidraidicon = {
                                name = 'Don\'t fade units with raid icons',
                                desc = 'Avoid fading units which have a raid icon (skull, cross, etc).',
                                type = 'toggle',
                                order = 10
                            },
                        },
                    },
                    fadedalpha = {
                        name = 'Faded alpha',
                        desc = 'The alpha value to which plates fade out to',
                        type = 'range',
                        min = 0,
                        max = 1,
                        bigStep = .01,
                        isPercent = true,
                        order = 30
                    },
                    fadespeed = {
                        name = 'Smooth fade speed',
                        desc = 'Fade animation speed modifier (lower is faster)',
                        type = 'range',
                        min = 0,
                        softMax = 5,
                        order = 40,
                        disabled = function(info)
                            return not addon.db.profile.fade.smooth
                        end
                    },
                }
            },
            text = {
                name = 'Text',
                type = 'group',
                order = 30,
                args = {
                    level = {
                        name = 'Show levels',
                        desc = 'Show levels on nameplates',
                        width = 'full',
                        type = 'toggle',
                        order = 0
                    },
                    healthoffset = {
                        name = 'Health bar text offset',
                        desc = 'Vertical offset of the text on the top and bottom of the health bar: level, name and health.\n'..
                               'Note that the default value ends in .5 as this prevents jittering text.',
                        type = 'range',
                        bigStep = .5,
                        softMin = -10,
                        softMax = 20,
                        order = 10
                    },
                }
            },
            hp = {
                name = 'Health display',
                type = 'group',
                order = 40,
                args = {
                    reactioncolours = {
                        name = 'Reaction colours',
                        type = 'group',
                        inline = true,
                        order = 1,
                        args = {
                            hatedcol = {
                                name = 'Hostile',
                                type = 'color',
                                order = 1
                            },
                            neutralcol = {
                                name = 'Neutral',
                                type = 'color',
                                order = 2
                            },
                            friendlycol = {
                                name = 'Friendly',
                                type = 'color',
                                order = 3
                            },
                            tappedcol = {
                                name = 'Tapped',
                                type = 'color',
                                order = 4
                            },
                            playercol = {
                                name = 'Friendly player',
                                type = 'color',
                                order = 5
                            }
                        }
                    },
                    bar = {
                        name = 'Health bar',
                        type = 'group',
                        inline = true,
                        order = 20,
                        args = {
                            animation = {
                                name = 'Animation',
                                desc = 'Health bar animation style.'..RELOAD_HINT,
                                type = 'select',
                                values = HealthAnimationSelectList,
                                order = 0
                            }
                        }
                    },
                    text = {
                        name = 'Health text',
                        type = 'group',
                        inline = true,
                        order = 30,
                        disabled = function(info)
                            return addon.db.profile.hp.text.hp_text_disabled
                        end,
                        args = {
                            hp_text_disabled = {
                                name = 'Never show health text',
                                type = 'toggle',
                                order = 0,
                                disabled = false
                            },
                            mouseover = {
                                name = 'Mouseover & target only',
                                desc = 'Only show health text upon mouseover or on the current target',
                                type = 'toggle',
                                order = 10
                            },
                            hp_friend_max = {
                                name = 'Max. health friend',
                                desc = 'Health text to show on maximum health friendly units',
                                type = 'select',
                                values = HealthTextSelectList,
                                order = 20
                            },
                            hp_friend_low = {
                                name = 'Damaged friend',
                                desc = 'Health text to show on damaged friendly units',
                                type = 'select',
                                values = HealthTextSelectList,
                                order = 30
                            },
                            hp_hostile_max = {
                                name = 'Max. health hostile',
                                desc = 'Health text to show on maximum health hostile units',
                                type = 'select',
                                values = HealthTextSelectList,
                                order = 40
                            },
                            hp_hostile_low = {
                                name = 'Damaged hostile',
                                desc = 'Health text to show on damaged hostile units',
                                type = 'select',
                                values = HealthTextSelectList,
                                order = 50
                            },
                            hp_warning = {
                                name = '\n|cffff8888Due to limitations introduced in patch 6.2.2, the precise health values of nameplates is not known until the first mouseover/target of that frame. This value is cached, but it may not be entirely accurate.\n\nPercentage will be used as a fallback where health is not yet known.',
                                type = 'description',
                                fontSize = 'medium',
                                order = 60
                            }
                        }
                    }
                }
            },
            fonts = {
                name = 'Fonts',
                type = 'group',
                order = 50,
                args = {
                    options = {
                        name = 'Global font settings',
                        type = 'group',
                        inline = true,
                        order = 10,
                        args = {
                            font = {
                                name = 'Font',
                                desc = 'The font used for all text on nameplates',
                                type = 'select',
                                dialogControl = 'LSM30_Font',
                                values = AceGUIWidgetLSMlists.font,
                                order = 5
                            },
                            fontscale = {
                                name = 'Font scale',
                                desc = 'The scale of all fonts displayed on nameplates',
                                type = 'range',
                                min = 0.01,
                                softMax = 3,
                                order = 1
                            },
                            outline = {
                                name = 'Outline',
                                desc = 'Display an outline on all fonts',
                                type = 'toggle',
                                order = 10
                            },
                            monochrome = {
                                name = 'Monochrome',
                                desc = 'Don\'t anti-alias fonts',
                                type = 'toggle',
                                order = 15
                            },
                            onesize = {
                                name = 'Use one font size',
                                desc = 'Use the same font size for all strings. Useful when using a pixel font.',
                                type = 'toggle',
                                order = 20
                            },
                            noalpha = {
                                name = 'All fonts opaque',
                                desc = 'Use 100% alpha value on all fonts.'..RELOAD_HINT,
                                type = 'toggle',
                                order = 25
                            },
                        }
                    },
                    sizes = {
                        name = 'Font sizes',
                        type = 'group',
                        inline = true,
                        order = 20,
                        disabled = function()
                            return addon.db.profile.fonts.options.onesize
                        end,
                        args = {
                            desc = {
                                name = 'These are the default font sizes used by various modules. Their names may or may not match what they actually change.',
                                type = 'description',
                                fontSize = 'medium',
                                order = 1
                            },
                            name = {
                                name = 'Name',
                                type = 'range',
                                order = 10,
                                step = 1,
                                min = 1,
                                softMin = 1,
                                softMax = 30,
                                disabled = false
                            },
                            spellname = {
                                name = 'Spell name',
                                type = 'range',
                                order = 20,
                                step = 1,
                                min = 1,
                                softMin = 1,
                                softMax = 30
                            },
                            large = {
                                name = 'Large',
                                type = 'range',
                                order = 30,
                                step = 1,
                                min = 1,
                                softMin = 1,
                                softMax = 30
                            },
                            small = {
                                name = 'Small',
                                type = 'range',
                                order = 40,
                                step = 1,
                                min = 1,
                                softMin = 1,
                                softMax = 30
                            },
                        },
                    }
                }
            }
        }
    }

    function addon:ProfileChanged()
        -- call all configChangedListeners
        if addon.configChangedListener then
            addon:configChangedListener()
        end

        for _,module in addon:IterateModules() do
            if module.configChangedListener then
                module:configChangedListener()
            end
        end
    end

    local function ToggleModule(mod,v)
        if v then
            mod:Enable()
        else
            mod:Disable()
        end
    end

    -- module prototype
    addon.Prototype = {
        ConfigChanged = ConfigChangedSkeleton,
        AddConfigChanged = AddConfigChanged,
        AddGlobalConfigChanged = AddGlobalConfigChanged,
        Toggle = ToggleModule,
    }

    -- create an options table for the given module
    function addon:InitModuleOptions(module)
        if not module.GetOptions then return end
        local opts = module:GetOptions()
        local name = module.uiName or module.moduleName

        if module.configChangedListener then
            -- run listener upon initialisation
            module:configChangedListener()
        end

        if not module.ConfigChanged then
            -- this module wasn't created with the prototype, so mix it in now
            -- (legacy support)
            for k,v in pairs(addon.Prototype) do
                module[k] = v
            end
        end

        options.args[name] = {
            name = name,
            handler = self:GetOptionHandler(module),
            type = 'group',
            order = 50+(#handlers*10),
            get = 'Get',
            set = 'Set',
            args = opts
        }
    end

    function addon:FinalizeOptions()
        options.args['profiles'] = LibStub('AceDBOptions-3.0'):GetOptionsTable(self.db)
        options.args.profiles.order = -1

        AceConfig:RegisterOptionsTable('kuinameplates', options)
        AceConfigDialog:AddToBlizOptions('kuinameplates', category)

        self.FinalizeOptions = nil
    end

    -- apply prototype to addon
    for k,v in pairs(addon.Prototype) do
        addon[k] = v
    end
end
--------------------------------------------------------------- Slash command --
SLASH_KUINAMEPLATES1 = '/kuinameplates'
SLASH_KUINAMEPLATES2 = '/knp'

function SlashCmdList.KUINAMEPLATES()
    -- twice to workaround an issue introduced with 5.3
    InterfaceOptionsFrame_OpenToCategory(category)
    InterfaceOptionsFrame_OpenToCategory(category)
end
-- config handlers #############################################################
do
    -- cycle all frames and reset the health and castbar status bar textures
    local function UpdateAllBars()
        local _,frame
        for _,frame in pairs(addon.frameList) do
            if frame.kui.health then
                frame.kui.health:SetStatusBarTexture(addon.bartexture)
            end

            if frame.kui.highlight then
                frame.kui.highlight:SetTexture(addon.bartexture)
            end

            if frame.kui.castbar then
                frame.kui.castbar.bar:SetStatusBarTexture(addon.bartexture)
            end
        end
    end

    -- post db change hooks ####################################################
    -- n.b. this is better
    addon:AddConfigChanged({'fonts','options','font'}, function(v)
        addon.font = LSM:Fetch(LSM.MediaType.FONT, v)
        addon:UpdateAllFonts()
    end)

    addon:AddConfigChanged({'fonts','options','outline'}, nil, function(f,v)
        for _, fontObject in pairs(f.fontObjects) do
            kui.ModifyFontFlags(fontObject, v, 'OUTLINE')
        end
    end)

    addon:AddConfigChanged({'fonts','options','monochrome'}, nil, function(f,v)
        for _, fontObject in pairs(f.fontObjects) do
            kui.ModifyFontFlags(fontObject, v, 'MONOCHROME')
        end
    end)

    addon:AddConfigChanged(
        {
            {'fonts','options','fontscale'},
            {'fonts','options','onesize'},
            {'fonts','sizes'}
        },
        function()
            addon:ScaleFontSizes()
        end,
        function(f)
            for _, fontObject in pairs(f.fontObjects) do
                if fontObject.size then
                    fontObject:SetFontSize(fontObject.size)
                end
            end
        end
    )

    addon:AddConfigChanged({'text','healthoffset'},
        function()
            addon.sizes.tex.healthOffset = addon.db.profile.text.healthoffset
        end,
        function(f)
            addon:UpdateHealthText(f, f.trivial)
            addon:UpdateLevel(f, f.trivial)
            addon:UpdateName(f, f.trivial)
        end
    )

    addon:AddConfigChanged({'hp','text'}, nil, function(f)
        if f:IsShown() then
            f:OnHealthValueChanged()
        end
    end)
    addon:AddConfigChanged({'hp','text','mouseover'}, nil, function(f,v)
        if not v and f.health and f.health.p then
            f.health.p:Show()
        end
    end)

    addon:AddConfigChanged({'general','bartexture'}, function(v)
        addon.bartexture = LSM:Fetch(LSM.MediaType.STATUSBAR, v)
        UpdateAllBars()
    end)

    addon:AddConfigChanged({'general','targetglowcolour'}, nil, function(f,v)
        if f.targetGlow then
            f.targetGlow:SetVertexColor(unpack(v))
        end

        if f.targetArrows then
            f.targetArrows.left:SetVertexColor(unpack(v))
            f.targetArrows.right:SetVertexColor(unpack(v))
        end
    end)

    addon:AddConfigChanged({'general','strata'}, nil, function(f,v)
        f:SetFrameStrata(v)
    end)

    do
        local function UpdateFrameSize(frame)
            addon:UpdateBackground(frame, frame.trivial)
            addon:UpdateHealthBar(frame, frame.trivial)
            addon:UpdateName(frame, frame.trivial)
            addon:UpdateRaidIcon(frame)
            frame:SetCentre()
        end

        addon:AddConfigChanged(
            {
                {'general','width'},
                {'general','twidth'},
                {'general','hheight'},
                {'general','thheight'},
                {'general','raidicon_size'},
                {'general','raidicon_side'},
            },
            addon.UpdateSizesTable,
            UpdateFrameSize
        )
    end
end
