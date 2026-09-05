# Template to be edited
# DNS and DHCP Configuration

> This section documents the DNS and DHCP services configured on `DC01` to provide name resolution and dynamic IPv4 addressing for the home lab.

## Server Configuration

|Component|Configuration|
|---|---|
|Server|`DC01`|
|Operating System|`Windows Server 2025`|
|IP Address|`10.10.10.10`|
|Domain|`baron.example.com`|
|DNS Role|`DNS Server`|
|DHCP Role|`DHCP Server`|

`DC01` provides centralised DNS resolution for the Active Directory domain and DHCP services for devices on the client network.

> - Active Directory configuration is documented in [Active Directory Domain Services](Active-Directory.md).
> - Network addressing is documented in [Network Architecture and IP Addressing](../Networking/Network-Architecture.md).
> - DHCP relay between the client and server networks is documented in [RRAS Routing and NAT Configuration](../Networking/RRAS.md).

# DNS Configuration

## Active Directory-Integrated DNS

DNS was installed alongside Active Directory Domain Services and provides name resolution for the `baron.example.com` domain.

|Configuration|Value|
|---|---|
|DNS Server|`DC01`|
|DNS Server IP|`10.10.10.10`|
|Forward Lookup Zone|`baron.example.com`|
|Zone Type|`Active Directory-Integrated`|
|Dynamic Updates|`Secure Only`|

### DNS Manager

> DNS Manager showing the Active Directory-integrated `baron.example.com` forward lookup zone.

<img src="INSERT-DNS-MANAGER-SCREENSHOT" width="900"/>

## DNS Records

DNS host records allow systems within the domain to resolve hostnames to IPv4 addresses.

|Hostname|FQDN|IP Address|
|---|---|---|
|`DC01`|`DC01.baron.example.com`|`10.10.10.10`|
|`FS01`|`FS01.baron.example.com`|`10.10.10.20`|
|`CLIENT01`|`CLIENT01.baron.example.com`|`DHCP`|

> Only include records that exist in the environment.

### DNS Records

<img src="INSERT-DNS-RECORDS-SCREENSHOT" width="900"/>

## DNS Forwarders

External DNS queries that cannot be resolved by the internal DNS server are forwarded to an upstream DNS resolver.

|Configuration|Value|
|---|---|
|DNS Forwarder|`<FORWARDER-IP>`|

> Remove this section if DNS forwarders have not been configured.

# DHCP Configuration

## DHCP Server

The DHCP Server role was installed and authorised in Active Directory on `DC01`.

DHCP provides dynamic IPv4 configuration to devices on the `CLIENTS` network.

|Configuration|Value|
|---|---|
|DHCP Server|`DC01`|
|DHCP Server IP|`10.10.10.10`|
|Client Network|`10.10.20.0/24`|
|Default Gateway|`10.10.20.1`|
|DNS Server|`10.10.10.10`|
|DNS Domain|`baron.example.com`|

## DHCP Scope

A DHCP scope was created for Windows client devices on the `10.10.20.0/24` network.

|Setting|Configuration|
|---|---|
|Scope Name|`<SCOPE-NAME>`|
|Network|`10.10.20.0/24`|
|Address Range|`<START-IP>` - `<END-IP>`|
|Excluded Addresses|`<EXCLUSIONS>`|
|Lease Duration|`<LEASE-DURATION>`|
|Router / Option 003|`10.10.20.1`|
|DNS Server / Option 006|`10.10.10.10`|
|DNS Domain / Option 015|`baron.example.com`|

### DHCP Scope

> DHCP management console showing the configured client scope and scope options.

<img src="INSERT-DHCP-SCOPE-SCREENSHOT" width="900"/>

## DHCP Relay

`CLIENT01` resides on the `10.10.20.0/24` network while `DC01` resides on the `10.10.10.0/24` server network.

DHCP broadcasts do not cross routers by default, so the DHCP Relay Agent configured on `RTR01` forwards DHCP requests from the `CLIENTS` network to `DC01`.

```text
CLIENT01
10.10.20.0/24
     │
     ▼
RTR01 DHCP Relay
10.10.20.1
     │
     ▼
DC01 DHCP Server
10.10.10.10



DHCP Relay configuration is documented in RRAS Routing and NAT Configuration.

Configuration Validation
DNS Resolution

DNS resolution was tested from a domain-joined system to verify that internal hostnames could be resolved using DC01.

DHCP Lease

DHCP leases were reviewed on DC01 to verify that CLIENT01 successfully obtained an address from the client scope.

CLIENT01 DHCP Configuration

ipconfig /all was used to confirm that CLIENT01 received its IPv4 configuration from DC01.

Validation Confirmed
DC01 provides DNS services for the baron.example.com domain.
Domain systems resolve internal DNS records through 10.10.10.10.
DHCP provides dynamic IPv4 addressing to the CLIENTS network.
DHCP scope options provide the correct default gateway, DNS server and DNS domain.
CLIENT01 successfully receives a DHCP lease from DC01 across the routed network.

Skills Demonstrated
Install and configure Windows Server DNS.
Configure Active Directory-integrated DNS zones.
Manage DNS host records and dynamic updates.
Configure DNS forwarding for external name resolution.
Install and authorise Windows Server DHCP.
Create and configure IPv4 DHCP scopes.
Configure DHCP scope options for gateway, DNS and domain settings.
Provide DHCP services across routed subnets using DHCP relay.
Validate DNS resolution and DHCP lease allocation using Windows networking tools and PowerShell.
