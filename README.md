# Windows Server 2025 Enterprise-Style Infrastructure Lab
> A multi-server Windows infrastructure lab demonstrating infrastructure engineering, networking, virtualisation, security and systems administration skills using Windows Server 2025 and Hyper-V.

## Project Overview
This project is a self-built Windows infrastructure environment designed to simulate the core IT services of a small organisation.

Hosted on Hyper-V, the environment uses dedicated Windows Server 2025 virtual machines for routing, identity and file services, alongside a Windows 11 domain workstation. Segmented server and client networks are connected through a dedicated RRAS router providing inter-subnet routing, NAT and DHCP relay.

The project focuses on practical infrastructure engineering, including Active Directory, DNS, DHCP, Group Policy, Windows LAPS, SMB/NTFS access control and PowerShell-based validation.

## Current Lab Environment: `Phase 1 Complete`
<p align="center">
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Network%20Diagram.png" width="500"/>
</p>

## Lab Documentation
> ### Phase 1 - Core Infrastructure
### Hyper-V & Virtual Infrastructure
- [Hyper-V Host, Virtual Switch and Virtual Machine Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Hyper-V%20%26%20Virtual%20Infrastructure/Hyper-V%20host%2C%20virtual%20switch%20and%20VM%20configuration.md)

### Networking & RRAS
- [Network Architecture and IP Addressing](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md)
- [RRAS Routing and NAT Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md)

### Domain Controller
- [Active Directory Domain Services](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md)
- [DNS and DHCP Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS%20and%20DHCP%20configuration.md)
- [Group Policy Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Group%20Policy%20Configuration.md)

### File Services
- [File Server and NTFS Access Control](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/File%20Services/File%20server%20and%20NTFS%20Access%20Control.md)

> ### Phase 2 - Resilience & Operations
### Resilience and High Availability
- [Active Directory and DNS Resilience](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/AD%20and%20DNS%20Resilience.md)
- [DHCP Failover](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Domain-Controller/DHCP%20Failover.md)

### Backup & Recovery
- [Windows Server Backup and Recovery](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/Phase-2/Documentation/Backup%20and%20Recovery/Windows%20Server%20Backup%20and%20Recovery.md)

### Monitoring & Logging

### PowerShell Automation
 
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

### Phase 2 — Resilience & Operations
- Automate common infrastructure administration and validation tasks using PowerShell.
- Deploy a second Domain Controller and configure Active Directory/DNS replication + DHCP Failover.
- Implement and test backup and recovery procedures.
- Introduce centralised monitoring and logging for infrastructure health and troubleshooting.

### Phase 3 — Hybrid Azure
- Extend the environment into Azure.
- Implement hybrid identity and networking.
- Explore Azure infrastructure services and management.
- Introduce Infrastructure as Code for Azure deployments.
