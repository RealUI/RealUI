## [2.6.2] ##
### Modified AddOns ###
  * Aurora 12.0.1.6
  * oUF

## Detailed Changes ##
[2.6.3]: https://github.com/RealUI/RealUI/compare/2.6.2...2.6.3


## [2.6.2] ##
### Modified AddOns ###
  * nibRealUI
  * RealUI_Bugs
  * Aurora 12.0.1.1
  * BugGrabber v12.0.1
  * oUF

### Changed ###
  * fix: patched DragEmAll to avoid protected-call taint.
  * chg: updated the safe-boolean helper
  * chg: more secret units
  * chg: safe guards about booleans that might be secrets
  * fix: UnitFrames/Shared.lua: attempt to perform boolean test on a secret boolean value (tainted by 'RealUI_Core-2.6.1')
  * fix: AngleStatusBar.lua - attempt to compare a secret number value (tainted by 'RealUI_Core-2.6.1')
  * fix: MenuFrame.lua: attempt to index field 'menu' (a nil value)

## Detailed Changes ##
[2.6.2]: https://github.com/RealUI/RealUI/compare/2.6.1...2.6.2


## [2.6.1] ##
### Modified AddOns ###
  * Aurora 12.0.1.0
  * RealUI_Bugs
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Inventory
  * RealUI_CombatText (disabled)
  * RealUI_Skins
  * RealUI_Tooltips

### Information ###
  * This is the second release for Midnight - World of Warcraft 12.0.1
  * This release is a major update to the Blizzard UI - with many changes to the core and modules
  * Certain features have been disabled or removed due to changes in the Blizzard API
  * This version may be stable enoough for general use, but there are still some issues to be resolved
  * Report issues at GitHub or connect with us on Discord

### Changed ###
  * chore: on unitframes
  * chg: patch for reverse missing.
  * fix: sometimes moneyFrameWidth is secret for some reason!?
  * fix: Classpower is fixed for Midnight
  * chg: make player unit frame grow from center/decrease to center as default.. and it is configurable..
  * chg: attempt to index field 'CastingBarFrame'  error
  * chg: Guarded Health.PostUpdate against secret/nonnumeric values.
  * chg: Fixed a typo that caused uiScale CVar to be set unconditionally

## Detailed Changes ##
[2.6.1]: https://github.com/RealUI/RealUI/compare/2.6.0...2.6.1


## [2.6.0] ##
### Modified AddOns ###
  * Aurora 12.0.0.0
  * RealUI_Bugs
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Inventory
  * RealUI_CombatText (disabled)
  * RealUI_Skins
  * RealUI_Tooltips (disabled)

### Information ###
  * This is the first release for Midnight - World of Warcraft 12.0
  * This release is a major update to the Blizzard UI - with many changes to the core and modules
  * Certain features have been disabled or removed due to changes in the Blizzard API
  * This version may be stable enoough for general use, but there are still some issues to be resolved
  * Report issues at GitHub or connect with us on Discord

### Changed ###
  * chg: make sure LibRangeCheck-3.0 is from local as other is not yet published
  * removed: removed RealUI_CombatText from packaging
  * chg: fix for Moneyframe nil errors
  * fix: Tooltips bugs in raid
  * fix: PostUpdate max is secret error
  * chg: fix errors on boss fights from unitframes
  * chg: fix secret crash on castbar getalpha
  * fix: remove taints and secrets errors on castbars, in combat updates to LDB etc.
  * chg: Make tooltips secrets safe...
  * fix: dont bug out if currency does not exist on a toon.. currencyInfo can be nil
  * chg: fixes for depricated api in qol patch
  * chg: fixes to AngleStatusBar and oUF tags [Naessah]
  * chg: castbar - Use flat texture instead of gradient [Naessah]
  * add: infobar qol - durability repair and heartstone functionality [Naessah]
  * chg: qol updates to tooltip objectiveprogress [Naessah]
  * chg: updates to oUF unitframes and castbar [Naessah]
  * chg: attempt to change start menu item for store...
  * chg: api update for tooltips OutfitDetailsPanel -> CustomSetDetailsPanel
  * add: RealUI Config button to GameMenu...
  * chg: fix registered pet ui event
  * chg: disable RealUI_CombatText if someone loads it
  * add: ToggleHousingDashboard to infobar menu
  * chg: _G.QuestMapFrame.QuestsFrame.Contents is now _G.QuestMapFrame.QuestsFrame.ScrollFrame.Contents
  * chg: make castbars great again....
  * fix: CurveConstants is _G.CurveConstants
  * chg: dont load PredictOverride in prepatch
  * chg: AngleStatusBar - fix so Frames still get created with Frame and StatusBar as Statusbar
  * chg: make oUF not push errors..
  * chg: castbar/angelbare can only be StatusBar and not "Frame" - lets hope this does not brake something else
  * fix: RealUI. functions not available in RealUI_Bugs
  * fix: should still be 0
  * fix: range now works -  percent = _G.UnitHealthPercent
  * chg: oUF color override needs init with oUF:CreateColor
  * chg: introduction of C_CombatLog
  * chg: don't AbbreviateName where unit names are secret.
  * chg: use RealUI.isSecret
  * add: RealUI.isSecret function to check if output is secret.
  * chore: remove debug message
  * chg: Bartender - turned on grid by default, made visibility on/off also on by default. Will add as configurable
  * chore: updated uise of RealUI.isXX
  * tmp: wrapper for SetColorTexture on AngleFrame so we dont barf wen colors dont exist
  * chg: Buttonsizes for bars changed from 26 to 35
  * add: flags for isRetail, isDragonflight, isMidnight
  * Merge remote-tracking branch 'origin/main' into beta/midnight_1
  * chg: remove RealUI Dev addon profiler command
  * beta: beta toc 2.6.0
  * fix: classColors bugs out when classToken is ADVENTURER
  * beta: temp workaround for midnight
  * beta: temp workaround for midnight
  * fix: HelpPlate is now HelpPlateButton
  * beta: temp midnight workaround
  * beta: temp midnight workaround
  * chg: remove notifications about profiler - it is long gone

