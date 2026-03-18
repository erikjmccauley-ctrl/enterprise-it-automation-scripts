<#
.SYNOPSIS
Resolves IPv4 addresses for a list of hostnames using DNS.

.DESCRIPTION
This script processes a list of hostnames, attempts to resolve each one to an IPv4 address
using Resolve-DnsName, and falls back to .NET DNS resolution if needed. It is useful for
endpoint discovery, DNS validation, and network troubleshooting tasks.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

# Resolve IPv4 addresses for a list of hostnames using DNS only.
# Prints results to the console.

# Define list of hostnames
$hostList = @(
    "PC001",
    "PC002",
    "PC003",
    "PC004",
    "PC005",
    "PC006",
    "PC007",
    "PC008",
    "PC009",
    "PC010"
)

# Try Resolve-DnsName first
function Resolve-WithResolveDnsName {
    param (
        [string]$Name
    )

    try {
        $result = Resolve-DnsName -Name $Name -Type A -ErrorAction Stop
        $result |
            Where-Object { $_.Type -eq "A" } |
            Select-Object -ExpandProperty IPAddress -Unique
    }
    catch {
        $null
    }
}

# Fallback using .NET DNS
function Resolve-WithNetDns {
    param (
        [string]$Name
    )

    try {
        [System.Net.Dns]::GetHostAddresses($Name) |
            Where-Object { $_.AddressFamily -eq "InterNetwork" } |
            ForEach-Object { $_.IPAddressToString } |
            Select-Object -Unique
    }
    catch {
        $null
    }
}

foreach ($host in $hostList) {
    $hostName = $host.Trim()
    if ($hostName -eq "") {
        continue
    }

    $ipAddresses = Resolve-WithResolveDnsName -Name $hostName
    $method = "Resolve-DnsName"

    if (-not $ipAddresses) {
        $ipAddresses = Resolve-WithNetDns -Name $hostName
        $method = "System.Net.Dns"
    }

    if ($ipAddresses) {
        Write-Output ("{0} -> {1} [{2}]" -f $hostName, ($ipAddresses -join "; "), $method)
    }
    else {
        Write-Output ("{0} -> Not found via DNS" -f $hostName)
    }
}
