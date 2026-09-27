local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

if RealUI.locale == "frFR" then

-- cf-localization: locale="frFR", format="lua_additive_table", handle-unlocalized="comment"
L["ActionBars_ActionBarsDesc"] = "Modifier la position et la taille des barres d'action"
L["ActionBars_Center"] = "Centrer"
L["ActionBars_CenterDesc"] = "Ajuster la position des trois barres d'action centrales."
L["ActionBars_CenterOption"] = "%d Centre - %d Bas"
L["ActionBars_EAB"] = "Extra bouton d'action"
L["ActionBars_Move"] = "Déplacer %s"
L["ActionBars_MoveDesc"] = "Cocher pour autoriser RealUI à utiliser la position du %s"
L["ActionBars_Pet"] = "Barre de familler"
L["ActionBars_ShowDoodads"] = "Afficher les gagdets"
L["ActionBars_ShowDoodadsDesc"] = "Affiche les marqueurs pour indiquer la position des barres de posture et de familier"
L["ActionBars_Sides"] = "Cotés"
L["ActionBars_SidesDesc"] = "Ajuster la position des deux barres d'action latérales"
L["ActionBars_SidesOption"] = "%d Gauche - %d Droit"
L["ActionBars_Stance"] = "Barre de positions"
L["Alert_CantOpenInCombat"] = "Impossible d'ouvrir la configuration de RealUI en combat."
L["Alert_CombatLockdown"] = "Verrouillage de combat."
L["Alert_WaitCombatLockdown"] = "Un combat est en cours, des restrictions sont appliquées. L'interface sera mise à jour à la fin de celui ci. "
L["Appearance_ButtonColor"] = "Couleur du bouton"
L["Appearance_ClassColorHealth"] = "Vie colorée selon la classe"
L["Appearance_ClassColorNames"] = "Nom coloré"
L["Appearance_FrameColor"] = "Couleur du cadre"
L["Appearance_HighRes"] = "Haute résolution"
L["Appearance_HighResDesc"] = "Ceci doublera l'échelle de l'interface pour que les éléments soient plus simples à voir. Note : Ce n'est recommandé que dans le cas ou l'affichage possède une résolution verticale supérieure ou égale à 1440 px.  "
L["Appearance_ModScale"] = "Mod. échelle interface"
L["Appearance_ModScaleDesc"] = "Ceci n'affecte pour le moment que certains éléments, mais sera éventuellement utilisé pour l'ensemble de l'interface utilisateur. "
L["Appearance_Pixel"] = "Pixel-parfait"
L["Appearance_PixelDesc"] = "Règle l'échelle de l'interface afin que les pixels du jeux correspondent aux pixels de votre écran."
L["Appearance_Skins"] = "Apparences"
L["Appearance_StripeOpacity"] = "Opacité des rayures"
L["Appearance_UIScale"] = "Echelle de l'interface personnalisée "
L["Appearance_UIScaleDesc"] = "Défini une échelle d'interface personnalisée (%.2f - %.2f). Note : certains éléments de l'interface peuvent perdre leur aspect net."
L["BindingsReminder"] = "Rappel des raccourcis"
L["BindingsReminderDesc"] = "Affiche un rappel des actions liées à chaque touche du clavier."
L["CastBars"] = "Barres d'incantation"
L["CastBars_Bottom"] = "Bas"
L["CastBars_BottomDesc"] = "Le nom et la durée sont affichées en dessous de la barre d'incantation"
L["CastBars_Inside"] = "Intérieur"
L["CastBars_InsideDesc"] = "Le nom et la durée sont affichées sur la gauche pour le joueur et sur la droite pour la cible"
L["Chat"] = "Discussion"
L["Chat_ClassColor"] = "Noms colorés en fonction de la classe"
L["Chat_ClassColorDesc"] = "Affiche le nom du joueur dans la couleur de leur classe."
L["Clock_CalenderInvites"] = "Invitations en attentes : "
L["Clock_Date"] = "Date"
L["Clock_ShowCalendar"] = "<Clic> Ouvrir le calendrier"
L["Clock_ShowTimer"] = "<Alt+Clic> Ouvrir les paramètres de l'horloge"
L["CombatFade"] = "Fondu en combat"
L["CombatFade_Desc"] = "Modifie automatiquement l'opacité d'un cadre en fonction de l'état en combat, de la santé et du statut de la cible."
L["CombatFade_HarmTarget"] = "Cible attaquable"
L["CombatFade_Hurt"] = "Blessé"
L["CombatFade_InCombat"] = "En combat"
L["CombatFade_NoCombat"] = "Hors combat"
L["CombatFade_Target"] = "Cible sélectionnée"
L["CombatText"] = "Journal de combat"
L["CombatText_MergeHits"] = "[%d Coups]"
L["Control_AddonControl"] = "Controle d'AddOn"
L["Control_Layout"] = "Contrôle de disposition"
L["Control_LayoutDesc"] = "Autoriser RealUI à contrôler les paramètres de %s"
L["Control_Position"] = "Contrôler position"
L["Control_PositionDesc"] = "Autoriser RealUI à contrôler la position de %s"
L["Currency_Cycle"] = "<Click> Ouvre la liste des monnaies, <Alt+Click> Change la monnaie affichée"
L["Currency_EraseData"] = "<Alt+Click> Efface les données de personnage en surbrillance"
L["Currency_TotalMoney"] = "Or total sur le royaume :"
L["Currency_UpdatedAbbr"] = "MàJ."
L["DoReloadUI"] = "Vous devez recharger l'interface pour que les changements prennent effet. Recharger maintenant ?"
L["Fonts"] = "Polices"
L["Fonts_Chat"] = "Police de Chat"
L["Fonts_ChatDesc"] = "Cette police est utilisée pour la fenêtre de chat et occasionnellement pour les chiffres."
L["Fonts_Crit"] = "Police coup critique"
L["Fonts_Header"] = "Police d'en-tête"
L["Fonts_HeaderDesc"] = "Cette police est utilisée principalement pour les titres et en-têtes"
L["Fonts_Normal"] = "Police normale"
L["Fonts_NormalDesc"] = "Cette police est utilisée pour une grande partie de l'interface telle que les indications, quêtes et objectifs"
--[[Translation missing --]]
--[[ L["General_AnchorPoint"] = "Anchor Point"--]] 
L["General_Debug"] = "Debug"
L["General_DebugDesc"] = "Apporte des informations de debug supplémenaires"
L["General_Enabled"] = "Activé"
L["General_EnabledDesc"] = "Activer/Désactiver %s"
L["General_InvalidParent"] = "La fenêtre parente initialisée pour %s n'existe pas. Tapez /realadv and allez dans %s->%s pour initialiser le nouveau parent"
L["General_Lock"] = "Verrouillé"
L["General_LockDesc"] = "activer pour déplacer ou verrouiller la position du cadre"
L["General_NoteParent"] = "Pour trouver le nom de cette fenêtre, tapez /fstack et survolez la fenêtre que vous voulez attacher. Utilisez ALT pour afficher la zone surligner verte"
L["General_NoteReload"] = "Note : Vous devrez recharger l'interface (/rl) pour que les changements prennent effet."
L["General_Position"] = "Position"
L["General_Positions"] = "Positions"
L["General_Tristatefalse"] = "cffff0000Ignoré|r - Simple- Multiple"
L["General_Tristatenil"] = "Ignoré- Simple- |cff00ff00Multiple|r"
L["General_Tristatetrue"] = "Ignoré - |cff00ff00Simple|r - Multiple"
L["General_XOffset"] = "Décalage X"
L["General_XOffsetDesc"] = "Décalage en X (horizontal) par rapport au point d'ancrage donné"
L["General_YOffset"] = "Décalage Y"
L["General_YOffsetDesc"] = "Décalage en Y (vertical) par rapport au point d'ancrage donné"
L["GuildFriend_WhisperInvite"] = "<Click> Murmurer, <Alt+Click> %s"
L["HuD_AlertHuDChangeSize"] = "Changer la taille du HuD peut modifier la position de certains éléments. Il est donc recommandé de vérifier la position des éléments de l'interface une fois que les changements aient pris effet."
L["HuD_Height"] = "Hauteur"
L["HuD_Horizontal"] = "Horizontale"
L["HuD_ReverseBars"] = "Inverser la direction de la barre"
L["HuD_ShowElements"] = "Montrer les éléments"
L["HuD_Uninterruptible"] = "Ininterruptible"
L["HuD_UseLarge"] = "Utiliser le grand HuD"
L["HuD_UseLargeDesc"] = "Agrandir les éléments clés du HuD (Portraits d'unités, etc)."
L["HuD_Vertical"] = "Vertical"
L["HuD_VerticalDesc"] = "Ajuster la position verticale de tout l'HUD"
L["HuD_Width"] = "Largeur"
L["Infobar"] = "Barre d'information"
--[[Translation missing --]]
--[[ L["Infobar_AllBlocks"] = "All Blocks"--]] 
--[[Translation missing --]]
--[[ L["Infobar_BlockGap"] = "Block Gap"--]] 
--[[Translation missing --]]
--[[ L["Infobar_BlockGapDesc"] = "The amount of space between each block."--]] 
--[[Translation missing --]]
--[[ L["Infobar_CombatTooltips"] = "In Combat Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Infobar_CombatTooltipsDesc"] = "Show tooltips while in combat."--]] 
--[[Translation missing --]]
--[[ L["Infobar_Desc"] = "LDB supported data display"--]] 
--[[Translation missing --]]
--[[ L["Infobar_ShowIcon"] = "Show icon"--]] 
--[[Translation missing --]]
--[[ L["Infobar_ShowLabel"] = "Show label"--]] 
--[[Translation missing --]]
--[[ L["Infobar_ShowStatusBar"] = "Show status bars"--]] 
--[[Translation missing --]]
--[[ L["Infobar_ShowStatusBarDesc"] = "Show the progress watch status bars."--]] 
L["Install"] = "CLIQUER POUR INSTALLER"
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
L["Layout_ApplyOOC"] = "La disposition changera après avoir quitté le combat"
L["Layout_DPSTank"] = "DPS/Tank"
L["Layout_Healing"] = "Soigneur"
L["Layout_Layout"] = "Disposition"
L["Layout_Link"] = "Lier les dispositions"
L["Layout_LinkDesc"] = "Utiliser les mêmes paramètres pour les dispositions DPS/Tank et soigneur"
L["Misc_SpellAlertsDesc"] = "Modifier la position et la taille des alertes de sorts"
L["Misc_SpellAlertsWidthDesc"] = "Ajuste la distance entre la gauche et la droite du cache d'alerte de sort"
L["Patch_DoApply"] = "Un patch a été appliqué, l'interface doit être rechargée pour que les changement prennent effet."
L["Patch_MiniPatch"] = "RealUI Mini Patch"
L["Patch_UpdateAddonSettings"] = "Les paramètres par défauts pour %s ont été mis à jour. Voulez vous appliquer ces changements? "
--[[Translation missing --]]
--[[ L["Progress"] = "Progress Watch"--]] 
--[[Translation missing --]]
--[[ L["Progress_Cycle"] = "<Alt+Click> Cycle display"--]] 
L["Progress_OpenArt"] = "<Click> Ouvre la fenêtre de l'équipement prodigieux actuellement équipé"
L["Progress_OpenHonor"] = "<Click> Ouvre les talents JcJ"
L["Progress_OpenRep"] = "<Click> Ouvre la liste des factions"
L["Raid_30Width"] = "Largeur 30 Joueurs"
L["Raid_40Width"] = "Largeur 40 Joueurs"
L["Raid_HideRaidFilter"] = "Cacher les filtres de raid"
L["Raid_HideRaidFilterDesc"] = "Cacher le filtre de groupe pour le gestionnaire de portrait de Raid de Blizzard"
L["Raid_LargeGroup"] = "Grands groupes"
L["Raid_LargeGroupDesc"] = "Utiliser des groupes horizontaux lorsqu'en grand groupes comme les raids et champs de bataille"
L["Raid_ShowSolo"] = "Afficher en solo"
L["Raid_SmallGroup"] = "Petits groupes"
L["Raid_SmallGroupDesc"] = "Utiliser des groupes horizontaux lorsqu'en petit groupes comme les donjons et les arênes"
L["Reset_Confirm"] = "Etes vous sur de vouloir réinitialiser RealUI ?"
L["Reset_SettingsLost"] = "Tout les paramètres seront perdus"
L["Resource"] = "Ressource de calsse"
L["Resource_Gap"] = "Espacement"
L["Resource_GapDesc"] = "La distance entre chaque %s"
L["Resource_HeightDesc"] = "Ajuster la hauteur de l'ancre de ressource"
L["Resource_HideUnused"] = "Cacher %s inutilisé"
L["Resource_HideUnusedDesc"] = "Afficher seulement le %s que vous avez"
L["Resource_Reverse"] = "Inverser l'orientation"
L["Resource_ReverseDesc"] = "Inverser l'orientation de l'affichage de %s"
L["Resource_WidthDesc"] = "Ajuster la largeur de l'ancre de ressource"
L["Slash_Profile"] = "|cff%sLe profilage de processeur est acrivé!|r Pour le désactiver taper: |cff%s/cpuProfiling|r"
L["Slash_RealUI"] = "Tapes %s pour configure le style, les positions et les paramètres de l'interface"
L["Slash_Taint"] = "|cff%sTaint les logs sont activés!|r Pour le désactiver taper: |cff%s/taintLogging|r"
--[[Translation missing --]]
--[[ L["Spec_ChangeGear"] = "<Right+Click> Cycle equip sets, <Alt+Right+Click> Unassign equip set"--]] 
L["Spec_ChangeSpec"] = "<Clic> Change la spécialisation, <Alt+Clic> Change la spécialisation de butin"
L["Spec_Open"] = "<Clic> Ouvre la fenêtre des talents"
L["Spec_SpecChanger"] = "Changement de spécialisation"
L["Start"] = "Début"
L["Start_Config"] = "Config RealUI"
L["Sys_AverageAbbr"] = "Moy"
L["Sys_CurrentAbbr"] = "Actl"
L["Sys_Stat"] = "Statistiques"
L["Sys_SysInfo"] = "Information système"
L["Tooltips"] = "Infobulle"
--[[Translation missing --]]
--[[ L["Tooltips_AtCursor"] = "At Cursor"--]] 
--[[Translation missing --]]
--[[ L["Tooltips_AtCursorDesc"] = "Position the tooltip at the cursor by default."--]] 
L["Tooltips_ShowIDs"] = "Montrer l'ID des objets"
L["Tooltips_ShowRealm"] = "Montrer les noms de royaumes"
L["Tooltips_ShowTitles"] = "Montrer les titres du joueur"
L["Tweaks_CooldownCount"] = "Compteur de temps de recharge"
L["Tweaks_CooldownCountDesc"] = "Modifie le texte de temps de recharge"
L["Tweaks_UITweaks"] = "Ajustements de l'interface"
--[[Translation missing --]]
--[[ L["Tweaks_UITweaksDesc"] = "Minor functional tweaks for the default UI"--]] 
L["UnitFrames_AnchorWidth"] = "Largeur de l'ancre"
L["UnitFrames_AnchorWidthDesc"] = "L'espace entre la portrait du joueur et de la cible"
L["UnitFrames_AnnounceChatDesc"] = "Canal de discussion utilisé pour l'annonce de trinket"
L["UnitFrames_AnnounceTrink"] = "Annoncer les trinkets"
L["UnitFrames_AnnounceTrinkDesc"] = "Annoncer l'utilisation d'un trinket adverse dans le chat"
L["UnitFrames_BuffCount"] = "Compteur d'amélioration"
L["UnitFrames_DebuffCount"] = "Compteur d'affaiblissement"
L["UnitFrames_Gap"] = "Vide"
L["UnitFrames_GapDesc"] = "Distance verticale entre chaque unité."
L["UnitFrames_ModifierKey"] = "Touche modificatrice"
L["UnitFrames_NPCAuras"] = "Afficher les auras de PNJ"
L["UnitFrames_NPCAurasDesc"] = "Montrer les Améliorations/Affaiblissements lancées par les PNJs."
L["UnitFrames_PlayerAuras"] = "Montrer les auras des joueurs"
L["UnitFrames_PlayerAurasDesc"] = "Montrer les Améliorations/Affaiblissements lancées par les vous même."
L["UnitFrames_SetFocus"] = "Cliquer pour focaliser"
L["UnitFrames_SetFocusDesc"] = "<Portrait Click+modificateur> Focaliser"
L["UnitFrames_Units"] = "Unité"
L["Version"] = "Version"
--[[Translation missing --]]
--[[ L["WorldMarker"] = "World Marker"--]] 
--[[Translation missing --]]
--[[ L["WorldMarker_Show"] = "Show the World Marker in..."--]] 
--[[Translation missing --]]
--[[ L["WorldMarkerDesc"] = "Quick access to World Markers"--]] 
-- cf-localization end
end
