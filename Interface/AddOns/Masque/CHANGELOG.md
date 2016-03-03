### 6.2.1 ###

**General**

  - SVN to Git conversion.
  - Updated Changelog, License and ReadMe.
  - Updated .pkgmeta.
 
**API**

  - API version 60201.
  - Renamed the "AutoCast" layer to the native name, "Shine".
      - Backwards compatibility available until game version 7.0.
  - Added support for ChargeCooldowns (tentative).
	  - A new API method, :UpdateCharge(Button) is available for add-ons that implement their own API for charges.

### 6.2.0 ###

**General**

  - ToC to 60200.
  - Updated version.

**API**

  - API version 60200.

### 6.1.0 ###

**General**

  - ToC to 60100.
  - Updated version.
  - Updated locales.

**API**

  - API version 60100.

**Bug Fixes**

  - Fixed hiding of options frame on `Group:Delete()`. [A147]
  - Fixed inheritence for disabled groups. [A153]
  - Fixed "General" options group.
  - Fixed minimap option not appearing. [A154]

### 6.0.0 ###

**General**

  - ToC to 60000.
  - Updated version.
  - Removed legacy ButtonFacade support.
  - Options panel is always load-on-demand.

**API**

  - New API method `:UpdateSpellAlert()` to allow add-ons that handle their own spell alerts to have them updated by Masque.
  - The callback for an add-on registered with Masque will return a sixth parameter, set to true, if the group is disabled.
  - Removed the Static parameter for groups.
  - Removed the following legacy group methods:
      - `GetLayerColor`
	  - `AddSubGroup`
	  - `RemoveSubGroup`
	  - `SetLayerColor`
	  - `Skin`
	  - `ResetColors`

**Bug Fixes**

  - Fixed groups not being removed from the options panel. [A144]
  - Fixed options window not opening to the correct panel.

### 5.4.396 ###

**General**

  - ToC to 50400.
  - Updated version.

### 5.3.394 ###

**General**

  - ToC to 50300.
  - Updated version.

### 5.2.391 ###

**General**

  - ToC to 50200.
  - Updated version.

### 5.1.389 ###

**General**

  - ToC to 50100.
  - Updated version.

### 5.0.387 ###

**General**

  - ToC to 50001.
  - Updated version.
  - Allow no-lib packages.

### 4.3.382 ###

**General**

  - ToC to 40300.
  - Updated version.
  - Updated locales.

**API**

  - New API method `:GetSpellAlert() to return the texture paths for the passed shape string.
  - Removed the Fonts feature.

**Bug Fixes**

  - Fixed the Background on Multibar buttons.
  - Fixed the Gloss showing on empty buttons.
  - Fixed 'Hotkey.SetPoint()'

### 4.2.375 ###

**General**

  - ToC to 40200.
  - Updated version.
  - Renamed ButtonFacade to Masque.
  - Added LibDualSpec support.
  - Added an option to disable groups.

**API**

  - Masque's API is accessed through `LibStub("Masque")`.
  - Added a debug mode.
  - Add-ons no longer need to save skin settings.
  - Renamed `:GetlayerColor()` to `GetColor()`.
  - Only hook check buttons for spell alert updates.

**Skins**

  - Cleaned up the default skin.
  - Skins can now use a random texture for the Normal layer.
  - Added a Duration layer.
  - Added Shape, Author, Version and Masque_Version attributes.

### 4.0.340 ###

**General**

  - ToC to 40000.
  - Updated version.

### 3.3.330 ###

**General**

  - Removed Border color support.
  - Miscellaneous fixes.

### 3.3.301 ###

**General**

  - ToC to 30300.
  - Updated version.
  - Updated locales.

### 3.2.285 ###

**General**

  - Updated ChangeLog.
  - Updated locales.

### 3.2.275 ###

**General**

  - ToC to 30200.
  - Updated version.
  - Updated locales.

### 3.1.270 ###

**General**

  - Removed the About panel.
  - Updated locales.

### 3.1.260 ###

**API**

  - Removed module support.

### 3.1.255 ###

**General**

  - Add X-WoWI-ID.
  - More GUI fixes.
  - Updated locales.

### 3.1.240 ###

**General**

  - GUI fixes.
  - Updated locales.

### 3.1.235 ###

**General**

  - ToC to 30100.
  - Updated GUI.
  - Updated locales.

### 3.1.225 ###

**General**

  - Added a new icon.
  - Updated locales.

### 3.0.211 ###

**General**

  - Updated locales.
  - Tag clean-up.

### 3.0.208 ###

**General**

  - Updated locales.

### 3.0.205 ###

**General**

  - Updated locales.

### 3.0.202 ###

**General**

  - Apply a fix for Border-less skins.

### 3.0.200 ###

**General**

  - Removed FuBar/Harbor support.
  - Rebuilt the options window.
  - The /bf and /buttonfacade chat commands now open the options window.
  - Updated locales.
  - Code clean-up.
