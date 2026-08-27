# Active Directory Domain Services

> This section documents the deployment and configuration of <b>AD DS</b> within my Windows Server home lab.
> 
> The objective was to build a structured Active Directory environment that simulates how identity, computers, departments and access could be managed within a small organisation.

## Overview
Active Directory Domain Services was installed on my Windows Server Domain Controller to provide centralised:

> - User and computer authentication
> - User and computer management
> - Security group management
> - Organisational Unit management
> - Group Policy management
> - DNS & DHCP services
> - Role-based access to resources

## Domain Configuration
I installed the <b>Active Directory Domain Services</b> server role and promoted <b>DC01</b> to a domain controller.

A new Active Directory Forest was created using: `Baron.local`

The domain controller also provides DNS & DHCP services - Detailed in the [DNS & DHCP configuration](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Domain-Controller/DNS-DHCP.md) section.

|Component|Configuration|
|---------|-------------|
|`Domain Controller`|`DC01`|
|`Operating System`|`Windows Server 2022`|
|`Domain Controller IP`|`192.168.162.10`|
|`AD Domain Name`|`Baron.local`|
|`DNS Server`|`192.168.162.10`|
|`DHCP Server`|`192.168.162.10`|

> I deployed a single forest and domain because the lab represents a small organisation and does not require the administrative complexity of multiple domains. DC01 was configured with a static IP address because infrastructure services such as Active Directory and DNS require predictable network addressing. DHCP was configured for Client workstations connecting to the domain.

<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/AD%20DS.JPG" width="700" height="700"/>

## Organisational Unit Structure
> Rather than storing users and computers within the default Active Directory containers, I created a custom OU structure to provide clearer organisation and allow Group Policy to be targeted at specific users, computers and departments.

### OU Structure:
<img src="https://github.com/simonbaron-it/HomeLab-EnterpriseEnvironment/blob/main/Images/OU%20Structure.JPG" width="400" height="600"/>

### OU Design Decisions
The structure separates different Active Directory objects based on their purpose.  
> - `Users` are separated by department to allow department-specific policies to be applied where required.
> - `Computers` are separated from user accounts so computer-based Group Policies can be targeted independently.  
> - `Servers` are separated from standard workstations because servers require different configuration and security policies.  
> - `Security Groups` provide a logical location for groups used to define role configuration and control access to resources.   

## User Accounts
> 20 test user accounts were created to represent employees from different departments within the organisation. These users were placed into their corresponding departmental OUs and assigned appropriate security group memberships.

### Naming Convention
User accounts follow a `[first initial]` `[surname]` naming convention.

#### Examples:
|User|Username|Department|OU|
|----|--------|----------|--|
|`Simon Baron`|`sbaron`|`IT`|`IT`|
|`example2`|`example2`|`HR`|`HR`|
|`example3`|`example3`|`Finance`|`Finance`|
|`example4`|`example4`|`Sales`|`Sales`|

<i>Screenshot?</i>

## Security Groups
> Security groups were created to manage permissions using group-based access rather than assigning permissions directly to individual users.

|Security Group|Scope|Purpose|
|----|--------|----------|
|`SecurityGroup1`|`Global`|`Group Purpose`|
|`SecurityGroup2`|`Global`|`Group Purpose`|
|`SecurityGroup3`|`Global`|`Group Purpose`|
|`SecurityGroup4`|`Global`|`Group Purpose`|

<i>Screenshot?</i>

## Servers and Domain Joined Computers
> Windows machines were joined to the `Baron.local` domain to allow for centralised authentication and management.

|Computer|Operating System|OU|IP Configuration|Role|
|----|--------|----------|--|---|
|`File01`|`Windows Server 2022`|`Servers`|`Static` `192.168.162.20`|`File Server`|
|`Client01`|`Windows 11`|`Computers`|`DHCP` `192.168.162.101`|`Client Workstation`|
|`Client02`|`Windows 11`|`Computers`|`DHCP` `192.168.162.102`|`Client Workstation`|

### Validation
> Domain connectivity was tested by signing into client machines using domain user accounts. Once signed in, these accounts were used to verify DNS & DHCP configuration, then test Group Policy and NTFS Permissions. I have documented the results [in this section.](https://github.com/Simonb316/HomeLab-EnterpriseEnvironment/blob/main/Documentation/Workstation/Domain-Join.md)

## Administrative Accounts?

## Security Considerations?

