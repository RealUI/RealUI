-------------------------------------------------------------------------------
-- Title: MSBT Options French Localization
-- Author: Mikord
-- French Translation by: Calthas, Devfool
-------------------------------------------------------------------------------

-- Don't do anything if the locale isn't French.
if (GetLocale() ~= "frFR") then return end

-- Local reference for faster access.
local L = MikSBT.translations

-------------------------------------------------------------------------------
-- French localization
-------------------------------------------------------------------------------


------------------------------
-- Interface messages
------------------------------

L.MSG_CUSTOM_FONTS					= "Polices Personnalisées"
L.MSG_INVALID_CUSTOM_FONT_NAME		= "Nom de Police incorrect."
L.MSG_FONT_NAME_ALREADY_EXISTS		= "Le nom de la Police existe déjà."
L.MSG_INVALID_CUSTOM_FONT_PATH		= "Le chemin de la Police doit pointé vers un fichier .ttf."
--L.MSG_UNABLE_TO_SET_FONT			= "Unable to set specified font." 
--L.MSG_TESTING_FONT			= "Testing the specified font for validity..."
L.MSG_CUSTOM_SOUNDS					= "Sons Personnalisés"
L.MSG_INVALID_CUSTOM_SOUND_NAME		= "Nom du Son incorrect."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "Le nom du son existe déjà."
L.MSG_NEW_PROFILE					= "Nouveau Profil"
L.MSG_PROFILE_ALREADY_EXISTS		= "Le Profil existe déjà."
L.MSG_INVALID_PROFILE_NAME			= "Nom de profil invalide."
L.MSG_NEW_SCROLL_AREA				= "Nouveau zone de défilement"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "Une zone de défilement portant ce nom existe déjà."
L.MSG_INVALID_SCROLL_AREA_NAME		= "Nom de zone de défilement invalide."
L.MSG_ACKNOWLEDGE_TEXT				= "Etes-vous certain de vouloir effectuer cette action?"
L.MSG_NORMAL_PREVIEW_TEXT			= "Normal"
L.MSG_INVALID_SOUND_FILE			= "Le fichier son doit être au format .ogg."
L.MSG_NEW_TRIGGER					= "Nouveau déclencheur"
L.MSG_TRIGGER_CLASSES				= "Classes du déclencheur"
L.MSG_MAIN_EVENTS					= "Evènements principaux"
L.MSG_TRIGGER_EXCEPTIONS			= "Exceptions du déclenchement"
L.MSG_EVENT_CONDITIONS				= "Conditions de l'évènement"
L.MSG_DISPLAY_QUALITY				= "Afficher une alerte pour les items de cette qualité."
L.MSG_SKILLS						= "Compétences"
L.MSG_SKILL_ALREADY_EXISTS			= "Cette compétence existe déjà."
L.MSG_INVALID_SKILL_NAME			= "Nom de compétence invalide."
L.MSG_HOSTILE						= "Hostile"
L.MSG_ANY							= "Tous"
L.MSG_CONDITION						= "Condition"
L.MSG_CONDITIONS					= "Conditions"
L.MSG_ITEM_QUALITIES				= "Qualité des Items"
L.MSG_ITEMS							= "Items"
L.MSG_ITEM_ALREADY_EXISTS			= "Le nom de l'item existe déjà."
L.MSG_INVALID_ITEM_NAME				= "Nom de l'item incorrect."


------------------------------
-- Interface tabs
------------------------------

obj = L.TABS
obj["customMedia"]	= { label="Média Personnalisé", tooltip="Affiche les options pour gérer les médias personnalisés."}
obj["general"]		= { label="Général", tooltip="Affiche les options générales."}
obj["scrollAreas"]	= { label="Zones de défilement", tooltip="Affiche les options de création, suppression et configuration des zones de défilement.\n\nPassez votre souris sur les icônes pour plus d'informations."}
obj["events"]		= { label="Evènements", tooltip="Affiche les options pour les évènements entrants, sortants et de notification.\n\nPassez votre souris sur les icônes pour plus d'informations."}
obj["triggers"]		= { label="Déclencheurs", tooltip="Affiche les options du système de déclencheurs.\n\nPassez votre souris sur les icônes pour plus d'informations."}
obj["spamControl"]	= { label="Controle du Spam", tooltip="Affiche les options de contrôle du spam."}
obj["cooldowns"]	= { label="Cooldowns", tooltip="Affiche les options des notifications de cooldown."}
obj["lootAlerts"]	= { label="Alertes Loot", tooltip="Affiche les options des notifications relatives au items ramassés."}
obj["skillIcons"]	= { label="Icônes des Compétences", tooltip="Affiche les options des icônes de compétences."}


------------------------------
-- Interface checkboxes
------------------------------

