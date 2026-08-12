# Home Lab - Enterprise Infrastructure Management
A virtualised enterprise-style infrastructure lab built using <b>VMWare Workstation Pro</b> to develop practical Infrastructure Engineering skills.

## Project Overview
This project is a self-built home lab designed to simulate an enterprise IT environment. The environment was built using <b>VMWare Workstation Pro</b> and consists of multiple virtual machines running <b>Windows Server 2022</b> and <b>Windows 11</b> to represent a small business network. All labs are documented with Markdown files and screenshots for clarity and portfolio presentation.

<b>Current Lab Environment:</b>
- <b>Windows Server 2022 Domain Controller</b>
  - Active Directory, DNS, DHCP, Group Policy
- <b>Windows Server 2022 File Server</b>
  - Network File Share, NTFS Permissions
- <b>Windows 11 Client Workstation</b>
  - To validate successful domain join, group policy and NTFS permissions. 

<b>Next:</b>
- VLAN's/Network Segmentation
- Backup & Disaster Recovery
- Monitoring & Alerts
- Linux Server
- Infrastructure Automation
- Azure Migration

## Lab Documentation
- #### Network Architecture
  - [Network-Architecture.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Network-Achitecture.md) - Network topology, IP configuration, DNS, DHCP.
- #### Windows Server 2022 - Domain Controller
  - [Active-Directory.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Active-Directory.md) - Domain setup, Organisational Unit structure, security groups.
  - [Group-Policy.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/Group-Policy.md) - Group Policy Objects enforced.
  - [DNS-DHCP.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS-DHCP.md) - DNS/DHCP setup and configuration.
- #### Windows Server 2022 - File Server
  - [NTFS-Permissions.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/File-Server/NTFS-Permissions.md) - Shared file structure, NTFS permissions.
- #### Windows 11 - Workstation
  - [Domain-join.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/Domain-Join.md) - Successful domain join, DNS & DHCP contact.    
  - [GPO-Checks.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/GPO-Checks.md) - Group Policy Object validation.
  - [NTFS-Validation.md](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/NTFS-Validation.md) - Verifying NTFS permissions are configured correctly.
 
## Skills Demonstrated
- Build a virtualised Windows Server environment from scratch.
- Deploy an Active Directory domain.
- Configure DNS and DHCP.
- Create organisational units, users and security groups.
- Implement Group Policy.
- Join Windows client machines to the domain.
- Configure file shares and NTFS permissions.

