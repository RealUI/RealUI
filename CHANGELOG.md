## [3.1.16] - 2026-04-25 ##
### Summary ###
Feature and compatibility follow-up release after 3.1.15. MinimapAdv now supports task-based minimap POIs, Masque skin integration is updated for current API fields, and RealUI build support now includes 120005. Aurora is updated from 12.0.5.2 to 12.0.5.3 with PlayerSpells icon corrections and additional taint-safety hardening.

### Modified AddOns ###
  * RealUI
  * RealUI_Skins
  * Aurora (12.0.5.3)

### Added ###
  * add: task-based minimap POI handling in MinimapAdv

### Changed ###
  * chg: add build 120005 to supported RealUI game versions
  * chg: update Masque skin integration for newer API fields (`api_version`, `AutoCast_Corners`, `ChargeCooldown`, `AssistedCombatHighlight`)
  * chg: Aurora updated to 12.0.5.3 (from 12.0.5.2)

### Fixed ###
  * fix: Aurora 12.0.5.3 prefers base spell textures for PlayerSpells spec icons
  * fix: Aurora 12.0.5.3 prevents UIWidget container taint in restricted layout paths
  * fix: Aurora 12.0.5.3 wraps GameTooltip_AddWidgetSet in securecallfunction to avoid LayoutFrame secret-number taint
  * fix: Aurora 12.0.5.3 prevents PaperDoll stat taint from CharacterFrame skinning
  * fix: Aurora 12.0.5.3 uses SharedButtonSmallTemplate for dialog buttons on WoW 12.0.5


## [3.1.15] - 2026-04-24 ##
### Summary ###
Follow-up WoW 12.0.5 stability release. Unit frame abbreviation formatting now uses a hardened multi-path fallback for Blizzard's new API preconditions, cast bar tick placement ignores tainted haste values, AltPowerBar guards early update races, and RealUI_Bugs filters stale Private Aura updates from Blizzard. Aurora is updated from 12.0.5.0 to 12.0.5.2 with QueueStatusFrame taint and SetVertexColor compatibility fixes.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * RealUI_Dev
  * Aurora (12.0.5.2)

### Changed ###
  * chg: Aurora updated to 12.0.5.2 (from 12.0.5.0)
  * chg: remove unused `Test.lua` entry from the RealUI_Dev TOC

### Fixed ###
  * fix: harden unit-frame abbreviated number formatting for WoW 12.0.5 with formatter, legacy config, default Blizzard, and pure-Lua fallback paths
  * fix: ignore secret or nonnumeric `UnitSpellHaste("player")` values when computing cast bar ticks to prevent tainted arithmetic on channel bars
  * fix: guard PlayerPowerBarAlt against early update callbacks before the bar frame exists so stale events stop raising errors
  * fix: filter stale `updatedAuraInstanceIDs` in Blizzard PrivateAuras updates before forwarding to Blizzard handlers to avoid race-driven nil aura data
  * fix: Aurora 12.0.5.2 avoids QueueStatusFrame tooltip-backdrop taint and protects `SetVertexColor` calls with Blizzard color objects on 12.0.5


## [3.1.14] - 2026-04-23 ##
### Summary ###
WoW 12.0.5 compatibility update. Hardened abbreviation config for new API preconditions, bumped all TOC Interface versions to 120005. Aurora updated to 12.0.5.0 with initial 12.0.5 compatibility fixes. Some upstream addons (oUF) are not yet updated for 12.0.5.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins
  * RealUI_Bugs
  * RealUI_Dev
  * RealUI_Tooltips
  * RealUI_Inventory
  * RealUI_CombatText
  * RealUI_Chat
  * !RealUI_Preloads
  * nibRealUI
  * Aurora (12.0.5.0)

### Changed ###
  * chg: bump ## Interface to 120005 for all RealUI TOC files
  * chg: Aurora updated to 12.0.5.0 with initial 12.0.5 compatibility

### Fixed ###
  * fix: harden abbreviation config in UnitFrames Tags.lua with pcall fallback for 12.0.5 CreateAbbreviateConfig precondition changes (RequiresRestrictedAbbreviationBreakpoints)
  * fix: add multi-path fallback strategy — AbbreviatedNumberFormatter (12.0.5+), CreateAbbreviateConfig (legacy), AbbreviateNumbers defaults, pure-Lua K/M/B
  * fix: update UF_BreakpointSuffixTest and UF_AbbrevFormatTest for new precondition behavior and fallback paths

