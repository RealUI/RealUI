RealUI
[![Build Status](https://github.com/RealUI/RealUI/workflows/CI/badge.svg)](https://github.com/RealUI/RealUI/actions?query=workflow%3ACI)
[![RealUI Discord](https://img.shields.io/badge/discord-RealUI-7289DA.svg)](https://discord.gg/sasExJYxgf)
======

RealUI is a minimalistic UI designed to be functional, yet also efficient and elegant.

Information
-----------

* Current branch target is Midnight-era WoW (12.0.x).
* Current release line is 3.3.1 (Platynator profile improvements, Aurora 12.0.5.9).
* RealUI includes the modernized setup pipeline, unified profile handling, and display setup stage.
* User settings are automatically migrated from nibRealUIDB to RealUIDB when needed.
* Report issues on GitHub or connect with us on Discord.

What's New in 3.3.1
--------------------

* **Aurora updated to 12.0.5.9** — multiple taint fixes: taint-safe `UIWidgetBaseStatusBarTemplate`, tooltip arithmetic taint resolved, `CommunitiesMemberList` taint removed; inactive panel tabs now use the correct border color; CDM cooldown swipes fixed; SpellBook border hook overflow resolved.
* **Platynator: out-of-range fading** — enemies outside your attack range now fade to 60% alpha, making target priority clearer at a glance.
* **Platynator: party role colors** — friendly nameplates show party members with role-colored names (tank blue, healer green, damage red).
* **Platynator compatibility** — profile updated for Platynator 380 and later.
* **`/realui platynator`** — new command to re-apply the bundled RealUI Platynator profile live, without a full UI reset. Use this after any RealUI update that ships Platynator changes.
* **Spec-swap stability** — fixed a race condition on spec change that produced a Lua error.
* **EditMode config** — `Blizzard_PlayerChoice` is now preloaded on login so the advanced config panel works correctly.

What's New in 3.3.0
--------------------

* EditMode integration now manages role-aware RealUI layouts (`RealUI` and `RealUI-Healing`) with account-wide or per-character layout support.
* RealUI_Tracker replaces ObjectivesAdv with a wrapped Blizzard tracker supporting custom positioning, instance hide/collapse behavior, CombatFader integration, quest counts, and quest difficulty coloring.
* RealUI_Auras introduces specialization-aware CooldownViewer preset setup and a reduced aura-group model for player/target/focus flows.
* Added aura migration helpers: `/realui setupauras` to apply presets, `/realui resetauras` to revert to native aura behavior.

Quick Start
-----------

After first login, these are the most useful commands:

* `/realui` - open configuration.
* `/realui setup` - rerun setup flow.
* `/realui display` - open display preset setup.
* `/realui platynator` - re-apply the RealUI Platynator nameplate profile (no reload needed).
* `/realui setupauras` - apply RealUI_Auras cooldown presets for your current spec.
* `/realui resetauras` - disable RealUI_Auras groups and restore native aura behavior.
* `/resetframes` - reset DragEmAll-managed frame positions.
* `/framemover reset` - reset moved frame positions.
* `/realui resetinventory` - reset inventory and bank positions.

Installation
------------

1. Exit WoW
2. Move your old `World of Warcraft\Interface` and `World of Warcraft\WTF` folders to a Backup folder
3. Copy the `Interface` folder from the download in to your `World of Warcraft\` folder.
4. Launch WoW and log in

Update
------

1. Exit WoW
2. Delete all RealUI and nibRealUI folders from your `World of Warcraft\Interface\AddOns` folder
3. Copy the `Interface` folder from the download in to your `World of Warcraft\` folder.
4. Launch WoW and log in

Troubleshooting/comments/questions?
------------------------------------

Find a bug or want to post a comment? Please visit the [RealUI Discord](https://discord.gg/sasExJYxgf).

Slash Commands
--------------

Primary command aliases:

* `/realui`
* `/real`
* `/realadv`

Default behavior:

* `/realui` opens the RealUI configuration.
* `/realadv` opens the advanced RealUI configuration.

Supported `/realui` subcommands:

* `/realui setup` - run setup flow.
* `/realui display` - open Display Setup stage.
* `/realui platynator` - re-apply the bundled RealUI Platynator nameplate profile live (no reload).
* `/realui setupauras` - apply RealUI_Auras cooldown presets for your current spec.
* `/realui resetauras` - disable RealUI_Auras groups and restore native aura behavior.
* `/realui grid2update` - apply the RealUI Grid2 modernization update.
* `/realui resetinventory` - reset inventory and bank frame positions.
* `/realui resetchar` - reset current character initialization and rerun setup on reload.
* `/realui reset` - full reset of RealUI/nibRealUI/Bartender4 plus Platynator profile data.

Other useful slash commands:

* `/resetframes` - reset DragEmAll-managed Blizzard/custom frame anchors.
* `/framemover status` - show frame mover status.
* `/framemover config` - toggle frame mover config mode.
* `/framemover reset` - reset all frame mover positions (reset frames).
* `/configmode` - toggle RealUI config mode overlays.
* `/installwizard start` - run the install wizard.

Packaged AddOns
---------------

These folders are included in release packages:

* `!RealUI_Preloads`
* `RealUI`
* `nibRealUI`
* `RealUI_Config`
* `RealUI_Bugs`
* `RealUI_CombatText`
* `RealUI_Inventory`
* `RealUI_Tracker`
* `RealUI_Auras`
* `RealUI_Skins` (includes embedded Aurora)
* `RealUI_Tooltips`

Not packaged:

* `RealUI_Dev`
* `RealUI_Chat`
