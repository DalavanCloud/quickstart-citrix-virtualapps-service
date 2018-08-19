<#
.SYNOPSIS
    Prepares XD VDA for installation using CWC library

    Copyright (c) Citrix Systems, Inc. All Rights Reserved.
.DESCRIPTION
    
#>
[CmdletBinding()]
param(
    # [Parameter(Mandatory=$true)][string] $VDA_MediaName,
    # [Parameter(Mandatory=$true)][string] $VDA_MediaLocation,
    # [Parameter(Mandatory=$false)][string] $VDA_LocalMediaLocation = (Join-Path -Path $ENV:Temp -ChildPath "Citrix")
)

try {
    # Copy XD media locally
    # Write-Host "Copying XD Media locally"
    # cwcOS-Tools\Download-File -FileName $VDA_MediaName -Path $VDA_MediaLocation -ToFolder $VDA_LocalMediaLocation -verbose
	Start-Transcript -Path C:\cfn\log\Prep-VDA.ps1.txt -Append    
	
    Import-Module ServerManager
	Write-Host "Enabling RDS Server Role"
	Add-WindowsFeature RDS-RD-Server

	# Write-Host "Enabling Desktop Experience"
	# Install-WindowsFeature -Name Desktop-Experience

	Write-Host "Enabling Remote Assistance"
	Install-WindowsFeature -Name Remote-Assistance 

	### Install C++ libararies
	Write-Host "Installing Nuget"
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
	Write-Host "Installing VcRedist"
	Install-Module -Name VcRedist -Force # Reference: https://github.com/aaronparker/Install-VisualCRedistributables
	New-Item C:\Temp\VcRedist -ItemType Directory
	Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist
	Get-VcList | Install-VcRedist -Path C:\Temp\VcRedist

	# Install Pre-req for v7.18 https://docs.citrix.com/en-us/session-recording/current-release/system-requirements.html
	Write-Host "Downloading Microsoft .NET Framework 4.7.1"
	cwcOS-Tools\Download-File -FileName "NDP471-KB4033342-x86-x64-AllOS-ENU.exe" -Path "https://download.microsoft.com/download/9/E/6/9E63300C-0941-4B45-A0EC-0008F96DD480" -ToFolder "C:\cfn\scripts\" -verbose
	Write-Host "Installing Microsoft .NET Framework 4.7.1"
	#Install-MSIOrEXE -installerPath c:\cfn\scripts\NDP471-KB4033342-x86-x64-AllOS-ENU.exe -installerArgs @("/Q", "/norestart")
    Start-Process -FilePath "c:\cfn\scripts\NDP471-KB4033342-x86-x64-AllOS-ENU.exe" -ArgumentList "/q /norestart" -Wait


}
catch {
	$_ | Write-AWSQuickStartException
}