local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "deDE")

if L then

-- General
L["Alert_CombatLockdown"] = "Kampfsperre" -- Needs review
L["DoReloadUI"] = "Du musst das UI neu laden, so dass die Änderungen wirksam werden. Jetzt neu laden?"
L["Slash_RealUI"] = "Tippe %s um den UI-Style, Positionen und Einstellungen zu konfigurieren" -- Needs review
L["Version"] = "Version" -- Needs review


-- Install
L["Install"] = "KLICKEN UM DIE INSTALLATION ZU STARTEN"
L["Patch_DoApply"] = "Möchtest du die letzten Einstellungen von RealUI übernehmen?" -- Needs review
L["Patch_MiniPatch"] = "RealUI Mini Patch" -- Needs review


-- Options
L["Appearance_StripeOpacity"] = "Streifen-Transparenz"
L["Appearance_WinOpacity"] = "Fenster-Transparenz"
L["Fonts"] = "Schriftarten" -- Needs review
L["Fonts_ChatOutline"] = "Chat Schriftartumriss" -- Needs review
L["Fonts_Hybrid"] = "Hybrid" -- Needs review
L["General_Enabled"] = "Aktiviert" -- Needs review
L["Layout_ApplyOOC"] = "Layout ändert sich sobald du den Kampf verläßt."
L["Layout_DPSTank"] = "DPS/Tank" -- Needs review
L["Layout_Healing"] = "Heilung" -- Needs review
L["Layout_Link"] = "Layouts verknüpfen" -- Needs review
L["Layout_LinkDesc"] = "Benutze die gleichen Einstellungen zwischen DPS/Tank- und Heiler-Layout" -- Needs review
L["Power_Eco"] = "Economy" -- Needs review
L["Power_EcoDesc"] = [=[Dieser Modus plant graphische Updates mit einer geringeren Rate als normal.
Kann bei Low-end PCs die Leistung erhöhen.]=]
L["Power_Normal"] = "Standardmodus"
L["Power_NormalDesc"] = "Dieser Modus plant graphische Updates mit einer Standardrate."
L["Power_PowerMode"] = "Powermodus"
L["Power_Turbo"] = "Turbomodus"
L["Power_TurboDesc"] = [=[Dieser Modus plant graphische Update mit einer sehr hohen Rate und stellt die Animationen des UI flüssiger.
Erhöht die Nutzung der CPU.]=]
L["Reset_Confirm"] = "Bist du sicher das du RealUI reseten möchtest?"
L["Reset_SettingsLost"] = "Alle Benutzereinstellungen gehen verloren." -- Needs review


