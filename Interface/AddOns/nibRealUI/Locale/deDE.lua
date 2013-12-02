local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "deDE")

if L then

L["Enabled"] = "Aktiviert"
L["Type /realui"] = "Gib %s ein, um Stil, Positionen und Einstellungen zu konfigurieren."
L["Combat Lockdown"] = "Combat Lockdown"
L["Layout will change after you leave combat."] = "Das Layout ändert sich, nachdem Du den Kampf verlassen hast."
L["Info Line currency tracking will update after UI Reload (/rl)"] = "Info Line currency tracking will update after UI Reload (/rl)"

-- Installation
L["INSTALL"] = "ZUM INSTALLIEREN KLICKEN"

L["RealUI Mini Patch"] = "RealUI Mini-Patch"
L["RealUI's settings have been updated."] = "RealUI-Einstellungen wurden aktualisiert."
L["Do you wish to apply the latest RealUI settings?"] = "Do you wish to apply the latest RealUI settings?"

L["Confirm reset RealUI?\n\nAll user settings will be lost."] = "Bist Du sicher, dass Du RealUI zurücksetzen möchtest?\n\n Alle Einstellungen gehen verloren."
L["Reload UI now to apply these changes?"] = "UI neu laden, um die Änderungen zu übernehmen?"
L["You need to Reload the UI for changes to take effect. Reload Now?"] = "Die UI muss neu geladen werden, damit die Änderungen wirksam werden. Jetzt neu laden?"

-- Power Mode
L["PowerModeEconomy"] =
[[|cff0099ffRealUI|r|cffffffff: Economy-Power-Modus aktiv.
Dieser Modus sieht grafische Updates in einer langsameren Rate vor. 
Kann die Performance bei schwächeren Rechner verbessern.]]

L["PowerModeNormal"] =
[[|cff0099ffRealUI|r|cffffffff: Normal-Power-Modus aktiv.
Dieser Modus sieht grafische Updates in der normalen Rate vor.]]

L["PowerModeTurbo"] =
[[|cff0099ffRealUI|r|cffffffff: Turbo-Power-Modus aktiv.
Dieser Modus sieht grafische Updates in einer schnellen Rate vor, so dass UI-Animationen flüssiger werden.
Dies wird die CPU-Last erhöhen.]]

-- RealUI Config
L["RealUI Config"] = "RealUI-Konfiguration"
L["Position"] = "Position"
L["Positions"] = "Positionen"
L["Vertical"] = "Vertikal"
L["Horizontal"] = "Horizontal"
L["Width"] = "Breite"
L["Height"] = "Höhe"

L["AddOn Control"] = "AddOn-Kontrolle"

L["Untick"] = "Deaktiviere"
L["Use"] = "Nutze"	-- i.e Use General Colors
L["to set"] = ", um an-\ngepasste Farben"
L["custom colors"] = "zu verwenden"

L["Fonts"] = "Fonts"
L["Chat Font Outline"] = "Chat Font Outline"
L["FS:Hybrid"] = "Hybrid"	-- Mixed
L["Use small fonts"] = "Kleine Fonts verwenden"
L["Use a mix of small and large fonts"] = "Große und kleine Fonts gemischt verwenden"
L["Use large fonts"] = "Große Fonts verwenden"

L["Latency"] = "Latenz"
L["Info Line"] = "Info-Line"
L["Bars"] = "Leisten"	-- Class Color Health "Bars"

L["Link Layouts"] = "Gleiche Layouts"
L["Use same settings between DPS/Tank and Healing layouts."] = "Gleiche Einstellungen für DPS/Tank- und Heiler-Layouts."
L["Use Large HuD"] = "Use Large HuD"
L["Increases size of key HuD elements (Unit Frames, etc)."] = "Increases size of key HuD elements (Unit Frames, etc)."
L["Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."] = "Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."

L["RealUI Control"] = "RealUI-Kontrolle"
L["Allow RealUI to control the action bars."] = "Erlaube RealUI, die Aktionsleisten zu kontrollieren."
L["Check to allow RealUI to control the Stance Bar's position."] = "Check to allow RealUI to control the Stance Bar's position."
L["Check to allow RealUI to control the Pet Bar's position."] = "Check to allow RealUI to control the Pet Bar's position."
L["Check to allow RealUI to control the Extra Action Button's position."] = "Check to allow RealUI to control the Extra Action Button's position."
L["Move Stance Bar"] = "Haltungsl. bewegen"
L["Move Pet Bar"] = "Begleiterl. bewegen"
L["Move Extra Button"] = "Extra-Aktionsl. bewegen"
L["Sizes"] = "Größen"
L["Buttons"] = "Buttons"
L["Padding"] = "Abstand"
L["Top"] = "Oben"
L["Bottom"] = "Unten"
L["Left"] = "Links"
L["Right"] = "Rechts"
L["Stance Bar"] = "Haltungsleiste"
L["Pet Bar"] = "Begleiterleiste"