obj = L.CHECKBOXES
obj["enableMSBT"]			= { label="Activer Mik's Scrolling Battle Text", tooltip="Activer MSBT."}
obj["stickyCrits"]			= { label="Critiques persistants", tooltip="Utiliser le style persistant pour les coups critiques."}
obj["enableSounds"]			= { label="Activer les sons", tooltip="Jouer les sons associés aux évènements et déclencheurs."}
obj["textShadowing"]		= { label="Ombre sur le texte", tooltip="Appliquer un effet d'ombre au texte pour améliorer le rendu de la police."}
obj["colorPartialEffects"]	= { label="Colorer les effets partiels", tooltip="Assigner des couleurs aux effets partiels."}
obj["crushing"]				= { label="Ecrasements", tooltip="Afficher les écrasements."}
obj["glancing"]				= { label="Eraflures", tooltip="Afficher les éraflures."}
obj["absorb"]				= { label="Absorptions partielles", tooltip="Afficher la valeur des absorptions partielles."}
obj["block"]				= { label="Bloquages partiels", tooltip="Afficher la valeur des bloquages partiels."}
obj["resist"]				= { label="Résistances partielles", tooltip="Afficher la valeur des résistances partielles."}
obj["vulnerability"]		= { label="Bonus de vulnérabilité", tooltip="Afficher la valeur des bonus de vulnérabilité."}
obj["overheal"]				= { label="Soins en excès", tooltip="Afficher la valeur des soins en excès."}
obj["overkill"]				= { label="Dommages en excès", tooltip="Afficher la valeur des dommages en excès."}
obj["colorDamageAmounts"]	= { label="Valeurs des dommages en couleur", tooltip="Utiliser des couleurs pour la valeur des dommages."}
obj["colorDamageEntry"]		= { tooltip="Activer la couleur pour ce type de dommage."}
obj["colorUnitNames"]		= { label="Colorer les Noms des Unités", tooltip="Aplliquer les couleurs de classe spécifiques aux noms des unités."}
obj["colorClassEntry"]		= { tooltip="Activer la couleur pour cette classe."}
obj["enableScrollArea"]		= { tooltip="Activer la zone de défilement."}
obj["inheritField"]			= { label="Hérité", tooltip="Hériter de la valeur par défaut. Désélectionner pour modifier cette valeur."}
obj["hideSkillIcons"]		= { label="Cacher les Icônes", tooltip="Ne pas montrer les icônes dans cette zone."}
obj["stickyEvent"]			= { label="Toujours Persistant", tooltip="Utiliser le style persistant pour l'évènement."}
obj["enableTrigger"]		= { tooltip="Activer le déclencheur."}
obj["allPowerGains"]		= { label="Tous les gains d'énergie", tooltip="Affiche tous les gains d'énergie même ceux qui ne sont pas affichés dans le journal ce combat.\n\nATTENTION: Cette option est source de spam et ignorera les réglages de seuil de spam et de son contrôle.\n\nNON RECOMMANDE."}
obj["abbreviateSkills"]		= { label="Compétences Abrégées", tooltip="Nom des compétences abrégées (client anglais seulement).\n\nCela peut être contourné pour chaque évènement en utilisant le code %sl."}
--obj["mergeSwings"]				= { label="Merge Swings", tooltip="Merge regular melee swings that hit within a short time span."}
--obj["shortenNumbers"]			= { label="Shorten Numbers", tooltip="Display numbers in an abbreviated format (example: 32765 -> 33k)."}
--obj["groupNumbers"]				= { label="Group By Thousands", tooltip="Display numbers grouped by thousands (example: 32765 -> 32,765)."}
obj["hideSkills"]			= { label="Cacher les Noms des Compétences", tooltip="Ne pas afficher les noms de compétences pour les évènements entrants et sortants.\n\nVous abandonnerez quelques possibilités de personnalisation de l'évènement si vous utilisez cette option car le code %s sera ignoré."}
obj["hideNames"]			= { label="Cacher les Noms des Unités", tooltip="Ne pas afficher les noms des unités pour les évènements entrants et sortants.\n\nVous abandonnerez quelques possibilités de personnalisation de l'évènement si vous utilisez cette option car le code %n sera ignoré."}
obj["hideFullOverheals"]	= { label="Cacher les Soins en Excès Total", tooltip="Ne pas afficher les soins qui ont un soin effectif égal à zéro."}
--obj["hideFullHoTOverheals"]		= { label="Hide Full HoT Overheals", tooltip="Don't display heals over time that have an effective heal amount of zero."}
--obj["hideMergeTrailer"]			= { label="Hide Merge Trailer", tooltip="Don't display the trailer that specifies the number of hits and crits at the end of merged events."}
obj["allClasses"]			= { label="Toutes les classes"}
--obj["enablePlayerCooldowns"]	= { label="Player Cooldowns", tooltip="Display notifications when your cooldowns complete."}
--obj["enablePetCooldowns"]		= { label="Pet Cooldowns", tooltip="Display notifications when your pet's cooldowns complete."}
--obj["enableItemCooldowns"]		= { label="Item Cooldowns", tooltip="Display notifications when item cooldowns complete."}
obj["lootedItems"]			= { label="Items Ramassés", tooltip="Affiche les notifications quand des items sont ramassés."}
obj["moneyGains"]			= { label="Gains d'argent", tooltip="Affiche vos gains d'argent."}
obj["alwaysShowQuestItems"]	= { label="Toujours Montrer les Items de Quête", tooltip="Toujours montrer les items de quête quelle que soit la sélection selon la qualité des items."}
obj["enableIcons"]			= { label="Activer les Icônes de Compétence", tooltip="Affiche les icônes des compétences pour les évènements quand c'est possible."}
obj["exclusiveSkills"]		= { label="Noms Exclusifs de compétence", tooltip="Montre seulement les noms de compétence quand une icône n'est pas disponible."}


------------------------------
-- Interface dropdowns
------------------------------

obj = L.DROPDOWNS
obj["profile"]				= { label="Profil actuel:", tooltip="Assigne le profil actif."}
obj["normalFont"]			= { label="Police normale:", tooltip="Assigne la police de caractères utilisée pour les coups non critiques."}
obj["critFont"]				= { label="Police critique:", tooltip="Assigne la police de caractères utilisée pour les coups critiques."}
obj["normalOutline"]		= { label="Contour normal:", tooltip="Assigne le contour utilisé pour les coups non critiques."}
obj["critOutline"]			= { label="Contour critique:", tooltip="Assigne le contour utilisé pour les coups critiques."}
obj["scrollArea"]			= { label="Zone de défilement:", tooltip="Sélectionne la zone de défilement à configurer."}
obj["sound"]				= { label="Son:", tooltip="Sélectionne le son à jouer quand un évènement intervient."}
obj["animationStyle"]		= { label="Animation normale:", tooltip="Style d'animation pour l'animation non persistante dans la zone de défilement."}
obj["stickyAnimationStyle"]	= { label="Animations persistante:", tooltip="Style d'animation pour l'animation persistante dans la zone de défilement."}
obj["direction"]			= { label="Direction:", tooltip="La direction de l'animation."}
obj["behavior"]				= { label="Comportement:", tooltip="Le comportement de l'animation."}
obj["textAlign"]			= { label="Alignement du texte:", tooltip="Alignement du texte pour l'animation."}
obj["iconAlign"]			= { label="Alignement de l'icône:", tooltip="L'alignement des icônes de compétence par rapport au texte."}
obj["eventCategory"]		= { label="Catégorie d'évènement:", tooltip="La catégorie de l'évènement à configurer."}
obj["outputScrollArea"]		= { label="Zone de défilement de sortie:", tooltip="Sélectionne la zone de défilement à utiliser."}
obj["mainEvent"]			= { label="Evènement principal:"}
obj["triggerCondition"]		= { label="Condition:", tooltip="La condition à tester."}
obj["triggerRelation"]		= { label="Relation:"}
obj["triggerParameter"]		= { label="Paramètre:"}


------------------------------
-- Interface buttons
------------------------------

