## [3.1.0] - 2026-03-23 ##
### Summary ###
**BREAKING CHANGE** — Profile management has been completely reworked. RealUI now has a Unified Profile System that manages Core, Skins, and Bartender4 profiles together from a single page. You can assign a different profile to each of your specializations (e.g. a druid can have separate profiles for Balance, Feral, Guardian, and Restoration), and when you change specs LibDualSpec will automatically switch all linked scopes in one coordinated action. Scope link toggles let you control which addons participate — Skins can be shared across all specs while Bartender4 follows your spec. New profiles inherit settings from your current profile instead of starting empty. Export and import lets you share profiles as text strings. An automated migration runs on first login to move your existing settings into the new system — no manual action required, but a /reload will be prompted.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins

### Added ###
  * add: Unified Profile Page under Advanced → Profiles with tabbed interface (General, Core Scope, Skins Scope, BT4 Scope, Export/Import)
  * add: ProfileCoordinator — coordinated profile switching across Core, Skins, and Bartender4 with combat deferral and reentrancy guard
  * add: per-specialization profile mapping — assign any profile to each spec via DualSpec Mapping section
  * add: scope link toggles — control whether Skins and Bartender4 follow Core profile switches
  * add: ProfileExporter — AceSerializer + base64 export/import for single or combined scope profiles
  * add: create new profile and delete profile controls on the General tab (built-in RealUI/RealUI-Healing profiles protected from deletion)
  * add: OnCoreProfileChanged callback — external profile switches (LibDualSpec, manual) now coordinate all linked scopes automatically
  * add: scopeLinks migration from db.profile to db.char (per-character, not per-profile)
  * add: use /resetinventory in-game to reset both the inventory and bank frames to their default positions.

### Changed ###
  * chg: profile management removed from individual scope tabs — all switching now routes through CoordinatedSwitch
  * chg: Bartender4 AddonData now reads custom per-spec mappings from DualSpecSystem instead of hardcoding role-based defaults
  * chg: new profiles created via CoordinatedSwitch inherit settings from the current profile via CopyProfile

### Fixed ###
  * fix: Bartender4 LibDualSpec mappings not syncing with RealUI's per-spec assignments — BT4's own LDS integration now kept in lockstep
  * fix: RealUI_Skins SetAlpha crash on profile switch — stale private.skinsDB reference now updated in OnProfileChanged/OnProfileCopied/OnProfileReset callbacks


## [3.0.10] - 2026-03-21 ##
### Summary ###
Nine-bug fix package targeting stability, usability, and profile reliability. Group loot roll windows now properly close after rolling instead of stacking up and blocking subsequent rolls. Castbar spell name and timer text no longer gets hidden behind the fill texture. Bartender4 mouseover casting now works correctly over RealUI unit frames. WoW's built-in "Use UI Scale" CVar is now actively suppressed to prevent it from overriding RealUI's scale management, with a 15-second notification explaining the conflict. Healer profile switching no longer incorrectly disables unrelated modules, and Bartender4 profile customizations are preserved across profile changes via a new userOverride flag in AddonControl. Player buffs are now displayed above the player unit frame, matching the existing target buff layout. The install wizard no longer re-triggers on every login for already-configured characters. The MiniPatch system now correctly handles major version transitions (2.5.x→3.0.0) and includes reserved slots for all 3.0.x incremental patches. Aurora's duplicate "UI Scale" message on login is fully suppressed when RealUI_Skins is the host addon. Also added NotificationWithDuration API for timed notification display, and moved dev test files from RealUI to RealUI_Dev to keep them out of release packages.

### Modified AddOns ###
  * RealUI
  * RealUI_Dev
  * RealUI_Skins
  * Aurora (12.0.1.19)

### Added ###
  * add: player buffs element on player unit frame, anchored above the frame matching target buff pattern
  * add: NotificationWithDuration API for displaying notifications with custom durations
  * add: userOverride flag in AddonControl to preserve user-customized addon profiles across profile switches
  * add: MiniPatch [0] for 2.5.x→3.0.0 major version transition (nibRealUI→RealUI migration, deprecated 2.x data cleanup)
  * add: reserved MiniPatch slots [2]–[9] for 3.0.x incremental data migrations
  * add: LOOT_ROLLS_COMPLETE safety-net handler for group loot cleanup

