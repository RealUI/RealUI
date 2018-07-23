$oldVersion = Get-Content "./utils/version.txt"
Write-Host "Current version: $oldVersion"

$newVersion = Read-Host "Enter a new version, or press enter to skip"
$addons = @(
    "./utils/version.txt",
    "./cargBags_Nivaya/cargBags_Nivaya.toc",
    "./nibRealUI/nibRealUI.toc",
    "./nibRealUI_Config/nibRealUI_Config.toc",
    "./RealUI_Bugs/RealUI_Bugs.toc"
    "./RealUI_Skins/RealUI_Skins.toc"
)

# replace version strings
if ($newVersion -eq "") {
    Write-Host "Skipping version update"
} else {
    Write-Host "Updating to $newVersion"
    foreach ($path in $addons) {
        (Get-Content $path) |
        Foreach-Object {$_ -replace $oldVersion, $newVersion} |
        Set-Content $path
    }

    $newHeader = "## [$newVersion] - $(Get-Date -UFormat "%Y-%m-%d") ##"
    $newLink = "`n[$newVersion]: https://github.com/RealUI/RealUI/compare/$($oldVersion.Replace(" ", "_"))...$($newVersion.Replace(" ", "_"))"

    $changelog = "./CHANGELOG.md"
    (Get-Content $changelog) | Foreach {
        if ($_ -match "Unreleased") {
            if ($_ -match "##") {
                $newHeader
            } else {
                $_ + $newLink
            }
        } else {
            $_
        }
    } | Out-File -encoding utf8 $changelog
}
