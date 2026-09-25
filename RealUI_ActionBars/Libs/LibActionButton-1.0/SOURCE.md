# LibActionButton-1.0 — source

Embedded copy, not a packager external.

- **Upstream:** https://github.com/Nevcairiel/LibActionButton-1.0
- **Snapshot:** `a87f39c` (2026-08-12, tag `0.62`, `MINOR_VERSION` 155)
- **Fork for upstream PRs:** https://github.com/arnvid/LibActionButton-1.0

## RealUI patches on top of the snapshot

Search the file for `RealUI patch`. When refreshing the copy, re-apply any patch upstream
has not taken yet.

| Patch | Why | Upstream |
| --- | --- | --- |
| Flyout nil guard: `if success and numSlots then` in `DiscoverFlyoutSpells` and `UpdateFlyoutSpells` | WoW Forever 1.60.1.70009 returns nothing from `GetFlyoutInfo` for an unused flyoutID instead of erroring, so the `pcall` succeeds with a nil `numSlots` | Branch `fix/flyout-nil-numslots` on the fork, PR not yet opened |