L["Cannot open RealUI Configuration while in combat."] = "RealUI-Konfiguration kann nicht während des Kampfs geöffnet werden."
L["Note: Bartender settings"] = "Hinweis: Klick auf Erweiterte Einstellungen, um Bartenders Konfiguration zu öffnen.\n               Deaktiviere |cff30d0ffRealUI-Kontrolle|r wenn Du Einstellungen ändern möchtest,\n               die Real-UI kontrolliert (Position, Größe, Buttons, Abstand)."
L["Hint: Hold down Ctrl to view action bars."] = "Tipp: Drücke Strg, um die Aktionsleisten zu sehen."
L["Note: After changing bar positions..."] = "Hinweis: Nachdem Einstellungen geändert wurden, prüfe die Positionseinstellungen\n               um sicher zu stellen, dass sich keine UI-Elemente überlappen."

L["Allow RealUI to control STR position settings."] = "Erlaube RealUI, die %s-Position zu kontrollieren."
L["Layout"] = "Layout"
L["Allow RealUI to control STR layout settings."] = "Erlaube RealUI, das %s-Layout zu kontrollieren."
L["Style"] = "Style"
L["Allow RealUI to style STR."] = "Erlaube RealUI, %s zu stylen (erfordert Reload: /rl)"

L["Horizontal Groups"] = "Horizontale Gruppen"
L["Show Pet Frames"] = "Show Pet Frames"
L["Show While Solo"] = "Show While Solo"
L["Note: Grid2 settings"] = "Hinweis: Klick auf Erweiterte Einstellungen, um die Grid2-Konfiguration zu\n               öffen. Deaktiviere |cff30d0ffRealUI-Kontrolle|r wenn Du Einstellungen ändern\n               möchtest, die RealUI kontrolliert (Position, Layout, Ränder)."

L["Element Settings"] = "Element-Einstellungen"
L["Choose UI element to configure."] = "UI-Element zum Konfigurieren auswählen."
L["(use mouse-wheel for precision adjustment of sliders)"] = "(Benutze das Mausrad für die Feineinstellung der Schieberegler)"

L["Reverse Bar"] = "Leiste umkehren"
L["Reverse the direction of the cast bar."] = "Kehrt die Richtung der Zauberleiste um."

L["Create New Tracker"] = "Neuen Tracker anlegen"
L["Disable Selected Tracker"] = "Disable Selected Tracker"
L["Enable Selected Tracker"] = "Enable Selected Tracker"
L["Are you sure you wish to reset Tracking information to defaults?"] = "Bist Du sicher, dass Du die Tracker-Informationen auf die Standardwerte zurücksetzen möchtest?"
L["Tracker Options"] = "Tracker-Optionen"
L["Choose Tracker type."] = "Wähle Tracker-Typ."
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Spell Name or ID"] = "Zaubername oder ID"
L["Note: Spell Name or ID must match the spell you wish to track exactly. Capitalization and spaces matter."] = "Hinweis: Zaubername/ID müssen exakt dem Zauber entsprechen, der verfolgt werden soll.\n                  Groß- und Kleinschreibung und Leerzeichen werden beachtet."

L["Static"] = "Statisch"
L["Static Trackers remain visible and in the same location."] = "Statische Tracker bleiben sichtbar und am gleichen Ort."
L["Min Level (0 = ignore)"] = "Min.-Level (0 = ignor.)"
L["Ignore Spec"] = "Ignore Spec"
L["Show tracker regardless of current specialization"] = "Show tracker regardless of current specialization"
L["Cat"] = "Katze"
L["Bear"] = "Bär"
L["Moonkin"] = "Mondkin"
L["Human"] = "Menschlich"
L["Hide Out-Of-Combat"] = "OOC verbergen"
L["Force this Tracker to hide OOC, even if it's active."] = "Diesen Tracker immer OOC verbergen, auch wenn er aktiv ist."
L["Hide Stack Count"] = "Stack-Anzahl verbergen"
L["Don't show Buff/Debuff stack count on this tracker."] = "Buff/Debuff-Stack-Anzahl dieses Trackers nicht zeigen."

L["Indicator size"] = "Indicator Size"
L["Indicator padding"] = "Indicator Padding"
L["Inactive indicator opacity"] = "Inactive Indicator Opacity"
L["Show in combat"] = "Show in combat"
L["Show Indicators when you are in combat"] = "Show Indicators when you are in combat"
L["Show w/ hostile"] = "Show w/ hostile"
L["Show Indicators when you have an attackable target"] = "Show Indicators when you have an attackable target"
L["Show in PvE"] = "Show in PvE"
L["Show Indicators when you are in a PvE instance"] = "Show Indicators when you are in a PvE instance"
L["Show in PvP"] = "Show in PvP"
L["Show Indicators when you are in a PvP instance"] = "Show Indicators when you are in a PvP instance"
L["Vertical Cooldown"] = "Vertical Cooldown"
L["Use vertical cooldown indicator instead of spiral"] = "Use vertical cooldown indicator instead of spiral"

L["Stripe Opacity"] = "Stripe Opacity"
L["Window Opacity"] = "Window Opacity"

