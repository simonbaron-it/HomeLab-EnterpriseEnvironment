# RRAS Routing and NAT Configuration
>This section documents the Routing and Remote Access Service (RRAS) configuration used on `RTR01` to route traffic between the lab's isolated network segments and provide upstream connectivity through NAT.

## RRAS Server
|Component|Configuration|
|---|---|
|Server|`RTR01`|
|Operating System|`Windows Server 2025`|
|Role|`Routing and Remote Access`|
|Routing|`IPv4 Routing`|
|NAT|`Enabled`|

>`RTR01` is not domain joined and operates as a dedicated router between the WAN, server and client networks.

## Network Interfaces
`RTR01` has three network interfaces, allowing it to route traffic between each network segment.
|Interface|Network|IP Address|Purpose|
|---|---|---|---|
|`WAN`|`172.16.0.0/24`|`172.16.0.2`|Upstream connectivity and NAT|
|`SERVERS`|`10.10.10.0/24`|`10.10.10.1`|Server network gateway|
|`CLIENTS`|`10.10.20.0/24`|`10.10.20.1`|Client network gateway|

> Full subnet design and device addressing are documented in [Network Architecture and IP Addressing](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md).

## RRAS Configuration
The Remote Access role was installed on `RTR01` and RRAS was configured to provide:

- IPv4 routing between the `SERVERS` and `CLIENTS` networks.
- NAT for traffic leaving the lab through the `WAN` interface.
- Default gateway functionality for both internal subnets.

### RRAS Management Console
>RRAS IPv4 interface overview showing the WAN, Server and Client interfaces operational on RTR01.
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20General.png" width="900"/>

## Internal Routing
`RTR01` provides Layer 3 connectivity between the two isolated internal networks:

|Source Network|Destination Network|Router Interface|
|---|---|---|
|`10.10.10.0/24`|`10.10.20.0/24`|`10.10.10.1`|
|`10.10.20.0/24`|`10.10.10.0/24`|`10.10.20.1`|

This allows systems on the client network to communicate with infrastructure services hosted on the server network while keeping the two networks logically separated.

## NAT Configuration
Network Address Translation is configured to allow systems on the private lab networks to access upstream networks. Traffic originating from the internal `10.10.10.0/24` and `10.10.20.0/24` networks is translated through the `WAN` interface.

|Interface|NAT Role|
|---|---|
|`WAN`|`Public interface connected to the Internet`|
|`SERVERS`|`Private interface`|
|`CLIENTS`|`Private interface`|

### RRAS NAT overview 
>Showing the WAN interface actively translating traffic from the isolated server and client networks to the upstream network.
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20NAT.png" width="900"/>

## DHCP Relay
Because `CLIENT01` resides on a different subnet from the DHCP server on `DC01`, DHCP relay is used to forward DHCP requests between the client and server networks.

|Component|Configuration|
|---|---|
|DHCP Server|`DC01` `10.10.10.10`|
|Client Network|`10.10.20.0/24`|
|Relay Interface|`CLIENTS`|
|DHCP Relay Destination|`10.10.10.10`|

### RRAS DHCP Relay Agent
>Configured on the CLIENTS interface, forwarding DHCP requests from the isolated client subnet to the DHCP server on DC01.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20DHCP%20Relay.png" width="900"/>

## Routing Table
A routing table was used to verify that `RTR01` had routes for each directly connected network and an upstream default route.

### Filtered IPv4 routing table on RTR01
>Showing the directly connected WAN, Server and Client networks, plus the default route to the upstream Hyper-V host at 172.16.0.1.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RTR01%20Routing%20Table.png" width="900"/>

## Skills Demonstrated
- Install and configure Windows Server Routing and Remote Access.
- Configure a multi-NIC Windows Server as a network router.
- Route traffic between isolated IPv4 subnets.
- Configure Network Address Translation for private networks.
- Configure appropriate internal and external RRAS interfaces.
- Configure DHCP relay across routed network segments.
- Interpret and validate Windows routing tables.
