## [3.0.0-preview] ##

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
  * Aurora (12.0.1.9)

### Information ###
  * This is a preview release with major architectural improvements and new systems
  * Introduces comprehensive module framework, performance monitoring, and advanced configuration
  * All new systems are accessible via `/realui` config and `/realdev` test commands
  * Report issues at GitHub or connect with us on Discord
  * **IMPORTANT**: Addon folders have been renamed from nibRealUI to RealUI naming convention
  * Automatic migration system preserves all user settings from nibRealUIDB to RealUIDB

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

### Removed ###
  * KUI Nameplates - no longer being updated, replaced with Platynator
  * Debug message on scaling
  * nibRealUI_Dev replaced by RealUI_Dev
  * Kui_Nameplates addon data file

### Libraries Updated ###
  * LibQTip-1.0 replaced with LibQTip-2.0 (sourced from GitHub instead of WoWAce)
  * LibRangeCheck-3.0 updated to v1.0.17-9-gd53d7b0
  * BugGrabber updated through v12.0.2 → v12.0.3 → v12.0.5 → v12.0.6
  * AceSerializer added to pkgmeta and libs.xml

## Detailed Changes ##
[3.0.0]: https://github.com/RealUI/RealUI/compare/2.6.3...3.0.0
