# Active Directory and DNS Resilience
> This section documents the Phase 2 deployment of an additional Domain Controller to improve Active Directory and DNS availability within the baron.example.com environment.

## Overview
The implementation covers:
- Deployment and promotion of `DC02` as an additional Domain Controller.
- Active Directory replication between `DC01` and `DC02`.
- AD-integrated DNS replication.
- Redundant DNS configuration for domain-joined systems.
- Validation of authentication and DNS resolution when one Domain Controller is unavailable.

> DHCP resilience is documented separately in [DHCP Failover](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/DHCP%20Failover.md).

## DC02 Deployment
### Virtual Machine Configuration

|Setting|Configuration|
|---|---|
|VM Name|`DC02`|
|Generation|`Gen 2`|
|vCPU|`2`|
|vRAM|`4GB`|
|vDisk|`50GB`|
|Operating System|`Windows Server 2025`|
|Network|`LAB-SERVERS`|

### Network Configuration
`DC02` was configured with a static IP address on the `SERVERS` network before being added to the `baron.example.com` domain and promoted to a Domain Controller.

|Setting|Value|
|---|---|
|IP Address|`10.10.10.11`|
|Subnet Mask|`255.255.255.0`|
|Default Gateway|`10.10.10.1`|
|Preferred DNS|`10.10.10.10`|
|Alternate DNS|`127.0.0.1`|

## Active Directory Replication
Active Directory replication ensures directory changes made on one Domain Controller are replicated to the other.
### Replication Validation
PowerShell and Active Directory replication tools were used to verify replication health between `DC01` and `DC02`.
```Powershell
repadmin /replsummary

repadmin /showrepl

Get-ADDomainController -Filter * |
Select-Object HostName, IPv4Address, Site, IsGlobalCatalog
```

### Functional Replication test??
A change was created on one Domain Controller and verified on the other to confirm successful replication.
<i>Screenshots??</i>

## DNS Resilience
Both Domain Controllers host DNS and the `baron.example.com` zone is Active Directory-integrated. Because the DNS zone is stored in Active Directory, DNS records replicate between `DC01` and `DC02` through Active Directory replication.

|Setting|Configuration|
|---|---|
|Primary Zone|`baron.example.com`|
|Zone Type|`Active Directory Integrated`|
|Dynamic Updates|`Secure only`|
|DNS Server 1|`DC01` `10.10.10.10`|
|DNS Server 2|`DC02` `10.10.10.11`|

### DNS Replication Validation
DNS records were verified on both Domain Controllers to confirm that AD-integrated DNS data replicated successfully.

```Powershell
Get-DnsServerZone -ComputerName DC01

Get-DnsServerZone -ComputerName DC02

Resolve-DnsName DC01.baron.example.com -Server <DC02-IP>
Resolve-DnsName DC02.baron.example.com -Server 10.10.10.10
```

### Client DNS Redundancy
Domain-joined systems were configured to use both Domain Controllers for DNS resolution.

|System Type|Preferred DNS|Alternate DNS|
|---|---|---|
|Servers|`DC01` `10.10.10.10`|`DC02` `10.10.10.11`|
|Clients via DHCP|`DC01` `10.10.10.10`|`DC02` `10.10.10.11`|

<i>Screenshot?</i>

## Resilience Validation
A controlled failure test was performed to verify that core Active Directory and DNS services remained available when one Domain Controller was unavailable.

### Test Scenario
|Component|Configuration|
|---|---|
|Unavailable Server|`DC01`|
|Test Client|`CLIENT01`|
|Authentication Test|`Add description`|
|DNS Test|`Add description`|
|Resource Access Test|`Add description`|

### Test Validation
#### Domain Authentication
<i>insert Screenshot</i>
#### Internal DNS Resolution
<i>insert Screenshot</i>
#### External DNS Resolution
<i>insert Screenshot</i>
#### Domain Resource Access
<i>insert Screenshot</i>

## Validation Confirmed
- `DC02` operates as an additional Domain Controller for `baron.example.com`.
- Active Directory replication between `DC01` and `DC02` is healthy.
- Both Domain Controllers host the AD-integrated DNS zone.
- DNS records replicate successfully between `DC01` and `DC02`.
- Domain-joined systems are configured with redundant DNS servers.
- Authentication and internal DNS resolution remain available when one Domain Controller is unavailable.
- Domain resources remain accessible during a single Domain Controller outage.

## Skills Demonstrated
- Deploy an additional Windows Server Domain Controller.
- Configure Active Directory Domain Services redundancy.
- Validate Active Directory replication using `repadmin` and PowerShell.
- Configure and validate AD-integrated DNS replication.
- Configure redundant DNS services for domain-joined systems.
- Update DHCP-delivered DNS configuration for resilient name resolution.
- Perform controlled failover testing of Active Directory and DNS services.
- Troubleshoot replication and DNS availability using Windows administration tools and PowerShell.
