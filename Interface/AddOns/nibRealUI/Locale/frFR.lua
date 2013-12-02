local L = LibStub("AceLocale-3.0"):NewLocale("nibRealUI", "frFR")

if L then

L["Enabled"] = "Activ\195\169"
L["Type /realui"] = "Taper %s Pour configurer l'interface."
L["Combat Lockdown"] = "Combat Lockdown"
L["Layout will change after you leave combat."] = "La dosposition changera d\195\168s la sortie du combat."
L["Info Line currency tracking will update after UI Reload (/rl)"] = "Le suivi des monnaies dans la barre d'info sera mis à jour après le rechargement de l'UI (/rl)"

-- Installation
L["INSTALL"] = "CLIQUEZ POUR INSTALLER"

L["RealUI Mini Patch"] = "Mini Patch RealUI"
L["RealUI's settings have been updated."] = "Les param\195\168tres de RealUI ont \195\169t\195\169 mis \195\160 jour."
L["Do you wish to apply the latest RealUI settings?"] = "Voulez-vous appliquer les derniers param\195\168tres RealUI ?"

L["Confirm reset RealUI?\n\nAll user settings will be lost."] = "Etes-vous sur de vouloir reinitialiser RealUI ?\n\nTous les parametres personnels seront perdus."
L["Reload UI now to apply these changes?"] = "Recharger l'IU maintenant pour appliquer les changements ?"
L["You need to Reload the UI for changes to take effect. Reload Now?"] = "Vous devez recharger l'IU maintenant pour appliquer les changements. Recharger maintenant?"

-- Power Mode
L["PowerModeEconomy"] =
[[|cff0099ffRealUI|r|cffffffff: mode Economie active.
Ce mode effectuera des mises \195\160 jour graphiques \195\160 une cadence inf\195\169rieure \195\160 la normale.
Peut aider a am\195\169liorer les performances sur des PC manquant de puissance.]]

L["PowerModeNormal"] =
[[|cff0099ffRealUI|r|cffffffff: Mode Normal active.
Ce mode effectuera des mises \195\160 jour graphiques \195\160 une cadence normale.]]

L["PowerModeTurbo"] =
[[|cff0099ffRealUI|r|cffffffff: Mode Turbo active.
Ce mode effectuera des mises \195\160 jour graphiques \195\160 une cadence rapide, rendant les animations plus fluide.
Ce mode augmente la charge CPU.]]

-- RealUI Config
L["RealUI Config"] = "Configuration RealUI"
L["Position"] = "Position"
L["Positions"] = "Positions"
L["Vertical"] = "Vertical"
L["Horizontal"] = "Horizontal"
L["Width"] = "Largeur"
L["Height"] = "Hauteur"

L["AddOn Control"] = "Contr\195\180le des AddOns"

L["Untick"] = "D\195\169cocher"
L["Use"] = "Utiliser"	-- i.e Use General Colors
L["to set"] = " : utilise des"
L["custom colors"] = "couleurs personnelles"

L["Fonts"] = "Fonts"
L["Chat Font Outline"] = "Chat Font Outline"
L["FS:Hybrid"] = "Hybride"	-- Mixed
L["Use small fonts"] = "Utilise de petites polices"
L["Use a mix of small and large fonts"] = "Utiliser un m\195\169lange de petites et grandes polices."
L["Use large fonts"] = "Utilise de grandes polices"

L["Latency"] = "Latence"
L["Info Line"] = "Ligne d'info"
L["Bars"] = "Barres"	-- Class Color Health "Bars"

L["Link Layouts"] = "Lier les confs"
L["Use same settings between DPS/Tank and Healing layouts."] = "Utilise les m\195\170mes param\195\168tres entre DPS/Tank et Soigneur."
L["Use Large HuD"] = "Use Large HuD"
L["Increases size of key HuD elements (Unit Frames, etc)."] = "Augmente la taille des élément clés du HuD (cadres d'unit\195\169, etc)."
L["Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."] = "Changer la taille du HuD modifiera la taille de plusieurs \195\169l\195\169ments, en cons\195\169quence il est recommand\195\169 de v\195\169rifier les positions de \195\169l\195\169ments de l'UI une fois le changement de taille efffectu\195\169."

L["RealUI Control"] = "Contr\195\180le RealUI"
L["Allow RealUI to control the action bars."] = "Autoriser RealUI a contr\195\180ler les barres d'actions."
L["Check to allow RealUI to control the Stance Bar's position."] = "Cocher pour autoriser RealUI \195\160 contr\195\180ler la position de la barre de postures."
L["Check to allow RealUI to control the Pet Bar's position."] = "Cocher pour autoriser RealUI \195\160 contr\195\180ler la position de la barre de mascottes."
L["Check to allow RealUI to control the Extra Action Button's position."] = "Cocher pour autoriser RealUI \195\160 contr\195\180ler la position de l'extra bouton."
L["Move Stance Bar"] = "Bouger barre de postures"
L["Move Pet Bar"] = "Bouger barre de mascottes"
L["Move Extra Button"] = "Bouger extra bouton"
L["Sizes"] = "Tailles"
L["Buttons"] = "Bouttons"
L["Padding"] = "Espacement"
L["Center"] = "Centre"
L["Bottom"] = "Bas"
L["Left"] = "Gauche"
L["Right"] = "Droite"
L["Stance Bar"] = "Barre de Postures"
L["Pet Bar"] = "Mascottes"

