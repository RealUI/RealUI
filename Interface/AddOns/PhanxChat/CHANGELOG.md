### Version 7.0.3.0

* Updated for WoW 7.0.3
* Added toggles for the game's "Enable Mouse Wheel Scrolling" and "Remove Chat Hover Delay" settings, which are no longer exposed in the default Chat options panel.

### Version 6.0.3.88

* Fixed the term "battle.net" being turned into a clickable link.
* Shift-clicking links into chat and cycling through previously entered chat lines will no longer insert an extra space.
* The `/pchat clear` command is now just `/clear` and clears only visible chat frames by default. Use `/clear all` to clear all chat frames instead.
* The `/pchat` command remains for opening the options window.

### Version 6.0.3.87

* Fixed option to disable chat fading

### Version 6.0.2.253

* Added an option to prevent the chat frame from opening a pet battle combat log window
* Updated French and Portuguese translations

### Version 6.0.2.250

* Updated for WoW 6.0
* Fixed an error that could occur if a Battle.net whisper was received while logging in

### Version 5.4.8.244

* Updated Русский translations from Yafis
* Updated 简体中文 translations from tss1398383123

### Version 5.4.8.241

* Fix for missing labels on dropdowns in options panel

### Version 5.4.7.240

* Fixed an error when opening the chat edit box to a numbered channel

### Version 5.4.7.239

* Fixed an error when setting the fade time to 0
* Improved channel name shortening to avoid matching other link types with channelname-like text

### Version 5.4.7.237

* Updated the "Hide extra textures" option to look better on temporary chat frames whose tabs have icons

### Version 5.4.7.236

* Updated Battle.net player name shift-click reports to support Hearthstone and the Battle.net Desktop App

### Version 5.4.2.231

* Battle.net names will now be colored by class all the time, not just when replacing them with character names
* Battle.net "Player (Character) has come online" messages will now be shortened to just "Name has come online" using your Battle.net name settings
* Battle.net name shortening and coloring will no longer occasionally not work right away after logging in
* The `/tt` and `/wt` commands will now recognize the player as a valid whisper target
* Updated Traditional Chinese localization from tss1398383123 on Curse

### Version 5.4.2.221

* Fixed an issue with removing realm names

### Version 5.4.1.219

* Improved the behavior of history cycling after reusing an existing history line.
* Fixed an error that would occur when trying to cycle through chat history before any lines were added to it.

### Version 5.4.1.216

* Added a limited workaround for Blizzard's stupid auto-complete changes in 5.4 that broke the ability to cycle through your chat input history using the Up/Down arrows without holding the Alt key. However, this is limited to non-secure commands only. If you need to access previously entered secure commands (like /cast or /use) you will still need to hold the Alt key.

### Version 5.4.1.212

* Updated for WoW 5.4
* Fixed the "Shorten RealID names" option not saving properly

### Version 5.3.0.210

* Updated German localization from staratnight
* Updated Simplified Chinese localization from tss1398383123

### Version 5.3.0.209

* Updated for WoW 5.3
* Battle.net names are no longer class colored when Show Class Colors is disabled

### Version 5.2.0.208

* Channel names are now shortened in the editbox too
* Chat fade time can now be specified in 15-second increments

### Version 5.2.0.203

* Updated Traditional Chinese localization from BNSSNB on CurseForge
* Updated German localization from bigx2 on CurseForge

### Version 5.2.0.201

* Fixed shortening real names at first login
* Fixed using short names for numbered channels instead of numbers only (Lua config only)

### Version 5.2.0.198

* Updated for WoW 5.2
* The "Shorten player names" option has been renamed to "Remove server names" and now only removes server names from cross-realm character names.
* A new "Shorten real names" option has been added, with the choice of keeping full names, showing first names only, or replacing Real ID names with BattleTags.
* The "Replace real names" option will continue to replace both Real ID names and BattleTags with character names.
* The "Show class colors" option now always overrides the individual channel options in the Blizzard chat options window. To avoid confusion, the Blizzard check boxes are disabled.

### Version 5.1.0.187

