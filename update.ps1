$version = Read-Host "What is the current version?"
$addons = @(
    "!Aurora_RealUI",
    "nibRealUI",
    "nibRealUI_Init"
)

# replace version strings
foreach ($addon in $addons) {
    $path = "./Interface/AddOns/" + $addon + "/" + $addon + ".toc"
    (Get-Content $path) |
    Foreach-Object {$_ -replace "@project-version@", $version} |
    Set-Content $path
}

# Package to zip, this requires .Net 4.5
$zipName = "RealUI " + $version + ".zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Create the zip file
[System.IO.Compression.ZipFile]::CreateFromDirectory("./Interface", $zipName)
$zipFile = [System.IO.Compression.ZipFile]::Open($zipName, "Update")
# Add the README as a txt file
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipFile, "README.md", "README.txt")
$zipFile.Dispose()

# return version strings
foreach ($addon in $addons) {
    $path = "./Interface/AddOns/" + $addon + "/" + $addon + ".toc"
    (Get-Content $path) |
    Foreach-Object {$_ -replace $version, "@project-version@"} |
    Set-Content $path
}
