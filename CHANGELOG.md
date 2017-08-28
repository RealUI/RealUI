# Change Log #
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [Unreleased] ##
## [8.1 r20d] - 2017-07-11 ##
### Modified AddOns ###

  * !Aurora_RealUI
  * cargBags_Nivaya
  * EasyMail
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs

### Changed ###

  * Improve name abbreviation.
  * The main menu RealUI Config button has been moved.

### Fixed ###

  * The Battle Pet bank bag would overlap others.
  * Misc bugs for patch 7.3.0




## [8.1 r20c] - 2017-07-11 ##
### Modified AddOns ###

  * !Aurora_RealUI
  * FreebTip
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init
  * RealUI_Bugs

### Fixed ###

  * RealUI_Bugs would itself throw an error if RealUI didn't load properly.
  * The guild list should no longer error after guild ranks are changed.
  * Fix a unit frames bug when using vehicles.
  * Class Resource could not be re-enabled if it had beed disabled.




## [8.1 r20b] - 2017-06-26 ##
### Modified AddOns ###

  * cargBags_Nivaya
  * FreebTip
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs

### Changed ###

  * Chat output and text updates for errors has been throttled.

### Fixed ###

  * UI scale will now behave properly when set to below .64.
  * An error may occur when sorting bags.
  * Added additional checks for forbidden frames.
  * Ensure minimap coordinates are not updating in an instance.




## [8.1 r20a] - 2017-06-21 ##
### Modified AddOns ###

  * !Aurora_RealUI
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init
  * RealUI_Bugs

### Added ###

  * There is a new option to change the UI Mod Scale. This will affect the size of a few select frames, like the Infobar.

### Changed ###

  * The text of an error will now be highlighted when clicked.
  * Certain Aurora options are no longer enforced.

### Fixed ###

  * Inturruptable spells would not display in the proper color.
  * The cooldown text will now have a more consistent size.
  * Fixed a few bugs that could taint the World Map.
  * Progress Watch should no longer switch to Honor for no reason.
  * Castbars in the healer layout will no longer overlap the action bars.
  * Healers should now be assigned to the Healer layout by default.




## [8.1 r20] - 2017-06-08 ##
### Removed AddOns ###

  * !BugGrabber
  * Bugger

### New AddOns ###

  * RealUI_Bugs

### Modified AddOns ###

  * !Aurora_RealUI
  * cargBags_Nivaya
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init

### Changed ###

  * Channeled spells have been updated for new and more recent tick info.
  * Added support for paragon reputations.
  * Death Knight Runes are now colored based on spec.
  * !BugGrabber and Bugger have been replaced with the new addon, RealUI_Bugs.

### Fixed ###

  * Cooldown count should no longer become unreadably small is some situations.
  * An error would sometimes occur when opening the bank or inventory if the bag bar was visible.
  * The reputation tracker no longer throws an error when displaying a faction at exalted.
  * Certain Infobar blocks should no longer shift positions between sessions.
  * Currency DB initialization is now more reliable.




## [8.1 r19g] - 2017-03-30 ##
### Modified AddOns ###

  * cargBags_Nivaya
  * nibRealUI

### Fixed ###

  * An arena error would occur sometimes after a load screen.
  * Mythic Keystones were not visible in bags.
  * Artifact Relics in bags would not show the proper item level bonus they provide.
  * Skinning the chat bubbles would cause an error while in a dungeon.




## [8.1 r19f] - 2017-03-27 ##
### Modified AddOns ###

  * EasyMail
  * FreebTip
  * nibRealUI

### Removed AddOns ###

  * FreebTipSpec
  * FreebTipiLvl

### Changed ###

  * Infobar fonts will only have an outline when the background has a low opacity.
  * The default block gap has been increased.
  * Infobar font sizes have been adjusted.
  * Infobar blocks now inherit the chat font instead of normal.
  * The Spec and iLvl modules of FreebTip have been integrated into the main FreebTip addon

### Fixed ###

  * The font used for block tooltips would not respect font settings.
  * The Color Picker swatch would not display the correct color.
  * Various errors for patch 7.2




## [8.1 r19e] - 2017-02-24 ##
### Modified AddOns ###

  * cargBags_Nivaya
  * nibRealUI

