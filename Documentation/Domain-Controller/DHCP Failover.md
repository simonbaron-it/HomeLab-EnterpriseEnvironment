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
