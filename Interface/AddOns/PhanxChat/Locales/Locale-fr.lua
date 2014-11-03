--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	French localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if GetLocale() ~= "frFR" then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "Conversation"
C.General         = "Général"
C.LocalDefense    = "DéfenseLocale"
C.LookingForGroup = "RechercheDeGroupe"
C.Trade           = "Commerce"
C.WorldDefense    = "DéfenseUniverselle"

------------------------------------------------------------------------
--	Abbreviated Channel Names
--	These should be one- or two-character abbreviations.
------------------------------------------------------------------------

S.Conversation    = "C"
S.General         = "G"
S.LocalDefense    = "DL"
S.LookingForGroup = "RG"
S.Trade           = "C"
S.WorldDefense    = "DM"

S.Guild              = "G"
S.InstanceChat       = "I"
S.InstanceChatLeader = "CI"
S.Officer            = "O"
S.Party              = "G"
S.PartyGuide         = "CG"
S.PartyLeader        = "CG"
S.Raid               = "R"
S.RaidLeader         = "CR"
S.RaidWarning        = "AR"
S.Say                = "D"
S.WhisperIncoming    = "De"
S.WhisperOutgoing    = "À"
S.Yell               = "C"

S.PET_BATTLE_COMBAT_LOG = "Combat"

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

L.All = "Tous"
L.Default = "Défaut"
L.EnableArrows = "Autoriser les touches fléchées"
L.EnableArrows_Desc = "Autoriser l'utilisation des touches fléchées dans la fenêtre de chat."
L.EnableResizeEdges = "Améliorer le redimensionnement"
L.EnableResizeEdges_Desc = "Autoriser le redimensionnement grâce à tous les coins de la fenêtre de chat, au lieu du seul coin bas droit."
L.EnableSticky = "Canal mémorisé"
L.EnableSticky_Desc = "Sélectionner les types de canaux mémorisés."
L.FadeTime = "Temps d'estompage"
L.FadeTime_Desc = "Régler le temps, en minutes, à attendre avant l'estompage du texte. Une valeur de 0 désactivera l'estompage."
L.FontSize = "Taille de police"
L.FontSize_Desc = "Régler la taille de police pour toutes les fenêtres de chat."
L.FontSize_Note = "Notez que ceci est juste un raccourci pour configurer les fenêtres de chat via les options de Blizzard."
L.HideButtons = "Masquer les boutons"
L.HideButtons_Desc = "Masquer le menu de la fenêtre de chat et les boutons de défilement."
L.HideFlash = "Masquer le flash des onglets"
L.HideFlash_Desc = "Désactiver l'effet de flash des onglets qui ont un nouveau message."
L.HideNotices = "Masquer les avertissements"
L.HideNotices_Desc = "Masquer les messages de notification de changement de canal."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "Masquer les spams"
L.HideRepeats_Desc = "Masquer les message spammés sur les canaux publics."
L.HideTextures = "Masquer les textures supplémentaires"
L.HideTextures_Desc = "Masquer les textures supplémentaires des onglets et de la fenêtre d'édition ajoutées avec la 3.3.5."
L.LinkURLs = "Liens URL"
L.LinkURLs_Desc = "Transformer les URL dans la fenêtre de chat en liens cliquables pour les copier."
L.LockTabs = "Verrouiller les onglets"
L.LockTabs_Desc = "Enpêcher de déplacer les onglets sans appuyer sur la touche shift."
L.MoveEditBox = "Déplacer la fenêtre d'édition"
L.MoveEditBox_Desc = "Déplacer les fenêtres d'édition en haut de leurs fenêtres de chat respectives."
L.None = "Aucun"
L.OptionLocked = "Cette option est verrouillée par PhanxChat. Utilisez l'option %q dans PhanxChat à la place."
L.OptionLockedConditional = "Cette option est verrouillée par PhanxChat. Si vous souhaitez la changer, vous d'abord désactiver l'option %q dans PhanxChat."
L.RemoveRealmNames = "Ôter les noms de serveurs"
L.RemoveRealmNames_Desc = "Raccourcir les noms des joueurs en ôtant les noms de serveurs."
L.ReplaceRealNames = "Remplacer les noms réels"
L.ReplaceRealNames_Desc = "Remplacer le nom réel par le nom de personnage."
L.ShortenChannelNames = "Noms de canaux courts"
L.ShortenChannelNames_Desc = "Raccourcir les noms de canaux et de chat."
L.ShortenRealNames = "Noms réels courts"
L.ShortenRealNames_Desc = "Choisis comment raccourcir le Real ID."
L.ShortenRealNames_UseBattleTag = "Remplace par le BattleTag"
L.ShortenRealNames_UseFirstName = "Affiche seulement le prénom"
L.ShortenRealNames_UseFullName = "Garde le nom complet"
L.ShowClassColors = "Afficher les couleurs de classe"
L.ShowClassColors_Desc = "Afficher les couleurs de classe dans tous les canaux."
L.Whisper_BadTarget = "Vous ne pouvez pas chuchoter vers cette cible!"
L.Whisper_NoTarget = "Vous n'avez pas de cible pour chuchoter!"
L.WhoStatus_Battlenet = "%s est sur l'application Battle.net."
L.WhoStatus_Offline = "%s est déconnecté."
L.WhoStatus_PlayingOtherGame = "%s joue à %s."

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	French translations for PhanxChat:
	- braincell @ Curse
	- L0relei @ Curse
----------------------------------------------------------------------]]