obj = L.BUTTONS
obj["addCustomFont"]			= { label="Ajouter une Police", tooltip="Ajoute une police personnalisée à la liste des polices disponibles.\n\nATTENTION: Le fichier de la police doit exister *AVANT* que WoW n'est démarré.\n\nIl est fortement recommandé de placer ce fichier dans le répertoire MikScrollingBattleText\\Fonts pour éviter tout problème."}
obj["addCustomSound"]			= { label="Ajouter un Son", tooltip="Ajoute un son personnalisé à la liste des sons disponibles.\n\nATTENTION: Le fichier son doit exister *AVANT* que WoW n'est démarré.\n\nIl est fortement recommandé de placer ce fichier dans le répertoire MikScrollingBattleText\\Sounds pour éviter tout problème."}
obj["editCustomFont"]			= { tooltip="Cliquer pour éditer la police personnalisée."}
obj["deleteCustomFont"]			= { tooltip="Cliquer pour enlever la police personnalisée de MSBT."}
obj["editCustomSound"]			= { tooltip="Cliquer pour éditer le son personnalisé."}
obj["deleteCustomSound"]		= { tooltip="Cliquer pour enlever le son personnalisé de MSBT."}
obj["copyProfile"]				= { label="Copier", tooltip="Copie le profil sous un nouveau nom."}
obj["resetProfile"]				= { label="Réinitialiser", tooltip="Réinitialise le profil avec les paramètres par défaut."}
obj["deleteProfile"]			= { label="Supprimer", tooltip="Supprime le profil."}
obj["masterFont"]				= { label="Police principale", tooltip="Paramètres des polices principales, hérités par les zones de défilement et les évènements associées avec elles, à moins qu'ils ne soient dépassés par les réglages individuels."}
obj["partialEffects"]			= { label="Effets partiels", tooltip="Détermine les effets partiels affichés et les paramètres de couleurs."}
obj["damageColors"]				= { label="Couleurs des Dommages", tooltip="Vous permet de paramétrer les couleurs assignées aux valeurs des dommages suivant leur type."}
obj["classColors"]				= { label="Couleurs des Classes", tooltip="Vous permet de définir si les noms d'unités sont colorées ou non selon leur classe et quelle couleur utiliser pour chaque classe." }
obj["inputOkay"]				= { label="OK", tooltip="Accepte la saisie."}
obj["inputCancel"]				= { label="Annuler", tooltip="Annule la saisie."}
obj["genericSave"]				= { label="Enregistrer", tooltip="Enregistre les modifications."}
obj["genericCancel"]			= { label="Annuler", tooltip="Annule les modifications."}
obj["addScrollArea"]			= { label="Ajouter une zone", tooltip="Ajoute une zone de défilement à laquelle des déclencheurs et évènements peuvent être assignés."}
obj["configScrollAreas"]		= { label="Configurer les zones", tooltip="Permet de configurer les styles d'animation normales et persistantes, l'alignement du texte, la largeur/hauteur de la zone de défilement et leur emplacement."}
obj["editScrollAreaName"]		= { tooltip="Cliquer pour modifier le nom de la zone de défilement."}
obj["scrollAreaFontSettings"]	= { tooltip="Cliquer pour modifier les paramètres de police pour la zone de défilement. Ces paramètres seront utilisés par tous les évènements de cette zone à moins qu'ils ne soient dépassés par les réglages individuels."}
obj["deleteScrollArea"]			= { tooltip="Cliquer pour supprimer la zone de défilement."}
obj["scrollAreasPreview"]		= { label="Aperçu", tooltip="Prévisualiser les modifications."}
obj["toggleAll"]				= { label="Changer Tout", tooltip="Modifie l'état des évènements dans la catégorie sélectionnée."}
obj["moveAll"]					= { label="Déplacer Tout", tooltip="Déplace tous les évènements dans la catégorie sélectionnée vers la zone de défilement spécifiée."}
obj["eventFontSettings"]		= { tooltip="Cliquer pour éditer les paramètres de police de l'évènement."}
obj["eventSettings"]			= { tooltip="Cliquer pour éditer les paramètres de l'évènement comme la zone de défilement, message, sonore, etc."}
obj["customSound"]				= { tooltip="Cliquer pour saisir un fichier son personnalisé." }
obj["playSound"]				= { label="Jouer", tooltip="Cliquer pour jouer le son."}
obj["addTrigger"]				= { label="Ajouter un déclencheur", tooltip="Ajoute un nouveau déclencheur."}
obj["triggerSettings"]			= { tooltip="Cliquer pour configurer les conditions du déclencheur."}
obj["deleteTrigger"]			= { tooltip="Cliquer pour supprimer ce déclencheur."}
obj["editTriggerClasses"]		= { tooltip="Cliquer pour déterminer à quelles classes le déclencheur s'applique."}
obj["addMainEvent"]				= { label="Ajouter un évènement", tooltip="Quand n'importe lequel de ces évènements survient et que leurs conditions définies sont vraies, le déclencheur s'activera à moins qu'une des exceptions spécifiées soient vraies."}
obj["addTriggerException"]		= { label="Ajouter une exception", tooltip="Quand n'importe laquelle de ces exceptions est vraie, le déclencheur ne s'activera pas."}
obj["editEventConditions"]		= { tooltip="Cliquer pour éditer les conditions de l'évènement."}
obj["deleteMainEvent"]			= { tooltip="Cliquer pour supprimer l'évènement."}
obj["addEventCondition"]		= { label="Ajouter une condition", tooltip="Quand TOUTES les conditions sont vraies pour l'évènement sélectionné, le déclencheur s'activera à moins qu'une des exceptions spécifiées soit vraie."}
obj["editCondition"]			= { tooltip="Cliquer pour éditer la condition."}
obj["deleteCondition"]			= { tooltip="Cliquer pour supprimer la condition."}
obj["throttleList"]				= { label="Commande de puissance", tooltip="Définit des durées personnalisées pour les compétences spécifiées."}
obj["mergeExclusions"]			= { label="Exclusions de la fusion", tooltip="Définit la liste des compétences qui ne seront pas fusionnées."}
obj["skillSuppressions"]		= { label="Compétences supprimées", tooltip="Supprime des compétences en fonction de leur nom."}
obj["skillSubstitutions"]		= { label="Compétences substituées", tooltip="Substitue les nom des compétences avec des valeurs personnalisées."}
obj["addSkill"]					= { label="Ajouter une compétence", tooltip="Ajoute une nouvelle compétence à la liste."}
obj["deleteSkill"]				= { tooltip="Cliquer pour supprimer cette compétence."}
obj["cooldownExclusions"]		= { label="Exclusions de la liste des cooldowns", tooltip="Spécifie les compétences pour lesquelles le cooldown sera ignoré."}
obj["itemsAllowed"]				= { label="Items Autorisés", tooltip="Toujours montrer les items spécifiés quelle que soit leur qualité."}
obj["itemExclusions"]			= { label="Item Interdit", tooltip="Empêche d'afficher les items spécifiés."}
obj["addItem"]					= { label="Ajouter un Item", tooltip="Ajoute un nouvel item à la liste."}
obj["deleteItem"]				= { tooltip="Cliquer pour supprimer l'item."}


------------------------------
-- Interface editboxes
------------------------------

