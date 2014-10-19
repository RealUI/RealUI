-------------------------------------------------------------------------------
-- Title: MSBT Options German Localization
-- Author: Mikord
-- German Translation by: Farook, Archiv
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't German.
if (GetLocale() ~= "deDE") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "Benutzerdefinierte Schrift"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "Ungültiger Schriftname."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "Schriftname existiert bereits."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "Schriftpfad muss zu einer .ttf-Datei führen."
L.MSG_UNABLE_TO_SET_FONT			= "Die ausgewählte Schrift kann nicht verwendet werden." 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "Benutzerdefinierte Sounds"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Ungültiger Sound-Name."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Sound-Name existiert bereits."
L.MSG_NEW_PROFILE					= "Neues Profil"
L.MSG_PROFILE_ALREADY_EXISTS		= "Profil existiert bereits."
L.MSG_INVALID_PROFILE_NAME			= "Ungültiger Profilname."
L.MSG_NEW_SCROLL_AREA				= "Neuer Scroll-Bereich"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Name für Scroll-Bereich existiert bereits."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Ungültiger Name für Scroll-Bereich."
L.MSG_ACKNOWLEDGE_TEXT				= "Bist du sicher, dass du diese Aktion durchführen willst?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normal"
L.MSG_INVALID_SOUND_FILE			= "Sound muss eine .ogg Datei sein."
L.MSG_NEW_TRIGGER					= "Neuer Auslöser"
L.MSG_TRIGGER_CLASSES				= "Klassen Auslöser"
L.MSG_MAIN_EVENTS					= "Hauptereignisse"
L.MSG_TRIGGER_EXCEPTIONS			= "Auslöser ausschließen"
L.MSG_EVENT_CONDITIONS				= "Ereignisbedingungen"
L.MSG_DISPLAY_QUALITY				= "Zeige Benachrichtigungen für Gegenstände dieser Qualtität."
L.MSG_SKILLS						= "Fähigkeiten"
L.MSG_SKILL_ALREADY_EXISTS			= "Fähigkeitsname existiert bereits."
L.MSG_INVALID_SKILL_NAME			= "Ungültiger Fähigkeitsname."
L.MSG_HOSTILE						= "Feind"
L.MSG_ANY							= "Jeder"
L.MSG_CONDITION						= "Bedingung"
L.MSG_CONDITIONS					= "Bedingungen"
L.MSG_ITEM_QUALITIES				= "Gegenstandsqualitäten"
L.MSG_ITEMS							= "Gegenstände"
L.MSG_ITEM_ALREADY_EXISTS			= "Gegenstandsname exisiert bereits."
L.MSG_INVALID_ITEM_NAME				= "Ungültiger Gegenstandsname."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="Benutzerdefinierte Medien", tooltip="Optionen für benutzerdefinierte Medien anzeigen."}
obj["general"]		= { label="Allgemein", tooltip="Allgemeine Optionen anzeigen."}
obj["scrollAreas"]	= { label="Scroll-Bereiche", tooltip="Optionen für das Erstellen, Löschen, und Konfigurieren der Scroll-Bereiche anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["events"]		= { label="Ereignisse", tooltip="Optionen für eingehende, ausgehende und benachrichtigende Ereignisse anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["triggers"]		= { label="Auslöser", tooltip="Optionen für das Auslösersystem anzeigen.\n\nFür mehr Informationen mit der Maus über die Symbole fahren."}
obj["spamControl"]	= { label="Spamkontrolle", tooltip="Optionen für die Spamkontrolle anzeigen."}
obj["cooldowns"]	= { label="Abklingzeiten", tooltip="Optionen für die Abklingzeiten anzeigen."}
obj["lootAlerts"]	= { label="Plündernachrichten", tooltip="Optionen für die Plünderbenachrichtigung anzeigen."}
obj["skillIcons"]	= { label="Fähigkeitssymbole", tooltip="Optionen für die Fähigkeitssymbole anzeigen."}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]				= { label="Mik's Scrolling Battle Text aktivieren", tooltip="MSBT aktivieren."}
obj["stickyCrits"]				= { label="Sticky-Krits", tooltip="Bei kritischen Treffern den 'Sticky'-Stil verwenden."}
obj["enableSounds"]				= { label="Sounds aktivieren", tooltip="Sounds abspielen, die Ereignissen und Auslösern zugewiesen wurden."}
obj["textShadowing"]			= { label="Textschatten", tooltip="Fügt den Schriften einen Schatteneffekt hinzu, um die Lesbarkeit zu erhöhen."}
obj["colorPartialEffects"]		= { label="Teileffekte einfärben", tooltip="Fügt den Teileffekten festgelegte Farben hinzu."}
obj["crushing"]					= { label="Schmetternde Stöße", tooltip="Zeigt den Anhang bei schmetternden Treffern an."}
obj["glancing"]					= { label="Streifende Treffer", tooltip="Zeigt den Anhang bei streifenden Treffern an."}
obj["absorb"]					= { label="Teilweise absorbiert", tooltip="Zeigt die zum Teil absobierte Menge an."}
obj["block"]					= { label="Teilweise geblockt", tooltip="Zeigt die zum Teil geblockte Menge an."}
obj["resist"]					= { label="Teilweise widerstanden", tooltip="Zeigt die zum Teil widerstandene Menge an."}
obj["vulnerability"]			= { label="Verwundbarkeitsboni", tooltip="Zeigt die Menge der Verwundbarkeitsboni an."}
obj["overheal"]					= { label="Überheilung", tooltip="Zeigt die Menge der Überheilung an."}
obj["overkill"]					= { label="Über Tod", tooltip="Zeigt die Menge des Schadens über Tod an."}
obj["colorDamageAmounts"]		= { label="Farbiger Schaden", tooltip="Färbt den Schaden in der entsprechenden Farbe ein."}
obj["colorDamageEntry"]			= { tooltip="Aktiviert Farbe für diese Schadensart."}
obj["colorUnitNames"]			= { label="Farbige Namen", tooltip="Färbt die Namen in Klassenfarbe ein."}
obj["colorClassEntry"]			= { tooltip="Aktiviert Farbe für diese Klasse."}
obj["enableScrollArea"]			= { tooltip="Scroll-Bereich aktivieren."}
obj["inheritField"]				= { label="Übernehmen", tooltip="Übernimmt die eingegebenen Werte.\n\nHacken entfernen, um zu überschreiben."}
obj["hideSkillIcons"]			= { label="Symbole verstecken", tooltip="Keine Symbole in diesem Scroll-Bereich anzeigen."}
obj["stickyEvent"]				= { label="Sticky-Stil verwenden", tooltip="Ereignis immer im 'Sticky'-Stil anzeigen."}
obj["enableTrigger"]			= { tooltip="Auslöser aktivieren."}
obj["allPowerGains"]			= { label="ALLE Regenerationen", tooltip="Zeigt alle Ressourcenregenerationen einschließlich derjenigen, die nicht im Kampflog gemeldet werden.\n\nWARNUNG: Diese Einstellung führt zu viel Spam, da sie alle Grenzwerte und Drosselfunktionen ignoriert.\n\nNICHT EMPFOHLEN."}
obj["abbreviateSkills"]			= { label="Fähigkeiten abkürzen", tooltip="Fähigkeiten abkürzen (nur Englisch).\n\nDies kann von jedem Ereignis mit dem %sl Code überschrieben werden."}
obj["mergeSwings"]				= { label="Schwünge verbinden", tooltip="Verbindet normale Meleetreffer, die in einer kurzen Zeitspanne erfolgen."}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]				= { label="Fähigkeiten verstecken", tooltip="Keine Fähigkeitsnamen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %s nun ignoriert wird."}
obj["hideNames"]				= { label="Namen verstecken", tooltip="Keine Namen für eingehende und ausgehende Ereignisse anzeigen.\n\nDu gibst ein wenig Anpassungsmöglichkeit auf Ereignisebene auf, da der Ereigniscode %n nun ignoriert wird."}
obj["hideFullOverheals"]		= { label="Überheilungen verstecken", tooltip="Heilungen, die eine effektive Heilung von null haben, werden nicht angezeigt."}
obj["hideFullHoTOverheals"]		= { label="HoT Überheilungen verstecken", tooltip="Heilungen über Zeit, die eine effektive Heilung von null haben, werden nicht angezeigt."}
obj["hideMergeTrailer"]			= { label="Verbinden-Anhang verstecken", tooltip="Der Anhang, der die Anzahl der miteinander verbundenen Treffer und Krits am Ende jedes Ereignisses darstellt, wird nicht angezeigt."}
obj["allClasses"]				= { label="Alle Klassen"}
obj["enablePlayerCooldowns"]	= { label="Spieler Abklingzeiten", tooltip="Zeigt Benachrichtigungen, wenn deine Abklingzeiten abgelaufen sind."}
obj["enablePetCooldowns"]		= { label="Begleiter Abklingzeiten", tooltip="Zeigt Benachrichtigungen, wenn die Abklingzeiten deines Begleiters abgelaufen sind."}
obj["enableItemCooldowns"]		= { label="Gegenstand Abklingzeiten", tooltip="Zeigt Benachrichtigungen, wenn deine Gegenstands-Abklingzeiten abgelaufen sind."}
obj["lootedItems"]				= { label="Geplünderte Gegenstände", tooltip="Zeigt Benachrichtigungen, wenn Gegenstände geplündert wurden."}
obj["moneyGains"]				= { label="Gold erhalten", tooltip="Zeigt Benachrichtigungen, wenn Gold erhalten wurde."}
obj["alwaysShowQuestItems"]		= { label="Questgegenstände immer anzeigen", tooltip="Questgegenstände immer anzeigen, unabhängig der ausgewählten Qualitäten."}
obj["enableIcons"]				= { label="Fähigkeitssymbole aktivieren", tooltip="Zeigt, wenn möglich, Symbole für Ereignisse an."}
obj["exclusiveSkills"]			= { label="Nur Fähigkeitsnamen", tooltip="Zeigt nur Fähigkeitsnamen, solange kein Symbol verfügbar ist."}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="Aktuelles Profil:", tooltip="Legt das aktuelle Profil fest."}
obj["normalFont"]			= { label="Schrift - Normal:", tooltip="Legt die Schriftart für nicht-kritische Treffer."}
obj["critFont"]				= { label="Schrift - Kritisch:", tooltip="Legt die Schriftart für kritische Treffer."}
obj["normalOutline"]		= { label="Kontur - Normal:", tooltip="Legt die Kontur für nicht-kritische Treffer."}
obj["critOutline"]			= { label="Kontur - Kritisch:", tooltip="Legt die Kontur für kritische Treffer."}
obj["scrollArea"]			= { label="Scroll-Bereich:", tooltip="Wählt den zu konfigurierenden Scroll-Bereich aus."}
obj["sound"]				= { label="Sound:", tooltip="Wählt den Sound aus, der abgespielt werden soll, wenn das Ereignis erscheint."}
obj["animationStyle"]		= { label="Animationen:", tooltip="Der Animationsstil für Nicht-'Sticky'-Animationen in dem Scroll-Bereich."}
obj["stickyAnimationStyle"]	= { label="Sticky Animationen:", tooltip="Der Animationsstil für 'Sticky'-Animationen in dem Scroll-Bereich."}
obj["direction"]			= { label="Richtung:", tooltip="Die Richtung der Animation."}
obj["behavior"]				= { label="Verhalten:", tooltip="Das Verhalten der Animation."}
obj["textAlign"]			= { label="Text ausrichten:", tooltip="Die Ausrichtung des Textes für die Animation."}
obj["iconAlign"]			= { label="Symbol ausrichten:", tooltip="Die Ausrichtung des Symbols für die Animation."}
obj["eventCategory"]		= { label="Ereigniskategorie:", tooltip="Die Kategorie der zu konfigurienden Ereignisse."}
obj["outputScrollArea"]		= { label="Scroll-Bereich:", tooltip="Den Scroll-Bereich für die Textausgabe auswählen."}
obj["mainEvent"]			= { label="Hauptereignis:"}
obj["triggerCondition"]		= { label="Bedingung:", tooltip="Die Bedingung, die getestet wird."}
obj["triggerRelation"]		= { label="Relation:"}
obj["triggerParameter"]		= { label="Parameter:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="Schrift hinzufügen", tooltip="Fügt eine benutzerdefinierte Schrift zu der Liste der verfügbaren Schriften.\n\nWARNUNG: Die Datei muss in dem Ziel-Verzeichnis existieren, *BEVOR* WoW gestartet wurde.\n\nEs wird empfohlen, die Datei in den MikScrollingBattleText\\Fonts Ordner zu kopieren um Fehler zu vermeiden."}
obj["addCustomSound"]			= { label="Sound hinzufügen", tooltip="Fügt einen benutzerdefinierten Sound zu der Liste der verfügbaren Sounds.\n\nWARNUNG: Die Datei muss in dem Ziel-Verzeichnis existieren, *BEVOR* WoW gestartet wurde.\n\nEs wird empfohlen, die Datei in den MikScrollingBattleText\\Sounds Ordner zu kopieren um Fehler zu vermeiden."}
obj["editCustomFont"]			= { tooltip="Klicken, um benutzerdefinierte Schrift zu bearbeiten."}
obj["deleteCustomFont"]			= { tooltip="Klicken, um benutzerdefinierte Schrift aus MSBT zu entfernen."}
obj["editCustomSound"]			= { tooltip="Klicken, um benutzerdefinierten Sound zu bearbeiten."}
obj["deleteCustomSound"]		= { tooltip="Klicken, um benutzerdefinierten Sound aus MSBT zu entfernen."}
obj["copyProfile"]				= { label="Kopieren", tooltip="Kopiert das aktuelle Profil auf ein neues Profil, dessen Namen du selbst bestimmst."}
obj["resetProfile"]				= { label="Zurücksetzen", tooltip="Setzt das Profil auf die Standardeinstellungen zurück."}
obj["deleteProfile"]			= { label="Löschen", tooltip="Löscht das Profil."}
obj["masterFont"]				= { label="Master Schrift", tooltip="Erlaubt dir die Master Schrift festzulegen, welche bei allen Scroll-Bereichen und Ereignissen übernommen wird, sofern sie nicht überschrieben wird."}
obj["partialEffects"]			= { label="Partielle Effekte", tooltip="Erlaubt dir festzulegen, welche partiellen Effekte angezeigt werden sollen, ob sie eingefärbt werden sollen, und wenn ja in welcher Farbe."}
obj["damageColors"]				= { label="Schaden Farben", tooltip="Erlaubt dir festzulegen, ob oder auch nicht die Beträge nach der Farbe der Schadensart gefärbt sind und welche Farben für jede Art verwendet werden."}
obj["classColors"]				= { label="Klassen Farben", tooltip="Erlaubt dir festzulegen, ob die Namen nach Klassenfarbe eingefärbt werden sollen oder welche Farbe für jede Klasse verwendet werden soll." }
obj["inputOkay"]				= { label=OKAY, tooltip="Eingaben übernehmen."}
obj["inputCancel"]				= { label=CANCEL, tooltip="Eingaben zurücksetzen."}
obj["genericSave"]				= { label=SAVE, tooltip="Speichert die Änderungen."}
obj["genericCancel"]			= { label=CANCEL, tooltip="Setzt die Änderungen zurück."}
obj["addScrollArea"]			= { label="Neuer Scroll-Bereich", tooltip="Einen neuen Scroll-Bereich auswählen, dem Ereignisse und Auslöser zugewiesen werden können."}
obj["configScrollAreas"]		= { label="Scroll-Bereiche konfigurieren", tooltip="Konfiguriert die normalen und Sticky-Styles, Text-Ausrichtung, Scroll Weite/Höhe und Position der Scroll-Bereiche."}
obj["editScrollAreaName"]		= { tooltip="Klicken, um den Namen des Scroll-Bereichs zu bearbeiten."}
obj["scrollAreaFontSettings"]	= { tooltip="Klicken, um die Schrifteinstellungen des Scroll-Bereichs zu bearbeiten, welche von allen Ereignissen dieses Bereichs übernommen werden, sofern sie nicht überschrieben werden."}
obj["deleteScrollArea"]			= { tooltip="Klicken, um den Scroll-Bereich zu löschen."}
obj["scrollAreasPreview"]		= { label="Vorschau", tooltip="Eine Vorschau auf die Änderungen."}
obj["toggleAll"]				= { label="Alle umschalten", tooltip="Die Aktivierung aller Ereignisse in der ausgewählten Kategorie umschalten."}
obj["moveAll"]					= { label="Alle verschieben", tooltip="Verschiebt alle Ereignisse in der ausgewählten Kategorie zu dem ausgewählten Scroll-Bereich."}
obj["eventFontSettings"]		= { tooltip="Klicken, um die Schrifteinstellungen für dieses Ereignis zu bearbeiten."}
obj["eventSettings"]			= { tooltip="Klicken, um die Ereigniseinstellungen wie Scroll-Bereich, Text, Sound, etc. zu bearbeiten."}
obj["customSound"]				= { tooltip="Klicken, um eine benutzerdefinierte Sound-Datei auszuwählen." }
obj["playSound"]				= { label="Abspielen", tooltip="Klicken, um den ausgewählten Sound abzuspielen."}
obj["addTrigger"]				= { label="Neuen Auslöser hinzufügen", tooltip="Einen neuen Auslöser hinzufügen."}
obj["triggerSettings"]			= { tooltip="Klicken, um die Auslöser-Einstellungen zu konfigurieren."}
obj["deleteTrigger"]			= { tooltip="Klicken, um diesen Auslöser zu löschen."}
obj["editTriggerClasses"]		= { tooltip="Klicken, um die Klassen, in der der Auslöser verwendet wird, zu bearbeiten."}
obj["addMainEvent"]				= { label="Ereignis hinzufügen", tooltip="Wenn IRGENDEINES dieser Ereignisse auftritt und deren definierte Bedingungen geschehen, werden die Auslöser ausgeführt, außer es trifft eine festgelegte Ausnahme zu."}
obj["addTriggerException"]		= { label="Ausnahme hinzufügen", tooltip="Wenn IRGENDEINE dieser Ausnahmen auftritt, wird der Auslöser nicht ausgeführt."}
obj["editEventConditions"]		= { tooltip="Klicken, um für dieses Ereignis die Bedingungen zu bearbeiten."}
obj["deleteMainEvent"]			= { tooltip="Klicken, um Ereignis zu entfernen."}
obj["addEventCondition"]		= { label="Bedingung hinzufügen", tooltip="Wenn JEDE dieser Bedingungen für das ausgewählte Ereignis zutrifft, wird der Auslöser ausgeführt, außer es trifft eine festgelegte Ausnahme zu."}
obj["editCondition"]			= { tooltip="Klicken, um Bedingung zu bearbeiten."}
obj["deleteCondition"]			= { tooltip="Klicken, um Bedingung zu entfernen."}
obj["throttleList"]				= { label="Unterdrückungs-Liste", tooltip="Benutzerdefinierte Unterdrückungszeit für festgelegte Fähigkeiten setzen."}
obj["mergeExclusions"]			= { label="Ausschlüsse zusammenfügen", tooltip="Verhindert, dass festgelegte Fähigkeiten zusammengefügt werden."}
obj["skillSuppressions"]		= { label="Fähigkeiten unterdrücken", tooltip="Unterdrückt Fähigkeiten durch ihren Namen."}
obj["skillSubstitutions"]		= { label="Fähigkeiten ersetzen", tooltip="Ersetzt Fähigkeitsnamen mit angepassten Werten."}
obj["addSkill"]					= { label="Fähigkeiten hinzufügen", tooltip="Neuen Fähigkeiten zur Liste hinzufügen."}
obj["deleteSkill"]				= { tooltip="Klicken, um Fähigkeiten zu entfernen."}
obj["cooldownExclusions"]		= { label="Cooldown-Ausschlüsse", tooltip="Bei festgelegten Fähigkeiten die Cooldown-Verfolgung ignorieren."}
obj["itemsAllowed"]				= { label="Gegenstände erlauben", tooltip="Festgelegte Gegenstände unabhängig der Gegenstandsqualität immer anzeigen."}
obj["itemExclusions"]			= { label="Gegenstände ignorieren", tooltip="Verhindert, dass festgelegte Gegenstände angezeigt werden."}
obj["addItem"]					= { label="Gegenstand hinzufügen", tooltip="Neuen Gegenstand zur Liste hinzufügen."}
obj["deleteItem"]				= { tooltip="Klicken, um Gegenstand zu entfernen."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="Schriftname:", tooltip="Der Name wird benutzt um die Schrift zu identifizieren.\n\nBeispiel: Meine Super Schrift"}
obj["customFontPath"]	= { label="Schrift Pfad:", tooltip="Der Pfad zu der Schrift Datei.\n\nNOTIZ: Wenn die Datei in dem empfohlenen MikScrollingBattleText\\Fonts Ordner ist, muss nur der Dateiname hier eingegeben werden anstatt der ganze Pfad.\n\nBeispiel: meineSchrift.ttf "}
obj["customSoundName"]	= { label="Sound Name:", tooltip="Der Name wird benutzt um den Sound zu identifizieren.\n\nBeispiel: Mein Sound"}
obj["customSoundPath"]	= { label="Sound Pfad:", tooltip="Der Pfad zu der Sound Datei.\n\nNOTIZ: Wenn die Datei in dem empfohlenen MikScrollingBattleText\\Sounds Ordner ist, muss nur der Dateiname hier eingegeben werden anstatt der ganze Pfad.\n\nBeispiel: mySound.ogg "}
obj["copyProfile"]		= { label="Neuer Profilname:", tooltip="Der Name des neuen Profils auf den das eben gewählte Profil kopiert werden soll."}
obj["partialEffect"]	= { tooltip="Der Trailer, der angehängt wird wenn der Partielle Effekte erscheint."}
obj["scrollAreaName"]	= { label="Neuen Scroll-Bereich-Namen eingeben:", tooltip="Neuer Name für den Scroll-Bereich."}
obj["xOffset"]			= { label="X-Achse:", tooltip="Die X-Achse des ausgewählten Scroll-Bereichs."}
obj["yOffset"]			= { label="Y-Achse:", tooltip="Die Y-Achse des ausgewählten Scroll-Bereichs."}
obj["eventMessage"]		= { label="Ausgabenachricht eingeben:", tooltip="Die Nachricht die angezeigt wird, wenn das Ereignis auftritt."}
obj["soundFile"]		= { label="Sound-Dateiname:", tooltip="Der Name der Sound Datei zum Abspielen wenn das Ereignis erscheint."}
obj["iconSkill"]		= { label="Fähigkeitssymbol:", tooltip="Der Name oder Spell-ID des Zaubers mit dem Symbol das angezeigt wird, wenn das Ereignis auftritt.\n\nMSBT wird versuchen, automatisch ein Symbol auszuwählen, wenn keines festgelegt wurde.\n\nNOTIZ: Eine Spell-ID muss anstatt einem Namen benutzt werden, wenn die Fähigkeit nicht im Zauberbuch für die Klasse, die gespielt wird, während das Ereignis auftritt, ist. Die meisten Datenbanken wie z.B. Wowhead Dir dabei helfen."}
obj["skillName"]		= { label="Fähigkeitsname:", tooltip="Name der Fähigkeit, die hinzugefügt werden soll."}
obj["substitutionText"]	= { label="Text ersetzen:", tooltip="Der Text, der für den Fähigkeitsnamen ersetzt werden soll."}
obj["itemName"]			= { label="Gegenstandsname:", tooltip="Name des Gegenstandes, der hinzugefügt werden soll."}

------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="Animationsgeschwindigkeit", tooltip="Die Master-Geschwindigkeit der Animation."}
obj["normalFontSize"]		= { label="Normale Schriftgröße", tooltip="Die Schriftgröße für nicht-kritische Treffer."}
obj["normalFontOpacity"]	= { label="Normale Transparenz", tooltip="Die Schrifttransparenz für nicht-kritische Treffer."}
obj["critFontSize"]			= { label="Kritische Schriftgröße", tooltip="Die Schriftgröße für kritische Treffer."}
obj["critFontOpacity"]		= { label="Kritische Transparenz", tooltip="Die Schrifttransparenz für kritische Treffer."}
obj["scrollHeight"]			= { label="Scroll-Höhe", tooltip="Die Höhe des Scroll-Bereichs."}
obj["scrollWidth"]			= { label="Scroll-Weite", tooltip="Die Weite des Scroll-Bereichs."}
obj["scrollAnimationSpeed"]	= { label="Geschwindigkeit", tooltip="Die Geschwindigkeit der Animation des Scroll-Bereichs."}
obj["powerThreshold"]		= { label="Energiesschwelle", tooltip="Die Schwelle, die die Energie überschreiten muss, um angezeigt zu werden."}
obj["healThreshold"]		= { label="Heilungsschwelle", tooltip="Die Schwelle, die die Heilung überschreiten muss, um angezeigt zu werden."}
obj["damageThreshold"]		= { label="Schadensschwelle", tooltip="Die Schwelle, die der Schaden überschreiten muss, um angezeigt zu werden."}
obj["dotThrottleTime"]		= { label="DoTs drosseln", tooltip="Die Nummer in Sekunden, die DoTs gedrosselt werden sollen."}
obj["hotThrottleTime"]		= { label="HoTs drosseln", tooltip="Die Nummer in Sekunden, die HoTs gedrosselt werden sollen."}
obj["powerThrottleTime"]	= { label="Energie drosseln", tooltip="Die Nummer in Sekunden, die Energieänderungen gedrosselt werden sollen."}
obj["skillThrottleTime"]	= { label="Drosseln", tooltip="Die Nummer in Sekunden, um diese Fähigkeit zu drosseln."}
obj["cooldownThreshold"]	= { label="Cooldown-Schwelle", tooltip="Fähigkeiten mit einer Abklingzeit, die weniger als die angegebenen Sekunden entspricht, werden nicht angezeigt."}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "Eingehend Spieler"
obj[2] = "Eingehend Begleiter"
obj[3] = "Ausgehend Spieler"
obj[4] = "Ausgehend Begleiter"
obj[5] = "Benachrichtigung"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Menge des erhaltenen Schadens.\n"
obj["HEALING_TAKEN"]		= "%a - Menge der erhaltenen Heilung.\n"
obj["DAMAGE_DONE"]			= "%a - Menge des Schadens.\n"
obj["HEALING_DONE"]			= "%a - Geheilte Menge.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Menge des absobierten Schadens.\n"
obj["AURA_AMOUNT"]			= "%a - Menge der Stapel für eine Aura.\n"
obj["ENERGY_AMOUNT"]		= "%a - Menge der Energie.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - Menge der momentanen Combo-Punkte.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Menge der heiligen Kraft.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - Menge der Ehre.\n"
obj["REP_AMOUNT"]			= "%a - Menge des Rufs.\n"
obj["ITEM_AMOUNT"]			= "%a - Menge des geplünderten Gegenstands.\n"
obj["SKILL_AMOUNT"]			= "%a - Menge der Punkte, die du in der Fähigkeit hast.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Menge der erhaltenen Erfahrung.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Menge des partiellen Effekts.\n"
obj["ATTACKER_NAME"]		= "%n - Name des Angreifers.\n"
obj["HEALER_NAME"]			= "%n - Name des Heilers.\n"
obj["ATTACKED_NAME"]		= "%n - Name der angegriffenen Einheit.\n"
obj["HEALED_NAME"]			= "%n - Name der geheilten Einheit.\n"
obj["BUFFED_NAME"]			= "%n - Name der gebufften Einheit.\n"
obj["UNIT_KILLED"]			= "%n - Name der getöteten Einheit.\n"
obj["SKILL_NAME"]			= "%s - Name der Fähigkeit.\n"
obj["SPELL_NAME"]			= "%s - Name des Zaubers.\n"
obj["DEBUFF_NAME"]			= "%s - Name des Debuffs.\n"
obj["BUFF_NAME"]			= "%s - Name des Buffs\n"
obj["ITEM_BUFF_NAME"]		= "%s - Name des Gegenstands-Buffs.\n"
obj["EXTRA_ATTACKS"]		= "%s - Name der Fähigkeit, die Extraangriffe gewährt.\n"
obj["SKILL_LONG"]			= "%sl - Lange Form von %s. Wird benutzt, um Abkürzungen für das Ereignis zu überschreiben.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Art des erhaltenen Schadens.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Art des angerichteten Schadens.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Name der Schadensquelle (Fallen, Ertrinken, Lava, usw.).\n"
obj["FACTION_NAME"]			= "%e - Name der Fraktion.\n"
obj["EMOTE_TEXT"]			= "%e - Der Text der Geste.\n"
obj["MONEY_TEXT"]			= "%e - Der Text des erhaltenen Geldes.\n"
obj["COOLDOWN_NAME"]		= "%e - Name der Fähigkeit, die bereit ist.\n"
obj["ITEM_COOLDOWN_NAME"]	= "%e - Name des Gegenstands, der bereit ist.\n"
obj["ITEM_NAME"]			= "%e - Der Name des geplünderten Gegenstands.\n"
obj["POWER_TYPE"]			= "%p - Art der Energie (Energie, Wut, Mana, Runenmacht, usw.).\n"
obj["TOTAL_ITEMS"]			= "%t - Gesamte Anzahl der geplünderten Gegenstände im Inventar."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert eingehende Melee-Treffer."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert eingehende Melee-Krits."}
obj["INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert eingehende Melee-Fehlschläge."}
obj["INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert eingehendes Melee-Ausweichen."}
obj["INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert eingehendes Melee-Parieren."}
obj["INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert eingehendes Melee-Blocken."}
obj["INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert eingehende Melee-Abwehr."}
obj["INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Meleeschaden."}
obj["INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert eingehende Fähigkeitstreffer."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert eingehende Fähigkeitskrits."}
obj["INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert eingehenden Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert eingehenden Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert eingehenden, kritischen Schaden durch Schadensschilde."}
obj["INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert eingehende Fähigkeits-Fehlschläge."}
obj["INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert eingehendes Fähigkeits-Ausweichen."}
obj["INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert eingehendes Fähigkeits-Parieren."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert eingehendes Fähigkeits-Blocken."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert eingehende Fähigkeits-Abwehr."}
obj["INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert eingehendes Widerstehen von Fähigkeiten."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert eingehenden, absorbierten Fähigkeitsschaden."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den du immun bist."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert eingehende Reflektionen von Fähigkeitsschaden."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert eingehende Fähigkeitsunterbrechungen."}
obj["INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert eingehende Heilungen."}
obj["INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert eingehende, kritische Heilungen."}
obj["INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert eingehende Heilungen über Zeit."}
obj["INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert eingehende, kritische Heilungen über Zeit."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Umwelt-Schaden", tooltip="Aktiviert Umwelt-Schaden (Fallen, Ertrinken, Lava, usw.)."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert für Begleiter eingehende Melee-Treffer."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert für Begleiter eingehende Melee-Krits."}
obj["PET_INCOMING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Melee-Fehlschläge."}
obj["PET_INCOMING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Melee-Ausweichen."}
obj["PET_INCOMING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert für Begleiter eingehendes Melee-Parieren."}
obj["PET_INCOMING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert für Begleiter eingehendes Melee-Blocken."}
obj["PET_INCOMING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert für Begleiter eingehende Melee-Abwehr."}
obj["PET_INCOMING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Meleeschaden."}
obj["PET_INCOMING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert eingehenden Meleeschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert für Begleiter eingehende Fähigkeitstreffer."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert für Begleiter eingehende Fähigkeitskrits."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert für Begleiter eingehenden Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert für Begleiter eingehenden Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert für Begleiter eingehenden, kritischen Schaden durch Schadensschilde."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Fehlschläge."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Ausweichen."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Parieren."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert für Begleiter eingehendes Fähigkeits-Blocken."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert für Begleiter eingehende Fähigkeits-Abwehr."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert für Begleiter eingehendes Widerstehen von Fähigkeiten."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert für Begleiter eingehenden, absorbierten Fähigkeitsschaden."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert eingehenden Fähigkeitsschaden, gegen den dein Begleiter immun ist."}
obj["PET_INCOMING_HEAL"]						= { label="Heilung", tooltip="Aktiviert für Begleiter eingehende Heilungen."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen."}
obj["PET_INCOMING_HOT"]							= { label="HoT", tooltip="Aktiviert für Begleiter eingehende Heilungen über Zeit."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert für Begleiter eingehende, kritische Heilungen über Zeit."}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert ausgehende Melee-Treffer."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert ausgehende Melee-Krits."}
obj["OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert ausgehende Melee-Fehlschläge."}
obj["OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert ausgehendes Melee-Ausweichen."}
obj["OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert ausgehendess Melee-Parieren."}
obj["OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert ausgehendes Melee-Blocken."}
obj["OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert ausgehende Melee-Abwehr."}
obj["OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Meleeschaden."}
obj["OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert ausgehendes Melee-Entkommen."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert ausgehende Fähigkeitstreffer."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert ausgehende Fähigkeitskrits."}
obj["OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert ausgehenden Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT-Krit", tooltip="Aktiviert ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde."}
obj["OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert ausgehende Fähigkeits-Fehlschläge."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert ausgehendes Fähigkeits-Ausweichen."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert ausgehendes Fähigkeits-Parieren."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert ausgehendes Fähigkeits-Blocken."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert ausgehende Fähigkeits-Abwehr."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert ausgehendes Widerstehen von Fähigkeiten."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert ausgehenden, absorbierten Fähigkeitsschaden."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Fähigkeit: Reflektieren", tooltip="Aktiviert Reflektionen von Fähigkeitsschaden, der zu dir zurückgeworfen wird."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert ausgehende Fähigkeitsunterbrechungen."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Entkommen", tooltip="Aktiviert ausgehendes Fähigkeits-Entkommen."}
obj["OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert ausgehende Heilungen."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen."}
obj["OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert ausgehende Heilungen über Zeit."}
obj["OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert ausgehende, kritische Heilungen über Zeit."}
obj["OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert ausgehende Entzauberungen."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Melee: Treffer", tooltip="Aktiviert von Begleiter ausgehende Melee-Treffer."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Melee: Krit", tooltip="Aktiviert von Begleiter ausgehende Melee-Krits."}
obj["PET_OUTGOING_MISS"]						= { label="Melee: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Melee-Fehlschläge."}
obj["PET_OUTGOING_DODGE"]						= { label="Melee: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Ausweichen."}
obj["PET_OUTGOING_PARRY"]						= { label="Melee: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Melee-Parieren."}
obj["PET_OUTGOING_BLOCK"]						= { label="Melee: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Melee-Blocken."}
obj["PET_OUTGOING_DEFLECT"]						= { label="Melee: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Melee-Abwehr."}
obj["PET_OUTGOING_ABSORB"]						= { label="Melee: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Meleeschaden."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Melee: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Meleeschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_EVADE"]						= { label="Melee: Entkommen", tooltip="Aktiviert von Begleiter ausgehendes Melee-Entkommen."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Fähigkeit: Treffer", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitstreffer."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Fähigkeit: Krit", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitskrits."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="Fähigkeit: DoT", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="Fähigkeit: DoT Kritisch", tooltip="Aktiviert von Begleiter ausgehenden, kritischen Fähigkeitsschaden über Zeit."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Schadensschild: Treffer", tooltip="Aktiviert ausgehenden Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Schadensschild: Krit", tooltip="Aktiviert ausgehenden, kritischen Schaden durch Schadensschilde des Begleiters."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Fähigkeit: Fehlschlag", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Fehlschläge."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Fähigkeit: Ausweichen", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Ausweichen."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Fähigkeit: Parieren", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Parieren."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Fähigkeit: Blocken", tooltip="Aktiviert von Begleiter ausgehendes Fähigkeits-Blocken."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Fähigkeit: Abwehr", tooltip="Aktiviert von Begleiter ausgehende Fähigkeits-Abwehr."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Fähigkeit: Widerstehen", tooltip="Aktiviert von Begleiter ausgehendes Widerstehen von Fähigkeiten."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Fähigkeit: Absorbieren", tooltip="Aktiviert von Begleiter ausgehenden, absorbierten Fähigkeitsschaden."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Fähigkeit: Immunität", tooltip="Aktiviert von Begleiter ausgehenden Fähigkeitsschaden, gegen den der Feind immun ist."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Fähigkeit: Unterbrechen", tooltip="Aktiviert von Begleiter ausgehende Fähigkeitsunterbrechungen."}
obj["PET_OUTGOING_HEAL"]						= { label="Heilung", tooltip="Aktiviert von Begleiter ausgehende Heilungen."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Heilung: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen."}
obj["PET_OUTGOING_HOT"]							= { label="HoT", tooltip="Aktiviert von Begleiter ausgehende Heilungen über Zeit."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="HoT: Krit", tooltip="Aktiviert von Begleiter ausgehende, kritische Heilungen über Zeit."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dispel", tooltip="Aktiviert von Begleiter ausgehende Entzauberungen."}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuffs", tooltip="Aktiviert Debuffs, wenn du betroffen bist."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Debuff-Stapel", tooltip="Aktiviert Debuff-Stapel, wenn du betroffen bist."}
obj["NOTIFICATION_BUFF"]				= { label="Buffs", tooltip="Aktiviert Buffs, die du erhälst."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Buff-Stacks", tooltip="Aktiviert Buff-Stapel, die du erhälst."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Gegenstands-Buffs", tooltip="Aktiviert Buffs, die ein Gegenstand erhält."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Debuff verblasst", tooltip="Aktiviert Debuffs, die von dir verblassen."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Buff verblasst", tooltip="Aktiviert Buffs, die von dir verblassen."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Gegenstands-Buff verblasst", tooltip="Aktiviert Gegenstands-Buffs, die von dir verblassen."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Kampfeintritt", tooltip="Aktiviert, wenn du in den Kampf eintrittst."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Kampfaustritt", tooltip="Aktiviert, wenn du in den Kampf verlässt."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Energie erhalten", tooltip="Aktiviert, wenn du zusätzliches Mana, Wut oder Energie erhälst."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Energie verloren", tooltip="Aktiviert, wenn du durch Abzug Mana, Wut oder Energie verlierst."}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Combo-Punkte erhalten", tooltip="Aktiviert, wenn du Combo-Punkte bekommst."}
obj["NOTIFICATION_CP_FULL"]				= { label="Combo-Punkte komplett", tooltip="Aktiviert, wenn du alle Combo-Punkte erreicht hast."}
obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Heilige Kraft verändert", tooltip="Aktiviert, wenn sich deine Heilige Kraft verändert."}
obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Heilige Kraft komplett", tooltip="Aktiviert, wenn deine Heilige Kraft voll ist."}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Ehre erhalten", tooltip="Aktiviert, wenn du Ehre erhälst."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Ruf erhalten", tooltip="Aktiviert, wenn du Ruf erhälst."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Ruf verloren", tooltip="Aktiviert, wenn du Ruf verlierst."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Skillpunkt erhalten", tooltip="Aktiviert, wenn du einen Skillpunkt erhälst."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Erfahrung erhalten", tooltip="Aktiviert, wenn du Erfahrung erhälst."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Todesstoß Spieler", tooltip="Aktiviert, wenn du einen Todesstoß bei einem Spieler anbringst."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Todesstoß NPC", tooltip="Aktiviert, wenn du einen Todesstoß bei einem NPC anbringst."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Extraattacken", tooltip="Aktiviert, wenn du Extraattacken durch Windzorn, Schwertspezialisierung usw. erhälst."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Feind erhält Buff", tooltip="Aktiviert, wenn dein aktuelles, feindliches Ziel einen Buff erhält."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Monster Emotes", tooltip="Aktiviert Emotes, die dein aktuelles Ziel sagt."}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "Meleeschaden"
obj["RANGE_DAMAGE"]				= "Fernkampfschaden"
obj["SPELL_DAMAGE"]				= "Fähigkeitsschaden"
obj["GENERIC_DAMAGE"]			= "Melee-/Fernkampf-/Fähigkeitsschaden"
obj["SPELL_PERIODIC_DAMAGE"]	= "Periodischer Fähigkeitsschaden (DoT)"
obj["DAMAGE_SHIELD"]			= "Schadensschild-Schaden"
obj["DAMAGE_SPLIT"]				= "Aufgeteilter Schaden"
obj["ENVIRONMENTAL_DAMAGE"]		= "Umwelt-Schaden"
obj["SWING_MISSED"]				= "Melee-Fehlschlag"
obj["RANGE_MISSED"]				= "Fernkampf-Fehlschlag"
obj["SPELL_MISSED"]				= "Fähigkeits-Fehlschlag"
obj["GENERIC_MISSED"]			= "Melee-/Fernkampf-/Fähigkeits-Fehlschlag"
obj["SPELL_PERIODIC_MISSED"]	= "Periodischer Fähigkeits-Fehlschlag"
obj["SPELL_DISPEL_FAILED"]		= "Dispel-Fehlschlag"
obj["DAMAGE_SHIELD_MISSED"]		= "Schadensschild-Fehlschlag"
obj["SPELL_HEAL"]				= "Heilung"
obj["SPELL_PERIODIC_HEAL"]		= "Periodische Heilung (HoT)"
obj["SPELL_ENERGIZE"]			= "Powergewinn"
obj["SPELL_PERIODIC_ENERGIZE"]	= "Periodischer Powergewinn"
obj["SPELL_DRAIN"]				= "Powerverlust"
obj["SPELL_PERIODIC_DRAIN"]		= "Periodischer Powerverlust"
obj["SPELL_LEECH"]				= "Power-Absaugen"
obj["SPELL_PERIODIC_LEECH"]		= "Periodischer Power-Absaugen"
obj["SPELL_INTERRUPT"]			= "Fähigkeit unterbrochen"
obj["SPELL_AURA_APPLIED"]		= "Aura eingesetzt"
obj["SPELL_AURA_REMOVED"]		= "Aura entfernt"
obj["SPELL_STOLEN"]				= "Aura gestohlen"
obj["SPELL_DISPEL"]				= "Aura Dispel"
obj["SPELL_AURA_REFRESH"]		= "Aura aufgefrischt"
obj["SPELL_AURA_BROKEN_SPELL"]	= "Aura gebrochen"
obj["ENCHANT_APPLIED"]			= "Verzauberung eingesetzt"
obj["ENCHANT_REMOVED"]			= "Verzauberung entfernt"
obj["SPELL_CAST_START"]			= "Wirken gestartet"
obj["SPELL_CAST_SUCCESS"]		= "Wirken erfolgreich"
obj["SPELL_CAST_FAILED"]		= "Wirken fehlgeschlagen"
obj["SPELL_SUMMON"]				= "Beschwören"
obj["SPELL_CREATE"]				= "Erstellen"
obj["PARTY_KILL"]				= "Todesstoß"
obj["UNIT_DIED"]				= "Einheit tot"
obj["UNIT_DESTROYED"]			= "Einheit zerstört"
obj["SPELL_EXTRA_ATTACKS"]		= "Zusätzliche Attacken"
obj["UNIT_HEALTH"]				= "Lebenspunkteveränderung"
obj["UNIT_POWER"]				= "Powerveränderung"
obj["SKILL_COOLDOWN"]			= "Spielerabklingzeit abgelaufen"
obj["PET_COOLDOWN"]				= "Begleiterabklingzeit abgelaufen"
obj["ITEM_COOLDOWN"]			= "Gegenstandabklingzeit abgelaufen"
 
-- Main event conditions.
obj["sourceName"]				= "Quellenname"
obj["sourceAffiliation"]		= "Quellenzugehörigkeit"
obj["sourceReaction"]			= "Quellenreaktion"
obj["sourceControl"]			= "Quellenkontrolle"
obj["sourceUnitType"]			= "Quellentyp"
obj["recipientName"]			= "Empfängername"
obj["recipientAffiliation"]		= "Empfängerzugehörigkeit"
obj["recipientReaction"]		= "Empfängerreaktion"
obj["recipientControl"]			= "Empfängerkontrolle"
obj["recipientUnitType"]		= "Empfängertyp"
obj["skillID"]					= "Fähigkeits-ID"
obj["skillName"]				= "Fähigkeitsname"
obj["skillSchool"]				= "Fähigkeitsschule"
obj["extraSkillID"]				= "Zusätzliche Fähigkeits-ID"
obj["extraSkillName"]			= "Zusätzlicher Fähigkeitsname"
obj["extraSkillSchool"]			= "Zusätzliche Fähigkeitsschule"
obj["amount"]					= "Menge"
obj["overkillAmount"]			= "Menge über Tod"
obj["damageType"]				= "Schadensart"
obj["resistAmount"]				= "Widerstandene Menge"
obj["blockAmount"]				= "Geblockte Menge"
obj["absorbAmount"]				= "Absobierte Menge"
obj["isCrit"]					= "Krit"
obj["isGlancing"]				= "Gestreifter Treffer"
obj["isCrushing"]				= "Schmetternder Stoß"
obj["extraAmount"]				= "Extra Menge"
obj["missType"]					= "Verfehlen-Typ"
obj["hazardType"]				= "Gefahrentyp"
obj["powerType"]				= "Power-Typ"
obj["auraType"]					= "Auren-Typ"
obj["threshold"]				= "Schwelle"
obj["unitID"]					= "Einheit ID"
obj["unitReaction"]				= "Einheit Reaktion"
obj["itemID"]					= "Gegenstand ID"
obj["itemName"]					= "Gegenstandsname"

-- Exception conditions.
obj["activeTalents"]			= "Aktive Talente"
obj["buffActive"]				= "Buff Aktiv"
obj["buffInactive"]				= "Buff Inaktiv"
obj["currentCP"]				= "Momentane Combo Punkte"
obj["currentPower"]				= "Momentane Energie"
obj["inCombat"]					= "Im Kampf"
obj["recentlyFired"]			= "Auslöser kürzlich aktiviert"
obj["trivialTarget"]			= "Triviales Ziel"
obj["unavailableSkill"]			= "Fehlende Fähigkeit"
obj["warriorStance"]			= "Krieger-Haltung"
obj["zoneName"]					= "Zonenname"
obj["zoneType"]					= "Zonenart"
 
-- Relationships.
obj["eq"]						= "ist gleich wie"
obj["ne"]						= "ist nicht gleich wie"
obj["like"]						= "ist wie"
obj["unlike"]					= "ist nicht wie"
obj["lt"]						= "ist kleiner als"
obj["gt"]						= "ist größer als"
 
-- Affiliations.
obj["affiliationMine"]			= "Mein"
obj["affiliationParty"]			= "Gruppenmitglied"
obj["affiliationRaid"]			= "Schlachtzugsmitglied"
obj["affiliationOutsider"]		= "Außenstehender"
obj["affiliationTarget"]		= "Ziel"
obj["affiliationFocus"]			= "Fokus"
obj["affiliationYou"]			= "Du"

-- Reactions.
obj["reactionFriendly"]			= "Freundlich"
obj["reactionNeutral"]			= "Neutral"
obj["reactionHostile"]			= "Feindlich"

-- Control types.
obj["controlServer"]			= "Server"
obj["controlHuman"]				= "Mensch"

-- Unit types.
obj["unitTypePlayer"]			= "Spieler"
obj["unitTypeNPC"]				= "NPC"
obj["unitTypePet"]				= "Begleiter"
obj["unitTypeGuardian"]			= "Wächter"
obj["unitTypeObject"]			= "Objekt"

-- Aura types.
obj["auraTypeBuff"]				= "Buff"
obj["auraTypeDebuff"]			= "Debuff"

-- Zone types.
obj["zoneTypeArena"]			= "Arena"
obj["zoneTypePvP"]				= "Schlachtfeld"
obj["zoneTypeParty"]			= "5-Mann Instanz"
obj["zoneTypeRaid"]				= "Schlachtzug-Instanz"

-- Booleans
obj["booleanTrue"]				= "Richtig"
obj["booleanFalse"]				= "Falsch"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "Kein"
obj[2] = "Dünn"
obj[3] = "Dick"
obj[4] = "Monochrom"
obj[5] = "Monochrom + Dünn"
obj[6] = "Monochrom + Dick"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "Links"
obj[2] = "Zentriert"
obj[3] = "Rechts"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT Wenig Mana"
obj["MSBT Low Health"]	= "MSBT Wenig Gesundheit"
obj["MSBT Cooldown"]	= "MSBT Abklingzeit"

------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "Gewinkelt"
obj["Horizontal"]	= "Horizontale"
obj["Parabola"]		= "Parabel"
obj["Straight"]		= "Gerade"
obj["Static"]		= "Statisch"
obj["Pow"]			= "Pow"

-- Animation style directions.
obj["Alternate"]	= "Alternativ"
obj["Left"]			= "Links"
obj["Right"]		= "Rechts"
obj["Up"]			= "Aufwärts"
obj["Down"]			= "Abwärts"

-- Animation style behaviors.
obj["AngleUp"]		= "Winkel aufwärts"
obj["AngleDown"]	= "Winkel abwärts"
obj["GrowUp"]		= "Wachsen aufwärts"
obj["GrowDown"]		= "Wachsen abwärts"
obj["CurvedLeft"]	= "Gerundet Links"
obj["CurvedRight"]	= "Gerundet Rechts"
obj["Jiggle"]		= "Rütteln"
obj["Normal"]		= "Normal"