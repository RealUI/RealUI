exclude_files = {
    "**/Libs/**",
    "**/Locale/**",
    ".release/**"
}

ignore = {
    "211/_.*", -- Unused local variable starting with _
}

max_line_length = false
max_cyclomatic_complexity = 76
unused_args = false
self = false
std = "none"
globals = {
    "_G"
}
