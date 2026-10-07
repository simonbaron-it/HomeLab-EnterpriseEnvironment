# Windows Server 2025 Enterprise-Style Infrastructure Lab
> A multi-server Windows infrastructure lab demonstrating infrastructure engineering, networking, virtualisation, security and systems administration skills using Windows Server 2025 and Hyper-V.

## Project Overview
This project is a self-built Windows infrastructure environment designed to simulate the core IT services and operational practices of a small organisation.

Hosted on Hyper-V, the environment uses dedicated Windows Server 2025 virtual machines for routing, identity, file services, centralised management and monitoring, alongside a Windows 11 domain workstation. Segmented server and client networks are connected through a dedicated RRAS router providing inter-subnet routing, NAT and DHCP relay.

The environment includes redundant Active Directory, DNS and DHCP services across multiple Domain Controllers, centralised file services with AGDLP-based access control, Group Policy and Windows LAPS, Windows Server backup and recovery, Windows Event Forwarding, security auditing, infrastructure monitoring and PowerShell-based administration.

> Phase 2 expands the lab beyond core infrastructure deployment into resilience and operations, with Active Directory and DNS redundancy, DHCP failover, tested backup and recovery procedures, centralised monitoring and logging, and PowerShell automation for health checks, user lifecycle management, configuration backup and operational reporting.

## Current Lab Environment: `Phase 2 Complete`
<p align="center">
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Images/Phase%202%20Network%20Diagram.png" width="700"/>
</p>

## Lab Documentation
### Phase 1 - Core Infrastructure
> #### Hyper-V & Virtual Infrastructure
> - [Hyper-V Host, Virtual Switch and Virtual Machine Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Hyper-V%20%26%20Virtual%20Infrastructure/Hyper-V%20host%2C%20virtual%20switch%20and%20VM%20configuration.md)
>
> #### Networking & RRAS
> - [Network Architecture and IP Addressing](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md)
> - [RRAS Routing and NAT Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md)
>
> #### Domain Controller
> - [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md)
> - [DNS and DHCP Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS%20and%20DHCP%20configuration.md)
> - [Group Policy Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Group%20Policy%20Configuration.md)
>
> #### File Services
> - [File Server and NTFS Access Control](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/File%20Services/File%20server%20and%20NTFS%20Access%20Control.md)
>
### Phase 2 - Resilience & Operations
> #### Resilience and High Availability
> - [Active Directory and DNS Resilience](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/AD%20and%20DNS%20Resilience.md)
> - [DHCP Failover](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/DHCP%20Failover.md)
>
> #### Backup & Recovery
> - [Windows Server Backup and Recovery](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Backup%20and%20Recovery/Windows%20Server%20Backup%20and%20Recovery.md)
>
> #### Monitoring & Logging
> - [Centralised Monitoring and Event Forwarding](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Monitoring%20and%20Logging/Centralised%20Monitoring%20and%20Event%20Forwarding.md)
>
> #### PowerShell Automation
 
## Skills Demonstrated
- Build and configure a multi-server Windows Server 2025 infrastructure environment using Hyper-V.
- Deploy and manage virtual machines, virtual switches and segmented client/server networks.
- Configure IPv4 addressing, multi-NIC routing, RRAS, NAT and DHCP relay.
- Deploy and administer Active Directory Domain Services, including OU design, users, computers and security groups.
- Configure AD-integrated DNS, DHCP scopes and cross-subnet DHCP delivery.
- Create and apply Group Policy for workstation security, drive mappings, local administrator access and Windows LAPS.
- Configure Windows File Services, SMB shares and AGDLP-based NTFS permissions using least-privilege principles.
- Validate and troubleshoot infrastructure configuration using Windows administration tools, networking utilities and PowerShell.

## Project Roadmap

### Phase 3 — Hybrid Azure
- Extend the environment into Azure.
- Implement hybrid identity and networking.
- Explore Azure infrastructure services and management.
- Introduce Infrastructure as Code for Azure deployments.