## Detailed Changes ##
[2.6.0]: https://github.com/RealUI/RealUI/compare/2.5.10...2.6.0


## [2.5.10] ##
### Modified AddOns ###
  * Aurora 11.2.7.2
  * nibRealUI
  * RealUI_Inventory

### Changed ###
  * chg: moved from NUM_CHAT_WINDOWS to Constants.ChatFrameConstants.MaxChatWindows

## Detailed Changes ##
[2.5.9]: https://github.com/RealUI/RealUI/compare/2.5.9...2.5.10

## [2.5.9] ##
### Modified AddOns ###
  * Aurora 11.2.7.1
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Inventory

### Changed ###
  * fix: bug in CUSTOM_CLASS_COLORS/LOCALIZED_CLASS_NAMES_MALE https://github.com/Stanzilla/WoWUIBugs/issues/798
  * fix: new enum.FrameTutorialAccount replaces LE_FRAME_TUTORIAL_ACCOUNT
  * fix: duplicate guid
  * add: housing xp tracking added (method from how to track xp with events found from ls-)

## Detailed Changes ##
[2.5.8]: https://github.com/RealUI/RealUI/compare/2.5.8...2.5.9



## [2.5.8] ##
### Modified AddOns ###
  * Aurora 11.2.7.0
  * nibRealUI

### Changed ###
  * fix: SetCVarBitfield throws error  LE_FRAME_TUTORIAL_ACCOUNT_*
  * chg: fix for ZoneAbilityFrame spellButton
  * chg: fix for double tap dragem..
  * BugGrabber - version: v11.2.5

## Detailed Changes ##
[2.5.7]: https://github.com/RealUI/RealUI/compare/2.5.7...2.5.8


## [2.5.7] ##
### Modified AddOns ###
  * Aurora 11.2.5.2
  * nibRealUI

### Changed ###
  * chg: fix an missing _G in EventRegistry
  * chg: make PlayerChoiceFrame moveable.
  * chg: fix for SUPER_TRACKING in Minimap
  * chore: removed some FIXLATERs
  * chg: OrderHall_CheckCommandBar removed from remix

## Detailed Changes ##
[2.5.6]: https://github.com/RealUI/RealUI/compare/2.5.6...2.5.7

## [2.5.6] ##
### Modified AddOns ###
  * Aurora 11.2.5.1
  * nibRealUI

### Changed ###
  * chg: infobar - blocks - removed druplicate ToggleHelpFrame
  * BugGrabber - version: v11.2.2

## Detailed Changes ##
[2.5.5]: https://github.com/RealUI/RealUI/compare/2.5.5...2.5.6


## [2.5.5] ##
### Modified AddOns ###
  * Aurora 11.2.5.0
  * nibRealUI

### Changed ###
  * chg: make WeeklyRewardsFrame moveable
  * chg: make CommunitiesGuildLogFrame moveable

## Detailed Changes ##
[2.5.4]: https://github.com/RealUI/RealUI/compare/2.5.4...2.5.5


