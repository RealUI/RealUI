local bugGrabberParentAddon, parentAddonTable = ...
local addon = parentAddonTable.BugGrabber
-- Bail out in case we didn't load up for some reason, which
-- happens for example when an embedded BugGrabber finds a
-- standalone !BugGrabber addon.
if not addon then return end

-- We don't need to bail out here if BugGrabber has been loaded from
-- some other embedding addon already, because :LoadTranslations is
-- only invoked on login. All we do is replace the method with a new
-- one that will never be invoked.

function addon:LoadTranslations(locale, L)
	if locale == "koKR" then
L["ADDON_CALL_PROTECTED"] = "[%s] \236\149\160\235\147\156\236\152\168 '%s' \235\179\180\237\152\184\235\144\156 \237\149\168\236\136\152 \237\152\184\236\182\156 '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (\236\149\160\235\147\156\236\152\168 '.*' \235\179\180\237\152\184\235\144\156 \237\149\168\236\136\152 \237\152\184\236\182\156 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r\236\153\128 |cffffff7f%s|r\235\138\148 \237\149\168\234\187\152 \234\179\181\236\161\180\237\149\160 \236\136\152 \236\151\134\236\138\181\235\139\136\235\139\164. |cffffff7f%s|r\236\151\144 \236\157\152\237\149\180 \236\164\145\236\167\128\235\144\152\236\151\136\236\138\181\235\139\136\235\139\164. \235\167\140\236\149\189 \235\139\185\236\139\160\236\157\180 \236\155\144\237\149\152\235\169\180, \236\160\145\236\134\141\236\157\132 \236\162\133\235\163\140\237\149\156 \237\155\132, |cffffff7fBugGrabber|r\235\165\188 \236\164\145\236\167\128\237\149\152\234\179\160 |cffffff7f%s|r\235\165\188 \236\158\172\237\153\156\236\132\177\237\149\152\236\132\184\236\154\148."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r\234\176\128 \235\139\164\236\139\156 \236\152\164\235\165\152\235\165\188 \236\186\161\236\179\144\237\149\169\235\139\136\235\139\164."
L["BUGGRABBER_STOPPED"] = "\236\157\180\234\178\131\236\157\128 \236\180\136\235\139\185 %d\234\176\156 \236\157\180\236\131\129\236\157\152 \236\152\164\235\165\152\235\165\188 \235\176\156\234\178\172\237\149\152\236\152\128\234\184\176\236\151\144 |cffffff7fBugGrabber|r\236\157\152 \236\152\164\235\165\152 \236\186\161\236\179\144\234\176\128 \236\164\145\236\167\128\235\144\152\236\151\136\236\156\188\235\169\176, \236\186\161\236\179\144\235\138\148 %d\236\180\136 \237\155\132 \236\158\172\234\176\156\235\144\169\235\139\136\235\139\164."
L["CMD_CREATED"] = "\236\152\164\235\165\152\234\176\128 \235\176\156\234\178\172\235\144\152\236\151\136\236\156\188\235\169\176, /buggrabber\235\165\188 \236\130\172\236\154\169\237\149\152\236\151\172 \236\182\156\235\160\165\237\149\160 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164."
L["ERROR_INDEX"] = "\236\131\137\236\157\184\234\176\146\236\157\128 \236\136\171\236\158\144\236\157\180\236\150\180\236\149\188 \237\149\169\235\139\136\235\139\164."
L["ERROR_UNKNOWN_INDEX"] = "\235\182\136\235\159\172\236\152\168 \236\152\164\235\165\152 \235\170\169\235\161\157\236\151\144 %d\235\178\136\236\167\184 \236\152\164\235\165\152\235\138\148 \236\161\180\236\158\172\237\149\152\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164."
L["NO_DISPLAY_1"] = "|cffff4411\235\139\185\236\139\160\236\157\128 \235\175\184\237\145\156\236\139\156 \236\149\160\235\147\156\236\152\168\234\179\188 \237\149\168\234\187\152 !BugGrabber\235\165\188 \236\139\164\237\150\137\237\149\160 \234\178\131\236\156\188\235\161\156 \235\179\180\236\158\133\235\139\136\235\139\164. !BugGrabber\235\138\148 \234\178\140\236\158\132 \236\152\164\235\165\152 \237\153\149\236\157\184\236\157\132 \236\156\132\237\149\156 \236\138\172\235\158\152\236\139\156 \235\170\133\235\160\185\236\150\180\235\165\188 \236\160\156\234\179\181\237\149\152\234\179\160 \236\158\136\236\167\128\235\167\140, \237\145\156\236\139\156 \236\149\160\235\147\156\236\152\168\236\157\128 \235\139\185\236\139\160\236\157\180 \235\141\148 \237\142\184\235\166\172\237\149\156 \235\176\169\235\178\149\236\156\188\235\161\156 \236\157\180\235\159\172\237\149\156 \236\152\164\235\165\152\235\165\188 \234\180\128\235\166\172\237\149\160 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164.|r"
L["NO_DISPLAY_2"] = "|cffff4411\237\145\156\236\164\128 !BugGrabber \237\145\156\236\139\156\235\138\148|r |cff44ff44BugSack|r|cffff4411\236\156\188\235\161\156 \235\182\136\235\159\172\236\152\164\235\169\176, \234\183\184\235\166\172\234\179\160 \236\149\132\235\167\136\235\143\132 \235\139\185\236\139\160\236\157\128 !BugGrabber\235\165\188 \235\176\156\234\178\172\237\149\156 \235\143\153\236\157\188 \236\130\172\236\157\180\237\138\184\236\151\144\236\132\156 \236\176\190\236\157\132 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164.|r"
L["NO_DISPLAY_STOP"] = "|cffff4411\235\167\140\236\149\189 \235\139\185\236\139\160\236\157\180 \236\157\180\234\178\131\236\151\144 \235\140\128\237\149\180 \235\139\164\236\139\156 \235\150\160\236\152\172\235\166\172\234\179\160 \236\139\182\236\167\128 \236\149\138\235\139\164\235\169\180, |cff44ff44/stopnag|r|cffff4411\235\165\188 \236\139\164\237\150\137\237\149\152\236\132\184\236\154\148.|r"
L["STOP_NAG"] = "|cffff4411!BugGrabber\235\138\148 \236\152\164\235\165\152\236\151\144 \234\180\128\237\149\180 \236\132\177\234\176\128\236\139\156\234\178\140 \237\149\152\236\167\128 \236\149\138\236\156\188\235\169\176 |r|cff44ff44BugSack|r|cffff4411\236\157\152 \235\139\164\236\157\140 \237\140\168\236\185\152\235\149\140\234\185\140\236\167\128\235\167\140 \236\158\133\235\139\136\235\139\164.|r"
L["USAGE"] = "\236\130\172\236\154\169\235\178\149: /buggrabber <1-%d>."

	elseif locale == "deDE" then
