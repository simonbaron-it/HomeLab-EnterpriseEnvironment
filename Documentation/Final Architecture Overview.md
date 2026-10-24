# Final Architecture Overview
> <b>Project:</b> Windows Server Enterprise Home Lab.   
> <b>Status:</b> Complete — Phases 1 and 2.   
> <b>Scope:</b> Final on-premises architecture before the separate Azure hybrid extension project.

## Purpose and Scope
This document provides a current-state view of the completed Windows Server enterprise home lab following <b>Phase 2</b>. It is an architecture reference, not a deployment guide. The <b>Phase 1</b> documentation records the initial build; <b>Phase 2</b> documentation records subsequent resilience, management, monitoring and automation improvements. For configuration steps, evidence and testing, follow the links throughout this document.
> <b>At a glance:</b> Six virtual machines, three Hyper-V virtual switches, segregated server/client networking, redundant directory and core network services, centralised management and monitoring, file services, and tested backup/recovery procedures.

## Final Architecture Diagram

<p align="center">
<img src="Images/Phase%202%20Network%20Diagram.png" width="700"/>
</p>

## Virtual Machine Inventory
|VM|Primary role|IP address|CPU|RAM|Storage|Virtual switch|
|---|---|---|---|---|---|---|
|`RTR01`|RRAS routing, NAT and DHCP relay|WAN: `172.16.0.2`; SERVERS: `10.10.10.1`; CLIENTS: `10.10.20.1`|`2 vCPU`|`4GB`|`40GB OS`|`LAB-WAN`, `LAB-SERVERS`, `LAB-CLIENTS`|
|`DC01`|AD DS, DNS, DHCP|`10.10.10.10`|`2 vCPU`|`4GB`|`50GB OS`, `100GB Backup`|`LAB-SERVERS`|
|`DC02`|Additional domain controller, DNS, DHCP failover|`10.10.10.11`|`2 vCPU`|`4GB`|`50GB OS`, `100GB Backup`|`LAB-SERVERS`|
|`FS01`|SMB file shares and NTFS access control|`10.10.10.20`|`2 vCPU`|`4GB`|`50GB OS`, `20GB Data`, `100GB Backup`|`LAB-SERVERS`|
|`MGMT01`|Centralised management, Windows Admin Center, WEF|`10.10.10.30`|`2 vCPU`|`4GB`|`50GB OS`|`LAB-SERVERS`|
|`CLIENT01`|Domain-joined client and validation workstation|DHCP-assigned: `10.10.20.100`|`2 vCPU`|`4GB`|`60GB OS`|`LAB-CLIENTS`|

## Network Design

|Hyper-V virtual switch|Purpose|Network|Routing and security notes|
|---|---|---|---|
|`LAB-WAN`|Upstream connectivity for RTR01|`172.16.0.0/24`|RTR01 provides NAT for lab traffic|
|`LAB-SERVERS`|Internal server network|`10.10.10.0/24`|Server-facing RTR01 interface; core services remain on this segment|
|`LAB-CLIENTS`|Client workstation network|`10.10.20.0/24`|Clients reach server services through RTR01; DHCP relay forwards requests to DHCP servers|

> <b>Traffic flow:</b> `CLIENT01` ↔ `RTR01` ↔ server network (`DC01`/`DC02`/`FS01`/`MGMT01`). Outbound traffic is routed/NATed through `RTR01` to `LAB-WAN`.

<b>Implementation references:</b> [Hyper-V Host and VMs](Documentation/Hyper-V%20%26%20Virtual%20Infrastructure/Hyper-V%20host%2C%20virtual%20switch%20and%20VM%20configuration.md) · [Network Architecture and Addressing](Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md) · [RRAS Routing and NAT](Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md)

## Identity, DNS and DHCP Resilience
- <b>Active Directory:</b> `DC01` and `DC02` provide domain services. Replication and domain authentication were validated, including during a controlled `DC01` outage.
- <b>DNS:</b> DNS service is present on both domain controllers. Internal/external name resolution was tested during loss of `DC01`.
- <b>DHCP:</b> `DC01` and `DC02` participate in DHCP failover. `RTR01` relays client DHCP traffic; lease acquisition was validated during the `DC01` failure scenario.

<b>Implementation and test evidence:</b> [AD DS](Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md) · [DNS and DHCP](Documentation/Domain-Controller/DNS%20and%20DHCP%20configuration.md) · [AD and DNS Resilience](Documentation/Domain-Controller/AD%20and%20DNS%20Resilience.md) · [DHCP Failover](Documentation/Domain-Controller/DHCP%20Failover.md)

## File Services, Management and Monitoring
- <b>FS01:</b> Dedicated file server with SMB shares and NTFS access controlled through an AD group-based permissions model (AGDLP).
- <b>MGMT01:</b> Dedicated administration and monitoring server, including Windows Admin Center and centralised event collection using Windows Event Forwarding (WEF).
- <b>Automation:</b> Five PowerShell scripts support infrastructure health checks, user onboarding, offboarding, configuration backups and centralised event reporting.

<b>Implementation references:</b> [File Services and NTFS](Documentation/File%20Services/File%20server%20and%20NTFS%20Access%20Control.md) · [Monitoring and Event Forwarding](Documentation/Monitoring%20and%20Logging/Centralised%20Monitoring%20and%20Event%20Forwarding.md) · [PowerShell Automation Overview](Documentation/PowerShell%20Automation/PowerShell%20Infrastructure%20Automation.md) · [Scripts](Scripts)

## Security, Recovery and Operational Controls
- <b>Security:</b> The environment uses OU-targeted Group Policy, Windows LAPS, Windows Firewall controls, least-privilege/group-based file access and account lifecycle safeguards. Security and administrative events are collected centrally where configured.
- <b>Recovery:</b> Windows Server Backup and application-specific recovery procedures were tested for files, Group Policy and Active Directory objects. Configuration-export scripts supplement - but do not replace - system backups.
- <b>Validation approach:</b> The project uses build evidence plus failure/recovery tests (including a `DC01` outage) to demonstrate operational behaviour instead of installation success alone.

<b>Implementation references:</b> [Group Policy](Documentation/Domain-Controller/Group%20Policy%20Configuration.md) · [Backup and Recovery](Documentation/Backup%20and%20Recovery/Windows%20Server%20Backup%20and%20Recovery.md) · [Infrastructure Configuration Backup](Documentation/PowerShell%20Automation/Infrastructure%20Configuration%20Backup.md)

## Known Limitations and Design Trade-offs

|Limitation|Practical Implication|
|---|---|
|Single physical Hyper-V host|Host failure affects all VMs; service redundancy does not equal host-level high availability.|
|Backup VHDXs remain within the same host environment|Supports recovery exercises, but not protection from loss of the host or underlying storage.|
|RRAS is a single routing/NAT point|Routing services are not highly available.|
|Lab-scale resources and workload|Tests validate the lab scenarios, not production-scale capacity, performance or SLA compliance.|
|No Azure integration in this repository|Hybrid/cloud architecture is intentionally reserved for a separate project.|

## Documentation Map and Project Boundary
- <b>Phase 1:</b> Initial Hyper-V, network, AD DS, DNS/DHCP, GPO and file-services build (historical baseline).
- <b>Phase 2:</b> AD/DNS/DHCP resilience, backup/recovery, centralised management and monitoring, and PowerShell automation (final on-premises state).
- <b>Separate Azure project:</b> — Future project to extend this completed on-premises environment without altering the scope of this project.
---
#### Return to the [Main Project README](README.md).
