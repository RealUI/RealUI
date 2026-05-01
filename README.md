RealUI
[![Build Status](https://github.com/RealUI/RealUI/workflows/CI/badge.svg)](https://github.com/RealUI/RealUI/actions?query=workflow%3ACI)
[![RealUI Discord](https://img.shields.io/badge/discord-RealUI-7289DA.svg)](https://discord.gg/sasExJYxgf)
======

RealUI is a minimalistic UI designed to be functional, yet also efficient and elegant.

Information
-----------
  * Current branch target is Midnight-era WoW (12.0.x).
  * RealUI now includes the modernized setup pipeline, unified profile handling, and display setup stage.
  * User settings are automatically migrated from nibRealUIDB to RealUIDB when needed.
  * Report issues on GitHub or connect with us on Discord.


Quick Start
-----------

After first login, these are the most useful commands:

  * `/realui` - open configuration.
  * `/realui setup` - rerun setup flow.
  * `/realui display` - open display preset setup.
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
-----------------------------------

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
  * `RealUI_Skins` (includes embedded Aurora)
  * `RealUI_Tooltips`

Not packaged:

  * `RealUI_Dev`
  * `RealUI_Chat`

