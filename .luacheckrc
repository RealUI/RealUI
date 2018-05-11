include_files = {
    "Interface/AddOns/cargBags_Nivaya",
    "Interface/AddOns/FreebTip",
    "Interface/AddOns/nibRealUI",
    "Interface/AddOns/nibRealUI_Config",
    "Interface/AddOns/nibRealUI_Dev",
    "Interface/AddOns/RealUI_Bugs",
    "Interface/AddOns/RealUI_Skins",
}

exclude_files = {
    "Interface/AddOns/**/Libs/**",
    "Interface/AddOns/**/Locale/**",
    "**/*.blp",
    "**/*.BLP",
    "**/*.ttf",
    "**/*.toc",
    "**/*.txt",
    "**/*.xml",
    "**/*.md",
}

max_line_length = false
max_cyclomatic_complexity = 76
unused_args = false
self = false
std = "none"
globals = {
    "_G"
}
