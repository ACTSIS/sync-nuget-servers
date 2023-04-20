# Sync Nuget

## Description

This is a Docker image that contains a PowerShell script to sync a NuGet feed with another one. In this case, the script is used to sync a private feed with a another private but using Nuget Gallery.

## Installation

- Before run the following commands, you need to have Docker installed in your machine for windows containers.
- You need to edit the parameters in [sync.ps1](sync.ps1):

```ps1
# NuGet Feed Origin
$nugetUrl = "https://nuget.actsis.com/nuget"

# NuGet Feed Destination
$packagePushUrl = "https://nugetgallery.actsis.com/api/v2/package/"

# NuGet API Key
$apiKey = "YOUR-KEY-HERE"
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
docker run -it -v ${pwd}:C:\temp sync-nuget-powershell
```

Recuerda reemplazar "${PWD}" por la ruta absoluta de la carpeta que quieras usar para el volumen del host si no estás en la misma carpeta del Dockerfile y agregar tus propias credenciales para el API Key y URL de tu feed de NuGet.

## Verifying the sync

The script verify-sync.ps1 is used to verify if the sync was successful.

- Before run the following commands, you need to have Docker installed in your machine for windows containers.
- You need to edit the parameters in [verify-sync.ps1](verify-sync.ps1):

```ps1
# NuGet Feed Origin
$nugetUrlSource = "https://first.nuget.com/nuget"

# NuGet Feed Destination
$nugetUrl = "https://second.nuget.com/api/v2/package/"
```

Now you can run the script:

```cli
verify-sync.ps1
```
