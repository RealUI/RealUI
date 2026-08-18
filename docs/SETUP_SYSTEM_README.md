# RealUI Setup System

## Overview

The Setup System detects previous RealUI installations and migrates settings automatically when upgrading. Setup completion is tracked per major version, so the wizard runs once per version and stays out of the way afterwards.

User-facing commands are documented in `SETUP_COMMANDS.md` (same folder).

## Architecture

1. **SetupSystem** (`RealUI/Core/SetupSystem.lua`) — orchestration: old-configuration detection, settings migration, setup state management
2. **InstallWizard** (`RealUI/Core/InstallWizard.lua`) — wizard flow control, stage management, upgrade detection support
3. **InstallUI** (`RealUI/Core/InstallUI.lua`) — wizard UI, upgrade-specific messaging, progress tracking
4. **CharacterInit** (`RealUI/Core/CharacterInit.lua`) — character-specific initialization, role-based defaults, chat positioning
5. **VersionManager** (`RealUI/Core/VersionManager.lua`) — version comparison utilities

## Key API

```lua
local state = RealUI.SetupSystem:Initialize()      -- detect; returns state table
RealUI.SetupSystem:NeedsSetup()                    -- setup needed for current version?
RealUI.SetupSystem:IsUpgrade()                     -- upgrade? returns isUpgrade, oldVersion
RealUI.SetupSystem:MigrateOldSettings()            -- returns success, errors
RealUI.SetupSystem:StartSetup()                    -- open the wizard
RealUI.SetupSystem:CompleteSetup()                 -- mark current version configured
```

`Core.lua`'s `OnEnable()` calls `CheckAndRun()` when `needsSetup` is true and shows the upgrade notification for upgrades.

## Migration behavior

**Migrated:** global settings (currency data, tags, tutorial state), profile settings (media, registered characters, settings for modules that still exist), character settings (layouts, spec layouts, previous-version tracking).

**Not migrated:** obsolete module settings, deprecated options, old tutorial progress (marked complete instead).

## Database keys

Global: `setupVersion` (last completed setup version), `verinfo`, `tutorial.stage` (−1 = complete).
Character: `init.initialized`, `init.installStage` (−1 = complete), `init.hadPreviousVersion`, `init.previousVersion`.

## Troubleshooting

- **Setup keeps appearing:** check `setupVersion` in the global DB and `init.initialized` on the character; look for migration errors via `/error`.
- **Settings not migrated:** verify old saved variables exist; check `/debug SetupSystem`; module must still exist in the current version.
- **Upgrade not detected:** verify old version info in saved variables; check `DetectOldConfiguration()` return values.
