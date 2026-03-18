<#
.SYNOPSIS
Adds a list of computer accounts to multiple Active Directory groups.

.DESCRIPTION
This script searches for computer objects within a specified Organizational Unit (OU)
and adds each computer to a defined set of AD security or application groups.

It is useful for bulk workstation provisioning, application access assignment,
and standardized endpoint setup in enterprise environments.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the groups to which the computers should be added
$groups = @(
    "APP-Standard-Printing",
    "APP-Secure-Print",
    "APP-Collaboration-Client",
    "APP-Call-Center-Shortcut",
    "APP-Office-Suite",
    "APP-Document-Management",
    "APP-Claims-Processing",
    "APP-Clinical-Application",
    "APP-Clinical-Application-Org",
    "APP-Content-Management",
    "APP-Preflight-Check",
    "APP-Primary-EMR",
    "APP-Virtual-Workspace"
)

# Define the search base for the Computers OU
$searchBase = "OU=Workstations,OU=Enterprise,DC=example,DC=local"

# Define the list of computer names to process
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

# Loop through each computer name
foreach ($computerName in $computerNames) {
    Write-Host "`n--- Processing Computer: $computerName ---"

    # Check if the computer exists in the specified OU
    $adComputer = Get-ADComputer -Filter "Name -eq '$computerName'" -SearchBase $searchBase -ErrorAction SilentlyContinue

    if (-not $adComputer) {
        Write-Host "Computer '$computerName' not found in the specified Active Directory location. Skipping." -ForegroundColor Yellow
        continue
    }

    # Add the computer to each group
    foreach ($group in $groups) {
        try {
            # Check if the group exists
            $adGroup = Get-ADGroup -Filter "Name -eq '$group'" -ErrorAction SilentlyContinue

            if (-not $adGroup) {
                Write-Host "Group '$group' not found in Active Directory. Skipping." -ForegroundColor Yellow
                continue
            }

            # Add the computer to the group
            Add-ADGroupMember -Identity $adGroup.DistinguishedName -Members $adComputer.DistinguishedName -ErrorAction Stop
            Write-Host "Computer '$computerName' successfully added to group '$group'." -ForegroundColor Green
        }
        catch {
            Write-Host "Error adding '$computerName' to '$group': $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
