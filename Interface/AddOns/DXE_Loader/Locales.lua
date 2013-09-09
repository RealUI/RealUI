--[[
	The contents of this file are auto-generated using the WoWAce localization application
	Please go to http://www.wowace.com/projects/deus-vox-encounters/localization/ to update translations.
	Anyone with a wowace/curseforge account can edit them. 
]] 

local AL = LibStub("AceLocale-3.0")

local silent = true

L = AL:NewLocale("DXE", "enUS", true, silent)

if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "enUS", true, silent)
AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "enUS", true, silent)
AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

if GetLocale() == "enUS" or GetLocale() == "enGB" then return end
end

local L = AL:NewLocale("DXE", "deDE")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "deDE")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Baradinfestung"
zone["Bastion"] = "Bastion"
zone["Blackwing Descent"] = "Pechschwingenabstieg"
zone["Descent"] = "Abstieg"
zone["Dragon Soul"] = "Drachenseele" -- Needs review
zone["Firelands"] = "Feuerlande"
zone["The Bastion of Twilight"] = "Die Bastion des Zwielichts"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "Thron"
zone["Throne of the Four Winds"] = "Thron der Vier Winde"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "deDE")
loader["|cffffff00Click|r to load"] = " |cffffff00Klicken|r, zum Laden"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Klicken|r, um das Einstellungsfenster anzuzeigen"
loader["Deus Vox Encounters"] = "Deus Vox Encounters"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "esES")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "esES")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Bastión de Baradin"
zone["Bastion"] = "Bastión"
zone["Blackwing Descent"] = "Descenso de Alanegra"
zone["Descent"] = "Descenso"
zone["Dragon Soul"] = "Alma de Dragón"
zone["Firelands"] = "Tierras de Fuego"
zone["The Bastion of Twilight"] = "El Bastión del Crepúsculo"
zone["The Dragon Wastes"] = "Baldío del Dragón" -- Needs review
zone["Throne"] = "Trono"
zone["Throne of the Four Winds"] = "Trono de los Cuatro Vientos"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "esES")
loader["|cffffff00Click|r to load"] = "|cffffff00Click|r para cargar"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Click|r para mostrar la ventana de opciones"
loader["Deus Vox Encounters"] = "Deus Vox Encounters"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "esMX")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "esMX")
-- zone["Baradin"] = ""
-- zone["Baradin Hold"] = ""
-- zone["Bastion"] = ""
-- zone["Blackwing Descent"] = ""
-- zone["Descent"] = ""
-- zone["Dragon Soul"] = ""
-- zone["Firelands"] = ""
-- zone["The Bastion of Twilight"] = ""
-- zone["The Dragon Wastes"] = ""
-- zone["Throne"] = ""
-- zone["Throne of the Four Winds"] = ""

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "esMX")
-- loader["|cffffff00Click|r to load"] = ""
-- loader["|cffffff00Click|r to toggle the settings window"] = ""
-- loader["Deus Vox Encounters"] = ""

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "frFR")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "frFR")
zone["Baradin"] = "Baradin"
zone["Baradin Hold"] = "Bastion de Baradin"
zone["Bastion"] = "Bastion"
zone["Blackwing Descent"] = "Descente de l'Aile noire"
zone["Descent"] = "Descente"
zone["Dragon Soul"] = "L’Âme des dragons" -- Needs review
zone["Firelands"] = "Terres de Feu"
zone["The Bastion of Twilight"] = "Le bastion du Crépuscule"
zone["The Dragon Wastes"] = "Le désert des Dragons" -- Needs review
zone["Throne"] = "Trône"
zone["Throne of the Four Winds"] = "Trône des quatre vents"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "frFR")
loader["|cffffff00Click|r to load"] = "|cffffff00Clic gauche|r pour charger."
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00Clic gauche|r pour afficher/cacher la fenêtre des paramètres."
loader["Deus Vox Encounters"] = "Deus Vox Encounters"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "koKR")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "koKR")
zone["Baradin"] = "바라딘"
zone["Baradin Hold"] = "바라딘 요새"
zone["Bastion"] = "요새"
zone["Blackwing Descent"] = "검은날개 강림지"
zone["Descent"] = "강림지"
zone["Dragon Soul"] = "용의 영혼" -- Needs review
zone["Firelands"] = "불의 땅"
zone["The Bastion of Twilight"] = "황혼의 요새"
-- zone["The Dragon Wastes"] = ""
zone["Throne"] = "왕좌"
zone["Throne of the Four Winds"] = "네 바람의 왕좌"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "koKR")
loader["|cffffff00Click|r to load"] = "불러 오려면 |cffffff00클릭|r "
loader["|cffffff00Click|r to toggle the settings window"] = "설정 창을 열거나 닫으려면 |cffffff00클릭|r "
loader["Deus Vox Encounters"] = "Deus Vox Encounters"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "ruRU")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "ruRU")
zone["Baradin"] = "Барадин"
zone["Baradin Hold"] = "Крепость Барадин"
zone["Bastion"] = "Бастион"
zone["Blackwing Descent"] = "Твердыня Крыла Тьмы"
zone["Descent"] = "Твердыня"
zone["Dragon Soul"] = "Душа Дракона"
zone["Firelands"] = "Огненные Просторы"
zone["The Bastion of Twilight"] = "Сумеречный бастион"
zone["The Dragon Wastes"] = "Драконьи пустоши"
zone["Throne"] = "Трон"
zone["Throne of the Four Winds"] = "Трон Четырех Ветров"
zone["Throne of Thunder"] = "Престол Гроз"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "ruRU")
loader["|cffffff00Click|r to load"] = " |cffffff00Кликните|r для загрузки"
loader["|cffffff00Click|r to toggle the settings window"] = " |cffffff00Кликните|r для показа окна настроек"
loader["Deus Vox Encounters"] = "Deus Vox Encounters"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "zhCN")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "zhCN")
zone["Baradin"] = "巴拉丁海湾"
zone["Baradin Hold"] = "巴拉丁监狱"
zone["Bastion"] = "暮光堡垒"
zone["Blackwing Descent"] = "黑翼血环"
zone["Descent"] = "黑翼血环"
zone["Dragon Soul"] = "巨龙之魂"
zone["Firelands"] = "火焰之地"
zone["The Bastion of Twilight"] = "暮光堡垒"
zone["The Dragon Wastes"] = "巨龙废土"
zone["Throne"] = "风神王座"
zone["Throne of the Four Winds"] = "风神王座"
zone["Throne of Thunder"] = "À×µçÍõ×ù"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "zhCN")
loader["|cffffff00Click|r to load"] = "|cffffff00点击|r加载"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00点击|r切换设置窗口"
loader["Deus Vox Encounters"] = "Deus Vox 战斗警报"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end

