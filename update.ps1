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
    Write-Host "Using version $oldVersion"
    $newVersion = $oldVersion
} else {
    Write-Host "Updating to $newVersion"
    foreach ($path in $addons) {
        (Get-Content $path) |
        Foreach-Object {$_ -replace $oldVersion, $newVersion} |
        Set-Content $path
    }
}

$zipName = "RealUI " + $newVersion + ".zip"
Add-Type -Path "utils/Ionic.Zip.dll"
# Create the zip file
Write-Host "Creating zip file"
$zipFile = new-object Ionic.Zip.ZipFile
$interface = $zipFile.AddDirectory("./Interface", "Interface")

# Add the README as a txt file
$readme = $zipFile.AddFile("./README.md")
$readme.FileName = "README.txt"

# Add the LICENSE as a txt file
$readme = $zipFile.AddFile("./LICENSE.md")
$readme.FileName = "LICENSE.txt"

#Exclude files
$remove = @(
    ".git",
    "Interface/AddOns/nibRealUI_Dev"
)
# Collect entries to remove
$toRemove = {@()}.Invoke()
Write-Host "Remove excluded files"
foreach ($entry in $zipFile.Entries) {
    foreach ($file in $remove) {
        if ($entry.FileName.Contains($file)) {
            $toRemove.Add($entry)
        }
    }
}
# Remove entries
foreach ($entry in $toRemove) {
    Write-Host $entry.FileName
    $zipFile.RemoveEntry($entry)
}

$zipFile.Save($zipName)
$zipFile.Dispose()
