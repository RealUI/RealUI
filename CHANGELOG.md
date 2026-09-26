## [Unreleased] ##
### Summary ###
RealUI now loads on the **WoW Forever** beta (1.60.x, Battle.net product `wow_classic_beta`, client folder `_classic_beta_`, interface `16001`). Forever runs the retail 12.1 UI architecture with Blizzard's `Camelot` overlay, so this is a flavor of the retail codebase rather than a classic port: every TOC now lists both interface numbers and the existing retail packaging job carries the build. Nothing changes on retail. Forever-only behaviour is gated on `RealUI.isForever`; "the 12.x code path exists" is gated on the new `RealUI.isTwelveAPI`, because `isMidnight` is false on Forever even though the code is 12.1-derived.

Two client facts shape the work and are still open on Blizzard's side: Forever has **no realms**, so `GetRealmName()` returns nothing, and on the current beta **SavedVariables do not persist across a reload**, so only defaults apply there for now.

Aurora's Forever skin pass lands alongside this (see the Aurora entries below).

Alongside the Forever work, this round rebuilds the parts of RealUI that went blank or stale under WoW 12's secret values. **RealUI_Auras groups now render on Blizzard's aura engine**, so they keep updating in combat. Nameplate health text, the execute colour and the raid-cell health deficit read secret health through Blizzard's curve and formatting APIs instead of hiding. Boss frames gain cast bars, a current-target highlight and aura filters. Nameplates can show your combo points or class power, health values, and who a cast is aimed at. Opening all bags on a full inventory no longer runs too long.

### Modified AddOns ###

  * RealUI
  * RealUI_ActionBars
  * RealUI_Auras
  * RealUI_Config
  * RealUI_Inventory
  * RealUI_Nameplates
  * RealUI_Skins
  * !RealUI_Preloads (and every other sub-addon TOC, for the interface line)
  * Aurora

