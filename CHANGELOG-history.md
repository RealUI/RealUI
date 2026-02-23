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


## [2.3.16] ##
### Modified AddOns ###
  * nibRealUI (Aurora 10.2.7.1)

### Changed ###
  * Pushed related to Aurora


## [2.3.15] ##
### Modified AddOns ###
  * nibRealUI
  * !RealUI_Preloads
  * RealUI_Bugs
  * RealUI_Skins
  * Other files

### Changed ###
  * chore: interface update for preloads/loadwiths
  * update: TaintLess - updated from 23-09-09 to 24-02-20
  * fix: missing C_Item for GetDetailedItemLevelInfo
  * chore: fix for discontinued functions
  * chore: FrameXML is discontinued - moved to Addons\Blizzard_SharedXML
  * chore: toc bump
  * chg: updated FUNDING yaml file


## [2.3.14] ##
### Modified AddOns ###

  * nibRealUI (Aurora 10.2.6.1)

### Changed ###
  * Pushed related to Aurora


## [2.3.13] ##
### Modified AddOns ###

  * nibRealUI
  * !RealUI_Preloads
  * RealUI_Bugs
  * RealUI_Skins

### Changed ###
  * Upgrade to BugGrabber v10.2.3
  * Added RealUI_Preloads

### Fixed ###
  * Fixed so make RealUI_Preloads LoadWith Blizzard_CompactRaidFrames to make sure Blizzard_deprecated is loaded before RealUI
  * Fixed Blizzard_Deprecated and friends since Blizzard changed the layout of Blizzard_Deprecated
  * Fixed the error from threat colors on targeting units.
  * Fixed threatcolor towards upstream in oUF
  * Fixed some lint errors for ENUM, missing _G and unused variables.
  * Fixed error caused by changes to GetItemIcon - replaced with C_Item.GetItemIconByID


## [2.3.12] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Changed ###

### Fixed ###
  * Changes needed for 10.2.6 API changes - C_Item, C_PVP TrackingFrame
  * Fixes for deprecated functions


## [2.3.11] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs
  * RealUI_Chat
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Tooltips

### Changed ###
 * BugGrabber to v10.2.2
 * Infobar - Hide StatusBars at maxlevel
 * Minimap - allow larger range on minimap size
 * Combattext events - interupt extraSpellSchool displayed
 * Taintless from 23-05-18 to 23-09-09
 * License info updated

### Fixed ###
  * Changes needed for 10.2.5 API differences
  * Fixes for deprecated functions
  * Using Enums for LFG Roles
  * ToolTips location are controlled via Edit and not RealUI location
  * Fixes to address nil situations


## [2.3.10] ##
### Modified AddOns ###
  * nibRealUI

### Changed ###
  * update: duplicate code removed from nibRealUI

### Fixed ###
  * update: change url of LibItemUpgradeInfo
  * fix: this version should be able to be packaged with the curseforge packager


## [2.3.9] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Changed ###
  * add: set questTextContrast to darkmode
  * fix: Addon management functions moved to the C_AddOns namespace.
  * fix: Stop AddonCompartmentFrame from popping back up uninvited...
  * update: rename output of GetAddOnInfo to match API
  * update: events for stolen, dispel and interupt updated
  * update: BugGrabber r294 to r290
  * update: UpdateBagMatchesSearch event on PLAYER_ENTERING_WORLD

### Fixed ###
  * Various fixes for 10.2.0


## [2.3.8] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_Skins
  * RealUI_Tooltips

### Changed ###
  *  fix: updated fix for duplicate mirrorbar (breath/fatigue/etc) [Squishses]
  *  update: upgrade BugGrabber from v10.1.1 to v10.1.6
  *  add: QueueStatusButton to minimap
  *  fix: ExpansionLandingPageMinimapButton - resized and updated
  *  fix: updated fix for minimap buttons [Squishses]
  *  Add: notify player if Limited Game mode is active.
  *  fix: MiniMap selection buttons on top fix [Squishses]
  *  fix: minimap fixes for instance difficulty, mailminimap and few others [Squishses]
  *  fix: Removed some if GameLimitedMode IsActive.
  *  fix: QUEST_TAG_TCOORDS error. [Squishses]
  *  removed: useCompactPartyFrames deprecated
  *  fix: updated paths for Aurora xml's after Gethe/Aurora@f5ac886d5640118704df9aacae4056506dc029e9
  *  update: LibRangeCheck 2.0 to 3.0

