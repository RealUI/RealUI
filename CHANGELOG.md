## [3.0.4] - 2026-03-10 ##
### Summary ###
Fixed infobar reputation block crashing when no faction is tracked, updated to use newer reputation APIs, and hardened Major Faction renown display. Removed tooltip money hooks that were causing "reported addon" blocks on gear upgrades. Aurora 12.0.1.14 fixes UIWidget taint by routing widget setup calls through securecallfunction.

### Modified AddOns ###
  * RealUI
  * RealUI_Tooltips
  * Aurora (12.0.1.14)

### Fixed ###
  * fix: Reputation on infobar
  * fix: reported addon block on gear upgrade


## [3.0.3] - 2026-03-06 ##
### Summary ###
Just a quick hotfix for a issue resolved in aurora 12.0.1.13 that was causing taint issues on the world map. This patch includes a fix for the GetUnscaledFrameRect global replacement that was introduced in aurora.

### Modified AddOns ###
  * Aurora (12.0.1.13)


## [3.0.2] - 2026-03-06 ##
### Summary ###
Stability patch addressing taint issues and minor fixes. Includes a LibStrata taint fix, a WorldMap skin toggle to avoid SetPassThroughButtons taint on map pins, a fix for secret value leaking through isAFK, and a Grid2RaidDebuffs namespace guard. Also fixes combo points display not clearing when leaving layout mode.

### Modified AddOns ###
  * RealUI
  * RealUI_Skins
  * Aurora (12.0.1.12)