### Changed ###
  * chg: UI Scale CVar guard — WoW's "Use UI Scale" is now force-disabled at startup and mid-session with a 15-second notification
  * chg: MiniPatchInstallation now runs minipatches[0] and all patch-level minipatches on cross-major-version upgrades
  * chg: dev test files (BugConditionTests, PreservationTests) moved from RealUI to RealUI_Dev

### Fixed ###
  * fix: group loot roll window not closing after clicking Need/Greed/Disenchant/Pass — roll entry now removed from grouplootlist immediately after RollOnLoot
  * fix: castbar spell name and timer text obscured by AngleStatusBar fill texture — text now parented to a higher-level overlay frame
  * fix: Bartender4 mouseover cast not detecting unit on RealUI frames — overlay frame mouse disabled so GetMouseFocus returns the unit frame
  * fix: WoW "Use UI Scale" CVar silently overriding RealUI scaling with no user feedback
  * fix: healer profile switch incorrectly disabling unrelated modules — module enabled states now snapshot/restored across profile cascade
  * fix: Bartender4 profile reset to "RealUI" on every profile event — userOverride flag now respected in SetProfileKeys
  * fix: CastBars module disabled after profile switch — explicitly re-enabled if incorrectly toggled off
  * fix: profile forcing running outside install wizard when user had custom addon profiles
  * fix: player buffs not displayed above player unit frame
  * fix: install wizard re-triggering on every login for already-configured characters — SetupSystem now checks installStage and initialized before NeedsSetup
  * fix: setupVersion not set for existing characters, causing NeedsSetup to always return true
  * fix: duplicate "UI Scale" + "Effective Scale" messages on login — private.scaleReported and AURORA_SCALE_REPORTED set early in RealUI_Skins OnLoad


## [3.0.9] - 2026-03-17 ##
### Summary ###
Reworked UI Scale strategy to be taint-safe. Engine scale (UIParent:SetScale) is now applied once at login instead of at runtime, hopefully eliminating the taint issues that plagued previous approaches. Config panel changes (Pixel Perfect toggle, HiDPI mode, custom scale slider) now save values and prompt a /reload instead of live-applying, which avoids ADDON_ACTION_BLOCKED errors entirely. ResolutionOptimizer profiles gained isHighRes/isPixelScale flags so resolution detection feeds directly into the new scale path. Aurora 12.0.1.18 updated to defer to the host addon's scaling when present, removing its own redundant scale logic. Also fixed an action bar error on login for dual-spec characters when the current spec differs from the one used during initial setup.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins
  * Aurora (12.0.1.18)

### Changed ###
  * chg: UI Scale Strategy update

### Fixed ###
  * fix: action bar error on login for dual-spec characters when current spec differs from the one used during initial setup.


## [3.0.8] - 2026-03-16 ##
### Summary ###
Stability fixes for dual-spec characters (e.g. Priests). Modules now refresh their db reference on profile switch so stale data no longer causes cascading nil errors on login. Removed obsolete Blizzard bug-fix patches and TaintLess.xml (inert since 11.0). Cleaned up InspectFix dead hooks. BugGrabber updated to v12.0.11. RealUI_Config overhauled to expose all Aurora settings, consolidate duplicated options, and add missing controls. New config test suite in RealUI_Dev.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * RealUI_Config
  * RealUI_Dev
  * RealUI_Skins
  * Aurora (12.0.1.17)

### Added ###
  * add: config test suite in RealUI_Dev

### Changed ###
  * chg: BugGrabber v12.0.10 -> v12.0.11
  * chg: BugGrabber API updated — fixing compatibility
  * chg: updated RealUI_Config Advanced panel — unified/removed/updated config options
  * chg: Remove 4 obsolete Blizzard bug fixes (TradeSkill, Shipyard, AddonTooltip, EnableAddOn); fix PetJournal dragButton to preserve RightButtonUp
  * chg: Clean up InspectFix: remove dead hooks (TalentFrame, InspectUnit, OnUpdate), fix revstr crash, drop Examiner reference
  * chg: Remove TaintLess.xml — all patches inert on retail after Blizzard's Menu system migration in 11.0

### Fixed ###
  * fix: stale db references after DualSpec profile switch on login — fixes 6 cascading nil errors for dual-spec characters (Infobar, MinimapAdv, CastBars, FrameMover, ActionBars)
  * fix: nil positions table error on priest login (Infobar)
  * fix: don't try to move/allow dragging of frames if we are in combat — fixes taint
  * fix: PRNG updated — no longer uses xorshift32 or linear congruential


