--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	https://mods.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local C, S, L = {}, {}, {}
PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L = C, S, L

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Conversation"
C.General         = "General"
C.LocalDefense    = "LocalDefense"
C.LookingForGroup = "LookingForGroup"
C.Trade           = "Trade"
C.WorldDefense    = "WorldDefense"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation       = "C"
S.General            = "G"
S.LocalDefense       = "LD"
S.LookingForGroup    = "LFG"
S.Trade              = "T"
S.WorldDefense       = "WD"
S.Guild              = "g"
S.InstanceChat       = "i"
S.InstanceChatLeader = "I"
S.Officer            = "o"
S.Party              = "p"
S.PartyGuide         = "P"
S.PartyLeader        = "P"
S.Raid               = "r"
S.RaidLeader         = "R"
S.RaidWarning        = "W"
S.Say                = "s"
S.WhisperIncoming    = "w"
S.WhisperOutgoing    = "@"
S.Yell               = "y"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Battle"

-- Options Panel
L.All = "All"
L.Default = "Default"
L.EnableArrows = "Enable arrow keys"
L.EnableArrows_Desc = "Enable arrow keys in the chat edit box."
L.EnableResizeEdges = "Enable resize edges"
L.EnableResizeEdges_Desc = "Enable resize controls at all edges of chat frames, instead of only the bottom right corner."
L.EnableSticky = "Sticky chat"
L.EnableSticky_Desc = "Set which chat types should be sticky."
L.FadeTime = "Fade time"
L.FadeTime_Desc = "Set the time, in minutes, to wait before fading chat text. A setting of 0 will disable fading."
L.FontSize = "Font size"
L.FontSize_Desc = "Set the font size for all chat frames."
L.FontSize_Note = "Note that this is just a shortcut to configuring each chat frame individually through the Blizzard chat options."
L.HideButtons = "Hide buttons"
L.HideButtons_Desc = "Hide the chat frame menu and scroll buttons."
L.HideFlash = "Hide tab flash"
L.HideFlash_Desc = "Disable the flashing effect on chat tabs that receive new messages."
L.HideNotices = "Hide notices"
L.HideNotices_Desc = "Hide channel notification messages."
L.HidePetCombatLog = "Disable pet battle log"
L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "Hide repeats"
L.HideRepeats_Desc = "Hide repeated messages in public channels."
L.HideTextures = "Hide extra textures"
L.HideTextures_Desc = "Hide the extra textures on chat tabs and chat edit boxes added in patch 3.3.5."
L.LinkURLs = "Link URLs"
L.LinkURLs_Desc = "Transform URLs in chat into clickable links for easy copying."
L.LockTabs = "Lock docked tabs"
L.LockTabs_Desc = "Prevent docked chat tabs from being dragged unless the Shift key is down."
L.MoveEditBox = "Move edit boxes"
L.MoveEditBox_Desc = "Move chat edit boxes to the top their respective chat frames."
L.None = "None"
L.OptionLocked = "This option is locked by PhanxChat. Use the %q option in PhanxChat instead."
L.OptionLockedConditional = "This option is locked by PhanxChat. If you wish to change it, you must first disable the %q option in PhanxChat."
L.RemoveRealmNames = "Remove realm names"
L.RemoveRealmNames_Desc = "Shorten player names by removing realm names."
L.ReplaceRealNames = "Replace real names"
L.ReplaceRealNames_Desc = "Replace Real ID names and BattleTags with WoW character names when possible."
L.ShortenChannelNames = "Short channel names"
L.ShortenChannelNames_Desc = "Shorten channel names and chat strings."
L.ShortenRealNames = "Shorten real names"
L.ShortenRealNames_Desc = "Choose how to shorten Real ID names, if at all."
L.ShortenRealNames_UseBattleTag = "Replace with BattleTag"
L.ShortenRealNames_UseFirstName = "Show first name only"
L.ShortenRealNames_UseFullName = "Keep full name"
L.ShowClassColors = "Show class colors"
L.ShowClassColors_Desc = "Show class colors in all channels."
L.Whisper_BadTarget = "You can't whisper that target!"
L.Whisper_NoTarget = "You don't have a target to whisper!"
L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
L.WhoStatus_Offline = "%s is currently offline."
L.WhoStatus_PlayingOtherGame = "%s is currently playing %s."

------------------------------------------------------------------------
-- German
-- Contributors: acer, bigx2, pas06, staratnight, Tumbleweed_DSA
-- Last updated: 2015-12-09
------------------------------------------------------------------------

if LOCALE == "deDE" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Chat"
C.General         = "Allgemein"
C.LocalDefense    = "LokaleVerteidigung"
C.LookingForGroup = "SucheNachGruppe"
C.Trade           = "Handel"
C.WorldDefense    = "WeltVerteidigung"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation     = "C"
S.General          = "A"
S.LocalDefense     = "LV"
S.LookingForGroup  = "LFG"
S.Trade            = "H"
S.WorldDefense     = "GV"

S.Guild              = "G"
S.InstanceChat       = "I"
S.InstanceChatLeader = "IF"
S.Officer            = "O"
S.Party              = "G"
S.PartyGuide         = "GL"
S.PartyLeader        = "GL"
S.Raid               = "SZ"
S.RaidLeader         = "SZL"
S.RaidWarning        = "SZW"
S.Say                = "S"
S.WhisperIncoming    = "W"
S.WhisperOutgoing    = "@"
S.Yell               = "S"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Kampf"

