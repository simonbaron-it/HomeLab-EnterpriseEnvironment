# Hyper-V & Virtual Infrastructure
> This section documents the Hyper-V host, virtual switches and virtual machines used to provide the virtualisation platform for the home lab.
> 
> The objective was to create a virtualisation platform capable of hosting multiple Windows Server and client virtual machines while maintaining an isolated internal lab network with controlled external connectivity through a dedicated RRAS server.

## Hyper-V Host
|Component|Configuration|
|---------|-------------|
|Operating System|`Windows 11 Pro`|
|Hypervisor|`Microsoft Hyper-V`|
|Processor|`AMD Ryzen 7 PRO 6850U`|
|CPU Cores/Threads|`8 Cores` `16 Threads`|
|Installed RAM|`32GB DDR5`|
|Storage|`1TB SSD`|

<i>Screenshot of Hyper-V Manager</i>

### Virtual Switch Configuration
> Three Hyper-V virtual switches are used to separate external network, client and server traffic.

|Virtual Switch|Type|Purpose|
|--------------|----|-------|
|`LAB-WAN`| `Internal`|Connectivity between Hyper-V Host and RTR01|
|`LAB-CLIENTS`|`Private`|Isolated network for Windows client VMs|
|`LAB-SERVERS`|`Private`|Isolated network for Windows server VMs|

### RTR01 Network Adapters
> RTR01 connects all three virtual networks.

|Virtual Switch|Adapter|IP Address|
|---|---|---|
|`LAB-WAN`|`WAN`|`172.16.0.1`|
|`LAB-CLIENTS`|`CLIENTS`|`10.10.20.1`|
|`LAB-SERVERS`|`SERVERS`|`10.10.10.1`|

<i>Insert RTR01 network adapter screenshot?</i>

### Virtual Machine Configuration

|VM|Generation|CPU|RAM|Virtual Disk|Operating System|
|--|----------|---|---|------------|----------------|
|`RTR01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`DC01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`FS01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`CLIENT01`|`Gen 2`|`X`|`X`|`X`|`Windows 11`|

<i>Insert VM/vswitch layout diagram</i>

<b>Notes:</b>  
>- IP addressing, subnet design and default gateways are documented in <i>Network Architecture.</i>
>
>- RRAS routing and NAT configuration are documented in <i>RRAS.</i>

### Powershell Validation?
### Skills Demonstrated
- Configure and manage Hyper-V virtual machines.
- Create and configure Hyper-V virtual switches.
- Design isolated client and server network segments.
- Configure multi-NIC virtual machines.
- Allocate VM compute, memory and storage resources.
- Map virtual machines to appropriate network segments.
- Validate Hyper-V configuration using PowerShell.