obj = L.EDITBOXES
obj["customFontName"]	= { label="Nom de la Police:", tooltip="Le nom utilisé pour identifier la police.\n\nExemple: Ma Super Police"}
obj["customFontPath"]	= { label="Chemin de la police:", tooltip="Le chemin du fichier de la police.\n\nNOTE: Si le fichier est situé dans le répertoire recommandé MikScrollingBattleText\\Fonts, seul le nom de fichier doit être entré ici, au lieu du chemin complet.\n\nExemple: maPolice.ttf"}
obj["customSoundName"]	= { label="Nom du Son:", tooltip="Le nom utilisé pour identifier le son.\n\nExemple: Mon Son"}
obj["customSoundPath"]	= { label="Chemin du Son:", tooltip="Le chemin qui pointe vers le fichier du son.\n\nNOTE: Si le fichier est situé dans le répertoire rcommandé MikScrollingBattleText\\Sounds, seul le nom de fichier doit être entré ici, au lieu du chemin complet.\n\nExemple: monSon.ogg"}
obj["copyProfile"]		= { label="Nom du nouveau profil:", tooltip="Nom du nouveau profil vers lequel copier le profil courant."}
--obj["partialEffect"]	= { tooltip="The trailer that will be appended when the partial effect occurs."}
obj["scrollAreaName"]	= { label="Nouveau nom pour la zone de défilement:", tooltip="Nouveau nom pour la zone de défilement."}
obj["xOffset"]			= { label="Décalage X:", tooltip="Le décalage horizontal de la zone de défilement."}
obj["yOffset"]			= { label="Décalage Y:", tooltip="Le décalage vertical de la zone de défilement."}
obj["eventMessage"]		= { label="Message affiché:", tooltip="Le message affiché quand l'évènement intervient."}
obj["soundFile"]		= { label="Nom du fichier son:", tooltip="le nom du fichier son à joueur quand l'évènement intervient."}
obj["iconSkill"]		= { label="Icône de la compétence:", tooltip="Le nom ou le numéro d'ID d'une compétence dont l'icône sera affichée quand l'évènement survient.\n\nMSBT essayera automatiquement d'afficher une icône appropriée si aucune n'est spécifiée.\n\nNOTE: une numéro d'ID doit être utilisé à la place du nom si la compétence n'est pas dans le livre de sort de la classe jouée quand l'évènement survient. La plupart des bases de données en ligne comme wowhead permettent de rechercher cette ID."}
obj["skillName"]		= { label="Nom de la compétence:", tooltip="Le nom de la compétence à ajouter."}
obj["substitutionText"]	= { label="Texte de substitution:", tooltip="Le texte à substituer pour le nom de la compétence."}
obj["itemName"]			= { label="Nom de l'item:", tooltip="Le nom de l'item à ajouter."}


------------------------------
-- Interface sliders
------------------------------

obj = L.SLIDERS
obj["animationSpeed"]		= { label="Vitesse d'animation", tooltip="Définit la vitesse maître de l'animation.\n\nChaque zone de défilement peut être configurée pour avoir sa propre vitesse d'animation."}
obj["normalFontSize"]		= { label="Taille normale", tooltip="Définit la taille de la police pour les coups non critiques."}
obj["normalFontOpacity"]	= { label="Opacité normale", tooltip="Définit l'opacité de la police pour les coups non critiques."}
obj["critFontSize"]			= { label="Taille critique", tooltip="Définit la taille de la police pour les coups critiques."}
obj["critFontOpacity"]		= { label="Opacité critique", tooltip="Définit l'opacité de la police pour les coups critiques."}
obj["scrollHeight"]			= { label="Hauteur de défilement", tooltip="La hauteur de la zone de défilement."}
obj["scrollWidth"]			= { label="Largeur de défilement", tooltip="La largeur de la zone de défilement."}
obj["scrollAnimationSpeed"]	= { label="Vitesse d'animation", tooltip="La vitesse de l'animation pour la zone de défilement."}
obj["powerThreshold"]		= { label="Seuil de l'énergie", tooltip="Le seuil que les gains d'énergie doivent dépasser pour être affichés."}
obj["healThreshold"]		= { label="Seuil des soins", tooltip="Le seuil que les soins doivent dépasser pour être affichés."}
obj["damageThreshold"]		= { label="Seuil des dommages", tooltip="Le seuil que les dommages doivent dépasser pour être affichés."}
obj["dotThrottleTime"]		= { label="Temps de spam des DoT", tooltip="Le nombre de secondes à prendre en compte pour afficher les DoT."}
obj["hotThrottleTime"]		= { label="Temps de spam des HoT", tooltip="Le nombre de secondes à prendre en compte pour afficher les HoT."}
obj["powerThrottleTime"]	= { label="Temps de spam des Gains", tooltip="Le nombre de secondes à prendre en compte pour afficher les gains de puissance."}
obj["skillThrottleTime"]	= { label="Contrôle du temps", tooltip="Le nombre de secondes à prendre en compte pour afficher la compétence."}
obj["cooldownThreshold"]	= { label="Contrôle du cooldown", tooltip="Les compétences avec un cooldown inférieur au nombre de secondes spécifié ne seront pas affichées."}


------------------------------
-- Event categories
------------------------------
obj = L.EVENT_CATEGORIES
obj[1] = "Entrant player"
obj[2] = "Entrant familier"
obj[3] = "Sortant player"
obj[4] = "Sortant familier"
obj[5] = "Alertes"


------------------------------
-- Event codes
------------------------------

obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - Quantité de dommages.\n"
obj["HEALING_TAKEN"]		= "%a - Quantité de soins reçus.\n"
obj["DAMAGE_DONE"]			= "%a - Dommages infligés.\n"
obj["HEALING_DONE"]			= "%a - Quantité de soins.\n"
obj["ABSORBED_AMOUNT"]		= "%a - Quantité de dommages absorbés.\n"
obj["AURA_AMOUNT"]			= "%a - Nombre de la pile pour cet aura.\n"
obj["ENERGY_AMOUNT"]		= "%a - Quantité de pouvoir.\n"
--obj["CHI_AMOUNT"]			= "%a - Amount of chi you have.\n"
obj["CP_AMOUNT"]			= "%a - Nombre de points de combo.\n"
obj["HOLY_POWER_AMOUNT"]	= "%a - Amount of holy power you have.\n"
--obj["SHADOW_ORBS_AMOUNT"]	= "%a - Amount of shadow orbs you have.\n"
obj["HONOR_AMOUNT"]			= "%a - Quantité d'honneur.\n"
obj["REP_AMOUNT"]			= "%a - Quantité de réputation.\n"
obj["ITEM_AMOUNT"]			= "%a - Quantité de l'item ramassé.\n"
obj["SKILL_AMOUNT"]			= "%a - Nouveau niveau dans la compétence.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - Quantité d'expérience.\n"
obj["PARTIAL_AMOUNT"]		= "%a - Quantité de l'effet partiel.\n"
obj["ATTACKER_NAME"]		= "%n - Nom de l'attaquant.\n"
obj["HEALER_NAME"]			= "%n - Nom du soigneur.\n"
obj["ATTACKED_NAME"]		= "%n - Nom de l'unité attaquée.\n"
obj["HEALED_NAME"]			= "%n - Nom de l'unité soignée.\n"
obj["BUFFED_NAME"]			= "%n - Nom de l'unité.\n"
obj["UNIT_KILLED"]			= "%n - Nom de l'unité tuée.\n"
obj["SKILL_NAME"]			= "%s - Nom de la compétence.\n"
obj["SPELL_NAME"]			= "%s - Nom du sort.\n"
obj["DEBUFF_NAME"]			= "%s - Nom du debuff.\n"
obj["BUFF_NAME"]			= "%s - Nom du buff.\n"
obj["ITEM_BUFF_NAME"]		= "%s - Nom du buff d'objet.\n"
obj["EXTRA_ATTACKS"]		= "%s - Attaque supplémentaire.\n"
obj["SKILL_LONG"]			= "%sl - Forme longue de %s. Utilisé pour outrepasser l'abrévation pour cet évènement.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - Type de dommages.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - Type de dommages faits.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - Nom de la source de dommages (chute, noyade, lave, etc...)\n"
obj["FACTION_NAME"]			= "%e - Faction.\n"
obj["EMOTE_TEXT"]			= "%e - Le texte de l'emote.\n"
obj["MONEY_TEXT"]			= "%e - Le texte de l'argent gagné.\n"
obj["COOLDOWN_NAME"]		= "%e - Le nom de la compétence qui est prête.\n"
--obj["ITEM_COOLDOWN_NAME"]	= "%e - The name of item that is ready.\n"
obj["ITEM_NAME"]			= "%e - Le nom de l'item ramassé.\n"
obj["POWER_TYPE"]			= "%p - Type de pouvoir (énergie, rage, mana).\n"
obj["TOTAL_ITEMS"]			= "%t - Nombre total de l'item ramassé dans l'inventaire."