L["ADDON_CALL_PROTECTED"] = "[%s] AddOn '%s' hat versucht die gesch\195\188tzte Funktion '%s' aufzurufen."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' hat versucht die gesch\195\188tzte Funktion '.*' aufzurufen.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r und |cffffff7f%s|r k\195\182nnen nicht zusammen laufen, |cffffff7f%s|r wurde deshalb deaktiviert. Du kannst jetzt WoW schlie\195\159en, |cffffff7fBugGrabber|r deaktivieren und |cffffff7f%s|r erneut aktivieren."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r zeichnet nun wieder Fehler auf."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r hat die Aufzeichnung von Fehlern gestoppt, weil mehr als %d Fehler pro Sekunde erzeugt wurden. Die Aufzeichnung wird in %d Sekunden fortgesetzt."
L["CMD_CREATED"] = "Ein Fehler wurde entdeckt, benutze /buggrabber um ihn anzuzeigen."
L["ERROR_INDEX"] = "Der zur Verf\195\188gung gestellte Index mu\195\159 eine Zahl sein."
L["ERROR_UNKNOWN_INDEX"] = "Der Index %d existiert nicht in der geladenen Fehlerliste."
L["NO_DISPLAY_1"] = "|cffff4411Anscheinend benutzt du !BugGrabber ohne dazugeh\195\182rigem Display-Addon. Zwar bietet !BugGrabber Slash-Befehle, um auf die Fehler zuzugreifen, mit einem Display-Addon w\195\164re die Fehlerverwaltung aber bequemer.|r"
L["NO_DISPLAY_2"] = "|cffff4411Die Standardanzeige f\195\188r !BugGrabber hei\195\159t |r|cff44ff44BugSack|r|cffff4411 und kann vermutlich auf der Seite gefunden werden, wo du auch !BugGrabber gefunden hast.|r"
L["NO_DISPLAY_STOP"] = "|cffff4411Wenn du diesen Hinweis nicht mehr sehen willst, gib bitte |cff44ff44/stopnag|r|cffff4411 ein.|r"
L["STOP_NAG"] = "|cffff4411!BugGrabber wird bis zum n\195\164chsten Patch nicht mehr auf ein fehlendes |r|cff44ff44BugSack|r|cffff4411 hinweisen.|r"
L["USAGE"] = "Benutzung: /buggrabber <1-%d>."

	elseif locale == "esES" then
