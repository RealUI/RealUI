# RealUI Commands & Diagnostics Reference

The authoritative list of RealUI slash commands, including the diagnostics and taint-debugging tools that ship in the normal release (no `RealUI_Dev` required). All commands are case-insensitive.

## Setup & configuration

| Command | What it does |
|---------|--------------|
| `/realui` or `/real` | Open the RealUI configuration interface (HuD settings) |
| `/realadv` | Open advanced configuration options |
| `/realui setup` or `/realuisetup` | Run the setup wizard (first-time config, re-run after upgrade) |
| `/realuisetup check` | Show setup status: whether setup is needed, upgrade detection, old config found |
| `/realuisetup migrate` | Manually run settings migration from a previous RealUI version |
| `/installwizard start\|skip\|reset` | Start, skip, or reset the installation wizard |
| `/charinit setup\|reset\|info` | Character-specific setup (role detection, chat positioning) |
| `/tutorial` | Open the tutorial |
| `/realui reset` / `/realui resetchar` | Reset settings (account / character) |
| `/rl` | Reload the UI |

## Layout & positioning

| Command | What it does |
|---------|--------------|
| `/layoutstatus` | Show current layout information |
| `/layoutswitch <1\|2>` | Switch to layout 1 (DPS/Tank) or 2 (Healing) |
| `/layouttoggle` | Toggle between layouts |
| `/hudstatus` / `/hudsize` / `/hudrecalc` / `/hudoptimize` | HuD sizing and recalculation |
| `/framemover status\|config\|reset` | Frame mover status / config mode / reset positions |
| `/configmode` | Toggle configuration mode for moving UI elements |
| `/ac` | Addon position control window |

## Diagnostics & health

| Command | What it does |
|---------|--------------|
| `/healthcheck` | Memory, FPS, addon count, DB integrity, module framework, taint state — with good/warning/critical ratings |
| `/systemstatus` | Version, build, game version, init/enable state, layout, install stage, performance, module counts |
| `/diagnostic [health\|status\|profile\|performance\|modules\|all]` | Run a specific diagnostic |
| `/exportdiag` | Print a copy-pasteable diagnostic report — **attach this to bug reports** |
| `/troubleshoot <key>` | Guided troubleshooting: `combat_lockdown`, `addon_conflict`, `profile_corruption`, `performance_issues` |
| `/moduleinfo [name]` / `/modulelist` | Module framework state |
| `/perfmon start\|stop\|status\|gc\|alerts on\|off` | Performance monitor |
| `/profilemgr status\|backup\|restore\|backups` | Profile backups |
| `/compat status\|check\|safemode on\|off` | Compatibility checks and safe mode |
| `/resoptimizer status\|optimize\|reset` | Resolution optimization |

## Taint debugging

These are the same tools used for A/B taint testing during development:

| Command | What it does |
|---------|--------------|
| `/taintLogging [0\|1\|2]` | Set the `taintLog` CVar and reload. **1** = blocked-action taint only (small log), **2** = every taint event (large log, stutters). Output: `Logs/taint.log` in the WoW folder. RealUI reminds you on login if it's left on. |
| `/taintScan [Global.Sub.Path]` | Field-level `issecurevariable` walk; with no argument, scans the frame under the mouse cursor. Prints `field <- taintingAddon`. |
| `/auroraInsertFrame` | A/B toggle for the `GameTooltip_InsertFrame` taint fix; prints its own test instructions |

## Errors & debug logs

`RealUI_Bugs` (always installed — required dependency) captures every Lua error:

| Command | What it does |
|---------|--------------|
| `/error` | Open the RealUI error frame at the latest error (prev/next navigation, reload button, selectable text). Errors also produce a clickable link in chat. |
| `/debug` | List all modules with debug buffers and their line counts |
| `/debug <Module>` | Open that module's debug buffer in a copyable window. Buffers persist to the `RealUI_Debug` saved variable — **attach to bug reports** for hard-to-reproduce issues. |

## Module dumps

| Command | What it does |
|---------|--------------|
| `/bardump` | Action bar db-vs-live state |
| `/bardumptrace` | Ring buffer of recent bar-settings applications (layout/profile/positions) |
| `/rab dump` | RealUI_ActionBars point/scale/rows deltas · `/rab bind` = keybind mode |
| `/cdvdump` | CooldownViewer layout/category IDs |
| `/rnp` | Nameplates state |
| `/findSpell "Name" [unit] [buff\|debuff]` | Locate a spell/aura on a unit |
| `/gridpos` / `/grid` | Grid layout helpers |
| `/resetFrames` | Reset DragEmAll-moved frames |

## Blizzard built-ins worth knowing

| Command | What it does |
|---------|--------------|
| `/fstack` | Frame stack under the cursor — RealUI adds per-texture detail (atlas/file, layer, vertex color, tex coords) in texture mode |
| `/etrace` | Event trace window |
| `/dump <expr>` | Evaluate and pretty-print a Lua expression |
| `/console scriptErrors 1` | Show Lua errors (the RealUI setup wizard enables this) |

## Setup workflow notes

- **First install:** the wizard appears automatically on login; if not, `/realui setup`.
- **Upgrading:** old configuration is detected and migrated automatically; the wizard shows upgrade-specific messaging.
- **Re-running:** `/realui setup` any time; current settings are preserved unless changed.
- If setup misbehaves: `/realuisetup check` → `/realuisetup migrate` → `/installwizard reset` then `/realui setup`; check `/error` for captured Lua errors.

See also `SETUP_SYSTEM_README.md` in this folder for the setup system's architecture.
