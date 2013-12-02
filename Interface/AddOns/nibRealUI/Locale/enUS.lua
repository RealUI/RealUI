local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "enUS", true)

if L then

L["Enabled"] = "Enabled"
L["Type /realui"] = "Type %s to configure UI style, positions and settings."
L["Combat Lockdown"] = "Combat Lockdown"
L["Layout will change after you leave combat."] = "Layout will change after you leave combat."
L["Info Line currency tracking will update after UI Reload (/rl)"] = "Info Line currency tracking will update after UI Reload (/rl)"

-- Installation
L["INSTALL"] = "CLICK TO INSTALL"
L["Version"] = "Version"

L["RealUI Mini Patch"] = "RealUI Mini Patch"
L["RealUI's settings have been updated."] = "RealUI's settings have been updated."
L["Do you wish to apply the latest RealUI settings?"] = "Do you wish to apply the latest RealUI settings?"

L["Confirm reset RealUI?\n\nAll user settings will be lost."] = "Are you sure you wish to reset RealUI?\n\nAll user settings will be lost."
L["Reload UI now to apply these changes?"] = "Reload UI now to apply these changes?"
L["You need to Reload the UI for changes to take effect. Reload Now?"] = "You need to Reload the UI for changes to take effect. Reload Now?"

-- Power Mode
L["PowerModeEconomy"] =
[[|cff0099ffRealUI|r|cffffffff: Economy power mode active.
This mode will schedule graphical updates at a slower than normal rate.
May help increase performance on low-end PCs.]]

L["PowerModeNormal"] =
[[|cff0099ffRealUI|r|cffffffff: Normal power mode active.
This mode will schedule graphical updates at a normal rate.]]

L["PowerModeTurbo"] =
[[|cff0099ffRealUI|r|cffffffff: Turbo power mode active.
This mode will schedule graphical updates at a fast rate, making animations across the UI smoother.
This will increase CPU usage.]]

-- RealUI Config
L["RealUI Config"] = "RealUI Config"
L["Position"] = "Position"
L["Positions"] = "Positions"
L["Vertical"] = "Vertical"
L["Horizontal"] = "Horizontal"
L["Width"] = "Width"
L["Height"] = "Height"

L["AddOn Control"] = "AddOn Control"

L["Untick"] = "Untick"
L["Use"] = "Use"	-- i.e Use General Colors
L["to set"] = "to set"
L["custom colors"] = "custom colors"

L["Fonts"] = "Fonts"
L["Chat Font Outline"] = "Chat Font Outline"
L["FS:Hybrid"] = "Hybrid"	-- Mixed
L["Use small fonts"] = "Use small fonts"
L["Use a mix of small and large fonts"] = "Use a mix of small and large fonts"
L["Use large fonts"] = "Use large fonts"

L["Latency"] = "Latency"
L["Info Line"] = "Info Line"
L["Bars"] = "Bars"	-- Class Color Health "Bars"

L["Link Layouts"] = "Link Layouts"
L["Use same settings between DPS/Tank and Healing layouts."] = "Use same settings between DPS/Tank and Healing layouts."
L["Use Large HuD"] = "Use Large HuD"
L["Increases size of key HuD elements (Unit Frames, etc)."] = "Increases size of key HuD elements (Unit Frames, etc)."
L["Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."] = "Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."

L["RealUI Control"] = "RealUI Control"
L["Allow RealUI to control the action bars."] = "Allow RealUI to control the action bars."
L["Check to allow RealUI to control the Stance Bar's position."] = "Check to allow RealUI to control the Stance Bar's position."
L["Check to allow RealUI to control the Pet Bar's position."] = "Check to allow RealUI to control the Pet Bar's position."
L["Check to allow RealUI to control the Extra Action Button's position."] = "Check to allow RealUI to control the Extra Action Button's position."
L["Move Stance Bar"] = "Move Stance Bar"
L["Move Pet Bar"] = "Move Pet Bar"
L["Move Extra Button"] = "Move Extra Button"
L["Sizes"] = "Sizes"
L["Buttons"] = "Buttons"
L["Padding"] = "Padding"
L["Center"] = "Center"
L["Bottom"] = "Bottom"
L["Left"] = "Left"
L["Right"] = "Right"
L["Stance Bar"] = "Stance Bar"
L["Pet Bar"] = "Pet Bar"

