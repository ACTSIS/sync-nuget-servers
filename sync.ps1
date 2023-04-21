<#
    .SYNOPSIS
    Syncronize the nuget packages from one repository to another.

    .DESCRIPTION
    This script will download all the packages from a repository and then push them to another repository.

    .PARAMETER Task
    The task to be executed. It can be "firstSync", "continueSync" or "pushAll".

    .INPUTS
    Nope

    .OUTPUTS
    Nope

    .EXAMPLE
    PS> .\sync.ps1 firstSync

    .LINK
    https://github.com/ACTSIS/sync-nuget-servers.git

    .NOTES
    Autor   : Daniel Rondón 
    Fecha   : 2023-04-21
    Version : 1.0
#>

Param (
    [Parameter(Mandatory)]
    [ValidateSet("firstSync",
                "continueSync",
                "pushAll")]
    [string]$Task
)

# get configs of the .env file
$envPath = Join-Path $PSScriptRoot ".env"
$envLines = Get-Content $envPath

foreach ($line in $envLines) {
    # Split each line into variable name and value
    $varName, $varValue = $line -split '=', 2
    
    # Set the variable to the corresponding value
    Set-Variable -Name $varName -Value $varValue
}

New-Item -ItemType Directory -Force -Path $DOWNLOAD_PATH | Out-Null

function Get-All {
    # Get the list of packages available in the repository
    $PACKAGE_LIST = nuget list -Source $ORIGIN_NUGET_URL -Prerelease | ForEach-Object { $_ -replace '^([\w\.]+)\s*\d[\d\.\-]*\w*', '$1' }

    # Download and package each VERSION of each package
    foreach ($PACKAGE_NAME in $PACKAGE_LIST) {
        Write-Host "downloading package $PACKAGE_NAME"

        $PACKAGE_VERSIONS =  nuget list $PACKAGE_NAME -AllVersions -Prerelease -Source $ORIGIN_NUGET_URL | ForEach-Object { $_ -replace '^([\w\.]+)', '' }

        foreach ($VERSION in $PACKAGE_VERSIONS) {
            $DOWNLOAD_URL = "$ORIGIN_NUGET_URL/Packages(Id='$PACKAGE_NAME',Version='$VERSION')/Download"
            Write-Host $DOWNLOAD_URL

            # Download the package
            $FOLDER_PATH = "nuget-packages"
            if (-not (Test-Path $FOLDER_PATH)) {
                New-Item -ItemType Directory -Path $FOLDER_PATH
            }
            if (-not (Test-Path "$FOLDER_PATH/$PACKAGE_NAME.$VERSION.nupkg")) {
                Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "$FOLDER_PATH/$PACKAGE_NAME.$VERSION.nupkg"
                Write-Host $DOWNLOAD_URL
            }else {
                Write-Host "The package $PACKAGE_NAME version $VERSION already exists."
            }
        }

        $DOWNLOAD_URL = "$ORIGIN_NUGET_URL/Packages(Id='$PACKAGE_NAME',Version='$PACKAGE_VERSIONS')/Download"
        Write-Host $DOWNLOAD_URL
    }
}

function Push-Nugets {
    # Push each packed package to the destination repository
    $PACKAGE_FILES = Get-ChildItem -Path $DOWNLOAD_PATH -Filter "*.nupkg"
    Write-Host $PACKAGE_FILES

    foreach ($PACKAGE_FILE in $PACKAGE_FILES) {
        $PACKAGE_NAME = $PACKAGE_FILE.BaseName
        $VERSION = $PACKAGE_NAME.Split("-")[-1]

        Write-Host "Pushing the package $PACKAGE_NAME ($VERSION)"
        Write-Host "package path " $PACKAGE_FILE.FullName
        
        & nuget push $PACKAGE_FILE.FullName -Source $DESTINY_NUGET_URL_PUSH -ApiKey $API_KEY

        # Print the result of the operation
        if ($null -ne $response.errors -and $response.errors.Length -gt 0) {
            Write-Host "Error message: $($response.errors[0].message)"
        } else {
            Write-Host "No error information available."
        }
    }
}

function Resume-Sync {
    # Get the list of packages available in the repository
    Write-Host "getting list of " $ORIGIN_NUGET_URL
    $PACKAGE_LIST_SOURCES = nuget list -Source $ORIGIN_NUGET_URL -Prerelease -AllVersions
    Write-Host "getting list of " $DESTINY_NUGET_URL
    $PACKAGE_LISTS = nuget list -Source $DESTINY_NUGET_URL -Prerelease -AllVersions

    $DIFFS = Compare-Object $PACKAGE_LIST_SOURCES $PACKAGE_LISTS

    # Download and package each version of each selected package
    foreach ($DIFF in $DIFFS) {
        $PACKAGE_NAME = $($DIFF.InputObject -replace '^([\w\.]+)\s*\d[\d\.\-]*\w*', '$1' )
        $VERSION = $($DIFF.InputObject -replace '^[A-Za-z0-9.]+(?=[\s-][0-9\w.-]+$)\s', '' )

        $DOWNLOAD_URL = "$ORIGIN_NUGET_URL/Packages(Id='$PACKAGE_NAME',Version='$VERSION')/Download"
        # Download the package
        $FOLDER_PATH = "nuget-packages"
        if (-not (Test-Path $FOLDER_PATH)) {
            New-Item -ItemType Directory -Path $FOLDER_PATH
        }

        Write-Host "Downloading..." $DOWNLOAD_URL
        Invoke-WebRequest -Uri $DOWNLOAD_URL -OutFile "$FOLDER_PATH/$PACKAGE_NAME.$VERSION.nupkg"
        
        Write-Host "Pushing... $FOLDER_PATH/$PACKAGE_NAME.$VERSION.nupkg" 
        & nuget push "$FOLDER_PATH/$PACKAGE_NAME.$VERSION.nupkg" -Source $DESTINY_NUGET_URL_PUSH -ApiKey $API_KEY

        # Print the result of the operation
        if ($null -ne $response.errors -and $response.errors.Length -gt 0) {
            Write-Host "Error message: $($response.errors[0].message)"
        } else {
            Write-Host "Success."
        }
    }
}

switch ($Task) {
    'firstSync' { Get-All ; Push-Nugets ; Break }
    'continueSync' { Resume-Sync ;Break }
    'pushAll' { Push-Nugets ;Break }
}