### Fixed ###

  * Various fixes for 10.1.7


## [2.3.7] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_Bugs
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Changed ###

  * First party RealUI addons now have a neat icon in the addons list

### Fixed ###

  * Various fixes for 10.1.0 and 10.1.5


## [2.3.6] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Changed ###

  * Re-enabled objective progress on tooltips
  * Bags will now auto hide when leaving a merchant
  * Clicking the Progress block when tracking a renown faction will now open the renown UI


### Fixed ###

  * Error when Extra Action Button is disabled in Bartender
  * Error when changing minimap tracking
  * Error when viewing the Friends block
  * Renown factions always showed max rep in the infobar
  * Tooltips would not show on some minimap blips
  * Equip sets would be lumped into the regular Equipment filter bag
  * Missing combat events



## [2.3.5] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * Support for new Empowered spell events in CombatText

### Changed ###

  * Transmog tips are now a bit more granular
  * The in-game addon list entries for nibRealUI and nibRealUI_Config have been
      changed to RealUI and RealUI Config for better searchablility and
      conformance. The folder names in the AddOns folder are unchanged at this
      time.

### Fixed ###

  * The notification banner would scale very large when shown
  * Some of the smaller minimap frames were still shown
  * Taint issues when trying to use an item from Inventory
  * Error when using the barber shop
  * Auto-sell junk would error
  * The default bank from would also show when opening the bank
  * Map coords were out of place
  * The start menu talent button opened the old talent frame
  * ClassResource would disappear from options if disabled
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.3.4] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_CombatText
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * Updated for Dragonflight



## [2.3.3] ##
### Modified AddOns ###

  * RealUI_Skins
  * RealUI_Tooltips

### Fixed ###

  * Error when opening WeakAuras options
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.3.2] ##
### Fixed ###

  * Possible error when opening the friends frame
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.3.1] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Fixed ###

  * Errors due to changes in 9.1.5
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.3.0] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * RealUI_CombatText is now officially included

### Changed ###

  * Druid mana is now also shown in bear and cat forms

### Fixed ###

  * Hover tooltips did not show for looted currency
  * Errors due to changes in 9.1
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.9] ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_Inventory

### Fixed ###

  * Error when attempting to use a filter bag that no longer exists
  * Some bank items would show the wrong tooltip
  * Error when splitting stacks in the bank



## [2.2.8] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Fixed ###

  * Conflict with Addon Control Panel
  * Error due to a change in Grid2
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.7] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Inventory

### Added ###

  * Built-in filter bags can now be disabled
  * New filter bag for Anima items
  * New "Restack Items" button
  * Bag button tooltips now show remaining free slots

### Changed ###

  * The "Trade Goods: Other" filter is now a catch all trade goods filter
  * The bank and reagent bank have been combined

### Fixed ###

  * Taint errors when using item slots created in combat
  * Bags would overlap in some situations
  * Bank was not technically closed when closing the UI



## [2.2.6] ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * Support for the Kyrian ability for Rogues

### Changed ###

  * RealUI addons will now show their individual version in error messages
  * There is no longer an in-combat alert when opening moved frames
  * Tweaked xp bar colors when rested
  * The "New Items" filter bag will now retain items until it's explicitly reset or a UI reload
  * The default positions of the zone ability and extra action have been updated

### Fixed ###

  * Minimap in Torghast was black
  * Error when opening config bar
  * Barber Shop options were out of place for some
  * Partial Soul Shards were not shown for Destro Locks
  * Error when mousing over characters with low level artifact weapons
  * The UI scale button was in the wrong place
  * Bags would not always close when hitting the Escape key
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.5] - 2020-11-16 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins
  * RealUI_Inventory

### Changed ###

  * The spec infobar block is now hidden for characters that have not chosen a spec
  * RealUI cooldown counts should now only show on action buttons

### Fixed ###

  * Addon control was not always updated
  * Error when creating a new filter bag
  * Error when tracking a Shadowlands campaign quest
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.4] - 2020-10-29 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins
  * RealUI_Tooltips
  * RealUI_Inventory

### Changed ###

  * The spec infobar block is now hidden for characters that have not chosen a spec

