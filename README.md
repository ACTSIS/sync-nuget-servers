# Sync Nuget

## Description

This is a Docker image that contains a PowerShell script to sync a NuGet feed with another one. In this case, the script is used to sync a private feed with a another private but using Nuget Gallery.

## Installation

- Before run the following commands, you need to have Docker installed in your machine for windows containers.
- You need to edit the parameters in [.env](.env):

```ps1
# NuGet Feed Origin
ORIGIN_NUGET_URL=https://nuget.com/nuget
# NuGet Feed Destination
DESTINY_NUGET_URL=https://nugetgallery.com/api/v2
# NuGet Feed Destination to push packages, in this case, NuGet Gallery improve v2 API then the path is different "api/v2/package"
DESTINY_NUGET_URL_PUSH=https://nugetgallery.com/api/v2/package
# NuGet API Key
API_KEY=YOUR_API_KEY
# NuGet Packages Path
DOWNLOAD_PATH=nuget-packages

```

Clone this repository and build the image with the following command in the same folder where the Dockerfile is located:

```cli
git clone https://github.com/ACTSIS/sync-nuget-servers.git
```

Access to the folder where the Dockerfile is located and build the image with the following command:

```cli
cd sync-nuget-servers
```

Build the image with the following command in the same folder where the Dockerfile is located:

```cli
docker build -t sync-nuget-powershell .
```

Now, run the following command to create and run a container based on this image, mapping the c:\temp folder of the container to the current host folder:

```cli
docker run -it -v ${pwd}:C:\temp sync-nuget-powershell .\verify-sync.ps1
```

```cli
docker run -it -v ${pwd}:C:\temp sync-nuget-powershell .\sync.ps1 firstSync
```

Recuerda reemplazar "${PWD}" por la ruta absoluta de la carpeta que quieras usar para el volumen del host si no estás en la misma carpeta del Dockerfile y agregar tus propias credenciales para el API Key y URL de tu feed de NuGet.

## Sync script

The script sync.ps1 is used to sync a NuGet feed with another one, have 3 commands:

1. firstSync: This command is used to sync the first time, it will download all the packages from the origin feed and upload them to the destiny feed.

2. continueSync: This command is used to sync the packages that were not uploaded to the destiny feed, so it will just download the packages that are not in the destiny feed and upload them.

3. pushAll: This command is used to upload all the packages that are in the parameter DOWNLOAD_PATH to the destiny feed.

- Example of use:

```cli
sync.ps1 firstSync
```

## Verifying the sync

The script verify-sync.ps1 is used to verify if the sync was successful.

```cli
verify-sync.ps1
```
