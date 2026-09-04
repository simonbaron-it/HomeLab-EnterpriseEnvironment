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

### Virtual Machine Configuration

|VM|Generation|vCPU|vRAM|vDisk|Operating System|
|--|----------|---|---|------------|----------------|
|`RTR01`|`Gen 2`|`2`|`4GB`|`40GB`|`Windows Server 2025`|
|`DC01`|`Gen 2`|`2`|`4GB`|`50GB`|`Windows Server 2025`|
|`FS01`|`Gen 2`|`2`|`4GB`|`50GB` `20GB`|`Windows Server 2025`|
|`CLIENT01`|`Gen 2`|`2`|`4GB`|`60GB`|`Windows 11`|

### Hyper-V Manager
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Hyper-V%20Manager.png" width="900"/><p>

## Virtual Network Configuration
> Three Hyper-V virtual switches segment WAN, server, and client traffic. `RTR01` connects all three networks and provides routing between them.

|Virtual Switch|Type|RTR01 Adapter|Purpose|
|---|---|---|---|
|`LAB-WAN`| `Internal`|`WAN`|Upstream Internet/NAT path|
|`LAB-CLIENTS`|`Private`|`CLIENTS`|Isolated network for Windows client VMs|
|`LAB-SERVERS`|`Private`|`SERVERS`|Isolated network for Windows server VMs|
<br>
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Network%20Adapters.png" width="650"/><p>

<b>Notes:</b>  
>- IP addressing, subnet design and default gateways are documented in [Network Architecture and IP Addressing.](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md)
>
>- RRAS and NAT are documented in [RRAS Routing and NAT Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20&%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md).</i>

## PowerShell Validation
> PowerShell was used to confirm each VM is connected to the correct virtual switches.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/PowerShell%20Validation%20-%20Switches.png" width="700"/><p>
### Skills Demonstrated
- Configure and manage Hyper-V virtual machines.
- Create and configure Hyper-V virtual switches.
- Design isolated client and server network segments.
- Configure multi-NIC virtual machines.
- Allocate VM compute, memory and storage resources.
- Map virtual machines to appropriate network segments.
- Validate Hyper-V configuration using PowerShell.
