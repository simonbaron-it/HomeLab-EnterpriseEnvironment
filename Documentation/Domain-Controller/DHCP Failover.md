# DHCP Failover
> This section documents the Phase 2 implementation of DHCP failover between `DC01` and `DC02` to improve availability of IP address assignment for clients on the `CLIENTS` network.

## Overview
The implementation covers:
- Installation and authorisation of the DHCP role on `DC02`.
- Configuration of DHCP failover between `DC01` and `DC02`.
- Synchronisation of the existing `10.10.20.0/24` scope.
- Validation of lease replication between both DHCP servers.
- Controlled failover testing using `CLIENT01`.

> Active Directory and DNS resilience are documented separately in [Active Directory and DNS Resilience](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/AD%20and%20DNS%20Resilience.md).

### DHCP Server Design

|Component|`DC01`|`DC02`|
|---|---|---|
|Operating System|`Windows Server 2025`|`Windows Server 2025`|
|Role|`DHCP Server`|`DHCP Server`|
|IP Address|`10.10.10.10`|`10.10.10.11`|
|Domain|`baron.example.com`|`baron.example.com`|
|DHCP Authorised in AD|`Yes`|`Yes`|
|Failover Partner|`DC02` `10.10.10.11`|`DC01` `10.10.10.10`|

### Existing DHCP Scope

|Setting|Configuration|
|---|---|
|Scope Name|`Client Scope`|
|Scope Network|`10.10.20.0/24`|
|Address Pool|`10.10.20.100` - `10.10.20.199`|
|Lease Duration|`8 days`|
|Default gateway|`10.10.20.1`|
|DNS Servers|`10.10.10.10` `10.10.10.11`|
|DNS Domain|`baron.example.com`|
|DHCP Relay|`RTR01`|

## Failover Configuration
DHCP failover was configured between `DC01` and `DC02` for the existing `10.10.20.0/24` client scope.

### DC02 DHCP Role Deployment
The DHCP Server role was installed on `DC02` and authorised in Active Directory before the failover relationship was created.

<i>Insert DHCP Authorisation Validation DC02</i>

### Failover Relationship

|Setting|Configuration|
|---|---|
|Relationship Name|`DC01-DC02-Failover`|
|Primary Server|`DC01`|
|Partner Server|`DC02`|
|Mode|`Load Balance`|
|ScopeID|`10.10.20.0`|
|Load Balance Percentage|`50`|
|Max Client Lead Time|`01:00:00`|
|Shared Secret|`Configured`|

<i>Insert DHCP Failover Validation screenshot</i>

#### Scope Replication
The DHCP scope configuration was replicated to `DC02` as part of the failover relationship.

<i>Insert DHCP Scope Replication Validation screenshot</i>

#### Lease Synchronisation
Active leases were reviewed on both DHCP servers to verify that lease information was synchronised between failover partners.

<i>Insert Lease Sync Validation screenshot</i>

### DHCP Relay
DHCP Relay was updated on `RTR01` to include `DC02` as a DHCP server.

<i>Insert DHCP Relay Update DC02 screenshot</i>

## Configuration Validaton

## Validation Confirmed:
- `DC01` and `DC02` are both authorised DHCP servers in Active Directory.
- The `10.10.20.0/24` client scope is configured for DHCP failover.
- DHCP scope configuration is available on both failover partners.
- Lease information is synchronised between `DC01` and `DC02`.
- `CLIENT01` receives the correct IP address, gateway, DNS and domain options.
- DHCP requests from the `CLIENTS` network continue to traverse `RTR01` using DHCP Relay.
- Client lease allocation remains available when one DHCP server is unavailable.

## Skills Demonstrated
- Install and authorise the Windows Server DHCP role.
- Configure DHCP failover between Windows Server hosts.
- Replicate DHCP scope configuration between failover partners.
- Validate DHCP failover relationships using PowerShell.
- Validate DHCP lease synchronisation across redundant servers.
- Configure resilient DHCP delivery across routed network segments.
- Perform controlled DHCP failover testing from a Windows client.
- Troubleshoot DHCP availability using Windows administration tools and PowerShell.