-- Options Panel
L.All = "Alle"
L.Default = "Standard"
L.EnableArrows = "Pfeiltasten aktivieren"
L.EnableArrows_Desc = "Aktiviert die Pfeiltasten im Eingabefeld des Chats."
L.EnableResizeEdges = "An allen Ecken veränderbar aktivieren"
L.EnableResizeEdges_Desc = "Aktivieren, um die Größe des Chatfenster an allen Ecken zu verändern, anstatt nur in der unteren rechten Ecke."
L.EnableSticky = "Channel merken"
L.EnableSticky_Desc = "Festlegen, welche Channels gemerkt werden sollen."
L.FadeTime = "Ausblenden des Textes"
L.FadeTime_Desc = "Zeit bis zum Ausblenden des Textes in Minuten (0 = deaktiviert)."
L.FontSize = "Schriftgröße"
L.FontSize_Desc = "Schriftgröße für alle Chatfenster festlegen."
L.FontSize_Note = "Beachte, dass dies nur eine Kurzform zum Konfigurieren jedes einzelnen Chatfensters durch die Blizzard-Chatoptionen ist."
L.HideButtons = "Buttons verbergen"
L.HideButtons_Desc = "Verbirgt das Chatfenstermenü und die Scroll-Buttons."
L.HideFlash = "Blinken der Tabs verbergen"
L.HideFlash_Desc = "Deaktiviert das Blinken der Chat-Tabs, bei denen eine neue Nachricht erhalten wurde."
L.HideNotices = "Meldungen verbergen"
L.HideNotices_Desc = "Channel-Meldungen verbergen"
L.HidePetCombatLog = "Haustierkampflog deaktivieren"
L.HidePetCombatLog_Desc = "Verhindert, dass ein neues Kampflogfenster für Haustierkämpfe geöffnet wird."
L.HideRepeats = "Wiederholungen verbergen"
L.HideRepeats_Desc = "Nachrichten, die in öffentlichen Channels wiederholt werden, verbergen."
L.HideTextures = "Extra-Texturen verbergen"
L.HideTextures_Desc = "Verbirgt Extra-Texturen der Chat-Tabs und dem Chat-Eingabefeld, die in Patch 3.3.5 hinzugefügt wurden."
L.LinkURLs = "URLs verlinken"
L.LinkURLs_Desc = "URLs im Chat für einfaches Kopieren anklickbar machen."
L.LockTabs = "Angedockte Tabs sperren"
L.LockTabs_Desc = "Verhindert, dass angedockte Tabs verschoben werden. Zum Verschieben die ALT-Taste gedrückt halten."
L.MoveEditBox = "Eingabefeld verschieben"
L.MoveEditBox_Desc = "Das Eingabefeld über dem Chatfenster anzeigen."
L.None = "Keine"
L.OptionLocked = "Diese Option ist von PhanxChat gesperrt. Benutze stattdessen die %q Option in PhanxChat."
L.OptionLockedConditional = "Diese Option ist von PhanxChat gesperrt. Wenn du sie ändern möchtest, musst du zunächst die Option %q in PhanxChat deaktivieren."
L.RemoveRealmNames = "Servernamen entfernen"
L.RemoveRealmNames_Desc = "Kürze die Spielernamen, indem der Servername entfernt wird."
L.ReplaceRealNames = "Realnamen ersetzen"
L.ReplaceRealNames_Desc = "Ersetzt, wenn möglich, die Real-ID-Namen und BattleTags mit den WoW-Charakternamen."
L.ShortenChannelNames = "Channelnamen abkürzen"
L.ShortenChannelNames_Desc = "Abkürzen der Channelnamen und Chat-Bezeichnungen."
L.ShortenRealNames = "Realnamen kürzen"
L.ShortenRealNames_Desc = "Wähle, wie Real-ID-Namen gekürzt werden."
L.ShortenRealNames_UseBattleTag = "Mit dem BattleTag ersetzen"
L.ShortenRealNames_UseFirstName = "Nur den Vornamen anzeigen"
L.ShortenRealNames_UseFullName = "Den vollständigen Namen beibehalten"
L.ShowClassColors = "Klassenfarben anzeigen"
L.ShowClassColors_Desc = "Klassenfarben in allen Chatkanälen anzeigen."
L.Whisper_BadTarget = "Du kannst dieses Ziel nicht anflüstern!"
L.Whisper_NoTarget = "Du hast kein Ziel zum anflüstern!"
L.WhoStatus_Battlenet = "%s befindet sich zur Zeit in der Battle.net-Software."
L.WhoStatus_Offline = "%s ist zur Zeit offline."
L.WhoStatus_PlayingOtherGame = "%s spielt zur Zeit %s."

return end

------------------------------------------------------------------------
-- Spanish
------------------------------------------------------------------------

if LOCALE == "esES" or LOCALE == "esMX" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Conversación"
C.General         = "General"
C.LocalDefense    = "DefensaLocal"
C.LookingForGroup = "BuscarGrupo"
C.Trade           = "Comercio"
C.WorldDefense    = "DefensaGeneral"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "D"
S.General         = "G"
S.LocalDefense    = "DL"
S.LookingForGroup = "BDG"
S.Trade           = "C"
S.WorldDefense    = "DG"

S.Guild              = "H"
S.InstanceChat       = "e"
S.InstanceChatLeader = "E"
S.Officer            = "O"
S.Party              = "g"
S.PartyGuide         = "G"
S.PartyLeader        = "G"
S.Raid               = "b"
S.RaidLeader         = "B"
S.RaidWarning        = "A"
S.Say                = "d"
S.WhisperIncoming    = "S"
S.WhisperOutgoing    = "@"
S.Yell               = "Gr"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Duelo"

