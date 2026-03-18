<#
.SYNOPSIS
Remotely clears temporary and cache folders on a target endpoint and restarts the system.

.DESCRIPTION
This script prompts for a computer name, verifies connectivity, and performs cleanup
of common system directories including Temp, SCCM cache, and Group Policy folders.
It is useful for troubleshooting, system remediation, and endpoint maintenance tasks.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Function to clear the contents of a folder
function Clear-Folder {
    param (
        [string]$FolderPath
    )

    if (Test-Path $FolderPath) {
        Get-ChildItem -Path $FolderPath -Recurse -Force -ErrorAction SilentlyContinue |
            Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

        Write-Host "Cleared contents of $FolderPath" -ForegroundColor Green
    }
    else {
        Write-Host "$FolderPath does not exist." -ForegroundColor Yellow
    }
}

# Prompt for computer name
$computerName = Read-Host -Prompt "Enter target computer name"

if ($computerName) {

    # Check connectivity
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        Write-Host "Processing $computerName..." -ForegroundColor Cyan

        # Define remote paths
        $tempFolder        = "\\$computerName\C$\Windows\Temp"
        $ccmcacheFolder    = "\\$computerName\C$\Windows\ccmcache"
        $groupPolicyFolder = "\\$computerName\C$\Windows\System32\GroupPolicy"

        # Perform cleanup
        Clear-Folder -FolderPath $tempFolder
        Clear-Folder -FolderPath $ccmcacheFolder
        Clear-Folder -FolderPath $groupPolicyFolder

        # Restart computer
        Write-Host "Restarting $computerName..." -ForegroundColor Cyan
        Restart-Computer -ComputerName $computerName -Force -ErrorAction SilentlyContinue

        Write-Host "$computerName has been restarted." -ForegroundColor Green
    }
    else {
        Write-Host "$computerName is offline or unreachable." -ForegroundColor Red
    }
}
else {
    Write-Host "No computer name provided. Exiting script." -ForegroundColor Yellow
}

Write-Host "Cleanup process completed." -ForegroundColor Cyan
