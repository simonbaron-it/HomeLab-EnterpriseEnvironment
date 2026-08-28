# RRAS Routing & NAT Configuration
>This section documents the Routing and Remote Access Service (RRAS) configuration used on `RTR01` to route traffic between the lab networks and provide NAT for upstream connectivity.

## RRAS Server
|Component|Configuraion|
|---|---|
|Server|`RTR01`|
|Operating System| `Windows Server 2025`|
|Role|`Routing and Remote Access`|
|WAN Network|`172.16.0.0/24`|
|Server Network|`10.10.10.0/24`|
|Client Network|`10.10.20.0/24`|

>Full subnet and device addressing is documented in <i>Network Architecture & IP Addressing.</i>

## Network Interfaces
`RTR01` has three network interfaces, allowing it to route traffic between each network segment.
|Interface|Network|IP Address|Purpose|
|---|---|---|---|
|`WAN`|`172.16.0.0/24`|`172.16.0.1`|Upstream connectivity/NAT|
|`SERVERS`|`10.10.10.0/24`|`10.10.10.1`|Server network gateway|
|`CLIENTS`|`10.10.20.0/24`|`10.10.20.1`|Client network gateway|

## RRAS Configuration