### Fixed ###
  * chg: l Blizzard_Worldmap handling placed back to Aurora
  * fix: taintfix in LibStrata
  * Clear combo points display when leaving layout mode [#116] [CalebHolt]
  * fix: Add option to disable Aurora's WorldMap skin — a taint bug causes SetPassThroughButtons ADDON_ACTION_BLOCKED on map pins when any addon modifies WorldMapFrame children. Toggle available in RealUI Config → Skins → Appearance.
  * Merge branch 'develop' of github.com:RealUI/RealUI into develop
  * (origin/main, origin/HEAD) fix: another instance of isAFK getting a secret
  * fix: make sure namespaces.Grid2RaidDebuffs exists.. if not create it

## [3.0.1] - 2026-03-03 ##

### Summary ###
Hotfix for taint introduced in aurora 12.0.1.10

### Modified AddOns ###
  * Aurora (12.0.1.11)

### Fixed ###
  * fix: Revert GetUnscaledFrameRect global replacement — overwriting this global taints every LayoutFrame call, causing massive CooldownViewer combat taint (aurora).


## [3.0.0] - 2026-03-03 ##

### Summary ###
RealUI 3.0.0 represents a major milestone with comprehensive architectural improvements and modernization for World of Warcraft 12.0+. This release includes the addon renaming from nibRealUI to RealUI, a complete HUD unit frame rewrite, extensive taint fixes, and integration of new frameworks.

Key highlights include a new module framework system with dependency management, automatic profile and layout switching, resolution optimization, compatibility management, and comprehensive error recovery. The addon now includes Platynator nameplate profiles (replacing the discontinued KUI Nameplates), full support for Banks and Warbanks introduced in WoW 11+, and numerous stability improvements addressing taint issues that caused ADDON_ACTION_BLOCKED errors.

All user settings are automatically migrated from nibRealUIDB to RealUIDB, ensuring a seamless upgrade experience. Aurora has been updated to version 12.0.1.10 with extensive WoW 12 compatibility fixes and taint protections.

### Modified AddOns ###
  * RealUI (formerly nibRealUI)
  * RealUI_Config (formerly nibRealUI_Config)
  * RealUI_Dev (formerly nibRealUI_Dev)
  * RealUI_Bugs
  * RealUI_Skins
  * RealUI_Inventory
  * RealUI_Chat
  * RealUI_CombatText
  * RealUI_Tooltips
  * Aurora (12.0.1.10)

### Information ###
  * Major release with architectural improvements and new systems
  * Introduces comprehensive module framework, performance monitoring, and advanced configuration
  * All new systems are accessible via `/realui` config (and `/realdev` test commands for developers)
  * Report issues at GitHub or connect with us on Discord
  * **IMPORTANT**: Addon folders have been renamed from nibRealUI to RealUI naming convention
  * Automatic migration system preserves all user settings from nibRealUIDB to RealUIDB
  * Compatible with World of Warcraft 12.0+ (Midnight)
  * There are still bugs and tweaks needed over the coming weeks.

### Added ###
  * Addon Renaming - Folders renamed from nibRealUI to RealUI naming convention
  * SavedVariables Migration - Automatic migration from nibRealUIDB to RealUIDB preserving all user settings
  * Module Framework System - Comprehensive module management with dependency handling and lifecycle control
  * Performance Monitor - Real-time tracking of memory, CPU, and FPS with alerting system
  * Profile System - Enhanced profile management with backup/restore and character registration
  * Layout Manager - Automatic layout switching based on specialization with manual override
  * Resolution Optimizer - Automatic HuD optimization for different screen resolutions
  * Compatibility Manager - Addon conflict detection and safe mode operation
  * Deployment Validator - System validation checks to ensure proper initialization
  * Resource Manager - Memory and resource optimization system
  * Error Recovery - Enhanced error handling and recovery mechanisms
  * Configuration UI - New "Systems" tab in config with controls for all new systems
  * Dev Commands - `/realdev testmodules`, `testperf`, `testprofile`, `testlayout`, `testresolution`, `testcompat`, `testdeploy`, and `testall`
  * HUD Test Suite - Comprehensive test suite for HuD positioning and unit frames
  * RealUI_Dev test suite for Bank addon (20+ test files covering bags, filters, slots, lifecycle, etc.)
  * Platynator profiles added to setup - replaces KUI Nameplates (thanks to zENK for the profile)
  * DragEmAll support for Blizzard_HousingDashboard, Blizzard_Professions, Blizzard_ProfessionsBook
  * DragEmAll force move for Blizzard_PlayerSpells and similar frames
  * Razer Naga Action Bar (BTBar2) configurable
  * General_Scale string added to enUS locale
  * GitHub Copilot instructions file
  * RealUI_Inventory support for Banks and Warbanks (post WoW 11)
  * Store menu item restored on Infobar

### Changed ###
  * Rewrite of the HUD unit frame system
  * Converted nibRealUI to RealUI with full migration support
  * InstallWizard now requires a reload on setup
  * Screen optimization on small screens with high resolution before starting wizard
  * Updated HuD Vertical ActionBar description
  * Moved reset command from `/realdev` to `/realui`
  * Performance monitor no longer on by default - optional addition
  * DragEmAll updated to add force move capability
  * IsEquippedItem API usage removed (deprecated by Blizzard)
  * Updated .pkgmeta configuration
  * Next beta target set to 13.0.0
  * Removed unused code and comments throughout
  * Moved core tests from RealUI to RealUI_Dev
  * Boss UID handling updated to avoid secret values
  * Work on importing Platynator defaults
  * Aurora updated for WoW 12 compatibility with extensive API modernization
  * Replaced deprecated WoW API calls throughout Aurora
  * Updated ObjectiveTracker, ActionBarController, and multiple Blizzard UI skins for WoW 12
  * Improved error handling with pcall wrappers for protected/secret values
  * Enhanced RealUI_Skins with toggle to disable World Map skin if taint issues occur

### Fixed ###
  * HUD growth direction fix
  * HUD unit tests fix
  * In-combat lockdowns to stop taints and errors
  * In-combat taint issues
  * Loot roll windows
  * uiScaleChanging keeps tainting stuff
  * uiScale was broken and tainted UI
  * Block tooltips
  * Three unguarded ndb.settings accesses causing crash on spec change
  * Taint error in GetVisualPercent
  * Dragging for Blizzard_Professions
  * DragEmAll for Blizzard_ProfessionsBook
  * Error in regioninfo of RealUI_Bugs
  * PerformanceMonitor fixes
  * Performance Monitor caused script timeout by scanning all installed addons on every memory check
  * Secret string value tainted by RealUI_Bugs
  * World map taint error causing ADDON_ACTION_BLOCKED when opening map (RealUI_Skins)
  * WorldMapFrame update
  * RealUI_Dev throws error on certain early loads
  * Screensaver should not start on auto on reload
  * Turn off ScreenSaver on movement
  * LibQTip-2 frame initialization before use
  * ResourceManager.lua script ran too long
  * Side bars positioning and vertical orientation
  * RealUI Config bar positioning issue
  * Checks for minWidth and maxWidth being secret/tainted
  * Safety check for db and db.positioners initialization
  * Nil check for db.units before accessing unit-specific settings (Shared.lua)
  * UpdateReverse function nil check for ndb.settings during profile switching
  * Error in Infobar module when switching profiles/specs
  * Nil checks for item quality and color when not yet available
  * oUF auras element sortedBuffs and sortedDebuffs table initialization
  * Boss being nil
  * ShowWarning method being nil
  * scanningTooltip being nil
  * Upgrade notification error
  * Update system bugs
  * Detection of older version
  * Modules not being loaded properly
  * Missed AceSerializer in pkgmeta and libs.xml
  * Database integrity validation errors during deployment
  * "attempt to index a nil value" errors in ModuleFramework OnProfileUpdate
  * "attempt to call method 'ScheduleTimer'" errors in ResolutionOptimizer and CompatibilityManager
  * "bad argument #1 to 'max' (number expected, got nil)" in FrameMover position validation
  * "attempt to index global 'stageContent'" in InstallUI onShow handler
  * "attempt to call method 'GetAvailableProfiles'" in SystemsConfig profile dropdown
  * All 7 modules (CooldownCount, FrameMover, Loot, ActionBars, EventNotifier, SpellAlerts, WorldMarker) now properly enable on load
  * GetUnscaledFrameRect secret number taint in UIWidget tooltip layout (Aurora)
  * SetPassThroughButtons taint on WorldMap pins mitigated with optional skin disable (RealUI_Skins)
  * ADDON_LOADED contamination in action bar initialization chain (Aurora)
  * Multiple Aurora taint fixes for WoW 12 compatibility
  * Secret value protections in chat bubbles and widget debug names (Aurora)

### Removed ###
  * KUI Nameplates - no longer being updated, replaced with Platynator
  * Debug message on scaling
  * nibRealUI_Dev replaced by RealUI_Dev
  * Kui_Nameplates addon data file

### Libraries Updated ###
  * LibQTip-1.0 replaced with LibQTip-2.0 (sourced from GitHub instead of WoWAce)
  * LibRangeCheck-3.0 updated to v1.0.17-9-gd53d7b0
  * BugGrabber updated through v12.0.2 → v12.0.3 → v12.0.5 → v12.0.6 → v12.0.7
  * AceSerializer-3.0 added to pkgmeta and libs.xml
  * oUF framework updated (13.3.0)
  * HereBeDragons library updated to latest
  * LibDualSpec-1.0 updated to latest
  * LibIconFonts updated to latest
  * LibWindow-1.1 updated to latest
  * LibItemUpgradeInfo-1.0 updated to latest
  * LibSharedMedia-3.0 updated to latest
  * LibObjectiveProgress-1.0 updated to latest

## Detailed Changes ##
[3.0.4]: https://github.com/RealUI/RealUI/compare/3.0.3...3.0.4
[3.0.3]: https://github.com/RealUI/RealUI/compare/3.0.2...3.0.3
[3.0.2]: https://github.com/RealUI/RealUI/compare/3.0.1...3.0.2
[3.0.1]: https://github.com/RealUI/RealUI/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/RealUI/RealUI/compare/2.6.3...3.0.0