### Fixed ###

  * The rested XP bar would still be shown after rested XP is gone
  * Newly created characters wouldn't have profiles set correctly
  * Error when logging into a new character
  * Changing skin colors wouldn't update the preview frames
  * Item levels weren't shown on items in the Equipment Set bag
  * Error when getting the ilvl of a player with a Legion artifact
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.3] - 2020-10-14 ##
### Modified AddOns ###

  * RealUI_Skins
  * RealUI_Tooltips
  * RealUI_Inventory

### Fixed ###

  * Barber shop was cut off
  * The tooltip was placed at the cursor by default
  * Error when viewing the bank
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.2] - 2020-10-12 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins
  * RealUI_Tooltips
  * RealUI_Inventory

### Added ###

  * Support for 9.0 Shadowlands
  * Option to show tooltips at the mouse cursor

### Changed ###

  * You can now assign a partial stack to the junk bag, and it will only auto sell the assigned amount

### Fixed ###

  * Auto-sell junk didn't work
  * Bags may not update if they were already open
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.1] - 2020-07-27 ##
### Modified AddOns ###

  * nibRealUI
  * RealUI_Skins
  * RealUI_Inventory

### Fixed ###

  * Error with bindings reminder
  * Assigning an item to another bag didn't work
  * Potential error with Objectives Adv. when opening config
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)



## [2.2.0] - 2020-06-23 ##
### Modified AddOns ###

  * cargBags_Nivaya has been replaced with RealUI_Inventory
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Changed ###

  * Options frame is now more fault tolerant
  * Minor tweaks to the bindings reminder

### Fixed ###

  * Error when opening the options frame
  * Color picker was not usable



## [2.1.10] - 2020-06-01 ##
### Modified AddOns ###

  * nibRealUI

### Added ###

  * The keybinding frame has a new visual reminder of the actions that keyboard keys are bound to

### Changed ###

  * Start menu items now have keybind hints

### Fixed ###

  * Error when clicking a button on the start menu
  * Broken DBM options skin from recent update



## [2.1.9] - 2020-05-25 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Changed ###

  * Improve RealUI generated dropdown menus

### Fixed ###

  * Error if the mouse trail tweak is disabled
  * Error preventing the arena prep frames from showing
  * Objective tracker visibility option did not recognize scenarios
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




## [2.1.8] - 2020-03-26 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Added ###

  * New option in UI Tweaks to disable dragging UI frames

### Changed ###

  * Most unit frame texts now have an outline
  * The friends list now shows character names in class colors

### Fixed ###

  * Minimap error when POIs are disabled
  * Worldmarker error when the Blizz raid frames are disabled
  * AFK timer would not show sometimes
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




## [2.1.7] - 2020-03-11 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Changed ###

  * Auction House can now be moved

### Fixed ###

  * File load error
  * Various errors while in raid
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




## [2.1.6] - 2020-02-17 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins

### Changed ###

  * Improved minimap world markers
  * Minor tweaks to the color picker

### Fixed ###

  * Font path error




## [2.1.5] - 2020-02-16 ##
### Modified AddOns ###

  * nibRealUI
  * nibRealUI_Config
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * A simple cursor trail can be enabled in `/realadv` -> UI Tweaks.

### Fixed ###

  * Tooltip error when in certain locations.
  * Error when switching specs.
  * Error when targeting certain mobs
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




## [2.1.4] - 2020-01-18 ##
### Modified AddOns ###

  * nibRealUI

### Added ###

  * New notification when RealUI tries to update certain things while in combat.
  * A new chat command, `/resetFrames`, that will reset the position of standard Blizzard frames that are outside the visible UI.

### Fixed ###

  * Error when logging into a new character or transfered character.




## [2.1.3] - 2020-01-14 ##
### Modified AddOns ###

  * cargBags_Nivaya
  * nibRealUI
  * nibRealUI_Config
  * RealUI_Bugs
  * RealUI_Skins
  * RealUI_Tooltips

### Added ###

  * Skin for the Clique settings.

### Changed ###

  * Objective progress in tooltips should now be more reliable.

### Fixed ###

  * Error when opening the bank if the reagent bank isn't purchased.
  * Conflict between Tooltips and Overachiever.
  * Draggable UI frames will now properly re-open in the position they were last in.
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




## [2.1.2] - 2019-10-04 ##
### Modified AddOns ###

  * nibRealUI

