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
|Installed RAM|`32GB` `DDR5`|
|Storage|`1TB` `SSD`|

<i>Screenshot of Hyper-V Manager</i>

### Virtual Switch and Network Adapter Configuration
> Three Hyper-V virtual switches and network adapters are used to provide network segmentation.

|Virtual Switch|Switch Type|NIC|Purpose|
|--------------|----|---|-------|
|`LAB-WAN`| `Internal`|`WAN`|Connectivity between Hyper-V Host and RTR01|
|`LAB-CLIENTS`|`Private`|`CLIENTS`|Connectivity between Windows 11 Client VM's and RTR01|
|`LAB-SERVERS`|`Private`|`SERVERS`|Connectivity between Windows Server VM's and RTR01|

### Virtual Machine Configuration

|VM|Generation|CPU|RAM|Virtual Disk|Operating System|
|--|----------|---|---|------------|----------------|
|`RTR01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`DC01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`FS01`|`Gen 2`|`X`|`X`|`X`|`Windows Server 2025`|
|`CLIENT01`|`Gen 2`|`X`|`X`|`X`|`Windows 11`|

<i>Insert virtual switch layout diagram</i>

>IP addressing, subnet design and default gateways are documented in <i>Network Architecture.</i>
>
>RRAS routing and NAT configuration are documented in <i>RRAS.</i>

### Powershell Validation?
### Skills Demonstrated?
