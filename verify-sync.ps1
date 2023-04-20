# set the variables
$nugetUrlSource = "https://first.nuget.com/nuget"
$nugetUrl = "https://second.nuget.com/api/v2/package/"
# Get the list of packages available in the repository
Write-Host "getting list of " $nugetUrlSource
$packageListSources = nuget.exe list -Source $nugetUrlSource -Prerelease -AllVersions
Write-Host "getting list of " $nugetUrl
$packageLists = nuget.exe list -Source $nugetUrl -Prerelease -AllVersions

# Compare the 2 lists and show which packages and their version are needed for synchronization
Write-Host $nugetUrlSource "--" $nugetUrl
Compare-Object $packageListSources $packageLists