L["ADDON_CALL_PROTECTED"] = "[%s] El accesorio '%s' ha intentado llamar a la funci\195\179n protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la funci\195\179n protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por este motivo. Si lo deseas, puedes salir, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r est\195\161 capturando errores de nuevo."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r ha detenido la captuta de errores, ya que ha capturado m\195\161s de %d errores por segundo. La captura se reanudar\195\161 en %d segundos."
L["CMD_CREATED"] = "Un error ha sido detectado, utiliza /buggrabber para imprimirlo."
L["ERROR_INDEX"] = "El \195\173ndice introducido debe ser un n\195\186mero."
L["ERROR_UNKNOWN_INDEX"] = "El \195\173ndice %d no existe en la tabla de errores de carga."
L["NO_DISPLAY_1"] = "|cffff441Parece que est\195\161s ejecutando !BugGrabber sin un accessorio de visualizaci\195\179n para acompa\195\177arlo. Aunque !BugGrabber proporciona un comando para ver a los errores en el juego, un addon de visualizaci\195\179n pueden ayudar a gestionar estos errores de una manera m\195\161s conveniente.|r  "
L["NO_DISPLAY_2"] = "|cffff4411El accesorio est\195\161ndar de visualizaci\195\179n para !BugGrabber se llama |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar descarg\195\179 BugSack.|r"
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres ver\195\161 este mensaje nuevamente, por favor escriba |r|cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordar\195\161 sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 de nuevo hasta el pr\195\179ximo parche.|r"
L["USAGE"] = "Uso: /buggrabber <1-%d>."

	elseif locale == "zhTW" then
