# RealUI 3.0.0 Setup System

## Overview

The new Setup System for RealUI 3.0.0 provides intelligent detection of previous RealUI installations and automatic migration of settings when upgrading from older versions.

## Features

### 1. Old Configuration Detection
- Automatically detects saved variables from previous RealUI versions
- Identifies version information from old installations
- Checks for legacy character data and incomplete setups

### 2. Version Upgrade Detection
- Compares old version with current version (3.0.0)
- Detects major version upgrades (e.g., 2.x → 3.0.0)
- Handles cases where version info is missing

### 3. Settings Migration
- Migrates global settings (currency data, tags, etc.)
- Migrates profile settings for RealUI and RealUI-Healing profiles
- Migrates character-specific settings (layouts, specializations)
- Selective migration - only migrates settings for modules that still exist

### 4. Setup Wizard Integration
- Integrates with existing InstallWizard and InstallUI
- Shows upgrade-specific messaging for users upgrading from previous versions
- Provides different welcome screens for new installs vs upgrades

### 5. Setup Completion Tracking
- Tracks setup completion per version using `setupVersion` key
- Ensures setup runs once per major version
- Prevents repeated setup prompts after completion

## Architecture

### Core Components

1. **SetupSystem** (`Core/SetupSystem.lua`)
   - Main setup orchestration
   - Old configuration detection
   - Settings migration
   - Setup state management

2. **InstallWizard** (`Core/InstallWizard.lua`)
   - Setup wizard flow control
   - Stage management
   - Upgrade detection support

3. **InstallUI** (`Core/InstallUI.lua`)
   - Visual interface for setup wizard
   - Upgrade-specific messaging
   - Progress tracking

4. **CharacterInit** (`Core/CharacterInit.lua`)
   - Character-specific initialization
   - Role-based defaults
   - Chat frame positioning

## Usage

### Automatic Setup Check

The setup system automatically checks if setup is needed when RealUI loads:

```lua
-- In Core.lua OnEnable()
if self.SetupSystem then
    local setupState = self.SetupSystem:GetState()
    if setupState.needsSetup then
        self.SetupSystem:CheckAndRun()

        if setupState.isUpgrade then
            self.SetupSystem:ShowUpgradeNotification()
        end
    end
end
```

### Manual Setup Commands

Users can manually trigger setup using chat commands:

- `/realuisetup` or `/realuisetup run` - Run the setup wizard
- `/realuisetup check` - Check setup status
- `/realuisetup migrate` - Manually run settings migration

### API Methods

#### SetupSystem:Initialize()
Initializes the setup system and detects old configurations.

```lua
local setupState = RealUI.SetupSystem:Initialize()
-- Returns: setupState table with needsSetup, isUpgrade, oldVersion, etc.
```

#### SetupSystem:DetectOldConfiguration()
Detects if old RealUI configuration exists.

```lua
local hasOldConfig, oldVersion = RealUI.SetupSystem:DetectOldConfiguration()
```

#### SetupSystem:NeedsSetup()
Checks if setup is needed for current version.

```lua
local needsSetup = RealUI.SetupSystem:NeedsSetup()
```

#### SetupSystem:IsUpgrade()
Determines if this is an upgrade from a previous version.

```lua
local isUpgrade, oldVersion = RealUI.SetupSystem:IsUpgrade()
```

#### SetupSystem:MigrateOldSettings()
Migrates settings from previous version.

```lua
local success, errors = RealUI.SetupSystem:MigrateOldSettings()
```

#### SetupSystem:StartSetup()
Starts the setup wizard.

```lua
local started = RealUI.SetupSystem:StartSetup()
```

#### SetupSystem:CompleteSetup()
Marks setup as complete for current version.

```lua
local success = RealUI.SetupSystem:CompleteSetup()
```

## Setup Flow

### New Installation Flow

1. User installs RealUI 3.0.0 for the first time
2. SetupSystem detects no previous configuration
3. Setup wizard shows standard welcome screen
4. User proceeds through setup stages
5. Setup completes and marks version 3.0.0 as configured

### Upgrade Flow

1. User upgrades from RealUI 2.x to 3.0.0
2. SetupSystem detects old configuration and version
3. SetupSystem migrates compatible settings
4. Setup wizard shows upgrade-specific welcome screen
5. User reviews and completes setup
6. Setup marks version 3.0.0 as configured

## Migration Details

### Global Settings Migration
- Currency tracking data
- User tags and preferences
- Tutorial completion status

### Profile Settings Migration
- Media settings (fonts, textures, colors)
- Registered characters list
- Module settings (only for modules that still exist)

### Character Settings Migration
- Layout preferences (DPS/Tank vs Healing)
- Specialization-specific layouts
- Previous version tracking

### What's NOT Migrated
- Obsolete module settings
- Deprecated configuration options
- Old tutorial progress (marked as complete instead)

## Database Keys

### Global Database
- `setupVersion` - Version string of last completed setup (e.g., "3.0.0")
- `verinfo` - Current version information
- `tutorial.stage` - Tutorial stage (-1 = complete)

### Character Database
- `init.initialized` - Whether character is initialized
- `init.installStage` - Installation stage (-1 = complete)
- `init.hadPreviousVersion` - Boolean indicating upgrade
- `init.previousVersion` - Version string of previous installation

## Testing

### Test New Installation
1. Delete or rename `WTF/Account/[Account]/SavedVariables/nibRealUI.lua`
2. Login to character
3. Verify setup wizard appears with standard welcome
4. Complete setup
5. Verify `setupVersion` is set to "3.0.0"

### Test Upgrade from 2.x
1. Create mock old configuration in saved variables
2. Set old version info to "2.5.0"
3. Login to character
4. Verify upgrade detection and migration
5. Verify setup wizard shows upgrade messaging
6. Complete setup
7. Verify settings were migrated

### Test Setup Completion
1. Complete setup
2. Reload UI
3. Verify setup wizard does not appear again
4. Check `setupVersion` in saved variables

## Future Enhancements

- Version-specific migration handlers
- Backup of old settings before migration
- Migration rollback capability
- Detailed migration report UI
- Support for minor version updates
- Automatic profile optimization based on detected hardware

## Troubleshooting

### Setup Keeps Appearing
- Check if `setupVersion` is set in global database
- Verify character `init.initialized` is true
- Check for errors in migration process

### Settings Not Migrated
- Verify old saved variables exist
- Check debug output for migration errors
- Ensure modules still exist in new version

### Upgrade Not Detected
- Verify old version info exists in saved variables
- Check `DetectOldConfiguration()` return values
- Review debug logs for detection process

## Debug Commands

Enable debug output:
```lua
/run RealUI:SetDebugLevel("SetupSystem", 1)
```

Check setup state:
```lua
/realuisetup check
```

Force migration:
```lua
/realuisetup migrate
```

## Related Files

- `Core/SetupSystem.lua` - Main setup system
- `Core/InstallWizard.lua` - Setup wizard logic
- `Core/InstallUI.lua` - Setup wizard UI
- `Core/CharacterInit.lua` - Character initialization
- `Core/VersionManager.lua` - Version comparison utilities
- `Core.lua` - Integration with core initialization

