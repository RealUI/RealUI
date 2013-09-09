Raven

Major Features

1) Customizable timer bar and icon configurations to monitor buffs, debuffs and cooldowns
2) Multi-target HoT and DoT tracking bars
3) Timelines to show buff, debuff and cooldown icons sliding along a bar
4) Comprehensive condition checking to support buffing/debuffing, spell rotations, etc.
5) Highlights for active spells plus cooldown counters on popular action bar addon buttons
6) Preset spell colors and cooldowns plus buff-related conditions for each class

Project page: http://wow.curseforge.com/addons/raven
Offical forum thread: http://forums.curseforge.com/showthread.php?t=18429
FAQ: http://wow.curseforge.com/addons/raven/pages/faq
Localizations: Chinese (zhCN and zhTW) by surgesoft and Alice, Korean (koKR) by rhinomans

Installation and Configuration

Install Raven by copying its files into your WoW addons folder (or use your favorite addons update utility). Optional additional Raven-compatible modules can be installed to add support for spell rotations used by specific classes.

You can bring up a configuration panel by typing in "/raven" or clicking on Raven's minimap button. Raven also includes a Data Broker launcher that can be displayed by addons like ChocolateBar.

Raven includes detailed tooltips for most options in the configuration panel.

Getting Started

The quickest way to get started with Raven is to use the standard bar groups on the Setup tab of the configuration panel. Standard bar groups include (1) all player buffs, (2) short player buffs (lasting less than 2 minutes), (3) long player buffs (lasting at least 2 minutes, such as Mark of the Wild, Blessing of Kings, and other "raid" buffs), (4) debuffs on the player, (5) cooldowns on player spells and equipped trinkets, (6) buffs/debuffs cast by the player on the target, (7) buffs/debuffs cast by the player on the focus, (8) rune cooldowns (Death Knights only), and (9) notifications for conditions relevant to your class (e.g., missing poisons on rogue weapons). Select the standard bar groups you want (hint: you probably don't want all the player buff bar groups since that will result in duplicates) and click either the Create As Bars or Create As Icons button. This will create an anchor for each selected bar group near the center of your display that you can move by clicking and dragging.

When you mouse over an anchor you'll see a tooltip with shortcuts for changing the bar group's configuration and for showing test bars. You can lock and unlock the bar group anchors using buttons on the configuration panel Setup tab (locked anchors are hidden, unlocked anchors are visible). The Defaults tab lets you change the appearance of your bars with configuration options for bar dimensions, fonts and textures.

Using Bar Groups

Once you set up standard bar groups, timer bars or icons will be displayed for buffs, debuffs and cooldowns and, if you set up the Notifications group, warning bars or icons will be displayed for missing buffs and cleansable debuffs. Bars will be in a variety of colors since Raven includes preset colors for many class-specific spells to help distinguish them (with the exception of Long Buffs that are class-colored by default).

After using Raven a while, you will probably want to make some adjustments. Perhaps you don't like the default colors of the bars or you want to switch between bars and icons. Or maybe you want a dedicated bar group for the procs and cooldowns you monitor closely during combat.

At this point, it is necessary to understand that there are two types of bar groups: auto bar groups and custom bar groups. Auto bar groups are used to automatically display bars for buffs, debuffs and cooldowns. Most of the standard bar groups (all except Notifications) are pre-configured auto bar groups. Custom bar groups allow you to manually configure bars for a mix of buffs, debuffs, cooldowns and notifications. Typically, custom bar groups are used to present spell rotations and buff/cleansing reminders.

Auto Bar Groups

Open the configuration panel and click on the Bar Groups tab. Using the pull-down menu near the top, select any existing standard bar group (except Notifications) or create a new auto bar group by clicking on the New Auto Group button. A second set of tabs appears that lets you configure the selected bar group.

You use the Buffs, Debuffs, and Cooldowns tabs to specify what kinds of bars to display (and which ones to filter out). These tabs lets you control how the bar group is populated as new buffs, debuffs and cooldowns are detected. For buffs and debuffs, you specify who the action must be on and who it must be cast by. For cooldowns, you specify what kinds of cooldowns to detect. When new buffs, debuffs and cooldowns are detected that match the criteria, bars for them are automatically displayed.

Auto bar groups have filter lists to let you suppress showing unwanted bars. Both black lists (i.e., don't show if on the list) and white lists (i.e., only show if on the list) are supported. You can manage filter lists on the Buff, Debuff and Cooldown tabs.

Custom Bar Groups

While the standard bar groups provide an easy way to get started, you might also want to set up bar groups that contain just the bars you care about during combat. For example, to support your feral druid's DPS rotation you might want bars for the Savage Roar buff on the player, Mangle, Rake and Rip debuffs on the target, and Tiger's Fury and Berserk cooldowns.

To create a new custom bar group, open the Raven configuration panel, select the Bar Groups tab, then click on New Custom Group and enter a name (e.g., "Combat Bars"). This will bring up a new, empty bar group. To add bars, select the Custom Bars tab and click the New button.

When you click the New button, the configuration panel is put into bar creation mode (you won't be able to access other options until you click either Okay or Cancel at the bottom of the scrollable options). Select a bar type (e.g., buff, debuff, cooldown) and then appropriate options. For example, when you select Buff, you can then select the source of actions (i.e., class, pet, racial, other) and you are presented with a list of available buff actions (or, in the case of "other", a text entry box for entering a spell name). Select actions within that list that you want bars for (All On and All Off buttons are provided for convenience). Pay particular attention to correctly setting who the action is on and who it is cast by. Click Okay to finishing adding the bars (they are now included in the list of bars and can be customized by clicking on them and setting their associated options). You can repeat the bar creation process by clicking New again to add any mix of bar types.

The Custom Bars tab also lets you make changes to bars after they have been added. Select any individual bar to bring up configuration options that let you adjust its color, label text, special effects, and other properties. You can toggle enable to disable the bar.

More Customization

You can further customize bar groups using configuration settings in the General, Layout, Appearance, and Timer Options tabs. The following is a brief description of what each tab supports (mouse over options for explanatory tooltips).

The General tab provides options to enable/disable the entire bar group, rename the bar group, specify how bars are sorted, conditionally show/hide the bar group, and adjust settings for mouse clicks, tooltips, and special effects (e.g., pulsing icons, flashing on expiration).

The Layout and Appearance tabs let you modify the look of the selected bar group. You can adjust the bar group's configuration and the direction that bars grow from the anchor. You can select alternate coloring schemes. You can adjust dimensions, fonts and textures (after overriding defaults set on the Defaults tab). You can turn on and off particular characteristics (icon, colored bar, spark, label, etc.) and change their relative positions. If you prefer icon-based interfaces, Raven includes configurations featuring large icons with optional mini-bars. You can also attach bar groups to each other to facilitate alignment (including the ability to attach to a bar group's last bar so a stack of bar groups can expand and shrink as needed). Play around some and check out the range of possible designs (hint: you can shift-left-click on a bar group anchor to show test bars).

The Timer Options tab lets you adjust settings related to bar duration and time left. You can set all bars in a group to have a uniform duration (this makes it easy to compare how much time is left on bars with similar, but slightly different, durations). You can specify whether to show bars with unlimited duration (e.g., paladin auras). You can filter bars based on their durations and amount of time left (this is how the standard bar groups separate short buffs from long buffs).

Bar groups can have background panels and borders. Set them up in the Defaults tab to show them for all bar groups or in the Appearance tab for individual bar groups. You can enable a background panel with texture, color, and size (size is specified as padding in pixels from the bar group's bars and icons). You can enable a background border separately with a border design, color, edge size, and inset (inset helps merge panel and border correctly).

Multi-Target Buff and Debuff Tracking

Raven includes multi-target buff and debuff tracking similar to other DoT and HoT timer addons. The Setup tab now includes Buff Tracker and Debuff Tracker standard bar groups. These bar groups will group timer bars for buffs or debuffs that you cast on each target and, by default, will show a header with the target name above its associated timer bars. Optionally, you can include the target name in the timer bar labels instead of showing headers (set Hide Headers on the General tab for the bar group). Use black list and white list filtering capabilities in these bar groups to customize them (e.g., you can make a Beacon of Light tracker by creating a HoT timer bar group with only that spell in its white list). You might want to stick with bar-oriented configurations for these since the headers (which include raid target icons and indicate current target, focus or mouseover unit) are currently designed to work best as bars.

Conditions

Raven monitors a variety of events during play and can display notifications when certain conditions are met. While somewhat complex to set up, conditions are quite powerful and can help with spell rotations, decursing, etc. Raven includes default conditions for each class for basics like making sure you have class-specific buffs during combat.

Conditions can be used in Raven to trigger notifications and to control whether or not bar groups are visible. Generally speaking, once you set up a condition you will want to set up a notification bar to show you when the condition is true. When you configure the Notifications standard bar group on the Setup tab, you automatically get notifications for your configured conditions.

Conditions are configured in Raven under the Conditions tab. To get a feel for setting up conditions, take a minute to look at the default conditions for your class. Select one of the conditions using the pull-down menu near the top. A second set of two tabs (General, Tests) appears with options for configuring the selected condition.

The Tests tab has a summary of settings at the top and a list of available tests below. There are tests for checking status of the player, target and focus, tests for checking for combinations of buffs and defuffs, and tests for checking if spells or items are ready to be used. Selecting a test brings up options specific to that test. For example, the Player Status test lets you check if you are in combat, resting, have more than a certain percentage of your health, how many combo points you have, etc.

All the tests you enable must be true for the overall condition to evaluate to true (the summary at the top is intended to help visualize how the tests combine). You can also add dependencies between conditions that can be helpful for factoring out common tests (e.g., a condition to see if you are in cat form and in combat might be a dependency for other conditions defining a druid's feral spell rotation).

The General tab for each condition allows you to enable/disable the condition and specify if the condition is suitable for triggering a notification. You can also associate a spell with a condition (the spell's icon and color are used to customize notifications based on the condition).

Cancelling Buffs

Raven includes support for cancelling buffs. When out of combat, you simply right-click the icon on any player buff bar to cancel the buff (this works for shaman weapon enchants and rogue poisons too). For cancelling buffs in combat, Raven includes an "in-combat" bar that you set up while out of combat with a list of player buffs that you want to be able to cancel in combat (you may need to do reload the UI after setting up the "in-combat" bar before using the buttons). When one of these buffs becomes active in combat, its icon pulses into place on the "in-combat" bar and you can right-click it to cancel the buff.

Class-Specific Modules

Raven includes special bar groups for Death Knight and Shaman classes. These show up as the Runes and Totems standard bar groups on the Setup tab. The Runes bar group replaces the Blizzard runes default UI and displays cooldown timer bars for all your runes. The Totems bar group tracks currently active totems and show a placeholder ready bar for each empty totem slot. You can right-click on a totem icon to destroy a totem. You can disable the placeholder bars by turning off Show If Unlimited Duration.

Raven supports optional modules that add spell rotation notifications for particular classes/specs (e.g., feral druid, survival hunter, destruction warlock). They contain conditions that prioritize spell selection based on current player and target status plus resource availabilty (combo points, energy, etc.). These modules are separate addons and distributed/enabled separately. A growing collection of these modules, many including video demos, is available at Zoumtag's website at http://noiretendard.free.fr/wow_addons/Raven_plugins/Info.html.

Since Raven allows anyone to create, view and edit conditions, you can see exactly how a module supports a spell rotation and customize it to your own preferences. Note, however, that spell rotations are often optimized for boss fights and may not be suitable for all circumstances. It is important to understand your class well enough to know when it is appropriate to follow spell rotation notifications and when to ignore them. Similarly, module writers should try to take into consideration a variety of scenarios (boss fights, trash pulls, questing) when designing spell rotations.

Highlights

If you are using Bartender4, Dominos or Macaroon then Raven can add overlays to buttons to show which of your spells are active and which are on cooldown. Raven is already tracking your buffs, debuffs and cooldowns so it does this with minimal added resources. You can customize (or disable) this feature in the configuration panel Highlights tab. Active spell highlights are color-coded to indicate if on player, target or focus. If ButtonFacade is loaded then Raven can use it for color highlighting. However, since this does not work well with all skins, ButtonFacade support is disabled by default. Cooldown counters are shown by default unless OmniCC is installed.

Multiple Characters

Raven is designed to simplify configuration across multiple characters. This is required because each class may make quite different use of timer bars (e.g., some depend on tracking cooldowns while others watch for debuffs to expire on the target). In the Profiles tab, Raven includes the profile options common to Ace3-based addons and, by default, creates a new profile for each character.

In addition to using profiles, Raven shares a variety of settings across characters. This can result in some confusion since it works differently than in other addons (but can simplify configuring Raven if you play several different classes). First, the appearance options on the Defaults tab (dimensions, fonts, textures) apply to all profiles (they can be overridden as needed in any bar group, of course). Second, almost all bar group settings (the primary exception being the actual bars associated with custom groups) are linked between bar groups of the same name in all profiles that have Link Settings enabled (note that Link Settings is no longer enabled by default for standard bar groups on the Setup tab). Third, filter lists are linked by default between auto bar groups of the same name in all profiles, simplifying dealing with unwanted buff, debuff and cooldown bars. Fourth, all settings related to button highlights are shared across characters.

Final Words

I hope you enjoy using Raven for all your buff, debuff and cooldown needs! Questions and comments are always welcome.