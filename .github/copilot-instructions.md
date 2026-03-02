# Copilot instructions for RealUI

## Project architecture (addon layout)
- Core addon lives in `RealUI/` and is the entry point declared in `RealUI/RealUI.toc` (loads `Init.lua`, `Core.lua`, `Core.xml`, `Modules.xml`, `HuD.xml`).
- RealUI creates a single AceAddon instance (`private.RealUI`) in `RealUI/Init.lua`; most modules hang off `RealUI` and use AceEvent/AceTimer messaging (e.g., `RealUI:SendMessage`).
- Core systems are organized via XML includes: `RealUI/Core.xml` (settings, positions, notifications, etc.) and `RealUI/Modules.xml` (feature modules like ActionBars, Minimap, Objectives).
- Sub-addons are separate folders (`RealUI_Config`, `RealUI_Dev`, `RealUI_Skins`, `RealUI_Inventory`, `RealUI_Tooltips`, `RealUI_CombatText`, `RealUI_Chat`, `RealUI_Bugs`) and are loaded/optional via TOC metadata in `RealUI/RealUI.toc`.
- Skinning is handled in `RealUI_Skins/` and embeds Aurora under `RealUI_Skins/Aurora` (see `.pkgmeta` move-folders).
- Unit frames are based on oUF; the embedded framework is pulled via `.pkgmeta` into `RealUI/Libs/oUF`.

## Runtime/data flow conventions
- Startup flow: `RealUI/Init.lua` loads `RealUI_Skins` and initializes `RealUI` with build/realm/class/spec info used throughout modules.
- Layout switching is driven by spec and stored in `dbc.layout` (see `RealUI/Core.lua`); default positions live in `RealUI.defaultPositions`.
- Config UI is lazy-loaded via `RealUI.LoadConfig()` which loads `RealUI_Config` on demand (see `RealUI/Core.lua`).
- Saved variables are `nibRealUIDB` (account) and `nibRealUICharacter` (per-character) from the TOC.

## Developer workflows
- Lint/package on Windows: run `package.bat` (root of repo). It runs `luacheck` then `packager/release.sh` with IDs.
- Packaging and externals are defined in `.pkgmeta` (externals, move-folders, manual changelog). Update this when adding libs or new packaged folders.
- Lua linting uses `.luacheckrc` (Lua 5.1; libs/locale excluded). Follow existing patterns for `_G` usage and globals.

## Integration points
- Optional dependencies (Bartender4, Grid2, oUF, Raven, etc.) are listed in `RealUI/RealUI.toc`; guard integration logic accordingly.
- `wow-ui-source/` is a reference copy of Blizzard UI code used for API changes/diffs; prefer checking it before reworking Blizzard-facing logic.

## Repository boundaries (critical)
- Treat external/vendor repositories in this workspace as **read-only reference** unless explicitly asked otherwise.
- Do **not** edit files under these folders: `../Bartender4/`, `../Aurora/`, `../oUF/`, `../packager/`, `../Platynator/`.
- Implement fixes for integrations from the RealUI side (e.g., `RealUI/`, `RealUI/Core/`, `RealUI/Modules/`, `RealUI_*` add-ons) rather than patching third-party addons.
- If a bug originates in a reference addon, document the issue and add a defensive compatibility fix in RealUI instead of modifying the dependency.

## Editing patterns
- Add new core systems in `RealUI/Core/` and include in `RealUI/Core.xml`.
- Add new feature modules under `RealUI/Modules/` and include in `RealUI/Modules.xml`.
- Keep module defaults and layout positions centralized in `RealUI/Core.lua` to preserve profile/layout behavior.
