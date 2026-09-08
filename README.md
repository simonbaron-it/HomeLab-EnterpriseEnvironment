# Home Lab - Enterprise-Style Infrastructure Environment
> A multi-server Windows infrastructure lab built with Windows Server 2025 and Hyper-V to develop practical Infrastructure Engineering, networking, virtualisation, security and systems administration skills.

## Project Overview
This project is a self-built home lab designed to simulate the core infrastructure of a small organisation. 

The environment is hosted using Hyper-V and consists of multiple Windows Server and Windows 11 virtual machines with dedicated roles for networking, identity, file services and client testing. The lab uses a dedicated Routing and Remote Access Service (RRAS) server to provide routing and NAT between the isolated lab network and the external network. 

All labs are documented with Markdown files and screenshots for clarity and portfolio presentation.

## Current Lab Environment:
<p align="center">
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/Network%20Diagram.png" width="500"/>
</p>

## Lab Documentation
### Hyper-V & Virtual Infrastructure
- [Hyper-V host, virtual switch and virtual machine configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Hyper-V%20%26%20Virtual%20Infrastructure/Hyper-V%20host%2C%20virtual%20switch%20and%20VM%20configuration.md)

### Networking & RRAS
- [Network architecture and IP addressing](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/Network%20architecture%20and%20IP%20addressing.md)
- [RRAS routing and NAT configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Networking%20%26%20RRAS/RRAS%20Routing%20and%20NAT%20Configuration.md)

### Domain Controller
- [Active Directory Domain setup, OU structure and security groups](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active%20Directory%20Domain%20Services.md)
- [DNS and DHCP Configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS%20and%20DHCP%20configuration.md)
- [Group Policy configuration](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Group%20Policy%20Configuration.md)

### File Services
- [File server and NTFS Access Control](https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Documentation/File%20Services/File%20server%20and%20NTFS%20Access%20Control.md)
 
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
