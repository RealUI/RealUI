local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "deDE")

if L then

-- General
L["Alert_CombatLockdown"] = "Kampfsperre" -- Needs review
L["DoReloadUI"] = "Du musst das UI neu laden, damit die Änderungen wirksam werden. Jetzt neu laden?" -- Needs review
-- L["Slash_Profile"] = ""
L["Slash_RealUI"] = "Tippe %s um UI-Style, Positionen und Einstellungen zu konfigurieren" -- Needs review
-- L["Slash_Taint"] = ""
L["Version"] = "Version"


-- Install
L["Install"] = "KLICKEN UM DIE INSTALLATION ZU STARTEN"
L["Patch_DoApply"] = "Möchtest du die letzten Einstellungen von RealUI übernehmen?" -- Needs review
L["Patch_MiniPatch"] = "RealUI Mini Patch" -- Needs review


-- Options
L["Appearance_ClassColorHealth"] = "Leben in Klassenfarben" -- Needs review
L["Appearance_ClassColorNames"] = "Namen in Klassenfarben" -- Needs review
L["Appearance_InfoLineBG"] = "Hintergrund für Informationszeile" -- Needs review
L["Appearance_StripeOpacity"] = "Streifen-Transparenz"
L["Appearance_WinOpacity"] = "Fenster-Transparenz"
L["Colors_Amber"] = "Bernsteingelb" -- Needs review
L["Colors_Blue"] = "Blau" -- Needs review
L["Colors_Cyan"] = "Cyan" -- Needs review
L["Colors_Green"] = "Grün" -- Needs review
L["Colors_Orange"] = "Orange" -- Needs review
L["Colors_Purple"] = "Violett" -- Needs review
L["Colors_Red"] = "Rot" -- Needs review
L["Colors_Yellow"] = "Gelb" -- Needs review
L["Fonts"] = "Schriftarten"
L["Fonts_AdvConfig"] = "Erweiterte Schriftartenkonfiguration" -- Needs review
-- L["Fonts_ChangeYellow"] = ""
-- L["Fonts_ChangeYellowDesc"] = ""
-- L["Fonts_Chat"] = ""
-- L["Fonts_ChatDesc"] = ""
-- L["Fonts_Desc"] = ""
-- L["Fonts_Font"] = ""
-- L["Fonts_Header"] = ""
-- L["Fonts_HeaderDesc"] = ""
L["Fonts_Hybrid"] = "Hybrid" -- Needs review
L["Fonts_HybridDesc"] = "Benutze eine Mischung aus kleinen und großen Schriftarten"
L["Fonts_LargeDesc"] = "Benutze große Schriftarten"
-- L["Fonts_Normal"] = ""
-- L["Fonts_NormalDesc"] = ""
-- L["Fonts_NormalOffset"] = ""
-- L["Fonts_NormalOffsetDesc"] = ""
-- L["Fonts_Outline"] = ""
-- L["Fonts_PixelCooldown"] = ""
-- L["Fonts_PixelLarge"] = ""
-- L["Fonts_PixelNumbers"] = ""
-- L["Fonts_PixelSmall"] = ""
L["Fonts_SmallDesc"] = "Benutze kleine Schriftarten"
-- L["Fonts_Standard"] = ""
-- L["Fonts_YellowFont"] = ""
L["General_Enabled"] = "Aktiviert"
-- L["General_InvalidParent"] = ""
-- L["General_LoadDefaults"] = ""
-- L["General_NoteParent"] = ""
-- L["General_NoteReload"] = ""
L["Layout_ApplyOOC"] = "Layout ändert sich sobald du den Kampf verläßt."
L["Layout_DPSTank"] = "DPS/Tank" -- Needs review
L["Layout_Healing"] = "Heilung"
L["Layout_Link"] = "Layouts verknüpfen" -- Needs review
L["Layout_LinkDesc"] = "Benutze die gleichen Einstellungen zwischen DPS/Tank- und Heiler-Layout"
L["Power_Eco"] = "Economy" -- Needs review
L["Power_EcoDesc"] = [=[Dieser Modus plant graphische Updates mit einer geringeren Rate als normal.
Kann bei Low-end PCs die Leistung erhöhen.]=]
L["Power_Normal"] = "Standardmodus"
L["Power_NormalDesc"] = "Dieser Modus plant graphische Updates mit einer Standardrate."
L["Power_PowerMode"] = "Powermodus"
L["Power_Turbo"] = "Turbomodus"
L["Power_TurboDesc"] = [=[Dieser Modus plant graphische Updates mit einer sehr hohen Rate und stellt die Animationen des UIs flüssiger dar.
Erhöht die Nutzung der CPU.]=] -- Needs review
L["Reset_Confirm"] = "Bist du sicher, dass du RealUI zurücksetzen möchtest?" -- Needs review
L["Reset_SettingsLost"] = "Alle Benutzereinstellungen gehen verloren."


