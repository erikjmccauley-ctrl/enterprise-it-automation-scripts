<#
.SYNOPSIS
Looks up multiple Active Directory user accounts and returns selected user attributes.

.DESCRIPTION
This script queries Active Directory for a list of user account IDs and retrieves
basic identity information such as first name and last name. It is useful for
bulk account validation, reporting, and administrative review tasks.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the search base
$searchBase = "DC=example,DC=local"

# Define the user IDs to look up
$userIds = @(
    "user1001",
    "user1002",
    "user1003",
    "user1004",
    "user1005"
) | ForEach-Object { $_.Trim() } |
    Where-Object { $_ -ne "" } |
    Select-Object -Unique

# Collect results
$results = foreach ($id in $userIds) {
    try {
        $user = Get-ADUser `
            -LDAPFilter "(sAMAccountName=$id)" `
            -SearchBase $searchBase `
            -Properties GivenName, Surname `
            -ErrorAction Stop

        [pscustomobject]@{
            SamAccountName = $id
            FirstName      = $user.GivenName
            LastName       = $user.Surname
            Status         = "Found"
        }
    }
    catch {
        [pscustomobject]@{
            SamAccountName = $id
            FirstName      = $null
            LastName       = $null
            Status         = "Not Found"
        }
    }
}

# Display results in the console
$results | Sort-Object SamAccountName | Format-Table -AutoSize

# Optional: export results to CSV
# $csvPath = "C:\Reports\AD-User-Lookup.csv"
# $results | Sort-Object SamAccountName | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $csvPath
# Write-Host "Results exported to $csvPath"
