# Network Architecture & IP Addressing
>This section documents the logical network design, subnet structure and IP addressing used throughout the home lab.

## Network Design
The lab is divided into three virtual network segments. RTR01 connects all three networks and acts as the router between the isolated client/server networks and upstream connectivity.

|Network|Switch|Subnet|Gateway|Purpose|
|---|---|---|---|---|
|`WAN`|`LAB-WAN`|`172.16.0.0/24`|`172.16.0.2`|Connectivity to Hyper-V host|
|`SERVERS`|`LAB-SERVERS`|`10.10.10.0/24`|`10.10.10.1`|Isolated network for Windows servers|
|`CLIENTS`|`LAB-CLIENTS`|`10.10.20.0/24`|`10.10.20.1`|Isolated network for Windows client devices|

## Network Topology
<i>Insert final network architecture diagram</i>

## IP Addressing Plan
### RTR01
|Interface|IP Address|Purpose|
|---|---|---|
|`WAN`|`172.16.0.1`|Upstream connectivity|
|`SERVERS`|`10.10.10.1`|Server network gateway|
|`CLIENTS`|`10.10.20.1`|Client network gateway|
### Server Network
|Device|Role|IP Address|Assignment|Gateway|DNS|
|---|---|---|---|---|---|
|`DC01`|`AD DS/DNS/DHCP`|`10.10.10.10`|`Static`|`10.10.10.1`|`10.10.10.10`|
|`FS01`|`File Server`|`10.10.10.20`|`Static`|`10.10.10.1`|`10.10.10.10`|
### Client Network
|Device|Role|IP Address|Assignment|Gateway|DNS|
|---|---|---|---|---|---|
|`CLIENT01`|`Windows 11 Workstation`|`DHCP`|`Dynamic`|`10.10.20.1`|`10.10.10.10`|

<i>Powershell screenshots?</i>

## Skills Demonstrated
- Design a segmented multi-subnet network.
- Plan and document IPv4 addressing.
- Separate client and server infrastructure into dedicated networks.
- Assign static addresses to infrastructure systems.
- Use dynamic addressing for client devices.
- Configure appropriate default gateways and DNS servers.
- Validate addressing and connectivity across multiple subnets.

