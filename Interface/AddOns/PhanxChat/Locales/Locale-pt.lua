--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
------------------------------------------------------------------------
	Portuguese localization
	See the end of this file for a complete list of translators.
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^pt") then return end
local _, PhanxChat = ...
local C, S, L = PhanxChat.ChannelNames, PhanxChat.ShortStrings, PhanxChat.L

------------------------------------------------------------------------
--	Channel Names
--	Must match the default channel names shown in your game client.
------------------------------------------------------------------------

C.Conversation    = "Conversa"
C.General         = "Geral"
C.LocalDefense    = "DefesaLocal"
C.LookingForGroup = "ProcurandoGrupo"
C.Trade           = "Comércio"
C.WorldDefense    = "DefesaGlobal"

------------------------------------------------------------------------
-- Short Channel Names
-- Use the shortest abbreviations that make sense in your language.
------------------------------------------------------------------------

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

S.PET_BATTLE_COMBAT_LOG = "Confronto"

------------------------------------------------------------------------
-- Options Panel
------------------------------------------------------------------------

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
--L.HidePetCombatLog = "Disable pet battle log"
--L.HidePetCombatLog_Desc = "Prevent the chat frame from opening a combat log for pet battles."
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

--[[--------------------------------------------------------------------
	Special thanks to the following people who have contributed
	Portuguese translations for PhanxChat:
	- mgaedke @ Curse
	- Tercioo @ Curse
----------------------------------------------------------------------]]