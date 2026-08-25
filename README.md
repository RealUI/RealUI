RealUI
[![Build Status](https://github.com/RealUI/RealUI/workflows/CI/badge.svg)](https://github.com/RealUI/RealUI/actions?query=workflow%3ACI)
[![RealUI Discord](https://img.shields.io/badge/discord-RealUI-7289DA.svg)](https://discord.gg/sasExJYxgf)
======

RealUI is a minimalistic UI designed to be functional, yet also efficient and elegant.

Information
-----------

* Current branch target is Midnight-era WoW (12.1.x).
* Current release line is 4.0.0 (the de-bundling release, Aurora 12.1.0.7).
* As of 4.0.0 the package contains **only RealUI's own addons** — no bundled third-party
  addons (standard embedded libraries such as Ace3, oUF, LibActionButton, and
  LibSharedMedia are still included, as in any addon). See "Recommended optional
  AddOns" below.
* RealUI includes the modernized setup pipeline, unified profile handling, and display setup stage.
* User settings are automatically migrated from nibRealUIDB to RealUIDB when needed.
* Report issues on GitHub or connect with us on Discord.

What's New in 4.0.0
--------------------

The de-bundling release: everything in the package is now RealUI's own code.

* **RealUI_Nameplates** — new clean-room nameplate addon with the classic KUI look:
  threat/reaction/execute health coloring, castbars with interrupt-ready coloring and
  empower stages, filtered aura rows (your debuffs, crowd control, dispellable buffs),
  minimal name-only friendly plates. Configure via `/realui` → Nameplates or `/rnp`.
* **Built-in party/raid frames** — oUF-based group frames in the HuD covering 5-man
  through 40-player raids: class-colored cells with incoming heals and absorbs,
  dispellable-debuff and my-HoTs icons, range fading, Clique support. Configure under
  Unit Frames → Raid; config mode shows a 20-man placeholder grid for positioning.
* **RealUI_ActionBars** — new action bar addon on LibActionButton-1.0: six bars laid
  out from your HuD settings automatically, stance and pet bars, your existing main-bar
  keybinds just work, hover keybind capture (`/rab bind`), Naga side-button bar
  (`/naga`), RealUI button skin built in (Masque optional). Configure via `/rab`.
* **Grid2, Masque, and BadBoy remain supported** — install any of them and RealUI
  auto-configures it (Grid2 gets the classic RealUI profile while the built-in raid
  frames stand down). Bartender4 and Platynator are no longer managed: the built-in
  bars/nameplates stand down if either is loaded, but their profiles are yours to
  configure — `/rab import` converts old Bartender4 keybinds and tweaks.
* **`/realui reset` asks what to reset** instead of wiping everything without warning — this
  character's setup, or every setting on the account behind a second confirmation. A full
  reset now clears the whole suite (skins, auras, nameplates, tracker, inventory, bars)
  rather than half of it, while leaving your captured error log and any third-party addon's
  saved data alone. `/realui resetchar` and `/realui resetall` are unprompted quick paths.
* **Changed defaults are offered, never forced** — on the first login after an upgrade,
  RealUI lists every default that changed since 3.4.0, shows which ones your profile is
  already on, and applies only what you tick. Reopen it anytime with `/realui newdefaults`.
* **Your Edit Mode layout is backed up before RealUI updates it** — when a release changes
  the shipped Edit Mode layout, your current one is saved first and `/realui editmode
  restore` puts it back. Assigning your own Edit Mode layout to a role (HuD config →
  General) keeps RealUI's hands off it entirely.
* **Target debuffs show only the ones you cast**, sorted by time remaining — the row used
  to show every debuff from every source. Filter, sort, and duration controls are on each
  aura group under HuD → Units, so "Everything" is one dropdown away.
* **Cast bars and class points are pinned to their unit frames by default** — they follow
  the player, target and focus frames rather than sitting at fixed screen positions. Each
  Cast Bars page and the Class Resource page carries an "Anchor To" option (Screen /
  Player / Target / Focus) if you prefer otherwise, and dragging a pinned element in
  config mode saves the offset relative to its frame instead of the screen. Existing
  profiles keep their placement until you accept the change from `/realui newdefaults`.
* **Bag position lock** — a padlock beside the bag close button freezes the bag position.
  Per character, with the bank locking separately from your bags, and locking freezes the
  whole cluster including categorized bags.
* **RealUI says when a core component is switched off** — shortly after login it names any
  core HuD piece disabled in your profile and notes that it is a setting, not a fault,
  because a switched-off component otherwise looks exactly like a broken one.
* **Map coordinates now use Blizzard's own display** — RealUI's coordinate overlay is
  retired. New installs get them switched on automatically; if you are upgrading, either
  re-run `/realui display` or enable "Player/Cursor map coordinates" in the Blizzard
  Interface options.
* **Instant loot and auto-repair** — with auto-loot on, everything is looted at once and
  the loot window stays shut; it only opens for what could not be looted (full bags), with
  a sound. Auto-repair fixes your gear on the first visit to a repair vendor, optionally
  from guild funds. Toggles under UI Tweaks and Core → Infobar → Durability Settings.
* **Delve and scenario fixes** — the objective tracker no longer breaks in delves: the
  remaining taint injectors were traced to the tracker and widget skins themselves, which
  are switched off pending a taint-safe rebuild (tracker and world-event widgets render
  with Blizzard's styling for now). The delve entry screen stays skinned.
* **Beta feedback rounds** — layout switching no longer resets your positions or bar
  settings, world markers work again, spell alerts stay centred on your character instead
  of following the HuD vertical slider, the LFG eye stays on the minimap, and action bar
  padding is now the gap you actually see. From the later rounds: per-role Edit Mode
  layout choice, bags opening bottom-right and dragging as one cluster, dispel-colored
  debuff borders instead of doubled icons, readable `51m`-style aura timers, config
  buttons that toggle, and the vehicle bar skinned.
* **WoW 12 stability** — continued secret-value hardening across the HuD, auras, and
  Aurora skins (12.1.0.7); EditMode layout writes gated to user-initiated actions; the
  nameplate absorb bar now works in combat via the engine's heal-prediction calculator.

What's New in 3.4.0
--------------------

* The WoW 12.1 "Curse of Ula'tek" release: the HuD migrated to oUF 14 — combat
  right-click buff cancelling, dispel-type colored target debuff borders, optional
  GCD bar, secret-value-safe cast time text; Grid2 profiles updated for Grid2 4.0;
  Aurora 12.1.0.0 with skins for the new 12.1 surfaces.

Quick Start
-----------

After first login, these are the most useful commands:

* `/realui` - open configuration.
* `/realui setup` - rerun setup flow.
* `/realui display` - open display preset setup.
* `/realui newdefaults` - review defaults that changed since 3.4.0 (upgrades only).
* `/rab` - action bar settings; `/rab bind` - hover keybind mode; `/naga` - toggle the Naga bar.
* `/rnp` - nameplate settings (also in `/realui` → Nameplates).
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

**Upgrading from 3.x to 4.0.0:** earlier versions bundled Bartender4, Grid2,
Platynator, Masque, and BadBoy — those folders are still in your AddOns folder
after an update. Grid2 and BadBoy stay supported as user installs: RealUI keeps
driving them as before while the built-in replacements stand down. Bartender4
and Platynator are no longer managed: RealUI's bars/nameplates stand down if
either is loaded, but their profiles are yours to configure. To switch to the
new built-in bars, delete or disable Bartender4, `/reload`, and run
`/rab import` once to convert your old keybinds and bar tweaks.

Your saved settings are kept on upgrade — which also means changed defaults do
not reach you automatically. RealUI opens a "new defaults" picker once per
character listing everything that changed since 3.4.0; tick what you want, or
reopen it later with `/realui newdefaults`.

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
* `/realui setupauras` - apply RealUI_Auras cooldown presets for your current spec.
* `/realui resetauras` - disable RealUI_Auras groups and restore native aura behavior.
* `/realui grid2update` - apply the RealUI Grid2 modernization update (when Grid2 is installed).
* `/realui resetinventory` - reset inventory and bank frame positions.
* `/realui reset` - ask what to reset: this character's setup, or everything.
* `/realui resetchar` - wipe every RealUI setting stored for this character (no prompt).
  Other characters and account-wide settings are untouched.
* `/realui newdefaults` - reopen the "new defaults" picker: every default that changed
  since 3.4.0, each applied only if you tick it. Opens itself once per character.
* `/realui editmode` - list the Edit Mode layout backup taken before a layout update;
  `/realui editmode restore` puts your saved layout back.
* `/realui resetall` - wipe every RealUI setting for every character (no prompt).

RealUI_ActionBars:

* `/rab` - open action bar settings (also on the Action Bars HuD config page).
* `/rab bind` - hover keybind mode: point at a button and press a key; ESC clears.
* `/rab import` - copy custom tweaks from an existing Bartender4 profile (optional).
* `/naga` - toggle the Naga side-button bar (bar 6).

RealUI_Nameplates:

* `/rnp` - open nameplate settings (also in `/realui` → Nameplates).

Other useful slash commands:

* `/ac` - open the AddOn Control window (which addons RealUI manages and positions).
* `/resetframes` - reset DragEmAll-managed Blizzard/custom frame anchors.
* `/framemover status` - show frame mover status.
* `/framemover config` - toggle frame mover config mode.
* `/framemover reset` - reset all frame mover positions (reset frames).
* `/configmode` - toggle RealUI config mode overlays.
* `/installwizard start` - run the install wizard.
* `/realui devcheck` - report any dev/diagnostic setting left in a non-shipping state;
  run it before reporting a bug, a stale toggle looks exactly like one.

Tips
----

Things that are easy to miss:

* **Infobar rows have an alt-click action.** Alt-clicking a guild or friends row invites
  that player instead of whispering them; alt-clicking a row in the currency block removes
  that character from the list; alt-clicking the clock opens the Time Manager.
* **Assign a bag item to a category** with **Ctrl+Alt+Right-click** on the item — this
  opens the "Choose bag" menu, which pins that item to a filter of your choice.
* **Config mode** (`/configmode`) shows drag handles for HuD elements, and puts a 20-man
  placeholder grid on the party/raid frames so you can position them solo.
* **Layouts are per spec.** RealUI keeps separate DPS/Tank and Healing layouts and switches
  between them with your specialization; most position and size settings are stored per
  layout, so adjust the one you are currently in.
* **Display Setup** (`/realui display`) sets UI scale, font size, and element scaling from a
  preset matched to your resolution. Re-run it if you change monitors or resolution.

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
* `RealUI_Nameplates`
* `RealUI_ActionBars`

Not packaged:

* `RealUI_Dev`
* `RealUI_Chat`

Recommended optional AddOns
---------------------------

These are no longer bundled, but RealUI detects and auto-configures them when
you install them yourself (from CurseForge/Wago/WoWInterface):

* **BadBoy** (plus `BadBoy_CCleaner`, `BadBoy_Guilded`) - chat spam and gold-seller
  filtering. RealUI does not filter chat itself; install BadBoy if you want that back.
* **Grid2** - advanced raid frames. RealUI ships its own party/raid frames as the
  default; installing Grid2 makes RealUI's frames stand down and applies the
  RealUI Grid2 profile automatically.
* **Masque** - button skinning. RealUI's bars skin themselves; install Masque if
  you prefer its skins (the "RealUI" Masque skin is always registered and available).

Bartender4 is *not* on this list: RealUI 4.0 no longer integrates with it. If it
is installed, RealUI's bars stand down to avoid doubled-up bars — disable it and
run `/rab import` to carry your old keybinds and tweaks into RealUI_ActionBars.