### Known Issues ###
  * oUF privateauras element needs upstream update for new isContainer field in C_UnitAuras.AddPrivateAuraAnchor args


## [3.1.13] - 2026-04-18 ##
### Summary ###
Unit frame status text now supports a configurable outline mode, Infobar hint text spacing is improved for readability, and performance monitor timeout handling is hardened so timers shut down correctly when monitoring is disabled. Aurora is updated from 12.0.1.30 to 12.0.1.31 with status text outline styling updates and fixes for ExternalDefensivesFrame and LootHistory item name visibility.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * Aurora (12.0.1.31)

### Added ###
  * add: configurable status text outline mode for health and power labels on unit frames

### Changed ###
  * chg: Infobar adds spacing above the Guild/Friends whisper-invite hint line for clearer separation
  * chg: Aurora updated to 12.0.1.31 (from 12.0.1.30)

### Fixed ###
  * fix: harden performance monitor timeout handling and enforce timer shutdown when the feature is disabled
  * fix: Aurora 12.0.1.31 removes the ExternalDefensivesFrame container backdrop to prevent an always-visible empty bar
  * fix: Aurora 12.0.1.31 hides LootHistory BackgroundArtFrame textures so item names remain visible


## [3.1.12] - 2026-04-16 ##
### Summary ###
Configurable aura button sizing, BugGrabber update, packaging fix, and new Aurora skins. Aura buttons now support user-configurable sizes with automatic container resizing. BugGrabber updated to v12.0.14. Aurora updated from 12.0.1.29 to 12.0.1.30 with skins for Housing, GenericShoppingCart, and Subtitles.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * Aurora (12.0.1.30)

### Changed ###
  * chg: BugGrabber updated to v12.0.14

### Added ###
  * add: configurable aura button size with automatic container resize
  * add: Aurora 12.0.1.30 adds skins for Blizzard_Housing, Blizzard_GenericShoppingCart, and Blizzard_Subtitles


## [3.1.11] - 2026-04-14 ##
### Summary ###
Taint safety hardening, library updates, dead code cleanup, and a massive Aurora skin expansion. ObjectiveProgress and Tooltips now use C_Secrets methods to prevent secret-number taint. BugGrabber updated to v12.0.12 and LibRangeCheck-3.0 to 1.0.17-10. Aurora updated from 12.0.1.28 to 12.0.1.29 with 25 new Blizzard addon skins covering nameplates, professions, talents, allied races, PvP, and legacy expansion content.

### Modified AddOns ###
  * RealUI
  * RealUI_Bugs
  * RealUI_Tooltips
  * Aurora (12.0.1.29)

### Changed ###
  * chg: update ObjectiveProgress to be protected by C_Secrets methods
  * chg: update Tooltips to be protected by new C_Secrets methods
  * chg: BugGrabber updated to v12.0.12
  * chg: LibRangeCheck-3.0 upgraded from 1.0.17-9 to 1.0.17-10
  * chore: clean up dead code in Loot module
  * chore: remove dead code from RealUI_Tooltips

### Added ###
  * add: Aurora 12.0.1.29 adds 25 new addon skins — Blizzard_AlliedRacesUI, Blizzard_AutoCompletePopupList, Blizzard_ClassTrial, Blizzard_ClickBindingUI, Blizzard_ContentTracking, Blizzard_CovenantToasts, Blizzard_CustomizationUI, Blizzard_DelvesToast, Blizzard_ExpansionTrial, Blizzard_GenericTraitUI, Blizzard_GuildRename, Blizzard_ItemBeltFrame, Blizzard_MajorFactions, Blizzard_NamePlates, Blizzard_ObliterumUI, Blizzard_PerksProgram, Blizzard_PlunderstormPrematchUI, Blizzard_ProfessionsCustomerOrders, Blizzard_QuestTimer, Blizzard_QuickKeybind, Blizzard_RemixArtifactUI, Blizzard_ReportFrame, Blizzard_RuneforgeUI, Blizzard_SharedTalentUI, Blizzard_StableUI