### Fixed ###

  * Addon profiles would not apply if an addon is missing.




## [2.1.1] - 2019-10-03 ##
### Modified AddOns ###

  * nibRealUI

### Changed ###

  * The "Reverse Bar Direction" unit frames option has been relabeled "Colored when full" to better convey its function.

### Fixed ###

  * The "Colored when full" option is now properly disabled by default.
  * Fixed an error when interacting with the infobar friends list.
  * The guild infobar block would sometimes show 0 people online when first logging in.




## [2.1.0] - 2019-09-24 ##
### Modified AddOns ###

  * FreebTip has been replaced with RealUI_Tooltips.
  * cargBags_Nivaya
  * nibRealUI

### Changed ###

  * There is a new insertion indicator while moving infobar blocks.

### Added ###

  * New "Tooltips" section in the Advanced options.
  * New option to show object IDs in tooltips.
  * New option to show if you've collected an item's appearance.
  * When doing world quests or bonus objectives, the progress contribution of an object is now shown on the tooltip.
  * There are new default bag categories for Travel, Archaeology, Tabards, and Mechagon items. Thanks to ItsMattTrevino on Github for this feature.
  * Use `/cbniv addtrade` to add bags for Trade Good sub categories like Cloth and Herbs. Thanks to ItsMattTrevino on Github for this feature.

### Fixed ###

  * Error when on an Island Expedition.
  * Reverse health bars would not set correctly on login.
  * The minimap button collection should now be more reliable
  * [Various bugs and errors with the UI skin.](https://www.wowinterface.com/downloads/info18589-Aurora.html#changelog)




[Unreleased]: https://github.com/RealUI/RealUI/compare/main...develop
[2.3.7]: https://github.com/RealUI/RealUI/compare/2.3.6...2.3.7
[2.3.6]: https://github.com/RealUI/RealUI/compare/2.3.5...2.3.6
[2.3.5]: https://github.com/RealUI/RealUI/compare/2.3.4...2.3.5
[2.3.4]: https://github.com/RealUI/RealUI/compare/2.3.3...2.3.4
[2.3.3]: https://github.com/RealUI/RealUI/compare/2.3.2...2.3.3
[2.3.2]: https://github.com/RealUI/RealUI/compare/2.3.1...2.3.2
[2.3.1]: https://github.com/RealUI/RealUI/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/RealUI/RealUI/compare/2.2.9...2.3.0
[2.2.9]: https://github.com/RealUI/RealUI/compare/2.2.8...2.2.9
[2.2.8]: https://github.com/RealUI/RealUI/compare/2.2.7...2.2.8
[2.2.7]: https://github.com/RealUI/RealUI/compare/2.2.6...2.2.7
[2.2.6]: https://github.com/RealUI/RealUI/compare/2.2.5...2.2.6
[2.2.5]: https://github.com/RealUI/RealUI/compare/2.2.4...2.2.5
[2.2.4]: https://github.com/RealUI/RealUI/compare/2.2.3...2.2.4
[2.2.3]: https://github.com/RealUI/RealUI/compare/2.2.2...2.2.3
[2.2.2]: https://github.com/RealUI/RealUI/compare/2.2.1...2.2.2
[2.2.1]: https://github.com/RealUI/RealUI/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/RealUI/RealUI/compare/2.1.10...2.2.0
[2.1.10]: https://github.com/RealUI/RealUI/compare/2.1.9...2.1.10
[2.1.9]: https://github.com/RealUI/RealUI/compare/2.1.8...2.1.9
[2.1.8]: https://github.com/RealUI/RealUI/compare/2.1.7...2.1.8
[2.1.7]: https://github.com/RealUI/RealUI/compare/2.1.6...2.1.7
[2.1.6]: https://github.com/RealUI/RealUI/compare/2.1.5...2.1.6
[2.1.5]: https://github.com/RealUI/RealUI/compare/2.1.4...2.1.5
[2.1.4]: https://github.com/RealUI/RealUI/compare/2.1.3...2.1.4
[2.1.3]: https://github.com/RealUI/RealUI/compare/2.1.2...2.1.3
[2.1.2]: https://github.com/RealUI/RealUI/compare/2.1.1...2.1.2
[2.1.1]: https://github.com/RealUI/RealUI/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/RealUI/RealUI/compare/2.0.14...2.1.0