------------------------------
-- Incoming events
------------------------------

obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="Mêlées", tooltip="Afficher les dommages des attaques de mêlée."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="Mêlées critiques", tooltip="Afficher les dommages des attaques critiques de mêlée."}
obj["INCOMING_MISS"]						= { label="Manques de mêlée", tooltip="Afficher les attaques de mêlée manquées."}
obj["INCOMING_DODGE"]						= { label="Esquives de mêlée", tooltip="Afficher les attaques de mêlée esquivées."}
obj["INCOMING_PARRY"]						= { label="Parades de mêlée", tooltip="Afficher les attaques de mêlée parées."}
obj["INCOMING_BLOCK"]						= { label="Blocages de mêlée", tooltip="Afficher les dommages en mêlée bloquées."}
--obj["INCOMING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable incoming melee deflects."}
obj["INCOMING_ABSORB"]						= { label="Absorptions de mêlée", tooltip="Afficher les dommages en mêlée absorbés."}
obj["INCOMING_IMMUNE"]						= { label="Immunités de mêlée", tooltip="Afficher les attaques de mêlée auxquelles vous êtes immunisé."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="Compétences", tooltip="Afficher les dommages des compétences."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Compétences critiques", tooltip="Afficher les dommages des compétences critiques."}
obj["INCOMING_SPELL_DOT"]					= { label="DoTs des compétences", tooltip="Afficher les dommages des DoT de compétences."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="DoTs des compétences critiques", tooltip="Afficher les dommages critiques entrant des DoT de compétences."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Dommages des boucliers", tooltip="Afficher les dommages entrant fait par les boucliers."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Dommages critiques des boucliers", tooltip="Afficher les dommages critiques entrants fait par les boucliers."}
obj["INCOMING_SPELL_MISS"]					= { label="Manques des compétences", tooltip="Afficher les compétences qui vous ont manqué."}
obj["INCOMING_SPELL_DODGE"]					= { label="Esquives des compétences", tooltip="Afficher les compétences que vous avez esquivé."}
obj["INCOMING_SPELL_PARRY"]					= { label="Parades des compétences", tooltip="Afficher les compétences que vous avez paré."}
obj["INCOMING_SPELL_BLOCK"]					= { label="Bloquages des compétences", tooltip="Afficher les capacités que vous avez bloqué."}
--obj["INCOMING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable incoming skill deflects."}
obj["INCOMING_SPELL_RESIST"]				= { label="Résistances aux sorts", tooltip="Afficher les sorts auxquels vous avez résisté."}
obj["INCOMING_SPELL_ABSORB"]				= { label="Absorptions des compétences", tooltip="Afficher les dommages des compétences que vous avez absorbé."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="Immunités aux compétences", tooltip="Afficher les compétences auxquelles vous êtes immunisé."}
obj["INCOMING_SPELL_REFLECT"]				= { label="Compétences renvoyés", tooltip="Afficher les compétences que vous avez renvoyé."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="Sorts interrompus", tooltip="Afficher les sorts que vous avez interrompu."}
obj["INCOMING_HEAL"]						= { label="Soins", tooltip="Afficher les soins reçus."}
obj["INCOMING_HEAL_CRIT"]					= { label="Soins critiques", tooltip="Afficher les soins critiques reçus."}
obj["INCOMING_HOT"]							= { label="Soins sur le temps (HoT)", tooltip="Afficher les soins des soins sur le temps (HoT) reçus."}
--obj["INCOMING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable incoming crit heals over time."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="Dommages de l'environnement", tooltip="Afficher les effets de l'environnement (chutes, noyades, lave, etc...) sur vous."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="Mêlées", tooltip="Afficher les dommages des attaques de mêlée sur votre familier."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="Mêlées critiques", tooltip="Afficher les dommages des attaques critiques de mêlée sur votre familier."}
obj["PET_INCOMING_MISS"]						= { label="Manques de mêlée", tooltip="Afficher les attaques de mêlée manquées sur votre familier."}
obj["PET_INCOMING_DODGE"]						= { label="Esquives de mêlée", tooltip="Afficher les attaques de mêlée esquivées par votre familier"}
obj["PET_INCOMING_PARRY"]						= { label="Parades de mêlée", tooltip="Afficher les attaques de mêlée parées par votre familier."}
obj["PET_INCOMING_BLOCK"]						= { label="Blocages de mêlée", tooltip="Afficher les dommages en mêlée bloquées par votre familier."}
--obj["PET_INCOMING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable your pet's incoming melee deflects."}
obj["PET_INCOMING_ABSORB"]						= { label="Absorptions de mêlée", tooltip="Afficher les dommages en mêlée absorbés par votre familier."}
obj["PET_INCOMING_IMMUNE"]						= { label="Immunités de mêlée", tooltip="Afficher les attaques de mêlée auxquelles votre familier est immunisé."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="Compétences", tooltip="Afficher les dommages des compétences sur votre familier."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="Compétences critiques", tooltip="Afficher les dommages des compétences critiques sur votre familier."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="DoTs des compétences", tooltip="Afficher les dommages des DoT de compétences sur votre familier."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="DoTs critiques des compétences", tooltip="Afficher les dommages critiques des DoT de compétences sur votre familier."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="Dommages des boucliers", tooltip="Afficher les dommages fait par les boucliers à votre familier."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Dommages critiques des boucliers", tooltip="Afficher les dommages critiques fait par les boucliers à votre familier."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="Manques des compétences", tooltip="Afficher les compétences qui ont manqué votre familier."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="Esquives des compétences", tooltip="Afficher les compétences que votre familier a esquivé."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="Parades des compétences", tooltip="Afficher les compétences que votre familier a paré."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="Bloquages des compétences", tooltip="Afficher les capacités que votre familier a bloqué."}
--obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable your pet's incoming skill deflects."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="Résistances aux sorts", tooltip="Afficher les sorts auxquels votre familier a résisté."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="Absorptions des compétences", tooltip="Afficher les dommages des compétences que votre familier a absorbé."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="Immunités aux compétences", tooltip="Afficher les compétences auxquelles votre familier est immunisé."}
obj["PET_INCOMING_HEAL"]						= { label="Soins", tooltip="Afficher les soins reçus par votre familier."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="Soins critiques", tooltip="Afficher les soins critiques reçus par votre familier."}
obj["PET_INCOMING_HOT"]							= { label="Soins sur le temps (HoT)", tooltip="Afficher les soins des soins sur le temps (HoT) reçus par votre familier."}
--obj["PET_INCOMING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable your pet's incoming crit heals over time."}


------------------------------
-- Outgoing events
------------------------------

obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="Mêlées", tooltip="Afficher les dommages infligés en mêlée."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="Mêlées critiques", tooltip="Afficher les dommages critiques infligés en mêlée."}
obj["OUTGOING_MISS"]						= { label="Manques de mêlée", tooltip="Afficher vos attaques manquées en mêlée."}
obj["OUTGOING_DODGE"]						= { label="Esquives de mêlée", tooltip="Afficher vos attaques esquivées en mêlée."}
obj["OUTGOING_PARRY"]						= { label="Parades de mêlée", tooltip="Afficher vos attaques parées en mêlée."}
obj["OUTGOING_BLOCK"]						= { label="Bloquages de mêlée", tooltip="Afficher vos dommages en mêlée bloquées."}
--obj["OUTGOING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable outgoing melee deflects."}
obj["OUTGOING_ABSORB"]						= { label="Absorptions de mêlée", tooltip="Afficher vos dommages en mêlée absorbés."}
obj["OUTGOING_IMMUNE"]						= { label="Immunités de mêlée", tooltip="Afficher vos attaques de mêlée auxquelles l'ennemi est immunisé."}
obj["OUTGOING_EVADE"]						= { label="Evites de mêlée", tooltip="Afficher vos attaques de mêlée evitées."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="Compétences", tooltip="Afficher les dommages de vos compétences."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Compétences critiques", tooltip="Afficher les dommages de vos compétences critiques."}
obj["OUTGOING_SPELL_DOT"]					= { label="DoTs des compétences", tooltip="Afficher les dommages sur le temps (DoT) de vos compétences."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="DoTs critiques des compétences", tooltip="Afficher les dommages critiques sur le temps (DoT) de vos compétences."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Dommages des boucliers", tooltip="Afficher les dommages fait par vos boucliers."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Dommages critiques des boucliers", tooltip="Afficher les dommages critiques fait par vos boucliers."}
obj["OUTGOING_SPELL_MISS"]					= { label="Manques compétences", tooltip="Afficher les coups manqués de vos compétences."}
obj["OUTGOING_SPELL_DODGE"]					= { label="Esquives compétences", tooltip="Afficher vos compétences esquivées."}
obj["OUTGOING_SPELL_PARRY"]					= { label="Parades compétences", tooltip="Afficher vos compétences parées."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="Bloquages compétences", tooltip="Afficher vos compétences bloquées."}
--obj["OUTGOING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable outgoing skill deflects."}
obj["OUTGOING_SPELL_RESIST"]				= { label="Résistances aux sorts", tooltip="Afficher les résistances à vos sorts."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="Absorptions compétences", tooltip="Afficher les absorptions de dommages de vos compétences."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="Immunités compétences", tooltip="Afficher les dommages de vos compétences auxquelles l'ennemi est immunisé."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="Compétences renvoyés", tooltip="Afficher les dommages de vos compétences qui vous sont renvoyés."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="Sorts interrompus", tooltip="Afficher les sorts qui sont interrompus."}
obj["OUTGOING_SPELL_EVADE"]					= { label="Evites compétences", tooltip="Afficher les évites de vos compétences."}
obj["OUTGOING_HEAL"]						= { label="Soins", tooltip="Afficher les soins effectués."}
obj["OUTGOING_HEAL_CRIT"]					= { label="Soins critiques", tooltip="Afficher les soins critiques effectués."}
obj["OUTGOING_HOT"]							= { label="Soins sur le temps (HoT)", tooltip="Afficher les soins sur le temps."}
--obj["OUTGOING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable outgoing crit heals over time."}
obj["OUTGOING_DISPEL"]						= { label="Dissipations", tooltip="Affiche les dissipations."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="Mêlées", tooltip="Afficher les dommages infligés par votre familier."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="Mêlées critiques", tooltip="Afficher les dommages critiques infligés par votre familier."}
obj["PET_OUTGOING_MISS"]						= { label="Manques de mêlée", tooltip="Afficher les attaques manquées par votre familier."}
obj["PET_OUTGOING_DODGE"]						= { label="Esquives de mêlée", tooltip="Afficher les attaques de mêlée de votre familier esquivées."}
obj["PET_OUTGOING_PARRY"]						= { label="Parades de mêlée", tooltip="Afficher les attaques de mêlée de votre familier parées."}
obj["PET_OUTGOING_BLOCK"]						= { label="Bloquages de mêlée", tooltip="Afficher les attaques de mêlée de votre familier bloquées."}
--obj["PET_OUTGOING_DEFLECT"]						= { label="Melee Deflects", tooltip="Enable your pet's outgoing melee deflects."}
obj["PET_OUTGOING_ABSORB"]						= { label="Absorptions de mêlée", tooltip="Afficher les dommages en mêlée absorbés de votre familier."}
obj["PET_OUTGOING_IMMUNE"]						= { label="Immunités de mêlée", tooltip="Afficher les capacités en mêlée de votre familier auxquelles l'ennemi est immunisé."}
obj["PET_OUTGOING_EVADE"]						= { label="Evites de mêlée", tooltip="Afficher les evites en mêlée de votre familier."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="Compétences", tooltip="Afficher les dommages des compétences de votre familier."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="Compétences critiques", tooltip="Afficher les dommages des compétences critiques de votre familier."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="DoTs des compétences", tooltip="Afficher les dommages sur le temps (DoTs) des compétences de votre familier."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="DoTs critiques des compétences", tooltip="Afficher les dommages critiques sur le temps (DoTs) des compétences de votre familier."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="Dommages des boucliers", tooltip="Afficher les dommages fait par les boucliers de votre familier."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="Dommages critiques des boucliers", tooltip="Afficher les dommages critiques fait par les boucliers de votre familier."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="Manques compétences", tooltip="Afficher les compétences de votre familier qui ont manqué."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="Esquives compétences", tooltip="Afficher les compétences de votre familier qui ont été esquivées."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="Parades compétences", tooltip="Afficher les compétences de votre familier qui ont été parées."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="Bloquages compétences", tooltip="Afficher les bloquages des compétences de votre familier."}
--obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="Skill Deflects", tooltip="Enable your pet's outgoing skill deflects."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="Résistances aux sorts", tooltip="Afficher les sorts de votre familier résisté."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="Absorptions compétences", tooltip="Afficher les compétences de votre familier absorbés."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="Immunités compétences", tooltip="Afficher les compétences de votre familier auxquelles l'ennemi est immunisé."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="Evites compétences", tooltip="Afficher les évites des compétences de votre familier."}
--obj["PET_OUTGOING_HEAL"]						= { label="Heals", tooltip="Enable your pet's outgoing heals."}
--obj["PET_OUTGOING_HEAL_CRIT"]					= { label="Crit Heals", tooltip="Enable your pet's outgoing crit heals."}
--obj["PET_OUTGOING_HOT"]							= { label="Heals Over Time", tooltip="Enable your pet's outgoing heals over time."}
--obj["PET_OUTGOING_HOT_CRIT"]					= { label="Crit Heals Over Time", tooltip="Enable your pet's outgoing crit heals over time."}
obj["PET_OUTGOING_DISPEL"]						= { label="Dissipations", tooltip="Affiche les dissipations de votre familier."}


------------------------------
-- Notification events
------------------------------

obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="Debuffs", tooltip="Afficher les debuffs qui vous affectent."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="Pile des Debuff", tooltip="Afficher les piles des debuff qui vous affectent."}
obj["NOTIFICATION_BUFF"]				= { label="Buffs", tooltip="Afficher les buffs reçus."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="Pile des Buff", tooltip="Afficher les piles des buff que vous recevez."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="Buffs des objets", tooltip="Afficher les buffs reçus par les objets."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="Fin des debuffs", tooltip="Afficher la fin des debuffs."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="Fin des buffs", tooltip="Afficher la fin des buffs."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="Fin des buffs d'objets", tooltip="Afficher quand un de vos buffs d'objet se termine."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="Début combat", tooltip="Afficher l'entrée en combat."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="Sortie combat", tooltip="Afficher la fin du combat."}
obj["NOTIFICATION_POWER_GAIN"]			= { label="Gains de puissance", tooltip="Afficher les gains de mana, rage et énergie."}
obj["NOTIFICATION_POWER_LOSS"]			= { label="Pertes de puissance", tooltip="Afficher les pertes de mana, rage et énergie par des drains."}
--obj["NOTIFICATION_ALT_POWER_GAIN"]		= { label="Alternate Power Gains", tooltip="Enable when you gain alternate power such as sound level on Atramedes."}
--obj["NOTIFICATION_ALT_POWER_LOSS"]		= { label="Alternate Power Losses", tooltip="Enable when you lose alternate power from drains."}
--obj["NOTIFICATION_CHI_CHANGE"]			= { label="Chi Changes", tooltip="Enable when you change chi."}
--obj["NOTIFICATION_CHI_FULL"]			= { label="Chi Full", tooltip="Enable when you attain full chi."}
obj["NOTIFICATION_CP_GAIN"]				= { label="Gain de points de combo", tooltip="Afficher les points de combo."}
obj["NOTIFICATION_CP_FULL"]				= { label="5 points de combo", tooltip="Afficher quand vous avez atteint 5 points de combo."}
--obj["NOTIFICATION_HOLY_POWER_CHANGE"]	= { label="Holy Power Changes", tooltip="Enable when you change holy power."}
--obj["NOTIFICATION_HOLY_POWER_FULL"]		= { label="Holy Power Full", tooltip="Enable when you attain full holy power."}
--obj["NOTIFICATION_SHADOW_ORBS_CHANGE"]	= { label="Shadow Orb Changes", tooltip="Enable when you change shadow orbs."}
--obj["NOTIFICATION_SHADOW_ORBS_FULL"]	= { label="Shadow Orbs Full", tooltip="Enable when you attain full shadow orbs."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="Gains d'honneur", tooltip="Afficher les gains d'honneur."}
obj["NOTIFICATION_REP_GAIN"]			= { label="Gains de réputation", tooltip="Afficher les gains de réputation."}
obj["NOTIFICATION_REP_LOSS"]			= { label="Pertes de réputation", tooltip="Afficher les pertes de réputation."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="Progression de compétences", tooltip="Afficher les progressions de compétences."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="Gains d'expérience", tooltip="Afficher les gains d'expérience."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="Coups fatals sur un joueur", tooltip="Afficher vos coups fatals sur les joueurs ennemis."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="Coups fatals sur un PNJ", tooltip="Afficher vos coups fatals sur les personnages non joueurs ennemis."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="Attaques supplémentaires", tooltip="Afficher les gains d'attaques supplémentaires, comme Windfury, etc."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="Gains de buff ennemi", tooltip="Affiche les buffs que gagne votre ennemi ciblé."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="Emote des monstres", tooltip="Affiche les emotes du monstre que vous ciblez."}