### Added ###

  * add: **RealUI loads on WoW Forever.** All 15 TOCs declare `## Interface: 120100, 16001`. `RealUI_Skins` picks Aurora's `AddOns_Mainline.xml` or `AddOns_Forever.xml` from its TOC with the same game-type directive pair Aurora uses (`[AllowLoadGameType standard]` / `[AllowLoadGameType camelot][ExcludeLoadGameType standard, classic]`); the include moved out of `Libs\Libs.xml`, where directives cannot work, into `Libs\Aurora_Mainline.xml` and `Libs\Aurora_Forever.xml`, keeping the packager's debug/non-debug path swap. The `RequiredDeps` lines of `RealUI.toc` and `!RealUI_PreLoads.toc` are split per game type because four `Blizzard_Deprecated*` shims (Currency, Item, Pvp, Sound) do not exist on Forever
  * add: `RealUI.isForever` (interface 16000–19999) and `RealUI.isTwelveAPI` (`isMidnight or isForever`) in `Init.lua`
  * add: **profile exports now carry module settings.** All three scopes exported only their root profile, while module settings live in AceDB namespaces — 22 RealUI core modules including the bar arrangement, every RealUI_ActionBars bar's position and visibility, Skins' sub-tables — so an import restored keybinds and colours and sent every module back to defaults. The namespaces ride along under `__namespaces`, the import writes them back and fires the profile-changed callbacks so modules rebuild; older exports still import
  * add: Aurora — **serves retail and Forever from one TOC.** `Aurora_Mainline.toc` lists both interface numbers and selects `AddOns_Mainline.xml` or the generated `AddOns_Forever.xml` per line; `private.isForever` and `AURORA_DEBUG_PROJECT = 60` identify the flavor. Camelot-only skins live under `Blizzard_X\Camelot\`, mirroring Blizzard's paths, and skins that Forever shares with retail were made to tolerate Camelot's trimmed frames (FriendsFrame, InspectUI, TokenUI, MailFrame, ProfessionsBook, TrainerUI among them)
  * add: Aurora — **Camelot character panel**: mode tabs and side pane, paper doll (ranged and ammo slots, model control bar), reputation, skills, PvP rank, bank and equipment flyout. Bodies shared with retail moved to `Skin\shared\` with thin per-flavor callers
  * add: Aurora — Camelot collections and pet stable, the Statistics tab, the Legacy system window and swing timers, micro menu bar art, bag bar, token detail side pane, professions book page, spellbook category tabs, and a taint-safe nameplate level badge
  * add: **RealUI_Auras groups render on Blizzard's AuraContainer**, the engine-side aura renderer, so an enabled group keeps updating in combat. The old Lua scan could not read a target's or focus's aura list while the game keeps it secret, so those groups went empty exactly when they mattered. Group options map onto the engine's filters and layout and apply live. Player buffs can be cancelled with a right-click in combat, and tooltips come from the engine. What changes: a duration cap now also hides auras with no duration; spell lists match by spell ID (the editor converts names, and names saved earlier are converted at load); with desaturation on, your auras are listed before everyone else's; and debuff borders use the game's dispel colours rather than the Colours tab. A group with **Check Time Left** on stays on the old renderer, because the engine cannot filter on time remaining
  * add: **boss frames**: a cast bar under each frame (tinted when the cast cannot be interrupted), a border on the boss you are targeting, and the same aura filter options as the target frame, with debuffs defaulting to "Cast by me" and buffs to "Dispellable". Buffs now sit beside the debuffs instead of hanging into the next boss frame. The default gap between boss frames grows to make room for the cast bar; toggles for the cast bars and the highlight are in Groups → Boss
  * add: **nameplate combo points and class power**: pips along the bottom of your target's health bar for combo points, holy power, chi, arcane charges, soul shards and essence. On by default, under "Combo points / class power"
  * add: nameplate **health values**, current and maximum health with the percent (`15.2K - 45.5K - 33%`) inside the health bar. Off by default, under Texts
  * add: nameplate cast bars name the **target of the cast**, in its class colour, under the bar. On by default, under Texts
  * add: Forever's group finder can be dragged
  * add: Aurora — the Forever group finder is skinned after 1.60.1.70009 restyled it: panel chrome, side tabs, close button, result rows, and a first skin for the Who tab
  * add: Aurora — `/aurora mawbuffs` (and `/auroraMawBuffs` under RealUI) turns off Aurora's `ShouldShowMawBuffs` wrapper for testing, to measure whether it is still needed; it writes a Blizzard global, which taints the objective tracker's aura path
  * add: Aurora — `/aurora skinaudit` lists the skin modules whose `pcall` failed on this login, which is how the Forever pass was verified wave by wave; `Aurora/dev/forever_report.py` regenerates the Camelot-vs-Mainline gap report from the manifests

### Fixed ###

  * fix: **the character key threw at login on Forever.** Six sites built `"Name - Realm"` from `GetRealmName()`, two by direct concatenation, and Forever has no realm. The key is now built once in `Init.lua` and mirrors AceDB's own `charKey` exactly — on Forever that substitutes the active ruleset (`Hardcore`, `RP`, `PvP`, `PvE`) for the realm, the same way AceDB-3.0 does — because `RealUI.key` indexes AceDB's `profileKeys` and `char` tables in the sibling addon DBs. The sibling-DB reset, AddonControl and the Bartender4 layout import all read that one key now; the normalized-realm poll no longer spins forever there, and `GetAutoCompleteRealms()` is guarded
  * fix: **`GetSpecialization()` was nil on Forever.** The global is supplied by `Blizzard_DeprecatedSpecialization`, which loads only on retail and classic. Six call sites now use `C_SpecializationInfo.GetSpecialization()`, and the cooldown-preset lookup tolerates a nil spec instead of doing arithmetic on it
  * fix: the Infobar Start menu drops entries whose toggle does not exist on the client — Encounter Journal, Group Finder and Housing on Forever, where those Blizzard addons never load — and the menu dispatcher no longer calls a nil global
  * fix: the install wizard's combat-text CVar guard and Aurora's WardrobeCustomSets skip now key off the 12.x code path (`isTwelveAPI`), so Forever behaves like Midnight there
  * fix: **first login on Forever, six load errors.** `RAID_CLASS_COLORS` only holds the original nine classes there, so the error-frame colours fall back to fixed hex for MONK and DEMONHUNTER; `Blizzard_GroupFinder` never loads, so the LFGFrame skin hook and the auto-holiday tweak are skipped when their targets are absent; retail-only channel spell IDs no longer assert in the cast bar tick table; the landing-page minimap button is guarded; and both the Start block and the RealUI_Bugs error frame tolerate a missing BugGrabber
  * fix: **RealUI's EditMode layout was never actually active on Forever.** `C_EditMode.SetActiveLayout` indexes a combined list of presets followed by saved layouts, and RealUI assumed two presets. Forever ships a third, Gamepad, so every activation landed one slot early on the Gamepad preset — whose system list has no main action bar, which EditMode then hid as "not supported by the active layout". The preset count is now read from Blizzard's preset manager at runtime
  * fix: RealUI's EditMode layout no longer hides Blizzard's action bars when RealUI_ActionBars is not running (absent, disabled, or yielding to Bartender4): `BuildLayout` writes Blizzard's own Modern-preset entries for the whole bar cluster instead — action bars, micro menu, bags, status bars and end caps together, because Blizzard anchors those to one another (on Camelot the main bar hangs off the micro menu), and omitting them is not enough since EditMode leaves an omitted system as the previous layout had it. New **`/realui editmode reset`** rebuilds both RealUI layouts from the template on demand, inside the user-initiated write scope
  * fix: loot window tooltips showed nothing on Forever. The mouseover gate compared the slot type against the legacy `LOOT_SLOT_ITEM` globals, which that client does not expose; it now uses `Enum.LootSlotType` as Blizzard's own loot frame does
  * fix: on Forever, Camelot's day/night indicator no longer sits stranded in the screen corner after RealUI moves the minimap; it rides on the RealUI minimap as a small badge and is re-asserted after Blizzard's scale hook re-anchors it
  * fix: second Forever login — arena unit frames are not spawned when `CompactArenaFrame` does not exist (oUF indexes it unguarded; Blizzard's own container code guards on it the same way), and the minimap queue-status hook is skipped on Camelot, whose queue button has no `UpdatePosition`
  * fix: **BugGrabber never installed its handler on Forever.** RealUI_Bugs disables the standalone `!BugGrabber` and relies on its embedded copy, but that copy asks the client whether the standalone is enabled using the full player name, and on Forever the client answers "enabled for all characters" even for a disabled addon — so the embedded copy deferred to a standalone that never loads. The vendored lib now only defers when the standalone is actually loaded (a marked local patch, re-applied on each BugGrabber update). Interface `16001` is also in the VersionManager's supported list, which silences the "Unsupported game version" line at login
  * fix: **nameplate health text now shows while health is secret**, in instances and in open-world combat on Forever, by reading the percent through Blizzard's percent curve. The execute colour works the same way, and a raid cell's health deficit shows as a missing percent (`-23%`) while the value is secret. A raid cell also shows CHARMED when the charm state is secret
  * fix: opening all bags on a full inventory could hit "script ran too long" and leave items that could not be used; slots are now looked up by bag and slot instead of scanning every slot for each one
  * fix: at Large HuD the action bars sat 20px lower than intended because the HuD size offset was counted twice. New profiles get the intended height; existing profiles are offered "Action bar height at Large HuD" in `/realui newdefaults`, which keeps any height set with the HuD Vertical slider
  * fix: on a low-resolution display, the switch to Small HuD now reaches both layouts, not only the active one
  * fix: the durability block shows `--` until it has read your gear and retries when a read comes back empty, instead of showing `1` after login
  * fix: the player frame is easy to grab when unlocked; every mover now sits above the frame it moves
  * fix: party and raid members who join during combat get a frame immediately instead of after combat
  * fix: the world marker bar no longer errors every second during encounters, M+ and rated PvP
  * fix: the component toggles in Advanced settings and the cargBags check look up addon state by character GUID, as Blizzard does; on Forever a name lookup could miss
  * fix: the startup deployment check no longer reports a failure on Forever's interface version, and says what failed when something does
  * fix: action bars no longer error at login on Forever 1.60.1.70009, whose flyout lookup returns nothing for unused IDs (a marked patch in the bundled LibActionButton)
  * fix: the HuD config bar no longer errors when combat starts while it is open, and its tab highlight no longer errors when a tab is clicked while the bar slides in
  * fix: RealUI buttons honour the game's Lock Action Bars setting, and the config panel shows its state

### Changed ###

  * chg: uninterruptible nameplate casts are tinted purple instead of a second red, which read the same as "interrupt not ready". Existing profiles are offered it in `/realui newdefaults`
  * chg: the action bars profile scope is named `actionbars` instead of `bt4`; exports made under the old name still import
  * chg: unit frame tooltips use RealUI's own handlers on oUF 14's live unit, as oUF's author recommends, instead of Blizzard's `UnitFrame_OnEnter`
  * chg: **the Forever secure-snippet workaround is removed.** Blizzard fixed the load-order bug in 1.60.1.70009, so RealUI's party and raid frames spawn there and action bar paging and flyouts work in combat

### Known Issues ###

  * RealUI_Auras groups with **Check Time Left** on use the old renderer and can go empty in combat on target, focus and similar units while the game keeps their auras secret
  * Upgrading a trinket with a long effect text at an item upgrade NPC can be blocked (Aurora owns `GameTooltip_InsertFrame`); investigation in progress
  * On the current Forever beta, **settings do not persist across `/reload`** — the client discards SavedVariables writes. Only defaults apply, for every addon. Confirmed by the Forever developers; not a RealUI bug
  * `UnitName("player")` returns the full name on Forever while `UnitName("target")` does not; Blizzard says the final behaviour is not settled
  * On Forever, unit frames, group frames, action bars, nameplates, the group finder and the config have been checked in game; the tracker, infobar, inventory, tooltips and chat have had a static pass only

## [4.0.2] - 2026-09-13 ##
### Summary ###
A maintenance release. The headline fix is **nameplate health text and execute colouring recovering correctly** — RealUI had been treating "in combat" as the same thing as "auras are secret", and measurement in game proved those are unrelated: secrecy can already be on out of combat, can stay on through a combat-end edge for half a minute, and can switch on with no combat edge at all. The re-check now hangs off `C_Secrets.ShouldAurasBeSecret` instead. The durability infobar block no longer reports a reassuring **100%** when it has actually measured nothing, keybind mode's ESC really does clear the binding it says it cleared, and the tank-taunt threat cue survives matchmade raids.

Two libraries, LibRangeCheck-3.0 and LibDualSpec-1.0, are now fetched at build time instead of being committed to the repo.

Aurora updates to 12.1.0.9.

### Modified AddOns ###

  * RealUI
  * RealUI_ActionBars
  * RealUI_Dev
  * RealUI_Nameplates
  * Aurora (12.1.0.9)

### Added ###

  * add: `/rui` as a third alias for the config command, alongside `/real` and `/realui`
  * add: `/realdev aurasecrecy` — a developer probe for the aura-secrecy predicate. `watch` logs every `ShouldAurasBeSecret` / `InCombatLockdown` transition with its triggering event, and `arm` auto-fires a snapshot the moment auras go secret with nameplates up, reporting per-plate whether each aura container is forbidden and whether `SetSize`/`ClearAllPoints`/`SetPoint`/`SetShown` are refused. This is what disproved the combat proxy below, and what established that our own container writes are **not** being refused

### Fixed ###

  * fix: **nameplate health percentage and execute-range colouring could stay blank after combat, or blank out with no combat at all.** RealUI recovered these off `PLAYER_REGEN_ENABLED`/`PLAYER_REGEN_DISABLED`, on the stated assumption that health values stop being secret when combat drops. Measured in a Timewalking run, that assumption fails in three separate ways: secrecy was already on out of combat; it stayed on through a combat-end edge and remained on for a 29-second out-of-combat window; and it switched on with no combat edge at all. Combat edges are neither necessary nor sufficient. The re-check is now driven by `C_Secrets.ShouldAurasBeSecret`, carried on the cast bar's existing slow tick. The per-value `Accessible` check was always correct and is unchanged — what was wrong was only *when* we re-ran it, so the text still hides while values are genuinely secret
  * fix: **the durability infobar block could read 100% while its own tooltip listed 78–82%.** The block recomputed its percentage from scratch on every pass starting at "full", while the per-slot numbers behind the tooltip persisted from the last good read — so a pass where `GetInventoryItemDurability` returned no maximum for any slot wrote a reassuring `100%` over a true lower value. A pass that reads nothing was indistinguishable from a pass that reads everything at full. It now counts the slots it actually measured and keeps the last true value when that count is zero, rather than inventing a number. A durability block that quietly reads high is the one failure mode that costs gear
  * fix: **keybind mode said "cleared binding" and left the key on the button.** ESC printed a confirmation it had not earned, and captured keys did not display, on any bar mirroring Blizzard's binding set. Both now edit the Blizzard binding set the buttons actually read
  * fix: **the tank-taunt threat cue disappeared in matchmade raids.** The off-tank colour keys off main tank / main assist assignments, and a matchmade raid with no role requirements auto-flags arbitrarily many main tanks, so those flags carry no signal there. They are now ignored in exactly that case — mirroring what Blizzard does in its own raid frames — while the player's *assigned role* keeps counting, since a role someone chose stays meaningful where an auto-flag does not. Guarded for clients predating the API
  * fix: **name text on the small unit frames sat below the bar.** Focus, focus target, target of target and pet names are now centred on the health bar itself rather than offset from the frame's bottom edge, so the alignment holds across HuD size, the per-unit size sliders and layout changes
  * fix: **cast bar pushback text could run back over the spell icon.** The delay number was anchored once at creation and followed the time text around without ever being re-anchored, so it always grew rightward — fine on a left-anchored text block, on top of the icon on a right-anchored one. It now takes its side from the same branch as the time text
  * fix: the health-percent option description no longer claims the text returns when you leave combat. It does not; in instances secrecy routinely outlasts the fight

### Changed ###

  * chg: **LibRangeCheck-3.0 and LibDualSpec-1.0 are fetched from `.pkgmeta` at build time** instead of being committed to the repository, removing about 5,400 lines of vendored library code. Packaged builds pull the current upstream release of each; a source checkout no longer carries them, and development environments pick them up from the standalone addons `tools/config.yaml` installs. LibActionButton stays vendored — there is no upstream package source tracked for it — and keeps its BSD-3 notice
  * chg: Aurora updated to 12.1.0.9 — fixes an error at login from the chat edit-box border hook, which read the channel from whichever chat edit box was open rather than from the one being updated, and so indexed a nil whenever nothing was open. It affected any chat window whose default target is a channel, and also coloured those borders from the wrong channel when it did not error

## [4.0.1] - 2026-08-29 ##
### Summary ###
A maintenance release for the objective tracker and the Delves companion panel. **The objective tracker is skinned again** — it has rendered with Blizzard's styling since 4.0.0 shipped with that skin gated off, because it was aborting tracker layout in LFR and delves. The throw is guarded at its source: Blizzard's own `ShouldShowMawBuffs` reads a player aura without a guard, and under WoW 12's secret-aura rules that read errors rather than coming back empty once addon code is anywhere in the execution. On the Delves side, the companion abilities panel gets the page arrows and skin it was missing, hovering the companion portrait no longer throws, and both Delves companion frames can be dragged. Thanks to Numy for the workaround.

Aurora updates to 12.1.0.8.

### Modified AddOns ###

  * RealUI
  * Aurora (12.1.0.8)

### Changed ###

  * chg: Aurora updated to 12.1.0.8 — **the objective tracker skin is enabled again**, gated off since 12.1.0.5; a full play session produced no tracker errors. This removes the symptom rather than the cause: the skin still writes to tracker frames in ways the taint-safe rewrite is meant to eliminate, and the gate is one flag away if faults return. The world-event/scenario widget skin stays gated, so those widgets keep Blizzard's styling for now

### Fixed ###

  * fix: **the objective tracker threw "Auras cannot be accessed when secret while tainted by 'RealUI_Skins'" in LFR and delves**, taking the stage block down mid-layout. Blizzard's `ShouldShowMawBuffs` reads `GetAuraDataByIndex("player", 1, "MAW")` unguarded, and all three of its callers sit inside the tracker's own update and layout path. It is wrapped to answer `false` when the client reports auras as secret — the only honest answer at that point, and the Maw/Torghast surface it gates is legacy content
  * fix: **the Delves companion abilities panel is skinned** — two blank boxes where the page arrows belong, plus a stock close button, role dropdown and portrait ring. The arrows went through a skin function that clears a button's textures, so Blizzard's art was stripped with nothing put back; the panel also inherits a portrait template whose child frames the texture strip never reaches
  * fix: **hovering the Delves companion portrait no longer errors** with `attempt to perform arithmetic on a secret number value`. Skinning the tooltip hierarchy makes a widget height read back secret, which Blizzard's tooltip code then adds padding to. The guard the skin already carried had never applied — it patched the mixin rather than the frame the game had already copied it onto — and it now sits where the call actually runs, with the tooltip show that the throw used to skip re-asserted
  * fix: **both Delves companion frames can be dragged.** The abilities list was in no drag list at all, and the configuration frame was registered as an always-loaded frame when it belongs to a load-on-demand addon, so the drag hook ran before the frame existed and never took

## [4.0.0] - 2026-08-26 ##
### Summary ###
RealUI 4.0.0 completes the de-bundling: the package now contains **only RealUI's own addons**, plus the embedded Aurora and the standard embedded libraries (Ace3, oUF, LibActionButton, LibSharedMedia). Three new RealUI-owned components take over from the addons that used to be bundled — **RealUI_Nameplates**, a clean-room rebuild of the classic KUI look on WoW 12's secure aura containers and engine castbars; **built-in party/raid frames** on the same oUF 14 foundation as the rest of the HuD; and **RealUI_ActionBars**, six bars on LibActionButton-1.0 laid out directly from the HuD settings. Grid2, BadBoy and Masque remain supported as optional installs — put one back and RealUI configures it as before while the built-in replacement stands down. Bartender4 and Platynator support is removed; `/rab import` converts old Bartender4 keybinds and bar tweaks, and runs once automatically on first load after upgrading.

Upgrades are opt-in by design — the "new defaults" picker lists every default that changed since 3.4.0 and applies only what you tick, and when a release updates the shipped Edit Mode layout, yours is backed up first and `/realui editmode restore` puts it back.

Underneath, the WoW 12 hardening campaign continues: secret-value guards across the HuD, auras, nameplates and skins; EditMode layout writes gated to user-initiated scopes; and a taint hunt that closed the injectors behind the delve tracker breakage, the login-time chat taint, and the talent-hover action-bar poisoning. The remaining world-map errors were traced to a confirmed Blizzard engine bug ([WoWUIBugs #453](https://github.com/Stanzilla/WoWUIBugs/issues/453)).

Aurora updates to 12.1.0.7.

### New AddOns ###

  * RealUI_Nameplates
  * RealUI_ActionBars

### Modified AddOns ###

  * RealUI
  * RealUI_Auras
  * RealUI_Config
  * RealUI_Dev
  * RealUI_Inventory
  * RealUI_Skins
  * RealUI_Tracker
  * Aurora (12.1.0.7)

### Added ###

  * add: **RealUI_Nameplates** — clean-room KUI-style nameplates replacing bundled Platynator: engine-driven castbars (duration-object timers, interrupt-ready lavender/red coloring, uninterruptible shield + tint, empower stage ticks), three aura rows (your debuffs, crowd control, dispellable/enrage buffs with dispel-type borders) on Blizzard's secure aura containers, execute→casting→class→tapped→threat→reaction health coloring with off-tank awareness, name-only friendly plates with role colors, per-state alpha (target always full), configurable aura anchors — options in `/realui` → Nameplates and `/rnp`
  * add: **built-in party/raid frames** (HuD UnitFrames) replacing bundled Grid2: oUF 14 secure headers covering party, flex, and full 40-man raids; class-colored health with incoming heals and absorb bars; deficit/status text (charmed/feign/offline/dead/vehicle) and name; dispellable-debuff center icon and my-HoTs/shield left icons with a curated-list filter toggle; role/leader/assist/raid-marker/ready-check indicators; threat and healer target borders; out-of-range fading; Clique click-casting support; config-mode shows a 20-man placeholder grid for positioning; options under Unit Frames → Raid
  * add: **RealUI_ActionBars** — six action bars on LibActionButton-1.0 (BSD-licensed) replacing bundled Bartender4: bar positions computed live from the RealUI HuD settings (layout/spec/HuD-size changes re-flow the bars automatically), full paging incl. Druid prowl page, stance and pet bars (adopted Blizzard buttons — clicks stay Blizzard-secure), bar 1 pressed by your existing ACTIONBUTTON keybinds, hover keybind capture via `/rab bind`, per-bar visibility conditionals with an opt-in fade state, Naga bar (`/naga`), RealUI button skin built in with automatic Masque handoff when Masque is installed, `/rab` config (also reachable from the Action Bars HuD page)
  * add: `/taintscan` field-level taint scanner; `/taintlogging` gains a level argument (bare toggle uses level 1)
  * add: `/realui devcheck` — reports any dev or diagnostic setting left in a non-shipping state (taint logging still on, the `GameTooltip_InsertFrame` A/B toggle, disabled skins, leftover harness keys). Worth running before reporting a bug: a stale toggle from an earlier debugging session looks exactly like a fault
  * add: dev A/B toggle `/auroraInsertFrame` for the GameTooltip_InsertFrame taint investigation (registration now load-order safe)
  * add: README "Recommended optional AddOns" section — BadBoy, Grid2, and Masque as supported optional installs with auto-detection
  * add: **cast bars and the class resource can be pinned to a unit frame** — a new "Anchor To" option (Screen / Player / Target / Focus) on the Cast Bars and Class Resource config pages; pinned elements follow their unit frame, and dragging one in config mode saves the offset relative to that frame instead of the screen. Switching between screen and pinned keeps the element visually in place rather than teleporting it
  * add: **instant loot** — with auto-loot on, every eligible slot is looted immediately and the loot window never opens. Slots that cannot be looted (full bags, a locked slot) are left alone and the window opens with a sound instead of silently dropping them; bag-family and partial-stack checks mean no loot call is issued that the server would refuse. Account-wide toggle under UI Tweaks
  * add: **auto-repair at merchants** — repairs all gear on the first visit to a repair-capable vendor, optionally from guild funds when your allowance covers the cost, otherwise your own money; prints the amount, or says so when you cannot afford it. Toggles under Core → Infobar → Durability Settings, alongside the existing repair-mount picker
  * add: **horizontal party layout** — party frames can be arranged in a row instead of a column, and party now has its own anchor (`RealUIPartyAnchor`) separate from raid, movable in config mode
  * add: `/realdev bagmenu` — diagnostic reporting per-row checkbox state in the inventory "Choose bag" menu
  * add: **choose your own Edit Mode layouts per role** — two pickers in HuD config → General select which Edit Mode layout RealUI keeps active for DPS/Tank and for Healing. A user-made layout can now be the one RealUI re-asserts on reloads and spec swaps instead of being replaced by it; the RealUI layouts stay the maintained defaults, and a configured layout that gets deleted falls back to them
  * add: **a "new defaults" picker** (`/realui newdefaults`) — WoW only applies changed defaults to settings you have never touched, so every improvement to a default was invisible to existing profiles. The picker lists each default that moved since 3.4.0, marks the ones your profile already matches, and applies only what you tick. Elements pinned to a unit frame move to their new default position rather than staying put. Opens itself once per character, then only on request
  * add: **per-component on/off switches** — `/realadv` → Core → Components turns the optional suite addons (Combat Text, Inventory, Nameplates, Tooltips, Auras, Tracker, Chat, Action Bars) on and off per character without going near the AddOn list, with a reload prompt where the component needs one
  * add: **an Action Bar Layout step in the install wizard** — pick how many bars sit centre versus bottom and which side the side bars take, with a live schematic that redraws as you choose. Reachable afterwards from HuD config → Other → Action Bars
  * add: **RealUI_ActionBars settings embedded in the RealUI config tree** — Advanced Options → Action Bars, alongside the standalone `/rab` window, following the RealUI_Auras precedent. A component switched off renders an explanatory stub instead of vanishing from the tree
  * add: **the vehicle exit button is positioned by RealUI**, with its own scale and position settings, and re-asserts itself when Edit Mode moves it
  * add: boss frame **alternate-power-only** toggle (oUF `displayAltPowerOnly`), off by default
  * add: RealUI's own fonts on action bar button text — the number face for hotkeys and counts, the text face for macro names
  * add: **a per-character bag position lock** — a padlock button beside the bag close button freezes the bag position; the bank locks separately from your bags, and locking freezes the whole cluster including categorized bags, so an alt never inherits a main's lock
  * add: **a notice when a core HuD component is switched off** — roughly eight seconds after login RealUI names any core piece (cast bars, unit frames, class resource, spell alerts, infobar) disabled in the active profile, and says plainly that it is a setting rather than a fault. `/realui devcheck` reports the same. A switched-off component is otherwise indistinguishable from a broken one — a stale flag from a 3.x-era fault left cast bars off in a healing profile for months with nothing on screen to explain it. A normal login stays silent
  * add: dev diagnostics for the reference-layout work — `/realdev layoutdump` captures every HuD anchor (including group frames) as pasteable values, `/realdev grid [px]` overlays an alignment grid, and `totshape`/`ufvert`/`totwatch`/`smallnames`/`fillstate`/`copydiag` probe the unit-frame and chat-copy faults they were built to chase
  * add: **filter, sort and duration controls on the unit frame aura groups** — player buffs, target buffs and target debuffs each carry a filter preset (everything / only yours / dispellable), a sort order, and a maximum-duration cutoff, resolved through the engine's own candidate filters and applied live without a reload (HuD → Units)
  * add: **Infobar font settings** — Core → Infobar → Font picks the family and size; size 0 follows your chat font
  * add: **"Re-attach elements to sliders"** (HuD → General) — hand-dragged HuD elements stop following the Vertical and Anchor Width sliders by design, and there was previously no way back; this returns them to slider control, and can be undone until you reload
  * add: **the pet, target-of-target and focus-target frames can be pinned** to their primary frame through the same "Anchor To" option as the cast bars, so they follow it; offset inputs grey out while the frame mover owns the frame
  * add: **the Edit Mode layout is backed up before RealUI rebuilds it** — a release that changes the shipped layout has to rebuild the auto-generated RealUI layouts, which used to silently discard hand-placed frames. The previous layout is now saved first, `/realui editmode` lists what is stored, and `/realui editmode restore` puts it back. Assigning a layout of your own to a role (HuD config → General) keeps RealUI's hands off it entirely

### Changed ###

  * chg: **the package no longer bundles third-party addons** — BadBoy(+CCleaner/Guilded), Bartender4, Grid2(+LDB/Options/RaidDebuffs), Platynator, and Masque are out of the zip. Grid2 and BadBoy remain supported: installing one makes the RealUI replacement stand down and RealUI applies its classic profile as before
  * chg: **Bartender4 support is removed** — RealUI no longer drives BT4 profiles, layout, or dual-spec sync; the bars scope now switches RealUI_ActionBars profiles instead (existing profile exports and scope links keep working). If Bartender4 is loaded, RealUI's bars stand down to avoid doubled bars. Upgrading users get their BT4 keybinds and bar tweaks converted once automatically; `/rab import` re-runs the conversion manually
  * chg: **Platynator support is removed** — the bundled Platynator profile, addon-control integration, and profile migration tool are gone; RealUI's nameplates still stand down if Platynator is loaded, but its profile is yours to configure
  * chg: **`/realui reset` now asks before destroying anything** — it used to wipe every setting for every character instantly with no confirmation, the only destructive command in the suite that never asked. It now offers "This Character" or "Everything", the latter behind a second confirmation. "This Character" wipes every RealUI setting stored against that character — layout, spec-profile mapping, Edit Mode choice, Infobar state, and that character's entry in each suite addon — while account-wide settings and your other characters stay untouched. `/realui resetchar` and the new `/realui resetall` stay as unprompted quick paths
  * chg: a full reset now clears **all** RealUI settings — skins, auras, nameplates, tracker, inventory, tooltips, chat, combat text and bars — instead of leaving half the suite configured. Third-party saved variables are never touched: Bartender4 and Platynator data belongs to your own installs (support removed), and the captured error log is kept so a UI reset does not throw away bug reports
  * chg: the Advanced AddOn List "RealUI" set counts only addons actually installed (optional addons no longer over-report), and gains RealUI_ActionBars/RealUI_Nameplates entries
  * chg: the Action Bars HuD config button opens RealUI_ActionBars settings
  * chg: Grid2 modernization dev-test skips cleanly (instead of failing) when Grid2 is not installed
  * chg: Clique added to OptionalDeps so click-casting registration catches the group headers
  * chg: **cast bars and class points are pinned to their unit frames by default** — they follow the player, target and focus frames instead of sitting at fixed screen positions. Screen anchoring stays available per element via "Anchor To", and existing profiles keep their saved placement until they accept the change from `/realui newdefaults`
  * chg: **"Link Layouts" is a single account-wide setting** rather than one copy per layout, which could previously read on in one layout and off in the other at the same time
  * chg: **the map coordinate overlay is retired** — Blizzard's native coords panel renders the same player and cursor values from inside secure code, so RealUI's hand-rolled overlay (which had to dodge the world-map pin taint path by hand) is gone and the two native CVars are enabled during setup instead. Existing installs need to re-run Display Setup, or tick "Player/Cursor map coordinates" in Interface options, to turn them on
  * chg: the 4K Desk display preset now boosts infobar and HuD config bar scaling to match 4K Theater — pixel-perfect at 2160p lands near 0.36 effective scale, which left those elements too small to read. Re-run Display Setup to pick it up
  * chg: the inventory "Warbound until equipped" bag filter now uses Blizzard's own label instead of the raw internal name
  * chg: LibRangeCheck-3.0 upgraded from 1.0.17-10 to 1.0.17-13
  * chg: **unit frame aura icons default to 28px** (player buffs, target buffs and debuffs) and their timers are drawn by oUF instead of the cooldown spiral's own countdown numbers, which cannot be restyled by an addon — one compact timer per icon at the bottom of the art. Existing profiles keep their saved size until changed
  * chg: the raid Enabled and Horizontal party layout toggles now prompt for a reload — both are spawn-time secure-header settings, and applying them live left the frames in a stale layout
  * chg: the Groups config tab is now "Party / Raid" and carries the party-specific options; party and raid share the same cell settings, so a separate tab would have shown every control twice
  * chg: Status Text on unit frames defaults to **Both** (health and power). The previous default rendered as blank, which cost at least one tester a death for want of a visible health value
  * chg: spell alerts are anchored to the screen centre and sized by their own scale setting, instead of riding the HuD vertical slider — they are meant to frame your character, not move with the UI. The width slider is replaced by a scale slider
  * chg: Aurora updated to 12.1.0.4 — the delve objective-tracker taint is resolved (see Fixed); chat skin restored to the "Skin Chat" setting; delve entry screen, delve tracker block and criteria bars, reputation filter dropdown and collapse buttons, spellbook, professions, quest log headers, calendar, chat scroll arrows and world map buttons all skinned or repaired; first skins for the icon-bearing UI widget templates. Supersedes 12.1.0.3 — reputation frame rebuilt for 12.1's ScrollBox (rows, headers, and bars were entirely unskinned because the old pre-ScrollBox hooks no longer exist; at-war factions are tinted red again, which Blizzard shows nowhere in the list); item quality borders hidden on bags and vendors again (12.1 routes them through a mixin method the old global hook never saw); dropdown menu backgrounds no longer inherit Frame Opacity, which could make them unreadable; new skin for the scenario/delve Tiered Entrance Traits flyout; talent-derived frames no longer have their own backdrop stripped immediately after it is applied (Altar of Corrosion and other Generic Trait layouts rendered with no frame at all); Achievements header restructure, profession spec tab lock icon, and housing/endeavor toast effect layers; skinned-state tracking moved off Blizzard frame tables into a weak side table. Also carries 12.1.0.2's secret-value guards across the retail skin hooks
  * chg: **the PvP match scoreboard no longer errors and renders fully skinned** — the post-match table threw repeatedly on values the engine hides during a match, and its scroll areas drew without a backdrop; reward loot buttons are square like the rest of the UI
  * chg: Aurora updated to 12.1.0.5 — scrollbar arrows now match Aurora's style from login instead of switching after the first scroll (and no longer flicker back on hover); the chat return-to-bottom arrow finally matches the other two, with the unread-below pulse kept; community/guild avatars and Club Finder logos load again (the skin's icon crop was making a protected call refuse them); the vehicle/override action bar is skinned. **The objective tracker and world-event widget skins are temporarily disabled**: they were found writing the tracker's internal layout state under addon taint, which broke protected reads mid-delve; both return after a taint-safe rewrite (tracker and widget areas render with Blizzard's styling until then)
  * chg: **bags open bottom-right by default** instead of the top-left corner, where they covered the minimap; the cluster grows up and left from there. Existing characters keep their saved position
  * chg: the default chat position now clears the Infobar at any resolution — the old fixed offset put the chat box on top of the bar at high display scales. Applies to new installs and setup re-runs
  * chg: **action bar options no longer offer settings the HuD layout owns** — rows, grow direction and position on bars 1–5 are computed by the layout (swaps, spec changes and HuD size re-flow them), so those controls are hidden there with a note, and stay available on bar 6. Button size, padding, scale and the rest were always yours and stick as before
  * chg: unit frame aura timers read `51m`, `3h`, `2d` instead of `51 m` — the timer text now uses a structured engine format with magnitude tiers rather than the locale's spaced abbreviation
  * chg: **target debuffs show only the ones you cast**, sorted by time remaining — the row used to show every debuff from every source, which on a group target is dozens of icons carrying nothing you can act on. "Everything" is one dropdown away (HuD → Units → Target); existing profiles keep their setting and are offered the change through the new-defaults picker
  * chg: **"Link Layouts" starts off** for new installs — it makes every position change apply to both layouts, which surprised people who had not asked for it. Existing settings are unchanged, and the setting is account-wide
  * chg: **the objective tracker's default position clears the right-hand action bars** — the shipped offset sat inside the side-bar column, and the Edit Mode template and the tracker's own seed disagreed about where the tracker belonged, with the worse value winning. The offset is now derived from the bar geometry in one place both readers share
  * chg: **nameplate debuffs centre above the plate** instead of anchoring to its left edge and overflowing past its right; centred anchor presets are available for every aura row
  * chg: **the world-map errors are documented as a Blizzard engine bug** — the blocked `SetPassThroughButtons` on opening the map, the secret-value errors on POI tooltips, and the quest-offer pin errors are all one confirmed engine fault ([WoWUIBugs #453](https://github.com/Stanzilla/WoWUIBugs/issues/453)) that fires for any addon with map pins; a controlled elimination of seven RealUI-side candidates confirmed none of it is fixable from an addon. A redundant super-tracking subscription found during that work was removed — it ran a full point-of-interest rebuild twice per change
  * chg: Aurora updated to 12.1.0.6 — the world-map hooks that tainted the map-open path are gone (the NavBar nudge and border restyle now ride Blizzard's own minimize/maximize events); the chat system is no longer tainted at every login (chat-config tabs are skinned on the frame's OnShow instead of wrapping the tab pool Blizzard acquires from); auction house and item-link comparison tooltips have their backdrop again via GameTooltip's taint-safe path; community and guild list entries are skinned again through Blizzard's own per-element callback; the battleground scoreboard builds without errors and its reward icons are square
  * chg: Aurora updated to 12.1.0.7 — hovering a talent button no longer poisons the action-bar highlight system for the rest of the session; the cosmetic hook responsible is removed outright, so the rotating gold sheen on talent nodes returns until a taint-free suppression lands

### Fixed ###

  * fix: **the delve objective-tracker error** — "Auras cannot be accessed when secret while tainted by 'RealUI_Skins'" fired in delves and aborted tracker layout. Two things had to be true: Aurora wrote four shared font globals (any addon writing a global taints it permanently, and every later reader inherits that), and the tracker skin stored fields directly on `ScenarioStageBlock` — the very frame whose `LayoutContents` reads auras. Removing the frame writes broke the chain; the chat skin, force-disabled while this was chased, is back under its own setting. Verified across a full delve with `taintLog 2`
  * fix: **layout switching no longer resets your settings** — three separate causes: HuD positioning overwrote saved values with recalculated defaults on every switch (UI vertical position, action bar heights, cast bar offsets); the profile coordinator still only switched Bartender4's database, so `RealUI_ActionBarsDB` never followed RealUI ↔ RealUI-Healing; and frame positions were restored against the previous profile's saved coordinates, which is what stranded focus and focus-target frames. `RealUI_ActionBars` also stopped force-writing button size, padding and scale on every recompute
  * fix: **bar profiles never followed layout switches at all** — the scope-link defaults were declared per-profile while the coordinator reads them per-character, so the table never existed and every scope read as unlinked
  * fix: **world markers did nothing when clicked** — the buttons carried the right secure attributes but never registered for clicks, so the secure handler was never dispatched. Both click phases are registered, since the handler acts on down or up depending on the "cast on key down" setting
  * fix: unit frame **buffs and debuffs no longer overlap** where they meet in the middle of the target frame, and their timers are legible
  * fix: **spell alerts** no longer move with the HuD vertical slider
  * fix: **the LFG eye** stays docked to the minimap — Blizzard's micro-menu layout pass re-anchors it on every update, which RealUI's one-shot setup never survived — and now follows the minimap's configured corner
  * fix: **minimap buttons from LibDBIcon** (Details and others) are collected into the button collector instead of staying stuck to the minimap
  * fix: **infobar tooltips** for Currency, Friends and Guild rendered far larger than the rest — those three use a text-table provider that ran its widths and row heights through physical-pixel scaling while LibQTip lays out in UI units
  * fix: **the hearthstone infobar block can be dragged** like every other block; its secure casting overlay was swallowing the drag
  * fix: **action bars** — side bars sit fully on screen with abbreviated keybind text, the vertical slider works on every layout, cooldown swipes fill the button face, the assisted-combat spinner is constrained to its button, and configured padding is now the actual visible gap (borders were not counted, so 0 overlapped and 4 gave 2px)
  * fix: **party frame** role, leader and raid-marker icons render above the health fill instead of behind it
  * fix: **boss frame debuffs** anchor to the frame's left edge and grow left
  * fix: **nameplate** aura timers are legible and the classification icon no longer overlaps castbar icons
  * fix: focus, focus target, target-of-target and pet name text sits on the bar baseline
  * fix: WoW 12 secret-value hardening across the HuD — `UnitIsPVP`/`UnitClassification`/health-color chain guards (secret table keys error like secret booleans), status/end-box unit queries guarded with `issecretvalue`, secret-safe PvPIndicator override for boss/arena frames (upstream oUF passes a secret honor level to `C_PvP.GetHonorRewardInfo`; logged upstream)
  * fix: RealUI_Auras no longer errors when the aura LIST itself is secret for tainted code (hostile/target units in combat) — the scan degrades to empty for that redraw; the full secure-container migration is tracked for a follow-up
  * fix: EditMode layout writes gated behind user-initiated scopes — automatic SaveLayouts calls tainted layoutInfo and made CooldownViewer throw on every UNIT_AURA
  * fix: config setup error when nameplates are activated
  * fix: `/auroraInsertFrame` registration no longer errors when RealUI_Skins loads before the RealUI core addon
  * fix: **RealUI_Auras options never appeared** — the addon errored on load looking up AceConfigRegistry, which lives in the load-on-demand config addon; the Auras group is now pulled into the options tree by RealUI_Config rather than pushed into it, so it no longer races the registration
  * fix: RealUI_Tracker options had the same problem more quietly — its config never reached the options tree at all
  * fix: **dragging an infobar block broke it** — the block was unanchored mid-drag, which then errored every frame until it was dropped, and left the block's tooltip anchored to nothing
  * fix: friends list errored on Battle.net friends who are online but not in a game
  * fix: spell alert and other HuD config sliders no longer error on a partly-populated layout
  * fix: **item icons in bags and at vendors kept Blizzard's rounded quality border** instead of RealUI's square one
  * fix: regular bag slots were never skinned at all — they now get the same treatment as bank slots, which also restores the yellow quest-item border
  * fix: action bar buttons show their backdrop again (empty slots were fully transparent), and the hover, pushed, and checked overlays are flat and square instead of Blizzard's oversized rounded glow
  * fix: **party/raid frames no longer default on top of the action bars** — they use per-layout positions measured from a hand-tuned reference layout: left edge at mid-height for DPS/tank, and for healing the group block sits in the gap between the action bars. Party and raid share the same region so the block does not move as the group grows, but each is independently movable
  * fix: **every frame you had not moved jumped to screen centre when switching layout** — the profile-switch path restored positions unconditionally, and the window library centres any frame with no saved position ("smack it in the center", as its own source puts it). A reload corrected it because the startup path had the guard the switch path was missing. Group frames showed this most obviously, but it applied to every movable frame
  * fix: **cast bars and the class resource pinned to a unit frame lost their pin on every layout switch** — the same profile-switch path never re-applied unit-frame anchoring, so pinned elements fell back to screen positioning
  * fix: **action bars sat about 150px too high in the Healing layout** — `HuDY` and `ActionBarsY` were absent from that profile and were read as zero rather than falling back to the layout's own defaults, so the bars were positioned against screen origin instead of the intended baseline
  * fix: **the vehicle exit button never appeared** — Blizzard parents it to the main action bar, which RealUI hides wholesale, so no amount of showing it could make it render. It is now re-parented and positioned by RealUI
  * fix: **`/naga` did nothing** — the Naga bar stayed hidden however often it was toggled. WoW's secure state driver only writes a visibility attribute when the value *changes*, and the cached hidden state survived unregistering the driver, so a re-enabled bar was told to hide forever. The command also called a bar-refresh function that did not exist, and a layout refresh was re-hiding the bar behind it
  * fix: reload prompts no longer stack on top of the install wizard during first-time setup
  * fix: the inventory "Choose bag" menu no longer drops every remaining filter when one entry is missing, and menu labels no longer overdraw their checkbox
  * fix: removed leftover debug output that printed to chat for every item on every bag update
  * fix: spell alert width slider minimum no longer floors above its own default
  * fix: guarded the cooldown hook against forbidden cooldown frames
  * fix: **the small green box on the action bars** — it was the action bar library's equipped-item indicator, a green border drawn on any button holding currently equipped gear, re-shown on every button update past the skin's one-time hide. It stays hidden now; the empty-slot "add row" artwork is suppressed on every update as well
  * fix: **dispellable debuffs on the target frame no longer draw a doubled icon** — the engine stamped its full-size border artwork over the cropped icon whenever a debuff carried a dispel type. The border texture is now preserved as RealUI's own 1px button border and the engine only colors it, so a dispellable debuff reads as a color-coded border instead of two stacked squares (raid frames use the same path)
  * fix: the HuD config's "AddOn Control" and "Display Setup" buttons toggle their panel closed on a second press, matching "Advanced Options"
  * fix: **categorized bags can be dragged** — dragging any bag moves the whole cluster; previously only the primary bag responded
  * fix: **both unit frames slid to the middle of the screen** whenever anything recalculated HuD positions — most visibly on touching the HuD Vertical slider. A missing width value was read as zero instead of falling back to the shipped default, collapsing the unit frame spacing from 380 to 80. The frames looked right at login only because they are placed before the first recalculation runs
  * fix: **the HuD Vertical slider did nothing on some characters, and "Link Layouts" did not link** — the config panel and the positioning code resolved the current layout differently, so slider writes landed in one layout's table and were read back from the other; and the link itself was only ever a one-shot copy taken at the moment you ticked it, so every later slider move applied to just one layout. Position edits now mirror to both while linked
  * fix: saved HuD positions survive reloads and spec swaps reliably — the same missing-value handling was also placing the Healing layout's action bars incorrectly
  * fix: **the spellbook "not on any action bar" indicator** is square like the rest of the UI, instead of a rounded glow overhanging the icon by several pixels
  * fix: dragging a frame whose position is locked no longer throws an error
  * fix: the bottom action bar row derives its clearance from the larger of the live Infobar height and the scaled bar constant, so an Infobar caught mid-construction can no longer seat the row on top of it
  * fix: **target-of-target and focus-target no longer flicker** or change height when other unit frames are adjusted. Three separate faults stacked here: an eventless status poll was disabling bar smoothing and re-tessellating the angled fill every tick, the trapezoid vertex writes were unguarded, and `SetReverseFill` re-anchored the fill even when the direction had not changed
  * fix: **copying chat came out completely blank** whenever the buffer held a Battle.net friend name — one protected `|K` sequence makes the edit box refuse the whole `SetText`, so a single line silently emptied the window. Those sequences are replaced with `[BNet]`, and the copy window scrolls back to the top instead of opening parked past short content
  * fix: **frames could get stuck mid-drag in config mode** — the player and focus cast bars especially would not release, and blocked clicks everywhere else until a reload. The drag now always stops the move, and coordinate reads are guarded against the secret values that were throwing mid-drag
  * fix: **the class resource teleported after being dragged** while pinned to a unit frame — screen coordinates were being written into an anchor-relative setting, so the next refresh read them as an offset from the frame
  * fix: **the pet and stance bar decorations are back** — the event that draws them was registered inside a branch that only ran when Bartender4 was installed, so once it was gone they never appeared at all
  * fix: **auto-attack no longer flashes a red box larger than its button** — the flash overlay is atlas-sized artwork and overhung RealUI's 27px buttons
  * fix: **an error storm in battlegrounds** — nameplate class colours, role and classification reads went through values the engine hides in combat; they are now guarded, and fonts are set when the plate is created rather than on every update
  * fix: movers for unnamed frames show a readable label built from the module and setting instead of a frame path ending in a hex address
  * fix: the objective tracker and chat config panel are exempt from the config-mode frame stripes — the stripe textures were addon-owned writes onto frames whose updates are secure
  * fix: **the nameplate absorb bar tracks in combat** — it now runs on the engine's heal-prediction calculator (the same one the health element uses) instead of computing health + absorb in addon code, which WoW 12 forbids mid-combat; the overlay spans from the health fill's edge so no arithmetic is needed anywhere
  * fix: the secret-value guards on nameplate texts, raid cell texts, the castbar interrupt check and cooldown timers now check accessibility up front instead of catching the engine's refusal — same behaviour, but ~2,400 taint-log entries per session stop being generated, which is what made the remaining log readable enough to find real taint bugs
  * fix: **a session-wide taint source in the skin engine is closed** — a global `SetCVar` hook marked every Blizzard execution that set any CVar as addon-tainted; it is replaced by an event listener. Decorative stripe textures are also no longer added inside the objective tracker or chat config, where secure code picking them up spread the taint further
  * fix: the Omnium Folio / expansion landing page button docks to the minimap corner again — each overlay refresh re-anchored it to Blizzard's default position, leaving it floating below the map
  * fix: **saved HuD positions stop disappearing** — the settings system deleted any saved position that happened to match its own default, silently, on reloads and spec swaps; this is very likely behind every "my layout reset itself" report of the beta cycle. Two accomplices went with it: linked changes never actually reached the other spec's settings, and a stale per-spec snapshot overwrote them again on every swap. Positions already lost to it cannot be restored, but they stay put now
  * fix: **linked action bars land in the same place in both specs** — the two layouts measure bar height from different baselines, so copying the number verbatim put the Healing bars about 46px lower, on top of the Infobar; linked position writes are now translated through each layout's own baseline
  * fix: **"Use Large HuD" could differ between your specs without you changing it**, which made identical position numbers render in visibly different places; linked layouts now link the HuD size as well, so they look the same rather than merely holding the same numbers
  * fix: **blocked-action errors on the action bars in combat**, most often in delves — `SetShown` blocked, cooldown spirals refusing to draw. RealUI parked Blizzard's own bars but never silenced them, so Blizzard's code kept running on the hidden frames in the background
  * fix: **the stance and pet bars were unskinned** with Bartender4 out of the picture — once its support was removed, nothing in the package was skinning the adopted Blizzard buttons at all
  * fix: gold "new spell" boxes no longer overhang their buttons onto their neighbours after a spec swap
  * fix: **a fresh install no longer breaks half-way through starting up** — a brand-new install hit an error during initialization and everything after that point silently never ran, including every slash command, so `/realui` and `/rl` simply did not exist. Existing installs were unaffected
  * fix: **the gap between aura icons is the gap you see** — the configured spacing was passed where the layout engine never read it, and each icon's border sits outside its own rect, so icons rendered flush with overlapping borders; they now sit 2px apart, matching the action bars
  * fix: the minimap info labels line up when the minimap is anchored to a right-hand corner
  * fix: world markers follow the minimap to whichever side faces the screen interior instead of running off the edge
  * fix: hovering points of interest while flying no longer errors from the tooltip skin
  * fix: **the install wizard and the "new defaults" window look like RealUI** — borders, buttons, checkboxes and the dropdown were all stock Blizzard widgets
  * fix: the wizard's action bar schematic draws two right-hand side bars stacked in one column, which is what the layout engine actually builds — it used to show them side by side
  * fix: **the install wizard leaves an upgrading character on current defaults** — four stacked faults, each masking the next: the chat placement step no-opped on a flag every upgrading character carries; the Edit Mode template held a stale exported chat position that put the frame back on every login; nothing in the install path applied the bag default at all; and the targeted fix for the template could not find its entry because saved layout data indexes systems differently than the template does. All four are fixed, and the new-defaults picker now stays silent after a wizard run unless something is genuinely left to offer
  * fix: **the optional GCD bar no longer errors on every global cooldown** — oUF 14 hands the callback a duration object rather than a number of seconds, and reading it as a number threw on every global once the bar was enabled; the window is now timed from the cooldown data itself
  * fix: leaving combat no longer prints a burst of `UnitIsPVP` errors — the PvP indicator override tolerates the unitless events oUF registers it for
  * fix: infobar odds and ends — hovering a block no longer errors before the skin database exists, the "all blocks" toggle in `/realadv` works through every state, and the SimulationCraft block no longer draws its own name twice ("Show label" now controls it)
  * fix: **Infobar font size 0 actually follows the chat font now** — the chat-size read truncated a multiple return, so it always came back empty and size 0 silently used the fixed fallback instead; close enough to the default chat size that it looked right



## Detailed Changes ##
[Unreleased]: https://github.com/RealUI/RealUI/compare/4.0.2...main
[4.0.2]: https://github.com/RealUI/RealUI/compare/4.0.1...4.0.2
[4.0.1]: https://github.com/RealUI/RealUI/compare/4.0.0...4.0.1
[4.0.0]: https://github.com/RealUI/RealUI/compare/3.4.0...4.0.0
