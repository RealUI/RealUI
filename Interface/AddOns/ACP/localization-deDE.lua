if not ACP then return end


--@non-debug@

if (GetLocale() == "deDE") then
	ACP:UpdateLocale(

{
	["ACP: Some protected addons aren't loaded. Reload now?"] = "ACP: Einige geschützte Addons sind nicht geladen. Jetzt neu laden?",
	["Active Embeds"] = "Aktive Embeds",
	AddOns = "AddOns",
	["Addon <%s> not valid"] = "Addon <%s> ungültig",
	["Addons [%s] Loaded."] = "Addons [%s] geladen.",
	["Addons [%s] renamed to [%s]."] = "Addons [%s] umbenannt zu [%s].",
	["Addons [%s] Saved."] = "Addons [%s] gespeichert.",
	["Addons [%s] Unloaded."] = "Addons [%s] entladen.",
	["Add to current selection"] = "Zur aktuellen Auswahl hinzufügen",
	Author = "Autor",
	Blizzard_AchievementUI = "Blizzard: Achievement",
	Blizzard_AuctionUI = "Blizzard: Auction",
	Blizzard_BarbershopUI = "Blizzard: Barbershop",
	Blizzard_BattlefieldMinimap = "Blizzard: Battlefield Minimap",
	Blizzard_BindingUI = "Blizzard: Binding",
	Blizzard_Calendar = "Blizzard: Calendar",
	Blizzard_CombatLog = "Blizzard: Combat Log",
	Blizzard_CombatText = "Blizzard: Combat Text",
	Blizzard_FeedbackUI = "Blizzard: Feedback",
	Blizzard_GlyphUI = "Blizzard: Glyph",
	Blizzard_GMSurveyUI = "Blizzard: GM Survey",
	Blizzard_GuildBankUI = "Blizzard: GuildBank",
	Blizzard_InspectUI = "Blizzard: Inspect",
	Blizzard_ItemSocketingUI = "Blizzard: Item Socketing",
	Blizzard_MacroUI = "Blizzard: Macro",
	Blizzard_RaidUI = "Blizzard: Raid",
	Blizzard_TalentUI = "Blizzard: Talent",
	Blizzard_TimeManager = "Blizzard: TimeManager",
	Blizzard_TokenUI = "Blizzard: Token",
	Blizzard_TradeSkillUI = "Blizzard: Trade Skill",
	Blizzard_TrainerUI = "Blizzard: Trainer",
	Blizzard_VehicleUI = "Blizzard: Vehicle",
	["Click to enable protect mode. Protected addons will not be disabled"] = "Klicken um geschützten Modus zu aktivieren. Geschützte Addons werden nicht deaktiviert",
	Close = "Schließen",
	Default = "Standard",
	Dependencies = "Abhängigkeiten",
	["Disable All"] = "Alle Aus",
	["Disabled on reloadUI"] = "Deaktiviert nach reloadUI",
	Embeds = "Embeds",
	["Enable All"] = "Alle An",
	["*** Enabling <%s> %s your UI ***"] = "*** Aktiviere <%s> %s deiner UI ***",
	["Enter the new name for [%s]:"] = "Gib den neuen Namen für [%s] ein:",
	Load = "Laden",
	["Loadable OnDemand"] = "Wird bei Bedarf geladen",
	Loaded = "Geladen",
	["Loaded on demand."] = "Geladen bei Bedarf.",
	["LoD Child Enable is now %s"] = "LoD Nachfolger Aktivierung ist nun %s .",
	["Memory Usage"] = "Speichernutzung",
	["No information available."] = "Keine Information verfügbar.",
	Recursive = "Rekursiv",
	["Recursive Enable is now %s"] = "Rekursives Aktivieren ist nun %s",
	Reload = "Neuladen",
	ReloadUI = "ReloadUI",
	["Reload your User Interface?"] = "Interface neu laden?",
	["Remove from current selection"] = "Aus der aktuellen Auswahl entfernen",
	Rename = "Umbenennen",
	Save = "Speichern",
	["Save the current addon list to [%s]?"] = "Die aktuelle Addonliste als [%s] speichern?",
	["Set "] = "Set",
	Sets = "Sets",
	Status = "Status",
	["*** Unknown Addon <%s> Required ***"] = "*** Unbekanntes Addon <%s> benötigt ***",
	["Use SHIFT to override the current enabling of dependancies behaviour."] = "Benutze SHIFT um die momentane Einstellung des Abhängigkeitsverhaltens zu überschreiben",
	Version = "Version",
	["when performing a reloadui."] = "wenn ein Reloadui ausgeführt wird.",
}


    )
end

--@end-non-debug@