# Windows Server 2025 Enterprise-Style Infrastructure Lab
> A multi-server Windows infrastructure lab demonstrating infrastructure engineering, networking, virtualisation, security and systems administration skills using Windows Server 2025 and Hyper-V.

## Project Overview
This project is a self-built Windows infrastructure environment designed to simulate the core IT services and operational practices of a small organisation.

Hosted on Hyper-V, the environment uses dedicated Windows Server 2025 virtual machines for routing, identity, file services, centralised management and monitoring, alongside a Windows 11 domain workstation. Segmented server and client networks are connected through a dedicated RRAS router providing inter-subnet routing, NAT and DHCP relay.

The environment includes redundant Active Directory, DNS and DHCP services across multiple Domain Controllers, centralised file services with AGDLP-based access control, Group Policy and Windows LAPS, Windows Server backup and recovery, Windows Event Forwarding, security auditing, infrastructure monitoring and PowerShell-based administration.

> Phase 2 expands the lab beyond core infrastructure deployment into resilience and operations, with Active Directory and DNS redundancy, DHCP failover, tested backup and recovery procedures, centralised monitoring and logging, and PowerShell automation for health checks, user lifecycle management, configuration backup and operational reporting.

## Key Achievements
- Designed and deployed a segmented Windows Server 2025 enterprise environment using Hyper-V, Active Directory and RRAS.
- Implemented redundant domain controllers, DNS and DHCP failover, validating service continuity through controlled outage testing.
- Secured enterprise resources using Group Policy, Windows LAPS and role-based NTFS permissions.
- Implemented and tested backup and recovery procedures for Active Directory objects, Group Policy and file services.
- Developed five PowerShell scripts for infrastructure monitoring, backup exports, event reporting and user lifecycle automation.

## Current Lab Environment: `Complete - Phases 1 & 2`
<p align="center">
<img src="Images/Phase%202%20Network%20Diagram.png" width="700"/>
</p>

## Lab Documentation
- ### [Final Architecture Overview](Documentation/Final%20Architecture%20Overview.md)
### Phase 1 - Core Infrastructure
> #### Hyper-V & Virtual Infrastructure
> - [Hyper-V Host, Virtual Switch and Virtual Machine Configuration](Documentation/Hyper-V%20%26%20Virtual%20Infrastructure/Hyper-V%20host%2C%20virtual%20switch%20and%20VM%20configuration.md)
>
> #### Networking & RRAS
> - [Network Architecture and IP Addressing](Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md)
> - [RRAS Routing and NAT Configuration](Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md)
>
> #### Domain Controller
> - [Active Directory Domain Services](Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md)
> - [DNS and DHCP Configuration](Documentation/Domain-Controller/DNS%20and%20DHCP%20configuration.md)
> - [Group Policy Configuration](Documentation/Domain-Controller/Group%20Policy%20Configuration.md)
>
> #### File Services
> - [File Server and NTFS Access Control](Documentation/File%20Services/File%20server%20and%20NTFS%20Access%20Control.md)
>
### Phase 2 - Resilience & Operations
> #### Resilience and High Availability
> - [Active Directory and DNS Resilience](Documentation/Domain-Controller/AD%20and%20DNS%20Resilience.md)
> - [DHCP Failover](Documentation/Domain-Controller/DHCP%20Failover.md)
>
> #### Backup & Recovery
> - [Windows Server Backup and Recovery](Documentation/Backup%20and%20Recovery/Windows%20Server%20Backup%20and%20Recovery.md)
>
> #### Monitoring & Logging
> - [Centralised Monitoring and Event Forwarding](Documentation/Monitoring%20and%20Logging/Centralised%20Monitoring%20and%20Event%20Forwarding.md)
>
> #### PowerShell Automation
>  - [PowerShell Infrastructure Automation Overview](Documentation/PowerShell%20Automation/PowerShell%20Infrastructure%20Automation.md)
>    - [Infrastructure Health Check](Documentation/PowerShell%20Automation/Infrastructure%20Health%20Check.md)
>    - [Active Directory User Onboarding](Documentation/PowerShell%20Automation/Active%20Directory%20User%20Onboarding.md)
>    - [Active Directory User Offboarding](Documentation/PowerShell%20Automation/Active%20Directory%20User%20Offboarding.md)
>    - [Infrastructure Configuration Backup](Documentation/PowerShell%20Automation/Infrastructure%20Configuration%20Backup.md)
>    - [Centralised Event Reporting](Documentation/PowerShell%20Automation/Centralised%20Event%20Reporting.md) 
 
## Skills Demonstrated
- Build and administer a multi-server Windows Server 2025 infrastructure environment using Hyper-V.
- Configure virtual machines, virtual switches, segmented networks, IPv4 routing, RRAS, NAT and DHCP relay.
- Deploy and manage Active Directory Domain Services, including OU design, users, computers, security groups and redundant Domain Controllers.
- Configure resilient AD-integrated DNS and DHCP services, including replication, failover and cross-subnet client delivery.
- Implement Group Policy, Windows LAPS, SMB file services and AGDLP-based NTFS permissions using least-privilege principles.
- Design and validate backup and recovery for Active Directory, file services, Group Policy and DHCP configuration.
- Implement centralised administration, monitoring and logging using Windows Admin Center, Server Manager and Windows Event Forwarding.
- Automate infrastructure health checks, user lifecycle tasks, configuration backup, event reporting and troubleshooting using PowerShell.
