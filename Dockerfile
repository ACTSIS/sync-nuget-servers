# Base image with PowerShell
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022

# Copy the sync script to the container and add it to the PATH
WORKDIR C:/sync
COPY sync.ps1 .
RUN setx /M PATH "%PATH%;C:\sync"

# Install nuget cli
WORKDIR C:/nuget
ADD https://dist.nuget.org/win-x86-commandline/latest/nuget.exe .
RUN setx /M PATH "%PATH%;C:\nuget"

# Set the default working directory
WORKDIR C:/temp

# run the script
CMD powershell -ExecutionPolicy Bypass -File C:\sync\sync.ps1
