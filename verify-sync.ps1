# set the variables
$nugetUrlSource = "https://server1.com/nuget"
$nugetUrl = "https://server2.com/api/v2"
# Get the list of packages available in the repository
Write-Host "getting list of " $nugetUrlSource
$packageListSources = nuget list -Source $nugetUrlSource -Prerelease -AllVersions

Write-Host "getting list of " $nugetUrl
$packageLists = nuget list -Source $nugetUrl -Prerelease -AllVersions

# Compare the 2 lists and show which packages and their version are needed for synchronization
Write-Host $nugetUrlSource "--" $nugetUrl
Compare-Object $packageListSources $packageLists

$diff = Compare-Object $packageListSources $packageLists

if ($diff -ne $null) {
    Write-Host "The lists are different"
} else {
    Write-Host "The lists are the same"
}
