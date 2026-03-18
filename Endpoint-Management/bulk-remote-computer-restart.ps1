<#
.SYNOPSIS
Restarts multiple remote computers.

.DESCRIPTION
This script allows administrators to restart one or more remote endpoints by specifying
a list of computer names. It is useful for patching, system updates, and remediation workflows.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Define list of target computers
$computerList = @(
    "PC001",
    "PC002"
)

foreach ($computer in $computerList) {
    try {
        Write-Host "Restarting $computer..." -ForegroundColor Cyan

        Restart-Computer -ComputerName $computer -Force -ErrorAction Stop

        Write-Host "$computer restarted successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to restart $computer : $($_.Exception.Message)" -ForegroundColor Red
    }
}
