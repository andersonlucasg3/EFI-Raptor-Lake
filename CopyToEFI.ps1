#!/usr/local/microsoft/powershell/7/pwsh

$MountPoint = "/Volumes/EFI"
$SystemEFIPath = "$MountPoint/EFI"
$SystemEFIBootPath = "$SystemEFIPath/BOOT"
$SystemEFIOCPath = "$SystemEFIPath/OC"

if (-not (Test-Path $SystemEFIPath))
{
    $AvailableDisks = $(diskutil list | grep EFI) | Out-String

    $DiskId = Read-Host -Prompt "Please provide an EFI disk to mount:`n$AvailableDisks"

    if ([string]::IsNullOrEmpty($DiskId))
    {
        Write-Error "EFI volume not mounted. Please mount the EFI volume and try again."

        return
    }

    if (-not (Test-Path $MountPoint))
    {
        sudo pwsh -c "New-Item -Path '$MountPoint' -ItemType Directory"
    }

    sudo diskutil mount -mountPoint $MountPoint $DiskId
    
    if (-not $? -or -not (Test-Path $SystemEFIPath))
    {
        Write-Error "EFI volume not mounted. Please mount the EFI volume and try again."

        return
    }
}

if (Test-Path $SystemEFIBootPath)
{
    Write-Host "Removing $SystemEFIBootPath"

    rm -rf "$SystemEFIBootPath"
}

if (Test-Path $SystemEFIOCPath)
{
    Write-Host "Removing $SystemEFIOCPath"
    
    rm -rf "$SystemEFIOCPath"
}

Write-Host "Copying EFI to $SystemEFIPath"
Copy-Item -Path "./EFI/BOOT" -Destination $SystemEFIPath -Recurse -Force -Exclude "**/.DS_Store"

Write-Host "Copying OC to $SystemEFIPath"
Copy-Item -Path "./EFI/OC" -Destination $SystemEFIPath -Recurse -Force -Exclude "**/.DS_Store"