-- Options Panel
L.All = "Todos"
L.Default = "Predeterminados"
L.EnableArrows = "Activar teclas de flecha"
L.EnableArrows_Desc = "Activar las teclas de flecha en el cuadro de escritura."
L.EnableResizeEdges = "Usar bordes para cambiar tamaño"
L.EnableResizeEdges_Desc = "Cambiar el tamaño la ventana de chat usando cualquiera de los bordes, en lugar de sólo la esquina inferior derecha."
L.EnableSticky = "Canales adhesivos"
L.EnableSticky_Desc = "Seleccionar cuál de los canales son adhesivos."
L.FadeTime = "Tiempo de desaparición"
L.FadeTime_Desc = "Desaparecer el texto en la ventana de chat después de estos minutos. Ajustado a 0 para para desactivar la desaparición."
L.FontSize = "Tamaño de fuente"
L.FontSize_Desc = "Ajustar el tamaño de fuente para todas las ventanas de chat."
L.FontSize_Note = "Observe que esto es simplemente un acceso rápido para configurar todas las ventanas de chat por separado en las opciones de chat del juego."
L.HideButtons = "Ocultar botones"
L.HideButtons_Desc = "Ocultar el botón de menú de chat y los botones de desplazamiento."
L.HideFlash = "Ocultar flash en pestaña"
L.HideFlash_Desc = "Ocultar el flash en las pestañas que reciben nuevos mensajes."
L.HideNotices = "Ocultar anuncios"
L.HideNotices_Desc = "Ocultar anuncios de canal."
L.HidePetCombatLog = "Desactivar registro de combate de mascotes"
L.HidePetCombatLog_Desc = "Evitar que se abren un nuevo registro de combate para los duelos de mascotas."
L.HideRepeats = "Ocultar repeticiones"
L.HideRepeats_Desc = "Ocultar mensajes repetidos en los canales públicos."
L.HideTextures = "Ocultar texturas extras"
L.HideTextures_Desc = "Ocultar las texturas extras en las pestañas y el cuadro de escritura, que han añadido en el Parche 3.3.5."
L.LinkURLs = "Enlazar URLs"
L.LinkURLs_Desc = "Cambiar a enlanes los URLs en mensajes de chat, para copiar fácilmente."
L.LockTabs = "Bloquear pestañas"
L.LockTabs_Desc = "Evitar arrastrar las pestañas de chat a menos que pulsas la tecla Mayús."
L.MoveEditBox = "Mover cuadro de escritura"
L.MoveEditBox_Desc = "Mover el cuadro de escritura a la parte superior de la ventana de chat."
L.None = "Ningunos"
L.OptionLocked = "Esta opción está bloqueado por PhanxChat. Use la opción %q de PhanxChat en vez."
L.OptionLockedConditional = "Esta opción está bloqueado por PhanxChat. Para cambiarlo, primero desactive la opción %q de PhanxChat."
L.RemoveRealmNames = "Eliminar nombres de reinos"
L.RemoveRealmNames_Desc = "Eliminar de los nombres de personajes los nombres de reinos."
L.ReplaceRealNames = "Reemplazar nombres reales"
L.ReplaceRealNames_Desc = "Reemplazar con los nombres de personajes los BattleTags y los nombres de amigos con ID real."
L.ShortenChannelNames = "Acortar nombres de canales"
L.ShortenChannelNames_Desc = "Acortar los nombres de los canales de chat."
L.ShortenRealNames = "Acortar nombres reales"
L.ShortenRealNames_Desc = "Seleccionar cómo acortar los nombres reales, o no."
L.ShortenRealNames_UseBattleTag = "Reemplazar con BattleTag"
L.ShortenRealNames_UseFirstName = "Sólo el nombre de pila"
L.ShortenRealNames_UseFullName = "Mantenga el nombre completo"
L.ShowClassColors = "Colores de clase"
L.ShowClassColors_Desc = "Mostrar colores de clase en todas las canales."
L.Whisper_BadTarget = "No es posible susurrar a ese objetivo!"
L.Whisper_NoTarget = "No es posible susurrar a ningún objetivo!"
L.WhoStatus_Battlenet = "%s está en la Battle.net Desktop App."
L.WhoStatus_Offline = "%s está desconectado."
L.WhoStatus_PlayingOtherGame = "%s está jugando a %s."

return end

------------------------------------------------------------------------
-- French
-- Contributors: aktaurus, braincell, L0relei
-- Last updated: 2015-04-08
------------------------------------------------------------------------

if LOCALE == "frFR" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Conversation"
C.General         = "Général"
C.LocalDefense    = "DéfenseLocale"
C.LookingForGroup = "RechercheDeGroupe"
C.Trade           = "Commerce"
C.WorldDefense    = "DéfenseUniverselle"

-- Abbreviated Channel Names
-- These should be one- or two-character abbreviations.
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

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Combat"

-- Options Panel
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
L.HidePetCombatLog = "Désactiver le journal de combat des familiers"
L.HidePetCombatLog_Desc = "Empêche la fenêtre de discussion d'ouvrir un journal de combat pour les combats de familiers."
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

return end

------------------------------------------------------------------------
-- Italian
-- Contributors: alar
-- Lad updated: 2015-03-17
------------------------------------------------------------------------

if LOCALE == "itIT" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Conversazione"
C.General         = "Generale"
C.LocalDefense    = "DifesaLocale"
C.LookingForGroup = "CercaGruppo"
C.Trade           = "Commercio"
C.WorldDefense    = "DifesaMondiale"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "BN"
S.General         = "G"
S.LocalDefense    = "DL"
S.LookingForGroup = "CG"
S.Trade           = "C"
S.WorldDefense    = "DM"

S.Guild              = "G"
S.InstanceChat       = "i"
S.InstanceChatLeader = "Ci"
S.Officer            = "Uf"
S.Party              = "Gr"
S.PartyGuide         = "GS"
S.PartyLeader        = "CG"
S.Raid               = "I"
S.RaidLeader         = "CI"
S.RaidWarning        = "AI"
S.Say                = "D"
S.WhisperIncoming    = "Sd"
S.WhisperOutgoing    = "Sa"
S.Yell               = "Ur"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Scontro"

