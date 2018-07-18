local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = {}

RealUI.locale = _G.GAME_LOCALE or _G.GetLocale()

L["ActionBars_ActionBarsDesc"] = "Modify the position and size of the Action Bars."
L["ActionBars_Center"] = "Center"
L["ActionBars_CenterDesc"] = "Adjust the location of the three center action bars."
L["ActionBars_CenterOption"] = "%d Center - %d Bottom"
L["ActionBars_EAB"] = "Extra Action Button"
L["ActionBars_Move"] = "Move %s"
L["ActionBars_MoveDesc"] = "Check to allow RealUI to control the position of the %s."
L["ActionBars_Pet"] = "Pet Bar"
L["ActionBars_ShowDoodads"] = "Show Doodads"
L["ActionBars_ShowDoodadsDesc"] = "Display doodads to indicate the position of the pet and stance bars."
L["ActionBars_Sides"] = "Sides"
L["ActionBars_SidesDesc"] = "Adjust the location of the two side action bars."
L["ActionBars_SidesOption"] = "%d Left - %d Right"
L["ActionBars_Stance"] = "Stance Bar"
L["Alert_CantOpenInCombat"] = "Cannot open RealUI Configuration while in combat."
L["Alert_CombatLockdown"] = "Combat Lockdown"
L["Appearance_ButtonColor"] = "Button Color"
L["Appearance_ClassColorHealth"] = "Class Colored Health"
L["Appearance_ClassColorNames"] = "Class Colored Names"
L["Appearance_FrameColor"] = "Frame Color"
L["Appearance_HighRes"] = "High Resolution"
L["Appearance_HighResDesc"] = "This will double the current UI Scale to make interface elements easier to see.\n\nNote: This is only recommended when using a display with a vertical resolution of 1440 px or larger."
L["Appearance_ModScale"] = "UI Mod Scale"
L["Appearance_ModScaleDesc"] = "This only affects certain frames at the moment, but will eventually be used for the entire UI.\n\n%s"
L["Appearance_Skins"] = "Skins"
L["Appearance_Pixel"] = "Pixel Perfect"
L["Appearance_PixelDesc"] = "Sets the scale of the UI so that an in-game pixel matches your physical screen's pixels."
L["Appearance_StripeOpacity"] = "Stripe Opacity"
L["Appearance_UIScale"] = "Custom UI Scale"
L["Appearance_UIScaleDesc"] = "Set a custom UI scale (%.2f - %.2f). Note: UI elements may lose their sharp appearance."
L["CastBars"] = "Cast Bars"
L["CastBars_Bottom"] = "Bottom"
L["CastBars_BottomDesc"] = "Name and duration are displayed below the cast bars."
L["CastBars_Inside"] = "Inside"
L["CastBars_InsideDesc"] = "Name and duration are displayed on the left for the player and on the right for the target."
L["Clock_CalenderInvites"] = "Pending Invites:"
L["Clock_Date"] = "Date"
L["Clock_ShowCalendar"] = "<Click> Open calendar"
L["Clock_ShowTimer"] = "<Alt+Click> Open clock settings"
L["CombatFade"] = "Combat Fade"
L["CombatFade_HarmTarget"] = "Attackable Target"
L["CombatFade_Hurt"] = "Hurt"
L["CombatFade_InCombat"] = "In Combat"
L["CombatFade_NoCombat"] = "Out of Combat"
L["CombatFade_Target"] = "Target Selected"
L["Control_AddonControl"] = "AddOn Control"
L["Control_Layout"] = "Control Layout"
L["Control_LayoutDesc"] = "Allow RealUI to control %s's layout settings."
L["Control_Position"] = "Control Position"
L["Control_PositionDesc"] = "Allow RealUI to control %s's position."
L["Currency_Cycle"] = "<Click> Open currency list, <Alt+Click> Cycle displayed currency"
L["Currency_EraseData"] = "<Alt+Click> Erase highlighted character data"
L["Currency_TotalMoney"] = "Total money on realm: "
L["Currency_UpdatedAbbr"] = "Upd."
L["DoReloadUI"] = "You need to Reload the UI for changes to take effect. Reload Now?"
L["Fonts"] = "Fonts"
L["Fonts_Chat"] = "Chat Font"
L["Fonts_ChatDesc"] = "This font is used for the chat box and occasionally numbers."
L["Fonts_Header"] = "Header Font"
L["Fonts_HeaderDesc"] = "This font is used primarily for titles and headers."
L["Fonts_Normal"] = "Normal Font"
L["Fonts_NormalDesc"] = "This font is used for most of the UI such as tooltips, quests, and objectives."
L["General_Debug"] = "Debug"
L["General_DebugDesc"] = "Provides extra debugging information"
L["General_Enabled"] = "Enabled"
L["General_EnabledDesc"] = "Enable/Disable %s"
L["General_InvalidParent"] = "The parent frame set for %s does not exist. Type /realadv and go to %s -> %s to set a new parent."
L["General_Lock"] = "Locked"
L["General_LockDesc"] = "Toggle to move or lock frame position."
L["General_NoteParent"] = "To find the name of a frame, type /fstack and hover over the frame you want to attach to. Use ALT to cycle the green highlight area"
L["General_NoteReload"] = "Note: You will need to reload the UI (/rl) for changes to take effect."
L["General_Position"] = "Position"
L["General_Positions"] = "Positions"
L["General_Tristatefalse"] = "|cffff0000Ignored|r - Single - Multiple"
L["General_Tristatenil"] = "Ignored - Single - |cff00ff00Multiple|r"
L["General_Tristatetrue"] = "Ignored - |cff00ff00Single|r - Multiple"
L["General_XOffset"] = "X Offset"
L["General_XOffsetDesc"] = "Offset in X direction (horizontal) from the given anchor point."
L["General_YOffset"] = "Y Offset"
L["General_YOffsetDesc"] = "Offset in Y direction (vertical) from the given anchor point."
L["GuildFriend_WhisperInvite"] = "<Click> Send whisper, <Alt+Click> %s"
L["HuD_AlertHuDChangeSize"] = "Changing the HuD size may alter the positions of some elements, therefore it is recommended to check UI Element positions once the changes have taken effect."
L["HuD_Height"] = "Height"
L["HuD_Horizontal"] = "Horizontal"
L["HuD_ReverseBars"] = "Reverse Bar Direction"
L["HuD_ShowElements"] = "Show UI Elements"
L["HuD_Uninterruptible"] = "Uninterruptible"
L["HuD_UseLarge"] = "Use Large HuD"
L["HuD_UseLargeDesc"] = "Increases size of key HuD elements (Unit Frames, etc)."
L["HuD_Vertical"] = "Vertical"
L["HuD_VerticalDesc"] = "Adjust the vertical position of the entire HuD."
L["HuD_Width"] = "Width"
L["Infobar"] = "Infobar"
L["Infobar_AllBlocks"] = "All Blocks"
L["Infobar_BlockGap"] = "Block Gap"
L["Infobar_BlockGapDesc"] = "The amount of space between each block."
L["Infobar_CombatTooltips"] = "In Combat Tooltips"
L["Infobar_CombatTooltipsDesc"] = "Show tooltips while in combat."
L["Infobar_Desc"] = "LDB supported data display"
L["Infobar_ShowIcon"] = "Show icon"
L["Infobar_ShowLabel"] = "Show label"
L["Infobar_ShowStatusBar"] = "Show status bars"
L["Infobar_ShowStatusBarDesc"] = "Show the progress watch status bars."
L["Install"] = "CLICK TO INSTALL"
L["Install_UseHighRes"] = "Enable high resolution scaling"
L["Install_UseHighResDec"] = "Set up RealUI using 2x UI Scaling so that UI elements are easier to see on a high hesolution display."
L["Layout_ApplyOOC"] = "Layout will change after you leave combat."
L["Layout_DPSTank"] = "DPS/Tank"
L["Layout_Healing"] = "Healing"
L["Layout_Layout"] = "Layout"
L["Layout_Link"] = "Link Layouts"
L["Layout_LinkDesc"] = "Use same settings between DPS/Tank and Healing layouts."
L["Misc_SpellAlertsDesc"] = "Modify the position and size of the Spell Alerts."
L["Misc_SpellAlertsWidthDesc"] = "Adjust the distance between the left and right Spell Alert Overlays."
L["Patch_DoApply"] = "A patch has been applied, the UI must be reloaded for the changes to take affect."
L["Patch_MiniPatch"] = "RealUI Mini Patch"
L["Progress"] = "Progress Watch"
L["Progress_Cycle"] = "<Alt+Click> Cycle display"
L["Progress_OpenArt"] = "<Click> Open equipped artifact"
L["Progress_OpenHonor"] = "<Click> Open honor talents"
L["Progress_OpenRep"] = "<Click> Open faction list"
L["Raid_30Width"] = "30 Player Width"
L["Raid_40Width"] = "40 Player Width"
L["Raid_HideRaidFilter"] = "Hide raid filters"
L["Raid_HideRaidFilterDesc"] = "Hide the group filters for Blizzard's Raid Frame Manager"
L["Raid_LargeGroup"] = "Large groups"
L["Raid_LargeGroupDesc"] = "Use horizontal groups while in large groups like raids or battlegrounds"
L["Raid_ShowSolo"] = "Show While Solo"
L["Raid_SmallGroup"] = "Small groups"
L["Raid_SmallGroupDesc"] = "Use horizontal groups while in small groups like dungeons or arenas"
L["Reset_Confirm"] = "Are you sure you wish to reset RealUI?"
L["Reset_SettingsLost"] = "All user settings will be lost."
L["Resource"] = "Class Resource"
L["Resource_Gap"] = "Gap"
L["Resource_GapDesc"] = "The distance between each %s."
L["Resource_HeightDesc"] = "Adjust the height of the resource anchor."
L["Resource_HideUnused"] = "Hide unused %s"
L["Resource_HideUnusedDesc"] = "Only show the %s you have."
L["Resource_Reverse"] = "Reverse orientation"
L["Resource_ReverseDesc"] = "Reverse the orientation of the %s display."
L["Resource_WidthDesc"] = "Adjust the width of the resource anchor."
L["Slash_Profile"] = "|cFFBB0000CPU Profiling is enabled!|r To disable, type: |cFF8080FF/cpuProfiling|r"
L["Slash_RealUI"] = "Type %s to configure UI style, positions and settings."
L["Slash_Taint"] = "|cFFBB0000Taint Logging is enabled!|r To disable, type: |cFF8080FF/taintLogging|r"
L["Spec_Open"] = "<Click> Open talent frame"
L["Spec_ChangeSpec"] = "<Click> Change spec, <Alt+Click> Change loot spec\n<Right+Click> Cycle equip sets, <Alt+Right+Click> Unassign equip set"
L["Spec_SpecChanger"] = "Spec Changer"
L["Start"] = "Start"
L["Start_Config"] = "RealUI Config"
L["Sys_AverageAbbr"] = "Avg"
L["Sys_CurrentAbbr"] = "Cur"
L["Sys_Stat"] = "Stat"
L["Sys_SysInfo"] = "System Info"
L["Tweaks_CooldownCount"] = "Cooldown Count"
L["Tweaks_CooldownCountDesc"] = "Modifies the countdown text on cooldown swipes"
L["Tweaks_UITweaks"] = "UI Tweaks"
L["Tweaks_UITweaksDesc"] = "Minor functional tweaks for the default UI"
L["UnitFrames_AnchorWidth"] = "Anchor Width"
L["UnitFrames_AnchorWidthDesc"] = "The amount of space between the Player frame and the Target frame."
L["UnitFrames_AnnounceChatDesc"] = "Chat channel used for trinket announcement."
L["UnitFrames_AnnounceTrink"] = "Announce trinkets"
L["UnitFrames_AnnounceTrinkDesc"] = "Announce opponent trinket use to chat."
L["UnitFrames_BuffCount"] = "Buff Count"
L["UnitFrames_DebuffCount"] = "Debuff Count"
L["UnitFrames_Gap"] = "Gap"
L["UnitFrames_GapDesc"] = "Vertical distance between each unit."
L["UnitFrames_ModifierKey"] = "Modifier Key"
L["UnitFrames_NPCAuras"] = "Show NPC Auras"
L["UnitFrames_NPCAurasDesc"] = "Show Buffs/Debuffs cast by NPCs."
L["UnitFrames_PlayerAuras"] = "Show Player Auras"
L["UnitFrames_PlayerAurasDesc"] = "Show Buffs/Debuffs cast by you."
L["UnitFrames_SetFocus"] = "Click to set Focus"
L["UnitFrames_SetFocusDesc"] = "Set focus by click+modifier on a Unit Frame."
L["UnitFrames_Units"] = "Units"
L["Version"] = "Version"

RealUI.L = L
