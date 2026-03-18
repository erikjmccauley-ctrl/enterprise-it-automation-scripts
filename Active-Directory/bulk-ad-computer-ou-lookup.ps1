<#
.SYNOPSIS
Retrieves the Organizational Unit (OU) location for multiple computer accounts in Active Directory.

.DESCRIPTION
This script looks up a list of computer objects in Active Directory, reads each
computer's Distinguished Name, and extracts the OU path for reporting or validation.
It is useful for endpoint audits, OU placement verification, and administrative cleanup tasks.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the list of computer names to look up
$computerNames = @(
    "SITEPC001",
    "SITEPC002",
    "SITEPC003",
    "SITEPC004",
    "SITEPC005",
    "SITEPC006",
    "SITEPC007",
    "SITEPC008",
    "SITEPC009",
    "SITEPC010"
)

# Loop through each computer and display its OU
foreach ($computerName in $computerNames) {
    try {
        $computer = Get-ADComputer -Identity $computerName -Properties DistinguishedName -ErrorAction Stop

        if ($computer) {
            $distinguishedName = $computer.DistinguishedName
            $organizationalUnit = ($distinguishedName -replace '^CN=.*?,(.*)$', '$1')

            Write-Host "$computerName is located in OU: $organizationalUnit" -ForegroundColor Green
        }
        else {
            Write-Host "$computerName not found in Active Directory." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error retrieving $computerName : $($_.Exception.Message)" -ForegroundColor Red
    }
}
