# DNS and DHCP Configuration
> This section documents the DNS and DHCP services configured on `DC01` to provide name resolution and dynamic IPv4 addressing for the home lab.
>
> `DC01` provides centralised DNS resolution for the Active Directory domain and DHCP services for devices on the `CLIENTS` network.

### Server Configuration

|Component|Configuration|
|---|---|
|Server|`DC01`|
|Operating System|`Windows Server 2025`|
|IP Address|`10.10.10.10`|
|Domain|`baron.example.com`|
|DNS Role|`DNS Server`|
|DHCP Role|`DHCP Server`|

## Active Directory-Integrated DNS
DNS was installed alongside Active Directory Domain Services and provides name resolution for the `baron.example.com` domain.

|Configuration|Value|
|---|---|
|DNS Server|`DC01`|
|DNS Server IP|`10.10.10.10`|
|Forward Lookup Zone|`baron.example.com`|
|Reverse Lookup Zone 1|`10.10.10.in-addr.arpa` (`10.10.10.0/24`)| 
|Reverse Lookup Zone 2|`20.10.10.in-addr.arpa` (`10.10.20.0/24`)|
|DNS Zone Types|`Active Directory-Integrated`|

### DNS Records
DNS host records allow systems within the domain to resolve hostnames to IPv4 addresses.

|Hostname|FQDN|IP Address|
|---|---|---|
|`DC01`|`DC01.baron.example.com`|`10.10.10.10`|
|`FS01`|`FS01.baron.example.com`|`10.10.10.20`|
|`CLIENT01`|`CLIENT01.baron.example.com`|`DHCP`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/DNS%20Manager.png" width="800"/>

### DNS Forwarders
External DNS queries that cannot be resolved by the internal DNS server are forwarded to an upstream DNS resolver.

|Configuration|Value|
|---|---|
|DNS Forwarder|`1.1.1.1`|
|DNS Forwarder|`8.8.8.8`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/DNS%20Forwarders.png" width="350"/>

## DHCP Configuration
The DHCP server role was installed and authorised in Active Directory on `DC01`. DHCP provides dynamic IPv4 configuration to devices on the `CLIENTS` network.

### DHCP Scope
> A DHCP scope was created for Windows client devices on the `10.10.20.0/24` network.

|Setting|Configuration|
|---|---|
|DHCP Server|`DC01`|
|DHCP Server IP|`10.10.10.10`|
|Scope Name|`Client Scope`|
|Network|`10.10.20.0/24`|
|Address Range|`10.10.20.100>` - `10.10.20.199`|
|Excluded Addresses|`N/A`|
|Lease Duration|`8 days`|
|003 Router|`10.10.20.1`|
|006 DNS Server|`10.10.10.10`|
|015 DNS Domain Name|`baron.example.com`|

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/DHCP%20Scope.png" width="800"/>
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/DHCP%20Scope%20Options.png" width="800"/>

#### DHCP Relay

`CLIENT01` resides on the `10.10.20.0/24` network while `DC01` resides on the `10.10.10.0/24` server network. The DHCP Relay Agent configured on `RTR01` forwards DHCP requests from the `CLIENTS` network to `DC01`. DHCP Relay configuration is documented in [RRAS Routing and NAT Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md).  
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/DHCP%20Relay%20diagram.png" width="500"/>

## Configuration Validation

### DNS Resolution
> DNS resolution was tested from a domain-joined system to verify that internal hostnames could be resolved using DC01.  

<i>Insert screenshot</i>

### DHCP Lease
> DHCP leases were reviewed on DC01 to verify that CLIENT01 successfully obtained an address from the client scope.  

<i>Insert screenshot</i>

### `CLIENT01` DHCP Configuration
> `ipconfig /all` was used to confirm that `CLIENT01` received its IPv4 configuration dynamically from DC01.  

<i>Insert screenshot</i>

## Skills Demonstrated
- Install and configure Windows Server DNS.
- Configure Active Directory-integrated DNS zones.
- Manage DNS host records.
- Configure DNS forwarding for external name resolution.
- Install and authorise Windows Server DHCP.
- Create and configure IPv4 DHCP scopes.
- Configure DHCP scope options for gateway, DNS and domain settings.
- Provide DHCP services across routed subnets using DHCP relay.
- Validate DNS resolution and DHCP lease allocation using Windows networking tools and PowerShell.