------------------------------
-- Trigger info
------------------------------

-- Main events.
obj = L.TRIGGER_DATA
obj["SWING_DAMAGE"]				= "Dommage du Swing"
obj["RANGE_DAMAGE"]				= "Dommage à Distance"
obj["SPELL_DAMAGE"]				= "Dommage de Compétence"
obj["GENERIC_DAMAGE"]			= "Dommage de Swing/Distance/Compétence"
obj["SPELL_PERIODIC_DAMAGE"]	= "Dommage de Compétence Périodique (DoT)"
obj["DAMAGE_SHIELD"]			= "Dommage de Bouclier"
obj["DAMAGE_SPLIT"]				= "Dommage de Split"
obj["ENVIRONMENTAL_DAMAGE"]		= "Dommage de l'Environnement"
obj["SWING_MISSED"]				= "Manque du Swing"
obj["RANGE_MISSED"]				= "Manque à Distance"
obj["SPELL_MISSED"]				= "Manque d'une Compétence"
obj["GENERIC_MISSED"]			= "Manque de Swing/Distance/Compétence"
obj["SPELL_PERIODIC_MISSED"]	= "Manque d'une Compétence Périodique"
obj["SPELL_DISPEL_FAILED"]		= "Manque d'une Dissipation"
obj["DAMAGE_SHIELD_MISSED"]		= "Manque d'un Dommage de Bouclier"
obj["SPELL_HEAL"]				= "Soin"
obj["SPELL_PERIODIC_HEAL"]		= "Soin Périodique (HoT)"
obj["SPELL_ENERGIZE"]			= "Gain de Puissance"
obj["SPELL_PERIODIC_ENERGIZE"]	= "Gain de Puissance Périodique"
obj["SPELL_DRAIN"]				= "Drain de Puissance"
obj["SPELL_PERIODIC_DRAIN"]		= "Drain de Puissance Périodique"
obj["SPELL_LEECH"]				= "Sangsue de Puissance"
obj["SPELL_PERIODIC_LEECH"]		= "Sangsue de Puissance Périodique"
obj["SPELL_INTERRUPT"]			= "Interruption de Compétence"
obj["SPELL_AURA_APPLIED"]		= "Aura Appliquée"
obj["SPELL_AURA_REMOVED"]		= "Aura Enlevée"
obj["SPELL_STOLEN"]				= "Aura Volée"
obj["SPELL_DISPEL"]				= "Aura Dissipée"
--obj["SPELL_AURA_REFRESH"]		= "Aura Refresh"
obj["SPELL_AURA_BROKEN_SPELL"]	= "Aura Cassée"
obj["ENCHANT_APPLIED"]			= "Enchantement Appliqué"
obj["ENCHANT_REMOVED"]			= "Enchantement Enlevé"
obj["SPELL_CAST_START"]			= "Sort Incanté"
obj["SPELL_CAST_SUCCESS"]		= "Sort Réussi"
obj["SPELL_CAST_FAILED"]		= "Sort Echoué"
obj["SPELL_SUMMON"]				= "Invoquer"
obj["SPELL_CREATE"]				= "Créer"
obj["PARTY_KILL"]				= "Coup Fatal"
obj["UNIT_DIED"]				= "Unité Morte"
obj["UNIT_DESTROYED"]			= "Unité Détruite"
obj["SPELL_EXTRA_ATTACKS"]		= "Attaque Supplémentaire"
obj["UNIT_HEALTH"]				= "Modification des Points de Vie"
obj["UNIT_POWER"]				= "Modification de Puissance"
--obj["SKILL_COOLDOWN"]			= "Player Cooldown Complete"
--obj["PET_COOLDOWN"]				= "Pet Cooldown Complete"
--obj["ITEM_COOLDOWN"]			= "Item Cooldown Complete"
 