-- Config
L["Alert_CantOpenInCombat"] = "Die RealUI-Konfiguration kann während des Kampfes nicht geöffnet werden."
L["Appearance_DefaultColors"] = "Benutze die Standardfarben"
L["Appearance_DefaultColorsDesc"] = "Deaktivieren, um benutzerdefinierte Farben zu nutzen" -- Needs review
L["AuraTrack_Buff"] = "Stärkungszauber"
L["AuraTrack_ChooseType"] = "Wähle Trackerart" -- Needs review
L["AuraTrack_Create"] = "Erzeuge einen neuen Tracker" -- Needs review
L["AuraTrack_Debuff"] = "Schwächungszauber"
L["AuraTrack_Disable"] = "Ausgewählten Tracker deaktivieren" -- Needs review
L["AuraTrack_DruidBear"] = "Bärform"
L["AuraTrack_DruidCat"] = "Katzenform" -- Needs review
L["AuraTrack_DruidHuman"] = "Mensch" -- Needs review
L["AuraTrack_DruidMoonkin"] = "Mondkin"
L["AuraTrack_Enable"] = "Aktiviere ausgewählten Tracker" -- Needs review
L["AuraTrack_HideOOC"] = "Verstecke außerhalb des Kampfes" -- Needs review
L["AuraTrack_HideOOCDesc"] = "Verstecken des Trackers außerhalb des Kampfes erzwingen, auch wenn er aktiv ist." -- Needs review
L["AuraTrack_HideStack"] = "Verstecke Stapelzähler" -- Needs review
L["AuraTrack_HideStackDesc"] = "Zeige keinen Stapelzähler für Stärkungs-/Schwächaungszauber auf diesem Tracker." -- Needs review
L["AuraTrack_HideTime"] = "Zeit verbergen" -- Needs review
L["AuraTrack_HideTimeDesc"] = "Verbleibende Zeit auf diesem Tracker nicht anzeigen." -- Needs review
L["AuraTrack_IgnoreSpec"] = "Ignoriere Spezalisierung" -- Needs review
L["AuraTrack_IgnoreSpecDesc"] = "Tracker unabhängig von der Spezialisierung anzeigen" -- Needs review
L["AuraTrack_InactiveOpacity"] = "Transparenz inaktiver Indikatoren" -- Needs review
L["AuraTrack_MinLevel"] = "Min Level (0 = ignorieren)" -- Needs review
L["AuraTrack_NoteSpellID"] = [=[Hinweis: Zaubername oder ID muss exakt dem Zauber entsprechen, den du verfolgen möchtest
Großschreibung und Leerzeichen spielen eine Rolle
Um mehrere Zauber zu verfolgen, nutze die ZauberID und separiere sie mit einem Komma (z.B. 1122,2233,3344).]=] -- Needs review
L["AuraTrack_Padding"] = "Indikatorfüllung" -- Needs review
L["AuraTrack_Reset"] = "Bist du sicher, dass du Tracking-Informationen auf Standard zurücksetzen möchtest?" -- Needs review
L["AuraTrack_ShowHostile"] = "Anzeigen mit feindlichem Ziel" -- Needs review
L["AuraTrack_ShowHostileDesc"] = "Zeige Indikatoren, wenn ein angreifbares Ziel vorhanden ist" -- Needs review
L["AuraTrack_ShowInCombat"] = "Im Kampf anzeigen"
L["AuraTrack_ShowInCombatDesc"] = "Zeige Indikatoren im Kampf" -- Needs review
L["AuraTrack_ShowInPvE"] = "Im PvE anzeigen"
L["AuraTrack_ShowInPvEDesc"] = "Zeige Indikatoren in einer PvE-Instanz"
L["AuraTrack_ShowInPvP"] = "Im PvP anzeigen"
L["AuraTrack_ShowInPvPDesc"] = "Zeige Indikatoren in einer PvP-Instanz"
L["AuraTrack_Size"] = "Indikatorgröße" -- Needs review
L["AuraTrack_SpellNameID"] = "Zaubername oder ID"
L["AuraTrack_Static"] = "Statisch"
L["AuraTrack_StaticDesc"] = "Statische Tracker verbleiben sichtbar an der gleichen Stelle"
L["AuraTrack_TrackerOptions"] = "Trackeroptionen" -- Needs review
L["AuraTrack_VerticalCD"] = "Vertikale Abklingzeit"
L["AuraTrack_VerticalCDDesc"] = "Benutze vertikale Abklingzeitenindikatoren anstatt der Spirale" -- Needs review
L["Bars_Bottom"] = "Unten"
L["Bars_Buttons"] = "Tasten" -- Needs review
L["Bars_Center"] = "Mitte"
L["Bars_Control"] = "Erlaube RealUI die Aktionsleisten zu kontrollieren." -- Needs review
L["Bars_HintCtrlView"] = "Halte Strg gedrückt um die Aktionsleisten anzuzeigen" -- Needs review
L["Bars_Left"] = "Links"
L["Bars_MoveEAB"] = "Bewege Extra Aktionsknopf" -- Needs review
L["Bars_MoveEABDesc"] = "Auswählen um RealUI zu erlauben die Position der Extraaktionstaste zu kontrollieren." -- Needs review
L["Bars_MovePet"] = "Bewege Begleiterleiste"
L["Bars_MovePetDesc"] = "Auswählen um RealUI zu erlauben die Position der Begleiterleiste zu kontrollieren." -- Needs review
L["Bars_MoveStance"] = "Bewege Haltungsleiste"
L["Bars_MoveStanceDesc"] = "Auswählen um RealUI zu erlauben die Position der Haltungsleiste zu kontrollieren." -- Needs review
L["Bars_NoteAdvSettings"] = [=[Hinweis: Benuzte die Fortgeschrittenen-Einstellung um das Konfigurationfenster von Bartender zu öffnen.
Wähle |cff30d0ffRealUI Control|r ab wenn du die Einstellungen ändern möchtest
die RealUI kontrolliert (Position, Größe, Buttons, Füllung).]=] -- Needs review
L["Bars_NoteCheckUIElements"] = [=[Hinweis: Nach Ändern der Einstellungen, stelle sicher, dass du die Positionen überprüft hast,
um sicherzustellen, dass keines der UI-Element sich überlappt.]=] -- Needs review
L["Bars_Padding"] = "Füllung" -- Needs review
L["Bars_PetBar"] = "Begleiterleiste"
L["Bars_Right"] = "Rechts"
L["Bars_Sizes"] = "Größen" -- Needs review
L["Control_AddonControl"] = "AddOn Kontrolle"
L["General_Position"] = "Position"
L["General_Positions"] = "Positionen"
L["HuD_AlertHuDChangeSize"] = "Ändern der HUD-Größe kann die Positionen einiger Elemente verändern. Daher wird empfohlen, die Positionen der UI-Elemente zu überprüfen, nachdem die Änderungen angewendet wurden." -- Needs review
L["HuD_ChooseElement"] = "Wähle das UI-Element zum Konfigurieren aus" -- Needs review
L["HuD_ElementSettings"] = "Elementeinstellungen" -- Needs review
L["HuD_Height"] = "Höhe"
L["HuD_HideElements"] = "Verstecke UI-Elemente" -- Needs review
L["HuD_Horizontal"] = "Horizontal"
L["HuD_Instructions"] = "Anweisungen" -- Needs review
L["HuD_Instructions1"] = "|cffffa500Step 1:|r Klicken |cff30ff30Zeige UI-Elemente|r um bei der Neupositionierung der UI-Elemente zu helfen." -- Needs review
L["HuD_Instructions2"] = "|cffffa500Schritt 2:|r Benutze das Fenster |cff30ff30Elementeinstellungen|r um die einzelnen UI-Elemente zu positionieren und die Größe zu ändern" -- Needs review
L["HuD_Instructions3"] = "|cffffa500Schritt 3:|r Wenn du fertig bist, klicke auf |cff30ff30Verstecke UI-Elemente|r." -- Needs review
L["HuD_Latency"] = "HuD-Latenz" -- Needs review
L["HuD_MouseWheelSliders"] = "(benutze das Mausrad für eine präzise Einstellung des Schiebereglers)"
L["HuD_ReverseBars"] = "Lebensbalken umkehren" -- Needs review
L["HuD_ShowElements"] = "Zeige UI-Elemente"
-- L["HuD_Uninterruptible"] = ""
L["HuD_UseLarge"] = "Benutze großes HuD"
L["HuD_UseLargeDesc"] = "Erhöht die Größe der Schlüsselelemente des HuD (Einheitenfenster, etc)." -- Needs review
L["HuD_Vertical"] = "Vertikal" -- Needs review
L["HuD_Width"] = "Breite"
L["Raid_30Width"] = "30 Spieler Breite" -- Needs review
L["Raid_40Width"] = "40 Spieler Breite" -- Needs review
L["Raid_ControlLayout"] = "Erlaube RealUI die Layouteinstellungen von %s's zu kontrollieren." -- Needs review
L["Raid_ControlPosition"] = "Erlaube RealUI die Positionen von %s's zu kontrollieren." -- Needs review
L["Raid_ControlStyle"] = "Erlaube RealUI %s zu ändern (benötigt ein Neuladen des UIs: /rl)" -- Needs review
L["Raid_Layout"] = "Layout"
L["Raid_NoteAdvSettings"] = [=[Hinweis: Benutze die Fortgeschrittenen-Einstellung um das Konfigurationsfenster von Grid2 zu öffnen.
Wähle |cff30d0ffRealUI Control|r ab wenn du die Einstellungen ändern möchtest
die RealUI kontrolliert (Position, Layout, Rahmen).]=] -- Needs review
L["Raid_ShowSolo"] = "Anzeigen wenn Solo" -- Needs review
L["Raid_Style"] = "Style" -- Needs review


