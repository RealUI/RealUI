:: Run luacheck and increment version
powershell ".\utils\update.ps1"

:: Run packager
:: Usage: release.sh [-acdelosuz] [-t topdir] [-r releasedir] [-g version] [-p slug] [-w wowi-id]
::   -a               Skip third party addons.
::   -c               Skip copying files into the package directory.
::   -d               Skip uploading.
::   -e               Skip checkout of external repositories.
::   -l               Skip @localization@ keyword replacement.
::   -o               Keep existing package directory, overwriting its contents.
::   -s               Create a stripped-down "nolib" package.
::   -u               Use Unix line-endings.
::   -z               Skip zipfile creation.
::   -t topdir        Set top-level directory of checkout.
::   -r releasedir    Set directory containing the package directory. Defaults to $topdir/.release.
::   -p curse-id      Set the project id used on CurseForge for localization and uploading.
::   -w wowi-id       Set the addon id used on WoWInterface for uploading.
bash -c "./utils/release.sh -clo -w 16068"
