# LibActionButton-1.0 — source

Embedded copy, not a packager external.

- **Upstream:** https://github.com/Nevcairiel/LibActionButton-1.0
- **Snapshot:** `bc1da7a` (2026-10-02, `0.62-17`, `MINOR_VERSION` 168), copied unmodified
  from `libraries/LibActionButton-1.0`
- **Fork for upstream PRs:** https://github.com/arnvid/LibActionButton-1.0

## RealUI patches on top of the snapshot

None. Search the file for `RealUI patch` to confirm. When refreshing the copy, re-apply any
patch listed here that upstream has not taken yet.

## Retired patches

Both patches carried on the `0.62` snapshot were taken upstream, so the `bc1da7a` refresh
dropped them:

| Patch | Why | Upstream |
| --- | --- | --- |
| Flyout nil guard: `if success and numSlots then` in `DiscoverFlyoutSpells` and `UpdateFlyoutSpells` | WoW Forever 1.60.1.70009 returns nothing from `GetFlyoutInfo` for an unused flyoutID instead of erroring, so the `pcall` succeeds with a nil `numSlots` | Identical fix in `ae12419` (MINOR 156) |
| Forever counts as retail: `WoWRetail` also matched `WOW_PROJECT_CAMELOT` | WoW Forever 1.60.1.70170 changed `WOW_PROJECT_ID` from `WOW_PROJECT_MAINLINE` (1) to `WOW_PROJECT_CAMELOT` (18), and `WoWRetail` was a project-ID test | Superseded by `6243a29` (MINOR 157): `WoWForever` is detected by interface number (16001–19999) and folded into `WoWMainline`, so the project-ID change cannot reach it |

## Upstream behaviour worth knowing (0.62 → bc1da7a)

- **Loss-of-control cooldowns are off on Forever.** Upstream gates them on
  `WoWMainlineStandard` (retail only), not `WoWMainline`. Cooldown duration objects, secret-safe
  action counts, button cast bars and pingable buttons all follow `WoWMainline`, so they include
  Forever.
- **Range and usable state are event-driven.** Action buttons register with
  `C_ActionBar.RegisterActionUIButton` and `EnableActionRangeCheck`, and update from
  `ACTION_RANGE_CHECK_UPDATE` and `ACTION_USABLE_CHANGED` (a per-slot lookup through
  `lib.buttonsByAction`). Only non-action buttons are still polled in `OnUpdate`.
- **LAB now owns the buttons' `OnShow`/`OnHide` scripts** (the opt-in flash/state tracker). Do
  not `SetScript` either on a LAB button; use `HookScript`.
- **Pingable buttons:** a `ping-receiver` attribute and `GetIsPingable`/`GetTargetInfo` on
  Mainline and Forever.
- **The legacy flyout handler is gone**, and every client uses LAB's custom flyout.