### Fixed ###
  * fix: Aurora 12.0.1.29 resolves taint-safe PVP queue/join button skinning to prevent JoinBattlefield ADDON_ACTION_FORBIDDEN, and guards NameFrame nil in LargeItemButtonTemplate for PVP loot buttons
  * fix: anchor EAB and ZoneAbility to left of topmost bar


## [3.1.10] - 2026-04-10 ##
### Summary ###
Combat text event queue handling, stagger bar fixes, taint safety improvements, and a major Aurora skin expansion. RealUI_CombatText now summarizes rapid event queues to prevent flooding. Stagger and Soul Fragment bars now fill correctly after decoupling Lua fill from the C++ StatusBar engine. Protected frame repositioning is deferred during combat to prevent ADDON_ACTION_BLOCKED. Aurora updated from 12.0.1.27 to 12.0.1.28 with 14 new Blizzard addon skins covering combat/HUD, matchmaking/PvP, and utility addons.

### Modified AddOns ###
  * RealUI
  * RealUI_CombatText
  * RealUI_Inventory
  * Aurora (12.0.1.28)

### Added ###
  * add: CombatText_Summary system for RealUI_CombatText to handle rapid event queue growth — summarize, report, drop queue, and continue
  * add: Aurora 12.0.1.28 adds 14 new addon skins — Blizzard_DamageMeter, Blizzard_EncounterTimeline, Blizzard_EncounterWarnings, Blizzard_CooldownViewer, Blizzard_BuffFrame, Blizzard_MatchmakingQueueDisplay, Blizzard_EndOfMatchUI, Blizzard_PersonalResourceDisplay, Blizzard_SpellDiminishUI, Blizzard_WorldLootObjectList, Blizzard_CombatLog, Blizzard_ScriptErrorsFrame, Blizzard_HelpPlate, Blizzard_DelvesCompanionConfiguration

### Fixed ###
  * fix: stagger bar not growing — add DisableNativeFill() to decouple Lua fill from C++ StatusBar engine for non-secret bars (Stagger, SoulFragments); fix PostUpdateColor to accept ColorMixin and replace removed BREWMASTER_POWER_BAR_NAME global
  * fix: defer protected frame repositioning during combat to prevent ADDON_ACTION_BLOCKED
  * fix: only set RestingIndicator on player frame to avoid secret boolean taint
  * fix: guard ForceUpdate calls against nil when element init is incomplete
  * fix: add Grizzly Hills Packmaster to InstallWizard repair mount list
  * fix: Aurora 12.0.1.28 resolves CooldownViewer taint by using external weak table instead of writing _auroraSkinned on item frames, fixes EnumeratePools crash on categoryPool, and fixes CharacterSpecificLayoutCheckButton targeting inner .Button child


## [3.1.9] - 2026-04-06 ##
### Summary ###
Character setup reliability and new DH class feature. First-character setup now correctly applies all character-specific CVars and addon profiles (including Platynator) for every new character, not just the first account login. Demon Hunter Devourer Soul Fragments are now tracked with a Stagger-style resource bar. Aurora updated from 12.0.1.26 to 12.0.1.27 with new utility helpers and a combat nil-safety fix.

### Modified AddOns ###
  * RealUI
  * RealUI_Skins
  * Aurora (12.0.1.27)

### Added ###
  * add: Stagger-style bar for DH Devourer Soul Fragments

### Fixed ###
  * fix: always apply character CVars and addon profiles during setup, not just first account
  * fix: add Platynator profile activation and always set profile keys for new characters
  * fix: add AceTimer-3.0 mixin for ScheduleTimer in RefreshMod
  * fix: Aurora 12.0.1.27 replaces GetBackdrop call with _auroraSkinned check to prevent nil method error in combat, adds SkinOnce/CropCircularIcon/SetHighlightColor utility helpers


## [3.1.8] - 2026-04-05 ##
### Summary ###
Hotfix for unit frame aura toggle state not applying on login. Saved Show/Hide aura settings on player and target frames now take effect immediately when frames are first created, instead of requiring a manual config change to trigger.

### Modified AddOns ###
  * RealUI

### Fixed ###
  * fix: apply saved aura toggle state on init, not just on config change


