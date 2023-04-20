# set the variables
$nugetUrl = "https://first.nuget.com/nuget"
$packagePushUrl = "https://second.nuget.com/api/v2/package/"
$apiKey = "YOUR-KEY-HERE"
$downloadPath = "$PSScriptRoot\nuget-packages"

New-Item -ItemType Directory -Force -Path $downloadPath | Out-Null

# Get the list of packages available in the repository
$packageList = nuget list -Source $nugetUrl -Prerelease | foreach { $_ -replace '^([\w\.]+)\s*\d[\d\.\-]*\w*', '$1' }

# Download and package each version of each package
foreach ($packageName in $packageList) {
    Write-Host "downloading package $packageName"

    $packageVersions =  nuget list $packageName -AllVersions -Prerelease -Source $nugetUrl | foreach { $_ -replace '^([\w\.]+)', '' }

    foreach ($version in $packageVersions) {
        $downloadUrl = "$nugetUrl/Packages(Id='$packageName',Version='$version')/Download"
        Write-Host $downloadUrl

        # Download the package
        $folderPath = "nuget-packages"
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath
        }
        if (-not (Test-Path "$folderPath/$packageName.$version.nupkg")) {
            Invoke-WebRequest -Uri $downloadUrl -OutFile "$folderPath/$packageName.$version.nupkg"
            Write-Host $downloadUrl
        }else {
            Write-Host "The package $packageName version $version already exists."
        }
    }

    $downloadUrl = "$nugetUrl/Packages(Id='$packageName',Version='$packageVersions')/Download"
    Write-Host $downloadUrl
}

# Push each packed package to the destination repository
$packageFiles = Get-ChildItem -Path $downloadPath -Filter "*.nupkg"
Write-Host $packageFiles

foreach ($packageFile in $packageFiles) {
    $packageName = $packageFile.BaseName
    $version = $packageName.Split("-")[-1]

    Write-Host "Pushing the package $packageName ($version)"
    Write-Host "packet path " $packageFile.FullName
	
	& nuget push $packageFile.FullName -Source $packagePushUrl -ApiKey $apiKey

    # Print the result of the operation
    if ($response.errors -ne $null -and $response.errors.Length -gt 0) {
        Write-Host "Error message: $($response.errors[0].message)"
    } else {
        Write-Host "No error information available."
    }
}
