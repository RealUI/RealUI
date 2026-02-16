# RealUI 3.0.0 Setup Commands

## Quick Setup Commands

### Run Setup Wizard

```
/realui setup
```
or
```
/realuisetup
```

Opens the RealUI 3.0.0 setup wizard. Use this to:
- Configure RealUI for the first time
- Re-run setup after upgrading from a previous version
- Reconfigure your installation

### Check Setup Status

```
/realuisetup check
```

Displays current setup status:
- Whether setup is needed
- If this is an upgrade from a previous version
- Old version detected (if any)
- Whether old configuration was found

### Migrate Settings Manually

```
/realuisetup migrate
```

Manually runs the settings migration from previous RealUI versions. This is normally done automatically during setup, but you can run it separately if needed.

## Other Useful Commands

### Open Configuration

```
/realui
```
or
```
/real
```

Opens the RealUI configuration interface (HuD settings).

### Advanced Configuration

```
/realadv
```

Opens the advanced RealUI configuration options.

### Reload UI

```
/rl
```

Quickly reloads the user interface.

### Installation Wizard

```
/installwizard start
```

Starts the installation wizard (alternative to `/realui setup`).

```
/installwizard skip
```

Skips the installation wizard.

```
/installwizard reset
```

Resets the installation wizard to start over.

### Character Initialization

```
/charinit setup
```

Runs character-specific setup (role detection, chat positioning, etc.).

```
/charinit reset
```

Resets character initialization.

```
/charinit info
```

Shows current character information (name, role, level).

## Troubleshooting Commands

### Check Module Status

```
/realui modules
```

Lists all RealUI modules and their enabled/disabled status.

### Diagnostic Information

```
/realui status
```

Shows detailed RealUI status including:
- Version information
- Initialization state
- Module framework status
- Performance metrics

### Layout Management

```
/layoutstatus
```

Shows current layout information.

```
/layoutswitch <1|2>
```

Switches to layout 1 (DPS/Tank) or layout 2 (Healing).

```
/layouttoggle
```

Toggles between layouts.

### Frame Movement

```
/framemover status
```

Shows frame mover status.

```
/framemover config
```

Toggles frame movement configuration mode.

```
/framemover reset
```

Resets all frame positions to defaults.

### Config Mode

```
/configmode
```

Toggles configuration mode for moving UI elements.

## Setup Workflow

### First-Time Installation

1. Install RealUI 3.0.0
2. Login to your character
3. Setup wizard should appear automatically
4. If not, type `/realui setup`
5. Follow the wizard steps
6. Click "Finish" when done

### Upgrading from Previous Version

1. Update to RealUI 3.0.0
2. Login to your character
3. Setup system detects old configuration automatically
4. Upgrade notification appears
5. Click "Run Setup" or type `/realui setup`
6. Your settings are migrated automatically
7. Review and complete the setup wizard

### Re-running Setup

If you want to re-run setup after it's been completed:

1. Type `/realui setup`
2. The wizard will open
3. You can reconfigure your settings
4. Your current settings will be preserved unless you change them

## Notes

- Setup can be run at any time, even after initial configuration
- Settings migration is safe and preserves your customizations
- You can skip setup and use default settings if preferred
- Setup wizard can be closed and resumed later
- All commands are case-insensitive

## Getting Help

If you encounter issues with setup:

1. Check setup status: `/realuisetup check`
2. View diagnostic info: `/realui status`
3. Try manual migration: `/realuisetup migrate`
4. Reset and try again: `/installwizard reset` then `/realui setup`
5. Check for errors: Enable Lua errors in Interface options

For more information, see the main RealUI documentation.
