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
    "_G"
}