## [3.1.7] - 2026-04-05 ##
### Summary ###
Stability and feature release focused on login reliability, Hero Talent positioning, and aura layout customization. Startup profile/layout initialization has been overhauled to prevent first-login thrash, healer-profile race conditions, and early-frame nil errors. Hero Talents can now be repositioned via a config preset dropdown, and aura icons on the player and target unit frames are now configurable in position. Resource/performance monitoring is disabled by default for all existing profiles as a safety measure. Aurora is updated from 12.0.1.25 to 12.0.1.26, bringing backdrop alpha fixes, bag button skin restructuring, Hero Talent anchor presets, and Blizzard file-structure alignment.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins
  * Aurora (12.0.1.26)

### Added ###
  * add: configurable aura layout positioning for player and target unit frames
  * add: Hero Talents anchor preset dropdown to config with preset-based positioning
  * add: optional HeroTalentsContainer custom re-anchor with default-off per-character behavior

### Changed ###
  * chg: additional tuning for heroTalentsAnchorPreset
  * chg: force resource/performance monitoring off by default for all existing profiles (users can re-enable manually)

### Fixed ###
  * fix: debounce initial-spec sync to prevent login profile/layout thrash and healer profile race resetting Bartender and oUF on first load
  * fix: throttle startup profile retries until ActionBars are initialized
  * fix: defer RefreshMod until frames exist on early login
  * fix: guard UnitFrames Shared against nil misc/units during UNIT_FACTION updates
  * fix: harden ResourceManager timeout handling
  * fix: Aurora 12.0.1.26 restores backdrop alpha transparency in SetBackdropColor, moves MainMenuBarBagButtons skin to its own addon, aligns TabSystemTemplates to the Blizzard restructure, and cleans up deprecated UIMenu code


## [3.1.6] - 2026-04-04 ##
### Summary ###
Bug-fix release addressing cooldown counter spam, loot roll issues, and oversized aura timers. Cooldown text no longer spams in dungeons and battlegrounds and is properly sized on unit frame buffs. Loot roll frames now re-populate after a reload and show correct transmog atlas textures instead of greed coin icons. Aurora is updated from 12.0.1.24 to 12.0.1.25, with tooltip taint fixes, NineSlice layout resolution, PVPMatchResults skinning work, and sanitized securecallfunction paths.

### Modified AddOns ###
  * RealUI
  * Aurora (12.0.1.25)

### Fixed ###
  * fix: cooldown counter spam in dungeons and battlegrounds
  * fix: protect against Timer update text with secret values
  * fix: re-populate custom roll frames from GetActiveLootRollIDs after reload
  * fix: use proper transmog atlas textures instead of greed coin icons on roll popup
  * fix: oversized aura cooldown text on unit frame buffs
  * fix: Aurora 12.0.1.25 resolves tooltip taint from NineSlice layout and GameTooltip_AddWidgetSet securecallfunction paths, sanitizes orderIndex after Setup calls, and wraps QuestMapLogTitleButton_OnEnter to prevent GetStringWidth secret number taint


## [3.1.5] - 2026-04-02 ##
### Summary ###
Minor follow-up release for the recent HuD totem work. Player totems now only initialize for Shamans, avoiding unnecessary element setup on other classes. Aurora is updated from 12.0.1.23 to 12.0.1.24, bringing DelvesDifficultyPicker and QuestMapFrame taint-related skinning fixes.

### Modified AddOns ###
  * RealUI
  * Aurora (12.0.1.24)

### Changed ###
  * chg: only create and load player totems for Shamans now that the oUF Totems element is enabled on the player frame

### Fixed ###
  * fix: Aurora 12.0.1.24 updates DelvesDifficultyPicker to use `DropdownButton` and stops skinning pooled QuestMapFrame title rows to avoid quest log tooltip taint


## [3.1.4] - 2026-04-01 ##
### Summary ###
This release refreshes RealUI's HuD and skinning stack, updating Aurora from 12.0.1.21 to 12.0.1.23 and oUF to 13.4.1. Player totems now use oUF's native Totems element with RealUI styling, cooldown swipes, fade integration, safer visibility handling in tainted paths, and fixes for disappearing or empty-duration slots. HuD class resources and power colors now understand the newer declassified aura-backed power types used by the updated oUF, including Frost Icicles and Hunter Tip of the Spear. Aurora configuration handling inside RealUI has also been hardened so embedded Aurora settings persist and stay synchronized more reliably across reloads and profile usage, while Aurora 12.0.1.23 adds another round of tooltip, pool, and Adventure Map taint fixes.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins
  * Aurora (12.0.1.23)
  * oUF (13.4.1)

