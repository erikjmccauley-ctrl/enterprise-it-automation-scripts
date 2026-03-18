<#
.SYNOPSIS
Creates standardized Active Directory user accounts based on workstation IDs, assigns group membership, and places accounts in the proper OU.

.DESCRIPTION
This script processes a defined list of workstation IDs, generates user account names from each device identifier,
creates corresponding Active Directory users with a standard description, assigns required application groups,
and places the accounts in the designated Organizational Unit for authentication platform use.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the Active Directory module
Import-Module ActiveDirectory

# Define a placeholder password
$password = "ReplaceWithSecurePassword"
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Define the Organizational Unit path
$ouPath = "OU=Authentication-Users,OU=Users,DC=example,DC=local"

# Define the group(s) to which the user should be added
$groups = @(
    "APP-Primary-EMR"
)

# List of workstation IDs to process
$pcList = @(
    "SITEPC217726",
    "SITEPC217865",
    "SITEPC221863",
    "SITEPC217756",
    "SITEPC217575"
)

# Loop through each workstation ID
foreach ($pc in $pcList) {
    # Extract the last six characters and create the username by prefixing a site code
    $username = "FL" + $pc.Substring($pc.Length - 6)

    # Set the standardized description
    $description = "Cardiovascular Surgery Desktop"

    # Define the user logon name and UPN
    $userLogonName = $username
    $userPrincipalName = "$username@example.local"

    try {
        # Create the new AD user
        New-ADUser -Name $username `
                   -SamAccountName $userLogonName `
                   -UserPrincipalName $userPrincipalName `
                   -Description $description `
                   -Path $ouPath `
                   -AccountPassword $securePassword `
                   -Enabled $true `
                   -PasswordNeverExpires $true `
                   -ChangePasswordAtLogon $false

        Write-Host "User '$username' created successfully with description '$description'." -ForegroundColor Green

        # Add the user to the specified groups
        foreach ($group in $groups) {
            try {
                Add-ADGroupMember -Identity $group -Members $userLogonName
                Write-Host "User '$username' added to group '$group'." -ForegroundColor Green
            }
            catch {
                Write-Host "Error adding user '$username' to group '$group': $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "Error creating user '$username': $($_.Exception.Message)" -ForegroundColor Red
    }
}