-- Main event conditions.
obj["sourceName"]				= "Origine Unité Nom"
obj["sourceAffiliation"]		= "Origine Unité Affiliation"
obj["sourceReaction"]			= "Origine Unité Réaction"
obj["sourceControl"]			= "Origine Unité Contrôle"
obj["sourceUnitType"]			= "Origine Unité Type"
obj["recipientName"]			= "Destinataire Unité Nom"
obj["recipientAffiliation"]		= "Destinataire Unité Affiliation"
obj["recipientReaction"]		= "Destinataire Unité Réaction"
obj["recipientControl"]			= "Destinataire Unité Contrôle"
obj["recipientUnitType"]		= "Destinataire Unité Type"
obj["skillID"]					= "Compétence ID"
obj["skillName"]				= "Compétence Nom"
obj["skillSchool"]				= "Compétence Ecole"
obj["extraSkillID"]				= "Extra Compétence ID"
obj["extraSkillName"]			= "Extra Compétence Nom"
obj["extraSkillSchool"]			= "Extra Compétence Ecole"
obj["amount"]					= "Quantité"
obj["overkillAmount"]			= "Quantité de dommages en excès"
obj["damageType"]				= "Dommage Type"
obj["resistAmount"]				= "Quantité Résistée"
obj["blockAmount"]				= "Quantité Bloquée"
obj["absorbAmount"]				= "Quantité Absorbée"
obj["isCrit"]					= "Critique"
obj["isGlancing"]				= "Coup Diminué"
obj["isCrushing"]				= "Coup Ecrasé"
obj["extraAmount"]				= "Extra Quantité"
obj["missType"]					= "Type Manque"
obj["hazardType"]				= "Type Hazard"
obj["powerType"]				= "Type Puissance"
obj["auraType"]					= "Type Aura"
obj["threshold"]				= "Seuil"
obj["unitID"]					= "Unité ID"
obj["unitReaction"]				= "Unité Réaction"
--obj["itemID"]					= "Item ID"
--obj["itemName"]					= "Item Name"

