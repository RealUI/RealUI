RealUI
[![Build Status](https://github.com/RealUI/RealUI/workflows/CI/badge.svg)](https://github.com/RealUI/RealUI/actions?query=workflow%3ACI)
[![RealUI Discord](https://img.shields.io/badge/discord-RealUI-7289DA.svg)](https://discord.gg/sasExJYxgf)
======

RealUI is a minimalistic UI designed to be functional, yet also efficient and elegant.

Information
-----------

* Supports retail WoW (Midnight, 12.1.x) and the WoW Forever beta (1.60.x) from the same download.
* Current release is 4.2.0 (Aurora 12.1.0.15).
* As of 4.0.0 the package contains **only RealUI's own addons** — no bundled third-party
  addons (standard embedded libraries such as Ace3, oUF, LibActionButton, and
  LibSharedMedia are still included, as in any addon). See "Recommended optional
  AddOns" below.
* RealUI includes the modernized setup pipeline, unified profile handling, and display setup stage.
* User settings are automatically migrated from nibRealUIDB to RealUIDB when needed.
* Report issues on GitHub or connect with us on Discord.

What's New in 4.2.0
--------------------

**If you upgraded from an earlier version, run `/realui newdefaults`**: profiles that saved "Cast by me"
for target debuffs are offered the new default there.

* **Nameplate debuffs show the ones that matter to your class**, the rule Blizzard's own nameplates use,
  so the rows are shorter on purpose. "All mine" brings the old rows back; Always show and Never show
  lists take spell IDs or spellbook names. The HuD target frame's debuffs default to the same rule.
* **Action bar page numbering:** each profile can number its pages like Bartender4 (the default) or
  like Blizzard. The install wizard's Action Bar Layout step offers the choice.
* **Auto-repair on the Durability block:** the tooltip shows the auto-repair setting, the estimated
  cost and the last repair; Shift + Left Click on the block toggles auto-repair.
* **Objective tracker** (`/realadv` → Tracker): a quest item button with a key binding, a fade during
  boss fights (not in a Mythic+ keystone), quest log capacity in the top header, green titles for quests
  ready to turn in, a "Wowhead link" entry in the quest right-click menus, and an optional mouseover
  reveal.
* **No more tracker taint.** The `GetAuraDataByIndex()` error in delves and LFR came from addon code
  tainting the tracker; the sources in RealUI and Aurora are removed, and the tracker and world-event
  bars are skinned again, restyled in place. A few frames keep Blizzard's look, or a plainer one, on
  purpose.
* **Colour modes:** all five of Aurora's colour modes, including the colour-blind ones, are in
  `/realadv` → Skins → Appearance, and the Skins colour pickers follow the mode until you change them.
* **The inspect window closes when you change target,** as Blizzard's does. The old bundled InspectFix
  is removed; on WoW Forever it blocked Inspect Talents.
* **Tracker options that changed:** a per-instance hide now fades the tracker out, and it stays
  clickable. The "collapse modules in" instance option, Difficulty Color and Wrap Text are removed.
* The micro menu stays hidden in a vehicle, the vehicle pitch controls are skinned, and the default zone
  text no longer sits on the PvP start timer.

What's New in 4.1.1
--------------------

A maintenance release. **If you upgraded from an earlier version, run `/realui newdefaults`**: the boss
timeline fix is applied through it.

* The Boss Abilities timeline and boss warnings sit where Blizzard's layout puts them, clear of the HuD.
* Trinkets and other items with a long effect description can be upgraded again.
* The LFR, dungeon and battleground ready popups, the ready check, role checks and group invites are
  skinned.
* Objects whose nameplate is only a progress bar show that bar with RealUI's nameplates on, and the
  minimap stays square inside a house.
* WoW Forever: action bars work on client builds from 1.60.1.70170 on, and Edit Mode no longer errors.
* `/realui grid` draws an alignment grid for placing frames by hand.

What's New in 4.1.0
--------------------

WoW 12 hides some combat information from addons. This release brings back what the game allows, adds
new frame features, fixes the layout on 1440p screens, and adds WoW Forever support.

* **Auras keep working in combat.** RealUI_Auras groups are drawn by Blizzard's own aura engine, so a
  group on your target no longer goes empty during a fight. Nameplate health text, the execute colour
  and the raid-cell health deficit read hidden health through Blizzard's curve functions, and raid cells
  show CHARMED while the charm state is hidden.
* **Boss frames** gain a cast bar under each frame, a border on the boss you are targeting, and the
  target frame's aura filters. Toggles are in Groups → Boss.
* **Nameplates** can show your combo points or class power on your target, current and maximum health,
  and who a cast is aimed at.
* **Profile exports carry every module's settings**, so an import restores the whole setup rather than
  only keybinds and colours.
* **1440p layout.** The Desktop High-Res preset uses a fixed 1200-unit canvas instead of doubling the UI
  scale. The bottom bar row and chat sit on the Infobar at any UI scale, and the Naga bar lines up with
  the bottom row until you move it.
* **WoW Forever beta.** RealUI loads on Forever (interface 16001). There, target and focus names show the
  surname, hunters get a pet happiness icon, and group cells show the master looter.
* `/realui editmode reset` rebuilds both RealUI Edit Mode layouts from the template.

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
* `/realadv` → Tracker - objective tracker fades, quest item button and display options.
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
2. Move your old `Interface` and `WTF` folders to a backup folder. They are in `World of Warcraft\_retail_\`
   for retail, or `World of Warcraft\_classic_beta_\` for the WoW Forever beta.
3. Copy the `Interface` folder from the download into that same folder.
4. Launch WoW and log in

Update
------

1. Exit WoW
2. Delete all RealUI and nibRealUI folders from `Interface\AddOns` (in `_retail_` or `_classic_beta_`)
3. Copy the `Interface` folder from the download into the same client folder.
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

**Action bar height at Large HuD (4.1.0).** Since 4.0.0 the HuD size offset was
counted twice for the action bars and cast bars, so at Large HuD the top action
bars sat 20px lower than intended. New profiles get the corrected height
automatically. Existing profiles are offered "Action bar height at Large HuD"
in the new-defaults picker. It removes the extra 20px once, keeps any height
you set with the HuD Vertical slider, and leaves bottom bars on the Infobar.
If you leave it unticked, your top bars stay where they are. Bottom bars always sit on the
Infobar either way. Small HuD is not affected.

Troubleshooting/comments/questions?
------------------------------------

Find a bug or want to post a comment? Please visit the [RealUI Discord](https://discord.gg/sasExJYxgf).

Slash Commands
--------------

Primary command aliases:

* `/realui`
* `/real`
* `/rui`
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
* `/realui editmode reset` - rebuild both RealUI Edit Mode layouts from the template.
* `/realui grid [spacing]` - toggle a screen alignment grid for placing frames by hand.
* `/realui resetall` - wipe every RealUI setting for every character (no prompt).

RealUI_ActionBars:

* `/rab` - open action bar settings (also on the Action Bars HuD config page).
* `/rab bind` - hover keybind mode: point at a button and press a key; ESC clears.
* `/rab import` - copy custom tweaks from an existing Bartender4 profile (optional). It also
  sets the profile's page numbering back to Bartender4's, which imported layouts use.
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
* **Quest item button.** Bind a key to "Use nearest quest item" under Key Bindings → AddOns →
  RealUI Tracker. The button uses the super-tracked quest's item first, otherwise the nearest one;
  right-drag moves it.
* **Durability block:** Shift + Left Click toggles auto-repair.

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