local L = AL:NewLocale("DXE", "zhTW")
if L then

-- Zone names
local zone = AL:NewLocale("DXE Zone", "zhTW")
zone["Baradin"] = "巴拉丁"
zone["Baradin Hold"] = "巴拉丁堡"
zone["Bastion"] = "暮光堡壘"
zone["Blackwing Descent"] = "黑翼陷窟"
zone["Descent"] = "黑翼陷窟"
zone["Dragon Soul"] = "巨龍之魂"
zone["Firelands"] = "火源之界"
zone["The Bastion of Twilight"] = "暮光堡壘"
zone["The Dragon Wastes"] = "龍墳荒原"
zone["Throne"] = "四風王座"
zone["Throne of the Four Winds"] = "四風王座"

AL:GetLocale("DXE").zone = AL:GetLocale("DXE Zone")
-- Loader
local loader = AL:NewLocale("DXE Loader", "zhTW")
loader["|cffffff00Click|r to load"] = "|cffffff00點擊|r加載"
loader["|cffffff00Click|r to toggle the settings window"] = "|cffffff00點擊|r打開設定視窗"
loader["Deus Vox Encounters"] = "Deus Vox 首領戰鬥"

AL:GetLocale("DXE").loader = AL:GetLocale("DXE Loader")

return
end
