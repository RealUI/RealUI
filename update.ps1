$oldVersion = Get-Content "./version.txt"
$newVersion = Read-Host "Enter new version, or leave blank to use current version."
$addons = @(
    "./version.txt",
    "./Interface/AddOns/!Aurora_RealUI/!Aurora_RealUI.toc",
    "./Interface/AddOns/nibRealUI/nibRealUI.toc",
    "./Interface/AddOns/nibRealUI_Config/nibRealUI_Config.toc",
    "./Interface/AddOns/nibRealUI_Init/nibRealUI_Init.toc"
)

# replace version strings
if ($newVersion -eq "") {
    $newVersion = $oldVersion
} else {
    foreach ($path in $addons) {
        (Get-Content $path) |
        Foreach-Object {$_ -replace $oldVersion, $newVersion} |
        Set-Content $path
    }
}

# Package to zip, this requires .Net 4.5
$zipName = "RealUI " + $newVersion + ".zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Create the zip file
[System.IO.Compression.ZipFile]::CreateFromDirectory("./Interface", $zipName)
$zipFile = [System.IO.Compression.ZipFile]::Open($zipName, "Update")
# Add the README as a txt file
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, "README.md", "README.txt")
$zipFile.Dispose()