-- InfoLine
L["Clock_CalenderInvites"] = "Ausstehende Einladungen" -- Needs review
L["Clock_Date"] = "Datum" -- Needs review
L["Clock_NoTBTime"] = "Keine Zeit für Tol Barad verfügbar"
L["Clock_NoWGTime"] = "Keine Zeit für Tausendwinter verfügbar"
L["Clock_ShowCalendar"] = "<Klicken> um den Kalendar anzuzeigen"
L["Clock_ShowTimer"] = "<Shift+Klick> um die Timer anzuzeigen."
L["Clock_TBTime"] = "Restliche Zeit bis Tol Barad" -- Needs review
L["Clock_WGTime"] = "Restliche Zeit bis Tausendwinter" -- Needs review
L["Currency_Cycle"] = "<Klicken> um durch die angezeigten Währungen zu wechseln."
L["Currency_EraseData"] = "<Alt+Klick> um die hervorgehobenen Charakterdaten zu löschen"
L["Currency_NoteWeeklyReset"] = [=[Hinweis: Wöchentliche Grenzen werden zurückgesetzt nachdem die Währungsdaten eines
Charakters geladen werden wenn dessen wöchentliche Grenzen zurückgesetzt wurden.]=] -- Needs review
L["Currency_ResetCaps"] = "<Shift+Klick> um die wöchentlichen Caps zurückzusetzen"
L["Currency_TrackMore"] = "Um zusätzliche Währungen zu verfolgen, benutze den Währungstab im Spielerfenster und ändere die gewünschte Währung zu 'Zeige im Rucksack'" -- Needs review
L["Currency_UpdatedAbbr"] = "Upd." -- Needs review
L["Friend_WhisperInvite"] = "<Klicken> zum Anflüstern, <Alt+Klick> zum Einladen." -- Needs review
L["Guild_WhisperInvite"] = "<Klicken> zum Anflüstern, <Alt+Klick> zum Einladen." -- Needs review
L["InfoLine"] = "Informationszeile"
L["Layout_Change"] = "<Klicken> um das Layout zu wechseln"
L["Layout_Current"] = "Derzeitiges Layout" -- Needs review
L["Layout_LayoutChanger"] = "Layoutwechsler" -- Needs review
L["Meters_Active"] = "Aktive Anzeigen:"
L["Meters_Header"] = "Anzeigenumschalter" -- Needs review
L["Meters_Toggle"] = "<Klicken> um Anzeigen ein- und auszublenden."
L["Spec_ChangeSpec"] = "<Spec Klick> um die Talentspezialisierung zu wechseln"
L["Spec_Equip"] = "< Ausrüstung Klick> zum Ausrüsten" -- Needs review
L["Spec_EquipAssignPrimary"] = "< Ausrüstung Strg+Klick> zum Zuweisen des Primärsets" -- Needs review
L["Spec_EquipAssignSecondary"] = "< Ausrüstung Alt+Klick> zum Zuweisen des Sekundärsets" -- Needs review
L["Spec_EquipUnassign"] = "< Ausrüstung Shift+Klick> um Zuweisung aufzuheben" -- Needs review
L["Spec_SpecChanger"] = "Spezialisierungswechsler" -- Needs review
L["Spec_StatConfig"] = "<Wert Klick> zum konfigurieren." -- Needs review
L["Spec_StatDisplay"] = "Werteanzeige" -- Needs review
L["Start"] = "Start"
L["Start_Config"] = "RealUI-Konfiguration" -- Needs review
L["Sys_AverageAbbr"] = "Avg" -- Needs review
L["Sys_CurrentAbbr"] = "Cur" -- Needs review
L["Sys_FPS"] = "FPS" -- Needs review
L["Sys_In"] = "Eingehend" -- Needs review
L["Sys_kbps"] = "kbps" -- Needs review
L["Sys_Max"] = "Max" -- Needs review
L["Sys_Min"] = "Min" -- Needs review
L["Sys_ms"] = "ms" -- Needs review
L["Sys_Out"] = "Ausgehend" -- Needs review
L["Sys_Stat"] = "Wert"
L["Sys_SysInfo"] = "Systeminformation"
L["XPRep"] = "EP/Ruf" -- Needs review
L["XPRep_Current"] = "Aktuell"
L["XPRep_NoFaction"] = "Keine Fraktion ausgewählt" -- Needs review
L["XPRep_Remaining"] = "Verbleibend"
L["XPRep_Toggle"] = "<Klicken> zum Umschalten der EP/Ruf-Anzeige" -- Needs review

end