L["ADDON_CALL_PROTECTED"] = "[%s] \230\143\146\228\187\182 '%s' \229\152\151\232\169\166\232\170\191\231\148\168\228\191\157\232\173\183\229\138\159\232\131\189 '%s'\227\128\130"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (\230\143\146\228\187\182 '.*' \229\152\151\232\169\166\232\170\191\231\148\168\228\191\157\232\173\183\229\138\159\232\131\189 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r \229\146\140 |cffffff7f%s|r \228\184\141\232\131\189\229\133\177\229\173\152\227\128\130|cffffff7f%s|r \229\183\178\229\129\156\231\148\168\227\128\130\229\143\175\229\156\168\230\143\146\228\187\182\228\187\139\233\157\162\229\129\156\231\148\168 |cffffff7fBugGrabber|r\239\188\140\229\134\141\231\148\168 |cffffff7f%s|r\227\128\130"
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r \229\183\178\233\135\141\230\150\176\233\150\139\229\167\139\227\128\130"
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r \231\143\190\230\173\163\230\154\171\229\129\156\239\188\140\229\155\160\231\130\186\230\175\143\231\167\146\230\141\149\230\141\137\229\136\176\232\182\133\233\129\142%d\229\128\139\233\140\175\232\170\164\227\128\130\229\174\131\230\156\131\229\156\168%d\231\167\146\229\190\140\233\135\141\230\150\176\233\150\139\229\167\139\227\128\130"
L["CMD_CREATED"] = "\231\153\188\231\143\190\233\140\175\232\170\164\239\188\140\231\148\168 /buggrabber \229\136\151\229\135\186\233\128\153\233\140\175\232\170\164\227\128\130"
L["ERROR_INDEX"] = "\230\143\144\228\190\155\231\154\132\231\180\162\229\188\149\229\128\188\229\191\133\233\160\136\230\152\175\230\149\184\229\173\151\227\128\130"
L["ERROR_UNKNOWN_INDEX"] = "\230\143\144\228\190\155\231\154\132\231\180\162\229\188\149\229\128\188\227\128\140%d\227\128\141\228\184\141\230\152\175\230\173\163\231\162\186\231\154\132\227\128\130"
L["USAGE"] = "\231\148\168\230\179\149\239\188\154/buggrabber <1-%d>\227\128\130"

	elseif locale == "zhCN" then
L["ADDON_CALL_PROTECTED"] = "[%s] \230\143\146\228\187\182 '%s' \229\176\157\232\175\149\232\176\131\231\148\168\228\191\157\230\138\164\229\138\159\232\131\189 '%s'\227\128\130"
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (\230\143\146\228\187\182 '.*' \229\176\157\232\175\149\232\176\131\231\148\168\228\191\157\230\138\164\229\138\159\232\131\189 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r \229\146\140 |cffffff7f%s|r \228\184\141\232\131\189\229\133\177\229\173\152\227\128\130|cffffff7f%s|r \229\183\178\229\129\156\231\148\168\227\128\130\229\143\175\229\156\168\230\143\146\228\187\182\231\149\140\233\157\162\229\129\156\231\148\168 |cffffff7fBugGrabber|r \229\134\141\231\148\168 |cffffff7f%s|r\227\128\130"
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r \229\183\178\233\135\141\230\150\176\229\188\128\229\167\139\227\128\130"
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r \231\142\176\230\173\163\230\154\130\229\129\156\239\188\140\229\155\160\228\184\186\230\175\143\231\167\146\230\141\149\230\141\137\229\136\176\232\182\133\232\191\135%d\228\184\170\233\148\153\232\175\175\227\128\130\229\174\131\228\188\154\229\156\168%d\231\167\146\229\144\142\233\135\141\230\150\176\229\188\128\229\167\139\227\128\130"
L["CMD_CREATED"] = "\229\143\145\231\142\176\228\184\128\228\184\170\233\148\153\232\175\175\239\188\140\231\148\168 /buggrabber \229\136\151\229\135\186\232\191\153\228\184\170\233\148\153\232\175\175\227\128\130"
L["ERROR_INDEX"] = "\230\143\144\228\190\155\231\154\132\231\180\162\229\188\149\229\128\188\229\191\133\233\161\187\230\152\175\230\149\176\229\173\151\227\128\130"
L["ERROR_UNKNOWN_INDEX"] = "\230\143\144\228\190\155\231\154\132\231\180\162\229\188\149\229\128\188\227\128\140%d\227\128\141\228\184\141\230\152\175\230\173\163\231\161\174\231\154\132\227\128\130"
L["NO_DISPLAY_STOP"] = "|cffff4411\229\166\130\230\158\156\228\189\160\228\184\141\229\184\140\230\156\155\229\134\141\230\172\161\232\162\171\230\143\144\233\134\146, \232\175\183\232\190\147\229\133\165 |cff44ff44/stopnag|r|cffff4411.|r"
L["USAGE"] = "\231\148\168\230\179\149\239\188\154/buggrabber <1-%d>\227\128\130"

	elseif locale == "ruRU" then
L["ADDON_CALL_PROTECTED"] = "[%s] \208\144\208\180\208\180\208\190\208\189 '%s' \208\191\209\139\209\130\208\176\208\187\209\129\209\143 \208\178\209\139\208\183\208\178\208\176\209\130\209\140 \208\183\208\176\209\137\208\184\209\137\208\181\208\189\208\189\209\131\209\142 \209\132\209\131\208\189\208\186\209\134\208\184\209\142 '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (\208\144\208\180\208\180\208\190\208\189 '.*' \208\191\209\139\209\130\208\176\208\187\209\129\209\143 \208\178\209\139\208\183\208\178\208\176\209\130\209\140 \208\183\208\176\209\137\208\184\209\137\208\181\208\189\208\189\209\131\209\142 \209\132\209\131\208\189\208\186\209\134\208\184\209\142 '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r \208\184 |cffffff7f%s|r \208\189\208\181 \208\188\208\190\208\182\208\181\209\130 \209\129\209\131\209\137\208\181\209\129\209\130\208\178\208\190\208\178\208\176\209\130\209\140 \208\178\208\188\208\181\209\129\209\130\208\181, |cffffff7f%s|r \208\177\209\139\208\187 \208\189\208\181\208\184\209\129\208\191\209\128\208\176\208\178\208\189\209\139\208\185. \208\181\209\129\208\187\208\184 \209\133\208\190\209\130\208\184\209\130\208\181 \208\178\209\139\208\185\208\180\208\184\209\130\208\181 \208\184\208\183 WoW \208\184\208\187\208\184 \208\190\209\130\208\186\208\187\209\142\209\135\208\184\209\130\208\181 \208\189\208\181\208\184\209\129\208\191\209\128\208\176\208\178\208\189\209\139\208\185 \208\176\208\180\208\180\208\190\208\189, |cffffff7fBugGrabber|r \208\191\208\190\208\178\209\130\208\190\209\128\208\189\208\190 \208\183\208\176\208\191\209\131\209\129\209\130\208\184\208\187 \208\176\208\180\208\180\208\190\208\189|cffffff7f%s|r."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r \208\183\208\176\209\133\208\178\208\176\209\130\208\184\208\187 \208\190\209\136\208\184\208\177\208\186\208\184 \209\129\208\189\208\190\208\178\208\176."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r \208\191\209\128\208\181\208\186\209\128\208\176\209\130\208\184\208\187 \208\183\208\176\209\133\208\178\208\176\209\130\209\139\208\178\208\176\209\130\209\140 \208\190\209\136\208\184\208\177\208\186\208\184, \209\130\208\176\208\186 \208\186\208\176\208\186 \208\190\208\189 \208\183\208\176\209\133\208\178\208\176\209\130\208\184\208\187 \208\177\208\190\208\187\208\181\208\181 %d \208\190\209\136\208\184\208\177\208\190\208\186  \208\178 \209\129\208\181\208\186\209\131\208\189\208\180\209\131. \208\151\208\176\209\133\208\178\208\176\209\130 \208\178\208\190\208\183\208\190\208\177\208\189\208\190\208\178\208\184\209\130\209\129\209\143 \209\135\208\181\209\128\208\181\208\183 %d \208\161\208\181\208\186\209\131\208\189\208\180."
L["CMD_CREATED"] = "\208\158\209\136\208\184\208\177\208\186\208\176 \208\177\209\139\208\187\208\176 \208\190\208\177\208\189\208\176\209\128\209\131\208\182\208\181\208\189\208\176, \208\189\208\176\208\177\208\181\209\128\208\184\209\130\208\181 /buggrabber \209\135\209\130\208\190\208\177\209\139 \208\191\208\190\209\129\208\188\208\190\209\130\209\128\208\181\209\130\209\140 \208\181\208\181."
L["ERROR_INDEX"] = "\208\159\209\128\208\181\208\180\208\190\209\129\209\130\208\176\208\178\208\187\208\181\208\189\208\189\209\139\208\185 \208\184\208\189\208\180\208\181\208\186\209\129 \208\180\208\190\208\187\208\182\208\181\208\189 \208\177\209\139\209\130\209\140 \209\135\208\184\209\129\208\187\208\190\208\188"
L["ERROR_UNKNOWN_INDEX"] = "\208\152\208\189\208\180\208\181\208\186\209\129 %d \208\189\208\181 \209\129\209\131\209\137\208\181\209\129\209\130\208\178\209\131\208\181\209\130 \208\178 \208\183\208\176\208\179\209\128\209\131\208\182\208\181\208\189\208\189\208\190\208\185 \209\130\208\176\208\177\208\187\208\184\209\134\208\181 \208\190\209\136\208\184\208\177\208\190\208\186."
L["NO_DISPLAY_1"] = "|cffff4411\208\154\208\176\208\182\208\181\209\130\209\129\209\143, !BugGrabber \208\183\208\176\208\191\209\131\209\137\208\181\208\189 \208\177\208\181\208\183 \208\191\208\190\208\180\208\180\208\181\209\128\208\182\208\186\208\184 \208\176\208\180\208\180\208\190\208\189\208\176 \208\180\208\187\209\143 \208\190\209\130\208\190\208\177\209\128\208\176\208\182\208\181\208\189\208\184\209\143 \208\184\208\189\209\132\208\190\209\128\208\188\208\176\209\134\208\184\208\184. \208\165\208\190\209\130\209\143 !BugGrabber \208\191\209\128\208\181\208\180\208\190\209\129\209\130\208\176\208\178\208\187\209\143\208\181\209\130 \209\129\208\187\208\181\209\136-\208\186\208\190\208\188\208\176\208\189\208\180\209\139 \208\180\208\187\209\143 \208\180\208\190\209\129\209\130\209\131\208\191\208\176 \208\186 \208\178\208\189\209\131\209\130\209\128\208\184\208\184\208\179\209\128\208\190\208\178\209\139\208\188 \208\190\209\136\208\184\208\177\208\186\208\176\208\188, \208\178\208\184\208\183\209\131\208\176\208\187\208\184\208\183\208\184\209\128\209\131\209\142\209\137\208\184\208\185 \208\176\208\180\208\180\208\190\208\189 \208\188\208\190\208\182\209\130 \208\191\208\190\208\188\208\190\209\135\209\140 \209\129 \209\141\209\130\208\184\208\188 \208\178 \208\177\208\190\208\187\208\181\208\181 \209\131\208\180\208\190\208\177\208\189\208\190\208\185 \209\132\208\190\209\128\208\188\208\181.|r"
L["NO_DISPLAY_2"] = "|cffff4411\208\161\209\130\208\176\208\189\208\180\208\176\209\128\209\130\208\189\209\139\208\185 \208\176\208\180\208\180\208\190\208\189 \208\180\208\187\209\143 \208\190\209\130\208\190\208\177\209\128\208\176\208\182\208\181\208\189\208\184\209\143 \208\184\208\189\209\132\208\190\209\128\208\188\208\176\209\134\208\184\208\184 \208\190\209\130 !BugGrabber \208\189\208\176\208\183\209\139\208\178\208\176\208\181\209\130\209\129\209\143 |r|cff44ff44BugSack|r|cffff4411, \208\184 \208\188\208\190\208\182\208\181\209\130 \208\177\209\139\209\130\209\140 \208\189\208\176\208\185\208\180\208\181\208\189 \209\130\208\176\208\188 \208\182\208\181, \208\179\208\180\208\181 \208\146\209\139 \208\189\208\176\209\136\208\187\208\184 !BugGrabber.|r"
L["NO_DISPLAY_STOP"] = "|cffff4411\208\149\209\129\208\187\208\184 \208\146\208\176\208\188 \208\189\208\181 \208\189\209\128\208\176\208\178\209\143\209\130\209\129\209\143 \208\189\208\176\208\191\208\190\208\188\208\184\208\189\208\176\208\189\208\184\209\143 \208\190\208\177 \209\141\209\130\208\190\208\188, \208\189\208\176\208\177\208\181\209\128\208\184\209\130\208\181, \208\191\208\190\208\182\208\176\208\187\209\131\208\185\209\129\209\130\208\176, |cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411!BugGrabber \208\177\208\190\208\187\209\140\209\136\208\181 \208\189\208\181 \208\177\209\131\208\180\208\181\209\130 \208\189\208\176\208\191\208\190\208\188\208\184\208\189\208\176\209\130\209\140 \208\190\208\177 \208\190\209\130\209\129\209\131\209\130\209\129\209\130\208\178\209\131\209\142\209\137\208\181\208\188 |r|cff44ff44BugSack|r|cffff4411 \208\180\208\190 \209\129\208\187\208\181\208\180\209\131\209\142\209\137\208\181\208\179\208\190 \208\191\208\176\209\130\209\135\208\176.|r"
L["USAGE"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\208\189\208\184\208\181: /buggrabber <1-%d>."

	elseif locale == "frFR" then
L["ADDON_CALL_PROTECTED"] = "[%s] L'AddOn '%s' a tent\195\169 d'appeler la fonction prot\195\169g\195\169e '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (L'AddOn '.*' a tent\195\169 d'appeler la fonction prot\195\169g\195\169e '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r et |cffffff7f%s|r ne peuvent pas \195\170tre lanc\195\169s en m\195\170me temps. |cffffff7f%s|r a \195\169t\195\169 d\195\169sactiv\195\169. Si vous le souhaitez, vous pouvez vous d\195\169connecter, d\195\169sactiver |cffffff7fBugGrabber|r et r\195\169activer |cffffff7f%s|r."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r capture les erreurs \195\160 nouveau."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r a cess\195\169 de capturer des erreurs, car plus de %d erreurs ont \195\169t\195\169 captur\195\169es par seconde. La capture sera reprise dans %d secondes."
L["CMD_CREATED"] = "Une erreur a \195\169t\195\169 d\195\169tect\195\169e, tapez /buggrabber pour l'afficher."
L["ERROR_INDEX"] = "L'index donn\195\169 doit \195\170tre un nombre."
L["ERROR_UNKNOWN_INDEX"] = "L'index %d n'existe pas dans la table d'erreurs charg\195\169e."
L["NO_DISPLAY_1"] = "|cffff4411Vous ne semblez pas utiliser !BugGrabber avec un add-on d'affichage. Bien que les erreurs enregistr\195\169es par !BugGrabber soient accessibles par ligne de commande, un add-on d'affichage peut vous aidez \195\160 g\195\169rer ces erreurs plus ais\195\169ment.|r"
L["NO_DISPLAY_2"] = "|cffff4411L'add-on d'affichage originel s'appelle |r|cff44ff44BugSack|r|cffff4411, vous devriez pouvoir le trouver sur le m\195\170me site que !BugGrabber.|r"
L["NO_DISPLAY_STOP"] = "|cffff4411Pour ne plus voir ce rappel, utiliser la commande |cff44ff44/stopnag|r|cffff4411.|r\
"
L["STOP_NAG"] = "|cffff4411!BugGrabber ne vous rappellera plus l'existence de |r|cff44ff44BugSack|r|cffff4411 jusqu'\195\160 la prochaine mise \195\160 jour.|r"
L["USAGE"] = "Utilisation: /buggrabber <1-%d>."

	elseif locale == "esMX" then
L["ADDON_CALL_PROTECTED"] = "[%s] El accesorio '%s' ha intentado llamar a la funci\195\179n protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (El accesorio '.*' ha intentado llamar a la funci\195\179n protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r y |cffffff7f%s|r no pueden coexistir juntos. |cffffff7f%s|r ha sido desactivado por este motivo. Si lo deseas, puedes salir, desactivar |cffffff7fBugGrabber|r y reactivar |cffffff7f%s|r."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r est\195\161 capturando errores de nuevo."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r ha detenido la captuta de errores, ya que ha capturado m\195\161s de %d errores por segundo. La captura se reanudar\195\161 en %d segundos."
L["CMD_CREATED"] = "Un error ha sido detectado, utiliza /buggrabber para imprimirlo."
L["ERROR_INDEX"] = "El \195\173ndice introducido debe ser un n\195\186mero."
L["ERROR_UNKNOWN_INDEX"] = "El \195\173ndice %d no existe en la tabla de errores de carga."
L["NO_DISPLAY_1"] = "|cffff441Parece que est\195\161s ejecutando !BugGrabber sin un accessorio de visualizaci\195\179n para acompa\195\177arlo. Aunque !BugGrabber proporciona un comando para ver a los errores en el juego, un addon de visualizaci\195\179n pueden ayudar a gestionar estos errores de una manera m\195\161s conveniente.|r  "
L["NO_DISPLAY_2"] = "|cffff4411El accesorio est\195\161ndar de visualizaci\195\179n para !BugGrabber se llama |r|cff44ff44BugSack|r|cff4411. Puedes descargarlo desde el mismo lugar descarg\195\179 BugSack.|r"
L["NO_DISPLAY_STOP"] = "|cff4411Si no quieres ver\195\161 este mensaje nuevamente, por favor escriba |r|cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411BugGrabber no te recordar\195\161 sobre el desaparecido |r|cff44ff44BugSack|r|cffff4411 de nuevo hasta el pr\195\179ximo parche.|r"
L["USAGE"] = "Uso: /buggrabber <1-%d>."

	elseif locale == "ptBR" then
L["ADDON_CALL_PROTECTED"] = "[%s] O AddOn '%s' tentou chamar a fun\195\167\195\163o protegida '%s'."
L["ADDON_CALL_PROTECTED_MATCH"] = "^%[(.*)%] (AddOn '.*' tentou chamar a fun\195\167\195\163o protegida '.*'.)$"
L["ADDON_DISABLED"] = "|cffffff7fBugGrabber|r e |cffffff7f%s|r n\195\163o podem existir juntos. |cffffff7f%s|r foi desabilitado por causa disso. Se voc\195\170 quiser, voc\195\170 pode sair, desabilitar o |cffffff7fBugGrabber|r e habilitar o |cffffff7f%s|r."
L["BUGGRABBER_RESUMING"] = "|cffffff7fBugGrabber|r est\195\161 capturando erros novamente."
L["BUGGRABBER_STOPPED"] = "|cffffff7fBugGrabber|r parou de capturar erros, j\195\161 que capturou mais de %d erros por segundo. A captura ser\195\161 resumida em %d segundos."
L["CMD_CREATED"] = "Um erro foi detectado, utilize /buggrabber para imprimi-lo."
L["ERROR_INDEX"] = "O \195\173ndice fornecido deve ser um n\195\186mero,"
L["ERROR_UNKNOWN_INDEX"] = "O \195\173ndice %d n\195\163o existe na tabela de carregamento de erros."
L["NO_DISPLAY_1"] = "|cffff4411Aparentemente voc\195\170 est\195\161 usando !BugGrabber sem nenhum addon de exibi\195\167\195\163o para acompanh\195\161-lo. Apesar de que o !BugGrabber fornece um comando para acessar os erros dentro do jogo, um addon de exibi\195\167\195\163o pode ajudar voc\195\170 a gerenciar esses erros de uma forma mais conveniente.|r"
L["NO_DISPLAY_2"] = "|cffff4411O exibidor padr\195\163o do !BugGrabber \195\169 conhecido por |r|cff44ff44BugSack|r|cffff4411, e voc\195\170 pode, provavelmente, encontrar no mesmo site onde voc\195\170 achou o !BugGrabber.|r"
L["NO_DISPLAY_STOP"] = "|cffff4411Se voc\195\170 n\195\163o deseja ser lembrado disso novamente, por favor utilize o comando |cff44ff44/stopnag|r|cffff4411.|r"
L["STOP_NAG"] = "|cffff4411!BugGrabber n\195\163o ir\195\161 perturbar sobre n\195\163o ter detectado o |r|cff44ff44BugSack|r|cffff4411 at\195\169 a pr\195\179xima atualiza\195\167\195\163o.|r"
L["USAGE"] = "Uso: /buggraber <1-%d>"

	end
end

