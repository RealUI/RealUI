local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "enUS", true, true)
if not L then return end

--{{{ General options
L["GRID2_WELCOME"] = "Welcome to Grid2"
L["GRID2_DESC"]  = "Grid2 is a party&raid unit frame addon. Grid2 displays health and all relevant information about the party&raid members in a more comprehensible manner."

L["General Settings"] = true

L["statuses"] = "Statuses"
L["indicators"] ="Indicators"

L["Frames"] = true
L["frame"] = true

L["Default Font"] = true

L["Invert Bar Color"] = true
L["Swap foreground/background colors on bars."] = true

L["Background Color"] = true
L["Sets the background color of each unit frame"] = true

L["Mouseover Highlight"] = true
L["Toggle mouseover highlight."] = true

L["Show Tooltip"] = true
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = true
L["Always"] = true
L["Never"] = true
L["OOC"] = true

L["Background Texture"] = true
L["Select the frame background texture."] = true

L["Inner Border Size"] = true
L["Sets the size of the inner border of each unit frame"] = true

L["Inner Border Color"] = true
L["Sets the color of the inner border of each unit frame"] = true

L["Frame Width"] = true
L["Adjust the width of each unit's frame."] = true

L["Frame Height"] = true
L["Adjust the height of each unit's frame."] = true

L["Orientation of Frame"] = true
L["Set frame orientation."] = true
L["VERTICAL"] = true
L["HORIZONTAL"] = true

L["Orientation of Text"] = true
L["Set frame text orientation."] = true

L["Show Frame"] = true
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = true
L["Always"] = true
L["Grouped"] = true
L["Raid"] = true

L["Layout Anchor"] = true
L["Sets where Grid is anchored relative to the screen."] = true

L["Horizontal groups"] = true
L["Switch between horzontal/vertical groups."] = true
L["Clamped to screen"] = true
L["Toggle whether to permit movement out of screen."] = true
L["Frame lock"] = true
L["Locks/unlocks the grid for movement."] = true
L["Click through the Grid Frame"] = true
L["Allows mouse click through the Grid Frame."] = true

L["Display"] = true
L["Padding"] = true
L["Adjust frame padding."] = true
L["Spacing"] = true
L["Adjust frame spacing."] = true
L["Scale"] = true
L["Adjust Grid scale."] = true

L["Group Anchor"] = true
L["Position and Anchor"] = true
L["Sets where groups are anchored relative to the layout frame."] = true
L["Resets the layout frame's position and anchor."] = true

L["Frame Strata"] = true
L["Sets the strata in which the layout frame should be layered."] = true
L["BACKGROUND"] = true
L["LOW"] = true
L["MEDIUM"] = true
L["HIGH"] = true

--blink
L["Misc"] = true
L["blink"] = true
L["Blink effect"] = true
L["Select the type of Blink effect used by Grid2."] = true
L["None"] = true
L["Blink"] = true
L["Flash"] = true
L["Blink Frequency"] = true
L["Adjust the frequency of the Blink effect."] = true

-- text formatting
L["Text Formatting"] = true
L["Duration Format"] = true
L["Examples:\n(%d)\n%d seconds"] = true
L["Duration+Stacks Format"] = true
L["Examples:\n%d/%s\n%s(%d)"] = true
L["Display tenths of a second"] = true
L["When duration<1sec"] = true

-- misc
L["Blizzard Raid Frames"] = true
L["Hide Blizzard Raid Frames on Startup"] = true

-- debugging & maintenance
L["debugging"] = true
L["Module debugging menu."] = true
L["Debug"]= true
L["Reset"] = true
L["Reset and ReloadUI."] = true
L["Reset Setup"] = true
L["Reset current setup and ReloadUI."] = true
L["Reset Indicators"] = true
L["Reset indicators to defaults."] = true
L["Reset Locations"] = true
L["Reset locations to the default list."] = true
L["Reset to defaults."] = true
L["Reset Statuses"] = true
L["Reset statuses to defaults."] = true

L["Warning! This option will delete all settings and profiles, are you sure ?"]= true

L["About"] = true

--{{{ Layouts options
L["Layout"] = true
L["Layouts"] = true
L["layout"] = true
L["Layouts for each type of groups you're in."] = true
L["Select which layout to use for: "] = true
L["Layout editor"] = true
L["Use Raid layout"] = true
L["Solo"] = true
L["Party"] = true
L["Arena"] = true
L["Raid"] = true
L["PvP Instances (BGs)"] = true
L["LFR Instances"] = true
L["Flexible raid Instances (normal/heroic)"] = true
L["Mythic raids Instances"] = true
L["Other raids Instances"] = true
L["In World"] = true
L["Layout Settings"] = true
L["Solo Layout"] = true
L["Party Layout"] = true
L["Raid %s Layout"] = true
L["Select which layout to use for %s person raids."] = true
L["Battleground Layout"] = true
L["Select which layout to use for battlegrounds."] = true
L["Arena Layout"] = true
L["Select which layout to use for arenas."] = true
L["Test"] = true
L["Test the layout."] = true
L["Select Layout"] = true
L["New Layout Name"] = true
L["Delete selected layout"] = true
L["Refresh"] = true
L["Refresh the Layout"] = true
L["Toggle for vehicle"] = true
L["When the player is in a vehicle replace the player frame with the vehicle frame."] = true
L["Header"] = true
L["Type of units to display"] = true
L["Columns"] = true
L["Maximum number of columns to display"] = true
L["Units/Column"] = true
L["Maximum number of units per column to display"] = true
L["First group"] = true
L["First group to display"] = true
L["Last Group"] = true
L["Last group to display"] = true
L["Group by"] = true
L["Sort by"] = true
L["Action"] = true
L["all"] = true
L["Class"] = true
L["Group"] = true
L["Role"] = true
L["Name"] = true 
L["Index"] = true
L["party"] = true
L["raid"] = true
L["partypet"] = true
L["raidpet"] = true
L["Insert"] = true
L["Copy"] = true

--{{{ Miscelaneous
L["New"] = true
L["Order"] = true
L["Delete"] = true
L["Color"] = true
L["Color %d"] = true
L["Color for %s."] = true
L["Font"] = true
L["Font Border"] = true
L["Thin"] = true
L["Thick"] = true
L["Soft"] = true
L["Sharp"] = true
L["Adjust the font settings"] = true
L["Border Texture"] = true
L["Adjust the border texture."] = true
L["Border"] = true
L["Border Color"] = true
L["Background"] = true
L["Enable Background"] = true
L["Adjust border color and alpha."] = true
L["Adjust background color and alpha."] = true
L["Opacity"] = true
L["Set the opacity."] = true
L["<CharacterOnlyString>"] = true
L["Options for %s."]= true
L["Delete this element"] = true

--{{{ Indicator management
L["New Indicator"] = true
L["Create Indicator"] = true
L["Create a new indicator."] = true
L["Name of the new indicator"] = true
L["Enable or disable test mode for indicators"] = true
L["Appearance"] = true
L["Adjust the border size of the indicator."] = true
L["Stack Text"] = true
L["Disable Stack Text"] = true
L["Disable Cooldown"] = true
L["Disable the Cooldown Frame"] = true
L["Reverse Cooldown"] = true
L["Set cooldown to become darker over time instead of lighter."] = true
L["Cooldown"]= true
L["Text Location"]= true
L["Disable OmniCC"]= true
L["Animations"] = true 
L["Enable animation"] = true
L["Turn on/off zoom animation of icons."] = true
L["Duration"] = true
L["Sets the duration in seconds."] = true
L["Scale"] = true
L["Sets the zoom factor."] = true
 
L["Type"] = true
L["Type of indicator"] = true
L["Type of indicator to create"] = true
L["Change type"] = true
L["Change the indicator type"] = true

L["Text Length"] = true
L["Maximum number of characters to show."] = true
L["Font Size"] = true
L["Adjust the font size."] = true
L["Size"] = true
L["Adjust the size of the indicator."] = true
L["Width"] = true
L["Adjust the width of the indicator."] = true
L["Height"] = true
L["Adjust the height of the indicator."] = true
L["Rectangle"] = true
L["Allows to independently adjust width and height."] = true
L["Use Status Color"] = true
L["Always use the status color for the border"] = true

L["Frame Texture"] = true
L["Adjust the frame texture."] = true

L["Show stack"] = true
L["Show the number of stacks."] = true
L["Show duration"] = true
L["Show the time remaining."] = true
L["Show elapsed time"] = true
L["Show the elapsed time."] = true
L["Show percent"] = true
L["Show percent value"] = true

L["Orientation of the Bar"] = true
L["Set status bar orientation."] = true
L["DEFAULT"]= true
L["Frame Level"] = true
L["Bars with higher numbers always show up on top of lower numbers."] = true
L["Bar Width"] = true
L["Choose zero to set the bar to the same width as parent frame"] = true
L["Bar Height"] = true
L["Choose zero to set the bar to the same height as parent frame"] = true
L["Anchor to"] = true
L["Anchor the indicator to the selected bar."] = true
L["Reverse Fill"] = true
L["Fill the bar in reverse."] = true

L["Border Size"] = true
L["Adjust the border of each unit's frame."] = true
L["Border Background Color"] = true
L["Adjust border background color and alpha."] = true
L["Border separation"] = true
L["Adjust the distance between the border and the frame content."] = true

L["Select statuses to display with the indicator"] = true
L["Available Statuses"] = true
L["Available statuses you may add"] = true
L["Current Statuses"] = true
L["Current statuses in order of priority"] = true
L["Move the status higher in priority"] = true
L["Move the status lower in priority"] = true

L["indicator"] = true

-- indicator types
L["icon"] = true
L["square"] = true
L["text"] = true
L["bar"] = true

-- indicators
L["corner-top-left"]= true
L["corner-top-right"]= true
L["corner-bottom-right"]= true
L["corner-bottom-left"]= true
L["side-top"]= true
L["side-right"]= true
L["side-bottom"]= true
L["side-left"]= true
L["text-up"]= true
L["text-down"]= true
L["icon-left"]= true
L["icon-center"]= true
L["icon-right"]= true

-- locations
L["CENTER"] = true
L["TOP"] = true
L["BOTTOM"] = true
L["LEFT"] = true
L["RIGHT"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true

L["location"] = true

L["Location"] = true
L["Align my align point relative to"] = true
L["Align Point"] = true
L["Align this point on the indicator"] = true
L["X Offset"] = true
L["X - Horizontal Offset"] = true
L["Y Offset"] = true
L["Y - Vertical Offset"] = true

--{{{ Statuses
L["-value"] = "(value)"
L["-color"] = ":color"
L["-mine"] = ":mine"
L["-not-mine"] = ":not mine"
L["buff-"] = "buff: "
L["debuff-"] = "debuff: "
L["color-"] = "color: "

L["status"] = true

L["buff"] = true
L["debuff"] = true
L["debuffType"] = true

L["New Buff"] = true
L["New Debuff"] = true
L["New Color"] = true
L["New Status"] = true
L["Delete Status"] = true
L["Create a new status."] = true
L["Create Buff"] = true
L["Create Debuff"] = true
L["Create Color"] = true

L["Threshold"] = true
L["Thresholds"] = true
L["Threshold at which to activate the status."] = true

L["available statuses"] = true

-- buff & debuff statuses management
L["Auras"] = true
L["Buffs"] = true
L["Debuffs"] = true
L["Colors"] = true
L["Health&Heals"] = true
L["Mana&Power"] = true
L["Combat"] = true
L["Targeting&Distances"] = true
L["Raid&Party Roles"] = true
L["Miscellaneous"] = true

L["Show if mine"] = true
L["Show if not mine"] = true
L["Show if missing"] = true
L["Display status only if the buff is not active."] = true
L["Display status only if the buff was cast by you."] = true
L["Display status only if the buff was not cast by you."] = true
L["Color count"]= true
L["Select how many colors the status must provide."]= true
L["You can include a descriptive prefix using separators \"@#>\""]= true
L["examples: Druid@Regrowth Chimaeron>Low Health"]= true
L["Threshold to activate Color"] = true
L["Track by SpellId"] = true
L["Track by spellId instead of aura name"] = true
L["Assigned to"] = true
L["Coloring based on"] = true
L["Number of stacks"] = true
L["Remaining time"] = true
L["Elapsed time"] = true
L["Class Filter"] = true
L["Show on %s."] = true
L["Blink Threshold"] = true
L["Blink Threshold at which to start blinking the status."] = true
L["Name or SpellId"] = true
L["Select Type"] = true
L["Buff"] = true
L["Debuff"] = true
L["Buffs Group"] = true
L["Debuffs Group"] = true
L["Buffs Group: Defensive Cooldowns"] = true
L["Debuffs Group: Healing Prevented "] = true
L["Debuffs Group: Healing Reduced"] = true
L["Filtered debuffs"] = true
L["Listed debuffs will be ignored."] = true
L["AURAVALUE_DESC"] = "Select an aura value to track. Auras can provide up to 3 values, but not all auras have additional values. Examples of auras providing additional values are: priest shields (shield amount is stored in Value1) or DeathKnight purgatory debuff."

-- general statuses
L["name"]= true
L["mana"]= true
L["power"]= true
L["poweralt"]= true
L["alpha"] = true
L["border"] = true
L["heals"] = true
L["health"] = true
L["charmed"] = true
L["afk"] = true
L["death"] = true
L["classcolor"] = true
L["creaturecolor"] = true
L["friendcolor"] = true
L["feign-death"] = true
L["heals-incoming"] = true
L["health-current"] = true
L["health-deficit"] = true
L["health-low"] = true
L["lowmana"] = true
L["offline"] = true
L["raid-icon-player"] = true
L["raid-icon-target"] = true
L["range"] = true
L["ready-check"] = true
L["role"] = true
L["dungeon-role"] = true
L["leader"]= true
L["master-looter"]= true
L["raid-assistant"]= true
L["target"] = true
L["threat"] = true
L["banzai"] = true
L["banzai-threat"] = true
L["vehicle"] = true
L["voice"] = true
L["pvp"] = true
L["direction"] = true
L["resurrection"] = true
L["self"] = true

L["Curse"] = true
L["Poison"] = true
L["Disease"] = true
L["Magic"] = true

L["raid-debuffs"]  = "Raid Debuffs"
L["raid-debuffs2"] = "Raid Debuffs(2)"
L["raid-debuffs3"] = "Raid Debuffs(3)"
L["raid-debuffs4"] = "Raid Debuffs(4)"
L["raid-debuffs5"] = "Raid Debuffs(5)"

L["boss-shields"] = true

-- class specific buffs & debuffs statuses

-- shaman
L["EarthShield"] = true
L["Earthliving"] = true
L["Riptide"] = true
L["ChainHeal"] = true
L["HealingRain"] = true 

-- Druid
L["Rejuvenation"]= true
L["Lifebloom"]= true
L["Regrowth"]= true
L["WildGrowth"]= true

-- paladin
L["BeaconOfLight"]= true
L["FlashOfLight"]= true
L["DivineShield"]= true
L["DivineProtection"]= true
L["HandOfProtection"]= true
L["HandOfSalvation"]= true
L["Forbearance"]= true

-- priest
L["Grace"]= true
L["DivineAegis"]= true
L["InnerFire"]= true
L["PrayerOfMending"]= true
L["PowerWordShield"]= true
L["Renew"]= true
L["WeakenedSoul"]= true
L["SpiritOfRedemption"]= true
L["CircleOfHealing"]= true
L["PrayerOfHealing"]= true

-- monk
L["EnvelopingMist"]= true
L["RenewingMist"]= true
L["LifeCocoon"]= true

-- mage
L["FocusMagic"]= true
L["IceArmor"]= true
L["IceBarrier"]= true

-- rogue
L["Evasion"]= true

-- warlock
L["ShadowWard"]= true
L["SoulLink"]= true
L["DemonArmor"]= true
L["FelArmor"]= true

-- warrior
L["Vigilance"]= true
L["BattleShout"]= true
L["CommandingShout"]= true
L["ShieldWall"]= true
L["LastStand"]= true

-- class color, creature color, friend color status
L["%s Color"] = "%s"
L["Player color"]= true
L["Pet color"] = true
L["Color Charmed Unit"] = true
L["Color Units that are charmed."] = true
L["Unit Colors"] = true
L["Charmed unit Color"] = true
L["Default unit Color"] = true
L["Default pet Color"] = true

L["DEATHKNIGHT"] = "DeathKnight"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"
L["Beast"] = "Beasst"
L["Demon"] = "Demon"
L["Humanoid"] = "Humanoid"
L["Elemental"] = "Elemental"

-- heal-current status
L["Full Health"] = true
L["Medium Health"] = true
L["Low Health"] = true
L["Show dead as having Full Health"] = true
L["Frequent Updates"] = true
L["Instant Updates"] = true
L["Normal"] = true
L["Fast"] = true
L["Instant"] = true
L["Update frequency"] = true
L["Select the health update frequency."] = true

-- health-low status
L["Use Health Percent"] = true

-- range status 
L["Range"] = true
L["%d yards"] = true
L["Range in yards beyond which the status will be lost."] = true
L["Default alpha"] = true
L["Default alpha value when units are way out of range."] = true
L["Update rate"] = true
L["Rate at which the status gets updated"] = true

-- ready-check status
L["Delay"] = true
L["Set the delay until ready check results are cleared."] = true
L["Waiting color"] = true
L["Color for Waiting."] = true
L["Ready color"] = true
L["Color for Ready."] = true
L["Not Ready color"] = true
L["Color for Not Ready."] = true
L["AFK color"] = true
L["Color for AFK."] = true

-- heals-incoming status 
L["Include player heals"] = true
L["Substract heal absorbs"] =  true
L["Substract heal absorbs shields from the incoming heals"] = true
L["Display status for the player's heals."] = true
L["Minimum value"] = true
L["Incoming heals below the specified value will not be shown."] = true

--target status
L["Your Target"] = true

--threat status
L["Not Tanking"] = true
L["Higher threat than tank."] = true
L["Insecurely Tanking"] = true
L["Tanking without having highest threat."] = true
L["Securely Tanking"] = true
L["Tanking with highest threat."] = true
L["Disable Blink"] = true

-- voice status
L["Voice Chat"] = true

-- raid debuffs
L["General"]= true
L["Advanced"]= true
L["Enabled raid debuffs modules"]= true
L["Enabled"]= true
L["Enable All"]= true
L["Disable All"]= true
L["Copy to Debuffs"]= true
L["Select module"]= true
L["Select instance"]= true
L["Cataclysm"]= true
L["The Lich King"]= true
L["The Burning Crusade"] = true
L["New raid debuff"] = true
L["Type the SpellId of the new raid debuff"] = true
L["Create raid debuff"] = true
L["Delete raid debuff"] = true

-- direction
L["Out of Range"] = true
L["Display status for units out of range."] = true
L["Visible Units"] = true
L["Display status for units less than 100 yards away"] = true
L["Dead Units"] = true
L["Display status only for dead units"] = true

-- resurrection
L["Casting resurrection"] = true
L["A resurrection spell is being casted on the unit"] = true
L["Resurrected"] = true
L["A resurrection spell has been casted on the unit"] = true
		
-- power
L["Mana"] = true
L["Rage"] = true
L["Focus"] = true
L["Energy"] = true
L["Runic Power"] = true

-- shields status
L["shields"] = true
L["Maximum shield amount"] = true
L["Value used by bar indicators. Select zero to use players Maximum Health."] = true
L["Normal"] = true
L["Medium"] = true
L["Low"] = true
L["Normal shield color"] = true
L["Medium shield color"] = true
L["Low shield color"] = true
L["Low shield threshold"] = true
L["The value below which a shield is considered low."] = true
L["Medium shield threshold"] = true
L["The value below which a shield is considered medium."] = true
L["Custom Shields"] = true
L["Type shield spell IDs separated by commas."] = true

-- heal-absorbs status
L["heal-absorbs"] = true
L["Maximum absorb amount"] = true
L["Medium absorb threshold"] = true
L["Low absorb threshold"] = true

-- role related statuses
L["Hide in combat"] = true
L["Hide Damagers"] = true

-- status descriptions
L["highlights your target"] = true
L["hostile casts against raid members"] = true
L["advanced threat detection"] = true
L["arrows pointing to each raid member"] = true
L["display remaining amount of heal absorb shields"] = true
L["display remaining amount of damage absorption shields"] = true

-- aoe heals
L["aoe-"] = true
L["neighbors"] = true
L["highlighter"] = true
L["OutgoingHeals"] = true

L["AOE Heals"] = true
L["Highlight status"] = true
L["Autodetect"] = true
L["Select the status the Highlighter will use."] = true
L["Mouse Enter Delay"] = true
L["Delay in seconds before showing the status."] = true
L["Mouse Leave Delay"] = true
L["Delay in seconds before hiding the status."] = true
L["Min players"] = true
L["Minimum players to enable the status."] = true
L["Radius"] = true
L["Max distance of nearby units."] = true
L["Health deficit"] = true
L["Minimum health deficit of units to enable the status."] = true
L["Keep same targets"] = true
L["Try to keep same heal targets solutions if posible."] = true
L["Max solutions"] = true
L["Maximum number of solutions to display."] = true
L["Hide on cooldown"] = true
L["Hide the status while the spell is on cooldown."] = true
L["Show overlapping heals"]  = true
L["Show heal targets even if they overlap with other heals."] = true
L["Show only in combat"]  = true
L["Enable the statuses only in combat."] = true
L["Show only in raid"] = true
L["Enable the statuses only in raid."]  = true
L["Active time"] = true
L["Show the status for the specified number of seconds."] = true
L["Spells"] = true
L["You can type spell IDs or spell names."] = true
L["Display all solutions"] = true
L["Display all solutions instead of only one solution per group."] = true

-- Import/export profiles module
L["Import/export options"]= true
L["Import profile"]= true
L["Export profile"]= true
L["Network sharing"]= true
L["Accept profiles from other players"]= true
L["Type player name"]= true
L["Send current profile"]= true
L["Profile import/export"]= true
L["Paste here a profile in text format"]= true
L["Press CTRL-V to paste a Grid2 configuration text"]= true
L["This is your current profile in text format"]= true
L["Press CTRL-C to copy the configuration to your clipboard"]= true
L["Progress"]= true
L["Data size: %.1fKB"]= true
L["Transmision progress: %d%%"]= true
L["Transmission completed"]= true
L["\"%s\" has sent you a profile configuration. Do you want to activate received profile ?"]= true
L["Include Custom Layouts"] = true

-- Open manager
L["Options management"] = true
L["Load options on demand (requires UI reload)"] = true
L["OPTIONS_ONDEMAND_DESC"] = "Options are not created until user clicks on them, reducing memory usage and load time. If you experiment any problem with this feature disable this option."
