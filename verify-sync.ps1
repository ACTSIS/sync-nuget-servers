# set the variables
$envPath = Join-Path $PSScriptRoot ".env"
$envLines = Get-Content $envPath

foreach ($line in $envLines) {
    # Split each line into variable name and value
    $varName, $varValue = $line -split '=', 2
    
    # Set the variable to the corresponding value
    Set-Variable -Name $varName -Value $varValue
}

# Get the list of packages available in the repository
Write-Host "getting list of " $ORIGIN_NUGET_URL
$PACKAGE_LIST_SOURCES = nuget list -Source $ORIGIN_NUGET_URL -Prerelease -AllVersions

Write-Host "getting list of " $DESTINY_NUGET_URL
$PACKAGE_LISTS = nuget list -Source $DESTINY_NUGET_URL -Prerelease -AllVersions

# Compare the 2 lists and show which packages and their version are needed for synchronization
Write-Host ""
Compare-Object $PACKAGE_LIST_SOURCES $PACKAGE_LISTS
Write-Host ""
$DIFF = Compare-Object $PACKAGE_LIST_SOURCES $PACKAGE_LISTS
Write-Host ""
if ($null -ne $DIFF) {
    Write-Host "The lists are different"
} else {
    Write-Host "The lists are the same"
}

Write-Host ""
foreach ($DIF in $DIFF) {
    Write-Host "--------------Package--------------"
    Write-Host ($DIF.InputObject -replace '^([\w\.]+)\s*\d[\d\.\-]*\w*', '$1' )
    Write-Host "Version" ($DIF.InputObject -replace '^[A-Za-z0-9.]+(?=[\s-][0-9\w.-]+$)\s', '' )
    Write-Host ""
}