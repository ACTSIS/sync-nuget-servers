# Imagen base con PowerShell
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

# Copiar el script sync al contenedor y agregarlo al PATH
WORKDIR C:/sync
COPY sync.ps1 .
RUN setx /M PATH "%PATH%;C:\sync"

# Instala nuget cli
WORKDIR C:/nuget
ADD https://dist.nuget.org/win-x86-commandline/latest/nuget.exe .
RUN setx /M PATH "%PATH%;C:\nuget"

# Establecer el directorio de trabajo por defecto
WORKDIR C:/temp

# Ejecutar el script
CMD powershell -ExecutionPolicy Bypass -File C:\sync\sync.ps1
