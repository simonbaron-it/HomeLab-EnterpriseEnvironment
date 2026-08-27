# Home Lab - Enterprise-Style Infrastructure Environment
> A multi-server Windows infrastructure lab built with Windows Server 2025 and Hyper-V to develop practical Infrastructure Engineering, networking, virtualisation, security and systems administration skills.

## Project Overview
This project is a self-built home lab designed to simulate the core infrastructure of a small organisation. 

The environment is hosted using Hyper-V and consists of multiple Windows Server and Windows 11 virtual machines with dedicated roles for networking, identity, file services and client testing. The lab uses a dedicated Routing and Remote Access Service (RRAS) server to provide routing and NAT between the isolated lab network and the external network. 

All labs are documented with Markdown files and screenshots for clarity and portfolio presentation.

## Current Lab Environment:
### RTR01 - Network/Routing Server  
- <b>Operating system:</b> Windows Server 2025  
- <b>Roles:</b> `RRAS` `Routing` `NAT` `Hyper-V Networking`

### DC01 - Domain Controller  
- <b>Operating system:</b> Windows Server 2025  
- <b>Roles:</b> `Active Directory` `DNS` `DHCP` `Group Policy`

### FS01 - File Server
- <b>Operating system:</b> Windows Server 2025 
- <b>Roles:</b> `SMB` `File Services` `NTFS Permissions`

### CLIENT01 - Domain Workstation
- <b>Operating System:</b> Windows 11  
- <b>Roles:</b> `Testing` `Validation` 

## Lab Documentation
### Hyper-V & Virtual Infrastructure
- Hyper-V host and virtual switch configuration
- Virtual machine design and configuration

### Networking & RRAS
- Network architecture and IP addressing
- RRAS routing and NAT configuration
- Network testing and validation

### Domain Controller
- Active Directory Domain setup, OU structure and security groups
- Group Policy configuration
- DNS and DHCP configuration

### File Services
- File server setup and SMB share structure
- NTFS permissions and access-control model

### Windows Client
- Domain join and client configuration
- DNS and DHCP validation
- Group Policy validation
- File-share and NTFS permission validation

<i>Old docs</i>
- #### Network Architecture
  - [Network topology, IP configuration](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Network-Achitecture.md)
- #### Windows Server 2022 - Domain Controller
  - [Domain setup, Organisational Unit structure, security groups](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active-Directory.md)
  - [Group Policy Objects](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Group-Policy.md)
  - [DNS/DHCP setup and configuration](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS-DHCP.md)
- #### Windows Server 2022 - File Server
  - [Shared file structure, NTFS permissions](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/File-Server/NTFS-Permissions.md)
- #### Windows 11 - Workstation
  - [Successful domain join, DNS & DHCP contact](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/Domain-Join.md)   
  - [Group Policy Object validation](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/GPO-Checks.md)
  - [NTFS permission validation](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/NTFS-Validation.md)
 
## Skills Demonstrated:
- Build and configure a multi-VM Windows Server 2025 infrastructure environment with dedicated networking, domain, file server and client roles.
- Deploy and manage virtual machines, virtual switches and isolated virtual networks using Hyper-V.
- Configure multi-NIC Windows Server networking, including RRAS and NAT.
- Plan and implement IPv4 addressing for servers and client devices.
- Deploy and administer Active Directory Domain Services, including a domain, Organisational Unit structure and security group model.
- Create and manage domain users, computers and security groups.
- Configure AD-integrated DNS and troubleshoot name resolution.
- Configure DHCP scopes, options and automatic client IP addressing.
- Join Windows 11 client machines to an Active Directory domain.
- Create and apply Group Policy Objects for centralised user, workstation and security configuration.
- Configure Windows File Services and SMB network shares.
- Implement group-based NTFS permissions using least-privilege principles.
- Test and troubleshoot DNS, DHCP, routing, authentication, Group Policy and file permissions from domain-joined clients.
- Document infrastructure architecture, configuration decisions, testing and troubleshooting.

## Future Improvements:  
Planned expansions to the environment include:
> - Automate infrastructure administration with PowerShell.
> - Deploy a second Domain Controller and configure AD/DNS replication.
> - Implement backup and recovery testing.
> - Introduce centralised monitoring and logging.
> - Add Linux Server administration to the environment.
> - Extend the lab into Azure to explore hybrid infrastructure. 