L["Cannot open RealUI Configuration while in combat."] = "Cannot open RealUI Configuration while in combat."
L["Note: Bartender settings"] = "Note: Use Advanced Settings to open Bartender's configuration window.\n          Untick |cff30d0ffRealUI Control|r if you want to change settings that\n          RealUI controls (position, size, buttons, padding)."
L["Hint: Hold down Ctrl to view action bars."] = "Hint: Hold down Ctrl to view action bars."
L["Note: After changing bar positions..."] = "Note: After changing settings, make sure to check the Positions options\n          to make sure no UI elements are overlapping each other."

L["Allow RealUI to control STR position settings."] = "Allow RealUI to control %s's position."
L["Layout"] = "Layout"
L["Allow RealUI to control STR layout settings."] = "Allow RealUI to control %s's layout settings."
L["Style"] = "Style"
L["Allow RealUI to style STR."] = "Allow RealUI to style %s (requires UI reload: /rl)"

L["Horizontal Groups"] = "Horizontal Groups"
L["Show Pet Frames"] = "Show Pet Frames"
L["Show While Solo"] = "Show While Solo"
L["Note: Grid2 settings"] = "Note: Use Advanced Settings to open Grid2's configuration window.\n          Untick |cff30d0ffRealUI Control|r settings if you want to change settings\n          that RealUI controls (position, layout, borders)."

L["Element Settings"] = "Element Settings"
L["Choose UI element to configure."] = "Choose UI element to configure."
L["(use mouse-wheel for precision adjustment of sliders)"] = "(use mouse-wheel for precision adjustment of sliders)"

L["Reverse Bar"] = "Reverse Bar"
L["Reverse the direction of the cast bar."] = "Reverse the direction of the cast bar."

L["Create New Tracker"] = "Create New Tracker"
L["Disable Selected Tracker"] = "Disable Selected Tracker"
L["Enable Selected Tracker"] = "Enable Selected Tracker"
L["Are you sure you wish to reset Tracking information to defaults?"] = "Are you sure you wish to reset Tracking information to defaults?"
L["Tracker Options"] = "Tracker Options"
L["Choose Tracker type."] = "Choose Tracker type."
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Spell Name or ID"] = "Spell Name or ID"
L["Note: Spell Name or ID must match the spell you wish to track exactly. Capitalization and spaces matter."] = "Note: Spell Name or ID must match the spell you wish to track exactly.\nCapitalization and spaces matter.\nTo track multiple spells, use Spell IDs and separate via commas (i.e 1122,2233,3344)."
L["Static"] = "Static"
L["Static Trackers remain visible and in the same location."] = "Static Trackers remain visible and in the same location."
L["Min Level (0 = ignore)"] = "Min Level (0 = ignore)"
L["Ignore Spec"] = "Ignore Spec"
L["Show tracker regardless of current specialization"] = "Show tracker regardless of current specialization"
L["Cat"] = "Cat"
L["Bear"] = "Bear"
L["Moonkin"] = "Moonkin"
L["Human"] = "Human"
L["Hide Out-Of-Combat"] = "Hide Out-Of-Combat"
L["Force this Tracker to hide OOC, even if it's active."] = "Force this Tracker to hide OOC, even if it's active."
L["Hide Stack Count"] = "Hide Stack Count"
L["Don't show Buff/Debuff stack count on this tracker."] = "Don't show Buff/Debuff stack count on this tracker."

L["Indicator size"] = "Indicator Size"
L["Indicator padding"] = "Indicator Padding"
L["Inactive indicator opacity"] = "Inactive Indicator Opacity"
L["Show in combat"] = "Show in combat"
L["Show Indicators when you are in combat"] = "Show Indicators when you are in combat"
L["Show w/ hostile"] = "Show w/ hostile"
L["Show Indicators when you have an attackable target"] = "Show Indicators when you have an attackable target"
L["Show in PvE"] = "Show in PvE"
L["Show Indicators when you are in a PvE instance"] = "Show Indicators when you are in a PvE instance"
L["Show in PvP"] = "Show in PvP"
L["Show Indicators when you are in a PvP instance"] = "Show Indicators when you are in a PvP instance"
L["Vertical Cooldown"] = "Vertical Cooldown"
L["Use vertical cooldown indicator instead of spiral"] = "Use vertical cooldown indicator instead of spiral"

L["Stripe Opacity"] = "Stripe Opacity"
L["Window Opacity"] = "Window Opacity"

