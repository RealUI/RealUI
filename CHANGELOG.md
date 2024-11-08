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
