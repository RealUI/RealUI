std = "lua51"
quiet = 1 -- suppress report output for files without warnings

exclude_files = {
    "**/Libs/**",
    "**/Locale/**",
    ".release/**",
    "!RealUI_Preloads/**",
    "RealUI_Preloads/**",
}

ignore = {
    "211/_.*", -- Unused local variable starting with _
}
max_line_length = false
max_cyclomatic_complexity = 73
unused_args = false
self = false
globals = {
    "_G",
    "RealUI_Auras",
    "SlashCmdList",
    "SLASH_EDITMODEDUMP1",
    "SLASH_EDITMODEEXPORT1",
    "SLASH_EDITMODELIST1",
    "StaticPopupDialogs",
}

read_globals = {
    "AuraUtil",
    "BuffFrame",
    "C_AddOns",
    "C_CooldownViewer",
    "C_EditMode",
    "C_EncodingUtil",
    "C_Garrison",
    "C_QuestLog",
    "C_Spell",
    "C_Timer",
    "CreateFrame",
    "DebuffFrame",
    "Enum",
    "GameTooltip",
    "GetInstanceInfo",
    "GetQuestDifficultyColor",
    "GetSpecialization",
    "GetSpellTexture",
    "GetTime",
    "LibStub",
    "RealUI",
    "ReloadUI",
    "SetCVar",
    "StaticPopup_Show",
    "UIParent",
    "UnitClass",
    "UnitExists",
    "UnitIsFriend",
    "date",
    "hooksecurefunc",
    "strsub",
    "tinsert",
    "tremove",
    "wipe",
}
