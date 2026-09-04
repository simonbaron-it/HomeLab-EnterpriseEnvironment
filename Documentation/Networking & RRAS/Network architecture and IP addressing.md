# Network Architecture and IP Addressing
>This section documents the logical network design, subnet structure and IP addressing used throughout the home lab.

## Network Design
The lab is divided into three virtual network segments. RTR01 connects all three networks and acts as the router between the isolated client/server networks and upstream connectivity.

|Network|Switch|Subnet|Gateway|Purpose|
|---|---|---|---|---|
|`WAN`|`LAB-WAN`|`172.16.0.0/24`|`172.16.0.1`|Connectivity to Hyper-V host|
|`SERVERS`|`LAB-SERVERS`|`10.10.10.0/24`|`10.10.10.1`|Isolated network for Windows servers|
|`CLIENTS`|`LAB-CLIENTS`|`10.10.20.0/24`|`10.10.20.1`|Isolated network for Windows client devices|

## IP Addressing Plan
### RTR01
|Interface|IP Address|Purpose|
|---|---|---|
|`WAN`|`172.16.0.2`|Upstream connectivity|
|`SERVERS`|`10.10.10.1`|Server network gateway|
|`CLIENTS`|`10.10.20.1`|Client network gateway|

### Server Network
|Device|Operating System|Role|IP Address|Assignment|Gateway|DNS|
|---|---|---|---|---|---|---|
|`DC01`|`Windows Server 2025`|`AD DS/DNS/DHCP`|`10.10.10.10`|`Static`|`10.10.10.1`|`10.10.10.10`|
|`FS01`|`Windows Server 2025`|`File Server`|`10.10.10.20`|`Static`|`10.10.10.1`|`10.10.10.10`|
### Client Network
|Device|Operating System|Role|IP Address|Assignment|Gateway|DNS|
|---|---|---|---|---|---|---|
|`CLIENT01`|`Windows 11`|`Domain Workstation`|`DHCP`|`Dynamic`|`10.10.20.1`|`10.10.10.10`|

## Network Diagram
<p align="center">
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Network%20Diagram.png" width="500"/>
</p>

## Configuration Validation
`ipconfig` was used to verify that each system's IPv4 address, subnet, default gateway and DNS configuration matched the documented addressing plan.
### RTR01
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/IPConfig%20-%20RTR01.png" width="700"/><p>
### DC01
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/IPConfig%20-%20DC01.png" width="700"/><p>
### FS01
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/IPConfig%20-%20FS01.png" width="700"/><p>
### CLIENT01
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/IPConfig%20-%20CLIENT01.png" width="700"/><p>

### Validation Confirmed:
- `RTR01` is configured with interfaces on all three network segments.
- `DC01` and `FS01` use static addressing on the 10.10.10.0/24 server network.
- `CLIENT01` receives dynamic addressing on the 10.10.20.0/24 client network.
- Server and client systems use the appropriate RTR01 interface as their default gateway.
- Domain members use `DC01` (10.10.10.10) for DNS.

## Skills Demonstrated
- Design a segmented multi-subnet network.
- Plan and document IPv4 addressing.
- Separate client and server infrastructure into dedicated networks.
- Assign static addresses to infrastructure systems.
- Use dynamic addressing for client devices.
- Configure appropriate default gateways and DNS servers.
- Validate IPv4 addressing, default gateway and DNS configuration.