L["Cannot open RealUI Configuration while in combat."] = "Impossible d'ouvrir la fen\195\170tre de configuration de RealUI en combat."
L["Note: Bartender settings"] = "Note: Utiliser Avanc\195\169 R\195\168glages pour ouvrir la fen\195\170tre de configuration de Bartender.\n          D\195\169cocher l'option |cff30d0ffRealUI Control|r pour changer les param\195\168tres contr\195\180l\195\169\n          par RealUI (position, taille, bouttons, Espacement)."
L["Hint: Hold down Ctrl to view action bars."] = "Suggestion: Maintenez Ctrl enfoncer pour visualiser les barres d'actions."
L["Note: After changing bar positions..."] = "Note: Apr\195\168s modification des param\195\168tres, verifiez les options de Positions\n          pour s'assurer qu'aucun \195\169l\195\169ment n'est en collision avec un autre."

L["Allow RealUI to control STR position settings."] = "RealUI contr\195\180le la position de %s."
L["Layout"] = "Disposition"
L["Allow RealUI to control STR layout settings."] = "RealUI contr\195\180le la configuration de %s."
L["Style"] = "Style"
L["Allow RealUI to style STR."] = "RealUI contr\195\180le le style de %s (necessite un /reload)"

L["Horizontal Groups"] = "Groupes Horizontaux"
L["Show Pet Frames"] = "Show Pet Frames"
L["Show While Solo"] = "Show While Solo"
L["Note: Grid2 settings"] = "Note: Utiliser Avanc\195\169s R\195\169glages pour acc\195\169der \195\160 la configuration de Grid2.\n          D\195\169cocher l'option |cff30d0ffRealUI Control|r pour changer les param\195\168tres contr\195\180l\195\169s\n          par RealUI (position, taille, bouttons, Espacement)."

L["Element Settings"] = "Param\195\168tres des \195\169l\195\169ments"
L["Choose UI element to configure."] = "Choisissez l'\195\169l\195\169ment d'interface \195\160 configurer."
L["(use mouse-wheel for precision adjustment of sliders)"] = "(Utiliser la molette pour ajuster la valeur avec pr\195\169cision)"

L["Reverse Bar"] = "Barre Invers\195\169e"
L["Reverse the direction of the cast bar."] = "Inverse la direction de la barre de lancement de sort."

L["Create New Tracker"] = "Cr\195\169er nouveau Tracker"
L["Disable Selected Tracker"] = "Disable Selected Tracker"
L["Enable Selected Tracker"] = "Enable Selected Tracker"
L["Are you sure you wish to reset Tracking information to defaults?"] = "Voulez-vous vraiment r\195\169initialiser les informations de suivi?"
L["Tracker Options"] = "Options du Tracker"
L["Choose Tracker type."] = "S\195\169lectionner le type de Tracker."
L["Buff"] = "Buff"
L["Debuff"] = "Debuff"
L["Spell Name or ID"] = "Nom du sort ou ID"
L["Note: Spell Name or ID must match the spell you wish to track exactly. Capitalization and spaces matter."] = "Note: Le nom du sort or l'ID doivent correspondre exactement au sort que vous souhaitez suivre. La casse et les espaces sont importants."
L["Static"] = "Statique"
L["Static Trackers remain visible and in the same location."] = "Les Trackers statiques restent visible et \195\160 la m\195\170me place."
L["Min Level (0 = ignore)"] = "Niveau Min (0 = ignore)"
L["Ignore Spec"] = "Ignore Spec"
L["Show tracker regardless of current specialization"] = "Show tracker regardless of current specialization"
L["Cat"] = "Chat"
L["Bear"] = "Ours"
L["Moonkin"] = "Chouettard"
L["Human"] = "Humain"
L["Hide Out-Of-Combat"] = "Cacher hors combat"
L["Force this Tracker to hide OOC, even if it's active."] = "Force ce Tracker \195\160 \195\170tre cacher hors combat m\195\170me s'il est actif."
L["Hide Stack Count"] = "Cacher le compteur"
L["Don't show Buff/Debuff stack count on this tracker."] = "Ne montre pas les stack de Buff/Debuff sur ce tracker."

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
L["XP/Rep"] = "XP/Rep"
L["SysInfo"] = "SysInfo"
L["Spec Changer"] = "S\195\169lecteur de Specialisation"
L["Layout Changer"] = "S\195\169lecteur de Disposition"
L["Meter Toggle"] = "Compteurs"

L["Menu"] = "Menu"