### Added ###
  * add: native oUF Totems support on the player frame with RealUI styling, cooldown swipes, and CombatFader integration
  * add: HuD class resource support for Hunter Tip of the Spear and the expanded oUF 13.4.x declassified aura power set

### Changed ###
  * chg: update oUF to 13.4.1, bringing newer declassified aura power handling plus the follow-up totem fixes that landed after 13.4.0
  * chg: expand Mage class resource handling to support up to 5 charges so Frost Icicles and Arcane Charges both fit the same HuD path
  * chg: mute the new oUF 13.4.x Icicles and Tip of the Spear colors to match RealUI's subdued class-power palette
  * chg: Aurora configuration access in RealUI config and skins now uses synchronized helpers so shared Aurora settings survive reloads and embedded usage more reliably

### Fixed ###
  * fix: player totems no longer pass secret `haveTotem` values into `SetShown()` in tainted execution paths
  * fix: player totem widgets no longer disappear too quickly and now handle empty-duration slots correctly with the updated oUF totem behavior
  * fix: restore garrison landing button hover visibility by removing an erroneous fade-out path in the minimap module
  * fix: embedded Aurora no longer risks nil `AuroraConfig` access during startup/profile sync paths
  * fix: Aurora 12.0.1.22 resolves a race condition in `VisitHouse`
  * fix: Aurora 12.0.1.23 prevents delve tooltip hide taint from `GameTooltip_AddWidgetSet`, removes `titleFramePool` taint, and fixes an `AdventureMapFrame` pool-wrap nil error


## [3.1.3] - 2026-03-30 ##
### Summary ###
Hotfix release for a single HuD unit frame bug: AFK status checks now safely handle Blizzard secret booleans in tainted execution contexts, preventing status indicator failures and related protected-value issues.

### Modified AddOns ###
  * RealUI

### Fixed ###
  * fix: guard HuD AFK indicator status checks with `issecretvalue` so `UnitIsAFK()` cannot leak a restricted boolean into tainted code paths


## [3.1.2] - 2026-03-30 ##
### Summary ###
HuD unit frames now support optional Private Auras beneath the player and target frames plus angled health prediction overlays for incoming heals, damage absorbs, and heal absorbs. Both features are configurable from the HuD options. Shaman Maelstrom handling has been restored for class resources and additional power, the Housing editor storage panel can now be repositioned, CooldownCount ignores auxiliary action button cooldown overlays, and Open Checked Mail no longer runs blacklist checks on currency attachments. Aurora is updated from 12.0.1.20 to 12.0.1.21, bringing new Blizzard housing, covenant calling, delve, and PvP match skins along with additional taint-safe widget and pooled-frame fixes.

### Modified AddOns ###
  * RealUI
  * RealUI_Config
  * RealUI_Skins
  * Aurora (12.0.1.21)

### Added ###
  * add: Private Auras on player and target unit frames, anchored beneath the frames with mirrored left/right growth
  * add: angled health prediction overlays for incoming heals, damage absorbs, and heal absorbs using secret-taint-safe geometry
  * add: HuD config toggles for showing Private Auras and health prediction overlays

### Changed ###
  * chg: DragEmAll can now move Blizzard_HouseEditor's StoragePanel
  * chg: Aurora updated to 12.0.1.21 with new skins for Blizzard_CovenantCallings, Blizzard_DelvesDifficultyPicker, Blizzard_HousingControls, Blizzard_HousingTemplates, and PvP match results
  * chg: Aurora expands pooled-frame skinning coverage and consolidates pooled acquisition helpers for safer shared skinning paths

### Fixed ###
  * fix: restore Shaman MAELSTROM support for class resource display and additional power color updates
  * fix: guard AFK indicator updates against UnitIsAFK secret boolean taint during combat
  * fix: CooldownCount now ignores auxiliary action button cooldown frames instead of attaching duplicate timers to them
  * fix: Open Checked Mail no longer blacklists currency attachments as if they were item IDs


