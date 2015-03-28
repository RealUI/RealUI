$oldVersion = Get-Content "./version.txt"
$newVersion = Read-Host "What is the current version?"
$addons = @(
    "version",
    "!Aurora_RealUI",
    "nibRealUI",
    "nibRealUI_Config",
    "nibRealUI_Init"
)

# replace version strings
foreach ($addon in $addons) {
    $path
    if ($addon -eq "version") {
        $path = "./version.txt"
    } else {
        $path = "./Interface/AddOns/" + $addon + "/" + $addon + ".toc"
    }
    (Get-Content $path) |
    Foreach-Object {$_ -replace $oldVersion, $newVersion} |
    Set-Content $path
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