### Fixed ###

  * Empty bag slots would not be shown even with the compress option disabled.
  * An error may occur for those on Connected Realms.




## [8.1 r19d] - 2017-02-23 ##
### Modified AddOns ###

  * cargBags_Nivaya
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init

### Added ###

  * The opacity of the Infobar can now be adjusted from fully transparent to fully opaque.
  * The total amount of money on a realm is shown in the Currency tooltip.

### Changed ###

  * New items will no longer passively reset as they are viewed.
  * The Currency block tooltip now also includes Connected Realms.
  * Class Resource updated to support up to 10 points.
  * Updated Russian locale.

### Fixed ###

  * Blocks would not show in the config if they were previously disabled.
  * Progress Watch status bars would not be properly updated when being toggled from disabled to enabled.




## [8.1 r19c] - 2017-02-15 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init

### Fixed ###

  * The Infobar would be oversized if the UI scale is larger than pixel perfect.
  * Alt-clicking a friend would not send a group invite.
  * Options for Master Loot would not appear when clicking an item.
  * Nothing would happen when clicking on a block while in combat even even with in combat tooltips enabled.
  * The layout would not change when switching between specs with different layouts.




## [8.1 r19b] - 2017-02-12 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config

### Changed ###

  * The list of blocks will now always be in alphabetical order.

### Fixed ###

  * An error would occur when toggling an option on the "All Blocks" row.
  * The font used for blocks would not respect font settings.
  * Block positions would sometimes not be preserved between sessions.




## [8.1 r19a] - 2017-02-10 ##
### Modified AddOns ###

  * nibRealUI

### Fixed ###

  * Moving a block on the Infobar could produce an error.




## [8.1 r19] - 2017-02-10 ##
### Modified AddOns ###

  * !Aurora_RealUI
  * cargBags_Nivaya
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Init
  * FreebTip
  * FreebTipiLvl

### Changed ###

  * Completely rewritten Infobar with support for LDB feeds.
  * Significant improvements to cargBags_Nivaya for better performance and reliability.
  * If they are controlled by RealUI, the position of Grid will be automatically adjusted for the position of the action bars.
  * Artifact relics are now sorted with gear and will show the item level increase they provide to an artifact.
  * Currency rewards from dungeons will now show your totals on other toons in the tooltip.

### Removed ###

  * The AuraTracker has been completely removed. [See the announcement post](http://www.wowinterface.com/forums/showthread.php?t=54839) for more information.

### Fixed ###

  * A proper layout will now be set when entering an arena.
  * Character tooltips should now have much more accurate iLvls.
  * The arena prep frames will now show opponent specs more reliably.

[Unreleased]: https://github.com/RealUI/RealUI/compare/master...develop
[8.1 r20d]: https://github.com/RealUI/RealUI/compare/8.1_r20c...8.1_r20d
[8.1 r20c]: https://github.com/RealUI/RealUI/compare/8.1_r20b...8.1_r20c
[8.1 r20b]: https://github.com/RealUI/RealUI/compare/8.1_r20a...8.1_r20b
[8.1 r20a]: https://github.com/RealUI/RealUI/compare/8.1_r20...8.1_r20a
[8.1 r20]: https://github.com/RealUI/RealUI/compare/8.1_r19g...8.1_r20
[8.1 r19g]: https://github.com/RealUI/RealUI/compare/8.1_r19f...8.1_r19g
[8.1 r19f]: https://github.com/RealUI/RealUI/compare/8.1_r19e...8.1_r19f
[8.1 r19e]: https://github.com/RealUI/RealUI/compare/8.1_r19d...8.1_r19e
[8.1 r19d]: https://github.com/RealUI/RealUI/compare/8.1_r19c...8.1_r19d
[8.1 r19c]: https://github.com/RealUI/RealUI/compare/8.1_r19b...8.1_r19c
[8.1 r19b]: https://github.com/RealUI/RealUI/compare/8.1_r19a...8.1_r19b
[8.1 r19a]: https://github.com/RealUI/RealUI/compare/8.1_r19...8.1_r19a
[8.1 r19]: https://github.com/RealUI/RealUI/compare/8.1_r18l...8.1_r19
