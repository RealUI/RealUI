--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
------------------------------------------------------------------ Ace config --
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

--------------------------------------------------------------- Options table --
do
	local handlers = {}
	local handlerProto = {}
	local handlerMeta = { __index = handlerProto }

	-- called by handler:Set when configuration is changed
	local function ConfigChangedSkeleton(mod, key, profile)
		if mod.configChangedFuncs.runOnce and
		   mod.configChangedFuncs.runOnce[key]
		then
			-- call runOnce function
			mod.configChangedFuncs.runOnce[key](profile[key])
		end

		if mod.configChangedFuncs[key] then
			-- iterate frames and call
			for _, frame in pairs(addon.frameList) do
				mod.configChangedFuncs[key](frame.kui, profile[key])
			end
		end
	end

	function handlerProto:ResolveInfo(info)
		local p = self.dbPath.db.profile
	
		local child, k
		for i = 1, #info do
			k = info[i]

			if i < #info then
				if not child then
					child = p[k]
				else
					child = child[k]
				end
			end
		end

		return child or p, k
	end

	function handlerProto:Get(info, ...)
		local p, k = self:ResolveInfo(info)

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
			self.dbPath:ConfigChanged(k, p)
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
				name = '|cffff0000Many options currently require a UI reload to take effect.|r',
				order = 0
			},
			general = {
				name = 'General display',
				type = 'group',
				order = 1,
				args = {
					combat = {
						name = 'Auto toggle in combat',
						desc = 'Automatically toggle on/off hostile nameplates upon entering/leaving combat',
						type = 'toggle',
						order = 0
					},
					highlight = {
						name = 'Highlight',
						desc = 'Highlight plates on mouse over (when not targeted)',
						type = 'toggle',
						order = 1
					},
					fixaa = {
						name = 'Fix aliasing',
						desc = 'Attempt to make plates appear sharper. Has a positive effect on FPS, but will make plates appear a bit "loose", especially at low frame rates. Works best when uiscale is disabled and at larger resolutions (lower resolutions automatically downscale the interface regardless of uiscale setting).\n\n|cffff0000UI reload required to take effect.',
						type = 'toggle',
						width = 'double',
						order = 3
					},
					targetglow = {
						name = 'Show target glow',
						desc = 'Make your target\'s nameplate glow',
						type = 'toggle',
						order = 4
					},
					targetglowcolour = {
						name = 'Target glow colour',
						type = 'color',
						order = 5,
						hasAlpha = true,
						disabled = function(info)
							return not addon.db.profile.general.targetglow
						end
					},
					hheight = {
						name = 'Health bar height',
						desc = 'Note that these values do not affect the size or shape of the click-box, which cannot be changed.',
						order = 6,
						type = 'range',
						step = 1,
						min = 1,
						softMin = 7,
						softMax = 20
					},
					thheight = {
						name = 'Trivial health bar height',
						desc = 'Height of the health bar of trivial (small, low maximum health) units.',
						order = 7,
						type = 'range',
						step = 1,
						min = 1,
						softMin = 6,
						softMax = 15
					},
				}
			},
			fade = {
				name = 'Frame fading',
				type = 'group',
				order = 2,
				args = {
					fadedalpha = {
						name = 'Faded alpha',
						desc = 'The alpha value to which plates fade out to',
						type = 'range',
						min = 0,
						max = 1,
						isPercent = true,
						order = 4
					},
					fademouse = {
						name = 'Fade in with mouse',
						desc = 'Fade plates in on mouse-over',
						type = 'toggle',
						order = 1
					},
					fadeall = {
						name = 'Fade all frames',
						desc = 'Fade out all frames by default (rather than in)',
						type = 'toggle',
						order = 2
					},
					smooth = {
						name = 'Smoothly fade',
						desc = 'Smoothly fade plates in/out (fading is instant when disabled)',
						type = 'toggle',
						order = 0
					},
					fadespeed = {
						name = 'Smooth fade speed',
						desc = 'Fade animation speed modifier (lower is faster)',
						type = 'range',
						min = 0,
						softMax = 5,
						order = 3,
						disabled = function(info)
							return not addon.db.profile.fade.smooth
						end
					}
				}
			},
			text = {
				name = 'Text',
				type = 'group',
				order = 3,
				args = {
					level = {
						name = 'Show levels',
						desc = 'Show levels on nameplates',
						type = 'toggle',
						order = 2
					},
					friendlyname = {
						name = 'Friendly name text colour',
						desc = 'The colour of names of friendly units',
						type = 'color',
						order = 4,
					},
					enemyname = {
						name = 'Enemy name text colour',
						desc = 'The colour of names of enemy units',
						type = 'color',
						order = 5,
					},
				}
			},
			hp = {
				name = 'Health display',
				type = 'group',
				order = 4,
				args = {
					showalt = {
						name = 'Show contextual health',
						desc = 'Show alternate (contextual) health values as well as main values',
						type = 'toggle',
						order = 1
					},
					mouseover = {
						name = 'Show on mouse over',
						desc = 'Show health only on mouse over or on the targeted plate',
						type = 'toggle',
						order = 2
					},
					smooth = {
						name = 'Smooth health bar',
						desc = 'Smoothly animate health bar value updates',
						type = 'toggle',
						width = 'double',
						order = 3
					},
					friendly = {
						name = 'Friendly health format',
						desc = 'The health display pattern for friendly units',
						type = 'input',
						pattern = '([<=]:[dmcpb];)',
						order = 5
					},
					hostile = {
						name = 'Hostile health format',
						desc = 'The health display pattern for hostile or neutral units',
						type = 'input',
						pattern = '([<=]:[dmcpb];)',
						order = 6
					}
				}
			},
			tank = {
				name = 'Tank mode',
				type = 'group',
				order = 5,
				args = {
					enabled = {
						name = 'Enable tank mode',
						desc = 'Change the colour of a plate\'s health bar and border when you have threat on its unit',
						type = 'toggle',
						order = 0
					},
					barcolour = {
						name = 'Bar colour',
						desc = 'The bar colour to use when you have threat',
						type = 'color',
						order = 1
					},
					glowcolour = {
						name = 'Glow colour',
						desc = 'The glow (border) colour to use when you have threat',
						type = 'color',
						hasAlpha = true,
						order = 2
					},
				}
			},
			fonts = {
				name = 'Fonts',
				type = 'group',
				args = {
					options = {
						name = 'Global font settings',
						type = 'group',
						inline = true,
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
								softMax = 2,
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
								desc = 'Use 100% alpha value on all fonts.\n|cffff0000Like a lot of options, this requires a UI reload.|r',
								type = 'toggle',
								order = 25
							},
						}
					},
				}
			},
			reload = {
				name = 'Reload UI',
				type = 'execute',
				width = 'triple',
				order = 99,
				func = ReloadUI
			},
		}
	}

	-- create module.ConfigChanged function
	-- TODO cycle these when changing profiles (or something)
	function addon:CreateConfigChangedListener(module)
		if module.configChangedFuncs and not module.ConfigChanged then
			module.ConfigChanged = ConfigChangedSkeleton
		end
	end

	-- create an options table for the given module
	function addon:InitModuleOptions(module)
		if not module.GetOptions then return end
		local opts = module:GetOptions()
		local name = module.uiName or module.moduleName

		self:CreateConfigChangedListener(module)

		options.args[name] = {
			name = name,
			handler = self:GetOptionHandler(module),
			type = 'group',
			order = 50+#handlers,
			get = 'Get',
			set = 'Set',
			args = opts
		}
	end

	AceConfig:RegisterOptionsTable('kuinameplates', options)
	AceConfigDialog:AddToBlizOptions('kuinameplates', 'Kui Nameplates')
end

--------------------------------------------------------------- Slash command --
SLASH_KUINAMEPLATES1 = '/kuinameplates'
SLASH_KUINAMEPLATES2 = '/knp'

function SlashCmdList.KUINAMEPLATES()
	InterfaceOptionsFrame_OpenToCategory('Kui Nameplates')
end
