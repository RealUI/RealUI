:: Run luacheck
call luacheck . -q || pause && EXIT

:: Increment version
powershell .\utils\update.ps1

:: Run packager
:: Usage: release.sh [-cdelLosuz] [-t topdir] [-r releasedir] [-p curse-id] [-w wowi-id] [-g game-version]
::   -c               Skip copying files into the package directory.
::   -d               Skip uploading.
::   -e               Skip checkout of external repositories.
::   -l               Skip @localization@ keyword replacement.
::   -L               Only do @localization@ keyword replacement (skip upload to CurseForge).
::   -o               Keep existing package directory, overwriting its contents.
::   -s               Create a stripped-down "nolib" package.
::   -u               Use Unix line-endings.
::   -z               Skip zip file creation.
::   -t topdir        Set top-level directory of checkout.
::   -r releasedir    Set directory containing the package directory. Defaults to "$topdir/.release".
::   -p curse-id      Set the project id used on CurseForge for localization and uploading.
::   -w wowi-id       Set the addon id used on WoWInterface for uploading.
::   -g game-version  Set the game version to use for CurseForge uploading.
bash -c "../../packager/release.sh -do -p 88269 -w 16068"

pause