-- Info Line
L["XP/Rep"] = "XP/Rep"
L["SysInfo"] = "SysInfo"
L["Spec Changer"] = "Spec Changer"
L["Layout Changer"] = "Layout Changer"
L["Meter Toggle"] = "Meter Toggle"

L["Menu"] = "Menu"

L["Meters"] = "Meters"

L["Stat"] = "Stat"
L["Cur"] = "Cur"
L["Max"] = "Max"
L["Min"] = "Min"
L["Avg"] = "Avg"

L["In"] = "In"
L["Out"] = "Out"
L["kbps"] = "kbps"
L["ms"] = "ms"
L["FPS"] = "FPS"

L["Date"] = "Date"
L["Wintergrasp Time Left"] = "Wintergrasp Time Left"
L["No Wintergrasp Time Available"] = "No Wintergrasp Time Available"
L["Tol Barad Time Left"] = "Tol Barad Time Left:"
L["No Tol Barad Time Available"] = "No Tol Barad Time Available"
L["Pending Invites:"] = "Pending Invites:"

L["Layout Changer"] = "Layout Changer"
L["Current Layout:"] = "Current Layout:"
L["DPS/Tank"] = "DPS/Tank"
L["Healing"] = "Healing"

L["Meter Toggle"] = "Meter Toggle"
L["Active Meters:"] = "Active Meters:"

L["Start"] = "Start"

L["Current"] = "Current"
L["Remaining"] = "Remaining"

L["Honor Points"] = "HP"
L["Conquest Points"] = "CP"
L["Justice Points"] = "JP"
L["Valor Points"] = "VP"
L["Updated"] = "Upd."
L["To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"] = "To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"

L["Faction not set"] = "Faction not set"

L["<Click> to switch between"] = "<Click> to switch between"
L["XP and Rep display."] = "XP and Rep display."
L["<Click> to switch currency displayed."] = "<Click> to switch currency displayed."
L["<Alt+Click> to erase highlighted character data."] = "<Alt+Click> to erase highlighted character data."
L["<Shift+Click> to reset weekly caps."] = "<Shift+Click> to reset weekly caps."
L["Note: Weekly caps will reset upon loading currency data"] = "Note: Weekly caps will reset upon loading currency data"
L["on a character whose weekly caps have reset."] = "on a character whose weekly caps have reset."
L["<Click> to whisper, <Alt+Click> to invite."] = "<Click> to whisper, <Alt+Click> to invite."

L["Stat Display"] = "Stat Display"
L["<Spec Click> to change talent specs."] = "<Spec Click> to change talent specs."
L["<Equip Click> to equip."] = "<Equip Click> to equip."
L["<Equip Ctl+Click> to assign to "] = "<Equip Ctl+Click> to assign to "
L["<Equip Alt+Click> to assign to "] = "<Equip Alt+Click> to assign to "
L["<Equip Shift+Click> to unassign."] = "<Equip Shift+Click> to unassign."
L["<Stat Click> to configure."] = "<Stat Click> to configure."

L["<Click> to cycle through equipment sets."] = "<Click> to cycle through equipment sets."
L["<Click> to show calendar."] = "<Click> to show calendar."
L["<Shift+Click> to show timer."] = "<Shift+Click> to show timer."
L["<Click> to change layouts."] = "<Click> to change layouts."
L["<Alt+Click> to change resolution."] = "<Alt+Click> to change resolution."
L["<Click> to toggle meters."] = "<Click> to toggle meters."

-- HuD Config
L["Instructions"] = "Instructions"
L["Load Defaults"] = "Load Defaults"
L["Show UI Elements"] = "Show UI Elements"
L["Hide UI Elements"] = "Hide UI Elements"
L["HuD Instructions"] = [[
		|cffffa500Step 1:|r Click |cff30ff30Show UI Elements|r to aid you in repositioning the UI elements.
		|cffffa500Step 2:|r Use the |cff30ff30Element Settings|r window to reposition and resize individual UI elements.
		|cffffa500Step 3:|r When finished, click |cff30ff30Hide UI Elements|r.
	]]

-- World Boss Info
L["Galleon"]="Galleon"
L["Sha Of Anger"]="Sha Of Anger"
L["Nalak"]="Nalak"
L["Oondasta"]="Oondasta"
L["Celestials"]="Celestials"
L["Ordos"]="Ordos"

L["World Boss Done"]="\124cff00ff00Done\124r"
L["World Boss Not Done"]="\124cffff0000Not Done\124r"

end