-- Options Panel
--L.All = "All"
--L.Default = "Default"
L.EnableArrows = "Abilita Tasti Freccia"
--L.EnableArrows_Desc = "Enable arrow keys in the chat edit box."
--L.EnableResizeEdges = "Enable resize edges"
--L.EnableResizeEdges_Desc = "Enable resize controls at all edges of chat frames, instead of only the bottom right corner."
--L.EnableSticky = "Sticky chat"
--L.EnableSticky_Desc = "Set which chat types should be sticky."
--L.FadeTime = "Fade time"
--L.FadeTime_Desc = "Set the time, in minutes, to wait before fading chat text. A setting of 0 will disable fading."
--L.FontSize = "Font size"
--L.FontSize_Desc = "Set the font size for all chat frames."
--L.FontSize_Note = "Note that this is just a shortcut to configuring each chat frame individually through the Blizzard chat options."
--L.HideButtons = "Hide buttons"
--L.HideButtons_Desc = "Hide the chat frame menu and scroll buttons."
--L.HideFlash = "Hide tab flash"
--L.HideFlash_Desc = "Disable the flashing effect on chat tabs that receive new messages."
--L.HideNotices = "Hide notices"
--L.HideNotices_Desc = "Hide channel notification messages."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
--L.HideRepeats = "Hide repeats"
--L.HideRepeats_Desc = "Hide repeated messages in public channels."
--L.HideTextures = "Hide extra textures"
--L.HideTextures_Desc = "Hide the extra textures on chat tabs and chat edit boxes added in patch 3.3.5."
--L.LinkURLs = "Link URLs"
--L.LinkURLs_Desc = "Transform URLs in chat into clickable links for easy copying."
--L.LockTabs = "Lock docked tabs"
--L.LockTabs_Desc = "Prevent docked chat tabs from being dragged unless the Shift key is down."
--L.MoveEditBox = "Move edit boxes"
--L.MoveEditBox_Desc = "Move chat edit boxes to the top their respective chat frames."
--L.None = "None"
--L.OptionLocked = "This option is locked by PhanxChat. Use the %q option in PhanxChat instead."
--L.OptionLockedConditional = "This option is locked by PhanxChat. If you wish to change it, you must first disable the %q option in PhanxChat."
--L.RemoveRealmNames = "Remove realm names"
--L.RemoveRealmNames_Desc = "Shorten player names by removing realm names."
--L.ReplaceRealNames = "Replace real names"
--L.ReplaceRealNames_Desc = "Replace Real ID names and BattleTags with WoW character names when possible."
--L.ShortenChannelNames = "Short channel names"
--L.ShortenChannelNames_Desc = "Shorten channel names and chat strings."
--L.ShortenRealNames = "Shorten real names"
--L.ShortenRealNames_Desc = "Choose how to shorten Real ID names, if at all."
--L.ShortenRealNames_UseBattleTag = "Replace with BattleTag"
--L.ShortenRealNames_UseFirstName = "Show first name only"
--L.ShortenRealNames_UseFullName = "Keep full name"
--L.ShowClassColors = "Show class colors"
--L.ShowClassColors_Desc = "Show class colors in all channels."
--L.Whisper_BadTarget = "You can't whisper that target!"
--L.Whisper_NoTarget = "You don't have a target to whisper!"
--L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
--L.WhoStatus_Offline = "%s is currently offline."
--L.WhoStatus_PlayingOtherGame = "%s is currently playing %s."

return end

------------------------------------------------------------------------
-- Portuguese
-- Contributors: AxellSlade, mgaedke, Tercioo
------------------------------------------------------------------------

if LOCALE == "ptBR" then

C.Conversation    = "Conversa"
C.General         = "Geral"
C.LocalDefense    = "DefesaLocal"
C.LookingForGroup = "ProcurandoGrupo"
C.Trade           = "Comércio"
C.WorldDefense    = "DefesaGlobal"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "C"
S.General         = "Ge"
S.LocalDefense    = "DL"
S.LookingForGroup = "PG"
S.Trade           = "Co"
S.WorldDefense    = "DG"

S.Guild              = "Gd"
S.InstanceChat       = "I"
S.InstanceChatLeader = "LI"
S.Officer            = "O"
S.Party              = "G"
S.PartyGuide         = "LG"
S.PartyLeader        = "LG"
S.Raid               = "R"
S.RaidLeader         = "LR"
S.RaidWarning        = "AR"
S.Say                = "D"
S.WhisperIncoming    = "d"
S.WhisperOutgoing    = "p"
S.Yell               = "Gr"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Confronto"

