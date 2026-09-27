local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

if RealUI.locale == "deDE" then

-- cf-localization: locale="deDE", format="lua_additive_table", handle-unlocalized="comment"
L["ActionBars_ActionBarsDesc"] = "Passe die Position und Größe der Aktionsleisten an."
L["ActionBars_Center"] = "Mittig"
L["ActionBars_CenterDesc"] = "Passe die Position der mittleren drei Aktionsleisten an."
L["ActionBars_CenterOption"] = " %d Mitte - %d Unten"
L["ActionBars_EAB"] = "Zusätzliche Aktionstaste"
L["ActionBars_Move"] = "Bewege %s"
L["ActionBars_MoveDesc"] = " Markieren um RealUI das Ändern der Position von %s zu erlauben."
L["ActionBars_Pet"] = "Begleiterleiste"
L["ActionBars_ShowDoodads"] = " Zeige Doodads"
L["ActionBars_ShowDoodadsDesc"] = " Zeige Doodads um die Position der Tier- und Haltungsleiste anzugeben."
L["ActionBars_Sides"] = " Seiten"
L["ActionBars_SidesDesc"] = "Passe die Position der seitlichen Aktionsleisten an."
L["ActionBars_SidesOption"] = " %d Links - %d Rechts"
L["ActionBars_Stance"] = "Haltungsleiste"
L["Alert_CantOpenInCombat"] = "Die RealUI-Konfiguration kann während des Kampfes nicht geöffnet werden."
L["Alert_CombatLockdown"] = " Kampfsperre"
--[[Translation missing --]]
--[[ L["Alert_WaitCombatLockdown"] = "Combat restrictions are active. The UI will be updated when out of combat."--]] 
L["Appearance_ButtonColor"] = " Tastenfarbe"
L["Appearance_ClassColorHealth"] = "Gesundheit in Klassenfarbe"
L["Appearance_ClassColorNames"] = "Namen in Klassenfarbe"
L["Appearance_FrameColor"] = " Fensterfarbe"
L["Appearance_HighRes"] = " Hohe Auflösung"
L["Appearance_HighResDesc"] = " Dies verdoppelt die aktuelle UI Skalierung, um die Interface Elemente leichter zu erkennen. Es wird empfohlen, dies nur bei einer vertikalen Auflösung von 1440px oder größer zu verwenden."
L["Appearance_ModScale"] = " UI Mod Skalierung"
L["Appearance_ModScaleDesc"] = " Dies beeinflusst aktuell nur bestimmte Frames, wird aber vielleicht für das ganze UI verwendbar sein."
L["Appearance_Pixel"] = "Pixel Perfect"
L["Appearance_PixelDesc"] = " Passt die Pixel des UI´s passend zu den physikalischen Bildschirm-Pixel an. "
L["Appearance_Skins"] = "Aussehen"
L["Appearance_StripeOpacity"] = "Streifen-Transparenz"
L["Appearance_UIScale"] = "Benutzerdefinierte  UI Skalierung"
L["Appearance_UIScaleDesc"] = "Lege eine benutzerdefinierte UI Skalierung fest (%.2f - %.2f). Hinweis: UI Elemente können unscharf dargestellt werden."
--[[Translation missing --]]
--[[ L["BindingsReminder"] = "Bindings Reminder"--]] 
--[[Translation missing --]]
--[[ L["BindingsReminderDesc"] = "Shows a visual reminder of what actions are bound to each key."--]] 
L["CastBars"] = "Zauberleiste"
L["CastBars_Bottom"] = "Unten"
L["CastBars_BottomDesc"] = "Name und Dauer werden unter den Zauberleisten angezeigt"
L["CastBars_Inside"] = "Innen"
L["CastBars_InsideDesc"] = "Name und Dauer werden links für den Spieler und rechts für das Ziel angezeigt."
--[[Translation missing --]]
--[[ L["Chat"] = "Chat"--]] 
--[[Translation missing --]]
--[[ L["Chat_ClassColor"] = "Class colored names"--]] 
L["Chat_ClassColorDesc"] = "Zeige Spielernamen in Klassenfarben an."
L["Clock_CalenderInvites"] = " Ausstehende Einladungen:"
L["Clock_Date"] = " Datum"
L["Clock_ShowCalendar"] = " <Klick> Kalender öffnen"
L["Clock_ShowTimer"] = " <Alt+Klick> Uhreinstellungen öffnen"
L["CombatFade"] = "Kampf Ausblendung"
L["CombatFade_Desc"] = "Ändert die Deckkraft eines Fensters, basierend auf aktuellen Kampfstatus, Leben oder Ziel. "
L["CombatFade_HarmTarget"] = "Angreifbares Ziel"
L["CombatFade_Hurt"] = " Verletzt"
L["CombatFade_InCombat"] = "Im Kampf"
L["CombatFade_NoCombat"] = "Nicht im Kampf"
L["CombatFade_Target"] = "Ausgewähltes Ziel"
--[[Translation missing --]]
--[[ L["CombatText"] = "Combat Text"--]] 
--[[Translation missing --]]
--[[ L["CombatText_MergeHits"] = " [%d Hits]"--]] 
L["Control_AddonControl"] = "AddOn Kontrolle"
L["Control_Layout"] = " Layout kontrollieren"
L["Control_LayoutDesc"] = " Erlaube RealUI die Layouteinstellungen von %s zu kontrollieren."
L["Control_Position"] = " Kontrolliere Position"
L["Control_PositionDesc"] = " Erlaube RealUI die Position von %s zu kontrollieren."
L["Currency_Cycle"] = " <Klick> Öffne Währungsliste, <Alt+Klick> Rotiere durch die angezeigten Währungen"
L["Currency_EraseData"] = " <Alt+Click> Lösche Daten des ausgewählten Charakters"
L["Currency_TotalMoney"] = "Gesamtes Gold auf dem Realm:"
L["Currency_UpdatedAbbr"] = "Upd."
L["DoReloadUI"] = "Du musst das UI neu laden, damit die Änderungen wirksam werden. Jetzt neu laden? "
L["Fonts"] = "Schriftarten"
L["Fonts_Chat"] = " Chat Schriftart"
L["Fonts_ChatDesc"] = "Diese Schriftart wird für den Chat und für manche Zahlen verwendet."
--[[Translation missing --]]
--[[ L["Fonts_Crit"] = "Crit Font"--]] 
L["Fonts_Header"] = "Überschrift Schriftart"
L["Fonts_HeaderDesc"] = " Diese Schriftart wird hauptsächlich für Titel und Überschriften verwendet."
L["Fonts_Normal"] = "Allgemeine Schriftart"
L["Fonts_NormalDesc"] = "Diese Schriftart wird für das Meiste im UI verwendet, wie zum Beispiel für Tooltips, Quests und Ziele."
--[[Translation missing --]]
--[[ L["General_AnchorPoint"] = "Anchor Point"--]] 
L["General_Debug"] = "Debug"
L["General_DebugDesc"] = "Liefert erweiterte Debuginformationen"
L["General_Enabled"] = "Aktiviert"
L["General_EnabledDesc"] = "Aktiviere / Deaktiviere %s"
L["General_InvalidParent"] = "Das Hauptfenster für %s existiert nicht. Gebe /realadv ein und gehe zu %s-> %s um ein neues Hauptfenster festzulegen."
L["General_Lock"] = "Gesperrt"
L["General_LockDesc"] = "Umschalten, um die Fenster Position freizugeben oder zu sperren."
L["General_NoteParent"] = "Um den Namen eines Fensters zu erfahren, tippe /fstack und zeige mit dem Mauszeiger über das gesuchte Fenster. Benutze ALT um durch die grün markierte Flächen umherzuschalten."
L["General_NoteReload"] = "Notiz: Du musst das UI neuladen (/rl), damit die Änderungen übernommen werden."
L["General_Position"] = "Position"
L["General_Positions"] = "Positionen"
L["General_Tristatefalse"] = "| cffff0000Ignoriert | r - Einzeln - Mehrere"
L["General_Tristatenil"] = "Ignoriert - Einzeln - | cff00ff00Mehrere | r"
L["General_Tristatetrue"] = "Ignoriert - | cff00ff00Einzeln | r  - Mehrere"
L["General_XOffset"] = "X Versatz"
L["General_XOffsetDesc"] = "Versatz in Richtung X (horizontal) vom aktuellen Ankerpunkt."
L["General_YOffset"] = "Y Versatz"
L["General_YOffsetDesc"] = "Versatz in Richtung Y (vertikal) vom aktuellen Ankerpunkt."
L["GuildFriend_WhisperInvite"] = "<Klick> sende Flüsternachricht, <Alt+Klick> %s"
L["HuD_AlertHuDChangeSize"] = "Ändern der HUD-Größe kann die Positionen einiger Elemente verändern. Es wird empfohlen, nach bestätigen der Änderungen, die UI-Elemente zu überprüfen."
L["HuD_Height"] = "Höhe"
L["HuD_Horizontal"] = "Horizontal"
L["HuD_ReverseBars"] = " Lebensbalken umkehren"
L["HuD_ShowElements"] = "Zeige UI-Elemente"
L["HuD_Uninterruptible"] = " nicht unterbrechbar"
L["HuD_UseLarge"] = "Verwende großes HuD"
L["HuD_UseLargeDesc"] = "Erhöht die Größe der Hauptelemente des HuD (Einheitenfenster, etc)."
L["HuD_Vertical"] = " Vertikal"
L["HuD_VerticalDesc"] = "Stelle die vertikale Position des gesamten HuD ein."
L["HuD_Width"] = "Breite"
L["Infobar"] = "Informationsbalken"
L["Infobar_AllBlocks"] = "Alle Blöcke"
L["Infobar_BlockGap"] = "Blockabstand"
L["Infobar_BlockGapDesc"] = "Die Menge der Abstände zwischen jedem Block"
L["Infobar_CombatTooltips"] = "Tooltips im Kampf"
L["Infobar_CombatTooltipsDesc"] = " Zeigt Tooltips während des Kampfes an."
L["Infobar_Desc"] = "LDB unterstützte Datenfenster"
L["Infobar_ShowIcon"] = "Zeige Icon"
L["Infobar_ShowLabel"] = "Zeige Label"
L["Infobar_ShowStatusBar"] = "Zeige Statusbalken"
L["Infobar_ShowStatusBarDesc"] = "Zeige den Statusbalken des Fortschritts an"
L["Install"] = "KLICKEN UM DIE INSTALLATION ZU STARTEN"
--[[Translation missing --]]
--[[ L["Install_UseHighRes"] = "Enable high resolution scaling"--]] 
--[[Translation missing --]]
--[[ L["Install_UseHighResDec"] = "Set up RealUI using 2x UI Scaling so that UI elements are easier to see on a high resolution display."--]] 
--[[Translation missing --]]
--[[ L["Inventory"] = "Inventory"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilter"] = "Create a new filter bag"--]] 
--[[Translation missing --]]
--[[ L["Inventory_AddFilterDesc"] = "New filter bags cannot share a name with an existing one. They are not case sensitive."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Duplicate"] = "A filter with this name already exists."--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeight"] = "Max Height"--]] 
--[[Translation missing --]]
--[[ L["Inventory_MaxHeightDesc"] = "The height at which Inventory will create a new column, as a percentage of screen height."--]] 
--[[Translation missing --]]
--[[ L["Inventory_Restack"] = "Re-stack Items"--]] 
--[[Translation missing --]]
--[[ L["Inventory_SellJunk"] = "Auto Sell Junk"--]] 
L["Layout_ApplyOOC"] = "Layout ändert sich sobald du den Kampf verlässt."
L["Layout_DPSTank"] = " Schaden/Schutz"
L["Layout_Healing"] = "Heilung"
L["Layout_Layout"] = "Layout"
L["Layout_Link"] = " Layouts verknüpfen"
L["Layout_LinkDesc"] = "Verwende die gleichen Einstellungen zwischen DPS/Tank- und Heiler-Layout"
L["Misc_SpellAlertsDesc"] = "Modifiziere die Position und Größe von Zauberwarnungen"
L["Misc_SpellAlertsWidthDesc"] = "Passe die Distanz zwischen der linken und rechten Zauberwarnung an"
L["Patch_DoApply"] = "Eine Aktualisierung wurde angewandt. Du musst dein UI neu laden, damit die Änderungen übernommen werden."
L["Patch_MiniPatch"] = " RealUI Mini Patch"
L["Patch_UpdateAddonSettings"] = "Die Standardeinstellung für %s wurden aktualisiert. Willst du diese Änderungen jetzt anwenden?"
L["Progress"] = "Fortschrittsbalken"
L["Progress_Cycle"] = "<Alt+Klick> Fenster wechseln"
L["Progress_OpenArt"] = "<Klick> Öffne ausgerüstete Artefakt"
L["Progress_OpenHonor"] = "<Klick> Öffne Ehrentalentfenster"
L["Progress_OpenRep"] = "<Klick> Öffne Fraktionsfenster"
L["Raid_30Width"] = " 30 Spieler Breite"
L["Raid_40Width"] = " 40 Spieler Breite"
L["Raid_HideRaidFilter"] = "Verstecke Schlachtzugsfilter"
L["Raid_HideRaidFilterDesc"] = "Verstecke den Gruppenfilter für Blizzard´s Schlachtzugsfenster"
L["Raid_LargeGroup"] = "Große Gruppen"
L["Raid_LargeGroupDesc"] = "Verwende horizontale Gruppen innerhalb großer Gruppen in Schlachtzügen oder Schlachtfelder"
L["Raid_ShowSolo"] = "Anzeigen wenn in keiner Gruppe"
L["Raid_SmallGroup"] = "kleine Gruppen"
L["Raid_SmallGroupDesc"] = "Verwende horizontale Gruppen innerhalb kleiner Gruppen wie Instanzen oder Arena"
L["Reset_Confirm"] = " Bist du sicher, dass du RealUI zurücksetzen möchtest?"
L["Reset_SettingsLost"] = "Alle Benutzereinstellungen gehen verloren."
L["Resource"] = "Klassen Ressource"
L["Resource_Gap"] = " Abstand"
L["Resource_GapDesc"] = "Die Distanz zwischen jeder %s."
L["Resource_HeightDesc"] = "Passe die Höhe des Ressourcenanker an"
L["Resource_HideUnused"] = "Verstecke unbenutzte %s"
L["Resource_HideUnusedDesc"] = "Zeige nur, wenn du %s hast."
L["Resource_Reverse"] = "Orientierung umkehren"
L["Resource_ReverseDesc"] = "Kehre die Orientierung der %s um."
L["Resource_WidthDesc"] = "Passe die Breite des Ressourcenankers an."
L["Slash_Profile"] = "|cFFBB0000CPU Profiling ist aktiviert!|r Um es zu deaktivieren, tippe: |cFF8080FF/cpuProfiling|r ein."
L["Slash_RealUI"] = " Tippe %s um UI-Style, Positionen und Einstellungen zu konfigurieren"
L["Slash_Taint"] = [=[|cFFBB0000Taint Logging ist aktiviert! |r Zum deaktivieren, tippe: |cFF8080FF/taintLogging|r ein.
]=]
--[[Translation missing --]]
--[[ L["Spec_ChangeGear"] = "<Right+Click> Cycle equip sets, <Alt+Right+Click> Unassign equip set"--]] 
L["Spec_ChangeSpec"] = [=[<Klick> Spezialisierung wechseln, <Alt+Klick> Beutespezialisierung wechseln <Rechtsklick> rotiere durch Rüstungssets, <Alt+Linksklick> Ordne Rüstungsset nicht zu
]=]
L["Spec_Open"] = [=[<Klick> Öffne Talentfenster
]=]
L["Spec_SpecChanger"] = "Spezialisierung wechseln"
L["Start"] = "Start"
L["Start_Config"] = "RealUI Konfiguration"
L["Sys_AverageAbbr"] = "Avg"
L["Sys_CurrentAbbr"] = "Cur"
L["Sys_Stat"] = "Wert"
L["Sys_SysInfo"] = " Systeminformationen"
--[[Translation missing --]]
--[[ L["Tooltips"] = "Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursor"] = "At Cursor"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursorDesc"] = "Position the tooltip at the cursor by default."--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowIDs"] = "Show object IDs"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowRealm"] = "Show realm names"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_ShowTitles"] = "Show player titles"--]] 
L["Tweaks_CooldownCount"] = "Abklingzeiten-Zähler"
L["Tweaks_CooldownCountDesc"] = "Modifiziert den Countdown von Abklingzeiten"
L["Tweaks_UITweaks"] = "UI Tweaks"
L["Tweaks_UITweaksDesc"] = "Kleinere Tweaks für das Standard-UI"
L["UnitFrames_AnchorWidth"] = "Anker Breite"
L["UnitFrames_AnchorWidthDesc"] = "Der Abstand zwischen Spieler- und Zielfenster"
L["UnitFrames_AnnounceChatDesc"] = "Chat-Kanal für Trinket-Ansagen"
L["UnitFrames_AnnounceTrink"] = "Sage Trinket an"
L["UnitFrames_AnnounceTrinkDesc"] = "Gebe Verwendung des Trinkets vom Gegner im Chat an."
L["UnitFrames_BuffCount"] = "Stärkungszauber-Zähler"
L["UnitFrames_DebuffCount"] = "Schwächungszauber-Zähler"
L["UnitFrames_Gap"] = " Abstand"
L["UnitFrames_GapDesc"] = " Vertikaler Abstand zwischen den Einheiten."
L["UnitFrames_ModifierKey"] = "Modtaste"
L["UnitFrames_NPCAuras"] = " Zeige NPC Auren "
L["UnitFrames_NPCAurasDesc"] = "Zeige Buffs/Debuffs, die von NPC´s gewirkt wurden."
L["UnitFrames_PlayerAuras"] = "Zeige Spieler Auren."
L["UnitFrames_PlayerAurasDesc"] = "Zeige Buffs/Debuffs, die durch dich gewirkt wurden."
L["UnitFrames_SetFocus"] = "Klicken um Fokus zu setzen."
L["UnitFrames_SetFocusDesc"] = "Setze Fokus mit Klick+Modtaste auf das Einheitenfenster"
L["UnitFrames_Units"] = "Einheiten"
L["Version"] = "Version"
--[[Translation missing --]]
--[[ L["WorldMarker"] = "World Marker"--]] 
--[[Translation missing --]]
--[[ L["WorldMarker_Show"] = "Show the World Marker in..."--]] 
--[[Translation missing --]]
--[[ L["WorldMarkerDesc"] = "Quick access to World Markers"--]] 
-- cf-localization end
end
