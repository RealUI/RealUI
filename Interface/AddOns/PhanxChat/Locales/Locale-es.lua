--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Spanish localization
	***
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^es") then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "Conversación"
C.General         = "General"
C.LocalDefense    = "DefensaLocal"
C.LookingForGroup = "BuscarGrupo"
C.Trade           = "Comercio"
C.WorldDefense    = "DefensaGeneral"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

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

S.PET_BATTLE_COMBAT_LOG = "Duelo"

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

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