-- Options Panel
L.All = "Todos"
L.Default = "Padrão"
L.EnableArrows = "Ativar teclas de seta"
L.EnableArrows_Desc = "Ativar as teclas de seta na caixa de entrada de mensagens de bate-papo."
L.EnableResizeEdges = "Bordas redimensionamento"
L.EnableResizeEdges_Desc = "Redimensionar a janela de bate-papo usando qualquer borda, em vez de apenas o canto direito inferior."
L.EnableSticky = "Canais fixos"
L.EnableSticky_Desc = "Definir quais os tipos de bate-papo deve ser fixa."
L.FadeTime = "Tempo para desvanecer"
L.FadeTime_Desc = "Definir o tempo, em minutos, para esperar antes de desvanecer mensagens de bate-papo. Uma configuração de 0 desativa a desvanecer."
L.FontSize = "Tamanho do texto"
L.FontSize_Desc = "Definir o tamanho da fonte para todas as janelas de bate-papo."
L.FontSize_Note = "Note que este é apenas um atalho para a configuração de cada janela de bate-papo individualmente com as opções da Blizzard."
L.HideButtons = "Ocultar botões"
L.HideButtons_Desc = "Ocultar o botão de menu e botões de rolagem de bate-papo."
L.HideFlash = "Ocultar clarão guia"
L.HideFlash_Desc = "Não clarão das guias de bate-papo que receber novas mensagens."
L.HideNotices = "Ocultar avisos"
L.HideNotices_Desc = "Ocultar mensagens de notificação de canais de bate-papo."
L.HidePetCombatLog = "Desabilita registro de batalha de mascote"
L.HidePetCombatLog_Desc = "Previne o quadro de chat de abrir o registro de combate das batalhas de mascote."
L.HideRepeats = "Ocultar repetições"
L.HideRepeats_Desc = "Ocultar mensagens repetidas nos canais públicos de bate-papo."
L.HideTextures = "Ocultar texturas extras"
L.HideTextures_Desc = "Ocultar as texturas extras em guias de bate-papo e caixas de entrada de mensagem adicionados no patch 3.3.5."
L.LinkURLs = "URLs ligação"
L.LinkURLs_Desc = "Transformar URLs no bate-papo em hyperlinks clicáveis ​​para facilitar a cópia."
L.LockTabs = "Travar guias acopladas"
L.LockTabs_Desc = "Só permitem arrastar guias acoplado de bate-papo quando a tecla Shift é pressionada."
L.MoveEditBox = "Mover caixas mensagens"
L.MoveEditBox_Desc = "Mover caixas de entrada de mensagens de bate-papo para o topo da sua respectice janelas de chat."
L.None = "Nenhum"
L.OptionLocked = "Esta opção está bloqueado por PhanxChat. Use a opção %q em PhanxChat em vez."
L.OptionLockedConditional = "Esta opção está bloqueado por PhanxChat. Se você deseja mudá-lo, você deve primeiro desativar a opção %q em PhanxChat."
L.RemoveRealmNames = "Remover nomes de reinos"
L.RemoveRealmNames_Desc = "Encurtar os nomes dos jogadores através da remoção de nomes de reinos."
L.ReplaceRealNames = "Substituir nomes reais"
L.ReplaceRealNames_Desc = "Substituir nomes Real ID com nomes de personagens."
L.ShortenChannelNames = "Curto nomes canais"
L.ShortenChannelNames_Desc = "Encurtar os nomes dos canais de bate-papo."
L.ShortenRealNames = "Abreviar nomes verdadeiros"
L.ShortenRealNames_Desc = "Escolha o método para diminuir o tamanho dos nomes da Real ID."
L.ShortenRealNames_UseBattleTag = "Substituir pela BattleTag"
L.ShortenRealNames_UseFirstName = "Mostrar apenas o primeiro nome"
L.ShortenRealNames_UseFullName = "Manter o nome completo"
L.ShowClassColors = "Cores das classes"
L.ShowClassColors_Desc = "Mostrar cores das classes em todos os canais."
L.Whisper_BadTarget = "Você não pode sussurrar este alvo!"
L.Whisper_NoTarget = "Você não possui um alvo para sussurrar!"
L.WhoStatus_Battlenet = "%s está no aplicativo da Battle.net."
L.WhoStatus_Offline = "%s não está online."
L.WhoStatus_PlayingOtherGame = "%s está jogando %s."

return end

------------------------------------------------------------------------
-- Russian
-- Contributors: hungry2, Yafis
------------------------------------------------------------------------

if LOCALE == "ruRU" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "Разговор"
C.General         = "Общий"
C.LocalDefense    = "ОборонаЛокальный"
C.LookingForGroup = "ПоискСпутников"
C.Trade           = "Торговля"
C.WorldDefense    = "ОборонаГлобальный"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "Ра"
S.General         = "О"
S.LocalDefense    = "ОЛ"
S.LookingForGroup = "ПС"
S.Trade           = "Т"
S.WorldDefense    = "ОГ"

S.Guild              = "Г"
S.InstanceChat       = "П"
S.InstanceChatLeader = "ЛП"
S.Officer            = "Оф"
S.Party              = "Гр"
S.PartyGuide         = "ГрЛ"
S.PartyLeader        = "ГрЛ"
S.Raid               = "Р"
S.RaidLeader         = "РЛ"
S.RaidWarning        = "РВ"
S.Say                = "С"
S.WhisperIncoming    = "Ш"
S.WhisperOutgoing    = "@"
S.Yell               = "К"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = "Битва"

