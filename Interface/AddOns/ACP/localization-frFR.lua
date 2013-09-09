if not ACP then return end

--@non-debug@

if (GetLocale() == "frFR") then
	ACP:UpdateLocale(

{
	["ACP: Some protected addons aren't loaded. Reload now?"] = "ACP: Certains addons ne sont pas chargés. Recharger maintenant?",
	["Active Embeds"] = "Intégrés actifs", -- Needs review
	AddOns = "Addons",
	["Addon <%s> not valid"] = "Addon <%s> invalide",
	["Addons [%s] Loaded."] = "Addons [%s] chargés.",
	["Addons [%s] renamed to [%s]."] = "Addons [%s] renommé en [%s].",
	["Addons [%s] Saved."] = "Addons [%s] sauvés.",
	["Addons [%s] Unloaded."] = "Addons [%s] déchargés.",
	["Add to current selection"] = "Ajouter à la sélection courante",
	Author = "Auteur",
	Blizzard_AchievementUI = "Blizzard: Hauts faits",
	Blizzard_AuctionUI = "Blizzard: Hôtel des ventes",
	Blizzard_BarbershopUI = "Blizzard: Barbier",
	Blizzard_BattlefieldMinimap = "Blizzard: Minimap Champ de Bataille",
	Blizzard_BindingUI = "Blizzard: Raccourcis",
	Blizzard_Calendar = "Blizzard: Calendrier",
	Blizzard_CombatLog = "Blizzard: Log de combat",
	Blizzard_CombatText = "Blizzard: Texte de combat",
	Blizzard_FeedbackUI = "Blizzard: Commentaire",
	Blizzard_GlyphUI = "Blizzard: Glyphe",
	Blizzard_GMSurveyUI = "Blizzard: Aide MJ",
	Blizzard_GuildBankUI = "Blizzard: Banque de guilde",
	Blizzard_InspectUI = "Blizzard: Inspection",
	Blizzard_ItemSocketingUI = "Blizzard: Mise en place de gemmes",
	Blizzard_MacroUI = "Blizzard: Macro",
	Blizzard_RaidUI = "Blizzard: Raid",
	Blizzard_TalentUI = "Blizzard: Talent",
	Blizzard_TimeManager = "Blizzard: Gestion du temps",
	Blizzard_TokenUI = "Blizzard: Jeton",
	Blizzard_TradeSkillUI = "Blizzard: Profession",
	Blizzard_TrainerUI = "Blizzard: Maîtres",
	Blizzard_VehicleUI = "Blizzard: Vehicule",
	["Click to enable protect mode. Protected addons will not be disabled"] = "Cliquez pour activer le mode protégé. Les addons protégés ne seront pas désactivés",
	Close = "Fermer",
	Default = "Défaut",
	Dependencies = "Dépendances",
	["Disable All"] = "---",
	["Disabled on reloadUI"] = "Désactivé au rechargement d'interface",
	Embeds = "Intégrés",
	["Enable All"] = "+++",
	["*** Enabling <%s> %s your UI ***"] = "*** Activation <%s> %s votre UI ***",
	["Enter the new name for [%s]:"] = "Entrez le nouveau nom pour [%s]:",
	Load = "Charger ",
	["Loadable OnDemand"] = "Chargement à la demande",
	Loaded = "Chargé",
	["Loaded on demand."] = "Chargé à la demande.",
	["LoD Child Enable is now %s"] = "L'activation des enfants LoD est maintenant %s",
	["Memory Usage"] = "Utilisation de la mémoire",
	["No information available."] = "Pas d'information disponible.",
	Recursive = "Récursif",
	["Recursive Enable is now %s"] = "L'activation récursive est maintenant %s",
	Reload = "Rechargement",
	ReloadUI = "Recharger",
	["Reload your User Interface?"] = "Recharger l'interface utilisateur?",
	["Remove from current selection"] = "Enlever de la sélection courante",
	Rename = "Renommer ",
	Save = "Sauver ",
	["Save the current addon list to [%s]?"] = "Sauver la liste actuelle dans [%s]?",
	["Set "] = "Set ",
	Sets = "Sets",
	Status = "Statut",
	["*** Unknown Addon <%s> Required ***"] = "*** Addon inconnu <%s> requis ***",
	["Use SHIFT to override the current enabling of dependancies behaviour."] = "Utilisez SHIFT pour passer outre la résolution des dépendances actuellement activée.",
	Version = "Version",
	["when performing a reloadui."] = "lors d'un rechargement de l'interface.",
}


    )
end

--@end-non-debug@