# DNS & DHCP Configuration
> This section documents the DNS and DHCP configuration implemented within my Windows Server home lab.
>
> The objective was to provide reliable name resolution and automated IP address assignment for devices within the domain environment.

## Overview
DNS and DHCP were configured on the Windows Server domain controller to provide core network services for the lab.
> - DNS Server            
> - Forward Lookup Zone   
> - Reverse Lookup Zone   
> - DNS host records     
> - DNS forwarders        
> - DHCP Server
> - DHCP scope
> - Address exclusions
> - DHCP options
> - DHCP reservations

## Environment
This home lab uses the following IPv4 configuration:

|Component|IP Address|
|---------|----------|
|`Network`|`192.168.162.0/24`|
|`Default Gateway`|`192.168.162.1`|
|`Domain Controller`|`192.168.162.10`|
|`File Server`|`192.168.162.20`|
|`DNS Server`|`192.168.162.10`|
|`DHCP Server`|`192.168.162.10`|
|`DHCP Range Start`|`192.168.162.100`|
|`DHCP Range End`|`192.168.162.200`|

## DNS Configuration
### DNS Server
> The DNS server role was installed on: `DC01` `192.168.162.10`. Domain clients were therefore configured to use the domain controller as their DNS server.

<i>Screenshot??</i>

### Forward Lookup Zone
> A forward lookup zone was configured for the Active Directory domain: `Baron.local`

#### Zone Configuration
<i>Screenshot?</i>

### Reverse Lookup Zone
> A reverse lookup zone was configured to allow IP addresses to be resolved back to hostnames.

<i>Screenshot?</i>

### DNS Host Records
|Host|FQDN|IP Address|Record Type|
|----|----|----------|-----------|
|`DC01`|`DC01.Baron.local`|`192.168.162.10`|`A`|
|`File01`|`File01.Baron.local`|`192.168.162.20`|`A`|
|`Client01`|`Client01.Baron.local`|`DHCP Address?`|`A`|

<i>Screenshot?</i>

### DNS Forwarders?

## DHCP Configuration
### DHCP Server
> The DHCP Server role was installed on: `DC01` `192.168.162.10` to automatically provide IP configuration to domain client machines.

<i>Authorisation?</i>  
<i>Screenshot?</i>

### DHCP Scope
|Setting|Configuration|
|-------|-------------|
|`Scope Name`|`Name?`|
|`Network`|`192.168.162.0/24`|
|`Start Address`|`192.168.162.100`|
|`End Address`|`192.168.162.200`|
|`Lease Duration`|`X days`|

<i>Screenshot?</i>

### DHCP Exclusions
### DHCP Options
### DHCP Reservations?
### DHCP Leases?

## Security & Reliability Considerations
## Skills Demonstrated?


