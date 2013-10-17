--[[
Name: LibBabble-TalentTree-3.0
Revision: $Rev: 54 $
Maintainers: ckknight, nevcairiel, Ackis
Website: http://www.wowace.com/projects/libbabble-talenttree-3-0/
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "LibBabble-TalentTree-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 54 $"):match("%d+"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local GAME_LOCALE = GetLocale()

lib:SetBaseTranslations {
	Affliction = "Affliction",
	Arcane = "Arcane",
	Arms = "Arms",
	Assassination = "Assassination",
	Balance = "Balance",
	["Beast Mastery"] = "Beast Mastery",
	Blood = "Blood",
	Brewmaster = "Brewmaster",
	Combat = "Combat",
	Demonology = "Demonology",
	Destruction = "Destruction",
	Discipline = "Discipline",
	Elemental = "Elemental",
	Enhancement = "Enhancement",
	Feral = "Feral",
	["Feral Combat"] = "Feral Combat",
	Fire = "Fire",
	Frost = "Frost",
	Fury = "Fury",
	Guardian = "Guardian",
	Holy = "Holy",
	Hybrid = "Hybrid",
	Marksmanship = "Marksmanship",
	Mistweaver = "Mistweaver",
	Protection = "Protection",
	Restoration = "Restoration",
	Retribution = "Retribution",
	Shadow = "Shadow",
	Subtlety = "Subtlety",
	Survival = "Survival",
	Unholy = "Unholy",
	Windwalker = "Windwalker",
}


if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
	Affliction = "Gebrechen",
	Arcane = "Arkan",
	Arms = "Waffen",
	Assassination = "Meucheln",
	Balance = "Gleichgewicht",
	["Beast Mastery"] = "Tierherrschaft",
	Blood = "Blut",
	Brewmaster = "Braumeister", -- Needs review
	Combat = "Kampf",
	Demonology = "Dämonologie",
	Destruction = "Zerstörung",
	Discipline = "Disziplin",
	Elemental = "Elementar",
	Enhancement = "Verstärkung",
	Feral = "Wildheit", -- Needs review
	["Feral Combat"] = "Wilder Kampf",
	Fire = "Feuer",
	Frost = "Frost",
	Fury = "Furor",
	Guardian = "Wächter", -- Needs review
	Holy = "Heilig",
	Hybrid = "Hybride",
	Marksmanship = "Treffsicherheit",
	Mistweaver = "Nebelwirker", -- Needs review
	Protection = "Schutz",
	Restoration = "Wiederherstellung",
	Retribution = "Vergeltung",
	Shadow = "Schatten",
	Subtlety = "Täuschung",
	Survival = "Überleben",
	Unholy = "Unheilig",
	Windwalker = "Windläufer", -- Needs review
}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
	Affliction = "Affliction",
	Arcane = "Arcane",
	Arms = "Armes",
	Assassination = "Assassinat",
	Balance = "Equilibre",
	["Beast Mastery"] = "Maîtrise des bêtes",
	Blood = "Sang",
	Brewmaster = "Maître brasseur", -- Needs review
	Combat = "Combat",
	Demonology = "Démonologie",
	Destruction = "Destruction",
	Discipline = "Discipline",
	Elemental = "Elémentaire",
	Enhancement = "Amélioration",
	Feral = "Farouche", -- Needs review
	["Feral Combat"] = "Combat farouche",
	Fire = "Feu",
	Frost = "Givre",
	Fury = "Fureur",
	Guardian = "Gardien", -- Needs review
	Holy = "Sacré",
	Hybrid = "Hybride",
	Marksmanship = "Précision",
	Mistweaver = "Tisse-brume", -- Needs review
	Protection = "Protection",
	Restoration = "Restauration",
	Retribution = "Vindicte",
	Shadow = "Ombre",
	Subtlety = "Finesse",
	Survival = "Survie",
	Unholy = "Impie",
	Windwalker = "Marche-vent", -- Needs review
}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
	Affliction = "고통",
	Arcane = "비전",
	Arms = "무기",
	Assassination = "암살",
	Balance = "조화",
	["Beast Mastery"] = "야수",
	Blood = "혈기",
	Brewmaster = "양조", -- Needs review
	Combat = "전투",
	Demonology = "악마",
	Destruction = "파괴",
	Discipline = "수양",
	Elemental = "정기",
	Enhancement = "고양",
	Feral = "야성", -- Needs review
	["Feral Combat"] = "야성",
	Fire = "화염",
	Frost = "냉기",
	Fury = "분노",
	Guardian = "수호", -- Needs review
	Holy = "신성",
	Hybrid = "하이브리드",
	Marksmanship = "사격",
	Mistweaver = "운무", -- Needs review
	Protection = "방어",
	Restoration = "복원",
	Retribution = "징벌",
	Shadow = "암흑",
	Subtlety = "잠행",
	Survival = "생존",
	Unholy = "부정",
	Windwalker = "풍운", -- Needs review
}
elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
	Affliction = "Aflicción",
	Arcane = "Arcano",
	Arms = "Armas",
	Assassination = "Asesinato",
	Balance = "Equilibrio",
	["Beast Mastery"] = "Dominio de bestias",
	Blood = "Sangre",
	Brewmaster = "Maestro cervecero", -- Needs review
	Combat = "Combate",
	Demonology = "Demonología",
	Destruction = "Destrucción",
	Discipline = "Disciplina",
	Elemental = "Elemental",
	Enhancement = "Mejora",
	Feral = "Feral", -- Needs review
	["Feral Combat"] = "Combate Feral",
	Fire = "Fuego",
	Frost = "Escarcha",
	Fury = "Furia",
	Guardian = "Guardián", -- Needs review
	Holy = "Sagrado",
	Hybrid = "Híbrido",
	Marksmanship = "Puntería",
	Mistweaver = "Tejedor de niebla", -- Needs review
	Protection = "Protección",
	Restoration = "Restauración",
	Retribution = "Reprensión",
	Shadow = "Sombras",
	Subtlety = "Sutileza",
	Survival = "Supervivencia",
	Unholy = "Profano",
	Windwalker = "Viajero del viento", -- Needs review
}
elseif GAME_LOCALE == "esMX" then
	lib:SetCurrentTranslations {
	Affliction = "Aflicción",
	Arcane = "Arcano",
	Arms = "Armas",
	Assassination = "Asesinato",
	Balance = "Balance",
	["Beast Mastery"] = "Bestias",
	Blood = "Sangre",
	Brewmaster = "Maestro cervecero", -- Needs review
	Combat = "Combate",
	Demonology = "Demonología",
	Destruction = "Destrucción",
	Discipline = "Disciplina",
	Elemental = "Elemental",
	Enhancement = "Mejora",
	Feral = "Feral", -- Needs review
	["Feral Combat"] = "Combate feral",
	Fire = "Fuego",
	Frost = "Escarcha",
	Fury = "Furia",
	Guardian = "Guardián", -- Needs review
	Holy = "Sagrado",
	Hybrid = "Híbrido",
	Marksmanship = "Puntería",
	Mistweaver = "Tejedor de niebla", -- Needs review
	Protection = "Protección",
	Restoration = "Restauración",
	Retribution = "Reprensión",
	Shadow = "Sombra",
	Subtlety = "Sutileza",
	Survival = "Supervivencia",
	Unholy = "Profano",
	Windwalker = "Viajero del viento", -- Needs review
}
elseif GAME_LOCALE == "ptBR" then
	lib:SetCurrentTranslations {
	Affliction = "Suplício",
	Arcane = "Arcano",
	Arms = "Armas",
	Assassination = "Assassinato",
	Balance = "Equilíbrio",
	["Beast Mastery"] = "Domínio das Feras",
	Blood = "Sangue",
	Brewmaster = "Mestre Cervejeiro", -- Needs review
	Combat = "Combate",
	Demonology = "Demonologia",
	Destruction = "Destruição",
	Discipline = "Disciplina",
	Elemental = "Elemental",
	Enhancement = "Aperfeiçoamento",
	Feral = "Feral", -- Needs review
	["Feral Combat"] = "Combate Feral",
	Fire = "Fogo",
	Frost = "Gelo",
	Fury = "Fúria",
	Guardian = "Guardião", -- Needs review
	Holy = "Sagrado",
	Hybrid = "Híbrido",
	Marksmanship = "Precisão",
	Mistweaver = "Tecelão da Névoa", -- Needs review
	Protection = "Proteção",
	Restoration = "Restauração",
	Retribution = "Retribuição",
	Shadow = "Sombra",
	Subtlety = "Subterfúgio",
	Survival = "Sobrevivência",
	Unholy = "Profano",
	Windwalker = "Andarilho do Vento", -- Needs review
}
elseif GAME_LOCALE == "itIT" then
	lib:SetCurrentTranslations {
	Affliction = "Afflizione",
	Arcane = "Arcano",
	Arms = "Armi",
	Assassination = "Assassinio",
	Balance = "Equilibrio",
	["Beast Mastery"] = "Affinità Animale",
	Blood = "Sangue",
	Brewmaster = "Mastro Birraio",
	Combat = "Combattimento",
	Demonology = "Demonologia",
	Destruction = "Distruzione",
	Discipline = "Disciplina",
	Elemental = "Elementale",
	Enhancement = "Potenziamento",
	Feral = "Aggressore Ferino",
	["Feral Combat"] = "Combattimento Ferale",
	Fire = "Fuoco",
	Frost = "Ghiaccio",
	Fury = "Furia",
	Guardian = "Guardiano Ferino",
	Holy = "Sacro",
	Hybrid = "Ibrido",
	Marksmanship = "Precisione di tiro",
	Mistweaver = "Misticismo",
	Protection = "Protezione",
	Restoration = "Rigenerazione",
	Retribution = "Castigo",
	Shadow = "Ombra",
	Subtlety = "Scaltrezza",
	Survival = "Sopravvivenza",
	Unholy = "Empietà",
	Windwalker = "Impeto",
}
elseif GAME_LOCALE == "ruRU" then
	lib:SetCurrentTranslations {
	Affliction = "Колдовство",
	Arcane = "Тайная магия",
	Arms = "Оружие",
	Assassination = "Убийство",
	Balance = "Баланс",
	["Beast Mastery"] = "Чувство зверя",
	Blood = "Кровь",
	Brewmaster = "Хмелевар", -- Needs review
	Combat = "Бой",
	Demonology = "Демонология",
	Destruction = "Разрушение",
	Discipline = "Послушание",
	Elemental = "Укрощение стихии",
	Enhancement = "Совершенствование",
	Feral = "Сила зверя", -- Needs review
	["Feral Combat"] = "Сила зверя",
	Fire = "Огонь",
	Frost = "Лед",
	Fury = "Неистовство",
	Guardian = "Страж", -- Needs review
	Holy = "Свет",
	Hybrid = "Гибрид",
	Marksmanship = "Стрельба",
	Mistweaver = "Ткач туманов", -- Needs review
	Protection = "Защита",
	Restoration = "Исцеление",
	Retribution = "Возмездие",
	Shadow = "Темная магия",
	Subtlety = "Скрытность",
	Survival = "Выживание",
	Unholy = "Нечестивость",
	Windwalker = "Танцующий с ветром", -- Needs review
}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
	Affliction = "痛苦",
	Arcane = "奥术",
	Arms = "武器",
	Assassination = "刺杀",
	Balance = "平衡",
	["Beast Mastery"] = "野兽控制",
	Blood = "鲜血",
	Brewmaster = "酒仙", -- Needs review
	Combat = "战斗",
	Demonology = "恶魔学识",
	Destruction = "毁灭",
	Discipline = "戒律",
	Elemental = "元素战斗",
	Enhancement = "增强",
	Feral = "野性", -- Needs review
	["Feral Combat"] = "野性战斗",
	Fire = "火焰",
	Frost = "冰霜",
	Fury = "狂怒",
	Guardian = "守护", -- Needs review
	Holy = "神圣",
	Hybrid = "混合",
	Marksmanship = "射击",
	Mistweaver = "织雾", -- Needs review
	Protection = "防护",
	Restoration = "恢复",
	Retribution = "惩戒",
	Shadow = "暗影魔法",
	Subtlety = "敏锐",
	Survival = "生存技能",
	Unholy = "邪恶",
	Windwalker = "踏风", -- Needs review
}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
	Affliction = "痛苦",
	Arcane = "秘法",
	Arms = "武器",
	Assassination = "刺殺",
	Balance = "平衡",
	["Beast Mastery"] = "野獸控制",
	Blood = "血魄",
	Brewmaster = "釀酒", -- Needs review
	Combat = "戰鬥",
	Demonology = "惡魔學識",
	Destruction = "毀滅",
	Discipline = "戒律",
	Elemental = "元素",
	Enhancement = "增強",
	Feral = "野性戰鬥", -- Needs review
	["Feral Combat"] = "野性戰鬥",
	Fire = "火焰",
	Frost = "冰霜",
	Fury = "狂怒",
	Guardian = "守護者", -- Needs review
	Holy = "神聖",
	Hybrid = "混合",
	Marksmanship = "射擊",
	Mistweaver = "織霧", -- Needs review
	Protection = "防護",
	Restoration = "恢復",
	Retribution = "懲戒",
	Shadow = "暗影",
	Subtlety = "敏銳",
	Survival = "生存",
	Unholy = "穢邪",
	Windwalker = "御風", -- Needs review
}

else
	error(("%s: Locale %q not supported"):format(MAJOR_VERSION, GAME_LOCALE))
end