## [3.1.1] - 2026-03-25 ##
### Summary ###
HuD unit frame enhancements: health/power values now display abbreviated numbers (101K, 1.97M) using the WoW AbbreviateNumbers API. An optional "Alternative Bar Style" replaces the default dark-red health fill with a dark foreground that shrinks to reveal a configurable red background for missing health. Custom text colors for health, power, and name tags are available via color pickers with reset-to-default. Aura display on player, target, and boss frames is now individually toggleable with configurable counts. Player health/power bars no longer appear grey on reload (secret value timing fix). ActionBars no longer crash when the positions table is missing for the current layout.

### Modified AddOns ###
  * RealUI
  * RealUI_Config

### Added ###
  * add: abbreviated health/power numbers via AbbreviateNumbers API with breakpoint table (K at 10K, M at 1M, B at 1B)
  * add: Alternative Bar Style toggle — dark foreground with red background for missing health, opt-in via ConfigBar
  * add: custom text color pickers for health, power, and name tags with reset-to-default buttons
  * add: per-frame aura toggles and count sliders for player buffs, target debuffs/buffs, and boss debuffs/buffs
  * add: deferred ForceUpdate on all unit frames to fix secret-value color timing on reload

### Changed ###
  * chg: health bar foreground/background color options only visible when Alternative Bar Style is enabled
  * chg: oUF.colors.health swapped to dark foreground color when Alternative Bar Style is active
  * chg: HealthBG uses BORDER draw layer at same frame level as Health for correct layering
  * chg: CombatFader alpha hook hides HealthBG below 50% alpha to prevent red bleed-through when faded

### Fixed ###
  * fix: player health/power bars grey on reload — deferred ForceUpdate after native StatusBar engine initializes for secret values
  * fix: ActionBars crash at line 179 when ndb.positions[RealUI.cLayout] is nil — fallback to defaultPositions
  * fix: remove hardcoded references to 3.0.0 and use RealUI.verinfo.string instead


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
  * chg: only show reload dialog if install wizard won't run
  * chg: simplify the boss frames to remove taint

### Fixed ###
  * fix: Bartender4 LibDualSpec mappings not syncing with RealUI's per-spec assignments — BT4's own LDS integration now kept in lockstep
  * fix: RealUI_Skins SetAlpha crash on profile switch — stale private.skinsDB reference now updated in OnProfileChanged/OnProfileCopied/OnProfileReset callbacks
  * fix: remove moduleFrameworkConfig persistence that caused CastBars to disable on healer spec login


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
[3.1.16]: https://github.com/RealUI/RealUI/compare/3.1.15...3.1.16
[3.1.15]: https://github.com/RealUI/RealUI/compare/3.1.14...3.1.15
[3.1.14]: https://github.com/RealUI/RealUI/compare/3.1.13...3.1.14
[3.1.13]: https://github.com/RealUI/RealUI/compare/3.1.12...3.1.13
[3.1.12]: https://github.com/RealUI/RealUI/compare/3.1.11...3.1.12
[3.1.11]: https://github.com/RealUI/RealUI/compare/3.1.10...3.1.11
[3.1.10]: https://github.com/RealUI/RealUI/compare/3.1.9...3.1.10
[3.1.9]: https://github.com/RealUI/RealUI/compare/3.1.8...3.1.9
[3.1.8]: https://github.com/RealUI/RealUI/compare/3.1.7...3.1.8
[3.1.7]: https://github.com/RealUI/RealUI/compare/3.1.6...3.1.7
[3.1.6]: https://github.com/RealUI/RealUI/compare/3.1.5...3.1.6
[3.1.5]: https://github.com/RealUI/RealUI/compare/3.1.4...3.1.5
[3.1.4]: https://github.com/RealUI/RealUI/compare/3.1.3...3.1.4
[3.1.3]: https://github.com/RealUI/RealUI/compare/3.1.2...3.1.3
[3.1.2]: https://github.com/RealUI/RealUI/compare/3.1.1...3.1.2
[3.1.1]: https://github.com/RealUI/RealUI/compare/3.1.0...3.1.1
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