-- Exception conditions.
obj["activeTalents"]	= "Talents Actifs"
obj["buffActive"]		= "Buff Actif"
obj["buffInactive"]		= "Buff Inactif"
obj["currentCP"]		= "Points de Combo Actuels"
obj["currentPower"]		= "Puissance Actuelle"
obj["inCombat"]			= "En combat"
obj["recentlyFired"]	= "Déclencheur Récemment Activé"
obj["trivialTarget"]	= "Cible Insignifiante"
obj["unavailableSkill"]	= "Compétence Indisponible"
obj["warriorStance"]	= "Position de Combat"
obj["zoneName"]			= "Nom de la Zone"
obj["zoneType"]			= "Type de la Zone"
 
-- Relationships.
obj["eq"]		= "Est égal à"
obj["ne"]		= "N'est pas égal à"
obj["like"]		= "Est comme"
obj["unlike"]	= "N'est pas comme"
obj["lt"]		= "Est moins que"
obj["gt"]		= "Est plus grand que"
 
-- Affiliations.
obj["affiliationMine"]		= "A Moi"
obj["affiliationParty"]		= "Membre du Groupe"
obj["affiliationRaid"]		= "Membre du Raid"
obj["affiliationOutsider"]	= "Etranger"
obj["affiliationTarget"]	= "Cible"
obj["affiliationFocus"]		= "Focus"
obj["affiliationYou"]		= "Vous"

-- Reactions.
obj["reactionFriendly"]	= "Ami"
obj["reactionNeutral"]	= "Neutre"
obj["reactionHostile"]	= "Hostile"

-- Control types.
obj["controlServer"]	= "Serveur"
obj["controlHuman"]		= "Humain"

-- Unit types.
obj["unitTypePlayer"]	= "Joueur" 
obj["unitTypeNPC"]		= "NPC"
obj["unitTypePet"]		= "Familier"
obj["unitTypeGuardian"]	= "Gardien"
obj["unitTypeObject"]	= "Objet"

-- Aura types.
obj["auraTypeBuff"]		= "Buff"
obj["auraTypeDebuff"]	= "Debuff"

-- Zone types.
obj["zoneTypeArena"]	= "Arène"
obj["zoneTypePvP"]		= "Champ de Bataille"
obj["zoneTypeParty"]	= "Instance 5"
obj["zoneTypeRaid"]		= "Instance de raid"

-- Booleans
obj["booleanTrue"]	= "Vrai"
obj["booleanFalse"]	= "Faux"


------------------------------
-- Font info
------------------------------

-- Font outlines.
obj = L.OUTLINES
obj[1] = "Aucun"
obj[2] = "Fin"
obj[3] = "Epais"
--obj[4] = "Monochrome"
--obj[5] = "Monochrome + Thin"
--obj[6] = "Monochrome + Thick"

-- Text aligns.
obj = L.TEXT_ALIGNS
obj[1] = "Gauche"
obj[2] = "Centre"
obj[3] = "Droite"


------------------------------
-- Sound info
------------------------------

obj = L.SOUNDS
obj["MSBT Low Mana"]	= "MSBT Mana Faible"
obj["MSBT Low Health"]	= "MSBT Vie Faible"
obj["MSBT Cooldown"]	= "MSBT Cooldown"


------------------------------
-- Animation style info
------------------------------

-- Animation styles
obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "En Angle"
obj["Horizontal"]	= "Horizontal"
obj["Parabola"]		= "Parabole"
obj["Straight"]		= "Directement"
obj["Static"]		= "Statique"
obj["Pow"]			= "Pow"

-- Animation style directions.
obj["Alternate"]	= "Alternée"
obj["Left"]			= "Gauche"
obj["Right"]		= "Droite"
obj["Up"]			= "Haut"
obj["Down"]			= "Bas"

-- Animation style behaviors.
obj["AngleUp"]		= "En Angle vers le Haut"
obj["AngleDown"]	= "En Angle vers le Bas"
obj["GrowUp"]		= "Développement vers le Haut"
obj["GrowDown"]		= "Développement vers le Bas"
obj["CurvedLeft"]	= "Incurvé à Gauche"
obj["CurvedRight"]	= "Incurvé à Droite"
obj["Jiggle"]		= "Secoué"
obj["Normal"]		= "Normal"