-- Config
L["Alert_CantOpenInCombat"] = "Die RealUI-Konfiguration kann während des Kampfes nicht geöffnet werden." -- Needs review
L["Appearance_DefaultColors"] = "Benutze die Standardfarben" -- Needs review
L["Appearance_DefaultColorsDesc"] = "Deaktivere das Nutzen von benutzerdefinierten Farben" -- Needs review
L["AuraTrack_Buff"] = "Stärkungszauber" -- Needs review
L["AuraTrack_Create"] = "Erzeuge einen neuen Tracker" -- Needs review
L["AuraTrack_Debuff"] = "Schwächungszauber" -- Needs review
L["AuraTrack_Disable"] = "Deaktivieren den ausgewählten Tracker" -- Needs review
L["AuraTrack_DruidBear"] = "Bärform" -- Needs review
L["AuraTrack_DruidCat"] = "Katzenform" -- Needs review
L["AuraTrack_DruidHuman"] = "Mensch" -- Needs review
L["AuraTrack_DruidMoonkin"] = "Mondkin" -- Needs review
L["AuraTrack_Enable"] = "Aktiviere ausgewählten Tracker" -- Needs review
L["AuraTracker_VerticalCD"] = "Vertikale Abklingzeit" -- Needs review
L["AuraTrack_HideOOC"] = "Verstecke ausserhalb des Kampfes" -- Needs review
L["AuraTrack_HideOOCDesc"] = "Verstecken des Trackers erzwingen wenn man nicht im Kampf ist, auch wenn er aktiv ist." -- Needs review
L["AuraTrack_HideStack"] = "Verstecke Stapelzähler" -- Needs review
L["AuraTrack_HideStackDesc"] = "Zeige keinen Stapelzähler für Stärkungs-/Schwächaungszauber auf diesem Tracker." -- Needs review
L["AuraTrack_IgnoreSpec"] = "Ignoriere Spezalisierung" -- Needs review
L["AuraTrack_IgnoreSpecDesc"] = "Tracker anzeigen unabhängig von der Spezalisierung" -- Needs review
L["AuraTrack_InactiveOpacity"] = "Transparenz inaktiver Indikatoren" -- Needs review
L["AuraTrack_MinLevel"] = "Min Level (0 = ignorieren)" -- Needs review
L["AuraTrack_NoteSpellID"] = [=[Hinweis: Zaubername oder ID muss exakt dem Zauber entsprechen den du verfolgen möchtest
Großschreibung und Leerzeichen spielen eine Rolle
Um mehre Zauber zu verfolgen, nutze die ZauberID und separiere sie mit einem Komma (z.B. 1122,2233,3344).]=] -- Needs review
L["AuraTrack_Padding"] = "Indikatorfüllung" -- Needs review
L["AuraTrack_Position"] = "Position" -- Needs review
L["AuraTrack_Reset"] = "Bist du sicher das Tracking-Informationen auf Standard zurücksetzen möchtest?" -- Needs review
L["AuraTrack_ShowHostile"] = "Anzeigen mit feindlichem Ziel" -- Needs review
L["AuraTrack_ShowHostileDesc"] = "Zeige Indikatoren wenn ein angreifbares Ziel vorhanden ist" -- Needs review
L["AuraTrack_ShowInCombat"] = "Im Kampf anzeigen" -- Needs review
L["AuraTrack_ShowInCombatDesc"] = "Zeige Indikatoren wenn man im Kampf ist" -- Needs review
L["AuraTrack_ShowInPvE"] = "Im PvE anzeigen" -- Needs review
L["AuraTrack_ShowInPvEDesc"] = "Zeige Indikatoren in einer PvE-Instanz" -- Needs review
L["AuraTrack_ShowInPvP"] = "Im PvP anzeigen" -- Needs review
L["AuraTrack_ShowInPvPDesc"] = "Zeige Indikatoren in einer PvP-Instanz" -- Needs review
L["AuraTrack_Size"] = "Indikatorgröße" -- Needs review
L["AuraTrack_SpellNameID"] = "Zaubername oder ID" -- Needs review
L["AuraTrack_Static"] = "Statisch" -- Needs review
L["AuraTrack_StaticDesc"] = "Statische Tracker verbleiben sichtbar an der gleichen Stelle" -- Needs review
L["AuraTrack_TrackerOptions"] = "Trackeroptionen" -- Needs review
L["AuraTrack_VerticalCDDesc"] = "Benutze vertikale Abklingzeitenindikatoren anstatt der Spirale" -- Needs review
L["Bars_Bottom"] = "Unten" -- Needs review
L["Bars_Buttons"] = "Tasten" -- Needs review
L["Bars_Center"] = "Mitte" -- Needs review
L["Bars_Control"] = "Erlaube RealUI die Aktionsleisten zu kontrollieren." -- Needs review
L["Bars_HintCtrlView"] = "Halte Strg gedrückt um die Aktionsleisten anzuzeigen" -- Needs review
L["Bars_Left"] = "Links" -- Needs review
L["Bars_MoveEAB"] = "Bewege Extra Aktionsknopf" -- Needs review
L["Bars_MoveEABDesc"] = "Auswählen um RealUI zu erlauben die Position der Extraaktionstaste zu kontrollieren." -- Needs review
L["Bars_MovePet"] = "Bewege Begleiterleiste" -- Needs review
L["Bars_MovePetDesc"] = "Auswählen um RealUI zu erlauben die Position der Begleiterleiste zu kontrollieren." -- Needs review
L["Bars_MoveStance"] = "Bewege Haltungsleiste" -- Needs review
L["Bars_MoveStanceDesc"] = "Auswählen um RealUI zu erlauben die Position der Haltungsleiste zu kontrollieren." -- Needs review
L["Bars_NoteAdvSettings"] = [=[Hinweis: Benuzte die Fortgeschrittenen-Einstellung um das Konfigurationfenster von Bartender zu öffnen.
Wähle |cff30d0ffRealUI Control|r ab wenn du die Einstellungen ändern möchtest
die RealUI kontrolliert (Position, Größe, Buttons, Füllung).]=] -- Needs review
L["Bars_NoteCheckUIElements"] = [=[Hinweis: Nach ändern der Einstellung, stelle sicher das Du die Positionen überprüft hast
um sicherzustellen das keines der UI-Element sich überlappt.]=] -- Needs review
L["Bars_Padding"] = "Füllung" -- Needs review
L["Bars_PetBar"] = "Begleiterleiste" -- Needs review
L["Bars_Right"] = "Rechts" -- Needs review
L["Bars_Sizes"] = "Größen" -- Needs review
L["Control_AddonControl"] = "AddOn Kontrolle" -- Needs review
L["Fonts_HybridDesc"] = "Benutze eine Mischung aus kleinen und großen Schriftarten" -- Needs review
L["Fonts_LargeDesc"] = "Benutze große Schriftarten" -- Needs review
L["Fonts_SmallDesc"] = "Benutze kleine Schriftarten" -- Needs review
L["General_LoadDefaults"] = "Lade Standardeinstellungen" -- Needs review
L["General_Positions"] = "Positionen" -- Needs review
L["HuD_AlertHuDChangeSize"] = "Ändern der HUD-Größe kann die Positionen einiger Elemente verändern, es wird empfohlen vorher die Positionen der UI-Elemente zu überprüfen bevor die Änderungen angewendet werden." -- Needs review
L["HuD_ChooseElement"] = "Wähle das UI-Element zum konfidurieren aus" -- Needs review
L["HuD_ElementSettings"] = "Elementeinstellungen" -- Needs review
L["HuD_Height"] = "Höhe" -- Needs review
L["HuD_HideElements"] = "Verstecke UI-Elemente" -- Needs review
L["HuD_Horizontal"] = "Horizontal" -- Needs review
L["HuD_Instructions"] = "Anweisungen" -- Needs review
L["HuD_Instructions1"] = "|cffffa500Step 1:|r Klicken |cff30ff30Zeige UI-Elemente|r um bei der Neupositionierung der UI-Elemente zu helfen." -- Needs review
L["HuD_Instructions2"] = "|cffffa500Schritt 2:|r Benutze das Fenster |cff30ff30Elementeinstellungen|r um die einzelnen UI-Elemente zu positionieren und die Größe zu ändern" -- Needs review
L["HuD_Instructions3"] = "|cffffa500Schritt 3:|r Wenn du fertig bist, klicke auf |cff30ff30Verstecke UI-Elemente|r." -- Needs review
L["HuD_Latency"] = "HuD-Latenz" -- Needs review
L["HuD_MouseWheelSliders"] = "(benutze das Mausrad für eine präzise Einstellung des Schiebereglers)"
L["HuD_ShowElements"] = "Zeige UI-Elemente" -- Needs review
L["HuD_UseLarge"] = "Benutze großes HuD" -- Needs review
L["HuD_UseLargeDesc"] = "Erhöht die Größe der Schlüsselelemente des HuD (Einheitenfenster, etc)." -- Needs review
L["HuD_Vertical"] = "Vertical" -- Needs review
L["HuD_Width"] = "Breite" -- Needs review
L["Raid_ControlLayout"] = "Erlaube RealUI die Layouteinstellungen von %s's zu kontrollieren." -- Needs review
L["Raid_ControlPosition"] = "Erlaube RealUI die Positionen von %s's zu kontrollieren." -- Needs review
L["Raid_ControlStyle"] = "Erlaube RealUI %s zu ändern (benötigt ein neu laden des UI: /rl)" -- Needs review
L["Raid_HorizGroups"] = "Horizontale Gruppen" -- Needs review
L["Raid_Layout"] = "Layout" -- Needs review
L["Raid_NoteAdvSettings"] = [=[Hinweis: Benutze die Fortgeschrittenen-Einstellung um das Konfigurationsfenster von Grid2 zu öffnen.
Wähle |cff30d0ffRealUI Control|r ab wenn du die Einstellungen ändern möchtest
die RealUI kontrolliert (Position, Layout, Rahmen).]=] -- Needs review
L["Raid_ShowPets"] = "Zeige Begleiterfenster" -- Needs review
L["Raid_ShowSolo"] = "Anzeigen wenn Solo" -- Needs review
L["Raid_Style"] = "Style" -- Needs review


