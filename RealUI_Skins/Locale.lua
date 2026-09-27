local _, private = ...

local L = {}
private.L = L

local locale = _G.GAME_LOCALE or _G.GetLocale()
_G.RealUI.locale = locale

L["MailFrame_OpenChecked"] = "Open Checked"

-- luacheck: ignore 542

if locale == "deDE" then

-- cf-localization: locale="deDE", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
L["MailFrame_OpenChecked"] = "Öffne markierte"
-- cf-localization end
elseif locale == "esES" then

-- cf-localization: locale="esES", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
L["MailFrame_OpenChecked"] = "Abrir leídos"
-- cf-localization end
elseif locale == "esMX" then

-- cf-localization: locale="esMX", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
elseif locale == "frFR" then

-- cf-localization: locale="frFR", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
L["MailFrame_OpenChecked"] = "Ouvrir les courriers sélectionnés"
-- cf-localization end
elseif locale == "itIT" then

-- cf-localization: locale="itIT", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
elseif locale == "koKR" then

-- cf-localization: locale="koKR", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
elseif locale == "ptBR" then

-- cf-localization: locale="ptBR", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
elseif locale == "ruRU" then

-- cf-localization: locale="ruRU", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
L["MailFrame_OpenChecked"] = "Открыть Отмеченные Письма"
-- cf-localization end
elseif locale == "zhCN" then

-- cf-localization: locale="zhCN", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
elseif locale == "zhTW" then

-- cf-localization: locale="zhTW", format="lua_additive_table", handle-unlocalized="comment", namespace="Skins"
-- Skins
--[[Translation missing --]]
--[[ L["MailFrame_OpenChecked"] = "Open Checked"--]] 
-- cf-localization end
end