## [2.5.4] ##
### Modified AddOns ###
  * Aurora 11.2.0.6
  * oUF
  * nibRealUI
  * RealUI_Bugs
  * RealUI_Skins
  * RealUI_Dev

### Changed ###
  * chg: Blizzard_PlayerSpells dragable
  * chg: renable part of blocks disabled to debug c stack overflow
  * add: make Blizzard_ProfessionsBook dragable..
  * chg: make CurrencyTransferMenu draggable
  * fix: C stack overflow fix in relation to GUILD_ROSTER_UPDATE
  * chg: add calendar back to minimenu, and remove store as it taints
  * chg: Patch 11.1.5 removed the ability to disable the profiler. It is now permanently enabled.
  * revert: blocks onupdate function
  * chg: more selfies replaced
  * chg: missed one self -> dialog
  * chg: Blizzard stopped using function(self) replaced function(dialog)

## Detailed Changes ##
[2.5.3]: https://github.com/RealUI/RealUI/compare/2.5.3...2.5.4


## [2.5.3] ##
### Modified AddOns ###
  * Aurora 11.2.0.1
  * oUF
  * RealUI_Skins
  * nibRealUI
  * RealUI_Bugs
  * RealUI_Dev

### Changed ###
  * chg: BugGrabber - version: v11.1.5
  * tmp: RealUI_Inventory workarounds
  * add: reminder about LibWindow-1.1
  * Removed commented code
  * chg: Minimap use GetQuestsOnMapCached
  * cleanup: C_Container unused code
  * chg: re-enabled   RealUI_Inventory
  * chg: ClearAllPoints changed in 11.2.0 - breaks moving certain windows
  * chg: Minor RealUI_Inventory changes
  * fix: RealUI_Inventory bugging out with EquipmentSets
  * chg: RealUI.C_Container removed and replaced with _G.C_Container
  * chg: Masque - api version update
  * chg: make RealUI_Inventory load, bags ok - banks disabled
  * fix: LFGFrame hook.
  * chg: skin for AddonCompartmentFrame
  * add: Adding skeleton for account wide money in infobar
  * chg: toc update for 11.2.0
  * fix: CommunitiesFrame is moveable again
  * chg: BNet_GetValidatedCharacterName -> FriendsFrame_GetFormattedCharacterName
  * chg: replace BNet_GetValidatedCharacterName with FriendsFrame_GetFormattedCharacterName - 11.2
  * chg: addons enabled is now boolean
  * chg: SendChatMessage -> C_ChatInfo.SendChatMessage
  * chg: naming chg from self following blizzard standards
  * chg: add debug info for blizzbugs
  * chg: GameFontNormalCenter replaced by GameFontNormal
  * chg: IsAzeriteItemLocationBankBag ->  IsAzeriteItemLocationBankTab
  * chg: other changes related to C_SpecializationInfo implementation.
  * chg: GetSpecialization ->  C_SpecializationInfo.GetSpecialization
  * chg: Blizzard_VoidStorageUI removed in retail.

## Detailed Changes ##
[2.5.2]: https://github.com/RealUI/RealUI/compare/2.5.2...2.5.3


## [2.5.2] ##
### Modified AddOns ###
  * Aurora 11.1.5.0
  * RealUI_Skins
  * nibRealUI
  * RealUI_Tooltips

### Changed ###
  * fix: HelpPlate_GetButton was remove from the API
  * revert: RealUI_Inventory error that sneaked in on mouse over npcs


## Detailed Changes ##
[2.5.1]: https://github.com/RealUI/RealUI/compare/2.5.1...2.5.2


## [2.5.0] ##
### Modified AddOns ###
  * Aurora 11.1.0.1
  * RealUI_Skins
  * nibRealUI
  * nibRealUI_Dev

### Information ###
  * This is the first release for The War Within - World of Warcraft 11.1.0
  * Certain features have been disabled or removed due to changes in the Blizzard API
  * This version is stable enoough for general use, but there are still some issues to be resolved

### Changed ###
  * chg: make addonprofiler off on RealUI releases and configurable with RealUI_Dev
  * fix: UpdateUIScale add some sanity checks and round only to 2 decimals
  * fix: SetSpecialization to C_SpecializationInfo.SetSpecialization (tnx Squishses)
  * chg: Some debug code

## Detailed Changes ##
[2.4.2]: https://github.com/RealUI/RealUI/compare/2.4.2...2.5.0

## [2.4.2] ##
### Modified AddOns ###
  * Aurora 11.0.5.3

### Changed ###
  * fix: Aurora chg of UIDropDownMenuTemplate replaced with DropdownButton

