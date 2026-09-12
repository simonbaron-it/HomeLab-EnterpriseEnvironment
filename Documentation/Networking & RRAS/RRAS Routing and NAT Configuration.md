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
The Remote Access server role was installed on `RTR01` and RRAS was configured to provide:

- IPv4 routing between the `SERVERS` and `CLIENTS` networks.
- NAT for traffic leaving the lab through the `WAN` interface.
- Default gateway functionality for both internal subnets.

### RRAS Management Console
>RRAS IPv4 interface overview showing the `WAN`, `SERVERS` and `CLIENTS` interfaces operational on `RTR01`.
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20General.png" width="900"/>

## Internal Routing
`RTR01` provides Layer 3 connectivity between the two isolated internal networks:

|Source Network|Destination Network|Source Gateway|
|---|---|---|
|`10.10.10.0/24`|`10.10.20.0/24`|`10.10.10.1`|
|`10.10.20.0/24`|`10.10.10.0/24`|`10.10.20.1`|

Devices on each internal subnet use the corresponding `RTR01` interface as their default gateway. `RTR01` then forwards traffic between the directly connected `SERVERS` and `CLIENTS` networks.

## NAT Configuration
Network Address Translation is configured to allow systems on the private lab networks to access upstream networks. Traffic originating from the internal `10.10.10.0/24` and `10.10.20.0/24` networks is translated through the `WAN` interface.

|Interface|NAT Role|
|---|---|
|`WAN`|`Public interface connected to the upstream network`|
|`SERVERS`|`Private interface`|
|`CLIENTS`|`Private interface`|

> RRAS console shows the `WAN` interface actively translating traffic from the isolated server and client networks to the upstream network.
 
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20NAT.png" width="900"/>

### Hyper-V Host Upstream Connectivity
The `LAB-WAN` Hyper-V switch provides an isolated upstream network between `RTR01` and the Windows 11 Hyper-V host.

|System|Interface|IP Address|Purpose|
|---|---|---|---|
|`Hyper-V Host`|`vEthernet (LAB-WAN)`|`172.16.0.1/24`|Upstream gateway for RTR01|
|`RTR01`|`WAN`|`172.16.0.2/24`|RRAS external interface|

> The Hyper-V host provides NAT between the `172.16.0.0/24` LAB-WAN network and its physical network connection.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Get-NetNat.png" width="900"/>

## DHCP Relay
Because `CLIENT01` resides on a different subnet from the DHCP server on `DC01`, DHCP relay is used to forward DHCP requests between the client and server networks.

|Component|Configuration|
|---|---|
|DHCP Server|`DC01` `10.10.10.10`|
|Client Network|`10.10.20.0/24`|
|Relay Interface|`CLIENTS`|
|DHCP Relay Destination|`10.10.10.10`|

### RRAS DHCP Relay Agent
>Configured on the `CLIENTS` interface, forwarding DHCP requests from the isolated client subnet to the DHCP server on `DC01`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RRAS%20Management%20Console%20-%20DHCP%20Relay.png" width="900"/>

## Routing Table
The IPv4 routing table was reviewed to verify that `RTR01` had routes for each directly connected network and a default route to the upstream gateway.

### Filtered IPv4 Routing Table
>Showing the directly connected `WAN`, `SERVERS` and `CLIENTS` networks, plus the default route to the upstream Hyper-V host at `172.16.0.1`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/RTR01%20Routing%20Table.png" width="900"/>

## Configuration Validation
Connectivity testing was performed from `CLIENT01` to verify inter-subnet routing and upstream connectivity through `RTR01`.

### Tracert to `DC01`
> Confirms that `CLIENT01` can reach `DC01` across the `CLIENTS` and `SERVERS` networks through `RTR01`.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/CLIENT01%20Tracert%20to%20DC01.png" width="900"/>

### Ping Upstream Network
> Confirms that traffic originating from `CLIENT01` can traverse `RTR01` and reach an external IP address through the lab's NAT path.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/CLIENT01%20Ping%20to%20upstream%20network.png" width="900"/>

### Validation Confirmed
- `RTR01` successfully routes traffic between the `CLIENTS` and `SERVERS` networks.
- `CLIENT01` can reach `DC01` across the routed network boundary.
- Traffic from the private client network successfully reaches external networks through the RRAS and Hyper-V host NAT path.
- `RTR01` maintains directly connected routes for all three network segments and a default route through `172.16.0.1`.
- DHCP Relay is configured to forward requests from the `CLIENTS` network to `DC01`.

## Skills Demonstrated
- Install and configure Windows Server Routing and Remote Access.
- Configure a multi-NIC Windows Server as a network router.
- Route traffic between isolated IPv4 subnets.
- Configure Network Address Translation for private networks.
- Configure appropriate internal and external RRAS interfaces.
- Configure DHCP relay across routed network segments.
- Interpret and validate Windows routing tables.
- Validate inter-subnet routing and upstream NAT connectivity.
- Troubleshoot routed network connectivity using Windows networking tools.
