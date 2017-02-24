# Change Log #
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/).

## [Unreleased] ##




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
[8.1 r19e]: https://github.com/RealUI/RealUI/compare/8.1_r19d...8.1_r19e
[8.1 r19d]: https://github.com/RealUI/RealUI/compare/8.1_r19c...8.1_r19d
[8.1 r19c]: https://github.com/RealUI/RealUI/compare/8.1_r19b...8.1_r19c
[8.1 r19b]: https://github.com/RealUI/RealUI/compare/8.1_r19a...8.1_r19b
[8.1 r19a]: https://github.com/RealUI/RealUI/compare/8.1_r19...8.1_r19a
[8.1 r19]: https://github.com/RealUI/RealUI/compare/8.1_r18l...8.1_r19

