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

## Active Directory Replication
Active Directory replication ensures directory changes made on one Domain Controller are replicated to the other.
### Replication Validation
PowerShell and Active Directory replication tools were used to verify replication health between `DC01` and `DC02`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/repadmin_replsummary.png" width="800"/>

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Global%20catalog.png" width="800"/>

### Functional Replication test
A `Replication Test User` was created inside the `IT Staff` Active Directory OU on `DC01` and then verified on `DC02` to confirm successful replication.
> User created on DC01
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Replication%20test%20DC01.png" width="800"/>

> User shown replicated on DC02
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Replication%20test%20DC02.png" width="800"/>

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

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/DNS%20Replication%20Validation.png" width="800"/>

### DNS Client Configuration
Domain-joined systems were configured to use both Domain Controllers for DNS resolution.

|System Type|Preferred DNS|Alternate DNS|
|---|---|---|
|DC01|`10.10.10.11`(`DC02`)|`10.10.10.10` (`DC01`)|
|DC02|`10.10.10.10` (`DC01`)|`10.10.10.11` (`DC02`)|
|Servers|`10.10.10.10` (`DC01`)|`10.10.10.11` (`DC02`)|
|Clients via DHCP|`10.10.10.10` (`DC01`)|`10.10.10.11` (`DC02`)|

## Resilience Validation
A controlled failure test was performed with `DC01` unavailable to verify that `DC02` could continue providing Active Directory authentication and DNS services.

### Test Scenario
|Component|Configuration|
|---|---|
|Unavailable Server|`DC01`|
|Available Domain Controller|`DC02`|
|Test Client|`CLIENT01`|
|Authentication Test|Log on using a domain account and confirm `DC02` is the logon server|
|DNS Test|Resolve internal and external DNS names while `DC01` is unavailable|
|Resource Access Test|Obtain new domain authentication tickets for `\\FS01\CompanyData` access while `DC01` is unavailable|

### Test Validation
#### Domain Authentication
A domain user account that had not previously signed in to `CLIENT01` was used to verify that authentication remained available while `DC01` was offline. PowerShell confirmed that `DC02` handled the domain logon.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Domain%20Authentication%20Test.png" width="800"/>

#### Internal DNS Resolution
With `DC01` unavailable, the DNS client cache on `CLIENT01` was cleared and the internal `FS01` hostname was resolved successfully.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Internal%20DNS%20Resolution%20Test.png" width="800"/>

#### External DNS Resolution
External DNS resolution was tested while `DC01` was unavailable to confirm that `DC02` continued providing recursive/upstream name resolution.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/External%20DNS%20Resolution%20Test.png" width="800"/>

#### Domain Resource Access
With `DC01` powered off, `CLIENT01` successfully obtained fresh Kerberos authentication and CIFS service tickets from `DC02`, maintaining access to the `FS01` file server.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Domain%20Resource%20Access%20Test.png" width="800"/>

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
