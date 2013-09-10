@echo off
echo This script will now prepare the files for using SharedMedia_MyMedia

if exist ..\SharedMedia_MyMedia goto has_folder
echo Creating the folders...
mkdir ..\SharedMedia_MyMedia
mkdir ..\SharedMedia_MyMedia\background
mkdir ..\SharedMedia_MyMedia\border
mkdir ..\SharedMedia_MyMedia\font
mkdir ..\SharedMedia_MyMedia\sound
mkdir ..\SharedMedia_MyMedia\statusbar
echo You can now put your media files into the subfolders found at World of Warcraft\Interface\Addons\SharedMedia_MyMedia
goto end_of_file

:has_folder
echo Creating the file...
echo local LSM = LibStub("LibSharedMedia-3.0") > ..\SharedMedia_MyMedia\MyMedia.lua

echo    BACKGROUND
echo.>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----- >> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- BACKGROUND >> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----- >> ..\SharedMedia_MyMedia\MyMedia.lua
for %%F in (..\SharedMedia_MyMedia\background\*.*) do (
echo       %%~nF
echo LSM:Register("background", "%%~nF", [[Interface\Addons\SharedMedia_MyMedia\background\%%~nxF]]^) >> ..\SharedMedia_MyMedia\MyMedia.lua
)

echo    BORDER
echo.>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----- >> ..\SharedMedia_MyMedia\MyMedia.lua
echo --  BORDER >> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ---- >> ..\SharedMedia_MyMedia\MyMedia.lua
for %%F in (..\SharedMedia_MyMedia\border\*.*) do (
echo       %%~nF
echo LSM:Register("border", "%%~nF", [[Interface\Addons\SharedMedia_MyMedia\border\%%~nxF]]^) >> ..\SharedMedia_MyMedia\MyMedia.lua
)

echo    FONT
echo.>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
echo --   FONT>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
for %%F in (..\SharedMedia_MyMedia\font\*.ttf) do (
echo       %%~nF
echo LSM:Register("font", "%%~nF", [[Interface\Addons\SharedMedia_MyMedia\font\%%~nxF]]^) >> ..\SharedMedia_MyMedia\MyMedia.lua
)

echo    SOUND
echo.>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
echo --   SOUND>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
for %%F in (..\SharedMedia_MyMedia\sound\*.*) do (
echo       %%~nF
echo LSM:Register("sound", "%%~nF", [[Interface\Addons\SharedMedia_MyMedia\sound\%%~nxF]]^) >> ..\SharedMedia_MyMedia\MyMedia.lua
)

echo    STATUSBAR
echo.>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
echo --   STATUSBAR>> ..\SharedMedia_MyMedia\MyMedia.lua
echo -- ----->> ..\SharedMedia_MyMedia\MyMedia.lua
for %%F in (..\SharedMedia_MyMedia\statusbar\*.*) do (
echo       %%~nF
echo LSM:Register("statusbar", "%%~nF", [[Interface\Addons\SharedMedia_MyMedia\statusbar\%%~nxF]]^) >> ..\SharedMedia_MyMedia\MyMedia.lua
)

:end_of_file
pause