-- InfoLine
L["Clock_CalenderInvites"] = "Ausstehende Einladungen" -- Needs review
L["Clock_Date"] = "Datum" -- Needs review
L["Clock_NoTBTime"] = "Keine Zeit für Tol Barad verfügbar" -- Needs review
L["Clock_NoWGTime"] = "Keine Zeit für Tausendwinter verfügbar" -- Needs review
L["Clock_ShowCalendar"] = "<Klicken> um den Kalendar anzuzeigen"
L["Clock_ShowTimer"] = "<Shift+Klick> um die Timer anzuzeigen." -- Needs review
L["Clock_TBTime"] = "Restliche Zeit bis Tol Barad" -- Needs review
L["Clock_WGTime"] = "Restliche Zeit bis Tausendwinter" -- Needs review
L["Currency_Cycle"] = "<Klicken> um durch die angezeigten Währungen zu wechseln." -- Needs review
L["Currency_EraseData"] = "<Alt+Klick> um die hervorgehobenen Charakterdaten zu löschen"
L["Currency_NoteWeeklyReset"] = [=[Hinweis: Wöchentliche Grenzen werden zurückgesetzt nachdem die Währungsdaten eines
Charakters geladen werden wenn dessen wöchentliche Grenzen zurückgesetzt wurden.]=] -- Needs review
L["Currency_ResetCaps"] = "<Shift+Klick> um die wöchentlichen Caps zurückzusetzen" -- Needs review
L["Currency_TrackMore"] = "Um zusätzliche Währungen zu verfolgen, benutze den Währungstab im Spielerfenster und ändere die gewählte Währung zu 'Zeige im Rucksack'" -- Needs review
L["Currency_UpdatedAbbr"] = "Upd." -- Needs review
L["Friend_WhisperInvite"] = "<Klicken> um anzuflüstern, <Alt+Klick> zum einladen." -- Needs review
L["Guild_WhisperInvite"] = "<Klicken> zum anflüstern, <Alt+Klick> zum einladen." -- Needs review
L["InfoLine"] = "Informationszeile"
L["Layout_Change"] = "<Klicken> um das Layout zu wechseln"
L["Layout_Current"] = "Derzeitiges layout" -- Needs review
L["Layout_LayoutChanger"] = "Layoutwechsler" -- Needs review
L["Meters_Active"] = "Aktive Anzeigen:" -- Needs review
L["Meters_Header"] = "Anzeigenumschalter" -- Needs review
L["Meters_Toggle"] = "<Klicken> um Anzeigen ein- und auszublenden." -- Needs review
L["Spec_ChangeSpec"] = "<Spec Klick> um die Talentspezialisierung zu wechseln" -- Needs review
L["Spec_Equip"] = "<Anlegen Klicken> zum ausrüsten" -- Needs review
L["Spec_EquipAssignPrimary"] = "<Anlegen Strg+Klick> zum zuweisen des primären Ausrüstungsset" -- Needs review
L["Spec_EquipAssignSecondary"] = "<Anlegen Alt+Klick> zum zuweisen des sekundären Ausrüstungsset" -- Needs review
L["Spec_EquipUnassign"] = "<Anlegen Shift+Klick> um Zuweisung aufzuheben" -- Needs review
L["Spec_SpecChanger"] = "Spezialisierungswechsler" -- Needs review
L["Spec_StatConfig"] = "<Stat Klicken> zum konfigurieren." -- Needs review
L["Start"] = "Start" -- Needs review
L["Start_Config"] = "RealUI Config" -- Needs review
L["Sys_AverageAbbr"] = "Avg" -- Needs review
L["Sys_CurrentAbbr"] = "Cur" -- Needs review
L["Sys_FPS"] = "FPS" -- Needs review
L["Sys_In"] = "Eingehend" -- Needs review
L["Sys_kbps"] = "kbps" -- Needs review
L["Sys_Max"] = "Max" -- Needs review
L["Sys_Min"] = "Min" -- Needs review
L["Sys_ms"] = "ms" -- Needs review
L["Sys_Out"] = "Ausgehend" -- Needs review
L["Sys_Stat"] = "Wert" -- Needs review
L["Sys_SysInfo"] = "Systeminformation" -- Needs review
L["XPRep"] = "XP/Ruf" -- Needs review
L["XPRep_Current"] = "Aktuell" -- Needs review
L["XPRep_NoFaction"] = "Keine Fraktion ausgewäühlt" -- Needs review
L["XPRep_Remaining"] = "Verbleibend" -- Needs review
L["XPRep_Toggle"] = "<Klicken> zum umschalten der XP/Ruf-Anzeige"

end
