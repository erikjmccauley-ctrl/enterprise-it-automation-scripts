# Network Infrastructure Automation Scripts

This folder contains PowerShell scripts used for network-level visibility, troubleshooting, and infrastructure management in enterprise environments.

## 🔧 Overview

The scripts in this directory focus on analyzing and validating network configurations, including DHCP scope assignments, DNS resolution, and IP address utilization. These tools are designed to support rapid troubleshooting, improve visibility, and reduce manual investigation time.

## 🚀 Key Capabilities

- DHCP scope identification and validation  
- IP address lease and reservation analysis  
- Multi-server DHCP lookup with fallback logic  
- DNS hostname-to-IP resolution  
- Bulk endpoint network discovery and validation  

## 🧠 Use Cases

- Investigating IP conflicts and duplicate address issues  
- Identifying which DHCP scope an IP belongs to  
- Validating reserved vs leased IP assignments  
- Resolving hostnames to IPs for endpoint discovery  
- Supporting network and endpoint troubleshooting workflows  

## ⚙️ Technologies Used

- PowerShell  
- DHCP Server module (`DhcpServer`)  
- DNS resolution (`Resolve-DnsName`, `.NET DNS`)  
- IPv4 parsing and subnet/range calculations  

## 📁 Included Scripts

- `dhcp-ip-scope-and-lease-check.ps1`  
- `dhcp-scope-lookup-with-fallback.ps1`  
- `bulk-dns-hostname-ip-lookup.ps1`  

## 🔒 Disclaimer

All scripts have been sanitized for public sharing.  
No sensitive, proprietary, or environment-specific information is included.

## 👤 Author

Erik McCauley