L["Meters"] = "Compteurs"

L["Stat"] = "Stat"
L["Cur"] = "Cur"
L["Max"] = "Max"
L["Min"] = "Min"
L["Avg"] = "Moy"

L["In"] = "In"
L["Out"] = "Out"
L["kbps"] = "kbps"
L["ms"] = "ms"
L["FPS"] = "IPS"

L["Date"] = "Date"
L["Wintergrasp Time Left"] = "Temps Restant - Joug-d'Hiver:"
L["No Wintergrasp Time Available"] = "Pas de temps pour le Joug-d'Hiver"
L["Tol Barad Time Left"] = "Temps Restant - Tol Barad:"
L["No Tol Barad Time Available"] = "Pas de temps restant pour Tol Barad"
L["Pending Invites:"] = "Invitation en attente:"

L["Layout Changer"] = "S\195\169lecteur de Disposition"
L["Current Layout:"] = "Disposition courante:"
L["DPS/Tank"] = "DPS/Tank"
L["Healing"] = "Soigneur"

L["Meter Toggle"] = "Compteurs"
L["Active Meters:"] = "Compteurs actifs:"

L["Start"] = "D\195\169but"

L["Current"] = "Courant"
L["Remaining"] = "Restant"

L["Honor Points"] = "HP"
L["Conquest Points"] = "CP"
L["Justice Points"] = "JP"
L["Valor Points"] = "VP"
L["Updated"] = "Upd."
L["To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"] = "To track additional currencies, use the Currency tab in the Player Frame and set desired Currency to 'Show On Backpack'"

L["Faction not set"] = "Faction non precis\195\169e"

L["<Click> to switch between"] = "<Click> pour changer"
L["XP and Rep display."] = "Affichage XP et Rep."
L["<Click> to switch currency displayed."] = "<Click> pour changer la monnaie affich\195\169e."
L["<Alt+Click> to erase highlighted character data."] = "<Alt+Click> pour effacer les donn\195\169es du personnage surlign\195\169."
L["<Shift+Click> to reset weekly caps."] = "<Shift+Click> pour remettre \195\160 z\195\169ro les cumuls hebdomadaires."
L["Note: Weekly caps will reset upon loading currency data"] = "Note: Les cumuls hebdomadaires seront mis \195\160 z\195\169ro au chargement des informations de devise"
L["on a character whose weekly caps have reset."] = "pour un personnage dont les cumuls hebdomadaires ont \195\169t\195\169 remis \195\160 zero."
L["<Click> to whisper, <Alt+Click> to invite."] = "<Click> pour Chuchoter, <Alt+Click> Pour Inviter."

L["Stat Display"] = "Affichage Stats"
L["<Spec Click> to change talent specs."] = "<Click Spec> pour changer de spec."
L["<Equip Click> to equip."] = "<Click Equip> pour changer d'\195\169quipement."
L["<Equip Ctl+Click> to assign to "] = "<Ctl+Click Equip> pour assigner a "
L["<Equip Alt+Click> to assign to "] = "<Alt+Click Equip> pour assigner a "
L["<Equip Shift+Click> to unassign."] = "<Shift+Click Equip> pour d\195\169sassigner."
L["<Stat Click> to configure."] = "<Click Stat> pour configurer."

L["<Click> to cycle through equipment sets."] = "<Click> pour faire une rotation parmis les \195\169quimements."
L["<Click> to show calendar."] = "<Click> pour afficher le calendrier."
L["<Shift+Click> to show timer."] = "<Shift+Click> pour afficher l'horloge."
L["<Click> to change layouts."] = "<Click> pour changer la disposition."
L["<Alt+Click> to change resolution."] = "<Alt+Click> pour changer la r\195\169solution."
L["<Click> to toggle meters."] = "<Click> pour changer le compteur."

-- HuD Config
L["Instructions"] = "Instructions"
L["Load Defaults"] = "Charger D\195\169faut"
L["Show UI Elements"] = "Montrer les \195\169l\195\169ments"
L["Hide UI Elements"] = "Masquer les \195\169l\195\169ments"
L["HuD Instructions"] = [[
		|cffffa500Step 1:|r Cliquer |cff30ff30Montrer les elements|r pour vous aider a repositionner les elements de l'interface.
		|cffffa500Step 2:|r Utiliser la fenetre |cff30ff30Parametres des elements|r pour positionner chaque element.
		|cffffa500Step 3:|r Une fois terminer, cliquer |cff30ff30OK|r pour fermer l'ecran de configuration.
	]]

-- World Boss Info
L["Galleon"]="Galleon"
L["Sha Of Anger"]="Sha de la Col\195\168re"
L["Nalak"]="Nalak"
L["Oondasta"]="Oondasta"
L["Celestials"]="Astres"
L["Ordos"]="Ordos"

L["World Boss Done"]="\124cff00ff00Fait\124r"
L["World Boss Not Done"]="\124cffff0000Pas Fait\124r"

end