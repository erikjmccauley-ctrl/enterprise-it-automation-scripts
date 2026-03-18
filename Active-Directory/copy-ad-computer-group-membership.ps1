<#
.SYNOPSIS
Copies Active Directory group memberships from one computer account to another.

.DESCRIPTION
This script prompts for a source and target computer name, retrieves the group memberships
assigned to the source computer account, and adds the target computer account to the same groups.
It is useful for workstation replacement, rebuilds, and standardized endpoint provisioning workflows.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Start loop for repeated use
while ($true) {
    Write-Host "`n--- Copy Groups from Source Computer to Target Computer ---" -ForegroundColor Cyan

    # Prompt for source computer
    $sourceComputerName = Read-Host "Enter the source computer name (or type 'exit' to quit)"
    if ($sourceComputerName -eq "exit") {
        Write-Host "Exiting script." -ForegroundColor Yellow
        break
    }

    # Prompt for target computer
    $targetComputerName = Read-Host "Enter the target computer name (or type 'exit' to quit)"
    if ($targetComputerName -eq "exit") {
        Write-Host "Exiting script." -ForegroundColor Yellow
        break
    }

    # Get source computer object
    $sourceComputer = Get-ADComputer -Filter "Name -eq '$sourceComputerName'" -Properties MemberOf -ErrorAction SilentlyContinue
    if (-not $sourceComputer) {
        Write-Host "Source computer '$sourceComputerName' not found in Active Directory." -ForegroundColor Red
        continue
    }

    # Get target computer object
    $targetComputer = Get-ADComputer -Filter "Name -eq '$targetComputerName'" -ErrorAction SilentlyContinue
    if (-not $targetComputer) {
        Write-Host "Target computer '$targetComputerName' not found in Active Directory." -ForegroundColor Red
        continue
    }

    # Retrieve source group memberships
    $groups = $sourceComputer.MemberOf
    if (-not $groups) {
        Write-Host "Source computer '$sourceComputerName' is not a member of any groups." -ForegroundColor Yellow
        continue
    }

    Write-Host "Source computer '$sourceComputerName' is a member of the following groups:" -ForegroundColor Cyan
    $groups | ForEach-Object { Write-Host $_ }

    # Add target computer to same groups
    foreach ($groupDN in $groups) {
        try {
            Add-ADGroupMember -Identity $groupDN -Members $targetComputer.DistinguishedName -ErrorAction Stop
            Write-Host "Target computer '$targetComputerName' added to group '$groupDN'." -ForegroundColor Green
        }
        catch {
            Write-Host "Error adding '$targetComputerName' to '$groupDN': $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`nGroup copy operation completed for '$sourceComputerName' -> '$targetComputerName'." -ForegroundColor Cyan
}