* Added [LibChatAnims](http://www.wowace.com/addons/libchatanims/) to work around public chat API functions tainting the talent frame due to Blizzard's stupidity

### Version 5.1.0.186

* Fixed channel name shortening in locales that include spaces, city names, etc.
* Updated abbreviations for "Instance Chat" for all locales

### Version 5.1.0.177

* Fixed an error that could occur when receiving certain types of messages
* Updated frFR translations from L0relei on Curse
* Removed 5.0.5 compatibility

### Version 5.1.0.174

* Updated for WoW 5.1
* Fixed shift-clicking on Real ID and BattleTag names
* Updated ptBR translations from mgaedke on Curse

### Version 5.0.5.167

* Fixed Real ID name shortening and character name replacement
* Added BattleTag name shortening (removes the #1234 nonsense) and character name replacement
* Updated deDE translations from staratnight
* Updated zhCN translations from tss1398383123

### Version 5.0.4.163

* Updated for WoW 5.0.4
* Removed all references to GuildRecruitment channel since it hasn't existed for a while
* Added itIT channel names and abbreviations
* Updated channel names for all locales from ChannelNames.dbc

### Version 4.3.4.159

* **Compatible with both 4.3 live realms and Mists of Pandaria beta realms.**
Use the “Load out of date addons” checkbox on beta realms — the TOC won’t be updated until Patch 5.0 goes live.
* The game’s “Enable Mouse Wheel Scrolling” option will now be enabled and locked while PhanxChat’s “Hide buttons” option is enabled.
* The game’s “Show Class Color” option for each individual chat type will be enabled and locked while PhanxChat’s “Show class colors” option is enabled.
* Fixed some options not updating properly.
* Removed a debugging print.
* Updated system channel names for deDE and frFR.
* Added more zhTW translations from yunrong on CurseForge.

### Version 4.3.4.155

* Compatible with both 4.3 live realms and Mists of Pandaria beta realms.
Use the “Load out of date addons” checkbox on beta realms — the TOC won’t be updated until Patch 5.0 goes live.
* The default UI’s “Chat Style” option will now be set and locked to “Classic” if the edit box is moved to the top.
* Added a “Show class colors” checkbox in the options panel as a shortcut for enabling class colors in all chat channels.
* Improved tell-target functionality.
* Added partial zhTW localization from yunrong on CurseForge.

### Version 4.3.3.147

* Fixed an issue preventing the "Short player names" option from working with Real ID names.
* Fixed an issue with Blizzard URL links.
* Added a workaround to help prevent taint errors from the Blizzard Glyph UI.
* Updated esMX translations for server chat channel names.

### Version 4.3.0.139

* Updated for WoW 4.3
* Added Português (ptBR) translations
* Fixed shift-clicking on RealID names

### Version 4.2.2.136

* Fixed beginner tooltips sticking on chat tabs

### Version 4.2.0.135

* Fixed short chat channel names
* Fixed class-colored character names for Real ID friends

### Version 4.2.0.134

* Updated for WoW 4.2

### Version 4.1.0.133

* Fixed the weird tab resizing behavior in Patch 4.1
* Added default sticky settings for Battle.net conversations and whispers
* Added Spanish translations (still need channel names)
* Added Simplified Chinese translations by tss1398383123 on CurseForge
* Improved the appearance of highlighted and selected tabs

### Version 4.0.3.120

* Added Korean localization from Talkswind on Curse

### Version 4.0.3.118

* Updated Real ID name replacement for WoW 4.0
* Fixed the cursor when resizing the chat frame

### Version 4.0.1.112

* Fixed the URL copy module for changes in WoW 4.0.1

### Version 4.0.1.111

* Fixed errors with temporary chat windows
* Added frFR localization from Strigx on curse.com

### Version 3.3.5.108

* Fixed chat buttons not switching sides when the chat frame is dragged
* Added deDE localization from ac3r on wowinterface.com
* Added ruRU localization from hungry2 on curse.com

### Version 3.3.5.101

* Fixed shortening of Real ID player names
* Added replacement of Real ID player names with WoW character names
* Added /who print when shift-clicking Real ID player names to keep them consistent with normal player names
* Improved efficiency of bottom button display check
* Improved visibility of resize edges on unlocked chat frames
* Fixed URL linking to not cause taint

### Version 3.3.5.94

**Due to file changes, you should completely uninstall your existing copy of the addon before installing this version. Removing your old saved variables is recommended, but not required.**

* Added a Shorten Player Names feature, which shortens player names by removing realm names from cross-realm players and last names from Real ID players.
* Removed the Auto Start Chat Log feature, because I never used it.
* Removed the Color Player Names feature, because it was just too much code and performance overhead to color the very few types of messages that the default UI doesn't already color, and also confused all the <insert uncomplimentary adjective here> people who never read patch notes or change logs.

* **Translations are needed for all locales.**
* All existing translations for the configuration UI have been discarded, since none of them had been updated since the transition from slash commands to a GUI over a year ago. If you can provide translations for any locale, please send me a PM.
* Additionally, several chat channels are currently only shortened in English locales, because nobody has provided translations for them. If you see a channel name that isn't shortened, please post a bug report ticket with your locale (eg. "German" or "deDE"), the English name of the channel (eg. "General"), the localized name of the channel (eg. "Allgemein"), and an appropriate short form for your locale (eg. "A").

### Version 3.3.5.73

* Fixed a bug preveing the new Battle.net "toast" window from being shown
* Fixed a bug relating to sticky channel selection

### Version 3.3.5.72

* **Updated for patch 3.3.5. NOT BACKWARDS COMPATIBLE.**
* Added an “Enable resize edges” option to add resize controls along all edges of chat frames, and remove the bottom-left-corner resize arrow. This basically just restores pre-3.3.5 chat frame resizing functionality.
* Added a “Hide extra textures” option to hide the extra textures on chat tabs and chat edit boxes added in patch 3.3.5.
* Removed the “Enable mousewheel scrolling” option, since this functionality is now provided by the default UI.
* Modified the default UI's mousewheel scrolling to scroll more lines at a time, page up/down on ctrl, and top/bottom on shift.
* Fixed a bug preventing custom short channel name formats from using the channel name in addition to the channel number.
* Translations are needed for the new options in all locales. Also, major revisions are needed for several locales. If you can assist with translations for any locale, please send me a PM.

### Version 3.3.3.68

* Fixed an bug that caused the player's own repeated messages to be hidden

### Version 3.3.3.67-beta

* Fixed an error that caused tab flashing to not always be disabled

### Version 3.3.3.66-beta

* Fixed an error caused by a misnamed variable
* Added missing config library

### Version 3.3.3.64-beta

* The "Dungeon Guide" title is now abbreviated
* Repeat-message suppression is now case-insensitive and ignores spaces
* The configuration panel has been rearranged, and the wording of several options improved
* **Translations for all locales need to be reviewed**

### Version 3.3.0.60
* Repeat message suppression now looks at the last 15 lines (up from 10)
* Fixed repeat message suppression option

### Version 3.3.0.57

* Update for WoW 3.3

### Version 3.2.0.53

* Added checks to prevent errors caused by other addons that haven't been updated for 3.2, because I'm tired of hearing about them
* Fixed suppression options again
* Changed from hardcoded class name translations to new FillLocalizedClassList API

### Version 3.2.0.51

* Updated class coloring for WoW 3.2

### Version 3.1.1.49-beta

* Fixed error preventing ChatFrame3 and ChatFrame7 from being formatted

### Version 3.1.1.48-beta

* Fixed achievement messages for Korean (and possibly other non-English) clients
* Improved URL linking to reduce the occurrence of false positives
* Updated koKR translations by kornshock @ WoWInterface

### Version 3.1.0.39-beta

* Rearranged configuration GUI
* Re-added "/pchat clear" command for easy keybinding

### Version 3.1.0.37-beta

* Fixed suppressing repeated messages in 3.1
* Fixed error in option for shortening channel names

### Version 3.1.0.35-beta

* Add LibStub for GUI configuration

### Version 3.1.0.33-beta

* Update for WoW 3.1 (*NOT* backwards compatible)
* Fix German translation for "Death Knight"
* Add GUI configuration in the Interface Options panel
* Remove command-line configuration

### Version 3.0.2.26

* Fix channel notice suppression option

### Version 3.0.2.22

* Fix chat tab dragging

### Version 3.0.2.21

* Fix font size command

### Version 3.0.2.20

* Remove 2.4.3 compatibility

### Version 2.4.3.19

* Fix scroll-to-bottom button for 2.4.3

### Version 2.4.3.18

* Fix channel notice suppression option

### Version 2.4.3.17

* Add complete deDE translations from Melikae
* Add complete ruRU translations from Valle

### Version 2.4.3.14

* Fix suppression options
* Add complete koKR translations from TalksWind

### Version 2.4.3.10

* Add complete frFR translations from Nicolas

### Version 2.4.3.9

* Fix frame blacklisting

### Version 20100-r08

* Fix erratic chat logging
* Added option to include number with short channel names
* Added partial Traditional Chinese translations (thanks ??)
* Use RAID_CLASS_COLORS for class coloring (I recommend ReTeal for restoring the teal class color for shamans)

### Version 20100-r07

* Changed method for getting class information from short who queries. This means you will not get class coloring from shift-clicking blood elves and night elves.

### Version 20100-r06

* Changed detection pattern for short who results to be less specific (should always pick up names and classes now)
* Added a compatibility check to stop the errors from AtlasLoot when validating items

### Version 20100-r05

* Fixed FuBar plugin / minimap icon error
* changed FuBar plugin / minimap icon menu

### Version 20100-r04

* Fixed duplicate FuBar plugin / minimap icon

### Version 20100-r03

* Fixed sticky channels toggle
* Fixed channel color memory toggle
* Maybe fixed Auctioneer conflict (I couldn't reproduce it)

### Version 20100-r02

* Added option to save class colors between sessions
* Added option to suppress certain spammy messages
* Added optional GUI configuration

### Version 20100-r01

TEMPORARY fix for visible line ID. Note that this fix discards the line ID completely, preventing use of the new spam reporting functions. If you would prefer to report spam, disable the player name class coloring and bracket removal features.

### Version 2.1.1

* Removed workaround code for Blizzard's "reappearing channels" bug (fixed in WoW 2.0.7)

### Version 2.1.0

* Added chat fading controls
* Fixed tell-target keybinding

### Version 2.0.5

* Updated embedded libraries for WoW 2.0.3

### Version 2.0.4

* Fixed chat string setup on login
* Fixed chat logging start on login

### Version 2.0.3

* Fixed chat string shortening

### Version 2.0.2

* Fixed menu button toggle (again)

### Version 2.0.1

* Fixed menu button toggle
* Fixed chat tab lock toggle

### Version 2.0

* Partial rewrite
* Fixed guild MotD being suppressed on login
* Added keybinding and slash command (/tt) to whisper your current target
* Added class name coloring
* Added toggle for arrow keys in the edit box

### Version 1.4

* Update for WoW 2.0

### Version 1.3

* Added URL copy feature with several options

### Version 1.2

* Added tab flash suppression
* Added tab locking
* Added toggles for some options

### Version 1.0

* Initial release
