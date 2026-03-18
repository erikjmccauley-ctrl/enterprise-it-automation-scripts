<#
.SYNOPSIS
Checks DHCP scope, reservation, and lease status for a given IP address.

.DESCRIPTION
This script prompts for an IP address, determines the associated DHCP scope,
and checks whether the IP is reserved, leased, or available. Useful for
troubleshooting IP conflicts and validating network assignments.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Import the DHCP Server module
Import-Module DhcpServer

# Define the DHCP server (placeholder)
$DhcpServer = "dhcp-server.example.local"

do {
    # Prompt user for IP
    $IPAddress = Read-Host -Prompt "Enter IP Address (or type 'exit' to quit)"

    if ($IPAddress.ToLower() -eq "exit") {
        break
    }

    try {
        # Get scope based on subnet (basic /24 assumption)
        $Scope = Get-DhcpServerv4Scope -ComputerName $DhcpServer | Where-Object {
            $_.ScopeId -eq (
                ([System.Net.IPAddress]::Parse($IPAddress)).Address -band
                ([System.Net.IPAddress]::Parse("255.255.255.0")).Address
            )
        }

        if ($Scope) {
            Write-Host "Scope Name: $($Scope.Name)" -ForegroundColor Cyan

            # Check reservation
            $Reservation = Get-DhcpServerv4Reservation `
                -ComputerName $DhcpServer `
                -ScopeId $Scope.ScopeId |
                Where-Object { $_.IPAddress -eq $IPAddress }

            # Check lease
            $Lease = Get-DhcpServerv4Lease `
                -ComputerName $DhcpServer `
                -ScopeId $Scope.ScopeId |
                Where-Object { $_.IPAddress -eq $IPAddress }

            if ($Reservation) {
                Write-Host "Status: Reserved IP" -ForegroundColor Yellow
            }
            elseif ($Lease) {
                Write-Host "Status: Active Lease" -ForegroundColor Green
            }
            else {
                Write-Host "Status: Available / Not in use" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "No matching DHCP scope found." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error processing IP: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""

} while ($true)
