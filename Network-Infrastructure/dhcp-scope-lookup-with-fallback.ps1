<#
.SYNOPSIS
Finds which DHCP scope an IPv4 address belongs to, with fallback to a secondary DHCP server.

.DESCRIPTION
This script prompts for an IPv4 address, checks a primary DHCP server for a matching scope,
and only queries a secondary DHCP server if no match is found. It returns the matching scope ID
and scope name for troubleshooting and network assignment validation.

.AUTHOR
Erik McCauley

.NOTES
Sanitized for public sharing. No sensitive, proprietary, or environment-specific data is included.
Replace placeholder values before use in a production environment.
#>

$primaryServer  = "dhcp-primary.example.local"
$fallbackServer = "dhcp-secondary.example.local"

function ConvertTo-IPv4UInt32 {
    param(
        [Parameter(Mandatory)]
        [string]$IpAddress
    )

    $ipObject = [System.Net.IPAddress]::Parse($IpAddress)

    if ($ipObject.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
        throw "Only IPv4 addresses are supported. Invalid input: $IpAddress"
    }

    $bytes = $ipObject.GetAddressBytes()
    [Array]::Reverse($bytes)
    [BitConverter]::ToUInt32($bytes, 0)
}

function Test-IPv4InRange {
    param(
        [Parameter(Mandatory)]
        [string]$Ip,

        [Parameter(Mandatory)]
        [string]$Start,

        [Parameter(Mandatory)]
        [string]$End
    )

    $ipValue    = ConvertTo-IPv4UInt32 -IpAddress $Ip
    $startValue = ConvertTo-IPv4UInt32 -IpAddress $Start
    $endValue   = ConvertTo-IPv4UInt32 -IpAddress $End

    ($ipValue -ge $startValue -and $ipValue -le $endValue)
}

function Find-MatchingScopesOnServer {
    param(
        [Parameter(Mandatory)]
        [string]$Server,

        [Parameter(Mandatory)]
        [string]$Ip
    )

    Write-Host "Scanning scopes on $Server..." -ForegroundColor Cyan

    try {
        $scopes = Get-DhcpServerv4Scope -ComputerName $Server -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to query scopes on $Server : $($_.Exception.Message)"
        return @()
    }

    $matches = foreach ($scope in $scopes) {
        if (Test-IPv4InRange -Ip $Ip -Start $scope.StartRange.ToString() -End $scope.EndRange.ToString()) {
            [pscustomobject]@{
                Server    = $Server
                IPAddress = $Ip
                ScopeId   = $scope.ScopeId
                ScopeName = $scope.Name
            }
        }
    }

    return $matches
}

# Prompt for a single IPv4 address
$ipAddress = Read-Host -Prompt "Enter the IPv4 address to check"

if (-not ($ipAddress -match '^\d{1,3}(\.\d{1,3}){3}$')) {
    Write-Error "Invalid IPv4 address format: $ipAddress"
    return
}

$results = New-Object System.Collections.Generic.List[Object]

# Check primary server first
$primaryMatches = @(Find-MatchingScopesOnServer -Server $primaryServer -Ip $ipAddress)

if ($primaryMatches.Count -gt 0) {
    $results.AddRange($primaryMatches)
}
else {
    # Only check fallback if nothing found on primary
    $fallbackMatches = @(Find-MatchingScopesOnServer -Server $fallbackServer -Ip $ipAddress)

    if ($fallbackMatches.Count -gt 0) {
        $results.AddRange($fallbackMatches)
    }
    else {
        $results.Add([pscustomobject]@{
            Server    = $primaryServer
            IPAddress = $ipAddress
            ScopeId   = $null
            ScopeName = "<no matching scope>"
        })

        $results.Add([pscustomobject]@{
            Server    = $fallbackServer
            IPAddress = $ipAddress
            ScopeId   = $null
            ScopeName = "<no matching scope>"
        })
    }
}

# Output results
$results |
    Sort-Object Server, ScopeId |
    Select-Object Server, IPAddress, ScopeId, ScopeName |
    Format-Table -AutoSize