-- Options Panel
L.All = "Все"
L.Default = "По умолчанию"
L.EnableArrows = "Включить стрелки"
L.EnableArrows_Desc = "Использовать стрелки курсора в окне редактирования сообщения."
L.EnableResizeEdges = "Включить рамку размера"
L.EnableResizeEdges_Desc = "Включить рамку изменения размера окна чата, вместо только нижнего правого угла."
L.EnableSticky = "Запоминать последний ввод"
L.EnableSticky_Desc = "Установить какие типы чата должны запоминать последний ввод, быть \"липкими\"."
L.FadeTime = "Время угасания"
L.FadeTime_Desc = "Установить время в минутах перед угасанием чата. Установив значение в 0 вы отмените угасание."
L.FontSize = "Размер шрифта"
L.FontSize_Desc = "Установить размер шрифта для всех окон чата."
L.FontSize_Note = "Заметьте, что это просто настраивает каждую вкладку индивидуально, как вы могли бы сделать обычным способом, через управление чатом в меню."
L.HideButtons = "Скрыть кнопки"
L.HideButtons_Desc = "Скрыть кнопку \"Общение\" и кнопки прокрутки."
L.HideFlash = "Скрыть мигание вкладок"
L.HideFlash_Desc = "Отключить мигание вкладок с новыми сообщениями."
L.HideNotices = "Скрыть уведомления"
L.HideNotices_Desc = "Скрывать информационные сообщения канала."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "Скрыть повторы"
L.HideRepeats_Desc = "Скрывать повторяющиеся сообщения в общих каналах."
L.HideTextures = "Скрыть текстуры"
L.HideTextures_Desc = "Скрыть дополнительные текстуры вкладок и окна ввода сообщения, добавленныe а патче 3.3.5."
L.LinkURLs = "Копирование ссылок"
L.LinkURLs_Desc = "Превратить ссылки в чате в кликабельные для простоты копирования."
L.LockTabs = "Зафиксировать вкладки"
L.LockTabs_Desc = "Запретить перетаскивание зафиксированных вкладок без зажатого Shift."
L.MoveEditBox = "Переместить окно ввода"
L.MoveEditBox_Desc = "Переместить окно ввода наверх окна чата."
L.None = "Никакие"
L.OptionLocked = "Эта опция заблокирована PhanxChat. Используйте опцию %q в PhanxChat."
L.OptionLockedConditional = "Эта опция заблокирована в PhanxChat. Если вы хотите включить ее то вы должны сначала отключить опцию %q в PhanxChat."
L.RemoveRealmNames = "Удалять название игрового мира"
L.RemoveRealmNames_Desc = "Укоротить имена игроков удалив название игрового мира."
L.ReplaceRealNames = "Заменить реальное имя"
L.ReplaceRealNames_Desc = "Заменять Real ID имена на имена персонажей."
L.ShortenChannelNames = "Короткие имена каналов"
L.ShortenChannelNames_Desc = "Сокращать имена каналов и строчки чата."
L.ShortenRealNames = "Сократить реальные имена"
--L.ShortenRealNames_Desc = "Choose how to shorten Real ID names, if at all."
L.ShortenRealNames_UseBattleTag = "Заменить BattleTag"
L.ShortenRealNames_UseFirstName = "Показывать только имя"
L.ShortenRealNames_UseFullName = "Сохранять полное имя"
L.ShowClassColors = "Отображать цвета классов"
L.ShowClassColors_Desc = "Отображать цвет классов во всех каналах."
L.Whisper_BadTarget = "Вы не можете прошептать цели!"
L.Whisper_NoTarget = "У вас нет цели для шепота!"
L.WhoStatus_Battlenet = "%s находиться в клиенте Battle.net."
L.WhoStatus_Offline = "%s игрок оффлайн."
L.WhoStatus_PlayingOtherGame = "%s в данный момент играет %s."

return end

------------------------------------------------------------------------
-- Korean
-- Contributors: talkswind
------------------------------------------------------------------------

if LOCALE == "koKR" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "대화"
C.General         = "공개"
C.LocalDefense    = "수비"
C.LookingForGroup = "파티찾기"
C.Trade           = "거래"
C.WorldDefense    = "전쟁"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "대화"
S.General         = "공"
S.LocalDefense    = "수"
S.LookingForGroup = "파찾"
S.Trade           = "거"
S.WorldDefense    = "쟁"

S.Guild              = "길"
S.InstanceChat       = "인던"
S.InstanceChatLeader = "인던장"
S.Officer            = "관"
S.Party              = "파"
S.PartyGuide         = "파장"
S.PartyLeader        = "파장"
S.Raid               = "공"
S.RaidLeader         = "공대"
S.RaidWarning        = "공경"
S.Say                = "일"
S.WhisperIncoming    = "귓받"
S.WhisperOutgoing    = "귓전"
S.Yell               = "외"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

-- Options Panel
L.All = "모두"
L.Default = "기본값"
L.EnableArrows = "화살표 키 활성화"
L.EnableArrows_Desc = "대화 입력 박스에서 화살표 키를 활성화합니다."
L.EnableResizeEdges = "구석 크기 조절 활성화"
L.EnableResizeEdges_Desc = "하단 오른쪽 모서리에 한정 된 것이 아닌, 모든 대화창 구석에서의 크기 조절을 활성화합니다."
L.EnableSticky = "채널 고정"
L.EnableSticky_Desc = "어떤 유형의 채널을 고정할 것인지를 설정합니다."
L.FadeTime = "사라짐 시간"
L.FadeTime_Desc = "대화 메시지가 사라지기 전에 기다려야 할 분단위 시간을 설정합니다. 이것을 0으로 설정하면 사라짐 기능을 비활성화하게 됩니다."
L.FontSize = "글꼴 크기"
L.FontSize_Desc = "대화창 모두에 적용할 글꼴 크기를 설정합니다."
L.FontSize_Note = "이것은 블리자드 대화창 옵션을 통해 각각의 대화창을 개별적으로 설정하기 위한 하나의 지름길이란 점에 유의하십시요."
L.HideButtons = "버튼 숨김"
L.HideButtons_Desc = "대화창 메뉴와 스크롤 버튼을 숨깁니다."
L.HideFlash = "탭 번쩍임 숨김"
L.HideFlash_Desc = "새로운 메시지를 받은 경우에 대화창 탭에서의 번쩍임 효과를 비활성화합니다."
L.HideNotices = "알림 메시지 숨김"
L.HideNotices_Desc = "채널 알림 메시지를 숨깁니다."
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "반복 메시지 숨김"
L.HideRepeats_Desc = "공용 채널에서 반복되는 메시지를 숨깁니다."
L.HideTextures = "별도의 텍스쳐 숨김"
L.HideTextures_Desc = "3.3.5. 패치에서 대화창 탭과 편집 박스에 추가된 별도의 텍스쳐를 숨깁니다."
L.LinkURLs = "URL 링크"
L.LinkURLs_Desc = "대화 메시지에서 쉬운 복사를 위해 클릭이 가능한 링크로 URL을 변환합니다."
L.LockTabs = "고정된 탭 잠금"
L.LockTabs_Desc = "고정된 대화창 탭을 Shift 키를 누르지 않고도 잡아 끌 수 있는 것을 방지합니다."
L.MoveEditBox = "대화 입력 박스 이동"
L.MoveEditBox_Desc = "대화 입력 박스를 그것의 각각의 대화창의 상단으로 이동합니다."
L.None = "없음"
--L.OptionLocked = "This option is locked by PhanxChat. Use the %q option in PhanxChat instead."
--L.OptionLockedConditional = "This option is locked by PhanxChat. If you wish to change it, you must first disable the %q option in PhanxChat."
--L.RemoveRealmNames = "Remove realm names"
--L.RemoveRealmNames_Desc = "Shorten player names by removing realm names."
L.ReplaceRealNames = "서버 이름 대체"
L.ReplaceRealNames_Desc = "캐릭터 이름으로 실제 ID 이름을 대체합니다."
L.ShortenChannelNames = "채널 이름 줄임"
L.ShortenChannelNames_Desc = "채널 이름과 대화 구문열을 줄입니다."
--L.ShortenRealNames = "Shorten real names"
--L.ShortenRealNames_Desc = "Choose how to shorten Real ID names, if at all."
--L.ShortenRealNames_UseBattleTag = "Replace with BattleTag"
--L.ShortenRealNames_UseFirstName = "Show first name only"
--L.ShortenRealNames_UseFullName = "Keep full name"
--L.ShowClassColors = "Show class colors"
--L.ShowClassColors_Desc = "Show class colors in all channels."
--L.Whisper_BadTarget = "You can't whisper that target!"
--L.Whisper_NoTarget = "You don't have a target to whisper!"
--L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
--L.WhoStatus_Offline = "%s is currently offline."
--L.WhoStatus_PlayingOtherGame = "%s is currently playing %s."