## Detailed Changes ##
[2.4.1]: https://github.com/RealUI/RealUI/compare/2.4.2...2.4.1


## [2.4.1] ##
### Modified AddOns ###
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips
  * nibRealUI
  * nibRealUI_Config

### Information ###
  * This is the second release for The War Within - World of Warcraft 11.0.5
  * This release is a major update to the Blizzard UI - with many changes to the core and modules
  * Certain features have been disabled or removed due to changes in the Blizzard API
  * This version is stable enoough for general use, but there are still some issues to be resolved

### Added ###
  * add: Show Tracking in Farm Mode (configurable)

### Changed ###
  * chg: dragemall changes to stop blocking communties frame
  * chg: removed RealUI.C_Container
  * chg: removed unused xml
  * chg: updated masque skin for 11.0.0 and new api
  * chg: AddonCompartmentFrame now anchored to coords
  * chg: removed compability realui.enum.bankindex replaced with _G.Enum.BagIndex..
  * chg: SpellActivationOverlay_ShowAllOverlays and SpellActivationOverlay_HideOverlays replaced.
  * chg: removed debug threat spam :)
  * chg: GetNumGuildMembers no longer gives back onlineandmobile users - replacing block entry
  * chg: CreateObjectPool is now securepools - replace with CreateUnsecuredObjectPool
  * chg: removed RealUI.Enum,BagIndex

### Fixed ###
a497c0ff fix: GetContainerItemInfo changed .
  * fix: spec button on block were broken due to changed api
  * fix: look up bankInteractionType with variable..
  * fix: POIButton:add was removed - add coordinates directly
  * fix: missing _G in Inventory
  * fix: MinimapAdv - GarrisonEnums, ObjectiveTrackerPOI, and cleanups.
  * fix: CompartmentFramePosition on minimap to follow anchorto

### Disabled ###

## Detailed Changes ##
[2.4.1]: https://github.com/RealUI/RealUI/compare/2.4.0...2.4.1


## [2.4.0] ##
### Modified AddOns ###
  * RealUI_Bugs
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips
  * nibRealUI
  * nibRealUI_Config
  * nibRealUI_Dev


### Information ###
  * This is the first release for The War Within - World of Warcraft 11.0.2
  * This release is a major update to the Blizzard UI - with many changes to the core and modules
  * Certain features have been disabled or removed due to changes in the Blizzard API
  * This version is stable enoough for general use, but there are still some issues to be resolved

### Added ###
  * add: talents to blocks micro menu
  * objectivetracker dvelve support
  * updatespec fire on additional events
  * add: extra command rc for readycheck
  * add: add debug code for missing blockInfo
  * add: RealUI.Enum.BagIndex now includes Warband bank flags

### Changed ###
  * EnumerateInactive no longer exists
  * support for new objectivetracker hide/collapse - added blocks
  * chg: realui minimap module updated for 11.0.2
  * chg: C_Reputation updates
  * chg: C_Bank api updates
  * chg: apis that moved to C_Spell
  * chg: IterateModules - name field deprecated
  * chg: upgraded BugGrabber
  * chg: discord link updated

### Fixed ###
  * AddonCompartmentFrame is not a happy camper.. placing it in the map for now
  * added GuildBanker and AccountBanker
  * registercommands for readycheck and reload are now functions
  * fix for updated api on ObjectiveTrackerFrame
  * fix: class resource bar throwing error on certain classes
  * fix: RealUI_Inventory numActiveObjects error on looting in combat
  * fix: RealUI_Inventory - added more events, freeslots fix
  * fix minimap tracking, removal of compartmentframe
  * TOGGLETALENTS and ToggleProfessionsBook on block bar mini menu
  * fix rl command
  * fix: mssing fields from GetWatchedFactionData and change of ToggleTalentFrame to PlayerSpellsUtil.TogglePlayerSpellsFrame
  * fix: TaintLess [24-02-20] to TaintLess [24-07-27]
  * fix: bags using Enum.BagIndex, fix a possible nil
  * fix: CVar countdownForCooldowns is reversed.
  * fix: RealUI_Inventory - fix of filters broken by 11.0
  * fix: changes to C_Reputation.GetWatchedFactionData
  * fix: typo and removed unused code
  * fix: CollectionWardrobeUtil replaced by C_TransmogCollection

### Disabled ###
  * AddonListAdv:OnEnable change in api
  * ZAFFrame.SpellButtonContainer.contentFramePool


## Detailed Changes ##
[2.4.0]: https://github.com/RealUI/RealUI/compare/2.3.16...2.4.0
