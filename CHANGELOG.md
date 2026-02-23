## [3.0.0-preview] ##
### Modified AddOns ###
  * RealUI (formerly nibRealUI)
  * RealUI_Config (formerly nibRealUI_Config)
  * RealUI_Dev (formerly nibRealUI_Dev)
  * Aurora

### Information ###
  * This is a preview release with major architectural improvements and new systems
  * Introduces comprehensive module framework, performance monitoring, and advanced configuration
  * All new systems are accessible via `/realui` config and `/realdev` test commands
  * Report issues at GitHub or connect with us on Discord
  * **IMPORTANT**: Addon folders have been renamed from nibRealUI to RealUI naming convention
  * Automatic migration system preserves all user settings from nibRealUIDB to RealUIDB

### Added ###
  * **Addon Renaming** - Folders renamed from nibRealUI to RealUI naming convention for better clarity
  * **SavedVariables Migration** - Automatic migration from nibRealUIDB to RealUIDB preserving all user settings
  * **Module Framework System** - Comprehensive module management with dependency handling and lifecycle control
  * **Performance Monitor** - Real-time tracking of memory, CPU, and FPS with alerting system
  * **Profile System** - Enhanced profile management with backup/restore and character registration
  * **Layout Manager** - Automatic layout switching based on specialization with manual override
  * **Resolution Optimizer** - Automatic HuD optimization for different screen resolutions
  * **Compatibility Manager** - Addon conflict detection and safe mode operation
  * **Deployment Validator** - System validation checks to ensure proper initialization
  * **Resource Manager** - Memory and resource optimization system
  * **Error Recovery** - Enhanced error handling and recovery mechanisms
  * **Configuration UI** - New "Systems" tab in config with controls for all new systems
  * **Dev Commands** - Added `/realdev testmodules`, `testperf`, `testprofile`, `testlayout`, `testresolution`, `testcompat`, `testdeploy`, and `testall`

### Changed ###
  * fix: SetDefaultModulePrototype now called at file load time to prevent Ace3 initialization errors
  * fix: Module enabling moved to OnEnable to ensure all modules are registered before enabling
  * fix: Resolution optimization notifications only show when category actually changes, not on every reload
  * fix: Install wizard now has proper backdrop with texture instead of being transparent
  * fix: ProfileSystem character registration deferred if charInfo not yet available
  * fix: Added nil checks throughout for database, profile, and charInfo structures
  * fix: ResolutionOptimizer and CompatibilityManager now include AceTimer-3.0 mixin
  * fix: InstallUI uses Aurora's SetBackdrop API instead of deprecated WoW API
  * chg: Removed calls to non-existent methods (OptimizeModuleLoading, OptimizeFrameUpdates, RefreshLayout, etc.)
  * chg: ProfileManager now has HasBackups() method for deployment validation
  * chg: DiagnosticTools uses GetPerformanceData() instead of non-existent GetMonitoringState()
  * chg: CompatibilityManager Grid2 integration updated to use proper frame registration
  * chg: DeploymentValidator initialization moved to after database setup
  * chg: Module Framework validation check made more lenient for module registration

### Fixed ###
  * fix: Database integrity validation errors during deployment
  * fix: "attempt to index a nil value" errors in ModuleFramework OnProfileUpdate
  * fix: "attempt to call method 'ScheduleTimer'" errors in ResolutionOptimizer and CompatibilityManager
  * fix: "bad argument #1 to 'max' (number expected, got nil)" in FrameMover position validation
  * fix: "attempt to index global 'stageContent'" in InstallUI onShow handler
  * fix: "attempt to call method 'GetAvailableProfiles'" in SystemsConfig profile dropdown
  * fix: All 7 modules (CooldownCount, FrameMover, Loot, ActionBars, EventNotifier, SpellAlerts, WorldMarker) now properly enable on load

## Detailed Changes ##
[3.0.0-preview]: https://github.com/RealUI/RealUI/compare/2.6.2...3.0.0-preview