return end

------------------------------------------------------------------------
-- Simplified Chinese
-- Contributors: bone_cures, tss1398383123
-- Last updated: 2015-01-05
------------------------------------------------------------------------

if LOCALE == "zhCN" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "对话"
C.General         = "综合"
C.LocalDefense    = "本地防务"
C.LookingForGroup = "寻求组队"
C.Trade           = "交易"
C.WorldDefense    = "世界防务"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "话"
S.General         = "综"
S.LocalDefense    = "本"
S.LookingForGroup = "寻"
S.Trade           = "交"
S.WorldDefense    = "世"

S.Guild              = "公"
S.InstanceChat       = "副本"
S.InstanceChatLeader = "副本首"
S.Officer            = "官"
S.Party              = "队"
S.PartyGuide         = "领队"
S.PartyLeader        = "队首"
S.Raid               = "团"
S.RaidLeader         = "领"
S.RaidWarning        = "团警"
S.Say                = "说"
S.WhisperIncoming    = "密自"
S.WhisperOutgoing    = "密往"
S.Yell               = "喊"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

-- Options Panel
L.All = "所有"
L.Default = "默认"
L.EnableArrows = "输入框中使用方向键"
L.EnableArrows_Desc = "允许在输入框中使用方向键。"
L.EnableResizeEdges = "开启边缘调整"
L.EnableResizeEdges_Desc = "开启聊天框边缘调整，而不只是在右下角调整。"
L.EnableSticky = "保持聊天频道与类型"
L.EnableSticky_Desc = "设定哪一聊天输出频道将被保持。"
L.FadeTime = "渐隐时间"
L.FadeTime_Desc = "设置文本消失时间，设为0将不消失。"
L.FontSize = "字体大小"
L.FontSize_Desc = "为所有聊天框设置字体大小。"
L.FontSize_Note = "注意，这只是链接到暴雪每个单独的聊天框设置的快捷方式。"
L.HideButtons = "隐藏按钮"
L.HideButtons_Desc = "隐藏聊天框菜单和滚动按钮。"
L.HideFlash = "隐藏标签闪烁"
L.HideFlash_Desc = "禁用聊天框收到消息后标签的闪烁效果。"
L.HideNotices = "隐藏警告"
L.HideNotices_Desc = "隐藏聊天框内的警告信息。"
L.HidePetCombatLog = "禁用宠物战斗纪录"
L.HidePetCombatLog_Desc = "阻止聊天框为一场宠物战斗开启战斗纪录。"
L.HideRepeats = "屏蔽重复信息"
L.HideRepeats_Desc = "屏蔽公共频道中的重复刷屏信息。"
L.HideTextures = "隐藏额外材质"
L.HideTextures_Desc = "隐藏在3.3.5中为聊天框标签和聊天输入框额外加入的材质。"
L.LinkURLs = "URL链接快速复制"
L.LinkURLs_Desc = "被点击的URL内容将被递交到聊天输入框以便复制。"
L.LockTabs = "隐藏附着标签"
L.LockTabs_Desc = "锁定已附着的聊天标签（按住Shift移动）。"
L.MoveEditBox = "移动聊天输入框"
L.MoveEditBox_Desc = "移动聊天输入框到该信息框顶部。"
L.None = "无"
L.OptionLocked = "此选项已被 PhanxChat 锁定。使用 PhanxChat 的 %q 选项代替。"
L.OptionLockedConditional = "此选项被 PhanxChat 锁定。如果你想改变设置，必须先在 PhanxChat 里禁用 %q 选项。"
L.RemoveRealmNames = "移除服务器名"
L.RemoveRealmNames_Desc = "移除玩家服务器名来缩短名字长度。"
L.ReplaceRealNames = "替换玩家实名"
L.ReplaceRealNames_Desc = "以玩家角色名替换显示战网实名。"
L.ShortenChannelNames = "缩短频道名"
L.ShortenChannelNames_Desc = "缩短频道名和聊天类型名。"
L.ShortenRealNames = "缩短玩家实名"
L.ShortenRealNames_Desc = "如果可行，选择如何去缩短玩家实名。"
L.ShortenRealNames_UseBattleTag = "用战网昵称代替"
L.ShortenRealNames_UseFirstName = "只显示角色名"
L.ShortenRealNames_UseFullName = "保持全名"
L.ShowClassColors = "显示职业颜色"
L.ShowClassColors_Desc = "在所有频道显示职业颜色。"
L.Whisper_BadTarget = "你无法密语此目标！"
L.Whisper_NoTarget = "你无法在没有目标时密语！"
L.WhoStatus_Battlenet = "%s 战网桌面客户端在线。"
L.WhoStatus_Offline = "%s 离线。"
L.WhoStatus_PlayingOtherGame = "%s 在线 %s。"