## [3.0.7] - 2026-03-14 ##
### Summary ###
Performance and GC hardening pass. PerformanceMonitor and ResourceManager now respect Aurora's combat GC mode — no more surprise collectgarbage("collect") calls mid-fight. ResourceManager check interval aligned with its data refresh rate (120s instead of 30s) to eliminate pointless timer callbacks. RealUI_CombatText restored and updated for WoW 12. BugGrabber updated to v12.0.10. Aurora updated to 12.0.1.16 with configurable GC tuning modes and object pooling.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * RealUI_CombatText
  * RealUI_Dev
  * Aurora (12.0.1.16)

### Added ###
  * add: configurable GC tuning settings UI in RealUI config panel
  * add: CombatText test suite in RealUI_Dev

### Changed ###
  * chg: PerformanceMonitor now honors Aurora's combat GC mode — skips GC during combat
  * chg: ResourceManager check interval aligned to data refresh rate (120s instead of 30s)
  * chg: RealUI_CombatText updated to work within WoW 12 limits
  * chg: BugGrabber v12.0.9 -> v12.0.10

### Fixed ###
  * fix: ResourceManager and PerformanceMonitor could fire collectgarbage("collect") during combat, undermining Aurora's combat GC pause mode
  * fix: CombatText TestMode fixes for RealUI_Dev tests


## [3.0.6] - 2026-03-13 ##
### Summary ###
Bug-fix and hardening pass. Fixes Grid2 setup crashes, Inventory bank errors, loot roll windows, and several combat taint sources. BugGrabber updated to v12.0.9. New stutter diagnostics and Inventory test coverage in RealUI_Dev.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * RealUI_Dev
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Bugs
  * RealUI_Dev
  * RealUI_Inventory
  * RealUI_Skins
  * Aurora (12.0.1.15)

### Added ###
  * add: stutter diagnostics to realui dev
  * add: extra tests and diag for RealUI_Inventory

### Changed ###
  * chg: BugGrabber v12.0.7-> v12.0.9

### Fixed ###
  * fix: setup issues with grid2 crashing and fubaring the setup
  * fix: RealUI_Inventory fix up for errors and faults on Character/Warband Bank
  * fix: loot window not closing after roll ++
  * fix: dont ScaleAPI.size in combat.
  * fix: Protected frames (force-hooked) may block EnableMouse/SetMovable


## [3.0.5] - 2026-03-11 ##
### Summary ###
Completed the migration from the old setup system to InstallWizard. The legacy installation window and Settings.lua setup code have been fully removed, eliminating a race condition between the two systems. The wizard gains a new Quality of Life stage with a repair mount selector (Tundra Mammoth, Grand Expedition Yak, Mighty Caravan Brutosaur) and a Razer Naga action bar toggle on the Layout stage. First-time character CVars and chat frame setup are now applied directly by InstallWizard on completion. Grid2 profile switching is wrapped in pcall to prevent errors during fresh installs.

### Modified AddOns ###
  * RealUI

### Added ###
  * add: new feawtures and qol seletions added to the install wizard

### Fixed ###
  * fix: removed last parts of the old setup system, migrated everything to InstallWizard - and removed a race condition


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
[3.1.0]: https://github.com/RealUI/RealUI/compare/3.0.10...3.1.0
[3.0.10]: https://github.com/RealUI/RealUI/compare/3.0.9...3.0.10
[3.0.9]: https://github.com/RealUI/RealUI/compare/3.0.8...3.0.9
[3.0.8]: https://github.com/RealUI/RealUI/compare/3.0.7...3.0.8
[3.0.7]: https://github.com/RealUI/RealUI/compare/3.0.6...3.0.7
[3.0.6]: https://github.com/RealUI/RealUI/compare/3.0.5...3.0.6
[3.0.5]: https://github.com/RealUI/RealUI/compare/3.0.4...3.0.5
[3.0.4]: https://github.com/RealUI/RealUI/compare/3.0.3...3.0.4
[3.0.3]: https://github.com/RealUI/RealUI/compare/3.0.2...3.0.3
[3.0.2]: https://github.com/RealUI/RealUI/compare/3.0.1...3.0.2
[3.0.1]: https://github.com/RealUI/RealUI/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/RealUI/RealUI/compare/2.6.3...3.0.0
