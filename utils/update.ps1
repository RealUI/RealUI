$oldVersion = Get-Content "./utils/version.txt"
Write-Host "Current version: $oldVersion"

$addons = {@()}.Invoke()
Get-ChildItem -Path "." -Filter "*RealUI_*" | % {
    $addons.Add("./$_/$_.toc")
}

$addons.Add("./utils/version.txt")
$addons.Add("./cargBags_Nivaya/cargBags_Nivaya.toc")
$addons.Add("./nibRealUI/nibRealUI.toc")

$newVersion = Read-Host "Enter a new version, or press enter to skip"
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