return end

------------------------------------------------------------------------
-- Traditional Chinese
-- Contributors: BNSSNB, yunrong
------------------------------------------------------------------------

if LOCALE == "zhTW" then

-- Channel Names
-- Must match the default channel names shown in your game client.
C.Conversation    = "對話"
C.General         = "綜合"
C.LocalDefense    = "本地防務"
C.LookingForGroup = "尋求組隊"
C.Trade           = "交易"
C.WorldDefense    = "世界防務"

-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
S.Conversation    = "話"
S.General         = "綜"
S.LocalDefense    = "本"
S.LookingForGroup = "尋"
S.Trade           = "交"
S.WorldDefense    = "世"

S.Guild              = "公"
S.InstanceChat       = "副"
S.InstanceChatLeader = "領"
S.Officer            = "官"
S.Party              = "隊"
S.PartyGuide         = "領"
S.PartyLeader        = "領"
S.Raid               = "團"
S.RaidLeader         = "領"
S.RaidWarning        = "警"
S.Say                = "說"
S.WhisperIncoming    = "自"
S.WhisperOutgoing    = "往"
S.Yell               = "喊"

-- Miscellaneous
S.PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG -- default is ok

-- Options Panel
L.All = "所有"
L.Default = "預設"
L.EnableArrows = "輸入框中使用方向鍵"
L.EnableArrows_Desc = "允許在輸入框中使用方向鍵。"
L.EnableResizeEdges = "開啟邊緣調整"
L.EnableResizeEdges_Desc = "開啟聊天框邊緣調整，而不只是在右下角調整。"
L.EnableSticky = "保持聊天頻道與類型"
L.EnableSticky_Desc = "設定哪一聊天輸出頻道將被保持。"
L.FadeTime = "漸隱時間"
L.FadeTime_Desc = "設置文字消失時間，以分為單位，設為0將不消失。"
L.FontSize = "字體大小"
L.FontSize_Desc = "為所有聊天框設置字體大小。"
L.FontSize_Note = "注意，這只是連結到暴雪每個單獨的聊天框設置的快捷方式。"
L.HideButtons = "隱藏按鈕"
L.HideButtons_Desc = "隱藏聊天視窗選單和滾動按鈕。"
L.HideFlash = "隱藏標籤閃爍"
L.HideFlash_Desc = "禁用聊天框收到消息後標籤的閃爍效果。"
L.HideNotices = "隱藏警告"
L.HideNotices_Desc = "隱藏聊天框內的警告訊息。"
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
L.HideRepeats = "隱藏重複訊息"
L.HideRepeats_Desc = "隱藏公共頻道中的重複刷頻訊息。"
L.HideTextures = "隱藏額外材質"
L.HideTextures_Desc = "隱藏在3.3.5中為聊天框標籤和聊天輸入框額外加入的材質。"
L.LinkURLs = "URL連結快速複製"
L.LinkURLs_Desc = "轉換聊天中的URL為可點擊的連結以便複製。"
L.LockTabs = "鎖定附著標籤"
L.LockTabs_Desc = "鎖定已附著的聊天標籤（按住Shift移動）。"
L.MoveEditBox = "移動聊天輸入框"
L.MoveEditBox_Desc = "移動聊天輸入框到該訊息框頂部。"
L.None = "無"
L.OptionLocked = "此選項已由PhanxChat鎖定。使用PhanxChat中的 %q 選項來替代。"
L.OptionLockedConditional = "此選項已由PhanxChat鎖定。如果你想要改動，你必須先取消PhanxChat中 %q 的選項。"
L.RemoveRealmNames = "移除伺服器名稱"
L.RemoveRealmNames_Desc = "移除伺服器名稱以縮短玩家名稱。"
L.ReplaceRealNames = "替換玩家實名"
L.ReplaceRealNames_Desc = "以玩家角色名取代顯示戰網ID。"
L.ShortenChannelNames = "縮短頻道名"
L.ShortenChannelNames_Desc = "縮短頻道名和聊天類型名。"
L.ShortenRealNames = "縮短玩家實名"
L.ShortenRealNames_Desc = "選擇如何縮短玩家實名，如果是所有。"
L.ShortenRealNames_UseBattleTag = "替換為BattleTag"
L.ShortenRealNames_UseFirstName = "僅顯示姓"
L.ShortenRealNames_UseFullName = "保留全名"
L.ShowClassColors = "顯示職業顏色"
L.ShowClassColors_Desc = "顯示職業顏色在所有頻道。"
L.Whisper_BadTarget = "你無法密語目標! "
L.Whisper_NoTarget = "你沒有目標可密語!"
--L.WhoStatus_Battlenet = "%s is currently in the Battle.net Desktop App."
L.WhoStatus_Offline = "%s 目前為離線。"
L.WhoStatus_PlayingOtherGame = "%s 目前正在玩 %s。"

return end