-- Info Line
L["Micromenu"] = "Mikromenu"
L["XP/Rep"] = "XP/Ruf"
L["SysInfo"] = "System-Info"
L["Spec Changer"] = "Spez.-Changer"
L["Layout Changer"] = "Layout-Changer"
L["Meter Toggle"] = "Anzeigen-Schalter"

L["Menu"] = "Menü"

L["Meters"] = "Anzeigen"

L["Stat"] = "Stat"
L["Cur"] = "Akt"
L["Max"] = "Max"
L["Min"] = "Min"
L["Avg"] = "Dur"

L["In"] = "In"
L["Out"] = "Out"
L["kbps"] = "kbps"
L["ms"] = "ms"
L["FPS"] = "FPS"

L["Date"] = "Datum"
L["Wintergrasp Time Left"] = "Restzeit Tausendwintersee"
L["No Wintergrasp Time Available"] = "Keine Zeit für Tausendwintersee verfügbar"
L["Tol Barad Time Left"] = "Restzeit Tol Barad"
L["No Tol Barad Time Available"] = "Keine Zeit für Tol Barad Time verfügbar"
L["Pending Invites:"] = "Offene Einladungen:"

L["Layout Changer"] = "Layout-Changer"
L["Current Layout:"] = "Aktuelles Layout:"
L["DPS/Tank"] = "DPS/Tank"
L["Healing"] = "Healing"

L["Meter Toggle"] = "Anzeigen-Schalter"
L["Active Meters:"] = "Aktive Anzeige:"

L["Start"] = "Start"

L["Current"] = "Aktuelle"
L["Remaining"] = "Übrige"

L["Honor Points"] = "EhP"
L["Conquest Points"] = "ErP"
L["Justice Points"] = "GP"
L["Valor Points"] = "TP"
L["Updated"] = "Akt."
L["To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"] = "To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"

L["Faction not set"] = "Keine Fraktion eingestellt"

L["<Click> to switch between"] = "<Klick> zum Wechseln"
L["XP and Rep display."] = "zwischen XP und Ruf."
L["<Click> to switch currency displayed."] = "<Klick> Angezeigte Währung wechseln."
L["<Alt+Click> to erase highlighted character data."] = "<Alt+Klick> Daten des markierten Charakters löschen."
L["<Shift+Click> to reset weekly caps."] = "<Shift+Klick>: Wöchentlichen Caps zurückstellen."
L["Note: Weekly caps will reset upon loading currency data"] = "Hinweis: Wöchentliche Caps werden auf einem Charakter, dessen wöchentliche "
L["on a character whose weekly caps have reset."] = "Caps schon zurückgestellt sind, erst beim Laden der Währungsdaten zurückgestellt."
L["<Click> to whisper, <Alt+Click> to invite."] = "<Klick> zum Flüstern, <Alt+Klick> zum Einladen."

L["Stat Display"] = "Stat-Anzeige"
L["<Spec Click> to change talent specs."] = "<Spez. Klick>: Talent-Spezialisierung wechseln."
L["<Equip Click> to equip."] = "<Ausr. Klick> zum Ausrüsten."
L["<Equip Ctl+Click> to assign to "] = "<Ausr. Strg+Klick>: Zuordnen zu "
L["<Equip Alt+Click> to assign to "] = "<Ausr. Alt+Klick>: Zuordnen zu "
L["<Equip Shift+Click> to unassign."] = "<Ausr. Shift+Klick>: Zuordnung aufheben."
L["<Stat Click> to configure."] = "<Stat Klick>: Konfigurieren."

L["<Click> to cycle through equipment sets."] = "<Klick> Ausrüstungsset wechseln."
L["<Click> to show calendar."] = "<Klick>: Kalender anzeigen."
L["<Shift+Click> to show timer."] = "<Shift+Klick>: Timer anzeigen."
L["<Click> to change layouts."] = "<Klick>: Layout ändern."
L["<Alt+Click> to change resolution."] = "<Alt+Klick>: Auflösung wechseln."
L["<Click> to toggle meters."] = "<Klick>: Anzeige wechseln."

-- HuD Config
L["Instructions"] = "Anleitung"
L["Load Defaults"] = "Standardwerte laden"
L["Show UI Elements"] = "UI-Elemente anzeigen"
L["Hide UI Elements"] = "UI-Elemente verbergen"
L["HuD Instructions"] = [[
		|cffffa500Step 1:|r Klick |cff30ff30UI-Elemente anzeigen|r um HIlfe bei der Positionierung der UI-Elemente zu erhalten.
		|cffffa500Step 2:|r Verwende das |cff30ff30Element-Sinstellungen|r-Fenster um Größe und Position einzelner UI-Elemente zu ändern.
		|cffffa500Step 3:|r Wen Du fertig bist, klicke |cff30ff30UI-Elemente verbergen|r.
	]]

-- World Boss Info
L["Galleon"]="Galleon"
L["Sha Of Anger"]="Sha Of Anger"
L["Nalak"]="Nalak"
L["Oondasta"]="Oondasta"
L["Celestials"]="Celestials"
L["Ordos"]="Ordos"

L["World Boss Done"]="\124cff00ff00Done\124r"
L["World Boss Not Done"]="\124cffff0000Not Done\124r"

end